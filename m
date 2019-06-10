Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67F42C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23F562089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="scYXVmWf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23F562089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 828276B026C; Mon, 10 Jun 2019 18:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B0D36B026D; Mon, 10 Jun 2019 18:16:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DBD56B026E; Mon, 10 Jun 2019 18:16:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 256826B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so6505237plr.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6gDH99Hzm+WVYiHprOTPdFzvuur8Lwudibupx/7wlxI=;
        b=JKUlco0uESJOknprmWqCK84mq6ouiNJ7MxmoELioyU59XI5LhQHJrT3jY9eHhc4AE3
         rMY+qQv5WKG0RxYZ0jUglw3Lbn+z7j7Eh3MRPFey1ncIB2eNNCnfIIYCMVwEvzBl4w+Q
         wBviHc5uDBmouTziPJ9vBOKdkWtScI0owehyJk/uWuQRShrutLjjo7QkGIXMNWNn9jhl
         Sk8B1ac5eCVnvzoX+zVJsWdcI9st4gKb3wrShFoR0DwAdWf4Ju8soETYDz0uphFo+P+j
         RnueR20aaeVR4T6adI4X1LnO2lqHhwnp5/BUyScxpNpLkTh6Y6AMOQu3ciBB8fgAsmYV
         rYHw==
X-Gm-Message-State: APjAAAU9yKZlNdXkQiHolRZjpK3iOtOwA/YMbheSANabzHSFhYL7uF4d
	zrXdSu9+xC4dWfYLHnDCiddGQ14zmJAqAJ50J3pEz4QgXD/WqArPCKGo4TUGzKV7ya8NrDzFYBq
	FIpCS3b0BlZQfUNwjKsgrcP0Xia/2ZMMqTAvE0EFhY1CNLgh2k//UTPd5MSi8qpw=
X-Received: by 2002:a65:41c5:: with SMTP id b5mr18047729pgq.128.1560204988678;
        Mon, 10 Jun 2019 15:16:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxg5HgZHumF5GQwFHzY3acGosmiW29sZND0Voj7IQ5BV7lIAbuXIchPG1c+SLDCgx+TM1pH
X-Received: by 2002:a65:41c5:: with SMTP id b5mr18047686pgq.128.1560204987964;
        Mon, 10 Jun 2019 15:16:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204987; cv=none;
        d=google.com; s=arc-20160816;
        b=DWvRp+y5xKyMcun6PW18y+h+VW20I/wrH2jYOclx7YVDJxvYo/ftbPN6HGf6mIMmXb
         vtWVonrmoUzn6Y+Da/fIcS2Mg1hLzK3QrvYInfrYzyRWc9XXBWevOsVox30znx73Zg7E
         iTrdiqwNrx0dRlDVY0pB49AhUi/BqJ2FLHcAg6PH6pAit51ZlaQWogS22Y7d/s5VC3e9
         LWgK0ze+cIvUm4u2t86VFWj8fNLm7E686foyGZV3DvFKyO54OLc0MhDEB8pe29c+cFTF
         jng/UVESs+8yXwZZnrDuySgCW1i7FKIHtZ90pRsJa7M2u6nkmNgLxsSGeD9GmwCQG+0M
         6K2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6gDH99Hzm+WVYiHprOTPdFzvuur8Lwudibupx/7wlxI=;
        b=uCpjgMopCNj3klJeG2XDaIgqS7UWld4GdTLOeHD1uXr4Tg4Je4lScPhe6AldBa/2vp
         hTmGX+K/uUJNrNUdtdnYmDN7K5ezmAi+VlpqRJNk5wf474AjBdo8QhbWaCPQigxwius5
         bGjdM/NY1KFEO5ge9Rh4tZBeDEmpEqxIjYvlFWGGa8yXLyHtN+R+f9nnWNibYmudr9AT
         iFyGJxNZPb/psk7snCR8rbhig0ggWvCtjreSj7vhoz1fBolErvEuTY85KXNWsn+gO0LO
         G9GZANb1U7P7VMB9DWXFFrKfitS6Y27RJseF/RL1X/Sf57qdINL8RdWf/mZypiVbGIh6
         WKqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=scYXVmWf;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t6si614716pjb.25.2019.06.10.15.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=scYXVmWf;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=6gDH99Hzm+WVYiHprOTPdFzvuur8Lwudibupx/7wlxI=; b=scYXVmWfCxMGuKvy+KYTDnjGoC
	rFeiHHz9ioI6lu9ROaFN8rv/PSxcZimXs1aLGEBVVnPMx2hulWbZUZNr5/Brsww2Nd1FiLPn3g1r8
	lhPWU9/3Rf1xyGqPRohCDykL6Bnrl/Mf0k95KU12Z3byjITtPTYxi7EivgWeTroAOG+lF7GioAT+X
	LK/z1c4rgvBRp71OC3i/3ukzGiw9fXh1CFpWoyoyfzn9NJOywgZT+bx9efDKVYDGt+inbNVikvaM1
	GQeC0G4kfqsjmud6V3Fi0uF/2tATq7LzhJK8X8VqDCkll68xiK1uXo3heJHbBsNx4laQghCgdLo9p
	uenkkJPw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSaY-0002kY-B7; Mon, 10 Jun 2019 22:16:26 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 01/17] mm: provide a print_vma_addr stub for !CONFIG_MMU
Date: Tue, 11 Jun 2019 00:16:05 +0200
Message-Id: <20190610221621.10938-2-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
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

