Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59FB4C46470
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15EB32413A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="izbZjIiW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15EB32413A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC2BE6B026E; Wed, 29 May 2019 16:12:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A73046B026F; Wed, 29 May 2019 16:12:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 989146B0270; Wed, 29 May 2019 16:12:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 600306B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:12:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so2277154plt.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:12:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=vtTPUOYXY5m0og1DQAYrqLBzmvmQTdaSbXXOGkCnX6o=;
        b=PtPyiyNOf6pM3r+jHMJvFUwkSKL+MRp3gPB+BePlApdblfGO2O3+FrkUgmjkCb6wTl
         cvDPl1sN4L0RQIAT5G0kh17vqqeSGURfzkbMZQsNqOZxwHd0i8WLwFtduiTIwFmCeaqs
         uOZblogWrIGQaOHni1OJTIHoQ74XDY/lvi1xie+Nn+ScRz2Q/OT/ioz6M7QMFSMvA+nH
         xm6je25+ZazCFo/0murDAJJydunzCEoH9rJylxluv1KyNVUo7L2GGNIRYVCVn98oUe7G
         S/5MxvXEaWG2K1+kdEMnkuTw/45vt9F4f6bkLvWFOe1N2eKpREH83gdwEwvpfnAwAsOS
         HLiA==
X-Gm-Message-State: APjAAAUAU1RWTgYB65n47MFqXs5iaZ6bdnqvadcXdIUOghzDZ/8t1vSE
	K8uIvvv0Axx/x5pXCUcr1DLrc9jl825er/GNQJ5LP8+F/38qAWaFi8IQZ5o/ASF5/e12b+DoK67
	EXnugp+sOxC2Uhf/cg9bhyM45VVTVVUSb3/gtH/tHrYMjASVTZy9d7NNsV7RGme84Pw==
X-Received: by 2002:a65:608a:: with SMTP id t10mr138901601pgu.155.1559160765034;
        Wed, 29 May 2019 13:12:45 -0700 (PDT)
X-Received: by 2002:a65:608a:: with SMTP id t10mr138901562pgu.155.1559160764235;
        Wed, 29 May 2019 13:12:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559160764; cv=none;
        d=google.com; s=arc-20160816;
        b=Hbts/igw8oEHbFFUi/ELQkKJQ87nxHYzZZ+ePmM0C2pPkIVChvrSvXhQq/G9EQSCc1
         TzRLgLUnAVo3ecGp5mTqW/iUyMWiVghzlGTjRNKXqo76LFIoyokEkp1AFI3OYJGyfhJB
         ENOvMNYgXRtL0dULVJLGDYdoWxO/AxyX6qVLVF609hrY3lqiOTqk2zZ/O2+Txt9w0BsP
         h1P/oD59qVKeAc0sv1CeKef3Y2r+ST76j6l+BU8S9x8PUOXMGixFOV5gUfDCwntm1PnH
         VJgPmUcgYnq4LUg7w6pgBHMQk8xaCprv9SIz5YUxI+ZV8gSOPJ09rP/qnrDG1B648qgv
         tMvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=vtTPUOYXY5m0og1DQAYrqLBzmvmQTdaSbXXOGkCnX6o=;
        b=hjFgTy/37L+ikTt0BN376oGB6uFBndK0IfrhC3OhZ4jWcb95d27pG2o6JS0OckDCBB
         xTRfZ73y53hUB0vckAIlsrCW6n8iS47vlkJmxcHzwercvkiuYwZW9hEP10VEKIWqbxXK
         U0Z2wg4oq+Fo3rT5s7AH/46doWLQUE/en/fsRvPrKZ+KnXfMxw8L5R8Ch3OaqwhBdZ7z
         xkn0T641wS2uKYQU83tUS+hnY1HjB6ZvMkpnJAMfYHWgkvTV1zQjl0YO98BPM9BC3ocZ
         B7LNoa7LGvDRxDwGuFwp5dPddA/9pATrYLKtR1xDXdsksuwmKhcawfH5XgKOTH5e8I60
         uiQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=izbZjIiW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor783708pgl.11.2019.05.29.13.12.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:12:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=izbZjIiW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=vtTPUOYXY5m0og1DQAYrqLBzmvmQTdaSbXXOGkCnX6o=;
        b=izbZjIiWQ/Fv+WJjP0wMfQyIRynGOeA9yHGwPdpR+4dMfnlaOa+dgNEd4aH312MAjZ
         yJ/Qg2ba0BERrllHazRza8HCzJl+Yano/A/AxV+iSxxaRczv4GSf15ykGnmVxhSaqQXJ
         KI6O1c8xPunR6Hc1q6mMiS6EKhlrE6pHuf7so=
X-Google-Smtp-Source: APXvYqwSS4yekoOSF9l1S+1nXL3eNKPkVkTIYLpbKGbaMM40b95uuvY6kdgpWvWD6BW1Ys75eZ2ZkA==
X-Received: by 2002:a63:2b8a:: with SMTP id r132mr30768540pgr.196.1559160763943;
        Wed, 29 May 2019 13:12:43 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q28sm522752pfn.106.2019.05.29.13.12.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 13:12:43 -0700 (PDT)
