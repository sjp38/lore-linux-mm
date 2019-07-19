Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA37AC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4A0B21874
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:07:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OKZvq3+z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4A0B21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 462C46B0007; Fri, 19 Jul 2019 15:07:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 414388E0003; Fri, 19 Jul 2019 15:07:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DAD28E0001; Fri, 19 Jul 2019 15:07:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6A76B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:07:10 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id t18so25276879ybp.13
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:07:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
        b=VeVFJlFNlA0a/L/WMWSl8pWZ763KHXNDN/D4ylkRP+6BYtDYrZd74f6rboCtJ/jp03
         5wJZXXGKQNaDjEI2QefybiY8rl+r6f53Yje4ribFSHFkTMWPC4eMAeKVy8jAfGH9xSa9
         dHSEIa0DJnoabTQYx3TiKu9J2hH2EW6mo0+3XIKJfk5k2B1MPV4LA/dVZHYXzD9X5/Zf
         4muVhvR5t8UhpWG5ARcl44O0Cb6E0tY7DS2XypQHH6rncwTDXOV/BbYWsh6IF13J/3Ah
         g7aiYZr/+VxPG5kXmiE1NYWzyRkt21PzvZEAGcihe07OuO8OJFOajJryPoHJJhfDfqtW
         n7gw==
X-Gm-Message-State: APjAAAUz6y1yiUInXkIW4WR+7NTcA6MPSQxC4MzEhHTtDeaII9ZsfQLg
	SsOvLjGjSYOPxy/Cx785kklh6j53/h4i9hz3Fef9AR0JVMQejAGRJ6OUKczxjVZXxobJEOEJJ7x
	92M8Xyojrjj7UgIZI4P+axfCCiEonooApkSqKdvE4AJiYrP+K+NNg4Y4PBWxvcaL9Sg==
X-Received: by 2002:a81:494f:: with SMTP id w76mr31517836ywa.21.1563563229817;
        Fri, 19 Jul 2019 12:07:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIQE25zpOaI2NCzJVw2bYOmYYOUwqjF7jDMH1p5LGwPcEFOt/j7tsnRER8ANLpovEe31xo
X-Received: by 2002:a81:494f:: with SMTP id w76mr31517779ywa.21.1563563228864;
        Fri, 19 Jul 2019 12:07:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563563228; cv=none;
        d=google.com; s=arc-20160816;
        b=K0EM4rGyy00PDH43lKjyov8COnSUMk+VCRZ9+u7m8KjQzo/Ap9kxzKyxjOH/uVPrux
         qMvepriTal62iZ5x0syQVa7EYEryDnahLLhncH1LKcb8nfSaEqC6ul04txWrHZ+xongh
         nZ+WHXnu7i3OBLvJIAbsAdz/oieaYpg3eDFTFLzXl8D+8rv0XFI2xkvYP7Bolu03GrNR
         +FNuEyuJiIruWTZiunxLNHDfB/PN45gzAP0yVgscB0NsH3chL9/IyymzacvBojDMxuFd
         90mcjiYrrrknT5BxEoRYr8gD3Y+xjLWotwJzBRQNlyj0FGqNS6EDnY3sKDHCkH1+4TnU
         fXxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
        b=weM64Nl5l53zqSmvRtJiQG8Sb22/Fm/L+LXLgYEtF9v0b8EUt1gxA120lmlFPfFDvR
         9KT6UFHmFazeBPz7/2iXa9Ybwdls+KpmGrK7393rxfKoupTpWUWsSSkLxO5UbyiJgUjY
         4SDjL4c2irobBgch7GrURQL7Q0h1DZ1eytUdqbDV5tlf+FrLo/0KYLGLP+8RHz3fWp5i
         j10zLs0Wn0I+iDCveCbZFzNEZL228DSNgeSQQUabaxzVycQl1JWTVmAQb5tBYNgWlWC2
         g3jGF4TrV8M7mkSWsKSUfXWQnjinyPnM1Cm/kU8A+8To4x28MIl8xy/06G0M/Ps3M8/7
         t1PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OKZvq3+z;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id k188si6359068yba.293.2019.07.19.12.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:07:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OKZvq3+z;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3214d80000>; Fri, 19 Jul 2019 12:07:04 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:07:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 19 Jul 2019 12:07:06 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:07:06 +0000
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:07:02 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:07:02 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3214d60000>; Fri, 19 Jul 2019 12:07:02 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	<stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Dan Williams
	<dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Jason
 Gunthorpe" <jgg@mellanox.com>, Logan Gunthorpe <logang@deltatee.com>, "Ira
 Weiny" <ira.weiny@intel.com>, Matthew Wilcox <willy@infradead.org>, "Mel
 Gorman" <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>
Subject: [PATCH 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Date: Fri, 19 Jul 2019 12:06:48 -0700
Message-ID: <20190719190649.30096-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719190649.30096-1-rcampbell@nvidia.com>
References: <20190719190649.30096-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563563224; bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=OKZvq3+z673WKe9ZxHHENZNaFNaPQZoxO8AM7Y6bFKGbam/hN8xmfqFwVzF/1F1Y0
	 UcnRMsDU67Z51I9cCja1HqAyybrks1U6IV32zBohgz0b+bAkYuAPGZeU4bl49NjQY+
	 oSgVVuKMaEJ9+usmKExyucb5HPeidwazzVoZM/YEk5eWYU9GEVacTlZdhbiM8F4FYO
	 kTGHcZCLoO2BnoiEjtVY9PoQ05yzaVRFVKbdyj5yNjiVu5piwj6VwAqAvnrT/iU14z
	 ovFCHJs05zX1f6DQI1ic67Zpb+D9KoDGQXGOJbW/SsAnUJVXx0VoaJoAgnvWvg7gvh
	 xrPQ4Hwllt9fA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a ZONE_DEVICE private page is freed, the page->mapping field can be
set. If this page is reused as an anonymous page, the previous value can
prevent the page from being inserted into the CPU's anon rmap table.
For example, when migrating a pte_none() page to device memory:
  migrate_vma(ops, vma, start, end, src, dst, private)
    migrate_vma_collect()
      src[] =3D MIGRATE_PFN_MIGRATE
    migrate_vma_prepare()
      /* no page to lock or isolate so OK */
    migrate_vma_unmap()
      /* no page to unmap so OK */
    ops->alloc_and_copy()
      /* driver allocates ZONE_DEVICE page for dst[] */
    migrate_vma_pages()
      migrate_vma_insert_page()
        page_add_new_anon_rmap()
          __page_set_anon_rmap()
            /* This check sees the page's stale mapping field */
            if (PageAnon(page))
              return
            /* page->mapping is not updated */

The result is that the migration appears to succeed but a subsequent CPU
fault will be unable to migrate the page back to system memory or worse.

Clear the page->mapping field when freeing the ZONE_DEVICE page so stale
pointer data doesn't affect future page use.

Fixes: b7a523109fb5c9d2d6dd ("mm: don't clear ->mapping in hmm_devmem_free"=
)
Cc: stable@vger.kernel.org
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
---
 kernel/memremap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index bea6f887adad..238ae5d0ae8a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -408,6 +408,10 @@ void __put_devmap_managed_page(struct page *page)
=20
 		mem_cgroup_uncharge(page);
=20
+		/* Clear anonymous page mapping to prevent stale pointers */
+		if (is_device_private_page(page))
+			page->mapping =3D NULL;
+
 		page->pgmap->ops->page_free(page);
 	} else if (!count)
 		__put_page(page);
--=20
2.20.1

