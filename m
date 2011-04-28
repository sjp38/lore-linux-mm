Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A1BA76B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 02:19:46 -0400 (EDT)
Date: Thu, 28 Apr 2011 16:19:33 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 08/13] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20110428161933.1f1266e6@notabene.brown>
In-Reply-To: <1303920491-25302-9-git-send-email-mgorman@suse.de>
References: <1303920491-25302-1-git-send-email-mgorman@suse.de>
	<1303920491-25302-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 27 Apr 2011 17:08:06 +0100 Mel Gorman <mgorman@suse.de> wrote:


> @@ -1578,7 +1589,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
>   */
>  static inline struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
>  {
> -	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
> +	return alloc_pages_node(NUMA_NO_NODE, gfp_mask | __GFP_MEMALLOC, 0);
>  }
>  

I'm puzzling a bit over this change.
__netdev_alloc_page appears to be used to get pages to put in ring buffer
for a network card to DMA received packets into.  So it is OK to use
__GFP_MEMALLOC for these allocations providing we mark the resulting skb as
'pfmemalloc' if a reserved page was used.

However I don't see where that marking is done.
I think it should be in skb_fill_page_desc, something like:

  if (page->pfmemalloc)
	skb->pfmemalloc = true;

Is this covered somewhere else that I am missing?

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
