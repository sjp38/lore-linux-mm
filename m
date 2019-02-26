Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A96DC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BA5021848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="GAmh5lh3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BA5021848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A29C98E0005; Tue, 26 Feb 2019 12:22:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2B98E0003; Tue, 26 Feb 2019 12:22:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 854888E0005; Tue, 26 Feb 2019 12:22:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 271098E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:46 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id b9so6647893wrw.14
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=oHghTvnVgM5iLsW9vWXEequS4LO8QERrM8ZuJ6h5wq4=;
        b=qYDAnnF7rh6xHxEJTSgplGXqwis3lC0wvwjtcu5oxvxpQ3in8qMArh0KiD2dWLuoV5
         wjqE4fFnBRb4xcq/5WSxJwjt2aOBHqC8QmJUVN1nwnnRHXghYa9tDB8ss5E/kaVMG/Hi
         5qF7dCgxhnW8pscVmYpyzwtN9livb4FBjfwb3JJYxKfNNuQ2OS8F7HSqjjJb8rAFw/Um
         L3AL1ijBdPAkzZENV0WWKV43pleqgGcar+PQzUF8VeBKVU6Ppu+RaQ/1GJ/qneShNZo3
         24fqlHvsAmOBStp9jty+2rt4EYfR5HCQdFIokguQ8xrcX79t44G0fYEdqFbxMZJrQ2tK
         VoDw==
X-Gm-Message-State: AHQUAuYGmI9+wIVhsjLoO61yw8LFHsYzGud5y1gfV1phOYmBQ6ITTZVg
	/KcZzz0s+brPe5/CaXVacmGvxSUSdEc1W1+Oe1181wbqiShmRYkFNWAx5EnUkECAnHsM4CoEVQr
	xjLWcU8Tque5dcd2eY1WjJU+pyn+f/awbRefrb2ltEomoxiJL1+Xw1qB+O53/bwcpVg==
X-Received: by 2002:adf:b3d1:: with SMTP id x17mr9809596wrd.15.1551201765645;
        Tue, 26 Feb 2019 09:22:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYrqJKjNeKQ0Qb/4KqADpcHxWVlHqH0Z3gOMXsK+3zNE6gl5ZnW+MX16Xhps00nkoo2UO5
X-Received: by 2002:adf:b3d1:: with SMTP id x17mr9809535wrd.15.1551201764371;
        Tue, 26 Feb 2019 09:22:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201764; cv=none;
        d=google.com; s=arc-20160816;
        b=OdwjfZaLbI2+kQ9fTalmUe8r6DZWJBmEW30DxpHzIjn+SFghCiP2aFj7RhjXwyON3w
         uKA0FrCFOl0PiXvcZfCK5LzFkOHBxjcMDi0UdXq+YaQepJht/rpO+qKsyLzYT+ioWz9k
         2bpwCFta0cWloRC+UGnSEdx5zqK7E4xq+5va1aZbJi0xyv20HTeyXhRnwIE7AOLCezpU
         m3zKqrKdxlkJUE02V0kP+0sFeBDFPTUT+s7d7WjQzLI8MttnWQGNOPVtS/G4c5t2F5QO
         XEcZzut4fjike4r7CkOOxYwoOGFLfJNlvcS+G91FJMvn2EvRQJYTtN04S+fjwmWBmDff
         tVLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=oHghTvnVgM5iLsW9vWXEequS4LO8QERrM8ZuJ6h5wq4=;
        b=rQOLk7CKbloKMmAGECgKpouu1+DQpKmj3yVYb+0c8zzbPV/bcdk9mhDmB4587yIdX5
         Vvdhb5txbESyTpx4t2ZvMp5pSPqF0YjxK/Q8FqubPzNOWwCDdvtSFj8UFQwY8rmfVph+
         5K7J+xTsADtonZJaCI2bwSIi69K5GO8PZmemhLapZstqin29LcWSvEPdiyzBeybYdsy5
         zgnORvCs+PS502feCeVulLgmxNowbu/4g2Fa/fno6iCkXyirblFePahI7bU/Ld8FDOKf
         mYj5leVoZkjTIR2m+ow+7XC4bvXmj2EJwwsIgyKxzaUgIpFlXWuCHWVVN+CNDNk/jcWP
         t9lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=GAmh5lh3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id e13si10159691wrv.387.2019.02.26.09.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:44 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=GAmh5lh3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H61YDdz9vJLc;
	Tue, 26 Feb 2019 18:22:42 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=GAmh5lh3; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id soow2-6HSENf; Tue, 26 Feb 2019 18:22:42 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H60S6jz9vJLY;
	Tue, 26 Feb 2019 18:22:42 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201762; bh=oHghTvnVgM5iLsW9vWXEequS4LO8QERrM8ZuJ6h5wq4=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=GAmh5lh3ZWilqfscY3ubC5F4zxDBpZssOw/aY9WDHxru45Aln57JYJoUqKmh0EwYg
	 ZqE339wMqCZTz2s/gCMwEH8tVLurOenepMJdjtXY10zONwXWIWI+H4AFXsndzV1XxX
	 gQ8B0sXcU7sn69JW23U+J8pnaM2IulQorMrnkJeI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id AE5DC8B97A;
	Tue, 26 Feb 2019 18:22:43 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id kwd6bLmzUTYr; Tue, 26 Feb 2019 18:22:43 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5D26A8B96A;
	Tue, 26 Feb 2019 18:22:43 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 401776F7B5; Tue, 26 Feb 2019 17:22:43 +0000 (UTC)
