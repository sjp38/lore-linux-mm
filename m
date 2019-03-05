Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E97CCC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 23:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8303820661
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 23:51:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="nEk84GlD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8303820661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E45188E0003; Tue,  5 Mar 2019 18:51:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF3C98E0001; Tue,  5 Mar 2019 18:51:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE3078E0003; Tue,  5 Mar 2019 18:51:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F46F8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 18:51:37 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id e5so10277119pgc.16
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 15:51:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=qATl0olHTx+GwNgvJm69zDapss6pdR6QwqlMRQ/5Y5o=;
        b=Qyqn7XaEhmrmAHwI2f0gWEMkqSJmR7/EV5j49+SNsRpBH4hiuJfHDn2MaccxA/gF60
         ei+PyGGcOVT0SNuQkxLf2FfRqA2vLTbVBrlw7JYk7IZt8/KcvZpt3QLHg19vgjaV6aPe
         ZvC8shZ9qVZjWCwV+QHN4BbRXmQhIqQnRR7xksINF/sRbroD3kh8ZvRQAEJYJ+h6Bq7O
         Rg1qvKxOpBL+ltESb5yc2yka0vmTizAE2v0wRasYW9dwYK/OMo7Dtj1NZco0qG91eX+k
         gsQL+oP/rbactr+wAFrZSRH7p94T8qdQAXDd72IgkO+wJnQZcycXJSIzBHQb5zFGWdjh
         WaJw==
X-Gm-Message-State: APjAAAWZOrTvkvbkZ7W3gNLl80cNG1s3gUthUp/DURny/Ym2nYvHU2we
	bq37gwsAZZGxB+WOmwRufoN5fGXaL5rmULQt8nyDXv+EJTSqrIu7wKmG5TGu5ZC4RQjKCLVUYlv
	3OaifENg90CmkLcKHaRHvy7iMKQWTWwsir75/e74dVJqVBK8iwvOLXMpevoGnE5H9mg==
X-Received: by 2002:a63:234c:: with SMTP id u12mr3761793pgm.282.1551829897113;
        Tue, 05 Mar 2019 15:51:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqyEyoDJbl9b+RS6HdToopq9S3CUsJ2L+XkZGGLqTWGmcpV/ayY+w2OFHHHDCpGuh5eZntsm
X-Received: by 2002:a63:234c:: with SMTP id u12mr3761735pgm.282.1551829895765;
        Tue, 05 Mar 2019 15:51:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551829895; cv=none;
        d=google.com; s=arc-20160816;
        b=rF4RmrqwNoNg9wgKmVUTud6ECHm15tChHzN5DKxc2KnqcvRTgG4Ff7SO6MHuCLjAeb
         ewV/IDy2aCwR3M3eCc+2rVAd5JTFPska7MXGw0E+vTliHityygQzywcIfLLJBC5japht
         Jnr+3Dga8z2hJdHlrLG/QNkOYIVsv2eNgBB08kRN1rU4sxJ3DbTNJ0Rgew/HB/7HskG2
         rBfUoPnhryoahmF4leaAcAKu+OnGwQEo/eekGx1sjQIrcgRpS+3LMXaAHeXCAYwq5UeD
         vW7qJkYWSkAQkOdrQ+9KMizM8erTjhUEYA9EDONqaRSnD+wcO2GviycSwSJUz5Tgj3ye
         3uNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=qATl0olHTx+GwNgvJm69zDapss6pdR6QwqlMRQ/5Y5o=;
        b=NV03ng9tHn3bzbPPTrL3zBsayFddnVARTOaKoFRfL6u/WIgMq844UnXkHdKxiaBkbc
         xpvMJ/vadEYDZnB2GHSJ40rMKVk1eJWDiT9oPTgVh3h/tspWEKoU4tyhFdt3wbR9zzTg
         rM2YRq6EqBFvlHkgRUWhjhyIexLiKIpgaolky58U+zE1R3s3uZ29zw9LJwb5lyBICGf4
         p5cZltOMxTN2hTjKCUXn5RGCErm0D2FWrJ1gFCujUgaLfXeywq1qmeNWMyMgZh6liE1g
         +5SMFR53mqQl6z6aypVS2Jaqk/5SLoT/k4FHMiIwRYC2f9x+9AfDdIuH5kBUxhdQSJP4
         Slcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=nEk84GlD;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id w11si9411368plq.340.2019.03.05.15.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 15:51:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=nEk84GlD;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7f0b860001>; Tue, 05 Mar 2019 15:51:34 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Mar 2019 15:51:33 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Mar 2019 15:51:33 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 5 Mar
 2019 23:51:33 +0000
