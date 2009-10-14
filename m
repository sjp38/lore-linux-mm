Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EA2136B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 12:28:01 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <20091014103002.GA5027@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <20091012134328.GB8200@csn.ul.ie> <200910121932.14607.elendil@planet.nl>
	 <200910132238.40867.elendil@planet.nl>  <20091014103002.GA5027@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 14 Oct 2009 09:28:00 -0700
Message-Id: <1255537680.21134.14.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Wed, 2009-10-14 at 03:30 -0700, Mel Gorman wrote:
> From 5fb9f897117bf2701f9fdebe4d008dbe34358ab9 Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Wed, 14 Oct 2009 11:19:57 +0100
> Subject: [PATCH] iwlwifi: Suppress warnings related to GFP_ATOMIC allocations that do not matter
> 
> iwlwifi refills RX buffers in two ways - a direct method using GFP_ATOMIC
> and a tasklet method using GFP_KERNEL. There are a number of RX buffers and
> there are only serious issues when there are no RX buffers left. The driver
> explicitly warns when refills are failing and the buffers are low but it
> always warns when a GFP_ATOMIC allocation fails even when there is no
> packet loss as a result.


No, it does not always warn when a GFP_ATOMIC allocation fails. Please
check earlier in iwl_rx_allocate() we have:

if (rxq->free_count > RX_LOW_WATERMARK)
	priority |= __GFP_NOWARN;

So it will suppress warnings as long as we have buffers available.

We do want to see warnings if memory is below watermark and allocation
fails - your patch prevents these warnings from appearing.

> This patch specifies __GFP_NOWARN for the direct refill method that uses
> GFP_ATOMIC. To help identify where allocation failures might be coming
> from, the stack is dumped when the RX queue is dangerously low.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  drivers/net/wireless/iwlwifi/iwl-rx.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
> old mode 100644
> new mode 100755
> diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
> index 8e1bb53..f91a108 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-rx.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
> @@ -260,10 +260,12 @@ void iwl_rx_allocate(struct iwl_priv *priv, gfp_t priority)
>  			if (net_ratelimit())
>  				IWL_DEBUG_INFO(priv, "Failed to allocate SKB buffer.\n");
>  			if ((rxq->free_count <= RX_LOW_WATERMARK) &&
> -			    net_ratelimit())
> +			    net_ratelimit()) {
>  				IWL_CRIT(priv, "Failed to allocate SKB buffer with %s. Only %u free buffers remaining.\n",
>  					 priority == GFP_ATOMIC ?  "GFP_ATOMIC" : "GFP_KERNEL",
>  					 rxq->free_count);
> +				dump_stack();
> +			}
>  			/* We don't reschedule replenish work here -- we will
>  			 * call the restock method and if it still needs
>  			 * more buffers it will schedule replenish */
> @@ -320,7 +322,7 @@ EXPORT_SYMBOL(iwl_rx_replenish);
>  
>  void iwl_rx_replenish_now(struct iwl_priv *priv)
>  {
> -	iwl_rx_allocate(priv, GFP_ATOMIC);
> +	iwl_rx_allocate(priv, GFP_ATOMIC|__GFP_NOWARN);
>  
>  	iwl_rx_queue_restock(priv);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
