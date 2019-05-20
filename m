Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E2DCC072AF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 455FA20815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TKZaPqvg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 455FA20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E28FF6B027A; Mon, 20 May 2019 01:58:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDA746B027C; Mon, 20 May 2019 01:58:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF00C6B027D; Mon, 20 May 2019 01:58:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 994326B027A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:58:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so9240643pff.1
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:58:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rcaOtmTyxwSnzPPNQ/axvrfybs4dWe6fVXdJWykZd68=;
        b=QAz9ZUoz6Yzd3na59oUQ16bd3pZ+8h/G7G98Nm8/VWjMPD3Km+873qAkB8rvWfNAVt
         j1cVCkjGzuCjERj/2ueeCEiL/xVD25NAWltyR5JgY48PbuqIMIviqkRg4mkwqaMHL2sx
         BSkngSU3JbihMfMY7bsEpagSFrpwgKjm5wug1LMhZ0JNz4tH6az1R2sioQ0xLJRfDsI8
         RGDgbEOYJiO1MWC3mNvZvPnCBxbTIEWuXkvXj1Euur/SudkfIEy9GJ4vXMooheOmYwoR
         jFYshG9X/COz0tBNHDIHYjO3PTzk6a+QQBkl0jcy0Bl/txIWOUD6bk1a6t3XUsbX2Ua9
         KCHA==
X-Gm-Message-State: APjAAAW98EUPeejJDueDYVMzYvsLY4CpgYdTpardzWSdSmx6jNpwz9VT
	Bya+/vsAEynviKL/FjoaCOJY0n+ScrcVwf3xpUO9IoB/6sOpD/qzQcH0kAlhVe8uW/q2EwWFOpO
	dnMzuhwRAaHfsxi/QvbRvU+2w2rvUQiWPT4PZbOZzeyocVGheqHrWcHg56l5xmaQ=
X-Received: by 2002:a63:804a:: with SMTP id j71mr74284395pgd.68.1558331917298;
        Sun, 19 May 2019 22:58:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxguCvBaGTywQmD3gRyxU9uuzTGdcgODqFd9NeLF0QjuYwydSQGOLfDBNBMEGbVs6d4ksWZ
X-Received: by 2002:a63:804a:: with SMTP id j71mr74284353pgd.68.1558331916653;
        Sun, 19 May 2019 22:58:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331916; cv=none;
        d=google.com; s=arc-20160816;
        b=wAgAxvdPNhvYmQ1w3MBEmVD7tm/V62I6nSBFdRCp/f2E/M8LU8cxLJsVxIg+ObcweK
         zdvSul1c98VYUEjSni9m6Uewx1BjabVaOCjAq5BxCfi7enjqLPDFNUKWc8TB6aIbth4g
         bVt+fY7ouzS3oWDx+qrmufMdtqRopo4bRNpKDLnY7sgWo687rJROfjjdzNbzfig9e0Hs
         DEkh8OQAt5379O8xxMQHZm8CUmFmTWyUZ49afl1j4YQnSnIBO77Z4yixWvjOyh7c2dnL
         zdi7LOet9Mo8pr1CjH+1C88ju/BuopUQZgOKkGG4LP4OQvI6wlZ123FKD6f37657Ew41
         4dRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rcaOtmTyxwSnzPPNQ/axvrfybs4dWe6fVXdJWykZd68=;
        b=o5K3pgxX+1fxsfSTe+WOSzKAiFak1PZCS7A68SGu21stl9Pl9W5rQn21m5/ijhtxjC
         6qAsmis2Kwt4U8rBppKpy/6u2CZtZAGiJ6S+wb5KzctWQWKqsTYleKauIJMLotVlxPvB
         wJf0vdGUECGjzh80Fu5pniWhEEgdJPzV9olVkgYVZAJ3OHYRuaovPHZpQlX/0kDGC4Jq
         M3Zx7w2jQvTm6TR14bOR8xomtPrHsfEXKR/qf/eQc+bUL8jATUK8YvoXVLWfy7/2yjDb
         ljePIyy614uAcWC+6z7R68ShzDZRuegShTbGnBDrvHVa666XDtD3eUZFf9PFjEBCsoyB
         nBBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TKZaPqvg;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i189si18309643pfb.41.2019.05.19.22.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:58:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TKZaPqvg;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rcaOtmTyxwSnzPPNQ/axvrfybs4dWe6fVXdJWykZd68=; b=TKZaPqvgbKWe2FRLJA63Rp5Va4
	EtvOO4vybw2xssgKukZXhNdAQkCvd0y1IE51VR6M7TTOcm6DLHU2qbgUwi6nPchdxoG4tGd5VhFj7
	9yybQfAzQmIjw22SU7R09kbrt8RnT/FngobcNa5wKjOlKMJ3XzkXclUBNGYSdK+al7cntGX2uvwNL
	eRifDrk6y+rx14GKPJO3SZblI7ry/8uTGUm2VZ3m6UDmQq12v2Y/7CyJiQUeU8OHnGXUxmfYvyuvG
	l1BG/wqrcj3QlYZP4pV6fuYRhD8W8fO60c9YZw65wHlm783Vt9UblIP7bahz++F6NgG2/U8i5iEi6
	YTclvUgQ==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbJe-0006FV-Qn; Mon, 20 May 2019 05:58:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/4] mm: don't cast ->readpage to filler_t for do_read_cache_page
Date: Mon, 20 May 2019 07:57:29 +0200
Message-Id: <20190520055731.24538-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520055731.24538-1-hch@lst.de>
References: <20190520055731.24538-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can just pass a NULL filler and do the right thing inside of
do_read_cache_page based on the NULL parameter.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 include/linux/pagemap.h |  3 +--
 mm/filemap.c            | 10 ++++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9ec3544baee2..6dd7ec95c778 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -396,8 +396,7 @@ extern int read_cache_pages(struct address_space *mapping,
 static inline struct page *read_mapping_page(struct address_space *mapping,
 				pgoff_t index, void *data)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
-	return read_cache_page(mapping, index, filler, data);
+	return read_cache_page(mapping, index, NULL, data);
 }
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 6a8048477bc6..3bec6e18b763 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2772,7 +2772,11 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 		}
 
 filler:
-		err = filler(data, page);
+		if (filler)
+			err = filler(data, page);
+		else
+			err = mapping->a_ops->readpage(data, page);
+
 		if (err < 0) {
 			put_page(page);
 			return ERR_PTR(err);
@@ -2884,9 +2888,7 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index,
 				gfp_t gfp)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
-
-	return do_read_cache_page(mapping, index, filler, NULL, gfp);
+	return do_read_cache_page(mapping, index, NULL, NULL, gfp);
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
-- 
2.20.1

