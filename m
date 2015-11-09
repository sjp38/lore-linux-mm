Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D72C6B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:23:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so166201544pac.3
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:23:23 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id mp10si20598995pbc.72.2015.11.08.23.23.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 23:23:22 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so190508100pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:23:22 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] mm/page_ref: add tracepoint to track down page reference manipulation
Date: Mon,  9 Nov 2015 16:23:04 +0900
Message-Id: <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Enabling this feature bloat kernel text 20 KB in my configuration.

   text    data     bss     dec     hex filename
12041272        2223424 1507328 15772024         f0a978 vmlinux_disabled
12064844        2225920 1507328 15798092         f10f4c vmlinux_enabled

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_ref.h        |  67 +++++++++++++++++++--
 include/trace/events/page_ref.h | 128 ++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig.debug                |   4 ++
 mm/Makefile                     |   1 +
 mm/debug_page_ref.c             |  46 +++++++++++++++
 5 files changed, 241 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/events/page_ref.h
 create mode 100644 mm/debug_page_ref.c

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 534249c..de81073 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -2,6 +2,42 @@
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
 
+#ifdef CONFIG_DEBUG_PAGE_REF
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
+
 static inline int page_count(struct page *page)
 {
 	return atomic_read(&compound_head(page)->_count);
@@ -10,6 +46,7 @@ static inline int page_count(struct page *page)
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
+	__page_ref_set(page, v);
 }
 
 /*
@@ -24,46 +61,65 @@ static inline void init_page_count(struct page *page)
 static inline void page_ref_add(struct page *page, int nr)
 {
 	atomic_add(nr, &page->_count);
+	__page_ref_mod(page, nr);
 }
 
 static inline void page_ref_sub(struct page *page, int nr)
 {
 	atomic_sub(nr, &page->_count);
+	__page_ref_mod(page, -nr);
 }
 
 static inline void page_ref_inc(struct page *page)
 {
 	atomic_inc(&page->_count);
+	__page_ref_mod(page, 1);
 }
 
 static inline void page_ref_dec(struct page *page)
 {
 	atomic_dec(&page->_count);
+	__page_ref_mod(page, -1);
 }
 
 static inline int page_ref_sub_and_test(struct page *page, int nr)
 {
-	return atomic_sub_and_test(nr, &page->_count);
+	int ret = atomic_sub_and_test(nr, &page->_count);
+
+	__page_ref_mod_and_test(page, -nr, ret);
+	return ret;
 }
 
 static inline int page_ref_dec_and_test(struct page *page)
 {
-	return atomic_dec_and_test(&page->_count);
+	int ret = atomic_dec_and_test(&page->_count);
+
+	__page_ref_mod_and_test(page, -1, ret);
+	return ret;
 }
 
 static inline int page_ref_dec_return(struct page *page)
 {
-	return atomic_dec_return(&page->_count);
+	int ret = atomic_dec_return(&page->_count);
+
+	__page_ref_mod_and_return(page, -1, ret);
+	return ret;
 }
 
 static inline int page_ref_add_unless(struct page *page, int nr, int u)
 {
-	return atomic_add_unless(&page->_count, nr, u);
+	int ret = atomic_add_unless(&page->_count, nr, u);
+
+	__page_ref_mod_unless(page, nr, ret);
+	return ret;
 }
 
 static inline int page_ref_freeze(struct page *page, int count)
 {
-	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+
+	__page_ref_freeze(page, count, ret);
+	return ret;
 }
 
 static inline void page_ref_unfreeze(struct page *page, int count)
@@ -72,5 +128,6 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	VM_BUG_ON(count == 0);
 
 	atomic_set(&page->_count, count);
+	__page_ref_unfreeze(page, count);
 }
 
diff --git a/include/trace/events/page_ref.h b/include/trace/events/page_ref.h
new file mode 100644
index 0000000..6c5fd5b
--- /dev/null
+++ b/include/trace/events/page_ref.h
@@ -0,0 +1,128 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM page_ref
+
+#if !defined(_TRACE_PAGE_REF_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGE_REF_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
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
+		__entry->flags = page->flags & ((1UL << NR_PAGEFLAGS) - 1);
+		__entry->count = atomic_read(&page->_count);
+		__entry->mapcount = page_mapcount(page);
+		__entry->mapping = page->mapping;
+		__entry->mt = get_pageblock_migratetype(page);
+		__entry->val = v;
+	),
+
+	TP_printk("pfn=0x%lx flags=0x%lx count=%d mapcount=%d mapping=%p mt=%d val=%d",
+		__entry->pfn, __entry->flags, __entry->count,
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
+		__entry->flags = page->flags & ((1UL << NR_PAGEFLAGS) - 1);
+		__entry->count = atomic_read(&page->_count);
+		__entry->mapcount = page_mapcount(page);
+		__entry->mapping = page->mapping;
+		__entry->mt = get_pageblock_migratetype(page);
+		__entry->val = v;
+		__entry->ret = ret;
+	),
+
+	TP_printk("pfn=0x%lx flags=0x%lx count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
+		__entry->pfn, __entry->flags, __entry->count,
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
index 957d3da..71d2399 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -28,3 +28,7 @@ config DEBUG_PAGEALLOC
 
 config PAGE_POISONING
 	bool
+
+config DEBUG_PAGE_REF
+	bool "Enable tracepoint to track down page reference manipulation"
+	depends on DEBUG_KERNEL
diff --git a/mm/Makefile b/mm/Makefile
index 2ed4319..000f89f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -81,3 +81,4 @@ obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
 obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
 obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
+obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
diff --git a/mm/debug_page_ref.c b/mm/debug_page_ref.c
new file mode 100644
index 0000000..d80b376
--- /dev/null
+++ b/mm/debug_page_ref.c
@@ -0,0 +1,46 @@
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
+
+void __page_ref_mod(struct page *page, int v)
+{
+	trace_page_ref_mod(page, v);
+}
+EXPORT_SYMBOL(__page_ref_mod);
+
+void __page_ref_mod_and_test(struct page *page, int v, int ret)
+{
+	trace_page_ref_mod_and_test(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_mod_and_test);
+
+void __page_ref_mod_and_return(struct page *page, int v, int ret)
+{
+	trace_page_ref_mod_and_return(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_mod_and_return);
+
+void __page_ref_mod_unless(struct page *page, int v, int u)
+{
+	trace_page_ref_mod_unless(page, v, u);
+}
+EXPORT_SYMBOL(__page_ref_mod_unless);
+
+void __page_ref_freeze(struct page *page, int v, int ret)
+{
+	trace_page_ref_freeze(page, v, ret);
+}
+EXPORT_SYMBOL(__page_ref_freeze);
+
+void __page_ref_unfreeze(struct page *page, int v)
+{
+	trace_page_ref_unfreeze(page, v);
+}
+EXPORT_SYMBOL(__page_ref_unfreeze);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
