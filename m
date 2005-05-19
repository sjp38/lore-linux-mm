Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4JGXHMS006128
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:33:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JGXHx6145450
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:33:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4JGXGZj027343
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:33:16 -0400
Date: Thu, 19 May 2005 09:26:53 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [ckrm-tech] [Patch 5/6] CKRM: Add config support for mem controller
Message-ID: <20050519162653.GB27270@chandralinux.beaverton.ibm.com>
References: <20050519003324.GA25265@chandralinux.beaverton.ibm.com> <1116466010.26955.102.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1116466010.26955.102.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 18, 2005 at 06:26:50PM -0700, Dave Hansen wrote:
> There appears to still be some serious issues in the patch with respect
> to per-zone accounting.  There is only accounting in each ckrm_mem_res
> for each *kind* of zone, not each zone.

In the absense of NUMA/DISCONTIGMEM, isn't 'kind of zone' and 'zone'
the same ? Correct me if this assumption is wrong.

> 
> For instance, the accounting for a page appears to be the same no matter
> which zone it came from, just which kind of zone
> 
> Then, when it comes to actually use some of the information, the kswapd
> wakeup just throws a completely unrelated number into wakeup_kswapd().
> ZONE_DMA (zone 0) tends to be *MUCH* smaller than ZONE_HIGHMEM, for
> instance.  It doesn't make a whole lot of logical sense to me to be
> waking up kswapd for a possibly 16GB zone with data from a 16MB zone.

When control goes into wakeup_kswapd(), it looks for the over_limit list and
works only on the classes, and completely ignores the arguments to 
wakeup_kswapd().

I did it this way(instead of having my own logic) to use existing code.
> 
> +       for_each_zone(zone) {
> +               /* This is just a number to get to wakeup kswapd */
> +               order = cls->pg_total[0] -
> +                       ((ckrm_mem_shrink_to * cls->pg_limit) / 100);
> +               wakeup_kswapd(zone, order);
> +               break; /* only once is enough */
> +       }
> 
> If the number doesn't matter, why not just pass 0 into it?

Yes, i could. will do it.
> 
> Could you explain what advantages keeping a per-zone-type count has over
> actually doing one count for each zone?  Also, why bother tracking it
> per-zone-type anyway?  Would a single count work the same way

fits the NUMA/DISCONTIGMEM issue discussed above.

> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
