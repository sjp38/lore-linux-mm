Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B98FE6B0044
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 22:42:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R2gueq014438
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Oct 2009 11:42:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 96AF545DE50
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:42:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7675E45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:42:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C7541DB803E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:42:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 149431DB8038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:42:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
In-Reply-To: <alpine.DEB.2.00.0910260005500.15361@chino.kir.corp.google.com>
References: <20091026100019.2F4A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0910260005500.15361@chino.kir.corp.google.com>
Message-Id: <20091026222159.2F72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Oct 2009 11:42:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 26 Oct 2009, KOSAKI Motohiro wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bf72055..5a27896 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1899,6 +1899,12 @@ rebalance:
> >  	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
> >  		/* Wait for some write requests to complete then retry */
> >  		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > +
> > +		/*
> > +		 * While we wait congestion wait, Amount of free memory can
> > +		 * be changed dramatically. Thus, we kick kswapd again.
> > +		 */
> > +		wake_all_kswapd(order, zonelist, high_zoneidx);
> >  		goto rebalance;
> >  	}
> >  
> 
> We're blocking to finish writeback of the directly reclaimed memory, why 
> do we need to wake kswapd afterwards?

the same reason of "goto restart" case. that's my intention.
if following scenario occur, it is equivalent that we didn't call wake_all_kswapd().

  1. call congestion_wait()
  2. kswapd reclaimed lots memory and sleep
  3. another task consume lots memory
  4. wakeup from congestion_wait()

IOW, if we falled into __alloc_pages_slowpath(), we naturally expect
next page_alloc() don't fall into slowpath. however if kswapd end to
its work too early, this assumption isn't true.

Is this too pessimistic assumption?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
