Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0807C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CAD1216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="K0d1or/U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CAD1216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAF516B02A5; Fri, 10 May 2019 09:50:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5E476B02A7; Fri, 10 May 2019 09:50:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2A886B02A6; Fri, 10 May 2019 09:50:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84A4A6B02A2
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so4178429pfi.5
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=SRc9kn+HFVEFfAHO5FxSDOwPRCh50tB+PZDD7cIygmU=;
        b=SW7unpFYejAQwEkCLD77jyCD3OnY2jPf+DSlUp0alRCeYMnHmlByPXDRJ7JktBIx1s
         fAcjfewCcYa54XyDDb2UGLArCCUL39WbFFVsM2jDI2rq6RrhciB4VkeAjHt3bhEl5di8
         YfJSibGEzxXtLK+LEpJTQ9H+tssU88v62fwmz4NIFcRgopC66cGbyLgDD+zGo7ByfwM1
         q0RiWQ2K+fHJdukHIo8Sfkg4l2MXKdrH/gLfe/4DwYH5+7Djk7/188Do6BdnPKjZkt7S
         UkCFyTz5ECLDRIVJfT7wgvYsYOu6ScvDvk6o5Q4/klr5ePcPnTVcJvtVrjUdpsKWj5nG
         n3ZA==
X-Gm-Message-State: APjAAAXleaTLQWFbB+sJkmpw1smg4ijQXwy7yRcCqwq/rc/eIVUDg6jG
	Rsp5+ikCFLj72uGBZtMkkNFYz8H5513zJPBLiXsqyyMdZEDTrm8uD0OjXN/Agay3BJsWwwpUJcR
	JKBcPsKnFmFOCFP+ic3m2a5fRuHLSLT5nQgKuo+OUsyVFGbismu73C+lUrLx0EFG9Ew==
X-Received: by 2002:a63:754b:: with SMTP id f11mr13839355pgn.32.1557496256188;
        Fri, 10 May 2019 06:50:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhoT26UzMuyEc0/gY5vKKSs1z8rH/N4F7FSeq8tFlxqM2DLFry4t0+DXcLTC0/37sQQ8MZ
X-Received: by 2002:a63:754b:: with SMTP id f11mr13838130pgn.32.1557496245490;
        Fri, 10 May 2019 06:50:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496245; cv=none;
        d=google.com; s=arc-20160816;
        b=ZJ9DQ9ltdzT2YgqwjrBUAHSBpanD8uDGXECeMwQxPVCkSvasLsbp0EI1lSBbxpfRQ+
         AlkmDz2RjhuNW0nDlrb90wo0YhQTHXLJVLd8QN/oWGZPrig18pYvLVWU1z4I0IFII6m+
         cq1+0+zhStJmNgEjtdAR25UVNpG9nCLD8M5W6cv0yOuzzDx0rBySl8qUBZxtjnTKDzEC
         CLfSLFEZtDHY2ofAU7qtWqtLQ00lfLuJwDD0Mn1n8NsSN0Iwoq1FJ5LEBKorqR8pDvKb
         6oyHNzMdIjGZi/WTsXdW6m2JYj74lu007l5rnRN3BxkNQoJAA7D1miDei+V3WEuzAqKD
         04Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=SRc9kn+HFVEFfAHO5FxSDOwPRCh50tB+PZDD7cIygmU=;
        b=poZG53A3Xir3S0m92HUZ0jTAysA+HK89BGw/xklQfh453vDTPOEbUUn4I+kYiArw0m
         Co6+dRtp7UGMojTaMPka6AGfox5x4Uu9dzxyiFtdb65fdjBRL9ZaifC6zX3//cXdHGdP
         7VeBXAj8mT4ttTcLNRcKmHIrCKtrQ2l62snaG6m5pNCsNUOw/sX/mxFuK65DtipqaOqv
         TZKxGjivixBlGyvim2o73dlv6gZtnIAuELax1txr55X8nlFD+phB2HnIspjMpAAr5ApV
         Z35MxsyEV6brErf2zcUCGu5I8k3OSd5Yb7Q8rMLsnXB0GcvuSxrE1Vt3P75zmYr+tH0G
         zPgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="K0d1or/U";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12si1537930plz.280.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="K0d1or/U";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SRc9kn+HFVEFfAHO5FxSDOwPRCh50tB+PZDD7cIygmU=; b=K0d1or/UF5n1nkGyTfKVMivL9
	WUIJ+mPuFcUQDWgtAC4xlPYzgwg7TpUuBZ3bgobWRZGdYar48/yopDYzy5Hs9g2FHYtjo6tqkBHQ6
	Wt+r0OvksQSrGqyDpys1agi9j9zD0elp0Zvzuo0SOBUHjZBZ9d8gkletEcIT+wNSSKEq2aUKj94sY
	CghSAZzmfuPaJgwio/i5mzpDYosiFsDKZ0zMFKkNE1YE2v8HjLHCHXcdMtvoCCUQxm35VMox4fXUY
	2WjqK995+1vcbxhMCEubxnen2oEr0ggC1u5G8JE8IegCUv3nciI+nkZslIamxtxuz2xeNWY2IHxtj
	zlqOap34Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004U4-Bd; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 08/15] mm: Pass order to __get_free_page in GFP flags
Date: Fri, 10 May 2019 06:50:31 -0700
Message-Id: <20190510135038.17129-9-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Switch __get_free_page() to be the implementation and __get_free_pages()
to be the wrapper that calls __get_free_page() with the appropriate
argument.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/gfp.h | 6 +++---
 mm/page_alloc.c     | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index faf3586419ce..dac282ac1158 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -536,15 +536,15 @@ extern struct page *alloc_pages_vma(gfp_t gfp, struct vm_area_struct *vma,
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, vma, addr, node, false)
 
-extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
+extern unsigned long __get_free_page(gfp_t gfp_mask);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
-#define __get_free_page(gfp_mask) \
-		__get_free_pages((gfp_mask), 0)
+#define __get_free_pages(gfp_mask, order) \
+		__get_free_page(gfp_mask | __GFP_ORDER(order))
 
 #define __get_dma_pages(gfp_mask, order) \
 		__get_free_pages((gfp_mask) | GFP_DMA, (order))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e968ab91660..eefe3c81c383 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4693,16 +4693,16 @@ EXPORT_SYMBOL(__alloc_pages_nodemask);
  * address cannot represent highmem pages. Use alloc_pages and then kmap if
  * you need to access high mem.
  */
-unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
+unsigned long __get_free_page(gfp_t gfp_mask)
 {
 	struct page *page;
 
-	page = alloc_pages(gfp_mask & ~__GFP_HIGHMEM, order);
+	page = alloc_page(gfp_mask & ~__GFP_HIGHMEM);
 	if (!page)
 		return 0;
 	return (unsigned long) page_address(page);
 }
-EXPORT_SYMBOL(__get_free_pages);
+EXPORT_SYMBOL(__get_free_page);
 
 unsigned long get_zeroed_page(gfp_t gfp_mask)
 {
-- 
2.20.1

