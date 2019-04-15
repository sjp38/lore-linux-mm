Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEFD0C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5980A2073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5980A2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F04556B0007; Mon, 15 Apr 2019 09:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB3C16B0008; Mon, 15 Apr 2019 09:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA4A56B000A; Mon, 15 Apr 2019 09:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6D16B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:48:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s21so1673245edd.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c0APLhANma++qnuYaZQHiVL/us6d4W1/04UjWUSq3KU=;
        b=sloOgyU+z10ZjsjCm5NWhg1Zk7iYOksGBbJ4ebMDr5/+RCg9uwTTt7QljWsPZPm2Y+
         zbfPThHclp1B2n7q4N0DWixTJHvac/d3EpkUhretxTFSTzbCDcxSDaezRUiD5Et/Y4bg
         E5gBhCgsMDkHfUnDuEUKU/0s0TSuN7Og69IZXxg+ltf13gTgK9F6DgSH++yc3VXXxfmC
         JtqojDbcoEdb4LQJpu7cCF3OtE8fpArapgblRKk8sHhEbqGCQssTk5W4YqYtUsfmj5j9
         Gl6xudc50mkrlC6kiKWEN3VxwlCP58QuhOaSj1TTEkFzBIhl3AIE2k4+3LdvEPTywqYP
         wz7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWnxX1VoNIt+86BC3M809VkzJ6WPp8s5UBwpIKaQNulxFohg/CC
	MjFLXTOB0i+38wdmJwoSJ6XyVcu7Tvf1IJdeMr3xQ43WBhNHpaqtciY/+zl6396y8DYo2M7tDCS
	q5PGiiWlIcOD/9dQvjM564qWqMCPAlp20SJw3nu0z0V/66yXFSpoxHMyMJxmNANPwNg==
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr40040833ejx.105.1555336132003;
        Mon, 15 Apr 2019 06:48:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7a0rxmJL3YJS/Yus66Ag2pE7LnR60AqzHuLCZzjAZycLK9K5Xf5l2siS4bYHCf6SglpvL
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr40040773ejx.105.1555336130762;
        Mon, 15 Apr 2019 06:48:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555336130; cv=none;
        d=google.com; s=arc-20160816;
        b=0NNq/aKf/bYSjpsqt3kKWGdtoEYtyAMQHCiDtaCBaYTtkD73MSkbtZ2Q80KaJx78q2
         Eksek0CrNpd5CSb7jnLKwIx23YmCFTVxR8SRjWmGrpnzrcKFDEB/ZiEc6MlMp/zZK5lh
         1ZKRqK3dg2QSlDdqdcI2rFV0fHdlyttjR2icDmN3TkaugFQPQqYmRXgHiB+yyGN9wuVb
         PoMGCMeulcf8uEOxa02XLl3qORmBDU7UvLpfw0pai7InxdG4Z16dBx6hVs63seZFOFEm
         EIVtllk4cTM+aqqs1GIegytaS1JO8ZBbUedhWPyAT5fAc8dCzZXraSZehiTnXkvMceSt
         BjJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c0APLhANma++qnuYaZQHiVL/us6d4W1/04UjWUSq3KU=;
        b=S3jivtN63m2EIgEnswiiFHCYLmwJPPwGoHC6OR5RgEheaR9Njt6AlAPYwXzL5tqbOj
         BVW6jJNOLoGvG+8bkgA0Aj3oXu/zNOoqOl6JUUOewRcRcBODW1aUb/qQ2v9iLdnf/BGw
         +yT1ikMZhJvKq4bpeMOY9Q+DlA/1LxoGGy5aiusIBlTJJnaY6LrGKgK4Y1uc3h40zJos
         XqPQYEPeQGpIbc4pKssd127gGkWJjdnzkAK9mAnc4MBTSlJx6zqU01Vddloh/KQRx9qr
         kBCbuY6vtSwU420HYrok89unR2TMbRLojaha63z/ecyvdK0lrY8/y9DdaHmzKcdIkevn
         NKuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y23si9107904ejo.107.2019.04.15.06.48.50
        for <linux-mm@kvack.org>;
        Mon, 15 Apr 2019 06:48:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 44D02374;
	Mon, 15 Apr 2019 06:48:49 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 29D9D3F68F;
	Mon, 15 Apr 2019 06:48:46 -0700 (PDT)
Date: Mon, 15 Apr 2019 14:48:43 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	robin.murphy@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, david@redhat.com,
	cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
