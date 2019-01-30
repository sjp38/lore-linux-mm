Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B651EC282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61A9D21852
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:15:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61A9D21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84428E0004; Wed, 30 Jan 2019 00:15:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E326A8E0001; Wed, 30 Jan 2019 00:15:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFA548E0004; Wed, 30 Jan 2019 00:15:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF338E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:15:00 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so15483785pgv.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:15:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=37sBbNeKgE01RWEfL+aHhrFRvdKPH9eZaD5xTRI3C+U=;
        b=NzamSXyOUleUyata7rd0ObcKmlUKYierMAfFkY1B+xbdqeXn5mV1lelISvAIwEOvN8
         +eJ/a/fWk3CqxRHI1D95TbWd0SbitnV151yXBSbCXDfSb9s8K040E9OTXTt2qzubW4Qv
         ULP9zS41HxcKUsumnCvnTSgbnH3mX/6i+4kai4fRKHnWe/FW/AZpiWzgQSmlNtke9Q1R
         ZGCY4o8AVJWSshP48UH1J3THCtVtMlBUc5Ya/r34kngWulOq13xR251ZqogtQUeDK54w
         E5vcxkiZb2JMD5ta95LwdxQ6TfZWiCMf9f3ZHdzGAXPg59703OWBXDCBwPeqLy+IOL2a
         uxNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukd//eYSMs7Ya0fEFSucjwKZcwI1h6hbLj69Eo7o78/8bUtZLZw/
	TYSILYLS4pJm4QP4VoSylj2ydXeGuUDpqJ1kQ2VrM0fS4Am9Drme1Zogbe6m/xynN0kYOXTJozl
	pxRm5yuVnoaLlaYj2tgBh9Ub02vHoH3+f6kiPqRFUhCf3SgYYQaWXXVa/npcVVMMofQ==
X-Received: by 2002:a63:2849:: with SMTP id o70mr19492565pgo.155.1548825300148;
        Tue, 29 Jan 2019 21:15:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7e/rcpnCMKpcCljD06KoCMAYzEcGmypwsnWJnaY0AkzlXBprpye2QV7M5ZTRnULBDBUSK/
X-Received: by 2002:a63:2849:: with SMTP id o70mr19492536pgo.155.1548825299078;
        Tue, 29 Jan 2019 21:14:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548825299; cv=none;
        d=google.com; s=arc-20160816;
        b=hrXehOm/M0kJd65vKT7EXnfrDJZjT8O4mNogeqR2oxQp15AgT5U2lrEa7ow6P5u9WG
         GQTkv3d3pUYl3K0z0dEqdC1UUvqnMHnQLsxAvUO9JCYS1o7ys12ct3cf7J/6zV8DfLOc
         bNaG2XeabYEyCBt4Dxvou2Pk/JK2/qfEf+1Fqb5OTF3ot/KWZIDLBg5JrUcLmncv0Red
         szU9t8EHdAPoUUsGhS1N7sjjYPkCR4nTIRgmaCNdi+2BLWi+BolTkkglZdbJfMlTkbzl
         PAOxeeDlV2tT1Q5W0BGyYPHJ86TRhzvrBcHnA5jK8nA929b6/6Fboh0MfWVexjaBQFLY
         rXlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=37sBbNeKgE01RWEfL+aHhrFRvdKPH9eZaD5xTRI3C+U=;
        b=xE/lUx5RvDGW9XZSs2kr3ljwRxsbFM0bhUhfUtDZon++UYm/Vi0V68/ITOPFvEpPL/
         AQCsi31cp19YHMIRVSJ6tA4+YvmrTJB4GqKNTOCirBAoiDHKRejrYihcu7hsZvtryJPw
         lnBbWaBtwW/NqWjylKAvJmucfv4VoEUPeRx42eup6I5Qe2+gfU31Ujqjymq1rhab64wF
         aizftUgQGDsa3Om5p5VHpX2/CGzsb8FwW5RStdxEfrvwo26OjmbbBsrJ7HlbNGOd5DAN
         WxghZwwbLmom8DWiRTnT4oL7/9TAF0IfoP2cZ9Xpg1hJnGAwKLwnQUWg/HV5ntApsRPb
         9dAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d38si540860pla.207.2019.01.29.21.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 21:14:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 21:14:58 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,539,1539673200"; 
   d="scan'208";a="112201726"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga006.jf.intel.com with ESMTP; 29 Jan 2019 21:14:58 -0800
Subject: [PATCH v9 2/3] mm: Move buddy list manipulations into helpers
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 29 Jan 2019 21:02:21 -0800
Message-ID: <154882454117.1338686.7584499675051923214.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index 374e9d483382..6ab8b58c6481 100644
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
index 6208ff744b07..1cb9a467e451 100644
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

