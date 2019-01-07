Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E555EC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 23:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B2FA2070B
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 23:33:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B2FA2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 467398E0044; Mon,  7 Jan 2019 18:33:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 417C68E0038; Mon,  7 Jan 2019 18:33:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3078A8E0044; Mon,  7 Jan 2019 18:33:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDED38E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:33:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so1010581pls.21
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:33:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=dpzq8U6sX6KNGIFiMCzUEnWlDckO99JJu/c2vvDNFTg=;
        b=Fr1a4adAeZqUZTJ8G7F/Jq2FuiDxrp11wzMuosUQgRMAuS0r91SfhxJP16TzdoyG+6
         GNxI8WTSz57rC7V08pAdvqeRjyxTQgLzu28gMajp7AfDkCm0g6Uv55seAaSG9xLyEepF
         cN4ZkxprRX57jfzfGDK6GCalUieVerjKCXZYLFOwlqSikyJ5pR6Tj7NTOVjT5d5mRitD
         8B3uLF6s4IXRmu1s9pic8XZH4ohRkQZAdN5dQCvODCKorEWTA84PNt5GP4imYblqXBLe
         wKocqzHOUJnLntBzCDRUURbN3IKqbwojjZU3mAt/7mSQ274agvbc95Sm/ai8D0NJnCrN
         LLxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcA3qS7IZvnkLhskIFiPoVYCybvLZeu2GR25DnmtLLYwYjqxZLb
	m4uDZqtBTWOa1XdQtcuL1WkbKds4CdhjEqjCTo5XIoMjFAJ8JIZG8oe6iiAdKd7Rf9haVCWn2qX
	EMS6jOc0FTw366527JevWJuZoEFPjPQ8smZg/6vdK5orqhyBrEIjmoLcVa7oQpQnCrQ==
X-Received: by 2002:a17:902:503:: with SMTP id 3mr63795209plf.233.1546904034530;
        Mon, 07 Jan 2019 15:33:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5erzOStyOj0+AG80z7fF9J2Xfpe7LTrzhH0EPbrhmicFztsugrPMbWk1y2gPmcjPmk9K8a
X-Received: by 2002:a17:902:503:: with SMTP id 3mr63795167plf.233.1546904033415;
        Mon, 07 Jan 2019 15:33:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546904033; cv=none;
        d=google.com; s=arc-20160816;
        b=wc1zfV8tXPRnP+G9Cw/cKkVixZ70v3dOsHTZVE3YtGMuf/bAU40YJjltsmho0ujZ5Q
         y7KQTi3mCQVfZEQzWPPF5FF6oh/3Ta5FkbVkauwruFiMZ+kvtFjVq5558bqgX7R+2jE9
         a2nh0bsoMU67e9Yz9tKgIqvOJQ66KQq3q2i+iWWbanKvgPAmpVgQNNz+oSaKlVMNWl77
         Z6FjNZqEU3xKCZwrQk8Kqd/JvWQL03HNcFliRTb8OwBraRMja+3IFs2oBoMZFquPofPF
         KGu6ZjIS16QVm1jRCa/pWbkKQqIAjhIS3W1mcDBJbVc8wmuE1VBoQTdVti1ANqL5zPz2
         S2lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=dpzq8U6sX6KNGIFiMCzUEnWlDckO99JJu/c2vvDNFTg=;
        b=Gq61Ud8EFfMONflVyfZmbkczZeZf6neiNVivzGd2C15E/G90zIfs740xma/kPyyui6
         GrWQtf7X3AU4F/acyOxHOIUhw8fd0+7Y1JWeEY4lYuxAgEMX21/sVuKiOxQ7cJPiXWdJ
         eoVmeAfZ+zJrCn6iXDHlvbjJBOa9GRnuBjybl+acsJCpdzrQ5OY84B6FXuCGBC0vNiw1
         +vx7iMEPqzhdpTqLmGY3UqDHKV0ZUv92W+BYWALm8+UXfcoL8h5czxN+tAtcgPcA57aK
         4s6YagAwlGCA4zxI970C0OauKGmrlHqJkjJvlVFd7R9a+RFZBoA2YZIqipanu2mUZnKS
         rP8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t6si60005220plz.96.2019.01.07.15.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:33:53 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jan 2019 15:33:52 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,451,1539673200"; 
   d="scan'208";a="124997897"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 07 Jan 2019 15:33:52 -0800
Subject: [PATCH v7 2/3] mm: Move buddy list manipulations into helpers
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 mhocko@suse.com, keith.busch@intel.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mgorman@suse.de
Date: Mon, 07 Jan 2019 15:21:16 -0800
Message-ID:
 <154690327612.676627.7469591833063917773.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107232116.FqtLRQ0psS-Dc2_lSEW9N3QEZqQw4iaQSSYGr3YcthA@z>

In preparation for runtime randomization of the zone lists, take all
(well, most of) the list_*() functions in the buddy allocator and put
them in helper functions. Provide a common control point for injecting
additional behavior when freeing pages.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h       |    3 --
 include/linux/mm_types.h |    3 ++
 include/linux/mmzone.h   |   51 ++++++++++++++++++++++++++++++++++
 mm/compaction.c          |    4 +--
 mm/page_alloc.c          |   70 ++++++++++++++++++----------------------------
 5 files changed, 84 insertions(+), 47 deletions(-)

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
index 8c37a023a790..b78a45e0b11c 100644
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
@@ -98,6 +100,55 @@ struct free_area {
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
+static inline void rmv_page_order(struct page *page)
+{
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+}
+
+static inline void del_page_from_free_area(struct page *page,
+		struct free_area *area, int migratetype)
+{
+	list_del(&page->lru);
+	rmv_page_order(page);
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
index 2adcd6da8a07..0b4791a2dd43 100644
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
@@ -1852,7 +1842,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		add_to_free_area(&page[size], area, migratetype);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1994,13 +1984,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
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
@@ -2086,8 +2073,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+		move_to_free_area(page, &zone->free_area[order], migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2263,7 +2249,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	move_to_free_area(page, area, start_type);
 }
 
 /*
@@ -2287,7 +2273,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (free_area_empty(area, fallback_mt))
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2374,9 +2360,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
-			page = list_first_entry_or_null(
-					&area->free_list[MIGRATE_HIGHATOMIC],
-					struct page, lru);
+			page = get_page_from_free_area(area, MIGRATE_HIGHATOMIC);
 			if (!page)
 				continue;
 
@@ -2499,8 +2483,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
 	VM_BUG_ON(current_order == MAX_ORDER);
 
 do_steal:
-	page = list_first_entry(&area->free_list[fallback_mt],
-							struct page, lru);
+	page = get_page_from_free_area(area, fallback_mt);
 
 	steal_suitable_fallback(zone, page, alloc_flags, start_migratetype,
 								can_steal);
@@ -2937,6 +2920,7 @@ EXPORT_SYMBOL_GPL(split_page);
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
+	struct free_area *area = &page_zone(page)->free_area[order];
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
@@ -2961,9 +2945,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
-	rmv_page_order(page);
+
+	del_page_from_free_area(page, area, mt);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -3265,13 +3248,13 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
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
@@ -5173,7 +5156,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!free_area_empty(area, type))
 					types[order] |= 1 << type;
 			}
 		}
@@ -8318,6 +8301,9 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
+		struct free_area *area;
+		int mt;
+
 		if (!pfn_valid(pfn)) {
 			pfn++;
 			continue;
@@ -8336,13 +8322,13 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
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

