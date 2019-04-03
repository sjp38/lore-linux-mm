Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 406C8C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E05FA2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E05FA2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3FF76B0276; Wed,  3 Apr 2019 15:33:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD22A6B0277; Wed,  3 Apr 2019 15:33:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87BD46B0278; Wed,  3 Apr 2019 15:33:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 583136B0276
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g25so130312qkm.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uKn34GWnpVv7ef4GRTWg8vkzWdtXgrNwtqkdqbeR1BA=;
        b=av7AOXfaM0l9Rvz2vlC8RTm5EXUlEzss0eQwzL1cnWpp6Bh/Cbt2vljpIN1bdlJT8L
         FB1LpHZfGoYhQ+8Engow22DGZi87WMq+ve3eoadSx7YpMDllkqbDe/aMQsh7WFp1ZgME
         5zfxhDoM+h1mCT0DZT+sLETQnpUn9ne5BEcK7bho8LjDMlzbnpNGqfAHQMtiw/rwk/ue
         QiFL3V+vgRMr11xSx6Q+Mff62jFDyu/MuVx4GZV6CjaMUDqrQYHOkgw3PCj2BCgHYTdy
         EIvZLYu1yxD6Q/lzuEj7+gb0Xcb7M3FUByUxqkA/irDlDoQUh05oxwSKLysrs6XUIt9s
         sZtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXB/MREGj8NIVisxe2Xoc0UwRI0v4N2znKx+gDa4va/21tU1bM8
	C4EMysz1VjsPxnefBppEYvQCK1+sy8WU2HrUUNqmFdbzT6A4dq9Bg7P4KRMSzv40PIZDH7Q3VyV
	WxBxLGY5JJSQlXc1keDo8SS05fPkp/zdDUA62V5Whj1qIHW+1VxLNCnZ0+/b27Ym1xQ==
X-Received: by 2002:a37:61d0:: with SMTP id v199mr1630963qkb.159.1554320026110;
        Wed, 03 Apr 2019 12:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzW38jymq9jnp72B/u3Y+QdDkCi2RplQ7d4DujLEh7qrM2DzQB4dsLE1f0E4BSldzB0LaY
X-Received: by 2002:a37:61d0:: with SMTP id v199mr1630923qkb.159.1554320025450;
        Wed, 03 Apr 2019 12:33:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320025; cv=none;
        d=google.com; s=arc-20160816;
        b=SvaW4Z5qh/W93mLy9EKdb5IcEUDNGUj3VJAWb439dttfXcE21zlj2dOPIvR7yBINJ5
         EHi0UCwlJuGBAsHMdeKj252vhOoFHl1LdFb8wW+jVdsh7IZk1l9J+xUAMCzEaqtFKRK4
         +yzc1URrQ0klXi/FSOuPOhLqld+z0Xby5jcB4qiU89VDV57Hb2ojLbGwdvBsfVrj6hiu
         EFVUb7kjpYYrm9XACOzD1NDcuQi8r8Y8JByT3jSgJ+syXXTI2Vqjh0Aj3UZr/UlZUyoJ
         Cz24SKZJv0qulzaWyrAh3Y8sVh3VHZZtfzLjaVea9r9TkIlbtmRGGSD/9anL4X2hbv+u
         CGjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uKn34GWnpVv7ef4GRTWg8vkzWdtXgrNwtqkdqbeR1BA=;
        b=WVR7Nl5sW4PWsHiB20lw+5PD459MSIMhp+x+ovxyqmo2nedki51xCnuN66pzFpOhdj
         XTX6HoXN71y7x7sxj/14RbV5NLoWXXsuQec8EW2UmFgVEof/lr84DZ8bB3TVj8QdAnt3
         M1lz+rTAixNgJT5RhLszATQ/Pd0wNHbHlomxp7hhp98M3HCZnW/xuOjvQ3tWssAOgXeh
         cRFKqAqfX7+CxhuyLIR1uqkokSwOjtCIFX0zmq0U/5WaZf5Z8lGP+nP46S5Ux4dyELGO
         pDpVGB4KIPk1c2V/4bGUleu/EHFGYSSGmy5YdVHIr6BVc0L6p7+oumDAJNtAsdxK7bHL
         XJ+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g185si2214509qkf.107.2019.04.03.12.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A5D6CC049598;
	Wed,  3 Apr 2019 19:33:44 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8FD0A6012C;
	Wed,  3 Apr 2019 19:33:43 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v3 12/12] mm/hmm: convert various hmm_pfn_* to device_entry which is a better name
