Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DFFA16B0037
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 11:19:13 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id x10so1133763pdj.12
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 08:19:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id cx4si18216913pbc.299.2013.10.30.08.19.11
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 08:19:12 -0700 (PDT)
Date: Wed, 30 Oct 2013 15:19:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: get rid of unnecessary pageblock scanning in
 setup_zone_migrate_reserve
Message-ID: <20131030151904.GO2400@suse.de>
References: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Wed, Oct 23, 2013 at 05:01:32PM -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Yasuaki Ithimatsu reported memory hot-add spent more than 5 _hours_
> on 9TB memory machine and we found out setup_zone_migrate_reserve
> spnet >90% time.
> 
> The problem is, setup_zone_migrate_reserve scan all pageblock
> unconditionally, but it is only necessary number of reserved block
> was reduced (i.e. memory hot remove).
> Moreover, maximum MIGRATE_RESERVE per zone are currently 2. It mean,
> number of reserved pageblock are almost always unchanged.
> 
> This patch adds zone->nr_migrate_reserve_block to maintain number
> of MIGRATE_RESERVE pageblock and it reduce an overhead of
> setup_zone_migrate_reserve dramatically.
> 

It seems regrettable to expand the size of struct zone just for this.
You are right that the number of blocks does not exceed 2 because of a
check made in setup_zone_migrate_reserve so it should be possible to
special case this. I didn't test this or think about it particularly
carefully and no doubt there is a nicer way but for illustration
purposes see the patch below.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..1aedddd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3897,6 +3897,8 @@ static int pageblock_is_reserved(unsigned long start_pfn, unsigned long end_pfn)
 	return 0;
 }
 
+#define MAX_MIGRATE_RESERVE_BLOCKS 2
+
 /*
  * Mark a number of pageblocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on min_wmark_pages(zone). The memory within
@@ -3910,6 +3912,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	struct page *page;
 	unsigned long block_migratetype;
 	int reserve;
+	int found = 0;
 
 	/*
 	 * Get the start pfn, end pfn and the number of blocks to reserve
@@ -3926,11 +3929,11 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	/*
 	 * Reserve blocks are generally in place to help high-order atomic
 	 * allocations that are short-lived. A min_free_kbytes value that
-	 * would result in more than 2 reserve blocks for atomic allocations
-	 * is assumed to be in place to help anti-fragmentation for the
-	 * future allocation of hugepages at runtime.
+	 * would result in more than MAX_MIGRATE_RESERVE_BLOCKS reserve blocks
+	 * for atomic allocations is assumed to be in place to help
+	 * anti-fragmentation for the future allocation of hugepages at runtime.
 	 */
-	reserve = min(2, reserve);
+	reserve = min(MAX_MIGRATE_RESERVE_BLOCKS, reserve);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		if (!pfn_valid(pfn))
@@ -3956,6 +3959,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 			/* If this block is reserved, account for it */
 			if (block_migratetype == MIGRATE_RESERVE) {
 				reserve--;
+				found++;
 				continue;
 			}
 
@@ -3970,6 +3974,10 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 			}
 		}
 
+		/* If all possible reserve blocks have been found, we're done */
+		if (found >= MAX_MIGRATE_RESERVE_BLOCKS)
+			break;
+
 		/*
 		 * If the reserve is met and this is a previous reserved block,
 		 * take it back

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
