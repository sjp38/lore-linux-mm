Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6F23C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90AD8215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u+Tng6Wd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90AD8215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DE546B0005; Wed, 19 Jun 2019 18:33:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F8F8E0002; Wed, 19 Jun 2019 18:33:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0098F8E0001; Wed, 19 Jun 2019 18:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4C8A6B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:33:05 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h4so1499192iol.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:33:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=F/9CnX80uREAl0+uDwGFKwrKVTkwRc085X3OG7yt7+w=;
        b=r2wA3eFxlp6twSlY+kDkPSpwBNw27Ry8UjRSm2GUJg685ZVniY10q0FeFcUNMRgX6K
         ziugXQXZQYhildDAxZWzL1BHLuymOWQ3LxqyhsGmfRzTk0aYn/1If2eCPGYYH7Folw70
         c2CruugtHYlIa/Iyv9TWFV0YUrdYhQftSrxTGpUFlORgM9MxWfCG522jXR2xWMC6pbui
         3wVuild3l+FIxom74kb+RrwRJnoGI4PPpd/dGYS+MNwJUrQX41R3P97QerxTUiDz5mwf
         s1zmrJdwHIosb1ITHf/tuUNMOodfOWQa2VB5QsosPuW0Hl7HSrA8274R/6N6CkNUj5xM
         hB1w==
X-Gm-Message-State: APjAAAU7n+iMfMjPI7YFT3Lhow8YK/+9IYZbpAgv8cFG53ovfn1uM57H
	avGjkOlnQTYIMjJM5VlYTXcdHjXja14ZBbju6NHfSyzL1S8rc9oncOZN2Bm8oxuy2m1pG3vY28U
	D1eMtWZJbWgy49Tffnppu4yHzq4dw/nticKxIdQb07p4BVL6fMYg6558fflEtVOrpPQ==
X-Received: by 2002:a5d:8447:: with SMTP id w7mr9889412ior.197.1560983585617;
        Wed, 19 Jun 2019 15:33:05 -0700 (PDT)
X-Received: by 2002:a5d:8447:: with SMTP id w7mr9889345ior.197.1560983584655;
        Wed, 19 Jun 2019 15:33:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560983584; cv=none;
        d=google.com; s=arc-20160816;
        b=jCty2OGwIlLEDVNkyX3S/GXreRrfPPAtJsaOuE7UK2Ffhhn6wD421EPZM00dXgzkvZ
         34+8SjXM9/2PJq9NAdS3j5zxy59M8gJewFUXUqqDC/FwArZu1idXnZ1U2xS5IvNuLZ6m
         Hq5TevP3ME3ULapJd0My0vxf1O2oCgEhGFY/cbQrUIXc3st3K7MGXVaKcHEYh4mqV4OQ
         5RlkkAXSBwft4EZ1Sj06ziqb75thhOA7Rj6RQxK8FxbRjsRBKuZaM7KsmHOnJPrkNRRP
         GpRb77rS/4KsOGSAaTLx2ncKUZkp2McC0Bd/eaRce3+Vs+KacYfCIWshnq8BCLj2cqY/
         lTPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=F/9CnX80uREAl0+uDwGFKwrKVTkwRc085X3OG7yt7+w=;
        b=bC/MT8LzrT+p3mTiCYpXPwPVvenyR905e46qOMXRoStCTVXu0omU7aQowDUjMdiZxY
         bGch1WubIQt2/mkQYjKLIA0fPVMh7eYbwACXoTJk3Z7fg7J83e51qZ2sqN22u8xu3cHE
         RgutTeDz70W7y3n5ATrAAP+0XNX28gbWgcxBDwSdWyqlMRe+XFu7m5pdI4Cj0105oyix
         KHxImq9utRVG5IxcFRW7Eh6FFQlVMYKYroAb8T7c1lxaI0fzp/cd0eWTgVfB3qFcHWyx
         1uXIcQjXMmtEGlMGmGk7W7bdw2ECCDa6jElzr3H1+MRJLFTIdSF3vb0AohLcRqKEDa5Y
         xTnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u+Tng6Wd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor44222492jaf.1.2019.06.19.15.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 15:33:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u+Tng6Wd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=F/9CnX80uREAl0+uDwGFKwrKVTkwRc085X3OG7yt7+w=;
        b=u+Tng6Wd+9EcoTeB9cOi6UNvkOs30SqWYHHObrN0enKv7O9KSLMiJD+B/m7FDKJobp
         U15+Gevz191I0isHqbdBxybXGLbmWa590iXaWpF8tJZe4fvVvAeOI8SN5hl95qKkIwoG
         4qVHJ63fZemQZXHnbmPQtO/b+uc8oH1nGjGoTFoM3a9+zq5FLUEpSqi3eagsTQsilwEH
         dC5xSnZPPX1uZ7XXNyYEgZukguxMfADOHl74s7AMg7zLHZSC/fsgG7trQfTec/h3X5V9
         feQWHkTkGhr1LKTcQ0pQjayjm8Vm9lUAojKvfGGtuj/RxUTP0h7ovzS+g/QizvRyss2e
         GmvA==
X-Google-Smtp-Source: APXvYqw4o8A6+PG9trd+RXJLq8lvf+5YtSoaew5wEQ4VMk70V7RQw3K9/H0udPCiWZ9wgQwxtWgceQ==
X-Received: by 2002:a02:11c2:: with SMTP id 185mr39139210jaf.8.1560983584277;
        Wed, 19 Jun 2019 15:33:04 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id i23sm13270218ioj.24.2019.06.19.15.33.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:33:03 -0700 (PDT)
Subject: [PATCH v1 1/6] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 19 Jun 2019 15:33:02 -0700
Message-ID: <20190619223302.1231.51136.stgit@localhost.localdomain>
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

This patch is meant to move the head/tail adding logic out of the shuffle
code and into the __free_one_page function since ultimately that is where
it is really needed anyway. By doing this we should be able to reduce the
overhead and can consolidate all of the list addition bits in one spot.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   12 --------
 mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
 mm/shuffle.c           |   24 ----------------
 mm/shuffle.h           |   35 ++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 67 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 427b79c39b3c..4c07af2cfc2f 100644
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
index f4651a09948c..ec344ce46587 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -830,6 +830,36 @@ static inline struct capture_control *task_capc(struct zone *zone)
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
+	if (is_shuffle_order(order) || order >= (MAX_ORDER - 2))
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
@@ -858,11 +888,12 @@ static inline void __free_one_page(struct page *page,
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
 
@@ -931,35 +962,12 @@ static inline void __free_one_page(struct page *page,
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
+	if (buddy_merge_likely(pfn, buddy_pfn, page, order) ||
+	    is_shuffle_tail_page(order))
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
index 777a257a0d2f..3f4edb60a453 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -3,6 +3,7 @@
 #ifndef _MM_SHUFFLE_H
 #define _MM_SHUFFLE_H
 #include <linux/jump_label.h>
+#include <linux/random.h>
 
 /*
  * SHUFFLE_ENABLE is called from the command line enabling path, or by
@@ -43,6 +44,35 @@ static inline bool is_shuffle_order(int order)
 		return false;
 	return order >= SHUFFLE_ORDER;
 }
+
+static inline bool is_shuffle_tail_page(int order)
+{
+	static u64 rand;
+	static u8 rand_bits;
+	u64 rand_old;
+
+	if (!is_shuffle_order(order))
+		return false;
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
@@ -60,5 +90,10 @@ static inline bool is_shuffle_order(int order)
 {
 	return false;
 }
+
+static inline bool is_shuffle_tail_page(int order)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */

