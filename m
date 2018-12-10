Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF2458E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:07:43 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id t184so6579812oih.22
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:07:43 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p126si4897153oih.133.2018.12.10.10.07.42
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 10:07:42 -0800 (PST)
Date: Mon, 10 Dec 2018 18:07:33 +0000
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Subject: Re: [PATCH V5 5/7] arm64: mm: Prevent mismatched 52-bit VA support
Message-ID: <20181210180733.GA17080@en101>
References: <20181206225042.11548-6-steve.capper@arm.com>
 <81860712-ff5f-5a51-d39e-9db9e3d31a26@arm.com>
 <20181207152529.GB2682@edgewater-inn.cambridge.arm.com>
 <be06b735-c6b4-1520-73f6-02a3a8e8af45@arm.com>
 <20181210133640.GA31425@edgewater-inn.cambridge.arm.com>
 <20181210160348.GA4564@capper-debian.cambridge.arm.com>
 <20181210161826.GA11135@edgewater-inn.cambridge.arm.com>
 <20181210165538.GA26756@capper-debian.cambridge.arm.com>
 <20181210170831.GA28176@capper-debian.cambridge.arm.com>
 <20181210174234.GA24059@capper-debian.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210174234.GA24059@capper-debian.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <Steve.Capper@arm.com>
Cc: Will Deacon <Will.Deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jcm@redhat.com" <jcm@redhat.com>, nd <nd@arm.com>

