Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A36C4C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5889B2189F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="T/Wkfrdv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5889B2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 061A68E0017; Wed, 24 Jul 2019 19:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 011238E0002; Wed, 24 Jul 2019 19:27:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF5358E0017; Wed, 24 Jul 2019 19:27:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B965E8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:27:14 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id x20so35731151ywg.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:27:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=AGMennFGR3RQwqOaKvawxIvCw+p1UUJkNAyV14vll0s=;
        b=JPjUoHT1d+RObcxWK2GJHZqOo49jw+wsRTMfz2pEihi6yBuVaLGJPrMo1ssgBLTtCv
         LzpHhUjMierUsFt/5FIhiAkf53ZMa9RFzbK/1miDIPW8BH9B5SGYgIvPuSTXtcq8hd++
         JwksgHEG+8RkVpf1kvzvvxsM2e5EyG+WYgFAspBUotF/Xj/NaDb4FjoODjUWZnKT+SnF
         zksu0JDEfd8lUcs16STna6OQIR+MWsaa04lsUIvzNQJPkdB+x5qUWrc9hzeZQ+zL66Yo
         7fgI06p4JUpuAN2R1gtXWCVzYuQnu0f9itaCIU/AH4Y27Z1LZbcObNpKMIcoJlMGsN5C
         YPMA==
X-Gm-Message-State: APjAAAX7qlcJhr0gkxDP/n6NqRRTzSpXIwJ5QcMTfY7t14kRhoVVZ2hl
	ILEJ9T3rpvD+PLzYyzZ+MG136mCDW7q1crSbUfKkGTJaqgceFlFelnraO28S+2sTLkd3gzPfhdu
	RLdQC8qthaSY1p9TT0rtdIcM5A5OYYT0dsrvHZLPAoXEdobLZaSrUZw+ETC5P9MqUJA==
X-Received: by 2002:a81:3803:: with SMTP id f3mr50448230ywa.337.1564010834522;
        Wed, 24 Jul 2019 16:27:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxp7/gYccoHysvseOCG664xuHe81z6/6MaqlhnDARaqLlA+CnbzR+UtYXJqFzqFKI14OAg
X-Received: by 2002:a81:3803:: with SMTP id f3mr50448208ywa.337.1564010833925;
        Wed, 24 Jul 2019 16:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564010833; cv=none;
        d=google.com; s=arc-20160816;
        b=HAd6SVtpJm869eZ6+MJZAtfXad9Iejo30ukQEniGOOeAl7V7J9jM8RpYlRUO+hR0bQ
         /oDApVSSD7xa0fqm67/bwrqzWHqD3hl7sL/INBXQfiR7GWoc/XJUHwsDVGkW54d4NPAE
         NRcFYn2YpCrHlTVzt+uy6WgO87PrRT8JQDQ7KvbLuwBU0BUgVPCPERhpTtQBZqeXdQy0
         t0bLwOf7dggfEt9cgrliRsNv7wijBXoZsgRbr/kj1avgbfT6foe4hapEvPZTmOtWVGx1
         TOrdOWeKDPx6AVQlOgNkbiRbhbZwlCfWAOeB1t4nY1Iev0OmUGO0q0NY+U30V6/Pm9/D
         qGLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=AGMennFGR3RQwqOaKvawxIvCw+p1UUJkNAyV14vll0s=;
        b=cl60uCWyyXWj4gI34YMK8HYDxJKSh+mNKFpzA9+vSUaxox50RRN6zKEhHrm6PTfVTF
         fhhnjgSP9x1R587trpPLo7VG0BiDsTz3gKQvOXtqZYTUARdejMljqvLwOOtw+ZE2h4+8
         nP19atJbHhzKvhECSdyJpmCa4YXut0LT682Q0oK1Jksy81naoD96N2aPfUG/Jd/CFPkM
         i4t6dEp8NenQBh+D5mX1URHMc/CUc1G7Bak31jo9qdd54yS2rbQk0w7IkbPGC4jolO7M
         IanDDYv0uiXo+9IezluqHZn+dfKaIEkkE7GzVF2rlm8mp26qgderyAW2aKQ3nNfPJL/n
         0VaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="T/Wkfrdv";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k129si17420939ywe.425.2019.07.24.16.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 16:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="T/Wkfrdv";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d38e9580001>; Wed, 24 Jul 2019 16:27:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 24 Jul 2019 16:27:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 24 Jul 2019 16:27:13 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 23:27:12 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 24 Jul 2019 23:27:12 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d38e9500002>; Wed, 24 Jul 2019 16:27:12 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	<stable@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, "Christoph
 Hellwig" <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Jason Gunthorpe <jgg@mellanox.com>, "Logan
 Gunthorpe" <logang@deltatee.com>, Ira Weiny <ira.weiny@intel.com>, "Matthew
 Wilcox" <willy@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, "Jan
 Kara" <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Mike
 Kravetz" <mike.kravetz@oracle.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>
Subject: [PATCH v3 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Date: Wed, 24 Jul 2019 16:26:59 -0700
Message-ID: <20190724232700.23327-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724232700.23327-1-rcampbell@nvidia.com>
References: <20190724232700.23327-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564010840; bh=AGMennFGR3RQwqOaKvawxIvCw+p1UUJkNAyV14vll0s=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=T/WkfrdvQlqhaZ1B4Gy+zyQ5343De2o15Dzo1m6FD/7MgNn5uKqnffF4dzB3dkmKY
	 mmiUUmdHltbF6ltMVOwrDVa9GllkGYNiDoq8WmcIVGVqsC/Elp3l1WNPJ6CISgybvP
	 AwRg2lBx7h+xQwmrhC5943YxhIcGH0bPZsj/InKaG0EwCLvi44iY7FVj6+e7E486BE
	 0tj8W2NNZgnn4UEtqs7sUYEQXacImUiNmRFT/MsiwokLzZHmyOCJmraHOwsIzPppSV
	 S/3nigz0kzkE415ZkUpGn5gyuXcicjh1ltdikJX7/SSNVGUDERXSqHLu4wTA/V2awn
	 z6wm+r3AU1nPQ==
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
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
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
 kernel/memremap.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6ee03a816d67..289a086e1467 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -397,6 +397,30 @@ void __put_devmap_managed_page(struct page *page)
=20
 		mem_cgroup_uncharge(page);
=20
+		/*
+		 * When a device_private page is freed, the page->mapping field
+		 * may still contain a (stale) mapping value. For example, the
+		 * lower bits of page->mapping may still identify the page as
+		 * an anonymous page. Ultimately, this entire field is just
+		 * stale and wrong, and it will cause errors if not cleared.
+		 * One example is:
+		 *
+		 *  migrate_vma_pages()
+		 *    migrate_vma_insert_page()
+		 *      page_add_new_anon_rmap()
+		 *        __page_set_anon_rmap()
+		 *          ...checks page->mapping, via PageAnon(page) call,
+		 *            and incorrectly concludes that the page is an
+		 *            anonymous page. Therefore, it incorrectly,
+		 *            silently fails to set up the new anon rmap.
+		 *
+		 * For other types of ZONE_DEVICE pages, migration is either
+		 * handled differently or not done at all, so there is no need
+		 * to clear page->mapping.
+		 */
+		if (is_device_private_page(page))
+			page->mapping =3D NULL;
+
 		page->pgmap->ops->page_free(page);
 	} else if (!count)
 		__put_page(page);
--=20
2.20.1

