Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB598C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:26:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A87AC240F6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:26:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Buw3FXSp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A87AC240F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47DA76B026B; Wed, 29 May 2019 15:26:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42E146B026D; Wed, 29 May 2019 15:26:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31E1F6B026E; Wed, 29 May 2019 15:26:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECB9B6B026B
	for <linux-mm@kvack.org>; Wed, 29 May 2019 15:26:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so2235439plb.2
        for <linux-mm@kvack.org>; Wed, 29 May 2019 12:26:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=MqvScE+mpTeungkeSlvv3Q/uzBYTV0O7Qr5Vox35/hw=;
        b=eGLiJYS28g6z5s217c4h59XpdAZOAc7nu+zLUrTFKTsbjJ7JbY00xRoT15Hex4hO8Y
         sQXJhHjMi+CppzqEp1G1u+1fhael/Q5rHqpexihRgBXb2YpQVHxSRVV+H27x8NpEazHD
         rY9DWAMKA+zgS+CkCi5dWWO54WH155px2n4e0uUUe5CF0uCpTg3lkK2penNwoPG9ELw6
         dAl4ZDNe5w/j6YRLlsKdJcOZy19lC9lfZ0kAKuy9MP5JQxbS5itSPFqrJf7d0xuPPtJs
         zSPFR9gBJ/xgFzvjMsoYAbU3lBkrumrrWuYvhi4RhH89tlr/p4140WnRx8CQuLH1Nml9
         bDFg==
X-Gm-Message-State: APjAAAViNSrYzeBE4zBJkipSHBkQbOMCPxwSu4P7fiSs88eCdaefPu6Y
	3SizLH+tuwX0lDKAv9q7aZotw2DWICx1Il86DKxmLIoYZxgNLOIdgxRF/CYnu2xaTFV8o1MjC6c
	VDq8k0QH04v3dk69pzCevwHZqYzClgUntCnDnYBvbs8vq7Ioo5ugutMJMkhXdWQv1qg==
X-Received: by 2002:a17:90a:32c1:: with SMTP id l59mr14406189pjb.1.1559157975432;
        Wed, 29 May 2019 12:26:15 -0700 (PDT)
X-Received: by 2002:a17:90a:32c1:: with SMTP id l59mr14406060pjb.1.1559157974122;
        Wed, 29 May 2019 12:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559157974; cv=none;
        d=google.com; s=arc-20160816;
        b=oUXmLBFj6nC0Ir1ujUOop4GORbalhjnsbTc2uazNC1AVF/ZSfKk/l78iNgcAkjCk1u
         atOnv3ip1vz94UREUJp4opl7pRyGr/rhnXA7uKF2pUpAhnpWdYk3xxeAZkh95OOEVfVk
         nChttQp0JRPRzoZ3PzYAelIR6yWGQEkMrD2f8dbjTpsR63KCy8MhhZfWazgG8fbYiQDu
         Koe2nMxDemSeaB3hJZGiUuxgsmhWj47YT5WzTpo4ZNP4fACuNJC6V9Sb14jUXAczwGwR
         gOignmMf+Nc+szawZb5yHRvoN5BWmivzIfufOqAoJ3G8xF6w9xTC0GzUj64s+ld1TyW/
         kJrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=MqvScE+mpTeungkeSlvv3Q/uzBYTV0O7Qr5Vox35/hw=;
        b=WlranZdwkb6FDgPrVmpU71rrDkEm0VfRGEc+kG9lvNPYA+nEOMFhlDT3c9m5necO+f
         domJZx71UJdat5ScbUw8MV9Mkc1YOmzz3XoXmhasIrRevX8CoQM2Bt5ST+eYRKB8dOAN
         TfHEzOqMmtAw8AgsY2lQTSc/5hyrEesAveIjxLjh6K6LUkqLFIF3kvKdEIli/2MNtte5
         ePzTopeaIHiFMbocoCzEBnLpQJ0X6rHNV50RgLDMnN28SJoB8GIqrQOLtLqgWugMTz2l
         5oRF+Yj51GLdxJSid1381KPaPYRYxOoJMcTYOzEcG9roTCjsayWCib1S0rMkI5Hk0Or7
         WClA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Buw3FXSp;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t25sor594821pfh.57.2019.05.29.12.26.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 12:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Buw3FXSp;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=MqvScE+mpTeungkeSlvv3Q/uzBYTV0O7Qr5Vox35/hw=;
        b=Buw3FXSp4ANIXhiVaYcFq7ueT4hHfJzssIhWbmrncc4YnHk0oVg8OvJ0WvauqQALhB
         sBghG+54cb3Hrx24CLKE7D0oxQLoKUXTBDFyYSm5aD1WKGg3/759D66vG6dvvqaZZSbX
         RMrPVBwObsIhqMoSQcIrTNLUVIJxzJvUk8a8g=
