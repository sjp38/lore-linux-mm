Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87A09280249
	for <linux-mm@kvack.org>; Sun, 12 Nov 2017 19:28:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r12so4088794pgu.9
        for <linux-mm@kvack.org>; Sun, 12 Nov 2017 16:28:36 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w71si14317445pfd.262.2017.11.12.16.28.34
        for <linux-mm@kvack.org>;
        Sun, 12 Nov 2017 16:28:34 -0800 (PST)
Date: Mon, 13 Nov 2017 09:28:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171113002833.GA18301@bbox>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Nov 10, 2017 at 01:26:35PM +0100, Michal Hocko wrote:
> On Fri 10-11-17 11:15:29, Michal Hocko wrote:
> > On Fri 10-11-17 09:19:33, Minchan Kim wrote:
> > > On Tue, Nov 07, 2017 at 09:54:53AM +0000, Wang Nan wrote:
> > > > tlb_gather_mmu(&tlb, mm, 0, -1) means gathering the whole virtual memory
> > > > space. In this case, tlb->fullmm is true. Some archs like arm64 doesn't
> > > > flush TLB when tlb->fullmm is true:
> > > > 
> > > >   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> > > > 
> > > > Which makes leaking of tlb entries.
> > > 
> > > That means soft-dirty which has used tlb_gather_mmu with fullmm could be
> > > broken via losing write-protection bit once it supports arm64 in future?
> > > 
> > > If so, it would be better to use TASK_SIZE rather than -1 in tlb_gather_mmu.
> > > Of course, it's a off-topic.
> > 
> > I wouldn't play tricks like that. And maybe the API itself could be more
> > explicit. E.g. add a lazy parameter which would allow arch specific code
> > to not flush if it is sure that nobody can actually stumble over missed
> > flush. E.g. the following?
> 
> This one has a changelog and even compiles on my crosscompile test
> ---
> From 7f0fcd2cab379ddac5611b2a520cdca8a77a235b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 10 Nov 2017 11:27:17 +0100
> Subject: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy
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
> problem [2].
> 
> Introduce an explicit lazy variant tlb_gather_mmu_lazy which allows the
> behavior arm64 implements for the fullmm case and replace it by an
> explicit lazy flag in the mmu_gather structure. exit_mmap path is then
> turned into the explicit lazy variant. Other architectures simply ignore
> the flag.
> 
> [1] http://lkml.kernel.org/r/20171106033651.172368-1-wangnan0@huawei.com
> [2] http://lkml.kernel.org/r/20171110001933.GA12421@bbox
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/arm/include/asm/tlb.h   |  3 ++-
>  arch/arm64/include/asm/tlb.h |  2 +-
>  arch/ia64/include/asm/tlb.h  |  3 ++-
>  arch/s390/include/asm/tlb.h  |  3 ++-
>  arch/sh/include/asm/tlb.h    |  2 +-
>  arch/um/include/asm/tlb.h    |  2 +-
>  include/asm-generic/tlb.h    |  6 ++++--
>  include/linux/mm_types.h     |  2 ++
>  mm/memory.c                  | 17 +++++++++++++++--
>  mm/mmap.c                    |  2 +-
>  10 files changed, 31 insertions(+), 11 deletions(-)
> 
> diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
> index d5562f9ce600..fe9042aee8e9 100644
> --- a/arch/arm/include/asm/tlb.h
> +++ b/arch/arm/include/asm/tlb.h
> @@ -149,7 +149,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
>  
>  static inline void
>  arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
> -			unsigned long start, unsigned long end)
> +			unsigned long start, unsigned long end,
> +			bool lazy)
> 

Thanks for the patch, Michal.
However, it would be nice to do it tranparently without asking
new flags from users.

When I read tlb_gather_mmu's description, fullmm is supposed to
be used only if there is no users and full address space.

That means we can do it API itself like this?

void arch_tlb_gather_mmu(...)

        tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
