Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E00406B02A9
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:57:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o60-v6so3079800edd.13
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:57:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j18-v6si8257469edf.210.2018.07.25.05.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 05:57:43 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:57:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Message-ID: <20180725125741.GL28386@dhcp22.suse.cz>
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725023728.44630-1-cannonmatthews@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>, Huang Ying <ying.huang@intel.com>

[Cc Huang]
On Tue 24-07-18 19:37:28, Cannon Matthews wrote:
> Reimplement clear_gigantic_page() to clear gigabytes pages using the
> non-temporal streaming store instructions that bypass the cache
> (movnti), since an entire 1GiB region will not fit in the cache anyway.
> 
> Doing an mlock() on a 512GiB 1G-hugetlb region previously would take on
> average 134 seconds, about 260ms/GiB which is quite slow. Using `movnti`
> and optimizing the control flow over the constituent small pages, this
> can be improved roughly by a factor of 3-4x, with the 512GiB mlock()
> taking only 34 seconds on average, or 67ms/GiB.
> 
> The assembly code for the __clear_page_nt routine is more or less
> taken directly from the output of gcc with -O3 for this function with
> some tweaks to support arbitrary sizes and moving memory barriers:
> 
> void clear_page_nt_64i (void *page)
> {
>   for (int i = 0; i < GiB /sizeof(long long int); ++i)
>     {
>       _mm_stream_si64 (((long long int*)page) + i, 0);
>     }
>   sfence();
> }
> 
> In general I would love to hear any thoughts and feedback on this
> approach and any ways it could be improved.

