Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29DD5C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F0F21841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:58:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uY1ehjWR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F0F21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61A7C8E0002; Wed, 24 Jul 2019 12:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CCA56B000E; Wed, 24 Jul 2019 12:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E03A8E0002; Wed, 24 Jul 2019 12:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEE26B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:58:27 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s9so51678158iob.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:58:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=wYHYz2CAMv2i0hd4mcN2CYyNrF3b9BU8TFbZbdGIzOs=;
        b=q1m6I7IDlNqO+eS6fvZ33aj28PAI0Qw4mnDwMYKlXedTaDQuWUOXAz3FirKW5Y5/BK
         Popt4rqef63/zjI6UgscyY+uM/JfX95aumwvMOIQfp1Zn0Yr+HoQeVTcCf++MoVHw97X
         6AwDDbifm0r+Lx3XCGfuAMk+l7WFR3zi59erf742vkXr9MIu2G7MZMnrhudRfrKcZw6I
         3vKaDy54PJQBvjZTgRRuP37fb4f81jz2UNqOdfii7UT0iYTaoQyZzUKXLhGwSpk/LMwm
         S+cVuSfVsTniokjUWrBmIkZwrczfvvacRtVcWG0dfPGI3Aq/izymS3Y/UthYsE84Eln5
         WVTQ==
X-Gm-Message-State: APjAAAWyJDVf2PbT8MTya/IFIkqmhnZOAr9Cyuj0IfnRZzLzCdbliNEh
	mu/z20zq4BEV06vv5cUdH/uywfdmsn5laN3P+kjcsDnH47DNEEuHVn3BN/0PNw1o3bEsVaNeQqy
	w5UwhPSWFlGHWGJ4nMHbPLQIsamNa9V7T35LKiWghPrnYaw18+ftWUeDWWGCbmYZJ8w==
X-Received: by 2002:a5d:8794:: with SMTP id f20mr8851892ion.128.1563987506887;
        Wed, 24 Jul 2019 09:58:26 -0700 (PDT)
X-Received: by 2002:a5d:8794:: with SMTP id f20mr8851828ion.128.1563987505941;
        Wed, 24 Jul 2019 09:58:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563987505; cv=none;
        d=google.com; s=arc-20160816;
        b=0nIQ09oGUCzfAE7kvpDzpIaKFoeYagK+hUjx1S0GDfzfJtoE0Nfxz3wLj5Uq3JIKd0
         oo2G6yN/OuFSshS04NWTWe5OZsCNA4mTCiQVTQ208DYCESdcY0f1m2yC5b8fJHo+QkN9
         IdCQpxt6nKKY7r1TreSuxEbbOs398tyvwzqZVBp+J+3GNLNGidhLxSla8FnsDKXeFNxz
         wxJcntMllFZNRH3571kRHmrqmHn4J+xqgoa9UmM0fBh3XJmSmkp6sBR4JH/gO4UTye2i
         7c0vVNISuOm/KGde4JzRxZrW8+Tdyk8yE0la6KwLplQmHDHaysC+kEtQY9vtAq5UEkcU
         X9JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=wYHYz2CAMv2i0hd4mcN2CYyNrF3b9BU8TFbZbdGIzOs=;
        b=lwasMSF/cmTqRGILBBcfbaur5CDCETxL1i/WZO/G5ex6CUXYTHj+QXlKXcw2Zs/r8w
         VEh3MSXsC1voXKl5bLfQlHw2Rp/Gw5m0YI7qLOBnNjxszgPe2/gO9IKUTstuzV5y4lbQ
         N+WKNs7OdbqKnSuxrZedA3GRIWin12fhZzda/H+/Hnrrzhf0gH+tbGtHRPQJhss6eguG
         YfkiqKe6FFk1QRDeTZUuP4dHgLZy1zQFkCKEqIXRoep0IExuQXyl4QT2hijzBphsD3rA
         bCz7vAxh8KMcPag7pAJmuirq7h1qc2LmM1ZX+if2wGAoLS8Nyt+k1rTMiJAasbq1eKci
         NUnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uY1ehjWR;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor32441392iol.66.2019.07.24.09.58.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 09:58:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uY1ehjWR;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=wYHYz2CAMv2i0hd4mcN2CYyNrF3b9BU8TFbZbdGIzOs=;
        b=uY1ehjWR6BNqfQDttxnJ2nwMmBN8h3DMwSIIAOAYu7j+1U9hWxIKRCWsDilAvtulS7
         jqHJXC90O93P97yw9YGdgSrzEUbp/ZLwkCT8Yc0LOVtg7XtoHzdwigcsAacCSXhT9E6V
         beqzvXL7IVwvTdXLU3GOtLQearf9QMNAH8y0xURecTQLtawiDMebQFFl5jX3uHtZ+F9c
         ikP//AaeOHroRE4+hUvKBROEkcq166E16z8wfjtJtzRhaXSVsUpd49066HnG3q72ZGj8
         LdvAH/t8xfq00R+pV9kgkHyBHNwpH45MFLV/9Our+I1qQxPvHjK9Ty+dkBWr4Kwu2ZzO
         j4qw==
