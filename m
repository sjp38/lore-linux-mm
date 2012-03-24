Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D73ED6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 22:04:08 -0400 (EDT)
Date: Sat, 24 Mar 2012 13:03:53 +1100
From: Anton Blanchard <anton@samba.org>
Subject: kswapd stuck using 100% CPU
Message-ID: <20120324130353.48f2e4c8@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, aarcange@redhat.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


Hi,

I booted the latest git today on a ppc64 box. When I pushed it into
swap I noticed both kswapd's were using 100% CPU and the soft lockup
detector suggested it was stuck in balance_pgdat:

BUG: soft lockup - CPU#7 stuck for 23s! [kswapd1:359]
Call Trace:
[c00000000015e190] .balance_pgdat+0x150/0x940 
[c00000000015eb2c] .kswapd+0x1ac/0x490
[c00000000009edbc] .kthread+0xbc/0xd0
[c00000000002142c] .kernel_thread+0x54/0x70

I haven't had time to bisect but I did notice we were looping here:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7658fd6..c92bad2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2945,9 +2959,11 @@ out:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
+#if 0
 			/* Would compaction fail due to lack of free memory? */
 			if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
 				goto loop_again;
+#endif
 
 			/* Confirm the zone is balanced for order-0 */
 			if (!zone_watermark_ok(zone, 0,


After commenting it out the box is happy again.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
