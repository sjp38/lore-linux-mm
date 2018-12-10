Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46F4B8E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:36:20 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id p131so6326299oig.10
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:36:20 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q25si3886102ota.70.2018.12.10.05.36.18
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 05:36:18 -0800 (PST)
Date: Mon, 10 Dec 2018 13:36:40 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V5 5/7] arm64: mm: Prevent mismatched 52-bit VA support
Message-ID: <20181210133640.GA31425@edgewater-inn.cambridge.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-6-steve.capper@arm.com>
 <81860712-ff5f-5a51-d39e-9db9e3d31a26@arm.com>
 <20181207152529.GB2682@edgewater-inn.cambridge.arm.com>
 <be06b735-c6b4-1520-73f6-02a3a8e8af45@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be06b735-c6b4-1520-73f6-02a3a8e8af45@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <suzuki.poulose@arm.com>
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com

On Fri, Dec 07, 2018 at 05:28:58PM +0000, Suzuki K Poulose wrote:
> 
> 
> On 07/12/2018 15:26, Will Deacon wrote:
> > On Fri, Dec 07, 2018 at 10:47:57AM +0000, Suzuki K Poulose wrote:
> > > On 12/06/2018 10:50 PM, Steve Capper wrote:
> > > > diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
> > > > index f60081be9a1b..58fcc1edd852 100644
> > > > --- a/arch/arm64/kernel/head.S
> > > > +++ b/arch/arm64/kernel/head.S
> > > > @@ -707,6 +707,7 @@ secondary_startup:
> > > >    	/*
> > > >    	 * Common entry point for secondary CPUs.
> > > >    	 */
> > > > +	bl	__cpu_secondary_check52bitva
> > > >    	bl	__cpu_setup			// initialise processor
> > > >    	adrp	x1, swapper_pg_dir
> > > >    	bl	__enable_mmu
> > > > @@ -785,6 +786,31 @@ ENTRY(__enable_mmu)
> > > >    	ret
> > > >    ENDPROC(__enable_mmu)
> > > > +ENTRY(__cpu_secondary_check52bitva)
> > > > +#ifdef CONFIG_ARM64_52BIT_VA
> > > > +	ldr_l	x0, vabits_user
> > > > +	cmp	x0, #52
> > > > +	b.ne	2f > +
> > > > +	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
> > > > +	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
> > > > +	cbnz	x0, 2f
> > > > +
> > > > +	adr_l	x0, va52mismatch
> > > > +	mov	w1, #1
> > > > +	strb	w1, [x0]
> > > > +	dmb	sy
> > > > +	dc	ivac, x0	// Invalidate potentially stale cache line
> > > 
> > > You may have to clear this variable before a CPU is brought up to avoid
> > > raising a false error message when another secondary CPU doesn't boot
> > > for some other reason (say granule support) after a CPU failed with lack
> > > of 52bitva. It is really a crazy corner case.
> > 
> > Can't we just follow the example set by the EL2 setup in the way that is
> > uses __boot_cpu_mode? In that case, we only need one variable and you can
> > detect a problem by comparing the two halves.
> 
> The only difference here is, the support is bolted at boot CPU time and hence
> we need to verify each and every CPU, unlike the __boot_cpu_mode where we
> check for mismatch after the SMP CPUs are brought up. If we decide to make
> the choice later, something like that could work. The only caveat is the 52bit
> kernel VA will have to do something like the above.

So looking at this a bit more, I think we're better off repurposing the
upper bits of the early boot status word to contain a reason code, rather
than introducing new variables for every possible mismatch.

Does the untested diff below look remotely sane to you?

Will

--->8

diff --git a/arch/arm64/include/asm/smp.h b/arch/arm64/include/asm/smp.h
index f82b447bd34f..1895561839a9 100644
--- a/arch/arm64/include/asm/smp.h
+++ b/arch/arm64/include/asm/smp.h
@@ -17,15 +17,20 @@
 #define __ASM_SMP_H
 
 /* Values for secondary_data.status */
+#define CPU_STUCK_REASON_SHIFT		(8)
+#define CPU_BOOT_STATUS_MASK		((1U << CPU_STUCK_REASON_SHIFT) - 1)
 
