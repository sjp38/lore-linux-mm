Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACC7FC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AAA1218FE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AAA1218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DDC36B0010; Fri, 12 Apr 2019 15:02:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58ED56B026A; Fri, 12 Apr 2019 15:02:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 405576B026B; Fri, 12 Apr 2019 15:02:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8D286B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:02:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z29so2574058edb.4
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=70luTOh7EZPm2mdLSlvwP+/XxOOcCyBYqtiI7hN9cdY=;
        b=MLad8jEFXuGLHBDp0sbdb4YyfgLm7g6Eq7iRQe4VgVxbw5eliF1oQxmHIw/qOLhPOx
         wQ96H/+EcFzVTlumnIo9RbUCPjJ+LnIHspLlyXBFvrKxN6xsGihUuhH4ZznwkXvaMhN1
         Hyj/2PTXtYG2Sjcd4AVq1DgCFRj3RVrUU/1sRXuY+TSPIs8s0ztitW6iKPMZAskb90/w
         Yz0GSR3c15KbKosNlV46PiEG1nbB1RoRDg1iyUpnzdQyQl1KwofbS/1Nx/m0tPaupn+I
         JrRTU7w72R7TETx61ONSQamw8vd5ElDNxV9amdMTy0nTI6cPOp+E8JMqzNk97PZ4qcS/
         7CCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAX1+jH/7ufke5POKFkMuvr6AeBY6Bl/M+qrazzAPO+MDpRL0w7l
	KlUpi6Z9rsbFQNh8gduWDfTuvfP5nlGEuKQv+TqY/5H06NBERM+Om7yp56PDKCWoQub/ylBPVqw
	igDiwH7CTKxsUpN+VDS4+bFB6lwCdSGZS+fWeXagdNM4NL1jbhx2x6/OAFD3X5/1ATQ==
X-Received: by 2002:a50:ed9a:: with SMTP id h26mr20102675edr.56.1555095729542;
        Fri, 12 Apr 2019 12:02:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4rQrTlIdMGdEVjesaEYv3MY6uqvdXp+Z4dsKt46CACxXlZdDA91tzc1lvZqix0vI+GIt2
X-Received: by 2002:a50:ed9a:: with SMTP id h26mr20102638edr.56.1555095728817;
        Fri, 12 Apr 2019 12:02:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095728; cv=none;
        d=google.com; s=arc-20160816;
        b=R9zLU964FVZQomRV8+NhVJ0t+1KxhE8s0JynjloSSFTxwBD69S0fqtMBdirgVtVp0e
         vJ22Cl98cG9eNFb3ky5gedOcJrdCS6G5wIXi3vGH62EWE7xqMf8BPSFRjwVDuIaPU/6w
         diCWDQLciA2NS+KtrQugjN+jpq0iBUxVKT8AmVcXjhbfK1LKtzQXVqXMnW2Bnk7wdW0K
         Y67ek9JxTEg2M7ekSjC8fbe39ETAqYxVAl9LoIEDkmjx2xaeS4Y/GSlnKoC/u8oojKOs
         VRuyDDTZ4oGF8b0b+cDfZBnBk+tQ9n3GP67on/GHjaBS2RRuFrLumD2VvyM6dF2UsxDu
         /kzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=70luTOh7EZPm2mdLSlvwP+/XxOOcCyBYqtiI7hN9cdY=;
        b=Rm+MdgN8/lLr6hdOQSnurp9NOsmgxj/01hj1/wR/p8PeUgrYeAXWzDdAawzfFf7pB7
         Uagcrd8ktT1ZL2cA0GZZ3f7HtL4xI3u2wE7w4H9Y0fedLqQHE3eeJYegv0A80x/woCYS
         wiGBZPey7nWHq0uCl3uAPorrvqIqVAR+V2VKiDOP89cxeiHhXUHfSQ9AC9VOkMotnXGl
         WWZUFBzCuBzeyNOnNsfS+hM3f2KbzqUHSmsRQWzdDchGR4lAVzwkjIrCpykirpVFKcsq
         9mv1xSYQwwik7c11wVJ7wT66Lb9sybdeJOaMy5ZKoeFnAw8VNj9XKjRsZyH+wvEga4DB
         TAgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z10si11626030ejr.238.2019.04.12.12.02.08
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 12:02:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C004A374;
	Fri, 12 Apr 2019 12:02:07 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2069E3F718;
	Fri, 12 Apr 2019 12:02:05 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	oohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH RESEND 2/3] mm: clean up is_device_*_page() definitions
Date: Fri, 12 Apr 2019 20:01:57 +0100
Message-Id:
 <2adb3982a790078fe49fd454414a7b9c0fd60bcb.1555093412.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1555093412.git.robin.murphy@arm.com>
References: <cover.1555093412.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190412190157.Ovw7xgFp9tPISrYLmMLz5kTFhvUM-Oa1HyGkTy4KHXI@z>

Refactor is_device_{public,private}_page() with is_pci_p2pdma_page()
to make them all consistent in depending on their respective config
options even when CONFIG_DEV_PAGEMAP_OPS is enabled for other reasons.
This allows a little more compile-time optimisation as well as the
conceptual and cosmetic cleanup.

Suggested-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 include/linux/mm.h | 43 +++++++++++++------------------------------
 1 file changed, 13 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..d76dfb7ac617 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -910,32 +910,6 @@ static inline bool put_devmap_managed_page(struct page *page)
 	}
 	return false;
 }
-
-static inline bool is_device_private_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
-}
-
-static inline bool is_device_public_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
-}
-
-#ifdef CONFIG_PCI_P2PDMA
-static inline bool is_pci_p2pdma_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PCI_P2PDMA;
-}
-#else /* CONFIG_PCI_P2PDMA */
-static inline bool is_pci_p2pdma_page(const struct page *page)
-{
-	return false;
-}
-#endif /* CONFIG_PCI_P2PDMA */
-
 #else /* CONFIG_DEV_PAGEMAP_OPS */
 static inline void dev_pagemap_get_ops(void)
 {
@@ -949,22 +923,31 @@ static inline bool put_devmap_managed_page(struct page *page)
 {
 	return false;
 }
+#endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline bool is_device_private_page(const struct page *page)
 {
-	return false;
+	return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
+		IS_ENABLED(CONFIG_DEVICE_PRIVATE) &&
+		is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
 }
 
 static inline bool is_device_public_page(const struct page *page)
 {
-	return false;
+	return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
+		IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
+		is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
 }
 
 static inline bool is_pci_p2pdma_page(const struct page *page)
 {
-	return false;
+	return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
+		IS_ENABLED(CONFIG_PCI_P2PDMA) &&
+		is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PCI_P2PDMA;
 }
-#endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline void get_page(struct page *page)
 {
-- 
2.21.0.dirty

