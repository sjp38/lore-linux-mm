Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6558E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:25:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w42-v6so6740135eda.23
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 02:25:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c40-v6si4566991edb.152.2018.09.10.02.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 02:25:12 -0700 (PDT)
Date: Mon, 10 Sep 2018 11:25:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arm64: mm: always enable CONFIG_HOLES_IN_ZONE
Message-ID: <20180910092511.GC10951@dhcp22.suse.cz>
References: <20180830150532.22745-1-james.morse@arm.com>
 <20180903194731.GE14951@dhcp22.suse.cz>
 <1310a17b-214a-b840-d87b-42b799b623d2@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310a17b-214a-b840-d87b-42b799b623d2@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Fri 07-09-18 18:47:24, James Morse wrote:
> Hi Michal,
> 
> On 03/09/18 20:47, Michal Hocko wrote:
> > On Thu 30-08-18 16:05:32, James Morse wrote:
> >> Commit 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
> >> only enabled HOLES_IN_ZONE for NUMA systems because the NUMA code was
> >> choking on the missing zone for nomap pages. This problem doesn't just
> >> apply to NUMA systems.
> >>
> >> If the architecture doesn't set HAVE_ARCH_PFN_VALID, pfn_valid() will
> >> return true if the pfn is part of a valid sparsemem section.
> >>
> >> When working with multiple pages, the mm code uses pfn_valid_within()
> >> to test each page it uses within the sparsemem section is valid. On
> >> most systems memory comes in MAX_ORDER_NR_PAGES chunks which all
> >> have valid/initialised struct pages. In this case pfn_valid_within()
> >> is optimised out.
> >>
> >> Systems where this isn't true (e.g. due to nomap) should set
> >> HOLES_IN_ZONE and provide HAVE_ARCH_PFN_VALID so that mm tests each
> >> page as it works with it.
> >>
> >> Currently non-NUMA arm64 systems can't enable HOLES_IN_ZONE, leading to
> >> VM_BUG_ON()
> 
> [...]
> 
> >> Remove the NUMA dependency.
> >>
> >> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> >> Link: https://www.spinics.net/lists/arm-kernel/msg671851.html
> >> Fixes: 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
> >> CC: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> >> Signed-off-by: James Morse <james.morse@arm.com>
> > 
> > OK. I guess you are also going to post a patch to drop
> > ARCH_HAS_HOLES_MEMORYMODEL, right?
> 
> Yes:
> https://marc.info/?l=linux-arm-kernel&m=153572884121769&w=2
> 
> After all this I'm suspicious about arm64's support for FLATMEM given we always
> set HAVE_ARCH_PFN_VALID.
> 
> 
> > Anyway
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> 
> 
> > I wish we could simplify the pfn validation code a bit. I find
> > pfn_valid_within quite confusing and I would bet it is not used
> > consistently.
> 
> > This will require a non trivial audit. I am wondering
> > whether we really need to make the code more complicated rather than
> > simply establish a contract that we always have a pageblock worth of
> > struct pages always available. Even when there is no physical memory
> > backing it. Such a page can be reserved and never used by the page
> > allocator. pfn walkers should back off for reserved pages already.
> 
> Is PG_Reserved really where this stops?
> Going through the mail archive it looks like whenever this crops up on arm64 the
> issues are with nomap pages needing a 'correct' node or zone,  where-as we would
> prefer it if linux knew nothing about them.

Well, I will not pretend I have a clear view on early mem init code. I
have seen so many surprises lately that I just gave up. I can clearly
see why you want nomap pages to have no backing struct pages. It just
makes sense but I strongly suspect that pfn_valid_within is not the
right approach. If for no other reason it is basically unmaintainable
interface. All/Most pfn walkers should use it but I do not see this
being the case. I strongly suspect that initializing sub section memmaps
is quite wastefull on its own (especially with VMEMAP) because you are
losing the large kernel pagetables for those memmaps. So having a full
section worth of initialized memory and then reserving holes should
result in a better maintainable code because pfn_valid_within shouldn't
be really needed. But I might easily miss something subtle here.
Especially arm specific.
-- 
Michal Hocko
SUSE Labs
