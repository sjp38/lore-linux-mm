Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA5D6B6980
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 15:33:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v9-v6so670520ply.13
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 12:33:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7-v6si19587927pgl.441.2018.09.03.12.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 12:33:26 -0700 (PDT)
Date: Mon, 3 Sep 2018 21:33:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Message-ID: <20180903193322.GD14951@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
 <20180824114158.GJ29735@dhcp22.suse.cz>
 <541193a6-2bce-f042-5bb2-88913d5f1047@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <541193a6-2bce-f042-5bb2-88913d5f1047@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Wed 29-08-18 18:37:55, James Morse wrote:
> Hi Michal,
> 
> (CC: +Ard)
> 
> On 24/08/18 12:41, Michal Hocko wrote:
> > On Thu 23-08-18 15:06:08, James Morse wrote:
> > [...]
> >> My best-guess is that pfn_valid_within() shouldn't be optimised out if
> > ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.
> >>
> >> Does something like this solve the problem?:
> >> ============================%<============================
> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index 32699b2dc52a..5e27095a15f4 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -1295,7 +1295,7 @@ void memory_present(int nid, unsigned long start, unsigned
> >> long end);
> >>   * pfn_valid_within() should be used in this case; we optimise this away
> >>   * when we have no holes within a MAX_ORDER_NR_PAGES block.
> >>   */
> >> -#ifdef CONFIG_HOLES_IN_ZONE
> >> +#if defined(CONFIG_HOLES_IN_ZONE) || defined(CONFIG_ARCH_HAS_HOLES_MEMORYMODEL)
> >>  #define pfn_valid_within(pfn) pfn_valid(pfn)
> >>  #else
> >>  #define pfn_valid_within(pfn) (1)
> >> ============================%<============================
> 
> After plenty of greping, git-archaeology and help from others, I think I've a
> clearer picture of what these options do.
> 
> 
> Please correct me if I've explained something wrong here:
> 
> > This is the first time I hear about CONFIG_ARCH_HAS_HOLES_MEMORYMODEL.
> 
> The comment in include/linux/mmzone.h describes this as relevant when parts the
> memmap have been free()d. This would happen on systems where memory is smaller
> than a sparsemem-section, and the extra struct pages are expensive.
> pfn_valid() on these systems returns true for the whole sparsemem-section, so an
> extra memmap_valid_within() check is needed.

I have hard times to find an actual code that does this partial memmap
initialization.

> This is independent of nomap, and isn't relevant on arm64 as our pfn_valid()
> always tests the page in memblock due to nomap pages, which can occur anywhere.
> (I will propose a patch removing ARCH_HAS_HOLES_MEMORYMODEL for arm64.)

It seems ARCH_HAS_HOLES_MEMORYMODEL is only defined for arm and arm64.
Is it really needed for arm?

> HOLES_IN_ZONE is similar, if some memory is smaller than MAX_ORDER_NR_PAGES,
> possibly due to nomap holes.
> 
> 6d526ee26ccd only enabled it for NUMA systems on arm64, because the NUMA code
> was first to fall foul of this, but there is nothing NUMA specific about nomap
> holes within a MAX_ORDER_NR_PAGES region.
> 
> I'm convinced arm64 should always enable HOLES_IN_ZONE because nomap pages can
> occur anywhere. I'll post a fix.
> 
> 
> Is it valid to have HOLES_IN_ZONE and !HAVE_ARCH_PFN_VALID?
> This would mean pfn_valid_within() is necessary, but pfn_valid() is only looking
> at sparse-sections. It looks like ia64 and mips:CAVIUM_OCTEON_SOC are both
> configured like this...

this smells suspicious and I wouldn't be surprised if this was some
leftover from the past.
-- 
Michal Hocko
SUSE Labs