X-Google-Smtp-Source: APXvYqwq6lC0O0O/2wGuHUis8CaujTzg5ED6XBldzBsiAKxCW18NlPMCdk/8ggb/wiv8TlnrM8H9eg==
X-Received: by 2002:a62:585:: with SMTP id 127mr130528149pff.231.1559157973778;
        Wed, 29 May 2019 12:26:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q17sm480361pfq.74.2019.05.29.12.26.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 12:26:12 -0700 (PDT)
Date: Wed, 29 May 2019 12:26:11 -0700
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
Subject: Re: [PATCH v4 08/14] arm: Use generic mmap top-down layout and brk
 randomization
Message-ID: <201905291222.595685C3F0@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-9-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-9-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:40AM -0400, Alexandre Ghiti wrote:
> arm uses a top-down mmap layout by default that exactly fits the generic
> functions, so get rid of arch specific code and use the generic version
> by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
> As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
> use the generic version of arch_randomize_brk since it also fits.
> Note that this commit also removes the possibility for arm to have elf
> randomization and no MMU: without MMU, the security added by randomization
> is worth nothing.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

It may be worth noting that STACK_RND_MASK is safe to remove here
because it matches the default that now exists in mm/util.c.

-Kees

> ---
>  arch/arm/Kconfig                 |  2 +-
>  arch/arm/include/asm/processor.h |  2 --
>  arch/arm/kernel/process.c        |  5 ---
>  arch/arm/mm/mmap.c               | 62 --------------------------------
>  4 files changed, 1 insertion(+), 70 deletions(-)
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 8869742a85df..27687a8c9fb5 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -6,7 +6,6 @@ config ARM
>  	select ARCH_CLOCKSOURCE_DATA
>  	select ARCH_HAS_DEBUG_VIRTUAL if MMU
>  	select ARCH_HAS_DEVMEM_IS_ALLOWED
> -	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_KEEPINITRD
>  	select ARCH_HAS_KCOV
> @@ -29,6 +28,7 @@ config ARM
>  	select ARCH_SUPPORTS_ATOMIC_RMW
>  	select ARCH_USE_BUILTIN_BSWAP
>  	select ARCH_USE_CMPXCHG_LOCKREF
> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>  	select ARCH_WANT_IPC_PARSE_VERSION
>  	select BUILDTIME_EXTABLE_SORT if MMU
>  	select CLONE_BACKWARDS
> diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
> index 5d06f75ffad4..95b7688341c5 100644
> --- a/arch/arm/include/asm/processor.h
> +++ b/arch/arm/include/asm/processor.h
> @@ -143,8 +143,6 @@ static inline void prefetchw(const void *ptr)
>  #endif
>  #endif
>  
> -#define HAVE_ARCH_PICK_MMAP_LAYOUT
> -
>  #endif
>  
>  #endif /* __ASM_ARM_PROCESSOR_H */
> diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
> index 72cc0862a30e..19a765db5f7f 100644
> --- a/arch/arm/kernel/process.c
> +++ b/arch/arm/kernel/process.c
> @@ -322,11 +322,6 @@ unsigned long get_wchan(struct task_struct *p)
>  	return 0;
>  }
>  
> -unsigned long arch_randomize_brk(struct mm_struct *mm)
> -{
> -	return randomize_page(mm->brk, 0x02000000);
> -}
> -
>  #ifdef CONFIG_MMU
>  #ifdef CONFIG_KUSER_HELPERS
>  /*
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index 0b94b674aa91..b8d912ac9e61 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -17,43 +17,6 @@
>  	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
>  	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
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
>  /*
>   * We need to ensure that shared mappings are correctly aligned to
>   * avoid aliasing issues with VIPT caches.  We need to ensure that
> @@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	return addr;
>  }
>  
> -unsigned long arch_mmap_rnd(void)
> -{
> -	unsigned long rnd;
> -
> -	rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
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
>  /*
>   * You really shouldn't be using read() or write() on /dev/mem.  This
>   * might go away in the future.
> -- 
> 2.20.1
> 

-- 
Kees Cook

