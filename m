Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96AFC6B2F73
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:42:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so5936967pfi.10
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:42:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1-v6si6383445plq.352.2018.08.24.04.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 04:42:02 -0700 (PDT)
Date: Fri, 24 Aug 2018 13:41:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Message-ID: <20180824114158.GJ29735@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

On Thu 23-08-18 15:06:08, James Morse wrote:
[...]
> My best-guess is that pfn_valid_within() shouldn't be optimised out if
> ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.
> 
> Does something like this solve the problem?:
> ============================%<============================
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2dc52a..5e27095a15f4 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1295,7 +1295,7 @@ void memory_present(int nid, unsigned long start, unsigned
> long end);
>   * pfn_valid_within() should be used in this case; we optimise this away
>   * when we have no holes within a MAX_ORDER_NR_PAGES block.
>   */
> -#ifdef CONFIG_HOLES_IN_ZONE
> +#if defined(CONFIG_HOLES_IN_ZONE) || defined(CONFIG_ARCH_HAS_HOLES_MEMORYMODEL)
>  #define pfn_valid_within(pfn) pfn_valid(pfn)
>  #else
>  #define pfn_valid_within(pfn) (1)
> ============================%<============================

This is the first time I hear about CONFIG_ARCH_HAS_HOLES_MEMORYMODEL.
Why it doesn't imply CONFIG_HOLES_IN_ZONE?

> > I analyzed the assembler:
> > PageBuddy in move_freepages returns false
> > Then we call PageLRU, the macro calls PF_HEAD which is compound_page()
> > compound_page reads page->compound_head, it is 0xffffffffffffffff, so it
> > resturns 0xfffffffffffffffe - and accessing this address causes crash
> 
> Thanks!
> That wasn't straightforward to work out without the vmlinux.
> 
> Because you see all-ones, even in KVM, it looks like the struct page is being
> initialized like that deliberately... I haven't found where this might be happening.

It should be

sparse_add_one_section
#ifdef CONFIG_DEBUG_VM
	/*
	 * Poison uninitialized struct pages in order to catch invalid flags
	 * combinations.
	 */
	memset(memmap, PAGE_POISON_PATTERN, sizeof(struct page) * PAGES_PER_SECTION);
#endif

-- 
Michal Hocko
SUSE Labs
