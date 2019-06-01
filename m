Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F883C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC2332714A
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hmItU0Mz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC2332714A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10E1E6B0282; Sat,  1 Jun 2019 03:51:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06F996B0284; Sat,  1 Jun 2019 03:51:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E065F6B0285; Sat,  1 Jun 2019 03:51:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7C1B6B0282
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:51:20 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v17so4957222plo.20
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:51:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rc9LqUIutMEld6u5RSQ1sWzYs7kKnMm3S4iYITq0SoM=;
        b=es8tqZs53fqJndx4Z77K4ilkEKXd14GwI9DOoKr3eA1oiOCUC1e1ul/CbmI6mVGy9a
         9nrM4lk3yC134xcVMyrfi7sJXPyffPkxLlPetMpJ8I2NUmrhELUcd30YaPmMGlxW5KdQ
         WHG9hk6Sao90S7jgj6y+F/Y110iQeKMbDZONLOZ9kgVaBlwABuiSWDUjZwOMSp/HK5Yz
         J7YG2ZBMXUxt89hUb2qVUUv07J25uOJY5116KEhGNwuX6rU08pWXYltQ2C2A2tKwEmod
         0G72Pnftur71RdW5yJLDI19obl227Gend4d5E5baU16zbe2prCzS06algopNasn/hQgZ
         BiKQ==
X-Gm-Message-State: APjAAAVEhKg7hplyk6fta5aQqgMxw6iw6N9bfMInpZx2on04UcQW2NRY
	SRMFvrjcSVQ/mpEuXC6XVLlQuXUrh1dZfaqq7qYR6ZUmTdrNFpNpsp2JnNiz326wdAjsFeZIQkK
	NoIm9ZsQKxwce4SIjyyi851BqioJL79b75qalhA9JQfIBJiAzEkGJd9I3LwGtanQ=
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr14524461plb.278.1559375480308;
        Sat, 01 Jun 2019 00:51:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN6dKcM7ncWOj7PPqGdzEs6hg4L+YdiufZglt5zvQMS1Ppnoa+IdTvU0srilpBFqJS7zmk
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr14524424plb.278.1559375479642;
        Sat, 01 Jun 2019 00:51:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375479; cv=none;
        d=google.com; s=arc-20160816;
        b=opGe/rY0VqzRXdg5ophyZiwvxAijXKaI2QLSgWW7DHf9BNKMGBDVnSCBIy0ebFgO0C
         GsnWqwZvEj3TvbEuVu6QwYnIEAgym//53XfOCOxOT6DgArZ+FhD2Kaczfcl2WDinb97w
         3KZEiycxIQ1skE/8r0FjBHkWQGEbiWFzaqQQJAfC+rmgUWSipRTiDjuWyAgUciosfr7W
         UoeWWMZv8gxknb3Xw6SFYRo1I+h0qE9yIzEuFM8/15annVK/2EVQJV5NfJXqd7VRqd2b
         BHgqUhz+/3rIkBwqt0n6dV0+6wHZb9JhTiefxUlAyOFOfjwvCb2pVSyPLA3jT0k5TQH7
         ICpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rc9LqUIutMEld6u5RSQ1sWzYs7kKnMm3S4iYITq0SoM=;
        b=KjycUarx5dyaem+KRJ2+Eyd1MDixnQgqugUNpvv/uV4kf+DMkOW9PXWHl3F82mu311
         2HPb82+6GXWp1cbWzQ1+ZA0nSQebpRaPj0+eLn/ZT9x0C68teyLzKByU5GOuT01YLUqf
         kh4fQXxIqZ/Q/a+RiH/g9A4C9K/azG8zJQhUjvGhUg46wBLGvAHaLDojfm5JSFNzGd9e
         9lLVEqwDelFhnprZugFKBTlwaGF/JbHtv7mpzwG/CD8dpQQF7cZ293pGLHWA6p9R//ju
         xnJl3UQ1dcAMpuCdgbT6yj1qh+4NU+RFYtDSfRQhkjHvnIS0QKRbdmXCGCEHES0v7+Q/
         uHiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hmItU0Mz;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h10si8887179pgq.187.2019.06.01.00.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:51:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hmItU0Mz;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rc9LqUIutMEld6u5RSQ1sWzYs7kKnMm3S4iYITq0SoM=; b=hmItU0MzoKBxkW0xZSY+1V9IVJ
	UlnIz7x0urr62nzgcyqnB/5AQ1M6XxA40U4gxuVcAGCsZXzQMrqW+4eKIbaj5MYaWx5FKa+gz1mKz
	HRuyf4AFR/AjCjgH8EDN4vHwAhjKlzmMds++4hoDLSl7tnnj8utVFIcJ1xF5v2BvjcyJSGfnZhRgg
	CGtHKWy+mwizinD1wdoATmhB/sprl/mtqAL2Mea12uUVfEACrsVwrstfEucPET4mDXbr7743/4ZpD
	tGZvwusRlY1sYBD80QVps0fAgFJ6FrIu6GKRIDGA4zcDNIRUJhWop4eFhMFiU+OV0AXhP+aTvhS++
	PTXgcQDg==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWynB-0007sS-Px; Sat, 01 Jun 2019 07:51:06 +0000
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
Subject: [PATCH 16/16] mm: mark the page referenced in gup_hugepte
Date: Sat,  1 Jun 2019 09:49:59 +0200
Message-Id: <20190601074959.14036-17-hch@lst.de>
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

All other get_user_page_fast cases mark the page referenced, so do
this here as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/gup.c b/mm/gup.c
index 6090044227f1..d1fc008de292 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2020,6 +2020,7 @@ static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
-- 
2.20.1

