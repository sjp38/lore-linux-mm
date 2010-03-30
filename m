Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EDF116B022D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:16:26 -0400 (EDT)
Date: Tue, 30 Mar 2010 02:15:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36 of 41] remove PG_buddy
Message-ID: <20100330001511.GB5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <27d13ddf7c8f7ca03652.1269887869@v2.random>
 <1269888584.12097.371.camel@laptop>
 <20100329221718.GA5825@random.random>
 <1269901837.9160.43341.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269901837.9160.43341.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 03:30:37PM -0700, Dave Hansen wrote:
> Don't forget that include/linux/memory_hotplug.h uses mapcount a bit for
> marking bootmem.  So, just for clarity, we'd probably want to use -5 or
> something.
>         
>         /*
>          * Types for free bootmem.
>          * The normal smallest mapcount is -1. Here is smaller value than it.
>          */
>         #define SECTION_INFO            (-1 - 1)
>         #define MIX_SECTION_INFO        (-1 - 2)
>         #define NODE_INFO               (-1 - 3)

So this is the memory holding the struct page and pgdat info that is
released when the memory is hot-removed? Why isn't
register_page_bootmem_info_node up to get_page_bootmem all let it go
in the __init section together with their only caller? 

what is the reader of that type field? is it only put_page_bootmem?
Just for this BUG_ON?

     BUG_ON(type >= -1);

and what is this about?

    if (atomic_dec_return(&page->_count) == 1) {

How can this every return 0?

Yes I can use -5 no problem, that's no big deal but I don't get how
this _mapcount type info is used and why. Well the BUG_ON above is
obvious but I wonder if it's just for a BUG_ON. If it's just for a
BUG_ON can we just move the layering violation to page->lru.next and
leave mapcount -2 for PageBuddy?

> Looks like SLUB also uses _mapcount for some fun purposes:
>         
>         struct page {
>                 unsigned long flags;            /* Atomic flags, some possibly
>                                                  * updated asynchronously */
>                 atomic_t _count;                /* Usage count, see below. */
>                 union {
>                         atomic_t _mapcount;     /* Count of ptes mapped in mms,
>                                                  * to show when page is mapped
>                                                  * & limit reverse map searches.
>                                                  */
>                         struct {                /* SLUB */
>                                 u16 inuse;
>                                 u16 objects;
>                         };
>                 };
> 
> I guess those don't *really* become a problem in practice until we get a
> really large page size that can hold >=64k objects.  But, at that point,
> we're overflowing the types anyway (or really close to it).  

Maybe we should add a BUG_ON in slub in case anybody runs this on
PAGE_SIZE == 2M (to avoid silent corruption).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
