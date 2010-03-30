Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 73A7A6B01F3
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:45:38 -0400 (EDT)
Date: Tue, 30 Mar 2010 18:44:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36 of 41] remove PG_buddy
Message-ID: <20100330164438.GI5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <27d13ddf7c8f7ca03652.1269887869@v2.random>
 <1269888584.12097.371.camel@laptop>
 <20100329221718.GA5825@random.random>
 <1269901837.9160.43341.camel@nimitz>
 <20100330001511.GB5825@random.random>
 <alpine.DEB.2.00.1003301133530.24266@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003301133530.24266@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 30, 2010 at 11:35:01AM -0500, Christoph Lameter wrote:
> On Tue, 30 Mar 2010, Andrea Arcangeli wrote:
> 
> > > Looks like SLUB also uses _mapcount for some fun purposes:
> > >
> > >         struct page {
> > >                 unsigned long flags;            /* Atomic flags, some possibly
> > >                                                  * updated asynchronously */
> > >                 atomic_t _count;                /* Usage count, see below. */
> > >                 union {
> > >                         atomic_t _mapcount;     /* Count of ptes mapped in mms,
> > >                                                  * to show when page is mapped
> > >                                                  * & limit reverse map searches.
> > >                                                  */
> > >                         struct {                /* SLUB */
> > >                                 u16 inuse;
> > >                                 u16 objects;
> > >                         };
> > >                 };
> > >
> > > I guess those don't *really* become a problem in practice until we get a
> > > really large page size that can hold >=64k objects.  But, at that point,
> > > we're overflowing the types anyway (or really close to it).
> >
> > Maybe we should add a BUG_ON in slub in case anybody runs this on
> > PAGE_SIZE == 2M (to avoid silent corruption).
> 
> SLUB has been verified a long time ago to run fine with 2M pages.
> 
> Just specify
> 
> slub_min_order=9
> 
> on the kernel command line to get a system booted up with 2M slab pages.

sure no doubt if order 9 == 2M it's no problem, what I meant is:

#define PAGE_SIZE (4096*512)

2M >>> 64k so with order 0 == 2m I thought it might overflow, dunno!

As far as PG_buddy removal is concerned, if I use -2 I don't think
there can be any problem as it'd be next to overflow anyway like Dave
said.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