X-Google-Smtp-Source: APXvYqzPsB0WoiSPD7TwB+7/Z6jVYA0qOPZHI3pVrvai/+z0Jj6tq9koz6Gcg9wg+Mxn8dfbkySShA==
X-Received: by 2002:a6b:ef06:: with SMTP id k6mr4646761ioh.70.1563987505511;
        Wed, 24 Jul 2019 09:58:25 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id q13sm42436508ioh.36.2019.07.24.09.58.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 09:58:25 -0700 (PDT)
Subject: [PATCH v2 1/5] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 09:56:16 -0700
Message-ID: <20190724165615.6685.24289.stgit@localhost.localdomain>
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

This patch is meant to move the head/tail adding logic out of the shuffle
code and into the __free_one_page function since ultimately that is where
it is really needed anyway. By doing this we should be able to reduce the
overhead and can consolidate all of the list addition bits in one spot.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   12 --------
 mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
 mm/shuffle.c           |   24 ----------------
 mm/shuffle.h           |   32 ++++++++++++++++++++++
 4 files changed, 71 insertions(+), 67 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..738e9c758135 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,18 +116,6 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	area->nr_free++;
 }
 
-#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
-/* Used to preserve page allocation order entropy */
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype);
-#else
-static inline void add_to_free_area_random(struct page *page,
-		struct free_area *area, int migratetype)
-{
-	add_to_free_area(page, area, migratetype);
-}
-#endif
-
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..1c4644b6cdc3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -877,6 +877,36 @@ static inline struct capture_control *task_capc(struct zone *zone)
 #endif /* CONFIG_COMPACTION */
 
 /*
+ * If this is not the largest possible page, check if the buddy
+ * of the next-highest order is free. If it is, it's possible
+ * that pages are being freed that will coalesce soon. In case,
+ * that is happening, add the free page to the tail of the list
+ * so it's less likely to be used soon and more likely to be merged
+ * as a higher order page
+ */
+static inline bool
+buddy_merge_likely(unsigned long pfn, unsigned long buddy_pfn,
+		   struct page *page, unsigned int order)
+{
+	struct page *higher_page, *higher_buddy;
+	unsigned long combined_pfn;
+
+	if (order >= MAX_ORDER - 2)
+		return false;
+
+	if (!pfn_valid_within(buddy_pfn))
+		return false;
+
+	combined_pfn = buddy_pfn & pfn;
+	higher_page = page + (combined_pfn - pfn);
+	buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
+	higher_buddy = higher_page + (buddy_pfn - combined_pfn);
+
+	return pfn_valid_within(buddy_pfn) &&
+	       page_is_buddy(higher_page, higher_buddy, order + 1);
+}
+
+/*
  * Freeing function for a buddy system allocator.
  *
  * The concept of a buddy system is to maintain direct-mapped table
@@ -905,11 +935,12 @@ static inline void __free_one_page(struct page *page,
 		struct zone *zone, unsigned int order,
 		int migratetype)
 {
-	unsigned long combined_pfn;
+	struct capture_control *capc = task_capc(zone);
 	unsigned long uninitialized_var(buddy_pfn);
-	struct page *buddy;
+	unsigned long combined_pfn;
+	struct free_area *area;
 	unsigned int max_order;
-	struct capture_control *capc = task_capc(zone);
+	struct page *buddy;
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -978,35 +1009,12 @@ static inline void __free_one_page(struct page *page,
 done_merging:
 	set_page_order(page, order);
 
-	/*
-	 * If this is not the largest possible page, check if the buddy
-	 * of the next-highest order is free. If it is, it's possible
-	 * that pages are being freed that will coalesce soon. In case,
-	 * that is happening, add the free page to the tail of the list
-	 * so it's less likely to be used soon and more likely to be merged
-	 * as a higher order page
-	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
-			&& !is_shuffle_order(order)) {
-		struct page *higher_page, *higher_buddy;
-		combined_pfn = buddy_pfn & pfn;
-		higher_page = page + (combined_pfn - pfn);
-		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
-		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
-		if (pfn_valid_within(buddy_pfn) &&
-		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			add_to_free_area_tail(page, &zone->free_area[order],
-					      migratetype);
-			return;
-		}
-	}
-
-	if (is_shuffle_order(order))
-		add_to_free_area_random(page, &zone->free_area[order],
-				migratetype);
+	area = &zone->free_area[order];
+	if (is_shuffle_order(order) ? shuffle_add_to_tail() :
+	    buddy_merge_likely(pfn, buddy_pfn, page, order))
+		add_to_free_area_tail(page, area, migratetype);
 	else
-		add_to_free_area(page, &zone->free_area[order], migratetype);
-
+		add_to_free_area(page, area, migratetype);
 }
 
 /*
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..55d592e62526 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -4,7 +4,6 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/mmzone.h>
-#include <linux/random.h>
 #include <linux/moduleparam.h>
 #include "internal.h"
 #include "shuffle.h"
@@ -182,26 +181,3 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
 		shuffle_zone(z);
 }
-
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype)
-{
-	static u64 rand;
-	static u8 rand_bits;
-
-	/*
-	 * The lack of locking is deliberate. If 2 threads race to
-	 * update the rand state it just adds to the entropy.
-	 */
-	if (rand_bits == 0) {
-		rand_bits = 64;
-		rand = get_random_u64();
-	}
-
-	if (rand & 1)
-		add_to_free_area(page, area, migratetype);
-	else
-		add_to_free_area_tail(page, area, migratetype);
-	rand_bits--;
-	rand >>= 1;
-}
diff --git a/mm/shuffle.h b/mm/shuffle.h
index 777a257a0d2f..add763cc0995 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -3,6 +3,7 @@
 #ifndef _MM_SHUFFLE_H
 #define _MM_SHUFFLE_H
 #include <linux/jump_label.h>
+#include <linux/random.h>
 
 /*
  * SHUFFLE_ENABLE is called from the command line enabling path, or by
@@ -43,6 +44,32 @@ static inline bool is_shuffle_order(int order)
 		return false;
 	return order >= SHUFFLE_ORDER;
 }
+
+static inline bool shuffle_add_to_tail(void)
+{
+	static u64 rand;
+	static u8 rand_bits;
+	u64 rand_old;
+
+	/*
+	 * The lack of locking is deliberate. If 2 threads race to
+	 * update the rand state it just adds to the entropy.
+	 */
+	if (rand_bits-- == 0) {
+		rand_bits = 64;
+		rand = get_random_u64();
+	}
+
+	/*
+	 * Test highest order bit while shifting our random value. This
+	 * should result in us testing for the carry flag following the
+	 * shift.
+	 */
+	rand_old = rand;
+	rand <<= 1;
+
+	return rand < rand_old;
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat)
 {
@@ -60,5 +87,10 @@ static inline bool is_shuffle_order(int order)
 {
 	return false;
 }
+
+static inline bool shuffle_add_to_tail(void)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */

