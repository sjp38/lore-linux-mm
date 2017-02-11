Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9F36B0038
	for <linux-mm@kvack.org>; Sat, 11 Feb 2017 09:13:45 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so21640513wmd.1
        for <linux-mm@kvack.org>; Sat, 11 Feb 2017 06:13:45 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 36si6200513wrk.321.2017.02.11.06.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Feb 2017 06:13:43 -0800 (PST)
Date: Sat, 11 Feb 2017 15:13:29 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 2/5] x86/mm: introduce mmap{,_legacy}_base
In-Reply-To: <20170130120432.6716-3-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702102033420.4042@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-3-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Mon, 30 Jan 2017, Dmitry Safonov wrote:

> In the following patch they will be used to compute:
> - mmap{,_legacy}_base for 64-bit mmap()
> - mmap_compat{,_legacy}_base for 32-bit mmap()
> 
> This patch makes it possible to calculate mmap bases for any specified
> task_size, which is needed to correctly choose the base address for mmap
> in 32-bit syscalls and 64-bit syscalls.

Please rework your changelogs so they follow the requirements in
Documentation....  Look for 'this patch' there.

Also order it in a way which makes it clear what the problem is and how
it's solved.

> +#define STACK_RND_MASK_MODE(native) (0x7ff)
>  #define STACK_RND_MASK (0x7ff)
>  
>  #define ARCH_DLINFO		ARCH_DLINFO_IA32
> @@ -295,7 +296,8 @@ do {									\
>  #else /* CONFIG_X86_32 */
>  
>  /* 1GB for 64bit, 8MB for 32bit */
> -#define STACK_RND_MASK (test_thread_flag(TIF_ADDR32) ? 0x7ff : 0x3fffff)
> +#define STACK_RND_MASK_MODE(native) ((native) ? 0x3fffff : 0x7ff)
> +#define STACK_RND_MASK STACK_RND_MASK_MODE(!test_thread_flag(TIF_ADDR32))

I had to look twice what MODE means. The macro name suggests that it
returns the mode, while it actually returns the mask. That's confusing at
best. And 'native' is not intuitive either.

#define __STACK_RND_MASK(is64bit)	((is64bit) ? 0x3fffff : 0x7ff)
#define STACK_RND_MASK			__STACK_RND_MASK(!mmap_is_ia32())

That is pretty much clear and it uses mmap_is_ia32() as we do in other
places. As a consequemce you can use the same macros for 64 and 32 bit.

> diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
> index 1be64da0384e..52086e65b422 100644
> --- a/arch/x86/include/asm/processor.h
> +++ b/arch/x86/include/asm/processor.h
> @@ -862,7 +862,8 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
>   * This decides where the kernel will search for a free chunk of vm
>   * space during mmap's.
>   */
> -#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
> +#define _TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
> +#define TASK_UNMAPPED_BASE	_TASK_UNMAPPED_BASE(TASK_SIZE)

Please use two underscores and align the macros in tabular fashion. 

#define __TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(TASK_SIZE)

That way stuff becomes easy to read.

>  #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
>  
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 42063e787717..98be520fd270 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -35,12 +35,14 @@ struct va_alignment __read_mostly va_align = {
>  	.flags = -1,
>  };
>  
> -static unsigned long stack_maxrandom_size(void)
> +static unsigned long stack_maxrandom_size(unsigned long task_size)
>  {
>  	unsigned long max = 0;
>  	if ((current->flags & PF_RANDOMIZE) &&
>  		!(current->personality & ADDR_NO_RANDOMIZE)) {
> -		max = ((-1UL) & STACK_RND_MASK) << PAGE_SHIFT;
> +		max = (-1UL);
> +		max &= STACK_RND_MASK_MODE(task_size == TASK_SIZE_MAX);

That just makes me barf, really. I have to go and lookup how TASK_SIZE_MAX
is defined in order to read that code. TASK_SIZE_MAX as is does not give a
hint at all that it means TASK_SIZE_MAX of 64 bit tasks.

You just explained me that you want stuff proper for clarity reasons. So
what's so wrong with adding a helper inline tasksize_64bit() or such?

> +		max <<= PAGE_SHIFT;
>  	}
>  
>  	return max;
> @@ -51,8 +53,8 @@ static unsigned long stack_maxrandom_size(void)
>   *
>   * Leave an at least ~128 MB hole with possible stack randomization.
>   */
> -#define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
> -#define MAX_GAP (TASK_SIZE/6*5)
> +#define MIN_GAP(task_size) (128*1024*1024UL + stack_maxrandom_size(task_size))
> +#define MAX_GAP(task_size) (task_size/6*5)

Eew. Yes it's existing macro mess, but there is not point in proliferating
that. That macro crap is only used in mmap_base() and there is no
justification for these unreadable macros at all. It just makes stuff
obfuscated for no reason. Just blindly making it more obfuscated does not
make it any better.

>  static int mmap_is_legacy(void)
>  {
> @@ -88,16 +90,22 @@ unsigned long arch_mmap_rnd(void)
>  	return arch_native_rnd();
>  }

#define SIZE_128M	(128 * 1024 * 1024UL)

> -static unsigned long mmap_base(unsigned long rnd)
> +static unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
>  {
> 	unsigned long gap = rlimit(RLIMIT_STACK);
	unsigned long gap_min, gap_max;

	/* Add comment what this means */
	gap_min = SIZE_128M + stack_maxrandom_size(task_size);
	/* Explain that ' /6 * 5' magic */
	gap_max = (task_size / 6) * 5;

and use gap_min/gap_max below. That would be too intuitive and readable,
right?

> -	if (gap < MIN_GAP)
> -		gap = MIN_GAP;
> -	else if (gap > MAX_GAP)
> -		gap = MAX_GAP;
> +	if (gap < MIN_GAP(task_size))
> +		gap = MIN_GAP(task_size);
> +	else if (gap > MAX_GAP(task_size))
> +		gap = MAX_GAP(task_size);
>  
> -	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
> +	return PAGE_ALIGN(task_size - gap - rnd);
> +}
> +
> +static unsigned long mmap_legacy_base(unsigned long rnd,
> +		unsigned long task_size)

Please align the argument in the second line with the argument in the first
one

static unsigned long mmap_legacy_base(unsigned long rnd,
		     		      unsigned long task_size)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
