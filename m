Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 487ACC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A622184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:59:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="cI2sZWCF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A622184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 836496B027B; Thu, 28 Mar 2019 17:59:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E5BE6B027C; Thu, 28 Mar 2019 17:59:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5B46B027E; Thu, 28 Mar 2019 17:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 386276B027B
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:59:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so164101pgs.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=NNa4/s5RLr8tBsJiCFnRZr38vKbxE2ngsDs1pGWjIlg=;
        b=kZ5yEyUf7UT2rm1uz68SlaOG+dn+7rBmWntaHqk7ZPL5yA25uekUpDL1EdRSxKKUfJ
         dJOtb1OCFIGDHGBxjAify3l/08UELApTzhnRKRYM5Fuu680m49hmOcfLmnOoydi+94HF
         C8j5ngMtGs9vQEJMhOvMlyRFIwpIqvLXLqsTjoja7lthy0llU5t1a8WR8qSxiS1JI3x4
         VV+7OYFNZNOTWFyDMG+HYdfZEeCqpuYnz93IShDdcaOjCF+mYq5/ALL7kXnLRV4l+SSW
         +YAzb0jCsnA8ZU3QVVqV8kVvNCSPUstTd9eCz/a2gR2t2MBOUhFafbUEKo/mKn3ll27T
         Ly+g==
X-Gm-Message-State: APjAAAV9t6Bvp6Vj4/m+xES0mCLT2kScJQ8JmXd3JWuFr5KgSZad+/el
	KcaDslk0BzJbQ7LqAD8c2hpIKPjSNe8vH6i5x/ma4GP6aW0swisVuYGkCXkVvrMd+2H2TJCsTq1
	rQQWTl77dCKbTweepI370/SUGDAqwc6kRggk6MuwYVXj/ZzExWQOtyoOk6hChb0JUAQ==
X-Received: by 2002:a63:d84b:: with SMTP id k11mr42033259pgj.281.1553810392807;
        Thu, 28 Mar 2019 14:59:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUAeErFe8nrAfuQki48d0OIqOU0ZUp7oWWBUdPbkXNzo4m+TH0MozvwkcsvNn/g+GnjB50
X-Received: by 2002:a63:d84b:: with SMTP id k11mr42033197pgj.281.1553810391904;
        Thu, 28 Mar 2019 14:59:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810391; cv=none;
        d=google.com; s=arc-20160816;
        b=aKJEF/j2IMgfJ7RpwbeAMMCRRRpzzNgDAEJwFEm738DV5QB7pRutti77fy3C6lkwbx
         I6RYoU/YvnQjad8GqnYGGkrPrTe1XcfmGq2/g4mXZyv2b65FG2rOgvn0cs1kYLm6nTvv
         xg0c2FpmTouqyt2NIiNLSRzGEWZQWCzDRvcMM/xvBZhJc2ov9yc9GeSIXY9iIPn5x1od
         JoveKDbnt0Myi+JCLguoHJoAT3exvQzpQX+TiMwhWQ8WFoJMZS5uvaHNzUAy93+RfoTA
         vUJ5Ul77KSVHOsGex0/RZEZ1iow8GBLX6x+/sJftMkyRBU9HNAhyZ0cCoL0+E0u4KPzx
         W7+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=NNa4/s5RLr8tBsJiCFnRZr38vKbxE2ngsDs1pGWjIlg=;
        b=Dy4A6jwrzPcy4CCspO0p1lHccVzceTAiSPD9IPjs3bHz6quWWI8RbMMy5rkDfceum9
         zaWGS01qFrnsKeP1CWZB2mtnGfRIOdvRiOvOc6TB5FWvgRYc7+ZIsY+/yUWnZV0KPpd6
         HbK9QcrXvbsagqDbAeeUZ1rK+JoTktxNPL4lz+eUYYij13lVs+1cC8XBzJkV/dlM+YEl
         rG8uSrwlLd9voZMtwnwPpBfMPvMIWuTt8E4o5kwLx1jVF3wBF6MM6fSVwpBG/0OKb0hl
         ruPE928M+GlKNWBqgD8xt/MU6Qn4e7E2hU+jzC6NNwRag+jVCvF9NaU2/eT2G9+/WAxD
         r0sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cI2sZWCF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id t8si239276pgp.174.2019.03.28.14.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:59:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cI2sZWCF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d43da0001>; Thu, 28 Mar 2019 14:59:54 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 14:59:51 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 14:59:51 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 21:59:50 +0000
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
Date: Thu, 28 Mar 2019 14:59:50 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190325144011.10560-8-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553810394; bh=NNa4/s5RLr8tBsJiCFnRZr38vKbxE2ngsDs1pGWjIlg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=cI2sZWCF4+YGKEOgcJkUT3mkH1Jc5Nyt+uoIoHzVIKMZ4xb84m+F0wvL7eWW4AybC
	 E+Vg/fKOCOUCvOAIJsRZ4ErgncGzMlC4u0jqjZp0taoiagLD5dYx50WQgPKPAnC28b
	 QiGx+5vZR9MOoN+7h/XvFW4FmcXRjCfYsBhGVNBJOmlAH3C7HhXzNoQ+Xg0a9meoQV
	 eugVY37iCwti5sciGjkF61tSPNzB5sPl+jwniGxrDQpPz7NgDvTixOMm5YRor1i2Yj
	 +GmAoB0UZisLt5CmuBDnHKjX0VwzTgL8Mj+b0IiV5zm6jNRlQdR3dC8dggn2POgmT3
	 Qs3LP9FdDaQDg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> The HMM mirror API can be use in two fashions. The first one where the HM=
