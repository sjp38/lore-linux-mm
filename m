Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 389DFC4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB44F20863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:28:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB44F20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB498E0004; Fri,  1 Feb 2019 00:28:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67ACD8E0001; Fri,  1 Feb 2019 00:28:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 591918E0004; Fri,  1 Feb 2019 00:28:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17E1A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:28:02 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so3862772pgj.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:28:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ek6GtjcmVUDWbKs+WnJ5MRWRCQt54S5YJhX4TC0I7Dc=;
        b=VuDJUR7t/X+Z2SqCAXiDOnMc+FSVcSge63EJ+1ZvV8gtO4h8muNKeXIHOx5Dm16RIW
         omlTHr45n90Qpobxu+njVKNm4utZ5oH/zzoMHHUXw+7ua7Bd0RkvS0foQxktbn08JdIG
         /t4UI5olWNbitRPReNbMLQHbi9IhC0KoI3pxxxnbaenSR9X5jMlPojXT6UYxg2mhqVf9
         LZm7smtBgNHmwzjuy0SChoXU6ZX+CPb4x57g5Q8yL0TGmWe94EDC7EW+VzQPQolE3GEt
         jBJmkkyfVoX/AozlVZrdByoYiYyfWlgmJIoIso9B2ySUf2JEsS7khgZ4QO9tEDOAMaFL
         8Lsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaeBSQ3+Z/zl0M/XxFXJoqLPJiO1KILko91Eh9KEtxl9ZWrtWgw
	dEiP6DLrtM6ZHyVHX+XCzbMgLtxZ+QSbRC0LHYgPMpHNjBDsoMEaQsNnzTXuELqqj0wT8DYwYXO
	dVpe/7SBuyR+/w8vQInToTPwUEJtMe0oHvXqf1CpaW4mLjQhThkczHKNgRRQxNMKtTw==
X-Received: by 2002:a62:8a57:: with SMTP id y84mr6877306pfd.197.1548998881719;
        Thu, 31 Jan 2019 21:28:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCuBUjuYoNiFgx/NfS01B0/gLvmSzB86BuA53U8VlvdyTQnfEs3+WNavBadX0uxy7PbWon
X-Received: by 2002:a62:8a57:: with SMTP id y84mr6877268pfd.197.1548998880628;
        Thu, 31 Jan 2019 21:28:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998880; cv=none;
        d=google.com; s=arc-20160816;
        b=kpMk4T4RSnsaa/PhD13sXOqFb8W/is8rACmAE4vAfbFuZ+jePhGs9IFNIewkUuDtT4
         Jx9GhwQEQcpEa3UuUsRY/DlYw+kjt15Pkaf7Lo0wiACjX7/ET7FCAChK7Sk+xPljRJQi
         RYkMLfTgfwOdbe43+g7DevzjLQgu5tbDpC33YtuKfN5im5jtFdsCv9mOIRy7fxSzDndX
         HnYVdWVH0egL04WsxxeoPjOCfBbUEFgy8KOWrEUMFzB7gl2H6jFBJ2h6v7Op8B2TsJgv
         4L8/U6Ws7sgkYOwanfsJvWhTeRzOma92TeORFzmmExElKSUpoPX2Js9ysudZYeOzoCF7
         Q7OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ek6GtjcmVUDWbKs+WnJ5MRWRCQt54S5YJhX4TC0I7Dc=;
        b=uhUMdZ+sJJQznr3Bj1MoMDa+tPzefvYC+j5n/Cl0n3kkBLmP1vaVys/QA8y74lxRHR
         BHuUiPMN4qX1lTDBlB/DHKNKFMPpHclH8XRZj8sZh8ODcxzloyFCDo8yqEn/vTCkJahp
         C2i6YLS4RuV7PWmlrA4hHxhK4zBn5N+/dPQQBbnxRRWZnUSA/n8HDku+ve+zCBMIxeUP
         Vmaaa7PsUxdMIW8pgktAW0BaQJFKnMBno2fezO+n7G1/U5p5wF+e9pCUVmX8M+YwDNzK
         INSzwOHa6eu2ZjjcvY3byjwT7XnTWDtKb6nHJ5LkTMD7r5aAKW02TwXZlckhVByAprT4
         FkPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i18si1986542pgl.414.2019.01.31.21.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 21:28:00 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jan 2019 21:28:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,547,1539673200"; 
   d="scan'208";a="112832716"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga006.jf.intel.com with ESMTP; 31 Jan 2019 21:28:00 -0800
Subject: [PATCH v10 2/3] mm: Move buddy list manipulations into helpers
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, keith.busch@intel.com
Date: Thu, 31 Jan 2019 21:15:22 -0800
Message-ID: <154899812264.3165233.5219320056406926223.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for runtime randomization of the zone lists, take all
(well, most of) the list_*() functions in the buddy allocator and put
them in helper functions. Provide a common control point for injecting
additional behavior when freeing pages.

Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h       |    3 --
 include/linux/mm_types.h |    3 ++
 include/linux/mmzone.h   |   46 ++++++++++++++++++++++++++++++
 mm/compaction.c          |    4 +--
 mm/page_alloc.c          |   70 ++++++++++++++++++----------------------------
 5 files changed, 79 insertions(+), 47 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..1621acd10f83 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -500,9 +500,6 @@ static inline void vma_set_anonymous(struct vm_area_struct *vma)
 struct mmu_gather;
 struct inode;
 
