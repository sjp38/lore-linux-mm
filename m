Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2726E6B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 10:10:06 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d5so9468986qtg.7
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 07:10:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 8si1119107qku.314.2018.04.01.07.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 07:10:04 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w31E9QK1103867
	for <linux-mm@kvack.org>; Sun, 1 Apr 2018 10:10:03 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h2y18374e-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 01 Apr 2018 10:10:02 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 1 Apr 2018 10:10:01 -0400
Date: Sun, 1 Apr 2018 07:10:50 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
 <20180327102116.GA2464@arm.com>
 <20180401111108.mudkiewzn33sifvk@yury-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180401111108.mudkiewzn33sifvk@yury-thinkpad>
Message-Id: <20180401141050.GF3948@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 01, 2018 at 02:11:08PM +0300, Yury Norov wrote:
> On Tue, Mar 27, 2018 at 11:21:17AM +0100, Will Deacon wrote:
> > On Sun, Mar 25, 2018 at 08:50:04PM +0300, Yury Norov wrote:
> > > kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast IPI.
> > > If CPU is in extended quiescent state (idle task or nohz_full userspace), this
> > > work may be done at the exit of this state. Delaying synchronization helps to
> > > save power if CPU is in idle state and decrease latency for real-time tasks.
> > > 
> > > This patch introduces kick_active_cpus_sync() and uses it in mm/slab and arm64
> > > code to delay syncronization.
> > > 
> > > For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU running
> > > isolated task would be fatal, as it breaks isolation. The approach with delaying
> > > of synchronization work helps to maintain isolated state.
> > > 
> > > I've tested it with test from task isolation series on ThunderX2 for more than
> > > 10 hours (10k giga-ticks) without breaking isolation.
> > > 
> > > Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> > > ---
> > >  arch/arm64/kernel/insn.c |  2 +-
> > >  include/linux/smp.h      |  2 ++
> > >  kernel/smp.c             | 24 ++++++++++++++++++++++++
> > >  mm/slab.c                |  2 +-
> > >  4 files changed, 28 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> > > index 2718a77da165..9d7c492e920e 100644
> > > --- a/arch/arm64/kernel/insn.c
> > > +++ b/arch/arm64/kernel/insn.c
> > > @@ -291,7 +291,7 @@ int __kprobes aarch64_insn_patch_text(void *addrs[], u32 insns[], int cnt)
> > >  			 * synchronization.
> > >  			 */
> > >  			ret = aarch64_insn_patch_text_nosync(addrs[0], insns[0]);
> > > -			kick_all_cpus_sync();
> > > +			kick_active_cpus_sync();
> > >  			return ret;
> > >  		}
> > >  	}
> > 
> > I think this means that runtime modifications to the kernel text might not
> > be picked up by CPUs coming out of idle. Shouldn't we add an ISB on that
> > path to avoid executing stale instructions?
> > 
> > Will
> 
> commit 153ae9d5667e7baab4d48c48e8ec30fbcbd86f1e
> Author: Yury Norov <ynorov@caviumnetworks.com>
> Date:   Sat Mar 31 15:05:23 2018 +0300
> 
> Hi Will, Paul,
> 
> On my system there are 3 paths that go thru rcu_dynticks_eqs_exit(),
> and so require isb().
> 
> First path starts at gic_handle_irq() on secondary_start_kernel stack.
> gic_handle_irq() already issues isb(), and so we can do nothing.
> 
> Second path starts at el0_svc entry; and third path is the exit from
> do_idle() on secondary_start_kernel stack.
> 
> For do_idle() path there is arch_cpu_idle_exit() hook that is not used by
> arm64 at now, so I picked it. And for el0_svc, I've introduced isb_if_eqs
> macro and call it at the beginning of el0_svc_naked.
> 
> I've tested it on ThunderX2 machine, and it works for me.
> 
> Below is my call traces and patch for them. If you OK with it, I think I'm
> ready to submit v2 (but maybe split this patch for better readability).

I must defer to Will on this one.

							Thanx, Paul

