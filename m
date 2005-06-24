Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5OMPi1N556880
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:25:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5OMPhcC183492
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:25:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5OMPhAK005100
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:25:43 -0600
Subject: [PATCH 4/6] CKRM: Add guarantee support for mem controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Fri, 24 Jun 2005 15:25:42 -0700
Message-Id: <1119651942.5105.21.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech <ckrm-tech@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Patch 4 of 6 patches to support memory controller under CKRM framework.
This patch provides the guarantee support for the controller.
----------------------------------------

 include/linux/ckrm_mem.h        |   28 +++-
 include/linux/ckrm_mem_inline.h |  255 ++++++++++++++++++++++++++
+----------
 include/linux/mm.h              |    2 
 include/linux/mm_inline.h       |   10 +
 include/linux/mmzone.h          |    2 
 kernel/ckrm/ckrm_memcore.c      |  105 ++++++++++++---
 kernel/ckrm/ckrm_memctlr.c      |  274 ++++++++++++++++++++++++++++++++
+-------
 mm/page_alloc.c                 |    4 
 mm/swap.c                       |    3 
 mm/vmscan.c                     |   99 +++++++++++++-
 10 files changed, 636 insertions(+), 146 deletions(-)

Content-Disposition: inline; filename=11-04-mem_limit-guar

Index: linux-2.6.12/include/linux/ckrm_mem.h
===================================================================
--- linux-2.6.12.orig/include/linux/ckrm_mem.h
+++ linux-2.6.12/include/linux/ckrm_mem.h
@@ -26,6 +26,21 @@
 #include <linux/mmzone.h>
 #include <linux/ckrm_rc.h>
 
