Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F02AC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42B4A208C3
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Zc62yhd/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B4A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7652D6B0006; Wed,  1 May 2019 12:07:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C9B76B0008; Wed,  1 May 2019 12:07:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518DE6B000A; Wed,  1 May 2019 12:07:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE1C6B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 12:07:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p11so9092562plr.3
        for <linux-mm@kvack.org>; Wed, 01 May 2019 09:07:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AzdtBbFHCjWd7P3mgIv4y6C+GQMKPuM0dPoXcWBi+4k=;
        b=E/ZsC0ZNGcjsrmFkgdAhZVhsW5rfTSYp6bHxQAcF/90j1p4W0GWwHfE1wzROeOhje5
         ouHYXglay9VpK69SiyDsMe7RaFmvInmkLSYlCYmHdovYX8Iq1ssiF6iS4VuLiPezbsCg
         /uRiG5Tx84ifisFKZqtBwE5qumc6sB9uX3n016h4iGQO+9OEgqc7+3avcRajLr0OBwUS
         vUZDrQKYjDhLD8exTJ1r0bwWGAYxtUM43nkbyOiRMFL4vMaxxELWVCeTF49Rla6TPswP
         PWqzz1ff8qMoQJgPXUbTG5VJHJq3Qo2b0/YxT9vUZsuoLGTz3HfJJM5Z76ypDFgyEcKd
         qw/g==
X-Gm-Message-State: APjAAAUpZn0/uBh1Qy20z0+KMJneJo6bLNos21zRO9/IVg5pjRqo0T83
	yNXTA3+FlEcPpYcPSr6SnlrjI9G4n4MTTqim41SNDiUz6O/J2txxjsHG6uEdCsLyVQ2rNrWN4Cw
	AHntJOKb5A5FK/khOfTozRzlzfqcAHZqizXOObTJluPdzusQt/NSzyOWQisyRLw4=
X-Received: by 2002:a63:243:: with SMTP id 64mr74108342pgc.214.1556726841703;
        Wed, 01 May 2019 09:07:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9crpvwTMua56shP0ByrjoUEctN41Sb09qh1VCqkCO7qsEb4dXnEg+r1EUAYs0s1Rl16g9
X-Received: by 2002:a63:243:: with SMTP id 64mr74108277pgc.214.1556726840816;
        Wed, 01 May 2019 09:07:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556726840; cv=none;
        d=google.com; s=arc-20160816;
        b=rrqCfmLbQ1N8biTWnZOsktY7zw5wb/yaVyWoWgShCIarjjzg5GgmTLSuRhLyeViQP3
         ts7Onb2ukOXCGt914N2pywGoVcxujcsLbSkOZqPfvPmqGhdaIM3tngyJuRSZWyIt0FnG
         8QgvwibNqhapipIqwX/7/z2NAIWXDOmkkWZUL/6/mi/PxAPA4DrEazn8wRDO3NZJ8nBi
         FFTPhEJ6xZM1x03UIClCqdLh1p9q1f22gsjVF20TkmlaDN8OHMQE4W3kiAdivRqDe8Dw
         Ks2NJby6/1tgWusUcpR4H+VbWIcKePM6Sg9Pie9QAU8n/yyxOn3pNgGspM2rfhamvDfh
         t8Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AzdtBbFHCjWd7P3mgIv4y6C+GQMKPuM0dPoXcWBi+4k=;
        b=i8bhSxkLalE4uTJL26ISvOmyqqE+ppALDx3NeqFG9SCZAbuDgfU+ijRuipVeJNjmfh
         4/jVGM580y9kACWUQdmMs7ekIx97AGvIsVamxqFvwJIwzDiZXHwGq8rkIRGIPAig+dD7
         jtKGwAwaM+l7+IWpT6DGtoB370Cx8vH7+K4XDvWCC+uy1v2b4xu4y5MRvxm6NVMhx3SC
         f0zbnp1ipBL1YbzAKXgcG3zkCTY926yl0I3rcM4Izft/0grPeugnxNNR/DaxiE8PKHBc
         PwgzONzyfYG7aao0+T/rfxQtRkgjx9EYSqFhHpIJlkf1ZUdFddqEx3f/2PM/DgeYiHMh
         BZ+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Zc62yhd/";
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l3si38741841pgj.136.2019.05.01.09.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 09:07:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Zc62yhd/";
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=AzdtBbFHCjWd7P3mgIv4y6C+GQMKPuM0dPoXcWBi+4k=; b=Zc62yhd/KNhOnoD4Oz0HVxIUGJ
	ECU+tSIb3iXx8Z3M+eD4di90/kAmhkssjjPMj9GHJP4XjlmteyGVje11Wn7gL/JwVChII6z7AowcK
	MthBbZ+89ENfqzGjZbWywKtyYxVuDh+sfFWmuPgZW+uc5LZni8tEJPG3n7q4xTtM25jG6BG9j0k6c
	fmpWrrX5SIoI0bzLo8wI/GNU6Upekohnlk8P2MBJZW7MCPOzlCInSikzRv1NXhI+8NHPXFRYwEte3
	G1cuS7x/BJjBWjSfd7c+o/BL0+efM51xjYubSnmdNSaSB7mHr1BRIFXx0g6OQXDnyjUu37GscR0qu
	ZnWid9CA==;
Received: from adsl-173-228-226-134.prtc.net ([173.228.226.134] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLrlM-0008L9-Sy; Wed, 01 May 2019 16:07:17 +0000
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
Date: Wed,  1 May 2019 12:06:34 -0400
Message-Id: <20190501160636.30841-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190501160636.30841-1-hch@lst.de>
References: <20190501160636.30841-1-hch@lst.de>
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
---
 include/linux/pagemap.h |  3 +--
 mm/filemap.c            | 10 ++++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index bcf909d0de5f..f52c3a2074cd 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -386,8 +386,7 @@ extern int read_cache_pages(struct address_space *mapping,
 static inline struct page *read_mapping_page(struct address_space *mapping,
 				pgoff_t index, void *data)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
-	return read_cache_page(mapping, index, filler, data);
+	return read_cache_page(mapping, index, NULL, data);
 }
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index a2fc59f56f50..51f5b02c299a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2866,7 +2866,11 @@ static struct page *do_read_cache_page(struct address_space *mapping,
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
@@ -2978,9 +2982,7 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
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

