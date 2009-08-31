Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E73D6B005A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:30:56 -0400 (EDT)
Date: Mon, 31 Aug 2009 11:30:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: page allocator regression on nommu
Message-ID: <20090831103056.GA29627@csn.ul.ie>
References: <20090831074842.GA28091@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090831074842.GA28091@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 04:48:43PM +0900, Paul Mundt wrote:
> Hi Mel,
> 
> It seems we've managed to trigger a fairly interesting conflict between
> the anti-fragmentation disabling code and the nommu region rbtree. I've
> bisected it down to:
> 
> commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> Author: Mel Gorman <mel@csn.ul.ie>
> Date:   Tue Jun 16 15:31:58 2009 -0700
> 
>     page allocator: move check for disabled anti-fragmentation out of fastpath
> 
>     On low-memory systems, anti-fragmentation gets disabled as there is
>     nothing it can do and it would just incur overhead shuffling pages between
>     lists constantly.  Currently the check is made in the free page fast path
>     for every page.  This patch moves it to a slow path.  On machines with low
>     memory, there will be small amount of additional overhead as pages get
>     shuffled between lists but it should quickly settle.
> 
> which causes death on unpacking initramfs on my nommu board. With this
> reverted, everything works as expected. Note that this blows up with all of
> SLOB/SLUB/SLAB.
> 
> I'll continue debugging it, and can post my .config if it will be helpful, but
> hopefully you have some suggestions on what to try :-)
> 

Based on the output you have given me, it would appear the real
underlying cause is that fragmentation caused the allocation to fail.
The following patch might fix the problem.

====
page-allocator: Always change pageblock ownership when anti-fragmentation is disabled

On low-memory systems, anti-fragmentation gets disabled as there is nothing
it can do and it would just incur overhead shuffling pages between lists
constantly. When the system starts up, there is a period of time when
all the pageblocks are marked MOVABLE and the expectation is that they
get marked UNMOVABLE.

However, when MAX_ORDER is a large number, the pageblocks may not change
ownership because the normal criteria do not apply. This can have the
effect of prematurely breaking up too many large contiguous blocks which
can be a problem on NOMMU systems.

This patch causes pageblocks to change ownership ever time a fallback
occurs when anti-fragmentation is disabled. This should prevent the
large blocks being prematurely broken up.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..cfe9a5b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -817,7 +817,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * agressive about taking ownership of free pages
 			 */
 			if (unlikely(current_order >= (pageblock_order >> 1)) ||
-					start_migratetype == MIGRATE_RECLAIMABLE) {
+					start_migratetype == MIGRATE_RECLAIMABLE ||
+					page_group_by_mobility_disabled) {
 				unsigned long pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
