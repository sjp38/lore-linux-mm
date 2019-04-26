Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67952C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2703206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="MKny5XH1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2703206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DCCE6B0008; Fri, 26 Apr 2019 12:23:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58D1F6B000A; Fri, 26 Apr 2019 12:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F836B000C; Fri, 26 Apr 2019 12:23:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA62A6B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:29 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s3so3887186wrn.1
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=9adWQ2eOTpeKwqD9lHYd+6T0EtP8IVztHNLFGdN0+Sk=;
        b=eWEcyyY4KXvLUFHMp/+0De1lWM0kv442NdeNPWtYObRzfZR2kRnG3Srv34B0iK2lrY
         EM7bez+e4cNfsGEpPp9R6UV0PbSY0DrClpR9rhZmOpL2MszBk0iz+NDETG+IqLoHEELj
         OhjJN6fFeRDE6IPZzuxLnS7mvPOXRwEIEz7bBX0t2QgW+7D15QtWm5aJM6oHaD332XhH
         i1bj3fm6jN8ERenrovld+oQ+xP8AIzK3bFf7r9G6kzJiu4Tm4C7r4QqSSwMVocpGqNip
         n5UD2LmIh7T33Ufb6PTS5K7nPrDPZ0BpSMFPKVqtK14xG4nXHSXuRjs+T8H2bAJUAFDn
         PdQQ==
X-Gm-Message-State: APjAAAVJpYx2sb7xC7yNNaqncqw7ryu4Do5Fn0IgU1165Jns9dKsKyYU
	UZl/DptzlYadppSeywfh8/Rk0mSQhs+aHuGKZ7kvnW0OwwlEqfht/U6Y9ne1YI0H+9CqWv6Q+8a
	zROvjFaIvBPrVfNn6YP+xkmgTluhWk3aU8wxCyCFfIzsx0eXWsWK99V8r7L2YLkiSQQ==
X-Received: by 2002:a1c:eb12:: with SMTP id j18mr8979286wmh.48.1556295809274;
        Fri, 26 Apr 2019 09:23:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfzabZAYEM3nXr/RoDpZ+Oxj2iEzvCRhdDSyF5m+juj3m71K473+vXlWQbwu5WjEKGI/RD
X-Received: by 2002:a1c:eb12:: with SMTP id j18mr8979141wmh.48.1556295807207;
        Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295807; cv=none;
        d=google.com; s=arc-20160816;
        b=0KKA++FP4h+eGWzGbHonhy7D1lhOC+VwiKl0A2TNRedKdnr0VCEWujA8FLZq2y6PZY
         HwGtkeNnEA5Cs+vR0T2TWdc16/sM2DxPJMCC1A6jDDZL7cUNA1/nY+xC4xI+zvs93p4o
         XWCSVW5jm28D7mlBGr2i6OIBvTA2JxGBnDZCJdS/AFQPvJJxB7Iwn092iKw2TULCJmAW
         prefq5FhUDFCk4lWtVw9gUsHFjB3K4k9pyniII1c+3ATDLbL+VSGfoFA9KQW9JWPBHHQ
         Uhxcze4NQTaHQ6F+N0R0ZdVrwrbW/hZ7dDb4953D49zKctqdVHWg8htaptO18TT6Ngi1
         XX4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=9adWQ2eOTpeKwqD9lHYd+6T0EtP8IVztHNLFGdN0+Sk=;
        b=jBfYVbS91J6kyxFpe8ulYM9qrB/Vxhp7Hg9O7r20dZicTDLy67bgv2X82gJqqHc5tj
         4IonsJP5Ddd3ryvrz+YGFRbBdm9sWpbWwlIeWRKchHi3zlvVzxvcwXXiDZ2TIn2y/ULj
         CZ26X9aS3ES/V2IcTxBj92Y8KG8qCFI8+EYLA9dgr9bTdwmRrK2Cg7jFQCCBNiJayccA
         yN4sb12Ser1JEVgUDlhfmEhNtoGcxpNCxW3UT9gxdw0GKpWcOJ0qwW98tmzgVfu/epdL
         dGJpbCXo4zUJnEetRohe1SQXVvGs0ZmwXdz7YpxYFH9dJ1a1XuRr/UHWMrwWyA0ayHqc
         cayA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=MKny5XH1;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p18si17124016wmg.69.2019.04.26.09.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=MKny5XH1;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9T0Jgtz9v0ym;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=MKny5XH1; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id WSbBYeza3GPJ; Fri, 26 Apr 2019 18:23:24 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9S6Fptz9v0yk;
	Fri, 26 Apr 2019 18:23:24 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295804; bh=9adWQ2eOTpeKwqD9lHYd+6T0EtP8IVztHNLFGdN0+Sk=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=MKny5XH1yYFlEAq+dXIMu3sMEXxD++jhnK85fTneFxjAFZ2D0vL7E9QLUTOhM/f3u
	 JJwGtsMCaSn2CkHLoS/s3CMbYrJkc9r9NED9QK4L9/5chBnjyQ4ZL7VD561Sz2gSL6
	 iZxd8qXY8mz/1A+r02OQ8yVd1PhfWm9nksLpxP2E=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 839BF8B950;
	Fri, 26 Apr 2019 18:23:26 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id u-KJZL0T1R3T; Fri, 26 Apr 2019 18:23:26 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5243F8B82F;
	Fri, 26 Apr 2019 18:23:26 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 48BC4666FE; Fri, 26 Apr 2019 16:23:26 +0000 (UTC)
