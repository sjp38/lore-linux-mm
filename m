Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 685186B025C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:48 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id b14so128459532wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u130si4226119wmg.2.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 05/14] mm, printk: introduce new format string for flags
Date: Tue, 26 Jan 2016 13:45:44 +0100
Message-Id: <1453812353-26744-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

In mm we use several kinds of flags bitfields that are sometimes printed for
debugging purposes, or exported to userspace via sysfs. To make them easier to
interpret independently on kernel version and config, we want to dump also the
symbolic flag names. So far this has been done with repeated calls to
pr_cont(), which is unreliable on SMP, and not usable for e.g. sysfs export.

To get a more reliable and universal solution, this patch extends printk()
format string for pointers to handle the page flags (%pGp), gfp_flags (%pGg)
and vma flags (%pGv). Existing users of dump_flag_names() are converted and
simplified.

It would be possible to pass flags by value instead of pointer, but the %p
format string for pointers already has extensions for various kernel
structures, so it's a good fit, and the extra indirection in a non-critical
path is negligible.

[linux@rasmusvillemoes.dk: lots of good implementation suggestions]
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/printk-formats.txt | 18 ++++++++++
 include/linux/mmdebug.h          |  6 ++++
 lib/test_printf.c                | 53 ++++++++++++++++++++++++++++
 lib/vsprintf.c                   | 75 ++++++++++++++++++++++++++++++++++++++++
 mm/debug.c                       | 34 ++++++++++--------
 mm/internal.h                    |  6 ++++
 6 files changed, 178 insertions(+), 14 deletions(-)

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 5d1128bf0282..5962949944fd 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -298,6 +298,24 @@ Raw pointer value SHOULD be printed with %p. The kernel supports
 
 	Passed by reference.
 
+Flags bitfields such as page flags, gfp_flags:
+
+	%pGp	referenced|uptodate|lru|active|private
+	%pGg	GFP_USER|GFP_DMA32|GFP_NOWARN
+	%pGv	read|exec|mayread|maywrite|mayexec|denywrite
+
+	For printing flags bitfields as a collection of symbolic constants that
+	would construct the value. The type of flags is given by the third
+	character. Currently supported are [p]age flags, [v]ma_flags (both
+	expect unsigned long *) and [g]fp_flags (expects gfp_t *). The flag
+	names and print order depends on the particular	type.
+
+	Note that this format should not be used directly in TP_printk() part
+	of a tracepoint. Instead, use the show_*_flags() functions from
+	<trace/events/mmflags.h>.
+
+	Passed by reference.
+
 Network device features:
 
 	%pNF	0x000000000000c000
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 053824b0a412..93fff2971fd4 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -3,11 +3,17 @@
 
 #include <linux/bug.h>
 #include <linux/stringify.h>
+#include <linux/types.h>
+#include <linux/tracepoint.h>
 
 struct page;
 struct vm_area_struct;
 struct mm_struct;
 
+extern const struct trace_print_flags pageflag_names[];
+extern const struct trace_print_flags vmaflag_names[];
+extern const struct trace_print_flags gfpflag_names[];
+
 extern void dump_page(struct page *page, const char *reason);
 extern void dump_page_badflags(struct page *page, const char *reason,
 			       unsigned long badflags);
diff --git a/lib/test_printf.c b/lib/test_printf.c
index 4f6ae60433bc..563f10e6876a 100644
--- a/lib/test_printf.c
+++ b/lib/test_printf.c
@@ -17,6 +17,9 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 
+#include <linux/gfp.h>
+#include <linux/mm.h>
+
 #define BUF_SIZE 256
 #define PAD_SIZE 16
 #define FILL_CHAR '$'
@@ -411,6 +414,55 @@ netdev_features(void)
 }
 
 static void __init
