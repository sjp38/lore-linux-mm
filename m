Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1710CC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:41:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3621222D7
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:41:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="pKBz2/3t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3621222D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 268AA8E0002; Fri, 15 Feb 2019 03:41:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F11A8E0001; Fri, 15 Feb 2019 03:41:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06B818E0002; Fri, 15 Feb 2019 03:41:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE9C8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:41:23 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id h65so144544wrh.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 00:41:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bvvWeQXbeVOmP2RoOlaiBQ0N7R7aDnT6BVTKaC+FPCA=;
        b=bMrZamMpt2HQvEqhDHsKQfBjl3iN2Y49jFpGm22VjNdSKxY4R1pkCQefO9iL/8yyir
         4PXH/bfmgJkIWnflmJeD1QCogaNufHkTKlU49BD1rBBqevMiOdTtbbcCEhcyZEun1/hr
         7m98ssHsxXs90dm6osyMKjC0n+58vyYPNznqyhHgkmXodz773oEQCtp7heUK6Egt5OTl
         3rRXsd/yQMPhXPC4h9naf70+0NpB1E792YA2y39KdyBspMNLbfCH3T3cKiMlf1hFm5xk
         0dEMn5RXvGG4+z1mFavC2btKN66D7XBJYunvjyf56I/zL/7GW/Hsrl8cTMFymu4Vc5rf
         ZNeQ==
X-Gm-Message-State: AHQUAub1SqY5MSm9ZrUj56dIf+qhk6medPUiFVh4bLtIU/mDMgoNrEGt
	nr/jTXeQecYprnr63FywyJnb24oW8pExrqXDCPhZqycbZrNB1B1MYMryIy8biJMc4NFx+g7QiV1
	qiwY4lcLV9cr/J1J3EZ6C2Y2QuffsUkg789BvwxcMoUM3q8tzZTpRwcoOm2MHP9GZnA==
X-Received: by 2002:adf:eb48:: with SMTP id u8mr5848455wrn.198.1550220082764;
        Fri, 15 Feb 2019 00:41:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaozVy++ksXN1PQbWhgQLL7bWaFnN5WFlrZKKadIAMRmMdUWU8/uLk3VQ98cPjPrfL7qX4M
X-Received: by 2002:adf:eb48:: with SMTP id u8mr5848364wrn.198.1550220080934;
        Fri, 15 Feb 2019 00:41:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550220080; cv=none;
        d=google.com; s=arc-20160816;
        b=QVzBnWgR1WVh0JVp4VJhaScwUDcIttQNcdGZyVeVQIJw8B0A40cSicI3p3WA2eqB4X
         t+CPOTeulfHgQW3N3VCibicX4/K1WoUWutJiiEHBE34VbbroOCJkBko9HKWrFHEKCuFb
         5ai73wPzRwOuj6l9hS4SpcbY1DQW0lT/+3QJFwPEEmTNVfkOOkxU5xUoulWQ4i8QWOjk
         qC8lo5Gsbv1IOtf9+2/ZVHqRmkzCEsVzMjwKWHJ57pvXG0tFzdeusp7uTGRbVUqm6MI0
         ZBimwWMjMsqKKRRlqNO4LwPVga1R8caokK2gEdjD5+VXSeN+wEI6BKiG+EzKbvKjQBAr
         c2Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=bvvWeQXbeVOmP2RoOlaiBQ0N7R7aDnT6BVTKaC+FPCA=;
        b=oF1t7CSxgm4AwMQayVLfd5IWeVi8F4Vw3up64JUlLWHjfpNvjjzEiNZz3A57nkHahO
         PSwZyh8C7IKaei3jNYn+/DYyArgtqMtvXjwGWgNedR+1omUyh4oMSIteHmKPoRoIo1Te
         4ROHZ0gzRoOah1dC+85iTLrwDWMNCn44Mx0yVko0PHWrYi3UHrtlzj6fJIRro/2ymhrS
         WPGtf2b8qkoT9ds1wWEr4bDvGvKy26F3Kelo8y/D7+NHxCwcjD61MBSi4kJmDHywbf1Y
         jbc153ve5VsNXGMatrWGTPZdrUQv3CJuI8lWbexFkJ/U0XMPH5z8QVj62EZJGmt6zNjb
         S8jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="pKBz2/3t";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id c2si3298065wrq.134.2019.02.15.00.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 00:41:20 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="pKBz2/3t";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4416Db1fGPz9v0N9;
	Fri, 15 Feb 2019 09:41:19 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=pKBz2/3t; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 3HD4heEMXDFX; Fri, 15 Feb 2019 09:41:19 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4416Db0PlDz9v0N7;
	Fri, 15 Feb 2019 09:41:19 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550220079; bh=bvvWeQXbeVOmP2RoOlaiBQ0N7R7aDnT6BVTKaC+FPCA=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=pKBz2/3txpu0uzpCwEhAOarsqdQw27zpTvVeE/wtUxKVj00iEBvoMIlKYg7rM+PQ1
	 NY8+1FJQ7nboSsk0Xb0sH1HzXVSGq7WPLEHsNXziuzGYeMliXgnw/KbScd+OPMhQv2
	 xfFfDZhxI2b4a5++Cb44W8al/OWTxQtzD7OaEy6Y=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 15C878B8C1;
	Fri, 15 Feb 2019 09:41:20 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id HaUQ8kQJ_PVv; Fri, 15 Feb 2019 09:41:19 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D8A018B8B5;
	Fri, 15 Feb 2019 09:41:19 +0100 (CET)
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
To: Daniel Axtens <dja@axtens.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 kasan-dev@googlegroups.com, linux-mm@kvack.org
References: <cover.1549935247.git.christophe.leroy@c-s.fr>
 <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
 <8736oq3u2r.fsf@dja-thinkpad.axtens.net>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <b5db7714-51e3-785c-34ca-6c358661c9e8@c-s.fr>
