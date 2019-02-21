Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 671A2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:25:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EFF120855
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:25:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="I6tgQuog"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EFF120855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89A1E8E004D; Wed, 20 Feb 2019 19:25:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 849F68E0002; Wed, 20 Feb 2019 19:25:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739718E004D; Wed, 20 Feb 2019 19:25:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47A158E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:25:20 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id g19so16836570ybe.2
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:25:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=dFWrCIETKXjg1FNqFb1me5bCDn/NW3Z/3TsvBhl4xRU=;
        b=XCjssGqiypSBWJ43u125XNDV4/5jZzSVuWpXErnNhZsUbUKv4rJvTAKia0Tz4I5LOM
         Ve++mLhHBrN/4nXOOIoKVdC3GGIvEx2zfqvg+4PadlGaHuxswTa6bqrKpFips/RcDR4v
         +5kOv9QcweXRclEN1sz9lPEMH1Ef3sLmIaL45H+S59kijA0O5e5e52tjcfRriKRzIMVo
         ybFwZ+LdqdzhL/mAnbJw8BQsf6g119Wx/aAb0zXIrO8zHLdnBGGrvXnpdlnZyhodCo5C
         AOf3rI6GkVzKhRnzpM+JG1bLhckxD/AbFygxd0s1ECac1q6K6IAtmQl4z+ue+pih+L5M
         e87A==
X-Gm-Message-State: AHQUAuar5jXw2JVhyBeBVqVgjDKgxlumvkfwmerVT4LV43aWTNZUjpXz
	srg0mf8dhXzMMWvC6+IQbGxutrILF40gAh8uhzgnJEVbY9a98RWTqjUJptRcMVCRNlP8EczjDJv
	i3wK5fNTqBL4b5/T6W2cyE3/ehSLw687rrH6miK/rwK2D8SfeS0N3Zhof2uqFavenyw==
X-Received: by 2002:a5b:542:: with SMTP id r2mr32108277ybp.174.1550708719968;
        Wed, 20 Feb 2019 16:25:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjXidPzyN+G58epem/rHOC8g7jNvKViaD+H+1Cd1oefLX9O0qeTt6kL2PMJ9+ihaWyvXGX
X-Received: by 2002:a5b:542:: with SMTP id r2mr32108246ybp.174.1550708719251;
        Wed, 20 Feb 2019 16:25:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550708719; cv=none;
        d=google.com; s=arc-20160816;
        b=V6hIQ+MmZNg8J9nKSd64bu61QuHIhaPe3/QHmuCq4S/vW+TY/ERnrUMkQTT3NLfoLy
         fZAx30BAwekCIcY28aZvzMjvxSXDkC+jkGzUyjAuWsadi6vnVVQ639IwlHqdvj1Nnswx
         ecfZtIbW52XwDu/c+YSlo7vqXfBPYZxJ2LuA5mOB9CEd4h6XUgWlzBVFzpj99B+mG2Av
         PTgw7j8bhKlMci49lXYvIBukxp7KDA2SefMeIgkV1eT4Z+y8Y+1RmC8vgBARDt2E5ym6
         dK+CgBhWAyeApHBhxCHZypKJCVLlx7BlDuyHSUHZGMCnTDO4EpARDBJbxcFt0CzM4zMA
         cV5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=dFWrCIETKXjg1FNqFb1me5bCDn/NW3Z/3TsvBhl4xRU=;
        b=rk+sifFCm3ohm7es/JaTKWZIWY6d2c8LZq+cYVZ8BOsEWyIkyIO6oeQtohl+7/ZGHJ
         5DQ4o1I+J4w+abdNCWcQzW0RPvH7IPRYz7p5kmcYA3MPnaXhWj40J2LpDDyUpNmVO15g
         U1G9mKDKRW2MdDEezeAttVNc5DS6/8GiOO+wAwWnf6POM3lE9/1UFbSrV3nEIqgTbXOp
         M6nW0y18rKw1UGeRgYiJgJHy1z6Yb+fqNzbNkDoSbN1LuwyOwcozoz+3WxOgp1tdkevS
         MeSK6W8mCpgx9aUIzWmWDN8QuHL7HgAbZD6u0XdA5WWFDnE4seuSyZ8u/Ou/LWmop6Ai
         KPaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I6tgQuog;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id p81si12376871ywp.149.2019.02.20.16.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:25:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I6tgQuog;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6deff40000>; Wed, 20 Feb 2019 16:25:24 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 16:25:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 16:25:18 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 21 Feb
 2019 00:25:17 +0000
Subject: Re: [PATCH 03/10] mm/hmm: improve and rename hmm_vma_get_pfns() to
 hmm_range_snapshot()
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-4-jglisse@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <cc2d909c-37c6-4239-7755-4383a8eca0df@nvidia.com>
Date: Wed, 20 Feb 2019 16:25:07 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-4-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550708724; bh=dFWrCIETKXjg1FNqFb1me5bCDn/NW3Z/3TsvBhl4xRU=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=I6tgQuog86qv6gu1dhnEdEk72Zm7NdftP96EfqGPweBvT2ZUu31lvTrE6mpAj2CeU
	 lJNcCeXEtXq5OvEdGjKH3Bb/Bsf2JTGPDQyQONBhJaKYOyB/jeDQkFaQr9e6d4q6Z7
	 Pr6P3iDGF5ALPBiard7zbm7SlHWArESTa/lntDBqxSQyGr6JScpdcGtDj47E3YXsSu
	 xAP1iDj84rART96QHRN+EfzXH4oNGPfo4HqyWhrZ8C9FE8lUZV6kzc5wcFDB6nLTWW
	 ZaoK4pBYw77SrwAguTS83eIJjkcQod+vtV9mR5K3tADcokFTAL7+K09uAcMTOQMNtw
	 twK/pe5LbPkOQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Rename for consistency between code, comments and documentation. Also
