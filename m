Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADDBC10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 106E620869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="pmEzazsb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 106E620869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8BE36B000D; Fri, 12 Apr 2019 14:52:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B11A46B0010; Fri, 12 Apr 2019 14:52:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A02816B026A; Fri, 12 Apr 2019 14:52:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 612476B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:52:26 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d16so6766836pll.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:52:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=hCzQmlhJXIJ1JvJEUrN2D8vb6coMMQDl9PBdk0RQevA=;
        b=RZDcimd8wU42nCvtuEPqym8JKiEzjFtEpWZXRtkG52IrpKoyTRGIctudC0Un0/pheA
         nS7VF8NGgzQoSgCjyG3vviFjqKSxs8sjfS4OHncYtHREKTy+wwBGh328/phAeIdXP9vX
         6bz5igBgVizb4MWOzz9LV22U1kpb2e6Uwi21Xc0wiHIuAmbQVUlUOvkY3R8VILQJHYOH
         pLuXZ/k/9E+9rhWCoDCEWBhs4TGCrf9D6EQ43GFiYNJiMgn7hXVsLr2VpPTxVnEqhvuK
         Veglo+Zlj+IMH3SiTum+dkZXPlIlSluSvDd5M5U01ckk8BYCaPiuwcTspnJkCdFvGzQY
         oBUQ==
X-Gm-Message-State: APjAAAWFooun4UZ8xv/GmyWi8nCcnAAoIPUN0IUIce23w+uBfYP81YLJ
	HhN+G/blf9Um4/j6UXDRqv0pazBwjibH3Q1u20okKMfLp/LlZ+ll+Lv/dUmL1n5dlvwiVQPmOZI
	EgNMyTKM5gGHiulP//HdjcDiPq+sejnSYXdDhfxpDobWtonDJ9h67UiMtkmP5XBGLGw==
X-Received: by 2002:a63:6581:: with SMTP id z123mr53184002pgb.243.1555095145909;
        Fri, 12 Apr 2019 11:52:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqrTjn8DPN5e1870TE+c2F//xPrpyYCt0c6gqN5kYM+yWDDmTQ/y/5KeWv/drVpfgP3jfk
X-Received: by 2002:a63:6581:: with SMTP id z123mr53183947pgb.243.1555095145045;
        Fri, 12 Apr 2019 11:52:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095145; cv=none;
        d=google.com; s=arc-20160816;
        b=elGcmMId32GpM1UdrjRqUpzWg7+JCVPUgcVL5DUEft/OBSKATKpK+2PsgomFjKR+yl
         Vps0eDgezXseCsoAwJPdbGEovcZSnNDDykiu2bpLFu10DIgMF8/sWCS87Lgq4grj3jpx
         5MVpjxAHqQe1RvqJZWnKap4HBnArgQIErZ85k+Bf/CbYmb224NMs4C/z6gm4HKhy8OeM
         r8ar9x+YHJ+Prk33gPw4qOer3NkqtDf/2NxXFtLOnC6cDyYZIRRsY1k68BMaUXUu6hXn
         GXnUKeY/LiLAfwPkHwTXyRAfh4hqcZhRet2K1TyQEYASnwOMziYL3o7v0Ud8cqqOFE7X
         vPyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=hCzQmlhJXIJ1JvJEUrN2D8vb6coMMQDl9PBdk0RQevA=;
        b=B0tJXfR3PuR9ebPAWgwNRXLaoUBpd9A8dcD8TGzzOeuIUvuMLmjEPBW5VLhDsQLrmX
         ju3vsVdJmuxe5q3eXf6LnQg0keLwx1nYfvfUK/CKl/zyIqmMJIwE/uzFleiBy1NW2KuZ
         UCBoOIoKzpyYsna7nXjQ3O7Sv1UwXf2hNUc8BXHbWkIbaNPrruB4zlWQMrnS4XikteS/
         Sh6Hw1epG8sLk86QUr9M7l/o3DBi+LQpse48QVs7zlReLEt2AVrU7JyBeJlwOPHGul7y
         pLCeLTF3mTj0r/ySEbU0gtaFUXoypWEmWfjbz4umY8CEqOg1IyJuWx5oJydubaFYQ0ab
         cXnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=pmEzazsb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l86si26621251pfb.182.2019.04.12.11.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 11:52:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=pmEzazsb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb0de570000>; Fri, 12 Apr 2019 11:52:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 12 Apr 2019 11:52:24 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 12 Apr 2019 11:52:24 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 12 Apr
 2019 18:52:23 +0000
