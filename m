Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE7976B7448
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 13:47:17 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id q5-v6so8747576ith.1
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 10:47:17 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0116.outbound.protection.outlook.com. [104.47.36.116])
        by mx.google.com with ESMTPS id k7-v6si1857084ite.30.2018.09.05.10.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 10:47:16 -0700 (PDT)
Date: Wed, 5 Sep 2018 10:47:10 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH RESEND] mips: switch to NO_BOOTMEM
Message-ID: <20180905174709.pz2rmyt2oob6bxpz@pburton-laptop>
References: <1535356775-20396-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180830214856.cwqyjksz36ujxydm@pburton-laptop>
 <20180831211747.GA31133@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831211747.GA31133@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Serge Semin <fancer.lancer@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike,

On Sat, Sep 01, 2018 at 12:17:48AM +0300, Mike Rapoport wrote:
> On Thu, Aug 30, 2018 at 02:48:57PM -0700, Paul Burton wrote:
> > On Mon, Aug 27, 2018 at 10:59:35AM +0300, Mike Rapoport wrote:
> > > MIPS already has memblock support and all the memory is already registered
> > > with it.
> > > 
> > > This patch replaces bootmem memory reservations with memblock ones and
> > > removes the bootmem initialization.
> > > 
> > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > ---
> > > 
> > >  arch/mips/Kconfig                      |  1 +
> > >  arch/mips/kernel/setup.c               | 89 +++++-----------------------------
> > >  arch/mips/loongson64/loongson-3/numa.c | 34 ++++++-------
> > >  arch/mips/sgi-ip27/ip27-memory.c       | 11 ++---
> > >  4 files changed, 33 insertions(+), 102 deletions(-)
> > 
> > Thanks for working on this. Unfortunately it breaks boot for at least a
> > 32r6el_defconfig kernel on QEMU:
> > 
> >   $ qemu-system-mips64el \
> >     -M boston \
> >     -kernel arch/mips/boot/vmlinux.gz.itb \
> >     -serial stdio \
> >     -append "earlycon=uart8250,mmio32,0x17ffe000,115200 console=ttyS0,115200 debug memblock=debug mminit_loglevel=4"
> >   [    0.000000] Linux version 4.19.0-rc1-00008-g82d0f342eecd (pburton@pburton-laptop) (gcc version 8.1.0 (GCC)) #23 SMP Thu Aug 30 14:38:06 PDT 2018
> >   [    0.000000] CPU0 revision is: 0001a900 (MIPS I6400)
> >   [    0.000000] FPU revision is: 20f30300
> >   [    0.000000] MSA revision is: 00000300
> >   [    0.000000] MIPS: machine is img,boston
> >   [    0.000000] Determined physical RAM map:
> >   [    0.000000]  memory: 10000000 @ 00000000 (usable)
> >   [    0.000000]  memory: 30000000 @ 90000000 (usable)
> >   [    0.000000] earlycon: uart8250 at MMIO32 0x17ffe000 (options '115200')
> >   [    0.000000] bootconsole [uart8250] enabled
> >   [    0.000000] memblock_reserve: [0x00000000-0x009a8fff] setup_arch+0x224/0x718
> >   [    0.000000] memblock_reserve: [0x01360000-0x01361ca7] setup_arch+0x3d8/0x718
> >   [    0.000000] Initrd not found or empty - disabling initrd
> >   [    0.000000] memblock_virt_alloc_try_nid: 7336 bytes align=0x40 nid=-1 from=0x00000000 max_addr=0x00000000 early_init_dt_alloc_memory_arch+0x20/0x2c
> >   [    0.000000] memblock_reserve: [0xbfffe340-0xbfffffe7] memblock_virt_alloc_internal+0x120/0x1ec
> >   <hang>
> > 
> > It looks like we took a TLB store exception after calling memset() with
> > a bogus address from memblock_virt_alloc_try_nid() or something inlined
> > into it.
> 
> Memblock tries to allocate from the top and the resulting address ends up
> in the high memory. 
> 
> With the hunk below I was able to get to "VFS: Cannot open root device"
> 
> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index 4114d3c..4a9b0f7 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -577,6 +577,8 @@ static void __init bootmem_init(void)
>          * Reserve initrd memory if needed.
>          */
>         finalize_initrd();
> +
> +       memblock_set_bottom_up(true);
>  }

That does seem to fix it, and some basic tests are looking good.

I notice you submitted this as part of your larger series to remove
bootmem - are you still happy for me to take this one through mips-next?

Thanks,
    Paul
