Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 83D436B0257
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:56:07 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so14452029pdr.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:56:07 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dp6si1489242pdb.233.2015.08.12.20.56.06
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:56:06 -0700 (PDT)
Subject: [RFC PATCH 4/7] mm: register_dev_memmap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:23 -0400
Message-ID: <20150813035023.36913.56455.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

Provide an interface for device drivers to register physical memory

The register_dev_memmap() api enables a device driver like pmem to setup
struct page entries for the memory it has discovered.  While this
mechanism is motivated by the desire to use persistent memory outside of
the block I/O and direct access (DAX) paths, this mechanism is generic
for any physical range that is not marked as RAM at boot.

Given capacities for the registered memory range may be too large to
house the memmap in RAM, this interface allows for the memmap to be
allocated from the new range being registered.  The pmem driver uses
this capability to let userspace policy determine the placement of the
memmap for peristent memory.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/kmap_pfn.h |   33 ++++++++
 include/linux/mm.h       |    4 +
 mm/kmap_pfn.c            |  195 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 231 insertions(+), 1 deletion(-)

diff --git a/include/linux/kmap_pfn.h b/include/linux/kmap_pfn.h
index fa44971d8e95..2dfad83337ba 100644
--- a/include/linux/kmap_pfn.h
+++ b/include/linux/kmap_pfn.h
@@ -4,7 +4,9 @@
 #include <linux/highmem.h>
 
 struct device;
+struct dev_map;
 struct resource;
+struct vmem_altmap;
 #ifdef CONFIG_KMAP_PFN
 extern void *kmap_atomic_pfn_t(__pfn_t pfn);
 extern void kunmap_atomic_pfn_t(void *addr);
@@ -28,4 +30,35 @@ static inline int devm_register_kmap_pfn_range(struct device *dev,
 }
 #endif /* CONFIG_KMAP_PFN */
 
+#ifdef CONFIG_ZONE_DEVICE
+struct dev_map *__register_dev_memmap(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap, struct module *mod);
+void unregister_dev_memmap(struct dev_map *dev_map);
+struct dev_map * __must_check try_pin_devpfn_range(__pfn_t pfn);
+void unpin_devpfn_range(struct dev_map *dev_map);
+#else
+static inline struct dev_map *__register_dev_memmap(struct device *dev,
+		struct resource *res, struct vmem_altmap *altmap,
+		struct module *mod)
+{
+	return NULL;
+}
+
+static inline void unregister_dev_memmap(struct dev_map *dev_map)
+{
+}
+
+static inline struct dev_map * __must_check try_pin_devpfn_range(__pfn_t pfn)
+{
+	return NULL;
+}
+
+static inline void unpin_devpfn_range(struct dev_map *dev_map)
+{
+}
+#endif
+
+#define register_dev_memmap(d, r, a) \
+__register_dev_memmap((d), (r), (a), THIS_MODULE)
+
 #endif /* _LINUX_KMAP_PFN_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8a4f24d7fdb0..07152a54b841 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -939,6 +939,7 @@ typedef struct {
  * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap
