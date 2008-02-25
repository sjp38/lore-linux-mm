Date: Mon, 25 Feb 2008 12:10:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [1/7] definitions for
 page_cgroup
Message-Id: <20080225121034.bd74be07.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(This is one of a series of patch for "lookup page_cgroup" patches..)

 * Exporting page_cgroup definition.
 * Remove page_cgroup member from sturct page.
 * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.

Other chages will appear in following patches.
There is a change in the structure itself, spin_lock is added.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h  |   13 -----
 include/linux/mm_types.h    |    3 -
 include/linux/page_cgroup.h |   46 +++++++++++++++++++
 mm/memcontrol.c             |  103 --------------------------------------------
 mm/page_alloc.c             |    2 
 5 files changed, 47 insertions(+), 120 deletions(-)

Index: linux-2.6.25-rc2/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ linux-2.6.25-rc2/include/linux/page_cgroup.h
@@ -0,0 +1,44 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+
+#ifdef CONFIG_CGROUP_MEM_CONT
+/*
+ * page_cgroup is yet another mem_map structure for accounting  usage.
+ * but, unlike mem_map, allocated on demand for accounted pages.
+ * see also memcontrol.h
+ * In nature, this cosumes much amount of memory.
+ */
+
+struct mem_cgroup;
+
+struct page_cgroup {
+	struct page 		*page;       /* the page this accounts for*/
+	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
+	int    			flags;	     /* See below */
+	int    			refcnt;      /* reference count */
+	spinlock_t		lock;        /* lock for all above members */
+	struct list_head 	lru;         /* for per cgroup LRU */
+};
+
+/* flags */
+#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
+#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
+
+/*
+ * Lookup and return page_cgroup struct.
+ * returns NULL when
+ * 1. Page Cgroup is not activated yet.
+ * 2. cannot lookup entry and gfp_mask was 0.
+ * return -ENOMEM if cannot allocate memory.
+ */
+
+struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask);
+
+#else
+
+static struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask)
+{
+	return NULL;
+}
+#endif
+#endif
Index: linux-2.6.25-rc2/include/linux/mm_types.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/mm_types.h
+++ linux-2.6.25-rc2/include/linux/mm_types.h
@@ -91,9 +91,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_CONT
-	unsigned long page_cgroup;
-#endif
 };
 
 /*
Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -30,6 +30,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/uaccess.h>
 
@@ -138,29 +139,6 @@ struct mem_cgroup {
 	struct mem_cgroup_stat stat;
 };
 
-/*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock. We need to ensure that page->page_cgroup is atleast two
- * byte aligned (based on comments from Nick Piggin)
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#define PAGE_CGROUP_LOCK 		(1 << PAGE_CGROUP_LOCK_BIT)
-
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
-					/* mapped and cached states     */
-	int	 flags;
-};
-#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
-
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
@@ -265,85 +243,6 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT,
-					&page->page_cgroup);
-}
-
-void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
-{
-	int locked;
-
-	/*
-	 * While resetting the page_cgroup we might not hold the
-	 * page_cgroup lock. free_hot_cold_page() is an example
-	 * of such a scenario
-	 */
-	if (pc)
-		VM_BUG_ON(!page_cgroup_locked(page));
-	locked = (page->page_cgroup & PAGE_CGROUP_LOCK);
-	page->page_cgroup = ((unsigned long)pc | locked);
-}
-
-struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return (struct page_cgroup *)
-		(page->page_cgroup & ~PAGE_CGROUP_LOCK);
-}
-
-static void __always_inline lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-	VM_BUG_ON(!page_cgroup_locked(page));
-}
-
-static void __always_inline unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-/*
- * Tie new page_cgroup to struct page under lock_page_cgroup()
- * This can fail if the page has been tied to a page_cgroup.
- * If success, returns 0.
- */
-static int page_cgroup_assign_new_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	int ret = 0;
-
-	lock_page_cgroup(page);
-	if (!page_get_page_cgroup(page))
-		page_assign_page_cgroup(page, pc);
-	else /* A page is tied to other pc. */
-		ret = 1;
-	unlock_page_cgroup(page);
-	return ret;
-}
-
-/*
- * Clear page->page_cgroup member under lock_page_cgroup().
- * If given "pc" value is different from one page->page_cgroup,
- * page->cgroup is not cleared.
- * Returns a value of page->page_cgroup at lock taken.
- * A can can detect failure of clearing by following
- *  clear_page_cgroup(page, pc) == pc
- */
-
-static struct page_cgroup *clear_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	struct page_cgroup *ret;
-	/* lock and clear */
-	lock_page_cgroup(page);
-	ret = page_get_page_cgroup(page);
-	if (likely(ret == pc))
-		page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-	return ret;
-}
-
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
Index: linux-2.6.25-rc2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/memcontrol.h
+++ linux-2.6.25-rc2/include/linux/memcontrol.h
@@ -32,9 +32,6 @@ struct mm_struct;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
-extern void page_assign_page_cgroup(struct page *page,
-					struct page_cgroup *pc);
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern void mem_cgroup_uncharge(struct page_cgroup *pc);
@@ -85,16 +82,6 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_assign_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-}
-
-static inline struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return NULL;
-}
-
 static inline int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask)
 {
Index: linux-2.6.25-rc2/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/page_alloc.c
+++ linux-2.6.25-rc2/mm/page_alloc.c
@@ -988,7 +988,6 @@ static void free_hot_cold_page(struct pa
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
-	VM_BUG_ON(page_get_page_cgroup(page));
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -2527,7 +2526,6 @@ void __meminit memmap_init_zone(unsigned
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
-		page_assign_page_cgroup(page, NULL);
 		SetPageReserved(page);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
