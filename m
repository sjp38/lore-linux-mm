Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FE41C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:42:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39AEA21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:42:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g6hBF2r7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39AEA21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F8056B0008; Wed,  7 Aug 2019 18:42:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A8636B000A; Wed,  7 Aug 2019 18:42:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3C586B000C; Wed,  7 Aug 2019 18:42:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A93946B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:42:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so57708209pff.8
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:42:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=poWy5H00eMbbkhDbizAoNp/mHsmKg4j5qADSq+zADLA=;
        b=mo0xu3n82nglhY+PmLZ3YbdycC1mr/vIzCFYpzKK4jYExQQwNXbh8LlH7lcUzImwXo
         ejk9y9lPUId7B020Qj/Qu4cBgMu6JoqKACndoDyVyhtAoYZtL9OtSw/VcvHtVKTvStkL
         bTOVNSRjjRfxO7xFT3yBbA3hVfhUJO9NGO0Om8Jxb5Nrx6w04xrYMmcknoBPg0KdgD/4
         Hal5Q+Bq6BoOf/PwtJnX28NyZLweDuaOmESayR8NwkFjK5GOwNK4tmHemC2poJZHC92K
         CrLwJQe1AIUjvm5qVueRi+RgrfClcapXZ1X+rV2NIwUX1QQ3DEWtI8UwoCk/QaR25fHL
         KeLA==
X-Gm-Message-State: APjAAAUup8U3OYtnAKWIlnapK/1ixNo4VbbgWwtyIWwnFxhMbpNbZcMf
	zJXIg1zZN5+xY8uuBxj82al/Obkxl+AKAxqLT93XhaR/Au84Mz4fmZnIOBTLTqcR0ksTbcLOfGv
	/WFOgKVyg6hDnjV89XaPhvG7rgNrKbj15wECnCCZySWC2Vh7bQp7B39UAm/iv/uBq/A==
X-Received: by 2002:a65:64cf:: with SMTP id t15mr9503713pgv.88.1565217723283;
        Wed, 07 Aug 2019 15:42:03 -0700 (PDT)
X-Received: by 2002:a65:64cf:: with SMTP id t15mr9503659pgv.88.1565217722228;
        Wed, 07 Aug 2019 15:42:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217722; cv=none;
        d=google.com; s=arc-20160816;
        b=ZWSn5/kqJ31lKVNeqMqtqArXbdhJPkYaURYa4Ba+/eNdsZL3cqzwUyS6zePTBgxgFW
         hrgnsNdWSZluOFPfYRcxoGsLQO5KouvZhCnORSJc8/Ng15NWMBUjFwV7Z/qLbf0OwN7+
         aK9h/FzwOWJDTGWJh74JsexzutB6x/i6KGk+esFQmXkGrlA+e6pgydzNsbQf8tVnQWFB
         nZiRs5I+tbqN5A25Lvh9pLauoigyohmDogClTwptPwRSfcpq3x2yI4z7s728z+I/vSsT
         EyVhBuKorRyG9E6FkO8m2JSm2lxymdtPRJlUWX+u258WJdNMOOzK6w4vuxO7pbtPf7Ve
         FzuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=poWy5H00eMbbkhDbizAoNp/mHsmKg4j5qADSq+zADLA=;
        b=iWBLBkPYVpf5eFqcThCzVdiHj+tLgmXTw/Pg9FPUT0RzhFsRiJQ0fZ+ImPa/kMjytf
         LRZ2r2u7EbfH2CCnCpjYHtPe+QWv06G+gZCbV9TMhazNSI4pPjUPJEd3QJHs8x3Y+5BU
         jhjNirwDtg73EoZJ2jOO3U94OxO5JAVei5R4ISTM9YSpSPk6Fhv24pCHTzHrhDNY7ofq
         DW1LlK6/XGEVUEIVRnPiJiehu/xUrUc1wld3T1V3hRfxKCm8OtnfxPpKdYZKr/7zS7Z4
         sO91Lu5V6Gm3cI1wbWdyMsgfFndEcY0lTGsvnq1fqxYnETPpjx6JZHlyqfq+cRFN+6xt
         Is2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g6hBF2r7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63sor520608pjb.6.2019.08.07.15.42.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:42:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=g6hBF2r7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=poWy5H00eMbbkhDbizAoNp/mHsmKg4j5qADSq+zADLA=;
        b=g6hBF2r7WDPHrgJhy1vmfJ9sEalu/lSmYgmQ7s3RlTRFadjUuZSww8JvgzL+ULhoNk
         p9DHTuPoVndY8HxqUsRV9hKFUsXqXIx+BOPo07E7hpw85yFttrHzVr7hTJoXVPdo8Ipz
         2I0WQI1bA26dcfLA7v5a45wDwnGiEO6FPre8VYY/rdKcD5OVXugi2yVZJPuz+foJ4TTu
         gCKAro4LzGV1ahasd3xiiG8kxY3KlmGGwcO3gb8I6Sb1IWXy14uIdxQmvGP+30iK4CWP
         zTYkTTEzIiPBD56QjlCipO/lolXia5FPWWvstXbrmT3DKS2eJ1Q5Vidt3Sn+yL9pOOtr
         BWKQ==
