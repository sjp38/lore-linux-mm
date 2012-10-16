Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A2D216B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 01:02:40 -0400 (EDT)
Message-ID: <1350363767.24332.9.camel@gitbox>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: Tony Prisk <linux@prisktech.co.nz>
Date: Tue, 16 Oct 2012 18:02:47 +1300
In-Reply-To: <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
References: <1350192523.10946.4.camel@gitbox>
	 <1350246895.11504.6.camel@gitbox> <20121015094547.GC29125@suse.de>
	 <1350325704.31162.16.camel@gitbox>
	 <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
Content-Type: multipart/mixed; boundary="=-EYyTEEIKooVITjPXnJO4"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Bob Liu <lliubbo@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Mel Gorman <mgorman@suse.de>, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>


--=-EYyTEEIKooVITjPXnJO4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2012-10-16 at 10:17 +0800, Bob Liu wrote:
> On Tue, Oct 16, 2012 at 2:28 AM, Tony Prisk <linux@prisktech.co.nz> wrote:
> > On Mon, 2012-10-15 at 10:45 +0100, Mel Gorman wrote:
> >> On Mon, Oct 15, 2012 at 09:34:55AM +1300, Tony Prisk wrote:
> >> > On Sun, 2012-10-14 at 18:28 +1300, Tony Prisk wrote:
> >> > > Up until 07 Oct, drivers/video/wm8505-fb.c was working fine, but on the
> >> > > 11 Oct when I did another pull from linus all of a sudden
> >> > > dma_alloc_coherent is failing to allocate the framebuffer any longer.
> >> > >
> >> > > I did a quick look back and found this:
> >> > >
> >> > > ARM: add coherent dma ops
> >> > >
> >> > > arch_is_coherent is problematic as it is a global symbol. This
> >> > > doesn't work for multi-platform kernels or platforms which can support
> >> > > per device coherent DMA.
> >> > >
> >> > > This adds arm_coherent_dma_ops to be used for devices which connected
> >> > > coherently (i.e. to the ACP port on Cortex-A9 or A15). The arm_dma_ops
> >> > > are modified at boot when arch_is_coherent is true.
> >> > >
> >> > > Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> >> > > Cc: Russell King <linux@arm.linux.org.uk>
> >> > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> >> > > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >> > >
> >> > >
> >> > > This is the only patch lately that I could find (not that I would claim
> >> > > to be any good at finding things) that is related to the problem. Could
> >> > > it have caused the allocations to fail?
> >> > >
> >> > > Regards
> >> > > Tony P
> >> >
> >> > Have done a bit more digging and found the cause - not Rob's patch so
> >> > apologies.
> >> >
> >> > The cause of the regression is this patch:
> >> >
> >> > From f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e Mon Sep 17 00:00:00 2001
> >> > From: Mel Gorman <mgorman@suse.de>
> >> > Date: Mon, 8 Oct 2012 16:32:36 -0700
> >> > Subject: [PATCH 2/3] mm: compaction: acquire the zone->lock as late as
> >> >  possible
> >> >
> >> > Up until then, the framebuffer allocation with dma_alloc_coherent(...)
> >> > was fine. From this patch onwards, allocations fail.
> >> >
> >>
> >> Was this found through bisection or some other means?
> >>
> >> There was a bug in that series that broke CMA but it was commit bb13ffeb
> >> (mm: compaction: cache if a pageblock was scanned and no pages were
> >> isolated) and it was fixed by 62726059 (mm: compaction: fix bit ranges
> >> in {get,clear,set}_pageblock_skip()). So it should have been fixed by
> >> 3.7-rc1 and probably was included by the time you pulled in October 11th
> >> but bisection would be a pain. There were problems with that series during
> >> development but tests were completing for other people.
> >>
> >> Just in case, is this still broken in 3.7-rc1?
> >
> > Still broken. Although the printk's might have cleared it up a bit.
> >>
> >> > I don't know how this patch would effect CMA allocations, but it seems
> >> > to be causing the issue (or at least, it's caused an error in
> >> > arch-vt8500 to become visible).
> >> >
> >> > Perhaps someone who understand -mm could explain the best way to
> >> > troubleshoot the cause of this problem?
> >> >
> >>
> >> If you are comfortable with ftrace, it can be used to narrow down where
> >> the exact failure is occurring but if you're not comfortable with that
> >> then the easiest is a bunch of printks starting in alloc_contig_range()
> >> to see at what point and why it returns failure.
> >>
> >> It's not obvious at the moment why that patch would cause an allocation
> >> problem. It's the type of patch that if it was wrong it would fail every
> >> time for everyone, not just for a single driver.
> >>
> >
> > I added some printk's to see what was happening.
> >
> > from arch/arm/mm/dma-mapping.c: arm_dma_alloc(..) it calls out to:
> > dma_alloc_from_coherent().
> >
> > This returns 0, because:
> > mem = dev->dma_mem
> > if (!mem) return 0;
> >
> > and then arm_dma_alloc() falls back on __dma_alloc(..)
> >
> >
> > I suspect the reason this fault is a bit 'weird' is because its
> > effectively not using alloc_from_coherent at all, but falling back on
> > __dma_alloc all the time, and sometimes it fails.
> >
> 
> I think you need to declare that memory using
> dma_declare_coherent_memory() before
> alloc_from_coherent.

I can't dma_declare_coherent_memory() because I don't have the memory
yet. We are trying to avoid 'reserving' a block of memory for the
framebuffer by requesting it in probe().

> 
> > Why it caused a problem on that particular commit I don't know - but it
> > was reproducible by adding/removing it.
> >
> >
> > Regards
> > Tony P
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

I did a bit more testing, and I've figured out why its different between
CMA and non-CMA.

in arch/arm/mm/dma-mapping.c