Subject: Re: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
To: Thomas Hellstrom <thellstrom@vmware.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
References: <20190412160338.64994-1-thellstrom@vmware.com>
 <20190412160338.64994-3-thellstrom@vmware.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <b00718ef-cf89-fb6d-7bd7-eca1205835e1@nvidia.com>
Date: Fri, 12 Apr 2019 11:52:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190412160338.64994-3-thellstrom@vmware.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555095127; bh=hCzQmlhJXIJ1JvJEUrN2D8vb6coMMQDl9PBdk0RQevA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=pmEzazsbrMi15ESvif6VCPja6+8mLMTuKFyWQrniRo0GSd4+yV3v9Qv0bMiKfYdEi
	 ppDfoVJMxySDSnqfSCOp2s+cu1UOxEqCmh4D58UHhV5sRs+bWmsYznk0m3WenLEMPW
	 ZztbXZFq+BoQW5hzzETr4pQKAJG8MPwIQJ378mkx7yda4HUF6zlgiZGnxO9lj5kxbq
	 nnJPgU/SSjWrjZfhDxQbFzXIYYPWC3gGGs0vFiJEDwC5yDpqdi3ydcZe1VRt2hstb3
	 pWNCCeVORCkt8D0vYQgQLWqrORbwyNmz6V4sJh6hjkWluSveY+qkFIoO3r0OJCKQGr
	 /ylF0tz5UPexw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/12/19 9:04 AM, Thomas Hellstrom wrote:
> This is basically apply_to_page_range with added functionality:
> Allocating missing parts of the page table becomes optional, which
> means that the function can be guaranteed not to error if allocation
> is disabled. Also passing of the closure struct and callback function
> becomes different and more in line with how things are done elsewhere.
>=20
> Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_rang=
e
>=20
> The reason for not using the page-walk code is that we want to perform
> the page-walk on vmas pointing to an address space without requiring the
> mmap_sem to be held rather thand on vmas belonging to a process with the

s/thand/than/