Subject: Re: [PATCH] mm/hmm: fix unused variable warnings
To: Arnd Bergmann <arnd@arndb.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell
	<rcampbell@nvidia.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Dan Williams
	<dan.j.williams@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
References: <20190304200026.1140281-1-arnd@arndb.de>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <bf509a99-604b-10a4-e71b-f4f8e61f00b3@nvidia.com>
Date: Tue, 5 Mar 2019 15:51:33 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190304200026.1140281-1-arnd@arndb.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551829894; bh=qATl0olHTx+GwNgvJm69zDapss6pdR6QwqlMRQ/5Y5o=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=nEk84GlD/4KXT+psnVGHU/VmqWSUd8S9zR4O0C9SM2Whkhra47krqLNU+IIFNkuE3
	 BSqfgnM6OkoKcJ6+0my5pBK75a1tIkTNswq141jxxmnPm+oxZsaiVV9ChpfMlh+mYM
	 k4yFBx5qRpB4acMjSo8v1t26mTk011AtREAJyG+UoUOYEvkoBx8X9/Bp400+5IKevx
	 iJUyZGrsu7/hltPoImvlE7BhGRLO7bok2pktSdDeW9INljMf6u7NiE/lk2Fl5qX7WV
	 II6wTairReiyCuv9T22j/42AITmpwJGDC8DqZOsg2Ixp8tKq0Dpf1GVVNswp8E3Cbf
	 5FoU3LOgy/mJQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/4/19 12:00 PM, Arnd Bergmann wrote:
> When CONFIG_HUGETLB_PAGE is disabled, the only use of the variable 'h'
> is compiled out, and the compiler thinks it is unnecessary:
>=20
> mm/hmm.c: In function 'hmm_range_snapshot':
> mm/hmm.c:1015:19: error: unused variable 'h' [-Werror=3Dunused-variable]
>     struct hstate *h =3D hstate_vma(vma);
>=20
> Rephrase the code to avoid the temporary variable instead, so the
> compiler stops warning.
>=20
> Fixes: 5409a90d4212 ("mm/hmm: support hugetlbfs (snapshotting, faulting a=
nd DMA mapping)")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/hmm.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 3c9781037918..c4beb1628cad 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1012,9 +1012,8 @@ long hmm_range_snapshot(struct hmm_range *range)
>  			return -EFAULT;
> =20
>  		if (is_vm_hugetlb_page(vma)) {
> -			struct hstate *h =3D hstate_vma(vma);
> -
> -			if (huge_page_shift(h) !=3D range->page_shift &&
> +			if (range->page_shift !=3D
> +				huge_page_shift(hstate_vma(vma)) &&
>  			    range->page_shift !=3D PAGE_SHIFT)
>  				return -EINVAL;
>  		} else {
> @@ -1115,9 +1114,8 @@ long hmm_range_fault(struct hmm_range *range, bool =
block)
>  			return -EFAULT;
> =20
>  		if (is_vm_hugetlb_page(vma)) {
> -			struct hstate *h =3D hstate_vma(vma);
> -
> -			if (huge_page_shift(h) !=3D range->page_shift &&
> +			if (range->page_shift !=3D
> +				huge_page_shift(hstate_vma(vma)) &&
>  			    range->page_shift !=3D PAGE_SHIFT)
>  				return -EINVAL;
>  		} else {
>=20

Hi Arnd,

With some Kconfig local hacks that removed all HUGE* support, while leaving
HMM enabled, I was able to reproduce your results, and also to verify the
fix. It also makes sense from reading it.

Also, I ran into one more warning as well:

mm/hmm.c: In function =E2=80=98hmm_vma_walk_pud=E2=80=99:
mm/hmm.c:764:25: warning: unused variable =E2=80=98vma=E2=80=99 [-Wunused-v=
ariable]
  struct vm_area_struct *vma =3D walk->vma;
                         ^~~

...which can be fixed like this:

diff --git a/mm/hmm.c b/mm/hmm.c
index c4beb1628cad..c1cbe82d12b5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -761,7 +761,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 {
        struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
        struct hmm_range *range =3D hmm_vma_walk->range;
-       struct vm_area_struct *vma =3D walk->vma;
        unsigned long addr =3D start, next;
        pmd_t *pmdp;
        pud_t pud;
@@ -807,7 +806,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
                return 0;
        }
=20
-       split_huge_pud(vma, pudp, addr);
+       split_huge_pud(walk->vma, pudp, addr);
        if (pud_none(*pudp))
                goto again;

...so maybe you'd like to fold that into your patch?



thanks,
--=20
John Hubbard
NVIDIA

