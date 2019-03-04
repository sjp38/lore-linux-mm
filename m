Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A49F8C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 05:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D48721019
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 05:26:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="Sub/QE35"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D48721019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5E28E0003; Mon,  4 Mar 2019 00:26:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 984F18E0001; Mon,  4 Mar 2019 00:26:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827318E0003; Mon,  4 Mar 2019 00:26:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34EA08E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 00:26:28 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h70so4092548pfd.11
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 21:26:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=aC2HvedaaToK8WRf4rbjRXl4nQTUyYOLv21b3btJFzI=;
        b=esPptLJHRF+8oPV+kZRtao16SRpBLdK1CbSGX+A+JeV365eMJy8d0FTVVbMICZSrs9
         pnwrGvE+zO382RAxzErqrrRM/xEgKRwRJfKhJzJFV45bHKNnQtUyIU5mAMxuhl3UijYq
         ByaT97WB4ZyxkUv2w7SupP7IzKYBCaCZIVocu9L3cR0/jj6v2byxLLXdIJabsLACuaYe
         ndlT/Sgqk6RIj7ocZWp1L0Z0Q0pR/pA/GSewu/UdmN247E/kWDS0uF7ll0906CuoluFs
         Vk5L+5S4DVJA/EE2H88fyrHYbqVnN2PFoHZcyStG2Z+rcONTU8ZP/8aJx0MjbFo2LUcM
         /99g==
X-Gm-Message-State: APjAAAU7KdQ7Wm/Dr2DdX422/XmEwik8V8OC0eb2JHuqTsFewDCRnKi0
	aDV1bSX5CfWZgT4RGCS9lHZq2qX1V9rV7xcJScJdEUSXXelr4XD++GayUvM+IAa/mHSgrxcBR43
	R0vwH3Hed3qiYO7mxK14/W3hkhW8e/neCPCx838RUh4JmAO4HJPUBSiGdmdBOlCtJXBWF4S0+mI
	8IjEc1xR5KDf7tKjWgiSuP1hzyZ3h9RecEvn/6T1Vx1kGpbLlp/wFkAokmMHnTiJMTaiuiobOwK
	JmD6uh7tLexFehPA/LDZiT0yoKrJLHs5kHL7j7GXR9Rj3ES+aYjwVIIjslXKI8LSrklZQe7soPD
	O0ONoIOsT5moEbQ6yssFjQFJWCrEA17fAsq3si9TEPjG1hOR6BMwEEL5OoYslrFr5k1k/bW6CCh
	d
X-Received: by 2002:a63:6903:: with SMTP id e3mr17018914pgc.147.1551677187718;
        Sun, 03 Mar 2019 21:26:27 -0800 (PST)
X-Received: by 2002:a63:6903:: with SMTP id e3mr17018824pgc.147.1551677186015;
        Sun, 03 Mar 2019 21:26:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551677186; cv=none;
        d=google.com; s=arc-20160816;
        b=txiv6APd0aoOVS0s/hb1+wcYqP5mPZXDm7cVdfK+45FTq037VS92MWQTab4FDuAcII
         cZi9ZXaFV/cCFfhFGb6jBkho85RK0WgQ++4+KC30nF6gAQBtTeOlVni/HNTZMvJhY/iL
         9VVxACmSOsDK4xLbb8EyP+VP1kyDQJByBE+wxqOHyVNdIxrmKgglql6t/eilVAM5gM6A
         kY50GcVmBiqdqj0MlR3QwQMZbAm6KZb4gkb1GF26rJH6uSVilaD5DQ9j4pVvjuGmk+T2
         DlbNX9O0oLGb0XEjgmgX8C6IkNG0IfekO/Z6VPXNIpmxFiOeXUMi2MKwJKwuba9uutFt
         eWcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=aC2HvedaaToK8WRf4rbjRXl4nQTUyYOLv21b3btJFzI=;
        b=Wk7lBzduOWQdhdxDq3Z1NNrHHmR6fVRWintAuU6m5pPamnhlAPtv66t8MdJ2EJudz+
         kqT7FSV8g6BVdE51rX3+OA9TlkC2wF/sm8pIuLluEsyYK8y1tIyGUmwB1Ag5YzBPSeP5
         qyRji10YNxDyq3sYT/t/0rwp0VVbeFjSqnL0EyCZ04mzVUJ8nVbTNTq6O2au8ABJ4dOh
         yLo0+2aqNhqYOVmoMSvLkZWE46Sye5UTzWZ/y7gCKGPey4A128DkTNfcMAS2n3T4PUpX
         DI04dCeCD9SLlunlqsJi9WZ3BwY72IE3IxW8Up1+nMIXzwbH9EGxbi2MdA3Y9ipKw7P9
         Uo6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b="Sub/QE35";
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15sor7179271pfa.40.2019.03.03.21.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 21:26:25 -0800 (PST)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b="Sub/QE35";
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=aC2HvedaaToK8WRf4rbjRXl4nQTUyYOLv21b3btJFzI=;
        b=Sub/QE356BRTkF7kfnrnFntu9oEN0+Otzhk0hCIGH45EbuM33Ntc1qGfvXNOC6iWVX
         CusPRSbJ3Jqf9o/OadX3H7T70jyopgTNZstOCx6CNMRP1kicLBwCtdX86UDarfHZX0lc
         ciuzRspqQIl3HkS7R/1Z+b7ess7DHnqs6tJY4=
