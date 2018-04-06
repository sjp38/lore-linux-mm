Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7380C6B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 06:05:48 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l67-v6so277762oif.23
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 03:05:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d201-v6si2892837oig.328.2018.04.06.03.05.47
        for <linux-mm@kvack.org>;
        Fri, 06 Apr 2018 03:05:47 -0700 (PDT)
Subject: Re: [PATCH 1/5] arm64: entry: isb in el1_irq
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
 <20180405171800.5648-2-ynorov@caviumnetworks.com>
From: James Morse <james.morse@arm.com>
Message-ID: <5036b99a-9faa-c220-27dd-e0d73f8b3fc7@arm.com>
Date: Fri, 6 Apr 2018 11:02:56 +0100
MIME-Version: 1.0
In-Reply-To: <20180405171800.5648-2-ynorov@caviumnetworks.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Yury,

On 05/04/18 18:17, Yury Norov wrote:
> Kernel text patching framework relies on IPI to ensure that other
> SMP cores observe the change. Target core calls isb() in IPI handler

(Odd, if its just to synchronize the CPU, taking the IPI should be enough).


> path, but not at the beginning of el1_irq entry. There's a chance
> that modified instruction will appear prior isb(), and so will not be
> observed.
> 
> This patch inserts isb early at el1_irq entry to avoid that chance.


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
> 

An ISB at the beginning of the vectors? This is odd, taking an IRQ to get in
here would be a context-synchronization-event too, so the ISB is superfluous.

The ARM-ARM  has a list of 'Context-Synchronization event's (Glossary on page
6480 of DDI0487B.b), paraphrasing:
* ISB
* Taking an exception
* ERET
* (...loads of debug stuff...)


Thanks,

James
