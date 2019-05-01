Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1286C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81E4A2089E
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N9hkv1/K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E4A2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20CC76B000A; Wed,  1 May 2019 12:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 199676B000C; Wed,  1 May 2019 12:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A8A6B000D; Wed,  1 May 2019 12:07:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEB926B000A
	for <linux-mm@kvack.org>; Wed,  1 May 2019 12:07:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v9so11122334pgg.8
        for <linux-mm@kvack.org>; Wed, 01 May 2019 09:07:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UYhsUC45x3BaFz65BgDHiQpOpAjMvMtZBCkBOB8hL5Q=;
        b=gm+JenaKlLcyUWuybqnAXejGpVtNWeXCOfRsTK2izoNIQf3OBVjaeGwZOOIUPA/byF
         FlscyizT9pVz2pfNNPtvfI1793AJpUJ03Jdz4Q9BbxVh1ywY5v36omWTBa5PHGhbwzeI
         bvLycyo7j4LEtsKTNhBwOEbdWJCwHF0fI4iKdHOJZEOx/eHnKAsvA+uI8fNqYvTmlcXq
         dA+H3TMnSaoZd4AAmH95G8XRi5a+sXfN+sp5UfKt8JhFmbYnQfFacweqWvWjcC2xnkTE
         eZcSQTQtxvL7L9DoDoUIz1hCGGaJihmkS4fCTrm+rqw3kVv9g1606L/0t0BdpU7EsGUM
         lvbA==
X-Gm-Message-State: APjAAAWeNF/u2b8AK4GD9EYAscIJBvs3PgBs8PiH3V+Gp89E0psGHT/w
	Y/jS4wR9zdeVBGrrnIJF3H6eB2KRrwVdUM+/kcSSb5FCniXdL3sBYkbY9LWZsS0cG5ANU77hmAL
	fUlBbWUA5IiCvGXCPvRMFqLnPbfTpgG+uP/LvJ3d//fm0rcj4SeqeWRbOhmfTo8E=
X-Received: by 2002:aa7:8b11:: with SMTP id f17mr12323404pfd.116.1556726845433;
        Wed, 01 May 2019 09:07:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgT/qcQf/nhSEP3+o7yEEyNmIsYLXo0T235WbJVvdoNRpSr3HgiKF3MZdf1uucip6my8zd
X-Received: by 2002:aa7:8b11:: with SMTP id f17mr12323341pfd.116.1556726844694;
        Wed, 01 May 2019 09:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556726844; cv=none;
        d=google.com; s=arc-20160816;
        b=gdxLz+bck82aiFp9oY5S/7qFpVVKnZUFZNGRBrCmA4qoTi4sA8P2QRxgbOd2d4Loe+
         ylE+YGaliA/z1pWLN768IgfV6L7IueHXxT3K9/j9vEXLA+YoldjeW4xNSE8e3Miigpi5
         MVf3S5IAKhGdo9SHPNFIr3m7rKuIjkCDJ+uS6hh5K8IsPpMS8slwyEdjeBN6H3O+TDIx
         jPD1qop8xPo+p6bXqDwqTO0GLuNr8G1xnkc0rZR25nSDOFDMMq968OrS9NvbAjsfjL62
         mpgVjxVW9H7JH9QxFKq2Y+Q/dSYIGVJ1WLFL8nyYeQCoxhvl1tfrbHNw1LdfF9xWD9QM
         Uhww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UYhsUC45x3BaFz65BgDHiQpOpAjMvMtZBCkBOB8hL5Q=;
        b=0jvmgDddlHieP0sHcWfoIWpEsOqVT/VR83f/iR6LztHMnNBG3tz81YudrL6W/v+8xO
         iya64xwu83Sruh4kMqkjnAccOvgi9KaQjrCeiWgOjFCUJtMHguKQzLMyZlSnRPWa0SGQ
         7KIlrXV+5K1Sk3hOT8WQ8w3phbewjUEgKJj+l2Tyc4N7oiBFCy2CP9NgYXY8ZqpgUa1g
         6KWherSNwRCi+j2KWcJ0qa6E5IJrW2ttaegya9WTaH31NmPkLLW0l9uCcoa8x85YxuDB
         Zrp2Q9+lrG7lCauNB896S0udIu+J9vcfH8S0S6/xq4PcDTLdEKWkqlkyJzXw8W6Nm1Ry
         ENdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N9hkv1/K";
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q2si45057286pfi.165.2019.05.01.09.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 09:07:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N9hkv1/K";
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UYhsUC45x3BaFz65BgDHiQpOpAjMvMtZBCkBOB8hL5Q=; b=N9hkv1/KxvUiY8l8aDh5EzrKDf
	aX39LFBLR0uVkQvhJLeEuPzxrJ0HtEIeY1e9ikhySWDweBLiPvDrdzTlg6Wi0QSSQyaH9yXwYdcov
	pBzp0wGVJgNK7NXNtPiDAUZ9JEhgdVCOcXx35OAT/umKz11Mt42tyvCSvcGByPL85Lm1hqWDO1jDB
	3eWTieiEchWRQ2uYH/Y5x99PF4advsXL+oOmTaa4AVdjheR/oqOCWxx1j8RQR+gadGYSv+v5Gdcjt
	uilpaJBDPY/A3oCNijbOhKOerYmle8m2zgrUn4qQy2u/DTcJ71W+0FaQ0X2cTtzC+j/lhgvo5htPv
	w1zfZX8A==;
Received: from adsl-173-228-226-134.prtc.net ([173.228.226.134] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLrlQ-0008P9-2K; Wed, 01 May 2019 16:07:20 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] jffs2: pass the correct prototype to read_cache_page
Date: Wed,  1 May 2019 12:06:36 -0400
Message-Id: <20190501160636.30841-5-hch@lst.de>
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

Fix the callback jffs2 passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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
index eab04eca95a3..7fbe8a7843b9 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -686,7 +686,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
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

