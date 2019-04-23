Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94C0BC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587E0217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LtyH4QvI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587E0217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F232A6B000D; Tue, 23 Apr 2019 12:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED3736B000E; Tue, 23 Apr 2019 12:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9C9F6B0010; Tue, 23 Apr 2019 12:31:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADEFF6B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:31:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so9989055pfn.8
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:31:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ePxLfWKock4PACAGTbvmsL8Pnjci4PixztM3T0bsi38=;
        b=WrejVTDyNWjaPPc5b45YmAIDcucOBU8KJvG1r3zvtIpThnbrELB/bLHhITsWTz9f34
         M69aBJtx06aXZBJSi+Ze5H4t5UVgskeVnYqUqMM7WL7ym4wKS/Io09o25xGIGKLJ9LPd
         e2HjycBjLDUTlJh/RtanjoTvVufsxICpP/vf6sV0nN9R2ilyzcpxs0vn+nAeXw9NH6x1
         nXPYr9Ct+1aPhBljylfWOUgPlTP06dNGpAPrZP5GDNFAzd/b+lxrZxt2qoFj1ulBHiQO
         YVRdKl//RgTeUdoPHHXOvqQmjFgaeryihkBCdEmZU0/X++iLdDbINA/lxETd4jrKZsdT
         rbmA==
X-Gm-Message-State: APjAAAUUunO12F9r/3sBwun5//VyMaO+UDQblBu+zfBL0sxZdeBDSD9R
	HPd9IixmcGNEik1y4ROw+RUKs7z4DquKJFuc8afkViHix+E3LO0y1t/PNpnh6dd8JFtLfp/G/bf
	4VWazdYf3KxbFcjw+11Uj+JMm2BZxImwAvICuFNrUOMSdS4Ei+Tm6vqvpk7bgbS8=
X-Received: by 2002:a65:410c:: with SMTP id w12mr25794570pgp.268.1556037087314;
        Tue, 23 Apr 2019 09:31:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOGQjOly8jwzLkU1ew5l+GJVXUQDYMFlTshaf/HaZpYbZYCiMbRZFd/yowWnW302sXoBcD
X-Received: by 2002:a65:410c:: with SMTP id w12mr25794477pgp.268.1556037086250;
        Tue, 23 Apr 2019 09:31:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037086; cv=none;
        d=google.com; s=arc-20160816;
        b=tQWjnndrMHpHRiU+Ny+IPk6J0npHc4MuTalQrSS9t3v8PDpcl1SvAmjxAviBx1PVrS
         g9HkUST5TpxujWgcqTmea4BR6am/QUg45kfG3TtqYmuV4o3AC/qAcltAxsvdOsm2Vy2g
         R4s39oTvh+J2Z6OddIzLFtHTAcAvClHC5Ise9t/hhLvCi4uxEvbzVMGdMClZ1/xKQ+B5
         i3m5OBnUiCknE1TVDUhajaPnkCDryrU1eJQbaVoa1uT5FjF46YXJF2l4g67A+0TvTk6X
         8yksNAGF7j5FR5tAZw/ncMgCpb8x86LGH9/50BGIBg3vPBGgSSv5vX2uVLcuby1CYv+G
         cvDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ePxLfWKock4PACAGTbvmsL8Pnjci4PixztM3T0bsi38=;
        b=oERXoZtSY8IyDg86wTkFmmozzYEgO3f5vIjTZ97rIkzTQPryC+KwKeltJsYsphO849
         31KI2dGEf2kVW+I+WH0spjraeUTaqxvJinjOXLMU3v1MMpcJrjErxuntgC7zzEP7t1WB
         twA3LENENpE8OpzjMCxeDDee0qNgG3xpYLDpmc2/Qt2j4A8jXgxMsMulcPSy12dpCX2J
         5hbYQL8GNiwAB17SDXH5yySOL0ndaEjk1Bgtp4XKuyWN6D8aTVeKFKModrTC92b7Skad
         ONIyiyyJ0QlyUhJJ4QlW0A3bZBuqI4+DSKRx+8tYQqWcL7XHgxVi3Lw0a0vg/37hEhTb
         kpHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LtyH4QvI;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v4si14872688pgj.138.2019.04.23.09.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 09:31:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LtyH4QvI;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ePxLfWKock4PACAGTbvmsL8Pnjci4PixztM3T0bsi38=; b=LtyH4QvIN08otoXLUaGeZuPhN
	QSCV3kXT4nvKtfKNSK15GhTXYk7NDM+GmqpdbfMURnW5OPRQCmf1FNl+cXpAQzh8MKra7gg6BnacP
	gqp7v7R1snYBxfaV/CcNbF9TREITByzN0J6ZeUpLo1ZXSAu7MlDSJKh54YrvvTVWsS0Q3yKx2vwNo
	soKI0pudMF1DAAfXAU2v0iZ5n9WGy7fCL/8rEToZO3AiKcenhZrRdxrwIXpXkW4yFQQ2h5bs+RAGQ
	PGeKSjapTeCY1uHbd8Nq8DsMR4/zeNhAV+E5eLvCgvOmyvqZcXVyhQ8PubE0XYYcqWYGi0++YaTyW
	+6+Nv4P3Q==;
Received: from 213-225-37-80.nat.highway.a1.net ([213.225.37.80] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIyKL-00041e-9v; Tue, 23 Apr 2019 16:31:25 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Subject: two small nommu cleanups
Date: Tue, 23 Apr 2019 18:30:57 +0200
Message-Id: <20190423163059.8820-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

these two patches avoid writing some boilerplate code for the upcoming
RISC-V nommu support, and might also help to clean up existing nommu
support in other architectures down the road.

