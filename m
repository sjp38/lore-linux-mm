Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 17DEE6B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:32 -0500 (EST)
Received: by padhk6 with SMTP id hk6so17768769pad.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:31 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id q62si283584pfq.5.2015.12.10.19.20.31
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:31 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 2/5] x86, vdso, pvclock: Simplify and speed up the vdso pvclock reader
Date: Thu, 10 Dec 2015 19:20:19 -0800
Message-Id: <6b51dcc41f1b101f963945c5ec7093d72bdac429.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

From: Andy Lutomirski <luto@amacapital.net>

The pvclock vdso code was too abstracted to understand easily and
excessively paranoid.  Simplify it for a huge speedup.

This opens the door for additional simplifications, as the vdso no
longer accesses the pvti for any vcpu other than vcpu 0.

Before, vclock_gettime using kvm-clock took about 45ns on my machine.
With this change, it takes 29ns, which is almost as fast as the pure TSC
implementation.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/entry/vdso/vclock_gettime.c | 81 ++++++++++++++++++++----------------
 1 file changed, 46 insertions(+), 35 deletions(-)

diff --git a/arch/x86/entry/vdso/vclock_gettime.c b/arch/x86/entry/vdso/vclock_gettime.c
index ca94fa649251..c325ba1bdddf 100644
--- a/arch/x86/entry/vdso/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vclock_gettime.c
@@ -78,47 +78,58 @@ static notrace const struct pvclock_vsyscall_time_info *get_pvti(int cpu)
 
 static notrace cycle_t vread_pvclock(int *mode)
 {
-	const struct pvclock_vsyscall_time_info *pvti;
+	const struct pvclock_vcpu_time_info *pvti = &get_pvti(0)->pvti;
 	cycle_t ret;
-	u64 last;
-	u32 version;
-	u8 flags;
-	unsigned cpu, cpu1;
-
+	u64 tsc, pvti_tsc;
+	u64 last, delta, pvti_system_time;
+	u32 version, pvti_tsc_to_system_mul, pvti_tsc_shift;
 
 	/*
-	 * Note: hypervisor must guarantee that:
-	 * 1. cpu ID number maps 1:1 to per-CPU pvclock time info.
-	 * 2. that per-CPU pvclock time info is updated if the
-	 *    underlying CPU changes.
-	 * 3. that version is increased whenever underlying CPU
-	 *    changes.
+	 * Note: The kernel and hypervisor must guarantee that cpu ID
+	 * number maps 1:1 to per-CPU pvclock time info.
+	 *
+	 * Because the hypervisor is entirely unaware of guest userspace
+	 * preemption, it cannot guarantee that per-CPU pvclock time
+	 * info is updated if the underlying CPU changes or that that
+	 * version is increased whenever underlying CPU changes.
 	 *
+	 * On KVM, we are guaranteed that pvti updates for any vCPU are
+	 * atomic as seen by *all* vCPUs.  This is an even stronger
+	 * guarantee than we get with a normal seqlock.
+	 *
+	 * On Xen, we don't appear to have that guarantee, but Xen still
+	 * supplies a valid seqlock using the version field.
+
+	 * We only do pvclock vdso timing at all if
+	 * PVCLOCK_TSC_STABLE_BIT is set, and we interpret that bit to
+	 * mean that all vCPUs have matching pvti and that the TSC is
+	 * synced, so we can just look at vCPU 0's pvti.
 	 */
-	do {
-		cpu = __getcpu() & VGETCPU_CPU_MASK;
-		/* TODO: We can put vcpu id into higher bits of pvti.version.
-		 * This will save a couple of cycles by getting rid of
-		 * __getcpu() calls (Gleb).
-		 */
-
-		pvti = get_pvti(cpu);
-
-		version = __pvclock_read_cycles(&pvti->pvti, &ret, &flags);
-
-		/*
-		 * Test we're still on the cpu as well as the version.
-		 * We could have been migrated just after the first
-		 * vgetcpu but before fetching the version, so we
-		 * wouldn't notice a version change.
-		 */
-		cpu1 = __getcpu() & VGETCPU_CPU_MASK;
-	} while (unlikely(cpu != cpu1 ||
-			  (pvti->pvti.version & 1) ||
-			  pvti->pvti.version != version));
-
-	if (unlikely(!(flags & PVCLOCK_TSC_STABLE_BIT)))
+
+	if (unlikely(!(pvti->flags & PVCLOCK_TSC_STABLE_BIT))) {
 		*mode = VCLOCK_NONE;
+		return 0;
+	}
+
+	do {
+		version = pvti->version;
+
+		/* This is also a read barrier, so we'll read version first. */
+		tsc = rdtsc_ordered();
+
+		pvti_tsc_to_system_mul = pvti->tsc_to_system_mul;
+		pvti_tsc_shift = pvti->tsc_shift;
+		pvti_system_time = pvti->system_time;
+		pvti_tsc = pvti->tsc_timestamp;
+
+		/* Make sure that the version double-check is last. */
+		smp_rmb();
+	} while (unlikely((version & 1) || version != pvti->version));
+
+	delta = tsc - pvti_tsc;
+	ret = pvti_system_time +
+		pvclock_scale_delta(delta, pvti_tsc_to_system_mul,
+				    pvti_tsc_shift);
 
 	/* refer to tsc.c read_tsc() comment for rationale */
 	last = gtod->cycle_last;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