Date: Fri, 15 Feb 2019 09:41:19 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <8736oq3u2r.fsf@dja-thinkpad.axtens.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 14/02/2019 à 23:04, Daniel Axtens a écrit :
> Hi Christophe,
> 
>> --- a/arch/powerpc/include/asm/string.h
>> +++ b/arch/powerpc/include/asm/string.h
>> @@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>>   extern void * memchr(const void *,int,__kernel_size_t);
>>   extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>>   
>> +void *__memset(void *s, int c, __kernel_size_t count);
>> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
>> +void *__memmove(void *to, const void *from, __kernel_size_t n);
>> +
>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>> +/*
>> + * For files that are not instrumented (e.g. mm/slub.c) we
>> + * should use not instrumented version of mem* functions.
>> + */
>> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
>> +#define memmove(dst, src, len) __memmove(dst, src, len)
>> +#define memset(s, c, n) __memset(s, c, n)
>> +#endif
>> +
> 
> I'm finding that I miss tests like 'kasan test: kasan_memcmp
> out-of-bounds in memcmp' because the uninstrumented asm version is used
> instead of an instrumented C version. I ended up guarding the relevant
> __HAVE_ARCH_x symbols behind a #ifndef CONFIG_KASAN and only exporting
> the arch versions if we're not compiled with KASAN.
> 
> I find I need to guard and unexport strncpy, strncmp, memchr and
> memcmp. Do you need to do this on 32bit as well, or are those tests
> passing anyway for some reason?

Indeed, I didn't try the KASAN test module recently, because my configs 
don't have CONFIG_MODULE by default.

Trying to test it now, I am discovering that module loading oopses with 
latest version of my series, I need to figure out exactly why. Here 
below the oops by modprobing test_module (the one supposed to just say 
hello to the world).

What we see is an access to the RO kasan zero area.

The shadow mem is 0xf7c00000..0xffc00000
Linear kernel memory is shadowed by 0xf7c00000-0xf8bfffff
0xf8c00000-0xffc00000 is shadowed read only by the kasan zero page.

Why is kasan trying to access that ? Isn't kasan supposed to not check 
stuff in vmalloc area ?

