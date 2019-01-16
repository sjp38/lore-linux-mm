Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA5CE8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:18:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so4881376pfr.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:18:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g12si6575142pll.428.2019.01.16.07.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:18:37 -0800 (PST)
Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0D33C20873
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:18:37 +0000 (UTC)
Received: by mail-qt1-f177.google.com with SMTP id n32so7460407qte.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:18:37 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 16 Jan 2019 09:18:24 -0600
Message-ID: <CAL_JsqJv=+SQwmbwuw1C5Rv9sFHhk4SiP=Z_cKJu3HG5kdwhrg@mail.gmail.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-um@lists.infradead.org, Linux USB List <linux-usb@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Openrisc <openrisc@lists.librecores.org>, sparclinux@vger.kernel.org, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xenproject.org

On Wed, Jan 16, 2019 at 7:46 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
>
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> size, align);
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/alpha/kernel/core_cia.c              |  3 +++
>  arch/alpha/kernel/core_marvel.c           |  6 ++++++
>  arch/alpha/kernel/pci-noop.c              | 11 ++++++++++-
>  arch/alpha/kernel/pci.c                   | 11 ++++++++++-
>  arch/alpha/kernel/pci_iommu.c             | 12 ++++++++++++
>  arch/arc/mm/highmem.c                     |  4 ++++
>  arch/arm/kernel/setup.c                   |  6 ++++++
>  arch/arm/mm/mmu.c                         | 14 +++++++++++++-
>  arch/arm64/kernel/setup.c                 |  9 ++++++---
>  arch/arm64/mm/kasan_init.c                | 10 ++++++++++
>  arch/c6x/mm/dma-coherent.c                |  4 ++++
>  arch/c6x/mm/init.c                        |  3 +++
>  arch/csky/mm/highmem.c                    |  5 +++++
>  arch/h8300/mm/init.c                      |  3 +++
>  arch/m68k/atari/stram.c                   |  4 ++++
>  arch/m68k/mm/init.c                       |  3 +++
>  arch/m68k/mm/mcfmmu.c                     |  6 ++++++
>  arch/m68k/mm/motorola.c                   |  9 +++++++++
>  arch/m68k/mm/sun3mmu.c                    |  6 ++++++
>  arch/m68k/sun3/sun3dvma.c                 |  3 +++
>  arch/microblaze/mm/init.c                 |  8 ++++++--
>  arch/mips/cavium-octeon/dma-octeon.c      |  3 +++
>  arch/mips/kernel/setup.c                  |  3 +++
>  arch/mips/kernel/traps.c                  |  3 +++
>  arch/mips/mm/init.c                       |  5 +++++
>  arch/nds32/mm/init.c                      | 12 ++++++++++++
>  arch/openrisc/mm/ioremap.c                |  8 ++++++--
>  arch/powerpc/kernel/dt_cpu_ftrs.c         |  5 +++++
>  arch/powerpc/kernel/pci_32.c              |  3 +++
>  arch/powerpc/kernel/setup-common.c        |  3 +++
>  arch/powerpc/kernel/setup_64.c            |  4 ++++
>  arch/powerpc/lib/alloc.c                  |  3 +++
>  arch/powerpc/mm/hash_utils_64.c           |  3 +++
>  arch/powerpc/mm/mmu_context_nohash.c      |  9 +++++++++
>  arch/powerpc/mm/pgtable-book3e.c          | 12 ++++++++++--
>  arch/powerpc/mm/pgtable-book3s64.c        |  3 +++
>  arch/powerpc/mm/pgtable-radix.c           |  9 ++++++++-
>  arch/powerpc/mm/ppc_mmu_32.c              |  3 +++
>  arch/powerpc/platforms/pasemi/iommu.c     |  3 +++
>  arch/powerpc/platforms/powermac/nvram.c   |  3 +++
>  arch/powerpc/platforms/powernv/opal.c     |  3 +++
>  arch/powerpc/platforms/powernv/pci-ioda.c |  8 ++++++++
>  arch/powerpc/platforms/ps3/setup.c        |  3 +++
>  arch/powerpc/sysdev/msi_bitmap.c          |  3 +++
>  arch/s390/kernel/setup.c                  | 13 +++++++++++++
>  arch/s390/kernel/smp.c                    |  5 ++++-
>  arch/s390/kernel/topology.c               |  6 ++++++
>  arch/s390/numa/mode_emu.c                 |  3 +++
>  arch/s390/numa/numa.c                     |  6 +++++-
>  arch/s390/numa/toptree.c                  |  8 ++++++--
>  arch/sh/mm/init.c                         |  6 ++++++
>  arch/sh/mm/numa.c                         |  4 ++++
>  arch/um/drivers/net_kern.c                |  3 +++
>  arch/um/drivers/vector_kern.c             |  3 +++
>  arch/um/kernel/initrd.c                   |  2 ++
>  arch/um/kernel/mem.c                      | 16 ++++++++++++++++
>  arch/unicore32/kernel/setup.c             |  4 ++++
>  arch/unicore32/mm/mmu.c                   | 15 +++++++++++++--
>  arch/x86/kernel/acpi/boot.c               |  3 +++
>  arch/x86/kernel/apic/io_apic.c            |  5 +++++
>  arch/x86/kernel/e820.c                    |  3 +++
>  arch/x86/platform/olpc/olpc_dt.c          |  3 +++
>  arch/x86/xen/p2m.c                        | 11 +++++++++--
>  arch/xtensa/mm/kasan_init.c               |  4 ++++
>  arch/xtensa/mm/mmu.c                      |  3 +++
>  drivers/clk/ti/clk.c                      |  3 +++
>  drivers/macintosh/smu.c                   |  3 +++
>  drivers/of/fdt.c                          |  8 +++++++-
>  drivers/of/unittest.c                     |  8 +++++++-

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/xen/swiotlb-xen.c                 |  7 +++++--
>  kernel/power/snapshot.c                   |  3 +++
>  lib/cpumask.c                             |  3 +++
>  mm/kasan/init.c                           | 10 ++++++++--
>  mm/sparse.c                               | 19 +++++++++++++++++--
>  74 files changed, 415 insertions(+), 29 deletions(-)
