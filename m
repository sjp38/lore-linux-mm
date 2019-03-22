Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C80AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91EAE218A5
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="jn+HRRQ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91EAE218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F1966B0007; Fri, 22 Mar 2019 10:00:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A1936B0008; Fri, 22 Mar 2019 10:00:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4433E6B000A; Fri, 22 Mar 2019 10:00:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3D846B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:00:10 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b133so590414wmg.7
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:00:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=CJiDtZpK8H5hjB+KPYUIhceGLlQqjCl3ug5QA7inh50=;
        b=kg+LbYNeS7bt8BoT4utsXicvSOZEfipz/fjzooGXpWKgF+XliRl8bth+jAxTM4F4AJ
         5vgFers2bMcsSIoWK6pSsCKVunlZxULmhGImcajsst/HoqjFiydV8GsudSeNio+Gw6tN
         7oCPMFLwcRqPQO9dQTfkxC8hI7CZzhXA3Hic6cGMhgxtUc/N66crCpSNic2yRAXn4Ip0
         wJ+L+/4bhuJofF5opie2wLNUIdaw+pzZk1zlt95Yvti/YcUcSBWYNxdHs+plv2gi+PEi
         jceafG7R1cVoBjRn+s42SZUw1EEvxl23ZhJHCzUj0rhkJWfOb1PR15IM081WM5/FL5vr
         TiLg==
X-Gm-Message-State: APjAAAU12MV6mST05Xr4Xkyw3duA2zHFiPVjKjlOL+zNCXX4xrf4qo6o
	xAi+2zUT4PaF4ve9U/HsTMx+m3IoXhZojd3Sb1NiT6bl26Lk006vOF1qEx6Sl3FMz1E20740n/N
	G7hmaA81eDcyXrmtrSNbUEywEtleeDOIIzt6g9o2YHI3CtKQqP6bsVyZ/wh0u/rrk2w==
X-Received: by 2002:a7b:c769:: with SMTP id x9mr3289185wmk.103.1553263210290;
        Fri, 22 Mar 2019 07:00:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxStLw9QLIIfnv9SfZu3icZ5lucxXkh2LXUD9RqR5qq/z3xsKMTKsldfc5oU3eXF64Fqur6
X-Received: by 2002:a7b:c769:: with SMTP id x9mr3289088wmk.103.1553263208758;
        Fri, 22 Mar 2019 07:00:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553263208; cv=none;
        d=google.com; s=arc-20160816;
        b=LuoqrhIkpMfn3BirFH8PLsnFZ9E4izn5F1h3pNH3MU2zJPBrsX2c9KOAtGtf5L9/S3
         dpObonFEdilmAeYZ7LE7O1R7xix1CaAlN7re4uGkXsmv0R5+xrHMi9oUXkCneFzXQmQ6
         fxTs08/I6ifAJyzEJOd+vPbQ8EgC9d5D0TtKUEME3YM8RuUAVLLV3k1R4neLTO06jTAk
         6+jgMCaieaOhe2kTg5vnkzd9PYIds6lfhZCrKoYQYFtv0Rb6DxusfOpd7ZW9eyYs9tQx
         TUMqCrqGCdH8330KQGr+wEUO9AN9UWfVBtwnw59viniGdLANUbXLcmAuAsfEs62BBj6q
         HCaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=CJiDtZpK8H5hjB+KPYUIhceGLlQqjCl3ug5QA7inh50=;
        b=CZZX7mfm6/CqSDhlilVDqoFkOhetqMWpmU3YmItOleu8Aouwgb6qhC5Ig5Y3LxD/Ka
         DOor5DR/uWEvR/IZKNFzkFPGsTs0riJT0bfQqtMyWhD49uqH2xRQN7OHODW3ZTRQg7gQ
         A/diQQ1bNU79klQUUKmggYeIcKG3AzRdUtsHvjqamxg0zVtQTsosdaMbiRmn/vERS79q
         V+CIKjVnUaGQiA5LdyQhxjgo5fvPbN6aeg7kGEoUJgGoRi9Zrobtp9ruZAqF4XaEXitK
         bF09+uf/5FEK9OD9aTLU4BdLd1RMqcXvsAt4yI7V6zr1PKfOplKVboLGpdK2IecbSC5G
         nryw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=jn+HRRQ2;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h7si5045981wru.58.2019.03.22.07.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:00:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=jn+HRRQ2;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44QlfG60Llz9tydX;
	Fri, 22 Mar 2019 15:00:06 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=jn+HRRQ2; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id N-Gfaqsg-HFZ; Fri, 22 Mar 2019 15:00:06 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44QlfG4lzjz9tydV;
	Fri, 22 Mar 2019 15:00:06 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553263206; bh=CJiDtZpK8H5hjB+KPYUIhceGLlQqjCl3ug5QA7inh50=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=jn+HRRQ2LeTrJM62w8zAfDxjmpTdEete5jM8mL5QlOnEluucDQLXE6ne0YShvYBg5
	 IdfKaNGInjswixPqOBw7FHuUpqom6ZhWn1G+WOtNyJwPTC5FYRktezsUDhq5UsObbH
	 4QghM/0tMpbQT/QqUiXkPKn30BTA/LXa5e6Qu3Xg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EA52D8BB1E;
	Fri, 22 Mar 2019 15:00:07 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id lzf0JGiAYaV6; Fri, 22 Mar 2019 15:00:07 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B343F8BB1B;
	Fri, 22 Mar 2019 15:00:07 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id A93C96CE54; Fri, 22 Mar 2019 14:00:07 +0000 (UTC)
Message-Id: <59d08c6ce4a36cafdbf270360fb77d67995b2ab9.1553263058.git.christophe.leroy@c-s.fr>
In-Reply-To: <45a5e13683694fc8d4574b52c4851ffb7f5e5fbd.1553263058.git.christophe.leroy@c-s.fr>
References: <45a5e13683694fc8d4574b52c4851ffb7f5e5fbd.1553263058.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v1 3/3] kasan: add interceptors for all string functions
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 22 Mar 2019 14:00:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the same spirit as commit 393f203f5fd5 ("x86_64: kasan: add
interceptors for memset/memmove/memcpy functions"), this patch
adds interceptors for string manipulation functions so that we
can compile lib/string.o without kasan support hence allow the
string functions to also be used from places where kasan has
to be disabled.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 This is the generic part. If we agree on the principle, then I'll
 go through the arches and see if adaptations need to be done there.

 include/linux/string.h |  79 ++++++++++++
 lib/Makefile           |   2 +
 mm/kasan/string.c      | 334 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 415 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 7927b875f80c..7e7441f4c420 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -19,54 +19,117 @@ extern void *memdup_user_nul(const void __user *, size_t);
  */
 #include <asm/string.h>
 
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+#define memset16	__memset16
+#define memset32	__memset32
+#define memset64	__memset64
+#define memzero_explicit	__memzero_explicit
+#define strcpy		__strcpy
+#define strncpy		__strncpy
+#define strlcpy		__strlcpy
+#define strscpy		__strscpy
+#define strcat		__strcat
+#define strncat		__strncat
+#define strlcat		__strlcat
+#define strcmp		__strcmp
+#define strncmp		__strncmp
+#define strcasecmp	__strcasecmp
+#define strncasecmp	__strncasecmp
+#define strchr		__strchr
+#define strchrnul	__strchrnul
+#define strrchr		__strrchr
+#define strnchr		__strnchr
+#define skip_spaces	__skip_spaces
+#define strim		__strim
+#define strstr		__strstr
+#define strnstr		__strnstr
+#define strlen		__strlen
+#define strnlen		__strnlen
+#define strpbrk		__strpbrk
+#define strsep		__strsep
+#define strspn		__strspn
+#define strcspn		__strcspn
+#define memscan		__memscan
+#define memcmp		__memcmp
+#define memchr		__memchr
+#define memchr_inv	__memchr_inv
+#define strreplace	__strreplace
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
+#endif
+
 #ifndef __HAVE_ARCH_STRCPY
 extern char * strcpy(char *,const char *);
+char *__strcpy(char *,const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNCPY
 extern char * strncpy(char *,const char *, __kernel_size_t);
+char *__strncpy(char *,const char *, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRLCPY
 size_t strlcpy(char *, const char *, size_t);
+size_t __strlcpy(char *, const char *, size_t);
 #endif
 #ifndef __HAVE_ARCH_STRSCPY
 ssize_t strscpy(char *, const char *, size_t);
+ssize_t __strscpy(char *, const char *, size_t);
 #endif
 #ifndef __HAVE_ARCH_STRCAT
 extern char * strcat(char *, const char *);
+char *__strcat(char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNCAT
 extern char * strncat(char *, const char *, __kernel_size_t);
+char *__strncat(char *, const char *, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRLCAT
 extern size_t strlcat(char *, const char *, __kernel_size_t);
+size_t __strlcat(char *, const char *, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRCMP
 extern int strcmp(const char *,const char *);
+int __strcmp(const char *,const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNCMP
 extern int strncmp(const char *,const char *,__kernel_size_t);
+int __strncmp(const char *,const char *,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRCASECMP
 extern int strcasecmp(const char *s1, const char *s2);
+int __strcasecmp(const char *s1, const char *s2);
 #endif
 #ifndef __HAVE_ARCH_STRNCASECMP
 extern int strncasecmp(const char *s1, const char *s2, size_t n);
+int __strncasecmp(const char *s1, const char *s2, size_t n);
 #endif
 #ifndef __HAVE_ARCH_STRCHR
 extern char * strchr(const char *,int);
+char *__strchr(const char *,int);
 #endif
 #ifndef __HAVE_ARCH_STRCHRNUL
 extern char * strchrnul(const char *,int);
+char *__strchrnul(const char *,int);
 #endif
 #ifndef __HAVE_ARCH_STRNCHR
 extern char * strnchr(const char *, size_t, int);
+char *__strnchr(const char *, size_t, int);
 #endif
 #ifndef __HAVE_ARCH_STRRCHR
 extern char * strrchr(const char *,int);
+char *__strrchr(const char *,int);
 #endif
 extern char * __must_check skip_spaces(const char *);
+char * __must_check __skip_spaces(const char *);
 
 extern char *strim(char *);
+char *__strim(char *);
 
 static inline __must_check char *strstrip(char *str)
 {
@@ -75,27 +138,35 @@ static inline __must_check char *strstrip(char *str)
 
 #ifndef __HAVE_ARCH_STRSTR
 extern char * strstr(const char *, const char *);
+char *__strstr(const char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNSTR
 extern char * strnstr(const char *, const char *, size_t);
+char *__strnstr(const char *, const char *, size_t);
 #endif
 #ifndef __HAVE_ARCH_STRLEN
 extern __kernel_size_t strlen(const char *);
+__kernel_size_t __strlen(const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNLEN
 extern __kernel_size_t strnlen(const char *,__kernel_size_t);
+__kernel_size_t __strnlen(const char *,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRPBRK
 extern char * strpbrk(const char *,const char *);
+char *__strpbrk(const char *,const char *);
 #endif
 #ifndef __HAVE_ARCH_STRSEP
 extern char * strsep(char **,const char *);
+char *__strsep(char **,const char *);
 #endif
 #ifndef __HAVE_ARCH_STRSPN
 extern __kernel_size_t strspn(const char *,const char *);
+__kernel_size_t __strspn(const char *,const char *);
 #endif
 #ifndef __HAVE_ARCH_STRCSPN
 extern __kernel_size_t strcspn(const char *,const char *);
+__kernel_size_t __strcspn(const char *,const char *);
 #endif
 
 #ifndef __HAVE_ARCH_MEMSET
@@ -104,14 +175,17 @@ extern void * memset(void *,int,__kernel_size_t);
 
 #ifndef __HAVE_ARCH_MEMSET16
 extern void *memset16(uint16_t *, uint16_t, __kernel_size_t);
+void *__memset16(uint16_t *, uint16_t, __kernel_size_t);
 #endif
 
 #ifndef __HAVE_ARCH_MEMSET32
 extern void *memset32(uint32_t *, uint32_t, __kernel_size_t);
+void *__memset32(uint32_t *, uint32_t, __kernel_size_t);
 #endif
 
 #ifndef __HAVE_ARCH_MEMSET64
 extern void *memset64(uint64_t *, uint64_t, __kernel_size_t);
+void *__memset64(uint64_t *, uint64_t, __kernel_size_t);
 #endif
 
 static inline void *memset_l(unsigned long *p, unsigned long v,
@@ -146,12 +220,15 @@ extern void * memmove(void *,const void *,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMSCAN
 extern void * memscan(void *,int,__kernel_size_t);
+void *__memscan(void *,int,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMCMP
 extern int memcmp(const void *,const void *,__kernel_size_t);
+int __memcmp(const void *,const void *,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMCHR
 extern void * memchr(const void *,int,__kernel_size_t);
+void *__memchr(const void *,int,__kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMCPY_MCSAFE
 static inline __must_check unsigned long memcpy_mcsafe(void *dst,
@@ -168,7 +245,9 @@ static inline void memcpy_flushcache(void *dst, const void *src, size_t cnt)
 }
 #endif
 void *memchr_inv(const void *s, int c, size_t n);
+void *__memchr_inv(const void *s, int c, size_t n);
 char *strreplace(char *s, char old, char new);
+char *__strreplace(char *s, char old, char new);
 
 extern void kfree_const(const void *x);
 
diff --git a/lib/Makefile b/lib/Makefile
index 30b9b0bfbba9..19d0237f9b9c 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -18,6 +18,8 @@ KCOV_INSTRUMENT_list_debug.o := n
 KCOV_INSTRUMENT_debugobjects.o := n
 KCOV_INSTRUMENT_dynamic_debug.o := n
 
+KASAN_SANITIZE_string.o := n
+
 lib-y := ctype.o string.o string_sysfs.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o xarray.o \
 	 idr.o int_sqrt.o extable.o \
diff --git a/mm/kasan/string.c b/mm/kasan/string.c
index f23a740ff985..9a86b422e2e7 100644
--- a/mm/kasan/string.c
+++ b/mm/kasan/string.c
@@ -16,6 +16,38 @@ void *memset(void *addr, int c, size_t len)
 	return __memset(addr, c, len);
 }
 
+#undef memset16
+void *memset16(uint16_t *s, uint16_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 1, true, _RET_IP_);
+
+	return __memset16(s, v, count);
+}
+
+#undef memset32
+void *memset32(uint32_t *s, uint32_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 2, true, _RET_IP_);
+
+	return __memset32(s, v, count);
+}
+
+#undef memset64
+void *memset64(uint64_t *s, uint64_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 3, true, _RET_IP_);
+
+	return __memset64(s, v, count);
+}
+
+#undef memzero_explicit
+void memzero_explicit(void *s, size_t count)
+{
+	check_memory_region((unsigned long)s, count, true, _RET_IP_);
+
+	return __memzero_explicit(s, count);
+}
+
 #undef memmove
 void *memmove(void *dest, const void *src, size_t len)
 {
@@ -33,3 +65,305 @@ void *memcpy(void *dest, const void *src, size_t len)
 
 	return __memcpy(dest, src, len);
 }
+
+#undef strcpy
+char *strcpy(char *dest, const char *src)
+{
+	size_t len = __strlen(src) + 1;
+
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __strcpy(dest, src);
+}
+
+#undef strncpy
+char *strncpy(char *dest, const char *src, size_t count)
+{
+	size_t len = min(__strlen(src) + 1, count);
+
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, count, true, _RET_IP_);
+
+	return __strncpy(dest, src, count);
+}
+
+#undef strlcpy
+size_t strlcpy(char *dest, const char *src, size_t size)
+{
+	size_t len = __strlen(src) + 1;
+
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, min(len, size), true, _RET_IP_);
+
+	return __strlcpy(dest, src, size);
+}
+
+#undef strscpy
+ssize_t strscpy(char *dest, const char *src, size_t count)
+{
+	int len = min(__strlen(src) + 1, count);
+
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __strscpy(dest, src, count);
+}
+
+#undef strcat
+char *strcat(char *dest, const char *src)
+{
+	size_t slen = __strlen(src) + 1;
+	size_t dlen = __strlen(dest);
+
+	check_memory_region((unsigned long)src, slen, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
+	check_memory_region((unsigned long)(dest + dlen), slen, true, _RET_IP_);
+
+	return __strcat(dest, src);
+}
+
+char *strncat(char *dest, const char *src, size_t count)
+{
+	size_t slen = min(__strlen(src) + 1, count);
+	size_t dlen = __strlen(dest);
+
+	check_memory_region((unsigned long)src, slen, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
+	check_memory_region((unsigned long)(dest + dlen), slen , true, _RET_IP_);
+
+	return __strncat(dest, src, count);
+}
+
+size_t strlcat(char *dest, const char *src, size_t count)
+{
+	size_t slen = min(__strlen(src) + 1, count);
+	size_t dlen = __strlen(dest);
+
+	check_memory_region((unsigned long)src, slen, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
+	check_memory_region((unsigned long)(dest + dlen), slen , true, _RET_IP_);
+
+	return __strlcat(dest, src, count);
+}
+
+int strcmp(const char *cs, const char *ct)
+{
+	size_t len = min(__strlen(cs) + 1, __strlen(ct) + 1);
+
+	check_memory_region((unsigned long)cs, len, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, len, false, _RET_IP_);
+
+	return __strcmp(cs, ct);
+}
+
+int strncmp(const char *cs, const char *ct, size_t count)
+{
+	size_t len = min3(__strlen(cs) + 1, __strlen(ct) + 1, count);
+
+	check_memory_region((unsigned long)cs, len, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, len, false, _RET_IP_);
+
+	return __strncmp(cs, ct, count);
+}
+
+int strcasecmp(const char *s1, const char *s2)
+{
+	size_t len = min(__strlen(s1) + 1, __strlen(s2) + 1);
+
+	check_memory_region((unsigned long)s1, len, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, len, false, _RET_IP_);
+
+	return __strcasecmp(s1, s2);
+}
+
+int strncasecmp(const char *s1, const char *s2, size_t len)
+{
+	size_t sz = min3(__strlen(s1) + 1, __strlen(s2) + 1, len);
+
+	check_memory_region((unsigned long)s1, sz, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, sz, false, _RET_IP_);
+
+	return __strncasecmp(s1, s2, len);
+}
+
+char *strchr(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strchr(s, c);
+}
+
+char *strchrnul(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strchrnul(s, c);
+}
+
+char *strrchr(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strrchr(s, c);
+}
+
+char *strnchr(const char *s, size_t count, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strnchr(s, count, c);
+}
+
+char *skip_spaces(const char *str)
+{
+	size_t len = __strlen(str) + 1;
+
+	check_memory_region((unsigned long)str, len, false, _RET_IP_);
+
+	return __skip_spaces(str);
+}
+
+char *strim(char *s)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strim(s);
+}
+
+char *strstr(const char *s1, const char *s2)
+{
+	size_t l1 = __strlen(s1) + 1;
+	size_t l2 = __strlen(s2) + 1;
+
+	check_memory_region((unsigned long)s1, l1, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, l2, false, _RET_IP_);
+
+	return __strstr(s1, s2);
+}
+
+char *strnstr(const char *s1, const char *s2, size_t len)
+{
+	size_t l1 = min(__strlen(s1) + 1, len);
+	size_t l2 = __strlen(s2) + 1;
+
+	check_memory_region((unsigned long)s1, l1, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, l2, false, _RET_IP_);
+
+	return __strnstr(s1, s2, len);
+}
+
+size_t strlen(const char *s)
+{
+	size_t len = __strlen(s);
+
+	check_memory_region((unsigned long)s, len + 1, false, _RET_IP_);
+
+	return len;
+}
+
+size_t strnlen(const char *s, size_t count)
+{
+	size_t len = __strnlen(s, count);
+
+	check_memory_region((unsigned long)s, min(len + 1, count), false, _RET_IP_);
+
+	return len;
+}
+
+char *strpbrk(const char *cs, const char *ct)
+{
+	size_t ls = __strlen(cs) + 1;
+	size_t lt = __strlen(ct) + 1;
+
+	check_memory_region((unsigned long)cs, ls, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, lt, false, _RET_IP_);
+
+	return __strpbrk(cs, ct);
+}
+char *strsep(char **s, const char *ct)
+{
+	char *cs = *s;
+
+	check_memory_region((unsigned long)s, sizeof(*s), true, _RET_IP_);
+
+	if (cs) {
+		int ls = __strlen(cs) + 1;
+		int lt = __strlen(ct) + 1;
+
+		check_memory_region((unsigned long)cs, ls, false, _RET_IP_);
+		check_memory_region((unsigned long)ct, lt, false, _RET_IP_);
+	}
+
+	return __strsep(s, ct);
+}
+
+size_t strspn(const char *s, const char *accept)
+{
+	size_t ls = __strlen(s) + 1;
+	size_t la = __strlen(accept) + 1;
+
+	check_memory_region((unsigned long)s, ls, false, _RET_IP_);
+	check_memory_region((unsigned long)accept, la, false, _RET_IP_);
+
+	return __strspn(s, accept);
+}
+
+size_t strcspn(const char *s, const char *reject)
+{
+	size_t ls = __strlen(s) + 1;
+	size_t lr = __strlen(reject) + 1;
+
+	check_memory_region((unsigned long)s, ls, false, _RET_IP_);
+	check_memory_region((unsigned long)reject, lr, false, _RET_IP_);
+
+	return __strcspn(s, reject);
+}
+
+void *memscan(void *addr, int c, size_t size)
+{
+	check_memory_region((unsigned long)addr, size, false, _RET_IP_);
+
+	return __memscan(addr, c, size);
+}
+
+int memcmp(const void *cs, const void *ct, size_t count)
+{
+	check_memory_region((unsigned long)cs, count, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, count, false, _RET_IP_);
+
+	return __memcmp(cs, ct, count);
+}
+
+void *memchr(const void *s, int c, size_t n)
+{
+	check_memory_region((unsigned long)s, n, false, _RET_IP_);
+
+	return __memchr(s, c, n);
+}
+
+void *memchr_inv(const void *start, int c, size_t bytes)
+{
+	check_memory_region((unsigned long)start, bytes, false, _RET_IP_);
+
+	return __memchr_inv(start, c, bytes);
+}
+
+char *strreplace(char *s, char old, char new)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, true, _RET_IP_);
+
+	return __strreplace(s, old, new);
+}
-- 
2.13.3

