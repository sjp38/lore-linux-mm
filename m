Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0533EC4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD6F7212F5
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:17:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Zx+/PZhf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD6F7212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 148C96B027A; Mon, 10 Jun 2019 18:17:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AD2C6B027B; Mon, 10 Jun 2019 18:17:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8E706B027C; Mon, 10 Jun 2019 18:17:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF1B76B027A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:17:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so6517963plb.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:17:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=;
        b=tmaYcZa9qqYLrugIwSAx+Zi9CWwq5LbOGCc8o+mOI3J0bWgKohmTvV+I1yykBuhwy3
         2xow8KeRvGlTnSRt94ooKcu9txQZr3+1wdOTuA1/igIjGB3hBUsPLTgcKvrIlltw9uKp
         4DpJnUduUQhYV0XB7VhlkdQSCa7p4se6FEFnCmm901GOtHxlhBLOMhyU64cA4HZSbvav
         fLkYC8/i5KvsSXWvzeg/IBvFw+3Fa6DlvMx8oVH3g+NmbLaZaXBvw2KR8Poi+WqbK/d3
         i8kt6PVOHSmZBgkDXueN5HlBBc7Bpr1ImEfHEwSTeMlrPVede+8iOaE/Za+WjEeLqUGJ
         Sp+A==
X-Gm-Message-State: APjAAAVuZkgV12FXVu5pyawzSX7svIGP0XvNBqqscHmpWw61Lqen5qi0
	x3KOQK2G7bdJBCudrad1ecN/DNAvegfJEHED98VSRv0YlwdEEYN6+s2g/u1UG/fa3Ma/wBTTuKf
	HM40N7+uBcsbpDzpFY5GSFxaeY470sFZg34naB6XzlN/jHK1emURSGhRAefriEXs=
X-Received: by 2002:a62:3447:: with SMTP id b68mr20450393pfa.67.1560205027383;
        Mon, 10 Jun 2019 15:17:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMESGRU1Luwj2a9izJiQks7qwiJlOm+5a4wX+Khk78QhXNEmgV5eL98rzKGhcMR0si1AHa
X-Received: by 2002:a62:3447:: with SMTP id b68mr20450346pfa.67.1560205026714;
        Mon, 10 Jun 2019 15:17:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205026; cv=none;
        d=google.com; s=arc-20160816;
        b=NsCTRpl/Z2V8Wt5BN9T2Wa6iubeccGIfEbAWFaVaQs4EZ0ojZ+HpEPHDF+Yknx554z
         WZpY/YmHIrjcqag0FPdTZhocsvjiCZYD4030QsCahWTHgLKnGuJFWVN/zEFtsrcYlIcM
         S0XRySzhFiveA/t6ks+KNq75A1t0qb2Lh3AgRK9Dx4vc1DSMK5zqewtIJa6Ge1Eso+M8
         8z5EN0Rdt1godSCZC509bcVhaas50g3OWTUDljWJW2qZc0HO8NSsfw37/3lWsaNm6sOk
         QvrtfMYKQVz18EvvvfDhzbglDImT/CO+b4GRIJEQfHISToUoH1/BE1Xxsn4+qRGMVzJc
         rwVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=;
        b=Q0fpbGK+KU8noOigb/RM6i3/EP/fNlMyi+tfOC/3qiMqWJ2tNt5kjbr9bbDdkKYuj4
         PzklLgeU3ldOCNMLq7zXmo5wrDHe5LzxeUUK2ZhopNsGKVw0soMyWiDc5wEPj+NYR/28
         sDw/javDwV1PcXf7lMxF7hO6I7ZJc01BVtDJfalr0ohh9YcTcmbFUqLDMzLHDpXjXq/5
         NVvh/qDNMko20fhRcVpu556SSN68uIS9BUWGbA/FBfWnXdDbwWlliiQ7qCMJkfRqc8UK
         8LezClyjqTfl+B4YSf/Zk7B8oB0SQ7D7cxKViG6U+Fthq52nw5YasSEWbiVM6coWHjXe
         bwGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Zx+/PZhf";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o32si11348490pld.115.2019.06.10.15.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:17:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Zx+/PZhf";
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=; b=Zx+/PZhfBbEfWkc+XH2fIwn4gM
	7sgLtr4sCHafnRXr+XP2JznmcIlNX248bZCdifub5mH85zuhsxvCQFfLsrnBtM63fMYYp2P1/dRDo
	7igRKORw8p0LCRWlvpUm0g09bQT3Gxa37R3n9bMHaOoFTL03BkBzS6hC71K/ypgdQ94DKUZx6aRq6
	4HIYRs8/jlN+25vLIjY/0Q8BksuIehE1hxqYcBmTCMzTh3T2PpgqHkpVS0Mu+bczO7iYXgQWFFrQ/
	wtx/glJXrELv35+7bMj8/QeYzcozoHW944bedT0rSogiTXrMhrXa9OM0YYC/XlogqbfTe88ICP1uG
	r+l+FaoA==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSbA-0003og-6Y; Mon, 10 Jun 2019 22:17:04 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 15/17] riscv: don't allow selecting SBI-based drivers for M-mode
Date: Tue, 11 Jun 2019 00:16:19 +0200
Message-Id: <20190610221621.10938-16-hch@lst.de>
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

From: Damien Le Moal <damien.lemoal@wdc.com>

Do not allow selecting SBI related options with MMU option not set.

Signed-off-by: Damien Le Moal <damien.lemoal@wdc.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/tty/hvc/Kconfig    | 2 +-
 drivers/tty/serial/Kconfig | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/hvc/Kconfig b/drivers/tty/hvc/Kconfig
index 4d22b911111f..5a1ab6b536ff 100644
--- a/drivers/tty/hvc/Kconfig
+++ b/drivers/tty/hvc/Kconfig
@@ -89,7 +89,7 @@ config HVC_DCC
 
 config HVC_RISCV_SBI
 	bool "RISC-V SBI console support"
-	depends on RISCV
+	depends on RISCV && !M_MODE
 	select HVC_DRIVER
 	help
 	  This enables support for console output via RISC-V SBI calls, which
diff --git a/drivers/tty/serial/Kconfig b/drivers/tty/serial/Kconfig
index 0d31251e04cc..59dba9f9e466 100644
--- a/drivers/tty/serial/Kconfig
+++ b/drivers/tty/serial/Kconfig
@@ -88,7 +88,7 @@ config SERIAL_EARLYCON_ARM_SEMIHOST
 
 config SERIAL_EARLYCON_RISCV_SBI
 	bool "Early console using RISC-V SBI"
-	depends on RISCV
+	depends on RISCV && !M_MODE
 	select SERIAL_CORE
 	select SERIAL_CORE_CONSOLE
 	select SERIAL_EARLYCON
-- 
2.20.1

