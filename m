Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28FE0C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB0E22082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VLiBuzt/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB0E22082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826B26B026F; Mon, 10 Jun 2019 18:16:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D6EC6B0270; Mon, 10 Jun 2019 18:16:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69E426B0271; Mon, 10 Jun 2019 18:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCA36B026F
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v62so7768932pgb.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=;
        b=seiVrDnGAefQbFhzwd0xCknVk18o81vrpUvrLtwv4yy2KdkZ0cuGvjEZWZHPt4IQTY
         53UYFy4oQMi5yuCaqTmRIDcUHvWO2gH4g2E8LZ/3Vrsj+RAmivLNA5caZVxw+3KUJue4
         M4a0wZ3Uu5UBDJnXTmBp+K0a4Ky7CuA7OOnKwGzg0oWuZNAN5zDSE30fLXijAnvcVQN1
         ifhZrqSiVYu4UWgtB4Mc+7tq+R+QSkVm7VppEHd3zzZvU1pQo2ewMXp9l5YyEF4Z06v8
         MRB25qDQpL7bL4LPyF/vDpoBXYg4MZhNAue78H4fqrFg3Rf5gQl29O0Sd3C7fIgWrnW4
         XFQw==
X-Gm-Message-State: APjAAAXMb5kLa44Zd9AvXRTdIVAKI7EU6NQLy3JlE+NJERhZKHugZ5K1
	CXvM2I0jjRamM3x72LRso4BLX7JdE16w35cXTEXslzQzp5iWTXMqY2dVp/idTIlksANThrxWADj
	lrL9eSDjcIAIH+igTfggohsadZAUV+8WIvVVsiFB0x91JKJk5DC2fAesGZ1NmZow=
X-Received: by 2002:a63:de4b:: with SMTP id y11mr15785184pgi.301.1560204997736;
        Mon, 10 Jun 2019 15:16:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEr432rHrKteqC9iHQN/NwUuIWELs4cmuZLCFJaMMdIov4n7x191j6SNFKPiRBA1vngFnZ
X-Received: by 2002:a63:de4b:: with SMTP id y11mr15785138pgi.301.1560204996868;
        Mon, 10 Jun 2019 15:16:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204996; cv=none;
        d=google.com; s=arc-20160816;
        b=Bn9fBnd1MdAaPtUScy3e3gXA9oZG129GtDh7Hq7n4p0XaUy/9zOUVz2PnAx5EJqbdv
         FbaAsH8KQFz6zwZ87804LOEla6uA1fS4uiognvU+JTllvHq7qMfi81yTTwa93XWnOP3D
         vhqHhGXWipNXPCo+TSNQcOmIiAbi4VT5mkjeUQaURmkBZMFoeq3Yd8uiYpvUhLXAW5wM
         CxAvGdCrMbo4G42rM/Iz1EQKx5Hob3j+wjPGia+nQT1yTPllBvWVC4uLnlU1d7ajyDY2
         BWSoq8VVN5U59xy3X420HlZcuXVN75kuCLIYAWHOoZ+6BWVls9Ff5T/FZ/IFxUiNLED5
         fVcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=;
        b=Ux4wRqLPhBKmwyT1SrGfraxtqgihyvM68SsbulRP/fN7ImxC5ie0khijt8WzUQCqqF
         gLILkk3avbAXWuPLpQKsuQVW5uhFKPtogPahXO8ilcujVd0jfCbe3q+iOj+joSpF85oQ
         v1BQjS9HDcjyBVG/XbuqZezsX0G0YQESFU0Z49QC7BJdR10tCh/uAzikd+qnvaX/5nS0
         64V0b61jDrJ/f4WQCnKtRmeJS4CJjonPaROyxffsvGsQxqDd3UirJ+X0/r7c84q0eN/B
         +UgG6UYueHXyL2BP9Sns/Up3CZZ4ahmWh57r4oC0reiqoftXzadBTCrJB4ySSYKRqDCj
         rIFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VLiBuzt/";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l67si12190132plb.370.2019.06.10.15.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VLiBuzt/";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=vOVF1bL6OtEC3ny1W9eKFWhCTN+KLHMSW/CBbgd+PKs=; b=VLiBuzt/vCbOSNdVx6os79JBD6
	vHnKMpAQlL5AlNNNY6kUIEWo3mmYqMBif4P0/ZHxfLKNTWQE6L38hwoB6FM1F0ZA1KeO9BEaW6pY3
	mBFPUsqKlrtVvcfV6lhyDH/+kpOVNYu2XTmKzyeQOZJaVctSjzYIB/HsBFT04XhYZJ+yQHtRutUyY
	rlgjDy+3bo1jIA+zRDuX+K3H/XbszJ2OvhsNR50E2XE9haoeTXtRJ4q+QHlPLGvTWXWkeubhxn6eT
	LE8gxz8rM992Eh6JzZVeQKH71lO4dlkg6DVCB3M1WB/+EcR9ZHteJP6TUm4Mdw5IqZYEOLkf0fSOg
	zKJUUySQ==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSag-0002rx-26; Mon, 10 Jun 2019 22:16:34 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/17] irqchip/sifive-plic: set max threshold for ignored handlers
Date: Tue, 11 Jun 2019 00:16:08 +0200
Message-Id: <20190610221621.10938-5-hch@lst.de>
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

