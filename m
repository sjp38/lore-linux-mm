Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 064A46B000C
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 09:14:09 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id h61-v6so8649002pld.3
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 06:14:08 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id p15si6448739pgn.17.2018.03.18.06.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 06:14:07 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 3/7] Disable instrumentation for some code
Date: Sun, 18 Mar 2018 20:53:38 +0800
Message-ID: <20180318125342.4278-4-liuwenliang@huawei.com>
In-Reply-To: <20180318125342.4278-1-liuwenliang@huawei.com>
References: <20180318125342.4278-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, marc.zyngier@arm.com, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, liuwenliang@huawei.com, akpm@linux-foundation.org, afzal.mohd.ma@gmail.com, alexander.levin@verizon.com
Cc: glider@google.com, dvyukov@google.com, christoffer.dall@linaro.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

From: Andrey Ryabinin <a.ryabinin@samsung.com>

Disable instrumentation for arch/arm/boot/compressed/*
and arch/arm/vdso/* because those code won't linkd with
kernel image.

Disable kasan check in the function unwind_pop_register
because it doesn't matter that kasan checks failed when
unwind_pop_register read stack memory of task.

Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
---
 arch/arm/boot/compressed/Makefile | 1 +
 arch/arm/kernel/unwind.c          | 3 ++-
 arch/arm/vdso/Makefile            | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/compressed/Makefile b/arch/arm/boot/compressed/Makefile
index 45a6b9b..966103e 100644
--- a/arch/arm/boot/compressed/Makefile
+++ b/arch/arm/boot/compressed/Makefile
@@ -24,6 +24,7 @@ OBJS		+= hyp-stub.o
 endif
 
 GCOV_PROFILE		:= n
+KASAN_SANITIZE		:= n
 
 #
 # Architecture dependencies
diff --git a/arch/arm/kernel/unwind.c b/arch/arm/kernel/unwind.c
index 0bee233..2e55c7d 100644
--- a/arch/arm/kernel/unwind.c
+++ b/arch/arm/kernel/unwind.c
@@ -249,7 +249,8 @@ static int unwind_pop_register(struct unwind_ctrl_block *ctrl,
 		if (*vsp >= (unsigned long *)ctrl->sp_high)
 			return -URC_FAILURE;
 
-	ctrl->vrs[reg] = *(*vsp)++;
+	ctrl->vrs[reg] = READ_ONCE_NOCHECK(*(*vsp));
+	(*vsp)++;
 	return URC_OK;
 }
 
diff --git a/arch/arm/vdso/Makefile b/arch/arm/vdso/Makefile
index bb411821..87abbb7 100644
--- a/arch/arm/vdso/Makefile
+++ b/arch/arm/vdso/Makefile
@@ -30,6 +30,8 @@ CFLAGS_vgettimeofday.o = -O2
 # Disable gcov profiling for VDSO code
 GCOV_PROFILE := n
 
+KASAN_SANITIZE := n
+
 # Force dependency
 $(obj)/vdso.o : $(obj)/vdso.so
 
-- 
2.9.0
