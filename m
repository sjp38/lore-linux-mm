Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A59986B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:51:07 -0400 (EDT)
Date: Mon, 23 Mar 2009 14:58:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: oom-killer killing even if memory is available?
Message-ID: <20090323145807.GB15416@csn.ul.ie>
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com> <20090317024605.846420e1.akpm@linux-foundation.org> <20090320152700.GM24586@csn.ul.ie> <20090320140255.e0c01a59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090320140255.e0c01a59.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 02:02:55PM -0700, Andrew Morton wrote:
> On Fri, 20 Mar 2009 15:27:00 +0000 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > 
> > > Something must have allocated (and possibly leaked) it.
> > > 
> > 
> > This looks like a memory leak all right. There used to be a patch that
> > recorded a stack trace for every page allocation but it was dropped from
> > -mm ages ago because of a merge conflict. I didn't revive it at the time
> > because it wasn't of immediate concern.
> > 
> > Should I revive the patch or do we have preferred ways of tracking down
> > memory leaks these days?
> 
> We know that a dentry is getting leaked but afaik we don't know which one
> or why.
> 
> We could get more info via the page-owner-tracking-leak-detector.patch
> approach, or by dumping the info in the cached dentries - I think Wu
> Fengguang prepared a patch which does that.
> 
> I'm not sure why I dropped page-owner-tracking-leak-detector.patch actually
> - it was pretty useful sometimes and afaik we still haven't merged any tool
> which duplicates it.
> 
> Here's the latest version which I have:
> 

Here is a rebased reversion. Appears to work as advertised based on a
quick test with qemu and builds without CONFIG_PROC_PAGEOWNER

============

From: Alexander Nyberg <alexn@dsv.su.se>
Subject: [PATCH] Introduces CONFIG_PAGE_OWNER that keeps track of the call chain under which a page was allocated

Introduces CONFIG_PROC_PAGEOWNER that keeps track of the call chain
under which a page was allocated.  Includes a user-space helper in
Documentation/page_owner.c to sort the enormous amount of output that this
may give (thanks tridge).

Information available through /proc/page_owner

x86_64 introduces some stack noise in certain call chains so for exact
output use of x86 && CONFIG_FRAME_POINTER is suggested.  Tested on x86,
x86 && CONFIG_FRAME_POINTER, x86_64

Output looks like:

4819 times:
Page allocated via order 0, mask 0x50
[0xc012b7b9] find_lock_page+25
[0xc012b8c8] find_or_create_page+152
[0xc0147d74] grow_dev_page+36
[0xc0148164] __find_get_block+84
[0xc0147ebc] __getblk_slow+124
[0xc0148164] __find_get_block+84
[0xc01481e7] __getblk+55
[0xc0185d14] do_readahead+100

We use a custom stack unwinder because using __builtin_return_address([0-7])
causes gcc to generate code that might try to unwind the stack looking for
function return addresses and "fall off" causing early panics if the call
chain is not deep enough.  So in that case we could have had a depth of
around 3 functions in all traces (I experimented a bit with this).

From: Dave Hansen <haveblue@us.ibm.com>

	make page_owner handle non-contiguous page ranges

From: Alexander Nyberg <alexn@telia.com>

I've cleaned up the __alloc_pages() part to a simple set_page_owner() call.

Signed-off-by: Alexander Nyberg <alexn@dsv.su.se>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-Off-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>
DESC
Update page->order at an appropriate time when tracking PAGE_OWNER
EDESC
From: mel@skynet.ie (Mel Gorman)

PAGE_OWNER tracks free pages by setting page->order to -1.  However, it is
set during __free_pages() which is not the only free path as
__pagevec_free() and free_compound_page() do not go through __free_pages().
 This leads to a situation where free pages are visible in /proc/page_owner
which is confusing and might be interpreted as a memory leak.

This patch sets page->owner when PageBuddy is set.  It also prints a
warning to the kernel log if a free page is found that does not appear free
to PAGE_OWNER.  This should be considered a fix to
page-owner-tracking-leak-detector.patch.

This only applies to -mm as PAGE_OWNER is not in mainline.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
DESC
Print out PAGE_OWNER statistics in relation to fragmentation avoidance
EDESC
From: Mel Gorman <mel@csn.ul.ie>

When PAGE_OWNER is set, more information is available of relevance to
fragmentation avoidance.  A second line is added to /proc/page_owner showing
the PFN, the pageblock number, the mobility type of the page based on its
allocation flags, whether the allocation is improperly placed and the flags.
A sample entry looks like

