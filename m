Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5469FC43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC657215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Eoulzf7P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC657215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 909B46B0007; Wed, 19 Jun 2019 18:33:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BA468E0002; Wed, 19 Jun 2019 18:33:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A9E18E0001; Wed, 19 Jun 2019 18:33:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF0F6B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:33:20 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n8so1443664ioo.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:33:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=C0Bf7M/8cNMTOD5Oi+UUTlzGK+ofWvIbu+KdmI1IyVU=;
        b=N+uTlglIlY2LxPbSHLyEcyWDEO3HQHZpsHIAq6kn+/X9uf+VI7wTe9G0htX0ByvrJw
         VOZTFa/T5QbIC2vU94KXsYBxp7e7etZhHFobMExUU+DtrHb3urzq8abRickdBITbprF4
         0Zj7j88EPlxDzstS/+hiB6dKazH7o1d3w0tiy8NIwIi3U7bCviWhuxRGpJigQcu4U4al
         WthuL64LF0CCAwOv92m5Q9Ra830lzMvR9b3jB9iYh+OCwqJVkZFIUK6TJ0ef+PsQz+a2
         J56vbDNMZYsyfIjdPoHaXs/autLc6lUuGTgW5/aUEvpaJ5ap2w5+nYatAGHqef9ESI8y
         ZvtQ==
X-Gm-Message-State: APjAAAUUfUUWW99UJ33iLmDRZKuIbiqoQp9833RxB61BpjYapHgN2L0I
	1EsuaT7kDThlpTttcP/mFe7rkaLjKzHAAcCqe6luuJRdsFVMShA94UNQ1QzaRoSJskXws2LgC0Z
	MsaFIFjpsTUFYwG8tOp8vPcEA/jRLjtWd/Ut08VQymkGP4XrLjxJTtDj/8E/M9/tB8A==
X-Received: by 2002:a02:ad17:: with SMTP id s23mr2776145jan.137.1560983600085;
        Wed, 19 Jun 2019 15:33:20 -0700 (PDT)
X-Received: by 2002:a02:ad17:: with SMTP id s23mr2776066jan.137.1560983599150;
        Wed, 19 Jun 2019 15:33:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560983599; cv=none;
        d=google.com; s=arc-20160816;
        b=pU0TaeBiIUAKxGNPNxawVEIlNB26M1AZrl2QX+Q1eVofXOVhCG4/zsHPhydsFCCpTF
         LiSnPXnQYJjrpccSl4qTif1zG1G9R1OsbWqX+puEdOt2DKQpR5B5HCr3COnbcFAP89X8
         rQ90HZj4sZA3DZfnLjpZugnYht4Y5SCl2oogH3VajEajlrCMn4jK9zFA3umzs35ICc7k
         tzVddY+/ESZZh2yr56wyvdUj/RB5TPwHpKrfHJjWKOTgCLkJWVo0dktvCb8Uksnim7Za
         +G7PmTvM6OslQ1tkI6Ouwxju89GG3mI+HfYrJfyh4KFIHioaWqD94WJD6lPDJy9kwum2
         wKjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=C0Bf7M/8cNMTOD5Oi+UUTlzGK+ofWvIbu+KdmI1IyVU=;
        b=NBucBAyRU6X3Zm9hyAK7htdAxJAoKCZlbjBIkjki3/3/e8du9N5kxluq3NIRByo/8r
         RicLy0Y0Da2JT79a/OmgSdrzgmUONXVRtP9VFTltdHg9wzpPaSf3Sa2h/BBBJMz6LFLN
         PZa4L/FPXG+8xzcjH/ObdGEyjgy/37cvLJLs7Khb9mY15XBdrktSkG76h2xlCyDIWthF
         NC1UHoJs/aUdoStIyYwvjRqN5UV7pXa7a1qNFLioDIAi3hoT4XUmA0hoHon627/rcNxC
         MtsP0Jwi6H9OYV64kA1/7JC4edql60rMi6XuxLvGCpt2pyyn1kYcudAFLOAwn3F4nkD0
         gCqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Eoulzf7P;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor15410578iof.129.2019.06.19.15.33.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 15:33:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Eoulzf7P;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=C0Bf7M/8cNMTOD5Oi+UUTlzGK+ofWvIbu+KdmI1IyVU=;
        b=Eoulzf7P/OMOo6UZcSrsWbKXBQDMcqi3Lt3uX4516MwL+PQ9++SEChgXNQyFiosCTa
         XTg4LkxnkpTckIHJnEJlp1MYaY4Lt9wnn8HkSZOd+pw3HaJjj732wmiSM4cNNILGt3j9
         ob7q+r/GhMWZrGJXnvmKGggYinS7vRlPyrluqnSjmvM0S3oIFGkV/Y8T1hizTV1BXYdb
         VtKWtXd+Vk/aqzxcjxtAP7m9CzCvIbAfYlzjvQWSXcgr9seH89NFUgRwO3gzSV3K4AsT
         pXF8Foro/42GRqNcJN2OP1EPhgLYDRqVardVtEb7/SbHc5T2/log0PBLWrXz8DwOWHRm
         B+fQ==