> Yury
> 
> [  585.412095] Call trace:
> [  585.412097] [<fffffc00080878d8>] dump_backtrace+0x0/0x380
> [  585.412099] [<fffffc0008087c6c>] show_stack+0x14/0x20
> [  585.412101] [<fffffc0008a091ec>] dump_stack+0x98/0xbc
> [  585.412104] [<fffffc0008122080>] rcu_dynticks_eqs_exit+0x68/0x70
> [  585.412105] [<fffffc00081260f0>] rcu_irq_enter+0x48/0x50
> [  585.412106] [<fffffc00080c92c4>] irq_enter+0xc/0x70
> [  585.412108] [<fffffc0008113a64>] __handle_domain_irq+0x3c/0x120
> [  585.412109] [<fffffc00080816c4>] gic_handle_irq+0xc4/0x180
> [  585.412110] Exception stack(0xfffffc001130fe20 to 0xfffffc001130ff60)
> [  585.412112] fe20: 00000000000000a0 0000000000000000 0000000000000001 0000000000000000
> [  585.412113] fe40: 0000028f6f0b0000 0000000000000020 0013cd6f53963b31 0000000000000000
> [  585.412144] fe60: 0000000000000002 fffffc001130fed0 0000000000000b80 0000000000003400
> [  585.412146] fe80: 0000000000000000 0000000000000001 0000000000000000 00000000000001db
> [  585.412147] fea0: fffffc0008247a78 000003ff86dc61f8 0000000000000014 fffffc0008fc0000
> [  585.412149] fec0: fffffc00090143e8 fffffc0009014000 fffffc0008fc94a0 0000000000000000
> [  585.412150] fee0: 0000000000000000 fffffe8f46bb1700 0000000000000000 0000000000000000
> [  585.412152] ff00: 0000000000000000 fffffc001130ff60 fffffc0008085034 fffffc001130ff60
> [  585.412153] ff20: fffffc0008085038 0000000000400149 fffffc0009014000 fffffc0008fc94a0
> [  585.412155] ff40: ffffffffffffffff 0000000000000000 fffffc001130ff60 fffffc0008085038
> [  585.412156] [<fffffc0008082fb0>] el1_irq+0xb0/0x124
> [  585.412158] [<fffffc0008085038>] arch_cpu_idle+0x10/0x18
> [  585.412159] [<fffffc00080ff38c>] do_idle+0x10c/0x1d8
> [  585.412160] [<fffffc00080ff5ec>] cpu_startup_entry+0x24/0x28
> [  585.412162] [<fffffc000808db04>] secondary_start_kernel+0x15c/0x1a0
> [  585.412164] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.14.0-isolation-160735-g59b71c1-dirty #18
> 
> [  585.412058] Call trace:
> [  585.412060] [<fffffc00080878d8>] dump_backtrace+0x0/0x380
> [  585.412062] [<fffffc0008087c6c>] show_stack+0x14/0x20
> [  585.412064] [<fffffc0008a091ec>] dump_stack+0x98/0xbc
> [  585.412066] [<fffffc0008122080>] rcu_dynticks_eqs_exit+0x68/0x70
> [  585.412068] [<fffffc00081232bc>] rcu_eqs_exit.isra.23+0x64/0x80
> [  585.412069] [<fffffc000812609c>] rcu_user_exit+0xc/0x18
> [  585.412071] [<fffffc000817c34c>] __context_tracking_exit.part.2+0x74/0x98
> [  585.412072] [<fffffc000817c3e0>] context_tracking_exit.part.3+0x40/0x50
> [  585.412074] [<fffffc000817c4e0>] context_tracking_user_exit+0x30/0x38
> [  585.412075] Exception stack(0xfffffc00385afec0 to 0xfffffc00385b0000)
> [  585.412076] fec0: 00000000000000b1 000002aacd702420 0000000000000200 00000000000001f4
> [  585.412078] fee0: 0000000000000000 0000000000000008 000002aabec9af17 ffffffffffffffff
> [  585.412079] ff00: 0000000000000016 ffffffffffffffff 000003ffe7619470 0000000000000057
> [  585.412081] ff20: a3d70a3d70a3d70b 000000000000016d 2ce33e6c02ce33e7 00000000000001db
> [  585.412082] ff40: 000002aabec7d260 000003ff86dc61f8 0000000000000014 00000000000001f4
> [  585.412083] ff60: 0000000000000000 000002aabecab000 000002aacd6e2830 0000000000000001
> [  585.412085] ff80: 000002aacd6e2830 000002aabec58380 0000000000000054 000002aabebccf50
> [  585.412086] ffa0: 0000000000000054 000003ffe7619540 000002aabebcf538 000003ffe7619540
> [  585.412088] ffc0: 000003ff86dc6410 0000000060000000 00000000000000b1 0000000000000016
> [  585.412089] ffe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  585.412091] [<fffffc0008083498>] el0_svc_naked+0xc/0x3c
> [  585.446067] CPU: 68 PID: 0 Comm: swapper/68 Not tainted 4.14.0-isolation-160735-g59b71c1-dirty #18
> 
> [  585.412038] Call trace:
> [  585.412041] [<fffffc00080878d8>] dump_backtrace+0x0/0x380
> [  585.412042] [<fffffc0008087c6c>] show_stack+0x14/0x20
> [  585.412045] [<fffffc0008a091ec>] dump_stack+0x98/0xbc
> [  585.412047] [<fffffc0008122080>] rcu_dynticks_eqs_exit+0x68/0x70
> [  585.412049] [<fffffc00081232bc>] rcu_eqs_exit.isra.23+0x64/0x80
> [  585.412050] [<fffffc0008126080>] rcu_idle_exit+0x18/0x28
> [  585.412052] [<fffffc00080ff398>] do_idle+0x118/0x1d8
> [  585.412053] [<fffffc00080ff5ec>] cpu_startup_entry+0x24/0x28
> [  585.412055] [<fffffc000808db04>] secondary_start_kernel+0x15c/0x1a0
> [  585.412057] CPU: 22 PID: 4315 Comm: nginx Not tainted 4.14.0-isolation-160735-g59b71c1-dirty #18
>     
> diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
> index e1c59d4008a8..efa5060a2f1c 100644
> --- a/arch/arm64/kernel/entry.S
> +++ b/arch/arm64/kernel/entry.S
> @@ -35,22 +35,29 @@
>  #include <asm/unistd.h>
> 
>  /*
> - * Context tracking subsystem.  Used to instrument transitions
> - * between user and kernel mode.
> + * Save/restore needed during syscalls.  Restore syscall arguments from
> + * the values already saved on stack during kernel_entry.
>   */
> -	.macro ct_user_exit, syscall = 0
> -#ifdef CONFIG_CONTEXT_TRACKING
> -	bl	context_tracking_user_exit
> -	.if \syscall == 1
> -	/*
> -	 * Save/restore needed during syscalls.  Restore syscall arguments from
> -	 * the values already saved on stack during kernel_entry.
> -	 */
> +	.macro __restore_syscall_args
>  	ldp	x0, x1, [sp]
>  	ldp	x2, x3, [sp, #S_X2]
>  	ldp	x4, x5, [sp, #S_X4]
>  	ldp	x6, x7, [sp, #S_X6]
> -	.endif
> +	.endm
> +
> +	.macro el0_svc_restore_syscall_args
> +#if !defined(CONFIG_TINY_RCU) || defined(CONFIG_CONTEXT_TRACKING)
> +	__restore_syscall_args
> +#endif
> +	.endm
> +
> +/*
> + * Context tracking subsystem.  Used to instrument transitions
> + * between user and kernel mode.
> + */
> +	.macro ct_user_exit
> +#ifdef CONFIG_CONTEXT_TRACKING
> +	bl	context_tracking_user_exit
>  #endif
>  	.endm
> 
> @@ -433,6 +440,20 @@ __bad_stack:
>  	ASM_BUG()
>  	.endm
> 
> +/*
> + * Flush I-cache if CPU is in extended quiescent state
> + */
> +	.macro	isb_if_eqs
> +#ifndef CONFIG_TINY_RCU
> +	bl	rcu_is_watching
> +	tst	w0, #0xff
> +	b.ne	1f
> +	/* Pairs with aarch64_insn_patch_text for EQS CPUs. */
> +	isb
> +1:
> +#endif
> +	.endm
> +
>  el0_sync_invalid:
>  	inv_entry 0, BAD_SYNC
>  ENDPROC(el0_sync_invalid)
> @@ -840,8 +861,10 @@ el0_svc:
>  	mov	wsc_nr, #__NR_syscalls
>  el0_svc_naked:					// compat entry point
>  	stp	x0, xscno, [sp, #S_ORIG_X0]	// save the original x0 and syscall number
> +	isb_if_eqs
>  	enable_dbg_and_irq
> -	ct_user_exit 1
> +	ct_user_exit
> +	el0_svc_restore_syscall_args
> 
>  	ldr	x16, [tsk, #TSK_TI_FLAGS]	// check for syscall hooks
>  	tst	x16, #_TIF_SYSCALL_WORK
> @@ -874,10 +897,7 @@ __sys_trace:
>  	mov	x1, sp				// pointer to regs
>  	cmp	wscno, wsc_nr			// check upper syscall limit
>  	b.hs	__ni_sys_trace
> -	ldp	x0, x1, [sp]			// restore the syscall args
> -	ldp	x2, x3, [sp, #S_X2]
> -	ldp	x4, x5, [sp, #S_X4]
> -	ldp	x6, x7, [sp, #S_X6]
> +	__restore_syscall_args
>  	ldr	x16, [stbl, xscno, lsl #3]	// address in the syscall table
>  	blr	x16				// call sys_* routine
> 
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 2dc0f8482210..f11afd2aa33a 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -88,6 +88,12 @@ void arch_cpu_idle(void)
>  	trace_cpu_idle_rcuidle(PWR_EVENT_EXIT, smp_processor_id());
>  }
> 
> +void arch_cpu_idle_exit(void)
> +{
> +	if (!rcu_is_watching())
> +		isb();
> +}
> +
>  #ifdef CONFIG_HOTPLUG_CPU
>  void arch_cpu_idle_dead(void)
>  {
> 
