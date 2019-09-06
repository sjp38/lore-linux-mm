Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5C51C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 824FC20650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 824FC20650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4AA6B026F; Fri,  6 Sep 2019 11:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5236B0271; Fri,  6 Sep 2019 11:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BB136B0272; Fri,  6 Sep 2019 11:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id E90326B026F
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:18:11 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 91E512DFB
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:11 +0000 (UTC)
X-FDA: 75904851582.06.base33_d42b04544358
X-HE-Tag: base33_d42b04544358
X-Filterd-Recvd-Size: 4469
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:10 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3FAE828;
	Fri,  6 Sep 2019 08:18:10 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 21E023F59C;
	Fri,  6 Sep 2019 08:18:08 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 06/17] arm64, hibernate: add trans_pgd public functions
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-7-pasha.tatashin@soleen.com>
Message-ID: <bcc3f71f-97d2-dff4-c55a-4798c6e2bede@arm.com>
Date: Fri, 6 Sep 2019 16:18:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-7-pasha.tatashin@soleen.com>
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
> trans_pgd_create_copy() and trans_pgd_map_page() are going to be
> the basis for public interface of new subsystem that handles page

Please don't call this a subsystem. 'sound' and 'mm' are subsystems, this is just some
shared code.

> tables for cases which are between kernels: kexec, and hibernate.

Even though you've baked the get_safe_page() calls into trans_pgd_map_page()?


> diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> index 750ecc7f2cbe..2e29d620b56c 100644
> --- a/arch/arm64/kernel/hibernate.c
> +++ b/arch/arm64/kernel/hibernate.c
> @@ -182,39 +182,15 @@ int arch_hibernation_header_restore(void *addr)

> +int trans_pgd_map_page(pgd_t *trans_pgd, void *page,
> +		       unsigned long dst_addr,
> +		       pgprot_t pgprot)

If this thing is going to be exposed, its name should reflect that its creating a set of
page tables, to map a single page.

A function called 'map_page' with this prototype should 'obviously' map @page at @dst_addr
in @trans_pgd using the provided @pgprot... but it doesn't.

This is what 'create' was doing in the old name, if that wasn't obvious, its because
naming things is hard!
| trans_create_single_page_mapping()?

(might be too verbose)

I think this bites you in patch 8, where you 'generalise' this.


>  {
> -	void *page = (void *)get_safe_page(GFP_ATOMIC);
> -	pgd_t *trans_pgd;
>  	pgd_t *pgdp;
>  	pud_t *pudp;
>  	pmd_t *pmdp;
>  	pte_t *ptep;
>  
> -	if (!page)
> -		return -ENOMEM;
> -
> -	memcpy(page, src_start, length);
> -	__flush_icache_range((unsigned long)page, (unsigned long)page + length);
> -
> -	trans_pgd = (void *)get_safe_page(GFP_ATOMIC);
> -	if (!trans_pgd)
> -		return -ENOMEM;
> -
>  	pgdp = pgd_offset_raw(trans_pgd, dst_addr);
>  	if (pgd_none(READ_ONCE(*pgdp))) {
>  		pudp = (void *)get_safe_page(GFP_ATOMIC);
> @@ -242,6 +218,44 @@ static int create_safe_exec_page(void *src_start, size_t length,
>  	ptep = pte_offset_kernel(pmdp, dst_addr);
>  	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
>  
> +	return 0;
> +}
> +
> +/*
> + * Copies length bytes, starting at src_start into an new page,
> + * perform cache maintentance, then maps it at the specified address low

Could you fix the spelling of maintenance as git thinks you've moved it?


> + * address as executable.
> + *
> + * This is used by hibernate to copy the code it needs to execute when
> + * overwriting the kernel text. This function generates a new set of page
> + * tables, which it loads into ttbr0.
> + *
> + * Length is provided as we probably only want 4K of data, even on a 64K
> + * page system.
> + */
> +static int create_safe_exec_page(void *src_start, size_t length,
> +				 unsigned long dst_addr,
> +				 phys_addr_t *phys_dst_addr)
> +{


Thanks,

James

