Date: Wed, 25 Jul 2007 13:36:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1-mm1
Message-Id: <20070725133655.849574b5.akpm@linux-foundation.org>
In-Reply-To: <64bb37e0707251322w38d19814pacea61d8cf69be63@mail.gmail.com>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<46A7411C.80202@fr.ibm.com>
	<200707251323.04594.lenb@kernel.org>
	<20070725115804.5b8efe83.akpm@linux-foundation.org>
	<64bb37e0707251213t6edcb0a5sabcf4a923c19bde7@mail.gmail.com>
	<64bb37e0707251322w38d19814pacea61d8cf69be63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Cc: Len Brown <lenb@kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, linux-kernel@vger.kernel.org, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007 22:22:41 +0200
"Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> On 7/25/07, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> > I hit something similar:
> >
> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > drivers/built-in.o: In function `acpi_pci_choose_state':
> > drivers/pci/pci-acpi.c:253: undefined reference to `acpi_pm_device_sleep_state'
> > drivers/built-in.o: In function `pnpacpi_suspend':
> > drivers/pnp/pnpacpi/core.c:124: undefined reference to
> > `acpi_pm_device_sleep_state'
> > make: *** [.tmp_vmlinux1] Error 1
> >
> > I also have CONFIG_SMP=y and CONFIG_HOTPLUG_CPU=n
> >
> > Will try to investigate more...
> 
> Removing (!SMP || SUSPEND_SMP) from the depends of ACPI_SLEEP and
> activation this option lets me build the kernel.

Yes, I'm trying to hunt down a fix for that.  Apparently it got repaired in
the acpi pull which Linus just did.

Maybe your fix is suitable?

> But it does not boot:

argh.

> [    0.000000] Linux version 2.6.23-rc1-mm1 (root@treogen) (gcc
> version 4.2.0 (Gentoo 4.2.0 p1.4)) #3 SMP Wed Jul 25 21:18:44 CEST
> 2007
> [    0.000000] Command line: earlyprintk=serial,ttyS0,38400
> console=ttyS0,38400 console=tty1 crypt_root=/dev/md1
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
> [    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfff0000 (usable)
> [    0.000000]  BIOS-e820: 00000000dfff0000 - 00000000dfffe000 (ACPI data)
> [    0.000000]  BIOS-e820: 00000000dfffe000 - 00000000e0000000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fef00000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ff700000 - 0000000100000000 (reserved)
> [    0.000000]  BIOS-e820: 0000000100000000 - 0000000120000000 (usable)
> [    0.000000] console [earlyser0] enabled
> [    0.000000] end_pfn_map = 1179648
> kernel direct mapping tables up to 120000000 @ 8000-e000
> [    0.000000] DMI present.
> [    0.000000] ACPI: RSDP 000FB5E0, 0014 (r0 ACPIAM)
> [    0.000000] ACPI: RSDT DFFF0000, 003C (r1 A M I  OEMRSDT   6000626
> MSFT       97)
> [    0.000000] ACPI: FACP DFFF0200, 0084 (r2 A M I  OEMFACP   6000626
> MSFT       97)
> [    0.000000] ACPI: DSDT DFFF0450, 48E1 (r1  S0027 S0027000        0
> INTL 20051117)
> [    0.000000] ACPI: FACS DFFFE000, 0040
> [    0.000000] ACPI: APIC DFFF0390, 0080 (r1 A M I  OEMAPIC   6000626
> MSFT       97)
> [    0.000000] ACPI: MCFG DFFF0410, 003C (r1 A M I  OEMMCFG   6000626
> MSFT       97)
> [    0.000000] ACPI: OEMB DFFFE040, 0060 (r1 A M I  AMI_OEM   6000626
> MSFT       97)
> [    0.000000] ACPI: SRAT DFFF4D40, 0110 (r1 AMD    HAMMER          1
> AMD         1)
> [    0.000000] ACPI: SSDT DFFF4E50, 04F0 (r1 A M I  ACPI2PPC        1
> AMI         1)
> [    0.000000] SRAT: PXM 0 -> APIC 0 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 1 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 2 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 3 -> Node 1
> [    0.000000] SRAT: Node 0 PXM 0 0-a0000
> [    0.000000] SRAT: Node 0 PXM 0 0-80000000
> [    0.000000] SRAT: Node 1 PXM 1 80000000-e0000000
> [    0.000000] SRAT: Node 1 PXM 1 80000000-120000000
> [    0.000000] Bootmem setup node 0 0000000000000000-0000000080000000
> [    0.000000] Bootmem setup node 1 0000000080000000-0000000120000000
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA             0 ->     4096
> [    0.000000]   DMA32        4096 ->  1048576
> [    0.000000]   Normal    1048576 ->  1179648
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[4] active PFN ranges
> [    0.000000]     0:        0 ->      159
> [    0.000000]     0:      256 ->   524288
> [    0.000000]     1:   524288 ->   917488
> [    0.000000]     1:  1048576 ->  1179648
> PANIC: early exception rip ffffffff807caac5 error 2 cr2 ffffe20003000010
> [    0.000000]
> [    0.000000] Call Trace:
> 
> ... but no Call Trace follows.
> 
> (gdb) list *0xffffffff807caac5
> 0xffffffff807caac5 is in memmap_init_zone (include/linux/list.h:32).
> 27      #define LIST_HEAD(name) \
> 28              struct list_head name = LIST_HEAD_INIT(name)
> 29
> 30      static inline void INIT_LIST_HEAD(struct list_head *list)
> 31      {
> 32              list->next = list;
> 33              list->prev = list;
> 34      }
> 35
> 36      /*
> 
> Torsten

Quite a few people have been playing in that area.  Can you please send the
.config?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