Message-Id: <5b21f6f0207ecab6d4f13bded4c95b0662fa749e.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 02/13] powerpc: prepare string/mem functions for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_KASAN implements wrappers for memcpy() memmove() and memset()
Those wrappers are doing the verification then call respectively
__memcpy() __memmove() and __memset(). The arches are therefore
expected to rename their optimised functions that way.

For files on which KASAN is inhibited, #defines are used to allow
them to directly call optimised versions of the functions without
going through the KASAN wrappers.

See commit 393f203f5fd5 ("x86_64: kasan: add interceptors for
memset/memmove/memcpy functions") for details.

Other string / mem functions do not (yet) have kasan wrappers,
we therefore have to fallback to the generic versions when
KASAN is active, otherwise KASAN checks will be skipped.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/kasan.h       | 15 +++++++++++++++
 arch/powerpc/include/asm/string.h      | 32 +++++++++++++++++++++++++++++---
 arch/powerpc/kernel/prom_init_check.sh | 10 +++++++++-
 arch/powerpc/lib/Makefile              | 11 ++++++++---
 arch/powerpc/lib/copy_32.S             | 12 +++++++++---
 arch/powerpc/lib/mem_64.S              |  9 +++++++--
 arch/powerpc/lib/memcpy_64.S           |  4 +++-
 7 files changed, 80 insertions(+), 13 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h

diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
new file mode 100644
index 000000000000..2c179a39d4ba
--- /dev/null
+++ b/arch/powerpc/include/asm/kasan.h
@@ -0,0 +1,15 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifdef CONFIG_KASAN
+#define _GLOBAL_KASAN(fn)	_GLOBAL(__##fn)
+#define _GLOBAL_TOC_KASAN(fn)	_GLOBAL_TOC(__##fn)
+#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(__##fn)
+#else
+#define _GLOBAL_KASAN(fn)	_GLOBAL(fn)
+#define _GLOBAL_TOC_KASAN(fn)	_GLOBAL_TOC(fn)
+#define EXPORT_SYMBOL_KASAN(fn)
+#endif
+
+#endif
diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
index 1647de15a31e..9bf6dffb4090 100644
--- a/arch/powerpc/include/asm/string.h
+++ b/arch/powerpc/include/asm/string.h
@@ -4,14 +4,17 @@
 
 #ifdef __KERNEL__
 
+#ifndef CONFIG_KASAN
 #define __HAVE_ARCH_STRNCPY
 #define __HAVE_ARCH_STRNCMP
+#define __HAVE_ARCH_MEMCHR
+#define __HAVE_ARCH_MEMCMP
+#define __HAVE_ARCH_MEMSET16
+#endif
+
 #define __HAVE_ARCH_MEMSET
 #define __HAVE_ARCH_MEMCPY
 #define __HAVE_ARCH_MEMMOVE
-#define __HAVE_ARCH_MEMCMP
-#define __HAVE_ARCH_MEMCHR
-#define __HAVE_ARCH_MEMSET16
 #define __HAVE_ARCH_MEMCPY_FLUSHCACHE
 
 extern char * strcpy(char *,const char *);
@@ -27,7 +30,27 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
 extern void * memchr(const void *,int,__kernel_size_t);
 extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
 
+void *__memset(void *s, int c, __kernel_size_t count);
+void *__memcpy(void *to, const void *from, __kernel_size_t n);
+void *__memmove(void *to, const void *from, __kernel_size_t n);
+
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
+#endif
+
 #ifdef CONFIG_PPC64
+#ifndef CONFIG_KASAN
 #define __HAVE_ARCH_MEMSET32
 #define __HAVE_ARCH_MEMSET64
 
@@ -49,8 +72,11 @@ static inline void *memset64(uint64_t *p, uint64_t v, __kernel_size_t n)
 {
 	return __memset64(p, v, n * 8);
 }
+#endif
 #else
+#ifndef CONFIG_KASAN
 #define __HAVE_ARCH_STRLEN
+#endif
 
 extern void *memset16(uint16_t *, uint16_t, __kernel_size_t);
 #endif
diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
index 667df97d2595..181fd10008ef 100644
--- a/arch/powerpc/kernel/prom_init_check.sh
+++ b/arch/powerpc/kernel/prom_init_check.sh
@@ -16,8 +16,16 @@
 # If you really need to reference something from prom_init.o add
 # it to the list below:
 
+grep "^CONFIG_KASAN=y$" .config >/dev/null
+if [ $? -eq 0 ]
+then
+	MEM_FUNCS="__memcpy __memset"
+else
+	MEM_FUNCS="memcpy memset"
+fi
+
 WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
-_end enter_prom memcpy memset reloc_offset __secondary_hold
+_end enter_prom $MEM_FUNCS reloc_offset __secondary_hold
 __secondary_hold_acknowledge __secondary_hold_spinloop __start
 strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
 reloc_got2 kernstart_addr memstart_addr linux_banner _stext
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index 79396e184bca..47a4de434c22 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -8,9 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
 
-obj-y += string.o alloc.o code-patching.o feature-fixups.o
+obj-y += alloc.o code-patching.o feature-fixups.o
 
-obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
+ifndef CONFIG_KASAN
+obj-y	+=	string.o memcmp_$(BITS).o
+obj-$(CONFIG_PPC32)	+= strlen_32.o
+endif
+
+obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o
 
 obj-$(CONFIG_FUNCTION_ERROR_INJECTION)	+= error-inject.o
 
@@ -34,7 +39,7 @@ obj64-$(CONFIG_KPROBES_SANITY_TEST)	+= test_emulate_step.o \
 					   test_emulate_step_exec_instr.o
 
 obj-y			+= checksum_$(BITS).o checksum_wrappers.o \
-			   string_$(BITS).o memcmp_$(BITS).o
+			   string_$(BITS).o
 
 obj-y			+= sstep.o ldstfp.o quad.o
 obj64-y			+= quad.o
diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
index ba66846fe973..d5642481fb98 100644
--- a/arch/powerpc/lib/copy_32.S
+++ b/arch/powerpc/lib/copy_32.S
@@ -14,6 +14,7 @@
 #include <asm/ppc_asm.h>
 #include <asm/export.h>
 #include <asm/code-patching-asm.h>
+#include <asm/kasan.h>
 
 #define COPY_16_BYTES		\
 	lwz	r7,4(r4);	\
@@ -68,6 +69,7 @@ CACHELINE_BYTES = L1_CACHE_BYTES
 LG_CACHELINE_BYTES = L1_CACHE_SHIFT
 CACHELINE_MASK = (L1_CACHE_BYTES-1)
 
+#ifndef CONFIG_KASAN
 _GLOBAL(memset16)
 	rlwinm.	r0 ,r5, 31, 1, 31
 	addi	r6, r3, -4
@@ -81,6 +83,7 @@ _GLOBAL(memset16)
 	sth	r4, 4(r6)
 	blr
 EXPORT_SYMBOL(memset16)
+#endif
 
 /*
  * Use dcbz on the complete cache lines in the destination
@@ -91,7 +94,7 @@ EXPORT_SYMBOL(memset16)
  * We therefore skip the optimised bloc that uses dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memset)
+_GLOBAL_KASAN(memset)
 	cmplwi	0,r5,4
 	blt	7f
 
@@ -151,6 +154,7 @@ _GLOBAL(memset)
 	bdnz	9b
 	blr
 EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
 /*
  * This version uses dcbz on the complete cache lines in the
@@ -163,12 +167,12 @@ EXPORT_SYMBOL(memset)
  * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memmove)
+_GLOBAL_KASAN(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	/* fall through */
 
-_GLOBAL(memcpy)
+_GLOBAL_KASAN(memcpy)
 1:	b	generic_memcpy
 	patch_site	1b, patch__memcpy_nocache
 
@@ -244,6 +248,8 @@ _GLOBAL(memcpy)
 65:	blr
 EXPORT_SYMBOL(memcpy)
 EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memcpy)