+flags(void)
+{
+	unsigned long flags;
+	gfp_t gfp;
+	char *cmp_buffer;
+
+	flags = 0;
+	test("", "%pGp", &flags);
+
+	/* Page flags should filter the zone id */
+	flags = 1UL << NR_PAGEFLAGS;
+	test("", "%pGp", &flags);
+
+	flags |= 1UL << PG_uptodate | 1UL << PG_dirty | 1UL << PG_lru
+		| 1UL << PG_active | 1UL << PG_swapbacked;
+	test("uptodate|dirty|lru|active|swapbacked", "%pGp", &flags);
+
+
+	flags = VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC
+			| VM_DENYWRITE;
+	test("read|exec|mayread|maywrite|mayexec|denywrite", "%pGv", &flags);
+
+	gfp = GFP_TRANSHUGE;
+	test("GFP_TRANSHUGE", "%pGg", &gfp);
+
+	gfp = GFP_ATOMIC|__GFP_DMA;
+	test("GFP_ATOMIC|GFP_DMA", "%pGg", &gfp);
+
+	gfp = __GFP_ATOMIC;
+	test("__GFP_ATOMIC", "%pGg", &gfp);
+
+	cmp_buffer = kmalloc(BUF_SIZE, GFP_KERNEL);
+	if (!cmp_buffer)
+		return;
+
+	/* Any flags not translated by the table should remain numeric */
+	gfp = ~__GFP_BITS_MASK;
+	snprintf(cmp_buffer, BUF_SIZE, "%#lx", (unsigned long) gfp);
+	test(cmp_buffer, "%pGg", &gfp);
+
+	snprintf(cmp_buffer, BUF_SIZE, "__GFP_ATOMIC|%#lx",
+							(unsigned long) gfp);
+	gfp |= __GFP_ATOMIC;
+	test(cmp_buffer, "%pGg", &gfp);
+
+	kfree(cmp_buffer);
+}
+
+static void __init
 test_pointer(void)
 {
 	plain();
@@ -428,6 +480,7 @@ test_pointer(void)
 	struct_clk();
 	bitmap();
 	netdev_features();
+	flags();
 }
 
 static int __init
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 48ff9c36644d..6dc428806811 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -35,6 +35,8 @@
 #include <linux/blkdev.h>
 #endif
 
+#include "../mm/internal.h"	/* For the trace_print_flags arrays */
+
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/sections.h>	/* for dereference_function_descriptor() */
 #include <asm/byteorder.h>	/* cpu_to_le16 */
@@ -1407,6 +1409,72 @@ char *clock(char *buf, char *end, struct clk *clk, struct printf_spec spec,
 	}
 }
 
