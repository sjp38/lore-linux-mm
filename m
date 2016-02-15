Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BE1756B0253
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 22:05:05 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id e127so79587234pfe.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 19:05:05 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 12si39985627pfb.80.2016.02.14.19.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 19:05:04 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id e127so6910113pfe.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 19:05:04 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 2/2] mm/page_ref: add tracepoint to track down page reference manipulation
Date: Mon, 15 Feb 2016 12:04:50 +0900
Message-Id: <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

CMA allocation should be guaranteed to succeed by definition, but,
unfortunately, it would be failed sometimes. It is hard to track down
the problem, because it is related to page reference manipulation and
we don't have any facility to analyze it.

This patch adds tracepoints to track down page reference manipulation.
With it, we can find exact reason of failure and can fix the problem.
Following is an example of tracepoint output.

<...>-9018  [004]    92.678375: page_ref_set:         pfn=0x17ac9 flags=0x0 count=1 mapcount=0 mapping=(nil) mt=4 val=1
<...>-9018  [004]    92.678378: kernel_stack:
 => get_page_from_freelist (ffffffff81176659)
 => __alloc_pages_nodemask (ffffffff81176d22)
 => alloc_pages_vma (ffffffff811bf675)
 => handle_mm_fault (ffffffff8119e693)
 => __do_page_fault (ffffffff810631ea)
 => trace_do_page_fault (ffffffff81063543)
 => do_async_page_fault (ffffffff8105c40a)
 => async_page_fault (ffffffff817581d8)
[snip]
<...>-9018  [004]    92.678379: page_ref_mod:         pfn=0x17ac9 flags=0x40048 count=2 mapcount=1 mapping=0xffff880015a78dc1 mt=4 val=1
[snip]
...
...
<...>-9131  [001]    93.174468: test_pages_isolated:  start_pfn=0x17800 end_pfn=0x17c00 fin_pfn=0x17ac9 ret=fail
[snip]
<...>-9018  [004]    93.174843: page_ref_mod_and_test: pfn=0x17ac9 flags=0x40068 count=0 mapcount=0 mapping=0xffff880015a78dc1 mt=4 val=-1 ret=1
 => release_pages (ffffffff8117c9e4)
 => free_pages_and_swap_cache (ffffffff811b0697)
 => tlb_flush_mmu_free (ffffffff81199616)
 => tlb_finish_mmu (ffffffff8119a62c)
 => exit_mmap (ffffffff811a53f7)
 => mmput (ffffffff81073f47)
 => do_exit (ffffffff810794e9)
 => do_group_exit (ffffffff81079def)
 => SyS_exit_group (ffffffff81079e74)
 => entry_SYSCALL_64_fastpath (ffffffff817560b6)

This output shows that problem comes from exit path. In exit path,
to improve performance, pages are not freed immediately. They are gathered
and processed by batch. During this process, migration cannot be possible
and CMA allocation is failed. This problem is hard to find without this
page reference tracepoint facility.

Enabling this feature bloat kernel text 30 KB in my configuration.

   text    data     bss     dec     hex filename
12127327        2243616 1507328 15878271         f2487f vmlinux_disabled
12157208        2258880 1507328 15923416         f2f8d8 vmlinux_enabled

