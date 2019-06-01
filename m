Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 123AEC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C90E227144
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ehdh6hvl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C90E227144
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AE426B027B; Sat,  1 Jun 2019 03:51:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 885E56B027D; Sat,  1 Jun 2019 03:51:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68A076B027C; Sat,  1 Jun 2019 03:51:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 332376B027A
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:51:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u7so9147646pfh.17
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:51:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tBVEdevPoucewTq4OAhkR7FJKNQsBjZp3J3iboXORi4=;
        b=GyX+CvN/nc0Vg2PqgFOw5mLgSlq6wSBfWufptUT0qT6CXYb+BRf+nZt+X4JpwJzrnW
         4X6aH2hrcSinHH+agB+SwAMq+MXSN8wcDCC6/zoD5la5ps0RxQrWsQJE4MXVO4OIkC+Z
         1kE5hURIXYkEkExzzjF+IdSwAG8J96URxRn0qHrS1+wMhkOO4NkCe21b1txewZFB6Y0X
         4cLoQnz9Cn5CaMHK/GnRBz1Ter4D3N2/BoMTm1phSEmWi1+HXjlIVT75m1CwAp8Wd3Hv
         dgsNPnZkmulm0dbIAvcOJWPmJlYimgtJFDsDzOAX42ay7YeTtAnYy/Kq+5ac3rjAo+7C
         htLQ==
X-Gm-Message-State: APjAAAVMp9qfJ2NquxFAnoOeZN16qixVgdObqfCkmJ2VaEsaUyaEoUsU
	Cl9Oano5zeRFJp9zMN7tEOukekOMu8WO7mQXKpcgeNsyb1GUo6vlIPAdI82fKJWuH8f8d4LoR+x
	8aSIw3RGVcHXxJPmXSxa82QYujkVQ+9Qt2RxOmmr0+bkbGQaSBPkbBUWSFcsQFTg=
X-Received: by 2002:a63:9a52:: with SMTP id e18mr13872078pgo.335.1559375470861;
        Sat, 01 Jun 2019 00:51:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJYBUPQQXXy3Hsy8pqs1JBf01Kco44krkhxQYhfu6JXpdrNyfDRj52AqSUdNnRM4knc52r
X-Received: by 2002:a63:9a52:: with SMTP id e18mr13872050pgo.335.1559375470146;
        Sat, 01 Jun 2019 00:51:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375470; cv=none;
        d=google.com; s=arc-20160816;
        b=T8mWZjIxgnkBq2dXAaBM5jdyJTP8H6+8IPp5ML33/fq4syfxjkcdMrdQpYVZSrFgEZ
         eWnde2MHRvDFkHfVg5JzbtFKUs7TZFyEULEeOwFwrru50pDH4eYVUE2pR03j2OpVY1Ul
         xxC7cAlPGQrPerJX/QmK5ERqgjAyGofUVV8NZeSfiF0XwAOiNiJYSJls0SzDbt7CxOuP
         wVMztx8MJmtr/M8tv53ebjWkwMYpVIW9+F5psoKQ5TkHnLJMs33oKTWN5ctqChg37jJ3
         6rn+PkA7TTL7gRHt6PEyeSylju5dO0NJT/J9XHJM4lQCI/BWZWPf/v5y5XSTtcmvu8up
         tL7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tBVEdevPoucewTq4OAhkR7FJKNQsBjZp3J3iboXORi4=;
        b=WMxsdBHkZgA6SyP2x0XKnI/B6hcmGaVlDKGxUuqGMjoueMcQDWaeLslaIqPgcG/UNP
         cSt2lMYuYZwk3UX4gXJKq16GWz1aZWmpVCGckIgucQRup++d8rsboS/5w1i1q0Pdim1j
         jU8dNL3tzbb/DBlZYrjWsQXYzmXLd88S64r6zq375piS73Cn6eyllh7P0M2DiYq3JNm9
         PObuPPbPlyjbGwkiE6md8sYrrEfmubV6GtIfDo/rnplwuvIFeNZTIGsF2FegdXhcw3QP
         9IsjprY8wIh5sbFCaRe1KWnxWnzPqZEX7qwZvjvkgZJKAxbL7PGYroOun/Ga4WOOASO6
         nv0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ehdh6hvl;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w13si8725325pge.212.2019.06.01.00.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:51:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ehdh6hvl;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tBVEdevPoucewTq4OAhkR7FJKNQsBjZp3J3iboXORi4=; b=ehdh6hvly314iwU1GnFuHEE5gQ
	fB2jAQcWZO4o+YOC+NJC2yWmmM772WTP/dLU/OM2dY/F3SXDE6UCRYeP2PYPbEeLJqneh2MERfV+g
	FcP/ATctAjNAhXWCGq1kezTvlWJNWdyKMSZD/sxA8Yx7y4dOa2GRyBgwUYDgB0/guLH+/24UDpQgu
	vjFUXTcIM6lqq9YjbfcH8h0S/DFSb8DRiG/N4q3UCxByRO4iiSuavdtY2XKPMhbdOWtyIOiou5eXX
	+D5M4jODgdxsUV6vZagl5C/VnqSARpiWDTSre9AfvM59FuGkPdH0xOTu258kDXC8kXZFo3g1E0iuY
	0WpBgjow==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWyn0-0007pM-QN; Sat, 01 Jun 2019 07:50:55 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/16] mm: validate get_user_pages_fast flags
Date: Sat,  1 Jun 2019 09:49:56 +0200
Message-Id: <20190601074959.14036-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can only deal with FOLL_WRITE and/or FOLL_LONGTERM in
get_user_pages_fast, so reject all other flags.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index c8da7764de9c..53b50c63ba51 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2316,6 +2316,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
+	if (WARN_ON_ONCE(gup_flags & ~(FOLL_WRITE | FOLL_LONGTERM)))
+		return -EINVAL;
+
 	start = untagged_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
-- 
2.20.1

