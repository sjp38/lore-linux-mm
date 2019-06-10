Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A9DC4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE1E92145D
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V8RFOZDd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE1E92145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6789E6B0274; Mon, 10 Jun 2019 18:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629836B0275; Mon, 10 Jun 2019 18:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A44F6B0276; Mon, 10 Jun 2019 18:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10C356B0274
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u21so5010418pfn.15
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h6J+QiOYKdoEDaESTAbqz0t3lndQulVAC+cSepnSvyI=;
        b=WZSVR2AYUahexq4dS/cWZA5MhN1QLHiAP60SP+CikJHIMC+nxPepeViH/xwjrp1w8A
         +fAc66i8rJ1S5m1QooGuZ2/FCeRAUuU8Nh9aOwy50CzktKEK1WIOHJZJZcBDjCLPzUaG
         xSANjFouXFB89agOkK/H1H11Utx2vJXmZSiJj6nH7WDNaoSipRDxSlJYguonMAdX6FoX
         f9OIQjs20s2h8de7Z+UwNNIVBcC4JX+8pu1viTjfUKBAq7QjP1om2XRFF+exaqUcQFLU
         JO/YHK/9KLr25794mfgs54oDJ11XqBEUYVsMjCWCLl3ktT8423FkeWSWIHSzQ83aR36W
         rOaQ==
X-Gm-Message-State: APjAAAUTTzatqCfb5yZMCYXFHzyr71NCnr4vzQFbf62FywUmQdeIA0KD
	sa8rUub9jQi+Y7kUznDVyQe7NZDs0xbRC2Wkxocb3Ns09u9q3QHFwgo6HIHnfzcDuWKyO/awHVM
	3D6RXnMBpBE1pt5QHfbYvJ8kAg5qPzQv5Mhl05h81qoMMgViiLLzkc75eLSoT6x8=
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr20551271plb.158.1560205011761;
        Mon, 10 Jun 2019 15:16:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7WiWL591wiKyHDDtQgB1ut/+Y4S5yJhRg/ZhL+k0tAVnHcSjjrJmqjE+DnQqSn0IA6qUJ
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr20551224plb.158.1560205011127;
        Mon, 10 Jun 2019 15:16:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205011; cv=none;
        d=google.com; s=arc-20160816;
        b=JWoJdq+i6It9KHXuoZzHVhH/AaUE+hGGnL3IOjB9u6yT8Hk318NYr5t0DXgNcYdGpC
         TQIWKrTr/g/OgI2yK9QqN/xaVcDi10N0Gh1EE4J6M+eAvys7i74g12ibsHf+/PsLJau/
         /NQdmX88Zl1hHL4bNBShhJyXY6Ko2eRYiF8xIJro2l4LQxbyCIdWJsUPfSFh1OLYz20w
         iH97CGRZzFumv0MkgSe1xElGH82jzvSlCjajWHH1AwmHQh8cSjTwUn13vyToTbBjQCdd
         EszRrLnLSnqNZn131+0I5QGkBvkXIszmjORrvcUKIKwNPRVk2E/bQSTxSreX7sy1aCG5
         /XfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=h6J+QiOYKdoEDaESTAbqz0t3lndQulVAC+cSepnSvyI=;
        b=NyXt5XBX80/XwpQBnIWe8L/KfjMQyrSuNj2/XIQthaWHTU01YSMKrFe7fBA+COorrl
         HPZNy2s5iQd78GVkq2cAheRdTxQIHX27387XxzljAtDzs2jErD6SGLMrKSZlecIgtccg
         kOf8fHmVEEj9cUDhCKmGWtctGgp0X+PqMhtI6bd1n5n2RBICsJMURSmeHmYe4duTtPGR
         aR98xAYcmu/pM9OWIJdEyS/M8uAhk3hCsxFv5a26VJFDxZAhsJS82pZi8Oem/WXR42FX
         WrDqt6oRTitGY24PgIuldcMzMr5kgCr83eDo6WaGrvjsnXLovLAHT3zKhZKoej+lDEzT
         /pMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V8RFOZDd;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p17si10519210plo.310.2019.06.10.15.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V8RFOZDd;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=h6J+QiOYKdoEDaESTAbqz0t3lndQulVAC+cSepnSvyI=; b=V8RFOZDdLN5chLDdbnVNK9dlJ1
	uM5w5wcrJO3+EZ1UHI1Wb7sGkact57SKESY7N/vrePmN6J9ymUTz0rocYalDwv/x5hQ+IMedgMgAc
	wl6Un4zMZ9Pe5bagqhYSEtmiqTQ5qDi9szAP/8e+L78AffT8CyyjsSzgAAzL+VkZHLWLqSw2PT+xi
	NPVGY7HJQr8dQJ2jazZN8KiG5Qyp03r+KVbBUNwDG4/KFvxHaoNQ4VU0M/CQbtQ3W1ydVkspsO9pe
	K2BhHiKUh/3u+35Jh73MILlEk6vMV5B3d6bz/+a+UG6CN8qTERqDNty7DmYmFk/eOhRcveplsenzs
	KD1Mi8vw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSat-0003Ll-PD; Mon, 10 Jun 2019 22:16:48 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/17] riscv: improve the default power off implementation
Date: Tue, 11 Jun 2019 00:16:13 +0200
Message-Id: <20190610221621.10938-10-hch@lst.de>
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

Only call the SBI code if we are not running in M mode, and if we didn't
do the SBI call, or it didn't succeed call wfi in a loop to at least
save some power.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/reset.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/riscv/kernel/reset.c b/arch/riscv/kernel/reset.c
index cfb6eb1d762d..17c810985ad0 100644
--- a/arch/riscv/kernel/reset.c
+++ b/arch/riscv/kernel/reset.c
@@ -8,8 +8,11 @@
 
 static void default_power_off(void)
 {
+#ifndef CONFIG_M_MODE
 	sbi_shutdown();
-	while (1);
+#endif
+	while (1)
+		wait_for_interrupt();
 }
 
 void (*pm_power_off)(void) = default_power_off;
-- 
2.20.1

