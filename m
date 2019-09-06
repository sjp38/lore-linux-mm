Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86658C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46E11218AF
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46E11218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2EA6B0003; Fri,  6 Sep 2019 11:20:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E63DC6B000E; Fri,  6 Sep 2019 11:20:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D79896B0266; Fri,  6 Sep 2019 11:20:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id B6FC06B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:20:14 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5AA9B180AD802
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:20:14 +0000 (UTC)
X-FDA: 75904856748.25.watch65_1f15b8faea516
X-HE-Tag: watch65_1f15b8faea516
X-Filterd-Recvd-Size: 9333
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:20:13 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2CF928;
	Fri,  6 Sep 2019 08:20:12 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E165B3F59C;
	Fri,  6 Sep 2019 08:20:08 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 08/17] arm64, trans_pgd: make trans_pgd_map_page
 generic
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-9-pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
Message-ID: <62fc9ed9-1740-d40b-bc72-6d1911ef1f24@arm.com>
Date: Fri, 6 Sep 2019 16:20:07 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-9-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 21/08/2019 19:31, Pavel Tatashin wrote:
> Currently, trans_pgd_map_page has assumptions that are relevant to
> hibernate. But, to make it generic we must allow it to use any allocator

Sounds familiar: you removed this in patch 2.


> and also, can't assume that entries do not exist in the page table
> already.

This thing creates a set of page tables to map one page: the relocation code.
This is mapped in TTBR0_EL1.
It can assume existing entries do not exist, because it creates the single-entry levels as
it goes. Kexec also needs to map precisely one page for relocation. You don't need to
generalise this.

'trans_pgd_create_copy()' is what creates a copy the linear map. This is mapped in TTBR1_EL1.

There is no reason for kexec to behave differently here.


> Also, we can't use init_mm here.

Why not? arm64's pgd_populate() doesn't use the mm. It's only there to make it obvious
this is an EL1 mapping we are creating. We use the kernel-asid with the new mapping.

The __ version is a lot less readable. Please don't use the page tables as an array: this
is what the offset helpers are for.


> Also, add "flags" for trans_pgd_info, they are going to be used
> in copy functions once they are generalized.

You don't need to 'generalize' this to support hypothetical users.
There are only two: hibernate and kexec, both of which are very specialised. Making these
things top-level marionette strings will tangle the logic.

The copy_p?d() functions should decide if they should manipulate _this_ entry based on
_this_ entry and the kernel configuration. This is only really done in _copy_pte(), which
is where it should stay.


> diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/trans_pgd.h
> index c7b5402b7d87..e3d022b1b526 100644
> --- a/arch/arm64/include/asm/trans_pgd.h
> +++ b/arch/arm64/include/asm/trans_pgd.h
> @@ -11,10 +11,45 @@
>  #include <linux/bits.h>
>  #include <asm/pgtable-types.h>
>  
> +/*
> + * trans_alloc_page
> + *	- Allocator that should return exactly one uninitilaized page, if this
> + *	 allocator fails, trans_pgd returns -ENOMEM error.
> + *
> + * trans_alloc_arg
> + *	- Passed to trans_alloc_page as an argument

This is very familiar.


> + * trans_flags
> + *	- bitmap with flags that control how page table is filled.
> + *	  TRANS_MKWRITE: during page table copy make PTE, PME, and PUD page
> + *			 writeable by removing RDONLY flag from PTE.

Why would you ever keep the read-only flags in a set of page tables that exist to let you
overwrite memory?


> + *	  TRANS_MKVALID: during page table copy, if PTE present, but not valid,
> + *			 make it valid.

Please keep this logic together with the !pte_none(pte) and debug_pagealloc_enabled()
check, where it is today.

Making an entry valid without those checks should never be necessary.


> + *	  TRANS_CHECKPFN: During page table copy, for every PTE entry check that
> + *			  PFN that this PTE points to is valid. Otherwise return
> + *			  -ENXIO

Hibernate does this when inventing a new mapping. This is how we check the kernel
should be able to read/write this page. If !pfn_valid(), the page should not be mapped.

Why do you need to turn this off?

It us only necessary at the leaf level, and only if debug-pagealloc is in use. Please keep
all these bits together, as its much harder to understand why this entry needs inventing
when its split up like this.



> diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> index 6ee81bbaa37f..17426dc8cb54 100644
> --- a/arch/arm64/kernel/hibernate.c
> +++ b/arch/arm64/kernel/hibernate.c
> @@ -179,6 +179,12 @@ int arch_hibernation_header_restore(void *addr)
>  }
>  EXPORT_SYMBOL(arch_hibernation_header_restore);
>  
> +static void *
> +hibernate_page_alloc(void *arg)
> +{
> +	return (void *)get_safe_page((gfp_t)(unsigned long)arg);
> +}
> +
>  /*
>   * Copies length bytes, starting at src_start into an new page,
>   * perform cache maintentance, then maps it at the specified address low
> @@ -195,6 +201,11 @@ static int create_safe_exec_page(void *src_start, size_t length,
>  				 unsigned long dst_addr,
>  				 phys_addr_t *phys_dst_addr)
>  {
> +	struct trans_pgd_info trans_info = {
> +		.trans_alloc_page	= hibernate_page_alloc,
> +		.trans_alloc_arg	= (void *)GFP_ATOMIC,
> +		.trans_flags		= 0,
> +	};
>  	void *page = (void *)get_safe_page(GFP_ATOMIC);
>  	pgd_t *trans_pgd;
>  	int rc;
> @@ -209,7 +220,7 @@ static int create_safe_exec_page(void *src_start, size_t length,
>  	if (!trans_pgd)
>  		return -ENOMEM;
>  
> -	rc = trans_pgd_map_page(trans_pgd, page, dst_addr,
> +	rc = trans_pgd_map_page(&trans_info, trans_pgd, page, dst_addr,
>  				PAGE_KERNEL_EXEC);
>  	if (rc)
>  		return rc;
> diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
> index 00b62d8640c2..dbabccd78cc4 100644
> --- a/arch/arm64/mm/trans_pgd.c
> +++ b/arch/arm64/mm/trans_pgd.c
> @@ -17,6 +17,16 @@
>  #include <asm/pgtable.h>
>  #include <linux/suspend.h>
>  
> +static void *trans_alloc(struct trans_pgd_info *info)
> +{
> +	void *page = info->trans_alloc_page(info->trans_alloc_arg);
> +
> +	if (page)
> +		clear_page(page);

The hibernate allocator already does this. As your reason for doing this is to make this
faster, it seems odd we do this twice.

If zeroed pages are necessary, the allocator should do it. (It already needs to be a
use-case specific allocator)


> +
> +	return page;
> +}
> +
>  static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long addr)
>  {
>  	pte_t pte = READ_ONCE(*src_ptep);
> @@ -172,40 +182,64 @@ int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
>  	return rc;
>  }
>  
> -int trans_pgd_map_page(pgd_t *trans_pgd, void *page, unsigned long dst_addr,
> -		       pgprot_t pgprot)
> +int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
> +		       void *page, unsigned long dst_addr, pgprot_t pgprot)
>  {
> -	pgd_t *pgdp;
> -	pud_t *pudp;
> -	pmd_t *pmdp;
> -	pte_t *ptep;
> -
> -	pgdp = pgd_offset_raw(trans_pgd, dst_addr);
> -	if (pgd_none(READ_ONCE(*pgdp))) {
> -		pudp = (void *)get_safe_page(GFP_ATOMIC);
> -		if (!pudp)
> +	int pgd_idx = pgd_index(dst_addr);
> +	int pud_idx = pud_index(dst_addr);
> +	int pmd_idx = pmd_index(dst_addr);
> +	int pte_idx = pte_index(dst_addr);

Yuck.



> +	pgd_t *pgdp = trans_pgd;
> +	pgd_t pgd = READ_ONCE(pgdp[pgd_idx]);
> +	pud_t *pudp, pud;
> +	pmd_t *pmdp, pmd;
> +	pte_t *ptep, pte;
> +
> +	if (pgd_none(pgd)) {
> +		pud_t *t = trans_alloc(info);
> +
> +		if (!t)
>  			return -ENOMEM;

> -		pgd_populate(&init_mm, pgdp, pudp);
> +
> +		__pgd_populate(&pgdp[pgd_idx], __pa(t), PUD_TYPE_TABLE);
> +		pgd = READ_ONCE(pgdp[pgd_idx]);


Please keep the pgd_populate() call. If there is some reason we can't pass init_mm, we can
pass NULL, or a fake mm pointer instead.

Going behind the page table helpers back to play with the table directly is a maintenance
headache.


>  	}
>  


> -	pudp = pud_offset(pgdp, dst_addr);
> -	if (pud_none(READ_ONCE(*pudp))) {
> -		pmdp = (void *)get_safe_page(GFP_ATOMIC);
> -		if (!pmdp)
> +	pudp = __va(pgd_page_paddr(pgd));
> +	pud = READ_ONCE(pudp[pud_idx]);
> +	if (pud_sect(pud)) {
> +		return -ENXIO;
> +	} else if (pud_none(pud) || pud_sect(pud)) {
> +		pmd_t *t = trans_alloc(info);
> +
> +		if (!t)
>  			return -ENOMEM;

Choke on block mappings? This should never happen because this function should only create
the tables necessary to map one page. Not a block mapping in sight.

(see my comments on patch 6)


Thanks,

James

