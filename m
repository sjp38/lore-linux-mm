Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E63046B005A
	for <linux-mm@kvack.org>; Sun, 25 Oct 2009 21:11:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9Q1BWqg000900
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Oct 2009 10:11:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 11C9545DE80
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:11:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D61C845DE60
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:11:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8C791DB803F
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:11:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 326B1E18005
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:11:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
In-Reply-To: <1256221356-26049-2-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20091026100019.2F4A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Oct 2009 10:11:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> If a direct reclaim makes no forward progress, it considers whether it
> should go OOM or not. Whether OOM is triggered or not, it may retry the
> application afterwards. In times past, this would always wake kswapd as well
> but currently, kswapd is not woken up after direct reclaim fails. For order-0
> allocations, this makes little difference but if there is a heavy mix of
> higher-order allocations that direct reclaim is failing for, it might mean
> that kswapd is not rewoken for higher orders as much as it did previously.
> 
> This patch wakes up kswapd when an allocation is being retried after a direct
> reclaim failure. It would be expected that kswapd is already awake, but
> this has the effect of telling kswapd to reclaim at the higher order as well.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf72055..dfa4362 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1817,9 +1817,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>  		goto nopage;
>  
> +restart:
>  	wake_all_kswapd(order, zonelist, high_zoneidx);
>  
> -restart:
>  	/*
>  	 * OK, we're below the kswapd watermark and have kicked background
>  	 * reclaim. Now things get more complex, so set up alloc_flags according

I think this patch is correct. personally, I like to add some commnent
at restart label. but it isn't big matter.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

However, I have a question. __alloc_pages_slowpath() retry logic is,

1. try_to_free_pages() reclaimed some pages:
	-> wait awhile and goto rebalance
2. try_to_free_pages() didn't reclaimed any page:
	-> call out_of_memory() and goto restart

Then, case-1 should be fixed too? 
I mean,

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf72055..5a27896 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1899,6 +1899,12 @@ rebalance:
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
+
+		/*
+		 * While we wait congestion wait, Amount of free memory can
+		 * be changed dramatically. Thus, we kick kswapd again.
+		 */
+		wake_all_kswapd(order, zonelist, high_zoneidx);
 		goto rebalance;
 	}
 
-------------------------------------------

?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
