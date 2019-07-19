Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57ABEC76198
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16A84218A5
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YIkfifBJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16A84218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D5B96B0008; Fri, 19 Jul 2019 15:30:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75EE56B000A; Fri, 19 Jul 2019 15:30:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58A868E0001; Fri, 19 Jul 2019 15:30:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 375C56B0008
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:30:11 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id q196so25392400ybg.8
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:30:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
        b=n2xURjvAEea/yjLoYOlYusPeqFd2NtS0cAkJQERdv0oPASKP54pYM7nvVvazCAZz3I
         Ubof8FlzwektkmWyreOSXqtixtnj1LCDzJlKqJr7clagGV8oK0l5lpYqSfcvay3SmOpY
         JUW70F64KhTU4nGBqdSrzh0V5rcOaLtj8wJrGglx/LzHxSMarXqDv893zR9/noYZdn5K
         qtp5v15P7cQbKqwWlaBpkHfWB0l61Vu9/GdGVpoG8+kW1Tz/XSvmlWOwDjzkP7D6JGFc
         FQHz+BVWSSYZdHeAZztpR43sveqSER8EO8f5Y8dfAKwUsY/OJVaFPrMG8R/zRkA4Ym3S
         +W6A==
X-Gm-Message-State: APjAAAVbNuBck1gl+BWJuojI/DuQGLd/eqkPMMhbR1XA3RhgLLsBvlP+
	fK5ZX42jg0tGqMr/Iu276JNk8+iRHLUtqMrmliziVWofHRPMyzPV3XnhbAgwYtU95FFOsyAFCiX
	5h3K2jwOgOgzrATPyzA4nA3HW3mJurBcri71hL2L4GEbIck0n+54+kifRjKIE7cWuqA==
X-Received: by 2002:a0d:c5c6:: with SMTP id h189mr32212156ywd.274.1563564610991;
        Fri, 19 Jul 2019 12:30:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgsSXyHrLDWZPk15MFns5BbSwBb8keSHgNe2wLPECcwTaBwbgGh9F1lAZTIl+qYHqwFIUJ
X-Received: by 2002:a0d:c5c6:: with SMTP id h189mr32212132ywd.274.1563564610387;
        Fri, 19 Jul 2019 12:30:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563564610; cv=none;
        d=google.com; s=arc-20160816;
        b=G3BLFQOmm8tW7a5EabaJPS9I4lTbwZXeslZ83PFgSQ6QURTD8U1kzMIsUULSeBxYN5
         dK76BZxbEMcsETXCoWD8aH7mFqbMp/QxgfwqEf5LhZr4bdvV3p+NmMFjls31jCknQz6g
         QfoHcjVjcmvDSfUnWvyZJSvX1YuL4NgifWGluxUKV43J2gohksVFKHBxZG0BShhhVlvh
         mne7p1t4ScfgX4O4ppwWfU3ODt2Z0vvRdlgefCT2Se2GdrnYKV73AI+nnik8Aqun1fuO
         QY9/o3sIRBdoS3aFiFs0YXfTV4fs5q2/0IAFwIAE/ANzru3rFW4l720/WkfSIWXYBEsa
         aiLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
        b=Lyx85A+wOWOA4Rl1wmr81pHewDmPYQHw/0DSTVIK60+C14z4Dj6vaTMT+gn3Q39FEW
         HPjYoo4IVuqhMNnabO1/GxXExvV/xnRHynstTa7zCcvASKaxPRKQ+i81w3pdoyRgMP/U
         cgBYCeeIjBLZXEWd5qT6MwpgI5iQP1BwELJplINDYO6Yu1KkvWAwgFE8QVQWZYqMsmlQ
         PDU6F12ZyV9CfpnjBVduWHQGSbRF4wvR4GG6kxHyd0Sjl1uIvUox8R+96ZWzndXAeBBU
         +zsWSbc/NbzrhMxOfE9Dek7Avvp4sjn9m2V8c+/NVzqy4JpeNftK6koyg9+1xqurYqvO
         5Gag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YIkfifBJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id b4si2129808ybk.4.2019.07.19.12.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:30:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YIkfifBJ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d321a3f0000>; Fri, 19 Jul 2019 12:30:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:30:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 12:30:09 -0700
Received: from HQMAIL110.nvidia.com (172.18.146.15) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:30:09 +0000
Received: from HQMAIL104.nvidia.com (172.18.146.11) by hqmail110.nvidia.com
 (172.18.146.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:30:06 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:30:06 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d321a3e0002>; Fri, 19 Jul 2019 12:30:06 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, John Hubbard <jhubbard@nvidia.com>,
	<stable@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Date: Fri, 19 Jul 2019 12:29:55 -0700
Message-ID: <20190719192955.30462-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719192955.30462-1-rcampbell@nvidia.com>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563564607; bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=YIkfifBJUS0alAYsaVI5Ym8d5Mg4+IaenMIF+Y0kr5t7XnywK5CHmhhjsvvwxA9YN
	 hbDUy5VkcxKbbwBf9ukQ7ACI2HDXzbD0iTnXCostTVhbyzPsfBQOqW5ZqgiHWqg/TP
	 MIS7pFfiezJRrkz9KW5msKmEg7H2CntpEWhdHIJXJb/VPi3uVI0Od4R1IDwOXCe4NP
	 QNBpDA11Dl9eAOplh9CwMN2llenNQpmONbUBX2CZwZ2FnX2zNmEGFP2F7n1WNt3mYk
	 ma8muqGT1xXFWVoBZKhUXjZHA19CbXrT/M+0ogyaKVYdDZFCytv8Rv2cc+PudYibtr
	 kBIWEui1O0Rtg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When migrating an anonymous private page to a ZONE_DEVICE private page,
the source page->mapping and page->index fields are copied to the
destination ZONE_DEVICE struct page and the page_mapcount() is increased.
This is so rmap_walk() can be used to unmap and migrate the page back to
system memory. However, try_to_unmap_one() computes the subpage pointer
from a swap pte which computes an invalid page pointer and a kernel panic
results such as:

BUG: unable to handle page fault for address: ffffea1fffffffc8

Currently, only single pages can be migrated to device private memory so
no subpage computation is needed and it can be set to "page".

Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE page=
 in migration")
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/rmap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..ec1af8b60423 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page *page, struc=
t vm_area_struct *vma,
 			 * No need to invalidate here it will synchronize on
 			 * against the special swap migration pte.
 			 */
+			subpage =3D page;
 			goto discard;
 		}
=20
--=20
2.20.1

