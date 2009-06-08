Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6D56B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 18:19:22 -0400 (EDT)
Date: Mon, 8 Jun 2009 23:29:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
	allocation failure reports
Message-ID: <20090608222904.GA18437@csn.ul.ie>
References: <20090608132950.GB15070@csn.ul.ie> <20090608135906.GA6027@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090608135906.GA6027@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 09:59:06AM -0400, Christoph Hellwig wrote:
> On Mon, Jun 08, 2009 at 02:29:50PM +0100, Mel Gorman wrote:
> > The page allocation failure messages include a line that looks like
> > 
> > page allocation failure. order:1, mode:0x4020
> > 
> > The mode is easy to translate but irritating for the lazy and a bit error
> > prone. This patch adds a very simple helper script gfp-translate for the mode:
> > portion of the page allocation failure messages. An example usage looks like
> 
> Maybe we just just print the symbolic flags directly? 

It'd be nice if it was possible, not ugly and didn't involve declaring
maps twice.

Even with such hypothetical support, I believe there is scope for having
the script readily available for use with reports from older kernels,
particularly distro kernels.

> The even tracer
> in the for-2.6.23 queue now has a __print_flags helper to translate the
> bitmask back into symbolic flags, and we even have a kmalloc tracer
> using it for the GFP flags.  Maybe we should add a printk_flags variant
> for regular printks and just do the right thing?
> 

The problem I found with a printk_flags variant was that there was no
buffer for it to easily print to for use with printk("%s"). We can't "see"
the printk buffer, we can't kmalloc() one and I suspect it's too large to
place on the stack. What had you in mind?

I haven't looked at the trace implementation before so I have very little
idea as to how best approach this problem. That didn't stop me attempting a
hatchet-job on the implementation of printk support for the bitflags->string
maps declared within ftrace - particularly the GFP flags.

The following patch is what it ended up looking like. I recommend goggles
because even if we go with printk support, this could be implemented better.

=== CUT HERE ===

Add support for %f for the printing of string representation of bit flags

This patch is a prototype to see if the tracing infrastructure used for
the outputting of symbolic representation of bits set in a flag can be
reused for printk. With it applied, a page allocation failure report
looks like

[  171.284889] cat: page allocation failure. order:9, mode:0xd1
[  171.284948] mode:|GFP_KERNEL|0x1
[  171.295114] Pid: 2383, comm: cat Not tainted 2.6.30-rc8-tip-02066-g800cfbb-dirty #38

Not-signed-off-yet-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 5c093ff..8f8e86c 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -16,6 +16,11 @@ struct trace_print_flags {
 	const char		*name;
 };
 
+struct trace_printf_spec {
+	unsigned long			flags;
+	struct trace_print_flags	*flag_array;
+};
+
 const char *ftrace_print_flags_seq(struct trace_seq *p, const char *delim,
 				   unsigned long flags,
 				   const struct trace_print_flags *flag_array);
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 9baba50..e2404ad 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -17,8 +17,7 @@
  *
  * Thus most bits set go first.
  */
-#define show_gfp_flags(flags)						\
-	(flags) ? __print_flags(flags, "|",				\
+#define gfp_flags_printf_map						\
 	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
 	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
 	{(unsigned long)GFP_USER,		"GFP_USER"},		\
@@ -42,6 +41,11 @@
 	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
+
+
+#define show_gfp_flags(flags, map)					\
+	(flags) ? __print_flags(flags, "|",				\
+	map								\
 	) : "GFP_NOWAIT"
 
 TRACE_EVENT(kmalloc,
@@ -75,7 +79,7 @@ TRACE_EVENT(kmalloc,
 		__entry->ptr,
 		__entry->bytes_req,
 		__entry->bytes_alloc,
-		show_gfp_flags(__entry->gfp_flags))
+		show_gfp_flags(__entry->gfp_flags, gfp_flags_printf_map))
 );
 
 TRACE_EVENT(kmem_cache_alloc,
@@ -109,7 +113,7 @@ TRACE_EVENT(kmem_cache_alloc,
 		__entry->ptr,
 		__entry->bytes_req,
 		__entry->bytes_alloc,
-		show_gfp_flags(__entry->gfp_flags))
+		show_gfp_flags(__entry->gfp_flags, gfp_flags_printf_map))
 );
 
 TRACE_EVENT(kmalloc_node,
@@ -146,7 +150,7 @@ TRACE_EVENT(kmalloc_node,
 		__entry->ptr,
 		__entry->bytes_req,
 		__entry->bytes_alloc,
-		show_gfp_flags(__entry->gfp_flags),
+		show_gfp_flags(__entry->gfp_flags, gfp_flags_printf_map),
 		__entry->node)
 );
 
