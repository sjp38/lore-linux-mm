Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2544BC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6B2520818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6B2520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF70E6B0010; Fri, 12 Apr 2019 14:57:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D85746B026A; Fri, 12 Apr 2019 14:57:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD4996B026B; Fri, 12 Apr 2019 14:57:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E07E6B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:57:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f42so209285edd.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:57:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=70luTOh7EZPm2mdLSlvwP+/XxOOcCyBYqtiI7hN9cdY=;
        b=mJDuBRURschqrPP+0HtJ//VSu0PkuFU61zt0elVEJK2QjKL7C7TEsDQ3BQMJkO3nx3
         cw5npHbi3lP2xeDz5G6Kmu66Vk/d5oYWyL8EL+KRcsVnICLhQQlBOGloRKOJWN8AyU5m
         aSrJtwS0QZvEIhlPbFjg5/uefFBAtC2hAtgkJ7bVukrrJCgX3E6ETPzJf8/3wgvpwPAn
         qgHNE+OGSVzSlMHRyScHbOLpnIMDLuEuq6hnlxuobwODaR3XpxcAeVT23oYLPJTHiq/V
         j0jzd1eNHXFTsTcgLG5RcXFM7Whejch5xjVLs3E920/Z9XRcZIC90Z8+6HVZa2ANYVTt
         9y4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAX8uJu6MdVe2ciLRwAe2+rjrBleX/nPlJ2ocoI2YMHqN7NQmcTB
	CZpUF9sosFY60Ma9Jq8mSmqaDnrbQmyJDEX5gW/CTLVSDTw/qOivfg3bXDH6+j4L64kC45tZDT4
	pD9SF/wDoaeU/LQH0wrcYwEhh35JSssnra8kzwvGZwgC+qFs24PJHABOMg3UTfa6T7g==
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr22575384ejg.98.1555095446935;
        Fri, 12 Apr 2019 11:57:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEx+RZXyFOyATyuq3xtBCXOC/AYr7+iLjx95FdT36XRa+2EmH7nzaiccV2zNOmlpiXh+il
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr22575358ejg.98.1555095446037;
        Fri, 12 Apr 2019 11:57:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095446; cv=none;
        d=google.com; s=arc-20160816;
        b=C5sVpksh60QNTrF98H194gRXZCauJH3dvlsLqZ9De5u98Nk9xUPtFQL8ZRspVN3V/t
         esDAwoA/8QfBPPwhRZPWL3+K+TK1ySjdmy08IHfrHuFmXTIZj5l2BZu9vBroaGX60vLL
         j2KcZvxWcLIEMttH33ppDR1G3/XIzfz7Mkqc8fXWp08cAcVyUv9LxrCoHLLh05D5B9gw
         6+LwQUm5FGQswbpY4CbiKPfgESaaOVAEl1ne2tXMUhq8C8Um1PpMTB/cG2xZ/Zs3kCOl
         t66KkKLq7mANxU3eqg6/znj71jQ7rgaFuiVUcKeuFRo+wdLvc3tSIm72jNnv3Ly/11sJ
         h0Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=70luTOh7EZPm2mdLSlvwP+/XxOOcCyBYqtiI7hN9cdY=;
        b=hT31DFvJ6c0sazDzgO/oPuh3JWJv2fDnEsZtyuH1KBW0mdLf5XT2Lug6UUlSTdcZOL
         hrrVgLHC6AdL5M8+BPu0Y5TRtGo8PaeNBctxj2K9hMgnHkZbbGom2oiOoW9jopTLWxSw
         D5YJ5M+i8SMaaes+t3x9H0XybR+Of4B062v1n8ODCN4vt2IkB3s+1FbxzyL+okMYrtJ6
         oflsV2TQhebNthQM2cLV2cePyhl47+TaDPSg7wdeDpVIAMd8eNzVCqtawYhErSb6VjTV
         fkTkpcC+tSvBri1/B875qZBfqKmuVa5LP6KV8LCB+wPUMGZbGCKnenh6aIq5tLrjWB8j
         VKJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f23si313817edf.211.2019.04.12.11.57.25
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 11:57:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1658C1682;
	Fri, 12 Apr 2019 11:57:25 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6D7253F718;
	Fri, 12 Apr 2019 11:57:23 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	ohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] mm: clean up is_device_*_page() definitions
Date: Fri, 12 Apr 2019 19:56:01 +0100
Message-Id: <2adb3982a790078fe49fd454414a7b9c0fd60bcb.1555093412.git.robin.murphy@arm.com>
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

