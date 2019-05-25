Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4324AC282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 070CB20449
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lJyfeDa/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 070CB20449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E536F6B0008; Sat, 25 May 2019 09:32:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8CEF6B000C; Sat, 25 May 2019 09:32:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF5606B000A; Sat, 25 May 2019 09:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE5A6B0005
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c7so9203897pfp.14
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0pMukIaJ8IjZEEoYFUSUOe32+fVx4NLHIFSad+NCaKI=;
        b=GiTnQzMlGKw/b6hBEj1U30TpPErrJEIM0EIc0uOfDs71vQbRUOw28UeHTVoxbQRIZh
         qn9HmXCkKB8PsUez0mG3Ri7xgnat9T+SDOMOJLmMJbMyctL6tVxy5HenCujqXI5F/Y/q
         DopYD83lRg8VdblTvRpoDrC5KqSRGVqUqZ9YAhPnKdOgeUfiRSETD6x9QzlnEyCVVc10
         0ZiW3SSDTxOdfmr5mGNA0uGZw2ClFo3V+OJjhWZuWKUcRmZQcxrX1Ha4mgveJNZJjgZC
         94bTsLUxtUTQB9pvf7pjR4lkkeyzpAOTvl8O9SPGQRNxS0v7otTxa92S9rprzaFBpceY
         v0Fw==
X-Gm-Message-State: APjAAAVO+T4Uo/LzmOBKEIOpHA5CBLMfvhsYsI2WcWjGLAa4jbCJdTnH
	ECnzXEBgJh17FgrxDM02uItQGZDTG0bssc/yXP4Z5w76SNlGL5o4PVyQ3So+mTl5TFW/HzxtmQp
	1A0OWkX0SMt9O6djjtI55BYLr2m2NxLp9AsjjrRRRlF6jBTFK7dHhIpky/7ZM/NA=
X-Received: by 2002:a17:90a:9305:: with SMTP id p5mr16074236pjo.33.1558791140975;
        Sat, 25 May 2019 06:32:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+mEZb/ZZNpuA3rNhZIQLUaagO64vJnJlwocccBObEKRdE4MzvRrZB+/6N47NJM6UK1bW9
X-Received: by 2002:a17:90a:9305:: with SMTP id p5mr16074117pjo.33.1558791139955;
        Sat, 25 May 2019 06:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791139; cv=none;
        d=google.com; s=arc-20160816;
        b=rV5k/o5Wk8cW+zLxEphPP96yQ0b30on2hR09wh/ifbPzZVljuAZJ4vIaPmUdZYA5os
         72XiMZOQnlY4uV6q1lmx4f3Tpz1RwuWQVwW24XobsGW+e2Rh0njfsAxNmwPz2qoT3xgs
         pxbjNSnE8YzSQP0/eKWYSdBz/BLyh5VLFLdEbHbCnPm1WpNLuNtMHmzydHhvSEgXwJF2
         o/XLjpopflSDcVjzBIGm0R88FwV9PCafDyet4ydIYwcg9S8eOINpFmFzGwbRq0u1B/w0
         wr4K5M9EXXNyTbLKUsOSqRcn8mloXadrN33Ex2dxgu/UgyDZcgx9clYVpLKzUhBYF9rt
         5LiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0pMukIaJ8IjZEEoYFUSUOe32+fVx4NLHIFSad+NCaKI=;
        b=I1Kut+WQtl+TOwWNu4W8illl5vP/tyijufDUX1cpSz3Niuz7cq0IIBbacj1RZSCPig
         JN6ESLgj7SgIF7subpJIWk8J+BlNInHmo2p8eqtsyb060jJQsCZSZvZwEFjCDeoNk6Gh
         zrUd8tB9YgdoRU5k0ZuAP9c2DQTWyLU3H78kX1+kwSsQi7r1gWT6WqmdD/WZa7pdSr37
         bqSx6/wvOFEVaaUyPLnRQC9gA0iPqJc9BZQJPOWrO0gnS8tySoZXZoJ9+3PeB8pP6mTw
         kZ7qxD3ff9ci/eUGwy9TX0IQiW9hY8lkS6w/YQ9QIO+QefMVMTHW6CUc+2kBx/gc6gbL
         eVhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lJyfeDa/";
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v4si8512113pfn.197.2019.05.25.06.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lJyfeDa/";
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0pMukIaJ8IjZEEoYFUSUOe32+fVx4NLHIFSad+NCaKI=; b=lJyfeDa/YDCTdpFVkfHBGq8IPd
	/nl3QEsbTzzUQGQAoHja/tQNWt/c587n2t3nMBjqiKS2T6e24vAAQ9+I2lko6f5sI1QWYbHfeDzdl
	bpRdyp6ulACoaIIuUT7IPCUniqdZ9Gf2sY1Jk8e9pODZh5nJUMjAekc1GM8TxVR7zlqRROMipzip+
	v3q5bqcN6EozJkKXJTV7MJORiGsUY9M1ZIqirrQ66xlF+aW2VCEBkbkQzU6TTbLQIl+KtExbl1wQm
	WeOOfyBBx6X5lwzo6ELMqr4uAvq+0eV/niwxNrXILjr8+zVAE7RBVK9iAb88ay3eouL4p/6Sd9I08
	gUvF8Jqw==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmS-0006Y2-U1; Sat, 25 May 2019 13:32:13 +0000
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
Subject: [PATCH 2/6] sh: add a missing pud_page definition
Date: Sat, 25 May 2019 15:31:59 +0200
Message-Id: <20190525133203.25853-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190525133203.25853-1-hch@lst.de>
References: <20190525133203.25853-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sh oddly enough had pud_page_vaddr, but not pud_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/pgtable-3level.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 7d8587eb65ff..8ff6fb6b4d19 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -37,6 +37,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 {
 	return pud_val(pud);
 }
+#define pud_page(pud)		virt_to_page((void *)pud_page_vaddr(pud))
 
 #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
-- 
2.20.1

