Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA7336B6C32
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 02:59:21 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 2-v6so1444704plc.11
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 23:59:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (lgeamrelo12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c128-v6si20989794pfg.347.2018.09.03.23.59.20
        for <linux-mm@kvack.org>;
        Mon, 03 Sep 2018 23:59:20 -0700 (PDT)
Subject: Re: Re: [PATCH v2] arm64: kasan: add interceptors for strcmp/strncmp
 functions
References: <1535014606-176525-1-git-send-email-kyeongdon.kim@lge.com>
 <dff9a2f3-7db5-9e60-072a-312b6cfbe0f0@virtuozzo.com>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <ad334e64-28d1-4b91-aeba-8352934a9c46@lge.com>
Date: Tue, 4 Sep 2018 15:59:17 +0900
MIME-Version: 1.0
In-Reply-To: <dff9a2f3-7db5-9e60-072a-312b6cfbe0f0@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, glider@google.com, dvyukov@google.com, Jason@zx2c4.com, robh@kernel.org, ard.biesheuvel@linaro.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

Hello Andrey,

Thanks for your review.

On 2018-09-03 i??i?? 6:40, Andrey Ryabinin wrote:
>
>
> On 08/23/2018 11:56 AM, Kyeongdon Kim wrote:
>
> > diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> > index c3bd520..61ad7f1 100644
> > --- a/mm/kasan/kasan.c
> > +++ b/mm/kasan/kasan.c
> > @@ -304,6 +304,29 @@ void *memcpy(void *dest, const void *src, 
> size_t len)
> >
> > return __memcpy(dest, src, len);
> > }
> > +#ifdef CONFIG_ARM64
> > +/*
> > + * Arch arm64 use assembly variant for strcmp/strncmp,
> > + * xtensa use inline asm operations and x86_64 use c one,
> > + * so now this interceptors only for arm64 kasan.
> > + */
> > +#undef strcmp
> > +int strcmp(const char *cs, const char *ct)
> > +{
> > + check_memory_region((unsigned long)cs, 1, false, _RET_IP_);
> > + check_memory_region((unsigned long)ct, 1, false, _RET_IP_);
> > +
>
> Well this is definitely wrong. strcmp() often accesses far more than 
> one byte.
>
> > + return __strcmp(cs, ct);
> > +}
> > +#undef strncmp
> > +int strncmp(const char *cs, const char *ct, size_t len)
> > +{
> > + check_memory_region((unsigned long)cs, len, false, _RET_IP_);
> > + check_memory_region((unsigned long)ct, len, false, _RET_IP_);
>
> This will cause false positives. Both 'cs', and 'ct' could be less 
> than len bytes.
>
> There is no need in these interceptors, just use the C implementations 
> from lib/string.c
> like you did in your first patch.
> The only thing that was wrong in the first patch is that assembly 
> implementations
> were compiled out instead of being declared week.
>
Well, at first I thought so..
I would remove diff code in /mm/kasan/kasan.c then use C implementations 
in lib/string.c
w/ assem implementations as weak :

diff --git a/lib/string.c b/lib/string.c
index 2c0900a..a18b18f 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -312,7 +312,7 @@ size_t strlcat(char *dest, const char *src, size_t 
count)
 A EXPORT_SYMBOL(strlcat);
 A #endif

-#ifndef __HAVE_ARCH_STRCMP
+#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || 
!defined(__HAVE_ARCH_STRCMP)
 A /**
 A  * strcmp - Compare two strings
 A  * @cs: One string
@@ -336,7 +336,7 @@ int strcmp(const char *cs, const char *ct)
 A EXPORT_SYMBOL(strcmp);
 A #endif

-#ifndef __HAVE_ARCH_STRNCMP
+#if (defined(CONFIG_ARM64) && defined(CONFIG_KASAN)) || 
!defined(__HAVE_ARCH_STRNCMP)
 A /**
 A  * strncmp - Compare two length-limited strings

Can I get your opinion wrt this ?

Thanks,
