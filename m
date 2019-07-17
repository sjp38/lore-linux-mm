Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C155C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54EC62184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TRCk27Tt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54EC62184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDA876B0008; Tue, 16 Jul 2019 20:15:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8DBD6B000A; Tue, 16 Jul 2019 20:15:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B42758E0001; Tue, 16 Jul 2019 20:15:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 916BD6B0008
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:15:43 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x20so17483220ywg.23
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:15:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
        b=dofLExKzZ1YAp2mnGWnp2qwKnBBe0Jir1AZR9Szj17VLZc8ErE9PWGypGFL9GJv/NO
         eexpiL/kf6mtUocUHhqt3QxNdmrxdZnJcDSt9sbKxd66Ma2GkE7wXoZ2mPiFdCb1NZgz
         7i9hwHg63aVgu4qkb5Xxedk07v67WA8CUX8nAVsUanig6V4jvdJEgkAbC8CmJA0tIw6R
         GrFBVpjfsPaYc59aPACxEHPMYMhYkWkKMwmdeFb5rRqruqMTi5LuK6CGibxUPJkHBhjn
         Z6/3+LId7tMA2S6kqalQYHX00c43bXHMRPIsY1TtrESvpYW8eGWEAR9KgiaAPpgspSN7
         UfHg==
X-Gm-Message-State: APjAAAUdizFyBy3ivHF4tOz72Wa1TZM97w6YiMi6dV28ybvV1U+PLoth
	bskGbyqaE5PCba7yR8TaJSJM5QTmQ3pZYKGKMqvU9rzESSV8kbaac3JBNR9jkeob+dc1oiU49UF
	B+TpL+6tBPkNXvXNsl1bkLEHxoNREAqg36bW+XvSztunx4gvWz3fsYfUDUAaIgk7Kqw==
X-Received: by 2002:a0d:ce84:: with SMTP id q126mr20340882ywd.88.1563322543324;
        Tue, 16 Jul 2019 17:15:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1mDRcYQ0ruS4uNLFPXD6LCpIAZoJfNOJbUbQOiDACqtlzYV0KDQEphA1w7uUGzWxlo3Q9
X-Received: by 2002:a0d:ce84:: with SMTP id q126mr20340855ywd.88.1563322542739;
        Tue, 16 Jul 2019 17:15:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563322542; cv=none;
        d=google.com; s=arc-20160816;
        b=WK4yVF7jnO6PQc0k7okvpH7G9NqGJzfeI06hZ4cvmUXJrws84e+X1iH+Hjfvg0FwLJ
         lz6m/e+E07bKkU2ZgAo7ZqZxAHbI+iNYsetShDES2mIhufiwlvfK5Z5wS3SOQqpcWL2r
         +He+MHj1IiT+fqTVJdd5vZwc3esHjvnprl2wofTJr8++COMmxy5gpEC46KmfaBBL+X4d
         YaTYK3YcaJY7qlDQtvFSytpPojYxIQ6bopvMhLwN8kE9xx5/ZrcpKGgZMpD9QyC/rC6/
         USBSEztUzlPdiWU68nkqZzykVgdmLRaeWVqUQfxskZZLkiP9Tb+N10T5CWHiRF2kHycI
         IXGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
        b=nACFUUKR2Z+wZQ86soOtQ/gEpXyCOZS9LimKnpk9P/9XCmkFkUdrUO+5yqOZkNuBqY
         +hQr1liBlhXeNajhW8nJJ0cIDFuJyQnGWfAXQQRERPksFrYMmu3o++2GIUzftT8p58Xa
         mZ68j8/PvrTm2W13XKogbW7pIFHOszX98ows/QsdpfVRl23UVALgJ7RwEpSTpuym1CS0
         VhxvSymT734SNGVYANfM1/G8Jzk4pxhp0gfLlBHKikWYmbt7y7j7SaUa2V83XE/Nkisb
         CEML9SFa6H6+TTPS1+LaSZGD3Ntct9S3GzjndXYlDh1SeA2W/LduvHGpXfILrX4ZoaoY
         7ZCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TRCk27Tt;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d14si8691441ybr.421.2019.07.16.17.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 17:15:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TRCk27Tt;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e68b40000>; Tue, 16 Jul 2019 17:15:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 17:15:41 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 16 Jul 2019 17:15:41 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 00:15:38 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 17 Jul 2019 00:15:38 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d2e68aa0003>; Tue, 16 Jul 2019 17:15:38 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	<stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Dan Williams
	<dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Jason
 Gunthorpe" <jgg@mellanox.com>, Logan Gunthorpe <logang@deltatee.com>, "Ira
 Weiny" <ira.weiny@intel.com>, Matthew Wilcox <willy@infradead.org>, Mel
 Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>,
	"Andrea Arcangeli" <aarcange@redhat.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>
Subject: [PATCH 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Date: Tue, 16 Jul 2019 17:14:45 -0700
Message-ID: <20190717001446.12351-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190717001446.12351-1-rcampbell@nvidia.com>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563322548; bh=xvR8iX2outgELqejVmTcMhX9RlYLy+wU1js0WKyDum8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=TRCk27TtRrVv4ByDmKeCrqvJNp6+08H/etGBrEm50CH2SOXfZYymRmojCkvp8tLa6
	 H24TZFPuMsdO5jijygFy328uG5wNmKsxJMZir8gAsUoeMTM1BKQGEV8NBWZSheafK/
	 1S/5Im8uAHIvUgtRm1EwNzfrk7IV6HonA8TEYRmmBQ2vyc8BFuVHI6uvlLQaEQfw0v
	 XMqf8AqOwJrQxQ9pw5ESS5F/4G13BCIKLFjGjLccKaQ2cKaJzvx7FfBQi37zgSgXYP
	 Ci17HzuHtXsMwYZDJqiTmYa54GJSGJ9gco+U/XzjJcosLSDUgG8c6QBed9JHo23xEJ
	 cUx2MNq/WejeQ==
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