+struct ckrm_zone {
+	struct list_head active_list;
+	struct list_head inactive_list;
+
+	unsigned long nr_active;
+	unsigned long nr_inactive;
+	unsigned long active_over;
+	unsigned long inactive_over;
+
+	struct list_head guar_list;	/* list of all over guar classes */
+	struct zone *zone;
+	int guar;			/* guarantee(# pages) of this czone */
+	struct ckrm_mem_res *memcls;
+};
+
 struct ckrm_mem_res {
 	unsigned long flags;
 	struct ckrm_core_class *core;	/* the core i am part of... */
@@ -46,20 +61,29 @@ struct ckrm_mem_res {
 	int hier;			/* hiearchy level, root = 0 */
 	int implicit_guar;		/* for classes with don't care guar */
 	int nr_dontcare;		/* # of dont care children */
+
+	struct ckrm_zone ckrm_zone[MAX_NR_ZONES];
 };
 
 extern atomic_t ckrm_mem_real_count;
 extern struct ckrm_res_ctlr mem_rcbs;
 extern struct ckrm_mem_res *ckrm_mem_root_class;
+extern struct list_head ckrm_memclass_list;
+extern spinlock_t ckrm_mem_lock;
+extern spinlock_t ckrm_overguar_lock[MAX_NR_ZONES];
+extern int ckrm_nr_mem_classes;
+extern unsigned int ckrm_tot_lru_pages;
 
 extern void ckrm_mem_migrate_mm(struct mm_struct *, struct ckrm_mem_res
*);
 extern void ckrm_mem_migrate_all_pages(struct ckrm_mem_res *,
 						struct ckrm_mem_res *);
 extern void memclass_release(struct kref *);
-extern void incr_use_count(struct ckrm_mem_res *, int, int);
-extern void decr_use_count(struct ckrm_mem_res *, int, int);
+extern void add_use_count(struct ckrm_mem_res *, int, int, int);
+extern void sub_use_count(struct ckrm_mem_res *, int, int, int);
 extern int ckrm_class_limit_ok(struct ckrm_mem_res *);
 
+extern struct ckrm_zone *ckrm_get_max_overguar_czone(int);
+
 #else
 
 #define ckrm_mem_migrate_mm(a, b)			do {} while (0)
Index: linux-2.6.12/include/linux/ckrm_mem_inline.h
===================================================================
--- linux-2.6.12.orig/include/linux/ckrm_mem_inline.h
+++ linux-2.6.12/include/linux/ckrm_mem_inline.h
@@ -40,24 +40,43 @@ ckrm_memclass(struct ckrm_core_class *cl
 }
 
 static inline void
-ckrm_set_page_class(struct page *page, struct ckrm_mem_res *cls)
+set_page_ckrmzone( struct page *page, struct ckrm_zone *cz)
 {
-	if (!cls) {
-		if (!ckrm_mem_root_class)
-			return;
-		cls = ckrm_mem_root_class;
-	}
-	if (page->ckrm_class)
-		kref_put(&page->ckrm_class->nr_users, memclass_release);
-	page->ckrm_class = cls;
-	kref_get(&cls->nr_users);
-	incr_use_count(cls, 0, page_zonenum(page));
+	page->ckrm_zone = cz;
+}
+
+static inline struct ckrm_zone *
+page_ckrmzone(struct page *page)
+{
+	return page->ckrm_zone;
+}
+
+/*
+ * Currently, a shared page that is shared by multiple classes is
charged
+ * to a class with max available guarantee. Simply replace this
function
+ * for other policies.
+ */
+static inline int
+ckrm_mem_share_compare(struct ckrm_mem_res *a, struct ckrm_mem_res *b)
+{
+	if (a == NULL)
+		return -(b != NULL);
+	if (b == NULL)
+		return 1;
+	if (a->pg_guar == b->pg_guar)
+		return 0;
+	if (a->pg_guar == CKRM_SHARE_DONTCARE)
+		return 1;
+	if (b->pg_guar == CKRM_SHARE_DONTCARE)
+		return -1;
+	return (a->pg_unused - b->pg_unused);
 }
 
 static inline void
 ckrm_change_page_class(struct page *page, struct ckrm_mem_res *newcls)
 {
-	struct ckrm_mem_res *oldcls = page->ckrm_class;
+	struct ckrm_zone *old_czone = page_ckrmzone(page), *new_czone;
+	struct ckrm_mem_res *oldcls;
 	int zindex = page_zonenum(page);
 
 	if  (!newcls) {
@@ -66,27 +85,62 @@ ckrm_change_page_class(struct page *page
 		newcls = ckrm_mem_root_class;
 	}
 
+	oldcls = old_czone->memcls;
 	if (oldcls == newcls)
 		return;
 
 	if (oldcls) {
 		kref_put(&oldcls->nr_users, memclass_release);
-		decr_use_count(oldcls, 0, zindex);
+		sub_use_count(oldcls, 0, zindex, 1);
 	}
 
-	page->ckrm_class = newcls;
+	new_czone = &newcls->ckrm_zone[page_zonenum(page)];
+	set_page_ckrmzone(page, new_czone);
 	kref_get(&newcls->nr_users);
-	incr_use_count(newcls, 0, zindex);
+	add_use_count(newcls, 0, zindex, 1);
+
+	list_del(&page->lru);
+	if (PageActive(page)) {
+		old_czone->nr_active--;
+		new_czone->nr_active++;
+		list_add(&page->lru, &new_czone->active_list);
+	} else {
+		old_czone->nr_inactive--;
+		new_czone->nr_inactive++;
+		list_add(&page->lru, &new_czone->inactive_list);
+	}
 }
 
 static inline void
-ckrm_clear_page_class(struct page *page)
+ckrm_set_page_class(struct page *page, struct ckrm_mem_res *cls)
 {
-	struct ckrm_mem_res *cls = page->ckrm_class;
-	if (cls) {
-		decr_use_count(cls, 0, page_zonenum(page));
-		kref_put(&cls->nr_users, memclass_release);
+	struct ckrm_zone *czone;
+
+	if (page_ckrmzone(page))
+		ckrm_change_page_class(page, cls); /* or die ??!! */
+
+	if (!cls) {
+		if (!ckrm_mem_root_class) {
+			set_page_ckrmzone(page, NULL);
+			return;
+		}
+		cls = ckrm_mem_root_class;
 	}
+	czone = &cls->ckrm_zone[page_zonenum(page)];
+	set_page_ckrmzone(page, czone);
+	kref_get(&cls->nr_users);
+	add_use_count(cls, 0, page_zonenum(page), 1);
+}
+
+static inline void
+ckrm_clear_page_class(struct page *page)
+{
+	struct ckrm_zone *czone = page_ckrmzone(page);
+	if (czone == NULL)
+		return;
+	sub_use_count(czone->memcls, 0, page_zonenum(page), 1);
+	kref_put(&czone->memcls->nr_users, memclass_release);
+	set_page_ckrmzone(page, NULL);
 }
 
 static inline void
@@ -94,18 +148,27 @@ ckrm_mem_inc_active(struct page *page)
 {
 	struct ckrm_mem_res *cls = ckrm_task_memclass(current)
 						?: ckrm_mem_root_class;
+	struct ckrm_zone *czone;
 
-	if (!cls)
-		return;
-	ckrm_set_page_class(page, cls);
+	if (cls == NULL)
+  		return;
+
+  	ckrm_set_page_class(page, cls);
+	czone = page_ckrmzone(page);
+	czone->nr_active++;
+	list_add(&page->lru, &czone->active_list);
 }
 
 static inline void
 ckrm_mem_dec_active(struct page *page)
 {
-	if (page->ckrm_class == NULL)
-		return;
-	ckrm_clear_page_class(page);
+	struct ckrm_zone *czone = page_ckrmzone(page);
+	if (czone == NULL)
+  		return;
+
+	list_del(&page->lru);
+	czone->nr_active--;
+  	ckrm_clear_page_class(page);
 }
 
 static inline void
@@ -113,26 +176,69 @@ ckrm_mem_inc_inactive(struct page *page)
 {
 	struct ckrm_mem_res *cls = ckrm_task_memclass(current)
 					?: ckrm_mem_root_class;
-
-	if (!cls)
+	struct ckrm_zone *czone;
+	if (cls == NULL)
 		return;
+
 	ckrm_set_page_class(page, cls);
+	czone = page_ckrmzone(page);
+	czone->nr_inactive++;
+	list_add(&page->lru, &czone->inactive_list);
 }
 
 static inline void
 ckrm_mem_dec_inactive(struct page *page)
 {
-	if (!page->ckrm_class)
+	struct ckrm_zone *czone = page_ckrmzone(page);
+	if (czone == NULL)
 		return;
+
+	czone->nr_inactive--;
+	list_del(&page->lru);
 	ckrm_clear_page_class(page);
 }
 
 static inline void
 ckrm_page_init(struct page *page)
 {
-	page->ckrm_class = NULL;
+	set_page_ckrmzone(page, NULL);
+}
+
+static inline void
+ckrm_zone_add_active(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_active += cnt;
+	add_use_count(czone->memcls, 0, zone_idx(czone->zone), cnt);
+	while (cnt--)
+		kref_get(&czone->memcls->nr_users);
+}
+
+static inline void
+ckrm_zone_add_inactive(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_inactive += cnt;
+	add_use_count(czone->memcls, 0, zone_idx(czone->zone), cnt);
+	while (cnt--)
+		kref_get(&czone->memcls->nr_users);
 }
 
+static inline void
+ckrm_zone_sub_active(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_active -= cnt;
+	sub_use_count(czone->memcls, 0, zone_idx(czone->zone), cnt);
+	while (cnt--)
+		kref_put(&czone->memcls->nr_users, memclass_release);
+}
+
+static inline void
+ckrm_zone_sub_inactive(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_inactive -= cnt;
+	sub_use_count(czone->memcls, 0, zone_idx(czone->zone), cnt);
+	while (cnt--)
+		kref_put(&czone->memcls->nr_users, memclass_release);
+}
 
 /* task/mm initializations/cleanup */
 
@@ -193,43 +299,30 @@ ckrm_mm_init(struct mm_struct *mm)
 static inline void
 ckrm_mm_setclass(struct mm_struct *mm, struct ckrm_mem_res *cls)
 {
-	if (cls) {
-		mm->memclass = cls;
-		kref_get(&cls->nr_users);
-	}
+	if (!cls)
+		return;
+	mm->memclass = cls;
+	kref_get(&cls->nr_users);
 }
 
 static inline void
 ckrm_mm_clearclass(struct mm_struct *mm)
 {
-	if (mm->memclass) {
-		kref_put(&mm->memclass->nr_users, memclass_release);
-		mm->memclass = NULL;
-	}
-}
-
-#else
-
-static inline void
-ckrm_task_mm_init(struct task_struct *tsk)
-{
+	if (!mm->memclass)
+		return;
+	kref_put(&mm->memclass->nr_users, memclass_release);
+	mm->memclass = NULL;
 }
 
-static inline void
-ckrm_task_mm_set(struct mm_struct * mm, struct task_struct *task)
-{
-}
+static inline void ckrm_init_lists(struct zone *zone) 			{}
 
-static inline void
-ckrm_task_mm_change(struct task_struct *tsk,
-		struct mm_struct *oldmm, struct mm_struct *newmm)
+static inline void ckrm_add_tail_inactive(struct page *page)
 {
+	 struct ckrm_zone *ckrm_zone = page_ckrmzone(page);
+	 list_add_tail(&page->lru, &ckrm_zone->inactive_list);
 }
 
-static inline void
-ckrm_task_mm_clear(struct task_struct *tsk, struct mm_struct *mm)
-{
-}
+#else
 
 static inline void *
 ckrm_task_memclass(struct task_struct *tsk)
@@ -237,27 +330,49 @@ ckrm_task_memclass(struct task_struct *t
 	return NULL;
 }
 
-static inline void
-ckrm_mm_init(struct mm_struct *mm)
-{
-}
+static inline void ckrm_clear_page_class(struct page *p)		{}
+
+static inline void ckrm_mem_inc_active(struct page *p)			{}
+static inline void ckrm_mem_dec_active(struct page *p)			{}
+static inline void ckrm_mem_inc_inactive(struct page *p)		{}
+static inline void ckrm_mem_dec_inactive(struct page *p)		{}
+
+#define ckrm_zone_add_active(a, b)	do {} while (0)
+#define ckrm_zone_add_inactive(a, b)	do {} while (0)
+#define ckrm_zone_sub_active(a, b)	do {} while (0)
+#define ckrm_zone_sub_inactive(a, b)	do {} while (0)
+#define set_page_ckrmzone(a, b)		do {} while (0)
+
+#define ckrm_class_limit_ok(a)						(1)
+
+static inline void ckrm_page_init(struct page *p)			{}
+static inline void ckrm_task_mm_init(struct task_struct *tsk)		{}
+static inline void ckrm_task_mm_set(struct mm_struct * mm,
+					struct task_struct *task)	{}
+static inline void ckrm_task_mm_change(struct task_struct *tsk,
+		struct mm_struct *oldmm, struct mm_struct *newmm)	{}
+static inline void ckrm_task_mm_clear(struct task_struct *tsk,
+						struct mm_struct *mm)	{}
+
+static inline void ckrm_mm_init(struct mm_struct *mm)			{}
 
 /* using #define instead of static inline as the prototype requires   *
  * data structures that is available only with the controller enabled
*/
-#define ckrm_mm_setclass(a, b) do { } while(0)
-#define ckrm_class_limit_ok(a)	(1)
+#define ckrm_mm_setclass(a, b) 					do {} while(0)
 
-static inline void
-ckrm_mm_clearclass(struct mm_struct *mm)
+static inline void ckrm_mm_clearclass(struct mm_struct *mm)		{}
+
+static inline void ckrm_init_lists(struct zone *zone)
 {
+	INIT_LIST_HEAD(&zone->active_list);
+	INIT_LIST_HEAD(&zone->inactive_list);
 }
 
-static inline void ckrm_mem_inc_active(struct page *p)		{}
-static inline void ckrm_mem_dec_active(struct page *p)		{}
-static inline void ckrm_mem_inc_inactive(struct page *p)	{}
-static inline void ckrm_mem_dec_inactive(struct page *p)	{}
-static inline void ckrm_page_init(struct page *p)		{}
-static inline void ckrm_clear_page_class(struct page *p)	{}
+static inline void ckrm_add_tail_inactive(struct page *page)
+{
+	 struct zone *zone = page_zone(page);
+	 list_add_tail(&page->lru, &zone->inactive_list);
+}
 
 #endif
 #endif /* _LINUX_CKRM_MEM_INLINE_H_ */
Index: linux-2.6.12/include/linux/mm.h
===================================================================
--- linux-2.6.12.orig/include/linux/mm.h
+++ linux-2.6.12/include/linux/mm.h
@@ -259,7 +259,7 @@ struct page {
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
 #ifdef CONFIG_CKRM_RES_MEM
-	struct ckrm_mem_res *ckrm_class;
+	struct ckrm_zone *ckrm_zone;
 #endif
 };
 
Index: linux-2.6.12/include/linux/mm_inline.h
===================================================================
--- linux-2.6.12.orig/include/linux/mm_inline.h
+++ linux-2.6.12/include/linux/mm_inline.h
@@ -3,7 +3,9 @@
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
+#ifndef CONFIG_CKRM_RES_MEM
 	list_add(&page->lru, &zone->active_list);
+#endif
 	zone->nr_active++;
 	ckrm_mem_inc_active(page);
 }
@@ -11,7 +13,9 @@ add_page_to_active_list(struct zone *zon
 static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
+#ifndef CONFIG_CKRM_RES_MEM
 	list_add(&page->lru, &zone->inactive_list);
+#endif
 	zone->nr_inactive++;
 	ckrm_mem_inc_inactive(page);
 }
@@ -19,7 +23,9 @@ add_page_to_inactive_list(struct zone *z
 static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
+#ifndef CONFIG_CKRM_RES_MEM
 	list_del(&page->lru);
+#endif
 	zone->nr_active--;
 	ckrm_mem_dec_active(page);
 }
@@ -27,7 +33,9 @@ del_page_from_active_list(struct zone *z
 static inline void
 del_page_from_inactive_list(struct zone *zone, struct page *page)
 {
+#ifndef CONFIG_CKRM_RES_MEM
 	list_del(&page->lru);
+#endif
 	zone->nr_inactive--;
 	ckrm_mem_dec_inactive(page);
 }
@@ -35,7 +43,9 @@ del_page_from_inactive_list(struct zone 
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
+#ifndef CONFIG_CKRM_RES_MEM
 	list_del(&page->lru);
+#endif
 	if (PageActive(page)) {
 		ClearPageActive(page);
 		zone->nr_active--;
Index: linux-2.6.12/include/linux/mmzone.h
===================================================================
--- linux-2.6.12.orig/include/linux/mmzone.h
+++ linux-2.6.12/include/linux/mmzone.h
@@ -135,8 +135,10 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
+#ifndef CONFIG_CKRM_RES_MEM
 	struct list_head	active_list;
 	struct list_head	inactive_list;
+#endif
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		nr_active;
Index: linux-2.6.12/kernel/ckrm/ckrm_memcore.c
===================================================================
--- linux-2.6.12.orig/kernel/ckrm/ckrm_memcore.c
+++ linux-2.6.12/kernel/ckrm/ckrm_memcore.c
@@ -38,14 +38,20 @@
 #define CKRM_MEM_MAX_HIERARCHY 2 /* allows only upto 2 levels - 0, 1 &
2 */
 
 /* all 1-level memory_share_class are chained together */
-static LIST_HEAD(ckrm_memclass_list);
-static spinlock_t ckrm_mem_lock; /* protects list above */
-static unsigned int ckrm_tot_lru_pages; /* # of pages in the system */
-
-static int ckrm_nr_mem_classes = 0;
-
+LIST_HEAD(ckrm_memclass_list);
+spinlock_t ckrm_mem_lock; /* protects list above */
+unsigned int ckrm_tot_lru_pages; /* # of pages in the system */
+int ckrm_nr_mem_classes = 0;
 struct ckrm_mem_res *ckrm_mem_root_class;
 atomic_t ckrm_mem_real_count = ATOMIC_INIT(0);
+
+struct list_head ckrm_overguar_list[MAX_NR_ZONES];
+spinlock_t ckrm_overguar_lock[MAX_NR_ZONES]; /* protects the above list
*/
+
+EXPORT_SYMBOL_GPL(ckrm_memclass_list);
+EXPORT_SYMBOL_GPL(ckrm_mem_lock);
+EXPORT_SYMBOL_GPL(ckrm_tot_lru_pages);
+EXPORT_SYMBOL_GPL(ckrm_nr_mem_classes);
 EXPORT_SYMBOL_GPL(ckrm_mem_root_class);
 EXPORT_SYMBOL_GPL(ckrm_mem_real_count);
 
@@ -80,6 +86,9 @@ set_ckrm_tot_pages(void)
 static void
 mem_res_initcls_one(struct ckrm_mem_res *res)
 {
+	int zindex = 0;
+	struct zone *zone;
+
 	memset(res, 0, sizeof(struct ckrm_mem_res));
 
 	res->shares.my_guarantee     = CKRM_SHARE_DONTCARE;
@@ -91,14 +100,65 @@ mem_res_initcls_one(struct ckrm_mem_res 
 
 	res->pg_guar = CKRM_SHARE_DONTCARE;
 	res->pg_limit = CKRM_SHARE_DONTCARE;
+	res->implicit_guar = CKRM_SHARE_DONTCARE;
 
 	INIT_LIST_HEAD(&res->mcls_list);
 
+	for_each_zone(zone) {
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].active_list);
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].inactive_list);
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].guar_list);
+		res->ckrm_zone[zindex].nr_active = 0;
+		res->ckrm_zone[zindex].nr_inactive = 0;
+		res->ckrm_zone[zindex].zone = zone;
+		res->ckrm_zone[zindex].memcls = res;
+		zindex++;
+	}
+
 	res->pg_unused = 0;
 	res->nr_dontcare = 1; /* for default class */
 	kref_init(&res->nr_users);
 }
 
