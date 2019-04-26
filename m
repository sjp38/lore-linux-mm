Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AADF9C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5341F206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="UzbSN/j3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5341F206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D4146B0266; Fri, 26 Apr 2019 12:23:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 234776B0269; Fri, 26 Apr 2019 12:23:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D9036B026A; Fri, 26 Apr 2019 12:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACD876B0266
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:35 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r7so3872210wrc.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=dvP5lscCIxFwTXSbK56B3yN5nYgunJPxd72/nngukmk=;
        b=tTdQ/6n42Z+sY+ay8r/kF4w3WuT+Evemjpy8AzM+LxrLTyVZruUzgRFXKsVbzwDqgq
         mDOPvPAc6MoUneRakPeibsP7z9fGU4fI/ZsAl9HcRbYh63+Sk+7JueCGw3Y3p2uPf4wZ
         gqiiS5WZHRYUHWyylntbVhFBQTX6nUI/tUp1poPBux1km+wsEtZMM7fa412lNZJQV8So
         ZTzneOSH9tfqmaLLvXIXUoFeZlQKs7QeZ1vwk2RDjyKXX8mRw8ElE8xu/8Lc9CvBasGC
         GbkGRfnOWH3d3KhTsM428KZy6kkKCTCQ/s/KRmnvtXDLr95EzZ/1aObeudobFP5PfdgC
         AvnA==
X-Gm-Message-State: APjAAAUMODKl1F8WuGS1bsUmDtfsg5L6onA1c5uaQ5Em8iVvmRlrV1nm
	IL+ZhDiOqVkUqwwxPNA3Ifl/MwxQ1EMfxVWrwsmpj/tYxkNXle3AKj4q+h+7hgGzsMSJrwG2E1/
	+SB6LW5R5HNBuduvlmbdlrZv//RaaHkBEqW9muGBNBAOaZtw29ibAXp3YltEVjueGoQ==
X-Received: by 2002:a1c:2348:: with SMTP id j69mr8467528wmj.35.1556295815210;
        Fri, 26 Apr 2019 09:23:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZn9SNwvkTBS+kDnrt1LTkFH5sI8RaRj6hkYiPKGyoJoQmJQLAYHaQCBl3Bvx5IS1cQIJ7
X-Received: by 2002:a1c:2348:: with SMTP id j69mr8467462wmj.35.1556295814285;
        Fri, 26 Apr 2019 09:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295814; cv=none;
        d=google.com; s=arc-20160816;
        b=olnsYvEfZabHLhP/z9Uh/VOzOach86Comk7d6bKPlOIuqND/7NNqWIkNPHHNj8qS7P
         zp8P/ADZ9P585OX6hSdVAYwto6foYFosqFojV2yvIt9nRsqbvVcCz/ILVZsnM5ET9UTR
         t7eB+o6CHa6+2+IMOAonDmMS+zFuRZA45MKpeOrrDfKb18pz2hVITiKHJb9qKYcUWXH8
         QX8XBWVsyspJR3uktmuk1OZNaVvejKBScsyi3bTOkmk2MbVFVsJMVeo2pEUiI+YLfgXe
         XQQLbGMEQzbQkpydfVF7BE1ZsMs2sjczpMcX1v/4JOk0SVpsL//FiGz28Zs4HTTXO1mh
         u9tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=dvP5lscCIxFwTXSbK56B3yN5nYgunJPxd72/nngukmk=;
        b=vNRO+ojEQfUoKtjD37KD5XRMHCEOB7xS+YD8KPHB6krlhFxl0ZyuZIofzG7mvDVZJE
         YziKY3hWt6oxO+vLI0qrape6g60i0hdxgzwwTuZSe85PvsgqIXrvEnvdOadpAUh9fqpd
         Py0C+6hzFw6Z0rghEzMC9GpVU7ON7HZlgTazXfQGEEJt4VFU5poHj+ky/UhG46KCh/k/
         U+wEKoFA4b9gdt7XoO4qHTkVmEzMa9IayovaDgAhjROWSihvys9E9L68r+KbY/jnPHZ3
         5iflHTJiyb34SAnT+zCqTwUKQZ5AuBm3+Zv7x2+J6yCzyZz2O5h9j9hBm+SMe+xnCQ9L
         34Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="UzbSN/j3";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id w14si18878017wrn.86.2019.04.26.09.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="UzbSN/j3";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9c1qRnz9v17y;
	Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=UzbSN/j3; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id UiLTnpFPBoW8; Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9c0nygz9v17t;
	Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295812; bh=dvP5lscCIxFwTXSbK56B3yN5nYgunJPxd72/nngukmk=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=UzbSN/j3XEFTsXbDYbDzOxM3qWKxVfblTu35QR9HTyXiuJl55VlRhResCsuaDd1vc
	 mofDQSHpRqyA6HDPp8w/aZGp3AWcVDbm1VytkJ6xpc2dLn9HNaH8e78gGu4m0jjWjr
	 nWs9JVzUZjo2lhrlKGVjbf6gJggsrp9hQOeT3lKI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C311A8B950;
	Fri, 26 Apr 2019 18:23:33 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id T2F1HCAiiGVx; Fri, 26 Apr 2019 18:23:33 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 96A4D8B82F;
	Fri, 26 Apr 2019 18:23:33 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 82E0C666FE; Fri, 26 Apr 2019 16:23:33 +0000 (UTC)
Message-Id: <867c149e77f80e855a9310a490fb15ca03ffd63d.1556295461.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 09/13] powerpc: disable KASAN instrumentation on
 early/critical files.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:33 +0000 (UTC)
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
index 3c1bd9fa23cd..dd945ca869b2 100644
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
index 20ebf35d7913..f4247ade71ca 100644
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

