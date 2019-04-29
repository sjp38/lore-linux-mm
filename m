Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43928C04AA8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF259216F4
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF259216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6762B6B0007; Mon, 29 Apr 2019 13:22:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625AF6B0008; Mon, 29 Apr 2019 13:22:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CBBB6B000A; Mon, 29 Apr 2019 13:22:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC8E66B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:22:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so5136031edy.19
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:22:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EGw7+OH1x4FPPC/oUKCYcTtdBb+/Z2Qy/RRdJBfjQZI=;
        b=RWGQPIfYqRRfb7guUfG+LjQBvLTmSl9MbKkEcByWclc2m4nGV61Cz73QECd7LtCEiq
         dPx+PNakJPhidGDxBy49pQVPnLx6FXZor9m+vdcEwi/jpjW8j2eZb9bdydK49dkkHBLY
         iGUPYHc2QWVNDLr8eb4cSTJktB3t+xEKjN9BMQZf+bR46Hlvs6oc6zUz3qGweFlibmMh
         9fB2JwnPKAKNOhXSH8IIqYXeI0vuu8+CtsHpYyCd2UiYsSSEt+ta/pcRlpHB82cTW7hM
         mZpdmMAkIFt/iw4Pi/y/8QfIGPz/Ui8NKDnjwTkHNlewjbtbVVZpHSoTgeGrGNxQZuux
         56/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVTe+oVx8l/l02J3YdJACVjPTOqJjNnjSlRqTge/vCekyeYOdII
	wqBzAaYQxoW7WZXDy9tAZDUd4LU3pHxUoveihkQrAaKHWjKiSPXaZgizOQbsnbxh3uYXG8Sjfz9
	ghjuYZxhOLJHAnb9FHuvPeL0kT1n68wdPFWUm4GZNeFCNgPiyRdtyAU9lUUK/TZ5qQA==
X-Received: by 2002:a17:906:1c8c:: with SMTP id g12mr30651078ejh.97.1556558551428;
        Mon, 29 Apr 2019 10:22:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlCF4mF/uZnoGKW1GQl5noR/FQhxnh4ZUp29jwXz0lMDD7jG1ZAyCLMwxzUoligrHFJjzp
X-Received: by 2002:a17:906:1c8c:: with SMTP id g12mr30651050ejh.97.1556558550555;
        Mon, 29 Apr 2019 10:22:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558550; cv=none;
        d=google.com; s=arc-20160816;
        b=Tg9ovJBC9gdNAEiAPChDPYebYvPxsAJ8R9W//WJ2WyRnFQFeZF75Gigr7vUTKqnw29
         NgT8fB+3gyJLlIx3lJtzEK849e4rZnnRTqPV0RfWS90bz3e0Xo61Gqz74QJgwjX8G55W
         8qtCuffXw0LmQojpRPf+qt5L+2aj6M4ZUhctZmkv8CVhbNM3EIf4omMbEvqWB2js/Bnb
         2t+IQMEN28jrm6jx2H+sfoDl2DBlPLhpElveWZbNPv0gp9DDiCyaY0Orrq3YJPHX+Wjk
         MOKJp4P2sJyT41o1Q5BIS1g/aAXjhyug0+tRewtuJXMvesylMJb0KXHjZfpw1YACfNxV
         79Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EGw7+OH1x4FPPC/oUKCYcTtdBb+/Z2Qy/RRdJBfjQZI=;
        b=0TCBwe8cdV/++FoKDmeJdvb2kAYnw7V/0SslfqgLof1fFW5vVKT3NZLT5g8ewRRye+
         qe3q3ZCbEESD8H8oZNEHGUa5izq5DhSzzaQd/22Og7DOPWqerxjDvYJXBbcYsCCyrZI4
         igl61uetPP/sWIJegZg3ceV/xnqhK6heytqhlJQ6Hvqoa8mixmr4omq09PBkjgtklNHG
         i/PwL7HsFoI65YR9QiNd657clQAORSrm8bI+4cpMiWooqi7LunxO6ov6LhMMXaPl54nn
         qPYYFGoDxspItAomGmRzgBQENM7CnoJOt/IsFNtzKh66GEsde0TLq5Du4/k7+6tTyUq4
         3lSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z11si278934ejp.297.2019.04.29.10.22.30
        for <linux-mm@kvack.org>;
        Mon, 29 Apr 2019 10:22:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8B4A8EBD;
	Mon, 29 Apr 2019 10:22:29 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7079A3F557;
	Mon, 29 Apr 2019 10:22:28 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v2 2/3] mm: clean up is_device_*_page() definitions
Date: Mon, 29 Apr 2019 18:22:16 +0100
Message-Id: <4d00e3aff0192dcfef244a348d8927f06ee3f394.1556555457.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1556555457.git.robin.murphy@arm.com>
References: <cover.1556555457.git.robin.murphy@arm.com>
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

v2: Add review tags.

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

