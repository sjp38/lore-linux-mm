Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 596246B00E8
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 07:33:48 -0400 (EDT)
Date: Mon, 18 Oct 2010 12:33:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Message-ID: <20101018113331.GB30667@csn.ul.ie>
References: <20101013144044.GS30667@csn.ul.ie> <20101013175205.21187.qmail@kosh.dhis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101013175205.21187.qmail@kosh.dhis.org>
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 12:52:05PM -0500, pacman@kosh.dhis.org wrote:
> Mel Gorman writes:
> > 
> > On Mon, Oct 11, 2010 at 02:00:39PM -0700, Andrew Morton wrote:
> > > 
> > > It's corruption of user memory, which is unusual.  I'd be wondering if
> > > there was a pre-existing bug which 6dda9d55bf545013597 has exposed -
> > > previously the corruption was hitting something harmless.  Something
> > > like a missed CPU cache writeback or invalidate operation.
> > > 
> > 
> > This seems somewhat plausible although it's hard to tell for sure. But
> > lets say we had the following situation in memory
> > 
> > [<----MAX_ORDER_NR_PAGES---->][<----MAX_ORDER_NR_PAGES---->]
> > INITRD                        memmap array
> 
> I don't use initrd, so this isn't exactly what happened here. But it could be
> close. Let me throw out some more information and see if it triggers any
> ideas.
> 

Ok.

> First, I tried a new test after seeing the corruption happen:
> # md5sum /sbin/e2fsck ; echo 1 > /proc/sys/vm/drop_caches ; md5sum /sbin/e2fsck
> And got 2 different answers. The second answer was the correct one.
> 
> Since applying the suggested patch which changed MAX_ORDER-1 to MAX_ORDER-2,
> I've been trying to isolate exactly when the corruption happens. Since I
> don't know much about kernel code, my main method is stuffing the area full
> of printk's.
> 
> First I duplicated the affected function __free_one_page, since it's inlined
> at 2 different places, so I could apply the patch to just one of them. This
> proved that the problem is happening when called from free_one_page.
> 
> The patch which fixes (or at least covers up) the bug will only matter when
> order==MAX_ORDER-2, otherwise everything is the same. So I added a lot of
> printk's to show what's happening when order==MAX_ORDER-2. I found that, very
> repeatably, 126 such instances occur during boot, and 61 of them pass the
> page_is_buddy(higher_page, higher_buddy, order + 1) test, causing them to
> call list_add_tail.
> 
> Next, since the bug appears when this code decides to call list_add_tail,
> I made my own wrapper for list_add_tail, which allowed me to force some of
> the calls to do list_add instead. Eventually I found that of the 61 calls,
> the last one makes the difference. Allowing the first 60 calls to go through
> to list_add_tail, and switching the last one to list_add, the symptom goes
> away.
> 
> dump_stack() for that last call gave me a backtrace like this:
> [c0303e80] [c0008124] show_stack+0x4c/0x144 (unreliable)
> [c0303ec0] [c0068a84] free_one_page+0x28c/0x5b0
> [c0303f20] [c0069588] __free_pages_ok+0xf8/0x120
> [c0303f40] [c02d28c8] free_all_bootmem_core+0xf0/0x1f8
> [c0303f70] [c02d29fc] free_all_bootmem+0x2c/0x6c
> [c0303f90] [c02cc7dc] mem_init+0x70/0x2ac
> [c0303fc0] [c02c66a4] start_kernel+0x150/0x27c
> [c0303ff0] [00003438] 0x3438
> 
> And this might be interesting: the PFN of the page being added in that
> critical 61st call is 130048, which exactly matches the number of available
> pages:
> 
>   free_area_init_node: node 0, pgdat c02fee6c, node_mem_map c0330000
>     DMA zone: 1024 pages used for memmap
>     DMA zone: 0 pages reserved
>     DMA zone: 130048 pages, LIFO batch:31
>   Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 130048
> 
> Suspicious?
> 

A bit but I still don't know why it would cause corruption. Maybe this is still
a caching issue but the difference in timing between list_add and list_add_tail
is enough to hide the bug. It's also possible there are some registers
ioremapped after the memmap array and reading them is causing some
problem.

Andrew, what is the right thing to do here? We could flail around looking
for explanations as to why the bug causes a user buffer corruption but never
get an answer or do we go with this patch, preferably before 2.6.36 releases?

==== CUT HERE ====
mm, page-allocator: Do not check the state of a non-existant buddy during free

There is a bug in commit [6dda9d55: page allocator: reduce fragmentation
in buddy allocator by adding buddies that are merging to the tail of the
free lists] that means a buddy at order MAX_ORDER is checked for
merging. A page of this order never exists so at times, an effectively
random piece of memory is being checked.

Alan Curry has reported that this is causing memory corruption in userspace
data on a PPC32 platform (http://lkml.org/lkml/2010/10/9/32). It is not clear
why this is happening. It could be a cache coherency problem where pages
mapped in both user and kernel space are getting different cache lines due
to the bad read from kernel space (http://lkml.org/lkml/2010/10/13/179). It
could also be that there are some special registers being io-remapped at
the end of the memmap array and that a read has special meaning on them.
Compiler bugs have been ruled out because the assembly before and after
the patch looks relatively harmless.

This patch fixes the problem by ensuring we are not reading a possibly
invalid location of memory. It's not clear why the read causes
corruption but one way or the other it is a buggy read.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8cfa9c..93cef41 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -530,7 +530,7 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-1) && pfn_valid_within(page_to_pfn(buddy))) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(page_to_pfn(buddy))) {
 		struct page *higher_page, *higher_buddy;
 		combined_idx = __find_combined_index(page_idx, order);
 		higher_page = page + combined_idx - page_idx;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