Message-Id: <54c5d48a557647be5e0269a22be277891bbdd7f7.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 02/11] powerpc: prepare string/mem functions for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:43 +0000 (UTC)
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
 arch/powerpc/lib/copy_32.S             | 15 +++++++++------
 arch/powerpc/lib/mem_64.S              | 11 +++++++----
 arch/powerpc/lib/memcpy_64.S           |  5 +++--
 7 files changed, 80 insertions(+), 19 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h

diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
new file mode 100644
index 000000000000..c3161b8fc017
--- /dev/null
+++ b/arch/powerpc/include/asm/kasan.h
@@ -0,0 +1,15 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifdef CONFIG_KASAN
+#define _GLOBAL_KASAN(fn)	.weak fn ; _GLOBAL(__##fn) ; _GLOBAL(fn)
+#define _GLOBAL_TOC_KASAN(fn)	.weak fn ; _GLOBAL_TOC(__##fn) ; _GLOBAL_TOC(fn)
+#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(__##fn) ; EXPORT_SYMBOL(fn)
+#else
+#define _GLOBAL_KASAN(fn)	_GLOBAL(fn)
+#define _GLOBAL_TOC_KASAN(fn)	_GLOBAL_TOC(fn)
+#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
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
index ba66846fe973..fc4fa7246200 100644
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
 
@@ -150,7 +153,7 @@ _GLOBAL(memset)
 9:	stbu	r4,1(r6)
 	bdnz	9b
 	blr
-EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
 /*
  * This version uses dcbz on the complete cache lines in the
@@ -163,12 +166,12 @@ EXPORT_SYMBOL(memset)
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
 
@@ -242,8 +245,8 @@ _GLOBAL(memcpy)
 	stbu	r0,1(r6)
 	bdnz	40b
 65:	blr
-EXPORT_SYMBOL(memcpy)
-EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memcpy)
+EXPORT_SYMBOL_KASAN(memmove)
 
 generic_memcpy:
 	srwi.	r7,r5,3
diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
index 3c3be02f33b7..7cd6cf6822a2 100644
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
@@ -95,9 +98,9 @@ _GLOBAL(memset)
 10:	bflr	31
 	stb	r4,0(r6)
 	blr
-EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
-_GLOBAL_TOC(memmove)
+_GLOBAL_TOC_KASAN(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	b	memcpy
@@ -138,4 +141,4 @@ _GLOBAL(backwards_memcpy)
 	beq	2b
 	mtctr	r7
 	b	1b
-EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memmove)
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index 273ea67e60a1..862b515b8868 100644
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
@@ -229,4 +230,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
 4:	ld	r3,-STACKFRAMESIZE+STK_REG(R31)(r1)	/* return dest pointer */
 	blr
 #endif
-EXPORT_SYMBOL(memcpy)
+EXPORT_SYMBOL_KASAN(memcpy)
-- 
2.13.3