static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t
*handle,
			 gfp_t gfp, pgprot_t prot, bool is_coherent, const void *caller)
{
...
	if (is_coherent || nommu())
		addr = __alloc_simple_buffer(dev, size, gfp, &page);
	else if (gfp & GFP_ATOMIC)
		addr = __alloc_from_pool(size, &page);
	else if (!IS_ENABLED(CONFIG_CMA))
		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
	else
		addr = __alloc_from_contiguous(dev, size, prot, &page);
...

With CMA enabled, it calls __alloc_from_contiguous.
Without CMA, it calls __alloc_remap_buffer.

__alloc_from_contiguous() calls into dma_alloc_from_contiguous().

This shows count=375, align=8 which makes sense (375*4K = ~1.5MB).
The 256 page alignment was a concern, so I limited it to 4, but it made
no difference either.

The for(;;) loop goes through the entire cma bitmap, but
alloc_contig_range() returns -16 on every call.

I have attached a kernel log with some of my debug messages. CMA was
16MB during this run, with max-order=4. It appears it simply can't find
enough contiguous memory.

Hopefully someone can see something that makes sense.

Regards
Tony P

--=-EYyTEEIKooVITjPXnJO4
Content-Disposition: attachment; filename="max-order-4.cap.txt"
Content-Type: text/plain; name="max-order-4.cap.txt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit



WonderMedia Technologies, Inc.
W-Load Version : 0.16.00.02
UPDATE_ID_1_4_4_0_2_256MB_0160002
ethaddr............found
wloader finish


U-Boot 1.1.4 (May 12 2011 - 15:34:56)
WonderMedia Technologies, Inc.
U-Boot Version : UPDATEID_0.04.00.00.07
U-Boot code: 03F80000 -> 03FC2A30  BSS: -> 03FCCC4C
boot from spi flash.
SF0: ManufID = C2, DeviceID = 2013 (Missing or Unknown FLASH)
     Use Default - Total size = 8MB, Sector size = 64KB
SF1: ManufID = FF, DeviceID = FFFF (Missing or Unknown FLASH)
     Use Default - Total size = 8MB, Sector size = 64KB
flash:
     Bank1: FF800000 -- FFFFFFFF
     Bank2: FF000000 -- FF7FFFFF
Flash: 16 MB
sfboot NAND:env nand config fail, use default flash id list info
pllb=0xc2a, spec_clk=0x140a0c64
T1=2, clk1=15, div1=6, Thold=1, tREA=20+delay(9)
T2=1, clk2=29, div2=11, Thold2=1, comp=1
Tim1=368640 , Tim2=475136
T2 is greater and not use
T=2, clk=15, divisor=6, Thold=0x201
divisor is set 0x6, NFC_timing=0x2424
USE_HW_ECC ECC24bitPer1K
1 Nand flash found.

Nand Flash Size: 2048 MB

In:    serial
Out:   serial
Err:   serial
### main_loop entered: bootdelay=1

logocmd="nandrw r ${wmt.nfc.mtd.u-boot-logo} ${wmt.display.logoaddr} 10000; nandrw r ${wmt.nfc.mtd.u-boot-logo2} ${wmt.display.logoaddr2} 40000; nandrw r ${wmt.nfc.mtd.kernel-logo} ${wmt.kernel.animation.addr} 80000; display init force; decompanima -f ${wmt.display.logoaddr2} 0x3000000; decompanima -f ${wmt.display.logoaddr} 0x3000000"
Load Image From NAND Flash
col=0x2150,  row = 0x3ff00
block1023 tag=42627430  version =1
col=0x2150,  row = 0x3fe00
block1022 tag=31746242  version =1
bbt table is found
USE_HW_ECC ECC24bitPer1K

Read NAND Flash OK
Load Image From NAND Flash
USE_HW_ECC ECC24bitPer1K

Read NAND Flash OK
Load Image From NAND Flash
USE_HW_ECC ECC24bitPer1K

Read NAND Flash OK
[VOUT] ext dev : LCD
[VOUT] int dev : NO
[LCD] wmt default lcd (id 4,bpp 24)
vpp_config(800x480@60),pixclock 40000000
div_addr_offs=0x35c PLL_NO=1 
[VPP] get base clock PLLC : 350000000
1div_addr_offs=0x374 PLL_NO=2 
find the equal valuePLLN64, PLLD5, PLLP2, divisor2 freq=40000000Hz 
PLL0x5440, pll addr =0xd8130208
PLLN64, PLLD5, PLLP2, div2 div_addr_offs=0x374
read divisor=2, pll=0x5440 from register
[GOVRH] set clock 40000000 ==> 40000000
div_addr_offs=0x374 PLL_NO=2 
[VPP] get base clock PLLB : 40000000
vo_lcd_visible(1)
### main_loop: bootcmd="nandrw r ${kernel-NAND_ofs} 0x1000000 ${kernel-NAND_len}; if iminfo 0x1000000; then run kernelargs; bootm 0x1000000; fi; echo No kernel found"
Hit any key to stop autoboot:  1  0 

Initial SD/MMC Card OK!
SD/MMC clock is 25Mhz
register mmc device
part_offset : 2000, cur_part : 1
part_offset : 2000, cur_part : 1
reading wmt_scriptcmd

258 bytes read
## Executing script at 00000000
** Script length: 186
Unknown command 'lcdinit' - try 'help'
x=30, y=30
argv[0] = textout, argv[1]=30, argv[2]=30, argv[3]=Booting Linux Image
<ERROR> please specify the text begin with " 
Usage:
textout - show text to the screen 
textout x y "str" color
color is 24bit Hex, R[23:16], G[15:8], B[7:0]
for example: textout 0 0 \"hello world\" FFFFFF

part_offset : 2000, cur_part : 1
reading /script/uzImage.bin

1947983 bytes read
## Booting image at 00000000 ...
   Image Name:   WM8650 Linux
   Image Type:   ARM Linux Kernel Image (uncompressed)
   Data Size:    1947919 Bytes =  1.9 MB
   Load Address: 00008000
   Entry Point:  00008000
   Verifying Checksum ... OK
OK
No initrd
## Transferring control to Linux (at address 00008000) ...

Starting kernel ...

Uncompressing Linux... done, booting the kernel.
[    0.000000] Booting Linux on physical CPU 0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.7.0-rc1+ (sentient@gitbox) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #219 Tue Oct 16 17:47:35 NZDT 2012
[    0.000000] CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=00053177
[    0.000000] CPU: VIVT data cache, VIVT instruction cache
[    0.000000] Machine: VIA/Wondermedia SoC (Device Tree Support), model: Wondermedia WM8650-MID Tablet
[    0.000000] cma: CMA: reserved 16 MiB at 07000000
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
[    0.000000] Kernel command line: earlyprintk console=ttyWMT0,115200n8 mem=128M root=/dev/sda1 rootdelay=5
[    0.000000] PID hash table entries: 512 (order: -1, 2048 bytes)
[    0.000000] Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
[    0.000000] Memory: 128MB = 128MB total
[    0.000000] Memory: 109616k/109616k available, 21456k reserved, 0K highmem
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xc8800000 - 0xff000000   ( 872 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xc8000000   ( 128 MB)
[    0.000000]       .text : 0xc0008000 - 0xc0347884   (3327 kB)
[    0.000000]       .init : 0xc0348000 - 0xc03649e8   ( 115 kB)
[    0.000000]       .data : 0xc0366000 - 0xc0399ec8   ( 208 kB)
[    0.000000]        .bss : 0xc0399eec - 0xc03c5130   ( 173 kB)
[    0.000000] NR_IRQS:128
[    0.000000] Added IRQ Controller @ f8140000 [virq_base = 0]
[    0.000000] Added IRQ Controller @ f8150000 [virq_base = 64]
[    0.000000] vt8500-irq: Enabled slave->parent interrupts
[    0.000000] sched_clock: 32 bits at 100 Hz, resolution 10000000ns, wraps every 4294967286ms
[    0.000000] Console: colour dummy device 80x30
[    0.070000] Calibrating delay loop... 299.82 BogoMIPS (lpj=1499136)
[    0.070000] pid_max: default: 32768 minimum: 301
[    0.070000] Security Framework initialized
[    0.070000] Mount-cache hash table entries: 512
[    0.070000] Initializing cgroup subsys cpuacct
[    0.070000] Initializing cgroup subsys devices
[    0.070000] CPU: Testing write buffer coherency: ok
[    0.070000] Setting up static identity map for 0x2858a0 - 0x2858dc
[    0.080000] NET: Registered protocol family 16
[    0.080000] dma_alloc_from_contiguous(cma c683c7a0, count 64, align 4)
[    0.080000] pageno = 0
[    0.080000] alloc_contig_range(pfn=28672) ret=-16
[    0.080000] start = 16
[    0.080000] pageno = 16
[    0.080000] alloc_contig_range(pfn=28688) ret=-16
[    0.080000] start = 32
[    0.080000] pageno = 32
[    0.080000] alloc_contig_range(pfn=28704) ret=-16
[    0.080000] start = 48
[    0.080000] pageno = 48
[    0.090000] alloc_contig_range(pfn=28720) ret=-16
[    0.090000] start = 64
[    0.090000] pageno = 64
[    0.090000] alloc_contig_range(pfn=28736) ret=-16
[    0.090000] start = 80
[    0.090000] pageno = 80
[    0.090000] alloc_contig_range(pfn=28752) ret=-16
[    0.090000] start = 96
[    0.090000] pageno = 96
[    0.090000] alloc_contig_range(pfn=28768) ret=-16
[    0.090000] start = 112
[    0.090000] pageno = 112
[    0.090000] alloc_contig_range(pfn=28784) ret=-16
[    0.090000] start = 128
[    0.090000] pageno = 128
[    0.100000] alloc_contig_range(pfn=28800) ret=-16
[    0.100000] start = 144
[    0.100000] pageno = 144
[    0.100000] alloc_contig_range(pfn=28816) ret=-16
[    0.100000] start = 160
[    0.100000] pageno = 160
[    0.100000] alloc_contig_range(pfn=28832) ret=-16
[    0.100000] start = 176
[    0.100000] pageno = 176
[    0.100000] alloc_contig_range(pfn=28848) ret=-16
[    0.100000] start = 192
[    0.100000] pageno = 192
[    0.100000] alloc_contig_range(pfn=28864) ret=-16
[    0.100000] start = 208
[    0.100000] pageno = 208
[    0.110000] alloc_contig_range(pfn=28880) ret=-16
[    0.110000] start = 224
[    0.110000] pageno = 224
[    0.110000] alloc_contig_range(pfn=28896) ret=-16
[    0.110000] start = 240
[    0.110000] pageno = 240
[    0.110000] alloc_contig_range(pfn=28912) ret=-16
[    0.110000] start = 256
[    0.110000] pageno = 256
[    0.110000] alloc_contig_range(pfn=28928) ret=-16
[    0.110000] start = 272
[    0.110000] pageno = 272
[    0.120000] alloc_contig_range(pfn=28944) ret=-16
[    0.120000] start = 288
[    0.120000] pageno = 288
[    0.120000] alloc_contig_range(pfn=28960) ret=-16
[    0.120000] start = 304
[    0.120000] pageno = 304
[    0.120000] alloc_contig_range(pfn=28976) ret=-16
[    0.120000] start = 320
[    0.120000] pageno = 320
[    0.120000] alloc_contig_range(pfn=28992) ret=-16
[    0.120000] start = 336
[    0.120000] pageno = 336
[    0.120000] alloc_contig_range(pfn=29008) ret=-16
[    0.120000] start = 352
[    0.120000] pageno = 352
[    0.130000] alloc_contig_range(pfn=29024) ret=-16
[    0.130000] start = 368
[    0.130000] pageno = 368
[    0.130000] alloc_contig_range(pfn=29040) ret=-16
[    0.130000] start = 384
[    0.130000] pageno = 384
[    0.130000] alloc_contig_range(pfn=29056) ret=-16
[    0.130000] start = 400
[    0.130000] pageno = 400
[    0.130000] alloc_contig_range(pfn=29072) ret=-16
[    0.130000] start = 416
[    0.130000] pageno = 416
[    0.130000] alloc_contig_range(pfn=29088) ret=-16
[    0.130000] start = 432
[    0.130000] pageno = 432
[    0.140000] alloc_contig_range(pfn=29104) ret=-16
[    0.140000] start = 448
[    0.140000] pageno = 448
[    0.140000] alloc_contig_range(pfn=29120) ret=-16
[    0.140000] start = 464
[    0.140000] pageno = 464
[    0.140000] alloc_contig_range(pfn=29136) ret=-16
[    0.140000] start = 480
[    0.140000] pageno = 480
[    0.140000] alloc_contig_range(pfn=29152) ret=-16
[    0.140000] start = 496
[    0.140000] pageno = 496
[    0.140000] alloc_contig_range(pfn=29168) ret=-16
[    0.140000] start = 512
[    0.140000] pageno = 512
[    0.150000] alloc_contig_range(pfn=29184) ret=-16
[    0.150000] start = 528
[    0.150000] pageno = 528
[    0.150000] alloc_contig_range(pfn=29200) ret=-16
[    0.150000] start = 544
[    0.150000] pageno = 544
[    0.150000] alloc_contig_range(pfn=29216) ret=-16
[    0.150000] start = 560
[    0.150000] pageno = 560
[    0.150000] alloc_contig_range(pfn=29232) ret=-16
[    0.150000] start = 576
[    0.150000] pageno = 576
[    0.150000] alloc_contig_range(pfn=29248) ret=-16
[    0.150000] start = 592
[    0.150000] pageno = 592
[    0.160000] alloc_contig_range(pfn=29264) ret=-16
[    0.160000] start = 608
[    0.160000] pageno = 608
[    0.160000] alloc_contig_range(pfn=29280) ret=-16
[    0.160000] start = 624
[    0.160000] pageno = 624
[    0.160000] alloc_contig_range(pfn=29296) ret=-16
[    0.160000] start = 640
[    0.160000] pageno = 640
[    0.160000] alloc_contig_range(pfn=29312) ret=-16
[    0.160000] start = 656
[    0.160000] pageno = 656
[    0.160000] alloc_contig_range(pfn=29328) ret=-16
[    0.160000] start = 672
[    0.160000] pageno = 672
[    0.170000] alloc_contig_range(pfn=29344) ret=-16
[    0.170000] start = 688
[    0.170000] pageno = 688
[    0.170000] alloc_contig_range(pfn=29360) ret=-16
[    0.170000] start = 704
[    0.170000] pageno = 704
[    0.170000] alloc_contig_range(pfn=29376) ret=-16
[    0.170000] start = 720
[    0.170000] pageno = 720
[    0.170000] alloc_contig_range(pfn=29392) ret=-16
[    0.170000] start = 736
[    0.170000] pageno = 736
[    0.170000] alloc_contig_range(pfn=29408) ret=-16
[    0.170000] start = 752
[    0.170000] pageno = 752
[    0.180000] alloc_contig_range(pfn=29424) ret=-16
[    0.180000] start = 768
[    0.180000] pageno = 768
[    0.180000] alloc_contig_range(pfn=29440) ret=-16
[    0.180000] start = 784
[    0.180000] pageno = 784
[    0.180000] alloc_contig_range(pfn=29456) ret=-16
[    0.180000] start = 800
[    0.180000] pageno = 800
[    0.180000] alloc_contig_range(pfn=29472) ret=-16
[    0.180000] start = 816
[    0.180000] pageno = 816
[    0.190000] alloc_contig_range(pfn=29488) ret=-16
[    0.190000] start = 832
[    0.190000] pageno = 832
[    0.190000] alloc_contig_range(pfn=29504) ret=-16
[    0.190000] start = 848
[    0.190000] pageno = 848
[    0.190000] alloc_contig_range(pfn=29520) ret=-16
[    0.190000] start = 864
[    0.190000] pageno = 864
[    0.190000] alloc_contig_range(pfn=29536) ret=-16
[    0.190000] start = 880
[    0.190000] pageno = 880
[    0.190000] alloc_contig_range(pfn=29552) ret=-16
[    0.190000] start = 896
[    0.190000] pageno = 896
[    0.200000] alloc_contig_range(pfn=29568) ret=-16
[    0.200000] start = 912
[    0.200000] pageno = 912
[    0.200000] alloc_contig_range(pfn=29584) ret=-16
[    0.200000] start = 928
[    0.200000] pageno = 928
[    0.200000] alloc_contig_range(pfn=29600) ret=-16
[    0.200000] start = 944
[    0.200000] pageno = 944
[    0.200000] alloc_contig_range(pfn=29616) ret=-16
[    0.200000] start = 960
[    0.200000] pageno = 960
[    0.200000] alloc_contig_range(pfn=29632) ret=0
[    0.200000] dma_alloc_from_contiguous(): returned c04ad800
[    0.200000] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.210000] bio: create slab <bio-0> at 0
[    0.220000] SCSI subsystem initialized
[    0.220000] usbcore: registered new interface driver usbfs
[    0.220000] usbcore: registered new interface driver hub
[    0.220000] usbcore: registered new device driver usb
[    0.220000] Switching to clocksource vt8500_timer
[    0.230000] NET: Registered protocol family 2
[    0.230000] TCP established hash table entries: 4096 (order: 3, 32768 bytes)
[    0.230000] TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
[    0.230000] TCP: Hash tables configured (established 4096 bind 4096)
[    0.230000] TCP: reno registered
[    0.230000] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.230000] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.230000] NET: Registered protocol family 1
[    0.230000] msgmni has been set to 246
[    0.240000] alg: No test for stdrng (krng)
[    0.240000] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.240000] io scheduler noop registered
[    0.240000] io scheduler deadline registered (default)
[    0.240000] Enabled support for WMT GE raster acceleration
[    0.240000] __dma_alloc: __alloc_from_contiguous
[    0.240000] dma_alloc_from_contiguous(cma c683c7a0, count 375, align 4)
[    0.240000] pageno = 0
[    0.240000] alloc_contig_range(pfn=28672) ret=-16
[    0.240000] start = 16
[    0.240000] pageno = 16
[    0.250000] alloc_contig_range(pfn=28688) ret=-16
[    0.250000] start = 32
[    0.250000] pageno = 32
[    0.250000] alloc_contig_range(pfn=28704) ret=-16
[    0.250000] start = 48
[    0.250000] pageno = 48
[    0.250000] alloc_contig_range(pfn=28720) ret=-16
[    0.250000] start = 64
[    0.250000] pageno = 64
[    0.250000] alloc_contig_range(pfn=28736) ret=-16
[    0.250000] start = 80
[    0.250000] pageno = 80
[    0.250000] alloc_contig_range(pfn=28752) ret=-16
[    0.250000] start = 96
[    0.250000] pageno = 96
[    0.250000] alloc_contig_range(pfn=28768) ret=-16
[    0.250000] start = 112
[    0.250000] pageno = 112
[    0.250000] alloc_contig_range(pfn=28784) ret=-16
[    0.250000] start = 128
[    0.250000] pageno = 128
[    0.260000] alloc_contig_range(pfn=28800) ret=-16
[    0.260000] start = 144
[    0.260000] pageno = 144
[    0.260000] alloc_contig_range(pfn=28816) ret=-16
[    0.260000] start = 160
[    0.260000] pageno = 160
[    0.260000] alloc_contig_range(pfn=28832) ret=-16
[    0.260000] start = 176
[    0.260000] pageno = 176
[    0.260000] alloc_contig_range(pfn=28848) ret=-16
[    0.260000] start = 192
[    0.260000] pageno = 192
[    0.260000] alloc_contig_range(pfn=28864) ret=-16
[    0.260000] start = 208
[    0.260000] pageno = 208
[    0.270000] alloc_contig_range(pfn=28880) ret=-16
[    0.270000] start = 224
[    0.270000] pageno = 224
[    0.270000] alloc_contig_range(pfn=28896) ret=-16
[    0.270000] start = 240
[    0.270000] pageno = 240
[    0.270000] alloc_contig_range(pfn=28912) ret=-16
[    0.270000] start = 256
[    0.270000] pageno = 256
[    0.270000] alloc_contig_range(pfn=28928) ret=-16
[    0.270000] start = 272
[    0.270000] pageno = 272
[    0.270000] alloc_contig_range(pfn=28944) ret=-16
[    0.270000] start = 288
[    0.270000] pageno = 288
[    0.270000] alloc_contig_range(pfn=28960) ret=-16
[    0.270000] start = 304
[    0.270000] pageno = 304
[    0.280000] alloc_contig_range(pfn=28976) ret=-16
[    0.280000] start = 320
[    0.280000] pageno = 320
[    0.280000] alloc_contig_range(pfn=28992) ret=-16
[    0.280000] start = 336
[    0.280000] pageno = 336
[    0.280000] alloc_contig_range(pfn=29008) ret=-16
[    0.280000] start = 352
[    0.280000] pageno = 352
[    0.280000] alloc_contig_range(pfn=29024) ret=-16
[    0.280000] start = 368
[    0.280000] pageno = 368
[    0.280000] alloc_contig_range(pfn=29040) ret=-16
[    0.280000] start = 384
[    0.280000] pageno = 384
[    0.280000] alloc_contig_range(pfn=29056) ret=-16
[    0.280000] start = 400
[    0.280000] pageno = 400
[    0.290000] alloc_contig_range(pfn=29072) ret=-16
[    0.290000] start = 416
[    0.290000] pageno = 416
[    0.290000] alloc_contig_range(pfn=29088) ret=-16
[    0.290000] start = 432
[    0.290000] pageno = 432
[    0.290000] alloc_contig_range(pfn=29104) ret=-16
[    0.290000] start = 448
[    0.290000] pageno = 448
[    0.290000] alloc_contig_range(pfn=29120) ret=-16
[    0.290000] start = 464
[    0.290000] pageno = 464
[    0.290000] alloc_contig_range(pfn=29136) ret=-16
[    0.290000] start = 480
[    0.290000] pageno = 480
[    0.300000] alloc_contig_range(pfn=29152) ret=-16
[    0.300000] start = 496
[    0.300000] pageno = 496
[    0.300000] alloc_contig_range(pfn=29168) ret=-16
[    0.300000] start = 512
[    0.300000] pageno = 512
[    0.300000] alloc_contig_range(pfn=29184) ret=-16
[    0.300000] start = 528
[    0.300000] pageno = 528
[    0.300000] alloc_contig_range(pfn=29200) ret=-16
[    0.300000] start = 544
[    0.300000] pageno = 544
[    0.300000] alloc_contig_range(pfn=29216) ret=-16
[    0.300000] start = 560
[    0.300000] pageno = 560
[    0.300000] alloc_contig_range(pfn=29232) ret=-16
[    0.300000] start = 576
[    0.300000] pageno = 576
[    0.300000] alloc_contig_range(pfn=29248) ret=-16
[    0.300000] start = 592
[    0.300000] pageno = 1024
[    0.310000] alloc_contig_range(pfn=29696) ret=-16
[    0.310000] start = 1040
[    0.310000] pageno = 1040
[    0.310000] alloc_contig_range(pfn=29712) ret=-16
[    0.310000] start = 1056
[    0.310000] pageno = 1056
[    0.310000] alloc_contig_range(pfn=29728) ret=-16
[    0.310000] start = 1072
[    0.310000] pageno = 1072
[    0.310000] alloc_contig_range(pfn=29744) ret=-16
[    0.310000] start = 1088
[    0.310000] pageno = 1088
[    0.320000] alloc_contig_range(pfn=29760) ret=-16
[    0.320000] start = 1104
[    0.320000] pageno = 1104
[    0.320000] alloc_contig_range(pfn=29776) ret=-16
[    0.320000] start = 1120
[    0.320000] pageno = 1120
[    0.320000] alloc_contig_range(pfn=29792) ret=-16
[    0.320000] start = 1136
[    0.320000] pageno = 1136
[    0.320000] alloc_contig_range(pfn=29808) ret=-16
[    0.320000] start = 1152
[    0.320000] pageno = 1152
[    0.320000] alloc_contig_range(pfn=29824) ret=-16
[    0.320000] start = 1168
[    0.320000] pageno = 1168
[    0.330000] alloc_contig_range(pfn=29840) ret=-16
[    0.330000] start = 1184
[    0.330000] pageno = 1184
[    0.330000] alloc_contig_range(pfn=29856) ret=-16
[    0.330000] start = 1200
[    0.330000] pageno = 1200
[    0.330000] alloc_contig_range(pfn=29872) ret=-16
[    0.330000] start = 1216
[    0.330000] pageno = 1216
[    0.330000] alloc_contig_range(pfn=29888) ret=-16
[    0.330000] start = 1232
[    0.330000] pageno = 1232
[    0.330000] alloc_contig_range(pfn=29904) ret=-16
[    0.330000] start = 1248
[    0.330000] pageno = 1248
[    0.340000] alloc_contig_range(pfn=29920) ret=-16
[    0.340000] start = 1264
[    0.340000] pageno = 1264
[    0.340000] alloc_contig_range(pfn=29936) ret=-16
[    0.340000] start = 1280
[    0.340000] pageno = 1280
[    0.340000] alloc_contig_range(pfn=29952) ret=-16
[    0.340000] start = 1296
[    0.340000] pageno = 1296
[    0.340000] alloc_contig_range(pfn=29968) ret=-16
[    0.340000] start = 1312
[    0.340000] pageno = 1312
[    0.350000] alloc_contig_range(pfn=29984) ret=-16
[    0.350000] start = 1328
[    0.350000] pageno = 1328
[    0.350000] alloc_contig_range(pfn=30000) ret=-16
[    0.350000] start = 1344
[    0.350000] pageno = 1344
[    0.350000] alloc_contig_range(pfn=30016) ret=-16
[    0.350000] start = 1360
[    0.350000] pageno = 1360
[    0.350000] alloc_contig_range(pfn=30032) ret=-16
[    0.350000] start = 1376
[    0.350000] pageno = 1376
[    0.350000] alloc_contig_range(pfn=30048) ret=-16
[    0.350000] start = 1392
[    0.350000] pageno = 1392
[    0.360000] alloc_contig_range(pfn=30064) ret=-16
[    0.360000] start = 1408
[    0.360000] pageno = 1408
[    0.360000] alloc_contig_range(pfn=30080) ret=-16
[    0.360000] start = 1424
[    0.360000] pageno = 1424
[    0.360000] alloc_contig_range(pfn=30096) ret=-16
[    0.360000] start = 1440
[    0.360000] pageno = 1440
[    0.360000] alloc_contig_range(pfn=30112) ret=-16
[    0.360000] start = 1456
[    0.360000] pageno = 1456
[    0.360000] alloc_contig_range(pfn=30128) ret=-16
[    0.360000] start = 1472
[    0.360000] pageno = 1472
[    0.370000] alloc_contig_range(pfn=30144) ret=-16
[    0.370000] start = 1488
[    0.370000] pageno = 1488
[    0.370000] alloc_contig_range(pfn=30160) ret=-16
[    0.370000] start = 1504
[    0.370000] pageno = 1504
[    0.370000] alloc_contig_range(pfn=30176) ret=-16
[    0.370000] start = 1520
[    0.370000] pageno = 1520
[    0.370000] alloc_contig_range(pfn=30192) ret=-16
[    0.370000] start = 1536
[    0.370000] pageno = 1536
[    0.370000] alloc_contig_range(pfn=30208) ret=-16
[    0.370000] start = 1552
[    0.370000] pageno = 1552
[    0.380000] alloc_contig_range(pfn=30224) ret=-16
[    0.380000] start = 1568
[    0.380000] pageno = 1568
[    0.380000] alloc_contig_range(pfn=30240) ret=-16
[    0.380000] start = 1584
[    0.380000] pageno = 1584
[    0.380000] alloc_contig_range(pfn=30256) ret=-16
[    0.380000] start = 1600
[    0.380000] pageno = 1600
[    0.380000] alloc_contig_range(pfn=30272) ret=-16
[    0.380000] start = 1616
[    0.380000] pageno = 1616
[    0.390000] alloc_contig_range(pfn=30288) ret=-16
[    0.390000] start = 1632
[    0.390000] pageno = 1632
[    0.390000] alloc_contig_range(pfn=30304) ret=-16
[    0.390000] start = 1648
[    0.390000] pageno = 1648
[    0.390000] alloc_contig_range(pfn=30320) ret=-16
[    0.390000] start = 1664
[    0.390000] pageno = 1664
[    0.390000] alloc_contig_range(pfn=30336) ret=-16
[    0.390000] start = 1680
[    0.390000] pageno = 1680
[    0.400000] alloc_contig_range(pfn=30352) ret=-16
[    0.400000] start = 1696
[    0.400000] pageno = 1696
[    0.400000] alloc_contig_range(pfn=30368) ret=-16
[    0.400000] start = 1712
[    0.400000] pageno = 1712
[    0.400000] alloc_contig_range(pfn=30384) ret=-16
[    0.400000] start = 1728
[    0.400000] pageno = 1728
[    0.410000] alloc_contig_range(pfn=30400) ret=-16
[    0.410000] start = 1744
[    0.410000] pageno = 1744
[    0.410000] alloc_contig_range(pfn=30416) ret=-16
[    0.410000] start = 1760
[    0.410000] pageno = 1760
[    0.410000] alloc_contig_range(pfn=30432) ret=-16
[    0.410000] start = 1776
[    0.410000] pageno = 1776
[    0.420000] alloc_contig_range(pfn=30448) ret=-16
[    0.420000] start = 1792
[    0.420000] pageno = 1792
[    0.420000] alloc_contig_range(pfn=30464) ret=-16
[    0.420000] start = 1808
[    0.420000] pageno = 1808
[    0.420000] alloc_contig_range(pfn=30480) ret=-16
[    0.420000] start = 1824
[    0.420000] pageno = 1824
[    0.430000] alloc_contig_range(pfn=30496) ret=-16
[    0.430000] start = 1840
[    0.430000] pageno = 1840
[    0.430000] alloc_contig_range(pfn=30512) ret=-16
[    0.430000] start = 1856
[    0.430000] pageno = 1856
[    0.440000] alloc_contig_range(pfn=30528) ret=-16
[    0.440000] start = 1872
[    0.440000] pageno = 1872
[    0.440000] alloc_contig_range(pfn=30544) ret=-16
[    0.440000] start = 1888
[    0.440000] pageno = 1888
[    0.440000] alloc_contig_range(pfn=30560) ret=-16
[    0.440000] start = 1904
[    0.440000] pageno = 1904
[    0.450000] alloc_contig_range(pfn=30576) ret=-16
[    0.450000] start = 1920
[    0.450000] pageno = 1920
[    0.450000] alloc_contig_range(pfn=30592) ret=-16
[    0.450000] start = 1936
[    0.450000] pageno = 1936
[    0.450000] alloc_contig_range(pfn=30608) ret=-16
[    0.450000] start = 1952
[    0.450000] pageno = 1952
[    0.460000] alloc_contig_range(pfn=30624) ret=-16
[    0.460000] start = 1968
[    0.460000] pageno = 1968
[    0.460000] alloc_contig_range(pfn=30640) ret=-16
[    0.460000] start = 1984
[    0.460000] pageno = 1984
[    0.470000] alloc_contig_range(pfn=30656) ret=-16
[    0.470000] start = 2000
[    0.470000] pageno = 2000
[    0.470000] alloc_contig_range(pfn=30672) ret=-16
[    0.470000] start = 2016
[    0.470000] pageno = 2016
[    0.470000] alloc_contig_range(pfn=30688) ret=-16
[    0.470000] start = 2032
[    0.470000] pageno = 2032
[    0.480000] alloc_contig_range(pfn=30704) ret=-16
[    0.480000] start = 2048
[    0.480000] pageno = 2048
[    0.480000] alloc_contig_range(pfn=30720) ret=-16
[    0.480000] start = 2064
[    0.480000] pageno = 2064
[    0.480000] alloc_contig_range(pfn=30736) ret=-16
[    0.480000] start = 2080
[    0.480000] pageno = 2080
[    0.480000] alloc_contig_range(pfn=30752) ret=-16
[    0.480000] start = 2096
[    0.480000] pageno = 2096
[    0.480000] alloc_contig_range(pfn=30768) ret=-16
[    0.480000] start = 2112
[    0.480000] pageno = 2112
[    0.490000] alloc_contig_range(pfn=30784) ret=-16
[    0.490000] start = 2128
[    0.490000] pageno = 2128
[    0.490000] alloc_contig_range(pfn=30800) ret=-16
[    0.490000] start = 2144
[    0.490000] pageno = 2144
[    0.490000] alloc_contig_range(pfn=30816) ret=-16
[    0.490000] start = 2160
[    0.490000] pageno = 2160
[    0.490000] alloc_contig_range(pfn=30832) ret=-16
[    0.490000] start = 2176
[    0.490000] pageno = 2176
[    0.500000] alloc_contig_range(pfn=30848) ret=-16
[    0.500000] start = 2192
[    0.500000] pageno = 2192
[    0.500000] alloc_contig_range(pfn=30864) ret=-16
[    0.500000] start = 2208
[    0.500000] pageno = 2208
[    0.500000] alloc_contig_range(pfn=30880) ret=-16
[    0.500000] start = 2224
[    0.500000] pageno = 2224
[    0.500000] alloc_contig_range(pfn=30896) ret=-16
[    0.500000] start = 2240
[    0.500000] pageno = 2240
[    0.500000] alloc_contig_range(pfn=30912) ret=-16
[    0.500000] start = 2256
[    0.500000] pageno = 2256
[    0.510000] alloc_contig_range(pfn=30928) ret=-16
[    0.510000] start = 2272
[    0.510000] pageno = 2272
[    0.510000] alloc_contig_range(pfn=30944) ret=-16
[    0.510000] start = 2288
[    0.510000] pageno = 2288
[    0.510000] alloc_contig_range(pfn=30960) ret=-16
[    0.510000] start = 2304
[    0.510000] pageno = 2304
[    0.510000] alloc_contig_range(pfn=30976) ret=-16
[    0.510000] start = 2320
[    0.510000] pageno = 2320
[    0.510000] alloc_contig_range(pfn=30992) ret=-16
[    0.510000] start = 2336
[    0.510000] pageno = 2336
[    0.520000] alloc_contig_range(pfn=31008) ret=-16
[    0.520000] start = 2352
[    0.520000] pageno = 2352
[    0.520000] alloc_contig_range(pfn=31024) ret=-16
[    0.520000] start = 2368
[    0.520000] pageno = 2368
[    0.520000] alloc_contig_range(pfn=31040) ret=-16
[    0.520000] start = 2384
[    0.520000] pageno = 2384
[    0.520000] alloc_contig_range(pfn=31056) ret=-16
[    0.520000] start = 2400
[    0.520000] pageno = 2400
[    0.530000] alloc_contig_range(pfn=31072) ret=-16
[    0.530000] start = 2416
[    0.530000] pageno = 2416
[    0.530000] alloc_contig_range(pfn=31088) ret=-16
[    0.530000] start = 2432
[    0.530000] pageno = 2432
[    0.530000] alloc_contig_range(pfn=31104) ret=-16
[    0.530000] start = 2448
[    0.530000] pageno = 2448
[    0.530000] alloc_contig_range(pfn=31120) ret=-16
[    0.530000] start = 2464
[    0.530000] pageno = 2464
[    0.530000] alloc_contig_range(pfn=31136) ret=-16
[    0.530000] start = 2480
[    0.530000] pageno = 2480
[    0.540000] alloc_contig_range(pfn=31152) ret=-16
[    0.540000] start = 2496
[    0.540000] pageno = 2496
[    0.540000] alloc_contig_range(pfn=31168) ret=-16
[    0.540000] start = 2512
[    0.540000] pageno = 2512
[    0.540000] alloc_contig_range(pfn=31184) ret=-16
[    0.540000] start = 2528
[    0.540000] pageno = 2528
[    0.540000] alloc_contig_range(pfn=31200) ret=-16
[    0.540000] start = 2544
[    0.540000] pageno = 2544
[    0.540000] alloc_contig_range(pfn=31216) ret=-16
[    0.540000] start = 2560
[    0.540000] pageno = 2560
[    0.550000] alloc_contig_range(pfn=31232) ret=-16
[    0.550000] start = 2576
[    0.550000] pageno = 2576
[    0.550000] alloc_contig_range(pfn=31248) ret=-16
[    0.550000] start = 2592
[    0.550000] pageno = 2592
[    0.550000] alloc_contig_range(pfn=31264) ret=-16
[    0.550000] start = 2608
[    0.550000] pageno = 2608
[    0.550000] alloc_contig_range(pfn=31280) ret=-16
[    0.550000] start = 2624
[    0.550000] pageno = 2624
[    0.550000] alloc_contig_range(pfn=31296) ret=-16
[    0.550000] start = 2640
[    0.550000] pageno = 2640
[    0.560000] alloc_contig_range(pfn=31312) ret=-16
[    0.560000] start = 2656
[    0.560000] pageno = 2656
[    0.560000] alloc_contig_range(pfn=31328) ret=-16
[    0.560000] start = 2672
[    0.560000] pageno = 2672
[    0.560000] alloc_contig_range(pfn=31344) ret=-16
[    0.560000] start = 2688
[    0.560000] pageno = 2688
[    0.560000] alloc_contig_range(pfn=31360) ret=-16
[    0.560000] start = 2704
[    0.560000] pageno = 2704
[    0.570000] alloc_contig_range(pfn=31376) ret=-16
[    0.570000] start = 2720
[    0.570000] pageno = 2720
[    0.570000] alloc_contig_range(pfn=31392) ret=-16
[    0.570000] start = 2736
[    0.570000] pageno = 2736
[    0.570000] alloc_contig_range(pfn=31408) ret=-16
[    0.570000] start = 2752
[    0.570000] pageno = 2752
[    0.580000] alloc_contig_range(pfn=31424) ret=-16
[    0.580000] start = 2768
[    0.580000] pageno = 2768
[    0.580000] alloc_contig_range(pfn=31440) ret=-16
[    0.580000] start = 2784
[    0.580000] pageno = 2784
[    0.590000] alloc_contig_range(pfn=31456) ret=-16
[    0.590000] start = 2800
[    0.590000] pageno = 2800
[    0.590000] alloc_contig_range(pfn=31472) ret=-16
[    0.590000] start = 2816
[    0.590000] pageno = 2816
[    0.590000] alloc_contig_range(pfn=31488) ret=-16
[    0.590000] start = 2832
[    0.590000] pageno = 2832
[    0.600000] alloc_contig_range(pfn=31504) ret=-16
[    0.600000] start = 2848
[    0.600000] pageno = 2848
[    0.600000] alloc_contig_range(pfn=31520) ret=-16
[    0.600000] start = 2864
[    0.600000] pageno = 2864
[    0.600000] alloc_contig_range(pfn=31536) ret=-16
[    0.600000] start = 2880
[    0.600000] pageno = 2880
[    0.610000] alloc_contig_range(pfn=31552) ret=-16
[    0.610000] start = 2896
[    0.610000] pageno = 2896
[    0.610000] alloc_contig_range(pfn=31568) ret=-16
[    0.610000] start = 2912
[    0.610000] pageno = 2912
[    0.610000] alloc_contig_range(pfn=31584) ret=-16
[    0.610000] start = 2928
[    0.610000] pageno = 2928
[    0.620000] alloc_contig_range(pfn=31600) ret=-16
[    0.620000] start = 2944
[    0.620000] pageno = 2944
[    0.620000] alloc_contig_range(pfn=31616) ret=-16
[    0.620000] start = 2960
[    0.620000] pageno = 2960
[    0.630000] alloc_contig_range(pfn=31632) ret=-16
[    0.630000] start = 2976
[    0.630000] pageno = 2976
[    0.630000] alloc_contig_range(pfn=31648) ret=-16
[    0.630000] start = 2992
[    0.630000] pageno = 2992
[    0.630000] alloc_contig_range(pfn=31664) ret=-16
[    0.630000] start = 3008
[    0.630000] pageno = 3008
[    0.640000] alloc_contig_range(pfn=31680) ret=-16
[    0.640000] start = 3024
[    0.640000] pageno = 3024
[    0.640000] alloc_contig_range(pfn=31696) ret=-16
[    0.640000] start = 3040
[    0.640000] pageno = 3040
[    0.640000] alloc_contig_range(pfn=31712) ret=-16
[    0.640000] start = 3056
[    0.640000] pageno = 3056
[    0.650000] alloc_contig_range(pfn=31728) ret=-16
[    0.650000] start = 3072
[    0.650000] pageno = 3072
[    0.650000] alloc_contig_range(pfn=31744) ret=-16
[    0.650000] start = 3088
[    0.650000] pageno = 3088
[    0.650000] alloc_contig_range(pfn=31760) ret=-16
[    0.650000] start = 3104
[    0.650000] pageno = 3104
[    0.650000] alloc_contig_range(pfn=31776) ret=-16
[    0.650000] start = 3120
[    0.650000] pageno = 3120
[    0.660000] alloc_contig_range(pfn=31792) ret=-16
[    0.660000] start = 3136
[    0.660000] pageno = 3136
[    0.660000] alloc_contig_range(pfn=31808) ret=-16
[    0.660000] start = 3152
[    0.660000] pageno = 3152
[    0.660000] alloc_contig_range(pfn=31824) ret=-16
[    0.660000] start = 3168
[    0.660000] pageno = 3168
[    0.660000] alloc_contig_range(pfn=31840) ret=-16
[    0.660000] start = 3184
[    0.660000] pageno = 3184
[    0.660000] alloc_contig_range(pfn=31856) ret=-16
[    0.660000] start = 3200
[    0.660000] pageno = 3200
[    0.670000] alloc_contig_range(pfn=31872) ret=-16
[    0.670000] start = 3216
[    0.670000] pageno = 3216
[    0.670000] alloc_contig_range(pfn=31888) ret=-16
[    0.670000] start = 3232
[    0.670000] pageno = 3232
[    0.670000] alloc_contig_range(pfn=31904) ret=-16
[    0.670000] start = 3248
[    0.670000] pageno = 3248
[    0.670000] alloc_contig_range(pfn=31920) ret=-16
[    0.670000] start = 3264
[    0.670000] pageno = 3264
[    0.680000] alloc_contig_range(pfn=31936) ret=-16
[    0.680000] start = 3280
[    0.680000] pageno = 3280
[    0.680000] alloc_contig_range(pfn=31952) ret=-16
[    0.680000] start = 3296
[    0.680000] pageno = 3296
[    0.680000] alloc_contig_range(pfn=31968) ret=-16
[    0.680000] start = 3312
[    0.680000] pageno = 3312
[    0.680000] alloc_contig_range(pfn=31984) ret=-16
[    0.680000] start = 3328
[    0.680000] pageno = 3328
[    0.680000] alloc_contig_range(pfn=32000) ret=-16
[    0.680000] start = 3344
[    0.680000] pageno = 3344
[    0.690000] alloc_contig_range(pfn=32016) ret=-16
[    0.690000] start = 3360
[    0.690000] pageno = 3360
[    0.690000] alloc_contig_range(pfn=32032) ret=-16
[    0.690000] start = 3376
[    0.690000] pageno = 3376
[    0.690000] alloc_contig_range(pfn=32048) ret=-16
[    0.690000] start = 3392
[    0.690000] pageno = 3392
[    0.690000] alloc_contig_range(pfn=32064) ret=-16
[    0.690000] start = 3408
[    0.690000] pageno = 3408
[    0.690000] alloc_contig_range(pfn=32080) ret=-16
[    0.690000] start = 3424
[    0.690000] pageno = 3424
[    0.700000] alloc_contig_range(pfn=32096) ret=-16
[    0.700000] start = 3440
[    0.700000] pageno = 3440
[    0.700000] alloc_contig_range(pfn=32112) ret=-16
[    0.700000] start = 3456
[    0.700000] pageno = 3456
[    0.700000] alloc_contig_range(pfn=32128) ret=-16
[    0.700000] start = 3472
[    0.700000] pageno = 3472
[    0.700000] alloc_contig_range(pfn=32144) ret=-16
[    0.700000] start = 3488
[    0.700000] pageno = 3488
[    0.700000] alloc_contig_range(pfn=32160) ret=-16
[    0.700000] start = 3504
[    0.700000] pageno = 3504
[    0.710000] alloc_contig_range(pfn=32176) ret=-16
[    0.710000] start = 3520
[    0.710000] pageno = 3520
[    0.710000] alloc_contig_range(pfn=32192) ret=-16
[    0.710000] start = 3536
[    0.710000] pageno = 3536
[    0.710000] alloc_contig_range(pfn=32208) ret=-16
[    0.710000] start = 3552
[    0.710000] pageno = 3552
[    0.710000] alloc_contig_range(pfn=32224) ret=-16
[    0.710000] start = 3568
[    0.710000] pageno = 3568
[    0.720000] alloc_contig_range(pfn=32240) ret=-16
[    0.720000] start = 3584
[    0.720000] pageno = 3584
[    0.720000] alloc_contig_range(pfn=32256) ret=-16
[    0.720000] start = 3600
[    0.720000] pageno = 3600
[    0.720000] alloc_contig_range(pfn=32272) ret=-16
[    0.720000] start = 3616
[    0.720000] pageno = 3616
[    0.720000] alloc_contig_range(pfn=32288) ret=-16
[    0.720000] start = 3632
[    0.720000] pageno = 3632
[    0.720000] alloc_contig_range(pfn=32304) ret=-16
[    0.720000] start = 3648
[    0.720000] pageno = 3648
[    0.730000] alloc_contig_range(pfn=32320) ret=-16
[    0.730000] start = 3664
[    0.730000] pageno = 3664
[    0.730000] alloc_contig_range(pfn=32336) ret=-16
[    0.730000] start = 3680
[    0.730000] pageno = 3680
[    0.730000] alloc_contig_range(pfn=32352) ret=-16
[    0.730000] start = 3696
[    0.730000] pageno = 3696
[    0.730000] alloc_contig_range(pfn=32368) ret=-16
[    0.730000] start = 3712
[    0.730000] pageno = 3712
[    0.730000] alloc_contig_range(pfn=32384) ret=-16
[    0.730000] start = 3728
[    0.730000] pageno = 4103
[    0.730000] pageno >= cma->count
[    0.730000] dma_alloc_from_contiguous(): returned   (null)
[    0.730000] __alloc_from_contiguous: !page
[    0.730000] wm8505fb_probe: Failed to allocate framebuffer
[    0.730000] wm8505-fb: probe of d8050800.fb failed with error -12
[    0.740000] d8200000.uart: ttyWMT0 at MMIO 0xd8200000 (irq = 32) is a VT8500 UART-1
[    3.720000] console [ttyWMT0] enabled
[    3.730000] d82b0000.uart: ttyWMT1 at MMIO 0xd82b0000 (irq = 33) is a VT8500 UART-1
[    3.740000] brd: module loaded
[    3.750000] loop: module loaded
[    3.750000] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    3.760000] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.770000] vt8500-ehci d8007900.ehci: VT8500 EHCI
[    3.770000] vt8500-ehci d8007900.ehci: new USB bus registered, assigned bus number 1
[    3.780000] __dma_alloc: __alloc_from_pool()
[    3.780000] __dma_alloc: __alloc_from_pool()
[    3.790000] __dma_alloc: __alloc_from_contiguous
[    3.790000] dma_alloc_from_contiguous(cma c683c7a0, count 1, align 0)
[    3.800000] pageno = 0
[    3.800000] alloc_contig_range(pfn=28672) ret=-16
[    3.810000] start = 1
[    3.810000] pageno = 1
[    3.810000] alloc_contig_range(pfn=28673) ret=-16
[    3.810000] start = 2
[    3.820000] pageno = 2
[    3.820000] alloc_contig_range(pfn=28674) ret=-16
[    3.820000] start = 3
[    3.830000] pageno = 3
[    3.830000] alloc_contig_range(pfn=28675) ret=-16
[    3.830000] start = 4
[    3.840000] pageno = 4
[    3.840000] alloc_contig_range(pfn=28676) ret=-16
[    3.840000] start = 5
[    3.840000] pageno = 5
[    3.850000] alloc_contig_range(pfn=28677) ret=-16
[    3.850000] start = 6
[    3.850000] pageno = 6
[    3.860000] alloc_contig_range(pfn=28678) ret=-16
[    3.860000] start = 7
[    3.860000] pageno = 7
[    3.870000] alloc_contig_range(pfn=28679) ret=-16
[    3.870000] start = 8
[    3.870000] pageno = 8
[    3.880000] alloc_contig_range(pfn=28680) ret=-16
[    3.880000] start = 9
[    3.880000] pageno = 9
[    3.890000] alloc_contig_range(pfn=28681) ret=-16
[    3.890000] start = 10
[    3.890000] pageno = 10
[    3.890000] alloc_contig_range(pfn=28682) ret=-16
[    3.900000] start = 11
[    3.900000] pageno = 11
[    3.900000] alloc_contig_range(pfn=28683) ret=-16
[    3.910000] start = 12
[    3.910000] pageno = 12
[    3.910000] alloc_contig_range(pfn=28684) ret=-16
[    3.920000] start = 13
[    3.920000] pageno = 13
[    3.920000] alloc_contig_range(pfn=28685) ret=-16
[    3.930000] start = 14
[    3.930000] pageno = 14
[    3.930000] alloc_contig_range(pfn=28686) ret=-16
[    3.940000] start = 15
[    3.940000] pageno = 15
[    3.940000] alloc_contig_range(pfn=28687) ret=-16
[    3.950000] start = 16
[    3.950000] pageno = 16
[    3.950000] alloc_contig_range(pfn=28688) ret=-16
[    3.950000] start = 17
[    3.960000] pageno = 17
[    3.960000] alloc_contig_range(pfn=28689) ret=-16
[    3.960000] start = 18
[    3.970000] pageno = 18
[    3.970000] alloc_contig_range(pfn=28690) ret=-16
[    3.970000] start = 19
[    3.980000] pageno = 19
[    3.980000] alloc_contig_range(pfn=28691) ret=-16
[    3.980000] start = 20
[    3.990000] pageno = 20
[    3.990000] alloc_contig_range(pfn=28692) ret=-16
[    3.990000] start = 21
[    4.000000] pageno = 21
[    4.000000] alloc_contig_range(pfn=28693) ret=-16
[    4.000000] start = 22
[    4.000000] pageno = 22
[    4.010000] alloc_contig_range(pfn=28694) ret=-16
[    4.010000] start = 23
[    4.010000] pageno = 23
[    4.020000] alloc_contig_range(pfn=28695) ret=-16
[    4.020000] start = 24
[    4.020000] pageno = 24
[    4.030000] alloc_contig_range(pfn=28696) ret=-16
[    4.030000] start = 25
[    4.030000] pageno = 25
[    4.040000] alloc_contig_range(pfn=28697) ret=-16
[    4.040000] start = 26
[    4.040000] pageno = 26
[    4.050000] alloc_contig_range(pfn=28698) ret=-16
[    4.050000] start = 27
[    4.050000] pageno = 27
[    4.060000] alloc_contig_range(pfn=28699) ret=-16
[    4.060000] start = 28
[    4.060000] pageno = 28
[    4.060000] alloc_contig_range(pfn=28700) ret=-16
[    4.070000] start = 29
[    4.070000] pageno = 29
[    4.070000] alloc_contig_range(pfn=28701) ret=-16
[    4.080000] start = 30
[    4.080000] pageno = 30
[    4.080000] alloc_contig_range(pfn=28702) ret=-16
[    4.090000] start = 31
[    4.090000] pageno = 31
[    4.090000] alloc_contig_range(pfn=28703) ret=-16
[    4.100000] start = 32
[    4.100000] pageno = 32
[    4.100000] alloc_contig_range(pfn=28704) ret=-16
[    4.110000] start = 33
[    4.110000] pageno = 33
[    4.110000] alloc_contig_range(pfn=28705) ret=-16
[    4.120000] start = 34
[    4.120000] pageno = 34
[    4.120000] alloc_contig_range(pfn=28706) ret=-16
[    4.120000] start = 35
[    4.130000] pageno = 35
[    4.130000] alloc_contig_range(pfn=28707) ret=-16
[    4.130000] start = 36
[    4.140000] pageno = 36
[    4.140000] alloc_contig_range(pfn=28708) ret=-16
[    4.140000] start = 37
[    4.150000] pageno = 37
[    4.150000] alloc_contig_range(pfn=28709) ret=-16
[    4.150000] start = 38
[    4.160000] pageno = 38
[    4.160000] alloc_contig_range(pfn=28710) ret=-16
[    4.160000] start = 39
[    4.170000] pageno = 39
[    4.170000] alloc_contig_range(pfn=28711) ret=-16
[    4.170000] start = 40
[    4.170000] pageno = 40
[    4.180000] alloc_contig_range(pfn=28712) ret=-16
[    4.180000] start = 41
[    4.180000] pageno = 41
[    4.190000] alloc_contig_range(pfn=28713) ret=-16
[    4.190000] start = 42
[    4.190000] pageno = 42
[    4.200000] alloc_contig_range(pfn=28714) ret=-16
[    4.200000] start = 43
[    4.200000] pageno = 43
[    4.210000] alloc_contig_range(pfn=28715) ret=-16
[    4.210000] start = 44
[    4.210000] pageno = 44
[    4.220000] alloc_contig_range(pfn=28716) ret=-16
[    4.220000] start = 45
[    4.220000] pageno = 45
[    4.230000] alloc_contig_range(pfn=28717) ret=-16
[    4.230000] start = 46
[    4.230000] pageno = 46
[    4.230000] alloc_contig_range(pfn=28718) ret=-16
[    4.240000] start = 47
[    4.240000] pageno = 47
[    4.240000] alloc_contig_range(pfn=28719) ret=-16
[    4.250000] start = 48
[    4.250000] pageno = 48
[    4.250000] alloc_contig_range(pfn=28720) ret=-16
[    4.260000] start = 49
[    4.260000] pageno = 49
[    4.260000] alloc_contig_range(pfn=28721) ret=-16
[    4.270000] start = 50
[    4.270000] pageno = 50
[    4.270000] alloc_contig_range(pfn=28722) ret=-16
[    4.280000] start = 51
[    4.280000] pageno = 51
[    4.280000] alloc_contig_range(pfn=28723) ret=-16
[    4.290000] start = 52
[    4.290000] pageno = 52
[    4.290000] alloc_contig_range(pfn=28724) ret=-16
[    4.300000] start = 53
[    4.300000] pageno = 53
[    4.300000] alloc_contig_range(pfn=28725) ret=-16
[    4.300000] start = 54
[    4.310000] pageno = 54
[    4.310000] alloc_contig_range(pfn=28726) ret=-16
[    4.310000] start = 55
[    4.320000] pageno = 55
[    4.320000] alloc_contig_range(pfn=28727) ret=-16
[    4.320000] start = 56
[    4.330000] pageno = 56
[    4.330000] alloc_contig_range(pfn=28728) ret=-16
[    4.330000] start = 57
[    4.340000] pageno = 57
[    4.340000] alloc_contig_range(pfn=28729) ret=-16
[    4.340000] start = 58
[    4.340000] pageno = 58
[    4.350000] alloc_contig_range(pfn=28730) ret=-16
[    4.350000] start = 59
[    4.350000] pageno = 59
[    4.360000] alloc_contig_range(pfn=28731) ret=-16
[    4.360000] start = 60
[    4.360000] pageno = 60
[    4.370000] alloc_contig_range(pfn=28732) ret=-16
[    4.370000] start = 61
[    4.370000] pageno = 61
[    4.380000] alloc_contig_range(pfn=28733) ret=-16
[    4.380000] start = 62
[    4.380000] pageno = 62
[    4.390000] alloc_contig_range(pfn=28734) ret=-16
[    4.390000] start = 63
[    4.390000] pageno = 63
[    4.400000] alloc_contig_range(pfn=28735) ret=-16
[    4.400000] start = 64
[    4.400000] pageno = 64
[    4.400000] alloc_contig_range(pfn=28736) ret=-16
[    4.410000] start = 65
[    4.410000] pageno = 65
[    4.410000] alloc_contig_range(pfn=28737) ret=-16
[    4.420000] start = 66
[    4.420000] pageno = 66
[    4.420000] alloc_contig_range(pfn=28738) ret=-16
[    4.430000] start = 67
[    4.430000] pageno = 67
[    4.430000] alloc_contig_range(pfn=28739) ret=-16
[    4.440000] start = 68
[    4.440000] pageno = 68
[    4.440000] alloc_contig_range(pfn=28740) ret=-16
[    4.450000] start = 69
[    4.450000] pageno = 69
[    4.450000] alloc_contig_range(pfn=28741) ret=-16
[    4.460000] start = 70
[    4.460000] pageno = 70
[    4.460000] alloc_contig_range(pfn=28742) ret=-16
[    4.470000] start = 71
[    4.470000] pageno = 71
[    4.470000] alloc_contig_range(pfn=28743) ret=-16
[    4.470000] start = 72
[    4.480000] pageno = 72
[    4.480000] alloc_contig_range(pfn=28744) ret=-16
[    4.480000] start = 73
[    4.490000] pageno = 73
[    4.490000] alloc_contig_range(pfn=28745) ret=-16
[    4.490000] start = 74
[    4.500000] pageno = 74
[    4.500000] alloc_contig_range(pfn=28746) ret=-16
[    4.500000] start = 75
[    4.510000] pageno = 75
[    4.510000] alloc_contig_range(pfn=28747) ret=-16
[    4.510000] start = 76
[    4.510000] pageno = 76
[    4.520000] alloc_contig_range(pfn=28748) ret=-16
[    4.520000] start = 77
[    4.520000] pageno = 77
[    4.530000] alloc_contig_range(pfn=28749) ret=-16
[    4.530000] start = 78
[    4.530000] pageno = 78
[    4.540000] alloc_contig_range(pfn=28750) ret=-16
[    4.540000] start = 79
[    4.540000] pageno = 79
[    4.550000] alloc_contig_range(pfn=28751) ret=-16
[    4.550000] start = 80
[    4.550000] pageno = 80
[    4.560000] alloc_contig_range(pfn=28752) ret=-16
[    4.560000] start = 81
[    4.560000] pageno = 81
[    4.570000] alloc_contig_range(pfn=28753) ret=-16
[    4.570000] start = 82
[    4.570000] pageno = 82
[    4.570000] alloc_contig_range(pfn=28754) ret=-16
[    4.580000] start = 83
[    4.580000] pageno = 83
[    4.580000] alloc_contig_range(pfn=28755) ret=-16
[    4.590000] start = 84
[    4.590000] pageno = 84
[    4.590000] alloc_contig_range(pfn=28756) ret=-16
[    4.600000] start = 85
[    4.600000] pageno = 85
[    4.600000] alloc_contig_range(pfn=28757) ret=-16
[    4.610000] start = 86
[    4.610000] pageno = 86
[    4.610000] alloc_contig_range(pfn=28758) ret=-16
[    4.620000] start = 87
[    4.620000] pageno = 87
[    4.620000] alloc_contig_range(pfn=28759) ret=-16
[    4.630000] start = 88
[    4.630000] pageno = 88
[    4.630000] alloc_contig_range(pfn=28760) ret=-16
[    4.640000] start = 89
[    4.640000] pageno = 89
[    4.640000] alloc_contig_range(pfn=28761) ret=-16
[    4.640000] start = 90
[    4.650000] pageno = 90
[    4.650000] alloc_contig_range(pfn=28762) ret=-16
[    4.650000] start = 91
[    4.660000] pageno = 91
[    4.660000] alloc_contig_range(pfn=28763) ret=-16
[    4.660000] start = 92
[    4.670000] pageno = 92
[    4.670000] alloc_contig_range(pfn=28764) ret=-16
[    4.670000] start = 93
[    4.680000] pageno = 93
[    4.680000] alloc_contig_range(pfn=28765) ret=-16
[    4.680000] start = 94
[    4.680000] pageno = 94
[    4.690000] alloc_contig_range(pfn=28766) ret=-16
[    4.690000] start = 95
[    4.690000] pageno = 95
[    4.700000] alloc_contig_range(pfn=28767) ret=-16
[    4.700000] start = 96
[    4.700000] pageno = 96
[    4.710000] alloc_contig_range(pfn=28768) ret=-16
[    4.710000] start = 97
[    4.710000] pageno = 97
[    4.720000] alloc_contig_range(pfn=28769) ret=-16
[    4.720000] start = 98
[    4.720000] pageno = 98
[    4.730000] alloc_contig_range(pfn=28770) ret=-16
[    4.730000] start = 99
[    4.730000] pageno = 99
[    4.740000] alloc_contig_range(pfn=28771) ret=-16
[    4.740000] start = 100
[    4.740000] pageno = 100
[    4.750000] alloc_contig_range(pfn=28772) ret=-16
[    4.750000] start = 101
[    4.750000] pageno = 101
[    4.750000] alloc_contig_range(pfn=28773) ret=-16
[    4.760000] start = 102
[    4.760000] pageno = 102
[    4.760000] alloc_contig_range(pfn=28774) ret=-16
[    4.770000] start = 103
[    4.770000] pageno = 103
[    4.770000] alloc_contig_range(pfn=28775) ret=-16
[    4.780000] start = 104
[    4.780000] pageno = 104
[    4.780000] alloc_contig_range(pfn=28776) ret=-16
[    4.790000] start = 105
[    4.790000] pageno = 105
[    4.790000] alloc_contig_range(pfn=28777) ret=-16
[    4.800000] start = 106
[    4.800000] pageno = 106
[    4.800000] alloc_contig_range(pfn=28778) ret=-16
[    4.810000] start = 107
[    4.810000] pageno = 107
[    4.810000] alloc_contig_range(pfn=28779) ret=-16
[    4.820000] start = 108
[    4.820000] pageno = 108
[    4.820000] alloc_contig_range(pfn=28780) ret=-16
[    4.830000] start = 109
[    4.830000] pageno = 109
[    4.830000] alloc_contig_range(pfn=28781) ret=-16
[    4.840000] start = 110
[    4.840000] pageno = 110
[    4.840000] alloc_contig_range(pfn=28782) ret=-16
[    4.840000] start = 111
[    4.850000] pageno = 111
[    4.850000] alloc_contig_range(pfn=28783) ret=-16
[    4.850000] start = 112
[    4.860000] pageno = 112
[    4.860000] alloc_contig_range(pfn=28784) ret=-16
[    4.860000] start = 113
[    4.870000] pageno = 113
[    4.870000] alloc_contig_range(pfn=28785) ret=-16
[    4.870000] start = 114
[    4.880000] pageno = 114
[    4.880000] alloc_contig_range(pfn=28786) ret=-16
[    4.880000] start = 115
[    4.890000] pageno = 115
[    4.890000] alloc_contig_range(pfn=28787) ret=-16
[    4.890000] start = 116
[    4.900000] pageno = 116
[    4.900000] alloc_contig_range(pfn=28788) ret=-16
[    4.900000] start = 117
[    4.900000] pageno = 117
[    4.910000] alloc_contig_range(pfn=28789) ret=-16
[    4.910000] start = 118
[    4.910000] pageno = 118
[    4.920000] alloc_contig_range(pfn=28790) ret=-16
[    4.920000] start = 119
[    4.920000] pageno = 119
[    4.930000] alloc_contig_range(pfn=28791) ret=-16
[    4.930000] start = 120
[    4.930000] pageno = 120
[    4.940000] alloc_contig_range(pfn=28792) ret=-16
[    4.940000] start = 121
[    4.940000] pageno = 121
[    4.950000] alloc_contig_range(pfn=28793) ret=-16
[    4.950000] start = 122
[    4.950000] pageno = 122
[    4.960000] alloc_contig_range(pfn=28794) ret=-16
[    4.960000] start = 123
[    4.960000] pageno = 123
[    4.970000] alloc_contig_range(pfn=28795) ret=-16
[    4.970000] start = 124
[    4.970000] pageno = 124
[    4.980000] alloc_contig_range(pfn=28796) ret=-16
[    4.980000] start = 125
[    4.980000] pageno = 125
[    4.990000] alloc_contig_range(pfn=28797) ret=-16
[    4.990000] start = 126
[    4.990000] pageno = 126
[    5.000000] alloc_contig_range(pfn=28798) ret=-16
[    5.000000] start = 127
[    5.000000] pageno = 127
[    5.000000] alloc_contig_range(pfn=28799) ret=-16
[    5.010000] start = 128
[    5.010000] pageno = 128
[    5.010000] alloc_contig_range(pfn=28800) ret=-16
[    5.020000] start = 129
[    5.020000] pageno = 129
[    5.020000] alloc_contig_range(pfn=28801) ret=-16
[    5.030000] start = 130
[    5.030000] pageno = 130
[    5.030000] alloc_contig_range(pfn=28802) ret=-16
[    5.040000] start = 131
[    5.040000] pageno = 131
[    5.040000] alloc_contig_range(pfn=28803) ret=-16
[    5.050000] start = 132
[    5.050000] pageno = 132
[    5.050000] alloc_contig_range(pfn=28804) ret=-16
[    5.060000] start = 133
[    5.060000] pageno = 133
[    5.060000] alloc_contig_range(pfn=28805) ret=-16
[    5.070000] start = 134
[    5.070000] pageno = 134
[    5.070000] alloc_contig_range(pfn=28806) ret=-16
[    5.080000] start = 135
[    5.080000] pageno = 135
[    5.080000] alloc_contig_range(pfn=28807) ret=-16
[    5.090000] start = 136
[    5.090000] pageno = 136
[    5.090000] alloc_contig_range(pfn=28808) ret=-16
[    5.100000] start = 137
[    5.100000] pageno = 137
[    5.100000] alloc_contig_range(pfn=28809) ret=-16
[    5.100000] start = 138
[    5.110000] pageno = 138
[    5.110000] alloc_contig_range(pfn=28810) ret=-16
[    5.110000] start = 139
[    5.120000] pageno = 139
[    5.120000] alloc_contig_range(pfn=28811) ret=-16
[    5.120000] start = 140
[    5.130000] pageno = 140
[    5.130000] alloc_contig_range(pfn=28812) ret=-16
[    5.130000] start = 141
[    5.140000] pageno = 141
[    5.140000] alloc_contig_range(pfn=28813) ret=-16
[    5.140000] start = 142
[    5.150000] pageno = 142
[    5.150000] alloc_contig_range(pfn=28814) ret=-16
[    5.150000] start = 143
[    5.160000] pageno = 143
[    5.160000] alloc_contig_range(pfn=28815) ret=-16
[    5.160000] start = 144
[    5.160000] pageno = 144
[    5.170000] alloc_contig_range(pfn=28816) ret=-16
[    5.170000] start = 145
[    5.170000] pageno = 145
[    5.180000] alloc_contig_range(pfn=28817) ret=-16
[    5.180000] start = 146
[    5.180000] pageno = 146
[    5.190000] alloc_contig_range(pfn=28818) ret=-16
[    5.190000] start = 147
[    5.190000] pageno = 147
[    5.200000] alloc_contig_range(pfn=28819) ret=-16
[    5.200000] start = 148
[    5.200000] pageno = 148
[    5.210000] alloc_contig_range(pfn=28820) ret=-16
[    5.210000] start = 149
[    5.210000] pageno = 149
[    5.220000] alloc_contig_range(pfn=28821) ret=-16
[    5.220000] start = 150
[    5.220000] pageno = 150
[    5.230000] alloc_contig_range(pfn=28822) ret=-16
[    5.230000] start = 151
[    5.230000] pageno = 151
[    5.240000] alloc_contig_range(pfn=28823) ret=-16
[    5.240000] start = 152
[    5.240000] pageno = 152
[    5.250000] alloc_contig_range(pfn=28824) ret=-16
[    5.250000] start = 153
[    5.250000] pageno = 153
[    5.260000] alloc_contig_range(pfn=28825) ret=-16
[    5.260000] start = 154
[    5.260000] pageno = 154
[    5.260000] alloc_contig_range(pfn=28826) ret=-16
[    5.270000] start = 155
[    5.270000] pageno = 155
[    5.270000] alloc_contig_range(pfn=28827) ret=-16
[    5.280000] start = 156
[    5.280000] pageno = 156
[    5.280000] alloc_contig_range(pfn=28828) ret=-16
[    5.290000] start = 157
[    5.290000] pageno = 157
[    5.290000] alloc_contig_range(pfn=28829) ret=-16
[    5.300000] start = 158
[    5.300000] pageno = 158
[    5.300000] alloc_contig_range(pfn=28830) ret=-16
[    5.310000] start = 159
[    5.310000] pageno = 159
[    5.310000] alloc_contig_range(pfn=28831) ret=-16
[    5.320000] start = 160
[    5.320000] pageno = 160
[    5.320000] alloc_contig_range(pfn=28832) ret=-16
[    5.330000] start = 161
[    5.330000] pageno = 161
[    5.330000] alloc_contig_range(pfn=28833) ret=-16
[    5.340000] start = 162
[    5.340000] pageno = 162
[    5.340000] alloc_contig_range(pfn=28834) ret=-16
[    5.350000] start = 163
[    5.350000] pageno = 163
[    5.350000] alloc_contig_range(pfn=28835) ret=-16
[    5.350000] start = 164
[    5.360000] pageno = 164
[    5.360000] alloc_contig_range(pfn=28836) ret=-16
[    5.360000] start = 165
[    5.370000] pageno = 165
[    5.370000] alloc_contig_range(pfn=28837) ret=-16
[    5.370000] start = 166
[    5.380000] pageno = 166
[    5.380000] alloc_contig_range(pfn=28838) ret=-16
[    5.380000] start = 167
[    5.390000] pageno = 167
[    5.390000] alloc_contig_range(pfn=28839) ret=-16
[    5.390000] start = 168
[    5.400000] pageno = 168
[    5.400000] alloc_contig_range(pfn=28840) ret=-16
[    5.400000] start = 169
[    5.410000] pageno = 169
[    5.410000] alloc_contig_range(pfn=28841) ret=-16
[    5.410000] start = 170
[    5.410000] pageno = 170
[    5.420000] alloc_contig_range(pfn=28842) ret=-16
[    5.420000] start = 171
[    5.420000] pageno = 171
[    5.430000] alloc_contig_range(pfn=28843) ret=-16
[    5.430000] start = 172
[    5.430000] pageno = 172
[    5.440000] alloc_contig_range(pfn=28844) ret=-16
[    5.440000] start = 173
[    5.440000] pageno = 173
[    5.450000] alloc_contig_range(pfn=28845) ret=-16
[    5.450000] start = 174
[    5.450000] pageno = 174
[    5.460000] alloc_contig_range(pfn=28846) ret=-16
[    5.460000] start = 175
[    5.460000] pageno = 175
[    5.470000] alloc_contig_range(pfn=28847) ret=-16
[    5.470000] start = 176
[    5.470000] pageno = 176
[    5.480000] alloc_contig_range(pfn=28848) ret=-16
[    5.480000] start = 177
[    5.480000] pageno = 177
[    5.490000] alloc_contig_range(pfn=28849) ret=-16
[    5.490000] start = 178
[    5.490000] pageno = 178
[    5.500000] alloc_contig_range(pfn=28850) ret=-16
[    5.500000] start = 179
[    5.500000] pageno = 179
[    5.510000] alloc_contig_range(pfn=28851) ret=-16
[    5.510000] start = 180
[    5.510000] pageno = 180
[    5.510000] alloc_contig_range(pfn=28852) ret=-16
[    5.520000] start = 181
[    5.520000] pageno = 181
[    5.520000] alloc_contig_range(pfn=28853) ret=-16
[    5.530000] start = 182
[    5.530000] pageno = 182
[    5.530000] alloc_contig_range(pfn=28854) ret=-16
[    5.540000] start = 183
[    5.540000] pageno = 183
[    5.540000] alloc_contig_range(pfn=28855) ret=-16
[    5.550000] start = 184
[    5.550000] pageno = 184
[    5.550000] alloc_contig_range(pfn=28856) ret=-16
[    5.560000] start = 185
[    5.560000] pageno = 185
[    5.560000] alloc_contig_range(pfn=28857) ret=-16
[    5.570000] start = 186
[    5.570000] pageno = 186
[    5.570000] alloc_contig_range(pfn=28858) ret=-16
[    5.580000] start = 187
[    5.580000] pageno = 187
[    5.580000] alloc_contig_range(pfn=28859) ret=-16
[    5.590000] start = 188
[    5.590000] pageno = 188
[    5.590000] alloc_contig_range(pfn=28860) ret=-16
[    5.600000] start = 189
[    5.600000] pageno = 189
[    5.600000] alloc_contig_range(pfn=28861) ret=-16
[    5.610000] start = 190
[    5.610000] pageno = 190
[    5.610000] alloc_contig_range(pfn=28862) ret=-16
[    5.610000] start = 191
[    5.620000] pageno = 191
[    5.620000] alloc_contig_range(pfn=28863) ret=-16
[    5.620000] start = 192
[    5.630000] pageno = 192
[    5.630000] alloc_contig_range(pfn=28864) ret=-16
[    5.630000] start = 193
[    5.640000] pageno = 193
[    5.640000] alloc_contig_range(pfn=28865) ret=-16
[    5.640000] start = 194
[    5.650000] pageno = 194
[    5.650000] alloc_contig_range(pfn=28866) ret=-16
[    5.650000] start = 195
[    5.660000] pageno = 195
[    5.660000] alloc_contig_range(pfn=28867) ret=-16
[    5.660000] start = 196
[    5.670000] pageno = 196
[    5.670000] alloc_contig_range(pfn=28868) ret=-16
[    5.670000] start = 197
[    5.670000] pageno = 197
[    5.680000] alloc_contig_range(pfn=28869) ret=-16
[    5.680000] start = 198
[    5.680000] pageno = 198
[    5.690000] alloc_contig_range(pfn=28870) ret=-16
[    5.690000] start = 199
[    5.690000] pageno = 199
[    5.700000] alloc_contig_range(pfn=28871) ret=-16
[    5.700000] start = 200
[    5.700000] pageno = 200
[    5.710000] alloc_contig_range(pfn=28872) ret=-16
[    5.710000] start = 201
[    5.710000] pageno = 201
[    5.720000] alloc_contig_range(pfn=28873) ret=-16
[    5.720000] start = 202
[    5.720000] pageno = 202
[    5.730000] alloc_contig_range(pfn=28874) ret=-16
[    5.730000] start = 203
[    5.730000] pageno = 203
[    5.740000] alloc_contig_range(pfn=28875) ret=-16
[    5.740000] start = 204
[    5.740000] pageno = 204
[    5.750000] alloc_contig_range(pfn=28876) ret=-16
[    5.750000] start = 205
[    5.750000] pageno = 205
[    5.760000] alloc_contig_range(pfn=28877) ret=-16
[    5.760000] start = 206
[    5.760000] pageno = 206
[    5.770000] alloc_contig_range(pfn=28878) ret=-16
[    5.770000] start = 207
[    5.770000] pageno = 207
[    5.770000] alloc_contig_range(pfn=28879) ret=-16
[    5.780000] start = 208
[    5.780000] pageno = 208
[    5.780000] alloc_contig_range(pfn=28880) ret=-16
[    5.790000] start = 209
[    5.790000] pageno = 209
[    5.790000] alloc_contig_range(pfn=28881) ret=-16
[    5.800000] start = 210
[    5.800000] pageno = 210
[    5.800000] alloc_contig_range(pfn=28882) ret=-16
[    5.810000] start = 211
[    5.810000] pageno = 211
[    5.810000] alloc_contig_range(pfn=28883) ret=-16
[    5.820000] start = 212
[    5.820000] pageno = 212
[    5.820000] alloc_contig_range(pfn=28884) ret=-16
[    5.830000] start = 213
[    5.830000] pageno = 213
[    5.830000] alloc_contig_range(pfn=28885) ret=-16
[    5.840000] start = 214
[    5.840000] pageno = 214
[    5.840000] alloc_contig_range(pfn=28886) ret=-16
[    5.850000] start = 215
[    5.850000] pageno = 215
[    5.850000] alloc_contig_range(pfn=28887) ret=-16
[    5.860000] start = 216
[    5.860000] pageno = 216
[    5.860000] alloc_contig_range(pfn=28888) ret=-16
[    5.860000] start = 217
[    5.870000] pageno = 217
[    5.870000] alloc_contig_range(pfn=28889) ret=-16
[    5.870000] start = 218
[    5.880000] pageno = 218
[    5.880000] alloc_contig_range(pfn=28890) ret=-16
[    5.880000] start = 219
[    5.890000] pageno = 219
[    5.890000] alloc_contig_range(pfn=28891) ret=-16
[    5.890000] start = 220
[    5.900000] pageno = 220
[    5.900000] alloc_contig_range(pfn=28892) ret=-16
[    5.900000] start = 221
[    5.910000] pageno = 221
[    5.910000] alloc_contig_range(pfn=28893) ret=-16
[    5.910000] start = 222
[    5.920000] pageno = 222
[    5.920000] alloc_contig_range(pfn=28894) ret=-16
[    5.920000] start = 223
[    5.920000] pageno = 223
[    5.930000] alloc_contig_range(pfn=28895) ret=-16
[    5.930000] start = 224
[    5.930000] pageno = 224
[    5.940000] alloc_contig_range(pfn=28896) ret=-16
[    5.940000] start = 225
[    5.940000] pageno = 225
[    5.950000] alloc_contig_range(pfn=28897) ret=-16
[    5.950000] start = 226
[    5.950000] pageno = 226
[    5.960000] alloc_contig_range(pfn=28898) ret=-16
[    5.960000] start = 227
[    5.960000] pageno = 227
[    5.970000] alloc_contig_range(pfn=28899) ret=-16
[    5.970000] start = 228
[    5.970000] pageno = 228
[    5.980000] alloc_contig_range(pfn=28900) ret=-16
[    5.980000] start = 229
[    5.980000] pageno = 229
[    5.990000] alloc_contig_range(pfn=28901) ret=-16
[    5.990000] start = 230
[    5.990000] pageno = 230
[    6.000000] alloc_contig_range(pfn=28902) ret=-16
[    6.000000] start = 231
[    6.000000] pageno = 231
[    6.010000] alloc_contig_range(pfn=28903) ret=-16
[    6.010000] start = 232
[    6.010000] pageno = 232
[    6.020000] alloc_contig_range(pfn=28904) ret=-16
[    6.020000] start = 233
[    6.020000] pageno = 233
[    6.020000] alloc_contig_range(pfn=28905) ret=-16
[    6.030000] start = 234
[    6.030000] pageno = 234
[    6.030000] alloc_contig_range(pfn=28906) ret=-16
[    6.040000] start = 235
[    6.040000] pageno = 235
[    6.040000] alloc_contig_range(pfn=28907) ret=-16
[    6.050000] start = 236
[    6.050000] pageno = 236
[    6.050000] alloc_contig_range(pfn=28908) ret=-16
[    6.060000] start = 237
[    6.060000] pageno = 237
[    6.060000] alloc_contig_range(pfn=28909) ret=-16
[    6.070000] start = 238
[    6.070000] pageno = 238
[    6.070000] alloc_contig_range(pfn=28910) ret=-16
[    6.080000] start = 239
[    6.080000] pageno = 239
[    6.080000] alloc_contig_range(pfn=28911) ret=-16
[    6.090000] start = 240
[    6.090000] pageno = 240
[    6.090000] alloc_contig_range(pfn=28912) ret=-16
[    6.100000] start = 241
[    6.100000] pageno = 241
[    6.100000] alloc_contig_range(pfn=28913) ret=-16
[    6.110000] start = 242
[    6.110000] pageno = 242
[    6.110000] alloc_contig_range(pfn=28914) ret=-16
[    6.110000] start = 243
[    6.120000] pageno = 243
[    6.120000] alloc_contig_range(pfn=28915) ret=-16
[    6.120000] start = 244
[    6.130000] pageno = 244
[    6.130000] alloc_contig_range(pfn=28916) ret=-16
[    6.130000] start = 245
[    6.140000] pageno = 245
[    6.140000] alloc_contig_range(pfn=28917) ret=-16
[    6.140000] start = 246
[    6.150000] pageno = 246
[    6.150000] alloc_contig_range(pfn=28918) ret=-16
[    6.150000] start = 247
[    6.160000] pageno = 247
[    6.160000] alloc_contig_range(pfn=28919) ret=-16
[    6.160000] start = 248
[    6.170000] pageno = 248
[    6.170000] alloc_contig_range(pfn=28920) ret=-16
[    6.170000] start = 249
[    6.180000] pageno = 249
[    6.180000] alloc_contig_range(pfn=28921) ret=-16
[    6.180000] start = 250
[    6.180000] pageno = 250
[    6.190000] alloc_contig_range(pfn=28922) ret=-16
[    6.190000] start = 251
[    6.190000] pageno = 251
[    6.200000] alloc_contig_range(pfn=28923) ret=-16
[    6.200000] start = 252
[    6.200000] pageno = 252
[    6.210000] alloc_contig_range(pfn=28924) ret=-16
[    6.210000] start = 253
[    6.210000] pageno = 253
[    6.220000] alloc_contig_range(pfn=28925) ret=-16
[    6.220000] start = 254
[    6.220000] pageno = 254
[    6.230000] alloc_contig_range(pfn=28926) ret=-16
[    6.230000] start = 255
[    6.230000] pageno = 255
[    6.240000] alloc_contig_range(pfn=28927) ret=-16
[    6.240000] start = 256
[    6.240000] pageno = 256
[    6.250000] alloc_contig_range(pfn=28928) ret=-16
[    6.250000] start = 257
[    6.250000] pageno = 257
[    6.260000] alloc_contig_range(pfn=28929) ret=-16
[    6.260000] start = 258
[    6.260000] pageno = 258
[    6.270000] alloc_contig_range(pfn=28930) ret=-16
[    6.270000] start = 259
[    6.270000] pageno = 259
[    6.280000] alloc_contig_range(pfn=28931) ret=-16
[    6.280000] start = 260
[    6.280000] pageno = 260
[    6.280000] alloc_contig_range(pfn=28932) ret=-16
[    6.290000] start = 261
[    6.290000] pageno = 261
[    6.290000] alloc_contig_range(pfn=28933) ret=-16
[    6.300000] start = 262
[    6.300000] pageno = 262
[    6.300000] alloc_contig_range(pfn=28934) ret=-16
[    6.310000] start = 263
[    6.310000] pageno = 263
[    6.310000] alloc_contig_range(pfn=28935) ret=-16
[    6.320000] start = 264
[    6.320000] pageno = 264
[    6.320000] alloc_contig_range(pfn=28936) ret=-16
[    6.330000] start = 265
[    6.330000] pageno = 265
[    6.330000] alloc_contig_range(pfn=28937) ret=-16
[    6.340000] start = 266
[    6.340000] pageno = 266
[    6.340000] alloc_contig_range(pfn=28938) ret=-16
[    6.350000] start = 267
[    6.350000] pageno = 267
[    6.350000] alloc_contig_range(pfn=28939) ret=-16
[    6.360000] start = 268
[    6.360000] pageno = 268
[    6.360000] alloc_contig_range(pfn=28940) ret=-16
[    6.370000] start = 269
[    6.370000] pageno = 269
[    6.370000] alloc_contig_range(pfn=28941) ret=-16
[    6.370000] start = 270
[    6.380000] pageno = 270
[    6.380000] alloc_contig_range(pfn=28942) ret=-16
[    6.380000] start = 271
[    6.390000] pageno = 271
[    6.390000] alloc_contig_range(pfn=28943) ret=-16
[    6.390000] start = 272
[    6.400000] pageno = 272
[    6.400000] alloc_contig_range(pfn=28944) ret=-16
[    6.400000] start = 273
[    6.410000] pageno = 273
[    6.410000] alloc_contig_range(pfn=28945) ret=-16
[    6.410000] start = 274
[    6.420000] pageno = 274
[    6.420000] alloc_contig_range(pfn=28946) ret=-16
[    6.420000] start = 275
[    6.430000] pageno = 275
[    6.430000] alloc_contig_range(pfn=28947) ret=-16
[    6.430000] start = 276
[    6.430000] pageno = 276
[    6.440000] alloc_contig_range(pfn=28948) ret=-16
[    6.440000] start = 277
[    6.440000] pageno = 277
[    6.450000] alloc_contig_range(pfn=28949) ret=-16
[    6.450000] start = 278
[    6.450000] pageno = 278
[    6.460000] alloc_contig_range(pfn=28950) ret=-16
[    6.460000] start = 279
[    6.460000] pageno = 279
[    6.470000] alloc_contig_range(pfn=28951) ret=-16
[    6.470000] start = 280
[    6.470000] pageno = 280
[    6.480000] alloc_contig_range(pfn=28952) ret=-16
[    6.480000] start = 281
[    6.480000] pageno = 281
[    6.490000] alloc_contig_range(pfn=28953) ret=-16
[    6.490000] start = 282
[    6.490000] pageno = 282
[    6.500000] alloc_contig_range(pfn=28954) ret=-16
[    6.500000] start = 283
[    6.500000] pageno = 283
[    6.510000] alloc_contig_range(pfn=28955) ret=-16
[    6.510000] start = 284
[    6.510000] pageno = 284
[    6.520000] alloc_contig_range(pfn=28956) ret=-16
[    6.520000] start = 285
[    6.520000] pageno = 285
[    6.530000] alloc_contig_range(pfn=28957) ret=-16
[    6.530000] start = 286
[    6.530000] pageno = 286
[    6.530000] alloc_contig_range(pfn=28958) ret=-16
[    6.540000] start = 287
[    6.540000] pageno = 287
[    6.540000] alloc_contig_range(pfn=28959) ret=-16
[    6.550000] start = 288
[    6.550000] pageno = 288
[    6.550000] alloc_contig_range(pfn=28960) ret=-16
[    6.560000] start = 289
[    6.560000] pageno = 289
[    6.560000] alloc_contig_range(pfn=28961) ret=-16
[    6.570000] start = 290
[    6.570000] pageno = 290
[    6.570000] alloc_contig_range(pfn=28962) ret=-16
[    6.580000] start = 291
[    6.580000] pageno = 291
[    6.580000] alloc_contig_range(pfn=28963) ret=-16
[    6.590000] start = 292
[    6.590000] pageno = 292
[    6.590000] alloc_contig_range(pfn=28964) ret=-16
[    6.600000] start = 293
[    6.600000] pageno = 293
[    6.600000] alloc_contig_range(pfn=28965) ret=-16
[    6.610000] start = 294
[    6.610000] pageno = 294
[    6.610000] alloc_contig_range(pfn=28966) ret=-16
[    6.620000] start = 295
[    6.620000] pageno = 295
[    6.620000] alloc_contig_range(pfn=28967) ret=-16
[    6.620000] start = 296
[    6.630000] pageno = 296
[    6.630000] alloc_contig_range(pfn=28968) ret=-16
[    6.630000] start = 297
[    6.640000] pageno = 297
[    6.640000] alloc_contig_range(pfn=28969) ret=-16
[    6.640000] start = 298
[    6.650000] pageno = 298
[    6.650000] alloc_contig_range(pfn=28970) ret=-16
[    6.650000] start = 299
[    6.660000] pageno = 299
[    6.660000] alloc_contig_range(pfn=28971) ret=-16
[    6.660000] start = 300
[    6.670000] pageno = 300
[    6.670000] alloc_contig_range(pfn=28972) ret=-16
[    6.670000] start = 301
[    6.680000] pageno = 301
[    6.680000] alloc_contig_range(pfn=28973) ret=-16
[    6.680000] start = 302
[    6.690000] pageno = 302
[    6.690000] alloc_contig_range(pfn=28974) ret=-16
[    6.690000] start = 303
[    6.690000] pageno = 303
[    6.700000] alloc_contig_range(pfn=28975) ret=-16
[    6.700000] start = 304
[    6.700000] pageno = 304
[    6.710000] alloc_contig_range(pfn=28976) ret=-16
[    6.710000] start = 305
[    6.710000] pageno = 305
[    6.720000] alloc_contig_range(pfn=28977) ret=-16
[    6.720000] start = 306
[    6.720000] pageno = 306
[    6.730000] alloc_contig_range(pfn=28978) ret=-16
[    6.730000] start = 307
[    6.730000] pageno = 307
[    6.740000] alloc_contig_range(pfn=28979) ret=-16
[    6.740000] start = 308
[    6.740000] pageno = 308
[    6.750000] alloc_contig_range(pfn=28980) ret=-16
[    6.750000] start = 309
[    6.750000] pageno = 309
[    6.760000] alloc_contig_range(pfn=28981) ret=-16
[    6.760000] start = 310
[    6.760000] pageno = 310
[    6.770000] alloc_contig_range(pfn=28982) ret=-16
[    6.770000] start = 311
[    6.770000] pageno = 311
[    6.780000] alloc_contig_range(pfn=28983) ret=-16
[    6.780000] start = 312
[    6.780000] pageno = 312
[    6.780000] alloc_contig_range(pfn=28984) ret=-16
[    6.790000] start = 313
[    6.790000] pageno = 313
[    6.790000] alloc_contig_range(pfn=28985) ret=-16
[    6.800000] start = 314
[    6.800000] pageno = 314
[    6.800000] alloc_contig_range(pfn=28986) ret=-16
[    6.810000] start = 315
[    6.810000] pageno = 315
[    6.810000] alloc_contig_range(pfn=28987) ret=-16
[    6.820000] start = 316
[    6.820000] pageno = 316
[    6.820000] alloc_contig_range(pfn=28988) ret=-16
[    6.830000] start = 317
[    6.830000] pageno = 317
[    6.830000] alloc_contig_range(pfn=28989) ret=-16
[    6.840000] start = 318
[    6.840000] pageno = 318
[    6.840000] alloc_contig_range(pfn=28990) ret=-16
[    6.850000] start = 319
[    6.850000] pageno = 319
[    6.850000] alloc_contig_range(pfn=28991) ret=-16
[    6.860000] start = 320
[    6.860000] pageno = 320
[    6.860000] alloc_contig_range(pfn=28992) ret=-16
[    6.870000] start = 321
[    6.870000] pageno = 321
[    6.870000] alloc_contig_range(pfn=28993) ret=-16
[    6.880000] start = 322
[    6.880000] pageno = 322
[    6.880000] alloc_contig_range(pfn=28994) ret=-16
[    6.880000] start = 323
[    6.890000] pageno = 323
[    6.890000] alloc_contig_range(pfn=28995) ret=-16
[    6.890000] start = 324
[    6.900000] pageno = 324
[    6.900000] alloc_contig_range(pfn=28996) ret=-16
[    6.900000] start = 325
[    6.910000] pageno = 325
[    6.910000] alloc_contig_range(pfn=28997) ret=-16
[    6.910000] start = 326
[    6.920000] pageno = 326
[    6.920000] alloc_contig_range(pfn=28998) ret=-16
[    6.920000] start = 327
[    6.930000] pageno = 327
[    6.930000] alloc_contig_range(pfn=28999) ret=-16
[    6.930000] start = 328
[    6.940000] pageno = 328
[    6.940000] alloc_contig_range(pfn=29000) ret=-16
[    6.940000] start = 329
[    6.940000] pageno = 329
[    6.950000] alloc_contig_range(pfn=29001) ret=-16
[    6.950000] start = 330
[    6.950000] pageno = 330
[    6.960000] alloc_contig_range(pfn=29002) ret=-16
[    6.960000] start = 331
[    6.960000] pageno = 331
[    6.970000] alloc_contig_range(pfn=29003) ret=-16
[    6.970000] start = 332
[    6.970000] pageno = 332
[    6.980000] alloc_contig_range(pfn=29004) ret=-16
[    6.980000] start = 333
[    6.980000] pageno = 333
[    6.990000] alloc_contig_range(pfn=29005) ret=-16
[    6.990000] start = 334
[    6.990000] pageno = 334
[    7.000000] alloc_contig_range(pfn=29006) ret=-16
[    7.000000] start = 335
[    7.000000] pageno = 335
[    7.010000] alloc_contig_range(pfn=29007) ret=-16
[    7.010000] start = 336
[    7.010000] pageno = 336
[    7.020000] alloc_contig_range(pfn=29008) ret=-16
[    7.020000] start = 337
[    7.020000] pageno = 337
[    7.030000] alloc_contig_range(pfn=29009) ret=-16
[    7.030000] start = 338
[    7.030000] pageno = 338
[    7.040000] alloc_contig_range(pfn=29010) ret=-16
[    7.040000] start = 339
[    7.040000] pageno = 339
[    7.040000] alloc_contig_range(pfn=29011) ret=-16
[    7.050000] start = 340
[    7.050000] pageno = 340
[    7.050000] alloc_contig_range(pfn=29012) ret=-16
[    7.060000] start = 341
[    7.060000] pageno = 341
[    7.060000] alloc_contig_range(pfn=29013) ret=-16
[    7.070000] start = 342
[    7.070000] pageno = 342
[    7.070000] alloc_contig_range(pfn=29014) ret=-16
[    7.080000] start = 343
[    7.080000] pageno = 343
[    7.080000] alloc_contig_range(pfn=29015) ret=-16
[    7.090000] start = 344
[    7.090000] pageno = 344
[    7.090000] alloc_contig_range(pfn=29016) ret=-16
[    7.100000] start = 345
[    7.100000] pageno = 345
[    7.100000] alloc_contig_range(pfn=29017) ret=-16
[    7.110000] start = 346
[    7.110000] pageno = 346
[    7.110000] alloc_contig_range(pfn=29018) ret=-16
[    7.120000] start = 347
[    7.120000] pageno = 347
[    7.120000] alloc_contig_range(pfn=29019) ret=-16
[    7.130000] start = 348
[    7.130000] pageno = 348
[    7.130000] alloc_contig_range(pfn=29020) ret=-16
[    7.130000] start = 349
[    7.140000] pageno = 349
[    7.140000] alloc_contig_range(pfn=29021) ret=-16
[    7.140000] start = 350
[    7.150000] pageno = 350
[    7.150000] alloc_contig_range(pfn=29022) ret=-16
[    7.150000] start = 351
[    7.160000] pageno = 351
[    7.160000] alloc_contig_range(pfn=29023) ret=-16
[    7.160000] start = 352
[    7.170000] pageno = 352
[    7.170000] alloc_contig_range(pfn=29024) ret=-16
[    7.170000] start = 353
[    7.180000] pageno = 353
[    7.180000] alloc_contig_range(pfn=29025) ret=-16
[    7.180000] start = 354
[    7.190000] pageno = 354
[    7.190000] alloc_contig_range(pfn=29026) ret=-16
[    7.190000] start = 355
[    7.190000] pageno = 355
[    7.200000] alloc_contig_range(pfn=29027) ret=-16
[    7.200000] start = 356
[    7.200000] pageno = 356
[    7.210000] alloc_contig_range(pfn=29028) ret=-16
[    7.210000] start = 357
[    7.210000] pageno = 357
[    7.220000] alloc_contig_range(pfn=29029) ret=-16
[    7.220000] start = 358
[    7.220000] pageno = 358
[    7.230000] alloc_contig_range(pfn=29030) ret=-16
[    7.230000] start = 359
[    7.230000] pageno = 359
[    7.240000] alloc_contig_range(pfn=29031) ret=-16
[    7.240000] start = 360
[    7.240000] pageno = 360
[    7.250000] alloc_contig_range(pfn=29032) ret=-16
[    7.250000] start = 361
[    7.250000] pageno = 361
[    7.260000] alloc_contig_range(pfn=29033) ret=-16
[    7.260000] start = 362
[    7.260000] pageno = 362
[    7.270000] alloc_contig_range(pfn=29034) ret=-16
[    7.270000] start = 363
[    7.270000] pageno = 363
[    7.280000] alloc_contig_range(pfn=29035) ret=-16
[    7.280000] start = 364
[    7.280000] pageno = 364
[    7.290000] alloc_contig_range(pfn=29036) ret=-16
[    7.290000] start = 365
[    7.290000] pageno = 365
[    7.290000] alloc_contig_range(pfn=29037) ret=-16
[    7.300000] start = 366
[    7.300000] pageno = 366
[    7.300000] alloc_contig_range(pfn=29038) ret=-16
[    7.310000] start = 367
[    7.310000] pageno = 367
[    7.310000] alloc_contig_range(pfn=29039) ret=-16
[    7.320000] start = 368
[    7.320000] pageno = 368
[    7.320000] alloc_contig_range(pfn=29040) ret=-16
[    7.330000] start = 369
[    7.330000] pageno = 369
[    7.330000] alloc_contig_range(pfn=29041) ret=-16
[    7.340000] start = 370
[    7.340000] pageno = 370
[    7.340000] alloc_contig_range(pfn=29042) ret=-16
[    7.350000] start = 371
[    7.350000] pageno = 371
[    7.350000] alloc_contig_range(pfn=29043) ret=-16
[    7.360000] start = 372
[    7.360000] pageno = 372
[    7.360000] alloc_contig_range(pfn=29044) ret=-16
[    7.370000] start = 373
[    7.370000] pageno = 373
[    7.370000] alloc_contig_range(pfn=29045) ret=-16
[    7.380000] start = 374
[    7.380000] pageno = 374
[    7.380000] alloc_contig_range(pfn=29046) ret=-16
[    7.380000] start = 375
[    7.390000] pageno = 375
[    7.390000] alloc_contig_range(pfn=29047) ret=-16
[    7.390000] start = 376
[    7.400000] pageno = 376
[    7.400000] alloc_contig_range(pfn=29048) ret=-16
[    7.400000] start = 377
[    7.410000] pageno = 377
[    7.410000] alloc_contig_range(pfn=29049) ret=-16
[    7.410000] start = 378
[    7.420000] pageno = 378
[    7.420000] alloc_contig_range(pfn=29050) ret=-16
[    7.420000] start = 379
[    7.430000] pageno = 379
[    7.430000] alloc_contig_range(pfn=29051) ret=-16
[    7.430000] start = 380
[    7.440000] pageno = 380
[    7.440000] alloc_contig_range(pfn=29052) ret=-16
[    7.440000] start = 381
[    7.450000] pageno = 381
[    7.450000] alloc_contig_range(pfn=29053) ret=-16
[    7.450000] start = 382
[    7.450000] pageno = 382
[    7.460000] alloc_contig_range(pfn=29054) ret=-16
[    7.460000] start = 383
[    7.460000] pageno = 383
[    7.470000] alloc_contig_range(pfn=29055) ret=-16
[    7.470000] start = 384
[    7.470000] pageno = 384
[    7.480000] alloc_contig_range(pfn=29056) ret=-16
[    7.480000] start = 385
[    7.480000] pageno = 385
[    7.490000] alloc_contig_range(pfn=29057) ret=-16
[    7.490000] start = 386
[    7.490000] pageno = 386
[    7.500000] alloc_contig_range(pfn=29058) ret=-16
[    7.500000] start = 387
[    7.500000] pageno = 387
[    7.510000] alloc_contig_range(pfn=29059) ret=-16
[    7.510000] start = 388
[    7.510000] pageno = 388
[    7.520000] alloc_contig_range(pfn=29060) ret=-16
[    7.520000] start = 389
[    7.520000] pageno = 389
[    7.530000] alloc_contig_range(pfn=29061) ret=-16
[    7.530000] start = 390
[    7.530000] pageno = 390
[    7.540000] alloc_contig_range(pfn=29062) ret=-16
[    7.540000] start = 391
[    7.540000] pageno = 391
[    7.550000] alloc_contig_range(pfn=29063) ret=-16
[    7.550000] start = 392
[    7.550000] pageno = 392
[    7.550000] alloc_contig_range(pfn=29064) ret=-16
[    7.560000] start = 393
[    7.560000] pageno = 393
[    7.560000] alloc_contig_range(pfn=29065) ret=-16
[    7.570000] start = 394
[    7.570000] pageno = 394
[    7.570000] alloc_contig_range(pfn=29066) ret=-16
[    7.580000] start = 395
[    7.580000] pageno = 395
[    7.580000] alloc_contig_range(pfn=29067) ret=-16
[    7.590000] start = 396
[    7.590000] pageno = 396
[    7.590000] alloc_contig_range(pfn=29068) ret=-16
[    7.600000] start = 397
[    7.600000] pageno = 397
[    7.600000] alloc_contig_range(pfn=29069) ret=-16
[    7.610000] start = 398
[    7.610000] pageno = 398
[    7.610000] alloc_contig_range(pfn=29070) ret=-16
[    7.620000] start = 399
[    7.620000] pageno = 399
[    7.620000] alloc_contig_range(pfn=29071) ret=-16
[    7.630000] start = 400
[    7.630000] pageno = 400
[    7.630000] alloc_contig_range(pfn=29072) ret=-16
[    7.640000] start = 401
[    7.640000] pageno = 401
[    7.640000] alloc_contig_range(pfn=29073) ret=-16
[    7.640000] start = 402
[    7.650000] pageno = 402
[    7.650000] alloc_contig_range(pfn=29074) ret=-16
[    7.650000] start = 403
[    7.660000] pageno = 403
[    7.660000] alloc_contig_range(pfn=29075) ret=-16
[    7.660000] start = 404
[    7.670000] pageno = 404
[    7.670000] alloc_contig_range(pfn=29076) ret=-16
[    7.670000] start = 405
[    7.680000] pageno = 405
[    7.680000] alloc_contig_range(pfn=29077) ret=-16
[    7.680000] start = 406
[    7.690000] pageno = 406
[    7.690000] alloc_contig_range(pfn=29078) ret=-16
[    7.690000] start = 407
[    7.700000] pageno = 407
[    7.700000] alloc_contig_range(pfn=29079) ret=-16
[    7.700000] start = 408
[    7.700000] pageno = 408
[    7.710000] alloc_contig_range(pfn=29080) ret=-16
[    7.710000] start = 409
[    7.710000] pageno = 409
[    7.720000] alloc_contig_range(pfn=29081) ret=-16
[    7.720000] start = 410
[    7.720000] pageno = 410
[    7.730000] alloc_contig_range(pfn=29082) ret=-16
[    7.730000] start = 411
[    7.730000] pageno = 411
[    7.740000] alloc_contig_range(pfn=29083) ret=-16
[    7.740000] start = 412
[    7.740000] pageno = 412
[    7.750000] alloc_contig_range(pfn=29084) ret=-16
[    7.750000] start = 413
[    7.750000] pageno = 413
[    7.760000] alloc_contig_range(pfn=29085) ret=-16
[    7.760000] start = 414
[    7.760000] pageno = 414
[    7.770000] alloc_contig_range(pfn=29086) ret=-16
[    7.770000] start = 415
[    7.770000] pageno = 415
[    7.780000] alloc_contig_range(pfn=29087) ret=-16
[    7.780000] start = 416
[    7.780000] pageno = 416
[    7.790000] alloc_contig_range(pfn=29088) ret=-16
[    7.790000] start = 417
[    7.790000] pageno = 417
[    7.800000] alloc_contig_range(pfn=29089) ret=-16
[    7.800000] start = 418
[    7.800000] pageno = 418
[    7.800000] alloc_contig_range(pfn=29090) ret=-16
[    7.810000] start = 419
[    7.810000] pageno = 419
[    7.810000] alloc_contig_range(pfn=29091) ret=-16
[    7.820000] start = 420
[    7.820000] pageno = 420
[    7.820000] alloc_contig_range(pfn=29092) ret=-16
[    7.830000] start = 421
[    7.830000] pageno = 421
[    7.830000] alloc_contig_range(pfn=29093) ret=-16
[    7.840000] start = 422
[    7.840000] pageno = 422
[    7.840000] alloc_contig_range(pfn=29094) ret=-16
[    7.850000] start = 423
[    7.850000] pageno = 423
[    7.850000] alloc_contig_range(pfn=29095) ret=-16
[    7.860000] start = 424
[    7.860000] pageno = 424
[    7.860000] alloc_contig_range(pfn=29096) ret=-16
[    7.870000] start = 425
[    7.870000] pageno = 425
[    7.870000] alloc_contig_range(pfn=29097) ret=-16
[    7.880000] start = 426
[    7.880000] pageno = 426
[    7.880000] alloc_contig_range(pfn=29098) ret=-16
[    7.890000] start = 427
[    7.890000] pageno = 427
[    7.890000] alloc_contig_range(pfn=29099) ret=-16
[    7.890000] start = 428
[    7.900000] pageno = 428
[    7.900000] alloc_contig_range(pfn=29100) ret=-16
[    7.900000] start = 429
[    7.910000] pageno = 429
[    7.910000] alloc_contig_range(pfn=29101) ret=-16
[    7.910000] start = 430
[    7.920000] pageno = 430
[    7.920000] alloc_contig_range(pfn=29102) ret=-16
[    7.920000] start = 431
[    7.930000] pageno = 431
[    7.930000] alloc_contig_range(pfn=29103) ret=-16
[    7.930000] start = 432
[    7.940000] pageno = 432
[    7.940000] alloc_contig_range(pfn=29104) ret=-16
[    7.940000] start = 433
[    7.950000] pageno = 433
[    7.950000] alloc_contig_range(pfn=29105) ret=-16
[    7.950000] start = 434
[    7.960000] pageno = 434
[    7.960000] alloc_contig_range(pfn=29106) ret=-16
[    7.960000] start = 435
[    7.960000] pageno = 435
[    7.970000] alloc_contig_range(pfn=29107) ret=-16
[    7.970000] start = 436
[    7.970000] pageno = 436
[    7.980000] alloc_contig_range(pfn=29108) ret=-16
[    7.980000] start = 437
[    7.980000] pageno = 437
[    7.990000] alloc_contig_range(pfn=29109) ret=-16
[    7.990000] start = 438
[    7.990000] pageno = 438
[    8.000000] alloc_contig_range(pfn=29110) ret=-16
[    8.000000] start = 439
[    8.000000] pageno = 439
[    8.010000] alloc_contig_range(pfn=29111) ret=-16
[    8.010000] start = 440
[    8.010000] pageno = 440
[    8.020000] alloc_contig_range(pfn=29112) ret=-16
[    8.020000] start = 441
[    8.020000] pageno = 441
[    8.030000] alloc_contig_range(pfn=29113) ret=-16
[    8.030000] start = 442
[    8.030000] pageno = 442
[    8.040000] alloc_contig_range(pfn=29114) ret=-16
[    8.040000] start = 443
[    8.040000] pageno = 443
[    8.050000] alloc_contig_range(pfn=29115) ret=-16
[    8.050000] start = 444
[    8.050000] pageno = 444
[    8.060000] alloc_contig_range(pfn=29116) ret=-16
[    8.060000] start = 445
[    8.060000] pageno = 445
[    8.060000] alloc_contig_range(pfn=29117) ret=-16
[    8.070000] start = 446
[    8.070000] pageno = 446
[    8.070000] alloc_contig_range(pfn=29118) ret=-16
[    8.080000] start = 447
[    8.080000] pageno = 447
[    8.080000] alloc_contig_range(pfn=29119) ret=-16
[    8.090000] start = 448
[    8.090000] pageno = 448
[    8.090000] alloc_contig_range(pfn=29120) ret=-16
[    8.100000] start = 449
[    8.100000] pageno = 449
[    8.100000] alloc_contig_range(pfn=29121) ret=-16
[    8.110000] start = 450
[    8.110000] pageno = 450
[    8.110000] alloc_contig_range(pfn=29122) ret=-16
[    8.120000] start = 451
[    8.120000] pageno = 451
[    8.120000] alloc_contig_range(pfn=29123) ret=-16
[    8.130000] start = 452
[    8.130000] pageno = 452
[    8.130000] alloc_contig_range(pfn=29124) ret=-16
[    8.140000] start = 453
[    8.140000] pageno = 453
[    8.140000] alloc_contig_range(pfn=29125) ret=-16
[    8.150000] start = 454
[    8.150000] pageno = 454
[    8.150000] alloc_contig_range(pfn=29126) ret=-16
[    8.150000] start = 455
[    8.160000] pageno = 455
[    8.160000] alloc_contig_range(pfn=29127) ret=-16
[    8.160000] start = 456
[    8.170000] pageno = 456
[    8.170000] alloc_contig_range(pfn=29128) ret=-16
[    8.170000] start = 457
[    8.180000] pageno = 457
[    8.180000] alloc_contig_range(pfn=29129) ret=-16
[    8.180000] start = 458
[    8.190000] pageno = 458
[    8.190000] alloc_contig_range(pfn=29130) ret=-16
[    8.190000] start = 459
[    8.200000] pageno = 459
[    8.200000] alloc_contig_range(pfn=29131) ret=-16
[    8.200000] start = 460
[    8.210000] pageno = 460
[    8.210000] alloc_contig_range(pfn=29132) ret=-16
[    8.210000] start = 461
[    8.220000] pageno = 461
[    8.220000] alloc_contig_range(pfn=29133) ret=-16
[    8.220000] start = 462
[    8.220000] pageno = 462
[    8.230000] alloc_contig_range(pfn=29134) ret=-16
[    8.230000] start = 463
[    8.230000] pageno = 463
[    8.240000] alloc_contig_range(pfn=29135) ret=-16
[    8.240000] start = 464
[    8.240000] pageno = 464
[    8.250000] alloc_contig_range(pfn=29136) ret=-16
[    8.250000] start = 465
[    8.250000] pageno = 465
[    8.260000] alloc_contig_range(pfn=29137) ret=-16
[    8.260000] start = 466
[    8.260000] pageno = 466
[    8.270000] alloc_contig_range(pfn=29138) ret=-16
[    8.270000] start = 467
[    8.270000] pageno = 467
[    8.280000] alloc_contig_range(pfn=29139) ret=-16
[    8.280000] start = 468
[    8.280000] pageno = 468
[    8.290000] alloc_contig_range(pfn=29140) ret=-16
[    8.290000] start = 469
[    8.290000] pageno = 469
[    8.300000] alloc_contig_range(pfn=29141) ret=-16
[    8.300000] start = 470
[    8.300000] pageno = 470
[    8.310000] alloc_contig_range(pfn=29142) ret=-16
[    8.310000] start = 471
[    8.310000] pageno = 471
[    8.310000] alloc_contig_range(pfn=29143) ret=-16
[    8.320000] start = 472
[    8.320000] pageno = 472
[    8.320000] alloc_contig_range(pfn=29144) ret=-16
[    8.330000] start = 473
[    8.330000] pageno = 473
[    8.330000] alloc_contig_range(pfn=29145) ret=-16
[    8.340000] start = 474
[    8.340000] pageno = 474
[    8.340000] alloc_contig_range(pfn=29146) ret=-16
[    8.350000] start = 475
[    8.350000] pageno = 475
[    8.350000] alloc_contig_range(pfn=29147) ret=-16
[    8.360000] start = 476
[    8.360000] pageno = 476
[    8.360000] alloc_contig_range(pfn=29148) ret=-16
[    8.370000] start = 477
[    8.370000] pageno = 477
[    8.370000] alloc_contig_range(pfn=29149) ret=-16
[    8.380000] start = 478
[    8.380000] pageno = 478
[    8.380000] alloc_contig_range(pfn=29150) ret=-16
[    8.390000] start = 479
[    8.390000] pageno = 479
[    8.390000] alloc_contig_range(pfn=29151) ret=-16
[    8.400000] start = 480
[    8.400000] pageno = 480
[    8.400000] alloc_contig_range(pfn=29152) ret=-16
[    8.410000] start = 481
[    8.410000] pageno = 481
[    8.410000] alloc_contig_range(pfn=29153) ret=-16
[    8.410000] start = 482
[    8.420000] pageno = 482
[    8.420000] alloc_contig_range(pfn=29154) ret=-16
[    8.420000] start = 483
[    8.430000] pageno = 483
[    8.430000] alloc_contig_range(pfn=29155) ret=-16
[    8.430000] start = 484
[    8.440000] pageno = 484
[    8.440000] alloc_contig_range(pfn=29156) ret=-16
[    8.440000] start = 485
[    8.450000] pageno = 485
[    8.450000] alloc_contig_range(pfn=29157) ret=-16
[    8.450000] start = 486
[    8.460000] pageno = 486
[    8.460000] alloc_contig_range(pfn=29158) ret=-16
[    8.460000] start = 487
[    8.470000] pageno = 487
[    8.470000] alloc_contig_range(pfn=29159) ret=-16
[    8.470000] start = 488
[    8.470000] pageno = 488
[    8.480000] alloc_contig_range(pfn=29160) ret=-16
[    8.480000] start = 489
[    8.480000] pageno = 489
[    8.490000] alloc_contig_range(pfn=29161) ret=-16
[    8.490000] start = 490
[    8.490000] pageno = 490
[    8.500000] alloc_contig_range(pfn=29162) ret=-16
[    8.500000] start = 491
[    8.500000] pageno = 491
[    8.510000] alloc_contig_range(pfn=29163) ret=-16
[    8.510000] start = 492
[    8.510000] pageno = 492
[    8.520000] alloc_contig_range(pfn=29164) ret=-16
[    8.520000] start = 493
[    8.520000] pageno = 493
[    8.530000] alloc_contig_range(pfn=29165) ret=-16
[    8.530000] start = 494
[    8.530000] pageno = 494
[    8.540000] alloc_contig_range(pfn=29166) ret=-16
[    8.540000] start = 495
[    8.540000] pageno = 495
[    8.550000] alloc_contig_range(pfn=29167) ret=-16
[    8.550000] start = 496
[    8.550000] pageno = 496
[    8.560000] alloc_contig_range(pfn=29168) ret=-16
[    8.560000] start = 497
[    8.560000] pageno = 497
[    8.570000] alloc_contig_range(pfn=29169) ret=-16
[    8.570000] start = 498
[    8.570000] pageno = 498
[    8.570000] alloc_contig_range(pfn=29170) ret=-16
[    8.580000] start = 499
[    8.580000] pageno = 499
[    8.580000] alloc_contig_range(pfn=29171) ret=-16
[    8.590000] start = 500
[    8.590000] pageno = 500
[    8.590000] alloc_contig_range(pfn=29172) ret=-16
[    8.600000] start = 501
[    8.600000] pageno = 501
[    8.600000] alloc_contig_range(pfn=29173) ret=-16
[    8.610000] start = 502
[    8.610000] pageno = 502
[    8.610000] alloc_contig_range(pfn=29174) ret=-16
[    8.620000] start = 503
[    8.620000] pageno = 503
[    8.620000] alloc_contig_range(pfn=29175) ret=-16
[    8.630000] start = 504
[    8.630000] pageno = 504
[    8.630000] alloc_contig_range(pfn=29176) ret=-16
[    8.640000] start = 505
[    8.640000] pageno = 505
[    8.640000] alloc_contig_range(pfn=29177) ret=-16
[    8.650000] start = 506
[    8.650000] pageno = 506
[    8.650000] alloc_contig_range(pfn=29178) ret=-16
[    8.660000] start = 507
[    8.660000] pageno = 507
[    8.660000] alloc_contig_range(pfn=29179) ret=-16
[    8.660000] start = 508
[    8.670000] pageno = 508
[    8.670000] alloc_contig_range(pfn=29180) ret=-16
[    8.670000] start = 509
[    8.680000] pageno = 509
[    8.680000] alloc_contig_range(pfn=29181) ret=-16
[    8.680000] start = 510
[    8.690000] pageno = 510
[    8.690000] alloc_contig_range(pfn=29182) ret=-16
[    8.690000] start = 511
[    8.700000] pageno = 511
[    8.700000] alloc_contig_range(pfn=29183) ret=0
[    8.700000] dma_alloc_from_contiguous(): returned c04a9fe0
[    8.710000] vt8500-ehci d8007900.ehci: irq 43, io mem 0xd8007900
[    8.730000] vt8500-ehci d8007900.ehci: USB 2.0 started, EHCI 1.00
[    8.730000] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    8.740000] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    8.740000] usb usb1: Product: VT8500 EHCI
[    8.750000] usb usb1: Manufacturer: Linux 3.7.0-rc1+ ehci_hcd
[    8.750000] usb usb1: SerialNumber: VT8500
[    8.760000] hub 1-0:1.0: USB hub found
[    8.760000] hub 1-0:1.0: 4 ports detected
[    8.770000] uhci_hcd: USB Universal Host Controller Interface driver
[    8.770000] platform-uhci d8007b00.uhci: Generic UHCI Host Controller
[    8.780000] platform-uhci d8007b00.uhci: new USB bus registered, assigned bus number 2
[    8.790000] platform-uhci d8007b00.uhci: detected 2 ports
[    8.790000] platform-uhci d8007b00.uhci: irq 43, io mem 0xd8007b00
[    8.800000] __dma_alloc: __alloc_from_contiguous
[    8.800000] dma_alloc_from_contiguous(cma c683c7a0, count 1, align 0)
[    8.810000] pageno = 0
[    8.810000] alloc_contig_range(pfn=28672) ret=-16
[    8.820000] start = 1
[    8.820000] pageno = 1
[    8.820000] alloc_contig_range(pfn=28673) ret=-16
[    8.820000] start = 2
[    8.830000] pageno = 2
[    8.830000] alloc_contig_range(pfn=28674) ret=-16
[    8.830000] start = 3
[    8.840000] pageno = 3
[    8.840000] alloc_contig_range(pfn=28675) ret=-16
[    8.840000] start = 4
[    8.850000] pageno = 4
[    8.850000] alloc_contig_range(pfn=28676) ret=-16
[    8.850000] start = 5
[    8.850000] pageno = 5
[    8.860000] alloc_contig_range(pfn=28677) ret=-16
[    8.860000] start = 6
[    8.860000] pageno = 6
[    8.870000] alloc_contig_range(pfn=28678) ret=-16
[    8.870000] start = 7
[    8.870000] pageno = 7
[    8.880000] alloc_contig_range(pfn=28679) ret=-16
[    8.880000] start = 8
[    8.880000] pageno = 8
[    8.890000] alloc_contig_range(pfn=28680) ret=-16
[    8.890000] start = 9
[    8.890000] pageno = 9
[    8.900000] alloc_contig_range(pfn=28681) ret=-16
[    8.900000] start = 10
[    8.900000] pageno = 10
[    8.900000] alloc_contig_range(pfn=28682) ret=-16
[    8.910000] start = 11
[    8.910000] pageno = 11
[    8.910000] alloc_contig_range(pfn=28683) ret=-16
[    8.920000] start = 12
[    8.920000] pageno = 12
[    8.920000] alloc_contig_range(pfn=28684) ret=-16
[    8.930000] start = 13
[    8.930000] pageno = 13
[    8.930000] alloc_contig_range(pfn=28685) ret=-16
[    8.940000] start = 14
[    8.940000] pageno = 14
[    8.940000] alloc_contig_range(pfn=28686) ret=-16
[    8.950000] start = 15
[    8.950000] pageno = 15
[    8.950000] alloc_contig_range(pfn=28687) ret=-16
[    8.960000] start = 16
[    8.960000] pageno = 16
[    8.960000] alloc_contig_range(pfn=28688) ret=-16
[    8.970000] start = 17
[    8.970000] pageno = 17
[    8.970000] alloc_contig_range(pfn=28689) ret=-16
[    8.970000] start = 18
[    8.980000] pageno = 18
[    8.980000] alloc_contig_range(pfn=28690) ret=-16
[    8.980000] start = 19
[    8.990000] pageno = 19
[    8.990000] alloc_contig_range(pfn=28691) ret=-16
[    8.990000] start = 20
[    9.000000] pageno = 20
[    9.000000] alloc_contig_range(pfn=28692) ret=-16
[    9.000000] start = 21
[    9.010000] pageno = 21
[    9.010000] alloc_contig_range(pfn=28693) ret=-16
[    9.010000] start = 22
[    9.010000] pageno = 22
[    9.020000] alloc_contig_range(pfn=28694) ret=-16
[    9.020000] start = 23
[    9.020000] pageno = 23
[    9.030000] alloc_contig_range(pfn=28695) ret=-16
[    9.030000] start = 24
[    9.030000] pageno = 24
[    9.040000] alloc_contig_range(pfn=28696) ret=-16
[    9.040000] start = 25
[    9.040000] pageno = 25
[    9.050000] alloc_contig_range(pfn=28697) ret=-16
[    9.050000] start = 26
[    9.050000] pageno = 26
[    9.060000] alloc_contig_range(pfn=28698) ret=-16
[    9.060000] start = 27
[    9.060000] pageno = 27
[    9.070000] alloc_contig_range(pfn=28699) ret=-16
[    9.070000] start = 28
[    9.070000] pageno = 28
[    9.070000] alloc_contig_range(pfn=28700) ret=-16
[    9.080000] start = 29
[    9.080000] pageno = 29
[    9.080000] alloc_contig_range(pfn=28701) ret=-16
[    9.090000] start = 30
[    9.090000] pageno = 30
[    9.090000] alloc_contig_range(pfn=28702) ret=-16
[    9.100000] start = 31
[    9.100000] pageno = 31
[    9.100000] alloc_contig_range(pfn=28703) ret=-16
[    9.110000] start = 32
[    9.110000] pageno = 32
[    9.110000] alloc_contig_range(pfn=28704) ret=-16
[    9.120000] start = 33
[    9.120000] pageno = 33
[    9.120000] alloc_contig_range(pfn=28705) ret=-16
[    9.130000] start = 34
[    9.130000] pageno = 34
[    9.130000] alloc_contig_range(pfn=28706) ret=-16
[    9.140000] start = 35
[    9.140000] pageno = 35
[    9.140000] alloc_contig_range(pfn=28707) ret=-16
[    9.140000] start = 36
[    9.150000] pageno = 36
[    9.150000] alloc_contig_range(pfn=28708) ret=-16
[    9.150000] start = 37
[    9.160000] pageno = 37
[    9.160000] alloc_contig_range(pfn=28709) ret=-16
[    9.160000] start = 38
[    9.170000] pageno = 38
[    9.170000] alloc_contig_range(pfn=28710) ret=-16
[    9.170000] start = 39
[    9.180000] pageno = 39
[    9.180000] alloc_contig_range(pfn=28711) ret=-16
[    9.180000] start = 40
[    9.180000] pageno = 40
[    9.190000] alloc_contig_range(pfn=28712) ret=-16
[    9.190000] start = 41
[    9.190000] pageno = 41
[    9.200000] alloc_contig_range(pfn=28713) ret=-16
[    9.200000] start = 42
[    9.200000] pageno = 42
[    9.210000] alloc_contig_range(pfn=28714) ret=-16
[    9.210000] start = 43
[    9.210000] pageno = 43
[    9.220000] alloc_contig_range(pfn=28715) ret=-16
[    9.220000] start = 44
[    9.220000] pageno = 44
[    9.230000] alloc_contig_range(pfn=28716) ret=-16
[    9.230000] start = 45
[    9.230000] pageno = 45
[    9.240000] alloc_contig_range(pfn=28717) ret=-16
[    9.240000] start = 46
[    9.240000] pageno = 46
[    9.240000] alloc_contig_range(pfn=28718) ret=-16
[    9.250000] start = 47
[    9.250000] pageno = 47
[    9.250000] alloc_contig_range(pfn=28719) ret=-16
[    9.260000] start = 48
[    9.260000] pageno = 48
[    9.260000] alloc_contig_range(pfn=28720) ret=-16
[    9.270000] start = 49
[    9.270000] pageno = 49
[    9.270000] alloc_contig_range(pfn=28721) ret=-16
[    9.280000] start = 50
[    9.280000] pageno = 50
[    9.280000] alloc_contig_range(pfn=28722) ret=-16
[    9.290000] start = 51
[    9.290000] pageno = 51
[    9.290000] alloc_contig_range(pfn=28723) ret=-16
[    9.300000] start = 52
[    9.300000] pageno = 52
[    9.300000] alloc_contig_range(pfn=28724) ret=-16
[    9.310000] start = 53
[    9.310000] pageno = 53
[    9.310000] alloc_contig_range(pfn=28725) ret=-16
[    9.310000] start = 54
[    9.320000] pageno = 54
[    9.320000] alloc_contig_range(pfn=28726) ret=-16
[    9.320000] start = 55
[    9.330000] pageno = 55
[    9.330000] alloc_contig_range(pfn=28727) ret=-16
[    9.330000] start = 56
[    9.340000] pageno = 56
[    9.340000] alloc_contig_range(pfn=28728) ret=-16
[    9.340000] start = 57
[    9.350000] pageno = 57
[    9.350000] alloc_contig_range(pfn=28729) ret=-16
[    9.350000] start = 58
[    9.350000] pageno = 58
[    9.360000] alloc_contig_range(pfn=28730) ret=-16
[    9.360000] start = 59
[    9.360000] pageno = 59
[    9.370000] alloc_contig_range(pfn=28731) ret=-16
[    9.370000] start = 60
[    9.370000] pageno = 60
[    9.380000] alloc_contig_range(pfn=28732) ret=-16
[    9.380000] start = 61
[    9.380000] pageno = 61
[    9.390000] alloc_contig_range(pfn=28733) ret=-16
[    9.390000] start = 62
[    9.390000] pageno = 62
[    9.400000] alloc_contig_range(pfn=28734) ret=-16
[    9.400000] start = 63
[    9.400000] pageno = 63
[    9.410000] alloc_contig_range(pfn=28735) ret=-16
[    9.410000] start = 64
[    9.410000] pageno = 64
[    9.410000] alloc_contig_range(pfn=28736) ret=-16
[    9.420000] start = 65
[    9.420000] pageno = 65
[    9.420000] alloc_contig_range(pfn=28737) ret=-16
[    9.430000] start = 66
[    9.430000] pageno = 66
[    9.430000] alloc_contig_range(pfn=28738) ret=-16
[    9.440000] start = 67
[    9.440000] pageno = 67
[    9.440000] alloc_contig_range(pfn=28739) ret=-16
[    9.450000] start = 68
[    9.450000] pageno = 68
[    9.450000] alloc_contig_range(pfn=28740) ret=-16
[    9.460000] start = 69
[    9.460000] pageno = 69
[    9.460000] alloc_contig_range(pfn=28741) ret=-16
[    9.470000] start = 70
[    9.470000] pageno = 70
[    9.470000] alloc_contig_range(pfn=28742) ret=-16
[    9.480000] start = 71
[    9.480000] pageno = 71
[    9.480000] alloc_contig_range(pfn=28743) ret=-16
[    9.480000] start = 72
[    9.490000] pageno = 72
[    9.490000] alloc_contig_range(pfn=28744) ret=-16
[    9.490000] start = 73
[    9.500000] pageno = 73
[    9.500000] alloc_contig_range(pfn=28745) ret=-16
[    9.500000] start = 74
[    9.510000] pageno = 74
[    9.510000] alloc_contig_range(pfn=28746) ret=-16
[    9.510000] start = 75
[    9.520000] pageno = 75
[    9.520000] alloc_contig_range(pfn=28747) ret=-16
[    9.520000] start = 76
[    9.520000] pageno = 76
[    9.530000] alloc_contig_range(pfn=28748) ret=-16
[    9.530000] start = 77
[    9.530000] pageno = 77
[    9.540000] alloc_contig_range(pfn=28749) ret=-16
[    9.540000] start = 78
[    9.540000] pageno = 78
[    9.550000] alloc_contig_range(pfn=28750) ret=-16
[    9.550000] start = 79
[    9.550000] pageno = 79
[    9.560000] alloc_contig_range(pfn=28751) ret=-16
[    9.560000] start = 80
[    9.560000] pageno = 80
[    9.570000] alloc_contig_range(pfn=28752) ret=-16
[    9.570000] start = 81
[    9.570000] pageno = 81
[    9.580000] alloc_contig_range(pfn=28753) ret=-16
[    9.580000] start = 82
[    9.580000] pageno = 82
[    9.580000] alloc_contig_range(pfn=28754) ret=-16
[    9.590000] start = 83
[    9.590000] pageno = 83
[    9.590000] alloc_contig_range(pfn=28755) ret=-16
[    9.600000] start = 84
[    9.600000] pageno = 84
[    9.600000] alloc_contig_range(pfn=28756) ret=-16
[    9.610000] start = 85
[    9.610000] pageno = 85
[    9.610000] alloc_contig_range(pfn=28757) ret=-16
[    9.620000] start = 86
[    9.620000] pageno = 86
[    9.620000] alloc_contig_range(pfn=28758) ret=-16
[    9.630000] start = 87
[    9.630000] pageno = 87
[    9.630000] alloc_contig_range(pfn=28759) ret=-16
[    9.640000] start = 88
[    9.640000] pageno = 88
[    9.640000] alloc_contig_range(pfn=28760) ret=-16
[    9.650000] start = 89
[    9.650000] pageno = 89
[    9.650000] alloc_contig_range(pfn=28761) ret=-16
[    9.650000] start = 90
[    9.660000] pageno = 90
[    9.660000] alloc_contig_range(pfn=28762) ret=-16
[    9.660000] start = 91
[    9.670000] pageno = 91
[    9.670000] alloc_contig_range(pfn=28763) ret=-16
[    9.670000] start = 92
[    9.680000] pageno = 92
[    9.680000] alloc_contig_range(pfn=28764) ret=-16
[    9.680000] start = 93
[    9.690000] pageno = 93
[    9.690000] alloc_contig_range(pfn=28765) ret=-16
[    9.690000] start = 94
[    9.690000] pageno = 94
[    9.700000] alloc_contig_range(pfn=28766) ret=-16
[    9.700000] start = 95
[    9.700000] pageno = 95
[    9.710000] alloc_contig_range(pfn=28767) ret=-16
[    9.710000] start = 96
[    9.710000] pageno = 96
[    9.720000] alloc_contig_range(pfn=28768) ret=-16
[    9.720000] start = 97
[    9.720000] pageno = 97
[    9.730000] alloc_contig_range(pfn=28769) ret=-16
[    9.730000] start = 98
[    9.730000] pageno = 98
[    9.740000] alloc_contig_range(pfn=28770) ret=-16
[    9.740000] start = 99
[    9.740000] pageno = 99
[    9.750000] alloc_contig_range(pfn=28771) ret=-16
[    9.750000] start = 100
[    9.750000] pageno = 100
[    9.750000] alloc_contig_range(pfn=28772) ret=-16
[    9.760000] start = 101
[    9.760000] pageno = 101
[    9.760000] alloc_contig_range(pfn=28773) ret=-16
[    9.770000] start = 102
[    9.770000] pageno = 102
[    9.770000] alloc_contig_range(pfn=28774) ret=-16
[    9.780000] start = 103
[    9.780000] pageno = 103
[    9.780000] alloc_contig_range(pfn=28775) ret=-16
[    9.790000] start = 104
[    9.790000] pageno = 104
[    9.790000] alloc_contig_range(pfn=28776) ret=-16
[    9.800000] start = 105
[    9.800000] pageno = 105
[    9.800000] alloc_contig_range(pfn=28777) ret=-16
[    9.810000] start = 106
[    9.810000] pageno = 106
[    9.810000] alloc_contig_range(pfn=28778) ret=-16
[    9.820000] start = 107
[    9.820000] pageno = 107
[    9.820000] alloc_contig_range(pfn=28779) ret=-16
[    9.830000] start = 108
[    9.830000] pageno = 108
[    9.830000] alloc_contig_range(pfn=28780) ret=-16
[    9.840000] start = 109
[    9.840000] pageno = 109
[    9.840000] alloc_contig_range(pfn=28781) ret=-16
[    9.850000] start = 110
[    9.850000] pageno = 110
[    9.850000] alloc_contig_range(pfn=28782) ret=-16
[    9.860000] start = 111
[    9.860000] pageno = 111
[    9.860000] alloc_contig_range(pfn=28783) ret=-16
[    9.860000] start = 112
[    9.870000] pageno = 112
[    9.870000] alloc_contig_range(pfn=28784) ret=-16
[    9.870000] start = 113
[    9.880000] pageno = 113
[    9.880000] alloc_contig_range(pfn=28785) ret=-16
[    9.880000] start = 114
[    9.890000] pageno = 114
[    9.890000] alloc_contig_range(pfn=28786) ret=-16
[    9.890000] start = 115
[    9.900000] pageno = 115
[    9.900000] alloc_contig_range(pfn=28787) ret=-16
[    9.900000] start = 116
[    9.910000] pageno = 116
[    9.910000] alloc_contig_range(pfn=28788) ret=-16
[    9.910000] start = 117
[    9.920000] pageno = 117
[    9.920000] alloc_contig_range(pfn=28789) ret=-16
[    9.920000] start = 118
[    9.920000] pageno = 118
[    9.930000] alloc_contig_range(pfn=28790) ret=-16
[    9.930000] start = 119
[    9.930000] pageno = 119
[    9.940000] alloc_contig_range(pfn=28791) ret=-16
[    9.940000] start = 120
[    9.940000] pageno = 120
[    9.950000] alloc_contig_range(pfn=28792) ret=-16
[    9.950000] start = 121
[    9.950000] pageno = 121
[    9.960000] alloc_contig_range(pfn=28793) ret=-16
[    9.960000] start = 122
[    9.960000] pageno = 122
[    9.970000] alloc_contig_range(pfn=28794) ret=-16
[    9.970000] start = 123
[    9.970000] pageno = 123
[    9.980000] alloc_contig_range(pfn=28795) ret=-16
[    9.980000] start = 124
[    9.980000] pageno = 124
[    9.990000] alloc_contig_range(pfn=28796) ret=-16
[    9.990000] start = 125
[    9.990000] pageno = 125
[   10.000000] alloc_contig_range(pfn=28797) ret=-16
[   10.000000] start = 126
[   10.000000] pageno = 126
[   10.010000] alloc_contig_range(pfn=28798) ret=-16
[   10.010000] start = 127
[   10.010000] pageno = 127
[   10.010000] alloc_contig_range(pfn=28799) ret=-16
[   10.020000] start = 128
[   10.020000] pageno = 128
[   10.020000] alloc_contig_range(pfn=28800) ret=-16
[   10.030000] start = 129
[   10.030000] pageno = 129
[   10.030000] alloc_contig_range(pfn=28801) ret=-16
[   10.040000] start = 130
[   10.040000] pageno = 130
[   10.040000] alloc_contig_range(pfn=28802) ret=-16
[   10.050000] start = 131
[   10.050000] pageno = 131
[   10.050000] alloc_contig_range(pfn=28803) ret=-16
[   10.060000] start = 132
[   10.060000] pageno = 132
[   10.060000] alloc_contig_range(pfn=28804) ret=-16
[   10.070000] start = 133
[   10.070000] pageno = 133
[   10.070000] alloc_contig_range(pfn=28805) ret=-16
[   10.080000] start = 134
[   10.080000] pageno = 134
[   10.080000] alloc_contig_range(pfn=28806) ret=-16
[   10.090000] start = 135
[   10.090000] pageno = 135
[   10.090000] alloc_contig_range(pfn=28807) ret=-16
[   10.100000] start = 136
[   10.100000] pageno = 136
[   10.100000] alloc_contig_range(pfn=28808) ret=-16
[   10.110000] start = 137
[   10.110000] pageno = 137
[   10.110000] alloc_contig_range(pfn=28809) ret=-16
[   10.110000] start = 138
[   10.120000] pageno = 138
[   10.120000] alloc_contig_range(pfn=28810) ret=-16
[   10.120000] start = 139
[   10.130000] pageno = 139
[   10.130000] alloc_contig_range(pfn=28811) ret=-16
[   10.130000] start = 140
[   10.140000] pageno = 140
[   10.140000] alloc_contig_range(pfn=28812) ret=-16
[   10.140000] start = 141
[   10.150000] pageno = 141
[   10.150000] alloc_contig_range(pfn=28813) ret=-16
[   10.150000] start = 142
[   10.160000] pageno = 142
[   10.160000] alloc_contig_range(pfn=28814) ret=-16
[   10.160000] start = 143
[   10.170000] pageno = 143
[   10.170000] alloc_contig_range(pfn=28815) ret=-16
[   10.170000] start = 144
[   10.170000] pageno = 144
[   10.180000] alloc_contig_range(pfn=28816) ret=-16
[   10.180000] start = 145
[   10.180000] pageno = 145
[   10.190000] alloc_contig_range(pfn=28817) ret=-16
[   10.190000] start = 146
[   10.190000] pageno = 146
[   10.200000] alloc_contig_range(pfn=28818) ret=-16
[   10.200000] start = 147
[   10.200000] pageno = 147
[   10.210000] alloc_contig_range(pfn=28819) ret=-16
[   10.210000] start = 148
[   10.210000] pageno = 148
[   10.220000] alloc_contig_range(pfn=28820) ret=-16
[   10.220000] start = 149
[   10.220000] pageno = 149
[   10.230000] alloc_contig_range(pfn=28821) ret=-16
[   10.230000] start = 150
[   10.230000] pageno = 150
[   10.240000] alloc_contig_range(pfn=28822) ret=-16
[   10.240000] start = 151
[   10.240000] pageno = 151
[   10.250000] alloc_contig_range(pfn=28823) ret=-16
[   10.250000] start = 152
[   10.250000] pageno = 152
[   10.260000] alloc_contig_range(pfn=28824) ret=-16
[   10.260000] start = 153
[   10.260000] pageno = 153
[   10.260000] alloc_contig_range(pfn=28825) ret=-16
[   10.270000] start = 154
[   10.270000] pageno = 154
[   10.270000] alloc_contig_range(pfn=28826) ret=-16
[   10.280000] start = 155
[   10.280000] pageno = 155
[   10.280000] alloc_contig_range(pfn=28827) ret=-16
[   10.290000] start = 156
[   10.290000] pageno = 156
[   10.290000] alloc_contig_range(pfn=28828) ret=-16
[   10.300000] start = 157
[   10.300000] pageno = 157
[   10.300000] alloc_contig_range(pfn=28829) ret=-16
[   10.310000] start = 158
[   10.310000] pageno = 158
[   10.310000] alloc_contig_range(pfn=28830) ret=-16
[   10.320000] start = 159
[   10.320000] pageno = 159
[   10.320000] alloc_contig_range(pfn=28831) ret=-16
[   10.330000] start = 160
[   10.330000] pageno = 160
[   10.330000] alloc_contig_range(pfn=28832) ret=-16
[   10.340000] start = 161
[   10.340000] pageno = 161
[   10.340000] alloc_contig_range(pfn=28833) ret=-16
[   10.350000] start = 162
[   10.350000] pageno = 162
[   10.350000] alloc_contig_range(pfn=28834) ret=-16
[   10.360000] start = 163
[   10.360000] pageno = 163
[   10.360000] alloc_contig_range(pfn=28835) ret=-16
[   10.360000] start = 164
[   10.370000] pageno = 164
[   10.370000] alloc_contig_range(pfn=28836) ret=-16
[   10.370000] start = 165
[   10.380000] pageno = 165
[   10.380000] alloc_contig_range(pfn=28837) ret=-16
[   10.380000] start = 166
[   10.390000] pageno = 166
[   10.390000] alloc_contig_range(pfn=28838) ret=-16
[   10.390000] start = 167
[   10.400000] pageno = 167
[   10.400000] alloc_contig_range(pfn=28839) ret=-16
[   10.400000] start = 168
[   10.410000] pageno = 168
[   10.410000] alloc_contig_range(pfn=28840) ret=-16
[   10.410000] start = 169
[   10.420000] pageno = 169
[   10.420000] alloc_contig_range(pfn=28841) ret=-16
[   10.420000] start = 170
[   10.430000] pageno = 170
[   10.430000] alloc_contig_range(pfn=28842) ret=-16
[   10.430000] start = 171
[   10.430000] pageno = 171
[   10.440000] alloc_contig_range(pfn=28843) ret=-16
[   10.440000] start = 172
[   10.440000] pageno = 172
[   10.450000] alloc_contig_range(pfn=28844) ret=-16
[   10.450000] start = 173
[   10.450000] pageno = 173
[   10.460000] alloc_contig_range(pfn=28845) ret=-16
[   10.460000] start = 174
[   10.460000] pageno = 174
[   10.470000] alloc_contig_range(pfn=28846) ret=-16
[   10.470000] start = 175
[   10.470000] pageno = 175
[   10.480000] alloc_contig_range(pfn=28847) ret=-16
[   10.480000] start = 176
[   10.480000] pageno = 176
[   10.490000] alloc_contig_range(pfn=28848) ret=-16
[   10.490000] start = 177
[   10.490000] pageno = 177
[   10.500000] alloc_contig_range(pfn=28849) ret=-16
[   10.500000] start = 178
[   10.500000] pageno = 178
[   10.510000] alloc_contig_range(pfn=28850) ret=-16
[   10.510000] start = 179
[   10.510000] pageno = 179
[   10.510000] alloc_contig_range(pfn=28851) ret=-16
[   10.520000] start = 180
[   10.520000] pageno = 180
[   10.520000] alloc_contig_range(pfn=28852) ret=-16
[   10.530000] start = 181
[   10.530000] pageno = 181
[   10.530000] alloc_contig_range(pfn=28853) ret=-16
[   10.540000] start = 182
[   10.540000] pageno = 182
[   10.540000] alloc_contig_range(pfn=28854) ret=-16
[   10.550000] start = 183
[   10.550000] pageno = 183
[   10.550000] alloc_contig_range(pfn=28855) ret=-16
[   10.560000] start = 184
[   10.560000] pageno = 184
[   10.560000] alloc_contig_range(pfn=28856) ret=-16
[   10.570000] start = 185
[   10.570000] pageno = 185
[   10.570000] alloc_contig_range(pfn=28857) ret=-16
[   10.580000] start = 186
[   10.580000] pageno = 186
[   10.580000] alloc_contig_range(pfn=28858) ret=-16
[   10.590000] start = 187
[   10.590000] pageno = 187
[   10.590000] alloc_contig_range(pfn=28859) ret=-16
[   10.600000] start = 188
[   10.600000] pageno = 188
[   10.600000] alloc_contig_range(pfn=28860) ret=-16
[   10.610000] start = 189
[   10.610000] pageno = 189
[   10.610000] alloc_contig_range(pfn=28861) ret=-16
[   10.620000] start = 190
[   10.620000] pageno = 190
[   10.620000] alloc_contig_range(pfn=28862) ret=-16
[   10.620000] start = 191
[   10.630000] pageno = 191
[   10.630000] alloc_contig_range(pfn=28863) ret=-16
[   10.630000] start = 192
[   10.640000] pageno = 192
[   10.640000] alloc_contig_range(pfn=28864) ret=-16
[   10.640000] start = 193
[   10.650000] pageno = 193
[   10.650000] alloc_contig_range(pfn=28865) ret=-16
[   10.650000] start = 194
[   10.660000] pageno = 194
[   10.660000] alloc_contig_range(pfn=28866) ret=-16
[   10.660000] start = 195
[   10.670000] pageno = 195
[   10.670000] alloc_contig_range(pfn=28867) ret=-16
[   10.670000] start = 196
[   10.680000] pageno = 196
[   10.680000] alloc_contig_range(pfn=28868) ret=-16
[   10.680000] start = 197
[   10.680000] pageno = 197
[   10.690000] alloc_contig_range(pfn=28869) ret=-16
[   10.690000] start = 198
[   10.690000] pageno = 198
[   10.700000] alloc_contig_range(pfn=28870) ret=-16
[   10.700000] start = 199
[   10.700000] pageno = 199
[   10.710000] alloc_contig_range(pfn=28871) ret=-16
[   10.710000] start = 200
[   10.710000] pageno = 200
[   10.720000] alloc_contig_range(pfn=28872) ret=-16
[   10.720000] start = 201
[   10.720000] pageno = 201
[   10.730000] alloc_contig_range(pfn=28873) ret=-16
[   10.730000] start = 202
[   10.730000] pageno = 202
[   10.740000] alloc_contig_range(pfn=28874) ret=-16
[   10.740000] start = 203
[   10.740000] pageno = 203
[   10.750000] alloc_contig_range(pfn=28875) ret=-16
[   10.750000] start = 204
[   10.750000] pageno = 204
[   10.760000] alloc_contig_range(pfn=28876) ret=-16
[   10.760000] start = 205
[   10.760000] pageno = 205
[   10.770000] alloc_contig_range(pfn=28877) ret=-16
[   10.770000] start = 206
[   10.770000] pageno = 206
[   10.770000] alloc_contig_range(pfn=28878) ret=-16
[   10.780000] start = 207
[   10.780000] pageno = 207
[   10.780000] alloc_contig_range(pfn=28879) ret=-16
[   10.790000] start = 208
[   10.790000] pageno = 208
[   10.790000] alloc_contig_range(pfn=28880) ret=-16
[   10.800000] start = 209
[   10.800000] pageno = 209
[   10.800000] alloc_contig_range(pfn=28881) ret=-16
[   10.810000] start = 210
[   10.810000] pageno = 210
[   10.810000] alloc_contig_range(pfn=28882) ret=-16
[   10.820000] start = 211
[   10.820000] pageno = 211
[   10.820000] alloc_contig_range(pfn=28883) ret=-16
[   10.830000] start = 212
[   10.830000] pageno = 212
[   10.830000] alloc_contig_range(pfn=28884) ret=-16
[   10.840000] start = 213
[   10.840000] pageno = 213
[   10.840000] alloc_contig_range(pfn=28885) ret=-16
[   10.850000] start = 214
[   10.850000] pageno = 214
[   10.850000] alloc_contig_range(pfn=28886) ret=-16
[   10.860000] start = 215
[   10.860000] pageno = 215
[   10.860000] alloc_contig_range(pfn=28887) ret=-16
[   10.870000] start = 216
[   10.870000] pageno = 216
[   10.870000] alloc_contig_range(pfn=28888) ret=-16
[   10.870000] start = 217
[   10.880000] pageno = 217
[   10.880000] alloc_contig_range(pfn=28889) ret=-16
[   10.880000] start = 218
[   10.890000] pageno = 218
[   10.890000] alloc_contig_range(pfn=28890) ret=-16
[   10.890000] start = 219
[   10.900000] pageno = 219
[   10.900000] alloc_contig_range(pfn=28891) ret=-16
[   10.900000] start = 220
[   10.910000] pageno = 220
[   10.910000] alloc_contig_range(pfn=28892) ret=-16
[   10.910000] start = 221
[   10.920000] pageno = 221
[   10.920000] alloc_contig_range(pfn=28893) ret=-16
[   10.920000] start = 222
[   10.930000] pageno = 222
[   10.930000] alloc_contig_range(pfn=28894) ret=-16
[   10.930000] start = 223
[   10.930000] pageno = 223
[   10.940000] alloc_contig_range(pfn=28895) ret=-16
[   10.940000] start = 224
[   10.940000] pageno = 224
[   10.950000] alloc_contig_range(pfn=28896) ret=-16
[   10.950000] start = 225
[   10.950000] pageno = 225
[   10.960000] alloc_contig_range(pfn=28897) ret=-16
[   10.960000] start = 226
[   10.960000] pageno = 226
[   10.970000] alloc_contig_range(pfn=28898) ret=-16
[   10.970000] start = 227
[   10.970000] pageno = 227
[   10.980000] alloc_contig_range(pfn=28899) ret=-16
[   10.980000] start = 228
[   10.980000] pageno = 228
[   10.990000] alloc_contig_range(pfn=28900) ret=-16
[   10.990000] start = 229
[   10.990000] pageno = 229
[   11.000000] alloc_contig_range(pfn=28901) ret=-16
[   11.000000] start = 230
[   11.000000] pageno = 230
[   11.010000] alloc_contig_range(pfn=28902) ret=-16
[   11.010000] start = 231
[   11.010000] pageno = 231
[   11.020000] alloc_contig_range(pfn=28903) ret=-16
[   11.020000] start = 232
[   11.020000] pageno = 232
[   11.020000] alloc_contig_range(pfn=28904) ret=-16
[   11.030000] start = 233
[   11.030000] pageno = 233
[   11.030000] alloc_contig_range(pfn=28905) ret=-16
[   11.040000] start = 234
[   11.040000] pageno = 234
[   11.040000] alloc_contig_range(pfn=28906) ret=-16
[   11.050000] start = 235
[   11.050000] pageno = 235
[   11.050000] alloc_contig_range(pfn=28907) ret=-16
[   11.060000] start = 236
[   11.060000] pageno = 236
[   11.060000] alloc_contig_range(pfn=28908) ret=-16
[   11.070000] start = 237
[   11.070000] pageno = 237
[   11.070000] alloc_contig_range(pfn=28909) ret=-16
[   11.080000] start = 238
[   11.080000] pageno = 238
[   11.080000] alloc_contig_range(pfn=28910) ret=-16
[   11.090000] start = 239
[   11.090000] pageno = 239
[   11.090000] alloc_contig_range(pfn=28911) ret=-16
[   11.100000] start = 240
[   11.100000] pageno = 240
[   11.100000] alloc_contig_range(pfn=28912) ret=-16
[   11.110000] start = 241
[   11.110000] pageno = 241
[   11.110000] alloc_contig_range(pfn=28913) ret=-16
[   11.120000] start = 242
[   11.120000] pageno = 242
[   11.120000] alloc_contig_range(pfn=28914) ret=-16
[   11.120000] start = 243
[   11.130000] pageno = 243
[   11.130000] alloc_contig_range(pfn=28915) ret=-16
[   11.130000] start = 244
[   11.140000] pageno = 244
[   11.140000] alloc_contig_range(pfn=28916) ret=-16
[   11.140000] start = 245
[   11.150000] pageno = 245
[   11.150000] alloc_contig_range(pfn=28917) ret=-16
[   11.150000] start = 246
[   11.160000] pageno = 246
[   11.160000] alloc_contig_range(pfn=28918) ret=-16
[   11.160000] start = 247
[   11.170000] pageno = 247
[   11.170000] alloc_contig_range(pfn=28919) ret=-16
[   11.170000] start = 248
[   11.180000] pageno = 248
[   11.180000] alloc_contig_range(pfn=28920) ret=-16
[   11.180000] start = 249
[   11.180000] pageno = 249
[   11.190000] alloc_contig_range(pfn=28921) ret=-16
[   11.190000] start = 250
[   11.190000] pageno = 250
[   11.200000] alloc_contig_range(pfn=28922) ret=-16
[   11.200000] start = 251
[   11.200000] pageno = 251
[   11.210000] alloc_contig_range(pfn=28923) ret=-16
[   11.210000] start = 252
[   11.210000] pageno = 252
[   11.220000] alloc_contig_range(pfn=28924) ret=-16
[   11.220000] start = 253
[   11.220000] pageno = 253
[   11.230000] alloc_contig_range(pfn=28925) ret=-16
[   11.230000] start = 254
[   11.230000] pageno = 254
[   11.240000] alloc_contig_range(pfn=28926) ret=-16
[   11.240000] start = 255
[   11.240000] pageno = 255
[   11.250000] alloc_contig_range(pfn=28927) ret=0
[   11.250000] dma_alloc_from_contiguous(): returned c04a7fe0
[   11.260000] __dma_alloc: __alloc_from_pool()
[   11.260000] __dma_alloc: __alloc_from_pool()
[   11.260000] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[   11.270000] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   11.280000] usb usb2: Product: Generic UHCI Host Controller
[   11.280000] usb usb2: Manufacturer: Linux 3.7.0-rc1+ uhci_hcd
[   11.290000] usb usb2: SerialNumber: d8007b00.uhci
[   11.290000] hub 2-0:1.0: USB hub found
[   11.300000] hub 2-0:1.0: 2 ports detected
[   11.300000] usbcore: registered new interface driver uas
[   11.310000] Initializing USB Mass Storage driver...
[   11.310000] usbcore: registered new interface driver usb-storage
[   11.320000] USB Mass Storage support registered.
[   11.320000] usbcore: registered new interface driver usbserial
[   11.330000] usbcore: registered new interface driver usbserial_generic
[   11.330000] usbserial: USB Serial support registered for generic
[   11.340000] mousedev: PS/2 mouse device common for all mice
[   11.350000] vt8500-rtc d8100000.rtc: rtc core: registered vt8500-rtc as rtc0
[   11.350000] __dma_alloc: __alloc_from_contiguous
[   11.360000] dma_alloc_from_contiguous(cma c683c7a0, count 8, align 3)
[   11.360000] pageno = 0
[   11.370000] alloc_contig_range(pfn=28672) ret=-16
[   11.370000] start = 8
[   11.370000] pageno = 8
[   11.380000] alloc_contig_range(pfn=28680) ret=-16
[   11.380000] start = 16
[   11.380000] pageno = 16
[   11.390000] alloc_contig_range(pfn=28688) ret=-16
[   11.390000] start = 24
[   11.390000] pageno = 24
[   11.400000] alloc_contig_range(pfn=28696) ret=-16
[   11.400000] start = 32
[   11.400000] pageno = 32
[   11.400000] alloc_contig_range(pfn=28704) ret=-16
[   11.410000] start = 40
[   11.410000] pageno = 40
[   11.410000] alloc_contig_range(pfn=28712) ret=-16
[   11.420000] start = 48
[   11.420000] pageno = 48
[   11.420000] alloc_contig_range(pfn=28720) ret=-16
[   11.430000] start = 56
[   11.430000] pageno = 56
[   11.430000] alloc_contig_range(pfn=28728) ret=-16
[   11.440000] start = 64
[   11.440000] pageno = 64
[   11.440000] alloc_contig_range(pfn=28736) ret=-16
[   11.450000] start = 72
[   11.450000] pageno = 72
[   11.450000] alloc_contig_range(pfn=28744) ret=-16
[   11.460000] start = 80
[   11.460000] pageno = 80
[   11.460000] alloc_contig_range(pfn=28752) ret=-16
[   11.470000] start = 88
[   11.470000] pageno = 88
[   11.470000] alloc_contig_range(pfn=28760) ret=-16
[   11.470000] start = 96
[   11.480000] pageno = 96
[   11.480000] alloc_contig_range(pfn=28768) ret=-16
[   11.480000] start = 104
[   11.490000] pageno = 104
[   11.490000] alloc_contig_range(pfn=28776) ret=-16
[   11.490000] start = 112
[   11.500000] pageno = 112
[   11.500000] alloc_contig_range(pfn=28784) ret=-16
[   11.500000] start = 120
[   11.510000] pageno = 120
[   11.510000] alloc_contig_range(pfn=28792) ret=0
[   11.510000] dma_alloc_from_contiguous(): returned c04a6f00
[   11.520000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.520000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.550000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.570000] wmt_mci_probe: WMT SDHC Controller initialized
[   11.570000] usbcore: registered new interface driver usbhid
[   11.570000] usbhid: USB HID core driver
[   11.580000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.590000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.590000] TCP: cubic registered
[   11.590000] NET: Registered protocol family 17
[   11.600000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.600000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.610000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.620000] VFP support v0.3: not present
[   11.620000] vt8500-rtc d8100000.rtc: hctosys: invalid date/time
[   11.630000] Waiting 5sec before mounting root device...
[   11.670000] vt8500_dclk_set_rate: invalid divisor for clock
[   11.680000] mmc0: new high speed SDHC card at address aaaa
[   11.680000] mmcblk0: mmc0:aaaa SU08G 7.40 GiB 
[   11.690000]  mmcblk0: p1
[   16.640000] VFS: Cannot open root device "sda1" or unknown-block(0,0): error -6
[   16.640000] Please append a correct "root=" boot option; here are the available partitions:
[   16.650000] b300         7761920 mmcblk0  driver: mmcblk
[   16.650000]   b301         7757824 mmcblk0p1 00000000-0000-0000-0000-000000000000
[   16.660000] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[   16.660000] [<c0013128>] (unwind_backtrace+0x0/0x130) from [<c0281eac>] (panic+0x80/0x1cc)
[   16.660000] [<c0281eac>] (panic+0x80/0x1cc) from [<c0348ba4>] (mount_block_root+0x204/0x2c8)
[   16.660000] [<c0348ba4>] (mount_block_root+0x204/0x2c8) from [<c0348f1c>] (prepare_namespace+0x154/0x1ac)
[   16.660000] [<c0348f1c>] (prepare_namespace+0x154/0x1ac) from [<c027f5e4>] (kernel_init+0x17c/0x2e0)
[   16.660000] [<c027f5e4>] (kernel_init+0x17c/0x2e0) from [<c000e690>] (ret_from_fork+0x14/0x24)

--=-EYyTEEIKooVITjPXnJO4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
