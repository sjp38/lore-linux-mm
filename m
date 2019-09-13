Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DA03C4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6263C2084F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:10:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6263C2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F11CF6B0005; Fri, 13 Sep 2019 06:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC35A6B0006; Fri, 13 Sep 2019 06:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D89EB6B0007; Fri, 13 Sep 2019 06:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id AEAF16B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:10:04 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 57324485A
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:10:04 +0000 (UTC)
X-FDA: 75929476728.24.wrist03_3a7c57c2aff4c
X-HE-Tag: wrist03_3a7c57c2aff4c
X-Filterd-Recvd-Size: 9648
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:10:01 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CB12C28;
	Fri, 13 Sep 2019 03:10:00 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E3CFA3F59C;
	Fri, 13 Sep 2019 03:09:57 -0700 (PDT)
Date: Fri, 13 Sep 2019 11:09:55 +0100
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
Message-ID: <20190913100955.GB55043@arrakis.emea.arm.com>
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
 <20190912201517.GB1068@C02TF0J2HF1T.local>
 <ce127798-3863-0f28-de04-84b177418310@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce127798-3863-0f28-de04-84b177418310@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 11:28:01AM +0530, Anshuman Khandual wrote:
> On 09/13/2019 01:45 AM, Catalin Marinas wrote:
> > On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
> >> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
> >>  void vmemmap_free(unsigned long start, unsigned long end,
> >>  		struct vmem_altmap *altmap)
> >>  {
> >> +#ifdef CONFIG_MEMORY_HOTPLUG
> >> +	/*
> >> +	 * FIXME: We should have called remove_pagetable(start, end, true).
> >> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
> >> +	 * page table entries. Removing vmemmap range page table pages here
> >> +	 * can potentially conflict with a concurrent vmalloc() allocation.
> >> +	 *
> >> +	 * This is primarily because vmalloc() does not take init_mm ptl for
> >> +	 * the entire page table walk and it's modification. Instead it just
> >> +	 * takes the lock while allocating and installing page table pages
> >> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
> >> +	 * entry via memory hot remove can cause vmalloc() kernel page table
> >> +	 * walk pointers to be invalid on the fly which can cause corruption
> >> +	 * or worst, a crash.
> >> +	 *
> >> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
> >> +	 * do not overlap at any intermediate level kernel page table entry.
> >> +	 */
> >> +	unmap_hotplug_range(start, end, true);
> >> +	if (!vmalloc_vmemmap_overlap)
> >> +		free_empty_tables(start, end);
> >> +#endif
> >>  }
> > 
> > So, I see the risk with overlapping and I guess for some kernel
> > configurations (PAGE_SIZE == 64K) we may not be able to avoid it. If we
> 
> Did not see 64K config options to have overlap, do you suspect they might ?
> After the 52 bit KVA series has been merged, following configurations have
> the vmalloc-vmemmap range overlap problem.
> 
> - 4K  page size with 48 bit VA space
> - 16K page size with 48 bit VA space

OK. I haven't checked, so it was just a guess that 64K has this problem
since the pgd entry coverage is fairly large.

> > can, that's great, otherwise could we rewrite the above functions to
> > handle floor and ceiling similar to free_pgd_range()? (I wonder how this
> > function works if you called it on init_mm and kernel address range). By
> 
> Hmm, never tried that. Are you wondering if this can be used directly ?
> There are two distinct elements which make it very specific to user page
> tables, mmu_gather based TLB tracking and mm->pgtable_bytes accounting
> with mm_dec_nr_pxx().

Ah, I missed the mm_dec_nr_*(). So I don't think it would work directly.
We could, however, use the same approach for kernel page tables.

> > having the vmemmap start/end information it avoids freeing partially
> > filled page table pages.
> 
> Did you mean page table pages which can partially overlap with vmalloc ?

Overlapping with the vmalloc range, not necessarily with a mapped
vmalloc area.

