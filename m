Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4414DC4321D
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B42A2082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="D5+yRbsO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B42A2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C9A16B0270; Mon, 10 Jun 2019 18:16:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 651476B0271; Mon, 10 Jun 2019 18:16:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47D4B6B0272; Mon, 10 Jun 2019 18:16:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF806B0270
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:40 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so6517200plb.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=;
        b=H313gu3gSN5bHa6QT6KgCe1NPNrHb7PJALWNZLK9HnA4owa1sGvzpJst1X4h/pThxY
         ELDRp1msTITqgzSBSzXcFDXBVsOG/H8NcMDYDlbffnecD+CJXvsNuuNiOsky0400g9XT
         kUoeJlqlPA9oYE9c+kyY1YECEXWK/HUWwIHRqfJpYrjp0gkU72bMz0GxwwIdE02QAxG7
         xOMvEw3VqHsO2KahsM7zj8coYNsyfaOyYQJKyXXgV0D+OeuxhP4kmxSXWUpIecFDL055
         5rj2FkNpD0nulwAKMZUjoFDIOK7w8GwPPW5q+MkVjk9Wcjz96OVAJ/p4mzst37+GMxAc
         3rvw==
X-Gm-Message-State: APjAAAX7KHhcgiWJVVv6g+hFxQMZEAZXDpA7CSAbGS7Wtj2BjmEDf5MU
	hsYjvvPlwutiWovX4nUFuXh4sj3ylFXKc9My3N4MGyLj4KSXjqhLzO11EngW7IUy6VWzLGAfx6e
	e8S867depepkfXuo4TIo+YKZwXfBn1pZg0jDm+lEHoWi+D/ATk2Hk0eOJRtouHIY=
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr70359882pld.271.1560204999736;
        Mon, 10 Jun 2019 15:16:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc6WjKPTiR9ZeBe2XnLtreipyl6Be3yfMimlypsQOwtlNaJkxaO2dpernAH9ngxaa2sJq/
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr70359828pld.271.1560204999085;
        Mon, 10 Jun 2019 15:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204999; cv=none;
        d=google.com; s=arc-20160816;
        b=AfqOwiXQfq1RUtrWEpqc0TRWtxfBQuj0BKEgOLMnA770jOj++AgozT6gkCNJRvCHlL
         HpvMSjdGX0TggvfBNBUWh4talRbwRAYv6MWfweZDZ4ho0xEzmyBMq3D5pelIWqNFrPV7
         83gbWcb0nSB11BqH8UCkNhxTTbQPbpvHDtW557N1+Wdn76dzSdoUmjVYV9IjS54rE+8h
         n1wX7r11UPyQePQE3tMEF7LzRHo5TLrdC/MilSgAEZafDmdz4INpmI3pBbjfQU1IRcXX
         BrDUuK7994TN561t0+stlTjU2Esvybe9h+LfZ1SOyerkSyjnpO5nE7FApeJ/KUAZQByq
         zNmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=;
        b=yEbNDzw86Fpan87YLn/XVaNgPRXIMU02ufJsl6mVvLGQBakUXJeKNCaKprGp5MPlBo
         mDW4ZJqMC8fTCn/5kcQROLfqAA3EgOj+pukL+fjwh644FijMSkYyua8Tid/UozaNlJ7c
         kAc3afl+NqA1HhukOMzxvFQcCnHfIbtzWBIyJNrOqZonY73b8qlCnnOqTxwBrnbx2r7I
         B+l1TSs58rlaCUAFUuHMlYJ50CAIpBQAsAsNWivxTUWlqxSXpqbucWFh5UJ7VF90QMNT
         f/rQFFXtC6j/TWK6rj/JaBD4o3crzPKVbwlEJXmmQONwgYTKdv1t+n4Ni+HorLzpUQI0
         nZUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D5+yRbsO;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l11si10828352plb.369.2019.06.10.15.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D5+yRbsO;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+l3vwi8bsor/tja9ZheW5y8DiiO/mW8k6zhZ4E83rTI=; b=D5+yRbsO/hXCqiKm2GvUbz94il
	/dNuqNwQmY5OQ3Ooit1Dab7teOpa5SiJPGelycZTu9GahSBTZF7KAFO9aMS7Yo9vzp0wvNnWU2YER
	Jl7nJeGUXhv5mckZ3JshZ19lrBeL58sJoBq2DLT2uxLb8B6TB8Zr9w0Z887+4PacERH+davU/yhMM
	z+BBG3Q5yD28cUJNPYcQRP35undVWKo6/Cex9urNZAd/SsQEgP+rFv9s+c44hRMWRFy/uH1/gXTh3
	XRU+FrgIA9iSjaJISHcDOy2bJYZRaw4jhH+9wiNBGMzFOzx+VmfFWBnSZTanK5IzjjNwXvyb3mhZr
	/l1MDpMg==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSai-0002vE-Ng; Mon, 10 Jun 2019 22:16:37 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/17] riscv: use CSR_SATP instead of the legacy sptbr name in switch_mm
Date: Tue, 11 Jun 2019 00:16:09 +0200
Message-Id: <20190610221621.10938-6-hch@lst.de>
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

