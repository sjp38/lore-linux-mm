Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98B1FC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51AE321926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IhtEE+3R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51AE321926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2E168E0019; Wed, 24 Jul 2019 19:27:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDEDB8E0002; Wed, 24 Jul 2019 19:27:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA66B8E0019; Wed, 24 Jul 2019 19:27:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B84FF8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:27:21 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id e71so30550066ybh.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:27:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=aE9jvpYovWbAuB2E+N8tRNTGgKOEO3ZSK7JOHwBAVAQ=;
        b=hUv+8GX4V+t2YAd4wVnnkVok+TXI2WH0Hd8gD5CYwLi0izH7/cO64mu9IoGKKupSLw
         DLt9ltsoggd3WLQBeCowg1V0DaboLZUykEyljKb/93spjVNYgZrVgH7nRTrjOBTblmil
         UnUF/iSktWtzchIcXRNnzoy6jcI1t6ViGgkji4+OeMLe9/CCV6PZdRrQTP+wd6OhRFVd
         o/N/yxxP1ZwzOXfF5UWasiyprFccnREQt7j1GvEvtyPhvI5iTrTobZsNtrAwCKu09+uv
         SUc5vcRWox2Ar5Qb4JhEX7ToHHH7QVSSdRd3URyZnerZrnAxB6+aPs3DMHWzVmsiO3fl
         sAJQ==
X-Gm-Message-State: APjAAAXiSGz0J3nu2tQrfJX76QAni6cJmS+6TM5mRsYEtvX5dz/b83QV
	ODnrSRBzg1nPJzozYBywECOefdTIhJTSMOK0IFLR1y2IHUkSzV83fQ/etI5GAwErrlIkDcHwr06
	BG/G9/waCuynlzx7sn64LyHtoz/snLKyFvXK2CTOEK6ntA+wG8w3kQJRRXGHtwxeG1A==
X-Received: by 2002:a0d:ed41:: with SMTP id w62mr49864977ywe.177.1564010841529;
        Wed, 24 Jul 2019 16:27:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwGgFPEmI/KdTFPirAjhWJJHCXkxb7tMC2M2fsG4NQO+WQaJ93Ae1m9oE2k3YwRH5l1v3g
X-Received: by 2002:a0d:ed41:: with SMTP id w62mr49864960ywe.177.1564010840956;
        Wed, 24 Jul 2019 16:27:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564010840; cv=none;
        d=google.com; s=arc-20160816;
        b=HKz4luUEW7W9RKYgZJS6Mk4W04fHyV8fUYtyePOLgXPAa5alc1z8Ku+WqOLzjo6Ot+
         URJR4ALWFWJzIlvT7V9nWhXIYXgB3Af0lNeFJAy2WfCGY+AgiUgJnLc4eoypYDV+L2Ga
         sdA8YYdQu8DMUS4FitbVsBaGzFsNiqdGOAf97a8vxOtxe6e0W6aXTjxdSGgu6GkINnsz
         WPFfw5v2DIArVuiK5vh5RP0T0Nt0An2RxknQnN2gFaY6wBlrrReP51L84oze79VZZY81
         j3Zvx/CSDDm/u2F6BQVdbXzXcfvb53un6QSXJBuGZZYzCzAwf4O9JiyiNJandVkJV7KH
         dWVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=aE9jvpYovWbAuB2E+N8tRNTGgKOEO3ZSK7JOHwBAVAQ=;
        b=HYCdOeRL08VN/zrIxTiZDYvg8Rl8SxIJQAHOYO5SCZrmIwiyYHklYT2H6IGicJO5Xr
         GkiSfa839uyN4vxZI/QLWKcwEIhQZ0MAuxSRobBVfDwOVWBKIpdUkM7UZq+QCWNxdGqc
         arABCpqUKKLDG4pvtyEsau8cKwUQAwe/iDRW3Q6jK+V/xxhxx7hhSn8IiQUoty8XS/jE
         ZJK7ZNSBi1dBSpLfZfhV7x4f2th4e0MoBq0qZzI3sa9qRQCXx2A0wYU1C0e7QxsOQ2xb
         NH+k5Tzw9HfDWyZ3hdSBVOnH6uWEeDVzxPhzYXO7EhARK6gUiXr19VhbRRI3fCfzEANS
         FzQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IhtEE+3R;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 7si16575698ybc.449.2019.07.24.16.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 16:27:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IhtEE+3R;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d38e95f0002>; Wed, 24 Jul 2019 16:27:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 24 Jul 2019 16:27:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 24 Jul 2019 16:27:20 -0700
Received: from HQMAIL102.nvidia.com (172.18.146.10) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 23:27:20 +0000
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL102.nvidia.com
 (172.18.146.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 23:27:15 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 24 Jul 2019 23:27:16 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d38e9530000>; Wed, 24 Jul 2019 16:27:15 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, John Hubbard <jhubbard@nvidia.com>,
	<stable@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v3 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Date: Wed, 24 Jul 2019 16:27:00 -0700
Message-ID: <20190724232700.23327-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724232700.23327-1-rcampbell@nvidia.com>
References: <20190724232700.23327-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564010847; bh=aE9jvpYovWbAuB2E+N8tRNTGgKOEO3ZSK7JOHwBAVAQ=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=IhtEE+3R5QhqFa2KEziinP9eneZiPUTOmHuX3Sno5dk2gEzneBtRMuE8WEt2lHLaE
	 AbaDZ5iX+QdPmQeebfejcPvuZ4D41S1xhiA4BLii6pTJSgMWdXUcWW5CrPQsupLeco
	 WBFf8AmzolDvoi5goY2JR1CweNtxSz6XR7Uv3XX+852s/f3+eqUPQ8jEJVd0GHsU6l
	 vxxT9YQ/FXsRyf5nVged5cLxXEImsR4cR31dJ1aHACQ5222keRwpvpiR+DC0o1NuR1
	 aTwHQdshh/APUALxv1ugMrYoF3O96zNWbpTodlMK2Kie1c1L6Vmuk5NhiwgwJp1xYB
	 K6yWPNzPEp/LA==
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
 mm/rmap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..003377e24232 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1475,7 +1475,15 @@ static bool try_to_unmap_one(struct page *page, stru=
ct vm_area_struct *vma,
 			/*
 			 * No need to invalidate here it will synchronize on
 			 * against the special swap migration pte.
+			 *
+			 * The assignment to subpage above was computed from a
+			 * swap PTE which results in an invalid pointer.
+			 * Since only PAGE_SIZE pages can currently be
+			 * migrated, just set it to page. This will need to be
+			 * changed when hugepage migrations to device private
+			 * memory are supported.
 			 */
+			subpage =3D page;
 			goto discard;
 		}
=20
--=20
2.20.1

