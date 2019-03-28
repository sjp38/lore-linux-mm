Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1272AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C03320811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ja91P3I0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C03320811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1436B0008; Thu, 28 Mar 2019 11:00:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 862C46B000A; Thu, 28 Mar 2019 11:00:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72AF16B000C; Thu, 28 Mar 2019 11:00:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 050186B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:00:23 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id a206so1891128wmh.2
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:00:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=q9NT2Llm953rb4Q2ZgieB5DwdmFzg9pvg6k5+wKs1Pk=;
        b=DbAsVJX6JNa4IZ6sFVMVp1teUqXSTrI9Gt5BllfO1EFXfOY1Bm9+coD6TMJjQhCMP1
         tquXr3JpHQFgLaDq0DWg1l/cUbHHGFPGc8G3tNRnStYhG87MzMe0tL/urKSvNi2fctMR
         pKGPN49SfHv9G+U/+iAU7ntm6K5Qv63am+V5cY2H1/Z03ZXEX+iKDlC15M8oOllnuAFF
         X3XR+SjBSkEtC4SfKbG3mw+MlQ+FyYySGn1qR6JrZjvXgpZlkpwk0jc+27MJv08phrz4
         eNNIilVANlueN1+JaFbeLO0RA12zIGRvm8X5JyokwNu1rMlzCzivZkT1C07b4uJO9tr1
         ICTg==
X-Gm-Message-State: APjAAAV392dwmnkoXHXqazZ53pjrEwm0OGKDGzB2mMo3wYZQU/fqu8YF
	aQJnzfGpN+1GS0PRuOVND+8cnLUDaijPJp4+rVKwuzH6ptO1miMSfbxYhqQZet0cAi0Ulv5kzsC
	Wkgc3PLlNldYcmtEZ4hya3yczWvBc52IBpizVA19+07tVw/cAiEcEwf01s3QqNlwRbw==
X-Received: by 2002:a1c:bd8b:: with SMTP id n133mr283196wmf.73.1553785222402;
        Thu, 28 Mar 2019 08:00:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+SWjz9Fdv8O/S+CuFu5YO5eZ1aWJVnluNsAsyGlnMGhcg65dsJd6yEbHAR1xX1uCzTPca
X-Received: by 2002:a1c:bd8b:: with SMTP id n133mr283083wmf.73.1553785220366;
        Thu, 28 Mar 2019 08:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785220; cv=none;
        d=google.com; s=arc-20160816;
        b=avfHFX1ngMyp5bi4dWEAzY3uOIW4x7cJGa259JWF9AT36+h24v7tldMzSHcCASbCVb
         6rr74jcU2lSJDmuSP9h+42rNSRpMhjl9++HxSk5iWvdFi/7c8gCs4+2JN4PGNXpcQeLr
         WwD4o0xS/qXaanr9P4v1iI3U/hS3FNIxoIHQMtXau6yDwj3lsr9f9OWYw/UcJHOPX1He
         M29CrY503KYO2Ga8D96DFJhpf/eHfE/25c8dozo1WBQWsmKqVtIy4oH7PfM36VCItmXB
         c6AQsc5GDJqua3+Kx5kNxFRctE1/1wyLSkHaS/IL+7U3tbFbmehkksN2MYpSHhweGv/6
         UB0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=q9NT2Llm953rb4Q2ZgieB5DwdmFzg9pvg6k5+wKs1Pk=;
        b=wn/VN9E/iYNorU1T9j1vvHEhLJ3VN7AKZm0tWQ6c4JLhSYoIQo8uKLf4Z5vTNEIfHM
         seFLO08cXcnkihUoUHkjSoLMPfe8quzvV186jdRUaaj45KBMeEzCW5W9/2YeIuLu4csJ
         EY1oPO7zUuJOhwey/do91sUe+yc766EQNHZBKIUx2UR50NE9TLMo5cu4j23rQAI7RE6q
         S/bx09sn1aOdiX2dV1/Wy20Grnry2WT3abpaB9yn67h9qpc3zF4G+0NhXz6jdLV3U+PK
         1Y9NDKZU8BC4JqroFRiHX9e4nKM9QD9aYlXS2162AQwMgXXu04X7SZ0ZUtScQktrUZoU
         fJgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ja91P3I0;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id d16si5491716wru.316.2019.03.28.08.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:00:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ja91P3I0;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44VShy2gDJz9v2Hj;
	Thu, 28 Mar 2019 16:00:18 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ja91P3I0; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id i0zdvdNMqUVU; Thu, 28 Mar 2019 16:00:18 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44VShy1Djgz9v2HP;
	Thu, 28 Mar 2019 16:00:18 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553785218; bh=q9NT2Llm953rb4Q2ZgieB5DwdmFzg9pvg6k5+wKs1Pk=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ja91P3I0DLiWITV5Z+cBccJVCMrjSdDJSJvN6mZ1oKbJUuijbEzEAmH/M0qj0+jPl
	 CMKPf8bZK3eChaq02f3oiRpcXxlipsE3/1cAMv+wnwV1Lzu6ZN8HmV9Svq7Bl4vwa0
	 2XFG6gF5FtItjw+J9QB2Lt6qAieA0daOTAgY9i9M=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 9186A8B923;
	Thu, 28 Mar 2019 16:00:19 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id CBK5Tgf_LUxV; Thu, 28 Mar 2019 16:00:19 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 353A88B91C;
	Thu, 28 Mar 2019 16:00:19 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 0B8CB6FC84; Thu, 28 Mar 2019 15:00:19 +0000 (UTC)
