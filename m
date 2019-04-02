Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA2B0C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21FC9206B7
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:58:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jPQOwjLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21FC9206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EADC6B0281; Tue,  2 Apr 2019 08:58:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799156B0282; Tue,  2 Apr 2019 08:58:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6921F6B0283; Tue,  2 Apr 2019 08:58:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41AFA6B0281
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 08:58:35 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id a7so10872187ioq.3
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 05:58:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=woK73oVSU6O8xwDDd+LA5qtIAVHFyC5v2XPC1bxqAk8=;
        b=kSjEogu/+gFgsMNXW/MSjBDvz3TQ+c369JyWFC1g/ibe6dRuMY9/FRDY3vIFMl8yeI
         Xou8UowMFpN39d+1VQLfsUUW1kt4SzdWzPKDTvFZHLE1liSd/uJI8Fv71mrz6ASOxeG4
         mwGLSiPvufm0GBApsLTBSDtfb5u8SWJ28OLdTE49K/2GJRMOCdBrO2MEEU2732H3b7Px
         Oxh/aEEf7pDKYv4qUssCaq2FcO7OSuGavu/gMsPUJ+jUJMEvvszQGIVf26J4bvFgqp4n
         OTLoUf9BwMu6nc3VFzIIZA1ufKLJ+QShCnkBxJT8abCLeW0ue+P8VsOnQkKV9tTavzaf
         ewAA==
X-Gm-Message-State: APjAAAUiUI9S0QrGcI9pTCko2AelrUCDx+0tOQYdQJr43dw6VN8+krIz
	RupUJ3hrsGH8+P31vAEEVm+hwOOMs6M6JbDWEPNB2TwNARVv7CYbqLPCD0Bi1IFrxk/zr9+Lolc
	fCI/m7iTcr4J/vlL4hthU0YxqtSfJs36dPYF5eFX6hEAYm66u5nMo07N5ek/00BmmmA==
X-Received: by 2002:a24:4290:: with SMTP id i138mr3664227itb.129.1554209914908;
        Tue, 02 Apr 2019 05:58:34 -0700 (PDT)
X-Received: by 2002:a24:4290:: with SMTP id i138mr3664177itb.129.1554209913764;
        Tue, 02 Apr 2019 05:58:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554209913; cv=none;
        d=google.com; s=arc-20160816;
        b=xlluvYMymvN7dVPMNZJAC9Tu8m3K2PwL7YHBUS//8tSqZcQac9vh4pjULdCi6O8H+P
         VN58ZUX/ZEN24CoEE6hVltfFsD0cBoFRVypk8mkudzMI63r90de7h7SNSqLJmwbD0Gth
         gDx2uOtTXliMOht2x7F6euInD6e2rvwAexdzN3wW0Xsnk1xZf/y3J86yrYx7guVMY1zO
         ebLkDofsrJD+GOAVm6k8LJbrmD47uMzu9ba4Br1xb7C6gev5654NP7Dk7MAi1IBoPFbm
         Img7EpAL7WjIPwtgbJ5GPbILf3LZpqJwDUCnXzSzOX1okIP+WBzM2KxYYgQajBLycQXh
         GGow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=woK73oVSU6O8xwDDd+LA5qtIAVHFyC5v2XPC1bxqAk8=;
        b=ZurEAEQoQlDk3PDHn0EUIaEXvSGoirqxW/rZgrv+GeOdr7+4v2Y+YZg0a+fRkroTPM
         AuEGWJOLr7CMXaCbm3nXuTSjfCNnpL2G8/ffeE6NokDxQ85iYdL1sWUIWyWCjeMi158d
         yn3Bqvfan2wvTZX0mXBvlcEm+RivwFGcsvv2umenRy8Im1ESoP4CHMX3x+rrzxOd9dVi
         iZS5yV+988ZpaYKMVcMmgX26g6+N+K0GLcB/pBnTPFkBV5BFH3KYLI9eY0oZaXhwraXw
         Pw0r+4TUaGLJrDkyDKJEf55TU7JDYos5TWi7CzQOV8/OQNgjyNYFHxWfhx/dSTUL6gQ9
         SK4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jPQOwjLK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r22sor8097997iom.92.2019.04.02.05.58.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 05:58:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jPQOwjLK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=woK73oVSU6O8xwDDd+LA5qtIAVHFyC5v2XPC1bxqAk8=;
        b=jPQOwjLKgNE/e67jp+N8Ol/vlcL+lWiDw3cKAoxmYHA24afVPSVHw47JLQSr7lKvO7
         ly3CBQ8RUtaX+oZOjUQpLKy4kMZJk24uuO6qXSZ/Sln7x5jpvKikG7/JiFphnV93sGSX
         pief21g+ycmB/SxY6BFPjBMLVKk+BjDVH5YkZNX56tkGvFrHhHVzYLwgz02ph27+PKM2
         xUoe2Swy8K+HAnJjygSN9vIfKX3pKeJiCfNK+3ACmNB+/q049SqeFdhlOg2SE9EEeuTI
         aDi86dq4ZBY3xMMqdMkfHGgfQUpzxVZPeUBB5OIwXjS+B/aBLqrJG6YWAo8Duqe+YLo0
         MfLg==
