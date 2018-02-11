Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAC46B0009
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 23:34:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t6so1605206wrc.12
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 20:34:30 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id 133si1837857wmr.230.2018.02.10.20.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 20:34:29 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 11 Feb 2018 04:31:11 +0000
Message-ID: <lsq.1518323471.680710138@decadent.org.uk>
Subject: [PATCH 3.16 134/136] x86/vdso: Remove pvclock fixmap machinery
In-Reply-To: <lsq.1518323469.348919605@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, Andy Lutomirski <luto@amacapital.net>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org

3.16.54-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit cc1e24fdb064d3126a494716f22ad4fc39306742 upstream.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/4933029991103ae44672c82b97a20035f5c1fe4f.1449702533.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
[bwh: Backported to 3.16: adjust filenames, context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/fixmap.h  |  5 -----
 arch/x86/include/asm/pvclock.h |  5 -----
 arch/x86/kernel/kvmclock.c     |  6 ------
 arch/x86/kernel/pvclock.c      | 24 ------------------------
 arch/x86/vdso/vclock_gettime.c |  1 -
 arch/x86/vdso/vma.c            |  1 +
 6 files changed, 1 insertion(+), 41 deletions(-)

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
@@ -70,10 +69,6 @@ enum fixed_addresses {
 	FIX_HOLE,
 #else
 	VSYSCALL_PAGE = (FIXADDR_TOP - VSYSCALL_ADDR) >> PAGE_SHIFT,
-#ifdef CONFIG_PARAVIRT_CLOCK
-	PVCLOCK_FIXMAP_BEGIN,
-	PVCLOCK_FIXMAP_END = PVCLOCK_FIXMAP_BEGIN+PVCLOCK_VSYSCALL_NR_PAGES-1,
-#endif
 #endif
 	FIX_DBGP_BASE,
 	FIX_EARLYCON_MEM_BASE,
--- a/arch/x86/include/asm/pvclock.h
+++ b/arch/x86/include/asm/pvclock.h
@@ -107,10 +107,5 @@ struct pvclock_vsyscall_time_info {
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 #define PVTI_SIZE sizeof(struct pvclock_vsyscall_time_info)
-#define PVCLOCK_VSYSCALL_NR_PAGES (((NR_CPUS-1)/(PAGE_SIZE/PVTI_SIZE))+1)
-
-int __init pvclock_init_vsyscall(struct pvclock_vsyscall_time_info *i,
-				 int size);
-struct pvclock_vcpu_time_info *pvclock_get_vsyscall_time_info(int cpu);
 
 #endif /* _ASM_X86_PVCLOCK_H */
--- a/arch/x86/kernel/kvmclock.c
+++ b/arch/x86/kernel/kvmclock.c
@@ -278,7 +278,6 @@ int __init kvm_setup_vsyscall_timeinfo(v
 {
 #ifdef CONFIG_X86_64
 	int cpu;
-	int ret;
 	u8 flags;
 	struct pvclock_vcpu_time_info *vcpu_time;
 	unsigned int size;
@@ -299,11 +298,6 @@ int __init kvm_setup_vsyscall_timeinfo(v
 		return 1;
 	}
 
-	if ((ret = pvclock_init_vsyscall(hv_clock, size))) {
-		preempt_enable();
-		return ret;
-	}
-
 	preempt_enable();
 
 	kvm_clock.archdata.vclock_mode = VCLOCK_PVCLOCK;
--- a/arch/x86/kernel/pvclock.c
+++ b/arch/x86/kernel/pvclock.c
@@ -140,27 +140,3 @@ void pvclock_read_wallclock(struct pvclo
 
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
--- a/arch/x86/vdso/vclock_gettime.c
+++ b/arch/x86/vdso/vclock_gettime.c
@@ -45,7 +45,6 @@ extern u8 pvclock_page
 
 #include <linux/kernel.h>
 #include <asm/vsyscall.h>
-#include <asm/fixmap.h>
 #include <asm/pvclock.h>
 
 notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -11,6 +11,7 @@
 #include <linux/random.h>
 #include <linux/elf.h>
 #include <asm/vsyscall.h>
+#include <asm/pvclock.h>
 #include <asm/vgtod.h>
 #include <asm/proto.h>
 #include <asm/vdso.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
