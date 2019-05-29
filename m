Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2657EC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:10:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A150124129
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:10:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="lZClLD4C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A150124129
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE2A16B026A; Wed, 29 May 2019 16:10:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93D26B026D; Wed, 29 May 2019 16:10:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D33946B026E; Wed, 29 May 2019 16:10:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 980806B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:10:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id m7so2732121pfh.9
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:10:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=4tO49DCZiMUuRTyd+RB4sj1Pf9UNQPKfv9m6vwCN9bU=;
        b=Y6OvcU6sFT/ly8OHej3fK4kIKNZ3XhHJquAKLElLJkZ4iObk+5yVcpKL7o5W/w261G
         G0oGzjQ6SnbBWEqPHOqJAjmbt8B/14el8fC2RfIqRk4OZq1m8l+eRy3MIjpRcVmmACOF
         qKUq4dP/8yyZkxm43Ez3XE05JIoCbPVAHzgNYE+nhnhny6nxmwFucaWrWtx1SIuUWElA
         Qq5kM0Wv95uCsqzS61vxzMGBlGc4D+WiMeKMNc6QZYXBtmFIF/sdnSW5C0oSgIAD0yTO
         UtbJcn08BkWgwhvtMq9lSxppRac84hEKarbbfkGmmKoBR6H278lUvhdnJLjaQYWlogdm
         uYNA==
X-Gm-Message-State: APjAAAWa8DEabYcZMBaUZqQSmuDBPjP9Zp6FMg2ozdujzdhLz2ueJSWc
	iz6Wi5k5/6BxCk5+qunOaRMxQKl0trsf7eOeX2HQgsQurRvmsapeu5z5MgAnqWfhXW896AfDDXs
	aXOZCDqLsUD4Q13lCX5HwYYNYMTIe2HAjx1go545fofCN01Yj1IVzkWESUaSPPAh+Jw==
X-Received: by 2002:a17:90a:dc86:: with SMTP id j6mr13972094pjv.141.1559160643189;
        Wed, 29 May 2019 13:10:43 -0700 (PDT)
X-Received: by 2002:a17:90a:dc86:: with SMTP id j6mr13971713pjv.141.1559160637396;
        Wed, 29 May 2019 13:10:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559160637; cv=none;
        d=google.com; s=arc-20160816;
        b=xZJ2yMBGa7L10WrU3VcZraJjjLed3omEZ7VlfWhxKXQhwX9ipu4UB27kAnUi9gzrZN
         kEOVAi5GM9G34h9NwXBoStKC5Grz986s6RHQdMzZo7iudxbq1ISJ/hfnqBgWyECiGEN7
         KG7w67o92ZL4SPVPbOUAugUnd4qY0In8vadw3cLvuiy1BY9SN+AYsqOPzNZR0kEkWnOP
         5LlBKcOkB19ZIU2BLNNIVEAY3qR7daBNwzlXHa/GSSMllWGJ1uQXl7QO3KIVsSKSSGZ5
         ahHtV+afzJ/GeQrz5Ig3avM3t3CjtgkboEycjDEiQkkA7jyVFKWfdl2WoMi4ijV3HW86
         /ZKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=4tO49DCZiMUuRTyd+RB4sj1Pf9UNQPKfv9m6vwCN9bU=;
        b=g6i6MpdqbA3lrEa/myHhpLROCerX4Jvb8s52Jxa5X/XCbAjrNF4KOVklzVzavvQVtv
         EF45wdIMHKB/ftw064HWvGA76z+HaOWkscWQnvI3KTZ3pgOD7LRUJDnIs5fdsYT/jmZ3
         u265iZZaM/CiLerAtISY9jHtetIHVr1HnEuzU/XG6W8xVsm/bdmC7rfAEfZ/ST2LfObe
         RIlMvZ40xOzU/+1zpjnW5MR7MVYRvgDpCGhwJa0UTlQW3xPcbqRMoYizm9QaLU/tB2SW
         gqGV2LK4Tyd9pTMsDp821koSyjDOvUaMT2F4JjcMR0MQkEO+0U9RW+B+iLW65qoDNUf+
         7/hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=lZClLD4C;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j20sor723251pfh.40.2019.05.29.13.10.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:10:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=lZClLD4C;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=4tO49DCZiMUuRTyd+RB4sj1Pf9UNQPKfv9m6vwCN9bU=;
        b=lZClLD4C5PJCN/fAXazHH9tFux7V7osICYTD415D0JHAHk0wYmLL0BNiWP2GXwT2jO
         iJp3k2hMYmE015ugulaI/SgLfdBc+b7Ih3aLb8qGzEGNW1C7RUJZUITdm8wIg0lnn62N
         UjssZpDlWyvPgk7k0JOYPvkBQgpbe6QGWgOn0=