Page allocated via order 0, mask 0x1280d2
PFN 7355 Block 7 type 3 Fallback Flags      LA
[0xc01528c6] __handle_mm_fault+598
[0xc0320427] do_page_fault+279
[0xc031ed9a] error_code+114

This information can be used to identify pages that are improperly placed.
As the format of PAGE_OWNER data is now different, the comment at the top
of Documentation/page_owner.c is updated with new instructions.

As PAGE_OWNER tracks the GFP flags used to allocate the pages,
/proc/pagetypeinfo is enhanced to contain how many mixed blocks exist.
The additional output looks like

Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            1            2            1
Node 0, zone   Normal            2           11           33            0

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
DESC
Allow PAGE_OWNER to be set on any architecture
EDESC
From: Mel Gorman <mel@csn.ul.ie>

Currently PAGE_OWNER depends on CONFIG_X86.  This appears to be due to
pfn_to_page() being called in an inappropriate for many memory models
and the presense of memory holes.  This patch ensures that pfn_valid()
and pfn_valid_within() is called at the appropriate places and the offsets
correctly updated so that PAGE_OWNER is safe on any architecture.

In situations where CONFIG_HOLES_IN_ZONES is set (IA64 with VIRTUAL_MEM_MAP),
there may be cases where pages allocated within a MAX_ORDER_NR_PAGES block
of pages may not be displayed in /proc/page_owner if the hole is at the
start of the block.  Addressing this would be quite complex, perform slowly
and is of no clear benefit.

Once PAGE_OWNER is allowed on all architectures, the statistics for grouping
pages by mobility that declare how many pageblocks contain mixed page types
becomes optionally available on all arches.

This patch was tested successfully on x86, x86_64, ppc64 and IA64 machines.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
DESC
allow-page_owner-to-be-set-on-any-architecture-fix
EDESC
From: Andrew Morton <akpm@linux-foundation.org>

Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>
DESC
allow-page_owner-to-be-set-on-any-architecture-fix fix
EDESC
From: mel@skynet.ie (Mel Gorman)

Page-owner-tracking stores the a backtrace of an allocation in the
struct page.  How the stack trace is generated depends on whether
CONFIG_FRAME_POINTER is set or not.  If CONFIG_FRAME_POINTER is set,
the frame pointer must be read using some inline assembler which is not
available for all architectures.

This patch uses the frame pointer where it is available but has a fallback
where it is not.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

From: Mel Gorman <mel@csn.ul.ie>

Rebase on top of procfs changes

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
new file mode 100644
index 0000000..9081bd6
--- /dev/null
+++ b/Documentation/page_owner.c
@@ -0,0 +1,144 @@
+/*
+ * User-space helper to sort the output of /proc/page_owner
+ *
+ * Example use:
+ * cat /proc/page_owner > page_owner_full.txt
+ * grep -v ^PFN page_owner_full.txt > page_owner.txt
+ * ./sort page_owner.txt sorted_page_owner.txt
+*/
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+
+struct block_list {
+	char *txt;
+	int len;
+	int num;
+};
+
+
+static struct block_list *list;
+static int list_size;
+static int max_size;
+
+struct block_list *block_head;
+
+int read_block(char *buf, FILE *fin)
+{
+	int ret = 0;
+	int hit = 0;
+	char *curr = buf;
+
+	for (;;) {
+		*curr = getc(fin);
+		if (*curr == EOF) return -1;
+
+		ret++;
+		if (*curr == '\n' && hit == 1)
+			return ret - 1;
+		else if (*curr == '\n')
+			hit = 1;
+		else
+			hit = 0;
+		curr++;
+	}
+}
+
+static int compare_txt(const void *d1, const void *d2)
+{
+	struct block_list *l1 = (struct block_list *)d1;
+	struct block_list *l2 = (struct block_list *)d2;
+	return strcmp(l1->txt, l2->txt);
+}
+
+static int compare_num(const void *d1, const void *d2)
+{
+	struct block_list *l1 = (struct block_list *)d1;
+	struct block_list *l2 = (struct block_list *)d2;
+	return l2->num - l1->num;
+}
+
+static void add_list(char *buf, int len)
+{
+	if (list_size != 0 &&
+	    len == list[list_size-1].len &&
+	    memcmp(buf, list[list_size-1].txt, len) == 0) {
+		list[list_size-1].num++;
+		return;
+	}
+	if (list_size == max_size) {
+		printf("max_size too small??\n");
+		exit(1);
+	}
+	list[list_size].txt = malloc(len+1);
+	list[list_size].len = len;
+	list[list_size].num = 1;
+	memcpy(list[list_size].txt, buf, len);
+	list[list_size].txt[len] = 0;
+	list_size++;
+	if (list_size % 1000 == 0) {
+		printf("loaded %d\r", list_size);
+		fflush(stdout);
+	}
+}
+
+int main(int argc, char **argv)
+{
+	FILE *fin, *fout;
+	char buf[1024];
+	int ret, i, count;
+	struct block_list *list2;
+	struct stat st;
+
+	fin = fopen(argv[1], "r");
+	fout = fopen(argv[2], "w");
+	if (!fin || !fout) {
+		printf("Usage: ./program <input> <output>\n");
+		perror("open: ");
+		exit(2);
+	}
+
+	fstat(fileno(fin), &st);
+	max_size = st.st_size / 100; /* hack ... */
+
+	list = malloc(max_size * sizeof(*list));
+
+	for(;;) {
+		ret = read_block(buf, fin);
+		if (ret < 0)
+			break;
+
+		buf[ret] = '\0';
+		add_list(buf, ret);
+	}
+
+	printf("loaded %d\n", list_size);
+
+	printf("sorting ....\n");
+
+	qsort(list, list_size, sizeof(list[0]), compare_txt);
+
+	list2 = malloc(sizeof(*list) * list_size);
+
+	printf("culling\n");
+
+	for (i=count=0;i<list_size;i++) {
+		if (count == 0 ||
+		    strcmp(list2[count-1].txt, list[i].txt) != 0)
+			list2[count++] = list[i];
+		else
+			list2[count-1].num += list[i].num;
+	}
+
+	qsort(list2, count, sizeof(list[0]), compare_num);
+
+	for (i=0;i<count;i++) {
+		fprintf(fout, "%d times:\n%s\n", list2[i].num, list2[i].txt);
+	}
+	return 0;
+}
diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index 63d9651..7bcb474 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -22,6 +22,7 @@ proc-$(CONFIG_PROC_SYSCTL)	+= proc_sysctl.o
 proc-$(CONFIG_NET)		+= proc_net.o
 proc-$(CONFIG_PROC_KCORE)	+= kcore.o
 proc-$(CONFIG_PROC_VMCORE)	+= vmcore.o
