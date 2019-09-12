Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9892DC4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 20:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 622902084D
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 20:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 622902084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB4206B0003; Thu, 12 Sep 2019 16:15:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63846B0005; Thu, 12 Sep 2019 16:15:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C79B36B0006; Thu, 12 Sep 2019 16:15:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5A56B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:15:34 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CA0853ABF
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 20:15:32 +0000 (UTC)
X-FDA: 75927373704.23.brake31_302415a12eb2b
X-HE-Tag: brake31_302415a12eb2b
X-Filterd-Recvd-Size: 5146
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 20:15:30 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 56D5128;
	Thu, 12 Sep 2019 13:15:29 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EC1A13F71F;
	Thu, 12 Sep 2019 13:15:21 -0700 (PDT)
Date: Thu, 12 Sep 2019 21:15:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	will@kernel.org, mark.rutland@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, mgorman@techsingularity.net,
	osalvador@suse.de, ard.biesheuvel@arm.com, steve.capper@arm.com,
	broonie@kernel.org, valentin.schneider@arm.com,
	Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
Message-ID: <20190912201517.GB1068@C02TF0J2HF1T.local>
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

Thanks for the details on the need for removing the page tables and
vmemmap backing. Some comments on the code below.

On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -60,6 +60,14 @@ static pud_t bm_pud[PTRS_PER_PUD] __page_aligned_bss __maybe_unused;
>  
>  static DEFINE_SPINLOCK(swapper_pgdir_lock);
>  
> +/*
> + * This represents if vmalloc and vmemmap address range overlap with
> + * each other on an intermediate level kernel page table entry which
> + * in turn helps in deciding whether empty kernel page table pages
> + * if any can be freed during memory hotplug operation.
> + */
> +static bool vmalloc_vmemmap_overlap;

I'd say just move the static find_vmalloc_vmemmap_overlap() function
here, the compiler should be sufficiently smart enough to figure out
that it's just a build-time constant.

> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  void vmemmap_free(unsigned long start, unsigned long end,
>  		struct vmem_altmap *altmap)
>  {
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	/*
> +	 * FIXME: We should have called remove_pagetable(start, end, true).
> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
> +	 * page table entries. Removing vmemmap range page table pages here
> +	 * can potentially conflict with a concurrent vmalloc() allocation.
> +	 *
> +	 * This is primarily because vmalloc() does not take init_mm ptl for
> +	 * the entire page table walk and it's modification. Instead it just
> +	 * takes the lock while allocating and installing page table pages
> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
> +	 * entry via memory hot remove can cause vmalloc() kernel page table
> +	 * walk pointers to be invalid on the fly which can cause corruption
> +	 * or worst, a crash.
> +	 *
> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
> +	 * do not overlap at any intermediate level kernel page table entry.
> +	 */
> +	unmap_hotplug_range(start, end, true);
> +	if (!vmalloc_vmemmap_overlap)
> +		free_empty_tables(start, end);
> +#endif
>  }

So, I see the risk with overlapping and I guess for some kernel
configurations (PAGE_SIZE == 64K) we may not be able to avoid it. If we
can, that's great, otherwise could we rewrite the above functions to
handle floor and ceiling similar to free_pgd_range()? (I wonder how this
function works if you called it on init_mm and kernel address range). By
having the vmemmap start/end information it avoids freeing partially
filled page table pages.

Another question: could we do the page table and the actual vmemmap
pages freeing in a single pass (sorry if this has been discussed
before)?

> @@ -1048,10 +1322,18 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
> +{
> +	unsigned long end = start + size;
> +
> +	WARN_ON(pgdir != init_mm.pgd);
> +	remove_pagetable(start, end, false);
> +}

I think the point I've made previously still stands: you only call
remove_pagetable() with sparse_vmap == false in this patch. Just remove
the extra argument and call unmap_hotplug_range() with sparse_vmap ==
false directly in remove_pagetable().

-- 
Catalin

