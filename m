Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 703E0C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27E8720828
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:48:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="VMDzn2N9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27E8720828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A17756B0274; Tue,  4 Jun 2019 15:48:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A1416B0276; Tue,  4 Jun 2019 15:48:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 868406B0277; Tue,  4 Jun 2019 15:48:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60A626B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 15:48:22 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 126so18038772ybw.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 12:48:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=dg2eFlce2wL8r6pAm2mCz7KFZbTnT7TbRCi0PP+rFvs=;
        b=dAXjQV8snh6Qn9yROwuxmW2OLi3LMM5f01Px/323ugFMLDFgJ4LAMtihLL7S4r0d+n
         iOgkrmqkMqMkxb+2eKciPek+Fs9PjsogLBHHBnKNrKdDffsEwQDuPQ2MuNelniu1l25N
         Fh8vFIE+OewyVU2eM1xfesxXw3qJG1+RTfZp/JjXku1IuT8fT47rzSZPqRoHR+SLyfdX
         1nI9gKZsMn2g/+i6Nlz1OZeseh/7TbZdot7f2rbiQcVu1f+Z4GN/Wf3zThCTE+AKQyy9
         7g6vcnA/uXBbsOMkSSe8ZCtTE+EZ70/gkjwSLrrRTcaV1N3didPcKigH12chAkcmp2/Q
         S2ZA==
X-Gm-Message-State: APjAAAUwzB2bpGw0bPsktxfr3SA0dBJzBop0v6MtwQ3J4ATfXE4a166Z
	nGxDl4+wLjPnlGMxDaIXB0fcDD6wTCqtEDEYeqM24t3EoJ3KgQeURz9vF83Jin3NeAoWdIkMRH7
	O2k1e2m8+fGLgQfKAZw7FHAL1psxBPg0PXK5lyutlLzqa9Nzce5oAWxA+u5WQ0lyUoA==
X-Received: by 2002:a25:b70c:: with SMTP id t12mr17241910ybj.67.1559677702127;
        Tue, 04 Jun 2019 12:48:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUeiohVKwWzG+ONkfaVDC5EmPMUUBXxIjjDBqMu36Sw+Yp/agY7uzczs+Iwf6L3lY+N1ix
X-Received: by 2002:a25:b70c:: with SMTP id t12mr17241885ybj.67.1559677701398;
        Tue, 04 Jun 2019 12:48:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559677701; cv=none;
        d=google.com; s=arc-20160816;
        b=N8xbk2Jd4ejNcQId55cKYvWcQzlHT8fxp+kol69+P6ArRw9IM8Q+QnlNSG6cICH0rM
         IXiiAkE8o2w5xm0TwFCvpHYxiJhH1HomEhi/fjoqCDj3D7C8bCCgr1KGm7sY+gBwpaRn
         DWPPF0DtG9yehDsWkcWtIHR4oOvoSP7DaXJmVQbtlKem45Ft3GojhIQu6AU3HU8zLKxp
         hduGpNGtbR5ckORLpBEPRFl4nSTJPNH9TGtc2xcCc/WWhcO8IRsJhNe+ra5Wk03YcFza
         1fA37bdgPKEhIBawOEyAkKW0RxMW66/TaVsWShhFbq7xwpB4WIcDBwN08IzJBCHNMa6X
         Rq2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=dg2eFlce2wL8r6pAm2mCz7KFZbTnT7TbRCi0PP+rFvs=;
        b=LQxcjfWzWtqRbTZT1S1Ujv3YgYfDhKNCUYnHdp42XrAdVaWzkZxdPeudoFVsva6kSV
         feRpTXnGZY65qATW6HnFVt8P7W/LRsaPB7JJ3Uq8Z6zXuvQFQboFBwdq1G4zh2Xv6IZD
         CGD46ulh/PGQQogz3adaMcOWGD0N3eTuRYZYMoV0rz1E+fvvwiZvusld8fAlScACNC2S
         GwQZ3RH8I05zWrECUAvh/bYzT5CWX/RZAQtxs9pTyhRmIGmDgqLMQWRbFstE8AI/q084
         H3l71Xq0RI/Xx/7rPdBvwAuDrffTBprlhHx6ge2Qhx+MBC14X2TuNVz5RZafjTHNPNs9
         W6vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VMDzn2N9;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s3si5757234ywe.176.2019.06.04.12.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 12:48:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VMDzn2N9;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf6cb010001>; Tue, 04 Jun 2019 12:48:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 04 Jun 2019 12:48:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 04 Jun 2019 12:48:20 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 4 Jun
 2019 19:48:18 +0000