Message-ID: <20190415134841.GC13990@lakrids.cambridge.arm.com>
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
> Memory removal from an arch perspective involves tearing down two different
> kernel based mappings i.e vmemmap and linear while releasing related page
> table pages allocated for the physical memory range to be removed.
> 
> Define a common kernel page table tear down helper remove_pagetable() which
> can be used to unmap given kernel virtual address range. In effect it can
> tear down both vmemap or kernel linear mappings. This new helper is called
> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
> The argument 'direct' here identifies kernel linear mappings.

Can you please explain why we need to treat these differently? I thought
the next paragraph was going to do that, but as per my comment there it
doesn't seem to be relevant. :/

> Vmemmap mappings page table pages are allocated through sparse mem helper
> functions like vmemmap_alloc_block() which does not cycle the pages through
> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
> destructor construct pgtable_page_dtor().

I thought the ctor/dtor dance wasn't necessary for any init_mm tables,
so why do we need to mention it here specifically for the vmemmap
tables?

> While here update arch_add_mempory() to handle __add_pages() failures by
> just unmapping recently added kernel linear mapping. 

Is this a latent bug?

> Now enable memory hot remove on arm64 platforms by default with
> ARCH_ENABLE_MEMORY_HOTREMOVE.
> 
> This implementation is overall inspired from kernel page table tear down
> procedure on X86 architecture.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm64/Kconfig               |   3 +
>  arch/arm64/include/asm/pgtable.h |   2 +
>  arch/arm64/mm/mmu.c              | 221 ++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 224 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index c383625..a870eb2 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -267,6 +267,9 @@ config HAVE_GENERIC_GUP
>  config ARCH_ENABLE_MEMORY_HOTPLUG
>  	def_bool y
>  
> +config ARCH_ENABLE_MEMORY_HOTREMOVE
> +	def_bool y
> +
>  config SMP
>  	def_bool y
>  
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index de70c1e..1ee22ff 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -555,6 +555,7 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>  
>  #else
>  
> +#define pmd_index(addr) 0
>  #define pud_page_paddr(pud)	({ BUILD_BUG(); 0; })
>  
>  /* Match pmd_offset folding in <asm/generic/pgtable-nopmd.h> */
> @@ -612,6 +613,7 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>  
>  #else
>  
> +#define pud_index(adrr)	0
>  #define pgd_page_paddr(pgd)	({ BUILD_BUG(); 0;})
>  
>  /* Match pud_offset folding in <asm/generic/pgtable-nopud.h> */
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index ef82312..a4750fe 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -733,6 +733,194 @@ int kern_addr_valid(unsigned long addr)
>  
>  	return pfn_valid(pte_pfn(pte));
>  }
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +static void free_pagetable(struct page *page, int order)

On arm64, all of the stage-1 page tables other than the PGD are always
PAGE_SIZE. We shouldn't need to pass an order around in order to free
page tables.

It looks like this function is misnamed, and is used to free vmemmap
backing pages in addition to page tables used to map them. It would be
nicer to come up with a better naming scheme.

> +{
> +	unsigned long magic;
> +	unsigned int nr_pages = 1 << order;
> +
> +	if (PageReserved(page)) {
> +		__ClearPageReserved(page);
> +
> +		magic = (unsigned long)page->freelist;
> +		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {

Not a new problem, but it's unfortunate that the core code reuses the
page::freelist field for this, given it also uses page::private for the
section number. Using fields from different parts of the union doesn't
seem robust.

It would seem nicer to have a private2 field in the struct for anonymous
pages.

> +			while (nr_pages--)
> +				put_page_bootmem(page++);
> +		} else {
> +			while (nr_pages--)
> +				free_reserved_page(page++);
> +		}
> +	} else {
> +		free_pages((unsigned long)page_address(page), order);
> +	}
> +}
> +
> +#if (CONFIG_PGTABLE_LEVELS > 2)
> +static void free_pte_table(pte_t *pte_start, pmd_t *pmd)

As a general note, for arm64 please append a 'p' for pointers to
entries, i.e. these should be ptep and pmdp.

> +{
> +	pte_t *pte;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++) {
> +		pte = pte_start + i;
> +		if (!pte_none(*pte))
> +			return;
> +	}

You could get rid of the pte temporary, rename pte_start to ptep, and
simplify this to:

	for (i = 0; i < PTRS_PER_PTE; i++)
		if (!pte_none(ptep[i]))
			return;

Similar applies at the other levels.

