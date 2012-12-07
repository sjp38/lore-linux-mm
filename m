Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D801B6B0085
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:26:15 -0500 (EST)
Date: Fri, 7 Dec 2012 14:26:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Debugging: Keep track of page owners
Message-Id: <20121207142614.428b8a54.akpm@linux-foundation.org>
In-Reply-To: <20121207212417.FAD8DAED@kernel.stglabs.ibm.com>
References: <20121207212417.FAD8DAED@kernel.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 07 Dec 2012 16:24:17 -0500
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> To: akpm@osdl.org

It's years since I was called that.

> From: mel@skynet.ie (Mel Gorman)

And him that.


I have cunningly divined the intention of your update and have queued
the below incremental.  The change to
pagetypeinfo_showmixedcount_print() was a surprise.  What's that there
for?




From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: debugging-keep-track-of-page-owners-fix

Use linux/stacktrace.h rather than hand-coding the stack tracing

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm_types.h   |    4 +-
 include/linux/stacktrace.h |    3 +
 kernel/stacktrace.c        |   23 ++++++++++++
 lib/Kconfig.debug          |    1 
 mm/page_alloc.c            |   65 ++++-------------------------------
 mm/pageowner.c             |   27 ++++----------
 mm/vmstat.c                |    5 ++
 7 files changed, 51 insertions(+), 77 deletions(-)

diff -puN include/linux/mm_types.h~debugging-keep-track-of-page-owners-fix include/linux/mm_types.h
--- a/include/linux/mm_types.h~debugging-keep-track-of-page-owners-fix
+++ a/include/linux/mm_types.h
@@ -8,6 +8,7 @@
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
+#include <linux/stacktrace.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
@@ -180,7 +181,8 @@ struct page {
 #ifdef CONFIG_PAGE_OWNER
 	int order;
 	unsigned int gfp_mask;
-	unsigned long trace[8];
+	struct stack_trace trace;
+	unsigned long trace_entries[8];
 #endif
 }
 /*
diff -puN include/linux/stacktrace.h~debugging-keep-track-of-page-owners-fix include/linux/stacktrace.h
--- a/include/linux/stacktrace.h~debugging-keep-track-of-page-owners-fix
+++ a/include/linux/stacktrace.h
@@ -20,6 +20,8 @@ extern void save_stack_trace_tsk(struct 
 				struct stack_trace *trace);
 
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
+extern int  snprint_stack_trace(char *buf, int buf_len,
+				struct stack_trace *trace, int spaces);
 
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
@@ -32,6 +34,7 @@ extern void save_stack_trace_user(struct
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
+# define snprint_stack_trace(buf, len, trace, spaces)	do { } while (0)
 #endif
 
 #endif
diff -puN kernel/stacktrace.c~debugging-keep-track-of-page-owners-fix kernel/stacktrace.c
--- a/kernel/stacktrace.c~debugging-keep-track-of-page-owners-fix
+++ a/kernel/stacktrace.c
@@ -11,6 +11,29 @@
 #include <linux/kallsyms.h>
 #include <linux/stacktrace.h>
 
+int snprint_stack_trace(char *buf, int buf_len, struct stack_trace *trace,
+			int spaces)
+{
+	int ret = 0;
+	int i;
+
+	if (WARN_ON(!trace->entries))
+		return 0;
+
+	for (i = 0; i < trace->nr_entries; i++) {
+		unsigned long ip = trace->entries[i];
+		int printed = snprintf(buf, buf_len, "%*c[<%p>] %pS\n",
+				1 + spaces, ' ',
+				(void *) ip, (void *) ip);
+		buf_len -= printed;
+		ret += printed;
+		buf += printed;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(snprint_stack_trace);
+
 void print_stack_trace(struct stack_trace *trace, int spaces)
 {
 	int i;
diff -puN lib/Kconfig.debug~debugging-keep-track-of-page-owners-fix lib/Kconfig.debug
--- a/lib/Kconfig.debug~debugging-keep-track-of-page-owners-fix
+++ a/lib/Kconfig.debug
@@ -103,6 +103,7 @@ config PAGE_OWNER
 	bool "Track page owner"
 	depends on DEBUG_KERNEL
 	select DEBUG_FS
+	select STACKTRACE
 	help
 	  This keeps track of what call chain is the owner of a page, may
 	  help to find bare alloc_page(s) leaks. Eats a fair amount of memory.
diff -puN mm/page_alloc.c~debugging-keep-track-of-page-owners-fix mm/page_alloc.c
--- a/mm/page_alloc.c~debugging-keep-track-of-page-owners-fix
+++ a/mm/page_alloc.c
@@ -2267,62 +2267,21 @@ __perform_reclaim(gfp_t gfp_mask, unsign
 	return progress;
 }
 
-#ifdef CONFIG_PAGE_OWNER
-static inline int valid_stack_ptr(struct thread_info *tinfo, void *p)
-{
-	return	p > (void *)tinfo &&
-		p < (void *)tinfo + THREAD_SIZE - 3;
-}
-
-static inline void __stack_trace(struct page *page, unsigned long *stack,
-			unsigned long bp)
-{
-	int i = 0;
-	unsigned long addr;
-	struct thread_info *tinfo = (struct thread_info *)
-		((unsigned long)stack & (~(THREAD_SIZE - 1)));
-
-	memset(page->trace, 0, sizeof(long) * 8);
-
-#ifdef CONFIG_FRAME_POINTER
-	if (bp) {
-		while (valid_stack_ptr(tinfo, (void *)bp)) {
-			addr = *(unsigned long *)(bp + sizeof(long));
-			page->trace[i] = addr;
-			if (++i >= 8)
-				break;
-			bp = *(unsigned long *)bp;
-		}
-		return;
-	}
-#endif /* CONFIG_FRAME_POINTER */
-	while (valid_stack_ptr(tinfo, stack)) {
-		addr = *stack++;
-		if (__kernel_text_address(addr)) {
-			page->trace[i] = addr;
-			if (++i >= 8)
-				break;
-		}
-	}
-}
-
 static void set_page_owner(struct page *page, unsigned int order,
 			unsigned int gfp_mask)
 {
-	unsigned long address;
-	unsigned long bp = 0;
-#ifdef CONFIG_X86_64
-	asm ("movq %%rbp, %0" : "=r" (bp) : );
-#endif
-#ifdef CONFIG_X86_32
-	asm ("movl %%ebp, %0" : "=r" (bp) : );
-#endif
+#ifdef CONFIG_PAGE_OWNER
+	struct stack_trace *trace = &page->trace;
+	trace->nr_entries = 0;
+	trace->max_entries = ARRAY_SIZE(page->trace_entries);
+	trace->entries = &page->trace_entries[0];
+	trace->skip = 3;
+	save_stack_trace(&page->trace);
+
 	page->order = (int) order;
 	page->gfp_mask = gfp_mask;
-	__stack_trace(page, &address, bp);
-}
 #endif /* CONFIG_PAGE_OWNER */