v2:
o Use static key of each tracepoints to avoid function call overhead
when tracepoints are disabled.
o Print human-readable page flag through show_page_flags()
o Add more description to Kconfig.debug.

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_ref.h        |  90 +++++++++++++++++++++++++--
 include/trace/events/page_ref.h | 133 ++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig.debug                |  13 ++++
 mm/Makefile                     |   1 +
 mm/debug_page_ref.c             |  53 ++++++++++++++++
 5 files changed, 285 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/events/page_ref.h
 create mode 100644 mm/debug_page_ref.c

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 534249c..fd6d9a5 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -1,6 +1,54 @@
 #include <linux/atomic.h>
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
+#include <linux/tracepoint-defs.h>
+
+extern struct tracepoint __tracepoint_page_ref_set;
+extern struct tracepoint __tracepoint_page_ref_mod;
+extern struct tracepoint __tracepoint_page_ref_mod_and_test;
+extern struct tracepoint __tracepoint_page_ref_mod_and_return;
+extern struct tracepoint __tracepoint_page_ref_mod_unless;
+extern struct tracepoint __tracepoint_page_ref_freeze;
+extern struct tracepoint __tracepoint_page_ref_unfreeze;
+
+#ifdef CONFIG_DEBUG_PAGE_REF
+#define page_ref_tracepoint_active(t) static_key_false(&(t).key)
+
+extern void __page_ref_set(struct page *page, int v);
+extern void __page_ref_mod(struct page *page, int v);
+extern void __page_ref_mod_and_test(struct page *page, int v, int ret);
+extern void __page_ref_mod_and_return(struct page *page, int v, int ret);
+extern void __page_ref_mod_unless(struct page *page, int v, int u);
+extern void __page_ref_freeze(struct page *page, int v, int ret);
+extern void __page_ref_unfreeze(struct page *page, int v);
+
+#else
+
+#define page_ref_tracepoint_active(t) false
+
+static inline void __page_ref_set(struct page *page, int v)
+{
+}
+static inline void __page_ref_mod(struct page *page, int v)
+{
+}
+static inline void __page_ref_mod_and_test(struct page *page, int v, int ret)
+{
+}
+static inline void __page_ref_mod_and_return(struct page *page, int v, int ret)
+{
+}
+static inline void __page_ref_mod_unless(struct page *page, int v, int u)
+{
+}
+static inline void __page_ref_freeze(struct page *page, int v, int ret)
+{
+}
+static inline void __page_ref_unfreeze(struct page *page, int v)
+{
+}
+
+#endif
 
 static inline int page_count(struct page *page)
 {
@@ -10,6 +58,8 @@ static inline int page_count(struct page *page)
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
+		__page_ref_set(page, v);
 }
 
 /*
@@ -24,46 +74,74 @@ static inline void init_page_count(struct page *page)
 static inline void page_ref_add(struct page *page, int nr)
 {
 	atomic_add(nr, &page->_count);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
+		__page_ref_mod(page, nr);
 }
 
 static inline void page_ref_sub(struct page *page, int nr)
 {
 	atomic_sub(nr, &page->_count);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
+		__page_ref_mod(page, -nr);
 }
 
 static inline void page_ref_inc(struct page *page)
 {
 	atomic_inc(&page->_count);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
+		__page_ref_mod(page, 1);
 }
 
 static inline void page_ref_dec(struct page *page)
 {
 	atomic_dec(&page->_count);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
+		__page_ref_mod(page, -1);
 }
 
 static inline int page_ref_sub_and_test(struct page *page, int nr)
 {
-	return atomic_sub_and_test(nr, &page->_count);
+	int ret = atomic_sub_and_test(nr, &page->_count);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
+		__page_ref_mod_and_test(page, -nr, ret);
+	return ret;
 }
 
 static inline int page_ref_dec_and_test(struct page *page)
 {
-	return atomic_dec_and_test(&page->_count);
+	int ret = atomic_dec_and_test(&page->_count);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
+		__page_ref_mod_and_test(page, -1, ret);
+	return ret;
 }
 
 static inline int page_ref_dec_return(struct page *page)
 {
-	return atomic_dec_return(&page->_count);
+	int ret = atomic_dec_return(&page->_count);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
+		__page_ref_mod_and_return(page, -1, ret);
+	return ret;
 }
 
 static inline int page_ref_add_unless(struct page *page, int nr, int u)
 {
-	return atomic_add_unless(&page->_count, nr, u);
+	int ret = atomic_add_unless(&page->_count, nr, u);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
+		__page_ref_mod_unless(page, nr, ret);
+	return ret;
 }
 
 static inline int page_ref_freeze(struct page *page, int count)
 {
-	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_freeze))
+		__page_ref_freeze(page, count, ret);
+	return ret;
 }
 
 static inline void page_ref_unfreeze(struct page *page, int count)
@@ -72,5 +150,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON(count == 0);
 
 	atomic_set(&page->_count, count);
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
+		__page_ref_unfreeze(page, count);
 }
 
diff --git a/include/trace/events/page_ref.h b/include/trace/events/page_ref.h
new file mode 100644
index 0000000..9fb920a
--- /dev/null
+++ b/include/trace/events/page_ref.h
@@ -0,0 +1,133 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM page_ref
+
+#if !defined(_TRACE_PAGE_REF_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGE_REF_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+#include <trace/events/mmflags.h>
+
+DECLARE_EVENT_CLASS(page_ref_mod_template,
+
+	TP_PROTO(struct page *page, int v),
+
+	TP_ARGS(page, v),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned long, flags)
+		__field(int, count)
+		__field(int, mapcount)
+		__field(void *, mapping)
+		__field(int, mt)
+		__field(int, val)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = page_to_pfn(page);
+		__entry->flags = page->flags;
+		__entry->count = atomic_read(&page->_count);
+		__entry->mapcount = page_mapcount(page);
+		__entry->mapping = page->mapping;
+		__entry->mt = get_pageblock_migratetype(page);
+		__entry->val = v;
+	),
+
+	TP_printk("pfn=0x%lx flags=%s count=%d mapcount=%d mapping=%p mt=%d val=%d",
+		__entry->pfn,
+		show_page_flags(__entry->flags & ((1UL << NR_PAGEFLAGS) - 1)),
+		__entry->count,
+		__entry->mapcount, __entry->mapping, __entry->mt,
+		__entry->val)
+);
+
+DEFINE_EVENT(page_ref_mod_template, page_ref_set,
+
+	TP_PROTO(struct page *page, int v),
+
+	TP_ARGS(page, v)
+);
+
+DEFINE_EVENT(page_ref_mod_template, page_ref_mod,
+
+	TP_PROTO(struct page *page, int v),
+
+	TP_ARGS(page, v)
+);
+
+DECLARE_EVENT_CLASS(page_ref_mod_and_test_template,
+
+	TP_PROTO(struct page *page, int v, int ret),
+
+	TP_ARGS(page, v, ret),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned long, flags)
+		__field(int, count)
+		__field(int, mapcount)
+		__field(void *, mapping)
+		__field(int, mt)
+		__field(int, val)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = page_to_pfn(page);
+		__entry->flags = page->flags;
+		__entry->count = atomic_read(&page->_count);
+		__entry->mapcount = page_mapcount(page);
+		__entry->mapping = page->mapping;
+		__entry->mt = get_pageblock_migratetype(page);
+		__entry->val = v;
+		__entry->ret = ret;
+	),
+
+	TP_printk("pfn=0x%lx flags=%s count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
+		__entry->pfn,
+		show_page_flags(__entry->flags & ((1UL << NR_PAGEFLAGS) - 1)),
+		__entry->count,
+		__entry->mapcount, __entry->mapping, __entry->mt,
+		__entry->val, __entry->ret)
+);
+
+DEFINE_EVENT(page_ref_mod_and_test_template, page_ref_mod_and_test,
+
+	TP_PROTO(struct page *page, int v, int ret),
+
+	TP_ARGS(page, v, ret)
+);
+
+DEFINE_EVENT(page_ref_mod_and_test_template, page_ref_mod_and_return,
+
+	TP_PROTO(struct page *page, int v, int ret),
+
+	TP_ARGS(page, v, ret)
+);
+
+DEFINE_EVENT(page_ref_mod_and_test_template, page_ref_mod_unless,
+
+	TP_PROTO(struct page *page, int v, int ret),
+
+	TP_ARGS(page, v, ret)
+);
+
+DEFINE_EVENT(page_ref_mod_and_test_template, page_ref_freeze,
+
+	TP_PROTO(struct page *page, int v, int ret),
+
+	TP_ARGS(page, v, ret)
+);
+
+DEFINE_EVENT(page_ref_mod_template, page_ref_unfreeze,
+
+	TP_PROTO(struct page *page, int v),
+
+	TP_ARGS(page, v)
+);
+
+#endif /* _TRACE_PAGE_COUNT_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index ee57dea..0596495 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -75,3 +75,16 @@ config PAGE_POISONING_ZERO
 	   allocation.
 
 	   If unsure, say N
+	bool
+
+config DEBUG_PAGE_REF
+	bool "Enable tracepoint to track down page reference manipulation"
+	depends on DEBUG_KERNEL
+	---help---
+	  This is the feature to add tracepoint for tracking down page reference
+	  manipulation. This tracking is useful to diagnosis functional failure
+	  due to migration failure caused by page reference mismatch. Be
+	  careful to turn on this feature because it could bloat some kernel
+	  text. In my configuration, it bloats 30 KB. Although kernel text will
+	  be bloated, there would be no runtime performance overhead if
+	  tracepoint isn't enabled thanks to jump label.
diff --git a/mm/Makefile b/mm/Makefile
index fb1a794..4f0f135 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
 obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
 obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
+obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
diff --git a/mm/debug_page_ref.c b/mm/debug_page_ref.c
new file mode 100644
index 0000000..87e60e8
--- /dev/null
+++ b/mm/debug_page_ref.c
@@ -0,0 +1,53 @@
+#include <linux/tracepoint.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/page_ref.h>
+
+void __page_ref_set(struct page *page, int v)
+{
+	trace_page_ref_set(page, v);
+}
+EXPORT_SYMBOL(__page_ref_set);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_set);
+
+void __page_ref_mod(struct page *page, int v)
+{
+	trace_page_ref_mod(page, v);
+}
+EXPORT_SYMBOL(__page_ref_mod);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_mod);
+
+void __page_ref_mod_and_test(struct page *page, int v, int ret)
+{
+	trace_page_ref_mod_and_test(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_mod_and_test);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_mod_and_test);
+
+void __page_ref_mod_and_return(struct page *page, int v, int ret)
+{
+	trace_page_ref_mod_and_return(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_mod_and_return);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_mod_and_return);
+
+void __page_ref_mod_unless(struct page *page, int v, int u)
+{
+	trace_page_ref_mod_unless(page, v, u);
+}
+EXPORT_SYMBOL(__page_ref_mod_unless);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_mod_unless);
+
+void __page_ref_freeze(struct page *page, int v, int ret)
+{
+	trace_page_ref_freeze(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_freeze);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_freeze);
+
+void __page_ref_unfreeze(struct page *page, int v)
+{
+	trace_page_ref_unfreeze(page, v);
+}
+EXPORT_SYMBOL(__page_ref_unfreeze);
+EXPORT_TRACEPOINT_SYMBOL(page_ref_unfreeze);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
