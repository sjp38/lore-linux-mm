Date: Mon, 25 Feb 2008 23:40:14 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 06/15] memcg: bad page if page_cgroup when free
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252339310.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Replace free_hot_cold_page's VM_BUG_ON(page_get_page_cgroup(page)) by a
"Bad page state" and clear: most users don't have CONFIG_DEBUG_VM on, and
if it were set here, it'd likely cause corruption when the page is reused.

Don't use page_assign_page_cgroup to clear it: that should be private to
memcontrol.c, and always called with the lock taken; and memmap_init_zone
doesn't need it either - like page->mapping and other pointers throughout
the kernel, Linux assumes pointers in zeroed structures are NULL pointers.

Instead use page_reset_bad_cgroup, added to memcontrol.h for this only.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I had page_reset_bad_cgroup as the approved inline function a few days ago,
but now there's been a cull of included header files, so it's a #define.

 include/linux/memcontrol.h |    8 ++++----
 mm/memcontrol.c            |   27 ++++++++++++---------------
 mm/page_alloc.c            |   18 ++++++++++++------
 3 files changed, 28 insertions(+), 25 deletions(-)

--- memcg05/include/linux/memcontrol.h	2008-02-25 14:05:38.000000000 +0000
+++ memcg06/include/linux/memcontrol.h	2008-02-25 14:05:55.000000000 +0000
@@ -29,8 +29,9 @@ struct mm_struct;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
-extern void page_assign_page_cgroup(struct page *page,
-					struct page_cgroup *pc);
+
+#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
+
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
@@ -82,8 +83,7 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_assign_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
+static inline void page_reset_bad_cgroup(struct page *page)
 {
 }
 
--- memcg05/mm/memcontrol.c	2008-02-25 14:05:38.000000000 +0000
+++ memcg06/mm/memcontrol.c	2008-02-25 14:05:55.000000000 +0000
@@ -140,11 +140,17 @@ struct mem_cgroup {
 
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock. We need to ensure that page->page_cgroup is atleast two
- * byte aligned (based on comments from Nick Piggin)
+ * lock.  We need to ensure that page->page_cgroup is at least two
+ * byte aligned (based on comments from Nick Piggin).  But since
+ * bit_spin_lock doesn't actually set that lock bit in a non-debug
+ * uniprocessor kernel, we should avoid setting it here too.
  */
 #define PAGE_CGROUP_LOCK_BIT 	0x0
-#define PAGE_CGROUP_LOCK 		(1 << PAGE_CGROUP_LOCK_BIT)
+#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
+#else
+#define PAGE_CGROUP_LOCK	0x0
+#endif
 
 /*
  * A page_cgroup page is associated with every page descriptor. The
@@ -271,19 +277,10 @@ static inline int page_cgroup_locked(str
 					&page->page_cgroup);
 }
 
-void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
+static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
 {
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
+	VM_BUG_ON(!page_cgroup_locked(page));
+	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
 }
 
 struct page_cgroup *page_get_page_cgroup(struct page *page)
--- memcg05/mm/page_alloc.c	2008-02-24 22:39:48.000000000 +0000
+++ memcg06/mm/page_alloc.c	2008-02-25 14:05:55.000000000 +0000
@@ -221,13 +221,19 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	printk(KERN_EMERG "Bad page state in process '%s'\n"
-		KERN_EMERG "page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n"
-		KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
-		KERN_EMERG "Backtrace:\n",
+	void *pc = page_get_page_cgroup(page);
+
+	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
+		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
+	if (pc) {
+		printk(KERN_EMERG "cgroup:%p\n", pc);
+		page_reset_bad_cgroup(page);
+	}
+	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
+		KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	page->flags &= ~(1 << PG_lru	|
 			1 << PG_private |
@@ -453,6 +459,7 @@ static inline int free_pages_check(struc
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -602,6 +609,7 @@ static int prep_new_page(struct page *pa
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -988,7 +996,6 @@ static void free_hot_cold_page(struct pa
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
-	VM_BUG_ON(page_get_page_cgroup(page));
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -2527,7 +2534,6 @@ void __meminit memmap_init_zone(unsigned
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
