From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Date: Sat, 26 Oct 2013 20:23:12 +0300
Message-ID: <20131026172312.GG17447@blackmetal.musicnaut.iki.fi>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
 <20131026143617.GA14034@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131026143617.GA14034@mudshark.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Will Deacon <will.deacon@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, gmbnomis@gmail.com, catalin.marinas@arm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
List-Id: linux-mm.kvack.org

Hi,

On Sat, Oct 26, 2013 at 03:36:17PM +0100, Will Deacon wrote:
> On Thu, Oct 24, 2013 at 09:07:30PM +0100, Aaro Koskinen wrote:
> > [   26.694345] ata2: link is slow to respond, please be patient (ready=0)
> > [   31.194346] ata2: SRST failed (errno=-16)
> > [   31.754426] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl F300)
> > [   31.834619] ata2.00: ATA-6: eSATA-2 WD5000AAKX-00ERMA0, 15.01H15, max UDMA/133
> > [   31.899627] ata2.00: 976773168 sectors, multi 0: LBA48
> > [   31.994458] ata2.00: configured for UDMA/133
> > [   32.075306] ------------[ cut here ]------------
> > [   32.136256] kernel BUG at mm/util.c:390!
> > [   32.195446] Internal error: Oops - BUG: 0 [#1] PREEMPT ARM
> > [   32.255893] Modules linked in:
> > [   32.313109] CPU: 0 PID: 12 Comm: kworker/u2:1 Not tainted 3.12.0-rc6-openrd-los.git-1836ad9-dirty #3
> > [   32.435821] Workqueue: events_unbound async_run_entry_fn
> > [   32.498701] task: df854700 ti: df8a8000 task.ti: df8a8000
> > [   32.561662] PC is at page_mapping+0x48/0x50
> > [   32.622764] LR is at flush_kernel_dcache_page+0x14/0x98
> > [   32.685421] pc : [<c00923c4>]    lr : [<c0010dd8>]    psr: 20000093
> > [   32.685421] sp : df8a99f8  ip : df8a9a08  fp : df8a9a04
> > [   32.812754] r10: 60000093  r9 : df8a9c24  r8 : 00000024
> > [   32.874269] r7 : 00000000  r6 : c0a3cd0c  r5 : 00001000  r4 : c0e2732c
> > [   32.936395] r3 : 00000000  r2 : 00000080  r1 : 00000564  r0 : c0e2732c
> > [   32.996978] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> > [   33.059012] Control: 0005317f  Table: 1a8dc000  DAC: 00000017
> > [   33.119473] Process kworker/u2:1 (pid: 12, stack limit = 0xdf8a81c0)
> 
> The BUG is because page_mapping is being given a slab page...
> 
> > [   36.477203] Backtrace:
> > [   36.535603] [<c009237c>] (page_mapping+0x0/0x50) from [<c0010dd8>] (flush_kernel_dcache_page+0x14/0x98)
> > [   36.661070] [<c0010dc4>] (flush_kernel_dcache_page+0x0/0x98) from [<c0172b60>] (sg_miter_stop+0xc8/0x10c)
> > [   36.792813]  r4:df8a9a64 r3:00000003
> > [   36.857524] [<c0172a98>] (sg_miter_stop+0x0/0x10c) from [<c0172f20>] (sg_miter_next+0x14/0x13c)
> 
> ... assumedly for scatter/gather DMA. How is your block driver allocating
> its buffers? If you're using the DMA API, I can't see how this would happen.

This is sata_mv driver. As far as I understand, it's using DMA API
(dma_pool_alloc() etc.).

I noticed that for some reason CMA has gotten disabled on my
.config. However, enabling both CMA and DMA_CMA will still trigger
this BUG...

A.
