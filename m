Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D72AE6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 17:31:46 -0400 (EDT)
Date: Thu, 26 Aug 2010 14:30:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-Id: <20100826143052.f079e43c.akpm@linux-foundation.org>
In-Reply-To: <20100826075910.GA2189@sli10-conroe.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
	<20100723234938.88EB.A69D9226@jp.fujitsu.com>
	<20100726050827.GA24047@sli10-desk.sh.intel.com>
	<20100805140755.501af8a7.akpm@linux-foundation.org>
	<20100806030805.GA10038@sli10-desk.sh.intel.com>
	<20100825130318.93c03403.akpm@linux-foundation.org>
	<20100826075910.GA2189@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 15:59:10 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> On Thu, Aug 26, 2010 at 04:03:18AM +0800, Andrew Morton wrote:
> > On Fri, 6 Aug 2010 11:08:05 +0800
> > Shaohua Li <shaohua.li@intel.com> wrote:
> > 
> > > Subject: mm: batch activate_page() to reduce lock contention
> > 
> ...
>
> > This function is pretty bizarre.  It really really needs some comments
> > explaining what it's doing and most especially *why* it's doing it.
> > 
> > It's a potential O(n*nr_zones) search (I think)!  We demand proof that
> > it's worthwhile!
> > 
> > Yes, if the pagevec is filled with pages from different zones then it
> > will reduce the locking frequency.  But in the common case where the
> > pagevec has pages all from the same zone, or has contiguous runs of
> > pages from different zones then all that extra bitmap fiddling gained
> > us nothing.
> > 
> > (I think the search could be made more efficient by advancing `i' when
> > we first see last_zone!=page_zone(page), but that'd just make the code
> > even worse).
> Thanks for pointing this out. Then we can simplify things a little bit.
> the 144 bytes footprint is because of this too, then we can remove it.

ok..

> > 
> > There's a downside/risk to this code.  A billion years ago I found
> > that it was pretty important that if we're going to batch pages in this
> > manner, it's important that ALL pages be batched via the same means. 
> > If 99% of the pages go through the pagevec and 1% of pages bypass the
> > pagevec, the LRU order gets scrambled and we can end up causing
> > additional disk seeks when the time comes to write things out.  The
> > effect was measurable.
> > 
> > And lo, putback_lru_pages() (at least) bypasses your new pagevecs,
> > potentially scrambling the LRU ordering.  Admittedly, if we're putting
> > back unreclaimable pages in there, the LRU is probably already pretty
> > scrambled.  But that's just a guess.
> ok, we can drain the pagevecs in putback_lru_pages() or add active page
> to the new pagevecs.

The latter I guess?

> > Even if that is addressed, we still scramble the LRU to some extent
> > simply because the pagevecs are per-cpu.  We already do that to some
> > extent when shrink_inactive_list() snips a batch of pages off the LRU
> > for processing.  To what extent this matters and to what extent your
> > new activate_page() worsens this is also unknown.
> ok, this is possible. Any suggestion which benchmark I can test to verify
> if this is a real problem?

Any test which does significant amounts of writeback off the LRU.

And...  we don't do significant amounts of writeback off the LRU any
more.  We used to, long ago.  Then we broke it and started to do lots
more.  Then we changed other things and the current state of play is
that Mel hasn't been able to find any workload which does much at all,
and there are moves afoot to eliminate writeback-off-LRU altogether.

So I expect this won't actually be a problem.  Until we change things again ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
