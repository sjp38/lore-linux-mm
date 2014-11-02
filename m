Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B02EC6B010D
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 23:16:06 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id m15so3495571wgh.21
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 20:16:05 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bh10si18588815wjc.97.2014.11.01.20.16.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Nov 2014 20:16:05 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: page_cgroup: rename file to mm/swap_cgroup.c
Date: Sat,  1 Nov 2014 23:15:55 -0400
Message-Id: <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Now that the external page_cgroup data structure and its lookup is
gone, the only code remaining in there is swap slot accounting.

Rename it and move the conditional compilation into mm/Makefile.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 MAINTAINERS                 |   2 +-
 include/linux/page_cgroup.h |  40 ---------
 include/linux/swap_cgroup.h |  42 +++++++++
 mm/Makefile                 |   3 +-
 mm/memcontrol.c             |   2 +-
 mm/page_cgroup.c            | 211 --------------------------------------------
 mm/swap_cgroup.c            | 208 +++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c             |   1 -
 mm/swapfile.c               |   2 +-
 9 files changed, 255 insertions(+), 256 deletions(-)
 delete mode 100644 include/linux/page_cgroup.h
 create mode 100644 include/linux/swap_cgroup.h
 delete mode 100644 mm/page_cgroup.c
 create mode 100644 mm/swap_cgroup.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 7e31be07197e..3a60389d3a13 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2583,7 +2583,7 @@ L:	cgroups@vger.kernel.org
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/memcontrol.c
-F:	mm/page_cgroup.c
+F:	mm/swap_cgroup.c
 
 CORETEMP HARDWARE MONITORING DRIVER
 M:	Fenghua Yu <fenghua.yu@intel.com>
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
deleted file mode 100644
index 65be35785c86..000000000000
--- a/include/linux/page_cgroup.h
+++ /dev/null
@@ -1,40 +0,0 @@
-#ifndef __LINUX_PAGE_CGROUP_H
-#define __LINUX_PAGE_CGROUP_H
-
-#include <linux/swap.h>
-
-#ifdef CONFIG_MEMCG_SWAP
-extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
-					unsigned short old, unsigned short new);
-extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
-extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
-extern int swap_cgroup_swapon(int type, unsigned long max_pages);
-extern void swap_cgroup_swapoff(int type);
-#else
-
-static inline
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
-{
-	return 0;
-}
-
-static inline
-unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
-{
-	return 0;
-}
-
-static inline int
-swap_cgroup_swapon(int type, unsigned long max_pages)
-{
-	return 0;
-}
-
-static inline void swap_cgroup_swapoff(int type)
-{
-	return;
-}
-
-#endif /* CONFIG_MEMCG_SWAP */
-
-#endif /* __LINUX_PAGE_CGROUP_H */
diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
new file mode 100644
index 000000000000..145306bdc92f
--- /dev/null
+++ b/include/linux/swap_cgroup.h
@@ -0,0 +1,42 @@
+#ifndef __LINUX_SWAP_CGROUP_H
+#define __LINUX_SWAP_CGROUP_H
+
+#include <linux/swap.h>
+
+#ifdef CONFIG_MEMCG_SWAP
+
+extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
+					unsigned short old, unsigned short new);
+extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
+extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
+extern int swap_cgroup_swapon(int type, unsigned long max_pages);
+extern void swap_cgroup_swapoff(int type);
+
+#else
+
+static inline
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+{
+	return 0;
+}
+
+static inline
+unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
+{
+	return 0;
+}
+
+static inline int
+swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	return 0;
+}
+
+static inline void swap_cgroup_swapoff(int type)
+{
+	return;
+}
+
+#endif /* CONFIG_MEMCG_SWAP */
+
+#endif /* __LINUX_SWAP_CGROUP_H */
diff --git a/mm/Makefile b/mm/Makefile
index 27ddb80403a9..d9d579484f15 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -56,7 +56,8 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_PAGE_COUNTER) += page_counter.o
-obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
+obj-$(CONFIG_MEMCG) += memcontrol.o vmpressure.o
+obj-$(CONFIG_MEMCG_SWAP) += swap_cgroup.o
 obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dc5e0abb18cb..fbb41a170eae 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -51,7 +51,7 @@
 #include <linux/seq_file.h>
 #include <linux/vmpressure.h>
 #include <linux/mm_inline.h>
