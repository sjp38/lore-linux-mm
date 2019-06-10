Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D495CC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96AB62086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hjZqNyqd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96AB62086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF68C6B0276; Mon, 10 Jun 2019 18:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7616B0277; Mon, 10 Jun 2019 18:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D4C16B0278; Mon, 10 Jun 2019 18:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65E8E6B0276
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so6505957pla.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j+NRg+K9rfMiwlW0bYi4vNNt08WFCywGA4nYguu1B0U=;
        b=m154JNxwagGBSEgyEWKISFsmLKA9c6Jibpx1jnpF+vy7PH7ePeGrRRtyVlywp/K1iI
         fdOo6NuhQ1Bd1Ah0crX/0d33hA2rCdpXIcKGW9RYVd+OGGDoWYO5GKk2cJJI/JJdlsJo
         xAtQWdAWftHElFDWsbA9GtPLgFGShAuGxX9JEn2mn818Pjcyas91svhdFGawYI6HPl87
         KGdDOcUIJAmimkdfJwjxFOjSKHV/L4snjkL/G65ZoahjhhnRsSC/AKNAjYx7cYjEx/o1
         DH67BqGKu2IByNt+lSb9OMprI7ingkN08HFj3/JwTkCOJRKI3kSuwwpwBR8RY5620vN9
         UCUw==
X-Gm-Message-State: APjAAAXZh2RCN/LryNvR9UkovAGLh+oI30bNJh+QTIdYmNqjA9DxYW2j
	rTeJ42BPU45nTYBbCIy0brdmz8LqcUKLa9fY1zyHNIiKcRTgo7XJmF5ZABAIl0wvCMf5PiX9Zqq
	017XijVCkX4IcMYdeNRBldiqcQ/7le4pQxJ64Oh0GIpPbnX9J4Clm1tnkrOzjePs=
X-Received: by 2002:aa7:8102:: with SMTP id b2mr50477567pfi.105.1560205017092;
        Mon, 10 Jun 2019 15:16:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyc3IX1eS2xX7FymYrlPUQc9PLxB/NJTsbgJkmG6ptD5AaBewZKB9FSwSQLUH+scRBmy3GZ
X-Received: by 2002:aa7:8102:: with SMTP id b2mr50477512pfi.105.1560205016483;
        Mon, 10 Jun 2019 15:16:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205016; cv=none;
        d=google.com; s=arc-20160816;
        b=CW4yFDR/cv1HpjsODPKEn/LI1RtZIfdGR4V4aHHNkkaVCMJPpTUPKk9ZF7QI8XbqVk
         8hfp3TcuqAyMH7mCQfSze0bNUnPzalzlLYLmfKn2EX1Xp4KU/EnRnYcQ5Ms9wwM4vWnt
         xXpSDoUQgHJqaTHXQBE9Wthbcaz0EGuqgEpWCqqnhXqxa5HpldyLd36j+nVSm1fnX546
         FoIrPkVPinzWpsrY5KKy4U3WxEw//FN1GHBkOgOL1NjVxDI8I712Ra6o4IzWkb7UjQTX
         D6VD07SV2HPOzfu/dMeeu5ZE4ILkFSmTnXQOeICbTXtu60Bqx4npuchshk1dM8nB0BrZ
         mDgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j+NRg+K9rfMiwlW0bYi4vNNt08WFCywGA4nYguu1B0U=;
        b=bK/3JvIOLD2J0co63n6QgZnwEvrGbUTj5pKqEIB6yIUA1JDLWdqcgjuPsuQsKJG4QL
         oIScfVQZNc98KMPvQX/BhBss+G9zlz8Gtwl29XEMtFEMf0TK0MtzN+TDpudel7gK+KiO
         szvUQWSr+U4aw0ssoSOy5hDlJKCcBlvVN9TCMjC1hbI2du/0oPqPXllW3pSNCJ0uQCWT
         Ys6CQlS4Clk/PvNdkD77EONnMsHalNTNRREzMkLQM5q7SvQtr8gLd2R8dujGtw7QwT0E
         5kTiTA8qjBX2M8U4Jn56Ap9fxYwte4E13ko+m80O+RuygH9rt6gmdsq78BESky9RUL3k
         I9XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hjZqNyqd;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s14si606387pji.28.2019.06.10.15.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hjZqNyqd;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=j+NRg+K9rfMiwlW0bYi4vNNt08WFCywGA4nYguu1B0U=; b=hjZqNyqdr1u43sSDisZ2XDo17m
	RlVo9LN9scl2OxGt/dwaDGkdB83y0zZDUSm52W0+dBgXU+wK1Lk/QjvThHqlo6TtKB6j561pq+1Ek
	qFo2fAwKH+2lB5+dELbqJuzBoGnB1WNOZVLTuxs9NQ0dpCipCQrYd00Vc67dfe4yibJfz5Bl92zy3
	YXl2c6SnHoMjqpAJ3wsTHchRvdLvjxjsDPAGWRXHA8R9YWtob/LeTvFSOlKhA+xjME9Dh7bdoFOQ2
	7ZElZq9Jnb2ZWxLgtIAqJKgfTmBtTaxEAwgkIlTjeRzRWUnCEDugA31drUsWn7Sf/4Dx+7D7RYrIg
	RuzPWyyQ==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSaz-0003Vu-7L; Mon, 10 Jun 2019 22:16:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/17] riscv: read hart ID from mhartid on boot
Date: Tue, 11 Jun 2019 00:16:15 +0200
Message-Id: <20190610221621.10938-12-hch@lst.de>
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

When in M-Mode, we can use the mhartid CSR to get the ID of the running
HART. Doing so, direct M-Mode boot without firmware is possible.

Signed-off-by: Damien Le Moal <damien.lemoal@wdc.com>
---
 arch/riscv/kernel/head.S | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/riscv/kernel/head.S b/arch/riscv/kernel/head.S
index cb5691d82b0b..e05379fd8b64 100644
--- a/arch/riscv/kernel/head.S
+++ b/arch/riscv/kernel/head.S
@@ -25,6 +25,14 @@ ENTRY(_start)
 	/* Reset all registers except ra, a0,a1 */
 	call reset_regs
 
+#ifdef CONFIG_M_MODE
+	/*
+	 * The hartid in a0 is expected later on, and we have no firmware
+	 * to hand it to us.
+	 */
+	csrr a0, mhartid
+#endif
+
 	/* Load the global pointer */
 .option push
 .option norelax
-- 
2.20.1

