Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5D2C04AAE
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CA9321019
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KhdjRbMY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CA9321019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8C376B0008; Mon,  6 May 2019 19:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61E86B000A; Mon,  6 May 2019 19:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A02766B000D; Mon,  6 May 2019 19:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A37B6B0008
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:30:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i123so4433920pfb.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:30:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=5WlIjBgfvDyvCsXkm0NjNZ11WXFUwiQ4B+j31tyLuKg=;
        b=SO6Nhi+WDJvcYVVkVADcs4l6vaxjFSJsrsD42a2aFO85/O8DAYRfxhWMRZdgcZV+R0
         clKMm+UMA7kw9+wgzwgZIW/z5r1xwxf2lobpVFDa7mZ/u8aBMonAJ+vyU3cPADWBpH52
         eNbGh3xKXL9slx115opvzChqhyZFqlISVuUDJvx0qtCLavLDcQVyvkt8s1snflOGTJH6
         zLIiOCV2Kzr7WVp6VNGtrpxwpO7KKcmbYkj/ItcluJtglvWD4ZoJelx6BvmLw32xP/H6
         Hor56/HMRddTVifFHfhal2NARLM+YcF4v61rDYVlgws6FaPK/iRY9Mw6dBaNnqq3eiH6
         poCQ==
X-Gm-Message-State: APjAAAWx+FaIRmASyq35W1hSSRVxWOedcWTVQgfgTFUWrF5AMuzWK1eC
	R4NS/A3DCxJ9or5hl0wgB7aK1Pi43Fu6wy5f14AZwytDJdiKTXvIqwj4tM9gpXmLCjK6uL6cXwm
	AcVgc9XmeP/AUOHOLnr/mHa2HxM+TAPquT8uR8b0nbARntv9H4U8LpfcDesqONQVF/Q==
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr36430122plp.291.1557185452117;
        Mon, 06 May 2019 16:30:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvOolTQs+aIQa4Dq7LNhFJ6q2IC0ysNVZdJPGxruBUesW5pStraMtolAz6DfRJSsMEj1WV
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr36430047plp.291.1557185451176;
        Mon, 06 May 2019 16:30:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185451; cv=none;
        d=google.com; s=arc-20160816;
        b=qSte1FgnxcuSNT26//j8N8y/n1HxrXDrXdnoWUrayndauNZcakXVWm5YL/osUWQIIz
         KjCpqEcSpkTJzyg4+6zcnS7K9Vp9VTzFDjec0s5IAUep63zvlEAlxmNTtFUOL/NU620q
         k5ud5z48M7rR3Wo30Xqd3JvpJOSSewYxMLBXqm9tH5t031JYQYQNJWiSEWJPWmkeFUKe
         cKWlL8qV6J/qDXqKi3k8Xjr9fQJAL52+NIFzXs6m5t4D39ienBrwSyGgG775jVZ/slSV
         EwLttlEkgV8J+LYlwuWeoKDDOGTfe321rGWX5aFnPxr+pwo23bSu/rn2NidnI79FF+/t
         B0Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=5WlIjBgfvDyvCsXkm0NjNZ11WXFUwiQ4B+j31tyLuKg=;
        b=B/2yIHiX5mnqt2i0GCwCoNFyaixGlLsv99M0hwxh11887fHugVtaB/931EUsjyBeUg
         UcLMX8V3zenfbWtoCdRiCE36ccgEC8TEB6MAe5MXFTC5yZ0Px38w1z7J0S2k+wzY9lIW
         6TjNDCjyt8E4BhAnlEiBXPQ6kwYKkVYFpq2xC6xf54ZzBEpdz5wqfftt7LJEtZl1Zmeo
         sRr4L6WkdKOGu7D3guR63lq3Vyc5oUNhvylhzVA7v3p68w6rQTp0ielo0JQxnloICmWE
         EBnWSYIEU8D6RSwYOaj5lyAkbtF5dORxoSUuRJjknG4u9K9FrQPkdbgdxOdVCT7gnrO1
         14Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KhdjRbMY;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f193si9204285pgc.144.2019.05.06.16.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:30:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KhdjRbMY;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd0c3880000>; Mon, 06 May 2019 16:30:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 06 May 2019 16:30:50 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 06 May 2019 16:30:50 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 6 May
 2019 23:30:50 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Souptick Joarder
	<jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 3/5] mm/hmm: Use mm_get_hmm() in hmm_range_register()
Date: Mon, 6 May 2019 16:29:40 -0700
Message-ID: <20190506232942.12623-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557185416; bh=5WlIjBgfvDyvCsXkm0NjNZ11WXFUwiQ4B+j31tyLuKg=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 X-Originating-IP:X-ClientProxiedBy:Content-Transfer-Encoding:
	 Content-Type;
	b=KhdjRbMYg4rMUz7KfK9xJEDf8RwHRFmHw5yW1h4Jhf0lnVFlVigwpaMNLfTtjfrFx
	 FSIoT52YDf6KQSTBJdQfBl0Y1SP60r51yon4cBXYK9TZYAcpO2GqaSkcFKpR3kteJr
	 9827Jc7XMXh9Mj3Brr3ZtP217RpbYYz1SQ0Nq9ZoiNGBmos3CU60FFaGS+avEFFpb5
	 cMxwubKqGavAbg5bTZ6Ioa2/Ov1aLGeAmVmwfEtyYXUDolypmiKZUxu+hA+nRIz0U8
	 jFTgs+iYsHmsF6Cr3/i1vWvMvEF6Q0erFwpi0nglHSYFRtvywldCLt2OpEHi64nDss
	 c7GjIKJjQXBCQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

In hmm_range_register(), the call to hmm_get_or_create() implies that
hmm_range_register() could be called before hmm_mirror_register() when
in fact, that would violate the HMM API.

Use mm_get_hmm() instead of hmm_get_or_create() to get the HMM structure.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index f6c4c8633db9..2aa75dbed04a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -936,7 +936,7 @@ int hmm_range_register(struct hmm_range *range,
 	range->start =3D start;
 	range->end =3D end;
=20
-	range->hmm =3D hmm_get_or_create(mm);
+	range->hmm =3D mm_get_hmm(mm);
 	if (!range->hmm)
 		return -EFAULT;
=20
--=20
2.20.1

