Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2835C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:45:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A5B62184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:45:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="M3SU/d2c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A5B62184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39FE76B0005; Fri, 19 Jul 2019 17:45:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350436B0006; Fri, 19 Jul 2019 17:45:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23E628E0001; Fri, 19 Jul 2019 17:45:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0015D6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:45:12 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id e71so19308453ybh.21
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:45:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=EWMnpOanoTl9uOzSae5VUG9sJSSMfpgHu1hrHwdel1M=;
        b=HFs9lL/D5UzfFYDksuFwFwdAOYsSL3ZiEE+tlSciXN3oJFqs45ow+NQGeDKUnjNXLy
         YGrtNV5AgR5NygA1pr8Su8BIhKUU8qkWAuNnXZWkdUNusLePiNNC+2ORlXw7ZXftq9SP
         lLKt4Erp5djv9UOWTt3i5d9twj3vB8NLmH+3Mc31m0EQKloFfHFKNkQxDWArCEK1zd4f
         3qOZyqFNTyf/Op/GA6KHoYLcFzJ1C9wl9YyOtrdw6j4gLN7QK/NMjkpZNKDI0eG5vT4i
         38PuRf9e20frae65P1Z6eJYbO5caGptWOIXcsXdd2LyvvnUrosHygdEQhB5aui8NHZMc
         quGw==
X-Gm-Message-State: APjAAAXEbGP7Yt4vdlB0arJAHrgDxKtOQhFJQgRKIDmmHOovq/NgbHeI
	x6Xe5ZLhxd4YTVCXUhqxWQXPGKe2Ia1/gaPqz9Jqno3u4E8Ts6uPhxl/+alfkXIDob2k3xEvid0
	cR2v95dmkC+z3pPPDIKJgKyyqsS/GM7LDxPFGkFqFNHZ3a87m59zVRfPCY3bzDKWq5w==
X-Received: by 2002:a81:37c7:: with SMTP id e190mr32484236ywa.144.1563572712769;
        Fri, 19 Jul 2019 14:45:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzglKogDvGvFIKWvDFiv9ChGYvTdchL3e5q5JkEILk6uMT/B9gER+gMzsSUCJojJTp27JL6
X-Received: by 2002:a81:37c7:: with SMTP id e190mr32484196ywa.144.1563572711895;
        Fri, 19 Jul 2019 14:45:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563572711; cv=none;
        d=google.com; s=arc-20160816;
        b=cDt+lSzu8vnC37BcKErDA1HQBLRVDLrSsZR7MClAiFOkz6Bfsrj1syvXRaG70yaWLa
         IXrFyXRcbU1XmKvH9fSTddOrm+e1akjIJbxfjRl9t4lIF+z5KisI90PqtSUQdAx4Udh/
         BE8draG9RvFiN+Ipi6JQkvlTG1SPy1Lidt7oHkWCmmsNrK4T83kqTN5JssOUQb9PcXG4
         En8bsOwWY3gnAVqnLZZfTbhvMCnu7Lkbbju3TZfaqIW1Byg9kNCZr1I1bLW1QB5t/NhZ
         d8aq5XQk7WYOR4+T8e2uTbV30DZB9E7SBuE99yku91e9fSA4rJ+sKk516F46iG0yy+Gc
         jNAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=EWMnpOanoTl9uOzSae5VUG9sJSSMfpgHu1hrHwdel1M=;
        b=k+vRurQmqo/AgGPnSGPfiSaENPQJkyvSZE7sbUWwasphPuGrROHJqeXcHM/zWH2jya
         3WImiQc6AcSYFEcGBgHPFFxd61tyargIyJUhZpoZHik68qVP6Dnd8mPW2cf5MMsj8H+I
         /t98rqoYSYzARs8P0Uj/rWQIULiOYyV/rOCMtBy+Cx3VvHaV9T6EfCiC+5qbl05ZRHG7
         JvdcONFgk7vriQg+rR1whqX6dusvALu1GRXSpert5HNdnVefru86uXjh4fem0ic8X5m3
         47CzmpI8tSlXETYq1iqcHWbU4twr6Ns3QhGfpODBrVZ7a0y8FLZHB7BEYVFjXQOz0qcS
         51Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="M3SU/d2c";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 129si6955152ybb.144.2019.07.19.14.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:45:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="M3SU/d2c";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3239e60001>; Fri, 19 Jul 2019 14:45:10 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 14:45:10 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 14:45:10 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 21:45:08 +0000
