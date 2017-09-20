Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 974236B02DE
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 19:21:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r83so6984868pfj.5
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:21:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l6si44179pgs.588.2017.09.20.16.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 16:21:18 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
Date: Wed, 20 Sep 2017 16:21:15 -0700
MIME-Version: 1.0
In-Reply-To: <20170920223452.vam3egenc533rcta@smitten>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 09/20/2017 03:34 PM, Tycho Andersen wrote:
>> I really have to wonder whether there are better ret2dir defenses than
>> this.  The allocator just seems like the *wrong* place to be doing this
>> because it's such a hot path.
> 
> This might be crazy, but what if we defer flushing of the kernel
> ranges until just before we return to userspace? We'd still manipulate
> the prot/xpfo bits for the pages, but then just keep a list of which
> ranges need to be flushed, and do the right thing before we return.
> This leaves a little window between the actual allocation and the
> flush, but userspace would need another thread in its threadgroup to
> predict the next allocation, write the bad stuff there, and do the
> exploit all in that window.

I think the common case is still that you enter the kernel, allocate a
single page (or very few) and then exit.  So, you don't really reduce
the total number of flushes.

Just think of this in terms of IPIs to do the remote TLB flushes.  A CPU
can do roughly 1 million page faults and allocations a second.  Say you
have a 2-socket x 28-core x 2 hyperthead system = 112 CPU threads.
That's 111M IPI interrupts/second, just for the TLB flushes, *ON* *EACH*
*CPU*.

I think the only thing that will really help here is if you batch the
allocations.  For instance, you could make sure that the per-cpu-pageset
lists always contain either all kernel or all user data.  Then remap the
entire list at once and do a single flush after the entire list is consumed.

>> Why do you even bother keeping large pages around?  Won't the entire
>> kernel just degrade to using 4k everywhere, eventually?
> 
> Isn't that true of large pages in general? Is there something about
> xpfo that makes this worse? I thought this would only split things if
> they had already been split somewhere else, and the protection can't
> apply to the whole huge page.

Even though the kernel gives out 4k pages, it still *maps* them in the
kernel linear direct map with the largest size available.  My 16GB
laptop, for instance, has 3GB of 2MB transparent huge pages, but the
rest is used as 4k pages.  Yet, from /proc/meminfo:

DirectMap4k:      665280 kB
DirectMap2M:    11315200 kB
DirectMap1G:     4194304 kB

Your code pretty much forces 4k pages coming out of the allocator to be
mapped with 4k mappings.
>>> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
>>> +{
>>> +	int level;
>>> +	unsigned long size, kaddr;
>>> +
>>> +	kaddr = (unsigned long)page_address(page);
>>> +
>>> +	if (unlikely(!lookup_address(kaddr, &level))) {
>>> +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr, level);
>>> +		return;
>>> +	}
>>> +
>>> +	switch (level) {
>>> +	case PG_LEVEL_4K:
>>> +		size = PAGE_SIZE;
>>> +		break;
>>> +	case PG_LEVEL_2M:
>>> +		size = PMD_SIZE;
>>> +		break;
>>> +	case PG_LEVEL_1G:
>>> +		size = PUD_SIZE;
>>> +		break;
>>> +	default:
>>> +		WARN(1, "xpfo: unsupported page level %x\n", level);
>>> +		return;
>>> +	}
>>> +
>>> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
>>> +}
>>
>> I'm not sure flush_tlb_kernel_range() is the best primitive to be
>> calling here.
>>
>> Let's say you walk the page tables and find level=PG_LEVEL_1G.  You call
>> flush_tlb_kernel_range(), you will be above
>> tlb_single_page_flush_ceiling, and you will do a full TLB flush.  But,
>> with a 1GB page, you could have just used a single INVLPG and skipped
>> the global flush.
>>
>> I guess the cost of the IPI is way more than the flush itself, but it's
>> still a shame to toss the entire TLB when you don't have to.
> 
> Ok, do you think it's worth making a new helper for others to use? Or
> should I just keep the logic in this function?

I'd just leave it in place.  Most folks already have a PTE when they do
the invalidation, so this is a bit of a weirdo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
