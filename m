Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90607C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 476812189F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="o+RBABok"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 476812189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC996B0008; Fri, 19 Jul 2019 15:07:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943598E0003; Fri, 19 Jul 2019 15:07:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80DC38E0001; Fri, 19 Jul 2019 15:07:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD4D6B0008
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:07:11 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v17so7271004ybq.0
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:07:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
        b=h3VV2+noqSVxzu5+wMJDoNpZooAVnB3qT2idmdQ6asmIygnQOBD5UJzEgIfbxQ5hf/
         ytHSJhkJKa/y6yrwGGpWpYvcrep/QGtaIabJrrT56s/P5kbcN4Bbo1UOIzLQRvLkw4Gt
         5XSajSR66Sp0GYjfT8l2a5/XmuMMVfN4pZPLOPbeXlRYRd8W09PhFnDZIyJa9KAU2wJH
         cx8Z6uDWNGT4DJAX5lPDPvLjNjFKk5hvk+OYf6haQiBru6wUUkUpIf3naFXr7nXo8LzH
         RymvbzmLWrFI2S1ZHgZnJAil1qG0Izr2ViTMRIMQCz8WRwsDrQoD0Tz0zwYFlsmayV7B
         l5bA==
X-Gm-Message-State: APjAAAUZ5rJZ2eAbdGZKUQ++D22qc/dazqNGg+NeyFm6S4UFcBB2qo7B
	a+pqMItb0nX+yatKDNLA8Ry5Ea2aAY+hjqLTp6HopJfBbh2mwaozA8ggZvRqTraJfISSbhJUnSo
	mfzVlz8AkH7j5Y0aWCpZChQnyJQmV0A0GzoQBjohKwzeKrnNruByVdVC7s95iTIrsdA==
X-Received: by 2002:a81:3b8e:: with SMTP id i136mr32212531ywa.493.1563563231111;
        Fri, 19 Jul 2019 12:07:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWydyrb+9EmJp+fNeHMlTDYYPvl3jtDWlEv/lCKL1KljFM0QrMEJz/4QSptxJDcGh8wQDR
X-Received: by 2002:a81:3b8e:: with SMTP id i136mr32212474ywa.493.1563563230151;
        Fri, 19 Jul 2019 12:07:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563563230; cv=none;
        d=google.com; s=arc-20160816;
        b=YHlFISfQEdv2GRK/WOVZKg99tIyift7Q+wJfyDh1KY9EreuD6m0HjIhm+y0xAe3zC3
         eSe+KM6XZRs6brV5LlIMZDspy4fbMuaLh0JlLYD5PXTVkPHxZaNQhMT+I5IXEinRb8hl
         fcCVjGIuRRM7wbHQ5aVJI8EMS4hEVxTPpxR5tgSH8iA4PB50bi12SNaYnvcTuR/DDYe2
         uw8VGE8ehxjdekHVXmuTZSeijt2S364dNBW9Hk9oHM1ElD9coqb26joMt2BrrO0g3j2v
         ieMjSl9lv69iwRo85qWXzbGoNUpcdE9Lw5M70hsKLBgGKvYAw1PIE/dexuwYB3zU13e9
         VK0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
        b=vJhAtpt99DGrVXLjdJ05zSaU9ASBC56DcX+oqmA/09dBwjr7HaK4Nstl2FsNRS/zc8
         IyK5D4gYcUkYRxFk8+DcgBvG2TBrIl4zdFLCxjipY7+veBfSoxJTPmwxVVWDn6g3Li8+
         pZFwH9S0O+qv6lfO3t8HGKv/feiSS8etvGY9tTTb3cp3NA/lsNBsFB9vQSOn69M/30TS
         2b0FvhBPAP1VEjNGuDYj2++okt9x0P4OpjlIOn6vcFfRERN3UHUn6eEngxlZV6DD7T8Q
         hGQ4X966AkgIg3MOCfjhFHHIR34eJCW/N2GTkc0LNyUKJ09sfEhEoJfb5cSUtrcXR9mN
         AuOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=o+RBABok;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id c9si4728987ywa.216.2019.07.19.12.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:07:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=o+RBABok;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3214dd0000>; Fri, 19 Jul 2019 12:07:09 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:07:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 12:07:09 -0700
Received: from HQMAIL104.nvidia.com (172.18.146.11) by HQMAIL106.nvidia.com
 (172.18.146.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:07:04 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:07:05 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3214d80005>; Fri, 19 Jul 2019 12:07:04 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, John Hubbard <jhubbard@nvidia.com>,
	<stable@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Date: Fri, 19 Jul 2019 12:06:49 -0700
Message-ID: <20190719190649.30096-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719190649.30096-1-rcampbell@nvidia.com>
References: <20190719190649.30096-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563563229; bh=U0IXy/zKKcejMP4DQKHZ57GJs0lTlzQ4MYtXzCim3fk=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=o+RBABok9q175TIaACbH78zORn0X6HKDRIaL7qVbx6i1lTfFIvWnzJW+4vNL6sV6b
	 ZKgT8U/FylXyFeAAKUtwBA/FkfEIAamghIZKdkVrDQ5M71n4NK6qlF4EKNxv4IL4eG
	 +muFf+zUoAUwJ+7LK/tHizAsQdE0USzc+yeNNAo+BhVqKHOsE2Pc3X9dhUdgl61mgH
	 F95OPZNtDZ+Hw34YccLNzh4c/8BUxt3ybbT6oi2KcaW8mcQG/dCe872irjZnjQI/eM
	 pN1XUWI2MkJJS0eZpCAGD73t9t7AvrexWZ6dujBLVTspyk/N1JQL1I0qnp79R8szhm
	 24nbXQtuN0hkw==
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

