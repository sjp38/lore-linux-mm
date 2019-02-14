Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD3AFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:04:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D55C21B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:04:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="by+RQE9d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D55C21B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 220B68E0003; Thu, 14 Feb 2019 17:04:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D1B18E0001; Thu, 14 Feb 2019 17:04:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 072BB8E0003; Thu, 14 Feb 2019 17:04:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7BD88E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:04:51 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a72so3933795pfj.19
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:04:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=jNfgh+9+YqcTyUUN3F+4itRdgED5I5t+gHKZm0Ithlg=;
        b=Aj9+Nb5Pham9SStaBbyFGo9MJWtFOaoAV4AhpJwxcSmWlbBiLkszONVaEr7YJyuC/H
         emAffuG2k9I7wDUXBSGQY3zXgspF2+v9iZ+SXL34OshYjCn3uVbX2kIcgKw7gz+PndwN
         lmz+94pC/qxi7pqilcu4Z1StF1U2ccheh12k5yZj0Zzju4wRFBDGh/WQftqCf74n/VYS
         PFNVZ2ZacVqhqz5x1M/0cdnmAcECqeti6kh3fFetGIFENJ4VBacpP3eAPjYzAfvdbKQc
         CBr0BSGQA6FIfeOdrWzaAuINtlp2QNvMX+Ccyjg6Ps2TDxE321BTNxBzjQxgaNYbZkji
         nAqQ==
X-Gm-Message-State: AHQUAuYP1a9z/q/rT8spPLg8edIW7WN6q1lZkLC18aUNeYYKJb9H3gPq
	Wis0XotXeypqzrNM/gsI0SOTbO3nOIW5f8oHHIRk59QVOoG5NqrsyZ7MgrtGIPG4im6LbN+2FKw
	J0KA70Y+vaIzPCeWlBQYNVWO3S/NaJmVI67Vf5cXx6SjlKHdQQ+4qQkHBrwF2SITS02bPT6OK7q
	X2rEOsuPiB1XFX4kUOSzJ7ml2DxwNnr7Ycq3g4LFWmyH0ETDvRuc6+AfyBnR7t/Va43znETnPC/
	idBQVUM6jKkFcaYL1xtZTJt1G57XILZU74xN3yUNrbMrcqccI9IXO+ZqCR6gSCENDyosPw7Iej7
	Z67bepg02ZhiPWG/dWBbojAMLnmlIqKXSdt5J4SZO0nKhzqd+jHlr1aLxgDpnPg1qoA8RcfHnON
	V
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr6650172pla.267.1550181891199;
        Thu, 14 Feb 2019 14:04:51 -0800 (PST)
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr6650079pla.267.1550181889940;
        Thu, 14 Feb 2019 14:04:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550181889; cv=none;
        d=google.com; s=arc-20160816;
        b=kt0orwq5s+ndFy5a16yOIJqEK7Rl3bhmQ1z6WHoSeHSMSernGDPqPOaZ78R0NKzDNa
         wlLCGaKVW0igCv3vP13Q2qoP+n8JLAMD25EVO4nSJbn+pYMaAtGnLiyK8teWKj4o89kw
         sPJdZ7dyTZc6yGkK1BOv9QC/ZHeFZ/cP9Ih5ukhlUosuTJhWn7PXVJ3oqv0X/NZS4Co1
         R+CuyaYuC2eGFWzygCqkva/snHYXMx1J3MkKGro/mRRk24c8w+fJWtRmlVwTA3y0lQCX
         ePLXqwybKlOkKE1N2rHCBXjVw6t7p28IIORtDYCHQ0Q7XT0dThhz9/TBPolovdY8s/3M
         g/sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=jNfgh+9+YqcTyUUN3F+4itRdgED5I5t+gHKZm0Ithlg=;
        b=mENS8y1vZQT64iU4ucafHNA8ZJATZhaY7b5NaGk0ikko1JHHrbck9jrzO5AT2klT/k
         N1NjHuxxvygHLJFmAx1BXGBNGvglcE+DDtkoOu9tI+Tyf55I0TDpgfxkpQ1CV8JSYU1I
         hSes4hau76Lsfab+wJgaHXTidxgLc8w5AVQnv5Qc6ubmYolz2Gyi3+EuCS46014zfa9U
         mf/VaEk5wWOsJ6LhmmbjFTzC+seEXKsTQRaWjFbR/qNn/IZVObTI8A1jAASUtEVEIqMX
         ekIVqJ3Rgahwz1/h02ge8TQj49CDKJY05mnj+sN6YACGs3gYJMfrkv21XR2wu5TI0Obn
         nRLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=by+RQE9d;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 127sor6071925pfw.60.2019.02.14.14.04.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:04:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=by+RQE9d;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=jNfgh+9+YqcTyUUN3F+4itRdgED5I5t+gHKZm0Ithlg=;
        b=by+RQE9djOdkQTvUfaHBLlnbqrT/tF8UkToE9czLWfOdsXjvuwtTiV5ebN3QwcgDRT
         ikxza+nJAtJVjIs2KGZmQsr744zER9SgEJsGRMpwvyGhe2X09/DkdGxvzbRJumn5Ljlu
         obbVrLjFR40S8/UxWF4vKykw7MbL2NPIKoSNM=
