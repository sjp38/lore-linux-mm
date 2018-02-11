Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4936B0007
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 23:34:19 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w10so7016806wrg.2
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 20:34:19 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id q127si1896413wma.6.2018.02.10.20.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 20:34:18 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 11 Feb 2018 04:31:11 +0000
Message-ID: <lsq.1518323471.513508387@decadent.org.uk>
Subject: [PATCH 3.16 130/136] x86, vdso, pvclock: Simplify and speed up
 the vdso pvclock reader
In-Reply-To: <lsq.1518323469.348919605@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Brian Gerst <brgerst@gmail.com>

3.16.54-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@amacapital.net>

commit 6b078f5de7fc0851af4102493c7b5bb07e49c4cb upstream.

The pvclock vdso code was too abstracted to understand easily
and excessively paranoid.  Simplify it for a huge speedup.

This opens the door for additional simplifications, as the vdso
no longer accesses the pvti for any vcpu other than vcpu 0.

Before, vclock_gettime using kvm-clock took about 45ns on my
machine. With this change, it takes 29ns, which is almost as
fast as the pure TSC implementation.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/6b51dcc41f1b101f963945c5ec7093d72bdac429.1449702533.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
[bwh: Backported to 3.16:
 - Open-code rdtsc_ordered()
 - Adjust filename]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/arch/x86/vdso/vclock_gettime.c
+++ b/arch/x86/vdso/vclock_gettime.c
@@ -78,47 +78,59 @@ static notrace const struct pvclock_vsys
 
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
 
-	if (unlikely(!(flags & PVCLOCK_TSC_STABLE_BIT)))
+	if (unlikely(!(pvti->flags & PVCLOCK_TSC_STABLE_BIT))) {
 		*mode = VCLOCK_NONE;
+		return 0;
+	}
+
+	do {
+		version = pvti->version;
+
+		/* This is also a read barrier, so we'll read version first. */
+		rdtsc_barrier();
+		tsc = __native_read_tsc();
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
