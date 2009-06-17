Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 668C86B004D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:43:52 -0400 (EDT)
Date: Thu, 18 Jun 2009 00:41:49 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090617224149.GA16104@cmpxchg.org>
References: <20090609190128.GA1785@cmpxchg.org> <20090611143122.108468f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611143122.108468f1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.org.uk>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 02:31:22PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Jun 2009 21:01:28 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > [resend with lists cc'd, sorry]
> > 
> > +static int swap_readahead_ptes(struct mm_struct *mm,
> > +			unsigned long addr, pmd_t *pmd,
> > +			swp_entry_t *entries,
> > +			unsigned long cluster)
> > +{
> > +	unsigned long window, min, max, limit;
> > +	spinlock_t *ptl;
> > +	pte_t *ptep;
> > +	int i, nr;
> > +
> > +	window = cluster << PAGE_SHIFT;
> > +	min = addr & ~(window - 1);
> > +	max = min + cluster;
> 
> Johannes, I wonder there is no reason to use "alignment".

I am wondering too.  I digged into the archives but the alignment
comes from a change older than what history.git documents, so I wasn't
able to find written down justification for this.

> I think we just need to read "nearby" pages. Then, this function's
> scan range should be
> 
> 	[addr - window/2, addr + window/2)
> or some.
> 
> And here, too
> > +	if (!entries)	/* XXX: shmem case */
> > +		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
> > +	pmin = swp_offset(entry) & ~(cluster - 1);
> > +	pmax = pmin + cluster;
> 
> pmin = swp_offset(entry) - cluster/2.
> pmax = swp_offset(entry) + cluster/2.
> 
> I'm sorry if I miss a reason for using "alignment".

Perhas someone else knows a good reason for it, but I think it could
even be harmful.

Chances are that several processes fault around the same slots
simultaneously.  By letting them all start at the same aligned offset
we have a maximum race between them and they all allocate pages for
the same slots concurrently.

By placing the window unaligned we decrease this overlapping, so it
sounds like a good idea.

It would increase the amount of readahead done even more, though, and
Fengguang already measured degradation in IO latency with my patch, so
this probably needs more changes to work well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