Date: Wed, 29 May 2019 13:12:42 -0700
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
	linux-mm@kvack.org
Subject: Re: [PATCH v4 13/14] mips: Use generic mmap top-down layout and brk
 randomization
Message-ID: <201905291312.A4D2DEE4@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-14-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-14-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:45AM -0400, Alexandre Ghiti wrote:
> mips uses a top-down layout by default that exactly fits the generic
> functions, so get rid of arch specific code and use the generic version
> by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
> As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
> use the generic version of arch_randomize_brk since it also fits.
> Note that this commit also removes the possibility for mips to have elf
> randomization and no MMU: without MMU, the security added by randomization
> is worth nothing.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/Kconfig                 |  2 +-
>  arch/mips/include/asm/processor.h |  5 --
>  arch/mips/mm/mmap.c               | 96 -------------------------------
>  3 files changed, 1 insertion(+), 102 deletions(-)
> 
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index 70d3200476bf..da15b02bbe23 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -5,7 +5,6 @@ config MIPS
>  	select ARCH_32BIT_OFF_T if !64BIT
>  	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
>  	select ARCH_CLOCKSOURCE_DATA
> -	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
>  	select ARCH_SUPPORTS_UPROBES
> @@ -13,6 +12,7 @@ config MIPS
>  	select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
>  	select ARCH_USE_QUEUED_RWLOCKS
>  	select ARCH_USE_QUEUED_SPINLOCKS
> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>  	select ARCH_WANT_IPC_PARSE_VERSION
>  	select BUILDTIME_EXTABLE_SORT
>  	select CLONE_BACKWARDS
> diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
> index aca909bd7841..fba18d4a9190 100644
> --- a/arch/mips/include/asm/processor.h
> +++ b/arch/mips/include/asm/processor.h
> @@ -29,11 +29,6 @@
>  
>  extern unsigned int vced_count, vcei_count;
>  
> -/*
> - * MIPS does have an arch_pick_mmap_layout()
> - */
> -#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
> -
>  #ifdef CONFIG_32BIT
>  #ifdef CONFIG_KVM_GUEST
>  /* User space process size is limited to 1GB in KVM Guest Mode */
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index 900670ea8531..c2effe535484 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -16,49 +16,10 @@
>  #include <linux/random.h>
>  #include <linux/sched/signal.h>
>  #include <linux/sched/mm.h>
> -#include <linux/sizes.h>
> -#include <linux/compat.h>
>  
>  unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>  EXPORT_SYMBOL(shm_align_mask);
>  
> -/* gap between mmap and stack */
> -#define MIN_GAP		(128*1024*1024UL)
> -#define MAX_GAP		((STACK_TOP)/6*5)
> -#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
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
>  #define COLOUR_ALIGN(addr, pgoff)				\
>  	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
>  	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
> @@ -156,63 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
>  			addr0, len, pgoff, flags, DOWN);
>  }
>  
> -unsigned long arch_mmap_rnd(void)
> -{
> -	unsigned long rnd;
> -
> -#ifdef CONFIG_COMPAT
> -	if (TASK_IS_32BIT_ADDR)
> -		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> -	else
> -#endif /* CONFIG_COMPAT */
> -		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> -
> -	return rnd << PAGE_SHIFT;
> -}
> -
> -void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
> -{
> -	unsigned long random_factor = 0UL;
> -
> -	if (current->flags & PF_RANDOMIZE)
> -		random_factor = arch_mmap_rnd();
> -
> -	if (mmap_is_legacy(rlim_stack)) {
> -		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
> -		mm->get_unmapped_area = arch_get_unmapped_area;
> -	} else {
> -		mm->mmap_base = mmap_base(random_factor, rlim_stack);
> -		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
> -	}
> -}
> -
> -static inline unsigned long brk_rnd(void)
> -{
> -	unsigned long rnd = get_random_long();
> -
> -	rnd = rnd << PAGE_SHIFT;
> -	/* 32MB for 32bit, 1GB for 64bit */
> -	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
> -		rnd = rnd & SZ_32M;
> -	else
> -		rnd = rnd & SZ_1G;
> -
> -	return rnd;
> -}
> -
> -unsigned long arch_randomize_brk(struct mm_struct *mm)
> -{
> -	unsigned long base = mm->brk;
> -	unsigned long ret;
> -
> -	ret = PAGE_ALIGN(base + brk_rnd());
> -
> -	if (ret < mm->brk)
> -		return mm->brk;
> -
> -	return ret;
> -}
> -
>  int __virt_addr_valid(const volatile void *kaddr)
>  {
>  	return pfn_valid(PFN_DOWN(virt_to_phys(kaddr)));
> -- 
> 2.20.1
> 

-- 
Kees Cook

