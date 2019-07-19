Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A78A4C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE2F21849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="B+e5qGRX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE2F21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9186B000A; Fri, 19 Jul 2019 15:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B586B000C; Fri, 19 Jul 2019 15:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC6408E0001; Fri, 19 Jul 2019 15:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B658A6B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:30:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id r67so24450760ywg.7
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:30:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=VRtcfh5WiSupUP5Y8ZWeqEYjlWzsti4A1ZaXu55dh6o=;
        b=VNkTdpxakaw8TBHhkGJ6CWeuWWzy2crPbnGZ3ciw7BIliPt4uKSEjlaA6o/GwVKHO+
         avEOsagSpH3P8gsW1GNpoo/vTDkO56yCs95BqdIiYSpXX2v0oBMacv4dTmudQUQJz4j1
         NYvg3PH8fgHtZbGhMMTBag/clNOsRH52ZcsOAYrzXy63Sh7OR/1/SnwZuo7I6L83W9Fr
         P8082vdrS8AuSd2S4davwOJAQLiquPmCZoSVCyShtI6BRXaT4DS73O+E9T1vcoyKxEoC
         Uy4PXjX3+Jif9u5bONQzCQokjeJ2+y4O1WdEKrIZz2CWHI/wOBKq0SxHvpq/dK0aZtZK
         df/w==
X-Gm-Message-State: APjAAAXuZ6yMF2BSaIytc1uHxEiaZIKrlWg0J8lqOrIArOz3YgzE9XcE
	V+EgbDS6RYrVwi7xDoD8FyPh9SHLcb1TKL5XnPRVydeEzwkO4cPBhyiJjsk8A4l+kMyjQ7Z7nzI
	cad/4hh+E23IixKvdU3juTu9GJUM+pNWs8LYri3yY46Q6sku6W62mRMuVugPCAsHgdQ==
X-Received: by 2002:a25:30c2:: with SMTP id w185mr32090215ybw.508.1563564615471;
        Fri, 19 Jul 2019 12:30:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3uMglz7FrcODb+sLt62hm3PaJ8JTDJ4iw9xIsxRRlDQWuXcj/ddSNvjANhwNyt61PXLn5
X-Received: by 2002:a25:30c2:: with SMTP id w185mr32090194ybw.508.1563564614892;
        Fri, 19 Jul 2019 12:30:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563564614; cv=none;
        d=google.com; s=arc-20160816;
        b=lfd1+WF6f8gRZNI1rIzb2SOrhXVvYhsMzB119UdOr8ALZ+CsrwvOhYjUBnNk4rOdXn
         aT4Z52+VvpA82kqLEmI8T/JOzIeeEMxTV0vttigotvP6l+nVoJKf46zEBGyWRAVkrM5s
         8iz+kWJ/nmHRPdcQql4NfwxE2Isi6rtcSID+RnaId+dIRyfIgNODskNZhH2IgAk3sXl7
         0qC2r0noHOX7xkZ+RTJG1Hc+JtMpbPpILlitO09HL76WaADnOCbOSIFYOSQt4wLk8oTm
         Wzrr/xH4qKHwVcpGq3P+FDzZaEczdVL5/oz2jEZb9nnqywe+h8JjNSZ7rzTBdOxxG6YV
         zd/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=VRtcfh5WiSupUP5Y8ZWeqEYjlWzsti4A1ZaXu55dh6o=;
        b=llu3J9whev89454IY+XmW8BpMZsTKoklCMqLSAlvaZiw9vl3cqfEvXf9TPaHw/WQBy
         Okft8MIKmA/k4RYgz60DsgGHp8jqPHgrMYrUTXLvX/8/cxIGJf9h78jX6UwM2be6p7EC
         yfq8QOJfu2Q2j0oSP/ZjtHRgDnJax340Ggs85JX5bNQodbuUUXbrWVJ81KPAvnstCyBT
         ZyKDNo9e0iwNXlWTTkCJx+UozQSIZkaBWi+yO9ddT+WXtvMavknn1lS+5xyhYespfMpc
         Z3SFiBW+2CgftBsAT+FyZkxHX8TVMQ78HRHRR1rCKh5Ns0GX+0RQd6FZ31WeEwEci8ab
         ciHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=B+e5qGRX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r21si14448901ybc.179.2019.07.19.12.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:30:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=B+e5qGRX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d321a430002>; Fri, 19 Jul 2019 12:30:12 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:30:14 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 19 Jul 2019 12:30:14 -0700
Received: from HQMAIL102.nvidia.com (172.18.146.10) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:30:13 +0000
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL102.nvidia.com
 (172.18.146.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:30:05 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:30:05 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d321a3c000b>; Fri, 19 Jul 2019 12:30:04 -0700
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
Subject: [PATCH v2 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Date: Fri, 19 Jul 2019 12:29:54 -0700
Message-ID: <20190719192955.30462-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719192955.30462-1-rcampbell@nvidia.com>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563564612; bh=VRtcfh5WiSupUP5Y8ZWeqEYjlWzsti4A1ZaXu55dh6o=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=B+e5qGRXNq78hbYvK0jR2F1wmPW858/Up0dRZbJZpsibttglgzYKMDTaY5O0kkqDn
	 9XStOpiEipTaCyrs4/YYKvqn2ukRw1bC2K1taS/8pvAIiY5YV1wRR1eZoCnOQyd2Xm
	 m8p3EG0tNoc8Hi1wKkrvHwCYFl+s6QyG9NN5XoFPT1hOlps3WClf1HEndKYJynvkoB
	 7guzLd8DbBpE457bUieNeGtI+dYXN1BKmnMKX6qTVcztr8EfCgk3TDriLPmNtXcix9
	 kqzuQVVFUoTFFU3ejMuQmfd6x0wh8YqS+TGYByo/+1bsLybirEeYo7rFI7MX3Ad/Mz
	 DlD4XaHKKTrAw==
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
 kernel/memremap.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index bea6f887adad..98d04466dcde 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -408,6 +408,30 @@ void __put_devmap_managed_page(struct page *page)
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

