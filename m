Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C44C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1096620818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:51:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="AIh90U/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1096620818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E7D66B0006; Tue, 16 Jul 2019 21:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9981C6B0008; Tue, 16 Jul 2019 21:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887B68E0001; Tue, 16 Jul 2019 21:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68AD46B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:51:15 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id t18so18315679ybp.13
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=1dmjq+OnPGvrHvEejwkg5+2298h2fZxzldWUuZPTtbI=;
        b=VWBF3iMZixehGUahn4WTTuXFWFfbE1h6sKKjhrs/fQ89hmuncJvYUVJBMisGNAfAnT
         2xi8s/C//O76d5hCJI96iXngZPOJZ0e2mjZA8M5kBla7b2ahGt5xSgRJbqXkfnchbkNa
         wIYoUxb+/EuMGAFZxXNdbLldlkfNUWD9nhSaE04XLb90c7Q9IYrenvAI5pep334E7gr9
         52gGBzrzmCgGYHqHdq9RtS3L/6uSizjlKjR02o6LblWyLBSEikk9Xr/eVOL7Tt44ngeI
         5feiDdUUpLB+5/9VwVy68Z/pOB8N1rrxrFgVn43HPH2fjnSVFKlJZqDUiE8ikeLXX/s6
         KN3g==
X-Gm-Message-State: APjAAAVBNBl1o45gz21v1ahqX+EZi2GEpgXcpWvU2keBzMPz6PgDdCUo
	dEsK6/P61eifwtr/4q3RT1P1GAXxTaLzlrnFIEav/eaXsXJdbedWpSYbJtVgOufUInergfoMrtr
	aJ3dPwthi7til1o5QherkDJMJubwnWzEa1ZjXwbe7a+OlxIED7TrR18QZmAoiDIq60w==
X-Received: by 2002:a81:1bcb:: with SMTP id b194mr22235855ywb.321.1563328275120;
        Tue, 16 Jul 2019 18:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIrTr2Yi+N5Zc5G+iBGnk57/0d8wdb9BISQ0c7YpCEaOLOGXZH+G+bf1BRI0yfEwVCcc+h
X-Received: by 2002:a81:1bcb:: with SMTP id b194mr22235835ywb.321.1563328274518;
        Tue, 16 Jul 2019 18:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563328274; cv=none;
        d=google.com; s=arc-20160816;
        b=ondDRwgp4xc/HglHJk2OtJJi2JrlbDGoAsOOPvxTRtnv/lZhQd+ViKHfl1cAgm4tfC
         BX2j5vCKtSI7VT+UQHTxBRXUcbUGH0TrxDWc6wVNOufjKU3ok8DIZ85tNPazZnmfaV2t
         DBUtHbDTY34jXnLGiB5xbnCHS5qN34OxN6jUqVyYngghkCNSqw4u4+Fv6g57ZtR8JYIZ
         NduDssOLJl9ExDyORZzIZClwtpcUFUDRN0OMzto4h1ljdMVpUdHtp+rlQQu55iIVYqg1
         9CdFgLuTcLQEUl0VWOH5i3HCyiVFPnshqpVyO2NH7m4eigsVT6Qn/EP1gHrdUm1y4zA3
         fjng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=1dmjq+OnPGvrHvEejwkg5+2298h2fZxzldWUuZPTtbI=;
        b=NvNtEXJZwWilkFGAYA+VQH0eopiRZbR67PCeD5etxjSBUicnaWu8P4kdztqXvuq2/c
         njILXbrF8VVEVX/nex5Y7Xdr3PGTBmm3tn6sXjSJvvZO9pyGNB66m6KsULBQzeQnmkOX
         0gbETPmagtg4oxk0vqNcndDJoKL6lpTPmmpaHCeWT15XyZAOMXPh1I8jt3GoxI5wirdY
         mlStHlIu+PoQtbFNz/9PKBOFeJOXlQke7ziTdQr4smmWkHXrBqnXTWqLN3vu/dVt24zF
         C6NbzxPvLFruW9RKxQYXWV/JO6lpxPG/uN8fpXb5dNxE6jvYROIkCSEFAaPLCz8l3a9T
         uanw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="AIh90U/C";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 80si8105044ywp.322.2019.07.16.18.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 18:51:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="AIh90U/C";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e7f170000>; Tue, 16 Jul 2019 18:51:19 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 18:51:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Jul 2019 18:51:13 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 01:51:11 +0000
Subject: Re: [PATCH 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
To: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>, Christoph Hellwig <hch@lst.de>, Jason
 Gunthorpe <jgg@mellanox.com>, <stable@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
 <20190717001446.12351-4-rcampbell@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <67107cc6-cc8a-c072-a323-b5c417fb45c6@nvidia.com>
Date: Tue, 16 Jul 2019 18:51:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717001446.12351-4-rcampbell@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563328279; bh=1dmjq+OnPGvrHvEejwkg5+2298h2fZxzldWUuZPTtbI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=AIh90U/Cm54D0y3Ou8lNAM1j8ozgoxqDzEIxoGg959X3ZDt/Gxbu0DLmQZjTpiPT3
	 k0E4lrszsGcs4DXpbafUoCk0Tvr1JFCUh3CZ9+tmc1Pe9C7eW3+7L6m3TnM6zAoOOO
	 uEW7HREvelwp9GSn7pMHEEYUvqSF5SL6ERgDBFqfOL5pI5l6ukeW8cmk2EOojUvVyW
	 8HQDwvUHMa7xudjZMCkqEhRWCYTYCfWG1qPhlloRFCHHYVkNTRwrsQFxObgdrwQj01
	 p9dtBgaPXQTk98EdNnY0m2+msq9M+krIEk6rKhqu9u/2MdjgnvwvxMKLi30pjZ3JBp
	 kklI/IdXiI2ug==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 5:14 PM, Ralph Campbell wrote:
> When migrating an anonymous private page to a ZONE_DEVICE private page,
> the source page->mapping and page->index fields are copied to the
> destination ZONE_DEVICE struct page and the page_mapcount() is increased.
> This is so rmap_walk() can be used to unmap and migrate the page back to
> system memory. However, try_to_unmap_one() computes the subpage pointer
> from a swap pte which computes an invalid page pointer and a kernel panic
> results such as:
>=20
> BUG: unable to handle page fault for address: ffffea1fffffffc8
>=20
> Currently, only single pages can be migrated to device private memory so
> no subpage computation is needed and it can be set to "page".
>=20
> Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE pa=
ge in migration")
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/rmap.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2ae6b0d..ec1af8b60423 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  			 * No need to invalidate here it will synchronize on
>  			 * against the special swap migration pte.
>  			 */
> +			subpage =3D page;
>  			goto discard;
>  		}

The problem is clear, but the solution still leaves the code ever so slight=
ly
more confusing, and it was already pretty difficult to begin with.

I still hold out hope for some comment documentation at least, and maybe
even just removing the subpage variable (as Jerome mentioned, offline) as
well.

Jerome?


thanks,
--=20
John Hubbard
NVIDIA

