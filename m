Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D729EC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88DCC2187F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XEXD8+Mp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88DCC2187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A0216B0006; Fri, 19 Jul 2019 15:07:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350FC8E0003; Fri, 19 Jul 2019 15:07:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2669D8E0001; Fri, 19 Jul 2019 15:07:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00DFC6B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:07:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 75so24429328ywb.3
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:07:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
        b=uQg97wJ7Z4h2QrO+XJ1bDXdibKxwvANtde46rhrAMyUku0bkadO6nojthd2QEt1I43
         IN0kel8l5t26olLTk2Bb7/OtPZA3Uz6+ZfurcqYCBwdxOy8yE1nVrxsve4C8BKgLFU0A
         LfAbpaUAGBNp/8/UL4npG9HYAsfbt0Int5jqdPMWinIq5vmt//kMvVO1FLMhDhrkRq3E
         GndbChoZu1YgFYr37ImT+lCzzGFyeq/76SOOst2Qf6q4O9a904KKMy4na9jY6uyq8Yie
         DrXpQJclv/gr3d0ZpUaUzWz0Uha6O7E3T4cPL2NwQYVxtg6hZPQnMeCFMxUZ1L7cbjF/
         UxSA==
X-Gm-Message-State: APjAAAX6C9CR2ylpnue/nfbWwU6qj44HpGsGW1aJ9Go4bZSTkQpymjat
	tJDfGGgw2TasBz5PaDMhLf5scAfy17iSfDybI1900tMBCtCT6HVQP54qyOun+C/jVreWlBLbfwm
	jSwnVe1z2M7auPAEHgUMm1IQ5/aNSeEGPIUKhNU90XIFB5BYIayI6azrW2R9JcAlJ+A==
X-Received: by 2002:a25:5f48:: with SMTP id h8mr31072935ybm.231.1563563225713;
        Fri, 19 Jul 2019 12:07:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqz+JaVeFfwFYAacs4HDRqHDcXGW2suzG77yaxtKXss8rXNJp51LdmFZm0cBnIpbaGEEP8
X-Received: by 2002:a25:5f48:: with SMTP id h8mr31072891ybm.231.1563563224924;
        Fri, 19 Jul 2019 12:07:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563563224; cv=none;
        d=google.com; s=arc-20160816;
        b=Ix3Cr1vS4tdJ6U5jctNGU+GsRN/yxFZYOLoZvvkgo7z4p7asQv+r0NyyWRz90Ze4rF
         uw9DjrKGEB5oR1bGf3zVHO2GWptrcQzMoi2TQ3ucDgZerVhUBgXAKxNaLNUaxc6CgU8C
         QDKqL68MGMNS11xMj3oDCct8Lgv1v9YuNjOXTvDC/hziwCIhHq+mtSoFcRz+n9k6jEPR
         Vyo+LfyPISpqgGBHzzvOhP02UMA16OQNhY/pf/SpjQFXO9lkIWgt2C3dGU+QB/T3KxNS
         zvVEZAEWeOM3Ai74Lp12LFT+LGUd5RsDmiYsZVH/yFRBufQmNYrNaDMhKT4DFmm+Ki63
         jgMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
        b=jGWKl54Kil2HMzgxZ+Lz4cPrygRr4IY2BkwkqZdjge3M2mDDDkpJnHfDWdKSFD1PFY
         7wZLnfP+Kk9LKqluZb5Wmr4zK2SLDwYNPDnC4HyAYe04hygZSVqddmfXiLSEBafdpCWE
         i13L1AxXrN0jprpQpBQWz6+eI3gaRFvpRtcMbDusMNdSVM8iXGgo6oGWDbAp67RgvJ6x
         CA4FJCAl0B0kcmhxkXTePZyA2EUR3YTv6w5sDZW8OG9oy4bP3Dqnh9ug8QlbTQcUlIne
         mpWQt3mw5NY3B9vlfv0yZBGtQj2uL5ExWH4ihBj2UHok/7uICV/l5CNIDJWrTSt09nDL
         DmEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XEXD8+Mp;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k128si13078839ybk.341.2019.07.19.12.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:07:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XEXD8+Mp;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3214d80000>; Fri, 19 Jul 2019 12:07:04 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:07:03 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 12:07:03 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL106.nvidia.com
 (172.18.146.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:07:03 +0000
Received: from HQMAIL107.nvidia.com (172.20.187.13) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:07:00 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:07:00 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3214d40003>; Fri, 19 Jul 2019 12:07:00 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan
	<jiangshanlai@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Pekka
 Enberg" <penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, "Andrey
 Ryabinin" <aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, "Jason
 Gunthorpe" <jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/3] mm: document zone device struct page reserved fields
Date: Fri, 19 Jul 2019 12:06:47 -0700
Message-ID: <20190719190649.30096-2-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719190649.30096-1-rcampbell@nvidia.com>
References: <20190719190649.30096-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563563224; bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=XEXD8+MpeZa8W8p+pE1zOfZ44fRxNZfhiDWMcWxGdu0UuRY6HiaEZ343XnQhe8G9l
	 plFxe13YRg7+09Pz3X/2r5ztqQ7vDggzGl7dYEf2qZhHAFEEIdiXXDfJIM11GZaBXD
	 8Sn/eycEEMOXvMVmcYByNs3x4Hgc294+XGXs2WN7VREX6SoSERQlIZ2kWAFpsBezK1
	 2qPKW/Tai815rjsLCrsQlfRNce4ANwWohy9W95HfonwFgt6rH/hFQ5j/SDdTFdiNVN
	 fyGTBqmwrAFuong+CNyxx6UPxHoDak9BCXrLSaPipZ+8bknLhdkw5Dh6BPDewv6qoB
	 LscjOGnASY84g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Struct page for ZONE_DEVICE private pages uses the reserved fields when
anonymous pages are migrated to device private memory. This is so
the page->mapping and page->index fields are preserved and the page can
be migrated back to system memory.
Document this in comments so it is more clear.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/linux/mm_types.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3a37a89eb7a7..d6ea74e20306 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -159,7 +159,14 @@ struct page {
 			/** @pgmap: Points to the hosting device page map. */
 			struct dev_pagemap *pgmap;
 			void *zone_device_data;
-			unsigned long _zd_pad_1;	/* uses mapping */
+			/*
+			 * The following fields are used to hold the source
+			 * page anonymous mapping information while it is
+			 * migrated to device memory. See migrate_page().
+			 */
+			unsigned long _zd_pad_1;	/* aliases mapping */
+			unsigned long _zd_pad_2;	/* aliases index */
+			unsigned long _zd_pad_3;	/* aliases private */
 		};
=20
 		/** @rcu_head: You can use this to free a page by RCU. */
--=20
2.20.1