+ * PFN_MAP - pfn is covered by a device specific memmap
  */
 enum {
 	PFN_MASK = (1UL << PAGE_SHIFT) - 1,
@@ -949,6 +950,7 @@ enum {
 #else
 	PFN_DEV = 0,
 #endif
+	PFN_MAP = (1UL << 3),
 };
 
 static inline __pfn_t pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
@@ -965,7 +967,7 @@ static inline __pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
 
 static inline bool __pfn_t_has_page(__pfn_t pfn)
 {
-	return (pfn.val & PFN_DEV) == 0;
+	return (pfn.val & PFN_DEV) == 0 || (pfn.val & PFN_MAP) == PFN_MAP;
 }
 
 static inline unsigned long __pfn_t_to_pfn(__pfn_t pfn)
diff --git a/mm/kmap_pfn.c b/mm/kmap_pfn.c
index 2d58e167dfbc..d60ac7463454 100644
--- a/mm/kmap_pfn.c
+++ b/mm/kmap_pfn.c
@@ -10,16 +10,36 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/percpu-refcount.h>
+#include <linux/kmap_pfn.h>
 #include <linux/rcupdate.h>
 #include <linux/rculist.h>
 #include <linux/highmem.h>
 #include <linux/device.h>
+#include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 
 static LIST_HEAD(ranges);
+static LIST_HEAD(dev_maps);
 static DEFINE_MUTEX(register_lock);
+static DECLARE_WAIT_QUEUE_HEAD(dev_map_wq);
+
+#ifndef CONFIG_MEMORY_HOTPLUG
+int __weak arch_add_dev_memory(int nid, u64 start, u64 size,
+		struct vmem_altmap *altmap)
+{
+	return -ENXIO;
+}
+#endif
+
+#ifndef CONFIG_MEMORY_HOTREMOVE
+int __weak arch_remove_dev_memory(u64 start, u64 size)
+{
+	return -ENXIO;
+}
+#endif
 
 struct kmap {
 	struct list_head list;
@@ -28,6 +48,22 @@ struct kmap {
 	void *base;
 };
 
+enum {
+	DEV_MAP_LIVE,
+	DEV_MAP_CONFIRM,
+};
+
+struct dev_map {
+	struct list_head list;
+	resource_size_t base;
+	resource_size_t end;
+	struct percpu_ref percpu_ref;
+	struct device *dev;
+	struct module *module;
+	struct vmem_altmap *altmap;
+	unsigned long flags;
+};
+
 static void teardown_kmap(void *data)
 {
 	struct kmap *kmap = data;
@@ -115,3 +151,162 @@ void kunmap_atomic_pfn_t(void *addr)
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(kunmap_atomic_pfn_t);
+
+#ifdef CONFIG_ZONE_DEVICE
+static struct dev_map *to_dev_map(struct percpu_ref *ref)
+{
+	return container_of(ref, struct dev_map, percpu_ref);
+}
+
+static void dev_map_release(struct percpu_ref *ref)
+{
+	struct dev_map *dev_map = to_dev_map(ref);
+
+	/* signal dev_map is idle (no more refs) */
+	clear_bit(DEV_MAP_LIVE, &dev_map->flags);
+	wake_up_all(&dev_map_wq);
+}
+
+static void dev_map_confirm(struct percpu_ref *ref)
+{
+	struct dev_map *dev_map = to_dev_map(ref);
+
+	/* signal dev_map is confirmed dead (slow path ref mode) */
+	set_bit(DEV_MAP_CONFIRM, &dev_map->flags);
+	wake_up_all(&dev_map_wq);
+}
+
+static void kill_dev_map(struct dev_map *dev_map)
+{
+	percpu_ref_kill_and_confirm(&dev_map->percpu_ref, dev_map_confirm);
+	wait_event(dev_map_wq, test_bit(DEV_MAP_CONFIRM, &dev_map->flags));
+}
+
+struct dev_map *__register_dev_memmap(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap, struct module *mod)
+{
+	struct dev_map *dev_map;
+	int rc, nid;
+
+	if (IS_ENABLED(CONFIG_MEMORY_HOTPLUG)
+			&& IS_ENABLED(CONFIG_MEMORY_HOTREMOVE))
+		/* pass */;
+	else
+		return NULL;
+
+	dev_map = kzalloc(sizeof(*dev_map), GFP_KERNEL);
+	if (!dev_map)
+		return NULL;
+
+	if (altmap) {
+		dev_map->altmap = kmemdup(altmap, sizeof(*altmap), GFP_KERNEL);
+		if (!dev_map->altmap)
+			goto err_altmap;
+	}
+
+	if (!try_module_get(mod))
+		goto err_mod;
+
+	nid = dev_to_node(dev);
+	if (nid < 0)
+		nid = 0;
+	INIT_LIST_HEAD(&dev_map->list);
+	dev_map->dev = dev;
+	dev_map->base = res->start;
+	dev_map->end = res->end;
+	dev_map->module = mod;
+	set_bit(DEV_MAP_LIVE, &dev_map->flags);
+	if (percpu_ref_init(&dev_map->percpu_ref, dev_map_release, 0,
+				GFP_KERNEL))
+		goto err_ref;
+
+	mutex_lock(&register_lock);
+	list_add_rcu(&dev_map->list, &dev_maps);
+	mutex_unlock(&register_lock);
+
+	rc = arch_add_dev_memory(nid, res->start, resource_size(res), altmap);
+	if (rc) {
+		/*
+		 * It is safe to delete here without checking percpu_ref
+		 * since this dev_map is established before
+		 * ->direct_access() has advertised this pfn range to
+		 *  other parts of the kernel.
+		 */
+		mutex_lock(&register_lock);
+		list_del_rcu(&dev_map->list);
+		mutex_unlock(&register_lock);
+		synchronize_rcu();
+		goto err_add;
+	}
+
+	return dev_map;
+
+ err_add:
+	kill_dev_map(dev_map);
+ err_ref:
+	module_put(mod);
+ err_mod:
+	kfree(dev_map->altmap);
+ err_altmap:
+	kfree(dev_map);
+	return NULL;
+
+}
+EXPORT_SYMBOL_GPL(__register_dev_memmap);
+
+void unregister_dev_memmap(struct dev_map *dev_map)
+{
+	u64 size;
+
+	if (!dev_map)
+		return;
+
+	/* block new references */
+	kill_dev_map(dev_map);
+
+	/* block new lookups */
+	mutex_lock(&register_lock);
+	list_del_rcu(&dev_map->list);
+	mutex_unlock(&register_lock);
+
+	/* flush pending lookups, and wait for pinned ranges */
+	synchronize_rcu();
+	wait_event(dev_map_wq, !test_bit(DEV_MAP_LIVE, &dev_map->flags));
+
+	/* pages are dead and unused, undo the arch mapping */
+	size = dev_map->end - dev_map->base + 1;
+	arch_remove_dev_memory(dev_map->base, size, dev_map->altmap);
+	module_put(dev_map->module);
+	kfree(dev_map->altmap);
+	kfree(dev_map);
+}
+EXPORT_SYMBOL_GPL(unregister_dev_memmap);
+
+struct dev_map * __must_check try_pin_devpfn_range(__pfn_t pfn)
+{
+	phys_addr_t addr = __pfn_t_to_phys(pfn);
+	struct dev_map *ret = NULL;
+	struct dev_map *dev_map;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(dev_map, &dev_maps, list) {
+		if (addr >= dev_map->base && addr <= dev_map->end) {
+			if (percpu_ref_tryget_live(&dev_map->percpu_ref))
+				ret = dev_map;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(try_pin_devpfn_range);
+
+void unpin_devpfn_range(struct dev_map *dev_map)
+{
+	if (dev_map)
+		percpu_ref_put(&dev_map->percpu_ref);
+
+}
+EXPORT_SYMBOL_GPL(unpin_devpfn_range);
+#endif /* ZONE_DEVICE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