Subject: Re: [PATCH v2 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
To: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>, "Christoph
 Hellwig" <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Jason Gunthorpe <jgg@mellanox.com>, "Logan
 Gunthorpe" <logang@deltatee.com>, Ira Weiny <ira.weiny@intel.com>, "Matthew
 Wilcox" <willy@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, "Jan
 Kara" <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Mike
 Kravetz" <mike.kravetz@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-3-rcampbell@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <5089cfa6-ba0c-efa8-6beb-6fb1881a57d4@nvidia.com>
Date: Fri, 19 Jul 2019 14:45:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190719192955.30462-3-rcampbell@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563572710; bh=EWMnpOanoTl9uOzSae5VUG9sJSSMfpgHu1hrHwdel1M=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=M3SU/d2cFHqeccbTX1WD+vjc0xuq2ALlX2QJVf5/Rs78JLBNyYft0uB6XGsFEMELg
	 EC3AIY3dhOAsmz/SlrI6BIkahQcfFSb32/kPwBUOhNxYwstDwhPHekaV7PLWs54x2P
	 A4zlnYYgc8fEJrnm+pUHwrAkBEzJqdltcWOYeQKu2rVRgFYx8GrmPh+ZQ9LNyQlgf8
	 y9iyaJJ5IzDwrSOsjdNyoKNKHpmEmGMHCiBeLc5lxhZt9X7xLmy3O69AVKYNLviqBN
	 9oWB2Tg3BKBF54n+TNpPp9luglQQm34rmXs9R6dt+zuj7Sf41rPQpKIIK+hwWnPj2K
	 2JhUTREHJ8Vyw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 12:29 PM, Ralph Campbell wrote:
> When a ZONE_DEVICE private page is freed, the page->mapping field can be
> set. If this page is reused as an anonymous page, the previous value can
> prevent the page from being inserted into the CPU's anon rmap table.
> For example, when migrating a pte_none() page to device memory:
>   migrate_vma(ops, vma, start, end, src, dst, private)
>     migrate_vma_collect()
>       src[] =3D MIGRATE_PFN_MIGRATE
>     migrate_vma_prepare()
>       /* no page to lock or isolate so OK */
>     migrate_vma_unmap()
>       /* no page to unmap so OK */
>     ops->alloc_and_copy()
>       /* driver allocates ZONE_DEVICE page for dst[] */
>     migrate_vma_pages()
>       migrate_vma_insert_page()
>         page_add_new_anon_rmap()
>           __page_set_anon_rmap()
>             /* This check sees the page's stale mapping field */
>             if (PageAnon(page))
>               return
>             /* page->mapping is not updated */
>=20
> The result is that the migration appears to succeed but a subsequent CPU
> fault will be unable to migrate the page back to system memory or worse.
>=20
> Clear the page->mapping field when freeing the ZONE_DEVICE page so stale
> pointer data doesn't affect future page use.

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Fixes: b7a523109fb5c9d2d6dd ("mm: don't clear ->mapping in hmm_devmem_fre=
e")
> Cc: stable@vger.kernel.org
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jan Kara <jack@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> ---
>  kernel/memremap.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>=20
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index bea6f887adad..98d04466dcde 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -408,6 +408,30 @@ void __put_devmap_managed_page(struct page *page)
> =20
>  		mem_cgroup_uncharge(page);
> =20
> +		/*
> +		 * When a device_private page is freed, the page->mapping field
> +		 * may still contain a (stale) mapping value. For example, the
> +		 * lower bits of page->mapping may still identify the page as
> +		 * an anonymous page. Ultimately, this entire field is just
> +		 * stale and wrong, and it will cause errors if not cleared.
> +		 * One example is:
> +		 *
> +		 *  migrate_vma_pages()
> +		 *    migrate_vma_insert_page()
> +		 *      page_add_new_anon_rmap()
> +		 *        __page_set_anon_rmap()
> +		 *          ...checks page->mapping, via PageAnon(page) call,
> +		 *            and incorrectly concludes that the page is an
> +		 *            anonymous page. Therefore, it incorrectly,
> +		 *            silently fails to set up the new anon rmap.
> +		 *
> +		 * For other types of ZONE_DEVICE pages, migration is either
> +		 * handled differently or not done at all, so there is no need
> +		 * to clear page->mapping.
> +		 */
> +		if (is_device_private_page(page))
> +			page->mapping =3D NULL;
> +
>  		page->pgmap->ops->page_free(page);
>  	} else if (!count)
>  		__put_page(page);
>=20

