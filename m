Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AB6FC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11994215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mx5wCxAm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11994215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C67D8E0011; Tue, 25 Jun 2019 10:38:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 851768E000B; Tue, 25 Jun 2019 10:38:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F02B8E0011; Tue, 25 Jun 2019 10:38:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9048E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f25so11960437pfk.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IRyX7WezlAVDVbSdXLwEQAHdOH3yDAfA0drmqFGnM/g=;
        b=PuXdHkEAmT1VXcLxsFSohBEoNsbBOONHRWrIIKpM5chG8I2EgUWuaDxNHvkHvl7+yB
         zm02hicNS+Y6qnGdgycR4zDHLlPTGkHQ++SlSsAekkOKpFPPO4nYH0AVhC9y9i3hwgpS
         P2rISxyN2BPmzRncQMEiDEMDu4Kp3K8QeidRoIhmncbW8FOnNrWoNO21P6a7duCCeEus
         fyzUbLl/GiotnNJH6cUxuMTpdAZ3uUvN7OnQqzlUzTOcoAE1SRn8shzEAJewRSJNllTO
         HQj0TGQhcOnEwL4bSD/ofCRaiNo0MKmNEz6CziR/vYsE1UUGH8SMkQxasWiilgHtVfN0
         +Chw==
X-Gm-Message-State: APjAAAWdvOt0NFq5SejNiXopk6aNzqrwR6vT0wb2mZnYO838mYLyF9ED
	bBWMPfISbebvKW3hqkaXn/5TtoE6B8r092UzPwBU2djKbxpy/Mu5jYXK3J8FknX+42iq2Nrla/f
	SNNGB4HYqUvjq6+pu0xiCgjpAoK0b0QdMhkLH9wZTWZjJSaVWLiAt9ZNfT8nydM0=
X-Received: by 2002:a65:51cb:: with SMTP id i11mr38033455pgq.390.1561473506725;
        Tue, 25 Jun 2019 07:38:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8PFi0ZmobjpD/JSGw0Iyh5tq64ZoUxLbxWXR4Q/u9kHDIRyQSKTk8qES2N2APSU72CyAd
X-Received: by 2002:a65:51cb:: with SMTP id i11mr38033395pgq.390.1561473505872;
        Tue, 25 Jun 2019 07:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473505; cv=none;
        d=google.com; s=arc-20160816;
        b=GlSRkL/v+t+/SfVkpnb+o/j4aYWK555dYCEA+ui9BrxjlqCqg4rp+tTrU2xgec1mZ3
         Q2R/p4S7Yu5xW8boj/E7EJJpYi9WsRIID9wNq5ooKEFhTX68lr0NCyNToiibBcgkCoAF
         rK3FQvgZkfGGrUs+N6J8xWbvQr6Gj6HLTT3bE2o+zqxGROOiYUAyjZ4Dh/i16mUVv/Qt
         Y0ppLkh1YagMtZBjPocrNHHafz3pLYattVELruKvQeEe4g+D9KQaRhReMjvX3F/dPG+A
         9GAqK1KnaFgkHSLPNZM6b4JYpUEsIjNjp5iq60fs7qe8ZKFm+OecsL92cAZyFiRiFxZp
         338A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IRyX7WezlAVDVbSdXLwEQAHdOH3yDAfA0drmqFGnM/g=;
        b=BsdWRyPnf9f4/54mXBJ1lcAY3Q08c0atyC8VR+O05TPJOKRJdJDr5V6YMgjQy5LdNr
         FJjje5bexw6/93VKAlsHBGs+9HpzMYUgBHEPFIIAuQ1cbk2AZC6sfX1n0/s9sSiY6LWR
         qtB8n1BMh2TaOkMRnfIeySHmeUlBzEjI/ScwmLDBPnRHv3Jx5PFxF1Q7Om/pukAQ93iA
         xFX3kDNA9lGdy4q5t6b/e0DaltXYHEnt0lBC8tsrTFLsBhchiyRH9gJjdAoHl8YsVBVv
         l9cs31xixQsBvH6zuzjLZBF0eG9Eg+7wplCj/6MviwEGZm5CuksD6lYzh2e3+VKp8vWr
         91UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mx5wCxAm;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k1si13240754pgo.574.2019.06.25.07.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mx5wCxAm;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=IRyX7WezlAVDVbSdXLwEQAHdOH3yDAfA0drmqFGnM/g=; b=mx5wCxAmvZg0i6ol2LaSGyLT44
	CxvPd/9fdlWmr2TxFf5RpjGlB2FY1BoBYpf+v+X8HSpJ0s0LdN/ijmpHTycSjpjShxE3zRR5drKFc
	U/Zog/l582GPFD22R0swDs6BpMeeV2Ud4oOeEpKE+9rAJ/xEEjfVAnJM2D2BnTm7rmWApYQKyr0l9
	a4OMUcW+x4vyahFylZB/x4EbDFmQPEAV4DjHt3WK+fVqg13S+BlhFUb4EYB8w2A0tF0vc4NE2v9wW
	wUm+jx3C0i2aGls+NjKmOMMEizlMkujMCKOc6/NAtnG9tNswgPc/c6Q+H8rJLWAJg7b4b3dnP9/1i
	htToIvAQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmaE-00087r-Qt; Tue, 25 Jun 2019 14:38:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
Subject: [PATCH 15/16] mm: switch gup_hugepte to use try_get_compound_head
Date: Tue, 25 Jun 2019 16:37:14 +0200
Message-Id: <20190625143715.1689-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This applies the overflow fixes from 8fde12ca79aff
("mm: prevent get_user_pages() from overflowing page refcount")
to the powerpc hugepd code and brings it back in sync with the
other GUP cases.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 7077549bc8ea..e06447cff635 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2006,7 +2006,8 @@ static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	if (!page_cache_add_speculative(head, refs)) {
+	head = try_get_compound_head(head, refs);
+	if (!head) {
 		*nr -= refs;
 		return 0;
 	}
-- 
2.20.1

