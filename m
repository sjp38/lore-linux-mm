Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02F90C5ACAD
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5E8F21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fg/Pfm4b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5E8F21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43CF16B0281; Tue,  6 Aug 2019 21:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39BD56B0283; Tue,  6 Aug 2019 21:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1309B6B0284; Tue,  6 Aug 2019 21:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6706B0281
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so57211872pfn.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=UDvXF0rtLhcsPfvx+GCZmtJOWx5wp7AH3aXsQv6i59Qg5WojlqHPkJ+KNl6bvSqPI1
         FcMoEXybuxa4pOm3l2VYuQyn1UwwcLhRJ1SBPGI+Q5oYjen7aPqaqSjkQli4CdFGlOp6
         q0gI6GmNXn+mtcuKork6+GYHl4zQg6BjauAMeaPPtyPE4w11m5HIsBqb3bHBPnKmSsqc
         IDa/a/UOyzYLa0R7ONwV2kkz+JAgSkgtSmo9R5fX9Yqp81bExqq3gZUnA3SvZnd6U41F
         woN6gNFK2+Kxu23x8s5TgN6oV/tM1JqIo3nleSWFcZno+6Ezmy1fmS28A0rElzBLTDdW
         XFNg==
X-Gm-Message-State: APjAAAUrEFy0hnZMPngBBUt256o7Y+r8CHdHUV79XBwCb7zoFy2ud2ey
	AqtPvn9qb6jfByCsblEP1OMYRpOvIMDkBjI0mdKbr73786FB4g37yMc6/ujxS1xc/cTQFhFkBDe
	pF6j5u4ViRBxOe1Lu6yySqXbwcsdEsmHtGRfcDSZCY8ZChjVxJBmP5CBdaVy6xTgV/w==
X-Received: by 2002:a65:60d3:: with SMTP id r19mr5595689pgv.91.1565141677410;
        Tue, 06 Aug 2019 18:34:37 -0700 (PDT)
X-Received: by 2002:a65:60d3:: with SMTP id r19mr5595643pgv.91.1565141676503;
        Tue, 06 Aug 2019 18:34:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141676; cv=none;
        d=google.com; s=arc-20160816;
        b=RyFTaBmPjDVtDI+nOt7BZHlx7tLk7/Exyqr/jAGNjXJnSQDNVkc6BGD6uXAZSPQPDr
         JF7esIbcwxn7OytSGydEmyS042mrKcDPgisQ/xb/r/llKKLapAwimyfVhV3KH0CB8dHt
         jBF4qp7PS+FzOmnBH2ZFowBs+QO6C7qZx/1SBzzaI/HZIiXpd3e5FIZn9PppEu7O+/7k
         hP22nENegv1kGBWq/9qxg30pcKUu+FsNkz95gyZrxpEjntWPi0dxv5ASmEsBw5xUyLwl
         a1BuTcTjDLtqfvn+cDwpz5vw+s5y9G/wBdRtUK+i417lZoncjAeVLgz3Vow9MrWI7nOb
         2yXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=oFpnu/w04sTQmFHGDAWE1vPMd5/LRHCJqqRUDvHEPz1XrEgLD5JIJTLKjHehiFLeQV
         e6EqbN7AfVeyvBOVI1Zqbc4zEVWCxr35sQHvjb83K9MvG8NVOR2NC2LZJ+oL7+U181JT
         qtDCizdcTOYkNbIImyT6CwRnLEKaB9nVOkR30ueSJxqNMUEvuec1am6WC5V/vR+CsICO
         e4ov73E3otHagBCbbD2qh8Vui84udgJ3TyeopNaZcYH1q2Gg+qzkL201QD+sO9SXx02s
         Yiz+2+XR2K+90d8Rme8SQmU+SEkWWnvhiadKwPcM0IpYVMRNc5u5k4O+4BZlL1BF/ec2
         OTEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fg/Pfm4b";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t69sor26384543pjb.5.2019.08.06.18.34.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fg/Pfm4b";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=fg/Pfm4bbVSmVcCrQT7+5JHEhqSFsHPgOaHWfBPnZWxRApjKfb4cb3kH5stgfnMMig
         zbelcrPsCI0tI4xwfOZRnckTrTKeUm3wG0kqfTVOMRYMB6MvjyF1Rql1N0HWLaZIzEfM
         iWdx9yjCpgBpQS5lPDIGFaAFICDzqEqnoV9x5MiP1hBYLTSZ4ogFH5QAAV9Yz6tw/8b2
         ZykLmdq9ZFns/SDVctWkjbZ0w3aCcCbjN/JvbQSxSyp41bzHjOAMChIKQXNa4QdCxgL9
         jwRKUeEurDeq/o0JqzXeiTfFAPo9oNntq7QpxEmENoOSeaVMGgE1SeT20aw5cXMwj05c
         mafQ==
X-Google-Smtp-Source: APXvYqyxpq50qUVkp6HWZCQLNWkEvhnyucBHKSZoboyNMe/1/wbJw75uRBEC9F8SIFpx6GEidj30Zg==
X-Received: by 2002:a17:90a:de02:: with SMTP id m2mr6000462pjv.18.1565141676262;
        Tue, 06 Aug 2019 18:34:36 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:35 -0700 (PDT)
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
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH v3 32/41] crypt: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:31 -0700
Message-Id: <20190807013340.9706-33-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-crypto@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 crypto/af_alg.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 879cf23f7489..edd358ea64da 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -428,10 +428,7 @@ static void af_alg_link_sg(struct af_alg_sgl *sgl_prev,
 
 void af_alg_free_sg(struct af_alg_sgl *sgl)
 {
-	int i;
-
-	for (i = 0; i < sgl->npages; i++)
-		put_page(sgl->pages[i]);
+	put_user_pages(sgl->pages, sgl->npages);
 }
 EXPORT_SYMBOL_GPL(af_alg_free_sg);
 
@@ -668,7 +665,7 @@ static void af_alg_free_areq_sgls(struct af_alg_async_req *areq)
 		for_each_sg(tsgl, sg, areq->tsgl_entries, i) {
 			if (!sg_page(sg))
 				continue;
-			put_page(sg_page(sg));
+			put_user_page(sg_page(sg));
 		}
 
 		sock_kfree_s(sk, tsgl, areq->tsgl_entries * sizeof(*tsgl));
-- 
2.22.0