Date: Wed,  3 Apr 2019 15:33:18 -0400
Message-Id: <20190403193318.16478-13-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 03 Apr 2019 19:33:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Convert hmm_pfn_* to device_entry_* as here we are dealing with device
driver specific entry format and hmm provide helpers to allow differents
components (including HMM) to create/parse device entry.

We keep wrapper with the old name so that we can convert driver to use the
new API in stages in each device driver tree. This will get remove once all
driver are converted.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/hmm.h | 93 +++++++++++++++++++++++++++++++--------------
 mm/hmm.c            | 19 +++++----
 2 files changed, 75 insertions(+), 37 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f81fe2c0f343..51ec27a84668 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -239,36 +239,36 @@ static inline bool hmm_range_valid(struct hmm_range *range)
 }
 
 /*
- * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
- * @range: range use to decode HMM pfn value
- * @pfn: HMM pfn value to get corresponding struct page from
- * Returns: struct page pointer if pfn is a valid HMM pfn, NULL otherwise
+ * hmm_device_entry_to_page() - return struct page pointed to by a device entry
+ * @range: range use to decode device entry value
+ * @entry: device entry value to get corresponding struct page from
+ * Returns: struct page pointer if entry is a valid, NULL otherwise
  *
- * If the HMM pfn is valid (ie valid flag set) then return the struct page
- * matching the pfn value stored in the HMM pfn. Otherwise return NULL.
+ * If the device entry is valid (ie valid flag set) then return the struct page
+ * matching the entry value. Otherwise return NULL.
  */
-static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
-					   uint64_t pfn)
+static inline struct page *hmm_device_entry_to_page(const struct hmm_range *range,
+						    uint64_t entry)
 {
-	if (pfn == range->values[HMM_PFN_NONE])
+	if (entry == range->values[HMM_PFN_NONE])
 		return NULL;
-	if (pfn == range->values[HMM_PFN_ERROR])
+	if (entry == range->values[HMM_PFN_ERROR])
 		return NULL;
-	if (pfn == range->values[HMM_PFN_SPECIAL])
+	if (entry == range->values[HMM_PFN_SPECIAL])
 		return NULL;
-	if (!(pfn & range->flags[HMM_PFN_VALID]))
+	if (!(entry & range->flags[HMM_PFN_VALID]))
 		return NULL;
-	return pfn_to_page(pfn >> range->pfn_shift);
+	return pfn_to_page(entry >> range->pfn_shift);
 }
 
 /*
- * hmm_pfn_to_pfn() - return pfn value store in a HMM pfn
- * @range: range use to decode HMM pfn value
- * @pfn: HMM pfn value to extract pfn from
- * Returns: pfn value if HMM pfn is valid, -1UL otherwise
+ * hmm_device_entry_to_pfn() - return pfn value store in a device entry
+ * @range: range use to decode device entry value
+ * @entry: device entry to extract pfn from
+ * Returns: pfn value if device entry is valid, -1UL otherwise
  */
