Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6B98C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66CC620842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="RBEEY4AQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66CC620842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FAA48E017E; Mon, 25 Feb 2019 08:48:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9821B8E011F; Mon, 25 Feb 2019 08:48:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D4628E017E; Mon, 25 Feb 2019 08:48:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29E898E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:46 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j44so4745277wre.22
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=f+gjqhz+4Hk5KVmhC1e+ByhOtoyj/5eiHmzF+GAPS6HTDFaTzKn3Hi4FoFEMzov72w
         vBE1thaCcdPyhI5Ex8SvGfSKk9ut+plUgDabv5kUSMlAtNuaqX3j4CeIqguIC6QX6twt
         /GVX3pXa9/KTbyFTwWBA8elrUfQggqSbmpI0TGZOW9KZCYinVnxPGKEWuZmS73D+tl6P
         Kzgcdi/RmguxziEOqeMAVASoaLIQFH18bKSoaUVOxluyOSmW/V1qzsO6UpCst5VlpJdi
         HvLnjpm7cjpsf1Vcktcke07rOZg2L3D51jemU3CrE8NLwCg5mNZVZCJZGqhZh5LjLtso
         cGiA==
X-Gm-Message-State: AHQUAuaZ3blwmwPi5XfDxWsYBrKjDfnwB7WtgWQR8SewwitHtaapXOxl
	lKa86F8yDkcMBHVhDu8KkQQbpr32HjOqMUl+sb0sCafyZVKoGTBX8eWGNj1iFpfPDrGhe7rzl3X
	c2aW2Dz/usQKoL+sfUFX0J9I+9DD0BPnGPxsnaIbya7Ws0loEx2L58OtqDC9DFm/oUA==
X-Received: by 2002:a05:6000:1084:: with SMTP id y4mr12848071wrw.14.1551102525697;
        Mon, 25 Feb 2019 05:48:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4AdjJwyuxXT6xVtUlI/iKcKxlnacp4drgO4ZzZDlLqUz1nj8PSqyZwxE72RMFGClITrt0
X-Received: by 2002:a05:6000:1084:: with SMTP id y4mr12848014wrw.14.1551102524590;
        Mon, 25 Feb 2019 05:48:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102524; cv=none;
        d=google.com; s=arc-20160816;
        b=lnCXOf6SDn4GtBZ5zYrpeJo0yH6QTxJPx8IvEaSFiQcvaXu//ZW5Wk+lss9DEqxlax
         VLigd+2mFZuVmNdPQ7bJhV6Oq1kpts+gM+i3FIFqQtrWyeqp1c2FVAtr8BGW2jEoOCxh
         LoxthT+vTx54ySBf0BBhYDfbbRC0RWzHknu17K/Tivo4uy6CuEDDoGg2DrCEKt+8g5bI
         /gvUQkZaZYIZocxxRuc3TlUXEUor1gXCmEaRvyZkgswYhUJgljzLwJrqENL6m52h75jI
         qmxdanwaU6Cg9X9ziDOVP+31S28/4Mf0YiKpGSIRuKrvzC4ozER4ZkPnWbt+nnFn5iwY
         Wt9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=tBlxZ8uK9dW6srH88I58aiWDBXLhgsDAGTkch51e33CEVeM2tB83ZZysuqvvGyZykq
         NF1b+1Z0Yx0LHQ113gP6oHBONW0V4kkVU+ae9BMRJ8outHqqxkOkVrQPkZ8b3+WkyiNa
         hJBw6xxtjDTYGZXhPljxqoSbEFe5mHJ2JXTaSgIn2cID66A+p+xanJDu0rjvCLdJg2UE
         /VPVjGRQV+oDNuesM5/zN2pNF2lk7E7TB2Hn/zIBEk/Hppln+oT3kUVVRNYk6mBncZVs
         0lwjOxWIQjLqq1f3t/h1hg9aJKUYrXaZlIfmDLXIo+Rbe4D5HzMFzdXHP8WGr8Jxnnog
         3HJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RBEEY4AQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n18si6382134wrv.402.2019.02.25.05.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:44 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RBEEY4AQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZb0NKQzB09b1;
	Mon, 25 Feb 2019 14:48:39 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=RBEEY4AQ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 0O_-sGb4wsrg; Mon, 25 Feb 2019 14:48:38 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZZ6Cc2zB09Zn;
	Mon, 25 Feb 2019 14:48:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102518; bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=RBEEY4AQo8xa5HF8qWEOFssZdky5eor7b9BU+Rj0jA3o5vwVLekQ/PxsPPrz0Y1gg
	 x7u2B52szmMVmuaPqQa/owp9xkb1wHv4FbQm/jS2BG1qmOCKAWt9zLxj8OP5vGEOEK
	 ow9cKNzwQc1Mxpphhj6M+vvuq8DfiXNoXUFKYtGQ=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2A5858B81D;
	Mon, 25 Feb 2019 14:48:43 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id E5-LlNlcuG2j; Mon, 25 Feb 2019 14:48:43 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id E48F58B844;
	Mon, 25 Feb 2019 14:48:42 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 7B65D6F20E; Mon, 25 Feb 2019 13:48:43 +0000 (UTC)
Message-Id: <c97af10bb56d7e6871c56ead3773a954320da205.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 08/11] powerpc: disable KASAN instrumentation on
 early/critical files.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All files containing functions run before kasan_early_init() is called
must have KASAN instrumentation disabled.

For those file, branch profiling also have to be disabled otherwise
each if () generates a call to ftrace_likely_update().

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile             | 12 ++++++++++++
 arch/powerpc/lib/Makefile                |  8 ++++++++
 arch/powerpc/mm/Makefile                 |  6 ++++++
 arch/powerpc/platforms/powermac/Makefile |  6 ++++++
 arch/powerpc/purgatory/Makefile          |  3 +++
 arch/powerpc/xmon/Makefile               |  1 +
 6 files changed, 36 insertions(+)

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 45e47752b692..0ea6c4aa3a20 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -31,6 +31,18 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
 endif
 
+KASAN_SANITIZE_early_32.o := n
+KASAN_SANITIZE_cputable.o := n
+KASAN_SANITIZE_prom_init.o := n
+KASAN_SANITIZE_btext.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_cputable.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_prom_init.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_btext.o += -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y				:= cputable.o ptrace.o syscalls.o \
 				   irq.o align.o signal_32.o pmc.o vdso.o \
 				   process.o systbl.o idle.o \
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index 47a4de434c22..c55f9c27bf79 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_code-patching.o := n
+KASAN_SANITIZE_feature-fixups.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y += alloc.o code-patching.o feature-fixups.o
 
 ifndef CONFIG_KASAN
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index d52ec118e09d..240d73dce6bb 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -7,6 +7,12 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 
 CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_ppc_mmu_32.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_ppc_mmu_32.o  		+= -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y				:= fault.o mem.o pgtable.o mmap.o \
 				   init_$(BITS).o pgtable_$(BITS).o \
 				   init-common.o mmu_context.o drmem.o
diff --git a/arch/powerpc/platforms/powermac/Makefile b/arch/powerpc/platforms/powermac/Makefile
index 923bfb340433..859efbacdf06 100644
--- a/arch/powerpc/platforms/powermac/Makefile
+++ b/arch/powerpc/platforms/powermac/Makefile
@@ -2,6 +2,12 @@
 CFLAGS_bootx_init.o  		+= -fPIC
 CFLAGS_bootx_init.o  		+= $(call cc-option, -fno-stack-protector)
 
+KASAN_SANITIZE_bootx_init.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_bootx_init.o  		+= -DDISABLE_BRANCH_PROFILING
+endif
+
 ifdef CONFIG_FUNCTION_TRACER
 # Do not trace early boot code
 CFLAGS_REMOVE_bootx_init.o = $(CC_FLAGS_FTRACE)
diff --git a/arch/powerpc/purgatory/Makefile b/arch/powerpc/purgatory/Makefile
index 4314ba5baf43..7c6d8b14f440 100644
--- a/arch/powerpc/purgatory/Makefile
+++ b/arch/powerpc/purgatory/Makefile
@@ -1,4 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
+
+KASAN_SANITIZE := n
+
 targets += trampoline.o purgatory.ro kexec-purgatory.c
 
 LDFLAGS_purgatory.ro := -e purgatory_start -r --no-undefined
diff --git a/arch/powerpc/xmon/Makefile b/arch/powerpc/xmon/Makefile
index 3050f9323254..f142570ad860 100644
--- a/arch/powerpc/xmon/Makefile
+++ b/arch/powerpc/xmon/Makefile
@@ -7,6 +7,7 @@ subdir-ccflags-y := $(call cc-disable-warning, builtin-requires-header)
 GCOV_PROFILE := n
 KCOV_INSTRUMENT := n
 UBSAN_SANITIZE := n
+KASAN_SANITIZE := n
 
 # Disable ftrace for the entire directory
 ORIG_CFLAGS := $(KBUILD_CFLAGS)
-- 
2.13.3