+EXPORT_SYMBOL_KASAN(memmove)
 
 generic_memcpy:
 	srwi.	r7,r5,3
diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
index 3c3be02f33b7..7f6bd031c306 100644
--- a/arch/powerpc/lib/mem_64.S
+++ b/arch/powerpc/lib/mem_64.S
@@ -12,7 +12,9 @@
 #include <asm/errno.h>
 #include <asm/ppc_asm.h>
 #include <asm/export.h>
+#include <asm/kasan.h>
 
+#ifndef CONFIG_KASAN
 _GLOBAL(__memset16)
 	rlwimi	r4,r4,16,0,15
 	/* fall through */
@@ -29,8 +31,9 @@ _GLOBAL(__memset64)
 EXPORT_SYMBOL(__memset16)
 EXPORT_SYMBOL(__memset32)
 EXPORT_SYMBOL(__memset64)
+#endif
 
-_GLOBAL(memset)
+_GLOBAL_KASAN(memset)
 	neg	r0,r3
 	rlwimi	r4,r4,8,16,23
 	andi.	r0,r0,7			/* # bytes to be 8-byte aligned */
@@ -96,8 +99,9 @@ _GLOBAL(memset)
 	stb	r4,0(r6)
 	blr
 EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
-_GLOBAL_TOC(memmove)
+_GLOBAL_TOC_KASAN(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	b	memcpy
@@ -139,3 +143,4 @@ _GLOBAL(backwards_memcpy)
 	mtctr	r7
 	b	1b
 EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memmove)
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index 273ea67e60a1..25c3772c1dfb 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -11,6 +11,7 @@
 #include <asm/export.h>
 #include <asm/asm-compat.h>
 #include <asm/feature-fixups.h>
+#include <asm/kasan.h>
 
 #ifndef SELFTEST_CASE
 /* For big-endian, 0 == most CPUs, 1 == POWER6, 2 == Cell */
@@ -18,7 +19,7 @@
 #endif
 
 	.align	7
-_GLOBAL_TOC(memcpy)
+_GLOBAL_TOC_KASAN(memcpy)
 BEGIN_FTR_SECTION
 #ifdef __LITTLE_ENDIAN__
 	cmpdi	cr7,r5,0
@@ -230,3 +231,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
 	blr
 #endif
 EXPORT_SYMBOL(memcpy)
+EXPORT_SYMBOL_KASAN(memcpy)
-- 
2.13.3