+proc-$(CONFIG_PROC_PAGEOWNER)	+= pageowner.o
 proc-$(CONFIG_PROC_DEVICETREE)	+= proc_devtree.o
 proc-$(CONFIG_PRINTK)	+= kmsg.o
 proc-$(CONFIG_PROC_PAGE_MONITOR)	+= page.o
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d84feb7..08cd32c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -94,6 +94,12 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+
+#ifdef CONFIG_PROC_PAGEOWNER
+	int order;
+	unsigned int gfp_mask;
+	unsigned long trace[8];
+#endif
 };
 
 /*
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 1bcf9cd..69840d2 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -66,6 +66,16 @@ config UNUSED_SYMBOLS
 	  you really need it, and what the merge plan to the mainline kernel for
 	  your module is.
 
+config PROC_PAGEOWNER
+	bool "Track page owner"
+	depends on DEBUG_KERNEL
+	help
+	  This keeps track of what call chain is the owner of a page, may
+	  help to find bare alloc_page(s) leaks. Eats a fair amount of memory.
+	  See Documentation/page_owner.c for user-space helper.
+
+	  If unsure, say N.
+
 config DEBUG_FS
 	bool "Debug Filesystem"
 	depends on SYSFS
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c44ed4..fd77809 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -358,6 +358,9 @@ static inline void set_page_order(struct page *page, int order)
 {
 	set_page_private(page, order);
 	__SetPageBuddy(page);
+#ifdef CONFIG_PROC_PAGEOWNER
+		page->order = -1;
+#endif
 }
 
 static inline void rmv_page_order(struct page *page)
@@ -1460,6 +1463,62 @@ try_next_zone:
 	return page;
 }
 
+#ifdef CONFIG_PROC_PAGEOWNER
+static inline int valid_stack_ptr(struct thread_info *tinfo, void *p)
+{
+	return	p > (void *)tinfo &&
+		p < (void *)tinfo + THREAD_SIZE - 3;
+}
+
+static inline void __stack_trace(struct page *page, unsigned long *stack,
+			unsigned long bp)
+{
+	int i = 0;
+	unsigned long addr;
+	struct thread_info *tinfo = (struct thread_info *)
+		((unsigned long)stack & (~(THREAD_SIZE - 1)));
+
+	memset(page->trace, 0, sizeof(long) * 8);
+
+#ifdef CONFIG_FRAME_POINTER
+	if (bp) {
+		while (valid_stack_ptr(tinfo, (void *)bp)) {
+			addr = *(unsigned long *)(bp + sizeof(long));
+			page->trace[i] = addr;
+			if (++i >= 8)
+				break;
+			bp = *(unsigned long *)bp;
+		}
+		return;
+	}
+#endif /* CONFIG_FRAME_POINTER */
+	while (valid_stack_ptr(tinfo, stack)) {
+		addr = *stack++;
+		if (__kernel_text_address(addr)) {
+			page->trace[i] = addr;
+			if (++i >= 8)
+				break;
+		}
+	}
+}
+
+static void set_page_owner(struct page *page, unsigned int order,
+			unsigned int gfp_mask)
+{
+	unsigned long address;
+	unsigned long bp = 0;
+#ifdef CONFIG_X86_64
+	asm ("movq %%rbp, %0" : "=r" (bp) : );
+#endif
+#ifdef CONFIG_X86_32
+	asm ("movl %%ebp, %0" : "=r" (bp) : );
+#endif
+	page->order = (int) order;
+	page->gfp_mask = gfp_mask;
+	__stack_trace(page, &address, bp);
+}
+#endif /* CONFIG_PROC_PAGEOWNER */
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -1668,6 +1727,10 @@ nopage:
 		show_mem();
 	}
 got_pg:
+#ifdef CONFIG_PROC_PAGEOWNER
+	if (page)
+		set_page_owner(page, order, gfp_mask);
+#endif
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_internal);
@@ -2668,6 +2731,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (!is_highmem_idx(zone))
 			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
+#ifdef CONFIG_PROC_PAGEOWNER
+		page->order = -1;
+#endif
 	}
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9114974..af12bc6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -15,6 +15,7 @@
 #include <linux/cpu.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
+#include "internal.h"
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -560,6 +561,97 @@ static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 	return 0;
 }
 
+#ifdef CONFIG_PROC_PAGEOWNER
+static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
+							pg_data_t *pgdat,
+							struct zone *zone)
+{
+	int mtype, pagetype;
+	unsigned long pfn;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+
+	/* Align PFNs to pageblock_nr_pages boundary */
+	pfn = start_pfn & ~(pageblock_nr_pages-1);
+
+	/*
+	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
+	 * a zone boundary, it will be double counted between zones. This does
+	 * not matter as the mixed block count will still be correct
+	 */
+	for (; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+		unsigned long offset = 0;
+
+		/* Do not read before the zone start, use a valid page */
+		if (pfn < start_pfn)
+			offset = start_pfn - pfn;
+
+		if (!pfn_valid(pfn + offset))
+			continue;
+
+		page = pfn_to_page(pfn + offset);
+		mtype = get_pageblock_migratetype(page);
+
+		/* Check the block for bad migrate types */
+		for (; offset < pageblock_nr_pages; offset++) {
+			/* Do not past the end of the zone */
+			if (pfn + offset >= end_pfn)
+				break;
+
+			if (!pfn_valid_within(pfn + offset))
+				continue;
+
+			page = pfn_to_page(pfn + offset);
+
+			/* Skip free pages */
+			if (PageBuddy(page)) {
+				offset += (1UL << page_order(page)) - 1UL;
+				continue;
+			}
+			if (page->order < 0)
+				continue;
+
+			pagetype = allocflags_to_migratetype(page->gfp_mask);
+			if (pagetype != mtype) {
+				count[mtype]++;
+				break;
+			}
+
+			/* Move to end of this allocation */
+			offset += (1 << page->order) - 1;
+		}
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12lu ", count[mtype]);
+	seq_putc(m, '\n');
+}
+#endif /* CONFIG_PROC_PAGEOWNER */
+
+/*
+ * Print out the number of pageblocks for each migratetype that contain pages
+ * of other types. This gives an indication of how well fallbacks are being
+ * contained by rmqueue_fallback(). It requires information from PAGE_OWNER
+ * to determine what is going on
+ */
+static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
+{
+#ifdef CONFIG_PROC_PAGEOWNER
+	int mtype;
+
+	seq_printf(m, "\n%-23s", "Number of mixed blocks ");
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showmixedcount_print);
+#endif /* CONFIG_PROC_PAGEOWNER */
+}
+
 /*
  * This prints out statistics in relation to grouping pages by mobility.
  * It is expensive to collect so do not constantly read the file.
@@ -577,6 +669,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	seq_putc(m, '\n');
 	pagetypeinfo_showfree(m, pgdat);
 	pagetypeinfo_showblockcount(m, pgdat);
+	pagetypeinfo_showmixedcount(m, pgdat);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