Message-Id: <51a6d9d7185de310f37ccbd7e4ebfdd6c7e9791f.1553785020.git.christophe.leroy@c-s.fr>
In-Reply-To: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
References: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v2 3/3] kasan: add interceptors for all string functions
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Thu, 28 Mar 2019 15:00:19 +0000 (UTC)
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
 v2: Fixed a few checkpatch stuff and added missing EXPORT_SYMBOL() and missing #undefs

 include/linux/string.h |  79 ++++++++++
 lib/Makefile           |   2 +
 lib/string.c           |   8 +
 mm/kasan/string.c      | 394 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 483 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 7927b875f80c..3d2aff2ed402 100644
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
+char *__strcpy(char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNCPY
 extern char * strncpy(char *,const char *, __kernel_size_t);
+char *__strncpy(char *, const char *, __kernel_size_t);
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
+int __strcmp(const char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRNCMP
 extern int strncmp(const char *,const char *,__kernel_size_t);
+int __strncmp(const char *, const char *, __kernel_size_t);
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
+char *__strchr(const char *, int);
 #endif
 #ifndef __HAVE_ARCH_STRCHRNUL
 extern char * strchrnul(const char *,int);
+char *__strchrnul(const char *, int);
 #endif
 #ifndef __HAVE_ARCH_STRNCHR
 extern char * strnchr(const char *, size_t, int);
+char *__strnchr(const char *, size_t, int);
 #endif
 #ifndef __HAVE_ARCH_STRRCHR
 extern char * strrchr(const char *,int);
+char *__strrchr(const char *, int);
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
+__kernel_size_t __strnlen(const char *, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_STRPBRK
 extern char * strpbrk(const char *,const char *);
+char *__strpbrk(const char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRSEP
 extern char * strsep(char **,const char *);
+char *__strsep(char **, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRSPN
 extern __kernel_size_t strspn(const char *,const char *);
+__kernel_size_t __strspn(const char *, const char *);
 #endif
 #ifndef __HAVE_ARCH_STRCSPN
 extern __kernel_size_t strcspn(const char *,const char *);
+__kernel_size_t __strcspn(const char *, const char *);
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
+void *__memscan(void *, int, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMCMP
 extern int memcmp(const void *,const void *,__kernel_size_t);
+int __memcmp(const void *, const void *, __kernel_size_t);
 #endif
 #ifndef __HAVE_ARCH_MEMCHR
 extern void * memchr(const void *,int,__kernel_size_t);
+void *__memchr(const void *, int, __kernel_size_t);
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
diff --git a/lib/string.c b/lib/string.c
index f3886c5175ac..31a253201bba 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -85,7 +85,9 @@ EXPORT_SYMBOL(strcasecmp);
  * @dest: Where to copy the string to
  * @src: Where to copy the string from
  */
+#ifndef CONFIG_KASAN
 #undef strcpy
+#endif
 char *strcpy(char *dest, const char *src)
 {
 	char *tmp = dest;
@@ -243,7 +245,9 @@ EXPORT_SYMBOL(strscpy);
  * @dest: The string to be appended to
  * @src: The string to append to it
  */
+#ifndef CONFIG_KASAN
 #undef strcat
+#endif
 char *strcat(char *dest, const char *src)
 {
 	char *tmp = dest;
@@ -319,7 +323,9 @@ EXPORT_SYMBOL(strlcat);
  * @cs: One string
  * @ct: Another string
  */
+#ifndef CONFIG_KASAN
 #undef strcmp
+#endif
 int strcmp(const char *cs, const char *ct)
 {
 	unsigned char c1, c2;
@@ -773,7 +779,9 @@ EXPORT_SYMBOL(memmove);
  * @ct: Another area of memory
  * @count: The size of the area.
  */
+#ifndef CONFIG_KASAN
 #undef memcmp
+#endif
 __visible int memcmp(const void *cs, const void *ct, size_t count)
 {
 	const unsigned char *su1, *su2;
diff --git a/mm/kasan/string.c b/mm/kasan/string.c
index 083b967255a2..0db31bbbf643 100644
--- a/mm/kasan/string.c
+++ b/mm/kasan/string.c
@@ -35,6 +35,42 @@ void *memset(void *addr, int c, size_t len)
 	return __memset(addr, c, len);
 }
 
+#undef memset16
+void *memset16(uint16_t *s, uint16_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 1, true, _RET_IP_);
+
+	return __memset16(s, v, count);
+}
+EXPORT_SYMBOL(memset16);
+
+#undef memset32
+void *memset32(uint32_t *s, uint32_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 2, true, _RET_IP_);
+
+	return __memset32(s, v, count);
+}
+EXPORT_SYMBOL(memset32);
+
+#undef memset64
+void *memset64(uint64_t *s, uint64_t v, size_t count)
+{
+	check_memory_region((unsigned long)s, count << 3, true, _RET_IP_);
+
+	return __memset64(s, v, count);
+}
+EXPORT_SYMBOL(memset64);
+
+#undef memzero_explicit
+void memzero_explicit(void *s, size_t count)
+{
+	check_memory_region((unsigned long)s, count, true, _RET_IP_);
+
+	return __memzero_explicit(s, count);
+}
+EXPORT_SYMBOL(memzero_explicit);
+
 #undef memmove
 void *memmove(void *dest, const void *src, size_t len)
 {
@@ -52,3 +88,361 @@ void *memcpy(void *dest, const void *src, size_t len)
 
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
+EXPORT_SYMBOL(strcpy);
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
+EXPORT_SYMBOL(strncpy);
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
+EXPORT_SYMBOL(strlcpy);
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
+EXPORT_SYMBOL(strscpy);
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
+EXPORT_SYMBOL(strcat);
+
+#undef strncat
+char *strncat(char *dest, const char *src, size_t count)
+{
+	size_t slen = min(__strlen(src) + 1, count);
+	size_t dlen = __strlen(dest);
+
+	check_memory_region((unsigned long)src, slen, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
+	check_memory_region((unsigned long)(dest + dlen), slen, true, _RET_IP_);
+
+	return __strncat(dest, src, count);
+}
+EXPORT_SYMBOL(strncat);
+
+#undef strlcat
+size_t strlcat(char *dest, const char *src, size_t count)
+{
+	size_t slen = min(__strlen(src) + 1, count);
+	size_t dlen = __strlen(dest);
+
+	check_memory_region((unsigned long)src, slen, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, dlen, false, _RET_IP_);
+	check_memory_region((unsigned long)(dest + dlen), slen, true, _RET_IP_);
+
+	return __strlcat(dest, src, count);
+}
+EXPORT_SYMBOL(strlcat);
+
+#undef strcmp
+int strcmp(const char *cs, const char *ct)
+{
+	size_t len = min(__strlen(cs) + 1, __strlen(ct) + 1);
+
+	check_memory_region((unsigned long)cs, len, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, len, false, _RET_IP_);
+
+	return __strcmp(cs, ct);
+}
+EXPORT_SYMBOL(strcmp);
+
+#undef strncmp
+int strncmp(const char *cs, const char *ct, size_t count)
+{
+	size_t len = min3(__strlen(cs) + 1, __strlen(ct) + 1, count);
+
+	check_memory_region((unsigned long)cs, len, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, len, false, _RET_IP_);
+
+	return __strncmp(cs, ct, count);
+}
+EXPORT_SYMBOL(strncmp);
+
+#undef strcasecmp
+int strcasecmp(const char *s1, const char *s2)
+{
+	size_t len = min(__strlen(s1) + 1, __strlen(s2) + 1);
+
+	check_memory_region((unsigned long)s1, len, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, len, false, _RET_IP_);
+
+	return __strcasecmp(s1, s2);
+}
+EXPORT_SYMBOL(strcasecmp);
+
+#undef strncasecmp
+int strncasecmp(const char *s1, const char *s2, size_t len)
+{
+	size_t sz = min3(__strlen(s1) + 1, __strlen(s2) + 1, len);
+
+	check_memory_region((unsigned long)s1, sz, false, _RET_IP_);
+	check_memory_region((unsigned long)s2, sz, false, _RET_IP_);
+
+	return __strncasecmp(s1, s2, len);
+}
+EXPORT_SYMBOL(strncasecmp);
+
+#undef strchr
+char *strchr(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strchr(s, c);
+}
+EXPORT_SYMBOL(strchr);
+
+#undef strchrnul
+char *strchrnul(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strchrnul(s, c);
+}
+EXPORT_SYMBOL(strchrnul);
+
+#undef strrchr
+char *strrchr(const char *s, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strrchr(s, c);
+}
+EXPORT_SYMBOL(strrchr);
+
+#undef strnchr
+char *strnchr(const char *s, size_t count, int c)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strnchr(s, count, c);
+}
+EXPORT_SYMBOL(strnchr);
+
+#undef skip_spaces
+char *skip_spaces(const char *str)
+{
+	size_t len = __strlen(str) + 1;
+
+	check_memory_region((unsigned long)str, len, false, _RET_IP_);
+
+	return __skip_spaces(str);
+}
+EXPORT_SYMBOL(skip_spaces);
+
+#undef strim
+char *strim(char *s)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, false, _RET_IP_);
+
+	return __strim(s);
+}
+EXPORT_SYMBOL(strim);
+
+#undef strstr
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
+EXPORT_SYMBOL(strstr);
+
+#undef strnstr
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
+EXPORT_SYMBOL(strnstr);
+
+#undef strlen
+size_t strlen(const char *s)
+{
+	size_t len = __strlen(s);
+
+	check_memory_region((unsigned long)s, len + 1, false, _RET_IP_);
+
+	return len;
+}
+EXPORT_SYMBOL(strlen);
+
+#undef strnlen
+size_t strnlen(const char *s, size_t count)
+{
+	size_t len = __strnlen(s, count);
+
+	check_memory_region((unsigned long)s, min(len + 1, count), false, _RET_IP_);
+
+	return len;
+}
+EXPORT_SYMBOL(strnlen);
+
+#undef strpbrk
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
+EXPORT_SYMBOL(strpbrk);
+
+#undef strsep
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
+EXPORT_SYMBOL(strsep);
+
+#undef strspn
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
+EXPORT_SYMBOL(strspn);
+
+#undef strcspn
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
+EXPORT_SYMBOL(strcspn);
+
+#undef memscan
+void *memscan(void *addr, int c, size_t size)
+{
+	check_memory_region((unsigned long)addr, size, false, _RET_IP_);
+
+	return __memscan(addr, c, size);
+}
+EXPORT_SYMBOL(memscan);
+
+#undef memcmp
+int memcmp(const void *cs, const void *ct, size_t count)
+{
+	check_memory_region((unsigned long)cs, count, false, _RET_IP_);
+	check_memory_region((unsigned long)ct, count, false, _RET_IP_);
+
+	return __memcmp(cs, ct, count);
+}
+EXPORT_SYMBOL(memcmp);
+
+#undef memchr
+void *memchr(const void *s, int c, size_t n)
+{
+	check_memory_region((unsigned long)s, n, false, _RET_IP_);
+
+	return __memchr(s, c, n);
+}
+EXPORT_SYMBOL(memchr);
+
+#undef memchr_inv
+void *memchr_inv(const void *start, int c, size_t bytes)
+{
+	check_memory_region((unsigned long)start, bytes, false, _RET_IP_);
+
+	return __memchr_inv(start, c, bytes);
+}
+EXPORT_SYMBOL(memchr_inv);
+
+#undef strreplace
+char *strreplace(char *s, char old, char new)
+{
+	size_t len = __strlen(s) + 1;
+
+	check_memory_region((unsigned long)s, len, true, _RET_IP_);
+
+	return __strreplace(s, old, new);
+}
+EXPORT_SYMBOL(strreplace);
-- 
2.13.3

