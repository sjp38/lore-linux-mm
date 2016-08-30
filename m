Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F08206B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:00:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u81so17836173wmu.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:00:55 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id p89si18067705wma.61.2016.08.30.08.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 08:00:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 2E5AD1C1CD9
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 16:00:54 +0100 (IST)
Date: Tue, 30 Aug 2016 16:00:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Message-ID: <20160830150051.GW8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
 <20160830120728.GV8119@techsingularity.net>
 <20160830142508.GA10514@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160830142508.GA10514@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

On Tue, Aug 30, 2016 at 07:55:08PM +0530, Srikar Dronamraju wrote:
> > > 
> > > This patch seems to hurt FA_DUMP functionality. This behaviour is not
> > > seen on v4.7 but only after this patch.
> > > 
> > > So when a kernel on a multinode machine with memblock_reserve() such
> > > that most of the nodes have zero available memory, kswapd seems to be
> > > consuming 100% of the time.
> > > 
> > 
> > Why is FA_DUMP specifically the trigger? If the nodes have zero available
> > memory then is the zone_populated() check failing when FA_DUMP is enabled? If
> > so, that would both allow kswapd to wake and stay awake.
> > 
> 
> The trigger is memblock_reserve() for the complete node memory.  And
> this is exactly what FA_DUMP does.  Here again the node has memory but
> its all reserved so there is no free memory in the node.
> 
> Did you mean populated_zone() when you said zone_populated or have I
> mistaken? populated_zone() does return 1 since it checks for
> zone->present_pages.
> 

Yes, I meant populated_zone(). Using present pages may have hidden
a long-lived corner case as it was unexpected that an entire node
would be reserved. The old code happened to survive *probably* because
pgdat_reclaimable would look false and kswapd checks for pgdat being
balanced would happen to do the right thing in this case.

Can you check if something like this works?

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78b65e1..cf64a5456cf6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -830,7 +830,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 
 static inline int populated_zone(struct zone *zone)
 {
-	return (!!zone->present_pages);
+	return (!!zone->managed_pages);
 }
 
 extern int movable_zone;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
