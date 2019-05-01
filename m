Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF0C2C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78BB020644
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BOHFVQkA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78BB020644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 803FC6B0008; Wed,  1 May 2019 12:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 715E46B000A; Wed,  1 May 2019 12:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 569BD6B000C; Wed,  1 May 2019 12:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D17C6B0008
	for <linux-mm@kvack.org>; Wed,  1 May 2019 12:07:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w9so9042326plz.11
        for <linux-mm@kvack.org>; Wed, 01 May 2019 09:07:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UkZuaD7Mm6HPsygbDYfM+bk4xZlXKq4hzNRQaTP1dh0=;
        b=Wl51JDqEzf9v2T/McATqzvSrrUbQaqr7H5QrcgyJn09axuK8slTtUlfsEz5zyxEpTd
         PLxMIf7gSFzWp51H7MaPtTXkYt3gq40Bp0IxiN7qIYzjKVwkNueGKkvaUeNl5X98CAhm
         VXwduztbl5UfC+snnQu5XT6b648s7TjY4bpm5PnFmL9eBAQHoYmdqSBXMds5zFD74s9G
         x8GrzeaHMT9C2FNhKHV7A3JupefIHpTj8YcCiIk6EguC3B67UBAT5voA3usOefA940uE
         LhfConJEm5YFQih46NpLn9HMtZV1FMnk8KdZuSUdNc5f0g9mD/wZAH0Jezwk4pxHtChI
         7X7Q==
X-Gm-Message-State: APjAAAVcHPjlw7qoXKbsx6I+YSwFhraoiJA16X296yxt60HT+dVnuMDN
	pLVQA2ue/Z8+/yC77BHtloZ/NRJN1pH8nexrYUw8w0Xus1QACILw+cBrhdmu4/klzDSSwkxWGSj
	QQ04TSrVxgcdUpzm8NS89kwK7vMK9KTljmUWofmB3+3JwLMzP434/H/nkf7KbkJw=
X-Received: by 2002:aa7:8054:: with SMTP id y20mr6540870pfm.108.1556726842761;
        Wed, 01 May 2019 09:07:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc4gmMzcD5TYOGOufDUsvhzwVtPiNtO0cjicKgMhI/2D2zhJl3tD/3x3VZvubSvPHqZ0xG
X-Received: by 2002:aa7:8054:: with SMTP id y20mr6540808pfm.108.1556726841965;
        Wed, 01 May 2019 09:07:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556726841; cv=none;
        d=google.com; s=arc-20160816;
        b=pVyVpX7RVZ8wiQf4HFmHHAXjCSrvEhbMBaSXnGaBwD9waH+0rBBZOosi+FPTnpPwrY
         O5purhBAUWDNACcyNd5xh4Jn+kR9xv+PQ7N2Y/Whtlo/fYdUivYmsjx6rQBFVS1PRUn3
         9jx8JiRAj6Vi8d28P2xJwwUHzzQSa4T1yEmpTcGUuHgqR3s6kvYpnbm1u97zpQbYlBQD
         74KRroTBdOlQUPxO8fFU2Dgzq3MHwOV8/FBzskMmBBBIDit0XwxMzxAYZ8VWLjwelRDL
         3/oChXVthQ7rt7dm0sBN8B2EPV8f2kLxQg/9BZ3Vr1L00RgZIlS9moO0JfwsnByu1OVA
         6nbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UkZuaD7Mm6HPsygbDYfM+bk4xZlXKq4hzNRQaTP1dh0=;
        b=FyvItGW8hhXN2IkCUXd1e0QyI/4/cNQ2XEwyc6+6+iG+VoQcvPvVUUKfBSByej52Sl
         Kej2RwRbBbYEdfnbPeGgrDezUpshJhLnahT9NEF6823iInPQdCMVLHUR8a8Vl0rMKi1V
         rhwO+S555qCXa5Z8HfIcCjOvb204NuO9KSVoRQBx5cCAMswZgmoqyMT0Kso0rPrU6NQT
         zNBdpKFlJtNHKoY4gNdHUmqVaFKUDTyi1yUpfQsoZT28n0kRzv/6FTNJTRdCt+DpK5Qx
         VXn0ubsGoOQ4uYjlfnq9iDXED01CjlKlQ6OQx26SddSG20/B8IWf7OyNodn/rFUkR2P0
         Jfjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BOHFVQkA;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 5si12332646plt.198.2019.05.01.09.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 09:07:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BOHFVQkA;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UkZuaD7Mm6HPsygbDYfM+bk4xZlXKq4hzNRQaTP1dh0=; b=BOHFVQkAG46eDJBYOpbwz2YPVY
	XQWZ6xnJ52th5oNnDhX56QOGmvBs2NJ18NLF+KQDVDgs3rolaHP4MR5TdjtPjR+JJdljMUmO9UBaN
	UB/BV55owFyHcMrd5/ND3t+hPSjcs6OAZhKGjGwewGeE/O+lTOnRqmy3RFwzppAdYHQ2H+DXywuMm
	zig7Ko9GH/87I/mhU7tKmPn98Lbrvo4gmTE4TZBR5yIECXjXWshC9BB1zcDlKjfv/kFxH1sAQ8ZXc
	Tr+c9N6Y6GLUZDRBdPrBPPRdRYpbwZ5VwuKftQ0dJWhnuBZEUCuf0ozkuIswyhHll3ggTqxOobjBe
	BBQuKPvg==;
Received: from adsl-173-228-226-134.prtc.net ([173.228.226.134] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLrlO-0008Mh-Dh; Wed, 01 May 2019 16:07:18 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] nfs: pass the correct prototype to read_cache_page
Date: Wed,  1 May 2019 12:06:35 -0400
Message-Id: <20190501160636.30841-4-hch@lst.de>
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

Fix the callbacks NFS passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/dir.c     | 7 ++++---
 fs/nfs/symlink.c | 7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a71d0b42d160..47d445bec8c9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -714,8 +714,9 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
  * We only need to convert from xdr once so future lookups are much simpler
  */
 static
-int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
+int nfs_readdir_filler(void *data, struct page* page)
 {
+	nfs_readdir_descriptor_t *desc = data;
 	struct inode	*inode = file_inode(desc->file);
 	int ret;
 
@@ -762,8 +763,8 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 static
 struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
 {
-	return read_cache_page(desc->file->f_mapping,
-			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
+	return read_cache_page(desc->file->f_mapping, desc->page_index,
+			nfs_readdir_filler, desc);
 }
 
 /*
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 06eb44b47885..25ba299fdac2 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -26,8 +26,9 @@
  * and straight-forward than readdir caching.
  */
 
-static int nfs_symlink_filler(struct inode *inode, struct page *page)
+static int nfs_symlink_filler(void *data, struct page *page)
 {
+	struct inode *inode = data;
 	int error;
 
 	error = NFS_PROTO(inode)->readlink(inode, page, 0, PAGE_SIZE);
@@ -65,8 +66,8 @@ static const char *nfs_get_link(struct dentry *dentry,
 		err = ERR_PTR(nfs_revalidate_mapping(inode, inode->i_mapping));
 		if (err)
 			return err;
-		page = read_cache_page(&inode->i_data, 0,
-					(filler_t *)nfs_symlink_filler, inode);
+		page = read_cache_page(&inode->i_data, 0, nfs_symlink_filler,
+				inode);
 		if (IS_ERR(page))
 			return ERR_CAST(page);
 	}
-- 
2.20.1

