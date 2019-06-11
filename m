Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B620AC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D3B92054F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NOYU9DLY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D3B92054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173246B0272; Tue, 11 Jun 2019 10:42:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FE646B0273; Tue, 11 Jun 2019 10:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1C586B0274; Tue, 11 Jun 2019 10:42:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A445F6B0272
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:42:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so7887276plo.6
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:42:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A1i8h65qriplI15qgyPKPV5aWfBos+CWcUOK7xSAxuY=;
        b=WKsLmDvJ6XBbG6V5IBF/YexO2zlYKmUtgUe0WpEdT9kSjemP5rj0LyEjB1uijGOilO
         023ZDEeIGz/AIstbOdLFEzeQWqqADZ4LiECjnZeD/pEy+gtaOh5S0HWcrYlaafj0OKpg
         h4Q0tbiPwWRatf8rWId7qTMUwZE0+QJLz+a2hpzx6uwAUuBn0z6QKjkY4YRsA1Hsy5bA
         W1Kakwr+I1R1K8DZj3Pf64kF0VUCggaJEQSWHlMic9zoHKNxbm7NLjASWlberIJbcGJB
         0XkMlXocxCdRPhHBd1pa2osVX7sfQe2LOXY9EKabb6GgE+zYecpXzELKxmxxLb1LM+Qd
         4i4g==
X-Gm-Message-State: APjAAAUZdlYOwVONAQwPqbFdICRqXseWydFrlk9zMxlM4fwDk/gi8BdH
	LhkHrR4RSWJiRXLX6lY6L4EbYIjqn0kPWH5soV0qAs1yM6mTE94C1E2+PPY+dyK5NUJYnWm9O5T
	u7qRMhrjzy0lrRT1CYqztwN6SlzIVAm+xMmQqx1X1NIQituWia9jfwfAQJO39j8g=
X-Received: by 2002:a62:62c1:: with SMTP id w184mr79678495pfb.95.1560264127295;
        Tue, 11 Jun 2019 07:42:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKHo7zm5Y8wtF/lkZQ2nr24Xuwqygfg0oiD/3bTk/l6bmPlKaiHpeHBLxk+BgV95IfXEK4
X-Received: by 2002:a62:62c1:: with SMTP id w184mr79678424pfb.95.1560264126336;
        Tue, 11 Jun 2019 07:42:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264126; cv=none;
        d=google.com; s=arc-20160816;
        b=XDF44N8qLjMFMs8N6Pz1kjbZE6vMeNaHDczDnEoGIAnZ0fmrsEuR+FzxN5q2jK2Hxx
         /nOESxNwLRXOkDep2YYtJmEa3KpL8F4w08p2CO8Tf7pIhwtNSLTag7noDVCl8+7htKBy
         enCqkca+Op9OnqZPgxPh3ibDCDbyZJWlboGaL5TPggecWuhSNiRaNGKj4CkLlMQcSD/J
         9lEMgQ9qV14Flj48rNwS9J32MiSwf9C6EdZIK63Wesw0WtM4hhCdkGkIHy12ju0oJY/z
         w+gJSum4n5GZgcnGon0N/xAhh+FxUMpwocCTugIznjzkFSxhw+8gPT5KHmQGP5tMt5m1
         pPag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=A1i8h65qriplI15qgyPKPV5aWfBos+CWcUOK7xSAxuY=;
        b=ZSw1px25qj/46cxFlvySNIlpHYzdDeM64+mFSjI1sPj9QlOU/OZMZ8OyNo/tDTmDMN
         HFCapTGstkOkGmyF3lI4eKoNeMJe7gTK0EnzO07pyE0nABtgtJ+KOVD+M9OfBWcgk181
         O6QIE5Q6wZQ9S5WKLHAaZxFZcrgC/9ZcAqcK83WmMnKtXyFJAsakW9vNYwNTQ6yn1d1p
         oNYiQcLdb1nKOYTF0m5w91gvv8yoFu64c0S1hyuQ+K3W+/oDTAoAGUs6NSccvmAqzqCd
         UK9hy8D9RM+//CGMVgjNknJllcvMzLzlkzBJTuPDLLiBQvlflfnbLBOML+PQj/LI1UiL
         tk3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NOYU9DLY;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 32si12916395plb.86.2019.06.11.07.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:42:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NOYU9DLY;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=A1i8h65qriplI15qgyPKPV5aWfBos+CWcUOK7xSAxuY=; b=NOYU9DLYhjro838aLFWjvDoMbZ
	UkqZ8t//il4sKiPD2MvuzAucG5i7l8pWQ6VZyXnM1lDiBoQSz1ebEgO0BoHCTP8qbcTO53B6Bxri5
	4hFy8f18Wb9wpm7g7LLyMcw6j6ZRXpvaD3DUeonwZKNckLX8QbqQvsZlKL5eHMh/7DG7/kuoYQcX/
	YW+S9XokqeT/7Vw2z5+vqNVRt8eGRYlmsFbAa22ATQgqR5aJPASr2OARLcEF1Ta3Mn/k33RIaEXrm
	z6rmE/LSYeU+Btb4GR8sulOJQPhFjwpE69UYW3PVZcX30EaXUIHK9X6wejIo8dhub+RTZQTowcoNm
	oUmZ6b2A==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahyB-0005u1-RB; Tue, 11 Jun 2019 14:41:52 +0000
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
Subject: [PATCH 15/16] mm: mark the page referenced in gup_hugepte
Date: Tue, 11 Jun 2019 16:41:01 +0200
Message-Id: <20190611144102.8848-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
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
index 0733674b539d..8bcc042f933a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2021,6 +2021,7 @@ static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
-- 
2.20.1