X-Google-Smtp-Source: APXvYqxPWLsBmMFr0rXIBgSd3wcLap47aQQf9K4aNMxxv7rvZtYDnWEBp1JC7PK/hDMUMcPdka0jXus1rkM02brfiHM=
X-Received: by 2002:a5e:d80e:: with SMTP id l14mr48004528iok.227.1554209913050;
 Tue, 02 Apr 2019 05:58:33 -0700 (PDT)
MIME-Version: 1.0
References: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
 <51a6d9d7185de310f37ccbd7e4ebfdd6c7e9791f.1553785020.git.christophe.leroy@c-s.fr>
 <3211b0f8-7b52-01b7-8208-65d746969248@c-s.fr>
In-Reply-To: <3211b0f8-7b52-01b7-8208-65d746969248@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 2 Apr 2019 14:58:21 +0200
Message-ID: <CACT4Y+YYMJX-PKZhOkjDFnhaC1wcC0h_DzhhgxEwtffNNUh_Nw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 3/3] kasan: add interceptors for all string functions
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Daniel Axtens <dja@axtens.net>, Linux-MM <linux-mm@kvack.org>, 
	linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>, 
	kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 11:43 AM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
>
> Hi Dmitry, Andrey and others,
>
> Do you have any comments to this series ?
>
> I'd like to know if this approach is ok or if it is better to keep doing
> as in https://patchwork.ozlabs.org/patch/1055788/

Hi Christophe,

Forking every kernel function does not look like a scalable approach
to me. There is not much special about str* functions. There is
something a bit special about memset/memcpy as compiler emits them for
struct set/copy.
Could powerpc do the same as x86 and map some shadow early enough
(before "prom")? Then we would not need anything of this? Sorry if we
already discussed this, I am losing context quickly.