X-Google-Smtp-Source: AHgI3IYBTUfI3T7O24BjJtXm7BnZ847rcvHnh5o9LMPNE9CQnfxZDU4wwfvctczWYBko2Tl54TfnCw==
X-Received: by 2002:aa7:9143:: with SMTP id 3mr18347632pfi.238.1551677185269;
        Sun, 03 Mar 2019 21:26:25 -0800 (PST)
Received: from localhost ([203.59.139.100])
        by smtp.gmail.com with ESMTPSA id 23sm7341976pfn.2.2019.03.03.21.26.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Mar 2019 21:26:21 -0800 (PST)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v9 02/11] powerpc: prepare string/mem functions for KASAN
In-Reply-To: <45fb252fc1b27f2804109fa35ba2882ae29e6035.1551443453.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr> <45fb252fc1b27f2804109fa35ba2882ae29e6035.1551443453.git.christophe.leroy@c-s.fr>
Date: Mon, 04 Mar 2019 16:26:18 +1100
Message-ID: <87sgw31a85.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christophe,
> diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
> new file mode 100644
> index 000000000000..c3161b8fc017
> --- /dev/null
> +++ b/arch/powerpc/include/asm/kasan.h
> @@ -0,0 +1,15 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __ASM_KASAN_H
> +#define __ASM_KASAN_H
> +
> +#ifdef CONFIG_KASAN
> +#define _GLOBAL_KASAN(fn)	.weak fn ; _GLOBAL(__##fn) ; _GLOBAL(fn)
> +#define _GLOBAL_TOC_KASAN(fn)	.weak fn ; _GLOBAL_TOC(__##fn) ; _GLOBAL_TOC(fn)
> +#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(__##fn) ; EXPORT_SYMBOL(fn)

I'm having some trouble with this. I get warnings like this:

WARNING: EXPORT symbol "__memcpy" [vmlinux] version generation failed, symbol will not be versioned.

It seems to be related to the export line, as if I swap the exports to
do fn before __##fn I get:

WARNING: EXPORT symbol "memset" [vmlinux] version generation failed, symbol will not be versioned.

I have narrowed this down to combining 2 EXPORT_SYMBOL()s on one line.
This works - no warning:

EXPORT_SYMBOL(memset)
EXPORT_SYMBOL(__memset)

This throws a warning:

EXPORT_SYMBOL(memset) ; EXPORT_SYMBOL(__memset)

I notice in looking at the diff of preprocessed source we end up
invoking an asm macro that doesn't seem to have a full final argument, I
wonder if that's relevant...

-___EXPORT_SYMBOL __memset, __memset, ; ___EXPORT_SYMBOL memset, memset,
+___EXPORT_SYMBOL __memset, __memset,
+___EXPORT_SYMBOL memset, memset,

I also notice that nowhere else in the source do people have multiple
EXPORT_SYMBOLs on the same line, and other arches seem to just
unconditionally export both symbols on multiple lines.

I have no idea how this works for you - maybe it's affected by something 32bit.

How would you feel about this approach instead? I'm not tied to any of
the names or anything.

diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
index e0637730a8e7..7b6a91b448dd 100644
--- a/arch/powerpc/include/asm/ppc_asm.h
+++ b/arch/powerpc/include/asm/ppc_asm.h
@@ -214,6 +214,9 @@ name: \
 
 #define DOTSYM(a)      a
 
