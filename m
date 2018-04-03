Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA0ED6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:48:40 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id w13-v6so144792ote.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:48:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y10-v6si832796oig.66.2018.04.03.06.48.39
        for <linux-mm@kvack.org>;
        Tue, 03 Apr 2018 06:48:39 -0700 (PDT)
Date: Tue, 3 Apr 2018 14:48:32 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180403134832.2cdae64uwuot6ryz@lakrids.cambridge.arm.com>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
 <20180327102116.GA2464@arm.com>
 <20180401111108.mudkiewzn33sifvk@yury-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180401111108.mudkiewzn33sifvk@yury-thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Will Deacon <will.deacon@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Yury,

On Sun, Apr 01, 2018 at 02:11:08PM +0300, Yury Norov wrote:
> +/*
> + * Flush I-cache if CPU is in extended quiescent state
> + */

This comment is misleading. An ISB doesn't touch the I-cache; it forces
a context synchronization event.

> +	.macro	isb_if_eqs
> +#ifndef CONFIG_TINY_RCU
> +	bl	rcu_is_watching
> +	tst	w0, #0xff
> +	b.ne	1f

The TST+B.NE can be a CBNZ:

	bl	rcu_is_watching
	cbnz	x0, 1f
	isb
1:

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

I don't think this is safe. here we issue the ISB *before* exiting a
quiesecent state, so I think we can race with another CPU that calls
kick_all_active_cpus_sync, e.g.

	CPU0				CPU1

	ISB
					patch_some_text()
					kick_all_active_cpus_sync()
	ct_user_exit

	// not synchronized!
	use_of_patched_text()

... and therefore the ISB has no effect, which could be disasterous.

I believe we need the ISB *after* we transition into a non-quiescent
state, so that we can't possibly miss a context synchronization event.

Thanks,
Mark.
