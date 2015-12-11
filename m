Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C24BC6B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:35 -0500 (EST)
Received: by pfbu66 with SMTP id u66so14675185pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:35 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id pv3si284068pac.61.2015.12.10.19.20.34
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:35 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 4/5] x86/vdso: Remove pvclock fixmap machinery
Date: Thu, 10 Dec 2015 19:20:21 -0800
Message-Id: <4933029991103ae44672c82b97a20035f5c1fe4f.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vclock_gettime.c |  1 -
 arch/x86/entry/vdso/vma.c            |  1 +
 arch/x86/include/asm/fixmap.h        |  5 -----
 arch/x86/include/asm/pvclock.h       |  5 -----
 arch/x86/kernel/kvmclock.c           |  6 ------
 arch/x86/kernel/pvclock.c            | 24 ------------------------
 6 files changed, 1 insertion(+), 41 deletions(-)

diff --git a/arch/x86/entry/vdso/vclock_gettime.c b/arch/x86/entry/vdso/vclock_gettime.c
index 5dd363d54348..59a98c25bde7 100644
--- a/arch/x86/entry/vdso/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vclock_gettime.c
@@ -45,7 +45,6 @@ extern u8 pvclock_page
 
 #include <linux/kernel.h>
 #include <asm/vsyscall.h>
-#include <asm/fixmap.h>
 #include <asm/pvclock.h>
 
 notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index aa828191c654..b8f69e264ac4 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -12,6 +12,7 @@
 #include <linux/random.h>
 #include <linux/elf.h>
 #include <linux/cpu.h>
+#include <asm/pvclock.h>
 #include <asm/vgtod.h>
 #include <asm/proto.h>
 #include <asm/vdso.h>
diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index f80d70009ff8..6d7d0e52ed5a 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -19,7 +19,6 @@
 #include <asm/acpi.h>
 #include <asm/apicdef.h>
 #include <asm/page.h>
-#include <asm/pvclock.h>
 #ifdef CONFIG_X86_32
 #include <linux/threads.h>
 #include <asm/kmap_types.h>
@@ -72,10 +71,6 @@ enum fixed_addresses {
 #ifdef CONFIG_X86_VSYSCALL_EMULATION
 	VSYSCALL_PAGE = (FIXADDR_TOP - VSYSCALL_ADDR) >> PAGE_SHIFT,
 #endif
-#ifdef CONFIG_PARAVIRT_CLOCK
-	PVCLOCK_FIXMAP_BEGIN,
-	PVCLOCK_FIXMAP_END = PVCLOCK_FIXMAP_BEGIN+PVCLOCK_VSYSCALL_NR_PAGES-1,
-#endif
 #endif
 	FIX_DBGP_BASE,
 	FIX_EARLYCON_MEM_BASE,
diff --git a/arch/x86/include/asm/pvclock.h b/arch/x86/include/asm/pvclock.h
index 3864398c7cb2..66df22b2e0c9 100644
--- a/arch/x86/include/asm/pvclock.h
+++ b/arch/x86/include/asm/pvclock.h
@@ -100,10 +100,5 @@ struct pvclock_vsyscall_time_info {
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 #define PVTI_SIZE sizeof(struct pvclock_vsyscall_time_info)
-#define PVCLOCK_VSYSCALL_NR_PAGES (((NR_CPUS-1)/(PAGE_SIZE/PVTI_SIZE))+1)
-
-int __init pvclock_init_vsyscall(struct pvclock_vsyscall_time_info *i,
-				 int size);
-struct pvclock_vcpu_time_info *pvclock_get_vsyscall_time_info(int cpu);
 
 #endif /* _ASM_X86_PVCLOCK_H */
diff --git a/arch/x86/kernel/kvmclock.c b/arch/x86/kernel/kvmclock.c
index ec1b06dc82d2..72cef58693c7 100644
--- a/arch/x86/kernel/kvmclock.c
+++ b/arch/x86/kernel/kvmclock.c
@@ -310,7 +310,6 @@ int __init kvm_setup_vsyscall_timeinfo(void)
 {
 #ifdef CONFIG_X86_64
 	int cpu;
-	int ret;
 	u8 flags;
 	struct pvclock_vcpu_time_info *vcpu_time;
 	unsigned int size;
@@ -330,11 +329,6 @@ int __init kvm_setup_vsyscall_timeinfo(void)
 		return 1;
 	}
 
-	if ((ret = pvclock_init_vsyscall(hv_clock, size))) {
-		put_cpu();
-		return ret;
-	}
-
 	put_cpu();
 
 	kvm_clock.archdata.vclock_mode = VCLOCK_PVCLOCK;
diff --git a/arch/x86/kernel/pvclock.c b/arch/x86/kernel/pvclock.c
index 2f355d229a58..99bfc025111d 100644
--- a/arch/x86/kernel/pvclock.c
+++ b/arch/x86/kernel/pvclock.c
@@ -140,27 +140,3 @@ void pvclock_read_wallclock(struct pvclock_wall_clock *wall_clock,
 
 	set_normalized_timespec(ts, now.tv_sec, now.tv_nsec);
 }
-
-#ifdef CONFIG_X86_64
-/*
- * Initialize the generic pvclock vsyscall state.  This will allocate
- * a/some page(s) for the per-vcpu pvclock information, set up a
- * fixmap mapping for the page(s)
- */
-
-int __init pvclock_init_vsyscall(struct pvclock_vsyscall_time_info *i,
-				 int size)
-{
-	int idx;
-
-	WARN_ON (size != PVCLOCK_VSYSCALL_NR_PAGES*PAGE_SIZE);
-
-	for (idx = 0; idx <= (PVCLOCK_FIXMAP_END-PVCLOCK_FIXMAP_BEGIN); idx++) {
-		__set_fixmap(PVCLOCK_FIXMAP_BEGIN + idx,
-			     __pa(i) + (idx*PAGE_SIZE),
-			     PAGE_KERNEL_VVAR);
-	}
-
-	return 0;
-}
-#endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