X-Google-Smtp-Source: APXvYqybauW2gI30Xi6XqcAdulH2GVOgYW3VwFTSqW0neJAGQv4mWsFCIkkDEXI5yU/IpmqLkkiYkA==
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr725275pji.136.1565217721744;
        Wed, 07 Aug 2019 15:42:01 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id o95sm242201pjb.4.2019.08.07.15.42.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:42:01 -0700 (PDT)
Subject: [PATCH v4 3/6] mm: Use zone and order instead of free area in
 free_list manipulators
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:42:00 -0700
Message-ID: <20190807224200.6891.69731.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

In order to enable the use of the zone from the list manipulator functions
I will need access to the zone pointer. As it turns out most of the
accessors were always just being directly passed &zone->free_area[order]
anyway so it would make sense to just fold that into the function itself
and pass the zone and order as arguments instead of the free area.

In order to be able to reference the zone we need to move the declaration
of the functions down so that we have the zone defined before we define the
list manipulation functions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   70 ++++++++++++++++++++++++++----------------------
 mm/page_alloc.c        |   30 ++++++++-------------
 2 files changed, 49 insertions(+), 51 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c6bd8e9bb476..2f2b6f968ed3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -100,29 +100,6 @@ struct free_area {
 	unsigned long		nr_free;
 };
 
-/* Used for pages not on another list */
-static inline void add_to_free_area(struct page *page, struct free_area *area,
-			     int migratetype)
-{
-	list_add(&page->lru, &area->free_list[migratetype]);
-	area->nr_free++;
-}
-
-/* Used for pages not on another list */
-static inline void add_to_free_area_tail(struct page *page, struct free_area *area,
-				  int migratetype)
-{
-	list_add_tail(&page->lru, &area->free_list[migratetype]);
-	area->nr_free++;
-}
-
-/* Used for pages which are on another list */
-static inline void move_to_free_area(struct page *page, struct free_area *area,
-			     int migratetype)
-{
-	list_move(&page->lru, &area->free_list[migratetype]);
-}
-
 static inline struct page *get_page_from_free_area(struct free_area *area,
 					    int migratetype)
 {
@@ -130,15 +107,6 @@ static inline struct page *get_page_from_free_area(struct free_area *area,
 					struct page, lru);
 }
 
-static inline void del_page_from_free_area(struct page *page,
-		struct free_area *area)
-{
-	list_del(&page->lru);
-	__ClearPageBuddy(page);
-	set_page_private(page, 0);
-	area->nr_free--;
-}
-
 static inline bool free_area_empty(struct free_area *area, int migratetype)
 {
 	return list_empty(&area->free_list[migratetype]);
@@ -789,6 +757,44 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
 }
 
