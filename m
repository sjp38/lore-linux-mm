Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E116C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BF112089E
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Mjceeoxu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BF112089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 122DB6B0005; Wed,  1 May 2019 12:07:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D31F6B0006; Wed,  1 May 2019 12:07:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB45C6B0008; Wed,  1 May 2019 12:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD1706B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 12:07:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s26so11210780pfm.18
        for <linux-mm@kvack.org>; Wed, 01 May 2019 09:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lmTrIGpEbI3KMOEYpjM6/I8DyJIPcU5OW04RpHaMmk4=;
        b=nYSM39oZ74GAttpDU3HMAgjfMjwjohH3zzchccaamUYE+Ky/IeYLlnWSsgYxCcu/CF
         nN0FM9AS1iURW7qG5qGgeN8Vhty7PPKw+bEKsositcodsdY35cLXGF5AXPh+bikI57MW
         rE5bkUoQrLNpxNMkC/SIKg8+MRwfNO0Of8a7oUcgba1+dh1IDHZz7EkS+av4jFhIEyPC
         LCmYkgQc1ePchcgRlHJBnxAecu4jB55ixhli4sKGf1Q/zZgFDQIN1WgQVQhsTczOGkfi
         CU1J56VJcDXhgcrCuAffWKucDkhi4JqKRT06id0oaJAc7VQd2szciSIiKomMfMCp29Js
         yC7w==
X-Gm-Message-State: APjAAAXfow6pAkAebEJSTsGwYMrsRLhDB059m+o+U7jkiEWTDxdXMdyi
	oKcWNq/fWU15w8HnetHoOQH7UIohV96inS4reyyVnu66z64Jarpg/cBUiVu5Wif8iVyZlIeViZ4
	5T/L8Jg5Y8ekzUqfh+NdJeXEKvegDIPoYqlBrCNjYSzD4KI0XrYuCu+0u6+O8ynU=
X-Received: by 2002:a65:64da:: with SMTP id t26mr38481044pgv.322.1556726840310;
        Wed, 01 May 2019 09:07:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKyfgRoI5/t3vq/WLgY336PGz6Toi44VAFpFPLsiuVNW8wq2Z54y2gKODMmFAX0GjBjfl4
X-Received: by 2002:a65:64da:: with SMTP id t26mr38480933pgv.322.1556726838860;
        Wed, 01 May 2019 09:07:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556726838; cv=none;
        d=google.com; s=arc-20160816;
        b=ExTHIBxiEHVNXw2wpjRtkzkLtWvrkRBQQabi9Py/Hqfy+GXAeX2+l7KWVSVchf3IxS
         c/PTDr3gGGj60MgrfxX2Y3Ocg92Bmm33nSF19m2SxxQWPWVdac08BtgdckkaCRnJReGx
         09bseBxZq8kChElC/3pyEgxd+xAwiM/jAYTGXLtIm1OXpltnwsAXA0gP3HSIFMKt7D7N
         lBC59QRhthbPYl8N8vZQGfsNV7TGEn+C2bBZpQzYmhjSnm8tiggym1q5ooZshTfsm/zs
         //yggpVat2cY+7Eu2xR4GMXQtKHsgTKhKG511hDA9Lhzm45oou/TdbaK4Qdxs242JxPQ
         /ypw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lmTrIGpEbI3KMOEYpjM6/I8DyJIPcU5OW04RpHaMmk4=;
        b=bkTlNMSAUiPZtOrl9pCK1dplB/9E11Wb0/rF72ufvb9ux/UQ0ZNsRoAex4gNBhkYXx
         Wv0gwLWwG3E2Jhcv5qHPCZeVB5ohw8zY7NaBmB6RE7kqPKe5AY+2qygo2UZckpg+rMSM
         7H5kkcR7pOOUs8GyNebtcxUtV4VAzN7XbYM4G90RWbhwdtQ1FztXkgmPInN7QjwkrBFg
         2f3mvvQpxVdo/Tv85EyGEpFaHApoVQDihGfjFYoRrbGOZKoHgSXcsAPG57uIp9bTJLAv
         25FAchzhXAOd2FAufap2IJrLAEfLV+LH7ukOfc9Zwf4mWIferco42UNBN4L9QqOskopt
         ltzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Mjceeoxu;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 34si33198242pgt.306.2019.05.01.09.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 09:07:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Mjceeoxu;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=lmTrIGpEbI3KMOEYpjM6/I8DyJIPcU5OW04RpHaMmk4=; b=MjceeoxumN84/e65UHYopkW3J5
	jbvdYbAu8j9CHPZfKzzFkJledp6gzX7UHAiSE2A1+0tOKgHOswlNOFYbe0kDzPsqLWFAsqHV8cNrr
	DZYb9sdK9qv9jOtfbU0kNMyP2h1odMGgHBqJs6/Hn8xUovLq3lAaypCDyTIVcTzBwLLrwY2M1B1P0
	tLI0BH7VQbm6FqOam7aePFfeJ2wuzPemXEZlU6HD8vV9Mf8+/QGyqeMYEg5zQ4trcRqAtzgZx+A4B
	WyjQ6Mecd3IE0LLrFjtwzmEbpo1lQ5ikOYpupyuNZZ+JvnMO4l/qWjwTEpKCJvFnqiiIzt6qKxoj4
	u3NrNhag==;
Received: from adsl-173-228-226-134.prtc.net ([173.228.226.134] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLrlL-0008Kv-Eh; Wed, 01 May 2019 16:07:15 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/4] mm: fix an overly long line in read_cache_page
Date: Wed,  1 May 2019 12:06:33 -0400
Message-Id: <20190501160636.30841-2-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/filemap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d78f577baef2..a2fc59f56f50 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2956,7 +2956,8 @@ struct page *read_cache_page(struct address_space *mapping,
 				int (*filler)(void *, struct page *),
 				void *data)
 {
-	return do_read_cache_page(mapping, index, filler, data, mapping_gfp_mask(mapping));
+	return do_read_cache_page(mapping, index, filler, data,
+			mapping_gfp_mask(mapping));
 }
 EXPORT_SYMBOL(read_cache_page);
 
-- 
2.20.1

