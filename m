Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 977736B01AC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 22:24:30 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5M2OSOj031155
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 22 Jun 2010 11:24:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA9F945DE4F
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 11:24:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CE62745DD71
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 11:24:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 70BA6E08001
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 11:24:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F359CE08002
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 11:24:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] Call cond_resched() at bottom of main look in balance_pgdat()
In-Reply-To: <20100621141315.GB2456@barrios-desktop>
References: <20100618093954.FBE7.A69D9226@jp.fujitsu.com> <20100621141315.GB2456@barrios-desktop>
Message-Id: <20100622112416.B554.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Jun 2010 11:24:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > =============================================================
> > Subject: [PATCH] Call cond_resched() at bottom of main look in balance_pgdat()
> > From: Larry Woodman <lwoodman@redhat.com>
> > 
> > We are seeing a problem where kswapd gets stuck and hogs the CPU on a
> > small single CPU system when an OOM kill should occur.  When this
> > happens swap space has been exhausted and the pagecache has been shrunk
> > to zero.  Once kswapd gets the CPU it never gives it up because at least
> > one zone is below high.  Adding a single cond_resched() at the end of
> > the main loop in balance_pgdat() fixes the problem by allowing the
> > watchdog and tasks to run and eventually do an OOM kill which frees up
> > the resources.
> > 
> > kosaki note: This seems regression caused by commit bb3ab59683
> > (vmscan: stop kswapd waiting on congestion when the min watermark is
> >  not being met)
> > 
> > Signed-off-by: Larry Woodman <lwoodman@redhat.com>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 9c7e57c..c5c46b7 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2182,6 +2182,7 @@ loop_again:
> >  		 */
> >  		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> >  			break;
> > +		cond_resched();
> >  	}
> >  out:
> >  	/*
> > -- 
> > 1.6.5.2
> 
> Kosaki's patch's goal is that kswap doesn't yield cpu if the zone doesn't meet its
> min watermark to avoid failing atomic allocation.
> But this patch could yield kswapd's time slice at any time. 
> Doesn't the patch break your goal in bb3ab59683?

No. it don't break.

Typically, kswapd periodically call shrink_page_list() and it call
cond_resched() even if bb3ab59683 case.
Larry observed very exceptional situation. his system don't have
reclaimable pages at all, then eventually shrink_page_list() was not
called very long time.
His patch only change such very rare situation, I think it's safe.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