-#define page_private(page)		((page)->private)
-#define set_page_private(page, v)	((page)->private = (v))
-
 #if !defined(__HAVE_ARCH_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline int pmd_devmap(pmd_t pmd)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..1c7dc7ffa288 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -214,6 +214,9 @@ struct page {
 #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
 #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
 
+#define page_private(page)		((page)->private)
+#define set_page_private(page, v)	((page)->private = (v))
+
 struct page_frag_cache {
 	void * va;
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c151c87a728a..2274e43933ae 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -18,6 +18,8 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -98,6 +100,50 @@ struct free_area {
 	unsigned long		nr_free;
 };
 
+/* Used for pages not on another list */
+static inline void add_to_free_area(struct page *page, struct free_area *area,
+			     int migratetype)
+{
+	list_add(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages not on another list */
+static inline void add_to_free_area_tail(struct page *page, struct free_area *area,
+				  int migratetype)
+{
+	list_add_tail(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages which are on another list */
+static inline void move_to_free_area(struct page *page, struct free_area *area,
+			     int migratetype)
+{
+	list_move(&page->lru, &area->free_list[migratetype]);
+}
+
+static inline struct page *get_page_from_free_area(struct free_area *area,
+					    int migratetype)
+{
+	return list_first_entry_or_null(&area->free_list[migratetype],
+					struct page, lru);
+}
+
+static inline void del_page_from_free_area(struct page *page,
+		struct free_area *area, int migratetype)
+{
+	list_del(&page->lru);
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+	area->nr_free--;
+}
+
+static inline bool free_area_empty(struct free_area *area, int migratetype)
+{
+	return list_empty(&area->free_list[migratetype]);
+}
+
 struct pglist_data;
 
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index ef29490b0f46..a22ac7ab65c5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1359,13 +1359,13 @@ static enum compact_result __compact_finished(struct zone *zone,
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (!free_area_empty(area, migratetype))
 			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+			!free_area_empty(area, MIGRATE_CMA))
 			return COMPACT_SUCCESS;
 #endif
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 14ef39445544..3fd0df403766 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -743,12 +743,6 @@ static inline void set_page_order(struct page *page, unsigned int order)
 	__SetPageBuddy(page);
 }
 
-static inline void rmv_page_order(struct page *page)
-{
-	__ClearPageBuddy(page);
-	set_page_private(page, 0);
-}
-
 /*
  * This function checks whether a page is free && is the buddy
  * we can coalesce a page and its buddy if
@@ -849,13 +843,11 @@ static inline void __free_one_page(struct page *page,
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
 		 */
-		if (page_is_guard(buddy)) {
+		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
-		} else {
-			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
-			rmv_page_order(buddy);
-		}
+		else
+			del_page_from_free_area(buddy, &zone->free_area[order],
+					migratetype);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -905,15 +897,13 @@ static inline void __free_one_page(struct page *page,
 		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (pfn_valid_within(buddy_pfn) &&
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
-			goto out;
+			add_to_free_area_tail(page, &zone->free_area[order],
+					      migratetype);
+			return;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
-out:
-	zone->free_area[order].nr_free++;
+	add_to_free_area(page, &zone->free_area[order], migratetype);
 }
 
 /*
@@ -1853,7 +1843,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		add_to_free_area(&page[size], area, migratetype);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1995,13 +1985,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
-		page = list_first_entry_or_null(&area->free_list[migratetype],
-							struct page, lru);
+		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
-		list_del(&page->lru);
-		rmv_page_order(page);
-		area->nr_free--;
+		del_page_from_free_area(page, area, migratetype);
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -2087,8 +2074,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+		move_to_free_area(page, &zone->free_area[order], migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2264,7 +2250,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	move_to_free_area(page, area, start_type);
 }
 
 /*
@@ -2288,7 +2274,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (free_area_empty(area, fallback_mt))
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2375,9 +2361,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
-			page = list_first_entry_or_null(
-					&area->free_list[MIGRATE_HIGHATOMIC],
-					struct page, lru);
+			page = get_page_from_free_area(area, MIGRATE_HIGHATOMIC);
 			if (!page)
 				continue;
 
@@ -2500,8 +2484,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
 	VM_BUG_ON(current_order == MAX_ORDER);
 
 do_steal:
-	page = list_first_entry(&area->free_list[fallback_mt],
-							struct page, lru);
+	page = get_page_from_free_area(area, fallback_mt);
 
 	steal_suitable_fallback(zone, page, alloc_flags, start_migratetype,
 								can_steal);
@@ -2938,6 +2921,7 @@ EXPORT_SYMBOL_GPL(split_page);
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
+	struct free_area *area = &page_zone(page)->free_area[order];
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
@@ -2962,9 +2946,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
-	rmv_page_order(page);
+
+	del_page_from_free_area(page, area, mt);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -3266,13 +3249,13 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			continue;
 
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
-			if (!list_empty(&area->free_list[mt]))
+			if (!free_area_empty(area, mt))
 				return true;
 		}
 
 #ifdef CONFIG_CMA
 		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		    !free_area_empty(area, MIGRATE_CMA)) {
 			return true;
 		}
 #endif
@@ -5174,7 +5157,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!free_area_empty(area, type))
 					types[order] |= 1 << type;
 			}
 		}
@@ -8319,6 +8302,9 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
+		struct free_area *area;
+		int mt;
+
 		if (!pfn_valid(pfn)) {
 			pfn++;
 			continue;
@@ -8337,13 +8323,13 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
+		area = &zone->free_area[order];
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
-		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
+		mt = get_pageblock_migratetype(page);
+		del_page_from_free_area(page, area, mt);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);