-
+}
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
@@ -2359,10 +2318,8 @@ retry:
 		goto retry;
 	}
 
-#ifdef CONFIG_PAGE_OWNER
 	if (page)
 		set_page_owner(page, order, gfp_mask);
-#endif
 	return page;
 }
 
@@ -2672,10 +2629,8 @@ nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 	return page;
 got_pg:
-#ifdef CONFIG_PAGE_OWNER
 	if (page)
 		set_page_owner(page, order, gfp_mask);
-#endif
 	if (kmemcheck_enabled)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 
@@ -2758,10 +2713,8 @@ out:
 
 	memcg_kmem_commit_charge(page, memcg, order);
 
-#ifdef CONFIG_PAGE_OWNER
 	if (page)
 		set_page_owner(page, order, gfp_mask);
-#endif
 
 	return page;
 }
diff -puN mm/pageowner.c~debugging-keep-track-of-page-owners-fix mm/pageowner.c
--- a/mm/pageowner.c~debugging-keep-track-of-page-owners-fix
+++ a/mm/pageowner.c
@@ -26,12 +26,8 @@ read_page_owner(struct file *file, char 
 {
 	unsigned long pfn;
 	struct page *page;
-	char *kbuf, *modname;
-	const char *symname;
+	char *kbuf;
 	int ret = 0;
-	char namebuf[128];
-	unsigned long offset = 0, symsize;
-	int i;
 	ssize_t num_written = 0;
 	int blocktype = 0, pagetype = 0;
 
@@ -67,7 +63,7 @@ read_page_owner(struct file *file, char 
 				pfn);
 
 		/* Stop search if page is allocated and has trace info */
-		if (page->order >= 0 && page->trace[0]) {
+		if (page->order >= 0 && page->trace.nr_entries) {
 			//intk("stopped search at pfn: %ld\n", pfn);
 			break;
 		}
@@ -126,20 +122,13 @@ read_page_owner(struct file *file, char 
 
 	num_written = ret;
 
-	for (i = 0; i < 8; i++) {
-		if (!page->trace[i])
-			break;
-		symname = kallsyms_lookup(page->trace[i], &symsize, &offset,
-					&modname, namebuf);
-		ret = snprintf(kbuf + num_written, count - num_written,
-				"[0x%lx] %s+%lu\n",
-				page->trace[i], namebuf, offset);
-		if (ret >= count - num_written) {
-			ret = -ENOMEM;
-			goto out;
-		}
-		num_written += ret;
+	ret = snprint_stack_trace(kbuf + num_written, count - num_written,
+				  &page->trace, 0);
+	if (ret >= count - num_written) {
+		ret = -ENOMEM;
+		goto out;
 	}
+	num_written += ret;
 
 	ret = snprintf(kbuf + num_written, count - num_written, "\n");
 	if (ret >= count - num_written) {
diff -puN mm/vmstat.c~debugging-keep-track-of-page-owners-fix mm/vmstat.c
--- a/mm/vmstat.c~debugging-keep-track-of-page-owners-fix
+++ a/mm/vmstat.c
@@ -985,7 +985,10 @@ static void pagetypeinfo_showmixedcount_
 
 			pagetype = allocflags_to_migratetype(page->gfp_mask);
 			if (pagetype != mtype) {
-				count[mtype]++;
+				if (is_migrate_cma(pagetype))
+					count[MIGRATE_MOVABLE]++;
+				else
+					count[mtype]++;
 				break;
 			}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