+/* Used for pages not on another list */
+static inline void add_to_free_list(struct page *page, struct zone *zone,
+				    unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_add(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages not on another list */
+static inline void add_to_free_list_tail(struct page *page, struct zone *zone,
+					 unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_add_tail(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages which are on another list */
+static inline void move_to_free_list(struct page *page, struct zone *zone,
+				     unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_move(&page->lru, &area->free_list[migratetype]);
+}
+
+static inline void del_page_from_free_list(struct page *page, struct zone *zone,
+					   unsigned int order)
+{
+	list_del(&page->lru);
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+	zone->free_area[order].nr_free--;
+}
+
 #include <linux/memory_hotplug.h>
 
 void build_all_zonelists(pg_data_t *pgdat);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f04192f5ec3c..4b5812c3800e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -920,7 +920,6 @@ static inline void __free_one_page(struct page *page,
 	struct capture_control *capc = task_capc(zone);
 	unsigned long uninitialized_var(buddy_pfn);
 	unsigned long combined_pfn;
-	struct free_area *area;
 	unsigned int max_order;
 	struct page *buddy;
 
@@ -957,7 +956,7 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
 		else
-			del_page_from_free_area(buddy, &zone->free_area[order]);
+			del_page_from_free_list(buddy, zone, order);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -991,12 +990,11 @@ static inline void __free_one_page(struct page *page,
 done_merging:
 	set_page_order(page, order);
 
-	area = &zone->free_area[order];
 	if (is_shuffle_order(order) ? shuffle_add_to_tail() :
 	    buddy_merge_likely(pfn, buddy_pfn, page, order))
-		add_to_free_area_tail(page, area, migratetype);
+		add_to_free_list_tail(page, zone, order, migratetype);
 	else
-		add_to_free_area(page, area, migratetype);
+		add_to_free_list(page, zone, order, migratetype);
 }
 
 /*
@@ -2000,13 +1998,11 @@ void __init init_cma_reserved_pageblock(struct page *page)
  * -- nyc
  */
 static inline void expand(struct zone *zone, struct page *page,
-	int low, int high, struct free_area *area,
-	int migratetype)
+	int low, int high, int migratetype)
 {
 	unsigned long size = 1 << high;
 
 	while (high > low) {
-		area--;
 		high--;
 		size >>= 1;
 		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
@@ -2020,7 +2016,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		add_to_free_area(&page[size], area, migratetype);
+		add_to_free_list(&page[size], zone, high, migratetype);
 		set_page_order(&page[size], high);
 	}
 }
@@ -2178,8 +2174,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
-		del_page_from_free_area(page, area);
-		expand(zone, page, order, current_order, area, migratetype);
+		del_page_from_free_list(page, zone, current_order);
+		expand(zone, page, order, current_order, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
 	}
@@ -2187,7 +2183,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
-
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -2264,7 +2259,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		move_to_free_area(page, &zone->free_area[order], migratetype);
+		move_to_free_list(page, zone, order, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2380,7 +2375,6 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		unsigned int alloc_flags, int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
-	struct free_area *area;
 	int free_pages, movable_pages, alike_pages;
 	int old_block_type;
 
@@ -2451,8 +2445,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	return;
 
 single_page:
-	area = &zone->free_area[current_order];
-	move_to_free_area(page, area, start_type);
+	move_to_free_list(page, zone, current_order, start_type);
 }
 
 /*
@@ -3123,7 +3116,6 @@ void split_page(struct page *page, unsigned int order)
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
-	struct free_area *area = &page_zone(page)->free_area[order];
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
@@ -3149,7 +3141,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	/* Remove page from free list */
 
-	del_page_from_free_area(page, area);
+	del_page_from_free_list(page, zone, order);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -8568,7 +8560,7 @@ void zone_pcp_reset(struct zone *zone)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		del_page_from_free_area(page, &zone->free_area[order]);
+		del_page_from_free_list(page, zone, order);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);

