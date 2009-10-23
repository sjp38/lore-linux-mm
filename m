Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3608B6B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 07:25:15 -0400 (EDT)
Date: Fri, 23 Oct 2009 12:25:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
	high-order watermarks are hit
Message-ID: <20091023112512.GW11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com> <20091023091334.GV11778@csn.ul.ie> <alpine.DEB.2.00.0910230229010.28109@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910230229010.28109@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 23, 2009 at 02:36:53AM -0700, David Rientjes wrote:
> On Fri, 23 Oct 2009, Mel Gorman wrote:
> 
> > > Hmm, is this really supposed to be added to __alloc_pages_high_priority()?  
> > > By the patch description I was expecting kswapd to be woken up 
> > > preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and 
> > > we're known to have just allocated at a higher order, not just when 
> > > current was oom killed (when we should already be freeing a _lot_ of 
> > > memory soon) or is doing a higher order allocation during direct reclaim.
> > > 
> > 
> > It was a somewhat arbitrary choice to have it trigger in the event high
> > priority allocations were happening frequently.
> > 
> 
> I don't quite understand, users of PF_MEMALLOC shouldn't be doing these 
> higher order allocations and if ALLOC_NO_WATERMARKS is by way of the oom 
> killer, we should be freeing a substantial amount of memory imminently 
> when it exits that waking up kswapd would be irrelevant.
> 

I agree. I think it's highly unlikely this patch will make any
difference but I wanted to eliminate it as a possibility. Patch 3 and 4
were previously one patch that were tested together.

> > > If this is moved to the fastpath, why is this wake_all_kswapd() and not
> > > wakeup_kswapd(preferred_zone, order)?  Do we need to kick kswapd in all 
> > > zones even though they may be free just because preferred_zone is now 
> > > below the watermark?
> > > 
> > 
> > It probably makes no difference as zones are checked for their watermarks
> > before any real work happens. However, even if this patch makes a difference,
> > I don't want to see it merged.  At best, it is an extremely heavy-handed
> > hack which is why I asked for it to be tested in isolation. It shouldn't
> > be necessary at all because sort of pre-emptive waking of kswapd was never
> > necessary before.
> > 
> 
> Ahh, that makes a ton more sense: this particular patch is a debugging 
> effort while the first two are candidates for 2.6.32 and -stable.  Gotcha.
> 

Yep.

> > > Wouldn't it be better to do this on page_zone(page) instead of 
> > > preferred_zone anyway?
> > > 
> > 
> > No. The preferred_zone is the zone we should be allocating from. If we
> > failed to allocate from it, it implies the watermarks are not being met
> > so we want to wake it.
> > 
> 
> Oops, I'm even more confused now :)  I thought the existing 
> wake_all_kswapd() in the slowpath was doing that and that this patch was 
> waking them prematurely because it speculates that a subsequent high 
> order allocation will fail unless memory is reclaimed. 


It should be doing that. This patch should be junk but because it was tested
previously, I needed to be sure it was actually junk.

> I thought we'd  
> want to reclaim from the zone we just did a high order allocation from so 
> that the fastpath could find the memory next time with ALLOC_WMARK_LOW.

The fastpath should be getting the pages it needs from the
preferred_zone. If it's not, we still want to get pages back in that
zone and the zone we actually ended up getting pages from.

It's probably best to ignore this patch except in the unlikely event Tobias
says it makes a difference to his testing. I'm hoping he's covered by patches
1+2 and maybe 3 and that patches 4 and 5 of this set get consigned to
the bit bucket.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
