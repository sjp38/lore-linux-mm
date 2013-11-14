Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0D72A6B0044
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 21:54:28 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y10so1326049pdj.33
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 18:54:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id n5si26139229pav.243.2013.11.13.18.54.26
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 18:54:27 -0800 (PST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 375BC3EE1D9
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:54:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26A1445DE51
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:54:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 026D745DE4D
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:54:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EAF1D1DB8032
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:54:23 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 554D81DB803E
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:54:23 +0900 (JST)
Message-ID: <52843B0E.60600@jp.fujitsu.com>
Date: Thu, 14 Nov 2013 11:53:02 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH resend] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, kosaki.motohiro@gmail.com, mgorman@suse.de

I resend this patch.
I added performance result into description of the patch.

------------------------------------------------------------------
Yasuaki Ishimatsu reported memory hot-add spent more than 5 _hours_
on 9TB memory machine since onlining memory sections is too slow.
And we found out setup_zone_migrate_reserve spnet >90% time.

The problem is, setup_zone_migrate_reserve scan all pageblock
unconditionally, but it is only necessary number of reserved block
was reduced (i.e. memory hot remove).
Moreover, maximum MIGRATE_RESERVE per zone are currently 2. It mean,
number of reserved pageblock are almost always unchanged.

This patch adds zone->nr_migrate_reserve_block to maintain number
of MIGRATE_RESERVE pageblock and it reduce an overhead of
setup_zone_migrate_reserve dramatically. Following table shows
time of onlining a memory section.

  Amount of memory     | 128GB | 192GB | 256GB|
  ---------------------------------------------
  linux-3.12           |  23.9 |  31.4 | 44.5 |
  This patch           |   8.3 |   8.3 |  8.6 |
  Mel's proposal patch |  10.9 |  19.2 | 31.3 |
  ---------------------------------------------
                                   (millisecond)

  128GB : 4 nodes and each node has 32GB of memory
  192GB : 6 nodes and each node has 32GB of memory
  256GB : 8 nodes and each node has 32GB of memory

  (*1) Mel proposed his idea by the following threads.
       https://lkml.org/lkml/2013/10/30/272	

Cc: Mel Gorman <mgorman@suse.de>
Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Tested-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |  6 ++++++
 mm/page_alloc.c        | 13 +++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e4..67ab5fe 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -490,6 +490,12 @@ struct zone {
 	unsigned long		managed_pages;

 	/*
+	 * Number of MIGRATE_RESEVE page block. To maintain for just
+	 * optimization. Protected by zone->lock.
+	 */
+	int			nr_migrate_reserve_block;
+
+	/*
 	 * rarely used fields:
 	 */
 	const char		*name;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5a98836..da93109 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3908,6 +3908,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	struct page *page;
 	unsigned long block_migratetype;
 	int reserve;
+	int old_reserve;

 	/*
 	 * Get the start pfn, end pfn and the number of blocks to reserve
@@ -3929,6 +3930,12 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	 * future allocation of hugepages at runtime.
 	 */
 	reserve = min(2, reserve);
+	old_reserve = zone->nr_migrate_reserve_block;
+
+	/* When memory hot-add, we almost always need to do nothing */
+	if (reserve == old_reserve)
+		return;
+	zone->nr_migrate_reserve_block = reserve;

 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		if (!pfn_valid(pfn))
@@ -3966,6 +3973,12 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 				reserve--;
 				continue;
 			}
+		} else if (!old_reserve) {
+			/*
+			 * When boot time, we don't need scan whole zone
+			 * for turning off MIGRATE_RESERVE.
+			 */
+			break;
 		}

 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