@@ -184,7 +188,7 @@ TRACE_EVENT(kmem_cache_alloc_node,
 		__entry->ptr,
 		__entry->bytes_req,
 		__entry->bytes_alloc,
-		show_gfp_flags(__entry->gfp_flags),
+		show_gfp_flags(__entry->gfp_flags, gfp_flags_printf_map),
 		__entry->node)
 );
 
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 756ccaf..acb20e0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/ftrace_event.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
@@ -403,6 +404,7 @@ enum format_type {
 	FORMAT_TYPE_CHAR,
 	FORMAT_TYPE_STR,
 	FORMAT_TYPE_PTR,
+	FORMAT_TYPE_TRACE_FLAGS,
 	FORMAT_TYPE_PERCENT_CHAR,
 	FORMAT_TYPE_INVALID,
 	FORMAT_TYPE_LONG_LONG,
@@ -574,6 +576,44 @@ static char *string(char *buf, char *end, char *s, struct printf_spec spec)
 	return buf;
 }
 
+/*
+ * Support a %f thing storing a struct trace_print_flags
+ */
+static char *trace_flags(char *buf, char *end,
+				struct trace_printf_spec *trace_flags_spec,
+				struct printf_spec spec)
+{
+	unsigned long mask;
+	unsigned long flags = trace_flags_spec->flags;
+	struct trace_print_flags *flag_array = trace_flags_spec->flag_array;
+	char *str;
+	char *delim = "|";
+	char *ret = buf;
+	int i;
+
+	for (i = 0;  flag_array[i].name && flags; i++) {
+
+		mask = flag_array[i].mask;
+		if ((flags & mask) != mask)
+			continue;
+
+		str = (char *)flag_array[i].name;
+		flags &= ~mask;
+		if (ret < end && delim)
+			ret = string(ret, end, delim, spec);
+		ret = string(ret, end, str, spec);
+	}
+
+	if (flags) {
+		ret = string(ret, end, delim, spec);
+		spec.flags |= SPECIAL|SMALL;
+		spec.base = 16;
+		ret = number(ret, end, flags, spec);
+	}
+
+	return ret;
+}
+
 static char *symbol_string(char *buf, char *end, void *ptr,
 				struct printf_spec spec, char ext)
 {
@@ -888,6 +928,11 @@ qualifier:
 		return fmt - start;
 		/* skip alnum */
 
+	case 'f':
+		spec->qualifier = 'l';
+		spec->type = FORMAT_TYPE_TRACE_FLAGS;
+		return ++fmt - start;
+
 	case 'n':
 		spec->type = FORMAT_TYPE_NRCHARS;
 		return ++fmt - start;
@@ -1058,6 +1103,12 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
 				fmt++;
 			break;
 
+		case FORMAT_TYPE_TRACE_FLAGS:
+			str = trace_flags(str, end,
+				va_arg(args, struct trace_printf_spec *),
+				spec);
+			break;
+
 		case FORMAT_TYPE_PERCENT_CHAR:
 			if (str < end)
 				*str = '%';
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ed766b5..714b5c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -47,6 +47,7 @@
 #include <linux/page-isolation.h>
 #include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
+#include <linux/ftrace_event.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -172,6 +173,11 @@ static void set_pageblock_migratetype(struct page *page, int migratetype)
 					PB_migrate, PB_migrate_end);
 }
 
+struct trace_print_flags trace_print_flags_gfp[] = {
+	gfp_flags_printf_map,
+	{ -1, NULL }
+};
+
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -1675,9 +1681,15 @@ nofail_alloc:
 
 nopage:
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
+		static struct trace_printf_spec gfpmask_printspec;
+		gfpmask_printspec.flags = gfp_mask;
+		gfpmask_printspec.flag_array = trace_print_flags_gfp;
+			
 		printk(KERN_WARNING "%s: page allocation failure."
-			" order:%d, mode:0x%x\n",
-			p->comm, order, gfp_mask);
+			" order:%d, mode:0x%x\nmode:%f\n",
+			p->comm, order, gfp_mask,
+			&gfpmask_printspec);
+
 		dump_stack();
 		show_mem();
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
