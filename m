Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60823C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23292206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:18:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tPLKCpRQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23292206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF5896B0005; Mon,  1 Jul 2019 11:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA4E38E0003; Mon,  1 Jul 2019 11:18:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BBCA8E0002; Mon,  1 Jul 2019 11:18:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id 658086B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 11:18:57 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id d190so8981274pfa.0
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 08:18:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W24hVTkWBqif5TpM38UrHl82eo9rhQffmi/qNIa3KQw=;
        b=Ucl68A4l7+JcqbpmdSbE8Oymeac6VmfZatvCrqv9NMXYkZjJtwh19INqlQsnJZH/XD
         QGAYTqzvO+JPTyJXIGE/6Vpd8w4UwtFyqIRlHxHolD8tC0gnK6SYig+XIVxHFDY5IxLh
         usinkwBmGDKi7r0MebBiuAThcJOeLN+5DgWTAzRfiwYyqbzOoqrvzCVAAMjGKvIPiZLS
         6LsXVAqAqrCnqTwaa/I8AAQEG4W2jbeYZdtzIrVqEuiH671U1ea3aIctKQRGQ4xr7Nm/
         x4atvyPugcOotCwaM3ULYcs/LllAShiYayVdOf5iTwUgJsSkdoiQnZe8F8GFpoGgtW9P
         SemQ==
X-Gm-Message-State: APjAAAXS/aqLOqTrAc/4QOx2rNsrnbsS0kwyTnQbZ4ywMhlNkOHUUO3I
	g1k5qS3Z8EJMzDt7lhevO2LQiPsHykmx/9alNaLv5OySdqR2d5b3HR/KBbgAptsySL1cgQfEO6o
	qJHg9XW+QPAV6Kehu62eU5ffiMzIUivLAJR79z1wJRSZ3J6VRFeU8az/CSTFR5io=
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr29583347plm.199.1561994337065;
        Mon, 01 Jul 2019 08:18:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz7fECF9rPvhlBNR3D89JBfqBIGTkfZ8cfe6b8OY0jZSgv4L5YLZAqbiOAb67QvrWOQtd/
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr29583275plm.199.1561994336273;
        Mon, 01 Jul 2019 08:18:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561994336; cv=none;
        d=google.com; s=arc-20160816;
        b=VSVtrmzNr8anW5go8SAUaovZfDHnvxR5hJK5WNrjOnz77iNMMlbW61atMqXKiHNJyr
         9eVjkAG2ma4QpzxpEw277RN/k1JbBG9OKVtXppblV+khMEBq8n757MfGftSsrLEU2AiY
         O6MhpiA9yNuoLSFcT6Ys6kCiA0/o2fMWDt3ciuUAvOy3E6KRFnG2+WjoNSRs6vmqUNS9
         P6aOdHByCAOfJTf0dxYFuWzDrWnJshRp1QT09TbmlPOSB8nTpUTgaCxF+VG94ihhzmJp
         rCT3+25BiESIq0P5vARLYH/roHVJxqwCwmkj6SuNoh/+XFwmUR2mMYWOuJVCw8A/PDU9
         gPPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=W24hVTkWBqif5TpM38UrHl82eo9rhQffmi/qNIa3KQw=;
        b=d8xYPV4jGm9H7mZhdVRM9BW0vAAcqekNqiCDXCQjMFVL/iR2tZzzOrXUJCwK9leiCR
         jwbU9KrkikluPQ5XIv1TG/imM3oclKUMz/q636FMhCaG19RX9TfCa0mEooZiD9LWBRGM
         w1g2MZIQwk3MYzLLx6elDsDOFLqLQXc66Uacl6D7egrwKB6IKxeeRuViiNkoa2LX0gYG
         5Qjx8ZrenJG6Z6NCYnW2X9ZD0SZXCB2MkENAjR2ONhBvcZW3fwgapwYva0rlj+h5VE9b
         /Z7kmPbJNKnu/8RTBR2NnkpoWvm8Cag8y+Uvtd/entzKU6fHReZ1Th+Ge0mmlvwl7raq
         4h5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tPLKCpRQ;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b7si11943691pfp.4.2019.07.01.08.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 08:18:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tPLKCpRQ;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=W24hVTkWBqif5TpM38UrHl82eo9rhQffmi/qNIa3KQw=; b=tPLKCpRQPwcfjNA8YQTbRBgjwB
	cTeldU53kGIZcXI4ZC+66G3bZsYi+NAOgC4hOnQDtHKBLPmjwM+rCM6k4MLq2saC76pV36iLBv82D
	7f8KK3JXNsZf4LqhlioGjqhdX7pQYdEm/6TVxvutgT8sqqkerg+ArxXH8RLmHVoobF5EWszZys7o+
	HvdKHl/gFGLrYBfl+57ncL82vSfHXvjNgMvVtore1OcJU2Z5i7SW8B083w3nloAyxPCd2IvOHGq1p
	+tdLt6vxN7p94V4K+zYQ3ireYu6T2Z2UCjgCJlAQhL731e0VNjeSx3YWFQa+mS//b6h2QwnVnPcbd
	+3WxPSsw==;
Received: from [38.98.37.141] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhy4h-0003zX-TP; Mon, 01 Jul 2019 15:18:36 +0000
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
Subject: [PATCH 1/2] sh: stub out pud_page
Date: Mon,  1 Jul 2019 17:18:17 +0200
Message-Id: <20190701151818.32227-2-hch@lst.de>
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

There wasn't any actual need to add a real pud_page, as pud_huge
always returns false on sh.  Just stub it out to fix the sh3
compile failure.

Fixes: 937b4e1d6471 ("sh: add the missing pud_page definition")
Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/pgtable-3level.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 3c7ff20f3f94..779260b721ca 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -37,7 +37,9 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 {
 	return pud_val(pud);
 }
-#define pud_page(pud)		pfn_to_page(pud_pfn(pud))
+
+/* only used by the stubbed out hugetlb gup code, should never be called */
+#define pud_page(pud)		NULL
 
 #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
-- 
2.20.1

