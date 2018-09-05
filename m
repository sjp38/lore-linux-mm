Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD3A6B71E2
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 03:45:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d132-v6so3187164pgc.22
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 00:45:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (lgeamrelo11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 97-v6si1251115plm.290.2018.09.05.00.44.59
        for <linux-mm@kvack.org>;
        Wed, 05 Sep 2018 00:44:59 -0700 (PDT)
Subject: Re: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
 <12d4e435-e229-b4af-4286-a53fa77cb09d@virtuozzo.com>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <0bde837e-2804-c6d6-4bda-8b166bdcfc6b@lge.com>
Date: Wed, 5 Sep 2018 16:44:54 +0900
MIME-Version: 1.0
In-Reply-To: <12d4e435-e229-b4af-4286-a53fa77cb09d@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com, Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 2018-09-05 i??i ? 1:24, Andrey Ryabinin wrote:
>
>
> On 09/04/2018 01:10 PM, Andrey Ryabinin wrote:
> >
> >
> > On 09/04/2018 09:59 AM, Kyeongdon Kim wrote:
> >
> >>>> +#undef strncmp
> >>>> +int strncmp(const char *cs, const char *ct, size_t len)
> >>>> +{
> >>>> + check_memory_region((unsigned long)cs, len, false, _RET_IP_);
> >>>> + check_memory_region((unsigned long)ct, len, false, _RET_IP_);
> >>>
> >>> This will cause false positives. Both 'cs', and 'ct' could be less 
> than len bytes.
> >>>
> >>> There is no need in these interceptors, just use the C 
> implementations from lib/string.c
> >>> like you did in your first patch.
> >>> The only thing that was wrong in the first patch is that assembly 
> implementations
> >>> were compiled out instead of being declared week.
> >>>
> >> Well, at first I thought so..
> >> I would remove diff code in /mm/kasan/kasan.c then use C 
> implementations in lib/string.c
> >> w/ assem implementations as weak :
> >>
> >> diff --git a/lib/string.c b/lib/string.c
> >> index 2c0900a..a18b18f 100644
> >> --- a/lib/string.c
> >> +++ b/lib/string.c
> >> @@ -312,7 +312,7 @@ size_t strlcat(char *dest, const char *src, 
> size_t count)
> >> A EXPORT_SYMBOL(strlcat);
> >> A #endif
> >>
> >> -#ifndef __HAVE_ARCH_STRCMP
> >> +#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || 
> !defined(__HAVE_ARCH_STRCMP)
> >
> > No. What part of "like you did in your first patch" is unclear to you?
>
> Just to be absolutely clear, I meant #ifdef out __HAVE_ARCH_* defines 
> like it has been done in this patch
> http://lkml.kernel.org/r/<1534233322-106271-1-git-send-email-kyeongdon.kim@lge.com> 
>
I understood what you're saying, but I might think the wrong patch.

So, thinking about the other way as below:
can pick up assem variant or c one, declare them as weak.
---
diff --git a/arch/arm64/include/asm/string.h 
b/arch/arm64/include/asm/string.h
index dd95d33..53a2ae0 100644
--- a/arch/arm64/include/asm/string.h
+++ b/arch/arm64/include/asm/string.h
@@ -22,11 +22,22 @@ extern char *strrchr(const char *, int c);
 A #define __HAVE_ARCH_STRCHR
 A extern char *strchr(const char *, int c);

+#ifdef CONFIG_KASAN
+extern int __strcmp(const char *, const char *);
+extern int __strncmp(const char *, const char *, __kernel_size_t);
+
+#ifndef __SANITIZE_ADDRESS__
+#define strcmp(cs, ct) __strcmp(cs, ct)
+#define strncmp(cs, ct, n) __strncmp(cs, ct, n)
+#endif
+
+#else
 A #define __HAVE_ARCH_STRCMP
 A extern int strcmp(const char *, const char *);

 A #define __HAVE_ARCH_STRNCMP
 A extern int strncmp(const char *, const char *, __kernel_size_t);
+#endif

 A #define __HAVE_ARCH_STRLEN
 A extern __kernel_size_t strlen(const char *);
diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
index d894a20..9aeffd5 100644
--- a/arch/arm64/kernel/arm64ksyms.c
+++ b/arch/arm64/kernel/arm64ksyms.c
@@ -50,6 +50,10 @@ EXPORT_SYMBOL(strcmp);
 A EXPORT_SYMBOL(strncmp);
 A EXPORT_SYMBOL(strlen);
 A EXPORT_SYMBOL(strnlen);
+#ifdef CONFIG_KASAN
+EXPORT_SYMBOL(__strcmp);
+EXPORT_SYMBOL(__strncmp);
+#endif
 A EXPORT_SYMBOL(memset);
 A EXPORT_SYMBOL(memcpy);
 A EXPORT_SYMBOL(memmove);
diff --git a/arch/arm64/kernel/image.h b/arch/arm64/kernel/image.h
index a820ed0..5ef7a57 100644
--- a/arch/arm64/kernel/image.h
+++ b/arch/arm64/kernel/image.h
@@ -110,6 +110,8 @@ __efistub___flush_dcache_areaA A A  = 
KALLSYMS_HIDE(__pi___flush_dcache_area);
 A __efistub___memcpyA A A  A A A  = KALLSYMS_HIDE(__pi_memcpy);
 A __efistub___memmoveA A A  A A A  = KALLSYMS_HIDE(__pi_memmove);
 A __efistub___memsetA A A  A A A  = KALLSYMS_HIDE(__pi_memset);
+__efistub___strcmpA A A  A A A  = KALLSYMS_HIDE(__pi_strcmp);
+__efistub___strncmpA A A  A A A  = KALLSYMS_HIDE(__pi_strncmp);
 A #endif

 A __efistub__textA A A  A A A  A A A  = KALLSYMS_HIDE(_text);
diff --git a/arch/arm64/lib/strcmp.S b/arch/arm64/lib/strcmp.S
index 471fe61..0dffef7 100644
--- a/arch/arm64/lib/strcmp.S
+++ b/arch/arm64/lib/strcmp.S
@@ -60,6 +60,8 @@ tmp3A A A  A A A  .reqA A A  x9
 A zeroonesA A A  .reqA A A  x10
 A posA A A  A A A  .reqA A A  x11

+.weak strcmp
+ENTRY(__strcmp)
 A ENTRY(strcmp)
 A A A A  eorA A A  tmp1, src1, src2
 A A A A  movA A A  zeroones, #REP8_01
@@ -232,3 +234,4 @@ CPU_BE(A A A  orrA A A  syndrome, diff, has_nul )
 A A A A  subA A A  result, data1, data2, lsr #56
 A A A A  ret
 A ENDPIPROC(strcmp)
+ENDPROC(__strcmp)
diff --git a/arch/arm64/lib/strncmp.S b/arch/arm64/lib/strncmp.S
index e267044..b2648c7 100644
--- a/arch/arm64/lib/strncmp.S
+++ b/arch/arm64/lib/strncmp.S
@@ -64,6 +64,8 @@ limit_wdA A A  .reqA A A  x13
 A maskA A A  A A A  .reqA A A  x14
 A endloopA A A  A A A  .reqA A A  x15

+.weak strncmp
+ENTRY(__strncmp)
 A ENTRY(strncmp)
 A A A A  cbzA A A  limit, .Lret0
 A A A A  eorA A A  tmp1, src1, src2
@@ -308,3 +310,4 @@ CPU_BE( orrA A A  syndrome, diff, has_nul )
 A A A A  movA A A  result, #0
 A A A A  ret
 A ENDPIPROC(strncmp)
+ENDPROC(__strncmp)
-- 
Could you review this diff?
