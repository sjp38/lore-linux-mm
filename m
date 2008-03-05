Date: Wed, 5 Mar 2008 20:55:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Preview] [PATCH] radix tree based page cgroup [1/6]
Message-Id: <20080305205547.fbc3b1fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "taka@valinux.co.jp" <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

 * Exporting page_cgroup definition.
 * Remove page_cgroup member from sturct page.
 * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.

Other chages will appear in following patches.
There is a change in the structure itself, spin_lock is added.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h  |   11 --------
 include/linux/mm_types.h    |    3 --
 include/linux/page_cgroup.h |   47 +++++++++++++++++++++++++++++++++++
 mm/memcontrol.c             |   59 --------------------------------------------
 4 files changed, 48 insertions(+), 72 deletions(-)

Index: linux-2.6.25-rc4/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ linux-2.6.25-rc4/include/linux/page_cgroup.h
@@ -0,0 +1,47 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
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
+ * 2. cannot lookup entry and allocate was false.
+ * return -ENOMEM if cannot allocate memory.
+ * If allocate==false, gfpmask will be ignored as a result.
+ */
+
+struct page_cgroup *
+get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate);
+
+#else
+
+static struct page_cgroup *
+get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
+{
+	return NULL;
+}
+#endif
+#endif
Index: linux-2.6.25-rc4/include/linux/mm_types.h
===================================================================
--- linux-2.6.25-rc4.orig/include/linux/mm_types.h
+++ linux-2.6.25-rc4/include/linux/mm_types.h
@@ -88,9 +88,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
-#endif
 };
 
 /*
Index: linux-2.6.25-rc4/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/memcontrol.c
+++ linux-2.6.25-rc4/mm/memcontrol.c
@@ -30,6 +30,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/uaccess.h>
 
@@ -139,33 +140,6 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
-/*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	int ref_cnt;			/* cached, mapped, migrating */
-	int flags;
-};
-#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -256,37 +230,6 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
-{
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
-}
-
-struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
-}
-
-static void lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
Index: linux-2.6.25-rc4/include/linux/memcontrol.h
===================================================================
--- linux-2.6.25-rc4.orig/include/linux/memcontrol.h
+++ linux-2.6.25-rc4/include/linux/memcontrol.h
@@ -30,9 +30,6 @@ struct mm_struct;
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
 
-#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
-
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -82,14 +79,6 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_reset_bad_cgroup(struct page *page)
-{
-}
-
-static inline struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return NULL;
-}
 
 static inline int mem_cgroup_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
Index: linux-2.6.25-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/page_alloc.c
+++ linux-2.6.25-rc4/mm/page_alloc.c
@@ -222,17 +222,11 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	void *pc = page_get_page_cgroup(page);
-
 	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
 		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
-	if (pc) {
-		printk(KERN_EMERG "cgroup:%p\n", pc);
-		page_reset_bad_cgroup(page);
-	}
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
@@ -460,7 +454,6 @@ static inline int free_pages_check(struc
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -610,7 +603,6 @@ static int prep_new_page(struct page *pa
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