[  189.087499] BUG: Unable to handle kernel data access at 0xf8eb7818
[  189.093455] Faulting instruction address: 0xc001ab60
[  189.098383] Oops: Kernel access of bad area, sig: 11 [#1]
[  189.103732] BE PAGE_SIZE=16K PREEMPT CMPC885
[  189.111414] Modules linked in: test_module(+)
[  189.115817] CPU: 0 PID: 514 Comm: modprobe Not tainted 
5.0.0-rc5-s3k-dev-00645-g1dd3acf23952 #1016
[  189.124627] NIP:  c001ab60 LR: c0194fe8 CTR: 00000003
[  189.129641] REGS: c5645b90 TRAP: 0300   Not tainted 
(5.0.0-rc5-s3k-dev-00645-g1dd3acf23952)
[  189.137924] MSR:  00009032 <EE,ME,IR,DR,RI>  CR: 44002884  XER: 00000000
[  189.144571] DAR: f8eb7818 DSISR: 8a000000
[  189.144571] GPR00: c0196620 c5645c40 c5aac000 f8eb7818 00000000 
00000003 f8eb7817 c01950d0
[  189.144571] GPR08: c00c2720 c95bc010 00000000 c95bc1a0 c01965ec 
100d7b30 c0802b80 c5ae0308
[  189.144571] GPR16: c5990480 00000124 0000000f c00bcf7c c5ae0324 
c95bc32c 000006b8 00000001
[  189.144571] GPR24: c95bc364 c95bc360 c95bc2c0 c95bc1a0 00000002 
00000000 00000018 f8eb781b
[  189.182611] NIP [c001ab60] __memset+0xb4/0xc0
[  189.186922] LR [c0194fe8] kasan_unpoison_shadow+0x34/0x54
[  189.192136] Call Trace:
[  189.194682] [c5645c50] [c0196620] __asan_register_globals+0x34/0x74
[  189.200900] [c5645c70] [c00c27a4] do_init_module+0xbc/0x5a4
[  189.206392] [c5645ca0] [c00c0d08] load_module+0x2b5c/0x3194
[  189.211901] [c5645e70] [c00c14c8] sys_init_module+0x188/0x1bc
[  189.217572] [c5645f40] [c001311c] ret_from_syscall+0x0/0x38
[  189.223049] --- interrupt: c01 at 0xfda2b50
[  189.223049]     LR = 0x10014b18
[  189.230175] Instruction dump:
[  189.233117] 4200fffc 70a50003 4d820020 7ca903a6 38c60003 9c860001 
4200fffc 4e800020
[  189.240859] 2c050000 4d820020 7ca903a6 38c3ffff <9c860001> 4200fffc 
4e800020 7c032040
[  189.248809] ---[ end trace 45cbb1b3215e5959 ]---

Christophe

> 
> Regards,
> Daniel
> 
> 
>>   #ifdef CONFIG_PPC64
>>   #define __HAVE_ARCH_MEMSET32
>>   #define __HAVE_ARCH_MEMSET64
>> diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
>> index 879b36602748..fc4c42262694 100644
>> --- a/arch/powerpc/kernel/Makefile
>> +++ b/arch/powerpc/kernel/Makefile
>> @@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
>>   CFLAGS_btext.o		+= -fPIC
>>   endif
>>   
>> -CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>> -CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>> +CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
>>   CFLAGS_btext.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>>   CFLAGS_prom.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>>   
>> @@ -31,6 +32,10 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
>>   CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
>>   endif
>>   
>> +KASAN_SANITIZE_early_32.o := n
>> +KASAN_SANITIZE_cputable.o := n
>> +KASAN_SANITIZE_prom_init.o := n
>> +
>>   obj-y				:= cputable.o ptrace.o syscalls.o \
>>   				   irq.o align.o signal_32.o pmc.o vdso.o \
>>   				   process.o systbl.o idle.o \
>> diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
>> index 9ffc72ded73a..846fb30b1190 100644
>> --- a/arch/powerpc/kernel/asm-offsets.c
>> +++ b/arch/powerpc/kernel/asm-offsets.c
>> @@ -783,5 +783,9 @@ int main(void)
>>   	DEFINE(VIRT_IMMR_BASE, (u64)__fix_to_virt(FIX_IMMR_BASE));
>>   #endif
>>   
>> +#ifdef CONFIG_KASAN
>> +	DEFINE(KASAN_SHADOW_OFFSET, KASAN_SHADOW_OFFSET);
>> +#endif
>> +
>>   	return 0;
>>   }
>> diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
>> index 05b08db3901d..0ec9dec06bc2 100644
>> --- a/arch/powerpc/kernel/head_32.S
>> +++ b/arch/powerpc/kernel/head_32.S
>> @@ -962,6 +962,9 @@ start_here:
>>    * Do early platform-specific initialization,
>>    * and set up the MMU.
>>    */
>> +#ifdef CONFIG_KASAN
>> +	bl	kasan_early_init
>> +#endif
>>   	li	r3,0
>>   	mr	r4,r31
>>   	bl	machine_init
>> diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
>> index b19d78410511..5d6ff8fa7e2b 100644
>> --- a/arch/powerpc/kernel/head_40x.S
>> +++ b/arch/powerpc/kernel/head_40x.S
>> @@ -848,6 +848,9 @@ start_here:
>>   /*
>>    * Decide what sort of machine this is and initialize the MMU.
>>    */
>> +#ifdef CONFIG_KASAN
>> +	bl	kasan_early_init
>> +#endif
>>   	li	r3,0
>>   	mr	r4,r31
>>   	bl	machine_init
>> diff --git a/arch/powerpc/kernel/head_44x.S b/arch/powerpc/kernel/head_44x.S
>> index bf23c19c92d6..7ca14dff6192 100644
>> --- a/arch/powerpc/kernel/head_44x.S
>> +++ b/arch/powerpc/kernel/head_44x.S
>> @@ -203,6 +203,9 @@ _ENTRY(_start);
>>   /*
>>    * Decide what sort of machine this is and initialize the MMU.
>>    */
>> +#ifdef CONFIG_KASAN
>> +	bl	kasan_early_init
>> +#endif
>>   	li	r3,0
>>   	mr	r4,r31
>>   	bl	machine_init
>> diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
>> index 0fea10491f3a..6a644ea2e6b6 100644
>> --- a/arch/powerpc/kernel/head_8xx.S
>> +++ b/arch/powerpc/kernel/head_8xx.S
>> @@ -823,6 +823,9 @@ start_here:
>>   /*
>>    * Decide what sort of machine this is and initialize the MMU.
>>    */
>> +#ifdef CONFIG_KASAN
>> +	bl	kasan_early_init
>> +#endif
>>   	li	r3,0
>>   	mr	r4,r31
>>   	bl	machine_init
>> diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
>> index 2386ce2a9c6e..4f4585a68850 100644
>> --- a/arch/powerpc/kernel/head_fsl_booke.S
>> +++ b/arch/powerpc/kernel/head_fsl_booke.S
>> @@ -274,6 +274,9 @@ set_ivor:
>>   /*
>>    * Decide what sort of machine this is and initialize the MMU.
>>    */
>> +#ifdef CONFIG_KASAN
>> +	bl	kasan_early_init
>> +#endif
>>   	mr	r3,r30
>>   	mr	r4,r31
>>   	bl	machine_init
>> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
>> index 667df97d2595..da6bb16e0876 100644
>> --- a/arch/powerpc/kernel/prom_init_check.sh
>> +++ b/arch/powerpc/kernel/prom_init_check.sh
>> @@ -16,8 +16,16 @@
>>   # If you really need to reference something from prom_init.o add
>>   # it to the list below:
>>   
>> +grep CONFIG_KASAN=y .config >/dev/null
>> +if [ $? -eq 0 ]
>> +then
>> +	MEMFCT="__memcpy __memset"
>> +else
>> +	MEMFCT="memcpy memset"
>> +fi
>> +
>>   WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
>> -_end enter_prom memcpy memset reloc_offset __secondary_hold
>> +_end enter_prom $MEMFCT reloc_offset __secondary_hold
>>   __secondary_hold_acknowledge __secondary_hold_spinloop __start
>>   strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
>>   reloc_got2 kernstart_addr memstart_addr linux_banner _stext
>> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
>> index ca00fbb97cf8..16ff1ea66805 100644
>> --- a/arch/powerpc/kernel/setup-common.c
>> +++ b/arch/powerpc/kernel/setup-common.c
>> @@ -978,6 +978,8 @@ void __init setup_arch(char **cmdline_p)
>>   
>>   	paging_init();
>>   
>> +	kasan_init();
>> +
>>   	/* Initialize the MMU context management stuff. */
>>   	mmu_context_init();
>>   
>> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
>> index 3bf9fc6fd36c..ce8d4a9f810a 100644
>> --- a/arch/powerpc/lib/Makefile
>> +++ b/arch/powerpc/lib/Makefile
>> @@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>>   CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>>   CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>>   
>> +KASAN_SANITIZE_code-patching.o := n
>> +KASAN_SANITIZE_feature-fixups.o := n
>> +
>> +ifdef CONFIG_KASAN
>> +CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
>> +endif
>> +
>>   obj-y += string.o alloc.o code-patching.o feature-fixups.o
>>   
>>   obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
>> diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
>> index ba66846fe973..4d8a1c73b4cf 100644
>> --- a/arch/powerpc/lib/copy_32.S
>> +++ b/arch/powerpc/lib/copy_32.S
>> @@ -91,7 +91,8 @@ EXPORT_SYMBOL(memset16)
>>    * We therefore skip the optimised bloc that uses dcbz. This jump is
>>    * replaced by a nop once cache is active. This is done in machine_init()
>>    */
>> -_GLOBAL(memset)
>> +_GLOBAL(__memset)
>> +KASAN_OVERRIDE(memset, __memset)
>>   	cmplwi	0,r5,4
>>   	blt	7f
>>   
>> @@ -163,12 +164,14 @@ EXPORT_SYMBOL(memset)
>>    * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
>>    * replaced by a nop once cache is active. This is done in machine_init()
>>    */
>> -_GLOBAL(memmove)
>> +_GLOBAL(__memmove)
>> +KASAN_OVERRIDE(memmove, __memmove)
>>   	cmplw	0,r3,r4
>>   	bgt	backwards_memcpy
>>   	/* fall through */
>>   
>> -_GLOBAL(memcpy)
>> +_GLOBAL(__memcpy)
>> +KASAN_OVERRIDE(memcpy, __memcpy)
>>   1:	b	generic_memcpy
>>   	patch_site	1b, patch__memcpy_nocache
>>   
>> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
>> index f965fc33a8b7..d6b76f25f6de 100644
>> --- a/arch/powerpc/mm/Makefile
>> +++ b/arch/powerpc/mm/Makefile
>> @@ -7,6 +7,8 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>>   
>>   CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
>>   
>> +KASAN_SANITIZE_kasan_init.o := n
>> +
>>   obj-y				:= fault.o mem.o pgtable.o mmap.o \
>>   				   init_$(BITS).o pgtable_$(BITS).o \
>>   				   init-common.o mmu_context.o drmem.o
>> @@ -55,3 +57,4 @@ obj-$(CONFIG_PPC_BOOK3S_64)	+= dump_linuxpagetables-book3s64.o
>>   endif
>>   obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
>>   obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
>> +obj-$(CONFIG_KASAN)		+= kasan_init.o
>> diff --git a/arch/powerpc/mm/dump_linuxpagetables.c b/arch/powerpc/mm/dump_linuxpagetables.c
>> index 6aa41669ac1a..c862b48118f1 100644
>> --- a/arch/powerpc/mm/dump_linuxpagetables.c
>> +++ b/arch/powerpc/mm/dump_linuxpagetables.c
>> @@ -94,6 +94,10 @@ static struct addr_marker address_markers[] = {
>>   	{ 0,	"Consistent mem start" },
>>   	{ 0,	"Consistent mem end" },
>>   #endif
>> +#ifdef CONFIG_KASAN
>> +	{ 0,	"kasan shadow mem start" },
>> +	{ 0,	"kasan shadow mem end" },
>> +#endif
>>   #ifdef CONFIG_HIGHMEM
>>   	{ 0,	"Highmem PTEs start" },
>>   	{ 0,	"Highmem PTEs end" },
>> @@ -310,6 +314,10 @@ static void populate_markers(void)
>>   	address_markers[i++].start_address = IOREMAP_TOP +
>>   					     CONFIG_CONSISTENT_SIZE;
>>   #endif
>> +#ifdef CONFIG_KASAN
>> +	address_markers[i++].start_address = KASAN_SHADOW_START;
>> +	address_markers[i++].start_address = KASAN_SHADOW_END;
>> +#endif
>>   #ifdef CONFIG_HIGHMEM
>>   	address_markers[i++].start_address = PKMAP_BASE;
>>   	address_markers[i++].start_address = PKMAP_ADDR(LAST_PKMAP);
>> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
>> new file mode 100644
>> index 000000000000..bd8e0a263e12
>> --- /dev/null
>> +++ b/arch/powerpc/mm/kasan_init.c
>> @@ -0,0 +1,114 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +
>> +#define DISABLE_BRANCH_PROFILING
>> +
>> +#include <linux/kasan.h>
>> +#include <linux/printk.h>
>> +#include <linux/memblock.h>
>> +#include <linux/sched/task.h>
>> +#include <asm/pgalloc.h>
>> +
>> +void __init kasan_early_init(void)
>> +{
>> +	unsigned long addr = KASAN_SHADOW_START;
>> +	unsigned long end = KASAN_SHADOW_END;
>> +	unsigned long next;
>> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>> +	int i;
>> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
>> +
>> +	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>> +
>> +	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>> +		panic("KASAN not supported with Hash MMU\n");
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>> +		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
>> +			     kasan_early_shadow_pte + i,
>> +			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL), 0);
>> +
>> +	do {
>> +		next = pgd_addr_end(addr, end);
>> +		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
>> +	} while (pmd++, addr = next, addr != end);
>> +}
>> +
>> +static void __init kasan_init_region(struct memblock_region *reg)
>> +{
>> +	void *start = __va(reg->base);
>> +	void *end = __va(reg->base + reg->size);
>> +	unsigned long k_start, k_end, k_cur, k_next;
>> +	pmd_t *pmd;
>> +	void *block;
>> +
>> +	if (start >= end)
>> +		return;
>> +
>> +	k_start = (unsigned long)kasan_mem_to_shadow(start);
>> +	k_end = (unsigned long)kasan_mem_to_shadow(end);
>> +	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
>> +
>> +	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
>> +		k_next = pgd_addr_end(k_cur, k_end);
>> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
>> +			pte_t *new = pte_alloc_one_kernel(&init_mm);
>> +
>> +			if (!new)
>> +				panic("kasan: pte_alloc_one_kernel() failed");
>> +			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
>> +			pmd_populate_kernel(&init_mm, pmd, new);
>> +		}
>> +	};
>> +
>> +	block = memblock_alloc(k_end - k_start, PAGE_SIZE);
>> +	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
>> +		void *va = block ? block + k_cur - k_start :
>> +				   memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>> +		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
>> +
>> +		if (!va)
>> +			panic("kasan: memblock_alloc() failed");
>> +		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
>> +		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
>> +	}
>> +	flush_tlb_kernel_range(k_start, k_end);
>> +}
>> +
>> +static void __init kasan_remap_early_shadow_ro(void)
>> +{
>> +	unsigned long k_cur;
>> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
>> +	int i;
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>> +		ptep_set_wrprotect(&init_mm, 0, kasan_early_shadow_pte + i);
>> +
>> +	for (k_cur = PAGE_OFFSET & PAGE_MASK; k_cur; k_cur += PAGE_SIZE) {
>> +		pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
>> +		pte_t *ptep = pte_offset_kernel(pmd, k_cur);
>> +
>> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte)
>> +			continue;
>> +		if ((pte_val(*ptep) & PAGE_MASK) != pa)
>> +			continue;
>> +
>> +		ptep_set_wrprotect(&init_mm, k_cur, ptep);
>> +	}
>> +	flush_tlb_mm(&init_mm);
>> +}
>> +
>> +void __init kasan_init(void)
>> +{
>> +	struct memblock_region *reg;
>> +
>> +	for_each_memblock(memory, reg)
>> +		kasan_init_region(reg);
>> +
>> +	kasan_remap_early_shadow_ro();
>> +
>> +	clear_page(kasan_early_shadow_page);
>> +
>> +	/* At this point kasan is fully initialized. Enable error messages */
>> +	init_task.kasan_depth = 0;
>> +	pr_info("KASAN init done\n");
>> +}
>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>> index 81f251fc4169..1bb055775e60 100644
>> --- a/arch/powerpc/mm/mem.c
>> +++ b/arch/powerpc/mm/mem.c
>> @@ -336,6 +336,10 @@ void __init mem_init(void)
>>   	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
>>   		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
>>   #endif /* CONFIG_HIGHMEM */
>> +#ifdef CONFIG_KASAN
>> +	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
>> +		KASAN_SHADOW_START, KASAN_SHADOW_END);
>> +#endif
>>   #ifdef CONFIG_NOT_COHERENT_CACHE
>>   	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
>>   		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
>> -- 
>> 2.13.3