M
> user coalesce multiple page faults into one request and set flags per pfn=
s
> for of those faults. The second one where the HMM user want to pre-fault =
a
> range with specific flags. For the latter one it is a waste to have the u=
ser
> pre-fill the pfn arrays with a default flags value.
>=20
> This patch adds a default flags value allowing user to set them for a ran=
ge
> without having to pre-fill the pfn array.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/hmm.h |  7 +++++++
>  mm/hmm.c            | 12 ++++++++++++
>  2 files changed, 19 insertions(+)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 79671036cb5f..13bc2c72f791 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
>   * @pfns: array of pfns (big enough for the range)
>   * @flags: pfn flags to match device driver page table
>   * @values: pfn value for some special case (none, special, error, ...)
> + * @default_flags: default flags for the range (write, read, ...)
> + * @pfn_flags_mask: allows to mask pfn flags so that only default_flags =
matter
>   * @pfn_shifts: pfn shift value (should be <=3D PAGE_SHIFT)
>   * @valid: pfns array did not change since it has been fill by an HMM fu=
nction
>   */
> @@ -177,6 +179,8 @@ struct hmm_range {
>  	uint64_t		*pfns;
>  	const uint64_t		*flags;
>  	const uint64_t		*values;
> +	uint64_t		default_flags;
> +	uint64_t		pfn_flags_mask;
>  	uint8_t			pfn_shift;
>  	bool			valid;
>  };
> @@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *ran=
ge, bool block)
>  {
>  	long ret;
> =20
> +	range->default_flags =3D 0;
> +	range->pfn_flags_mask =3D -1UL;

Hi Jerome,

This is nice to have. Let's constrain it a little bit more, though: the pfn=
_flags_mask
definitely does not need to be a run time value. And we want some assurance=
 that
the mask is=20
	a) large enough for the flags, and
	b) small enough to avoid overrunning the pfns field.

Those are less certain with a run-time struct field, and more obviously cor=
rect with
something like, approximately:

 	#define PFN_FLAGS_MASK 0xFFFF

or something.

In other words, this is more flexibility than we need--just a touch too muc=
h,
IMHO.

> +
>  	ret =3D hmm_range_register(range, range->vma->vm_mm,
>  				 range->start, range->end);
>  	if (ret)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index fa9498eeb9b6..4fe88a196d17 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct h=
mm_vma_walk *hmm_vma_walk,
>  	if (!hmm_vma_walk->fault)
>  		return;
> =20
> +	/*
> +	 * So we not only consider the individual per page request we also
> +	 * consider the default flags requested for the range. The API can
> +	 * be use in 2 fashions. The first one where the HMM user coalesce
> +	 * multiple page fault into one request and set flags per pfns for
> +	 * of those faults. The second one where the HMM user want to pre-
> +	 * fault a range with specific flags. For the latter one it is a
> +	 * waste to have the user pre-fill the pfn arrays with a default
> +	 * flags value.
> +	 */
> +	pfns =3D (pfns & range->pfn_flags_mask) | range->default_flags;

Need to verify that the mask isn't too large or too small.

> +
>  	/* We aren't ask to do anything ... */
>  	if (!(pfns & range->flags[HMM_PFN_VALID]))
>  		return;
>=20



thanks,
--=20
John Hubbard
NVIDIA