X-Google-Smtp-Source: APXvYqx79H8ElBelvGscKvVv57A/nzg/ZdF+AMPkeYAHiq1eEfYfdHd9cuqUI0iuasR1vsEvSUjDfQ==
X-Received: by 2002:a5e:820a:: with SMTP id l10mr13256571iom.283.1560983598744;
        Wed, 19 Jun 2019 15:33:18 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id p10sm12684507iob.54.2019.06.19.15.33.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:33:18 -0700 (PDT)
Subject: [PATCH v1 3/6] mm: Use zone and order instead of free area in
 free_list manipulators
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 19 Jun 2019 15:33:16 -0700
Message-ID: <20190619223316.1231.50329.stgit@localhost.localdomain>
In-Reply-To: <20190619222922.1231.27432.stgit@localhost.localdomain>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
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

In addition in order to be able to reference the zone we need to move the
declaration of the functions down so that we have the zone defined before
we define the list manipulation functions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   72 +++++++++++++++++++++++++++---------------------
 mm/page_alloc.c        |   30 +++++++-------------
 2 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6f8fd5c1a286..c3597920a155 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -118,29 +118,6 @@ struct free_area {
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
@@ -148,15 +125,6 @@ static inline struct page *get_page_from_free_area(struct free_area *area,
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
@@ -805,6 +773,46 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
 }
 
+/* Used for pages not on another list */
+static inline void add_to_free_area(struct page *page, struct zone *zone,
+				    unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_add(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages not on another list */
+static inline void add_to_free_area_tail(struct page *page, struct zone *zone,
+					 unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_add_tail(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages which are on another list */
+static inline void move_to_free_area(struct page *page, struct zone *zone,
+				     unsigned int order, int migratetype)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_move(&page->lru, &area->free_list[migratetype]);
+}
+
+static inline void del_page_from_free_area(struct page *page, struct zone *zone,
+					   unsigned int order)
+{
+	struct free_area *area = &zone->free_area[order];
+
+	list_del(&page->lru);
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+	area->nr_free--;
+}
+
 #include <linux/memory_hotplug.h>
 
 void build_all_zonelists(pg_data_t *pgdat);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3e21e01f6165..aad2b2529ab7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -873,7 +873,6 @@ static inline void __free_one_page(struct page *page,
 	struct capture_control *capc = task_capc(zone);
 	unsigned long uninitialized_var(buddy_pfn);
 	unsigned long combined_pfn;
-	struct free_area *area;
 	unsigned int max_order;
 	struct page *buddy;
 
@@ -910,7 +909,7 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
 		else
-			del_page_from_free_area(buddy, &zone->free_area[order]);
+			del_page_from_free_area(buddy, zone, order);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -944,12 +943,11 @@ static inline void __free_one_page(struct page *page,
 done_merging:
 	set_page_order(page, order);
 
-	area = &zone->free_area[order];
 	if (buddy_merge_likely(pfn, buddy_pfn, page, order) ||
 	    is_shuffle_tail_page(order))
-		add_to_free_area_tail(page, area, migratetype);
+		add_to_free_area_tail(page, zone, order, migratetype);
 	else
-		add_to_free_area(page, area, migratetype);
+		add_to_free_area(page, zone, order, migratetype);
 }
 
 /*
@@ -1941,13 +1939,11 @@ void __init init_cma_reserved_pageblock(struct page *page)
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
@@ -1961,7 +1957,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		add_to_free_area(&page[size], area, migratetype);
+		add_to_free_area(&page[size], zone, high, migratetype);
 		set_page_order(&page[size], high);
 	}
 }
@@ -2122,8 +2118,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
-		del_page_from_free_area(page, area);
-		expand(zone, page, order, current_order, area, migratetype);
+		del_page_from_free_area(page, zone, current_order);
+		expand(zone, page, order, current_order, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
 	}
@@ -2131,7 +2127,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
-
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -2208,7 +2203,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		move_to_free_area(page, &zone->free_area[order], migratetype);
+		move_to_free_area(page, zone, order, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2324,7 +2319,6 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		unsigned int alloc_flags, int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
-	struct free_area *area;
 	int free_pages, movable_pages, alike_pages;
 	int old_block_type;
 
@@ -2395,8 +2389,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	return;
 
 single_page:
-	area = &zone->free_area[current_order];
-	move_to_free_area(page, area, start_type);
+	move_to_free_area(page, zone, current_order, start_type);
 }
 
 /*
@@ -3067,7 +3060,6 @@ void split_page(struct page *page, unsigned int order)
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
-	struct free_area *area = &page_zone(page)->free_area[order];
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
@@ -3093,7 +3085,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	/* Remove page from free list */
 
-	del_page_from_free_area(page, area);
+	del_page_from_free_area(page, zone, order);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -8513,7 +8505,7 @@ void zone_pcp_reset(struct zone *zone)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		del_page_from_free_area(page, &zone->free_area[order]);
+		del_page_from_free_area(page, zone, order);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);

