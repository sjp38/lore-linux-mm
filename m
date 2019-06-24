Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFAEDC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B44AF2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WQf5kvD0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B44AF2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0CC86B026D; Mon, 24 Jun 2019 01:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABD848E0002; Mon, 24 Jun 2019 01:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985B48E0001; Mon, 24 Jun 2019 01:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 624CD6B026D
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:44:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so8880877pfa.0
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=;
        b=RbKoRkqrgPO2AmpWP+9UYOSS4nICfGN4/0HMQziAF2fX9k/QcMJ68EdhzHSbOES/64
         tnrEuT8VHeacQVIhob9ujNz9vAOwZDvLW96DFs1MgcQ3tyk6gmue5YLCQhON6PBNIjrU
         YeVAqEvHQvwxUom4rMIKrlnatTTzwRkXt5NV2TqNYIkhCm+742Nae7ZS5Tn26dtwmKVO
         LiTC0JflR6W5XDg7K/QGbEfHay8KA16QidIZyTE/xVkMDtffVq3CqOEhq0p6QZTDyYta
         KbNV1d7/JEZqkygYAvHYjRoy8d19iTdMm1/go5chQiJAhoVfTrGmvEb2D4h7pQbjOqod
         Z2Tg==
X-Gm-Message-State: APjAAAXNTiXWO6LnG8eCBY1SZQua0362LxIlFZMB45v6JzqLWH5Cic0K
	IWYLK8YprAZC0MXt2Z7tR/I2mIIn2ErpVVIL++iKHDi/7zjJ8/lCq6U56HjqglHJEJP/BHhTWVr
	d1hUZBAEK5BvNjptGYmN/UhzsgWkqeuGRhgAHBiXg1u5XSewEH8Ywmg3kqDWBD6Y=
X-Received: by 2002:a65:5a0a:: with SMTP id y10mr3624171pgs.369.1561355044967;
        Sun, 23 Jun 2019 22:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygq9Da9KnxTAPwiYHNgmUkAnyPHkmX+t/ECFR18UcwPgmiW9qLHysW/lbrmKsnVBGDcJyY
X-Received: by 2002:a65:5a0a:: with SMTP id y10mr3624144pgs.369.1561355044289;
        Sun, 23 Jun 2019 22:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355044; cv=none;
        d=google.com; s=arc-20160816;
        b=jTHoIFbFI9pa7LUZIrvtZ62L4MViymsTvBx2iOTrlvmgTlEaBgcjY7gYec1tyI55bA
         I9J8AZWrweO/6/bwx4rUqgvJpZdEB0RNn6E+UVSBwznaVyyleWUSN3VYQ8x97vS5ZM24
         Du07XRrha9wwj4NQpQzzWLNKItExrwGM9st18Fu2RLrwmzK5xUloqB/MjwnIOh7UuZD+
         YjuaqJUOKsrLxSIQxp6PHX9/R8bDFeqbTwDuCzXcGowl772630ih4C0fCvHJehcikY3Q
         KQFcLTmtsUqYeswCae7OkmwOUnDMul+61d3GGseit0QprIKKSgI/5nsAIejBBkiaJ9iN
         FJjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=;
        b=feVDyxqRmpmX4nc8c9I/fydJi410Zz2umhDhfhbI3qbbj2h5dQMqR09wHGL1V+78/f
         4R4y5DgsGLPaYE+4TlUQfqyy+C1MZBhJ/FmZ4Uqf3whmadb4JCaOZZuYhM/KLuBQrDO/
         kiaKz+UZTne0UwHCMVI4PziNbxEfR6jTOdfe5tNfACcxNgQr7pSBouKfF0/om3HFeY67
         UCJ2k3nfloj5ior2xTd5lJD7JNFaRWUVTASnBd/wkV6vUT13yfjuF8CpsbZX1SW1pRhH
         WZ4fixBthjdcAcRImjpNeJANS3Cs2FmYTSzxAHZppgfYboosWQzpKYqghLu2IR2e7YXR
         HzTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WQf5kvD0;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t14si9300179pgh.128.2019.06.23.22.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:44:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WQf5kvD0;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UZgDc4NqB64labXbUkmbFOqDnFwUTKKO+bOXvo7uUrA=; b=WQf5kvD0iLeHL+gjoj9J2oADBP
	LqKMXZw+Mj+AhxwqQumEt4dck7OeMldp9+qZsUi7B2njdhoQu5EYx9HMGkX0f6BZ50q5dRuZ4z1fT
	xjcJ3Fxh0FopxWvWOfSUIS1qMVI2flIkOXrIJjRCUtiJX4VPtxJ6BqxCmUsRQFXIKQBfkdmEbJqU2
	d5oaTF/5MSXuHffMrBZ4jDAip4f6sbJx9s0dN/zB1w1MPlJBup2k3r5CKECJxiVwJZGWMOqr1ikMr
	hiKgwcLxeGK0RQ1cUvdJ7t06nuZ2LkDd2cyrhv+BNWPPFaOpNgO6utQQ/35pKQ6GLaWc7jrmveRbx
	yy5XiOIg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlq-0006o6-Ir; Mon, 24 Jun 2019 05:44:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 14/17] riscv: don't allow selecting SBI-based drivers for M-mode
Date: Mon, 24 Jun 2019 07:43:08 +0200
Message-Id: <20190624054311.30256-15-hch@lst.de>
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

