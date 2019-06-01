Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4159EC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08E292715B
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="REuEawrB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08E292715B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A33C26B0280; Sat,  1 Jun 2019 03:51:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E7336B0282; Sat,  1 Jun 2019 03:51:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 863676B0283; Sat,  1 Jun 2019 03:51:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48F6A6B0280
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:51:19 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so7829762pla.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:51:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=d1mKwnxq0/21AleEJW7W0Ivu2dwVglOxlHTSE/EgRxs=;
        b=kq0+TyjowPK/ua/jW4cpAYtE8CkP3a9Zg8zYAeTq8bptNXykfV10d8xrFQ8wvZUXWv
         FRZAzOyUr+QKLt6bWt6EPCgPCElrneyTXcOa2SlMenD99eOpHCg+5FLM4SCJg86yyiPY
         5tjER08JlTYwzkjWXJ8yPxFA0KOL5Atwt4MVkNXKhlDqOBPxRiqFI7tWpl+WpvzFgt3T
         waKUyLpK+xGVDXrFcLB8kciVqB9cOgM7kizg56u7/GH83nLb2wREaHxzv2s4BFf1+5jO
         NloO3CHTxJNeloKpyJDwI2Zj0KyEqn38m41HSKcoIWD1d5Xsu7hsVEdH7wB9W6gbqzQp
         uF7w==
X-Gm-Message-State: APjAAAV8q65upH6mOjzAMkTY71OpdNCu+7hClOqPs5AMTs6WbvqLH6C5
	5BwJRfjxn3dzNqV6BfyL/ZfXdNKIp/DcZmv1asrcnFPm0p0jKsO6kNh8x4vP4nAr8yesIlJpVKp
	P6aRfwn5Ml5b/ENSUfIWyD9FTYXsxRWxaXZN+vgQrbBJF+xMbI2wnfnNhoo5MMOY=
X-Received: by 2002:a63:d354:: with SMTP id u20mr13383102pgi.129.1559375478939;
        Sat, 01 Jun 2019 00:51:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5TuBblf7RcdIWLa/QqTzDROXEiel7BnPbKWNxveowTo/7Teebw0wLKjb+dLvzLjYjyB8c
X-Received: by 2002:a63:d354:: with SMTP id u20mr13383073pgi.129.1559375478131;
        Sat, 01 Jun 2019 00:51:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375478; cv=none;
        d=google.com; s=arc-20160816;
        b=v6OP5FCS4AOdvWeDbm6XqHuscVNL9eHvEs0sSZsFKj8B/xtbxVpCW7CkOTSfcz6C+B
         T4YIpmIV1845NXnNvtPYalxPidTmLwmTDDxdK5V8BtvGwa0xxOCiuSV0Ib4VN1zQASX5
         fTmMBqWQZBNp0aAStYds+QGQ7koWt0xpTOs6QahxDTAb4ts9JEIr7ys06Wwsp+DSOxC/
         yTSHWfchQVI04ZGHPQxOmQUbDz60ucY8HTlktIinyY7aGOE6K1fAiXpud57Oietaif+O
         4nQ373mjxrLTSCM3p+pHRLPMVUhnnqTyz9Z6gDaxIqFIWUidNUj7C/nz3hkuftC7IvP8
         RnBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=d1mKwnxq0/21AleEJW7W0Ivu2dwVglOxlHTSE/EgRxs=;
        b=0aS0UONODntg3aj1VjMwaiSn07wZGWq/MdYzDeY9kfZzb9pUJ/7PC5cEa54f5tjb56
         1ROMt3Ve6RTt90N1SgT1vctKeckL4NiJIXQkW9krjuGYs2w/KKjmYQyO+9BbX2Zj/5Qo
         16qrwcMBofUfS3ArqiA+zLcko3+rslcOcLTfEzb6PW7GYaUq2gBQdEzA8eZG+CmxvjcD
         dQIFe+n1jaKVmAk2w+t60r4HqaXdV2EftaKyvDomhp91G1++27KPpPTIW0W+FtbIEUD8
         00lqRdC765DB+25sjHI6UH0vdy/NfO/tT2N868shFALLNAWUpJxsyTOPU/sDZP+mHjnA
         agPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=REuEawrB;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b11si9333062pgq.455.2019.06.01.00.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:51:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=REuEawrB;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=d1mKwnxq0/21AleEJW7W0Ivu2dwVglOxlHTSE/EgRxs=; b=REuEawrBG9hy1w/8tCiSMSGDQr
	QmlJAVeLmCzHaQeCZ6QVeotjDLj2GXg0W/wnB9YZ+BE6+11w0s6WZNPG/ikohc3P+qPllwiZPMOZK
	Uf04Dcy7w+CE2UCj6lraV7/IJ6LgNaen6eTng5WzyUKlNntVp+5qt3qWaxSE8Xj9X9jm3fnM5ql4O
	0nTV/cHhydhIgwqLfn+yXdOjke+6B6TCGd8c4gIT1VmjmBwuNJIQ8+VkzzOaaEcb2BsUXCDy+tudh
	rVmzdbazRoVoLH18OBy5SxhO/nmLtVZkuB2qMC7Nswrxp+XFEatPa01wyJPnEAwRdzn16fDGmzYOW
	wWqwVD1Q==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWyn8-0007rr-9v; Sat, 01 Jun 2019 07:51:03 +0000
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
Subject: [PATCH 15/16] mm: switch gup_hugepte to use try_get_compound_head
Date: Sat,  1 Jun 2019 09:49:58 +0200
Message-Id: <20190601074959.14036-16-hch@lst.de>
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

This applies the overflow fixes from 8fde12ca79aff
("mm: prevent get_user_pages() from overflowing page refcount")
to the powerpc hugepd code and brings it back in sync with the
other GUP cases.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index e03c7e6b1422..6090044227f1 100644
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

