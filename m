Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 673EBC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ACC6218A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:54:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ACC6218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A27948E0002; Wed, 30 Jan 2019 05:54:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B1088E0001; Wed, 30 Jan 2019 05:54:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 878B18E0002; Wed, 30 Jan 2019 05:54:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F01A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:54:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p15so19405111pfk.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:54:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=jyzIli0JeYSc0qLNP9X6R4bBlKHhZzsK+6JwcbNfplE=;
        b=CYJ5rzC3ANy/aLsDC90IJOnWJVAvbCTeVCce7VzRTSwWo18L59uD4sK9BKlsn/zlrr
         j4EvpMWRJIPGk5EXoom5XOLoQBGI3yhUf80TmKGDYreB+2QBVnJEpAEpNyRL8gwtv+35
         2FIMc+b/nki+W1A0sIRG78FnpFHTYm2epASmEyNE9H/KnioJfOgifWALl1qRLR6m2zS8
         GccvL0ds0jrZ3g8n832EBKrxFd2h7czlHfGezU1OumoRNq809ddYU1pXUhaoPR+X9p5+
         o+0NHz/LYcDYbuNMPea7Njc1lXqUopNgYRZSHXZnohU5Ra09UYbs3JwAoIzHpUNSD2WC
         PGcw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukel4w5nuGUhfnIyds4KlZb5xTLsr8ChQowP7Olxo9iAAC9vbCnT
	QQ2VPyU7TKbiuX66ZOpkxnSV8TgyuzD/fW1vGDHGR4wVaQhuAkGfpMugBB+jb332Hk5rrvfzddm
	k/V/xi7h1jztep+Ctc9t0Ngms+bOB2hpzbrkpWWjJqbjuhe3TbQYYrM5TimtTznQ=
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr30564578pli.160.1548845690913;
        Wed, 30 Jan 2019 02:54:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Bd8bnzbuytwtb2ekL4vG/Px97v3q5MRVKAdotvZU55sjSeRosGh+Cf3vkgc1cspWmosGd
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr30564538pli.160.1548845690167;
        Wed, 30 Jan 2019 02:54:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548845690; cv=none;
        d=google.com; s=arc-20160816;
        b=r9uovV97l044N3g3Sp1AfHZp3F+De+U60FyhwgBlf1ee+cOjoFHqTZ+1u+AfL/kwnv
         VjygSuiurj5K76kwGMgmuNF4o1roAD3xbu+rtB3S2XzVxDwlu6c+mhwIEFnqKJExBXeL
         Mm+P0++u9KD8VUgdPX57XfMI5m1TPk+bJZ28n+92+RFga+gBYVns2m+OGA+q6dKvBW6p
         le64FLKiK4yk7896nucLjX2KL7h+a3FCFeeX2yG9orEKLx5XTEuAuUip141oxu50AzlT
         jzyfUzsylocmvUR6Mfy4kXYoxAJBm13618q7xnsCH6pjoABN0LhXQ3OYpzNVWfY4JSA/
         oarw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=jyzIli0JeYSc0qLNP9X6R4bBlKHhZzsK+6JwcbNfplE=;
        b=Jhg4+i3WWulr8JBEyc4KH88Exfc1+gzKaU9CUSIRTPi5FEygNnmRs/aDwN/CnIPdzf
         46U0CFJcKdvIxNZbBmi7gZCOmam4qo4OUy2Zyj4tJgaLs84Hi7HqpEuG2L3hUdr1XD7S
         WZceY34gujjhvkcztriYwW4QCCHfSQs+N7gLFMqzsiwOURqom/AqurumWDHVuRj+youX
         FU/Uigo5B7tQcraUdTL8y5C0KftFMqhJ0MdLHm+kgbJfa62e1kFRdU7oac0gAn59EELU
         9PEAQ+HMWPzdk5iKkxZPGFDO/CH2P0g+08wCUs7+MKsEB1vOMTjjPdu+1TFnX3iZ84vT
         k3tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id g71si1134196pgc.419.2019.01.30.02.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 02:54:50 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qKy00FvPz9s3q;
	Wed, 30 Jan 2019 21:54:47 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V5 4/5] mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
In-Reply-To: <20190116085035.29729-5-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-5-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 21:54:47 +1100
Message-ID: <87d0oequtk.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> Architectures like ppc64 require to do a conditional tlb flush based on the old
> and new value of pte. Follow the regular pte change protection sequence for
> hugetlb too. This allows the architectures to override the update sequence.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  include/linux/hugetlb.h | 20 ++++++++++++++++++++
>  mm/hugetlb.c            |  8 +++++---
>  2 files changed, 25 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 087fd5f48c91..39e78b80375c 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -543,6 +543,26 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
>  	set_huge_pte_at(mm, addr, ptep, pte);
>  }
>  #endif
> +
> +#ifndef huge_ptep_modify_prot_start
> +#define huge_ptep_modify_prot_start huge_ptep_modify_prot_start
> +static inline pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
> +						unsigned long addr, pte_t *ptep)
> +{
> +	return huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
> +}
> +#endif
> +
> +#ifndef huge_ptep_modify_prot_commit
> +#define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
> +static inline void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
> +						unsigned long addr, pte_t *ptep,
> +						pte_t old_pte, pte_t pte)
> +{
> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> +#endif
> +
>  #else	/* CONFIG_HUGETLB_PAGE */
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index df2e7dd5ff17..f824d2200ca9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4387,10 +4387,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  			continue;
>  		}
>  		if (!huge_pte_none(pte)) {
> -			pte = huge_ptep_get_and_clear(mm, address, ptep);
> -			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
> +			pte_t old_pte;
> +
> +			old_pte = huge_ptep_modify_prot_start(vma, address, ptep);
> +			pte = pte_mkhuge(huge_pte_modify(old_pte, newprot));
>  			pte = arch_make_huge_pte(pte, vma, NULL, 0);
> -			set_huge_pte_at(mm, address, ptep, pte);
> +			huge_ptep_modify_prot_commit(vma, address, ptep, old_pte, pte);
>  			pages++;
>  		}
>  		spin_unlock(ptl);

Looks like a faithful conversion.

Reviewed-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

