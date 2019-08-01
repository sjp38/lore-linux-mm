Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F238C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 058082080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZBtpkVwz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 058082080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A95A56B0005; Thu,  1 Aug 2019 18:33:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A46616B0006; Thu,  1 Aug 2019 18:33:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E5846B0008; Thu,  1 Aug 2019 18:33:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5295A6B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:33:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so46717890pfn.19
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:33:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/ALyy5tBTJRj9deFR87ZUlllw72TrmFyWSdgPjQp4rM=;
        b=gP77cFwZwgEJiLiLsTACInlhki9HOfLLlCSnpwJ9AsqwUTwetbOhv/EPa1HiSpkc/W
         mi/3+wrimjKAgVNVDXp5TaINKreo0I6l7oJwZvqEwL+CE/YQ0bjeHJ6PKa5YEzSz7Ahv
         66BemmAUBDsjKPLHsFjnS0YLK7MTe6/4pAv54+8NBfvrkruKuF8IveZbYIFL0PL1Md9G
         ceX2ulJigby343ZeKLckdpkNexU3aeWZi8Plb7mDncd2tUZD0hLA3crFweZ+PgrwRoKq
         RFTAxWnu57PBzVArzKZ5hkqjyu/dhrxZEJSpj3/aDZ60xqtDD6pH1Uf1Vq9lmtA9HGJK
         Zz6Q==
X-Gm-Message-State: APjAAAVl14CH+9PnGLd9clDWtJdqz4eKf9k2Ie2JiIGRndsEJhOb18aZ
	RbFAblycXmU4MQOupGjT+g1VgZp0zqzjrpeVkLDLRY8kngrhxevj1Nqat8qo7jwnz+A8MPY6cNr
	b4r1QnjDWa5C+Dw8GtEzyy0TvlBc5rTlob5wAo5/0EpoFuhRsahqNp8Bs9MK3qTCuUg==
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr1063425pjn.136.1564698835899;
        Thu, 01 Aug 2019 15:33:55 -0700 (PDT)
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr1063377pjn.136.1564698834846;
        Thu, 01 Aug 2019 15:33:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564698834; cv=none;
        d=google.com; s=arc-20160816;
        b=gZZ7V1r2gDNAX4OlTDd4Q6oWB504tgQBlHPqEfOxa/9U0Im9qPqHdtrV1cjY9kodfE
         zxnJRryhYSwucODfkAUj+sKKpIsPL40o4nh0+FHlqXWq1oXHsRVJarQSsLS/bNeqsfAm
         JAyjwFasT+eFZDNzS7yN0/jF1LGfPLhrm+2BlgyA3Fk82t/02zcBBcmN2iHxMLBGKCjx
         T6oKsJjcFWRG+90leuXxRjpdTk0/+JFOYv3+df19v1AO7u9yr0rtb/4YmmG4O4/tMSgm
         JHqnbqsFANZVt89cwgkAC7jsGjDonNv2N+a/48GoRwQLdgIZ3MUuLuRm5e7vOO3hqKIA
         O7eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=/ALyy5tBTJRj9deFR87ZUlllw72TrmFyWSdgPjQp4rM=;
        b=Op+I7yvrpWRQNI6UpSdjsoSwxWZ3eSEpGp2X9Jay83EkEsD6gvWu9cAirXY9NTTfWU
         IvRQUR/WrtlsDGj8cXNN0cW7YHiFWZVWSZ2Ri6wjv1yJNN+LR8oBDIQIiS91OYYChVk7
         NHftV9ZRxVunbRWydstsLXIW5JDcptO1Z0sj++kM2UCAp0b3h0TXgUKh09tE8rRZrIfb
         7RpxJpuMkk4K3/DEepZgJUYhB0gJ5j5ScSgudDa4MqQ2Hu7+F3XqwUR59CrW7lC8E/TG
         6Bk5AfEh+XprhlnYKPgqB38yXFv8gDCqxDFhcWBCFrpp6OqTpv/TdNsgvp3FY2RlbrJO
         CATw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZBtpkVwz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor86864556pll.35.2019.08.01.15.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:33:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZBtpkVwz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/ALyy5tBTJRj9deFR87ZUlllw72TrmFyWSdgPjQp4rM=;
        b=ZBtpkVwzOe4eyGoq9QPqUpxtiZRKtqzBH/tyBWE8UnrimostlvcQjvVc/SXZMgbk9N
         DYil48OxFec1bR3QcSym0HQF290WYdsxjQrKwJXFI7LkKkgljotO2z7gnhVmFcGw0q4W
         RkcNEAOwyFAHZFD2x0fSSd5S048yDyryAyMpI/Tkf82RXjFdu4NHYfhK7lJPOOO83o7j
         YgGxggzrRW1L//7xkten1pa/cAZ29ibGzFALKw6Oy5gBAU72fwwEJdrje9WIssnpI1qz
         e4z+iprUrsN+jdd8nQcP0RVuSU6/DGQvYlI3GBZ7Ry9TuIc6mQiJjm2BhRjHgZrkPKPj
         GB7w==
X-Google-Smtp-Source: APXvYqxlI/m+J1Vb1i+6OdKITlgM+lspjQ95MM8yt+CwgY55W8rjUhUi5OBsWSgJiUOC8m2kY4ICJA==
X-Received: by 2002:a17:902:2ae7:: with SMTP id j94mr128150310plb.270.1564698834276;
        Thu, 01 Aug 2019 15:33:54 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id x25sm104397434pfa.90.2019.08.01.15.33.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:33:53 -0700 (PDT)
Subject: [PATCH v3 3/6] mm: Use zone and order instead of free area in
 free_list manipulators
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:31:44 -0700
Message-ID: <20190801223144.22190.30566.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
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
index 738e9c758135..f0c68b6b6154 100644
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
@@ -787,6 +755,44 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
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
index 7cedc73953fd..71aadc7d5ff6 100644
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
@@ -8560,7 +8552,7 @@ void zone_pcp_reset(struct zone *zone)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		del_page_from_free_area(page, &zone->free_area[order]);
+		del_page_from_free_list(page, zone, order);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);

