Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id DA2FF6B00A5
	for <linux-mm@kvack.org>; Sat, 26 Oct 2013 10:36:41 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so5198567pde.15
        for <linux-mm@kvack.org>; Sat, 26 Oct 2013 07:36:41 -0700 (PDT)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id yk3si8175653pac.12.2013.10.26.07.36.39
        for <linux-mm@kvack.org>;
        Sat, 26 Oct 2013 07:36:40 -0700 (PDT)
Date: Sat, 26 Oct 2013 15:36:17 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Message-ID: <20131026143617.GA14034@mudshark.cambridge.arm.com>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, catalin.marinas@arm.com, gmbnomis@gmail.com

On Thu, Oct 24, 2013 at 09:07:30PM +0100, Aaro Koskinen wrote:
> Hi,

Hello,

[adding Catalin and Simon]

> I was trying to debug kernel crashes on Marvell Kirkwood (openrd)
> when upgrading from GCC 4.7.3 -> GCC 4.8.2. So I enabled most of the
> kernel debug options. However, I noticed that already when compiled with
> GCC 4.7.3 kernel crashes consistently at boot when DEBUG_VM is enabled
> (without it there are no issues with 4.7.3). See below for the boot/crash
> log & kernel config.

Ok, but this doesn't seem to be related to GCC.

[...]

> [   26.694345] ata2: link is slow to respond, please be patient (ready=0)
> [   31.194346] ata2: SRST failed (errno=-16)
> [   31.754426] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl F300)
> [   31.834619] ata2.00: ATA-6: eSATA-2 WD5000AAKX-00ERMA0, 15.01H15, max UDMA/133
> [   31.899627] ata2.00: 976773168 sectors, multi 0: LBA48
> [   31.994458] ata2.00: configured for UDMA/133
> [   32.075306] ------------[ cut here ]------------
> [   32.136256] kernel BUG at mm/util.c:390!
> [   32.195446] Internal error: Oops - BUG: 0 [#1] PREEMPT ARM
> [   32.255893] Modules linked in:
> [   32.313109] CPU: 0 PID: 12 Comm: kworker/u2:1 Not tainted 3.12.0-rc6-openrd-los.git-1836ad9-dirty #3
> [   32.435821] Workqueue: events_unbound async_run_entry_fn
> [   32.498701] task: df854700 ti: df8a8000 task.ti: df8a8000
> [   32.561662] PC is at page_mapping+0x48/0x50
> [   32.622764] LR is at flush_kernel_dcache_page+0x14/0x98
> [   32.685421] pc : [<c00923c4>]    lr : [<c0010dd8>]    psr: 20000093
> [   32.685421] sp : df8a99f8  ip : df8a9a08  fp : df8a9a04
> [   32.812754] r10: 60000093  r9 : df8a9c24  r8 : 00000024
> [   32.874269] r7 : 00000000  r6 : c0a3cd0c  r5 : 00001000  r4 : c0e2732c
> [   32.936395] r3 : 00000000  r2 : 00000080  r1 : 00000564  r0 : c0e2732c
> [   32.996978] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> [   33.059012] Control: 0005317f  Table: 1a8dc000  DAC: 00000017
> [   33.119473] Process kworker/u2:1 (pid: 12, stack limit = 0xdf8a81c0)

The BUG is because page_mapping is being given a slab page...

> [   36.477203] Backtrace:
> [   36.535603] [<c009237c>] (page_mapping+0x0/0x50) from [<c0010dd8>] (flush_kernel_dcache_page+0x14/0x98)
> [   36.661070] [<c0010dc4>] (flush_kernel_dcache_page+0x0/0x98) from [<c0172b60>] (sg_miter_stop+0xc8/0x10c)
> [   36.792813]  r4:df8a9a64 r3:00000003
> [   36.857524] [<c0172a98>] (sg_miter_stop+0x0/0x10c) from [<c0172f20>] (sg_miter_next+0x14/0x13c)

... assumedly for scatter/gather DMA. How is your block driver allocating
its buffers? If you're using the DMA API, I can't see how this would happen.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
