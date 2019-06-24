Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70CBFC48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 341342089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mAvADQ+c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 341342089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEAD26B000C; Mon, 24 Jun 2019 01:43:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9A258E0002; Mon, 24 Jun 2019 01:43:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95FC78E0001; Mon, 24 Jun 2019 01:43:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2CA6B000C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so8656514pga.4
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=;
        b=d1kQGqThxpnY2dOW9jnL3+2Nmdkf3QfHw/4glHsNq8gHQSkVAv0hs2rfYCjdZIzsby
         Rs53lTtEUaAFyHXNb1oiQlzV/Rra0w5+pkqSzRKghPdjnZzE87M0dJlFkNZip5DyOfBB
         KKQ+BVxDXPcKISCPJjFffNJYKf/moUu7TcZMJm6ekdNMBfinDM5zFuMZg1hfkgvyhBIK
         Wol4Q0gJPftR6fcl6iryTIKP5Ml3gNTjT07F4X3bedA5k7yj/D11dWsuMY8Y8zG+DFyC
         QsI8WQjuijGRUEOWHrdsY/iOxL/0gVqy57cb+PBqXR0zqUREfr9XOcKvE5VabUIRoP3k
         mCqA==
X-Gm-Message-State: APjAAAUxScIkd/hOYw8N7zBdTtm7IalrDoiUOZJvHfjfdiJZdZBswusy
	XdRbTBEuyXA9A2KkDWXDPi0RG1kS79ffFinJsmlhJPQMDrQ+RfKB9YxfBjNFTfUICSMz+GyvVa0
	HinaDfgDX6rROG3ANCzNMepNU69hSUGqHe04fNXBVKWp3bSkuBhrAyok2cbMJlRg=
X-Received: by 2002:a63:4d4a:: with SMTP id n10mr25503356pgl.396.1561355015880;
        Sun, 23 Jun 2019 22:43:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRpSa8egB44ZhzGuHXSc9m34KUWRyHUs8nXSUxyLldkbe4wwhv/fJEKzq8a7gcbNeUFpTt
X-Received: by 2002:a63:4d4a:: with SMTP id n10mr25503321pgl.396.1561355015170;
        Sun, 23 Jun 2019 22:43:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355015; cv=none;
        d=google.com; s=arc-20160816;
        b=oxA+onsqcOwAkR/i9tIrJpKjHHBQhr/wjNrq2UMgkRxUTe0Aut2v6iZLlrchk9jvqA
         bXLYEVSh1FRW+RPFEnAD00rOGt79yqNYBVXh/0MNeqJR1FlKgqoAza9IzrlQ24T3bFWi
         u+DxXiOCocNhb/ABxqyKzjHHDoUtyZe0bHQLFjA2wgGBVRznSiHeIwTyltXO1zlGYzPn
         W0PnFOd74rRcIVd6P8CPQUFugKlF9wFJbjiRzsxFC6dZ5bj5CAddpYsziG+boE/ikFfV
         WA7JjUilEaAJp9Y9jAgHDNgzNq7yJYXZACfpJsYr4GzNIF0DIsNXLaY+nUjUaFhAS5qD
         owdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=;
        b=hI9gp6tJ4N/+d+4RRS9NrZ/CIdzuEE4k93r6xVE5O6ybvg9k/uNCajgyqnaEpTTDkn
         a95RllwTrjbJ3HnrqTfxwLgzG9c3qv1SsnT0NWrMWSAjCsTL2I/EkTrbIxEaFgBZzuTH
         COg7QNvoIn9sdXdbYjfI6dFuoVlO2iELjNsA0eDATvng8g1Nyx7fkfCzjxESC5zl5tNN
         foQjXqFzDsTh7xED7Bv1dpdduNTeNzRVBypqVrX8F8ZbtqxDNxoc7d9IOBVxWlo+J6eM
         YPU+RmYQwmIt5m0cBR0Q46Iffky+ZBWb2zcs2FUL0bQ7+DW+456ZGsTSZQjOjGHxQL6P
         fPSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mAvADQ+c;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 6si9627376plb.345.2019.06.23.22.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mAvADQ+c;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=; b=mAvADQ+cwTdSv+lt/UrCLAQIca
	0dD4dqEu4sMMNiFBL7leKtPj9jibj22MJ0jwgHB3KU5zu4mlrT2QfCgV56BTu/m9YZiG5Nr1uUm84
	y1PwMD41gPqcy/8w1H7CcUsZnBbdXBxDp9rR/8b7435grnEb/8gn616L6xirlmp6IkDOHezq54Jci
	M+NToc3yEOIoREpCO/yTJs29tuZDuvF0ETJp51nUCIKg/w2K4HNxKopP12CaHADIOpvmDhFTgD5Qr
	WovcnekXgMnBwUh7ex4C90RWdFHYis/U2RnDWbeNGhclz0LrvcsC3mzmXItVAbQVafsOja8CpIj2P
	g7pyPeTQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlM-0006Fu-LS; Mon, 24 Jun 2019 05:43:33 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/17] riscv: use CSR_SATP instead of the legacy sptbr name in switch_mm
Date: Mon, 24 Jun 2019 07:42:59 +0200
Message-Id: <20190624054311.30256-6-hch@lst.de>
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

Switch to our own constant for the satp register instead of using
the old name from a legacy version of the privileged spec.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/mm/context.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/riscv/mm/context.c b/arch/riscv/mm/context.c
index 89ceb3cbe218..beeb5d7f92ea 100644
--- a/arch/riscv/mm/context.c
+++ b/arch/riscv/mm/context.c
@@ -57,12 +57,7 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	cpumask_clear_cpu(cpu, mm_cpumask(prev));
 	cpumask_set_cpu(cpu, mm_cpumask(next));
 
-	/*
-	 * Use the old spbtr name instead of using the current satp
-	 * name to support binutils 2.29 which doesn't know about the
-	 * privileged ISA 1.10 yet.
-	 */
-	csr_write(sptbr, virt_to_pfn(next->pgd) | SATP_MODE);
+	csr_write(CSR_SATP, virt_to_pfn(next->pgd) | SATP_MODE);
 	local_flush_tlb_all();
 
 	flush_icache_deferred(next);
-- 
2.20.1