Well, I like it. In fact 2MB pages are in a similar situation even
though they fit into the cache so the problem is not that pressing.
Anyway if you are a standard DB wokrload which simply preallocates large
hugetlb shared files then it would help. Huang has gone a different
direction c79b57e462b5 ("mm: hugetlb: clear target sub-page last when
clearing huge page") and I was asking about using the mechanism you are
proposing back then http://lkml.kernel.org/r/20170821115235.GD25956@dhcp22.suse.cz
I've got an explanation http://lkml.kernel.org/r/87h8x0whfs.fsf@yhuang-dev.intel.com
which hasn't really satisfied me but I didn't really want to block the
obvious optimization. The similar approach has been proposed for GB
pages IIRC but I do not see it in linux-next so I am not sure what
happened with it.

Is there any reason to use a different scheme for GB an 2MB pages? Why
don't we settle with movnti for both? The first access will be a miss
but I am not really sure it matters all that much.

Keeping the rest of the email for reference

> Some specific questions:
> 
> - What is the appropriate method for defining an arch specific
> implementation like this, is the #ifndef code sufficient, and did stuff
> land in appropriate files?
> 
> - Are there any obvious pitfalls or caveats that have not been
> considered? In particular the iterator over mem_map_next() seemed like a
> no-op on x86, but looked like it could be important in certain
> configurations or architectures I am not familiar with.
> 
> - Is there anything that could be improved about the assembly code? I
> originally wrote it in C and don't have much experience hand writing x86
> asm, which seems riddled with optimization pitfalls.
> 
> - Is the highmem codepath really necessary? would 1GiB pages really be
> of much use on a highmem system? We recently removed some other parts of
> the code that support HIGHMEM for gigantic pages (see:
> http://lkml.kernel.org/r/20180711195913.1294-1-mike.kravetz@oracle.com)
> so this seems like a logical continuation.
> 
> - The calls to cond_resched() have been reduced from between every 4k
> page to every 64, as between all of the 256K page seemed overly
> frequent.  Does this seem like an appropriate frequency? On an idle
> system with many spare CPUs it get's rescheduled typically once or twice
> out of the 4096 times it calls cond_resched(), which seems like it is
> maybe the right amount, but more insight from a scheduling/latency point
> of view would be helpful. See the "Tested:" section below for some more data.
> 
> - Any other thoughts on the change overall and ways that this could
> be made more generally useful, and designed to be easily extensible to
> other platforms with non-temporal instructions and 1G pages, or any
> additional pitfalls I have not thought to consider.
> 
> Tested:
> 	Time to `mlock()` a 512GiB region on broadwell CPU
> 				AVG time (s)	% imp.	ms/page
> 	clear_page_erms		133.584		-	261
> 	clear_page_nt		34.154		74.43%	67
> 
> For a more in depth look at how the frequency we call cond_resched() affects
> the time this takes, I tested both on an idle system, and a system running
> `stress -c N` program to overcommit CPU to ~115%, and ran 10 replications of
> the 512GiB mlock test.
> 
> Unfortunately there wasn't as clear of a pattern as I had hoped. On an
> otherwise idle system there is no substantive difference different values of
> PAGES_BETWEEN_RESCHED.
> 
> On a stressed system, there appears to be a pattern, that resembles something
> of a bell curve: constantly offering to yield, or never yielding until the end
> produces the fastest results, but yielding infrequently increases latency to a
> slight degree.
> 
> That being said, it's not clear this is actually a significant difference, the
> std deviation is occasionally quite high, and perhaps a larger sample set would
> be more informative. From looking at the log messages indicating the number of
> times cond_resched() returned 1, there wasn't that much variance, with it
> usually being 1 or 2 when idle, and only increasing to ~4-7 when stressed.
> 
> 
> 	PAGES_BETWEEN_RESCHED	state	AVG	stddev
> 	1	4 KiB		idle	36.086	1.920
> 	16	64 KiB		idle	34.797	1.702
> 	32	128 KiB		idle	35.104	1.752
> 	64	256 KiB		idle	34.468	0.661
> 	512	2048 KiB	idle	36.427	0.946
> 	2048	8192 KiB	idle	34.988	2.406
> 	262144	1048576 KiB	idle	36.792	0.193
> 	infin	512 GiB		idle	38.817	0.238  [causes softlockup]
> 	1	4 KiB		stress 	55.562	0.661
> 	16	64 KiB		stress 	57.509	0.248
> 	32	128 KiB		stress 	69.265	3.913
> 	64	256 KiB		stress 	70.217	4.534
> 	512	2048 KiB	stress 	68.474	1.708
> 	2048	8192 KiB	stress 	70.806	1.068
> 	262144	1048576 KiB	stress 	55.217	1.184
> 	infin	512 GiB		stress 	55.062	0.291  [causes softlockup]
> 
> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
> ---
> 
> v2:
>  - Removed question about SSE2 Availability.
>  - Changed #ifndef symbol to match function
>  - removed spurious newlines
>  - Expanded Tested: field to include additional timings for different sizes
>    between cond_resched().
> 
>  arch/x86/include/asm/page_64.h     |  5 +++++
>  arch/x86/lib/Makefile              |  2 +-
>  arch/x86/lib/clear_gigantic_page.c | 29 +++++++++++++++++++++++++++++
>  arch/x86/lib/clear_page_64.S       | 20 ++++++++++++++++++++
>  include/linux/mm.h                 |  3 +++
>  mm/memory.c                        |  4 +++-
>  6 files changed, 61 insertions(+), 2 deletions(-)
>  create mode 100644 arch/x86/lib/clear_gigantic_page.c
> 
> diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
> index 939b1cff4a7b..177196d6abc7 100644
> --- a/arch/x86/include/asm/page_64.h
> +++ b/arch/x86/include/asm/page_64.h
> @@ -56,6 +56,11 @@ static inline void clear_page(void *page)
> 
>  void copy_page(void *to, void *from);
> 
> +#ifndef __clear_page_nt
> +void __clear_page_nt(void *page, u64 page_size);
> +#define __clear_page_nt __clear_page_nt
> +#endif  /* __clear_page_nt */
> +
>  #endif	/* !__ASSEMBLY__ */
> 
>  #ifdef CONFIG_X86_VSYSCALL_EMULATION
> diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
> index 25a972c61b0a..4ba395234088 100644
> --- a/arch/x86/lib/Makefile
> +++ b/arch/x86/lib/Makefile
> @@ -44,7 +44,7 @@ endif
>  else
>          obj-y += iomap_copy_64.o
>          lib-y += csum-partial_64.o csum-copy_64.o csum-wrappers_64.o
> -        lib-y += clear_page_64.o copy_page_64.o
> +        lib-y += clear_page_64.o copy_page_64.o clear_gigantic_page.o
>          lib-y += memmove_64.o memset_64.o
>          lib-y += copy_user_64.o
>  	lib-y += cmpxchg16b_emu.o
> diff --git a/arch/x86/lib/clear_gigantic_page.c b/arch/x86/lib/clear_gigantic_page.c
> new file mode 100644
> index 000000000000..0d51e38b5be0
> --- /dev/null
> +++ b/arch/x86/lib/clear_gigantic_page.c
> @@ -0,0 +1,29 @@
> +#include <asm/page.h>
> +
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/sched.h>
> +
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> +#define PAGES_BETWEEN_RESCHED 64
> +void clear_gigantic_page(struct page *page,
> +				unsigned long addr,
> +				unsigned int pages_per_huge_page)
> +{
> +	int i;
> +	void *dest = page_to_virt(page);
> +	int resched_count = 0;
> +
> +	BUG_ON(pages_per_huge_page % PAGES_BETWEEN_RESCHED != 0);
> +	BUG_ON(!dest);
> +
> +	for (i = 0; i < pages_per_huge_page; i += PAGES_BETWEEN_RESCHED) {
> +		__clear_page_nt(dest + (i * PAGE_SIZE),
> +				PAGES_BETWEEN_RESCHED * PAGE_SIZE);
> +		resched_count += cond_resched();
> +	}
> +	/* __clear_page_nt requrires and `sfence` barrier. */
> +	wmb();
> +	pr_debug("clear_gigantic_page: rescheduled %d times\n", resched_count);
> +}
> +#endif
> diff --git a/arch/x86/lib/clear_page_64.S b/arch/x86/lib/clear_page_64.S
> index 88acd349911b..81a39804ac72 100644
> --- a/arch/x86/lib/clear_page_64.S
> +++ b/arch/x86/lib/clear_page_64.S
> @@ -49,3 +49,23 @@ ENTRY(clear_page_erms)
>  	ret
>  ENDPROC(clear_page_erms)
>  EXPORT_SYMBOL_GPL(clear_page_erms)
> +
> +/*
> + * Zero memory using non temporal stores, bypassing the cache.
> + * Requires an `sfence` (wmb()) afterwards.
> + * %rdi - destination.
> + * %rsi - page size. Must be 64 bit aligned.
> +*/
> +ENTRY(__clear_page_nt)
> +	leaq	(%rdi,%rsi), %rdx
> +	xorl	%eax, %eax
> +	.p2align 4,,10
> +	.p2align 3
> +.L2:
> +	movnti	%rax, (%rdi)
> +	addq	$8, %rdi
> +	cmpq	%rdx, %rdi
> +	jne	.L2
> +	ret
> +ENDPROC(__clear_page_nt)
> +EXPORT_SYMBOL(__clear_page_nt)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9ffe380..d10ac4e7ef6a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2729,6 +2729,9 @@ enum mf_action_page_type {
>  };
> 
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> +extern void clear_gigantic_page(struct page *page,
> +			 unsigned long addr,
> +			 unsigned int pages_per_huge_page);
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr_hint,
>  			    unsigned int pages_per_huge_page);
> diff --git a/mm/memory.c b/mm/memory.c
> index 7206a634270b..e43a3a446380 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4568,7 +4568,8 @@ EXPORT_SYMBOL(__might_fault);
>  #endif
> 
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> -static void clear_gigantic_page(struct page *page,
> +#ifndef __clear_page_nt
> +void clear_gigantic_page(struct page *page,
>  				unsigned long addr,
>  				unsigned int pages_per_huge_page)
>  {
> @@ -4582,6 +4583,7 @@ static void clear_gigantic_page(struct page *page,
>  		clear_user_highpage(p, addr + i * PAGE_SIZE);
>  	}
>  }
> +#endif  /* __clear_page_nt */
>  void clear_huge_page(struct page *page,
>  		     unsigned long addr_hint, unsigned int pages_per_huge_page)
>  {
> --
> 2.18.0.233.g985f88cf7e-goog

-- 
Michal Hocko
SUSE Labs