-#include <linux/page_cgroup.h>
+#include <linux/swap_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include <linux/lockdep.h>
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
deleted file mode 100644
index f0f31c1d4d0c..000000000000
--- a/mm/page_cgroup.c
+++ /dev/null
@@ -1,211 +0,0 @@
-#include <linux/mm.h>
-#include <linux/page_cgroup.h>
-#include <linux/vmalloc.h>
-#include <linux/swapops.h>
-
-#ifdef CONFIG_MEMCG_SWAP
-
-static DEFINE_MUTEX(swap_cgroup_mutex);
-struct swap_cgroup_ctrl {
-	struct page **map;
-	unsigned long length;
-	spinlock_t	lock;
-};
-
-static struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
-
-struct swap_cgroup {
-	unsigned short		id;
-};
-#define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
-
-/*
- * SwapCgroup implements "lookup" and "exchange" operations.
- * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
- * against SwapCache. At swap_free(), this is accessed directly from swap.
- *
- * This means,
- *  - we have no race in "exchange" when we're accessed via SwapCache because
- *    SwapCache(and its swp_entry) is under lock.
- *  - When called via swap_free(), there is no user of this entry and no race.
- * Then, we don't need lock around "exchange".
- *
- * TODO: we can push these buffers out to HIGHMEM.
- */
-
-/*
- * allocate buffer for swap_cgroup.
- */
-static int swap_cgroup_prepare(int type)
-{
-	struct page *page;
-	struct swap_cgroup_ctrl *ctrl;
-	unsigned long idx, max;
-
-	ctrl = &swap_cgroup_ctrl[type];
-
-	for (idx = 0; idx < ctrl->length; idx++) {
-		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
-		if (!page)
-			goto not_enough_page;
-		ctrl->map[idx] = page;
-	}
-	return 0;
-not_enough_page:
-	max = idx;
-	for (idx = 0; idx < max; idx++)
-		__free_page(ctrl->map[idx]);
-
-	return -ENOMEM;
-}
-
-static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
-					struct swap_cgroup_ctrl **ctrlp)
-{
-	pgoff_t offset = swp_offset(ent);
-	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
-	struct swap_cgroup *sc;
-
-	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
-	if (ctrlp)
-		*ctrlp = ctrl;
-
-	mappage = ctrl->map[offset / SC_PER_PAGE];
-	sc = page_address(mappage);
-	return sc + offset % SC_PER_PAGE;
-}
-
-/**
- * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
- * @ent: swap entry to be cmpxchged
- * @old: old id
- * @new: new id
- *
- * Returns old id at success, 0 at failure.
- * (There is no mem_cgroup using 0 as its id)
- */
-unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
-					unsigned short old, unsigned short new)
-{
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
-	unsigned long flags;
-	unsigned short retval;
-
-	sc = lookup_swap_cgroup(ent, &ctrl);
-
-	spin_lock_irqsave(&ctrl->lock, flags);
-	retval = sc->id;
-	if (retval == old)
-		sc->id = new;
-	else
-		retval = 0;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
-	return retval;
-}
-
-/**
- * swap_cgroup_record - record mem_cgroup for this swp_entry.
- * @ent: swap entry to be recorded into
- * @id: mem_cgroup to be recorded
- *
- * Returns old value at success, 0 at failure.
- * (Of course, old value can be 0.)
- */
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
-{
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
-	unsigned short old;
-	unsigned long flags;
-
-	sc = lookup_swap_cgroup(ent, &ctrl);
-
-	spin_lock_irqsave(&ctrl->lock, flags);
-	old = sc->id;
-	sc->id = id;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
-
-	return old;
-}
-
-/**
- * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
- * @ent: swap entry to be looked up.
- *
- * Returns ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
- */
-unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
-{
-	return lookup_swap_cgroup(ent, NULL)->id;
-}
-
-int swap_cgroup_swapon(int type, unsigned long max_pages)
-{
-	void *array;
-	unsigned long array_size;
-	unsigned long length;
-	struct swap_cgroup_ctrl *ctrl;
-
-	if (!do_swap_account)
-		return 0;
-
-	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
-	array_size = length * sizeof(void *);
-
-	array = vzalloc(array_size);
-	if (!array)
-		goto nomem;
-
-	ctrl = &swap_cgroup_ctrl[type];
-	mutex_lock(&swap_cgroup_mutex);
-	ctrl->length = length;
-	ctrl->map = array;
-	spin_lock_init(&ctrl->lock);
-	if (swap_cgroup_prepare(type)) {
-		/* memory shortage */
-		ctrl->map = NULL;
-		ctrl->length = 0;
-		mutex_unlock(&swap_cgroup_mutex);
-		vfree(array);
-		goto nomem;
-	}
-	mutex_unlock(&swap_cgroup_mutex);
-
-	return 0;
-nomem:
-	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
-	printk(KERN_INFO
-		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
-	return -ENOMEM;
-}
-
-void swap_cgroup_swapoff(int type)
-{
-	struct page **map;
-	unsigned long i, length;
-	struct swap_cgroup_ctrl *ctrl;
-
-	if (!do_swap_account)
-		return;
-
-	mutex_lock(&swap_cgroup_mutex);
-	ctrl = &swap_cgroup_ctrl[type];
-	map = ctrl->map;
-	length = ctrl->length;
-	ctrl->map = NULL;
-	ctrl->length = 0;
-	mutex_unlock(&swap_cgroup_mutex);
-
-	if (map) {
-		for (i = 0; i < length; i++) {
-			struct page *page = map[i];
-			if (page)
-				__free_page(page);
-		}
-		vfree(map);
-	}
-}
-
-#endif
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
new file mode 100644
index 000000000000..b5f7f24b8dd1
--- /dev/null
+++ b/mm/swap_cgroup.c
@@ -0,0 +1,208 @@
+#include <linux/swap_cgroup.h>
+#include <linux/vmalloc.h>
+#include <linux/mm.h>
+
+#include <linux/swapops.h> /* depends on mm.h include */
+
+static DEFINE_MUTEX(swap_cgroup_mutex);
+struct swap_cgroup_ctrl {
+	struct page **map;
+	unsigned long length;
+	spinlock_t	lock;
+};
+
+static struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
+
+struct swap_cgroup {
+	unsigned short		id;
+};
+#define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
+
+/*
+ * SwapCgroup implements "lookup" and "exchange" operations.
+ * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
+ * against SwapCache. At swap_free(), this is accessed directly from swap.
+ *
+ * This means,
+ *  - we have no race in "exchange" when we're accessed via SwapCache because
+ *    SwapCache(and its swp_entry) is under lock.
+ *  - When called via swap_free(), there is no user of this entry and no race.
+ * Then, we don't need lock around "exchange".
+ *
+ * TODO: we can push these buffers out to HIGHMEM.
+ */
+
+/*
+ * allocate buffer for swap_cgroup.
+ */
+static int swap_cgroup_prepare(int type)
+{
+	struct page *page;
+	struct swap_cgroup_ctrl *ctrl;
+	unsigned long idx, max;
+
+	ctrl = &swap_cgroup_ctrl[type];
+
+	for (idx = 0; idx < ctrl->length; idx++) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page)
+			goto not_enough_page;
+		ctrl->map[idx] = page;
+	}
+	return 0;
+not_enough_page:
+	max = idx;
+	for (idx = 0; idx < max; idx++)
+		__free_page(ctrl->map[idx]);
+
+	return -ENOMEM;
+}
+
+static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
+					struct swap_cgroup_ctrl **ctrlp)
+{
+	pgoff_t offset = swp_offset(ent);
+	struct swap_cgroup_ctrl *ctrl;
+	struct page *mappage;
+	struct swap_cgroup *sc;
+
+	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
+	if (ctrlp)
+		*ctrlp = ctrl;
+
+	mappage = ctrl->map[offset / SC_PER_PAGE];
+	sc = page_address(mappage);
+	return sc + offset % SC_PER_PAGE;
+}
+
+/**
+ * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
+ * @ent: swap entry to be cmpxchged
+ * @old: old id
+ * @new: new id
+ *
+ * Returns old id at success, 0 at failure.
+ * (There is no mem_cgroup using 0 as its id)
+ */
+unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
+					unsigned short old, unsigned short new)
+{
+	struct swap_cgroup_ctrl *ctrl;
+	struct swap_cgroup *sc;
+	unsigned long flags;
+	unsigned short retval;
+
+	sc = lookup_swap_cgroup(ent, &ctrl);
+
+	spin_lock_irqsave(&ctrl->lock, flags);
+	retval = sc->id;
+	if (retval == old)
+		sc->id = new;
+	else
+		retval = 0;
+	spin_unlock_irqrestore(&ctrl->lock, flags);
+	return retval;
+}
+
+/**
+ * swap_cgroup_record - record mem_cgroup for this swp_entry.
+ * @ent: swap entry to be recorded into
+ * @id: mem_cgroup to be recorded
+ *
+ * Returns old value at success, 0 at failure.
+ * (Of course, old value can be 0.)
+ */
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+{
+	struct swap_cgroup_ctrl *ctrl;
+	struct swap_cgroup *sc;
+	unsigned short old;
+	unsigned long flags;
+
+	sc = lookup_swap_cgroup(ent, &ctrl);
+
+	spin_lock_irqsave(&ctrl->lock, flags);
+	old = sc->id;
+	sc->id = id;
+	spin_unlock_irqrestore(&ctrl->lock, flags);
+
+	return old;
+}
+
+/**
+ * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
+ * @ent: swap entry to be looked up.
+ *
+ * Returns ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
+ */
+unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
+{
+	return lookup_swap_cgroup(ent, NULL)->id;
+}
+
+int swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	void *array;
+	unsigned long array_size;
+	unsigned long length;
+	struct swap_cgroup_ctrl *ctrl;
+
+	if (!do_swap_account)
+		return 0;
+
+	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
+	array_size = length * sizeof(void *);
+
+	array = vzalloc(array_size);
+	if (!array)
+		goto nomem;
+
+	ctrl = &swap_cgroup_ctrl[type];
+	mutex_lock(&swap_cgroup_mutex);
+	ctrl->length = length;
+	ctrl->map = array;
+	spin_lock_init(&ctrl->lock);
+	if (swap_cgroup_prepare(type)) {
+		/* memory shortage */
+		ctrl->map = NULL;
+		ctrl->length = 0;
+		mutex_unlock(&swap_cgroup_mutex);
+		vfree(array);
+		goto nomem;
+	}
+	mutex_unlock(&swap_cgroup_mutex);
+
+	return 0;
+nomem:
+	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
+	printk(KERN_INFO
+		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
+	return -ENOMEM;
+}
+
+void swap_cgroup_swapoff(int type)
+{
+	struct page **map;
+	unsigned long i, length;
+	struct swap_cgroup_ctrl *ctrl;
+
+	if (!do_swap_account)
+		return;
+
+	mutex_lock(&swap_cgroup_mutex);
+	ctrl = &swap_cgroup_ctrl[type];
+	map = ctrl->map;
+	length = ctrl->length;
+	ctrl->map = NULL;
+	ctrl->length = 0;
+	mutex_unlock(&swap_cgroup_mutex);
+
+	if (map) {
+		for (i = 0; i < length; i++) {
+			struct page *page = map[i];
+			if (page)
+				__free_page(page);
+		}
+		vfree(map);
+	}
+}
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 154444918685..9711342987a0 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -17,7 +17,6 @@
 #include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
-#include <linux/page_cgroup.h>
 
 #include <asm/pgtable.h>
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..63f55ccb9b26 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -38,7 +38,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
-#include <linux/page_cgroup.h>
+#include <linux/swap_cgroup.h>
 
 static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 				 unsigned char);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
