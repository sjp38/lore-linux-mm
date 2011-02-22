Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A0B198D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:42:28 -0500 (EST)
Date: Tue, 22 Feb 2011 15:42:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110222144200.GY13092@random.random>
References: <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <20110214022524.GA18198@sli10-conroe.sh.intel.com>
 <20110222142559.GD15652@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222142559.GD15652@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, alex.shi@intel.com

On Tue, Feb 22, 2011 at 02:25:59PM +0000, Mel Gorman wrote:
> The higher min_free_kbytes is expected as a result of using transparent
> hugepages so I don't really consider it a bug. Free memory going up to

That's true. THP can definitely increase the memory footprint of
certain apps. Especially if the app is allocating lots of data but
only touching a few bytes scattered over the mapping, the memory
footprint can increase up to 512fold (absolute worst case of course,
in average it will be less). This is why there's the enabled=madvise
option after all.

> about 700M as a result of kswapd is a real bug though.

Yes.

> > in our test, there is about 50M memory free (originally just about 5M, which
> > will cause more swap. Should we also reduce the min_free_kbytes?
> > 
> 
> Either that or boot with transparent hugepages disabled and
> min_free_kbytes will be lower.

I suggest to boot with transparent_hugepage=madvise, or to set the
default to madvise in make menuconfig. That will still enable the
anti-frag logic in the buddy allocator in full. If the problem goes
away with the madvise setting, then it's not related to
min_free_kbytes. With the 700M fix for kswapd however it's hard to
imagine the increase min_free_kbytes to cause out of memory conditions
even if it uses a little more memory to allow for increased
performance thanks to hugepages.

Another thing we can change (in addition to the 700M-waste fix in
kswapd) is this:

	/*
	 * By default disable transparent hugepages on smaller
	systems,
	 * where the extra memory used could hurt more than TLB
	overhead
	 * is likely to save.  The admin can still enable it through
	/sys.
	 */
	 if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
	    transparent_hugepage_flags = 0;

and:

	/* don't ever allow to reserve more than 5% of the lowmem */
	recommended_min = min(recommended_min,
			        (unsigned long) nr_free_buffer_pages()
	/ 20);


We can reduce the max min_free_kbytes to less than 5% of the lowmem,
and we can also decide not to enable THP if there's less than 2G
instead of "less than 512M".

I'm also intrigued by reducing this from 2 to 1:

    /* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
    recommended_min = pageblock_nr_pages * nr_zones * 2;

Do we really need 2 pages instead of just 1 here to provide the
guarantee? I thought 1 page would be enough. But you know anti-frag
logic better ;). It won't save a lot of memory but just a couple of
mbytes, I doubt it can make any real difference. Still I prefer 1 if
it's enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
