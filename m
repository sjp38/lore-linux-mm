Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F0BC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:19:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37843206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:19:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="B8zOfMOL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37843206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04996B0006; Mon,  1 Jul 2019 11:19:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3328E0003; Mon,  1 Jul 2019 11:19:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC9878E0002; Mon,  1 Jul 2019 11:19:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 9575D6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 11:19:01 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id u4so4113365pgb.20
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 08:19:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Ba+Jb98yVS5mZ3n94oGXQBYD6fv7eSFwFd2YiewCW0=;
        b=ms7R1+7yOWrvdo+q77Rbc/+NJS2pemJ80aprMAYiVcnOb4KjiKOK+vrMD1d7THvBi6
         NS1jutVWprC4K9CJ+OkO3tmR8IQZosp8R/eRxVNi+8YCjK+5asQOFzpgMh23TNee4DQr
         KnfDfbcxrVG9K0M6dlKkbBXOt/gJgbJ1nXsFrszge14I25e4U2NhIf+hsGShcTL2p+ON
         3az1qff4s0QwEHvVW+NkOomk8nqI8Ny6A5NVg6yH0ycEovdTNzkkQKOMxfwTb6jxzeaP
         IzGq11bduVKMNkx0lOTxbUYqHMVwsp8vK/Rn3uMBEJ0HmCoTjF5sY4m6A+biJTfrTCs1
         +2Kg==
X-Gm-Message-State: APjAAAUSWkASAqtfBwaOFDw7rAbg9MBzJiCgljjknC/WQZPvF0B5hFXh
	Lzt680DLgspV07bE2vB3rFD2zt9ydNEnYqFRniyXSFaR8wJVm/E1dCDrBRqRUAzKCrVHdZB2roD
	vXP9uCTuPr6v0gW3xXA9eEEAX4MJJd9p4mro72gEKFJsXoJXLK9o5Igrr0lUUl+o=
X-Received: by 2002:a17:902:4222:: with SMTP id g31mr30713983pld.41.1561994341244;
        Mon, 01 Jul 2019 08:19:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxA8ZJq581oFBapTakAUbJXZqO2l+CBVES6M1H9tNJ+Vduy2QZnPPxcCEy/l6IPyr/U1RF
X-Received: by 2002:a17:902:4222:: with SMTP id g31mr30713925pld.41.1561994340531;
        Mon, 01 Jul 2019 08:19:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561994340; cv=none;
        d=google.com; s=arc-20160816;
        b=Up4mTjGx4Gtv0OZ0SOAkUHtQGT6P0cS2+bzfUPY5ll8+CAh1lhMOL0f3AdjIInS7x5
         r7kphf3xVM+VthD+jL5+n7m03jrSlN3EoRN21fpm8ap0NWiXKR8G7Y7yGxA9+YSZA/u+
         MqXzex7Xjlww8L3preTD+xTX0k3/o9QQvWc91+Jgk9yUt6VY02MZjti/x8CriVgBu07B
         TWkkFfoc/pXcL31EpSjP7Icny9hsIAd59d5SqOcHZUszlyQLmGxbSdmvpgoxPblcCot/
         MoTRPg7KMTcwRj6mtXBlmgYtp55HYDcirtCgzENfaB0xJsYkq77CtyPBmHfdtr2kogpA
         1N0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3Ba+Jb98yVS5mZ3n94oGXQBYD6fv7eSFwFd2YiewCW0=;
        b=wNFk0Ec2TwRhNm5sGrjWjtruklzPmiP4GbblSF8Sfy2eVnG0rEKX9I/FTI2Bmum2JS
         9RDp/aFjWc5GSLfzHeiKTcVti5Ua1N6zCBNDn/2QmJG+BqEKPdwZPEICy2SEdo3oV5YL
         KOA/2VO6FRhRn1T3mrfePDnlkh6sOfgD/2VgBs4XIWdNVgcxnLKF7qVXgTCRJEA5k99k
         Z/BbH0/m7pwJC5UNOavV624yaz1bzBkqM88hSdjrj2+Cmu+x5MBajw7/MD9g74CHjVUp
         DlvXxm5f3zFqxNxr6kRE9cbSvA7vLFXrBZOXuM/3Ta2gRhgi1sqlH2Q/OSBUV9gJLLcx
         LuyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=B8zOfMOL;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3si10675612plh.265.2019.07.01.08.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 08:19:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=B8zOfMOL;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=3Ba+Jb98yVS5mZ3n94oGXQBYD6fv7eSFwFd2YiewCW0=; b=B8zOfMOLAu59NaUvSy8QYch5Jh
	NskcwR4SmdPEjEvWY+1ydPBApZywsDWMb5u4PEb5VzW92AySwlrysI5iqPnkp3omLj25ThQsOC8OQ
	VhpVvsHnGevdZJh5uci2lEnl3+OnEZs+hB8YdhBvjqdmhe8uaZ3GTURjRS9se6y1zC6uTlifH6Duz
	jQGnrj1ElyoefePcSMTTs0ZEzU/YG5oQFbDmjs4gOMgXnfoIaInv2X4QwXyvuepYtI15agNcO8hpv
	vQQCvAGi87ceTgfl8rtDBr32iVm1vSdz7dsEndDPWwZ3k9U1ghjO+iHrZ4ion4SiXsUNgC4FwnmyB
	jV4wmmCw==;
Received: from [38.98.37.141] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhy4q-0003zx-QI; Mon, 01 Jul 2019 15:18:46 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>
Cc: linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] MIPS: don't select ARCH_HAS_PTE_SPECIAL
Date: Mon,  1 Jul 2019 17:18:18 +0200
Message-Id: <20190701151818.32227-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701151818.32227-1-hch@lst.de>
References: <20190701151818.32227-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MIPS doesn't really have a proper pte_special implementation, just
stubs.  It turns out they were not enough to make get_user_pages_fast
work, so drop the select.  This means get_user_pages_fast won't
actually use the fast path for non-hugepage mappings, so someone who
actually knows about mips page table management should look into
adding real pte_special support.

Fixes: eb9488e58bbc ("MIPS: use the generic get_user_pages_fast code")
Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index b1e42f0e4ed0..7957d3457156 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -6,7 +6,6 @@ config MIPS
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_ELF_RANDOMIZE
-	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_SUPPORTS_UPROBES
-- 
2.20.1