I take it that some higher-level serialization prevents concurrent
modification to this table. Where does that happen?

> +
> +	free_pagetable(pmd_page(*pmd), 0);

Here we free the pte level of table...

> +	spin_lock(&init_mm.page_table_lock);
> +	pmd_clear(pmd);

... but only here do we disconnect it from the PMD level of table, and
we don't do any TLB maintenance just yet. The page could be poisoned
and/or reallocated before we invalidate the TLB, which is not safe. In
all cases, we must follow the sequence:

1) clear the pointer to a table
2) invalidate any corresponding TLB entries
3) free the table page

... or we risk a number of issues resulting from erroneous programming
of the TLBs. See pmd_free_pte_page() for an example of how to do this
correctly.

I'd have thought similar applied to x86, so that implementation looks
suspicious to me too...

> +	spin_unlock(&init_mm.page_table_lock);

What precisely is the page_table_lock intended to protect? 

It seems odd to me that we're happy to walk the tables without the lock,
but only grab the lock when performing a modification. That implies we
either have some higher-level mutual exclusion, or we're not holding the
lock in all cases we need to be.

> +}
> +#else
> +static void free_pte_table(pte_t *pte_start, pmd_t *pmd)
> +{
> +}
> +#endif

I'm surprised that we never need to free a pte table for 2 level paging.
Is that definitely the case?

> +
> +#if (CONFIG_PGTABLE_LEVELS > 3)
> +static void free_pmd_table(pmd_t *pmd_start, pud_t *pud)
> +{
> +	pmd_t *pmd;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PMD; i++) {
> +		pmd = pmd_start + i;
> +		if (!pmd_none(*pmd))
> +			return;
> +	}
> +
> +	free_pagetable(pud_page(*pud), 0);
> +	spin_lock(&init_mm.page_table_lock);
> +	pud_clear(pud);
> +	spin_unlock(&init_mm.page_table_lock);
> +}
> +
> +static void free_pud_table(pud_t *pud_start, pgd_t *pgd)
> +{
> +	pud_t *pud;
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PUD; i++) {
> +		pud = pud_start + i;
> +		if (!pud_none(*pud))
> +			return;
> +	}
> +
> +	free_pagetable(pgd_page(*pgd), 0);
> +	spin_lock(&init_mm.page_table_lock);
> +	pgd_clear(pgd);
> +	spin_unlock(&init_mm.page_table_lock);
> +}
> +#else
> +static void free_pmd_table(pmd_t *pmd_start, pud_t *pud)
> +{
> +}
> +
> +static void free_pud_table(pud_t *pud_start, pgd_t *pgd)
> +{
> +}
> +#endif

It seems very odd to me that we suddenly need both of these, rather than
requiring one before the other. Naively, I'd have expected that we'd
need:

- free_pte_table for CONFIG_PGTABLE_LEVELS > 1 (i.e. always)
- free_pmd_table for CONFIG_PGTABLE_LEVELS > 2
- free_pud_table for CONFIG_PGTABLE_LEVELS > 3

... matching the cases where the levels "really" exist. What am I
missing that ties the pmd and pud levels together?

> +static void
> +remove_pte_table(pte_t *pte_start, unsigned long addr,
> +			unsigned long end, bool direct)
> +{
> +	pte_t *pte;
> +
> +	pte = pte_start + pte_index(addr);
> +	for (; addr < end; addr += PAGE_SIZE, pte++) {
> +		if (!pte_present(*pte))
> +			continue;
> +
> +		if (!direct)
> +			free_pagetable(pte_page(*pte), 0);

This is really confusing. Here we're freeing a page of memory backing
the vmemmap, which it _not_ a page table.

At the least, can we please rename "direct" to something like
"free_backing", inverting its polarity?

> +		spin_lock(&init_mm.page_table_lock);
> +		pte_clear(&init_mm, addr, pte);
> +		spin_unlock(&init_mm.page_table_lock);
> +	}
> +}

Rather than explicitly using pte_index(), the usual style for arm64 is
to pass the pmdp in and use pte_offset_kernel() to find the relevant
ptep, e.g.

static void remove pte_table(pmd_t *pmdp, unsigned long addr,
			     unsigned long end, bool direct)
{
	pte_t *ptep = pte_offset_kernel(pmdp, addr);

	do {
		if (!pte_present(*ptep)
			continue;

		...

	} while (ptep++, addr += PAGE_SIZE, addr != end);
}

... with similar applying at all levels.

Thanks,
Mark.