X-Google-Smtp-Source: AHgI3Ibqzq/9tfj8ZMoXiYgaOrrP3vxTONIeTm2uqSXgv1OQIeAR2N68APHAXyBBDRIlj0lFU3ukHA==
X-Received: by 2002:a62:fb07:: with SMTP id x7mr6346509pfm.71.1550181889455;
        Thu, 14 Feb 2019 14:04:49 -0800 (PST)
Received: from localhost (124-171-165-212.dyn.iinet.net.au. [124.171.165.212])
        by smtp.gmail.com with ESMTPSA id r80sm5177609pfa.111.2019.02.14.14.04.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 14:04:47 -0800 (PST)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
In-Reply-To: <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
References: <cover.1549935247.git.christophe.leroy@c-s.fr> <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
Date: Fri, 15 Feb 2019 09:04:44 +1100
Message-ID: <8736oq3u2r.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christophe,

> --- a/arch/powerpc/include/asm/string.h
> +++ b/arch/powerpc/include/asm/string.h
> @@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>  extern void * memchr(const void *,int,__kernel_size_t);
>  extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>  
> +void *__memset(void *s, int c, __kernel_size_t count);
> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
> +void *__memmove(void *to, const void *from, __kernel_size_t n);
> +
> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
> +/*
> + * For files that are not instrumented (e.g. mm/slub.c) we
> + * should use not instrumented version of mem* functions.
> + */
> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
> +#define memmove(dst, src, len) __memmove(dst, src, len)
> +#define memset(s, c, n) __memset(s, c, n)
> +#endif
> +

I'm finding that I miss tests like 'kasan test: kasan_memcmp
out-of-bounds in memcmp' because the uninstrumented asm version is used
instead of an instrumented C version. I ended up guarding the relevant
__HAVE_ARCH_x symbols behind a #ifndef CONFIG_KASAN and only exporting
the arch versions if we're not compiled with KASAN.

I find I need to guard and unexport strncpy, strncmp, memchr and
memcmp. Do you need to do this on 32bit as well, or are those tests
passing anyway for some reason?

Regards,
Daniel


