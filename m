Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3C26B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:04:52 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id 22-v6so2345702ywd.15
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:04:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a7-v6si7745402oii.235.2018.07.24.08.04.50
        for <linux-mm@kvack.org>;
        Tue, 24 Jul 2018 08:04:50 -0700 (PDT)
Date: Tue, 24 Jul 2018 16:04:49 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 02/10] mm: workingset: tell cache transitions from
 workingset thrashing
Message-ID: <20180724150448.GA25412@arm.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-3-hannes@cmpxchg.org>
 <CAK8P3a3Nsmt54-ed_gWNev3CBS6_Sv5QGOw4G0sY4ZXOi1R4_Q@mail.gmail.com>
 <20180723152323.GA3699@cmpxchg.org>
 <CAK8P3a15K-TXYuFX-ZsJiroqA1GWX2XS4ioZSjcjJYgh1b_xSA@mail.gmail.com>
 <20180723162735.GA5980@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723162735.GA5980@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Suren Baghdasaryan <surenb@google.com>, Mike Galbraith <efault@gmx.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Linux-MM <linux-mm@kvack.org>, Vinayak Menon <vinmenon@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Shakeel Butt <shakeelb@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christopher Lameter <cl@linux.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Jul 23, 2018 at 12:27:35PM -0400, Johannes Weiner wrote:
> On Mon, Jul 23, 2018 at 05:35:35PM +0200, Arnd Bergmann wrote:
> > On Mon, Jul 23, 2018 at 5:23 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > > index 1b18b4722420..72c9b6778b0a 100644
> > > --- a/arch/arm64/mm/init.c
> > > +++ b/arch/arm64/mm/init.c
> > > @@ -611,11 +611,13 @@ void __init mem_init(void)
> > >         BUILD_BUG_ON(TASK_SIZE_32                       > TASK_SIZE_64);
> > >  #endif
> > >
> > > +#ifndef CONFIG_SPARSEMEM_VMEMMAP
> > >         /*
> > 
> > I tested it on two broken configurations, and found that you have
> > a typo here, it should be 'ifdef', not 'ifndef'. With that change, it
> > seems to build fine.
> > 
> > Tested-by: Arnd Bergmann <arnd@arndb.de>
> 
> Thanks for testing it, I don't have a cross-compile toolchain set up.
> 
> ---

Thanks Arnd, Johannes. I can pick this up for -rc7 via the arm64 tree,
unless it's already queued elsewhere?

Will

> From 34c4c4549f09f971d2d391a8d652d56cb9b05475 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 23 Jul 2018 10:18:23 -0400
> Subject: [PATCH] arm64: fix vmemmap BUILD_BUG_ON() triggering on !vmemmap
>  setups
> 
> Arnd reports the following arm64 randconfig build error with the PSI
> patches that add another page flag:
> 
>   /git/arm-soc/arch/arm64/mm/init.c: In function 'mem_init':
>   /git/arm-soc/include/linux/compiler.h:357:38: error: call to
>   '__compiletime_assert_618' declared with attribute error: BUILD_BUG_ON
>   failed: sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT)
> 
> The additional page flag causes other information stored in
> page->flags to get bumped into their own struct page member:
> 
>   #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <=
>   BITS_PER_LONG - NR_PAGEFLAGS
>   #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
>   #else
>   #define LAST_CPUPID_WIDTH 0
>   #endif
> 
>   #if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
>   #define LAST_CPUPID_NOT_IN_PAGE_FLAGS
>   #endif
> 
> which in turn causes the struct page size to exceed the size set in
> STRUCT_PAGE_MAX_SHIFT. This value is an an estimate used to size the
> VMEMMAP page array according to address space and struct page size.
> 
> However, the check is performed - and triggers here - on a !VMEMMAP
> config, which consumes an additional 22 page bits for the sparse
> section id. When VMEMMAP is enabled, those bits are returned, cpupid
> doesn't need its own member, and the page passes the VMEMMAP check.
> 
> Restrict that check to the situation it was meant to check: that we
> are sizing the VMEMMAP page array correctly.
> 
> Says Arnd:
> 
>     Further experiments show that the build error already existed before,
>     but was only triggered with larger values of CONFIG_NR_CPU and/or
>     CONFIG_NODES_SHIFT that might be used in actual configurations but
>     not in randconfig builds.
> 
>     With longer CPU and node masks, I could recreate the problem with
>     kernels as old as linux-4.7 when arm64 NUMA support got added.
> 
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Tested-by: Arnd Bergmann <arnd@arndb.de>
> Cc: stable@vger.kernel.org
> Fixes: 1a2db300348b ("arm64, numa: Add NUMA support for arm64 platforms.")
> Fixes: 3e1907d5bf5a ("arm64: mm: move vmemmap region right below the linear region")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  arch/arm64/mm/init.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 1b18b4722420..86d9f9d303b0 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -611,11 +611,13 @@ void __init mem_init(void)
>  	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
>  #endif
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
>  	/*
>  	 * Make sure we chose the upper bound of sizeof(struct page)
> -	 * correctly.
> +	 * correctly when sizing the VMEMMAP array.
>  	 */
>  	BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));
> +#endif
>  
>  	if (PAGE_SIZE >= 16384 && get_num_physpages() <= 128) {
>  		extern int sysctl_overcommit_memory;
> -- 
> 2.18.0
> 
