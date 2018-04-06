Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E67586B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 13:22:19 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y10-v6so942086oia.15
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 10:22:19 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r69-v6si3277908ota.481.2018.04.06.10.22.18
        for <linux-mm@kvack.org>;
        Fri, 06 Apr 2018 10:22:18 -0700 (PDT)
Date: Fri, 6 Apr 2018 18:22:11 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/5] arm64: entry: isb in el1_irq
Message-ID: <20180406172211.r42reit2bnpocab2@lakrids.cambridge.arm.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
 <20180405171800.5648-2-ynorov@caviumnetworks.com>
 <5036b99a-9faa-c220-27dd-e0d73f8b3fc7@arm.com>
 <20180406165402.nq3sabeku2mp3hpb@yury-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406165402.nq3sabeku2mp3hpb@yury-thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: James Morse <james.morse@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 06, 2018 at 07:54:02PM +0300, Yury Norov wrote:
> In general, kick_all_cpus_sync() is needed to switch contexts. But exit from
> userspace is anyway the switch of context. And while in userspace, we cannot
> do something wrong on kernel side. For me it means that we can safely drop
> IPI for all userspace modes - both normal and nohz_full. 

This *may* be true, but only if we never have to patch text in the
windows:

* between exception entry and eqs_exit()

* between eqs_enter() and exception return

* between eqs_enter() and eqs_exit() in the idle loop.

If it's possible that we need to execute patched text in any of those
paths, we must IPI all CPUs in order to correctly serialize things.

Digging a bit, I also thing that our ct_user_exit and ct_user_enter
usage is on dodgy ground today.

For example, in el0_dbg we call do_debug_exception() *before* calling
ct_user_exit. Which I believe means we'd use RCU while supposedly in an
extended quiescent period, which would be bad.

In other paths, we unmask all DAIF bits before calling ct_user_exit, so
we could similarly take an EL1 debug exception without having exited the
extended quiescent period.

I think similar applies to SDEI; we don't negotiate with RCU prior to
invoking handlers, which might need RCU.

> If it's correct, for v3 I would suggest:
>  - in kick_all_cpus_sync() mask all is_idle_task() and user_mode() CPUs;
>  - add isb() for arm64 in do_idle() path only - this path doesn't imply
>    context switch.

As mentioned in my other reply, I don't think the ISB in do_idle()
makes sense, unless that occurs *after* we exit the extended quiescent
state.

Thanks,
Mark.
