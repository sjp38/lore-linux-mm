Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7985F6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 17:01:47 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1875894pad.28
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 14:01:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id hj4si16483542pac.68.2013.10.23.14.01.45
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 14:01:46 -0700 (PDT)
Received: by mail-qe0-f50.google.com with SMTP id 1so866959qee.23
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 14:01:44 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
Date: Wed, 23 Oct 2013 17:01:32 -0400
Message-Id: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Yasuaki Ithimatsu reported memory hot-add spent more than 5 _hours_
on 9TB memory machine and we found out setup_zone_migrate_reserve
spnet >90% time.

The problem is, setup_zone_migrate_reserve scan all pageblock
unconditionally, but it is only necessary number of reserved block
was reduced (i.e. memory hot remove).
Moreover, maximum MIGRATE_RESERVE per zone are currently 2. It mean,
number of reserved pageblock are almost always unchanged.

This patch adds zone->nr_migrate_reserve_block to maintain number
of MIGRATE_RESERVE pageblock and it reduce an overhead of
setup_zone_migrate_reserve dramatically.

Cc: Mel Gorman <mgorman@suse.de>
Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |    6 ++++++
 mm/page_alloc.c        |   13 +++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

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
index 58e67ea..76ca054 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3909,6 +3909,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	struct page *page;
 	unsigned long block_migratetype;
 	int reserve;
+	int old_reserve;
 
 	/*
 	 * Get the start pfn, end pfn and the number of blocks to reserve
@@ -3930,6 +3931,12 @@ static void setup_zone_migrate_reserve(struct zone *zone)
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
@@ -3967,6 +3974,12 @@ static void setup_zone_migrate_reserve(struct zone *zone)
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
