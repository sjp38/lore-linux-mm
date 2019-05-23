Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C73AC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DC332175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DC332175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 083656B000D; Thu, 23 May 2019 11:03:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E3A6B000E; Thu, 23 May 2019 11:03:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E179B6B0010; Thu, 23 May 2019 11:03:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95D186B000D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:03:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so9473651edz.3
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:03:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MS3bRiad9Fep4WHmQ9etJt6j6qqU4xpmR+31qYwLW3Q=;
        b=DeRCnDiGPGhF7SHw1JUbkcnOVhS5c3E1fuAlBTFC5IPiwa4XGmeHWZ3ad3FRuug2vw
         LrQFtft+pULd+gUBS47y2v4QREwuNBpy7lGWl5M+D157sqGBR3pkh+LxInvmqELsn3qU
         yRfamGgRKe0OcOK1QKi5l9C4oGBqTDy3c8T90gQw9XDzwNEMUhRLUld+nQrPeNeO2zeL
         9QOW48Zo8/DiPeRPx3MK06Off6wOz8xHMQ8DAt9FCbS+vn6zZKwWzk1VR+PcvcC2x3RC
         F/g5jFGq6N5TQB2Q6Iym4rYKZqik9wlllIn3Il6UxV6eECAv8Tj7DBxovYEB2WoX6XWS
         89Pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWtrV4oiWgj8QHSGB0vq6WznoHPW9QfOw2jm/YSFszJhdQsndzC
	hb/9IinyRmv370kJnilkSTmMFNpfEPZV6On6cpQJSxQfvIbQkeyJAKHT8SVb5u1xODzJYyMB42S
	TERphsGFmAxHecxYpBNXxCChJwJ2oGIQXeD5q6b3uJUI6S61oxBpyX0EwaMDYpEpgNg==
X-Received: by 2002:a50:ad98:: with SMTP id a24mr97413509edd.235.1558623810860;
        Thu, 23 May 2019 08:03:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIBzoLtlYfiOPFBxmh0UW/f3BJClG9lI29JaTvifomDcqs0b0F2LxeO2tjgNgJUcK/PP9M
X-Received: by 2002:a50:ad98:: with SMTP id a24mr97413346edd.235.1558623809414;
        Thu, 23 May 2019 08:03:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558623809; cv=none;
        d=google.com; s=arc-20160816;
        b=b5XlIlGNLuKX9W5YSzIdMNzxRDsZVcdnONn3tWGX8FQO6AN1YVO2JTR1YfAuWi7yv1
         +I3SoyjgFASusWKHqz7sswYOm2d7iZD2ceodcujNqELf2CQv+ImrF+tRPOSBTJK5GIO/
         su87H5ICMrWmykPotYQx433LzF/waa0otqDDjpUI3aWXSrcU6JF8dkQ3480+OtcpVyUI
         qsVL0299cP7RGeert7LsfYz9Olp4LAOcIjEt/oNjCsK1fnVIb69fR7gWYStlDnv9eC9C
         1b9a+QojCvIX2pkzrhtbPdYRaZxQGeKpi8w7oL1SyM0sdQLed62zT+QKXuyu1QVFVwMx
         a0zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MS3bRiad9Fep4WHmQ9etJt6j6qqU4xpmR+31qYwLW3Q=;
        b=XKWEeAfB8xVgaiz61GckJSOLyOdR09f96QFhBkH07JrDLZfwFpQd12YUEmyerUexth
         QuBqoLGBES4wl74jlw/qjTCPmfjBhQ84FRSJtz8GuzX6KWFKzl3pia6ZcMZSH1LoTrsk
         C3GwFMymQKwcYhnyk6K39KLnSeGjrco/26DeWezbsBem4Jj/dGhdh/NJ9Nw02R0sI9np
         q2jnGl92xlihWjKGnjdk+lKAVPRBYz9OHARSTWfAAIbBmRS8C66IYUII3Q9e3qsSC7SR
         RWZiD7TwakvMlLh7pB7KbVIR8XALv+Kfc0jP1CVwslCH16KGWMgMkqv5XzObFvS5tuNA
         U5Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k13si7518215ejr.389.2019.05.23.08.03.29
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:03:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7383AA78;
	Thu, 23 May 2019 08:03:28 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id DF5823F690;
	Thu, 23 May 2019 08:03:26 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: [PATCH v3 2/4] mm: clean up is_device_*_page() definitions
Date: Thu, 23 May 2019 16:03:14 +0100
Message-Id: <187c2ab27dea70635d375a61b2f2076d26c032b0.1558547956.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1558547956.git.robin.murphy@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
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
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 include/linux/mm.h | 43 +++++++++++++------------------------------
 1 file changed, 13 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..9cd613a7f67b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -942,32 +942,6 @@ static inline bool put_devmap_managed_page(struct page *page)
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
@@ -981,22 +955,31 @@ static inline bool put_devmap_managed_page(struct page *page)
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
 
 /* 127: arbitrary random number, small enough to assemble well */
 #define page_ref_zero_or_close_to_overflow(page) \
-- 
2.21.0.dirty

