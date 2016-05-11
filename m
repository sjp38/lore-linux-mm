From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
Date: Wed, 11 May 2016 16:13:50 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1605111611210.3540@nanos>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp> <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp> <alpine.DEB.2.11.1605091853130.3540@nanos> <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, 11 May 2016, Tetsuo Handa wrote:
> Thomas Gleixner wrote:
> > On Mon, 9 May 2016, Tetsuo Handa wrote:
> > > 
> > > It seems to me that APIC_BASE APIC_ICR APIC_ICR_BUSY are all constant
> > > regardless of calling cpu. Thus, native_apic_mem_read() and
> > > native_apic_mem_write() are using globally shared constant memory
> > > address and __xapic_wait_icr_idle() is making decision based on
> > > globally shared constant memory address. Am I right?
> > 
> > No. The APIC address space is per cpu. It's the same address but it's always
> > accessing the local APIC of the cpu on which it is called.
> 
> Same address but per CPU magic. I see.
> 
> Now, I'm trying with CONFIG_TRACE_IRQFLAGS=y and I can observe that
> irq event stamp shows that hardirqs are disabled for two CPUs when I hit
> this bug. It seems to me that this bug is triggered when two CPUs are
> concurrently calling smp_call_function_many() with wait == true.


> [  180.434649] hardirqs last  enabled at (5324977): [<ffff88007860f990>] 0xffff88007860f990
> [  180.434650] hardirqs last disabled at (5324978): [<ffff88007860f990>] 0xffff88007860f990

Those addresses are on the stack !?! That makes no sense whatsoever.

> [  180.434659] task: ffff88007a046440 ti: ffff88007860c000 task.ti: ffff88007860c000
> [  180.434665] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
> [  180.434666] RSP: 0000:ffff88007860f950  EFLAGS: 00000202

And on this CPU interrupt are enabled because the IF bit (9) in EFLAGS is set.

> [  180.548951] hardirqs last  enabled at (601147): [<ffff880078cffa00>] 0xffff880078cffa00
> [  180.551359] hardirqs last disabled at (601148): [<ffff880078cffa00>] 0xffff880078cffa00

Equally crap.

> [  180.563802] task: ffff880077ad1940 ti: ffff880078cfc000 task.ti: ffff880078cfc000
> [  180.565984] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
> [  180.568517] RSP: 0000:ffff880078cff9c0  EFLAGS: 00000202

And again interrupts are enabled.

Thanks,

	tglx
