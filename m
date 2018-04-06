Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7147E6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 13:50:35 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id l22-v6so1090651otj.17
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 10:50:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e17-v6si2546846oii.268.2018.04.06.10.50.34
        for <linux-mm@kvack.org>;
        Fri, 06 Apr 2018 10:50:34 -0700 (PDT)
Date: Fri, 6 Apr 2018 18:50:27 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/5] arm64: entry: isb in el1_irq
Message-ID: <20180406175027.oxaru6r3zptct7vb@lakrids.cambridge.arm.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
 <20180405171800.5648-2-ynorov@caviumnetworks.com>
 <5036b99a-9faa-c220-27dd-e0d73f8b3fc7@arm.com>
 <20180406165402.nq3sabeku2mp3hpb@yury-thinkpad>
 <20180406172211.r42reit2bnpocab2@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406172211.r42reit2bnpocab2@lakrids.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: James Morse <james.morse@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 06, 2018 at 06:22:11PM +0100, Mark Rutland wrote:
> Digging a bit, I also thing that our ct_user_exit and ct_user_enter
> usage is on dodgy ground today.
> 
> For example, in el0_dbg we call do_debug_exception() *before* calling
> ct_user_exit. Which I believe means we'd use RCU while supposedly in an
> extended quiescent period, which would be bad.

It seems this is the case. I can trigger the following by having GDB
place a SW breakpoint:

[   51.217947] =============================
[   51.217953] WARNING: suspicious RCU usage
[   51.217961] 4.16.0 #4 Not tainted
[   51.217966] -----------------------------
[   51.217974] ./include/linux/rcupdate.h:632 rcu_read_lock() used illegally while idle!
[   51.217980]
[   51.217980] other info that might help us debug this:
[   51.217980]
[   51.217987]
[   51.217987] RCU used illegally from idle CPU!
[   51.217987] rcu_scheduler_active = 2, debug_locks = 1
[   51.217992] RCU used illegally from extended quiescent state!
[   51.217999] 1 lock held by ls/2412:
[   51.218004]  #0:  (rcu_read_lock){....}, at: [<0000000092efbdd5>] brk_handler+0x0/0x198
[   51.218041]
[   51.218041] stack backtrace:
[   51.218049] CPU: 2 PID: 2412 Comm: ls Not tainted 4.16.0 #4
[   51.218055] Hardware name: ARM Juno development board (r1) (DT)
[   51.218061] Call trace:
[   51.218070]  dump_backtrace+0x0/0x1c8
[   51.218078]  show_stack+0x14/0x20
[   51.218087]  dump_stack+0xac/0xe4
[   51.218096]  lockdep_rcu_suspicious+0xcc/0x110
[   51.218103]  brk_handler+0x144/0x198
[   51.218110]  do_debug_exception+0x9c/0x190
[   51.218116]  el0_dbg+0x14/0x20

We will need to fix this before we can fiddle with kick_all_cpus_sync().

Thanks,
Mark.
