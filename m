Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02E49C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B96E7214DA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="taUea8cm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B96E7214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C00C8E0007; Tue, 25 Jun 2019 10:37:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 370608E0002; Tue, 25 Jun 2019 10:37:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EE168E0007; Tue, 25 Jun 2019 10:37:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C39C18E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w22so2793899pgc.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=;
        b=aAYNOqD2M9dBmtKo0aeZu76pCUNHl1Ri0589Uejb1SFE/vdtef/dgAbC79F26xv1m6
         B/vyXsci3XHU1Rk8fyWHHyJzC4XyVc6ZE0Frf5u/lKoTuWHlB+6rbbW/eSH7nNezNfVV
         98R6eb9LDs4J9gH7arzyMndhkBed05ilsYToDbxeE2uH9ZiYs7LzZAgabPTwYdr6vHM6
         UNI4iqBdw39SP4Ai29GpbI+pwzQcx0PiDTND48Ak2T2JpTv+dD7DGIbjR4dqBMQzd9w8
         I966dU0UZdDW6cpjIGRRJ+V1KlXhC1Zzw0CoJj2HEDrrzFEIKiQlLpl8pH7owG/I0vOJ
         5+fA==
X-Gm-Message-State: APjAAAVwbR5bPDFopmXZNyxKu/1EZZLUKKwgMbQLPEC4H3ohtRMGjO/4
	mEA1NIJuVBRZG/kHQG6kuMtgYGUYpsaO65EKuIc2oag57UkFXY9rFO+JuVu/i+wy5whX+k8Xv0T
	OTAaD6CtHBrU70ScDoBFIBf+wWW/6UIK6q+PlPc0MMwYnhOistRmOFya1FJJDI4s=
X-Received: by 2002:a63:ec13:: with SMTP id j19mr19293380pgh.174.1561473473427;
        Tue, 25 Jun 2019 07:37:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxikwUJ2kjcCOSfkJ5FVQrkpX40PWXPyXvBXkOrJg3F3UwCgZGuyuJ6DISdGouK0WGH3g2h
X-Received: by 2002:a63:ec13:: with SMTP id j19mr19293339pgh.174.1561473472729;
        Tue, 25 Jun 2019 07:37:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473472; cv=none;
        d=google.com; s=arc-20160816;
        b=GXYB4IlwoDUcwcEPRT2LnfBJjOHUjwXv+J0nZhEI+qJfJBDJMssJSuRdIYOOaRzODj
         hq9vFSCQxx/DrkMDX2htdLhKAQCUHagRTevMzMmKiN/WqB7RbCj0TBy7zu0M9FRk0tWz
         8NP7+gtfcBdh6qOZa19ZRWs7iuCjqolcmT9XGAllmuaxaNKBmghMHTlm2p1wHE2GOmg2
         WTLqoZPNX2XzcbH1FfxnCPtwtySnukeqrMVg8gCjEAHX0s8POK1Az23R8jYHDHyl855y
         fxVbXtl9NUwSQ4CwlKrLNJ+DR/Zekr1J+HHQofXaAgS8fnUCkUtNeOX7+/DNP3pmt1Tw
         BC2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=;
        b=VlcwwQ2Fq26UhoWJaCj1ps8WM1nEs9FC2mqIY/0vslgasyD1R5ZuxW2B1SYKB8kjCA
         ab/v+SKKCnzCvHaoYObmdXtNFXViXyhjIEXf2M58eyUPKHmZ0PCpF7I9rQ8WvCwxxd04
         6h89TPG7iau2RYQrtfP5FbFBgNDo/Uemfjh1Mnq5Px9+TBcqilt9also56wei4f4Dq7U
         FhA5al58tgR+EA7iGUATRVSbuboMe+xo1LvnVTdD14z3RbVaQJeApip2o6/chtFfd5bO
         ZEHzEDAM38l+bPf9M3VibKm2VLOQv0zPIdszAVvJhV1bsjsnSE7CMsmNCfpyNuSvSM+q
         QuPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=taUea8cm;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h194si15161530pfe.214.2019.06.25.07.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=taUea8cm;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=; b=taUea8cmHqyNdvhD2wgVGB0dn9
	UNjhchjKAVybII1/xC+BKN2QzvKFCFr65RLRIrYQ5h4VNHBnZrtGlvGb8ysL1RNjg0DIGXH3JJr1I
	wMmt0t69KSievW3CsBhwGLOMqCpmB619xq3/7dNBm8QoSK245z64i8ktRJFvsX6oiaUYgokit7Ev3
	D09QUigKWtdPTnPr1NAYcmON9yQk7kWkgyVI2wQQX4iGZhTHyA2OoMmC6neGyVEt0qA+n2vzKFob3
	lwTirQjakiJ+2XeS0olA5OJaEgxmx40KulfZoE0tJi+IazqucJGMT7t3wUDhq1sUX+wQ+1FStiMvB
	g1sc0hpA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZo-0007zf-3H; Tue, 25 Jun 2019 14:37:40 +0000
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
Subject: [PATCH 07/16] sparc64: add the missing pgd_page definition
Date: Tue, 25 Jun 2019 16:37:06 +0200
Message-Id: <20190625143715.1689-8-hch@lst.de>
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

sparc64 only had pgd_page_vaddr, but not pgd_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/pgtable_64.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 22500c3be7a9..f0dcf991d27f 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -861,6 +861,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pgd_page_vaddr(pgd)		\
 	((unsigned long) __va(pgd_val(pgd)))
+#define pgd_page(pgd)			pfn_to_page(pgd_pfn(pgd))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
-- 
2.20.1

