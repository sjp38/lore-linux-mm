Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F09EC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC0C216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PsKqXUcN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC0C216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1C18E0010; Mon, 29 Jul 2019 10:29:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76D928E0009; Mon, 29 Jul 2019 10:29:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570068E0010; Mon, 29 Jul 2019 10:29:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 223358E0009
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i3so33256978plb.8
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UZ1iiZ91D5ta7woyBUt0JspQpjAYy1irdMsZOOrHXMc=;
        b=h8R5FjYEZJCx5EQ4DV2+5oyqo2k1SNPxEAS1h32stv/pS4xG0kWyVJ+Rp2alNbRJ8h
         xWiSD23hX5g75Pxga1HxdFpe7OO9i6W+aLeUYJ1Oa01OQeERvKP4cT0w4yGsIaJTK/ft
         ZjEo87QT9FylO0gpmCtnXv+JSTxADRZ0Zx4+vzO4swm+VESmBdynFMPlu1BxAEDDUiFo
         +7W1Hmmr21QqLqJpo2KsHry0vyiD9uvGWuufwKGXWBeeS+mV58jFwFCK2UaHb3heU/ly
         Je6/XXKLaVXnTJdnxkTjb8FKIpCoMAc6oOt5hLrqAaglwyj+VG7WdxSakuS42Th0Wrs7
         5stQ==
X-Gm-Message-State: APjAAAX0HHDFvKu0H4PXua4DzWnf4olRQZNuNtdfTz3w6p6rCQKrsju7
	X9e9gwZWoiO73iWyMN2jRH7KIxk9wLE1jApF8Dg6oO03nbM6ZpTNNcDZudjl+I7Q12Ssnb+/U8L
	Uf66kJbNnpuij292qJYgr/MYCIktkLK7qCejyehoMYj9PjVLYK60MscAWgCg1+Qc=
X-Received: by 2002:a62:5c01:: with SMTP id q1mr14555960pfb.53.1564410563833;
        Mon, 29 Jul 2019 07:29:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwza1aiYwxT/1REW6jljIS3XfvAYKEvxX5ZiRZvukSPOrX3yt8QLj7HnpAfX1TYET4Q0g/N
X-Received: by 2002:a62:5c01:: with SMTP id q1mr14555904pfb.53.1564410563040;
        Mon, 29 Jul 2019 07:29:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410563; cv=none;
        d=google.com; s=arc-20160816;
        b=0/P8iRwqTk1ioQrHTgoVxj978hoygjxaXwpMriRZpeSD1V6QOOJvqi8y65erAGmofp
         +4NVh/2pbwjkYO4/g1p5RpKCos8reasEdk4FAyNlc4L/DGYQ/JMFRg/4GmjhhRw1BRwS
         +1NInU2ouVOhBK4BGwgzri9Qv815GzwATD/GWvaHPG66OubHTmRrAFelwWQ9xU1P1iBx
         V+/slJsRTeF/34iJ7dELwao0icR93RHzB5sVRY622ImV/bJw5JXWgHH/2+xoZth7moKz
         WhxNXm9BeX2Eo17uqzuas8jNr0q+++t83xe/H7Yq/bJcWMSOPscqhSlZs0Em7D/xAyjm
         +ZlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UZ1iiZ91D5ta7woyBUt0JspQpjAYy1irdMsZOOrHXMc=;
        b=L8Ev3oHZWqHGJeLveO3cAyjmW95PH8vkjqA7gYuzt0vZtB2zIhnDB3LWN/83+8gaK6
         IMV8aL3C1qQmXfbzHWwdHeOP74V2b8Tf+uXHBE6JsG3yu3ayX/AiQ/ZbICsLFwO9Vnq1
         SWrEDdXia7fVxEOxPvlAKJSxzgKmGj/y9j9nHYvuEJJBsKejpkCxEI7xdfoMCqojq+DV
         vnt98xRkzxBKv/p3xmu8yWT0l7SizTg15lTCuwWAUgzYO8eHA2xY/o1tmyBAfXK3/vG4
         Jgo8dDpmmARDBW2VuKQEaAPhQKHnkBfZSYMUfdatMY1uMbz9wksb2szfU4uD2x+DRKkH
         m/Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PsKqXUcN;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a13si24824883pgn.359.2019.07.29.07.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PsKqXUcN;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UZ1iiZ91D5ta7woyBUt0JspQpjAYy1irdMsZOOrHXMc=; b=PsKqXUcN7z7Xz9gU7L79usjrqd
	1TEUjHamWsPT+rB4y+/yJm/EmvCFSl7ml+1TBJeGQpJ7BwVxO9wF2ewwlhrRVlZhQ2fn7eM4nvSru
	Htj0+NqPiUUfos5bsZ+wlkRab0SxVL9RrtXQZ0X5t45PUuUj7wuHcCn43N+m+i27dIdLRZryJCjb+
	p41WXKWECLMO9LZLn3XL4a/cY1LJKbqbDtDs9Mnwi1jx/mtoDZJwIzftrtvBMEa3DqdCL4xlxrb9T
	Pn5dnuGhyiDr2tSO2dx5kndNT3pjthrpWfVIQvSgWUpbBrW0LeWUm490FPAwN1pfH7BrK6o7UT0aq
	y3B5AiUQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6eN-0006P2-Jm; Mon, 29 Jul 2019 14:29:20 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
Date: Mon, 29 Jul 2019 17:28:43 +0300
Message-Id: <20190729142843.22320-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142843.22320-1-hch@lst.de>
References: <20190729142843.22320-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
where it can be replaced with a simple boolean local variable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/migrate.h | 1 -
 mm/migrate.c            | 9 +++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8b46cfdb1a0e..ba74ef5a7702 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -165,7 +165,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_VALID	(1UL << 0)
 #define MIGRATE_PFN_MIGRATE	(1UL << 1)
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
-#define MIGRATE_PFN_WRITE	(1UL << 3)
 #define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index 74735256e260..724f92dcc31b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2212,6 +2212,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		unsigned long mpfn, pfn;
 		struct page *page;
 		swp_entry_t entry;
+		bool writable = false;
 		pte_t pte;
 
 		pte = *ptep;
@@ -2240,7 +2241,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			mpfn = migrate_pfn(page_to_pfn(page)) |
 					MIGRATE_PFN_MIGRATE;
 			if (is_write_device_private_entry(entry))
-				mpfn |= MIGRATE_PFN_WRITE;
+				writable = true;
 		} else {
 			if (is_zero_pfn(pfn)) {
 				mpfn = MIGRATE_PFN_MIGRATE;
@@ -2250,7 +2251,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			}
 			page = vm_normal_page(migrate->vma, addr, pte);
 			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
-			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
+			if (pte_write(pte))
+				writable = true;
 		}
 
 		/* FIXME support THP */
@@ -2284,8 +2286,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			ptep_get_and_clear(mm, addr, ptep);
 
 			/* Setup special migration page table entry */
-			entry = make_migration_entry(page, mpfn &
-						     MIGRATE_PFN_WRITE);
+			entry = make_migration_entry(page, writable);
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pte))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-- 
2.20.1