Subject: Re: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap
 pages
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Dan Williams
	<dan.j.williams@intel.com>
References: <20190604164813.31514-1-ira.weiny@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
Date: Tue, 4 Jun 2019 12:48:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190604164813.31514-1-ira.weiny@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559677699; bh=dg2eFlce2wL8r6pAm2mCz7KFZbTnT7TbRCi0PP+rFvs=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=VMDzn2N9Weq9nF01e9HdN7Q2C346rS9JiNUOwA+2rSAJpSAXvmGPR/vS8o1biYWvF
	 xGEuSPqgs80J4f9vVflVazjnC0wcBvuqWR0qgknO1TRdcV3BZzdjdNHlCjmLZJNhe9
	 imzGKpC3YIU9VXkwh7QrxIeofG+RBt7v36HcTJjATu0jByxSqiGNRMNQd8JoOvHv9m
	 I2SdbTLcFf9HrtUSAmMTYkRGLTIWP8Z871c0ZeIIRfAIaxfjZO8O3PYKvs6zzqXpQ0
	 g5OYXGX6LsD9SY8f3PViEb295WoMoNHOisSnqx9lGFteU9gPdSIwV1tB+NBVo7/A/v
	 AIXuwp8vPWeMA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/4/19 9:48 AM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
>=20
> release_pages() is an optimized version of a loop around put_page().
> Unfortunately for devmap pages the logic is not entirely correct in
> release_pages().  This is because device pages can be more than type
> MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS
> DAX, and PCI P2PDMA.  Some of these have specific needs to "put" the
> page while others do not.
>=20
> This logic to handle any special needs is contained in
> put_devmap_managed_page().  Therefore all devmap pages should be
> processed by this function where we can contain the correct logic for a
> page put.
>=20
> Handle all device type pages within release_pages() by calling
> put_devmap_managed_page() on all devmap pages.  If
> put_devmap_managed_page() returns true the page has been put and we
> continue with the next page.  A false return of
> put_devmap_managed_page() means the page did not require special
> processing and should fall to "normal" processing.
>=20
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.[1]
>=20
> [1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.i=
ntel.com/
>=20
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
>=20
> ---
> Changes from V2:
> 	Update changelog for more clarity as requested by Michal
> 	Update comment WRT "failing" of put_devmap_managed_page()
>=20
> Changes from V1:
> 	Add comment clarifying that put_devmap_managed_page() can still
> 	fail.
> 	Add Reviewed-by tags.
>=20
>  mm/swap.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/swap.c b/mm/swap.c
> index 7ede3eddc12a..6d153ce4cb8c 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
>  		if (is_huge_zero_page(page))
>  			continue;
> =20
> -		/* Device public page can not be huge page */
> -		if (is_device_public_page(page)) {
> +		if (is_zone_device_page(page)) {
>  			if (locked_pgdat) {
>  				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
>  						       flags);
>  				locked_pgdat =3D NULL;
>  			}
> -			put_devmap_managed_page(page);
> -			continue;
> +			/*
> +			 * Not all zone-device-pages require special
> +			 * processing.  Those pages return 'false' from
> +			 * put_devmap_managed_page() expecting a call to
> +			 * put_page_testzero()
> +			 */

Just a documentation tweak: how about:=20

			/*
			 * ZONE_DEVICE pages that return 'false' from=20
			 * put_devmap_managed_page() do not require special=20
			 * processing, and instead, expect a call to=20
			 * put_page_testzero().
			 */


thanks,
--=20
John Hubbard
NVIDIA

> +			if (put_devmap_managed_page(page))
> +				continue;
>  		}
> =20
>  		page =3D compound_head(page);
>=20

