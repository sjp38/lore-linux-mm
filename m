Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F18C6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 18:17:36 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c67so840898itg.23
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 15:17:36 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 82si4684328itf.68.2017.03.28.15.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 15:17:35 -0700 (PDT)
Message-Id: <20170328221729.593175609@goodmis.org>
Date: Tue, 28 Mar 2017 18:16:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [for-next][PATCH 5/7] ftrace: Allow for function tracing to record init functions on boot
 up
References: <20170328221645.326712684@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0005-ftrace-Allow-for-function-tracing-to-record-init-fun.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Todd Brandt <todd.e.brandt@linux.intel.com>

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
 include/linux/ftrace.h  |  5 +++++
 include/linux/init.h    |  4 +++-
 kernel/trace/ftrace.c   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c         |  4 ++++
 scripts/recordmcount.c  |  1 +
 scripts/recordmcount.pl |  1 +
 6 files changed, 58 insertions(+), 1 deletion(-)

diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 569db5589851..0276a2c487e6 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -146,6 +146,10 @@ struct ftrace_ops_hash {
 	struct ftrace_hash		*filter_hash;
 	struct mutex			regex_lock;
 };
+
+void ftrace_free_mem(void *start, void *end);
+#else
+static inline void ftrace_free_mem(void *start, void *end) { }
 #endif
 
 /*
@@ -262,6 +266,7 @@ static inline int ftrace_nr_registered_ops(void)
 }
 static inline void clear_ftrace_function(void) { }
 static inline void ftrace_kill(void) { }
+static inline void ftrace_free_mem(void *start, void *end) { }
 #endif /* CONFIG_FUNCTION_TRACER */
 
 #ifdef CONFIG_STACK_TRACER
diff --git a/include/linux/init.h b/include/linux/init.h
index 79af0962fd52..94769d687cf0 100644
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
index b9691ee8f6c1..0556a202c055 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -5262,6 +5262,50 @@ void ftrace_module_init(struct module *mod)
 }
 #endif /* CONFIG_MODULES */
 
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
 void __init ftrace_init(void)
 {
 	extern unsigned long __start_mcount_loc[];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cbde310abed..eee82bfb7cd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -65,6 +65,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/ftrace.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -6605,6 +6606,9 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
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
index 0b6002b36f20..1633c3e6c0b9 100755
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
