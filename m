Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8BC6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 15:48:16 -0400 (EDT)
Received: by obfe9 with SMTP id e9so45592463obf.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:48:16 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id s204si8956448oia.32.2015.04.24.12.48.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 12:48:15 -0700 (PDT)
Message-ID: <553A9DFC.5040803@hp.com>
Date: Fri, 24 Apr 2015 15:48:12 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v3
References: <1429785196-7668-1-git-send-email-mgorman@suse.de> <1429804437.24139.3@cpanel21.proisp.no>
In-Reply-To: <1429804437.24139.3@cpanel21.proisp.no>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On 04/23/2015 11:53 AM, Daniel J Blueman wrote:
> On Thu, Apr 23, 2015 at 6:33 PM, Mel Gorman <mgorman@suse.de> wrote:
>> The big change here is an adjustment to the topology_init path that 
>> caused
>> soft lockups on Waiman and Daniel Blue had reported it was an expensive
>> function.
>>
>> Changelog since v2
>> o Reduce overhead of topology_init
>> o Remove boot-time kernel parameter to enable/disable
>> o Enable on UMA
>>
>> Changelog since v1
>> o Always initialise low zones
>> o Typo corrections
>> o Rename parallel mem init to parallel struct page init
>> o Rebase to 4.0
> []
>
> Splendid work! On this 256c setup, topology_init now takes 185ms.
>
> This brings the kernel boot time down to 324s [1]. It turns out that 
> one memset is responsible for most of the time setting up the the PUDs 
> and PMDs; adapting memset to using non-temporal writes [3] avoids 
> generating RMW cycles, bringing boot time down to 186s [2].
>
> If this is a possibility, I can split this patch and map other arch's 
> memset_nocache to memset, or change the callsite as preferred; 
> comments welcome.
>
> Thanks,
>  Daniel
>
> [1] https://resources.numascale.com/telemetry/defermem/h8qgl-defer2.txt
> [2] 
> https://resources.numascale.com/telemetry/defermem/h8qgl-defer2-nontemporal.txt
>
> -- [3]
>
> From f822139736cab8434302693c635fa146b465273c Mon Sep 17 00:00:00 2001
> From: Daniel J Blueman <daniel@numascale.com>
> Date: Thu, 23 Apr 2015 23:26:27 +0800
> Subject: [RFC] Speedup PMD setup
>
> Using non-temporal writes prevents read-modify-write cycles,
> which are much slower over large topologies.
>
> Adapt the existing memset() function into a _nocache variant and use
> when setting up PMDs during early boot to reduce boot time.
>
> Signed-off-by: Daniel J Blueman <daniel@numascale.com>
> ---
> arch/x86/include/asm/string_64.h |  3 ++
> arch/x86/lib/memset_64.S         | 90 
> ++++++++++++++++++++++++++++++++++++++++
> mm/memblock.c                    |  2 +-
> 3 files changed, 94 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/include/asm/string_64.h 
> b/arch/x86/include/asm/string_64.h
> index e466119..1ef28d0 100644
> --- a/arch/x86/include/asm/string_64.h
> +++ b/arch/x86/include/asm/string_64.h
> @@ -55,6 +55,8 @@ extern void *memcpy(void *to, const void *from, 
> size_t len);
> #define __HAVE_ARCH_MEMSET
> void *memset(void *s, int c, size_t n);
> void *__memset(void *s, int c, size_t n);
> +void *memset_nocache(void *s, int c, size_t n);
> +void *__memset_nocache(void *s, int c, size_t n);
>
> #define __HAVE_ARCH_MEMMOVE
> void *memmove(void *dest, const void *src, size_t count);
> @@ -77,6 +79,7 @@ int strcmp(const char *cs, const char *ct);
> #define memcpy(dst, src, len) __memcpy(dst, src, len)
> #define memmove(dst, src, len) __memmove(dst, src, len)
> #define memset(s, c, n) __memset(s, c, n)
> +#define memset_nocache(s, c, n) __memset_nocache(s, c, n)
> #endif
>
> #endif /* __KERNEL__ */
> diff --git a/arch/x86/lib/memset_64.S b/arch/x86/lib/memset_64.S
> index 6f44935..fb46f78 100644
> --- a/arch/x86/lib/memset_64.S
> +++ b/arch/x86/lib/memset_64.S
> @@ -137,6 +137,96 @@ ENTRY(__memset)
> ENDPROC(memset)
> ENDPROC(__memset)
>
> +/*
> + * bzero_nocache - set a memory block to zero. This function uses
> + * non-temporal writes in the fastpath
> + *
> + * rdi   destination
> + * rsi   value (char)
> + * rdx   count (bytes)
> + *
> + * rax   original destination
> + */
> +
> +ENTRY(memset_nocache)
> +ENTRY(__memset_nocache)
> +    CFI_STARTPROC
> +    movq %rdi,%r10
> +
> +    /* expand byte value */
> +    movzbl %sil,%ecx
> +    movabs $0x0101010101010101,%rax
> +    imulq  %rcx,%rax
> +
> +    /* align dst */
> +    movl  %edi,%r9d
> +    andl  $7,%r9d
> +    jnz  bad_alignment
> +    CFI_REMEMBER_STATE
> +after_bad_alignment:
> +
> +    movq  %rdx,%rcx
> +    shrq  $6,%rcx
> +    jz     handle_tail
> +
> +    .p2align 4
> +loop_64:
> +    decq  %rcx
> +    movnti    %rax,(%rdi)
> +    movnti    %rax,8(%rdi)
> +    movnti    %rax,16(%rdi)
> +    movnti    %rax,24(%rdi)
> +    movnti    %rax,32(%rdi)
> +    movnti    %rax,40(%rdi)
> +    movnti    %rax,48(%rdi)
> +    movnti    %rax,56(%rdi)
> +    leaq  64(%rdi),%rdi
> +    jnz    loop_64
> +
> +

Your version of memset_nocache differs from from memset only in the use 
of movnti instruction. You may consider using compiler macros to make a 
single copy of source code to generate 2 different versions of 
executable codes. That will make the new code much easier to maintain.

For example,

#include ...

#define MOVQ    movnti
#define memset memset_nocache
#define __mmset __memset_nocache

#include "memset_64.S"

Of course, you need to replace the target movq instructions in 
memset_64.S to MOVQ, define

#ifndef MOVQ
#define MOVQ movq
#endif

You also need to use conditional compilation macro to disable the 
alternate instruction stuff in memset_64.S.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
