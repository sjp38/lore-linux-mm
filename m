Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E17A6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 05:21:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so11815917wrb.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:21:55 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id f8si2804669edf.111.2017.08.17.02.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 02:21:53 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id 49so1198032wrw.5
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:21:53 -0700 (PDT)
Date: Thu, 17 Aug 2017 11:21:50 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 14/14] x86/mm: Offset boot-time paging mode switching
 cost
Message-ID: <20170817092150.imggg3pjguagvudd@gmail.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-15-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-15-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> By this point we have functioning boot-time switching between 4- and
> 5-level paging mode. But naive approach comes with cost.
> 
> Numbers below are for kernel build, allmodconfig, 5 times.
> 
> CONFIG_X86_5LEVEL=n:
> 
>  Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):
> 
>    17308719.892691      task-clock:u (msec)       #   26.772 CPUs utilized            ( +-  0.11% )
>                  0      context-switches:u        #    0.000 K/sec
>                  0      cpu-migrations:u          #    0.000 K/sec
>        331,993,164      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
> 43,614,978,867,455      cycles:u                  #    2.520 GHz                      ( +-  0.01% )
> 39,371,534,575,126      stalled-cycles-frontend:u #   90.27% frontend cycles idle     ( +-  0.09% )
> 28,363,350,152,428      instructions:u            #    0.65  insn per cycle
>                                                   #    1.39  stalled cycles per insn  ( +-  0.00% )
>  6,316,784,066,413      branches:u                #  364.948 M/sec                    ( +-  0.00% )
>    250,808,144,781      branch-misses:u           #    3.97% of all branches          ( +-  0.01% )
> 
>      646.531974142 seconds time elapsed                                          ( +-  1.15% )
> 
> CONFIG_X86_5LEVEL=y:
> 
>  Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):
> 
>    17411536.780625      task-clock:u (msec)       #   26.426 CPUs utilized            ( +-  0.10% )
>                  0      context-switches:u        #    0.000 K/sec
>                  0      cpu-migrations:u          #    0.000 K/sec
>        331,868,663      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
> 43,865,909,056,301      cycles:u                  #    2.519 GHz                      ( +-  0.01% )
> 39,740,130,365,581      stalled-cycles-frontend:u #   90.59% frontend cycles idle     ( +-  0.05% )
> 28,363,358,997,959      instructions:u            #    0.65  insn per cycle
>                                                   #    1.40  stalled cycles per insn  ( +-  0.00% )
>  6,316,784,937,460      branches:u                #  362.793 M/sec                    ( +-  0.00% )
>    251,531,919,485      branch-misses:u           #    3.98% of all branches          ( +-  0.00% )
> 
>      658.886307752 seconds time elapsed                                          ( +-  0.92% )
> The patch tries to fix the performance regression by using
> 
> !cpu_feature_enabled(X86_FEATURE_LA57) instead of p4d_folded in all hot
> code paths. These will statically patch the target code for additional
> performance.
> 
> Also, I had to re-write number of static inline helpers as macros.
> It was needed to break header dependency loop between cpufeature.h and
> pgtable_types.h.
> 
> CONFIG_X86_5LEVEL=y + the patch:
> 
>  Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):
> 
>    17381990.268506      task-clock:u (msec)       #   26.907 CPUs utilized            ( +-  0.19% )
>                  0      context-switches:u        #    0.000 K/sec
>                  0      cpu-migrations:u          #    0.000 K/sec
>        331,862,625      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
> 43,697,726,320,051      cycles:u                  #    2.514 GHz                      ( +-  0.03% )
> 39,480,408,690,401      stalled-cycles-frontend:u #   90.35% frontend cycles idle     ( +-  0.05% )
> 28,363,394,221,388      instructions:u            #    0.65  insn per cycle
>                                                   #    1.39  stalled cycles per insn  ( +-  0.00% )
>  6,316,794,985,573      branches:u                #  363.410 M/sec                    ( +-  0.00% )
>    251,013,232,547      branch-misses:u           #    3.97% of all branches          ( +-  0.01% )
> 
>      645.991174661 seconds time elapsed                                          ( +-  1.19% )

Ok - these measurements are very nice and address many of my worries about earlier 
parts of the series.

Anyway, please split this patch up some more as well (as any of the optimizations 
could regress by themselves), and my renaming suggestions still stand as well.

> @@ -11,6 +11,11 @@
>  #undef CONFIG_PARAVIRT_SPINLOCKS
>  #undef CONFIG_KASAN
>  
> +#ifdef CONFIG_X86_5LEVEL
> +/* cpu_feature_enabled() cannot be used that early */
> +#define p4d_folded __p4d_folded
> +#endif
> +
>  #include <linux/linkage.h>
>  #include <linux/screen_info.h>
>  #include <linux/elf.h>
> diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> index 077e8b45784c..702a1feb4991 100644
> --- a/arch/x86/entry/entry_64.S
> +++ b/arch/x86/entry/entry_64.S
> @@ -274,15 +274,8 @@ return_from_SYSCALL_64:
>  	 * depending on paging mode) in the address.
>  	 */
>  #ifdef CONFIG_X86_5LEVEL
> -	testl	$1, p4d_folded(%rip)
> -	jnz	1f
> -	shl	$(64 - 57), %rcx
> -	sar	$(64 - 57), %rcx
> -	jmp	2f
> -1:
> -	shl	$(64 - 48), %rcx
> -	sar	$(64 - 48), %rcx
> -2:
> +	ALTERNATIVE "shl $(64 - 48), %rcx; sar $(64 - 48), %rcx", \
> +		"shl $(64 - 57), %rcx; sar $(64 - 57), %rcx", X86_FEATURE_LA57

Ignore my earlier suggestion to use alternatives, you already implemented it!
This is what I get for replying to a patch series in chronological order. ;-)

I suspect the syscall overhead was the main reason for the performance regression.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
