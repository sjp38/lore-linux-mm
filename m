Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id F20906B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 03:02:10 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so4302448eek.6
        for <linux-mm@kvack.org>; Mon, 12 May 2014 00:02:10 -0700 (PDT)
Received: from lvps176-28-13-145.dedicated.hosteurope.de (lvps176-28-13-145.dedicated.hosteurope.de. [176.28.13.145])
        by mx.google.com with ESMTP id 43si9748756eer.87.2014.05.12.00.02.08
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 00:02:09 -0700 (PDT)
From: Tim Sander <tim@krieglstein.org>
Subject: Re: set_fiq_handler: Bad mode in data abort handler detected (mmu translation fault)
Date: Mon, 12 May 2014 09:02:08 +0200
Message-ID: <9398501.4D8aYHERx3@dabox>
In-Reply-To: <20140425135117.GP26756@n2100.arm.linux.org.uk>
References: <2527501.cXAbiV8bqS@dabox> <7402473.jpZGckhttH@dabox> <20140425135117.GP26756@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

Hi

I am still hunting the mmu faults during FIQ. But i have some new information
which seem to warrant a new mail. But first for reference the thread start:
http://lists.infradead.org/pipermail/linux-arm-kernel/2014-April/250196.html
as i am also cc'ing linux-mm as this seems also concerning mm.

Am Freitag, 25. April 2014, 14:51:18 schrieb Russell King - ARM Linux:
> On Fri, Apr 25, 2014 at 03:36:48PM +0200, Tim Sander wrote:
> > Hi Russell and List
> > 
> > Thanks for your feedback!
> > 
> > Am Donnerstag, 24. April 2014, 20:01:56 schrieb Russell King - ARM Linux:
> > > > > In years gone by, I'd have recommended that the kernel mappings for
> > > > > this stuff were done via static mappings, but with DT, that's no
> > > > > longer acceptable.  So I guess we have a problem...
> > > > 
> > > > To verify that your very plausible hypothesis is right i tried:
> > > > timer_memory = __arm_ioremap(0x4280000>>PAGE_SHIFT,0x1000,MT_MEMORY);
> > > > //also tried MT_DEVICE
> > > 
> > > This isn't going to help.  Any dynamically initialised mapping via any
> > > of the ioremap functions is going to fail for the reason I outlined,
> > > and it doesn't matter what type of mapping you use.  *All* dynamically
> > > created mappings are populated to other threads lazily.
> > 
> > Ok, i tried mapping statically in bootup. Just to verify and understand
> > the
> > problem. It seems to help somewhat (probably it does go into more
> > threads),
> > but it doesn't remedy the problem completly:
> > 
> > static struct map_desc zynq_axi_gp0 __initdata = {
> > 
> >     .virtual   = 0xe4000000, //FIXME just arbitrary, which?
> >     .pfn    = __phys_to_pfn(0x40000000),
> >     .length = SZ_128M,
> >     .type   = MT_DEVICE,
> > 
> > };
> > 
> > static void __init zynq_axi_gp_init(void)
> > {
> > 
> >     iotable_init(&zynq_axi_gp0,1);
> >     zynq_axi_gp0_base = (void __iomem *) zynq_axi_gp0.virtual;
> >     BUG_ON(!zynq_axi_gp0_base);
> > 
> > }
> > This was called in the .map_io callback. But it seems, even this is to
> > late to propagate into all threads. Calling it earlier does not work
> > (e.g. .init_early ,.init_timer or init_irq)...
> 
> It isn't too late.  .map_io is called as part of the very early kernel
> initialisation, when the page tables are being setup with real mappings
> for the very first time.  There's no interrupts, no real memory allocators,
> in fact not much of anything at that point.
> 
> I'm afraid that I'm no longer that knowledgeable about whether ioremap
> will take account of this stuff or not - other people have been hacking
> in this area and my knowledge is outdated.
> 
> > Thinking about it, if its truly lazy even an early initialization does not
> > help if mapping synchronisation is allways done lazy via data abort.
> 
> This is how it works.
> 
> .map_io is called with the init_mm as the current mm structure.  This
> contains the page tables.  Calling iotable_init() sets up mappings in
> that page table.  No other threads exist at this point.
> 
> When a kernel thread is spawned, all L1 page tables for kernel mappings
> are copied to the child's page tables.  Therefore, the mappings setup
> via iotable_init() will propagate into the children without any data
> aborts.
> 
> On ioremap(), the init_mm's page tables are updated with the L1 entries.
> Other page tables are not updated until an access is performed, which
> causes a data abort if there is no L1 page table entry.
> 
> So, .map_io should resolve the problem.  If it doesn't, something else
> is going on - maybe ioremap() is trampling all over your static mappings...
> though I thought we put the iotable_init()-created mappings into the
> vmalloc list, which should prevent it.  I don't know anymore...
I did an prefaulting for each available processes:
    for_each_process(process)
    {
        printk("process: %s [%d]\n",process->comm,process->pid);
        if(process->mm) {
            switch_mm(old_process->mm,process->mm,process);
            ioread32(priv->my_hardware);   // access the memory, prefault mmu
            old_process = process;
        }
    }
