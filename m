Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9319003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:57 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142029087pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q2si35857477pdo.21.2015.08.25.18.33.56
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:56 -0700 (PDT)
Subject: [PATCH v2 9/9] devm_memremap_pages: protect against pmem device
 unbind
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:28:13 -0400
Message-ID: <20150826012813.8851.35482.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

Given that:

1/ device ->remove() can not be failed

2/ a pmem device may be unbound at any time

3/ we do not know what other parts of the kernel are actively using a
   'struct page' from devm_memremap_pages()

...provide a facility for active usages of device memory to block pmem
device unbind.  With a percpu_ref it should be feasible to take a
reference on a per-I/O or other high frequency basis.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/io.h |   37 ++++++++++++++++++++++
 kernel/memremap.c  |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 123 insertions(+), 3 deletions(-)

diff --git a/include/linux/io.h b/include/linux/io.h
index de64c1e53612..e20cc04f42b7 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -90,8 +90,31 @@ void devm_memunmap(struct device *dev, void *addr);
 void *__devm_memremap_pages(struct device *dev, struct resource *res);
 
 #ifdef CONFIG_ZONE_DEVICE
+#include <linux/percpu-refcount.h>
+#include <linux/ioport.h>
+#include <linux/list.h>
+
+struct page_map {
+	struct resource res;
+	struct list_head list;
+	unsigned long flags;
+	struct percpu_ref percpu_ref;
+	struct device *dev;
+};
+
 void *devm_memremap_pages(struct device *dev, struct resource *res);
+struct page_map * __must_check get_page_map(resource_size_t addr);
+static inline void ref_page_map(struct page_map *page_map)
+{
+	percpu_ref_get(&page_map->percpu_ref);
+}
+
+static inline void put_page_map(struct page_map *page_map)
+{
+	percpu_ref_put(&page_map->percpu_ref);
+}
 #else
+struct page_map;
 static inline void *devm_memremap_pages(struct device *dev, struct resource *res)
 {
 	/*
@@ -102,6 +125,20 @@ static inline void *devm_memremap_pages(struct device *dev, struct resource *res
 	WARN_ON_ONCE(1);
 	return ERR_PTR(-ENXIO);
 }
+
+static inline __must_check struct page_map *get_page_map(resource_size_t addr)
+{
+	return NULL;
+}
+
+static inline void ref_page_map(struct page_map *page_map)
+{
+	return false;
+}
+
+static inline void put_page_map(struct page_map *page_map)
+{
+}
 #endif
 
 /*
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 72b0c66628b6..65a6c9396062 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -12,6 +12,8 @@
  */
 #include <linux/device.h>
 #include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/memory_hotplug.h>
@@ -138,14 +140,66 @@ void devm_memunmap(struct device *dev, void *addr)
 EXPORT_SYMBOL(devm_memunmap);
 
 #ifdef CONFIG_ZONE_DEVICE
-struct page_map {
-	struct resource res;
+static DEFINE_MUTEX(page_map_lock);
+static DECLARE_WAIT_QUEUE_HEAD(page_map_wait);
+static LIST_HEAD(page_maps);
+
+enum {
+	PAGE_MAP_LIVE,
+	PAGE_MAP_CONFIRM,
 };
 
+static struct page_map *to_page_map(struct percpu_ref *ref)
+{
+	return container_of(ref, struct page_map, percpu_ref);
+}
+
+static void page_map_release(struct percpu_ref *ref)
+{
+	struct page_map *page_map = to_page_map(ref);
+
+	/* signal page_map is idle (no more refs) */
+	clear_bit(PAGE_MAP_LIVE, &page_map->flags);
+	wake_up_all(&page_map_wait);
+}
+
+static void page_map_confirm(struct percpu_ref *ref)
+{
+	struct page_map *page_map = to_page_map(ref);
+
+	/* signal page_map is confirmed dead (slow path ref mode) */
+	set_bit(PAGE_MAP_CONFIRM, &page_map->flags);
+	wake_up_all(&page_map_wait);
+}
+
+static void page_map_destroy(struct page_map *page_map)
+{
+	long tmo;
+
+	/* flush new lookups */
+	mutex_lock(&page_map_lock);
+	list_del_rcu(&page_map->list);
+	mutex_unlock(&page_map_lock);
+	synchronize_rcu();
+
+	percpu_ref_kill_and_confirm(&page_map->percpu_ref, page_map_confirm);
+	do {
+		tmo = wait_event_interruptible_timeout(page_map_wait,
+			!test_bit(PAGE_MAP_LIVE, &page_map->flags)
+			&& test_bit(PAGE_MAP_CONFIRM, &page_map->flags), 5*HZ);
+		if (tmo <= 0)
+			dev_dbg(page_map->dev,
+					"page map active, continuing to wait...\n");
+	} while (tmo <= 0);
+}
+
 static void devm_memremap_pages_release(struct device *dev, void *res)
 {
 	struct page_map *page_map = res;
 
+	if (test_bit(PAGE_MAP_LIVE, &page_map->flags))
+		page_map_destroy(page_map);
+
 	/* pages are dead and unused, undo the arch mapping */
 	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
 }
@@ -155,7 +209,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 	int is_ram = region_intersects(res->start, resource_size(res),
 			"System RAM");
 	struct page_map *page_map;
-	int error, nid;
+	int error, nid, rc;
 
 	if (is_ram == REGION_MIXED) {
 		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
@@ -172,6 +226,12 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 		return ERR_PTR(-ENOMEM);
 
 	memcpy(&page_map->res, res, sizeof(*res));
+	INIT_LIST_HEAD(&page_map->list);
+	page_map->dev = dev;
+	rc = percpu_ref_init(&page_map->percpu_ref, page_map_release, 0,
+				GFP_KERNEL);
+	if (rc)
+		return ERR_PTR(rc);
 
 	nid = dev_to_node(dev);
 	if (nid < 0)
@@ -183,8 +243,31 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 		return ERR_PTR(error);
 	}
 
+	set_bit(PAGE_MAP_LIVE, &page_map->flags);
+	mutex_lock(&page_map_lock);
+	list_add_rcu(&page_map->list, &page_maps);
+	mutex_unlock(&page_map_lock);
+
 	devres_add(dev, page_map);
 	return __va(res->start);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
+
+struct page_map * __must_check get_page_map(resource_size_t addr)
+{
+	struct page_map *page_map, *ret = NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(page_map, &page_maps, list) {
+		if (addr >= page_map->res.start && addr <= page_map->res.end) {
+			if (percpu_ref_tryget(&page_map->percpu_ref))
+				ret = page_map;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(get_page_map);
 #endif /* CONFIG_ZONE_DEVICE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
