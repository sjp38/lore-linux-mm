Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B81AC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3149205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LoaCL2H2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3149205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364856B0282; Thu,  1 Aug 2019 22:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BF5A6B0283; Thu,  1 Aug 2019 22:21:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE7C6B0284; Thu,  1 Aug 2019 22:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B13D06B0282
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:21:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so47143383pfn.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b/YV2nCBRUvj+JHalhe5VKLnhqnMLLZTxEiSQrNBGLQ=;
        b=hQXlbRXJ25aK5H4XUE0a38vLTkVkQm+eSJIkrk57+VuIEp9bnuqEw1xwoZFz8h3+ru
         RQhjyIV/JhTDqamCFQyUnAfCHF6ohKUyKU0O7UoDsRhFG1lrB3l6S0Aectol5mvEvdCJ
         Gw8XEZVKiOAXW0g9gkYzmE+E2eORNS+eCAUHheA/bUURlaqUc1SJAb/tHiOW38NEKMOR
         yVPwlPVeLrxgllxMB+gR33ucOeL4qAIDBP1cpZBRnccalNRtjkSP1M3Y73P3DRflyibW
         7fVys3+nZGWSJrkG5B92VWfU8w8snqUlkuASxEDIFdb75ZtcWcUyxyU6rwWWE+KA7LqO
         A3cA==
X-Gm-Message-State: APjAAAWTRerk+b5fXuP+E+wcauc4Nz2aedTtC46DB28AAfxAyb8IM5HW
	Q+iUSxHl1EVbgj9uD1rs+Y9IMYYlWmUEujoUwttqBLod2iqVvRFX0ON6qLpBXT3iLbv+wh7b67Y
	iO0lQtLyuWtkrFuG9Me25T3SvM3SnMfoZ3pJ3igur9up0ylrKMUFbj1456AeWTr7sJw==
X-Received: by 2002:a17:90a:17a6:: with SMTP id q35mr1901530pja.118.1564712461405;
        Thu, 01 Aug 2019 19:21:01 -0700 (PDT)
X-Received: by 2002:a17:90a:17a6:: with SMTP id q35mr1901493pja.118.1564712460790;
        Thu, 01 Aug 2019 19:21:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712460; cv=none;
        d=google.com; s=arc-20160816;
        b=sm71yQksp05r7NrhK9CDS8q4fofyXm8OwW15rmWN7aKoyfeNLZ9DPmqUpdFMFpet0L
         2bV4ue9jv8iO88OzgMLJwfAC2t4kBJR+4/EnK7eKdhf2536BowEiRQQ6BTYw3UxgjD+b
         U8Qz3RfXNGMPq2VHIClEBQrWr3wQNBxvP2L9fn8eOS9audAj8dGLjJZeBYcPkSLSBF3Y
         JjiYoh1gUmAv9K1mwIwfPzChcOGZlpkwPN2I8aXguq5z/o0tBN3sP4tQU0f1LgXxH6Uz
         oTJ31Ufj/W3l8ftE1j0E3xRLXa236fA/EUVwWtHs+sur6reu+Y+R64ahMx25ZpeSokBd
         gklQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=b/YV2nCBRUvj+JHalhe5VKLnhqnMLLZTxEiSQrNBGLQ=;
        b=N1Uhr4JWqw1cPdtA2WhDqFIfsiakvrG5vgQrDKZvnevh++g/sdMV1ysjT2RMbQFiqP
         jponWPxt1F6Fcqj9VLtO5DbVSZcaUZiOCo6Ro+CBXkWzCooYk7RNg/9VGq7Xm6ZDGaeV
         x7B5jEkSyV098Gn9Kv4z0+tOfyHTlItxGurvYAd5h45J4Q6Rb6z4S5BWXwDu/T9rbfz6
         IbAOOw/VvomMvWgZNndLzGdvQEbE3FI4y579E3CKVZc1IEK/ObvmqKpefli2NIQy3u7w
         LmL07mQ9m2z/yT8Bmpo8w5M1FmgPLrq632lCJEKgVSkR9B3uh6vt6dJbcg5iCX0kfa5w
         SnWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LoaCL2H2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor8495141pjv.3.2019.08.01.19.21.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:21:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LoaCL2H2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=b/YV2nCBRUvj+JHalhe5VKLnhqnMLLZTxEiSQrNBGLQ=;
        b=LoaCL2H2RUJBCIOglYnaArkmIVWTYlGIsKjGOYisZuAUApfhu5gEmc6qkNjj0+H7tu
         P+8Dh9t16ihvD6gplnd7Tc9AK6ZGCZeLjxm8tt5yZaZLJjevhgAQKR5u0bAClFOVBiw3
         mudk+AK8dwI6nYLVBSSjbYQjnEo/x77kPGPgsQFzLk0mY0MTwpLYueBrrkls4g4lNcFE
         23WeAWQvuXbP3ljk10sU7SrPFsFGjeRWLbXNTJO4ixgqQlxC9gc1Tv3tUxDQgjI0BYi3
         8BhTJVYtfR/r0jUz//rNUXMcepW6CTlPDrLR0cTlbj3o8jhk3sRuBiigNZ2CjgqdDsZo
         Ctuw==
X-Google-Smtp-Source: APXvYqwGNmSeCqbGUwEK1nMIVRCwdEn4NOX6aNf7I9lvnteHEiZ+Pa2UbMiy7LcaaaYIQGQbOjX2Vg==
X-Received: by 2002:a17:90a:3086:: with SMTP id h6mr1977670pjb.14.1564712460540;
        Thu, 01 Aug 2019 19:21:00 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:21:00 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 31/34] nfs: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:02 -0700
Message-Id: <20190802022005.5117-32-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/nfs/direct.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0cb442406168..b00b89dda3c5 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -278,9 +278,7 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
-	unsigned int i;
-	for (i = 0; i < npages; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, npages);
 }
 
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
-- 
2.22.0