> improves the comments on all the possible returns values. Improve the
> function by returning the number of populated entries in pfns array.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>   include/linux/hmm.h |  4 ++--
>   mm/hmm.c            | 23 ++++++++++-------------
>   2 files changed, 12 insertions(+), 15 deletions(-)
>=20

Hi Jerome,

After applying the entire patchset, I still see a few hits of the old name,
in Documentation:

$ git grep -n hmm_vma_get_pfns
Documentation/vm/hmm.rst:192:  int hmm_vma_get_pfns(struct vm_area_struct *=
vma,
Documentation/vm/hmm.rst:205:The first one (hmm_vma_get_pfns()) will only f=
etch=20
present CPU page table
Documentation/vm/hmm.rst:224:      ret =3D hmm_vma_get_pfns(vma, &range, st=
art,=20
end, pfns);
include/linux/hmm.h:145: * HMM pfn value returned by hmm_vma_get_pfns() or=
=20
hmm_vma_fault() will be:


> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index bd6e058597a6..ddf49c1b1f5e 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -365,11 +365,11 @@ void hmm_mirror_unregister(struct hmm_mirror *mirro=
r);
>    * table invalidation serializes on it.
>    *
>    * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU =
CALL
> - * hmm_vma_get_pfns() WITHOUT ERROR !
> + * hmm_range_snapshot() WITHOUT ERROR !
>    *
>    * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE IN=
VALID !
>    */
> -int hmm_vma_get_pfns(struct hmm_range *range);
> +long hmm_range_snapshot(struct hmm_range *range);
>   bool hmm_vma_range_done(struct hmm_range *range);
>  =20
>  =20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 74d69812d6be..0d9ecd3337e5 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -706,23 +706,19 @@ static void hmm_pfns_special(struct hmm_range *rang=
e)
>   }
>  =20
>   /*
> - * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual a=
ddresses
> - * @range: range being snapshotted
> + * hmm_range_snapshot() - snapshot CPU page table for a range
> + * @range: range
>    * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM =
invalid

Channeling Mike Rapoport, that should be @Return: instead of Returns: , but=
...


> - *          vma permission, 0 success
> + *          permission (for instance asking for write and range is read =
only),
> + *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no =
valid
> + *          vma or it is illegal to access that range), number of valid =
pages
> + *          in range->pfns[] (from range start address).

...actually, that's a little hard to spot that we're returning number of va=
lid=20
pages. How about:

  * @Returns: number of valid pages in range->pfns[] (from range start
  *           address). This may be zero. If the return value is negative,
  *           then one of the following values may be returned:
  *
  *           -EINVAL  range->invalid is set, or range->start or range->end
  *                    are not valid.
  *           -EPERM   For example, asking for write, when the range is
  *      	      read-only
  *           -EAGAIN  Caller needs to retry
  *           -EFAULT  Either no valid vma exists for this range, or it is
  *                    illegal to access the range

(caution: my white space might be wrong with respect to tabs)

>    *
>    * This snapshots the CPU page table for a range of virtual addresses. =
Snapshot
>    * validity is tracked by range struct. See hmm_vma_range_done() for fu=
rther
>    * information.
> - *
> - * The range struct is initialized here. It tracks the CPU page table, b=
ut only
> - * if the function returns success (0), in which case the caller must th=
en call
> - * hmm_vma_range_done() to stop CPU page table update tracking on this r=
ange.
> - *
> - * NOT CALLING hmm_vma_range_done() IF FUNCTION RETURNS 0 WILL LEAD TO S=
ERIOUS
> - * MEMORY CORRUPTION ! YOU HAVE BEEN WARNED !
>    */
> -int hmm_vma_get_pfns(struct hmm_range *range)
> +long hmm_range_snapshot(struct hmm_range *range)
>   {
>   	struct vm_area_struct *vma =3D range->vma;
>   	struct hmm_vma_walk hmm_vma_walk;
> @@ -776,6 +772,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>   	hmm_vma_walk.fault =3D false;
>   	hmm_vma_walk.range =3D range;
>   	mm_walk.private =3D &hmm_vma_walk;
> +	hmm_vma_walk.last =3D range->start;
>  =20
>   	mm_walk.vma =3D vma;
>   	mm_walk.mm =3D vma->vm_mm;
> @@ -792,9 +789,9 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>   	 * function return 0).
>   	 */
>   	range->hmm =3D hmm;
> -	return 0;
> +	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>   }
> -EXPORT_SYMBOL(hmm_vma_get_pfns);
> +EXPORT_SYMBOL(hmm_range_snapshot);
>  =20
>   /*
>    * hmm_vma_range_done() - stop tracking change to CPU page table over a=
 range
>=20

Otherwise, looks good.

thanks,
--=20
John Hubbard
NVIDIA

