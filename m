Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C6DAC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 227F820815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Y8rXbybl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 227F820815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1C4F6B000C; Mon, 20 May 2019 01:58:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACD356B027A; Mon, 20 May 2019 01:58:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9462F6B027B; Mon, 20 May 2019 01:58:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7386B000C
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:58:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 11so7215688pfb.4
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:58:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MsXW1oUHr05ZSy88t0Z7I0GXKd9SSvBG18rggV2Vu2g=;
        b=rtudwQg4N1V/4iPV9MjLp3owZ6GJtH2fzjhiBhXEB3ok+Mzkwb9liB9C75IydYpRp1
         NLfWzuYZLlYC0ty6sQsOTYkSuJnC+op/Z24J6RI8Xm/bzmIxLGvGoU6Mce73TXGko7s9
         i01XYA0nliQzeOBp0FocNwXzWMRi5aPAWRkYp/4f/ZP0td9TqZ1Tif3yXfCb96QKY605
         wy7VtN+SQ60ommjthwWEyghUIsf9FIstgILfVHef15HLqlP071MlcK+UO4Ux9tLNiyi7
         3kdu+16utuu45ggio8YXgj+ioaMN72TFBG3DUfwV+BwrT+DYs56inSxLUTCWEHKtk9o8
         BVxA==
X-Gm-Message-State: APjAAAXVDQsu2wpvKA+006bVPqJuGLPo2cBPKKHOXYfD0mQBLsm0DVfk
	n5BgYhs2nTooPHQI/EeOAyRN8ifFaOncKKoFekWniJK83YCcgbvFY2wTWvHBtbzHFDkt9Q25pGT
	zzfiJ3sFbhnPOU0j4VfBwMqaTKMTtL0rbHa2v9xWxum8KbL3Bif72pQMiLZIz/Tw=
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr78665009pfe.242.1558331911977;
        Sun, 19 May 2019 22:58:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzshblQqEcw10KgQiW7hjXXeehaPNSZ1qRWLvHDxoQ9C5bcVEt8sAdCkc41M0e95rNO7OG9
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr78664954pfe.242.1558331911108;
        Sun, 19 May 2019 22:58:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331911; cv=none;
        d=google.com; s=arc-20160816;
        b=r68Qd+g38O7/aLnwp5u4ZnYKAirP37bV2Npjg5L3ld+YrcZhN4r57zz2AA9AV57Zca
         dl5G/tcF+R9fe6BTn8edEipf7cu+mzbEzhAuVObiNqQmgB7yPd8gNu6Q10lUkqJ/HqGI
         z6tjPjO/wMO5DeyhjgYYSFDXBdUgCmSEiGPxvwk3XPOV6MqahxVYKqpuZ4f0Hc+DmODK
         VrKGLpOsJlLYPsNSORoyQmTzc09FQVGzejYwfsTzjR5ZzvesymQP4Ry7ladMNrkM8BeI
         +Wn98UhojfAxaI73Bj9xAHQIOZdERG43PC4MmGRny50sfFkTu6xr0vpVKQzMp5r90Vry
         tgzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MsXW1oUHr05ZSy88t0Z7I0GXKd9SSvBG18rggV2Vu2g=;
        b=UvHActoddzrf4lPtNsQb9QdYyrDVwacM1pK3EULdNngCGXUvu1LoaVbYrQ/8wf1D2l
         W6C3WsSA27otKddM3IP9C7WoADyCQXORhzk8ExMIw+2d2Pl0qxnWRaQApX46KYnr0Spl
         5dxRH2BmHjdGkFqE34ovCqtvIAHYTpF5/OcLvzTQ2AeUAVNvUpaxw1rRk9xJbOMBGzBy
         wOJr+mHYi8GFNGwxoul9dIzl0Fe8jyEHx8ABbpxp3CMbDMdjCtkaBp5H0dNv9QcmwM1N
         J//65zszRwUaDtYJSS2erL6HFDNemeWuJDb2vW7ll80PlBYi+BGPrtVEZO7Zjnz1kfl0
         6vQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Y8rXbybl;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r21si9056086pls.151.2019.05.19.22.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:58:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Y8rXbybl;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=MsXW1oUHr05ZSy88t0Z7I0GXKd9SSvBG18rggV2Vu2g=; b=Y8rXbybloiYAZIahaVSujAokhz
	2Yi2UAMOUpPcvHfhuSHLQu4Juf5a1UAxTglQmGxVdyniHxS24VDy1xVzAnQsKm5k9Im81PSFPeMCp
	iR6c10H9cNGjTJJiTzM27ZW02nvJmYAMVOBAM7TdgvrB0NJW+fWgdreJcQhRt/7/ftrttcvqetx1U
	rWn7x9w7HZ9lj9cm3tviyv3JE/7gPR54vNFSwecekAofc7b1GzqZusqzQqbRLZWj8a2q4yV66IyoI
	msf9FbMvBh8VtCYc1ERTpXzsAPWMHbYvaqX210fg7ZdbKDzr92R1HS8AHgaIZExx/0OSOcra4N6Tg
	eHYmr0TQ==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbJa-0006Eo-Oh; Mon, 20 May 2019 05:58:28 +0000
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
Date: Mon, 20 May 2019 07:57:28 +0200
Message-Id: <20190520055731.24538-2-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 mm/filemap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c5af80c43d36..6a8048477bc6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2862,7 +2862,8 @@ struct page *read_cache_page(struct address_space *mapping,
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

