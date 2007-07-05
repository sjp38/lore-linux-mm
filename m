Date: Thu, 5 Jul 2007 17:21:21 +0100
Subject: Re: [PATCH] Allow PAGE_OWNER to be set on any architecture
Message-ID: <20070705162121.GA21219@skynet.ie>
References: <20070608125349.GA8444@skynet.ie> <20070627165651.1ffb72d7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070627165651.1ffb72d7.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: alexn@telia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (27/06/07 16:56), Andrew Morton didst pronounce:
> On Fri, 8 Jun 2007 13:53:49 +0100
> mel@skynet.ie (Mel Gorman) wrote:
> 
> > Currently PAGE_OWNER depends on CONFIG_X86. This appears to be due to
> > pfn_to_page() being called in an inappropriate for many memory models
> > and the presense of memory holes. This patch ensures that pfn_valid()
> > and pfn_valid_within() is called at the appropriate places and the offsets
> > correctly updated so that PAGE_OWNER is safe on any architecture.
> > 
> > In situations where CONFIG_HOLES_IN_ZONES is set (IA64 with VIRTUAL_MEM_MAP),
> > there may be cases where pages allocated within a MAX_ORDER_NR_PAGES block
> > of pages may not be displayed in /proc/page_owner if the hole is at the
> > start of the block. Addressing this would be quite complex, perform slowly
> > and is of no clear benefit.
> > 
> > Once PAGE_OWNER is allowed on all architectures, the statistics for grouping
> > pages by mobility that declare how many pageblocks contain mixed page types
> > becomes optionally available on all arches.
> > 
> > This patch was tested successfully on x86, x86_64, ppc64 and IA64 machines.
> 
> I'm kinda mystified about how you successfully tested this on ppc64 and
> ia64.  They don't assemble and execute i386 opcodes?
> 

You are of course right and I thought I must be insane to apparently screw
up testing so badly.  However somewhat to my suprise, this does work on
ppc64 and IA64. I boot tested with the patch and was able to read the stack
trace on /proc/page_owner although it is a bit useless on IA64. Of course,
the inline assember doesn't show up in the disassembled vmlinux because it
could never be executed.

What appears to happen is that the inline assembler is optimised away when
CONFIG_FRAME_POINTER is not set as the bp variable is unused.  As it cannot
be set on IA64 or PPC64, it appeared to work and passed earlier testing.
When I cross-compile for m68k (something I hadn't done before), it builds
if CONFIG_FRAME_POINTER is unset but fails with parse errors when set which
is what one would expect.

I think the following patch brings things more in line with expectations once
your fix is in place at the cost of a larger __stack_trace function. It uses
the frame pointer if possible but otherwise falls back. It appears to work
fine on ppc64, IA64 and an x86 laptop.

======

Page-owner-tracking stores the a backtrace of an allocation in the struct
page. How the stack trace is generated depends on whether CONFIG_FRAME_POINTER
is set or not. If CONFIG_FRAME_POINTER is set, the frame pointer must be
read using some inline assembler which is not available for all architectures.

This patch uses the frame pointer where it is available but has a fallback
where it is not.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

--- 
 page_alloc.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-005_pageowner_anyarch/mm/page_alloc.c linux-2.6.22-rc4-mm2-010_handle_framepointer/mm/page_alloc.c
--- linux-2.6.22-rc4-mm2-005_pageowner_anyarch/mm/page_alloc.c	2007-07-05 14:12:56.000000000 +0100
+++ linux-2.6.22-rc4-mm2-010_handle_framepointer/mm/page_alloc.c	2007-07-05 14:48:23.000000000 +0100
@@ -1494,14 +1494,17 @@ static inline void __stack_trace(struct 
 	memset(page->trace, 0, sizeof(long) * 8);
 
 #ifdef CONFIG_FRAME_POINTER
-	while (valid_stack_ptr(tinfo, (void *)bp)) {
-		addr = *(unsigned long *)(bp + sizeof(long));
-		page->trace[i] = addr;
-		if (++i >= 8)
-			break;
-		bp = *(unsigned long *)bp;
+	if (bp) {
+		while (valid_stack_ptr(tinfo, (void *)bp)) {
+			addr = *(unsigned long *)(bp + sizeof(long));
+			page->trace[i] = addr;
+			if (++i >= 8)
+				break;
+			bp = *(unsigned long *)bp;
+		}
+		return;
 	}
-#else
+#endif /* CONFIG_FRAME_POINTER */
 	while (valid_stack_ptr(tinfo, stack)) {
 		addr = *stack++;
 		if (__kernel_text_address(addr)) {
@@ -1510,7 +1513,6 @@ static inline void __stack_trace(struct 
 				break;
 		}
 	}
-#endif
 }
 
 static void set_page_owner(struct page *page, unsigned int order,
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
