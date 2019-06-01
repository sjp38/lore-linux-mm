Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21624C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD72A26E92
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rcHoPkNB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD72A26E92
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 510C36B000C; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BAED6B0007; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37C926B000D; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2DE06B0007
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c4so6183509pgm.21
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yY/ra2PGFgbg7XqU3FF0wFq0V6rCLZSmY3LqWPMhNa4=;
        b=Blb1Fju8HoBYDiE9ASUUXNjXXiT8V7jGHaad+8PeY+Gq1AEbzngzD6kWxRYxRvxlQI
         KevZziHyAcGvN9KrGs+MtA0D1sYinbZb3+C75Qo+chr50ohtLajpB+kewiBVjhXOZmm2
         YIFzdwUy2IvHCuIQZfsi20dLFoP61Felontyx9TXYY10w45TsPGVGSBq/RZfIif3DAWa
         n6WiSCkRXTS2otq5tk5RUz0VEbNqq3uDst9FZA3/pR9s9XpaHLvN+T1r7Utdy+nOp/c1
         ZpTHZ/UIKkib65WilUUSfUgmRj+ojv++fhBWxVI54rXt2AjsNjri8akRvUz2d0di5N+A
         DHMA==
X-Gm-Message-State: APjAAAV0oD1yZ5Wbi1mQHi8fnsfIiyfXvUoj/OaoNGMezo4Mg6xAbe1F
	PDuwJeHyHaR1UwojKD9xdyi4DAUBUkCUwgfpsU7/r97DeonRN1Z2+OWVKC7wSfUXYwi0i4jGd75
	yX0KeNQx5wuSPmI5jkknzbf3CeFZzpB7pMTpnIqnD2neJsgIVf9X10FI6KQoYq/A=
X-Received: by 2002:a17:902:1cb:: with SMTP id b69mr14703181plb.1.1559375450554;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywEqktL2LiMRsMD4ZLKSImYvDHSO6U+QVJ2r7M3SYd40RFYfSUnwCJlLvVXqhmKbjwaYWe
X-Received: by 2002:a17:902:1cb:: with SMTP id b69mr14703122plb.1.1559375449540;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=jfx+HcEMx2m9KNC1hpeMTJ+BpFW82aELuAMMun5KW8EwDQpdIX0VYBO+EnBVxDiiWV
         ZyovqAw5WpPGIAzvqLAOAPf4z9NWGT7HLa4Q3i9RXevEmY6y7zX1Cn40q8iW0sifPCjS
         n6aowPiitT9ZyrVYoA9Iy1LekjKU0YobdFq6S3ixTlv5eeJFlPjPvrsbEmAO48sNem3X
         L/ZSPEXpqI/qjogGnGKzMgEvyzg9oPMOMM2Rs/G8Qu6/6Xfh3ZE32ZmoybZ1UzEXVpUq
         /cwa53XBFTB95O/AgyyFDO1SWa3nkhWhHY5wka+wj9tX5RqMRISR1TCu616eg86ivthY
         wsqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yY/ra2PGFgbg7XqU3FF0wFq0V6rCLZSmY3LqWPMhNa4=;
        b=Gvk/rS+QwmDHApW8ynz4+At9+a77+HEkIC+YAgroUKqA63JsJCG+fOPM3c5t9aeTPV
         0f3/MJ4uhoaIMX3b86e6o7hPLpOglABpCRKf4kc97yGRou1jkwfErWpNFfZXd0/lV3Sr
         xEv+2czrqWYWgdtpupvtQ+VcNiQWWSgMZBZqRFJsNiwM5Wm9yIXKR68XP96qYe4WHuIN
         BEnwcHNgcKNH8XA/KpjtytMl8khfY+2w33Ta6raXGSJsFyPG83R17ge4sYs8ujIDr2uB
         6kDFsXfz2uZ+ap/x4jT4lmCD4BZ2Ina0x5TCAZngc2xGmFJYFUhbwg3xf3HH2Qf5Q2+i
         7TlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rcHoPkNB;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p3si8960791plo.170.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rcHoPkNB;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yY/ra2PGFgbg7XqU3FF0wFq0V6rCLZSmY3LqWPMhNa4=; b=rcHoPkNBcn5I35lT0nSXPSoUmK
	4vxZRGXHEDwfmRiduNeBcHUEvPxoD8OJrN0S5PQmE3re/arNQar+m7iSLIMTsowGpB4Ex04zPb/gN
	29PPacLkhP5k/ojj3/Pa75U++zPDy3dYVb7BB3Paj88dFUs47D6xLlvkBHuqM7Il063uPmOqZZNcF
	wD8Tfl4VS9E3grfV6nmX4Tt/FE4OvZDbbNPrwWgUWcHBoL/a9qclxKhIIBdy59SE5ZBiYm89iK4RM
	INzpbbwRa9Sf7Gyw3QMcVnAV2C3wd8IfP0CShLYG4iQifTBRdaFTvSUlYc0QaQRmDfkZUOHZgrJuX
	0fxi4omg==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymI-0007kx-5x; Sat, 01 Jun 2019 07:50:11 +0000
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
Subject: [PATCH 02/16] mm: use untagged_addr() for get_user_pages_fast addresses
Date: Sat,  1 Jun 2019 09:49:45 +0200
Message-Id: <20190601074959.14036-3-hch@lst.de>
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

This will allow sparc64 to override its ADI tags for
get_user_pages and get_user_pages_fast.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcbaf1b2..9775f7675653 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2145,7 +2145,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long flags;
 	int nr = 0;
 
-	start &= PAGE_MASK;
+	start = untagged_addr(start) & PAGE_MASK;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
@@ -2218,7 +2218,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
-	start &= PAGE_MASK;
+	start = untagged_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
-- 
2.20.1

