Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F54C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E83C2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fMawuu3O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E83C2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 875556B000A; Mon, 24 Jun 2019 01:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 828A98E0002; Mon, 24 Jun 2019 01:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8518E0001; Mon, 24 Jun 2019 01:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3889F6B000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so7730461pfn.5
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=;
        b=m7EMl+CYL0IvyQ1rIBJkDHliKN2yH8GTwtOBdn9b6TimLif5+M2vW1+qafeW+8Kuv9
         0Iot5Wk61gJC4dqk3BH3mJVpRrQ64cF5OF69qH8DZGTat2VTYysj/Zpd4Vn2/ar5Ao5H
         oOMYJ9YxbnJOptx68H+VfbwBVG9mKISOleyg6GKIH7BRW0HABK9U5dF353DUxKy4e4Qu
         Y4mLFF9Q8ExOWmMvvNYCg2r46b56GwcdTi8wBR7TfnJEM0DMHeWotBOmJZbDoVcvDTvK
         Wp++XNtrdQ5XzgNfwvmPEVFyCGr+M3/7ruNMZeft8BQ4630NTqw6KNNdUijHiGRcpL5f
         S5kw==
X-Gm-Message-State: APjAAAWYz0jf7YKYRYCHfKkx/xF7dRltMWHeQnDbx6a5O8+fzL8zOn6H
	4128MhufJgYeVwWfK4i8wjBhDsgVoeO2GDbUg0T2Vy1lpk+vc05EXE/7x8CZEN9b8rjj9x4iPoG
	N7W6dYKCZhgfICEgvIgOC36ZfHsXxVFllMdHl5JhybK+ZdbrTf8nyk3IeHCqGshM=
X-Received: by 2002:a17:902:9a06:: with SMTP id v6mr126590331plp.71.1561355011936;
        Sun, 23 Jun 2019 22:43:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF4Zk91TP1MN6SUwV8sd6k/ioG9RPddAdTF/PhCC1/YvtC2Hu2JATlAjZudawhnA5rYh+S
X-Received: by 2002:a17:902:9a06:: with SMTP id v6mr126590296plp.71.1561355011312;
        Sun, 23 Jun 2019 22:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355011; cv=none;
        d=google.com; s=arc-20160816;
        b=g8BkWHw1xR+2IePjy3xLMlF8VGjrOvpK8/PD57Eya5vyVN0Jj2rOoW2R6SW1K/t4UX
         LLvQyVExnN9zqG2+dqjN2hdl1U6EK0l7htd/T8RygTg08KoBqDuBsKJ+Vi7NgdM8up83
         pkh3iPe/6LXj+xo6w9QsjR5y90ppbwSCSLj0uaKn0YYcO9sRZOWzEMOV723GRMIBTXkk
         nG0012zklYh7bfmnU8KLXbJ82e/z1Ns+IHuq1MwemD133vFEl1/IhihnHx19+5yMJGE6
         Vb9/2pKztoyK6LPbcvnVqmzSglPKkoTpCCvSN1EaSqgD88tz2SUIdlvnsTVlimlM9YDS
         uRBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=;
        b=S971J1WgGKJ69AiYM18meSYJAjXlX6pZPnX+ySFmokTio7+OMFoT3z3iQ5PvoZBhVd
         7rRr9juaYE/dl4XVug/FL/qfJJWdNxoTUtwWNIOkq+5GsHdXPzG4N9uy+fMOpC84Vgwa
         ZBc5uYh6NyS+zCd7sky+ZsNS2VR+wxcV2xRk1o6Po/oRjQjwZtDrl+DvhrpMzEeIZPvU
         BZlaMm5+J2F1yA03SwmqUYURvmT8etpo3b64cvGE5q3GkK+MfWMskaynUn9Epbtln/gZ
         RTEUkPKczFbJtwMcFvaKyFrpi8PtJHVoqtjTIvDVz+D77ZywqkiarnKd/06sANWwvNxT
         /wqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fMawuu3O;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 31si9532924plf.195.2019.06.23.22.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fMawuu3O;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=; b=fMawuu3Opqat44vDe3HBjfC2NV
	U5+fXW3mv7s7Jlh5elWKOcphZfFUedF1vGm+7MYpefOZ9keuy6mkobCiyuiWMY5CLEcGsBYr3epoG
	m757TAQi2HxXtEeXw31FzGZsYfQbEb96/9Ia45hV6LD8/DMRBoIc4DCLBiY6bHE3E/pVumBkLBY5w
	zQsrCXvA58a8v8QR10iyNRva5OtbMApi6LzDxtYh6XUzs8CFb1qIBB/sbzkWkI0sjoTbtb5hHeHM8
	YgjPe0IwJKPuJTnzuw0MJiDrV8RqIWDzx9q3MB2qJlJKHNWksaE9721c9vrJkODjAmgxyXQOo4sY+
	3XbUdhVw==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlJ-0006Cb-Dy; Mon, 24 Jun 2019 05:43:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/17] irqchip/sifive-plic: set max threshold for ignored handlers
Date: Mon, 24 Jun 2019 07:42:58 +0200
Message-Id: <20190624054311.30256-5-hch@lst.de>
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

When running in M-mode we still the S-mode plic handlers in the DT.
Ignore them by setting the maximum threshold.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/irqchip/irq-sifive-plic.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/irqchip/irq-sifive-plic.c b/drivers/irqchip/irq-sifive-plic.c
index cf755964f2f8..c72c036aea76 100644
--- a/drivers/irqchip/irq-sifive-plic.c
+++ b/drivers/irqchip/irq-sifive-plic.c
@@ -244,6 +244,7 @@ static int __init plic_init(struct device_node *node,
 		struct plic_handler *handler;
 		irq_hw_number_t hwirq;
 		int cpu, hartid;
+		u32 threshold = 0;
 
 		if (of_irq_parse_one(node, i, &parent)) {
 			pr_err("failed to parse parent for context %d.\n", i);
@@ -266,10 +267,16 @@ static int __init plic_init(struct device_node *node,
 			continue;
 		}
 
+		/*
+		 * When running in M-mode we need to ignore the S-mode handler.
+		 * Here we assume it always comes later, but that might be a
+		 * little fragile.
+		 */
 		handler = per_cpu_ptr(&plic_handlers, cpu);
 		if (handler->present) {
 			pr_warn("handler already present for context %d.\n", i);
-			continue;
+			threshold = 0xffffffff;
+			goto done;
 		}
 
 		handler->present = true;
@@ -279,8 +286,9 @@ static int __init plic_init(struct device_node *node,
 		handler->enable_base =
 			plic_regs + ENABLE_BASE + i * ENABLE_PER_HART;
 
+done:
 		/* priority must be > threshold to trigger an interrupt */
-		writel(0, handler->hart_base + CONTEXT_THRESHOLD);
+		writel(threshold, handler->hart_base + CONTEXT_THRESHOLD);
 		for (hwirq = 1; hwirq <= nr_irqs; hwirq++)
 			plic_toggle(handler, hwirq, 0);
 		nr_handlers++;
-- 
2.20.1

