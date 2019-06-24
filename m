Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12F80C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C269F2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aGN6dTub"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C269F2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51AD46B026E; Mon, 24 Jun 2019 01:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A3A68E0002; Mon, 24 Jun 2019 01:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F62C8E0001; Mon, 24 Jun 2019 01:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F023D6B026E
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:44:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so8871575pfj.4
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=;
        b=coHwwRbiwtER7Y6bvPfHltIHaUdFRn0Y5P//nKMzDBBo2jZdpgdjDSun4Pr0I2JBga
         N1beBAIr8YiI9m7HgE82HklbzQeQ09stjYY10Son0wTdmAsNvopdOED2uHZ6XADDRLWD
         TEnbRk61osCPVqc9KWKoz3NMq7+UqEOr0PqC3PKm2JTPuZqcf3AW9A+nMNQAGZgRyKu+
         F/VnjuR1w0cUEBcRmVjX1FEEAPnojdu+PmuxD8WEJQt3ptalRHtyhMP1gKKVnagbpZ35
         69O+Tx+tYd/HyY8bZzatGtymd4xveVHiJtBfMJu3iemSSicbh1UMt2fSFH4EospHfP4C
         1yiw==
X-Gm-Message-State: APjAAAV0jlDcerW1APdEDCZUk5HuIePfDoR2V4O5u36jCne0GMZhJnmt
	Geu2FISbSSgtbFWeb+IgjGk0mrKyTr5tqCMRIRVVWPnA46AmDJl94sqT7nrqn48TXcRImqVAhUT
	2Ide+Xx43GpGasyXBI/6w6/gONeVBPEAUoZml+xGGqD60qsCdgWz56px04XywpCc=
X-Received: by 2002:a17:902:b594:: with SMTP id a20mr1747159pls.259.1561355048675;
        Sun, 23 Jun 2019 22:44:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzv6t69oZYIvS94VY4/QSetWIrTkiD5mOvSSb+xu/1BrMfS3FQO41iIR+jLR+LnlgC7GVwS
X-Received: by 2002:a17:902:b594:: with SMTP id a20mr1747131pls.259.1561355048045;
        Sun, 23 Jun 2019 22:44:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355048; cv=none;
        d=google.com; s=arc-20160816;
        b=kLWv3xIw5WUCt4OHRKr7NalegY8QFfKK44eokCZEbUl6Sph96k50LzCDlKtCF+X3de
         jOJ8GdODSHTO1jtv7ck1U9sRXjMp6Q+w8555u2o+PklVtnNCTOLwPZtvWzTualL7Naes
         NsrJItjL19+8rC630+j8Mbupid20MY0z7hpBSDPApLZNXAGBji9GWB6YjN/eefFBfitU
         2UlghpFuMHIJkcedTRRBBZBIMu6Q6usAa3EYR11Za1t1wmuO3bHZIs8Zmk1uCa/cFi67
         qvfJR8Q4nU+hXIfj/yMRvMG9J8k9pjjGc7WHsX3CcgSbJrRKeOn4tGRNwT0ZU4OQ8eld
         EVMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=;
        b=0zzjZgYpUBUusKA/xEJoQLKJv9YlNScz6bBae1P7iEq/IUUoWpnzgAPOxO7IOdg56D
         njI8lUpPe9AESuRzP5wyUqmqer2fhNBpyM5jCSDYRBvk2ZrAXY2O7byYqIm7COZWOXEk
         +VN/9pc7HHVkhnm6wAGrIH44iBkHvSw5nb+x3QT8dq2Y/ifubvBuOaFLWyj8flhkEqyy
         tJNxAl+7XFUP3h8yDjcdL3RcGtdZlf8z3h2zOlSMDbSN2QvRb4Va6TWWL379oIKCoYYf
         95wIIw1xvrjwH94cXhLT/6VfvxsOhaMLDQWw95yR4PxN2rUJ9SPINaurNoLSmgqqZFBS
         u4mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aGN6dTub;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d31si9363045pla.84.2019.06.23.22.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:44:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aGN6dTub;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=; b=aGN6dTubD0D69mjO3WVEYJFyjB
	5y1YlY/6WZAOlD+aKcYvIOSCcaua7/aYGOliKS7XJuG4hrrjZ8LENcRaGw3h5Qxcn3tfYP+glU6+8
	mawXoplRfU0xqHBf5u8/l3kyzWnAhIMkD8V+mrzNMUQYSaO+kjzJcogITGDZnZKasWvnBP9oNNDgK
	hj3dWYDaI2wLnybTsj2wZ6SjoTGq1z5k6vzU9VlJQhSORsNP5/hU0NvVargMZNfFhht1yqHP2bUto
	Utoklu47DO5TT2RGMSMPZhgFQ9KoMDLkL98EyoGYczUHATr8gAs+6BZbwI6bJ6VBLCCW0dmXV/Ie/
	GJwuemoA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlu-0006sF-4K; Mon, 24 Jun 2019 05:44:06 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 15/17] riscv: use the correct interrupt levels for M-mode
Date: Mon, 24 Jun 2019 07:43:09 +0200
Message-Id: <20190624054311.30256-16-hch@lst.de>
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

The numerical levels for External/Timer/Software interrupts differ
between S-mode and M-mode.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/irq.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/riscv/kernel/irq.c b/arch/riscv/kernel/irq.c
index 804ff70bb853..9566aabbe50b 100644
--- a/arch/riscv/kernel/irq.c
+++ b/arch/riscv/kernel/irq.c
@@ -14,9 +14,15 @@
 /*
  * Possible interrupt causes:
  */
-#define INTERRUPT_CAUSE_SOFTWARE	IRQ_S_SOFT
-#define INTERRUPT_CAUSE_TIMER		IRQ_S_TIMER
-#define INTERRUPT_CAUSE_EXTERNAL	IRQ_S_EXT
+#ifdef CONFIG_M_MODE
+# define INTERRUPT_CAUSE_SOFTWARE	IRQ_M_SOFT
+# define INTERRUPT_CAUSE_TIMER		IRQ_M_TIMER
+# define INTERRUPT_CAUSE_EXTERNAL	IRQ_M_EXT
+#else
+# define INTERRUPT_CAUSE_SOFTWARE	IRQ_S_SOFT
+# define INTERRUPT_CAUSE_TIMER		IRQ_S_TIMER
+# define INTERRUPT_CAUSE_EXTERNAL	IRQ_S_EXT
+#endif /* CONFIG_M_MODE */
 
 int arch_show_interrupts(struct seq_file *p, int prec)
 {
-- 
2.20.1

