Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 612BDC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAA021841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:02:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q7Qtd8QK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAA021841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FD106B0010; Wed, 24 Jul 2019 13:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887ED8E0006; Wed, 24 Jul 2019 13:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74EED8E0005; Wed, 24 Jul 2019 13:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53C796B0010
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:02:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c5so51332864iom.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=VeZ5bajO/AKYwVnzW540b0VQt3bRLs5FygnYd5RGmx0=;
        b=td0VM2NgC8WnhjgHeTp2Hx3zfklI0nJXOWJ45RafOLE6TUriAv/Li5C2ZehlaCUZxg
         XOKgCfanf8IzOJy/1/RdXuwAB0WmH02GeSOIE0h8BgGXceZgkby6ikvuIyBIPP4qqIr6
         /sXKeBzmLP1r8GUkkz2TFqshtf+aPSaSP5NxeBIIIIk+jontzuvJB5guDmG64bQYSc30
         34Hebv6WBrGqRPLphzJQH2/SgpbI0711D6ZL5pYX9uVak2M/pv5+8OQkvoMm/Kws3H2w
         GK1l1IGsbV7cNXA85fxZaxgRtyK4fiFfGvWYjNPAX+auESfzg590yC78Hs3KILyVx4tE
         9Ing==
X-Gm-Message-State: APjAAAXve5rvPVTqowTorFkv4GC6Xp1rz2qN/ZArwa2ov/K3sjuKtONr
	qzDInnXgapnw6jSL6RTVarmjcTaZKj7owC0HaQ66nKe1lIMfNfrHFYsPfKf9blpCgpmqj3oYT03
	KYCzzu1e6Myq+XT5GEcCpIRoFajIwMyXrZGFwAF66i+Wu8JIcuIBKK9i9014Cm/i7VQ==
X-Received: by 2002:a6b:3102:: with SMTP id j2mr11549847ioa.5.1563987776110;
        Wed, 24 Jul 2019 10:02:56 -0700 (PDT)
X-Received: by 2002:a6b:3102:: with SMTP id j2mr11549784ioa.5.1563987775265;
        Wed, 24 Jul 2019 10:02:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563987775; cv=none;
        d=google.com; s=arc-20160816;
        b=ZI56DA7+ds9vshquUJDTiRLH1Y9MeIM6ve2ZjAeT0+xWFiWU5Z3FjwzlK85XsLvGSE
         q4vNJG1h673moMHx4oJLNeYjM4AiOOk2WNCXp+P83lJ1B80d8A0XcpgpRjQj6ivVQLZ+
         wyQnmDQ+Cas7RJ+YLUcKSkNLoZ423XC1WPD0MrqxD2zhq6woatNhmUBrfwgJehVAbPvO
         YXilomaxbkUTOlYXD+X9kpQCt5D4Uz6HLdAj51J208yV0BP5j6DBRsWHnxn2gc0RPjcm
         R6umL48bV5ijOWmgyIxfGBNbp46PU1bywjINtdXkR9egem43LLhtKlnmQk7RvzsSH06D
         /3YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=VeZ5bajO/AKYwVnzW540b0VQt3bRLs5FygnYd5RGmx0=;
        b=xcY25SDsYU0w+rPtN8ycLlCp5YFmxV2e2H4vZw6/fqpmVxVDpaV5wfz9bMO7DoOBu6
         /K2kDxtu/PXv9fAY8WdAd6Yv/4WybaixwEoBs6Df/UZ2Ui75zvY0euZr5B0KuL64IkiF
         uhWc1XiI9HNR17HQPO0xHkK/R2W/SMkeHgw4OwjVBm5vQ2lj404a5dLEIPQiQhwi3VFi
         bZJ+89tR2ZNCK9xVkDhR1aOpARF1uIIzDE/tZV552h7RjUlnbNG6Gl+nJ0aNPBg5x1hk
         /G/2l/5CRqwlldwk7bDpXgFsAWEWYXJvenLCtAKFFQc96M6PqnvxNMqHmewYZMN1ibHW
         HMAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q7Qtd8QK;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor32576125ioj.63.2019.07.24.10.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:02:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q7Qtd8QK;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VeZ5bajO/AKYwVnzW540b0VQt3bRLs5FygnYd5RGmx0=;
        b=Q7Qtd8QKtnQdZUVvZ/h7hYIDRDYc3G//tbW32a2/VqmgvDBnyqybVP+kflA3hRSvMQ
         qMEw2TJzxUlXXk9ItRIswieNAk1Otro2G3nuDAagh7pkcG/hxQv+eHjKUhC7U3KEyfyy
         qeeMGt9EPrLiZpuCI2y3FLRlWFd5OpGbbgxcvimfPCSGwfPXxQ74ACG/uEYfYYNX94qx
         mBksrK2OJ0gwRCy2ZIyvrdRk7n/HU0cc4ybPG08fiBjbNPQE1oWe2r6r9MW5crP+Jtqw
         gCjnLwdLFoG+QsfdOGxcmjORadYzhnTRlv4dCS+mgqzGQjRw8D66NqeEKdLy/pkq56kp
         ICaQ==
X-Google-Smtp-Source: APXvYqwcgXA0Ie0L+IDNnlc04ZvDr22nrMcaKVYfkLIQngt2mRFE3aSw5bYGcnM2PggW1eMnB1Rm+g==
X-Received: by 2002:a02:13c3:: with SMTP id 186mr84555363jaz.30.1563987774830;
        Wed, 24 Jul 2019 10:02:54 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id b14sm50259209iod.33.2019.07.24.10.02.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:02:54 -0700 (PDT)
Subject: [PATCH v2 3/5] mm: Use zone and order instead of free area in
 free_list manipulators
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 10:00:45 -0700
Message-ID: <20190724170045.6685.92452.stgit@localhost.localdomain>
In-Reply-To: <20190724165158.6685.87228.stgit@localhost.localdomain>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
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
index 3d612a6b1771..9a73f69b37af 100644
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