-#define CPU_MMU_OFF		(-1)
-#define CPU_BOOT_SUCCESS	(0)
+#define CPU_MMU_OFF			(-1)
+#define CPU_BOOT_SUCCESS		(0)
 /* The cpu invoked ops->cpu_die, synchronise it with cpu_kill */
-#define CPU_KILL_ME		(1)
+#define CPU_KILL_ME			(1)
 /* The cpu couldn't die gracefully and is looping in the kernel */
-#define CPU_STUCK_IN_KERNEL	(2)
+#define CPU_STUCK_IN_KERNEL		(2)
 /* Fatal system error detected by secondary CPU, crash the system */
-#define CPU_PANIC_KERNEL	(3)
+#define CPU_PANIC_KERNEL		(3)
+
+#define CPU_STUCK_REASON_52_BIT_VA	(1U << CPU_STUCK_REASON_SHIFT)
+#define CPU_STUCK_REASON_NO_GRAN	(2U << CPU_STUCK_REASON_SHIFT)
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index c229d9cfe9bf..7377e14884e3 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -809,13 +809,8 @@ ENTRY(__cpu_secondary_check52bitva)
 	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
 	cbnz	x0, 2f
 
-	adr_l	x0, va52mismatch
-	mov	w1, #1
-	strb	w1, [x0]
-	dmb	sy
-	dc	ivac, x0	// Invalidate potentially stale cache line
-
-	update_early_cpu_boot_status CPU_STUCK_IN_KERNEL, x0, x1
+	update_early_cpu_boot_status \
+		CPU_STUCK_IN_KERNEL | CPU_STUCK_REASON_52_BIT_VA, x0, x1
 1:	wfe
 	wfi
 	b	1b
@@ -826,7 +821,8 @@ ENDPROC(__cpu_secondary_check52bitva)
 
 __no_granule_support:
 	/* Indicate that this CPU can't boot and is stuck in the kernel */
-	update_early_cpu_boot_status CPU_STUCK_IN_KERNEL, x1, x2
+	update_early_cpu_boot_status \
+		CPU_STUCK_IN_KERNEL | CPU_STUCK_REASON_NO_GRAN, x1, x2
 1:
 	wfe
 	wfi
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index e15b0b64d4d0..4e3bfbde829a 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -108,7 +108,6 @@ static int boot_secondary(unsigned int cpu, struct task_struct *idle)
 }
 
 static DECLARE_COMPLETION(cpu_running);
-bool va52mismatch __ro_after_init;
 
 int __cpu_up(unsigned int cpu, struct task_struct *idle)
 {
@@ -138,10 +137,6 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 
 		if (!cpu_online(cpu)) {
 			pr_crit("CPU%u: failed to come online\n", cpu);
-
-			if (IS_ENABLED(CONFIG_ARM64_52BIT_VA) && va52mismatch)
-				pr_crit("CPU%u: does not support 52-bit VAs\n", cpu);
-
 			ret = -EIO;
 		}
 	} else {
@@ -156,7 +151,7 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 		if (status == CPU_MMU_OFF)
 			status = READ_ONCE(__early_cpu_boot_status);
 
-		switch (status) {
+		switch (status & CPU_BOOT_STATUS_MASK) {
 		default:
 			pr_err("CPU%u: failed in unknown state : 0x%lx\n",
 					cpu, status);
@@ -170,6 +165,10 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 			pr_crit("CPU%u: may not have shut down cleanly\n", cpu);
 		case CPU_STUCK_IN_KERNEL:
 			pr_crit("CPU%u: is stuck in kernel\n", cpu);
+			if (status & CPU_STUCK_REASON_52_BIT_VA)
+				pr_crit("CPU%u: does not support 52-bit VAs\n", cpu);
+			if (status & CPU_STUCK_REASON_NO_GRAN)
+				pr_crit("CPU%u: does not support %luK granule \n", cpu, PAGE_SIZE / SZ_1K);
 			cpus_stuck_in_kernel++;
 			break;
 		case CPU_PANIC_KERNEL:
