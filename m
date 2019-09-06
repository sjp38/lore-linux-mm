Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D73DCC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E3732070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:23:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3732070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514B96B0272; Fri,  6 Sep 2019 11:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3C06B0273; Fri,  6 Sep 2019 11:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DABD6B0274; Fri,  6 Sep 2019 11:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9F76B0272
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:23:21 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BF5DB181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:23:20 +0000 (UTC)
X-FDA: 75904864560.10.nerve64_3a407e32f3054
X-HE-Tag: nerve64_3a407e32f3054
X-Filterd-Recvd-Size: 5760
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:23:20 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AF61828;
	Fri,  6 Sep 2019 08:23:19 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C6D063F59C;
	Fri,  6 Sep 2019 08:23:16 -0700 (PDT)
Subject: Re: [PATCH v3 12/17] arm64, trans_pgd: complete generalization of
 trans_pgds
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-13-pasha.tatashin@soleen.com>
From: James Morse <james.morse@arm.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
Message-ID: <d4a5bb7b-21c0-9f39-ad96-3fa43684c6c6@arm.com>
Date: Fri, 6 Sep 2019 16:23:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-13-pasha.tatashin@soleen.com>
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
> Make the last private functions in page table copy path generlized for use
> outside of hibernate.
> 
> Switch to use the provided allocator, flags, and source page table. Also,
> unify all copy function implementations to reduce the possibility of bugs.

By changing it? No one has reported any problems. We're more likely to break it making
unnecessary changes.

Why is this necessary?


> All page table levels are implemented symmetrically.


> diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
> index efd42509d069..ccd9900f8edb 100644
> --- a/arch/arm64/mm/trans_pgd.c
> +++ b/arch/arm64/mm/trans_pgd.c
> @@ -27,139 +27,157 @@ static void *trans_alloc(struct trans_pgd_info *info)

> -static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long addr)
> +static int copy_pte(struct trans_pgd_info *info, pte_t *dst_ptep,
> +		    pte_t *src_ptep, unsigned long start, unsigned long end)
>  {
> -	pte_t pte = READ_ONCE(*src_ptep);
> -
> -	if (pte_valid(pte)) {
> -		/*
> -		 * Resume will overwrite areas that may be marked
> -		 * read only (code, rodata). Clear the RDONLY bit from
> -		 * the temporary mappings we use during restore.
> -		 */
> -		set_pte(dst_ptep, pte_mkwrite(pte));
> -	} else if (debug_pagealloc_enabled() && !pte_none(pte)) {
> -		/*
> -		 * debug_pagealloc will removed the PTE_VALID bit if
> -		 * the page isn't in use by the resume kernel. It may have
> -		 * been in use by the original kernel, in which case we need
> -		 * to put it back in our copy to do the restore.
> -		 *
> -		 * Before marking this entry valid, check the pfn should
> -		 * be mapped.
> -		 */
> -		BUG_ON(!pfn_valid(pte_pfn(pte)));
> -
> -		set_pte(dst_ptep, pte_mkpresent(pte_mkwrite(pte)));
> -	}
> -}

> -static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, unsigned long start,
> -		    unsigned long end)
> -{
> -	pte_t *src_ptep;
> -	pte_t *dst_ptep;
>  	unsigned long addr = start;
> +	int i = pte_index(addr);
>  
> -	dst_ptep = (pte_t *)get_safe_page(GFP_ATOMIC);
> -	if (!dst_ptep)
> -		return -ENOMEM;
> -	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
> -	dst_ptep = pte_offset_kernel(dst_pmdp, start);
> -
> -	src_ptep = pte_offset_kernel(src_pmdp, start);
>  	do {
> -		_copy_pte(dst_ptep, src_ptep, addr);
> -	} while (dst_ptep++, src_ptep++, addr += PAGE_SIZE, addr != end);
> +		pte_t src_pte = READ_ONCE(src_ptep[i]);
> +
> +		if (pte_none(src_pte))
> +			continue;

> +		if (info->trans_flags & TRANS_MKWRITE)
> +			src_pte = pte_mkwrite(src_pte);

This should be unconditional. The purpose of this thing is to create a set of page tables
you can use to overwrite all of memory. Why would you want to keep the RDONLY flag for
normal memory?


> +		if (info->trans_flags & TRANS_MKVALID)
> +			src_pte = pte_mkpresent(src_pte);
> +		if (info->trans_flags & TRANS_CHECKPFN) {
> +			if (!pfn_valid(pte_pfn(src_pte)))
> +				return -ENXIO;
> +		}

This lets you skip the pfn_valid() check if you want to create bogus mappings. This should
not be conditional.
This removes the BUG_ON(), which is there to make sure we stop if we find page-table
corruption.

Please keep the shape of _copy_pte() as it is. Putting a different mapping in the copied
tables is risky, the code that does it should all be in one place, along with the
justification of why its doing this. Anything else is harder to debug when it goes wrong.


> +		set_pte(&dst_ptep[i], src_pte);
> +	} while (addr += PAGE_SIZE, i++, addr != end && i < PTRS_PER_PTE);

Incrementing pte/pud/pmg/pgd pointers is a common pattern in the kernel's page table
walkers. Why do we need to change this to index it like an array?

This needs to look like walk_page_range() as the eventual aim is to remove it, and use the
core-code page table walker.

(at the time it was merged the core-code page table walker removed block mappings it
didn't like, which didn't go well.)

This is a backwards step as it makes any attempt to remove this arch-specific walker harder.


>  
>  	return 0;
>  }



Thanks,

James

