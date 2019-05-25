Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCAB7C282E5
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6601420863
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qMmTNCLA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6601420863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDB2C6B0003; Sat, 25 May 2019 09:32:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8C2A6B0005; Sat, 25 May 2019 09:32:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7A946B0007; Sat, 25 May 2019 09:32:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 911166B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w14so7761978plp.4
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Fclx2EkLgGZXMWSnoaUIWWcWHkhmXZk15XX3q1+NpkY=;
        b=U/uLFhUKsvlHQDTFLcSihiVaCroXPsuPou0DTLOZMG8ZMEBWHWVbCUVPaAPxFipSzr
         S1R56T26wONA/zjjqgSaU2S7lYucsBFkF4fmHKrChdlNEjTNuudg8f4oEsKtUL7S89G7
         b4+QK/NGU60NPNLak/ji+Sl85ZHApptKpP67dxaYy0ZVWcaoKufkk8FPpdxZIJRZ9NkA
         78qXtXJ/0bmkc0JUZsTahUCdGFHmSIIdnYMzICvRwO50vpTH4cwsqcvlC9sx885/8t30
         i+snBJIzNyU8u8YDOL3JJnmrQgenA6Y4za4UmexuBTQEzbB/v220+5nx1gSq53+q7vhw
         Z34g==
X-Gm-Message-State: APjAAAVMy86bQbYKadGk2e/kW/RpvO7HmV8UTRMS4eGE1689k2tgzTKI
	M19ckCSf4kmZ5ZsA1Taj+dyRACTaXM4k1uu+5WubxpIHFFHa6IRUyrB1lobK5aAdEeFrQMin8M3
	5s13R31TFhl6sjGuv5ZycXAGpf/en83qBAPAAAgrGEmCIj5Ddm9NoG43ieXjaY38=
X-Received: by 2002:a63:2d6:: with SMTP id 205mr111431991pgc.114.1558791139035;
        Sat, 25 May 2019 06:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCdi1MpKCLp3EV4VdXSil5xkrFLuTJPxMje+j27I0sqRbpht3RgoK1+LJ21qmTDcwgWb/v
X-Received: by 2002:a63:2d6:: with SMTP id 205mr111431919pgc.114.1558791138318;
        Sat, 25 May 2019 06:32:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791138; cv=none;
        d=google.com; s=arc-20160816;
        b=qVkYqYIcOhtKqILTPb7oAkb/s39Uwadzxkqw62a2H89xuGxp8lvzkMKnDFIBtUbvKm
         BP3Kr+v8hWfJpFwN8PZrRH3el8lvLbkwrtJbVNeEcmNaOm2ksC0/SEUgBGOxPvfA/yiS
         l3qBkFPR9v2gsoxmgthZwK+S6yLTgm2yjrbwspZVJZKcFT8rxEGC3kY/QMJbVg+WtzSW
         9jUolZ2oHqsA9DyA5FzUBK4lKuppAozXFgE86HMr0iniQyOEIYYfEjgbos+KpZVWDess
         Vtjrr0moYmMbeRP4hr+Bu0A0HbjmrQTGo8gdoLJj+YbqIxtY3gEFGGjZoLXM14uGq6k9
         NhuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Fclx2EkLgGZXMWSnoaUIWWcWHkhmXZk15XX3q1+NpkY=;
        b=WyuIGNX/G6LL2TEcWnPEWGMQSFm1eZYZ2MWv90V2JFsv290WPTriQXvrYNk1+4ywPx
         nrN6lufFmOjwmyRcSgBD/4F0ayloMu7t/Ar61C3piswRogtQPZ/Aa6T44lkCXdZwU91/
         gTyZxSEmI8HheM8+Yk0ZIxaYOcKlNQZMRDZ62nqdo2o6eB5T+INEZuzqQyeNz47fhdQ+
         bOgW5VaX4Uj7E46NIyKK+223DlFV5oinde+a+cwmPlDjQvmWLEzgaZwoohETzhgBkwuA
         5B4ejpFURUD0BbPRgd5byjuVv7ZOIHYWREBMYZxtoMxr2tnE80eaIrhMgm8Fjet9ZHzd
         B+wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qMmTNCLA;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c3si8355683pjc.103.2019.05.25.06.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qMmTNCLA;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Fclx2EkLgGZXMWSnoaUIWWcWHkhmXZk15XX3q1+NpkY=; b=qMmTNCLA+cd0wrgFY7M1IdfhH
	a7UH0ogu20h1J5SiJ/CDdmDVN9+6plSUgOdLtw3s3GA2P9KXe6LQZlEXEKL0WcNscFuhnXCdw2lxO
	VuHb5eNnQXbvfmNnQUqHuEmqKzqRxazORsOaeMyDwmRz5w9p3gMNhCdrtTJ4VLUohQnwaiDFp1Qsv
	XFRTyZ3rwPRms3QA30d7IAPD/xQIcNt9mcpAZSyEVPZA+e3w2S28DBaUJrnQVYVIthXWpPO2fQy8i
	uQ1Z5oaqOxJXFLu3lOo+SJMMZQNl9Yl23YrszkAJElJUuHdqZlRJdv2gxlf3DCUZk3fInV7so85zJ
	WqCevvc0g==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmM-0006Xn-Vj; Sat, 25 May 2019 13:32:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: RFC: switch the remaining architectures to use generic GUP
Date: Sat, 25 May 2019 15:31:57 +0200
Message-Id: <20190525133203.25853-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus and maintainers,

below is a series to switch mips, sh and sparc64 to use the generic
GUP code so that we only have one codebase to touch for further
improvements to this code.  I don't have hardware for any of these
architectures, and generally no clue about their page table
management, so handle with care.  But it at least survives a
basic defconfig compile test..

