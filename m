Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8FAB6B022F
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 18:30:53 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2TMR8in007771
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 16:27:08 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2TMUgcH111242
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 16:30:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2TMUeS2022682
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 16:30:41 -0600
Subject: Re: [PATCH 36 of 41] remove PG_buddy
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100329221718.GA5825@random.random>
References: <patchbomb.1269887833@v2.random>
	 <27d13ddf7c8f7ca03652.1269887869@v2.random>
	 <1269888584.12097.371.camel@laptop>  <20100329221718.GA5825@random.random>
Content-Type: text/plain
Date: Mon, 29 Mar 2010 15:30:37 -0700
Message-Id: <1269901837.9160.43341.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-30 at 00:17 +0200, Andrea Arcangeli wrote:
> On Mon, Mar 29, 2010 at 08:49:44PM +0200, Peter Zijlstra wrote:
> > On Mon, 2010-03-29 at 20:37 +0200, Andrea Arcangeli wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > PG_buddy can be converted to page->_count == -1. So the PG_compound_lock can be
> > > added to page->flags without overflowing (because of the section bits
> > > increasing) with CONFIG_X86_PAE=y.
> > 
> > This seems to break the assumption that all free pages have a zero page
> > count relied upon by things like page_cache_get_speculative().
> > 
> > What if a page-cache pages gets freed and used as a head in the buddy
> > list while a concurrent lockless page-cache lookup tries to get a page
> > ref?
> 
> I forgot about get_page_unless_zero, still the concept remains the
> same, we've just to move from _count to _mapcount or some other field
> in the page that we know will never to be some fixed value. Mapcount
> is the next candidate as it uses atomic ops and it starts from -1 but
> it should only be available on already allocated pages and to be
> guaranteed -1 when inside the buddy, so we can set mapcount -2 to
> signal the page is in the buddy. Or something like that, to me
> mapcount looks ideal but it's likely doubt in other means. The basic
> idea is that PG_buddy is a waste of ram

Don't forget that include/linux/memory_hotplug.h uses mapcount a bit for
marking bootmem.  So, just for clarity, we'd probably want to use -5 or
something.
        
        /*
         * Types for free bootmem.
         * The normal smallest mapcount is -1. Here is smaller value than it.
         */
        #define SECTION_INFO            (-1 - 1)
        #define MIX_SECTION_INFO        (-1 - 2)
        #define NODE_INFO               (-1 - 3)
        
Looks like SLUB also uses _mapcount for some fun purposes:
        
        struct page {
                unsigned long flags;            /* Atomic flags, some possibly
                                                 * updated asynchronously */
                atomic_t _count;                /* Usage count, see below. */
                union {
                        atomic_t _mapcount;     /* Count of ptes mapped in mms,
                                                 * to show when page is mapped
                                                 * & limit reverse map searches.
                                                 */
                        struct {                /* SLUB */
                                u16 inuse;
                                u16 objects;
                        };
                };

I guess those don't *really* become a problem in practice until we get a
really large page size that can hold >=64k objects.  But, at that point,
we're overflowing the types anyway (or really close to it).  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
