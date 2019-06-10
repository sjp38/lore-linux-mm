Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E75C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA3382086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WoT5qfZO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA3382086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 430536B026D; Mon, 10 Jun 2019 18:16:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 394266B026E; Mon, 10 Jun 2019 18:16:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C5D6B026F; Mon, 10 Jun 2019 18:16:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA1A16B026D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b10so3498404pgb.22
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=oeA7fdOZYlM85rg7g7leA8Pnr4eyrodo4nJKqUJy11eSBhi/1eivUsRVtIUF+AzY/K
         zjhm5iYAPiUvC92OMQnEAGH2ede2Qmv7iND/FBqHLlMYUmDyX/1RuSkylwUqirEuUm1/
         /8kEBEqfcfdwAZ9Zzuzv/lUcYAEbWx/o/uyL5hp8Ybts4TAjXsv70zH/KhxxBazNemQI
         tB1RvAlPCNTkHPIeyPOBdgtnklcRSiYPRVk/Qpse987Gvo50Nr4GCX+TwpoIBorNYheV
         3oO9KjCMY9KoicKQARMghuVhTRnYYBZhk0Bk+CrwnulvSNzbotbGcw4NBN0BvJx1gRT9
         ur4A==
X-Gm-Message-State: APjAAAW+7yfe2BS91M3gih8X3OV9PbpAe0OMPE1qWSMFuHmVaTlGefLl
	K8JmyZ/OiunQ28uLLF11qHQHt8N0n4QOpWg28PLGP5eKOel0yT/9TjC+qTk1S+gzfBBow+pOq0/
	gR/cofgbyOozbeAXuueCnJXfndsNKA5Rf3ZPpzi2Pv1AJzAvkNb+MESxrRiAbThk=
X-Received: by 2002:a63:f402:: with SMTP id g2mr16869887pgi.197.1560204991482;
        Mon, 10 Jun 2019 15:16:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgcypFPeS0Y85ujlwOCb6O3Hk5iNGSULDKRgqywMFVX+UCufBBSF7CC0KgriO7cQYkI0JQ
X-Received: by 2002:a63:f402:: with SMTP id g2mr16869844pgi.197.1560204990771;
        Mon, 10 Jun 2019 15:16:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204990; cv=none;
        d=google.com; s=arc-20160816;
        b=iXrFYowWYUfG85+8wEcIbb5EveJrY9gKXOM50Yx8JNMlPF7im4Ptq95CdYztMe8cnZ
         wcr+7Qf3Ug6a03O4Z53wDz+6LuUgMyzzvY50wsKolC9gd7Gn8wCmT/9+xZhQ4FUUcwh3
         lOV9LkcG4YXYwysglXkCBIID/ChpNLp+DITp56N5EOjgXp9w3LdhufqrB8chU1k9R1vW
         7XkH/Lzm9buK0NWZZSGKkzSeuBqztycYY+b0x91yut9jCsGpAshFNsbU8g6DWdvAyf7q
         fOY/jK+C6/dGJ2BnM2RN1649ZLsHu5LliUklGtoLTNOuzwUjf1Rjh+s/WmHE9wU7EE7w
         ouyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=fDFUmwNPsAXq8Gxk2vefNLljUFyJ11QDAKmvuf2yH6pZe6V8+CmtYG/k4E6kMh99j3
         MKZl8I10OS2Wlro7yNbZJd9hb6yDv22snM1B31kWalVM7975PBxutVo9XPLPz8qLS5Gk
         LIhR2PXnjLQCBwBugpjfF+oQW2ch7kaXI3jGxCyGWJ9bYji/cW3rqyfc3KlFvjeMLQR6
         zbRynp7uTA/tJX7r+RrZtXjiuRRRbi56leeO7/SMn+ofXtnyvqaaS9GfS7lkrk2yn2g7
         oS2+RWKnU2Gnh908pSr0xR9I2YZumXclRApPxYy5ScRwedsO6uqFXWFlF3uTXcrC0QOj
         T0jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WoT5qfZO;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w36si11182905pgl.540.2019.06.10.15.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WoT5qfZO;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=; b=WoT5qfZOaCdlI5cjodJO96MTUa
	0x0FTUYOBpRsHYygY/XLRcYru1xwfiTUOH/aiIMRbNiEB0rWP1GO4Xk2gH/26HqDQe+j2Ybm6u/Rv
	hupkRFH69Ysbq0FC3igQAwsbpJU618sqwSYdNRkyNM58whYGLdOuZJih7LYrSSzsRQCkMlyedKmp1
	ApZeHTypJnTEPZDUphxKWpF2bD7O6bBM0bMcDdsTblUbbiQq7uHikPzv7wXg0izoJxUurD2y92zv1
	LM0WfD9mxU80dyyv93OBxyEnVWpfoleq8QXyRkJoWLd4bGvAAP2qR00MhSEMk9xXdbgybODC2RYFM
	ypkZtJVA==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSaa-0002mM-Ql; Mon, 10 Jun 2019 22:16:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
Date: Tue, 11 Jun 2019 00:16:06 +0200
Message-Id: <20190610221621.10938-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The whole header file deals with swap entries and PTEs, none of which
can exist for nommu builds.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/swapops.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..b02922556846 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -6,6 +6,8 @@
 #include <linux/bug.h>
 #include <linux/mm_types.h>
 
+#ifdef CONFIG_MMU
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -50,13 +52,11 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 	return entry.val & SWP_OFFSET_MASK;
 }
 
-#ifdef CONFIG_MMU
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
 	return !pte_none(pte) && !pte_present(pte);
 }
-#endif
 
 /*
  * Convert the arch-dependent pte representation of a swp_entry_t into an
@@ -375,4 +375,5 @@ static inline int non_swap_entry(swp_entry_t entry)
 }
 #endif
 
+#endif /* CONFIG_MMU */
 #endif /* _LINUX_SWAPOPS_H */
-- 
2.20.1