+static
+char *format_flags(char *buf, char *end, unsigned long flags,
+					const struct trace_print_flags *names)
+{
+	unsigned long mask;
+	const struct printf_spec strspec = {
+		.field_width = -1,
+		.precision = -1,
+	};
+	const struct printf_spec numspec = {
+		.flags = SPECIAL|SMALL,
+		.field_width = -1,
+		.precision = -1,
+		.base = 16,
+	};
+
+	for ( ; flags && names->name; names++) {
+		mask = names->mask;
+		if ((flags & mask) != mask)
+			continue;
+
+		buf = string(buf, end, names->name, strspec);
+
+		flags &= ~mask;
+		if (flags) {
+			if (buf < end)
+				*buf = '|';
+			buf++;
+		}
+	}
+
+	if (flags)
+		buf = number(buf, end, flags, numspec);
+
+	return buf;
+}
+
+static noinline_for_stack
+char *flags_string(char *buf, char *end, void *flags_ptr, const char *fmt)
+{
+	unsigned long flags;
+	const struct trace_print_flags *names;
+
+	switch (fmt[1]) {
+	case 'p':
+		flags = *(unsigned long *)flags_ptr;
+		/* Remove zone id */
+		flags &= (1UL << NR_PAGEFLAGS) - 1;
+		names = pageflag_names;
+		break;
+	case 'v':
+		flags = *(unsigned long *)flags_ptr;
+		names = vmaflag_names;
+		break;
+	case 'g':
+		flags = *(gfp_t *)flags_ptr;
+		names = gfpflag_names;
+		break;
+	default:
+		WARN_ONCE(1, "Unsupported flags modifier: %c\n", fmt[1]);
+		return buf;
+	}
+
+	return format_flags(buf, end, flags, names);
+}
+
 int kptr_restrict __read_mostly;
 
 /*
@@ -1495,6 +1563,11 @@ int kptr_restrict __read_mostly;
  * - 'Cn' For a clock, it prints the name (Common Clock Framework) or address
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
+ * - 'G' For flags to be printed as a collection of symbolic strings that would
+ *       construct the specific value. Supported flags given by option:
+ *       p page flags (see struct page) given as pointer to unsigned long
+ *       g gfp flags (GFP_* and __GFP_*) given as pointer to gfp_t
+ *       v vma flags (VM_*) given as pointer to unsigned long
  *
  * ** Please update also Documentation/printk-formats.txt when making changes **
  *
@@ -1648,6 +1721,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return bdev_name(buf, end, ptr, spec, fmt);
 #endif
 
+	case 'G':
+		return flags_string(buf, end, ptr, fmt);
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
diff --git a/mm/debug.c b/mm/debug.c
index 410af904a7d5..0328fd377545 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -11,12 +11,21 @@
 #include <linux/memcontrol.h>
 #include <trace/events/mmflags.h>
 
-static const struct trace_print_flags pageflag_names[] = {
-	__def_pageflag_names
+#include "internal.h"
+
+const struct trace_print_flags pageflag_names[] = {
+	__def_pageflag_names,
+	{0, NULL}
+};
+
+const struct trace_print_flags gfpflag_names[] = {
+	__def_gfpflag_names,
+	{0, NULL}
 };
 
-static const struct trace_print_flags gfpflag_names[] = {
-	__def_gfpflag_names
+const struct trace_print_flags vmaflag_names[] = {
+	__def_vmaflag_names,
+	{0, NULL}
 };
 
 static void dump_flags(unsigned long flags,
@@ -58,14 +67,15 @@ void dump_page_badflags(struct page *page, const char *reason,
 	if (PageCompound(page))
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
-	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
-	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
+	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
+	dump_flags(page->flags, pageflag_names,
+					ARRAY_SIZE(pageflag_names) - 1);
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
 	if (page->flags & badflags) {
 		pr_alert("bad because of flags:\n");
-		dump_flags(page->flags & badflags,
-				pageflag_names, ARRAY_SIZE(pageflag_names));
+		dump_flags(page->flags & badflags, pageflag_names,
+					ARRAY_SIZE(pageflag_names) - 1);
 	}
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
@@ -81,10 +91,6 @@ EXPORT_SYMBOL(dump_page);
 
 #ifdef CONFIG_DEBUG_VM
 
-static const struct trace_print_flags vmaflag_names[] = {
-	__def_vmaflag_names
-};
-
 void dump_vma(const struct vm_area_struct *vma)
 {
 	pr_emerg("vma %p start %p end %p\n"
@@ -96,7 +102,7 @@ void dump_vma(const struct vm_area_struct *vma)
 		(unsigned long)pgprot_val(vma->vm_page_prot),
 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
 		vma->vm_file, vma->vm_private_data);
-	dump_flags(vma->vm_flags, vmaflag_names, ARRAY_SIZE(vmaflag_names));
+	dump_flags(vma->vm_flags, vmaflag_names, ARRAY_SIZE(vmaflag_names) - 1);
 }
 EXPORT_SYMBOL(dump_vma);
 
@@ -168,7 +174,7 @@ void dump_mm(const struct mm_struct *mm)
 		);
 
 		dump_flags(mm->def_flags, vmaflag_names,
-				ARRAY_SIZE(vmaflag_names));
+				ARRAY_SIZE(vmaflag_names) - 1);
 }
 
 #endif		/* CONFIG_DEBUG_VM */
diff --git a/mm/internal.h b/mm/internal.h
index 9006ce1960ff..e806b89f8a43 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,7 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/tracepoint-defs.h>
 
 /*
  * The set of flags that only affect watermark checking and reclaim
@@ -444,4 +445,9 @@ static inline void try_to_unmap_flush_dirty(void)
 }
 
 #endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
+
+extern const struct trace_print_flags pageflag_names[];
+extern const struct trace_print_flags vmaflag_names[];
+extern const struct trace_print_flags gfpflag_names[];
+
 #endif	/* __MM_INTERNAL_H */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
