Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B77186B0022
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 06:57:17 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id i18-v6so381510ota.13
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 03:57:17 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y131-v6si2830938oia.82.2018.04.06.03.57.16
        for <linux-mm@kvack.org>;
        Fri, 06 Apr 2018 03:57:16 -0700 (PDT)
Date: Fri, 6 Apr 2018 11:57:09 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/5] arm64: entry: isb in el1_irq
Message-ID: <20180406105709.kd3uumwustwnzcd4@lakrids.cambridge.arm.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
 <20180405171800.5648-2-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405171800.5648-2-ynorov@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2018 at 08:17:56PM +0300, Yury Norov wrote:
> Kernel text patching framework relies on IPI to ensure that other
> SMP cores observe the change. Target core calls isb() in IPI handler
> path, but not at the beginning of el1_irq entry. There's a chance
> that modified instruction will appear prior isb(), and so will not be
> observed.
> 
> This patch inserts isb early at el1_irq entry to avoid that chance.

As James pointed out, taking an exception is context synchronizing, so
this looks unnecessary.

Also, it's important to realise that the exception entry is not tied to a
specific interrupt. We might take an EL1 IRQ because of a timer interrupt,
then an IPI could be taken before we get to gic_handle_irq().

This means that we can race:

	CPU0				CPU1
	<take IRQ>
	ISB
					<patch text>
					<send IPI>
	<discover IPI pending>

... and thus the ISB is too early.

Only once we're in the interrupt handler can we pair an ISB with the IPI, and
any code executed before that is not guaranteed to be up-to-date.

Thanks,
Mark.

> 
> Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> ---
>  arch/arm64/kernel/entry.S | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
> index ec2ee720e33e..9c06b4b80060 100644
> --- a/arch/arm64/kernel/entry.S
> +++ b/arch/arm64/kernel/entry.S
> @@ -593,6 +593,7 @@ ENDPROC(el1_sync)
>  
>  	.align	6
>  el1_irq:
> +	isb					// pairs with aarch64_insn_patch_text
>  	kernel_entry 1
>  	enable_da_f
>  #ifdef CONFIG_TRACE_IRQFLAGS
> -- 
> 2.14.1
> 
