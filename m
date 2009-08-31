Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59E396B0062
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:59:53 -0400 (EDT)
Date: Mon, 31 Aug 2009 11:59:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: page allocator regression on nommu
Message-ID: <20090831105952.GC29627@csn.ul.ie>
References: <20090831074842.GA28091@linux-sh.org> <20090831103056.GA29627@csn.ul.ie> <20090831104315.GB30264@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090831104315.GB30264@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 07:43:15PM +0900, Paul Mundt wrote:
> On Mon, Aug 31, 2009 at 11:30:56AM +0100, Mel Gorman wrote:
> > On Mon, Aug 31, 2009 at 04:48:43PM +0900, Paul Mundt wrote:
> > > Hi Mel,
> > > 
> > > It seems we've managed to trigger a fairly interesting conflict between
> > > the anti-fragmentation disabling code and the nommu region rbtree. I've
> > > bisected it down to:
> > > 
> > > commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > > Author: Mel Gorman <mel@csn.ul.ie>
> > > Date:   Tue Jun 16 15:31:58 2009 -0700
> > > 
> > >     page allocator: move check for disabled anti-fragmentation out of fastpath
> > > 
> > >     On low-memory systems, anti-fragmentation gets disabled as there is
> > >     nothing it can do and it would just incur overhead shuffling pages between
> > >     lists constantly.  Currently the check is made in the free page fast path
> > >     for every page.  This patch moves it to a slow path.  On machines with low
> > >     memory, there will be small amount of additional overhead as pages get
> > >     shuffled between lists but it should quickly settle.
> > > 
> > > which causes death on unpacking initramfs on my nommu board. With this
> > > reverted, everything works as expected. Note that this blows up with all of
> > > SLOB/SLUB/SLAB.
> > > 
> > > I'll continue debugging it, and can post my .config if it will be helpful, but
> > > hopefully you have some suggestions on what to try :-)
> > > 
> > 
> > Based on the output you have given me, it would appear the real
> > underlying cause is that fragmentation caused the allocation to fail.
> > The following patch might fix the problem.
> >
> Unfortunately this has no impact, the same issue occurs.
> 

What is the output of the following debug patch?

====
page-allocator: Debug per-cpu free

It's possible that pages being freed on the per-cpu list of 1 page is
the wrong type when anti-fragmentation is disabled. It could have the
impact of triggering a fallback earlier than it should happen.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..a2a11ce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1042,6 +1042,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	set_page_private(page, get_pageblock_migratetype(page));
+	WARN_ON_ONCE(page_group_by_mobility_disabled && page_private(page) != MIGRATE_UNMOVABLE);
 	local_irq_save(flags);
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