On Mon, Dec 10, 2018 at 05:42:45PM +0000, Steve Capper wrote:
> On Mon, Dec 10, 2018 at 05:08:31PM +0000, Steve Capper wrote:
> > On Mon, Dec 10, 2018 at 04:55:38PM +0000, Steve Capper wrote:
> > > On Mon, Dec 10, 2018 at 04:18:26PM +0000, Will Deacon wrote:
> > > > On Mon, Dec 10, 2018 at 04:04:02PM +0000, Steve Capper wrote:
> > > > > On Mon, Dec 10, 2018 at 01:36:40PM +0000, Will Deacon wrote:
> > > > > > On Fri, Dec 07, 2018 at 05:28:58PM +0000, Suzuki K Poulose wrote:
> > > > > > > On 07/12/2018 15:26, Will Deacon wrote:
> > > > > > > > On Fri, Dec 07, 2018 at 10:47:57AM +0000, Suzuki K Poulose wrote:
> > > > > > > > > On 12/06/2018 10:50 PM, Steve Capper wrote:
> > > > > > > > > > diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
> > > > > > > > > > index f60081be9a1b..58fcc1edd852 100644
> > > > > > > > > > --- a/arch/arm64/kernel/head.S
> > > > > > > > > > +++ b/arch/arm64/kernel/head.S
> > > > > > > > > > @@ -707,6 +707,7 @@ secondary_startup:
> > > > > > > > > >    	/*
> > > > > > > > > >    	 * Common entry point for secondary CPUs.
> > > > > > > > > >    	 */
> > > > > > > > > > +	bl	__cpu_secondary_check52bitva
> > > > > > > > > >    	bl	__cpu_setup			// initialise processor
> > > > > > > > > >    	adrp	x1, swapper_pg_dir
> > > > > > > > > >    	bl	__enable_mmu
> > > > > > > > > > @@ -785,6 +786,31 @@ ENTRY(__enable_mmu)
> > > > > > > > > >    	ret
> > > > > > > > > >    ENDPROC(__enable_mmu)
> > > > > > > > > > +ENTRY(__cpu_secondary_check52bitva)
> > > > > > > > > > +#ifdef CONFIG_ARM64_52BIT_VA
> > > > > > > > > > +	ldr_l	x0, vabits_user
> > > > > > > > > > +	cmp	x0, #52
> > > > > > > > > > +	b.ne	2f > +
> > > > > > > > > > +	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
> > > > > > > > > > +	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
> > > > > > > > > > +	cbnz	x0, 2f
> > > > > > > > > > +
> > > > > > > > > > +	adr_l	x0, va52mismatch
> > > > > > > > > > +	mov	w1, #1
> > > > > > > > > > +	strb	w1, [x0]
> > > > > > > > > > +	dmb	sy
> > > > > > > > > > +	dc	ivac, x0	// Invalidate potentially stale cache line
> > > > > > > > > 
> > > > > > > > > You may have to clear this variable before a CPU is brought up to avoid
> > > > > > > > > raising a false error message when another secondary CPU doesn't boot
> > > > > > > > > for some other reason (say granule support) after a CPU failed with lack
> > > > > > > > > of 52bitva. It is really a crazy corner case.
> > > > > > > > 
> > > > > > > > Can't we just follow the example set by the EL2 setup in the way that is
> > > > > > > > uses __boot_cpu_mode? In that case, we only need one variable and you can
> > > > > > > > detect a problem by comparing the two halves.
> > > > > > > 
> > > > > > > The only difference here is, the support is bolted at boot CPU time and hence
> > > > > > > we need to verify each and every CPU, unlike the __boot_cpu_mode where we
> > > > > > > check for mismatch after the SMP CPUs are brought up. If we decide to make
> > > > > > > the choice later, something like that could work. The only caveat is the 52bit
> > > > > > > kernel VA will have to do something like the above.
> > > > > > 
> > > > > > So looking at this a bit more, I think we're better off repurposing the
> > > > > > upper bits of the early boot status word to contain a reason code, rather
> > > > > > than introducing new variables for every possible mismatch.
> > > > > > 
> > > > > > Does the untested diff below look remotely sane to you?
> > > > > > 
> > > > > > Will
> > > > > > 
> > > > > 
> > > > > Thanks Will,
> > > > > This looks good to me, I will test now and fold this into a patch.
> > > > 
> > > > Cheers, Steve. Testing would be handy, but don't worry about respinning the
> > > > patches as I'm already on top of this and hope to push this out later today.
> > > > 
> > > 
> > > Thanks Will,
> > > This looks good to me so FWIW:
> > > Tested-by: Steve Capper <steve.capper@arm.com>
> > > 
> > > (for both the 52-bit VA mismatch and 64KB granule not supported cases
> > > using the model).
> > > 
> > > The only small issue I see is that if subsequent CPUs aren't brought
> > > online (because they don't exist in the model) then the error reason is
> > > repeated.
> > > 
> > > I'll dig into this.
> > >
> > 
> > I think __early_cpu_boot_status needs to be reset at the beginning of
> > __cpu_up before the secondary is booted. Testing a check for this now.
> >
> 




> Hi Will,
> 
> The following fixed the repeating error message problem for me. If you
> want, I can send a separate patch to fix this?
> 
> Cheers,
> -- 
> Steve
> 
> 
> --->8
> 
> diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
> index 4e3bfbde829a..936156a7ae88 100644
> --- a/arch/arm64/kernel/smp.c
> +++ b/arch/arm64/kernel/smp.c
> @@ -123,6 +123,11 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
>  	update_cpu_boot_status(CPU_MMU_OFF);
>  	__flush_dcache_area(&secondary_data, sizeof(secondary_data));
>  
> +	__early_cpu_boot_status = 0;
> +	dsb(ishst);
> +	__flush_dcache_area(&__early_cpu_boot_status,
> +			sizeof(__early_cpu_boot_status));
> +
>  	/*
>  	 * Now bring the CPU into our world.
>  	 */
>

I have tested Will's changes and hit the issue reported by Steve. But this
is mainly due to a bug in our __cpu_up() code, which ignores the errors reported
by the firmware and goes ahead assuming that the CPU entered the kernel and
failed so in the process.

e.g, with a missing CPU3:

[   78.050880] psci: failed to boot CPU3 (-22)
[   78.051079] CPU3: failed to boot: -22
[   78.051319] CPU3: is stuck in kernel
[   78.051496] CPU3: does not support 52-bit VAs

With the fix attached below, I get:
# echo 1 > cpu5/online
[  101.883862] CPU5: failed to come online
[  101.884860] CPU5: is stuck in kernel
[  101.885060] CPU5: does not support 52-bit VAs
-sh: echo: write error: Input/output error
# echo 1 > cpu3/online
[  106.746141] psci: failed to boot CPU3 (-22)
[  106.746360] CPU3: failed to boot: -22
-sh: echo: write error: Invalid argument


----8>----

arm64: smp: Handle errors reported by the firmware

The __cpu_up() routine ignores the errors reported by the firmware
for a CPU bringup operation and looks for the error status set by the
booting CPU. If the CPU never entered the kernel, we could end up
in assuming stale error status, which otherwise would have been
set/cleared appropriately by the booting CPU.

Reported-by: Steve Capper <steve.capper@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Suzuki K Poulose <suzuki.poulose@arm.com>
---
 arch/arm64/kernel/smp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index ac73d6c..a854e3d 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -141,6 +141,7 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 		}
 	} else {
 		pr_err("CPU%u: failed to boot: %d\n", cpu, ret);
+		return ret;
 	}
 
 	secondary_data.task = NULL;
-- 
2.7.4

 