+#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
+       .weak weakname ; .set weakname, strongname ;
+
 #else
 
 #define XGLUE(a,b) a##b
@@ -236,6 +239,10 @@ GLUE(.,name):
 
 #define DOTSYM(a)      GLUE(.,a)
 
+#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
+       .weak weakname ; .set weakname, strongname ; \
+       .weak DOTSYM(weakname) ; .set DOTSYM(weakname), DOTSYM(strongname) ;
+
 #endif
 
 #else /* 32-bit */
@@ -251,6 +258,9 @@ GLUE(.,name):
 
 #define _GLOBAL_TOC(name) _GLOBAL(name)
 
+#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
+       .weak weakname ; .set weakname, strongname ;
+
 #endif
 
 /*
--- a/arch/powerpc/lib/mem_64.S
+++ b/arch/powerpc/lib/mem_64.S
@@ -33,7 +33,8 @@ EXPORT_SYMBOL(__memset32)
 EXPORT_SYMBOL(__memset64)
 #endif
 
-_GLOBAL_KASAN(memset)
+PROVIDE_WEAK_ALIAS(__memset,memset)
+_GLOBAL(__memset)
        neg     r0,r3
        rlwimi  r4,r4,8,16,23
        andi.   r0,r0,7                 /* # bytes to be 8-byte aligned */
@@ -98,9 +99,11 @@ _GLOBAL_KASAN(memset)
 10:    bflr    31
        stb     r4,0(r6)
        blr
-EXPORT_SYMBOL_KASAN(memset)
+EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL(__memset)
 
-_GLOBAL_TOC_KASAN(memmove)
+PROVIDE_WEAK_ALIAS(__memmove,memove)
+_GLOBAL_TOC(__memmove)
        cmplw   0,r3,r4
        bgt     backwards_memcpy
        b       memcpy
@@ -141,4 +144,5 @@ _GLOBAL(backwards_memcpy)
        beq     2b
        mtctr   r7
        b       1b
-EXPORT_SYMBOL_KASAN(memmove)
+EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL(__memmove)
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index 862b515b8868..7c1b09556cad 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -19,7 +19,8 @@
 #endif
 
        .align  7
-_GLOBAL_TOC_KASAN(memcpy)
+PROVIDE_WEAK_ALIAS(__memcpy,memcpy)
+_GLOBAL_TOC(__memcpy)
 BEGIN_FTR_SECTION
 #ifdef __LITTLE_ENDIAN__
        cmpdi   cr7,r5,0
@@ -230,4 +231,5 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
 4:     ld      r3,-STACKFRAMESIZE+STK_REG(R31)(r1)     /* return dest pointer */
        blr
 #endif
-EXPORT_SYMBOL_KASAN(memcpy)
+EXPORT_SYMBOL(__memcpy)
+EXPORT_SYMBOL(memcpy)


Regards,
Daniel


