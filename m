Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7076B0398
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:29:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v190so23953951pfb.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:29:49 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id o13si1092317pgd.349.2017.03.07.13.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:29:48 -0800 (PST)
Message-Id: <20170307212943.573855971@goodmis.org>
Date: Tue, 07 Mar 2017 16:28:37 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [RFC][PATCH 4/4] ftrace: Allow for function tracing to record init functions on boot
 up
References: <20170307212833.964734229@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0004-ftrace-Allow-for-function-tracing-to-record-init-fun.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Todd Brandt <todd.e.brandt@linux.intel.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>

From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>

Adding a hook into free_reserve_area() that informs ftrace that boot up init
text is being free, lets ftrace safely remove those init functions from its
records, which keeps ftrace from trying to modify text that no longer
exists.

Note, this still does not allow for tracing .init text of modules, as
modules require different work for freeing its init code.

Link: http://lkml.kernel.org/r/1488502497.7212.24.camel@linux.intel.com

Cc: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Requested-by: Todd Brandt <todd.e.brandt@linux.intel.com>
Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 include/linux/ftrace.h  |  3 +++
 include/linux/init.h    |  4 +++-
 kernel/trace/ftrace.c   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c         |  4 ++++
 scripts/recordmcount.c  |  1 +
 scripts/recordmcount.pl |  1 +
 6 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 569db5589851..25407b5553c3 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -249,6 +249,8 @@ static inline int ftrace_function_local_disabled(struct ftrace_ops *ops)
 extern void ftrace_stub(unsigned long a0, unsigned long a1,
 			struct ftrace_ops *op, struct pt_regs *regs);
 
+void ftrace_free_mem(void *start, void *end);
+
 #else /* !CONFIG_FUNCTION_TRACER */
 /*
  * (un)register_ftrace_function must be a macro since the ops parameter
@@ -262,6 +264,7 @@ static inline int ftrace_nr_registered_ops(void)
 }
 static inline void clear_ftrace_function(void) { }
 static inline void ftrace_kill(void) { }
+static inline void ftrace_free_mem(void *start, void *end) { }
 #endif /* CONFIG_FUNCTION_TRACER */
 
 #ifdef CONFIG_STACK_TRACER
diff --git a/include/linux/init.h b/include/linux/init.h
index 885c3e6d0f9d..c119e76f6d6e 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -39,7 +39,7 @@
 
 /* These are for everybody (although not all archs will actually
    discard it in modules) */
-#define __init		__section(.init.text) __cold notrace __latent_entropy
+#define __init		__section(.init.text) __cold __inittrace __latent_entropy
 #define __initdata	__section(.init.data)
 #define __initconst	__section(.init.rodata)
 #define __exitdata	__section(.exit.data)
@@ -68,8 +68,10 @@
 
 #ifdef MODULE
 #define __exitused
+#define __inittrace notrace
 #else
 #define __exitused  __used
+#define __inittrace
 #endif
 
 #define __exit          __section(.exit.text) __exitused __cold notrace
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index d129ae51329a..4c2d751eb886 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -5251,6 +5251,50 @@ void ftrace_module_enable(struct module *mod)
 	mutex_unlock(&ftrace_lock);
 }
 
+void ftrace_free_mem(void *start_ptr, void *end_ptr)
+{
+	unsigned long start = (unsigned long)start_ptr;
+	unsigned long end = (unsigned long)end_ptr;
+	struct ftrace_page **last_pg = &ftrace_pages_start;
+	struct ftrace_page *pg;
+	struct dyn_ftrace *rec;
+	struct dyn_ftrace key;
+	int order;
+
+	key.ip = start;
+	key.flags = end;	/* overload flags, as it is unsigned long */
+
+	mutex_lock(&ftrace_lock);
+
+	for (pg = ftrace_pages_start; pg; last_pg = &pg->next, pg = *last_pg) {
+		if (end < pg->records[0].ip ||
+		    start >= (pg->records[pg->index - 1].ip + MCOUNT_INSN_SIZE))
+			continue;
+ again:
+		rec = bsearch(&key, pg->records, pg->index,
+			      sizeof(struct dyn_ftrace),
+			      ftrace_cmp_recs);
+		if (!rec)
+			continue;
+		pg->index--;
+		if (!pg->index) {
+			*last_pg = pg->next;
+			order = get_count_order(pg->size / ENTRIES_PER_PAGE);
+			free_pages((unsigned long)pg->records, order);
+			kfree(pg);
+			pg = container_of(last_pg, struct ftrace_page, next);
+			if (!(*last_pg))
+				ftrace_pages = pg;
+			continue;
+		}
+		memmove(rec, rec + 1,
+			(pg->index - (rec - pg->records)) * sizeof(*rec));
+		/* More than one function may be in this block */
+		goto again;
+	}
+	mutex_unlock(&ftrace_lock);
+}
+
 void ftrace_module_init(struct module *mod)
 {
 	if (ftrace_disabled || !mod->num_ftrace_callsites)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f64feca..95ac03de4cda 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/ftrace.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -6441,6 +6442,9 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 	void *pos;
 	unsigned long pages = 0;
 
+	/* This may be .init text, inform ftrace to remove it */
+	ftrace_free_mem(start, end);
+
 	start = (void *)PAGE_ALIGN((unsigned long)start);
 	end = (void *)((unsigned long)end & PAGE_MASK);
 	for (pos = start; pos < end; pos += PAGE_SIZE, pages++) {
diff --git a/scripts/recordmcount.c b/scripts/recordmcount.c
index aeb34223167c..16e086dcc567 100644
--- a/scripts/recordmcount.c
+++ b/scripts/recordmcount.c
@@ -412,6 +412,7 @@ static int
 is_mcounted_section_name(char const *const txtname)
 {
 	return strcmp(".text",           txtname) == 0 ||
+		strcmp(".init.text",     txtname) == 0 ||
 		strcmp(".ref.text",      txtname) == 0 ||
 		strcmp(".sched.text",    txtname) == 0 ||
 		strcmp(".spinlock.text", txtname) == 0 ||
diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index faac4b10d8ea..328590d58eee 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
@@ -130,6 +130,7 @@ if ($inputfile =~ m,kernel/trace/ftrace\.o$,) {
 # Acceptable sections to record.
 my %text_sections = (
      ".text" => 1,
+     ".init.text" => 1,
      ".ref.text" => 1,
      ".sched.text" => 1,
      ".spinlock.text" => 1,
-- 
2.10.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
