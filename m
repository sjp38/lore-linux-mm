Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77F086B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:00:01 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id z81so311124oig.16
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:00:01 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f186si9673686oig.444.2017.11.28.10.59.59
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 11:00:00 -0800 (PST)
Date: Tue, 28 Nov 2017 19:00:01 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH] arch, mm: introduce arch_tlb_gather_mmu_exit
Message-ID: <20171128190001.GD8187@arm.com>
References: <20171123090236.18574-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123090236.18574-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrea Argangeli <andrea@kernel.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Thu, Nov 23, 2017 at 10:02:36AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1") has
> introduced an optimization to not flush tlb when we are tearing the
> whole address space down. Will goes on to explain
> 
> : Basically, we tag each address space with an ASID (PCID on x86) which
> : is resident in the TLB. This means we can elide TLB invalidation when
> : pulling down a full mm because we won't ever assign that ASID to
> : another mm without doing TLB invalidation elsewhere (which actually
> : just nukes the whole TLB).
> 
> This all is nice but tlb_gather users are not aware of that and this can
> actually cause some real problems. E.g. the oom_reaper tries to reap the
> whole address space but it might race with threads accessing the memory [1].
> It is possible that soft-dirty handling might suffer from the same
> problem [2] as soon as it starts supporting the feature.
> 
> Introduce an explicit exit variant tlb_gather_mmu_exit which allows the
> behavior arm64 implements for the fullmm case and replace it by an
> explicit exit flag in the mmu_gather structure. exit_mmap path is then
> turned into the explicit exit variant. Other architectures simply ignore
> the flag.
> 
> [1] http://lkml.kernel.org/r/20171106033651.172368-1-wangnan0@huawei.com
> [2] http://lkml.kernel.org/r/20171110001933.GA12421@bbox
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> I am sending this as an RFC because I am not fully familiar with the tlb
> gather arch implications, espacially the semantic of fullmm. Therefore
> I might duplicate some of its functionality. I hope people on the CC
> list will help me to sort this out.
> 
> Comments? Objections?

I can't think of a case where we'd have exit set but not be doing the
fullmm, in which case I'd be inclined to remove the last two parameters
from tlb_gather_mmu_exit.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
