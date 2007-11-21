Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lALLtAD0004425
	for <linux-mm@kvack.org>; Wed, 21 Nov 2007 16:55:10 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lALLt9Z8127950
	for <linux-mm@kvack.org>; Wed, 21 Nov 2007 14:55:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lALLt9pJ006946
	for <linux-mm@kvack.org>; Wed, 21 Nov 2007 14:55:09 -0700
Subject: pseries (power3) boot hang  (pageblock_nr_pages==0)
From: Will Schmidt <will_schmidt@vnet.ibm.com>
Reply-To: will_schmidt@vnet.ibm.com
Content-Type: text/plain
Date: Wed, 21 Nov 2007 15:55:11 -0600
Message-Id: <1195682111.4421.23.camel@farscape.rchland.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>, Stephen Rothwell <sfr@canb.auug.org.au>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

Hi Folks, 

I've been seeing a boot hang/crash on power3 systems for a few weeks.
(hangs on a 270, drops to SP on a p610).   This afternoon I got around
to tracking it down to the changes in 

commit d9c2340052278d8eb2ffb16b0484f8f794def4de
    Do not depend on MAX_ORDER when grouping pages by mobility

cpu 0x0: Vector: 100 (System Reset) at [c00000006e803ae0]
    pc: c00000000009bf50: .setup_per_zone_pages_min+0x298/0x34c
    lr: c00000000009be38: .setup_per_zone_pages_min+0x180/0x34c
[c00000006e803e20] c0000000005e3898 .init_per_zone_pages_min+0x80/0xa0
[c00000006e803ea0] c0000000005c9c04 .kernel_init+0x214/0x3d8
[c00000006e803f90] c000000000026cac .kernel_thread+0x4c/0x68

I narrowed it down to the for loop within setup_zone_migrate_reserve(),
called by setup_per_zone_pages_min().   The loop spins forever due to
pageblock_nr_pages being 0.

I imagine this would be properly fixed with something similar to the
change for iSeries.   Depending on how obvious, quick and easy it is for
the experts to come up with a proper fix,  I'll be able to do additional
debug and hacking after turkey-day.   :-)
For the moment, I've hacked it with the following patch.   (tested on
both the 270 and the p610):

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2454,6 +2454,9 @@ static void setup_zone_migrate_reserve(struct zone
*zone)
        reserve = roundup(zone->pages_min, pageblock_nr_pages) >>
                                                        pageblock_order;

+/* this is a cheap and dirty bailout, probally not a proper fix. */
+       if (pageblock_nr_pages==0) return;
+
        for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages)
{
                if (!pfn_valid(pfn))
                        continue;




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
