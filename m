Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4J1R7Au032747
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:27:07 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4J1R7kv121248
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:27:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4J1R6CO007683
	for <linux-mm@kvack.org>; Wed, 18 May 2005 21:27:06 -0400
Subject: Re: [ckrm-tech] [Patch 5/6] CKRM: Add config support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050519003324.GA25265@chandralinux.beaverton.ibm.com>
References: <20050519003324.GA25265@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Wed, 18 May 2005 18:26:50 -0700
Message-Id: <1116466010.26955.102.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

There appears to still be some serious issues in the patch with respect
to per-zone accounting.  There is only accounting in each ckrm_mem_res
for each *kind* of zone, not each zone.

For instance, the accounting for a page appears to be the same no matter
which zone it came from, just which kind of zone

Then, when it comes to actually use some of the information, the kswapd
wakeup just throws a completely unrelated number into wakeup_kswapd().
ZONE_DMA (zone 0) tends to be *MUCH* smaller than ZONE_HIGHMEM, for
instance.  It doesn't make a whole lot of logical sense to me to be
waking up kswapd for a possibly 16GB zone with data from a 16MB zone.

+       for_each_zone(zone) {
+               /* This is just a number to get to wakeup kswapd */
+               order = cls->pg_total[0] -
+                       ((ckrm_mem_shrink_to * cls->pg_limit) / 100);
+               wakeup_kswapd(zone, order);
+               break; /* only once is enough */
+       }

If the number doesn't matter, why not just pass 0 into it?

Could you explain what advantages keeping a per-zone-type count has over
actually doing one count for each zone?  Also, why bother tracking it
per-zone-type anyway?  Would a single count work the same way?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
