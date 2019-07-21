Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F398C76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3CBF2085A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Dp5kZOZA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3CBF2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CC0C8E0006; Sun, 21 Jul 2019 06:46:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 556218E0005; Sun, 21 Jul 2019 06:46:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41CB38E0006; Sun, 21 Jul 2019 06:46:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA2B8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 06:46:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so12731807pgh.21
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 03:46:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n/2VHsc+nvnGVRHIDyk7RkyeOeUNMmmMgaK72876yAU=;
        b=rbY6B9bqQRKJgs7rNSv4zvxIy4pbpzWT1/GFYAC7FqzZInefJej9lfhUtYFC7983la
         OTayqpr85EckZ6FWnd0j9JZOR9sOeU16LXvRQ7en5kxTv627clsevhaZYnPN+3/tXcMf
         cyiMogjy4DP0wERLMsd5mZbX7DivlX3t8gQHKi5UCKSoVi3lNGCfTZ+ohUJ+tuaD6/TY
         dCLlnhSPijdJZ4hQMaoerAmh/Dyo2yMNYx1kWulhz+d81rUxHoXSIHDZczsdOm9Nr7mm
         yC1+xS8QRz8yxbpjv1DRCsRjK93ey2br2DoG+AoQ2o2p5xhDa3MLYEgWLWbEBOy8VK38
         LnWw==
X-Gm-Message-State: APjAAAV8UxVah91elbokBEH/+udVjvl5Uw0dp8XOVLoMFy9ntWvRp9IG
	oMg73BVfJTTBQq5dH4f03Rc/lccPaKBoiwCPqJZIsbDQFVHCKOf4RTz669HKb9z1WZsgE5fg1P8
	c7byRc5iYG7g4czGT8DMaXRfFQKfAL7w/Ib7bKFGdfRCViNAXuFbisXY5Rr+TfuJZ8Q==
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr68951512plo.312.1563705976589;
        Sun, 21 Jul 2019 03:46:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQZPDCyxD48EAgwB+E4s91ivOMaVQVNWHtEa2Ov3DXHfi/JKrReEdaOE2wpv7CyseSuWwg
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr68951467plo.312.1563705975829;
        Sun, 21 Jul 2019 03:46:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563705975; cv=none;
        d=google.com; s=arc-20160816;
        b=T4SkMyCMJ41z7wA3346KF9JoZI2mQblXZnrKXOa7ZJdWmFUb0PDr+8LMPXJMHnD9iG
         s7uQ1UPUI17UMEF965GD9IvSGtdKBYsaHhzOPY0MhBJHzX5vHdiCS46SJW9P0wpYTgWf
         wgXwMrJ6zko5lTGc+fkSNxyF3G9YnvrbeaVkkTWMLd7iS+QBb85DTCgItlHIifXn3JSC
         id7LkyRYTOL+m8+vwW2RpXNzTT2JEs9S8Zbv6jarSPmICoVpTdEKArULwV0kWcBbWH+l
         L5mDssKuYJiwJqXiZBMgyqZRxmLIg4u7ERxzVsAawBYvfKL/EV9yBfh5WdecRr1hNJfC
         oxEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=n/2VHsc+nvnGVRHIDyk7RkyeOeUNMmmMgaK72876yAU=;
        b=vkGLv0iN4I72LTFP5l1S5lOaUe/bErte9G9gWG5xXg5HDkw3ZduLcZ3wdmRLrmPjMR
         joZR/R12nA9/6PRLDx/S8Jr3n0W1cSMobt3GgOg84ET88RktFE+jHHoFw9AiUtcA0yeh
         EmWwWXXnZbIhCs0/ZzVcEHlghq3/hDW3tQxmmimZvIJnNSe2lnk0bowrmSG4zP9L/y+8
         YN7MbREfxDzlI5eQQ+IJiD90S6P0W+iCyu2YfVqK5eskWRHRaN/rSJi7YJkZJvMe1zmH
         lFeStInUc5nulipra7hmqVVXbEDPhej2Y08VagOSNj4dgVTy0ja3q4Npv/mNTB2uPNg8
         nYRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dp5kZOZA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j1si5371906pfr.52.2019.07.21.03.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 03:46:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dp5kZOZA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=n/2VHsc+nvnGVRHIDyk7RkyeOeUNMmmMgaK72876yAU=; b=Dp5kZOZA90ifh7qp+w2f6pHi++
	xXHj9tUP4uJgKj+cY7zrZAXCNjqnPz6CQsKvTSIQYyWrMGbvLbDVWdSoxQ5eouhkWtGBtvr8KSE+k
	guMlY5fXIMdjtG1LY64Cdx3FJPFXrdHDalivdzbEWYmJvzaIhtJpI0UvZbqTGCmO4jDulIK+h299Y
	SpIU5xlgM8UW2+bzNIzJBGOsZdh1l3Yg8FIY8g6z3D0DudY3321qfukqabK0IYppygUJQI2hD5qF7
	Q6qDN+pjs4T4mWd4IaxFOm9kvB+DouYVRpMXuUOVWj7YO0CvSavN+kxEBxEaecx7mvXfTF0va9I3V
	HVPme7fA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hp9M6-000504-Pd; Sun, 21 Jul 2019 10:46:14 +0000
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 2/3] mm: Introduce page_shift()
Date: Sun, 21 Jul 2019 03:46:11 -0700
Message-Id: <20190721104612.19120-3-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190721104612.19120-1-willy@infradead.org>
References: <20190721104612.19120-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Replace PAGE_SHIFT + compound_order(page) with the new page_shift()
function.  Minor improvements in readability.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 arch/powerpc/mm/book3s64/iommu_api.c | 7 ++-----
 drivers/vfio/vfio_iommu_spapr_tce.c  | 2 +-
 include/linux/mm.h                   | 6 ++++++
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
index b056cae3388b..56cc84520577 100644
--- a/arch/powerpc/mm/book3s64/iommu_api.c
+++ b/arch/powerpc/mm/book3s64/iommu_api.c
@@ -129,11 +129,8 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 		 * Allow to use larger than 64k IOMMU pages. Only do that
 		 * if we are backed by hugetlb.
 		 */
-		if ((mem->pageshift > PAGE_SHIFT) && PageHuge(page)) {
-			struct page *head = compound_head(page);
-
-			pageshift = compound_order(head) + PAGE_SHIFT;
-		}
+		if ((mem->pageshift > PAGE_SHIFT) && PageHuge(page))
+			pageshift = page_shift(compound_head(page));
 		mem->pageshift = min(mem->pageshift, pageshift);
 		/*
 		 * We don't need struct page reference any more, switch
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 8ce9ad21129f..1883fd2901b2 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -190,7 +190,7 @@ static bool tce_page_is_contained(struct mm_struct *mm, unsigned long hpa,
 	 * a page we just found. Otherwise the hardware can get access to
 	 * a bigger memory chunk that it should.
 	 */
-	return (PAGE_SHIFT + compound_order(compound_head(page))) >= page_shift;
+	return page_shift(compound_head(page)) >= page_shift;
 }
 
 static inline bool tce_groups_attached(struct tce_container *container)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 899dfcf7c23d..64762559885f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -811,6 +811,12 @@ static inline unsigned long page_size(struct page *page)
 	return PAGE_SIZE << compound_order(page);
 }
 
+/* Returns the number of bits needed for the number of bytes in a page */
+static inline unsigned int page_shift(struct page *page)
+{
+	return PAGE_SHIFT + compound_order(page);
+}
+
 void free_compound_page(struct page *page);
 
 #ifdef CONFIG_MMU
-- 
2.20.1