X-Google-Smtp-Source: APXvYqzGkzotfqRqlViLgd17DR1DtrVmfgKSVcRWSDYtwWcN+yj4Gv1oMUrd81n+gHG7RpUcJbaPsA==
X-Received: by 2002:a63:9d8d:: with SMTP id i135mr140578933pgd.245.1559160636677;
        Wed, 29 May 2019 13:10:36 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id g8sm432758pjp.17.2019.05.29.13.10.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 13:10:35 -0700 (PDT)
Date: Wed, 29 May 2019 13:10:34 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 04/14] arm64, mm: Move generic mmap layout functions
 to mm
Message-ID: <201905291310.D7E954C95B@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-5-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-5-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:36AM -0400, Alexandre Ghiti wrote:
> arm64 handles top-down mmap layout in a way that can be easily reused
> by other architectures, so make it available in mm.
> It then introduces a new config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> that can be set by other architectures to benefit from those functions.
> Note that this new config depends on MMU being enabled, if selected
> without MMU support, a warning will be thrown.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/Kconfig                       | 10 ++++
>  arch/arm64/Kconfig                 |  1 +
>  arch/arm64/include/asm/processor.h |  2 -
>  arch/arm64/mm/mmap.c               | 76 -----------------------------
>  kernel/sysctl.c                    |  6 ++-
>  mm/util.c                          | 78 +++++++++++++++++++++++++++++-
>  6 files changed, 92 insertions(+), 81 deletions(-)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index c47b328eada0..df3ab04270fa 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -701,6 +701,16 @@ config HAVE_ARCH_COMPAT_MMAP_BASES
>  	  and vice-versa 32-bit applications to call 64-bit mmap().
>  	  Required for applications doing different bitness syscalls.
>  
> +# This allows to use a set of generic functions to determine mmap base
> +# address by giving priority to top-down scheme only if the process
> +# is not in legacy mode (compat task, unlimited stack size or
> +# sysctl_legacy_va_layout).
> +# Architecture that selects this option can provide its own version of:
> +# - STACK_RND_MASK
> +config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> +	bool
> +	depends on MMU
> +
>  config HAVE_COPY_THREAD_TLS
>  	bool
>  	help
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 4780eb7af842..3d754c19c11e 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -69,6 +69,7 @@ config ARM64
>  	select ARCH_SUPPORTS_INT128 if GCC_VERSION >= 50000 || CC_IS_CLANG
>  	select ARCH_SUPPORTS_NUMA_BALANCING
>  	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
>  	select ARCH_WANT_FRAME_POINTERS
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
>  	select ARM_AMBA
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> index fcd0e691b1ea..3bd818edf319 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -282,8 +282,6 @@ static inline void spin_lock_prefetch(const void *ptr)
>  		     "nop") : : "p" (ptr));
>  }
>  
> -#define HAVE_ARCH_PICK_MMAP_LAYOUT
> -
>  #endif
>  
>  extern unsigned long __ro_after_init signal_minsigstksz; /* sigframe size */
> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
> index ac89686c4af8..c74224421216 100644
> --- a/arch/arm64/mm/mmap.c
> +++ b/arch/arm64/mm/mmap.c
> @@ -31,82 +31,6 @@
>  
>  #include <asm/cputype.h>
>  
> -/*
> - * Leave enough space between the mmap area and the stack to honour ulimit in
> - * the face of randomisation.
> - */
> -#define MIN_GAP (SZ_128M)
> -#define MAX_GAP	(STACK_TOP/6*5)
> -
> -static int mmap_is_legacy(struct rlimit *rlim_stack)
> -{
> -	if (current->personality & ADDR_COMPAT_LAYOUT)
> -		return 1;
> -
> -	if (rlim_stack->rlim_cur == RLIM_INFINITY)
> -		return 1;
> -
> -	return sysctl_legacy_va_layout;
> -}
> -
> -unsigned long arch_mmap_rnd(void)
> -{
> -	unsigned long rnd;
> -
> -#ifdef CONFIG_COMPAT
> -	if (is_compat_task())
> -		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> -	else
> -#endif
> -		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> -	return rnd << PAGE_SHIFT;
> -}
> -
> -static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
> -{
> -	unsigned long gap = rlim_stack->rlim_cur;
> -	unsigned long pad = stack_guard_gap;
> -
> -	/* Account for stack randomization if necessary */
> -	if (current->flags & PF_RANDOMIZE)
> -		pad += (STACK_RND_MASK << PAGE_SHIFT);
> -
> -	/* Values close to RLIM_INFINITY can overflow. */
> -	if (gap + pad > gap)
> -		gap += pad;
> -
> -	if (gap < MIN_GAP)
> -		gap = MIN_GAP;
> -	else if (gap > MAX_GAP)
> -		gap = MAX_GAP;
> -
> -	return PAGE_ALIGN(STACK_TOP - gap - rnd);
> -}
> -
> -/*
> - * This function, called very early during the creation of a new process VM
> - * image, sets up which VM layout function to use:
> - */
> -void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
> -{
> -	unsigned long random_factor = 0UL;
> -
> -	if (current->flags & PF_RANDOMIZE)
> -		random_factor = arch_mmap_rnd();
> -
> -	/*
> -	 * Fall back to the standard layout if the personality bit is set, or
> -	 * if the expected stack growth is unlimited:
> -	 */
> -	if (mmap_is_legacy(rlim_stack)) {
> -		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
> -		mm->get_unmapped_area = arch_get_unmapped_area;
> -	} else {
> -		mm->mmap_base = mmap_base(random_factor, rlim_stack);
> -		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
> -	}
> -}
> -
>  /*
>   * You really shouldn't be using read() or write() on /dev/mem.  This might go
>   * away in the future.
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 943c89178e3d..aebd03cc4b65 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -271,7 +271,8 @@ extern struct ctl_table epoll_table[];
>  extern struct ctl_table firmware_config_table[];
>  #endif
>  
> -#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
> +#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
> +    defined(CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
>  int sysctl_legacy_va_layout;
>  #endif
>  
> @@ -1566,7 +1567,8 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler	= proc_dointvec,
>  		.extra1		= &zero,
>  	},
> -#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
> +#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
> +    defined(CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
>  	{
>  		.procname	= "legacy_va_layout",
>  		.data		= &sysctl_legacy_va_layout,
> diff --git a/mm/util.c b/mm/util.c
> index dab33b896146..717f5d75c16e 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -15,7 +15,12 @@
>  #include <linux/vmalloc.h>
>  #include <linux/userfaultfd_k.h>
>  #include <linux/elf.h>
> +#include <linux/elf-randomize.h>
> +#include <linux/personality.h>
>  #include <linux/random.h>
> +#include <linux/processor.h>
> +#include <linux/sizes.h>
> +#include <linux/compat.h>
>  
>  #include <linux/uaccess.h>
>  
> @@ -313,7 +318,78 @@ unsigned long randomize_stack_top(unsigned long stack_top)
>  #endif
>  }
>  
> -#if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
> +#ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> +#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
> +unsigned long arch_mmap_rnd(void)
> +{
> +	unsigned long rnd;
> +
> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
> +	if (is_compat_task())
> +		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> +	else
> +#endif /* CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS */
> +		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> +
> +	return rnd << PAGE_SHIFT;
> +}
> +#endif /* CONFIG_ARCH_HAS_ELF_RANDOMIZE */
> +
> +static int mmap_is_legacy(struct rlimit *rlim_stack)
> +{
> +	if (current->personality & ADDR_COMPAT_LAYOUT)
> +		return 1;
> +
> +	if (rlim_stack->rlim_cur == RLIM_INFINITY)
> +		return 1;
> +
> +	return sysctl_legacy_va_layout;
> +}
> +
> +/*
> + * Leave enough space between the mmap area and the stack to honour ulimit in
> + * the face of randomisation.
> + */
> +#define MIN_GAP		(SZ_128M)
> +#define MAX_GAP		(STACK_TOP / 6 * 5)
> +
> +static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
> +{
> +	unsigned long gap = rlim_stack->rlim_cur;
> +	unsigned long pad = stack_guard_gap;
> +
> +	/* Account for stack randomization if necessary */
> +	if (current->flags & PF_RANDOMIZE)
> +		pad += (STACK_RND_MASK << PAGE_SHIFT);
> +
> +	/* Values close to RLIM_INFINITY can overflow. */
> +	if (gap + pad > gap)
> +		gap += pad;
> +
> +	if (gap < MIN_GAP)
> +		gap = MIN_GAP;
> +	else if (gap > MAX_GAP)
> +		gap = MAX_GAP;
> +
> +	return PAGE_ALIGN(STACK_TOP - gap - rnd);
> +}
> +
> +void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
> +{
> +	unsigned long random_factor = 0UL;
> +
> +	if (current->flags & PF_RANDOMIZE)
> +		random_factor = arch_mmap_rnd();
> +
> +	if (mmap_is_legacy(rlim_stack)) {
> +		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
> +		mm->get_unmapped_area = arch_get_unmapped_area;
> +	} else {
> +		mm->mmap_base = mmap_base(random_factor, rlim_stack);
> +		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
> +	}
> +}
> +#elif defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
>  void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
>  {
>  	mm->mmap_base = TASK_UNMAPPED_BASE;
> -- 
> 2.20.1
> 

-- 
Kees Cook