> The problem (race) is not because of the inability to deal with partially
> filled table. We can handle that correctly as explained below [1]. The
> problem is with inadequate kernel page table locking during vmalloc()
> which might be accessing intermediate kernel page table pointers which is
> being freed with free_empty_tables() concurrently. Hence we cannot free
> any page table page which can ever have entries from vmalloc() range.

The way you deal with the partially filled table in this patch is to
avoid freeing if there is a non-empty entry (!p*d_none()). This is what
causes the race with vmalloc. If you simply avoid freeing a pmd page,
for example, if the range floor/ceiling is not aligned to PUD_SIZE,
irrespective of whether the other entries are empty or not, you
shouldn't have this problem. You do free the pte page if the range is
aligned to PMD_SIZE but in this case it wouldn't overlap with the
vmalloc space. That's how free_pgd_range() works.

We may have some pgtable pages not freed at both ends of the range
(maximum 6 in total) but I don't really see this an issue. They could be
reused if something else gets mapped in that range.

> Though not completely sure, whether I really understood the suggestion above
> with respect to the floor-ceiling mechanism as in free_pgd_range(). Are you
> suggesting that we should only attempt to free up those vmemmap range page
> table pages which *definitely* could never overlap with vmalloc by working
> on a modified (i.e cut down with floor-ceiling while avoiding vmalloc range
> at each level) vmemmap range instead ?

You can ignore the overlap check altogether, only free the page tables
with floor/ceiling set to the start/size passed to arch_remove_memory()
and vmemmap_free().

> This can be one restrictive version of the function
> free_empty_tables() called in case there is an overlap. So we will
> maintain two versions for free_empty_tables(). Please correct me if
> any the above assumptions or understanding is wrong.

I'd rather have a single version of free_empty_tables(). As I said
above, the only downside is that a partially filled pgtable page would
not be freed even though the other entries are empty.

> But yes, with this we should be able to free up some possible empty page
> table pages which were being left out in the current proposal when overlap
> happens.
> 
> [1] Skipping partially filled page tables
> 
> All free_pXX_table() functions take care in avoiding freeing partially filled
> page table pages whether they represent or ever represented linear or vmemmap
> or vmalloc mapping in init_mm. They go over each individual entry in a given
> page table making sure that each of them checks as pXX_none() before freeing
> the entire page table page.

Yes but that's what's causing the race with a vmalloc trying to create
such entries.

> > Another question: could we do the page table and the actual vmemmap
> > pages freeing in a single pass (sorry if this has been discussed
> > before)?
> 
> We could and some initial versions (till V5) of the series had that in fact.
> Initially Mark Rutland had suggested to do this in two passes. Some extracts
> from the previous discussion.
> 
> https://lkml.org/lkml/2019/5/30/1159
> 
> -----------------------
> Looking at this some more, I don't think this is quite right, and tI
> think that structure of the free_*() and remove_*() functions makes this
> unnecessarily hard to follow. We should aim for this to be obviously
> correct.
> 
> The x86 code is the best template to follow here. As mentioned
> previously, I'm fairly certain it's not entirely correct (e.g. due to
> missing TLB maintenance), and we've already diverged a fair amount in
> fixing up obvious issues, so we shouldn't aim to mirror it.
> 
> I think that the structure of unmap_region() is closer to what we want
> here -- do one pass to unmap leaf entries (and freeing the associated
> memory if unmapping the vmemmap), then do a second pass cleaning up any
> empty tables.
> ----------------------
> 
> Apart from the fact that two passes over the page table is cleaner and gives
> us more granular and modular infrastructure to use for later purposes, it is
> also a necessity in dealing with vmalloc-vmemmap overlap. free_empty_tables()
> which is the second pass, can be skipped cleanly when overlap is detected.

I'm fine with two passes for unmap and pgtable free for the time being
and if they look fairly similar in a feature version, we can think of
merging them. But for now, stick with two passes. The unmapping one in
this patchset I think seems fine (though I haven't looked in detail).

There is also a race with ptdump that I haven't looked into.

-- 
Catalin