>  #ifdef CONFIG_PPC64
>  #define __HAVE_ARCH_MEMSET32
>  #define __HAVE_ARCH_MEMSET64
> diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
> index 879b36602748..fc4c42262694 100644
> --- a/arch/powerpc/kernel/Makefile
> +++ b/arch/powerpc/kernel/Makefile
> @@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
>  CFLAGS_btext.o		+= -fPIC
>  endif
>  
> -CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
> -CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
> +CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
> +CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
> +CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
>  CFLAGS_btext.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>  CFLAGS_prom.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>  
> @@ -31,6 +32,10 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
>  endif
>  
> +KASAN_SANITIZE_early_32.o := n
> +KASAN_SANITIZE_cputable.o := n
> +KASAN_SANITIZE_prom_init.o := n
> +
>  obj-y				:= cputable.o ptrace.o syscalls.o \
>  				   irq.o align.o signal_32.o pmc.o vdso.o \
>  				   process.o systbl.o idle.o \
> diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
> index 9ffc72ded73a..846fb30b1190 100644
> --- a/arch/powerpc/kernel/asm-offsets.c
> +++ b/arch/powerpc/kernel/asm-offsets.c
> @@ -783,5 +783,9 @@ int main(void)
>  	DEFINE(VIRT_IMMR_BASE, (u64)__fix_to_virt(FIX_IMMR_BASE));
>  #endif
>  
> +#ifdef CONFIG_KASAN
> +	DEFINE(KASAN_SHADOW_OFFSET, KASAN_SHADOW_OFFSET);
> +#endif
> +
>  	return 0;
>  }
> diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
> index 05b08db3901d..0ec9dec06bc2 100644
> --- a/arch/powerpc/kernel/head_32.S
> +++ b/arch/powerpc/kernel/head_32.S
> @@ -962,6 +962,9 @@ start_here:
>   * Do early platform-specific initialization,
>   * and set up the MMU.
>   */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	li	r3,0
>  	mr	r4,r31
>  	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
> index b19d78410511..5d6ff8fa7e2b 100644
> --- a/arch/powerpc/kernel/head_40x.S
> +++ b/arch/powerpc/kernel/head_40x.S
> @@ -848,6 +848,9 @@ start_here:
>  /*
>   * Decide what sort of machine this is and initialize the MMU.
>   */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	li	r3,0
>  	mr	r4,r31
>  	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_44x.S b/arch/powerpc/kernel/head_44x.S
> index bf23c19c92d6..7ca14dff6192 100644
> --- a/arch/powerpc/kernel/head_44x.S
> +++ b/arch/powerpc/kernel/head_44x.S
> @@ -203,6 +203,9 @@ _ENTRY(_start);
>  /*
>   * Decide what sort of machine this is and initialize the MMU.
>   */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	li	r3,0
>  	mr	r4,r31
>  	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
> index 0fea10491f3a..6a644ea2e6b6 100644
> --- a/arch/powerpc/kernel/head_8xx.S
> +++ b/arch/powerpc/kernel/head_8xx.S
> @@ -823,6 +823,9 @@ start_here:
>  /*
>   * Decide what sort of machine this is and initialize the MMU.
>   */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	li	r3,0
>  	mr	r4,r31
>  	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
> index 2386ce2a9c6e..4f4585a68850 100644
> --- a/arch/powerpc/kernel/head_fsl_booke.S
> +++ b/arch/powerpc/kernel/head_fsl_booke.S
> @@ -274,6 +274,9 @@ set_ivor:
>  /*
>   * Decide what sort of machine this is and initialize the MMU.
>   */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	mr	r3,r30
>  	mr	r4,r31
>  	bl	machine_init
> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
> index 667df97d2595..da6bb16e0876 100644
> --- a/arch/powerpc/kernel/prom_init_check.sh
> +++ b/arch/powerpc/kernel/prom_init_check.sh
> @@ -16,8 +16,16 @@
>  # If you really need to reference something from prom_init.o add
>  # it to the list below:
>  
> +grep CONFIG_KASAN=y .config >/dev/null
> +if [ $? -eq 0 ]
> +then
> +	MEMFCT="__memcpy __memset"
> +else
> +	MEMFCT="memcpy memset"
> +fi
> +
>  WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
> -_end enter_prom memcpy memset reloc_offset __secondary_hold
> +_end enter_prom $MEMFCT reloc_offset __secondary_hold
>  __secondary_hold_acknowledge __secondary_hold_spinloop __start
>  strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
>  reloc_got2 kernstart_addr memstart_addr linux_banner _stext
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index ca00fbb97cf8..16ff1ea66805 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -978,6 +978,8 @@ void __init setup_arch(char **cmdline_p)
>  
>  	paging_init();
>  
> +	kasan_init();
> +
>  	/* Initialize the MMU context management stuff. */
>  	mmu_context_init();
>  
> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
> index 3bf9fc6fd36c..ce8d4a9f810a 100644
> --- a/arch/powerpc/lib/Makefile
> +++ b/arch/powerpc/lib/Makefile
> @@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>  CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>  
> +KASAN_SANITIZE_code-patching.o := n
> +KASAN_SANITIZE_feature-fixups.o := n
> +
> +ifdef CONFIG_KASAN
> +CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
> +CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
> +endif
> +
>  obj-y += string.o alloc.o code-patching.o feature-fixups.o
>  
>  obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
> diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
> index ba66846fe973..4d8a1c73b4cf 100644
> --- a/arch/powerpc/lib/copy_32.S
> +++ b/arch/powerpc/lib/copy_32.S
> @@ -91,7 +91,8 @@ EXPORT_SYMBOL(memset16)
>   * We therefore skip the optimised bloc that uses dcbz. This jump is
>   * replaced by a nop once cache is active. This is done in machine_init()
>   */
> -_GLOBAL(memset)
> +_GLOBAL(__memset)
> +KASAN_OVERRIDE(memset, __memset)
>  	cmplwi	0,r5,4
>  	blt	7f
>  
> @@ -163,12 +164,14 @@ EXPORT_SYMBOL(memset)
>   * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
>   * replaced by a nop once cache is active. This is done in machine_init()
>   */
> -_GLOBAL(memmove)
> +_GLOBAL(__memmove)
> +KASAN_OVERRIDE(memmove, __memmove)
>  	cmplw	0,r3,r4
>  	bgt	backwards_memcpy
>  	/* fall through */
>  
> -_GLOBAL(memcpy)
> +_GLOBAL(__memcpy)
> +KASAN_OVERRIDE(memcpy, __memcpy)
>  1:	b	generic_memcpy
>  	patch_site	1b, patch__memcpy_nocache
>  
> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index f965fc33a8b7..d6b76f25f6de 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -7,6 +7,8 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>  
>  CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
>  
> +KASAN_SANITIZE_kasan_init.o := n
> +
>  obj-y				:= fault.o mem.o pgtable.o mmap.o \
>  				   init_$(BITS).o pgtable_$(BITS).o \
>  				   init-common.o mmu_context.o drmem.o
> @@ -55,3 +57,4 @@ obj-$(CONFIG_PPC_BOOK3S_64)	+= dump_linuxpagetables-book3s64.o
>  endif
>  obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
>  obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
> +obj-$(CONFIG_KASAN)		+= kasan_init.o
> diff --git a/arch/powerpc/mm/dump_linuxpagetables.c b/arch/powerpc/mm/dump_linuxpagetables.c
> index 6aa41669ac1a..c862b48118f1 100644
> --- a/arch/powerpc/mm/dump_linuxpagetables.c
> +++ b/arch/powerpc/mm/dump_linuxpagetables.c
> @@ -94,6 +94,10 @@ static struct addr_marker address_markers[] = {
>  	{ 0,	"Consistent mem start" },
>  	{ 0,	"Consistent mem end" },
>  #endif
> +#ifdef CONFIG_KASAN
> +	{ 0,	"kasan shadow mem start" },
> +	{ 0,	"kasan shadow mem end" },
> +#endif
>  #ifdef CONFIG_HIGHMEM
>  	{ 0,	"Highmem PTEs start" },
>  	{ 0,	"Highmem PTEs end" },
> @@ -310,6 +314,10 @@ static void populate_markers(void)
>  	address_markers[i++].start_address = IOREMAP_TOP +
>  					     CONFIG_CONSISTENT_SIZE;
>  #endif
> +#ifdef CONFIG_KASAN
> +	address_markers[i++].start_address = KASAN_SHADOW_START;
> +	address_markers[i++].start_address = KASAN_SHADOW_END;
> +#endif
>  #ifdef CONFIG_HIGHMEM
>  	address_markers[i++].start_address = PKMAP_BASE;
>  	address_markers[i++].start_address = PKMAP_ADDR(LAST_PKMAP);
> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
> new file mode 100644
> index 000000000000..bd8e0a263e12
> --- /dev/null
> +++ b/arch/powerpc/mm/kasan_init.c
> @@ -0,0 +1,114 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#define DISABLE_BRANCH_PROFILING
> +
> +#include <linux/kasan.h>
> +#include <linux/printk.h>
> +#include <linux/memblock.h>
> +#include <linux/sched/task.h>
> +#include <asm/pgalloc.h>
> +
> +void __init kasan_early_init(void)
> +{
> +	unsigned long addr = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long next;
> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
> +	int i;
> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
> +
> +	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
> +
> +	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
> +		panic("KASAN not supported with Hash MMU\n");
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
> +			     kasan_early_shadow_pte + i,
> +			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL), 0);
> +
> +	do {
> +		next = pgd_addr_end(addr, end);
> +		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
> +	} while (pmd++, addr = next, addr != end);
> +}
> +
> +static void __init kasan_init_region(struct memblock_region *reg)
> +{
> +	void *start = __va(reg->base);
> +	void *end = __va(reg->base + reg->size);
> +	unsigned long k_start, k_end, k_cur, k_next;
> +	pmd_t *pmd;
> +	void *block;
> +
> +	if (start >= end)
> +		return;
> +
> +	k_start = (unsigned long)kasan_mem_to_shadow(start);
> +	k_end = (unsigned long)kasan_mem_to_shadow(end);
> +	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
> +
> +	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
> +		k_next = pgd_addr_end(k_cur, k_end);
> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
> +			pte_t *new = pte_alloc_one_kernel(&init_mm);
> +
> +			if (!new)
> +				panic("kasan: pte_alloc_one_kernel() failed");
> +			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
> +			pmd_populate_kernel(&init_mm, pmd, new);
> +		}
> +	};
> +
> +	block = memblock_alloc(k_end - k_start, PAGE_SIZE);
> +	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
> +		void *va = block ? block + k_cur - k_start :
> +				   memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> +		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
> +
> +		if (!va)
> +			panic("kasan: memblock_alloc() failed");
> +		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
> +		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
> +	}
> +	flush_tlb_kernel_range(k_start, k_end);
> +}
> +
> +static void __init kasan_remap_early_shadow_ro(void)
> +{
> +	unsigned long k_cur;
> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		ptep_set_wrprotect(&init_mm, 0, kasan_early_shadow_pte + i);
> +
> +	for (k_cur = PAGE_OFFSET & PAGE_MASK; k_cur; k_cur += PAGE_SIZE) {
> +		pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
> +		pte_t *ptep = pte_offset_kernel(pmd, k_cur);
> +
> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte)
> +			continue;
> +		if ((pte_val(*ptep) & PAGE_MASK) != pa)
> +			continue;
> +
> +		ptep_set_wrprotect(&init_mm, k_cur, ptep);
> +	}
> +	flush_tlb_mm(&init_mm);
> +}
> +
> +void __init kasan_init(void)
> +{
> +	struct memblock_region *reg;
> +
> +	for_each_memblock(memory, reg)
> +		kasan_init_region(reg);
> +
> +	kasan_remap_early_shadow_ro();
> +
> +	clear_page(kasan_early_shadow_page);
> +
> +	/* At this point kasan is fully initialized. Enable error messages */
> +	init_task.kasan_depth = 0;
> +	pr_info("KASAN init done\n");
> +}
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 81f251fc4169..1bb055775e60 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -336,6 +336,10 @@ void __init mem_init(void)
>  	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
>  		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
>  #endif /* CONFIG_HIGHMEM */
> +#ifdef CONFIG_KASAN
> +	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
> +		KASAN_SHADOW_START, KASAN_SHADOW_END);
> +#endif
>  #ifdef CONFIG_NOT_COHERENT_CACHE
>  	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
>  		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
> -- 
> 2.13.3