-static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
-					   uint64_t pfn)
+static inline unsigned long
+hmm_device_entry_to_pfn(const struct hmm_range *range, uint64_t pfn)
 {
 	if (pfn == range->values[HMM_PFN_NONE])
 		return -1UL;
@@ -282,31 +282,66 @@ static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
 }
 
 /*
- * hmm_pfn_from_page() - create a valid HMM pfn value from struct page
+ * hmm_device_entry_from_page() - create a valid device entry for a page
  * @range: range use to encode HMM pfn value
- * @page: struct page pointer for which to create the HMM pfn
- * Returns: valid HMM pfn for the page
+ * @page: page for which to create the device entry
+ * Returns: valid device entry for the page
  */
-static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
-					 struct page *page)
+static inline uint64_t hmm_device_entry_from_page(const struct hmm_range *range,
+						  struct page *page)
 {
 	return (page_to_pfn(page) << range->pfn_shift) |
 		range->flags[HMM_PFN_VALID];
 }
 
 /*
- * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
+ * hmm_device_entry_from_pfn() - create a valid device entry value from pfn
  * @range: range use to encode HMM pfn value
- * @pfn: pfn value for which to create the HMM pfn
- * Returns: valid HMM pfn for the pfn
+ * @pfn: pfn value for which to create the device entry
+ * Returns: valid device entry for the pfn
  */
-static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
-					unsigned long pfn)
+static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
+						 unsigned long pfn)
 {
 	return (pfn << range->pfn_shift) |
 		range->flags[HMM_PFN_VALID];
 }
 
+/*
+ * Old API:
+ * hmm_pfn_to_page()
+ * hmm_pfn_to_pfn()
+ * hmm_pfn_from_page()
+ * hmm_pfn_from_pfn()
+ *
+ * This are the OLD API please use new API, it is here to avoid cross-tree
+ * merge painfullness ie we convert things to new API in stages.
+ */
+static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
+					   uint64_t pfn)
+{
+	return hmm_device_entry_to_page(range, pfn);
+}
+
+static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
+					   uint64_t pfn)
+{
+	return hmm_device_entry_to_pfn(range, pfn);
+}
+
+static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
+					 struct page *page)
+{
+	return hmm_device_entry_from_page(range, page);
+}
+
+static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
+					unsigned long pfn)
+{
+	return hmm_device_entry_from_pfn(range, pfn);
+}
+
+
 
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 82fded7273d8..75d2ea906efb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -542,7 +542,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			if (unlikely(!hmm_vma_walk->pgmap))
 				return -EBUSY;
 		}
-		pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+		pfns[i] = hmm_device_entry_from_pfn(range, pfn) | cpu_flags;
 	}
 	if (hmm_vma_walk->pgmap) {
 		put_dev_pagemap(hmm_vma_walk->pgmap);
@@ -606,7 +606,8 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 					   &fault, &write_fault);
 			if (fault || write_fault)
 				goto fault;
-			*pfn = hmm_pfn_from_pfn(range, swp_offset(entry));
+			*pfn = hmm_device_entry_from_pfn(range,
+					    swp_offset(entry));
 			*pfn |= cpu_flags;
 			return 0;
 		}
@@ -644,7 +645,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		return -EFAULT;
 	}
 
-	*pfn = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
+	*pfn = hmm_device_entry_from_pfn(range, pte_pfn(pte)) | cpu_flags;
 	return 0;
 
 fault:
@@ -797,7 +798,8 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 					      hmm_vma_walk->pgmap);
 			if (unlikely(!hmm_vma_walk->pgmap))
 				return -EBUSY;
-			pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+			pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
+				  cpu_flags;
 		}
 		if (hmm_vma_walk->pgmap) {
 			put_dev_pagemap(hmm_vma_walk->pgmap);
@@ -870,7 +872,8 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 
 	pfn = pte_pfn(entry) + (start & mask);
 	for (; addr < end; addr += size, i++, pfn += pfn_inc)
-		range->pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
+		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
+				 cpu_flags;
 	hmm_vma_walk->last = end;
 
 unlock:
@@ -1213,7 +1216,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 		 */
 		daddrs[i] = 0;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
@@ -1243,7 +1246,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
@@ -1298,7 +1301,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
-- 
2.17.2