+static inline void
+set_zone_guarantees(struct ckrm_mem_res *cls)
+{
+	int i, guar, total;
+	struct zone *zone;
+	u64 temp;
+
+	if (cls->pg_guar == CKRM_SHARE_DONTCARE)
+		/* no guarantee for this class. use implicit guarantee */
+		guar = cls->implicit_guar / cls->nr_dontcare;
+	else
+		guar = cls->pg_unused / cls->nr_dontcare;
+
+	i = 0;
+	for_each_zone(zone) {
+
+		if (zone->present_pages == 0) {
+			cls->ckrm_zone[i].guar = 0;
+			i++;
+			continue;
+		}
+
+		/*
+		 * Guarantee for a ckrmzone is calculated from the class's
+		 * guarantee and the pages_low of the zone proportional
+		 * to the ckrmzone.
+		 */
+		total = zone->nr_active + zone->nr_inactive + zone->free_pages;
+		temp = (u64) guar * total;
+		do_div(temp, ckrm_tot_lru_pages);
+		cls->ckrm_zone[i].guar = (int) temp;
+
+		temp = zone->pages_low * cls->ckrm_zone[i].guar;
+		do_div(temp, zone->present_pages);
+		cls->ckrm_zone[i].guar -= (int) temp;
+		i++;
+	}
+}
+
 static void
 set_impl_guar_children(struct ckrm_mem_res *parres)
 {
@@ -106,11 +166,10 @@ set_impl_guar_children(struct ckrm_mem_r
 	struct ckrm_mem_res *cres;
 	int nr_dontcare = 1; /* for defaultclass */
 	int guar, impl_guar;
-	int resid = mem_rcbs.resid;
 
 	ckrm_lock_hier(parres->core);
 	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
-		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		cres = ckrm_memclass(child);
 		/* treat NULL cres as don't care as that child is just being
 		 * created.
 		 * FIXME: need a better way to handle this case.
@@ -125,13 +184,14 @@ set_impl_guar_children(struct ckrm_mem_r
 	impl_guar = guar / parres->nr_dontcare;
 
 	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
-		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		cres = ckrm_memclass(child);
 		if (cres && cres->pg_guar == CKRM_SHARE_DONTCARE) {
 			cres->implicit_guar = impl_guar;
 			set_impl_guar_children(cres);
 		}
 	}
 	ckrm_unlock_hier(parres->core);
+	set_zone_guarantees(parres);
 
 }
 
@@ -142,7 +202,7 @@ mem_res_alloc(struct ckrm_core_class *co
 
 	BUG_ON(mem_rcbs.resid == -1);
 
-	pres = ckrm_get_res_class(parent, mem_rcbs.resid, struct
ckrm_mem_res);
+	pres = ckrm_memclass(parent);
 	if (pres && (pres->hier == CKRM_MEM_MAX_HIERARCHY)) {
 		printk(KERN_ERR "MEM_RC: only allows hieararchy of %d\n",
 						CKRM_MEM_MAX_HIERARCHY);
@@ -184,6 +244,7 @@ mem_res_alloc(struct ckrm_core_class *co
 				pres->implicit_guar : pres->pg_unused;
 			res->implicit_guar = guar / pres->nr_dontcare;
 		}
+		set_zone_guarantees(res);
 		ckrm_nr_mem_classes++;
 	} else
 		printk(KERN_ERR "MEM_RC: alloc: GFP_ATOMIC failed\n");
@@ -206,8 +267,7 @@ child_maxlimit_changed_local(struct ckrm
 	/* run thru parent's children and get new max_limit of parent */
 	ckrm_lock_hier(parres->core);
 	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
-		childres = ckrm_get_res_class(child, mem_rcbs.resid,
-				struct ckrm_mem_res);
+		childres = ckrm_memclass(child);
 		if (maxlimit < childres->shares.my_limit)
 			maxlimit = childres->shares.my_limit;
 	}
@@ -225,7 +285,6 @@ recalc_and_propagate(struct ckrm_mem_res
 {
 	struct ckrm_core_class *child = NULL;
 	struct ckrm_mem_res *cres;
-	int resid = mem_rcbs.resid;
 	struct ckrm_shares *self = &res->shares;
 
 	if (parres) {
@@ -266,10 +325,11 @@ recalc_and_propagate(struct ckrm_mem_res
 	} else
 		res->pg_unused = 0;
 
+	set_zone_guarantees(res);
 	/* propagate to children */
 	ckrm_lock_hier(res->core);
 	while ((child = ckrm_get_next_child(res->core, child)) != NULL) {
-		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		cres = ckrm_memclass(child);
 		recalc_and_propagate(cres, res);
 	}
 	ckrm_unlock_hier(res->core);
@@ -281,14 +341,14 @@ mem_res_free(void *my_res)
 {
 	struct ckrm_mem_res *res = my_res;
 	struct ckrm_mem_res *pres;
+	int i;
 
 	if (!res)
 		return;
 
 	ckrm_mem_migrate_all_pages(res, ckrm_mem_root_class);
 
-	pres = ckrm_get_res_class(res->parent, mem_rcbs.resid,
-			struct ckrm_mem_res);
+	pres = ckrm_memclass(res->parent);
 
 	if (pres) {
 		child_guarantee_changed(&pres->shares,
@@ -308,6 +368,9 @@ mem_res_free(void *my_res)
 	res->pg_limit = 0;
 	res->pg_unused = 0;
 
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		BUG_ON(!list_empty(&res->ckrm_zone[i].guar_list));
+
 	spin_lock_irq(&ckrm_mem_lock);
 	list_del_init(&res->mcls_list);
 	spin_unlock_irq(&ckrm_mem_lock);
@@ -329,8 +392,7 @@ mem_set_share_values(void *my_res, struc
 	if (!res)
 		return -EINVAL;
 
-	parres = ckrm_get_res_class(res->parent, mem_rcbs.resid,
-		struct ckrm_mem_res);
+	parres = ckrm_memclass(res->parent);
 
 	rc = set_shares(shares, &res->shares, parres ? &parres->shares :
NULL);
 
@@ -494,10 +556,15 @@ int __init
 init_ckrm_mem_res(void)
 {
 	struct ckrm_classtype *clstype;
-	int resid = mem_rcbs.resid;
+	int i, resid = mem_rcbs.resid;
 
 	set_ckrm_tot_pages();
 	spin_lock_init(&ckrm_mem_lock);
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		INIT_LIST_HEAD(&ckrm_overguar_list[i]);
+		spin_lock_init(&ckrm_overguar_lock[i]);
+	}
+
 	clstype = ckrm_find_classtype_by_name("taskclass");
 	if (clstype == NULL) {
 		printk(KERN_INFO " Unknown ckrm classtype<taskclass>");
Index: linux-2.6.12/kernel/ckrm/ckrm_memctlr.c
===================================================================
--- linux-2.6.12.orig/kernel/ckrm/ckrm_memctlr.c
+++ linux-2.6.12/kernel/ckrm/ckrm_memctlr.c
@@ -14,53 +14,98 @@
  *
  */
 
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/ckrm_mem_inline.h>
 
+extern struct list_head ckrm_overguar_list[];
+
+static inline void
+ckrm_add_to_guar_list(struct ckrm_zone *czone, int zindex)
+{
+	int usage;
+	unsigned long flags;
+
+	/* fast path, after this czone gets into the list */
+	if (!list_empty(&czone->guar_list))
+		return;
+
+	usage = czone->nr_active + czone->nr_inactive;
+	if (usage > czone->guar) {
+		spin_lock_irqsave(&ckrm_overguar_lock[zindex], flags);
+		if (list_empty(&czone->guar_list))
+			list_add_tail(&czone->guar_list,
+				&ckrm_overguar_list[zindex]);
+		spin_unlock_irqrestore(&ckrm_overguar_lock[zindex], flags);
+	}
+}
+
+static inline void
+ckrm_del_from_guar_list(struct ckrm_zone *czone, int zindex)
+{
+	int usage;
+	unsigned long flags;
+
+	/* fast path, return immediately if we are not in the list */
+	if (list_empty(&czone->guar_list))
+		return;
+
+	usage = czone->nr_active + czone->nr_inactive;
+	if (usage <= czone->guar) {
+		spin_lock_irqsave(&ckrm_overguar_lock[zindex], flags);
+		if (!list_empty(&czone->guar_list))
+			list_del_init(&czone->guar_list);
+		spin_unlock_irqrestore(&ckrm_overguar_lock[zindex], flags);
+	}
+}
+
 void
-incr_use_count(struct ckrm_mem_res *cls, int borrow, int zindex)
+add_use_count(struct ckrm_mem_res *cls, int borrow, int zindex, int
cnt)
 {
 	int i, pg_total = 0;
-	struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
-				mem_rcbs.resid, struct ckrm_mem_res);
+	struct ckrm_mem_res *parcls = ckrm_memclass(cls->parent);
 
 	if (!cls)
 		return;
 
-	cls->pg_total[zindex]++;
+	cls->pg_total[zindex] += cnt;
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		pg_total += cls->pg_total[i];
 	if (borrow)
-		cls->pg_lent[zindex]++;
+		cls->pg_lent[zindex] += cnt;
 
-	parcls = ckrm_get_res_class(cls->parent,
-				mem_rcbs.resid, struct ckrm_mem_res);
+	parcls = ckrm_memclass(cls->parent);
 	if (parcls && ((cls->pg_guar == CKRM_SHARE_DONTCARE) ||
 			(pg_total > cls->pg_unused))) {
-		incr_use_count(parcls, 1, zindex);
-		cls->pg_borrowed[zindex]++;
+		add_use_count(parcls, 1, zindex, cnt);
+		cls->pg_borrowed[zindex] += cnt;
 	} else
-		atomic_inc(&ckrm_mem_real_count);
+		atomic_add(cnt, &ckrm_mem_real_count);
+	ckrm_add_to_guar_list(&cls->ckrm_zone[zindex], zindex);
 	return;
 }
 
 void
-decr_use_count(struct ckrm_mem_res *cls, int borrowed, int zindex)
+sub_use_count(struct ckrm_mem_res *cls, int borrowed, int zindex, int
cnt)
 {
+	int borrow_cnt = 0;
+
 	if (!cls)
 		return;
-	cls->pg_total[zindex]--;
+	cls->pg_total[zindex] -= cnt;
 	if (borrowed)
-		cls->pg_lent[zindex]--;
-	if (cls->pg_borrowed > 0) {
-		struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
-				mem_rcbs.resid, struct ckrm_mem_res);
+		cls->pg_lent[zindex] -= cnt;
+	if (cls->pg_borrowed[zindex] > 0) {
+		struct ckrm_mem_res *parcls = ckrm_memclass(cls->parent);
 		if (parcls) {
-			decr_use_count(parcls, 1, zindex);
-			cls->pg_borrowed[zindex]--;
-			return;
+			borrow_cnt = min(cnt, cls->pg_borrowed[zindex]);
+			sub_use_count(parcls, 1, zindex, borrow_cnt);
+			cls->pg_borrowed[zindex] -= borrow_cnt;
 		}
 	}
-	atomic_dec(&ckrm_mem_real_count);
+	atomic_sub(cnt - borrow_cnt, &ckrm_mem_real_count);
+	ckrm_del_from_guar_list(&cls->ckrm_zone[zindex], zindex);
+	return;
 }
 
 int
@@ -73,8 +118,7 @@ ckrm_class_limit_ok(struct ckrm_mem_res 
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		pg_total += cls->pg_total[i];
 	if (cls->pg_limit == CKRM_SHARE_DONTCARE) {
-		struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
-					mem_rcbs.resid, struct ckrm_mem_res);
+		struct ckrm_mem_res *parcls = ckrm_memclass(cls->parent);
 		ret = (parcls ? ckrm_class_limit_ok(parcls) : 0);
 	} else
 		ret = (pg_total <= cls->pg_limit);
@@ -82,8 +126,88 @@ ckrm_class_limit_ok(struct ckrm_mem_res 
 	return ret;
 }
 
+static int
+ckrm_mem_evaluate_page_anon(struct page* page)
+{
+	struct ckrm_mem_res* pgcls = page_ckrmzone(page)->memcls;
+	struct ckrm_mem_res* maxshareclass = NULL;
+	struct anon_vma *anon_vma = (struct anon_vma *) page->mapping;
+	struct vm_area_struct *vma;
+	struct mm_struct* mm;
+	int ret = 0;
+
+	if (!spin_trylock(&anon_vma->lock))
+		return 0;
+	BUG_ON(list_empty(&anon_vma->head));
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		mm = vma->vm_mm;
+		if (!maxshareclass || ckrm_mem_share_compare(maxshareclass,
+				mm->memclass) < 0) {
+			maxshareclass = mm->memclass;
+		}
+	}
+	spin_unlock(&anon_vma->lock);
+
+	if (!maxshareclass)
+		maxshareclass = ckrm_mem_root_class;
+	if (pgcls != maxshareclass) {
+		ckrm_change_page_class(page, maxshareclass);
+		ret = 1;
+	}
+	return ret;
+}
+
+static int
+ckrm_mem_evaluate_page_file(struct page* page)
+{
+	struct ckrm_mem_res* pgcls = page_ckrmzone(page)->memcls;
+	struct ckrm_mem_res* maxshareclass = NULL;
+	struct address_space *mapping = page->mapping;
+	struct vm_area_struct *vma = NULL;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct prio_tree_iter iter;
+	struct mm_struct* mm;
+	int ret = 0;
+
+	if (!mapping)
+		return 0;
+
+	if (!spin_trylock(&mapping->i_mmap_lock))
+		return 0;
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap,
+					pgoff, pgoff) {
+		mm = vma->vm_mm;
+		if (!maxshareclass || ckrm_mem_share_compare(maxshareclass,
+				mm->memclass)<0)
+			maxshareclass = mm->memclass;
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+
+	if (!maxshareclass)
+		maxshareclass = ckrm_mem_root_class;
+	if (pgcls != maxshareclass) {
+		ckrm_change_page_class(page, maxshareclass);
+		ret = 1;
+	}
+	return ret;
+}
+
+static int
+ckrm_mem_evaluate_page(struct page* page)
+{
+	int ret = 0;
+	if (page->mapping) {
+		if (PageAnon(page))
+			ret = ckrm_mem_evaluate_page_anon(page);
+		else
+			ret = ckrm_mem_evaluate_page_file(page);
+	}
+	return ret;
+}
+
 static void migrate_list(struct list_head *list,
-	struct ckrm_mem_res* from, struct ckrm_mem_res* to)
+	struct ckrm_mem_res* from, struct ckrm_mem_res* def)
 {
 	struct page *page;
 	struct list_head *pos, *next;
@@ -92,21 +216,26 @@ static void migrate_list(struct list_hea
 	while (pos != list) {
 		next = pos->next;
 		page = list_entry(pos, struct page, lru);
-		if (page->ckrm_class == from)
-			ckrm_change_page_class(page, to);
+		if (!ckrm_mem_evaluate_page(page))
+			ckrm_change_page_class(page, def);
 		pos = next;
 	}
 }
 
 void
-ckrm_mem_migrate_all_pages(struct ckrm_mem_res* from, struct
ckrm_mem_res* to)
+ckrm_mem_migrate_all_pages(struct ckrm_mem_res* from,
+					struct ckrm_mem_res* def)
 {
+	int i;
 	struct zone *zone;
+	struct ckrm_zone *ckrm_zone;
 
-	for_each_zone(zone) {
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		ckrm_zone = &from->ckrm_zone[i];
+		zone = ckrm_zone->zone;
 		spin_lock_irq(&zone->lru_lock);
-		migrate_list(&zone->inactive_list, from, to);
-		migrate_list(&zone->active_list, from, to);
+		migrate_list(&ckrm_zone->inactive_list, from, def);
+		migrate_list(&ckrm_zone->active_list, from, def);
 		spin_unlock_irq(&zone->lru_lock);
 	}
 	return;
@@ -131,8 +260,13 @@ class_migrate_pmd(struct mm_struct* mm, 
 		pte = pte_offset_map(pmdir, address);
 		if (pte_present(*pte)) {
 			struct page *page = pte_page(*pte);
-			if (page->mapping)
+			struct ckrm_zone *czone = page_ckrmzone(page);
+			if (page->mapping && czone) {
+				struct zone *zone = czone->zone;
+				spin_lock_irq(&zone->lru_lock);
 				ckrm_change_page_class(page, mm->memclass);
+				spin_unlock_irq(&zone->lru_lock);
+			}
 		}
 		address += PAGE_SIZE;
 		pte_unmap(pte);
@@ -193,7 +327,9 @@ class_migrate_vma(struct mm_struct* mm, 
 void
 ckrm_mem_migrate_mm(struct mm_struct* mm, struct ckrm_mem_res *def)
 {
+	struct task_struct *task;
 	struct vm_area_struct *vma;
+	struct ckrm_mem_res *maxshareclass = def;
 
 	/* We leave the mm->memclass untouched since we believe that one
 	 * mm with no task associated will be deleted soon or attach
@@ -202,18 +338,72 @@ ckrm_mem_migrate_mm(struct mm_struct* mm
 	if (list_empty(&mm->tasklist))
 		return;
 
-	if (mm->memclass)
-		kref_put(&mm->memclass->nr_users, memclass_release);
-	mm->memclass = def ?: ckrm_mem_root_class;
-	kref_get(&mm->memclass->nr_users);
-
-	/* Go through all VMA to migrate pages */
-	down_read(&mm->mmap_sem);
-	vma = mm->mmap;
-	while(vma) {
-		class_migrate_vma(mm, vma);
-		vma = vma->vm_next;
+	list_for_each_entry(task, &mm->tasklist, mm_peers) {
+		struct ckrm_mem_res* cls = ckrm_task_memclass(task);
+		if (!cls)
+			continue;
+		if (!maxshareclass ||
+				ckrm_mem_share_compare(maxshareclass,cls)<0 )
+			maxshareclass = cls;
+	}
+
+	if (maxshareclass && (mm->memclass != maxshareclass)) {
+		if (mm->memclass)
+			kref_put(&mm->memclass->nr_users, memclass_release);
+		mm->memclass = maxshareclass;
+		kref_get(&maxshareclass->nr_users);
+
+		/* Go through all VMA to migrate pages */
+		down_read(&mm->mmap_sem);
+		vma = mm->mmap;
+		while(vma) {
+			class_migrate_vma(mm, vma);
+			vma = vma->vm_next;
+		}
+		up_read(&mm->mmap_sem);
 	}
-	up_read(&mm->mmap_sem);
 	return;
 }
+
+/*
+ * Returns the ckrm zone whose usage is over its guarantee and is
+ * is the most among all the ckrm zones who are over their respective
+ * guarantees.
+ *
+ * While returning holds a reference to the class, Caller is
responsible
+ * for dropping the reference(kref_put), when it is done with the ckrm
+ * zone.
+ */
+struct ckrm_zone *
+ckrm_get_max_overguar_czone(int zindex)
+{
+	struct ckrm_zone *czone;
+	struct ckrm_zone *maxczone = &ckrm_mem_root_class->ckrm_zone[zindex];
+	int max_overguar = 0, usage, cnt;
+	struct ckrm_mem_res *cls;
+
+	kref_get(&maxczone->memcls->nr_users);
+
+	spin_lock_irq(&ckrm_overguar_lock[zindex]);
+	list_for_each_entry(czone, &ckrm_overguar_list[zindex], guar_list) {
+		cls = czone->memcls;
+		usage = czone->nr_active + czone->nr_inactive;
+		if ((usage - czone->guar) > max_overguar) {
+			kref_put(&maxczone->memcls->nr_users, memclass_release);
+			max_overguar = usage - czone->guar;
+			maxczone = czone;
+			kref_get(&maxczone->memcls->nr_users);
+		}
+	}
+	spin_unlock_irq(&ckrm_overguar_lock[zindex]);
+	BUG_ON(maxczone == NULL);
+
+	/* calculate active_over and inactive_over */
+	cnt = maxczone->nr_active - (2 * maxczone->guar / 3);
+	maxczone->active_over = (cnt > 0) ? cnt : SWAP_CLUSTER_MAX;
+	cnt = maxczone->active_over + maxczone->nr_inactive
+			 - (maxczone->guar / 3);
+	maxczone->inactive_over = (cnt > 0) ? cnt : SWAP_CLUSTER_MAX;
+
+	return maxczone;
+}
Index: linux-2.6.12/mm/page_alloc.c
===================================================================
--- linux-2.6.12.orig/mm/page_alloc.c
+++ linux-2.6.12/mm/page_alloc.c
@@ -358,7 +358,6 @@ free_pages_bulk(struct zone *zone, int c
 		/* have to delete it as __free_pages_bulk list manipulates */
 		list_del(&page->lru);
 		__free_pages_bulk(page, zone, order);
-		ckrm_clear_page_class(page);
 		ret++;
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -1713,8 +1712,7 @@ static void __init free_area_init_core(s
 		}
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 				zone_names[j], realsize, batch);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
+		ckrm_init_lists(zone);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
Index: linux-2.6.12/mm/swap.c
===================================================================
--- linux-2.6.12.orig/mm/swap.c
+++ linux-2.6.12/mm/swap.c
@@ -30,6 +30,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/ckrm_mem_inline.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -87,7 +88,7 @@ int rotate_reclaimable_page(struct page 
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
 		list_del(&page->lru);
-		list_add_tail(&page->lru, &zone->inactive_list);
+		ckrm_add_tail_inactive(page);
 		inc_page_state(pgrotated);
 	}
 	if (!test_clear_page_writeback(page))
Index: linux-2.6.12/mm/vmscan.c
===================================================================
--- linux-2.6.12.orig/mm/vmscan.c
+++ linux-2.6.12/mm/vmscan.c
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
+#include <linux/ckrm_mem.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -79,6 +80,11 @@ struct scan_control {
 	 * In this context, it doesn't matter that we scan the
 	 * whole list at once. */
 	int swap_cluster_max;
+
+#ifdef CONFIG_CKRM_RES_MEM
+	int ckrm_active;
+	int ckrm_inactive;
+#endif
 };
 
 /*
@@ -586,6 +592,7 @@ static int isolate_lru_pages(int nr_to_s
 			continue;
 		} else {
 			list_add(&page->lru, dst);
+			set_page_ckrmzone(page, NULL);
 			nr_taken++;
 		}
 	}
@@ -597,11 +604,23 @@ static int isolate_lru_pages(int nr_to_s
 /*
  * shrink_cache() adds the number of pages reclaimed to sc-
>nr_reclaimed
  */
+#ifdef CONFIG_CKRM_RES_MEM
+static void shrink_cache(struct ckrm_zone *ckrm_zone, struct
scan_control *sc)
+#else
 static void shrink_cache(struct zone *zone, struct scan_control *sc)
+#endif
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
 	int max_scan = sc->nr_to_scan;
+#ifdef CONFIG_CKRM_RES_MEM
+	struct zone *zone = ckrm_zone->zone;
+	struct list_head *inactive_list = &ckrm_zone->inactive_list;
+	struct list_head *active_list = &ckrm_zone->active_list;
+#else
+	struct list_head *inactive_list = &zone->inactive_list;
+	struct list_head *active_list = &zone->active_list;
+#endif
 
 	pagevec_init(&pvec, 1);
 
@@ -614,9 +633,10 @@ static void shrink_cache(struct zone *zo
 		int nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
+					     inactive_list,
 					     &page_list, &nr_scan);
 		zone->nr_inactive -= nr_taken;
+		ckrm_zone_sub_inactive(ckrm_zone, nr_taken);
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -643,10 +663,16 @@ static void shrink_cache(struct zone *zo
 			if (TestSetPageLRU(page))
 				BUG();
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			if (PageActive(page)) {
+				ckrm_zone_add_active(ckrm_zone, 1);
+				zone->nr_active++;
+				list_add(&page->lru, active_list);
+			} else {
+				ckrm_zone_add_inactive(ckrm_zone, 1);
+				zone->nr_inactive++;
+				list_add(&page->lru, inactive_list);
+			}
+			set_page_ckrmzone(page, ckrm_zone);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -677,7 +703,11 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void
+#ifdef CONFIG_CKRM_RES_MEM
+refill_inactive_zone(struct ckrm_zone *ckrm_zone, struct scan_control
*sc)
+#else
 refill_inactive_zone(struct zone *zone, struct scan_control *sc)
+#endif
 {
 	int pgmoved;
 	int pgdeactivate = 0;
@@ -692,13 +722,22 @@ refill_inactive_zone(struct zone *zone, 
 	long mapped_ratio;
 	long distress;
 	long swap_tendency;
+#ifdef CONFIG_CKRM_RES_MEM
+	struct zone *zone = ckrm_zone->zone;
+	struct list_head *active_list = &ckrm_zone->active_list;
+	struct list_head *inactive_list = &ckrm_zone->inactive_list;
+#else
+	struct list_head *active_list = &zone->active_list;
+	struct list_head *inactive_list = &zone->inactive_list;
+#endif
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
+	pgmoved = isolate_lru_pages(nr_pages, active_list,
 				    &l_hold, &pgscanned);
 	zone->pages_scanned += pgscanned;
 	zone->nr_active -= pgmoved;
+	ckrm_zone_sub_active(ckrm_zone, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
 	/*
@@ -757,10 +796,12 @@ refill_inactive_zone(struct zone *zone, 
 			BUG();
 		if (!TestClearPageActive(page))
 			BUG();
-		list_move(&page->lru, &zone->inactive_list);
+		list_move(&page->lru, inactive_list);
+		set_page_ckrmzone(page, ckrm_zone);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_inactive += pgmoved;
+			ckrm_zone_add_inactive(ckrm_zone, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -771,6 +812,7 @@ refill_inactive_zone(struct zone *zone, 
 		}
 	}
 	zone->nr_inactive += pgmoved;
+	ckrm_zone_add_inactive(ckrm_zone, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -785,10 +827,12 @@ refill_inactive_zone(struct zone *zone, 
 		if (TestSetPageLRU(page))
 			BUG();
 		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		list_move(&page->lru, active_list);
+		set_page_ckrmzone(page, ckrm_zone);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_active += pgmoved;
+			ckrm_zone_add_active(ckrm_zone, pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
@@ -796,6 +840,7 @@ refill_inactive_zone(struct zone *zone, 
 		}
 	}
 	zone->nr_active += pgmoved;
+	ckrm_zone_add_active(ckrm_zone, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 
@@ -803,6 +848,29 @@ refill_inactive_zone(struct zone *zone, 
 	mod_page_state(pgdeactivate, pgdeactivate);
 }
 
+#ifdef CONFIG_CKRM_RES_MEM
+static void
+shrink_ckrmzone(struct ckrm_zone *czone, struct scan_control *sc)
+{
+	while (sc->ckrm_active || sc->ckrm_inactive) {
+		if (sc->ckrm_active) {
+			sc->nr_to_scan = (unsigned long)min(sc->ckrm_active,
+					SWAP_CLUSTER_MAX);
+			sc->ckrm_active -= sc->nr_to_scan;
+			refill_inactive_zone(czone, sc);
+		}
+		if (sc->ckrm_inactive) {
+			sc->nr_to_scan = (unsigned long)min(sc->ckrm_inactive,
+					SWAP_CLUSTER_MAX);
+			sc->ckrm_inactive -= sc->nr_to_scan;
+			shrink_cache(czone, sc);
+			if (sc->nr_to_reclaim <= 0)
+				break;
+		}
+	}
+}
+#endif
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct
reclaim.
  */
@@ -832,6 +900,20 @@ shrink_zone(struct zone *zone, struct sc
 
 	sc->nr_to_reclaim = sc->swap_cluster_max;
 
+#ifdef CONFIG_CKRM_RES_MEM
+	while (nr_active || nr_inactive) {
+		int zindex = zone_idx(zone);
+		struct ckrm_zone *czone;
+
+		czone = ckrm_get_max_overguar_czone(zindex);
+		sc->ckrm_active = min(nr_active, czone->active_over);
+		sc->ckrm_inactive = min(nr_inactive, czone->inactive_over);
+		nr_active -= sc->ckrm_active;
+		nr_inactive -= sc->ckrm_inactive;
+		shrink_ckrmzone(czone, sc);
+		kref_put(&czone->memcls->nr_users, memclass_release);
+	}
+#else
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
 			sc->nr_to_scan = min(nr_active,
@@ -849,6 +931,7 @@ shrink_zone(struct zone *zone, struct sc
 				break;
 		}
 	}
+#endif
 
 	throttle_vm_writeout();
 }

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
