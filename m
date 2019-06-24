Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0E17C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B5152089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="X6al4PUP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B5152089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC726B0006; Mon, 24 Jun 2019 01:43:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84D4E8E0002; Mon, 24 Jun 2019 01:43:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE2B8E0001; Mon, 24 Jun 2019 01:43:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2276B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id u10so6697972plq.21
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=;
        b=jnaemqpwnNPB/pLqTJVHeLwZ1jk5P4Tzt498iiCteRS/i962W5I9HRXQKVrMyyhFqU
         R9wle4Qdr0DfbHMWldoyEZXF7vKiKjzWMbT0wi6j+gN47EUpqX4MbH2XrJlulT7fYb4R
         QxpQsOgnJOpzb+FYgIyDqA0tVG6aT0uAUrbrHVFrwnZRXgYFVs4a7alo/iBZyGDOQKJZ
         +V91Av/sEl7uK3pqDhaB8Q9MEhjlLHxGX+1EgNBndXmYFQA+5bgLVwBQVi0C9qGOqCc1
         lqu1zzI5HYLrs+5ALN5CmjGQVDsP57KLr59G+MOpyKSH1Zg37y929aMbCtxCJvFTdWck
         LlLQ==
X-Gm-Message-State: APjAAAWwEEmqtZVOj+PYfT7WhBw4jQVXLdEsGmogS3JpPOVVlsRAhsi0
	MG9XHpWRKt7FVm6g/MQWz8La0ejvDJILh+B/cFvf4b00Gnw72pJ2EP+WiX6PQW3+SWtm8HprDyQ
	ClfxoLdcGZx0ZBpTSEI4vHyaYwxbN5jFr1Ei1VIoquHGR/dGAoIPIlGdmLwbQs0Q=
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr49098374plp.95.1561355003830;
        Sun, 23 Jun 2019 22:43:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytUiRbzAtVQa82mhCY8D/HFM8P0FMV2QIYtqSeVSdy1qzniV1mOMjovpCpZpkX5+wuA5Bb
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr49098281plp.95.1561355002114;
        Sun, 23 Jun 2019 22:43:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355002; cv=none;
        d=google.com; s=arc-20160816;
        b=w6s0YhHojmN9l3g6LJR+GQnr3D5U/mdi2JVl4e2HhXcNIg3/XS1lXdcP8aVYPxq0+W
         1n7ZTfpPEPWJi+dzVDcJJLBkqA78EN0pc/jINtMn+wMH+KFvsIkllEIKEmLILzKXUkU3
         u6ATlfcKYI38drDLGe9C5Ls+uRGm7N2dMx95c0N+LajmQutr3dFNRIykMzLRECg2Ao4c
         iX60khFfg+0fOq3ovyEf0segO9ttT6PO85EMN/d3zPtYYEfPbajCMdQ5AIVflLeR8zef
         bvZe8MWBQ+UOa9MtRqm2e/Hq/EwdFC0ovutDPni9pF5kty6TxBbzx4aq0WpwHt+nz+yM
         59TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=;
        b=WkSKakf3z2LvuwkZm9LT4Bq3g/Pl7MAxpHaXmISJYMD/d6lnmobD3w1Vg2ZH7JSsCy
         DIV77eJ0d9eghxoUxKj1+VymAS8BPJ6htn36ImdTdPrLp5DubyasbcRqYNxe3wAFI4dc
         mmzxgmFGqbDOy5AVr/G06CC3nBnJvosFtEtJ7udkxO+OPG+UhYxWXKHBp75hxMlw1yMt
         MxMoiHiMUaWOitHb3x6OM45oxpXTr8Mi4vzP79QV6mPAvVhuHaH/7ydosocJb6WuBI4e
         ShVRHJQi4EtdsSI/ShslpBQB9ubHV42UpANX439l4j+naxiOiSgBfORgC6YzXnw2ZdW+
         lFrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=X6al4PUP;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h15si4511857plr.23.2019.06.23.22.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=X6al4PUP;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=; b=X6al4PUPrJG3GXXDCc+GVTzTlg
	2TSkJtcBJThDHIeyPeJiS8/uksAhamtWEZqHOR7790Zoc05bZD4vgnQfeFrUhpgVmS6Wtj34h+Zp8
	LauTUq5EVZOKR9tSXliqJAsyWJ+cFEkaJ7oZfe4j7mDAwtXbxzD6go0vThELFfQTkD5IxmXoNvw0o
	L0gFZrRUmOexC+mmTGo11vv5/KRkjFhwZXlKYQGHpUZD90U1hUU3pTX0qmaYFxdQRVfkjVqmPirtZ
	pukuQReHO+bDQdEoXqU6Ycu/nnJkbAVTVnG3qUyQ0Az1wVOLQPr8aw2Y0GyezJJ14dT8hSXtMfQ9y
	0CzY8sZA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHl8-00064U-KY; Mon, 24 Jun 2019 05:43:19 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 01/17] mm: provide a print_vma_addr stub for !CONFIG_MMU
Date: Mon, 24 Jun 2019 07:42:55 +0200
Message-Id: <20190624054311.30256-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 include/linux/mm.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd0b5f4e1e45..69843ee0c5f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2756,7 +2756,13 @@ extern int randomize_va_space;
 #endif
 
 const char * arch_vma_name(struct vm_area_struct *vma);
+#ifdef CONFIG_MMU
 void print_vma_addr(char *prefix, unsigned long rip);
+#else
+static inline void print_vma_addr(char *prefix, unsigned long rip)
+{
+}
+#endif
 
 void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
-- 
2.20.1