> +#else
> +#define _GLOBAL_KASAN(fn)	_GLOBAL(fn)
> +#define _GLOBAL_TOC_KASAN(fn)	_GLOBAL_TOC(fn)
> +#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
> +#endif
> +
> +#endif
> diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
> index 1647de15a31e..9bf6dffb4090 100644
> --- a/arch/powerpc/include/asm/string.h
> +++ b/arch/powerpc/include/asm/string.h
> @@ -4,14 +4,17 @@
>  
>  #ifdef __KERNEL__
>  
> +#ifndef CONFIG_KASAN
>  #define __HAVE_ARCH_STRNCPY
>  #define __HAVE_ARCH_STRNCMP
> +#define __HAVE_ARCH_MEMCHR
> +#define __HAVE_ARCH_MEMCMP
> +#define __HAVE_ARCH_MEMSET16
> +#endif
> +
>  #define __HAVE_ARCH_MEMSET
>  #define __HAVE_ARCH_MEMCPY
>  #define __HAVE_ARCH_MEMMOVE
> -#define __HAVE_ARCH_MEMCMP
> -#define __HAVE_ARCH_MEMCHR
> -#define __HAVE_ARCH_MEMSET16
>  #define __HAVE_ARCH_MEMCPY_FLUSHCACHE
>  
>  extern char * strcpy(char *,const char *);
> @@ -27,7 +30,27 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
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
> +
> +#ifndef __NO_FORTIFY
> +#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
> +#endif
> +
> +#endif
> +
>  #ifdef CONFIG_PPC64
> +#ifndef CONFIG_KASAN
>  #define __HAVE_ARCH_MEMSET32
>  #define __HAVE_ARCH_MEMSET64
>  
> @@ -49,8 +72,11 @@ static inline void *memset64(uint64_t *p, uint64_t v, __kernel_size_t n)
>  {
>  	return __memset64(p, v, n * 8);
>  }
> +#endif
>  #else
> +#ifndef CONFIG_KASAN
>  #define __HAVE_ARCH_STRLEN
> +#endif
>  
>  extern void *memset16(uint16_t *, uint16_t, __kernel_size_t);
>  #endif
> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
> index 667df97d2595..181fd10008ef 100644
> --- a/arch/powerpc/kernel/prom_init_check.sh
> +++ b/arch/powerpc/kernel/prom_init_check.sh
> @@ -16,8 +16,16 @@
>  # If you really need to reference something from prom_init.o add
>  # it to the list below:
>  
> +grep "^CONFIG_KASAN=y$" .config >/dev/null
> +if [ $? -eq 0 ]
> +then
> +	MEM_FUNCS="__memcpy __memset"
> +else
> +	MEM_FUNCS="memcpy memset"
> +fi
> +
>  WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
> -_end enter_prom memcpy memset reloc_offset __secondary_hold
> +_end enter_prom $MEM_FUNCS reloc_offset __secondary_hold
>  __secondary_hold_acknowledge __secondary_hold_spinloop __start
>  strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
>  reloc_got2 kernstart_addr memstart_addr linux_banner _stext
> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
> index 79396e184bca..47a4de434c22 100644
> --- a/arch/powerpc/lib/Makefile
> +++ b/arch/powerpc/lib/Makefile
> @@ -8,9 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>  CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>  
> -obj-y += string.o alloc.o code-patching.o feature-fixups.o
> +obj-y += alloc.o code-patching.o feature-fixups.o
>  
> -obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
> +ifndef CONFIG_KASAN
> +obj-y	+=	string.o memcmp_$(BITS).o
> +obj-$(CONFIG_PPC32)	+= strlen_32.o
> +endif
> +
> +obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o
>  
>  obj-$(CONFIG_FUNCTION_ERROR_INJECTION)	+= error-inject.o
>  
> @@ -34,7 +39,7 @@ obj64-$(CONFIG_KPROBES_SANITY_TEST)	+= test_emulate_step.o \
>  					   test_emulate_step_exec_instr.o
>  
>  obj-y			+= checksum_$(BITS).o checksum_wrappers.o \
> -			   string_$(BITS).o memcmp_$(BITS).o
> +			   string_$(BITS).o
>  
>  obj-y			+= sstep.o ldstfp.o quad.o
>  obj64-y			+= quad.o
> diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
> index ba66846fe973..fc4fa7246200 100644
> --- a/arch/powerpc/lib/copy_32.S
> +++ b/arch/powerpc/lib/copy_32.S
> @@ -14,6 +14,7 @@
>  #include <asm/ppc_asm.h>
>  #include <asm/export.h>
>  #include <asm/code-patching-asm.h>
> +#include <asm/kasan.h>
>  
>  #define COPY_16_BYTES		\
>  	lwz	r7,4(r4);	\
> @@ -68,6 +69,7 @@ CACHELINE_BYTES = L1_CACHE_BYTES
>  LG_CACHELINE_BYTES = L1_CACHE_SHIFT
>  CACHELINE_MASK = (L1_CACHE_BYTES-1)
>  
> +#ifndef CONFIG_KASAN
>  _GLOBAL(memset16)
>  	rlwinm.	r0 ,r5, 31, 1, 31
>  	addi	r6, r3, -4
> @@ -81,6 +83,7 @@ _GLOBAL(memset16)
>  	sth	r4, 4(r6)
>  	blr
>  EXPORT_SYMBOL(memset16)
> +#endif
>  
>  /*
>   * Use dcbz on the complete cache lines in the destination
> @@ -91,7 +94,7 @@ EXPORT_SYMBOL(memset16)
>   * We therefore skip the optimised bloc that uses dcbz. This jump is
>   * replaced by a nop once cache is active. This is done in machine_init()
>   */
> -_GLOBAL(memset)
> +_GLOBAL_KASAN(memset)
>  	cmplwi	0,r5,4
>  	blt	7f
>  
> @@ -150,7 +153,7 @@ _GLOBAL(memset)
>  9:	stbu	r4,1(r6)
>  	bdnz	9b
>  	blr
> -EXPORT_SYMBOL(memset)
> +EXPORT_SYMBOL_KASAN(memset)
>  
>  /*
>   * This version uses dcbz on the complete cache lines in the
> @@ -163,12 +166,12 @@ EXPORT_SYMBOL(memset)
>   * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
>   * replaced by a nop once cache is active. This is done in machine_init()
>   */
> -_GLOBAL(memmove)
> +_GLOBAL_KASAN(memmove)
>  	cmplw	0,r3,r4
>  	bgt	backwards_memcpy
>  	/* fall through */
>  
> -_GLOBAL(memcpy)
> +_GLOBAL_KASAN(memcpy)
>  1:	b	generic_memcpy
>  	patch_site	1b, patch__memcpy_nocache
>  
> @@ -242,8 +245,8 @@ _GLOBAL(memcpy)
>  	stbu	r0,1(r6)
>  	bdnz	40b
>  65:	blr
> -EXPORT_SYMBOL(memcpy)
> -EXPORT_SYMBOL(memmove)
> +EXPORT_SYMBOL_KASAN(memcpy)
> +EXPORT_SYMBOL_KASAN(memmove)
>  
>  generic_memcpy:
>  	srwi.	r7,r5,3
> diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
> index 3c3be02f33b7..7cd6cf6822a2 100644
> --- a/arch/powerpc/lib/mem_64.S
> +++ b/arch/powerpc/lib/mem_64.S
> @@ -12,7 +12,9 @@
>  #include <asm/errno.h>
>  #include <asm/ppc_asm.h>
>  #include <asm/export.h>
> +#include <asm/kasan.h>
>  
> +#ifndef CONFIG_KASAN
>  _GLOBAL(__memset16)
>  	rlwimi	r4,r4,16,0,15
>  	/* fall through */
> @@ -29,8 +31,9 @@ _GLOBAL(__memset64)
>  EXPORT_SYMBOL(__memset16)
>  EXPORT_SYMBOL(__memset32)
>  EXPORT_SYMBOL(__memset64)
> +#endif
>  
> -_GLOBAL(memset)
> +_GLOBAL_KASAN(memset)
>  	neg	r0,r3
>  	rlwimi	r4,r4,8,16,23
>  	andi.	r0,r0,7			/* # bytes to be 8-byte aligned */
> @@ -95,9 +98,9 @@ _GLOBAL(memset)
>  10:	bflr	31
>  	stb	r4,0(r6)
>  	blr
> -EXPORT_SYMBOL(memset)
> +EXPORT_SYMBOL_KASAN(memset)
>  
> -_GLOBAL_TOC(memmove)
> +_GLOBAL_TOC_KASAN(memmove)
>  	cmplw	0,r3,r4
>  	bgt	backwards_memcpy
>  	b	memcpy
> @@ -138,4 +141,4 @@ _GLOBAL(backwards_memcpy)
>  	beq	2b
>  	mtctr	r7
>  	b	1b
> -EXPORT_SYMBOL(memmove)
> +EXPORT_SYMBOL_KASAN(memmove)
> diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
> index 273ea67e60a1..862b515b8868 100644
> --- a/arch/powerpc/lib/memcpy_64.S
> +++ b/arch/powerpc/lib/memcpy_64.S
> @@ -11,6 +11,7 @@
>  #include <asm/export.h>
>  #include <asm/asm-compat.h>
>  #include <asm/feature-fixups.h>
> +#include <asm/kasan.h>
>  
>  #ifndef SELFTEST_CASE
>  /* For big-endian, 0 == most CPUs, 1 == POWER6, 2 == Cell */
> @@ -18,7 +19,7 @@
>  #endif
>  
>  	.align	7
> -_GLOBAL_TOC(memcpy)
> +_GLOBAL_TOC_KASAN(memcpy)
>  BEGIN_FTR_SECTION
>  #ifdef __LITTLE_ENDIAN__
>  	cmpdi	cr7,r5,0
> @@ -229,4 +230,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
>  4:	ld	r3,-STACKFRAMESIZE+STK_REG(R31)(r1)	/* return dest pointer */
>  	blr
>  #endif
> -EXPORT_SYMBOL(memcpy)
> +EXPORT_SYMBOL_KASAN(memcpy)
> -- 
> 2.13.3

