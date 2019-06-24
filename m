Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 249BDC48BEA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E101C2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ox0Bj2s2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E101C2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14AD46B0269; Mon, 24 Jun 2019 01:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D4258E0002; Mon, 24 Jun 2019 01:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDDBF8E0001; Mon, 24 Jun 2019 01:43:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B63AF6B0269
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so8889471pfn.3
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=43pRHKdJKqNssrr4/Vc0cDK/nlhOlcebDC3ttvLu+nk=;
        b=KCbBhmDH83M83DQEFHZPkQ7z6vKyOlnrbQp0sL/kUCZh2TZAQOo9DZUlTwl/oDhWiT
         Sh4U8ag2sVzlwIIhQ/Rf1jNCv6xHf6RFOedr93i+MstrE452dBdAUUUnR31FMcmEa5qH
         Up9qblPs+cGqwwUxxn//Pu8BNv23zL8mB7gWR9sjfU9wItIDFsjxAIiZyFveuAKXQZ2V
         XIsgNpMpSpxbHtM+d0P++h8OhalReg3ZTGTYAETWP9mOvHV+igWjcLEy2MUxZibA6DWY
         aBOYW3Duvt9RO9JdokE2Ali3V5jAMxuPkEVrAyENozxawD9HtxXqI/U3KCPwJGehYWyo
         gr/A==
X-Gm-Message-State: APjAAAVHnX/jAMzeo/I7p44rhHq+e4Apyt8QsrkHLpWHdeuAF9qSwZAY
	H6qFdmHS1uuJLeVGy5KiJQJjTsOOY4JrzmpKsxMxLa/cewQU4WCHYBz0gr3yP2Du1M1FpPURD72
	xzS6z65ZtSpOUzJjwry+X7DViyADy1Gg5r+1dckvFfKMcJlF9lGxYkQ69O5dQHGc=
X-Received: by 2002:a65:524b:: with SMTP id q11mr30301876pgp.384.1561355032332;
        Sun, 23 Jun 2019 22:43:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5olcSIoAIqovBqj5sngIHCt9o6TL9a07GwkC2N5QP3+HfQfF7gEjS+DKS1cZau/vcTvn/
X-Received: by 2002:a65:524b:: with SMTP id q11mr30301850pgp.384.1561355031609;
        Sun, 23 Jun 2019 22:43:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355031; cv=none;
        d=google.com; s=arc-20160816;
        b=UqDVHz7DKs5UGeWeDcc6AT4qZegXM/31jr69r59a6PPLTPJL1BaVe04AQCUVs05Uyp
         JFH8fjRIWs2fjUqByy1nS+p7V7sAxuJ2aqONPX2TI47i8+x00Ok6eB5CEd1qxVzQDJck
         9EIzMMV98XCx4KuBbTQR3/6zNaqQKf322fnp429g0bBVDwfXymDsiSd4H3bdqNFdEFDw
         Y0YfLzWoBzhg3GmslfA2f8bN3WHlzWcYx8uKZPZUoglW7nUKVyNaoVSVsVOOMsiByxNP
         xCTha8+JhN865hSbeDF8Eusw4zsqwgyiBNHjXwEK4j+mxzIUU9Vb+hhIpqCHhpb+iqWf
         lv3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=43pRHKdJKqNssrr4/Vc0cDK/nlhOlcebDC3ttvLu+nk=;
        b=TBfHnuB5chHYRGNVQJAfIh8iu3d64ha5JbnbGiAsTj6aN4HyeVFgTWet3CSMWwNYMd
         qJR1bB1wVvDq4EobMd0Rh7YeqFPtKWE8blFp8d+rLf867uwttma9+mvkIB0vszCvDWKn
         Cfwue5EJvOO39XwErJPv4BtRWsOmjyUQL3HgJQ060X3x4FvAyWbpUuWSDNsawdOJw9bh
         S3UhCGERXXa7RjVDaFFuD4AaduwoY9sM8kNGnwp4QSmdqmnqg4o4NYednr16YsSqC7Sx
         6ltqEnwe68jcgRalQ3pwfxTV5im4zPuIWRQ/naiWVekedyMbx/+PoP/65We17xxhSUF/
         6s4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ox0Bj2s2;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 59si10154952plp.90.2019.06.23.22.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ox0Bj2s2;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=43pRHKdJKqNssrr4/Vc0cDK/nlhOlcebDC3ttvLu+nk=; b=Ox0Bj2s2AYtMiNqOyzVUJu1aca
	4Zw5sJu947Gj5rs0jUIlbbOtlbwYiuHZ0nJ1wtQi79umOkWFdlOji03dK+QH22LmwJp2C8vJ56/Fw
	VBYObyjWlQcJ9h5SQj6t76j0JD5TudW+arpOJd2w7RxIDG8pwuO4dR1jb3JpSDfRzc7ZczKYWm7vh
	QI2c2xxg9ZuRIDvDgzexiDXDbZSYqdKgNNN3aPwHwGLG857aQEXAdzB2Nf4gvK+YbgR5Imuqbwebr
	zBivLC6z+ob0BD9JpbwnxUy0vPPLYKipdDiBzZ5jLr7Jy5pym/AnznE86d12FYY1jmZQrC/xeH+IC
	s5lNwFPQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHld-0006Xj-5S; Mon, 24 Jun 2019 05:43:49 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Damien Le Moal <Damien.LeMoal@wdc.com>
Subject: [PATCH 10/17] riscv: read the hart ID from mhartid on boot
Date: Mon, 24 Jun 2019 07:43:04 +0200
Message-Id: <20190624054311.30256-11-hch@lst.de>
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

From: Damien Le Moal <Damien.LeMoal@wdc.com>

When in M-Mode, we can use the mhartid CSR to get the ID of the running
HART. Doing so, direct M-Mode boot without firmware is possible.

Signed-off-by: Damien Le Moal <damien.lemoal@wdc.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/head.S | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/riscv/kernel/head.S b/arch/riscv/kernel/head.S
index e5fa5481aa99..a4c170e41a34 100644
--- a/arch/riscv/kernel/head.S
+++ b/arch/riscv/kernel/head.S
@@ -18,6 +18,14 @@ ENTRY(_start)
 	csrw CSR_XIE, zero
 	csrw CSR_XIP, zero
 
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