> Thanks
> Christophe
>
> Le 28/03/2019 =C3=A0 16:00, Christophe Leroy a =C3=A9crit :
> > In the same spirit as commit 393f203f5fd5 ("x86_64: kasan: add
> > interceptors for memset/memmove/memcpy functions"), this patch
> > adds interceptors for string manipulation functions so that we
> > can compile lib/string.o without kasan support hence allow the
> > string functions to also be used from places where kasan has
> > to be disabled.
> >
> > Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> > ---
> >   v2: Fixed a few checkpatch stuff and added missing EXPORT_SYMBOL() an=
d missing #undefs
> >
> >   include/linux/string.h |  79 ++++++++++
> >   lib/Makefile           |   2 +
> >   lib/string.c           |   8 +
> >   mm/kasan/string.c      | 394 ++++++++++++++++++++++++++++++++++++++++=
+++++++++
> >   4 files changed, 483 insertions(+)
> >
> > diff --git a/include/linux/string.h b/include/linux/string.h
> > index 7927b875f80c..3d2aff2ed402 100644
> > --- a/include/linux/string.h
> > +++ b/include/linux/string.h
> > @@ -19,54 +19,117 @@ extern void *memdup_user_nul(const void __user *, =
size_t);
> >    */
> >   #include <asm/string.h>
> >
> > +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
> > +/*
> > + * For files that are not instrumented (e.g. mm/slub.c) we
> > + * should use not instrumented version of mem* functions.
> > + */
> > +#define memset16     __memset16
> > +#define memset32     __memset32
> > +#define memset64     __memset64
> > +#define memzero_explicit     __memzero_explicit
> > +#define strcpy               __strcpy
> > +#define strncpy              __strncpy
> > +#define strlcpy              __strlcpy
> > +#define strscpy              __strscpy
> > +#define strcat               __strcat
> > +#define strncat              __strncat
> > +#define strlcat              __strlcat
> > +#define strcmp               __strcmp
> > +#define strncmp              __strncmp
> > +#define strcasecmp   __strcasecmp
> > +#define strncasecmp  __strncasecmp
> > +#define strchr               __strchr
> > +#define strchrnul    __strchrnul
> > +#define strrchr              __strrchr
> > +#define strnchr              __strnchr
> > +#define skip_spaces  __skip_spaces
> > +#define strim                __strim
> > +#define strstr               __strstr
> > +#define strnstr              __strnstr
> > +#define strlen               __strlen
> > +#define strnlen              __strnlen
> > +#define strpbrk              __strpbrk
> > +#define strsep               __strsep
> > +#define strspn               __strspn
> > +#define strcspn              __strcspn
> > +#define memscan              __memscan
> > +#define memcmp               __memcmp
> > +#define memchr               __memchr
> > +#define memchr_inv   __memchr_inv
> > +#define strreplace   __strreplace
> > +
> > +#ifndef __NO_FORTIFY
> > +#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
> > +#endif
> > +
> > +#endif
> > +
> >   #ifndef __HAVE_ARCH_STRCPY
> >   extern char * strcpy(char *,const char *);
> > +char *__strcpy(char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNCPY
> >   extern char * strncpy(char *,const char *, __kernel_size_t);
> > +char *__strncpy(char *, const char *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRLCPY
> >   size_t strlcpy(char *, const char *, size_t);
> > +size_t __strlcpy(char *, const char *, size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRSCPY
> >   ssize_t strscpy(char *, const char *, size_t);
> > +ssize_t __strscpy(char *, const char *, size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCAT
> >   extern char * strcat(char *, const char *);
> > +char *__strcat(char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNCAT
> >   extern char * strncat(char *, const char *, __kernel_size_t);
> > +char *__strncat(char *, const char *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRLCAT
> >   extern size_t strlcat(char *, const char *, __kernel_size_t);
> > +size_t __strlcat(char *, const char *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCMP
> >   extern int strcmp(const char *,const char *);
> > +int __strcmp(const char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNCMP
> >   extern int strncmp(const char *,const char *,__kernel_size_t);
> > +int __strncmp(const char *, const char *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCASECMP
> >   extern int strcasecmp(const char *s1, const char *s2);
> > +int __strcasecmp(const char *s1, const char *s2);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNCASECMP
> >   extern int strncasecmp(const char *s1, const char *s2, size_t n);
> > +int __strncasecmp(const char *s1, const char *s2, size_t n);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCHR
> >   extern char * strchr(const char *,int);
> > +char *__strchr(const char *, int);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCHRNUL
> >   extern char * strchrnul(const char *,int);
> > +char *__strchrnul(const char *, int);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNCHR
> >   extern char * strnchr(const char *, size_t, int);
> > +char *__strnchr(const char *, size_t, int);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRRCHR
> >   extern char * strrchr(const char *,int);
> > +char *__strrchr(const char *, int);
> >   #endif
> >   extern char * __must_check skip_spaces(const char *);
> > +char * __must_check __skip_spaces(const char *);
> >
> >   extern char *strim(char *);
> > +char *__strim(char *);
> >
> >   static inline __must_check char *strstrip(char *str)
> >   {
> > @@ -75,27 +138,35 @@ static inline __must_check char *strstrip(char *st=
r)
> >
> >   #ifndef __HAVE_ARCH_STRSTR
> >   extern char * strstr(const char *, const char *);
> > +char *__strstr(const char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNSTR
> >   extern char * strnstr(const char *, const char *, size_t);
> > +char *__strnstr(const char *, const char *, size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRLEN
> >   extern __kernel_size_t strlen(const char *);
> > +__kernel_size_t __strlen(const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRNLEN
> >   extern __kernel_size_t strnlen(const char *,__kernel_size_t);
> > +__kernel_size_t __strnlen(const char *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRPBRK
> >   extern char * strpbrk(const char *,const char *);
> > +char *__strpbrk(const char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRSEP
> >   extern char * strsep(char **,const char *);
> > +char *__strsep(char **, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRSPN
> >   extern __kernel_size_t strspn(const char *,const char *);
> > +__kernel_size_t __strspn(const char *, const char *);
> >   #endif
> >   #ifndef __HAVE_ARCH_STRCSPN
> >   extern __kernel_size_t strcspn(const char *,const char *);
> > +__kernel_size_t __strcspn(const char *, const char *);
> >   #endif
> >
> >   #ifndef __HAVE_ARCH_MEMSET
> > @@ -104,14 +175,17 @@ extern void * memset(void *,int,__kernel_size_t);
> >
> >   #ifndef __HAVE_ARCH_MEMSET16
> >   extern void *memset16(uint16_t *, uint16_t, __kernel_size_t);
> > +void *__memset16(uint16_t *, uint16_t, __kernel_size_t);
> >   #endif
> >
> >   #ifndef __HAVE_ARCH_MEMSET32
> >   extern void *memset32(uint32_t *, uint32_t, __kernel_size_t);
> > +void *__memset32(uint32_t *, uint32_t, __kernel_size_t);
> >   #endif
> >
> >   #ifndef __HAVE_ARCH_MEMSET64
> >   extern void *memset64(uint64_t *, uint64_t, __kernel_size_t);
> > +void *__memset64(uint64_t *, uint64_t, __kernel_size_t);
> >   #endif
> >
> >   static inline void *memset_l(unsigned long *p, unsigned long v,
> > @@ -146,12 +220,15 @@ extern void * memmove(void *,const void *,__kerne=
l_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_MEMSCAN
> >   extern void * memscan(void *,int,__kernel_size_t);
> > +void *__memscan(void *, int, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_MEMCMP
> >   extern int memcmp(const void *,const void *,__kernel_size_t);
> > +int __memcmp(const void *, const void *, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_MEMCHR
> >   extern void * memchr(const void *,int,__kernel_size_t);
> > +void *__memchr(const void *, int, __kernel_size_t);
> >   #endif
> >   #ifndef __HAVE_ARCH_MEMCPY_MCSAFE
> >   static inline __must_check unsigned long memcpy_mcsafe(void *dst,
> > @@ -168,7 +245,9 @@ static inline void memcpy_flushcache(void *dst, con=
st void *src, size_t cnt)
> >   }
> >   #endif
> >   void *memchr_inv(const void *s, int c, size_t n);
> > +void *__memchr_inv(const void *s, int c, size_t n);
> >   char *strreplace(char *s, char old, char new);
> > +char *__strreplace(char *s, char old, char new);
> >
> >   extern void kfree_const(const void *x);
> >
> > diff --git a/lib/Makefile b/lib/Makefile
> > index 30b9b0bfbba9..19d0237f9b9c 100644
> > --- a/lib/Makefile
> > +++ b/lib/Makefile
> > @@ -18,6 +18,8 @@ KCOV_INSTRUMENT_list_debug.o :=3D n
> >   KCOV_INSTRUMENT_debugobjects.o :=3D n
> >   KCOV_INSTRUMENT_dynamic_debug.o :=3D n
> >
> > +KASAN_SANITIZE_string.o :=3D n
> > +
> >   lib-y :=3D ctype.o string.o string_sysfs.o vsprintf.o cmdline.o \
> >        rbtree.o radix-tree.o timerqueue.o xarray.o \
> >        idr.o int_sqrt.o extable.o \
> > diff --git a/lib/string.c b/lib/string.c
> > index f3886c5175ac..31a253201bba 100644
> > --- a/lib/string.c
> > +++ b/lib/string.c
> > @@ -85,7 +85,9 @@ EXPORT_SYMBOL(strcasecmp);
> >    * @dest: Where to copy the string to
> >    * @src: Where to copy the string from
> >    */
> > +#ifndef CONFIG_KASAN
> >   #undef strcpy
> > +#endif
> >   char *strcpy(char *dest, const char *src)
> >   {
> >       char *tmp =3D dest;
> > @@ -243,7 +245,9 @@ EXPORT_SYMBOL(strscpy);
> >    * @dest: The string to be appended to
> >    * @src: The string to append to it
> >    */
> > +#ifndef CONFIG_KASAN
> >   #undef strcat
> > +#endif
> >   char *strcat(char *dest, const char *src)
> >   {
> >       char *tmp =3D dest;
> > @@ -319,7 +323,9 @@ EXPORT_SYMBOL(strlcat);
> >    * @cs: One string
> >    * @ct: Another string
> >    */
> > +#ifndef CONFIG_KASAN
> >   #undef strcmp
> > +#endif
> >   int strcmp(const char *cs, const char *ct)
> >   {
> >       unsigned char c1, c2;
> > @@ -773,7 +779,9 @@ EXPORT_SYMBOL(memmove);
> >    * @ct: Another area of memory
> >    * @count: The size of the area.
> >    */
> > +#ifndef CONFIG_KASAN
> >   #undef memcmp
> > +#endif
> >   __visible int memcmp(const void *cs, const void *ct, size_t count)
> >   {
> >       const unsigned char *su1, *su2;
> > diff --git a/mm/kasan/string.c b/mm/kasan/string.c
> > index 083b967255a2..0db31bbbf643 100644
> > --- a/mm/kasan/string.c
> > +++ b/mm/kasan/string.c
> > @@ -35,6 +35,42 @@ void *memset(void *addr, int c, size_t len)
> >       return __memset(addr, c, len);
> >   }
> >
> > +#undef memset16
> > +void *memset16(uint16_t *s, uint16_t v, size_t count)
> > +{
> > +     check_memory_region((unsigned long)s, count << 1, true, _RET_IP_)=
;
> > +
> > +     return __memset16(s, v, count);
> > +}
> > +EXPORT_SYMBOL(memset16);
> > +
> > +#undef memset32
> > +void *memset32(uint32_t *s, uint32_t v, size_t count)
> > +{
> > +     check_memory_region((unsigned long)s, count << 2, true, _RET_IP_)=
;
> > +
> > +     return __memset32(s, v, count);
> > +}
> > +EXPORT_SYMBOL(memset32);
> > +
> > +#undef memset64
> > +void *memset64(uint64_t *s, uint64_t v, size_t count)
> > +{
> > +     check_memory_region((unsigned long)s, count << 3, true, _RET_IP_)=
;
> > +
> > +     return __memset64(s, v, count);
> > +}
> > +EXPORT_SYMBOL(memset64);
> > +
> > +#undef memzero_explicit
> > +void memzero_explicit(void *s, size_t count)
> > +{
> > +     check_memory_region((unsigned long)s, count, true, _RET_IP_);
> > +
> > +     return __memzero_explicit(s, count);
> > +}
> > +EXPORT_SYMBOL(memzero_explicit);
> > +
> >   #undef memmove
> >   void *memmove(void *dest, const void *src, size_t len)
> >   {
> > @@ -52,3 +88,361 @@ void *memcpy(void *dest, const void *src, size_t le=
n)
> >
> >       return __memcpy(dest, src, len);
> >   }
> > +
> > +#undef strcpy
> > +char *strcpy(char *dest, const char *src)
> > +{
> > +     size_t len =3D __strlen(src) + 1;
> > +
> > +     check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> > +
> > +     return __strcpy(dest, src);
> > +}
> > +EXPORT_SYMBOL(strcpy);
> > +
> > +#undef strncpy
> > +char *strncpy(char *dest, const char *src, size_t count)
> > +{
> > +     size_t len =3D min(__strlen(src) + 1, count);
> > +
> > +     check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, count, true, _RET_IP_);
> > +
> > +     return __strncpy(dest, src, count);
> > +}
> > +EXPORT_SYMBOL(strncpy);
> > +
> > +#undef strlcpy
> > +size_t strlcpy(char *dest, const char *src, size_t size)
> > +{
> > +     size_t len =3D __strlen(src) + 1;
> > +
> > +     check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, min(len, size), true, _R=
ET_IP_);
> > +
> > +     return __strlcpy(dest, src, size);
> > +}
> > +EXPORT_SYMBOL(strlcpy);
> > +
> > +#undef strscpy
> > +ssize_t strscpy(char *dest, const char *src, size_t count)
> > +{
> > +     int len =3D min(__strlen(src) + 1, count);
> > +
> > +     check_memory_region((unsigned long)src, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> > +
> > +     return __strscpy(dest, src, count);
> > +}
> > +EXPORT_SYMBOL(strscpy);
> > +
> > +#undef strcat
> > +char *strcat(char *dest, const char *src)
> > +{
> > +     size_t slen =3D __strlen(src) + 1;
> > +     size_t dlen =3D __strlen(dest);
> > +
> > +     check_memory_region((unsigned long)src, slen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)(dest + dlen), slen, true, _RE=
T_IP_);
> > +
> > +     return __strcat(dest, src);
> > +}
> > +EXPORT_SYMBOL(strcat);
> > +
> > +#undef strncat
> > +char *strncat(char *dest, const char *src, size_t count)
> > +{
> > +     size_t slen =3D min(__strlen(src) + 1, count);
> > +     size_t dlen =3D __strlen(dest);
> > +
> > +     check_memory_region((unsigned long)src, slen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)(dest + dlen), slen, true, _RE=
T_IP_);
> > +
> > +     return __strncat(dest, src, count);
> > +}
> > +EXPORT_SYMBOL(strncat);
> > +
> > +#undef strlcat
> > +size_t strlcat(char *dest, const char *src, size_t count)
> > +{
> > +     size_t slen =3D min(__strlen(src) + 1, count);
> > +     size_t dlen =3D __strlen(dest);
> > +
> > +     check_memory_region((unsigned long)src, slen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
> > +     check_memory_region((unsigned long)(dest + dlen), slen, true, _RE=
T_IP_);
> > +
> > +     return __strlcat(dest, src, count);
> > +}
> > +EXPORT_SYMBOL(strlcat);
> > +
> > +#undef strcmp
> > +int strcmp(const char *cs, const char *ct)
> > +{
> > +     size_t len =3D min(__strlen(cs) + 1, __strlen(ct) + 1);
> > +
> > +     check_memory_region((unsigned long)cs, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)ct, len, false, _RET_IP_);
> > +
> > +     return __strcmp(cs, ct);
> > +}
> > +EXPORT_SYMBOL(strcmp);
> > +
> > +#undef strncmp
> > +int strncmp(const char *cs, const char *ct, size_t count)
> > +{
> > +     size_t len =3D min3(__strlen(cs) + 1, __strlen(ct) + 1, count);
> > +
> > +     check_memory_region((unsigned long)cs, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)ct, len, false, _RET_IP_);
> > +
> > +     return __strncmp(cs, ct, count);
> > +}
> > +EXPORT_SYMBOL(strncmp);
> > +
> > +#undef strcasecmp
> > +int strcasecmp(const char *s1, const char *s2)
> > +{
> > +     size_t len =3D min(__strlen(s1) + 1, __strlen(s2) + 1);
> > +
> > +     check_memory_region((unsigned long)s1, len, false, _RET_IP_);
> > +     check_memory_region((unsigned long)s2, len, false, _RET_IP_);
> > +
> > +     return __strcasecmp(s1, s2);
> > +}
> > +EXPORT_SYMBOL(strcasecmp);
> > +
> > +#undef strncasecmp
> > +int strncasecmp(const char *s1, const char *s2, size_t len)
> > +{
> > +     size_t sz =3D min3(__strlen(s1) + 1, __strlen(s2) + 1, len);
> > +
> > +     check_memory_region((unsigned long)s1, sz, false, _RET_IP_);
> > +     check_memory_region((unsigned long)s2, sz, false, _RET_IP_);
> > +
> > +     return __strncasecmp(s1, s2, len);
> > +}
> > +EXPORT_SYMBOL(strncasecmp);
> > +
> > +#undef strchr
> > +char *strchr(const char *s, int c)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, false, _RET_IP_);
> > +
> > +     return __strchr(s, c);
> > +}
> > +EXPORT_SYMBOL(strchr);
> > +
> > +#undef strchrnul
> > +char *strchrnul(const char *s, int c)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, false, _RET_IP_);
> > +
> > +     return __strchrnul(s, c);
> > +}
> > +EXPORT_SYMBOL(strchrnul);
> > +
> > +#undef strrchr
> > +char *strrchr(const char *s, int c)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, false, _RET_IP_);
> > +
> > +     return __strrchr(s, c);
> > +}
> > +EXPORT_SYMBOL(strrchr);
> > +
> > +#undef strnchr
> > +char *strnchr(const char *s, size_t count, int c)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, false, _RET_IP_);
> > +
> > +     return __strnchr(s, count, c);
> > +}
> > +EXPORT_SYMBOL(strnchr);
> > +
> > +#undef skip_spaces
> > +char *skip_spaces(const char *str)
> > +{
> > +     size_t len =3D __strlen(str) + 1;
> > +
> > +     check_memory_region((unsigned long)str, len, false, _RET_IP_);
> > +
> > +     return __skip_spaces(str);
> > +}
> > +EXPORT_SYMBOL(skip_spaces);
> > +
> > +#undef strim
> > +char *strim(char *s)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, false, _RET_IP_);
> > +
> > +     return __strim(s);
> > +}
> > +EXPORT_SYMBOL(strim);
> > +
> > +#undef strstr
> > +char *strstr(const char *s1, const char *s2)
> > +{
> > +     size_t l1 =3D __strlen(s1) + 1;
> > +     size_t l2 =3D __strlen(s2) + 1;
> > +
> > +     check_memory_region((unsigned long)s1, l1, false, _RET_IP_);
> > +     check_memory_region((unsigned long)s2, l2, false, _RET_IP_);
> > +
> > +     return __strstr(s1, s2);
> > +}
> > +EXPORT_SYMBOL(strstr);
> > +
> > +#undef strnstr
> > +char *strnstr(const char *s1, const char *s2, size_t len)
> > +{
> > +     size_t l1 =3D min(__strlen(s1) + 1, len);
> > +     size_t l2 =3D __strlen(s2) + 1;
> > +
> > +     check_memory_region((unsigned long)s1, l1, false, _RET_IP_);
> > +     check_memory_region((unsigned long)s2, l2, false, _RET_IP_);
> > +
> > +     return __strnstr(s1, s2, len);
> > +}
> > +EXPORT_SYMBOL(strnstr);
> > +
> > +#undef strlen
> > +size_t strlen(const char *s)
> > +{
> > +     size_t len =3D __strlen(s);
> > +
> > +     check_memory_region((unsigned long)s, len + 1, false, _RET_IP_);
> > +
> > +     return len;
> > +}
> > +EXPORT_SYMBOL(strlen);
> > +
> > +#undef strnlen
> > +size_t strnlen(const char *s, size_t count)
> > +{
> > +     size_t len =3D __strnlen(s, count);
> > +
> > +     check_memory_region((unsigned long)s, min(len + 1, count), false,=
 _RET_IP_);
> > +
> > +     return len;
> > +}
> > +EXPORT_SYMBOL(strnlen);
> > +
> > +#undef strpbrk
> > +char *strpbrk(const char *cs, const char *ct)
> > +{
> > +     size_t ls =3D __strlen(cs) + 1;
> > +     size_t lt =3D __strlen(ct) + 1;
> > +
> > +     check_memory_region((unsigned long)cs, ls, false, _RET_IP_);
> > +     check_memory_region((unsigned long)ct, lt, false, _RET_IP_);
> > +
> > +     return __strpbrk(cs, ct);
> > +}
> > +EXPORT_SYMBOL(strpbrk);
> > +
> > +#undef strsep
> > +char *strsep(char **s, const char *ct)
> > +{
> > +     char *cs =3D *s;
> > +
> > +     check_memory_region((unsigned long)s, sizeof(*s), true, _RET_IP_)=
;
> > +
> > +     if (cs) {
> > +             int ls =3D __strlen(cs) + 1;
> > +             int lt =3D __strlen(ct) + 1;
> > +
> > +             check_memory_region((unsigned long)cs, ls, false, _RET_IP=
_);
> > +             check_memory_region((unsigned long)ct, lt, false, _RET_IP=
_);
> > +     }
> > +
> > +     return __strsep(s, ct);
> > +}
> > +EXPORT_SYMBOL(strsep);
> > +
> > +#undef strspn
> > +size_t strspn(const char *s, const char *accept)
> > +{
> > +     size_t ls =3D __strlen(s) + 1;
> > +     size_t la =3D __strlen(accept) + 1;
> > +
> > +     check_memory_region((unsigned long)s, ls, false, _RET_IP_);
> > +     check_memory_region((unsigned long)accept, la, false, _RET_IP_);
> > +
> > +     return __strspn(s, accept);
> > +}
> > +EXPORT_SYMBOL(strspn);
> > +
> > +#undef strcspn
> > +size_t strcspn(const char *s, const char *reject)
> > +{
> > +     size_t ls =3D __strlen(s) + 1;
> > +     size_t lr =3D __strlen(reject) + 1;
> > +
> > +     check_memory_region((unsigned long)s, ls, false, _RET_IP_);
> > +     check_memory_region((unsigned long)reject, lr, false, _RET_IP_);
> > +
> > +     return __strcspn(s, reject);
> > +}
> > +EXPORT_SYMBOL(strcspn);
> > +
> > +#undef memscan
> > +void *memscan(void *addr, int c, size_t size)
> > +{
> > +     check_memory_region((unsigned long)addr, size, false, _RET_IP_);
> > +
> > +     return __memscan(addr, c, size);
> > +}
> > +EXPORT_SYMBOL(memscan);
> > +
> > +#undef memcmp
> > +int memcmp(const void *cs, const void *ct, size_t count)
> > +{
> > +     check_memory_region((unsigned long)cs, count, false, _RET_IP_);
> > +     check_memory_region((unsigned long)ct, count, false, _RET_IP_);
> > +
> > +     return __memcmp(cs, ct, count);
> > +}
> > +EXPORT_SYMBOL(memcmp);
> > +
> > +#undef memchr
> > +void *memchr(const void *s, int c, size_t n)
> > +{
> > +     check_memory_region((unsigned long)s, n, false, _RET_IP_);
> > +
> > +     return __memchr(s, c, n);
> > +}
> > +EXPORT_SYMBOL(memchr);
> > +
> > +#undef memchr_inv
> > +void *memchr_inv(const void *start, int c, size_t bytes)
> > +{
> > +     check_memory_region((unsigned long)start, bytes, false, _RET_IP_)=
;
> > +
> > +     return __memchr_inv(start, c, bytes);
> > +}
> > +EXPORT_SYMBOL(memchr_inv);
> > +
> > +#undef strreplace
> > +char *strreplace(char *s, char old, char new)
> > +{
> > +     size_t len =3D __strlen(s) + 1;
> > +
> > +     check_memory_region((unsigned long)s, len, true, _RET_IP_);
> > +
> > +     return __strreplace(s, old, new);
> > +}
> > +EXPORT_SYMBOL(strreplace);
> >

