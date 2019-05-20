Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12C1CC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4DD420815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TjdrOaCy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4DD420815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59D3C6B027C; Mon, 20 May 2019 01:58:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54E7F6B027E; Mon, 20 May 2019 01:58:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43D0F6B027F; Mon, 20 May 2019 01:58:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 094A76B027C
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:58:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so9231346pfa.10
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:58:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s0uOtVt2IyE4cfR/Y0SEBdScE54aOmbj3l250cgaAfI=;
        b=HEH+u9rrmlzsDZd6SpaRmdAjeXHzcHBAt/a0KPQujU45FOgcpxGNq7FuM8gWAUVmvw
         V9sJy9ltNtgrOFMJUDbkhAA6fQRH//COY2oT0SiRVCenyg9x2lddql0SFKpJfEapTEHD
         FrA47j0IkSI9W3342mNbmzVhHiQtpdVSCoTxFd4cTNlFyJs0LFKrsR6G1MhNqbyvge/0
         GRilF2/CiTN8KxrH+LsIVdsNgFA7tRjSUqLiuGDSmFd6Y0nyBl49FSjUXSFTSolpj2WP
         OuuIpPDwKBCHec/JIzFJCqbIeuHTkaSr+fZrpdh8Acg8WluGpMuyV4VX48Bhkq4AlgYE
         WsRQ==
X-Gm-Message-State: APjAAAWf+VDGhPBnmR8kHX2S5tQXokY3eBDsbmVCQOn5cuAn8VT0zyql
	YaKVs6YV1WlJKaumGTed5gSex62XIWkFbjZt6Tgsl4DJiiL9lqltmQeTJ95VIevnq3f6VX9rTDT
	k2SCul2QsJ6S/W813vG4w7niJLnPKEG7WQAg8dl/2iAzayKYwZwTiLr8vYzzZJtE=
X-Received: by 2002:a63:ee10:: with SMTP id e16mr67840927pgi.207.1558331921702;
        Sun, 19 May 2019 22:58:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGicCJBIuXMf3G+QDzyrgTO8thgKf82KTGMxzqEJzZughRdVPfJbCa+zZ+nkSeJZd7B+hn
X-Received: by 2002:a63:ee10:: with SMTP id e16mr67840868pgi.207.1558331920687;
        Sun, 19 May 2019 22:58:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331920; cv=none;
        d=google.com; s=arc-20160816;
        b=oGM+pwKeounkRJCbOJLibgXZqgzPBHN91Gs2RonY7VWrYR1l2RkvmBLDeZTpKfFxZC
         qpzLrUD6Upgoa+zhc2L7U9lPYNYlRTaRm02x6hWjMudAChl+RyiAuBdcrC77mD0MHuUv
         0mHDbYRehKyoF2GDXqyQ11M4Rz66Zum1Lgt0uQSfmBVnGK+UNuicSnO3MON0ZAWhl6c5
         W6vu3qV8puc2OT4PVb/juiQ0I2JJb226VsyiPuRydToFIM26kCtdGLbBBMc3IWHbVwe4
         Lh/HdQhlYdSsLLfkSB5sFVKrGkhhEiSEvCVF4w+i5897N9NimjDZolZRBMyqpb3DMUIG
         369g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=s0uOtVt2IyE4cfR/Y0SEBdScE54aOmbj3l250cgaAfI=;
        b=zepgsmRAzHE27NP76y0zR53U3ixTpfHBCSgB9ATWVpwnhd2huNUNQqvQZPu/DykQa+
         jfl2OLJxoLZQXBV5kTYXQYWDtEEwo1bVxM1VDTP2iiLI5JTTOlVel9rkPhZL7XYThN1q
         R0dp3lIA/L0i2ZglbcyYsxkpT3emdj/5Fm4b/MX6hBcl3aXWU1U4C3vxUBbf68Gjc0M5
         XBsKerKI4TI0j3BMXMfTZWsrOrZsBsibZUl3NxioG/Qaj4kVW0f5hDIj8xF22pD2nb8R
         r+ZZtpypc8d4yiAA0wVhUfypFXuDTdc/xXaW7dWBbb6cC7N9d23kSnjPAEkDiITe9oOf
         RrBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TjdrOaCy;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 21si17386734pgv.410.2019.05.19.22.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:58:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TjdrOaCy;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=s0uOtVt2IyE4cfR/Y0SEBdScE54aOmbj3l250cgaAfI=; b=TjdrOaCygaa/v3jG/wHnMz3jBW
	n24bEiQWWQaZjA+YPHfrxSijLYaBE8PmAGLyk+L0ae7WI+QX+gWOG+vRGMllV8nU/BakVdpXQuN3f
	d7vkmkFg1o0zgdfvGXmGVHk9PdY9RyTPk1qJ4jKCNShwL1s1SbM+ojVnVPyNQ7CxDJuDeXaGrA3IE
	2BqmX/79Rxk8tY/OI3mMEIH5wfsc81P6NnVKbBCmNBswsu9SZ/6Jd7XjzZ9dvpaAZigb54nKDwvmF
	QmUm+6sft6TWtT6DiMAJysavX4ZHQxyQrp7AB38L4VAl85fWA3casXlj+6TBedfIqOCXX7QmriJhj
	Nrz0y9Zg==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbJh-0006Js-Q9; Mon, 20 May 2019 05:58:34 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] jffs2: pass the correct prototype to read_cache_page
Date: Mon, 20 May 2019 07:57:30 +0200
Message-Id: <20190520055731.24538-4-hch@lst.de>
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

Fix the callback jffs2 passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 fs/jffs2/file.c     | 4 ++--
 fs/jffs2/fs.c       | 2 +-
 fs/jffs2/os-linux.h | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index 7d8654a1472e..f8fb89b10227 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -109,9 +109,9 @@ static int jffs2_do_readpage_nolock (struct inode *inode, struct page *pg)
 	return ret;
 }
 
-int jffs2_do_readpage_unlock(struct inode *inode, struct page *pg)
+int jffs2_do_readpage_unlock(void *data, struct page *pg)
 {
-	int ret = jffs2_do_readpage_nolock(inode, pg);
+	int ret = jffs2_do_readpage_nolock(data, pg);
 	unlock_page(pg);
 	return ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index 112d85849db1..8a20ddd25f2d 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -687,7 +687,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct page *pg;
 
 	pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
-			     (void *)jffs2_do_readpage_unlock, inode);
+			     jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
 
diff --git a/fs/jffs2/os-linux.h b/fs/jffs2/os-linux.h
index a2dbbb3f4c74..bd3d5f0ddc34 100644
--- a/fs/jffs2/os-linux.h
+++ b/fs/jffs2/os-linux.h
@@ -155,7 +155,7 @@ extern const struct file_operations jffs2_file_operations;
 extern const struct inode_operations jffs2_file_inode_operations;
 extern const struct address_space_operations jffs2_file_address_operations;
 int jffs2_fsync(struct file *, loff_t, loff_t, int);
-int jffs2_do_readpage_unlock (struct inode *inode, struct page *pg);
+int jffs2_do_readpage_unlock(void *data, struct page *pg);
 
 /* ioctl.c */
 long jffs2_ioctl(struct file *, unsigned int, unsigned long);
-- 
2.20.1

