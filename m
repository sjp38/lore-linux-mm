Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C010C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 331DB208E3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qU78Z5cn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 331DB208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ED056B027B; Mon, 10 Jun 2019 18:17:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69E1D6B027C; Mon, 10 Jun 2019 18:17:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4F06B027D; Mon, 10 Jun 2019 18:17:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23B5A6B027B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:17:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bc12so6518679plb.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:17:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=;
        b=kOmovsEZLK1ReDmPwzbCZYfWXHyHp8RRrUDR36mHdaDsNbqawCL+BFF80WjiPnyXtQ
         NlD+Ol+XA8y46qtxOXt6rYR4JLsJ9Fbhhw1deUC0hMVQn0aZ2BYWjmloagaP+Hmnm32Z
         GXDM58lwM3VCWv6l+Gt1oXS3zONTso8blPNmvOZ25y8ZR1viGLqKP1dXtTC09aPlTUYd
         bjOaZDuJLtsT2yg9V9GFw17zAiTZd3n06Oq+HSemNQhJuMrByG/PoOth1x6RjFh6fvtQ
         H5+/x3YIFlBtAgc33s47mZuRnBu6521Vlg61loMCcvtbtwtIxLF+pBxluFkaCq4Z4D0R
         5/Ow==
X-Gm-Message-State: APjAAAU9TdjCrny8jtnBRHeeMym/u24QRaloiGwWz/xiF8M0SlfsHwv3
	6b/jWq1Rjb9Tl0RwrqshMj2gAt6+q4MtY8uZDWr4lT+6X7mOYHKp5xRPGin0OrVWd8p+esykr+N
	aVRhPAixAhl078xvBfDf7EiGc8/rnN49qnaLqAjVFbXcQWksKcz62eoQHUDpzXWc=
X-Received: by 2002:a62:bd03:: with SMTP id a3mr19627271pff.209.1560205029818;
        Mon, 10 Jun 2019 15:17:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVXu2BC+UL+4b3NPAY9GxGYc4JNo5A6tJSJUbg8P8CjYuRMALHaT3kXyl9yEDF/EASOuBg
X-Received: by 2002:a62:bd03:: with SMTP id a3mr19627217pff.209.1560205029160;
        Mon, 10 Jun 2019 15:17:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205029; cv=none;
        d=google.com; s=arc-20160816;
        b=atxeo6eYxBJDAbZOBMTjrbXVb9moVRahIOzNEpEf8iL07mtynEYJu54GScA40JR3z+
         gMdCWHzGScwPfn87GrvSnQIgX5PS96PGZumm0W+iIo1YPh8zodA1Tgu5rQtPyuN5Nmhv
         p751Cof4E7nXoJnVeiXEGjLyLhm07Tsm6kpCsBOvrqRlHCB5hwMPmikjM17eut4xyF3f
         QisZ8aapOlpRgIhTb5PBLKBb1BvBnfAuOkwDnLGMnlAXL1hLbUgunhfwfO6nN7OKjthp
         pw8l7Rj9MYZveu+WBRYrxYVRY8nEtWogfIPd9dOAFu4LnE4ZhaFis7taUhQrR8KYm9sN
         MOCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=;
        b=OEF514UEsL0qLSk1rX8IrZclv4JqUFhPr7aDypDbMBmZm4IR8/02RIZJO1yeM0AcUm
         FrALn9djnTnxgVbfx0j/ksI3HAUKafZgt4VH7LDp5j4NFjKtgsZ8077HC7NnbEITc6/n
         mcBgmboPx1putf2eYK7MH4OCU14cQDKvxtHfz6I8TdUfxvN0uJGMBSL7bolX2bCyy2zm
         OgZVpYwx7emD6CttKLGpHtMfTjqDM5EPK2D/+KSnIW/7Q9IAqN3SPKXLBgCFThjtAcnC
         zUZ8vf97FlecUlE9PU2xntdgThs2yzvm5z7HdwkJYWkFzpXJS/7PlkjyaGRGLSdZ8Ry0
         U2zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qU78Z5cn;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r130si10745521pgr.509.2019.06.10.15.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:17:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qU78Z5cn;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+BjmfBU5ZU5hXn/L4jPTIPV2WW0RF6JWpSgCnxtzPjA=; b=qU78Z5cnfCWCw2IhCl3vEc+Nk4
	x8G++H0NEOUJ2ys+ciqLUxac+QBlvsUkpd58ip9As/SDTEYoUd6K3iDHsMzJhb9GK/WT/8GqqNR7+
	flS1vwCdfmtYwSiPtpMV9Ee/sIFyYw2+YerekgTEhM2bcO/WmW90zlrNKNFtBdzWLEm0igIIjjY8c
	tLXGh8crZITiRR7SGBzNoyUGtH1tmAZQaqebPQJLEKEemcHXz2qzWCI/JhExzdlzvYAAeSF/YRhBq
	smOc+AA8QBT/bWdWvC1lO2M8Jgu7vvrmKIOohSZNknUQvPhQEqYpq7+yut5oiPHq/CCikZkpCygu4
	KCmqITAg==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSbC-0003uj-M6; Mon, 10 Jun 2019 22:17:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 16/17] riscv: use the correct interrupt levels for M-mode
Date: Tue, 11 Jun 2019 00:16:20 +0200
Message-Id: <20190610221621.10938-17-hch@lst.de>
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

