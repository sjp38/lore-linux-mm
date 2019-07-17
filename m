Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 942E4C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F3EC20818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:40:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NMQ9OBew"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F3EC20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C883C6B0006; Tue, 16 Jul 2019 21:40:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C385D6B0008; Tue, 16 Jul 2019 21:40:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFFD48E0001; Tue, 16 Jul 2019 21:40:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5DB6B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:40:18 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i73so17610934ywa.18
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:40:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=4zW6WMS58NKwkK2EYGU0erGO3LAau6AlIU4w5xeRscI=;
        b=lI0yEiDokGLDMZEq072gv5MSijPEChkCc/dPReb3Be/B/OCAXQEdZQz+cFTWTOXYv8
         JU12IzZIXdLrqGTijPiSDux/kVuYeZ6TC5TY3jzNCVR1f3gy0wqO6EBN9PTZUMSOdbOZ
         KTK5Ofi7KJDRqNi/4LR7Pc4GHAxbn+tcYlkM28LS7YaxhrGekZL4xonvevpT7N3qIFUY
         4UXErO8KnzkzaET+Cilwvos1EneVkT1NNxpOpMa7XazQaTARKBPedfaViK3F7p3pCXhC
         RUOX92WU0OPpsMFBKe5PzzuEGBhSOBihUXiWUEmtqMJbM9iTdqgQF19VTCtBCKErHr+9
         Pmqw==
X-Gm-Message-State: APjAAAVajL0ctRBQlGE+goQ3vzxrW3uemV0+4CBrOzHtG2SokCIvAceF
	Zkv8HFTgv8I2aU6NNBrWFi5W2Ypq71cp35fztuy/YjIPo0UH/dETHn8IAJOkktJ6ei/z+iUGyl4
	sCA86FXOMwfxgTxHOISmVCe15VAHgJL1DLI3lyuTZl+qgAfLiLaDv0miU15YlG2VMbg==
X-Received: by 2002:a25:9305:: with SMTP id f5mr14534093ybo.520.1563327618217;
        Tue, 16 Jul 2019 18:40:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZUM6Wyq/S+NW+VIi+WJ7rbIzDxTj3nJJuq1LFhjgtBL8KRad0iWQdIxNPtmcKykS8td0p
X-Received: by 2002:a25:9305:: with SMTP id f5mr14534075ybo.520.1563327617246;
        Tue, 16 Jul 2019 18:40:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563327617; cv=none;
        d=google.com; s=arc-20160816;
        b=p4dy9nB9pdJgZipxKWlS/zad4AEhHmlk3NFTNN0iyH0PY/s9G7QFcZaXIxUbx6h2A2
         Po5yajmXbJ/3d201Ht0zOTDu160dOpkchFVu1EvKIbsTELkys15U127bkezmM0Kfwxgo
         sLdMSRjseLXdpg2U6nHajtTe7CBQ5Dw0eplhvsJlQQX5v7BrSFQN12Ia2nMOJtuUOeJ1
         fc+qs7+sF9oy0pL/Mn99lh/DmoC6Ks1E1qpBzzOJfnrIpxw2bn9cSGhz7Kh+Xu5cNkOt
         UzoPonA6sMuyUYpUcmLThmkDct4/WgXSrNHWeUbeEOJ6T7J/a3/PcfPKDChiII5gCIOe
         glRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=4zW6WMS58NKwkK2EYGU0erGO3LAau6AlIU4w5xeRscI=;
        b=QSpC/eJ/V1KWKLJZxa1+Tlf4uVYIYpB/jULhV7RZQQwx9kPVkCfrdxya014kWYuLMk
         NDgzON33yV70He2GvQ0rNuHZOdfCcaEFZn7affXP3uQMow/5ylgloEFuQwt1dmn86A+M
         qckh6hzgaTO0faeD6SYvbyxswfooOPMXePb2+NwsQnoJ5aOfN6gCACZq341RzVXcdL1v
         V5ZcNDv7S+EtA5Fqk9efTqvZOBjT6rWzvjMxys0cw/aoEmFyjV9Phz4aWwF2SOlawmdK
         1ZxRhvClfqp7WcBzoGMoYIfP/f63zNbyqVmLJZZ+aOGJdE/ZForD872z9+uaqhDmbyTJ
         DJng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NMQ9OBew;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r126si8131168yba.165.2019.07.16.18.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 18:40:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NMQ9OBew;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e7c7b0000>; Tue, 16 Jul 2019 18:40:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 18:40:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Jul 2019 18:40:13 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 01:40:09 +0000
Subject: Re: [PATCH 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
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
References: <20190717001446.12351-1-rcampbell@nvidia.com>
 <20190717001446.12351-3-rcampbell@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ebd1ea66-f8c0-7a03-594c-dce9ec4d0fa6@nvidia.com>
Date: Tue, 16 Jul 2019 18:40:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717001446.12351-3-rcampbell@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563327611; bh=4zW6WMS58NKwkK2EYGU0erGO3LAau6AlIU4w5xeRscI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NMQ9OBewREnnGi+MzFdTbeISiClUuUw26DewOW2/gLvttzLKSC1XGFYxlpGNrQX76
	 VKZ6sM2Vrn3hs4a/KqcMLLarvtE7n9bdVrc/pixmxjDDxNbLYX+yP1MKKbW3j3MhJD
	 EAElXQgWL2H1BcX1fP8k557RCIcWIJXff0FLDHEIV/d6O2SXxB3AnwPgo3z7T34t1Q
	 aDnlxp0eegoOosDedPH/as6UFkO61/whGbcnxvOiTJkKqDKnc2NuJXMUcpffcJOE93
	 F5/9V7Uq09XAxJeIcx82qR198xvNbwe4WkoAQeESsy2JsDBAPvvrZu+Q1vIE1+IGqN
	 2TRvEOS/JW3gw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 5:14 PM, Ralph Campbell wrote:
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
>  kernel/memremap.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index bea6f887adad..238ae5d0ae8a 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -408,6 +408,10 @@ void __put_devmap_managed_page(struct page *page)
> =20
>  		mem_cgroup_uncharge(page);
> =20
> +		/* Clear anonymous page mapping to prevent stale pointers */

This is sufficiently complex, that some concise form of the documentation
that you've put in the commit description, needs to also exist right here, =
as
a comment.=20

How's this read:

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 238ae5d0ae8a..e52e9da5d0a7 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -408,7 +408,27 @@ void __put_devmap_managed_page(struct page *page)
=20
                mem_cgroup_uncharge(page);
=20
-               /* Clear anonymous page mapping to prevent stale pointers *=
/
+               /*
+                * When a device_private page is freed, the page->mapping f=
ield
+                * may still contain a (stale) mapping value. For example, =
the
+                * lower bits of page->mapping may still identify the page =
an an
+                * anonymous page. Ultimately, this entire field is just st=
ale
+                * and wrong, and it will cause errors if not cleared. One
+                * example is:
+                *
+                *  migrate_vma_pages()
+                *    migrate_vma_insert_page()
+                *      page_add_new_anon_rmap()
+                *        __page_set_anon_rmap()
+                *          ...checks page->mapping, via PageAnon(page) cal=
l,
+                *            and incorrectly concludes that the page is an
+                *            anonymous page. Therefore, it incorrectly,
+                *            silently fails to set up the new anon rmap.
+                *
+                * For other types of ZONE_DEVICE pages, migration is eithe=
r
+                * handled differently or not done at all, so there is no n=
eed
+                * to clear page->mapping.
+                */
                if (is_device_private_page(page))
                        page->mapping =3D NULL;
=20
?

thanks,
--=20
John Hubbard
NVIDIA

