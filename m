Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3657F6B0258
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:37 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so57955097pac.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id w77si154136pfi.227.2015.12.10.19.20.36
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:36 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 5/5] x86/vdso: Enable vdso pvclock access on all vdso variants
Date: Thu, 10 Dec 2015 19:20:22 -0800
Message-Id: <a7ef693b7a4c88dd2173dc1d4bf6bc27023626eb.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

Now that pvclock doesn't require access to the fixmap, all vdso
variants can use it.

The kernel side isn't wired up for 32-bit kernels yet, but this
covers 32-bit and x32 userspace on 64-bit kernels.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vclock_gettime.c | 91 ++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 51 deletions(-)

diff --git a/arch/x86/entry/vdso/vclock_gettime.c b/arch/x86/entry/vdso/vclock_gettime.c
index 59a98c25bde7..8602f06c759f 100644
--- a/arch/x86/entry/vdso/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vclock_gettime.c
@@ -17,8 +17,10 @@
 #include <asm/vvar.h>
 #include <asm/unistd.h>
 #include <asm/msr.h>
+#include <asm/pvclock.h>
 #include <linux/math64.h>
 #include <linux/time.h>
+#include <linux/kernel.h>
 
 #define gtod (&VVAR(vsyscall_gtod_data))
 
@@ -43,10 +45,6 @@ extern u8 pvclock_page
 
 #ifndef BUILD_VDSO32
 
-#include <linux/kernel.h>
-#include <asm/vsyscall.h>
-#include <asm/pvclock.h>
-
 notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
 {
 	long ret;
@@ -64,8 +62,42 @@ notrace static long vdso_fallback_gtod(struct timeval *tv, struct timezone *tz)
 	return ret;
 }
 
-#ifdef CONFIG_PARAVIRT_CLOCK
 
+#else
+
+notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
+{
+	long ret;
+
+	asm(
+		"mov %%ebx, %%edx \n"
+		"mov %2, %%ebx \n"
+		"call __kernel_vsyscall \n"
+		"mov %%edx, %%ebx \n"
+		: "=a" (ret)
+		: "0" (__NR_clock_gettime), "g" (clock), "c" (ts)
+		: "memory", "edx");
+	return ret;
+}
+
+notrace static long vdso_fallback_gtod(struct timeval *tv, struct timezone *tz)
+{
+	long ret;
+
+	asm(
+		"mov %%ebx, %%edx \n"
+		"mov %2, %%ebx \n"
+		"call __kernel_vsyscall \n"
+		"mov %%edx, %%ebx \n"
+		: "=a" (ret)
+		: "0" (__NR_gettimeofday), "g" (tv), "c" (tz)
+		: "memory", "edx");
+	return ret;
+}
+
+#endif
+
+#ifdef CONFIG_PARAVIRT_CLOCK
 static notrace const struct pvclock_vsyscall_time_info *get_pvti0(void)
 {
 	return (const struct pvclock_vsyscall_time_info *)&pvclock_page;
@@ -109,9 +141,9 @@ static notrace cycle_t vread_pvclock(int *mode)
 	do {
 		version = pvti->version;
 
-		/* This is also a read barrier, so we'll read version first. */
-		tsc = rdtsc_ordered();
+		smp_rmb();
 
+		tsc = rdtsc_ordered();
 		pvti_tsc_to_system_mul = pvti->tsc_to_system_mul;
 		pvti_tsc_shift = pvti->tsc_shift;
 		pvti_system_time = pvti->system_time;
@@ -126,7 +158,7 @@ static notrace cycle_t vread_pvclock(int *mode)
 		pvclock_scale_delta(delta, pvti_tsc_to_system_mul,
 				    pvti_tsc_shift);
 
-	/* refer to tsc.c read_tsc() comment for rationale */
+	/* refer to vread_tsc() comment for rationale */
 	last = gtod->cycle_last;
 
 	if (likely(ret >= last))
@@ -136,49 +168,6 @@ static notrace cycle_t vread_pvclock(int *mode)
 }
 #endif
 
-#else
-
-notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
-{
-	long ret;
-
-	asm(
-		"mov %%ebx, %%edx \n"
-		"mov %2, %%ebx \n"
-		"call __kernel_vsyscall \n"
-		"mov %%edx, %%ebx \n"
-		: "=a" (ret)
-		: "0" (__NR_clock_gettime), "g" (clock), "c" (ts)
-		: "memory", "edx");
-	return ret;
-}
-
-notrace static long vdso_fallback_gtod(struct timeval *tv, struct timezone *tz)
-{
-	long ret;
-
-	asm(
-		"mov %%ebx, %%edx \n"
-		"mov %2, %%ebx \n"
-		"call __kernel_vsyscall \n"
-		"mov %%edx, %%ebx \n"
-		: "=a" (ret)
-		: "0" (__NR_gettimeofday), "g" (tv), "c" (tz)
-		: "memory", "edx");
-	return ret;
-}
-
-#ifdef CONFIG_PARAVIRT_CLOCK
-
-static notrace cycle_t vread_pvclock(int *mode)
-{
-	*mode = VCLOCK_NONE;
-	return 0;
-}
-#endif
-
-#endif
-
 notrace static cycle_t vread_tsc(void)
 {
 	cycle_t ret = (cycle_t)rdtsc_ordered();
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
