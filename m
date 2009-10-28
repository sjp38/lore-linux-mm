Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B8F66B0078
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 23:54:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S3s5Qf006698
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 28 Oct 2009 12:54:06 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC3B145DE5B
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BAEC45DE53
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4980F1DB8043
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:54:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E155D1DB8040
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:54:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
In-Reply-To: <20091027131905.410ec04a.akpm@linux-foundation.org>
References: <1256650833-15516-4-git-send-email-mel@csn.ul.ie> <20091027131905.410ec04a.akpm@linux-foundation.org>
Message-Id: <20091028115505.FD88.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Oct 2009 12:54:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 27 Oct 2009 13:40:33 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When a high-order allocation fails, kswapd is kicked so that it reclaims
> > at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> > allocations. Something has changed in recent kernels that affect the timing
> > where high-order GFP_ATOMIC allocations are now failing with more frequency,
> > particularly under pressure. This patch forces kswapd to notice sooner that
> > high-order allocations are occuring.
> 
> "something has changed"?  Shouldn't we find out what that is?

if kswapd_max_order was changed, kswapd quickly change its own reclaim
order.

old:
  1. happen order-0 allocation
  2. kick kswapd
  3. happen high-order allocation
  4. change kswapd_max_order, but kswapd continue order-0 reclaim.
  5. kswapd end order-0 reclaim and exit balance_pgdat
  6. kswapd() restart balance_pdgat() with high-order

new:
  1. happen order-0 allocation
  2. kick kswapd
  3. happen high-order allocation
  4. change kswapd_max_order
  5. kswapd notice it and quickly exit balance_pgdat()
  6. kswapd() restart balance_pdgat() with high-order

> 
> > ---
> >  mm/vmscan.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 64e4388..7eceb02 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2016,6 +2016,15 @@ loop_again:
> >  					priority != DEF_PRIORITY)
> >  				continue;
> >  
> > +			/*
> > +			 * Exit the function now and have kswapd start over
> > +			 * if it is known that higher orders are required
> > +			 */
> > +			if (pgdat->kswapd_max_order > order) {
> > +				all_zones_ok = 1;
> > +				goto out;
> > +			}
> > +
> >  			if (!zone_watermark_ok(zone, order,
> >  					high_wmark_pages(zone), end_zone, 0))
> >  				all_zones_ok = 0;
> 
> So this handles the case where some concurrent thread or interrupt
> increases pgdat->kswapd_max_order while kswapd was running
> balance_pgdat(), yes?

Yes.

> Does that actually happen much?  Enough for this patch to make any
> useful difference?

In typical use-case, it doesn't have so much improvement. However some
driver use high-order allocation on interrupt context.
It mean we need quickly reclaim before GFP_ATOMIC allocation failure.

I agree these driver is ill. but...
We can't ignore enduser bug report.


> 
> If one where to whack a printk in that `if' block, how often would it
> trigger, and under what circumstances?
> 
> 
> If the -stable maintainers were to ask me "why did you send this" then
> right now my answer would have to be "I have no idea".  Help.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
