Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j324KxTD007998
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j324Kxk4248848
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j324KxLp018217
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Date: Fri, 1 Apr 2005 19:14:34 -0800
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: [PATCH 4/6] CKRM: Add guarantee support for mem controller
Message-ID: <20050402031434.GE23284@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6WlEvdN9Dv0WHSBl"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------

--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=11-04-mem_limit-guar

Patch 4 of 6 patches to support memory controller under CKRM framework.
This patch provides the guarantee support for the controller.

 include/linux/ckrm_mem.h        |   31 ++++
 include/linux/ckrm_mem_inline.h |  244 ++++++++++++++++++++++++--------
 include/linux/mm.h              |    2 
 include/linux/mm_inline.h       |   10 +
 include/linux/mmzone.h          |    2 
 kernel/ckrm/ckrm_memcore.c      |   29 +++
 kernel/ckrm/ckrm_memctlr.c      |  299 +++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c                 |    3 
 mm/swap.c                       |    3 
 mm/vmscan.c                     |  114 +++++++++++++--
 10 files changed, 631 insertions(+), 106 deletions(-)

Index: linux-2.6.12-rc1/include/linux/ckrm_mem.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/ckrm_mem.h
+++ linux-2.6.12-rc1/include/linux/ckrm_mem.h
@@ -26,6 +26,27 @@
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
+	unsigned long shrink_active;
+	unsigned long shrink_inactive;
+	long shrink_weight;
+	unsigned long shrink_flag;
+	struct list_head victim_list;	/* list of ckrm_zones chosen for
+					 * shrinking. These are over their
+					 * 'guarantee'
+					 */
+	struct zone *zone;
+	struct ckrm_mem_res *memcls;
+};
+
 struct ckrm_mem_res {
 	unsigned long flags;
 	struct ckrm_core_class *core;	/* the core i am part of... */
@@ -46,11 +67,19 @@ struct ckrm_mem_res {
 	int hier;			/* hiearchy level, root = 0 */
 	int impl_guar;			/* for classes with don't care guar */
 	int nr_dontcare;		/* # of dont care children */
+
+	struct ckrm_zone ckrm_zone[MAX_NR_ZONES];
 };
 
+#define CLS_SHRINK_BIT		(1)
+
 extern atomic_t ckrm_mem_real_count;
 extern struct ckrm_res_ctlr mem_rcbs;
 extern struct ckrm_mem_res *ckrm_mem_root_class;
+extern struct list_head ckrm_memclass_list;
+extern spinlock_t ckrm_mem_lock;
+extern int ckrm_nr_mem_classes;
+extern unsigned int ckrm_tot_lru_pages;
 
 extern void ckrm_mem_migrate_mm(struct mm_struct *, struct ckrm_mem_res *);
 extern void ckrm_mem_migrate_all_pages(struct ckrm_mem_res *,
@@ -60,6 +89,8 @@ extern void incr_use_count(struct ckrm_m
 extern void decr_use_count(struct ckrm_mem_res *, int, int);
 extern int ckrm_class_limit_ok(struct ckrm_mem_res *);
 
+extern void shrink_get_victims(struct zone *, unsigned long ,
+				unsigned long, struct list_head *);
 #else
 
 #define ckrm_mem_migrate_mm(a, b)			do {} while (0)
Index: linux-2.6.12-rc1/include/linux/ckrm_mem_inline.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/ckrm_mem_inline.h
+++ linux-2.6.12-rc1/include/linux/ckrm_mem_inline.h
@@ -34,16 +34,75 @@ ckrm_get_mem_class(struct task_struct *t
 }
 
 static inline void
+ckrm_set_shrink(struct ckrm_zone *cz)
+{
+	set_bit(CLS_SHRINK_BIT, &cz->shrink_flag);
+}
+
+static inline int
+ckrm_test_set_shrink(struct ckrm_zone *cz)
+{
+	return test_and_set_bit(CLS_SHRINK_BIT, &cz->shrink_flag);
+}
+
+static inline void 
+ckrm_clear_shrink(struct ckrm_zone *cz)
+{
+	clear_bit(CLS_SHRINK_BIT, &cz->shrink_flag);
+}
+
+static inline void
+set_page_ckrmzone( struct page *page, struct ckrm_zone *cz)
+{
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
+ * Currently, a shared page that is shared by multiple classes is charged
+ * to a class with max available guarantee. Simply replace this function
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
+}
+
+static inline void
 ckrm_set_page_class(struct page *page, struct ckrm_mem_res *cls)
 {
+	struct ckrm_zone *new_czone, *old_czone;
+
 	if (!cls) {
-		if (!ckrm_mem_root_class)
+		if (!ckrm_mem_root_class) {
+			set_page_ckrmzone(page, NULL);
 			return;
+		}
 		cls = ckrm_mem_root_class;
 	}
-	if (page->ckrm_class)
-		kref_put(&page->ckrm_class->nr_users, memclass_release);
-	page->ckrm_class = cls;
+	new_czone = &cls->ckrm_zone[page_zonenum(page)];
+	old_czone = page_ckrmzone(page);
+	
+	if (old_czone)
+		kref_put(&old_czone->memcls->nr_users, memclass_release);
+
+	set_page_ckrmzone(page, new_czone);
 	kref_get(&cls->nr_users);
 	incr_use_count(cls, 0, page_zonenum(page));
 	SetPageCkrmAccount(page);
@@ -52,7 +111,8 @@ ckrm_set_page_class(struct page *page, s
 static inline void
 ckrm_change_page_class(struct page *page, struct ckrm_mem_res *newcls)
 {
-	struct ckrm_mem_res *oldcls = page->ckrm_class;
+	struct ckrm_zone *old_czone = page_ckrmzone(page), *new_czone;
+	struct ckrm_mem_res *oldcls;
 	int zindex = page_zonenum(page);
 
 	if  (!newcls) {
@@ -61,6 +121,7 @@ ckrm_change_page_class(struct page *page
 		newcls = ckrm_mem_root_class;
 	}
 
+	oldcls = old_czone->memcls;
 	if (oldcls == newcls)
 		return;
 
@@ -69,20 +130,35 @@ ckrm_change_page_class(struct page *page
 		decr_use_count(oldcls, 0, zindex);
 	}
 
-	page->ckrm_class = newcls;
+	new_czone = &newcls->ckrm_zone[page_zonenum(page)];
+	set_page_ckrmzone(page, new_czone);
 	kref_get(&newcls->nr_users);
 	incr_use_count(newcls, 0, zindex);
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
 ckrm_clear_page_class(struct page *page)
 {
-	struct ckrm_mem_res *cls = page->ckrm_class;
-	if (cls && PageCkrmAccount(page)) {
-		decr_use_count(cls, 0, page_zonenum(page));
-		ClearPageCkrmAccount(page);
-		kref_put(&cls->nr_users, memclass_release);
-	}
+	struct ckrm_zone *czone = page_ckrmzone(page);
+	if (czone != NULL) {
+		if (PageCkrmAccount(page)) {
+			decr_use_count(czone->memcls, 0, page_zonenum(page));
+			ClearPageCkrmAccount(page);
+		}
+		kref_put(&czone->memcls->nr_users, memclass_release);
+		set_page_ckrmzone(page, NULL);
+  	}
 }
 
 static inline void
@@ -91,17 +167,27 @@ ckrm_mem_inc_active(struct page *page)
 	struct ckrm_mem_res *cls = ckrm_get_mem_class(current)
 						?: ckrm_mem_root_class;
 
-	if (!cls)
-		return;
-	ckrm_set_page_class(page, cls);
+	struct ckrm_zone *czone;
+  
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
@@ -109,25 +195,58 @@ ckrm_mem_inc_inactive(struct page *page)
 {
 	struct ckrm_mem_res *cls = ckrm_get_mem_class(current)
 					?: ckrm_mem_root_class;
-
-	if (!cls)
-		return;
-	ckrm_set_page_class(page, cls);
+	struct ckrm_zone *czone;
+  
+	if (cls == NULL)
+  		return;
+
+  	ckrm_set_page_class(page, cls);
+	czone = page_ckrmzone(page);
+	czone->nr_inactive++;
+	list_add(&page->lru, &czone->inactive_list);
 }
 
 static inline void
 ckrm_mem_dec_inactive(struct page *page)
 {
-	if (!page->ckrm_class)
-		return;
-	ckrm_clear_page_class(page);
+	struct ckrm_zone *czone = page_ckrmzone(page);
+	if (czone == NULL)
+  		return;
+
+	czone->nr_inactive--;
+	list_del(&page->lru);
+  	ckrm_clear_page_class(page);
 }
 
 static inline void
 ckrm_page_init(struct page *page)
 {
 	page->flags &= ~(1 << PG_ckrm_account);
-	page->ckrm_class = NULL;
+	set_page_ckrmzone(page, NULL);
+}
+
+static inline void
+ckrm_zone_add_active(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_active += cnt;
+}
+
+static inline void
+ckrm_zone_add_inactive(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_inactive += cnt;
+}
+
+static inline void
+ckrm_zone_sub_active(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_active -= cnt;
+}
+
+static inline void
+ckrm_zone_sub_inactive(struct ckrm_zone *czone, int cnt)
+{
+	czone->nr_inactive -= cnt;
 }
 
 
@@ -202,28 +321,15 @@ ckrm_mm_clearclass(struct mm_struct *mm)
 	}
 }
 
-#else
-
-static inline void
-ckrm_task_mm_init(struct task_struct *tsk)
-{
-}
+static inline void ckrm_init_lists(struct zone *zone) 			{}
 
-static inline void
-ckrm_task_mm_set(struct mm_struct * mm, struct task_struct *task)
+static inline void ckrm_add_tail_inactive(struct page *page)
 {
+	 struct ckrm_zone *ckrm_zone = page_ckrmzone(page);
+	 list_add_tail(&page->lru, &ckrm_zone->inactive_list);
 }
 
-static inline void
-ckrm_task_mm_change(struct task_struct *tsk,
-		struct mm_struct *oldmm, struct mm_struct *newmm)
-{
-}
-
-static inline void
-ckrm_task_mm_clear(struct task_struct *tsk, struct mm_struct *mm)
-{
-}
+#else
 
 static inline void *
 ckrm_get_memclass(struct task_struct *tsk)
@@ -231,27 +337,47 @@ ckrm_get_memclass(struct task_struct *ts
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
  * data structures that is available only with the controller enabled */
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
-
+static inline void ckrm_add_tail_inactive(struct page *page)
+{
+	 struct zone *zone = page_zone(page);
+	 list_add_tail(&page->lru, &zone->inactive_list);
+}
 #endif 
 #endif /* _LINUX_CKRM_MEM_INLINE_H_ */
Index: linux-2.6.12-rc1/include/linux/mm.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/mm.h
+++ linux-2.6.12-rc1/include/linux/mm.h
@@ -262,7 +262,7 @@ struct page {
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
 #ifdef CONFIG_CKRM_RES_MEM
-	struct ckrm_mem_res *ckrm_class;
+	struct ckrm_zone *ckrm_zone;
 #endif
 };
 
Index: linux-2.6.12-rc1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/mm_inline.h
+++ linux-2.6.12-rc1/include/linux/mm_inline.h
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
Index: linux-2.6.12-rc1/include/linux/mmzone.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/mmzone.h
+++ linux-2.6.12-rc1/include/linux/mmzone.h
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
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
===================================================================
--- linux-2.6.12-rc1.orig/kernel/ckrm/ckrm_memcore.c
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
@@ -38,14 +38,17 @@
 #define CKRM_MEM_MAX_HIERARCHY 2 /* allows only upto 2 levels - 0, 1 & 2 */
 
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
+EXPORT_SYMBOL_GPL(ckrm_memclass_list);
+EXPORT_SYMBOL_GPL(ckrm_mem_lock);
+EXPORT_SYMBOL_GPL(ckrm_tot_lru_pages);
+EXPORT_SYMBOL_GPL(ckrm_nr_mem_classes);
 EXPORT_SYMBOL_GPL(ckrm_mem_root_class);
 EXPORT_SYMBOL_GPL(ckrm_mem_real_count);
 
@@ -80,6 +83,9 @@ set_ckrm_tot_pages(void)
 static void
 mem_res_initcls_one(struct ckrm_mem_res *res)
 {
+	int zindex = 0;
+	struct zone *zone;
+
 	memset(res, 0, sizeof(struct ckrm_mem_res));
 
 	res->shares.my_guarantee     = CKRM_SHARE_DONTCARE;
@@ -94,6 +100,17 @@ mem_res_initcls_one(struct ckrm_mem_res 
 
 	INIT_LIST_HEAD(&res->mcls_list);
 
+	for_each_zone(zone) {
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].active_list);
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].inactive_list);
+		INIT_LIST_HEAD(&res->ckrm_zone[zindex].victim_list);
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
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
===================================================================
--- linux-2.6.12-rc1.orig/kernel/ckrm/ckrm_memctlr.c
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
@@ -14,6 +14,8 @@
  *
  */
 
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/ckrm_mem_inline.h>
 
 void
@@ -82,8 +84,88 @@ ckrm_class_limit_ok(struct ckrm_mem_res 
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
@@ -92,21 +174,26 @@ static void migrate_list(struct list_hea
 	while (pos != list) {
 		next = pos->next;
 		page = list_entry(pos, struct page, lru);
-		if (page->ckrm_class == from) 
-			ckrm_change_page_class(page, to);
+		if (ckrm_mem_evaluate_page(page))
+			ckrm_change_page_class(page, def);
 		pos = next;
 	}
 }
 
 void
-ckrm_mem_migrate_all_pages(struct ckrm_mem_res* from, struct ckrm_mem_res* to)
+ckrm_mem_migrate_all_pages(struct ckrm_mem_res* from,
+					struct ckrm_mem_res* def)
 {
+	int i;
 	struct zone *zone;
-
-	for_each_zone(zone) {
+	struct ckrm_zone *ckrm_zone;
+  
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
@@ -131,8 +218,13 @@ class_migrate_pmd(struct mm_struct* mm, 
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
@@ -190,7 +282,9 @@ class_migrate_vma(struct mm_struct* mm, 
 void
 ckrm_mem_migrate_mm(struct mm_struct* mm, struct ckrm_mem_res *def)
 {
+	struct task_struct *task;
 	struct vm_area_struct *vma;
+	struct ckrm_mem_res *maxshareclass = def;
 
 	/* We leave the mm->memclass untouched since we believe that one
 	 * mm with no task associated will be deleted soon or attach
@@ -199,18 +293,177 @@ ckrm_mem_migrate_mm(struct mm_struct* mm
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
+		struct ckrm_mem_res* cls = ckrm_get_mem_class(task);
+		if (!cls)
+			continue;
+		if (!maxshareclass ||
+				ckrm_mem_share_compare(maxshareclass,cls)<0 )
+			maxshareclass = cls;
+	}
+
+	if (maxshareclass && (mm->memclass != maxshareclass)) {
+		if (mm->memclass) {
+			kref_put(&mm->memclass->nr_users, memclass_release);
+		}
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
+static int
+shrink_weight(struct ckrm_zone *czone)
+{
+	u64 temp;
+	struct zone *zone = czone->zone;
+	struct ckrm_mem_res *cls = czone->memcls;
+	int zone_usage, zone_guar, zone_total, guar, ret, cnt;
+
+	zone_usage = czone->nr_active + czone->nr_inactive;
+	czone->active_over = czone->inactive_over = 0;
+
+	if (zone_usage < SWAP_CLUSTER_MAX * 4)
+		return 0;
+
+	if (cls->pg_guar == CKRM_SHARE_DONTCARE)
+		/* no guarantee for this class. use implicit guarantee */
+		guar = cls->impl_guar / cls->nr_dontcare;
+	else
+		guar = cls->pg_unused / cls->nr_dontcare;
+	zone_total = zone->nr_active + zone->nr_inactive + zone->free_pages;
+	temp = (u64) guar * zone_total;
+	do_div(temp, ckrm_tot_lru_pages);
+	zone_guar = (int) temp;
+
+	ret = ((zone_usage - zone_guar) > SWAP_CLUSTER_MAX) ?
+				(zone_usage - zone_guar) : 0;
+	if (ret) {
+		cnt = czone->nr_active - (2 * zone_guar / 3);
+		if (cnt > 0)
+			czone->active_over = cnt;
+		cnt = czone->active_over + czone->nr_inactive
+					- zone_guar / 3;
+		if (cnt > 0)
+			czone->inactive_over = cnt;
+	}
+	return ret;
+}
+
+/* insert an entry to the list and sort decendently*/
+static void
+list_add_sort(struct list_head *entry, struct list_head *head)
+{
+	struct ckrm_zone *czone, *new =
+			list_entry(entry, struct ckrm_zone, victim_list);
+	struct list_head* pos = head->next;
+
+	while (pos != head) {
+		czone = list_entry(pos, struct ckrm_zone, victim_list);
+		if (new->shrink_weight > czone->shrink_weight) {
+			__list_add(entry, pos->prev, pos);
+			return;
+		}
+		pos = pos->next;
+  	}
+	list_add_tail(entry, head);
+	return;	
+}
+
+static void
+shrink_choose_victims(struct list_head *victims,
+		unsigned long nr_active, unsigned long nr_inactive)
+{
+	unsigned long nr;
+	struct ckrm_zone* czone;
+	struct list_head *pos, *next;
+  
+	pos = victims->next;
+	while ((pos != victims) && (nr_active || nr_inactive)) {
+		czone = list_entry(pos, struct ckrm_zone, victim_list);
+		
+		if (nr_active && czone->active_over) {
+			nr = min(nr_active, czone->active_over);
+			czone->shrink_active += nr;
+			czone->active_over -= nr;
+			nr_active -= nr;
+		}
+
+		if (nr_inactive && czone->inactive_over) {
+			nr = min(nr_inactive, czone->inactive_over);
+			czone->shrink_inactive += nr;
+			czone->inactive_over -= nr;
+			nr_inactive -= nr;
+		}
+		pos = pos->next;
+  	}
+
+	pos = victims->next;
+	while (pos != victims) {
+		czone = list_entry(pos, struct ckrm_zone, victim_list);
+		next = pos->next;
+		if (czone->shrink_active == 0 && czone->shrink_inactive == 0) {
+			list_del_init(pos);
+			ckrm_clear_shrink(czone);
+		}
+		pos = next;
+	}	
+  	return;
+  }
+
+void
+shrink_get_victims(struct zone *zone, unsigned long nr_active,
+		unsigned long nr_inactive, struct list_head *victims)
+{
+	struct list_head *pos;
+	struct ckrm_mem_res *cls;
+	struct ckrm_zone *czone;
+	int zoneindex = zone_idx(zone);
+	
+	if (ckrm_nr_mem_classes <= 1) {
+		if (ckrm_mem_root_class) {
+			czone = ckrm_mem_root_class->ckrm_zone + zoneindex;
+			if (!ckrm_test_set_shrink(czone)) {
+				list_add(&czone->victim_list, victims);
+				czone->shrink_active = nr_active;
+				czone->shrink_inactive = nr_inactive;
+			}
+		}
+		return;
+	}
+	spin_lock_irq(&ckrm_mem_lock);
+	list_for_each_entry(cls, &ckrm_memclass_list, mcls_list) {
+		czone = cls->ckrm_zone + zoneindex;
+		if (ckrm_test_set_shrink(czone))
+			continue;
+
+		czone->shrink_active = 0;
+		czone->shrink_inactive = 0;
+		czone->shrink_weight = shrink_weight(czone);
+		if (czone->shrink_weight)
+			list_add_sort(&czone->victim_list, victims);
+		else
+			ckrm_clear_shrink(czone);
+	}
+	pos = victims->next;
+	while (pos != victims) {
+		czone = list_entry(pos, struct ckrm_zone, victim_list);
+		pos = pos->next;
+	}
+	shrink_choose_victims(victims, nr_active, nr_inactive);
+	spin_unlock_irq(&ckrm_mem_lock);
+	pos = victims->next;
+	while (pos != victims) {
+		czone = list_entry(pos, struct ckrm_zone, victim_list);
+		pos = pos->next;
+	}
+}
Index: linux-2.6.12-rc1/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc1.orig/mm/page_alloc.c
+++ linux-2.6.12-rc1/mm/page_alloc.c
@@ -1693,8 +1693,7 @@ static void __init free_area_init_core(s
 		}
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 				zone_names[j], realsize, batch);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
+		ckrm_init_lists(zone);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
Index: linux-2.6.12-rc1/mm/swap.c
===================================================================
--- linux-2.6.12-rc1.orig/mm/swap.c
+++ linux-2.6.12-rc1/mm/swap.c
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
Index: linux-2.6.12-rc1/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc1.orig/mm/vmscan.c
+++ linux-2.6.12-rc1/mm/vmscan.c
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
+#include <linux/ckrm_mem.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -555,11 +556,23 @@ keep:
  * For pagecache intensive workloads, the first loop here is the hottest spot
  * in the kernel (apart from the copy_*_user functions).
  */
+#ifdef CONFIG_CKRM_RES_MEM
+static void shrink_cache(struct ckrm_zone *ckrm_zone, struct scan_control *sc)
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
 
@@ -572,11 +585,10 @@ static void shrink_cache(struct zone *zo
 		int nr_freed;
 
 		while (nr_scan++ < sc->swap_cluster_max &&
-				!list_empty(&zone->inactive_list)) {
-			page = lru_to_page(&zone->inactive_list);
+				!list_empty(inactive_list)) {
+			page = lru_to_page(inactive_list);
 
-			prefetchw_prev_lru_page(page,
-						&zone->inactive_list, flags);
+			prefetchw_prev_lru_page(page, inactive_list, flags);
 
 			if (!TestClearPageLRU(page))
 				BUG();
@@ -587,13 +599,14 @@ static void shrink_cache(struct zone *zo
 				 */
 				__put_page(page);
 				SetPageLRU(page);
-				list_add(&page->lru, &zone->inactive_list);
+				list_add(&page->lru, inactive_list);
 				continue;
 			}
 			list_add(&page->lru, &page_list);
 			nr_taken++;
 		}
 		zone->nr_inactive -= nr_taken;
+		ckrm_zone_sub_inactive(ckrm_zone, nr_taken);
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -620,10 +633,15 @@ static void shrink_cache(struct zone *zo
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
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -654,7 +672,11 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void
+#ifdef CONFIG_CKRM_RES_MEM
+refill_inactive_zone(struct ckrm_zone *ckrm_zone, struct scan_control *sc)
+#else
 refill_inactive_zone(struct zone *zone, struct scan_control *sc)
+#endif
 {
 	int pgmoved;
 	int pgdeactivate = 0;
@@ -669,13 +691,21 @@ refill_inactive_zone(struct zone *zone, 
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
 	pgmoved = 0;
 	spin_lock_irq(&zone->lru_lock);
-	while (pgscanned < nr_pages && !list_empty(&zone->active_list)) {
-		page = lru_to_page(&zone->active_list);
-		prefetchw_prev_lru_page(page, &zone->active_list, flags);
+	while (pgscanned < nr_pages && !list_empty(active_list)) {
+		page = lru_to_page(active_list);
+		prefetchw_prev_lru_page(page, active_list, flags);
 		if (!TestClearPageLRU(page))
 			BUG();
 		list_del(&page->lru);
@@ -688,7 +718,7 @@ refill_inactive_zone(struct zone *zone, 
 			 */
 			__put_page(page);
 			SetPageLRU(page);
-			list_add(&page->lru, &zone->active_list);
+			list_add(&page->lru, active_list);
 		} else {
 			list_add(&page->lru, &l_hold);
 			pgmoved++;
@@ -697,6 +727,7 @@ refill_inactive_zone(struct zone *zone, 
 	}
 	zone->pages_scanned += pgscanned;
 	zone->nr_active -= pgmoved;
+	ckrm_zone_sub_active(ckrm_zone, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
 	/*
@@ -755,10 +786,11 @@ refill_inactive_zone(struct zone *zone, 
 			BUG();
 		if (!TestClearPageActive(page))
 			BUG();
-		list_move(&page->lru, &zone->inactive_list);
+		list_move(&page->lru, inactive_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_inactive += pgmoved;
+			ckrm_zone_add_inactive(ckrm_zone, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -769,6 +801,7 @@ refill_inactive_zone(struct zone *zone, 
 		}
 	}
 	zone->nr_inactive += pgmoved;
+	ckrm_zone_add_inactive(ckrm_zone, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -783,10 +816,11 @@ refill_inactive_zone(struct zone *zone, 
 		if (TestSetPageLRU(page))
 			BUG();
 		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
+		list_move(&page->lru, active_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_active += pgmoved;
+			ckrm_zone_add_active(ckrm_zone, pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
@@ -794,6 +828,7 @@ refill_inactive_zone(struct zone *zone, 
 		}
 	}
 	zone->nr_active += pgmoved;
+	ckrm_zone_add_active(ckrm_zone, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 
@@ -801,6 +836,32 @@ refill_inactive_zone(struct zone *zone, 
 	mod_page_state(pgdeactivate, pgdeactivate);
 }
 
+#ifdef CONFIG_CKRM_RES_MEM
+static void
+shrink_ckrmzone(struct ckrm_zone *czone, struct scan_control *sc)
+{
+	while (czone->shrink_active || czone->shrink_inactive) {
+		if (czone->shrink_active) {
+			sc->nr_to_scan = min(czone->shrink_active,
+					(unsigned long)SWAP_CLUSTER_MAX);
+			czone->shrink_active -= sc->nr_to_scan;
+			refill_inactive_zone(czone, sc);
+		}
+		if (czone->shrink_inactive) {
+			sc->nr_to_scan = min(czone->shrink_inactive,
+					(unsigned long)SWAP_CLUSTER_MAX);
+			czone->shrink_inactive -= sc->nr_to_scan;
+			shrink_cache(czone, sc);
+			if (sc->nr_to_reclaim <= 0) {
+				czone->shrink_active = 0;
+				czone->shrink_inactive = 0;
+				break;
+			}
+		}
+	}
+}
+#endif
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -809,6 +870,9 @@ shrink_zone(struct zone *zone, struct sc
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
+#ifdef CONFIG_CKRM_RES_MEM
+	struct ckrm_zone *czone;
+#endif
 
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
@@ -830,6 +894,24 @@ shrink_zone(struct zone *zone, struct sc
 
 	sc->nr_to_reclaim = sc->swap_cluster_max;
 
+#ifdef CONFIG_CKRM_RES_MEM
+	if (nr_active || nr_inactive) {
+		struct list_head *pos, *next;
+		LIST_HEAD(victims);
+
+		shrink_get_victims(zone, nr_active, nr_inactive, &victims);
+		pos = victims.next;
+		while (pos != &victims) {
+			czone = list_entry(pos, struct ckrm_zone, victim_list);
+			next = pos->next;
+			list_del_init(pos);
+			sc->nr_to_reclaim = czone->shrink_inactive;
+			shrink_ckrmzone(czone, sc);
+			ckrm_clear_shrink(czone);
+			pos = next;
+		}
+	}
+#else 
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
 			sc->nr_to_scan = min(nr_active,
@@ -847,6 +929,7 @@ shrink_zone(struct zone *zone, struct sc
 				break;
 		}
 	}
+#endif
 
 	throttle_vm_writeout();
 }

--6WlEvdN9Dv0WHSBl--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
