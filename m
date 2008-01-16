Date: Wed, 16 Jan 2008 23:24:21 +0100
From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Only print kernel debug information for OOMs caused by kernel allocations
Message-ID: <20080116222421.GA7953@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I recently suffered an 20+ minutes oom thrash disk to death and computer
completely unresponsive situation on my desktop when some user program
decided to grab all memory. It eventually recovered, but left lots
of ugly and imho misleading messages in the kernel log. here's a minor
improvement

-Andi

---

Only print kernel debug information for OOMs caused by kernel allocations

For any page cache allocation don't print the backtrace and the detailed
zone debugging information. This makes the problem look less like 
a kernel bug because it typically isn't.

I needed a new task flag for that. Since the bits are running low
I reused an unused one (PF_STARTING) 

Also clarify the error message (OOM means nothing to a normal user) 

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/pagemap.h |    7 -------
 include/linux/sched.h   |    2 +-
 mm/filemap.c            |   16 +++++++++++-----
 mm/oom_kill.c           |    9 ++++++---
 4 files changed, 18 insertions(+), 16 deletions(-)

Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h
+++ linux/include/linux/sched.h
@@ -1358,7 +1358,7 @@ static inline void put_task_struct(struc
  */
 #define PF_ALIGNWARN	0x00000001	/* Print alignment warning msgs */
 					/* Not implemented yet, only for 486*/
-#define PF_STARTING	0x00000002	/* being created */
+#define PF_USER_ALLOC	0x00000002	/* Current allocation is user initiated */
 #define PF_EXITING	0x00000004	/* getting shut down */
 #define PF_EXITPIDONE	0x00000008	/* pi exit done on shut down */
 #define PF_VCPU		0x00000010	/* I'm a virtual CPU */
Index: linux/mm/oom_kill.c
===================================================================
--- linux.orig/mm/oom_kill.c
+++ linux/mm/oom_kill.c
@@ -340,11 +340,14 @@ static int oom_kill_process(struct task_
 	struct task_struct *c;
 
 	if (printk_ratelimit()) {
-		printk(KERN_WARNING "%s invoked oom-killer: "
+		printk(KERN_WARNING "%s ran out of available memory: "
 			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
 			current->comm, gfp_mask, order, current->oomkilladj);
-		dump_stack();
-		show_mem();
+		/* Only dump backtrace for kernel initiated allocations */
+		if (!(p->flags & PF_USER_ALLOC)) {
+			dump_stack();
+			show_mem();
+		}
 	}
 
 	/*
Index: linux/include/linux/pagemap.h
===================================================================
--- linux.orig/include/linux/pagemap.h
+++ linux/include/linux/pagemap.h
@@ -62,14 +62,7 @@ static inline void mapping_set_gfp_mask(
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
-#ifdef CONFIG_NUMA
 extern struct page *__page_cache_alloc(gfp_t gfp);
-#else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
-{
-	return alloc_pages(gfp, 0);
-}
-#endif
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c
+++ linux/mm/filemap.c
@@ -482,17 +482,23 @@ int add_to_page_cache_lru(struct page *p
 	return ret;
 }
 
-#ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
 {
+	struct task_struct *me = current;
+	unsigned old = (~me->flags) & PF_USER_ALLOC;
+	struct page *p;
+
+	me->flags |= PF_USER_ALLOC;
 	if (cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
-		return alloc_pages_node(n, gfp, 0);
-	}
-	return alloc_pages(gfp, 0);
+		p = alloc_pages_node(n, gfp, 0);
+	} else
+		p = alloc_pages(gfp, 0);
+	/* Clear USER_ALLOC if it wasn't set originally */
+	me->flags ^= old;
+	return p;
 }
 EXPORT_SYMBOL(__page_cache_alloc);
-#endif
 
 static int __sleep_on_page_lock(void *word)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