but still i get the the "Bad mode in data abort":
Bad mode in data abort handler detected
Internal error: Oops - bad mode: 0 [#1] PREEMPT SMP ARM
Modules linked in: firq(O+) ipv6
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O 3.12.0-xilinx-00005-gc9455c0-dirty #97
task: c05cb420 ti: c05c0000 task.ti: c05c0000
PC is at 0xe3fc0000
LR is at arch_cpu_idle+0x20/0x2c
pc : [<e3fc0000>]    lr : [<c000f344>]    psr: 600701d1
sp : c05c1f70  ip : 00000000  fp : 00000000
r10: 00000000  r9 : 413fc090  r8 : c0a7b4c0
r7 : c05b6088  r6 : c0412348  r5 : c06008c0  r4 : c05c0000
r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : c0a7e9f8
Flags: nZCv  IRQs off  FIQs off  Mode FIQ_32  ISA ARM  Segment kernel
Control: 18c5387d  Table: 1ec2c04a  DAC: 00000015
Process swapper/0 (pid: 0, stack limit = 0xc05c0240)
Stack: (0xc05c1f70 to 0xc05c2000)
1f60:                                     c0a7e9f8 00000000 00000000 00000000
1f80: c05c0000 c06008c0 c0412348 c05b6088 c0a7b4c0 413fc090 00000000 00000000
1fa0: 00000000 c05c1f70 c000f344 e3fc0000 600701d1 ffffffff 00000000 c0056748
1fc0: c0414a30 c0592a60 ffffffff ffffffff c0592574 00000000 00000000 c05b6088
1fe0: 18c5387d c05c83cc c05b6084 c05cc440 0000406a 00008074 00000000 00000000
[<c000f344>] (arch_cpu_idle+0x20/0x2c) from [<00000000>] (  (null))
Code: bad PC value
---[ end trace 38f263d4b2076bcb ]---

But then i realized that its always swapper/0 which is faulting. But i don't see a pid 0 process
in my for_each_process loop. So i tried some special handling for pid 0 to also prefault it:

    process = pid_task(&init_struct_pid, PIDTYPE_PID);
    if(process) {
        printk("process: %s [%d]\n",process->comm,process->pid);
        switch_mm(current_task->mm,process->mm,process);
        ioread32(priv->my_hardware);  // access the memory, prefault mmu
        switch_mm(process->mm,current_task->mm,current_task);
    } else printk("process pid prefault failed\n");  //<this path is taken

But it seems that the scheduler pid struct has no process associated. So its 
not possible to get the mmu_struct for the pid 0. The structure can't be 
implicit or otherwise there should be an mmu entry due to the prefaulting done
or due to the static mapping. So it seems there is an MMU table which is not
associated with any process and is used during scheduler/swapper work...
but where is it hiding?

I am sure that the error seen is a mmu translation fault as the IFSR bits of the
DFSR show 00101 or 00111 which is a mmu translation fault for section or page.
I have also verified the address accessed by the fiq handler routine accesses 
my_hardware. Also the fact that the handler is working *most* of the time fits 
well to the mmu translation fault.

Another interesting fact is that if the interrupt rate is slower (e.g. 1 second), i see
this problem if it is faster (probably Kernel HZ(?), but hard to tell as the error is not 
deterministic) they seem to go away. 

Best regards
Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
