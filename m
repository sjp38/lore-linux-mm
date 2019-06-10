Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57554C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F283208E3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DClxskAq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F283208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D08E66B0279; Mon, 10 Jun 2019 18:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C91F86B027A; Mon, 10 Jun 2019 18:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE3FA6B027B; Mon, 10 Jun 2019 18:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 734536B0279
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:17:05 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so7761041pga.4
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=;
        b=WSgHwLcJk9J7hp1wdfqDzNqjiSIOg2kozrVEMaoGiM5MDYNNtiaYPEzpDcpyXldGct
         q4ebTWSE1fRSYdBgZR1qei3/tl0NFtq7+Pq8Y5osjF7Tegm9j71n1aLGBgHQJ+sU7Ce+
         N7xecpyodF6moGpE1fMXos6vga4KFGzT/MtZuf3Svzcoi5xAq59YzK8qZLOtUsukAnq2
         kpulfDVPA0jKtbjzOA1MCDuBoip/CC0ysUDzRyQ61miXAMzwkLXzik6VdcHz9pbR36uq
         KK+jYVS7Ge38dup8z71XDHsQU9DniD07w8uE8rR6Ve8B8WNxQrDcKDfkVhJzxgq2qA2m
         wdDQ==
X-Gm-Message-State: APjAAAU+4vEljWsNOyf71VB9EvefXTMbWEdoFkff8+DYw00e1k3hux4q
	LOiLqttouMvJcI1pS8lOppSNAJWPhcb/wiQWyxipdpYOhHfEm8a0musCRugYhyKDW9jkCLL+KnT
	w+VvDDIGcnmk26B9qGIsHUn2upCwy+lD1uM2I3Bb3mf0PkV52GVyinSDphAoRAL0=
X-Received: by 2002:a17:902:70cb:: with SMTP id l11mr11774751plt.343.1560205025132;
        Mon, 10 Jun 2019 15:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZDshoguPlqaVRZn3ETvuHJKO9uLOo53rfWlP7+pyssd7VhHltunMo3s+K7olt1DObb7x2
X-Received: by 2002:a17:902:70cb:: with SMTP id l11mr11774702plt.343.1560205024559;
        Mon, 10 Jun 2019 15:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205024; cv=none;
        d=google.com; s=arc-20160816;
        b=TgM9kYdwL2AmW6Bn3kP5AIv/c+eWfr1+fJfZJjMRT+QcYPNM7TrqxADhPKY6nIfFAz
         6izKWMLqxuljFQm1lQc+BFIqx5wF+9l2RjrD9NhAuAmwZacwpNuBLWC0DBzFJ2bajM7C
         857mwuxQEyLz0a9nw7dohoiIAwqF0v+Gc7DlvV8JMN5+M6XyC3kF6J3N6cPc+lmICxFg
         78J/xxf1B8ZgYuAWjAryoplp2X9TkgZedJNsrkx72iEe5Gvc//MLukhmX0omJSletLp2
         r/tXteC808Em18vTC3Is71p01iTlmnULrwjyeW8Y46ld028JassTLYJoBgXYez1hS44C
         1z3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=;
        b=Z1hvPcRqtGt6xrSmamODLtg0NwGFCNyPGnBlckdurhERV3WgrQafH0i/uoFT0/9esM
         c/HwQHxWYLqIKURZ3P9qbIPk9fGwvHDbRBot8G32HOkNfcmFbZNoHVexMquqGvfhX8pM
         eX2zQgcsYZUq0TMQqfc3InBfOdoeLvFUm0Mp/lCoXka2cXc1vZ33LTjoX0Dm6eKZEzVF
         G6F+/0XTG9166Ik/CqiAr9PM6EDvCAkXsIv5h4EyHZ1uN7SpnvvkcJtZCOF9rc5Jpmp5
         4qY0Il6YsEYkoxSakILF9X9FDArMpvc4/fBRjAfXGo+K20DQFwmpStrVAgkFy8jP0y/G
         iBVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DClxskAq;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 32si10879245plc.152.2019.06.10.15.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:17:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DClxskAq;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=; b=DClxskAqPYBFK2k3TMB5K7R+nZ
	z9U0LsZbiV3WZgHBzl0PPjdk6qWGeEdJiS1YtZ0SKEHrHuRODqonx6dexyzM7838Hd1RDMSO1GsPI
	5EP7DM/TJru3t1osBnbbuJ4pgDh64/bYNN/M2AJKc64NE8wqqi5FwaR8miqqNxK1yv+Nr7ZBLmLGY
	HyrwouU9iQMTFYKtVWSyaDqYnmdvhj3W95zAH6aUxsCJ0wqUzs3dI9TW92uoHJf+tzVaURVvyLntw
	384Ro2sNdxWU/qybRIdirBfbpimN6YNMOLxWG2AwEV39Emf87QmpodZMzd3x4MOix5y77HeGJdgd4
	ow+VBniA==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSb7-0003jm-Gv; Mon, 10 Jun 2019 22:17:01 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 14/17] riscv: poison SBI calls for M-mode
Date: Tue, 11 Jun 2019 00:16:18 +0200
Message-Id: <20190610221621.10938-15-hch@lst.de>
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

There is no SBI when we run in M-mode, so fail the compile for any code
trying to use SBI calls.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/include/asm/sbi.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/riscv/include/asm/sbi.h b/arch/riscv/include/asm/sbi.h
index 21134b3ef404..1e17f07eadaf 100644
--- a/arch/riscv/include/asm/sbi.h
+++ b/arch/riscv/include/asm/sbi.h
@@ -8,6 +8,7 @@
 
 #include <linux/types.h>
 
+#ifndef CONFIG_M_MODE
 #define SBI_SET_TIMER 0
 #define SBI_CONSOLE_PUTCHAR 1
 #define SBI_CONSOLE_GETCHAR 2
@@ -94,4 +95,5 @@ static inline void sbi_remote_sfence_vma_asid(const unsigned long *hart_mask,
 	SBI_CALL_4(SBI_REMOTE_SFENCE_VMA_ASID, hart_mask, start, size, asid);
 }
 
-#endif
+#endif /* CONFIG_M_MODE */
+#endif /* _ASM_RISCV_SBI_H */
-- 
2.20.1