> mmap_sem held.
>=20
> Notable changes since RFC:
> Don't export apply_to_pfn range.
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   include/linux/mm.h |  10 ++++
>   mm/memory.c        | 130 ++++++++++++++++++++++++++++++++++-----------
>   2 files changed, 108 insertions(+), 32 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..b7dd4ddd6efb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2632,6 +2632,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t toke=
n, unsigned long addr,
>   extern int apply_to_page_range(struct mm_struct *mm, unsigned long addr=
ess,
>   			       unsigned long size, pte_fn_t fn, void *data);
>  =20
> +struct pfn_range_apply;
> +typedef int (*pter_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr=
,
> +			 struct pfn_range_apply *closure);
> +struct pfn_range_apply {
> +	struct mm_struct *mm;
> +	pter_fn_t ptefn;
> +	unsigned int alloc;
> +};
> +extern int apply_to_pfn_range(struct pfn_range_apply *closure,
> +			      unsigned long address, unsigned long size);
>  =20
>   #ifdef CONFIG_PAGE_POISONING
>   extern bool page_poisoning_enabled(void);
> diff --git a/mm/memory.c b/mm/memory.c
> index a95b4a3b1ae2..60d67158964f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1938,18 +1938,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, p=
hys_addr_t start, unsigned long
>   }
>   EXPORT_SYMBOL(vm_iomap_memory);
>  =20
> -static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pte_range(struct pfn_range_apply *closure, pmd_t *pm=
d,
> +			      unsigned long addr, unsigned long end)
>   {
>   	pte_t *pte;
>   	int err;
>   	pgtable_t token;
>   	spinlock_t *uninitialized_var(ptl);
>  =20
> -	pte =3D (mm =3D=3D &init_mm) ?
> +	pte =3D (closure->mm =3D=3D &init_mm) ?
>   		pte_alloc_kernel(pmd, addr) :
> -		pte_alloc_map_lock(mm, pmd, addr, &ptl);
> +		pte_alloc_map_lock(closure->mm, pmd, addr, &ptl);
>   	if (!pte)
>   		return -ENOMEM;
>  =20
> @@ -1960,86 +1959,107 @@ static int apply_to_pte_range(struct mm_struct *=
mm, pmd_t *pmd,
>   	token =3D pmd_pgtable(*pmd);
>  =20
>   	do {
> -		err =3D fn(pte++, token, addr, data);
> +		err =3D closure->ptefn(pte++, token, addr, closure);
>   		if (err)
>   			break;
>   	} while (addr +=3D PAGE_SIZE, addr !=3D end);
>  =20
>   	arch_leave_lazy_mmu_mode();
>  =20
> -	if (mm !=3D &init_mm)
> +	if (closure->mm !=3D &init_mm)
>   		pte_unmap_unlock(pte-1, ptl);
>   	return err;
>   }
>  =20
> -static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pmd_range(struct pfn_range_apply *closure, pud_t *pu=
d,
> +			      unsigned long addr, unsigned long end)
>   {
>   	pmd_t *pmd;
>   	unsigned long next;
> -	int err;
> +	int err =3D 0;
>  =20
>   	BUG_ON(pud_huge(*pud));
>  =20
> -	pmd =3D pmd_alloc(mm, pud, addr);
> +	pmd =3D pmd_alloc(closure->mm, pud, addr);
>   	if (!pmd)
>   		return -ENOMEM;
> +
>   	do {
>   		next =3D pmd_addr_end(addr, end);
> -		err =3D apply_to_pte_range(mm, pmd, addr, next, fn, data);
> +		if (!closure->alloc && pmd_none_or_clear_bad(pmd))
> +			continue;
> +		err =3D apply_to_pte_range(closure, pmd, addr, next);
>   		if (err)
>   			break;
>   	} while (pmd++, addr =3D next, addr !=3D end);
>   	return err;
>   }
>  =20
> -static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pud_range(struct pfn_range_apply *closure, p4d_t *p4=
d,
> +			      unsigned long addr, unsigned long end)
>   {
>   	pud_t *pud;
>   	unsigned long next;
> -	int err;
> +	int err =3D 0;
>  =20
> -	pud =3D pud_alloc(mm, p4d, addr);
> +	pud =3D pud_alloc(closure->mm, p4d, addr);
>   	if (!pud)
>   		return -ENOMEM;
> +
>   	do {
>   		next =3D pud_addr_end(addr, end);
> -		err =3D apply_to_pmd_range(mm, pud, addr, next, fn, data);
> +		if (!closure->alloc && pud_none_or_clear_bad(pud))
> +			continue;
> +		err =3D apply_to_pmd_range(closure, pud, addr, next);
>   		if (err)
>   			break;
>   	} while (pud++, addr =3D next, addr !=3D end);
>   	return err;
>   }
>  =20
> -static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_p4d_range(struct pfn_range_apply *closure, pgd_t *pg=
d,
> +			      unsigned long addr, unsigned long end)
>   {
>   	p4d_t *p4d;
>   	unsigned long next;
> -	int err;
> +	int err =3D 0;
>  =20
> -	p4d =3D p4d_alloc(mm, pgd, addr);
> +	p4d =3D p4d_alloc(closure->mm, pgd, addr);
>   	if (!p4d)
>   		return -ENOMEM;
> +
>   	do {
>   		next =3D p4d_addr_end(addr, end);
> -		err =3D apply_to_pud_range(mm, p4d, addr, next, fn, data);
> +		if (!closure->alloc && p4d_none_or_clear_bad(p4d))
> +			continue;
> +		err =3D apply_to_pud_range(closure, p4d, addr, next);
>   		if (err)
>   			break;
>   	} while (p4d++, addr =3D next, addr !=3D end);
>   	return err;
>   }
>  =20
> -/*
> - * Scan a region of virtual memory, filling in page tables as necessary
> - * and calling a provided function on each leaf page table.
> +/**
> + * apply_to_pfn_range - Scan a region of virtual memory, calling a provi=
ded
> + * function on each leaf page table entry
> + * @closure: Details about how to scan and what function to apply
> + * @addr: Start virtual address
> + * @size: Size of the region
> + *
> + * If @closure->alloc is set to 1, the function will fill in the page ta=
ble
> + * as necessary. Otherwise it will skip non-present parts.
> + * Note: The caller must ensure that the range does not contain huge pag=
es.
> + * The caller must also assure that the proper mmu_notifier functions ar=
e
> + * called. Either in the pte leaf function or before and after the call =
to
> + * apply_to_pfn_range.
> + *
> + * Returns: Zero on success. If the provided function returns a non-zero=
 status,

s/Returns/Return/
See Documentation/kernel-guide/kernel-doc.rst

> + * the page table walk will terminate and that status will be returned.
> + * If @closure->alloc is set to 1, then this function may also return me=
mory
> + * allocation errors arising from allocating page table memory.
>    */
> -int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
> -			unsigned long size, pte_fn_t fn, void *data)
> +int apply_to_pfn_range(struct pfn_range_apply *closure,
> +		       unsigned long addr, unsigned long size)
>   {
>   	pgd_t *pgd;
>   	unsigned long next;
> @@ -2049,16 +2069,62 @@ int apply_to_page_range(struct mm_struct *mm, uns=
igned long addr,
>   	if (WARN_ON(addr >=3D end))
>   		return -EINVAL;
>  =20
> -	pgd =3D pgd_offset(mm, addr);
> +	pgd =3D pgd_offset(closure->mm, addr);
>   	do {
>   		next =3D pgd_addr_end(addr, end);
> -		err =3D apply_to_p4d_range(mm, pgd, addr, next, fn, data);
> +		if (!closure->alloc && pgd_none_or_clear_bad(pgd))
> +			continue;
> +		err =3D apply_to_p4d_range(closure, pgd, addr, next);
>   		if (err)
>   			break;
>   	} while (pgd++, addr =3D next, addr !=3D end);
>  =20
>   	return err;
>   }
> +
> +/**
> + * struct page_range_apply - Closure structure for apply_to_page_range()
> + * @pter: The base closure structure we derive from
> + * @fn: The leaf pte function to call
> + * @data: The leaf pte function closure
> + */
> +struct page_range_apply {
> +	struct pfn_range_apply pter;
> +	pte_fn_t fn;
> +	void *data;
> +};
> +
> +/*
> + * Callback wrapper to enable use of apply_to_pfn_range for
> + * the apply_to_page_range interface
> + */
> +static int apply_to_page_range_wrapper(pte_t *pte, pgtable_t token,
> +				       unsigned long addr,
> +				       struct pfn_range_apply *pter)
> +{
> +	struct page_range_apply *pra =3D
> +		container_of(pter, typeof(*pra), pter);
> +
> +	return pra->fn(pte, token, addr, pra->data);
> +}
> +
> +/*
> + * Scan a region of virtual memory, filling in page tables as necessary
> + * and calling a provided function on each leaf page table.
> + */
> +int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
> +			unsigned long size, pte_fn_t fn, void *data)
> +{
> +	struct page_range_apply pra =3D {
> +		.pter =3D {.mm =3D mm,
> +			 .alloc =3D 1,
> +			 .ptefn =3D apply_to_page_range_wrapper },
> +		.fn =3D fn,
> +		.data =3D data
> +	};
> +
> +	return apply_to_pfn_range(&pra.pter, addr, size);
> +}
>   EXPORT_SYMBOL_GPL(apply_to_page_range);
>  =20
>   /*
>=20

