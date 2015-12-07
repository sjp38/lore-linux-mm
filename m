Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 43C846B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 04:00:01 -0500 (EST)
Received: by pacej9 with SMTP id ej9so122114908pac.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 01:00:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 68si50258pfi.137.2015.12.07.01.00.00
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 01:00:00 -0800 (PST)
Date: Mon, 7 Dec 2015 16:59:56 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151207085956.GA16783@aaronlu.sh.intel.com>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com>
 <56600DAA.4050208@suse.cz>
 <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Content-Disposition: inline
In-Reply-To: <20151207073523.GA27292@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 07, 2015 at 04:35:24PM +0900, Joonsoo Kim wrote:
> It looks like overhead still remain. I guess that migration scanner
> would call pageblock_pfn_to_page() for more extended range so
> overhead still remain.
> 
> I have an idea to solve his problem. Aaron, could you test following patch
> on top of base? It tries to skip calling pageblock_pfn_to_page()

It doesn't apply on top of 25364a9e54fb8296837061bf684b76d20eec01fb
cleanly, so I made some changes to make it apply and the result is:
https://github.com/aaronlu/linux/commit/cb8d05829190b806ad3948ff9b9e08c8ba1daf63

There is a problem occured right after the test starts:
[   58.080962] BUG: unable to handle kernel paging request at ffffea0082000018
[   58.089124] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   58.096109] PGD 107ffd6067 PUD 207f7d5067 PMD 0
[   58.101569] Oops: 0000 [#1] SMP 

The full dmesg is attached.

Regards,
Aaron

> if we check that zone is contiguous at initialization stage.
> 
> Thanks.
> 
> ---->8----
> From 9c4fbf8f8ed37eb88a04a97908e76ba2437404a2 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Mon, 7 Dec 2015 14:51:42 +0900
> Subject: [PATCH] mm/compaction: Optimize pageblock_pfn_to_page() for
>  contiguous zone
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/compaction.c        | 35 ++++++++++++++++++++++++++++++++++-
>  2 files changed, 35 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..573f9a9 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -521,6 +521,7 @@ struct zone {
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +       int                     contiguous;
>         /* Set to true when the PG_migrate_skip bits should be cleared */
>         bool                    compact_blockskip_flush;
>  #endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 67b8d90..f4e8c89 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -88,7 +88,7 @@ static inline bool migrate_async_suitable(int migratetype)
>   * the first and last page of a pageblock and avoid checking each individual
>   * page in a pageblock.
>   */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +static struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>                                 unsigned long end_pfn, struct zone *zone)
>  {
>         struct page *start_page;
> @@ -114,6 +114,37 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>         return start_page;
>  }
>  
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +                               unsigned long end_pfn, struct zone *zone)
> +{
> +       if (zone->contiguous == 1)
> +               return pfn_to_page(start_pfn);
> +
> +       return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
> +static void check_zone_contiguous(struct zone *zone)
> +{
> +       unsigned long pfn = zone->zone_start_pfn;
> +       unsigned long end_pfn = zone_end_pfn(zone);
> +
> +       /* Already checked */
> +       if (zone->contiguous)
> +               return;
> +
> +       pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> +       for (; pfn < end_pfn; pfn += pageblock_nr_pages) {
> +               if (!__pageblock_pfn_to_page(pfn, end_pfn, zone)) {
> +                       /* We have hole */
> +                       zone->contiguous = -1;
> +                       return;
> +               }
> +       }
> +
> +       /* We don't have hole */
> +       zone->contiguous = 1;
> +}
> +
>  #ifdef CONFIG_COMPACTION
>  
>  /* Do not skip compaction more than 64 times */
> @@ -1353,6 +1384,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                 ;
>         }
>  
> +       check_zone_contiguous(zone);
> +
>         /*
>          * Clear pageblock skip if there were failures recently and compaction
>          * is about to be retried after being deferred. kswapd does not do
> -- 
> 1.9.1
> 
> 

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg
Content-Transfer-Encoding: quoted-printable

early console in decompress_kernel
input_data: 0x000000207edd03b4
input_len: 0x00000000006adf26
output: 0x000000207e000000
output_len: 0x000000000146c960
run_size: 0x000000000169b000

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.4.0-rc3-00025-gcb8d058 (kbuild@lkp-nex05) (g=
cc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Mon Dec 7 16:32:43 CST 2015
[    0.000000] Command line: root=3D/dev/ram0 user=3Daaron job=3D/lkp/sched=
uled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_64-rhel-cb8d0582919=
0b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.yaml ARCH=3Dx86_64 k=
config=3Dx86_64-rhel branch=3Daaron/kim commit=3Dcb8d05829190b806ad3948ff9b=
9e08c8ba1daf63 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel/gcc-4.9/cb8d05829190b806=
ad3948ff9b9e08c8ba1daf63/vmlinuz-4.4.0-rc3-00025-gcb8d058 max_uptime=3D1121=
 RESULT_ROOT=3D/result/swap/performance-always-always/lkp-hsw-ep2/debian-x8=
6_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/cb8d05829190b806ad3948ff9b9e08c8ba1=
daf63/0 LKP_SERVER=3Dinn earlyprintk=3DttyS0,115200 systemd.log_level=3Derr=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal rw ip=3D::::lkp-hsw-ep2::dhcp
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: Supporting XSAVE feature 0x01: 'x87 floating point =
registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x02: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x04: 'AVX registers'
[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 by=
tes, using 'standard' format.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009b3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009b400-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000076230fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000076231000-0x00000000762ddfff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000762de000-0x000000007a1d2fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007a1d3000-0x000000007accefff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7d6fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x000000007b7d7000-0x000000007b7fffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000ff400000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Intel Corporation S2600WTT/S2600WTT, BIOS SE5C610.86B.0=
1.01.0008.021120151325 02/11/2015
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x2080000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT=
 =20
[    0.000000] e820: last_pfn =3D 0x7b800 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fd850-0x000fd85f] mapped at =
[ffff8800000fd850]
[    0.000000]   mpc: fd860-fde24
[    0.000000] Base memory trampoline at [ffff880000095000] 95000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] BRK [0x207f275000, 0x207f275fff] PGTABLE
[    0.000000] BRK [0x207f276000, 0x207f276fff] PGTABLE
[    0.000000] BRK [0x207f277000, 0x207f277fff] PGTABLE
[    0.000000] BRK [0x207f278000, 0x207f278fff] PGTABLE
[    0.000000] BRK [0x207f279000, 0x207f279fff] PGTABLE
[    0.000000] BRK [0x207f27a000, 0x207f27afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x20756c1000-0x207dffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0460 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000007B7D50E8 0000B4 (v01 INTEL  S2600WT  00=
000000 INTL 01000013)
[    0.000000] ACPI: FACP 0x000000007B7D4000 0000F4 (v04 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: DSDT 0x000000007B79A000 0313B2 (v02 INTEL  S2600WT  00=
000003 INTL 20091013)
[    0.000000] ACPI: FACS 0x000000007B6FB000 000040
[    0.000000] ACPI: HPET 0x000000007B7D3000 000038 (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: APIC 0x000000007B7D2000 00085C (v03 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: MCFG 0x000000007B7D1000 00003C (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: MSCT 0x000000007B7D0000 000090 (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SLIT 0x000000007B7CF000 00006C (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SRAT 0x000000007B7CE000 0009B0 (v03 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SPMI 0x000000007B7CD000 000041 (v05 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: WDDT 0x000000007B7CC000 000040 (v01 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: PRAD 0x000000007B795000 000102 (v02 INTEL  SpsPrAgg 00=
000002 INTL 20130328)
[    0.000000] ACPI: SSDT 0x0000000076231000 0ACA42 (v02 INTEL  S2600WT  00=
004000 INTL 20130328)
[    0.000000] ACPI: SSDT 0x000000007B797000 00216B (v02 INTEL  S2600WT  00=
000002 INTL 20130328)
[    0.000000] ACPI: SSDT 0x000000007B796000 000064 (v02 INTEL  S2600WT  00=
000002 INTL 20130328)
[    0.000000] ACPI: HEST 0x000000007B794000 0000A8 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000007B793000 000030 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: ERST 0x000000007B792000 000230 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000007B791000 000130 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: SPCR 0x000000007B790000 000050 (v01        S2600WT  00=
000000 INTL 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57c000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x26 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x28 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x36 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x40 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x42 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x44 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x46 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x48 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x50 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x52 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x54 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x56 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x60 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x62 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x64 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x66 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x68 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x70 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x72 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x74 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x76 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x27 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x29 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x37 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x41 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x43 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x45 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x47 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x49 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x51 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x53 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x55 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x57 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x61 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x63 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x65 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x67 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x69 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x71 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x73 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x75 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x77 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x107fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x1080000000-0x207fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=3D2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-=
0x107fffffff] -> [mem 0x00000000-0x107fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x107ffde000-0x107fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x207ffdc000-0x207fffdfff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000207fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009afff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000076230fff]
[    0.000000]   node   0: [mem 0x00000000762de000-0x000000007a1d2fff]
[    0.000000]   node   0: [mem 0x000000007b7d7000-0x000000007b7fffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000107fffffff]
[    0.000000]   node   1: [mem 0x0000001080000000-0x000000207fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000107ffff=
fff]
[    0.000000] On node 0 totalpages: 16752873
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3994 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7750 pages used for memmap
[    0.000000]   DMA32 zone: 495951 pages, LIFO batch:31
[    0.000000]   Normal zone: 253952 pages used for memmap
[    0.000000]   Normal zone: 16252928 pages, LIFO batch:31
[    0.000000] Initmem setup node 1 [mem 0x0000001080000000-0x000000207ffff=
fff]
[    0.000000] On node 1 totalpages: 16777216
[    0.000000]   Normal zone: 262144 pages used for memmap
[    0.000000]   Normal zone: 16777216 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57c000 (        fee00000)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24=
-47
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 4=
8-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 144 CPUs, 72 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57b000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff57a000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff579000 (fec40000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009c000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x76231000-0x762ddfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7a1d3000-0x7accefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7d6fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff3fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff400000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:144 nr_cpu_ids:14=
4 nr_node_ids:2
[    0.000000] PERCPU: Embedded 34 pages/cpu @ffff88103ec00000 s99736 r8192=
 d31336 u262144
[    0.000000] pcpu-alloc: s99736 r8192 d31336 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007=20
[    0.000000] pcpu-alloc: [0] 008 009 010 011 012 013 014 015=20
[    0.000000] pcpu-alloc: [0] 016 017 036 037 038 039 040 041=20
[    0.000000] pcpu-alloc: [0] 042 043 044 045 046 047 048 049=20
[    0.000000] pcpu-alloc: [0] 050 051 052 053 072 074 076 078=20
[    0.000000] pcpu-alloc: [0] 080 082 084 086 088 090 092 094=20
[    0.000000] pcpu-alloc: [0] 096 098 100 102 104 106 108 110=20
[    0.000000] pcpu-alloc: [0] 112 114 116 118 120 122 124 126=20
[    0.000000] pcpu-alloc: [0] 128 130 132 134 136 138 140 142=20
[    0.000000] pcpu-alloc: [1] 018 019 020 021 022 023 024 025=20
[    0.000000] pcpu-alloc: [1] 026 027 028 029 030 031 032 033=20
[    0.000000] pcpu-alloc: [1] 034 035 054 055 056 057 058 059=20
[    0.000000] pcpu-alloc: [1] 060 061 062 063 064 065 066 067=20
[    0.000000] pcpu-alloc: [1] 068 069 070 071 073 075 077 079=20
[    0.000000] pcpu-alloc: [1] 081 083 085 087 089 091 093 095=20
[    0.000000] pcpu-alloc: [1] 097 099 101 103 105 107 109 111=20
[    0.000000] pcpu-alloc: [1] 113 115 117 119 121 123 125 127=20
[    0.000000] pcpu-alloc: [1] 129 131 133 135 137 139 141 143=20
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Tota=
l pages: 33006158
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=3D/dev/ram0 user=3Daaron job=3D/lk=
p/scheduled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_64-rhel-cb8d=
05829190b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.yaml ARCH=3Dx=
86_64 kconfig=3Dx86_64-rhel branch=3Daaron/kim commit=3Dcb8d05829190b806ad3=
948ff9b9e08c8ba1daf63 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel/gcc-4.9/cb8d05829=
190b806ad3948ff9b9e08c8ba1daf63/vmlinuz-4.4.0-rc3-00025-gcb8d058 max_uptime=
=3D1121 RESULT_ROOT=3D/result/swap/performance-always-always/lkp-hsw-ep2/de=
bian-x86_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/cb8d05829190b806ad3948ff9b9e=
08c8ba1daf63/0 LKP_SERVER=3Dinn earlyprintk=3DttyS0,115200 systemd.log_leve=
l=3Derr debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal rw ip=3D::::lkp-hsw-ep2::dhcp
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 585728 bytes
[    0.000000] log_buf_len min size: 524288 bytes
[    0.000000] log_buf_len: 2097152 bytes
[    0.000000] early log buf free: 495268(94%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Memory: 131775292K/134120356K available (9002K kernel code, =
1768K rwdata, 4112K rodata, 1880K init, 2080K bss, 2345064K reserved, 0K cm=
a-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D144,=
 Nodes=3D2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D8192 to nr_cpu_ids=3D14=
4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=
=3D144
[    0.000000] NR_IRQS:524544 nr_irqs:2392 16
[    0.000000] 	Offload RCU callbacks from all CPUs
[    0.000000] 	Offload RCU callbacks from CPUs: 0-143.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.4.0-rc3-00025-gcb8d058 (kbuild@lkp-nex05) (g=
cc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Mon Dec 7 16:32:43 CST 2015
[    0.000000] Command line: root=3D/dev/ram0 user=3Daaron job=3D/lkp/sched=
uled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_64-rhel-cb8d0582919=
0b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.yaml ARCH=3Dx86_64 k=
config=3Dx86_64-rhel branch=3Daaron/kim commit=3Dcb8d05829190b806ad3948ff9b=
9e08c8ba1daf63 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel/gcc-4.9/cb8d05829190b806=
ad3948ff9b9e08c8ba1daf63/vmlinuz-4.4.0-rc3-00025-gcb8d058 max_uptime=3D1121=
 RESULT_ROOT=3D/result/swap/performance-always-always/lkp-hsw-ep2/debian-x8=
6_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/cb8d05829190b806ad3948ff9b9e08c8ba1=
daf63/0 LKP_SERVER=3Dinn earlyprintk=3DttyS0,115200 systemd.log_level=3Derr=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal rw ip=3D::::lkp-hsw-ep2::dhcp
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: Supporting XSAVE feature 0x01: 'x87 floating point =
registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x02: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x04: 'AVX registers'
[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 by=
tes, using 'standard' format.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009b3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009b400-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000076230fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000076231000-0x00000000762ddfff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000762de000-0x000000007a1d2fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007a1d3000-0x000000007accefff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7d6fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x000000007b7d7000-0x000000007b7fffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000ff400000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Intel Corporation S2600WTT/S2600WTT, BIOS SE5C610.86B.0=
1.01.0008.021120151325 02/11/2015
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x2080000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT=
 =20
[    0.000000] e820: last_pfn =3D 0x7b800 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fd850-0x000fd85f] mapped at =
[ffff8800000fd850]
[    0.000000]   mpc: fd860-fde24
[    0.000000] Base memory trampoline at [ffff880000095000] 95000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] BRK [0x207f275000, 0x207f275fff] PGTABLE
[    0.000000] BRK [0x207f276000, 0x207f276fff] PGTABLE
[    0.000000] BRK [0x207f277000, 0x207f277fff] PGTABLE
[    0.000000] BRK [0x207f278000, 0x207f278fff] PGTABLE
[    0.000000] BRK [0x207f279000, 0x207f279fff] PGTABLE
[    0.000000] BRK [0x207f27a000, 0x207f27afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x20756c1000-0x207dffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0460 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000007B7D50E8 0000B4 (v01 INTEL  S2600WT  00=
000000 INTL 01000013)
[    0.000000] ACPI: FACP 0x000000007B7D4000 0000F4 (v04 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: DSDT 0x000000007B79A000 0313B2 (v02 INTEL  S2600WT  00=
000003 INTL 20091013)
[    0.000000] ACPI: FACS 0x000000007B6FB000 000040
[    0.000000] ACPI: HPET 0x000000007B7D3000 000038 (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: APIC 0x000000007B7D2000 00085C (v03 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: MCFG 0x000000007B7D1000 00003C (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: MSCT 0x000000007B7D0000 000090 (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SLIT 0x000000007B7CF000 00006C (v01 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SRAT 0x000000007B7CE000 0009B0 (v03 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: SPMI 0x000000007B7CD000 000041 (v05 INTEL  S2600WT  00=
000001 INTL 20091013)
[    0.000000] ACPI: WDDT 0x000000007B7CC000 000040 (v01 INTEL  S2600WT  00=
000000 INTL 20091013)
[    0.000000] ACPI: PRAD 0x000000007B795000 000102 (v02 INTEL  SpsPrAgg 00=
000002 INTL 20130328)
[    0.000000] ACPI: SSDT 0x0000000076231000 0ACA42 (v02 INTEL  S2600WT  00=
004000 INTL 20130328)
[    0.000000] ACPI: SSDT 0x000000007B797000 00216B (v02 INTEL  S2600WT  00=
000002 INTL 20130328)
[    0.000000] ACPI: SSDT 0x000000007B796000 000064 (v02 INTEL  S2600WT  00=
000002 INTL 20130328)
[    0.000000] ACPI: HEST 0x000000007B794000 0000A8 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000007B793000 000030 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: ERST 0x000000007B792000 000230 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000007B791000 000130 (v01 INTEL  S2600WT  00=
000001 INTL 00000001)
[    0.000000] ACPI: SPCR 0x000000007B790000 000050 (v01        S2600WT  00=
000000 INTL 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57c000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x26 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x28 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x36 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x40 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x42 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x44 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x46 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x48 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x50 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x52 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x54 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x56 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x60 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x62 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x64 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x66 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x68 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x70 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x72 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x74 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x76 -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x27 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x29 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x37 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x41 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x43 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x45 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x47 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x49 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x51 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x53 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x55 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x57 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x61 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x63 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x65 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x67 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x69 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x71 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x73 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x75 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x77 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x107fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x1080000000-0x207fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=3D2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-=
0x107fffffff] -> [mem 0x00000000-0x107fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x107ffde000-0x107fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x207ffdc000-0x207fffdfff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000207fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009afff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000076230fff]
[    0.000000]   node   0: [mem 0x00000000762de000-0x000000007a1d2fff]
[    0.000000]   node   0: [mem 0x000000007b7d7000-0x000000007b7fffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000107fffffff]
[    0.000000]   node   1: [mem 0x0000001080000000-0x000000207fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000107ffff=
fff]
[    0.000000] On node 0 totalpages: 16752873
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3994 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7750 pages used for memmap
[    0.000000]   DMA32 zone: 495951 pages, LIFO batch:31
[    0.000000]   Normal zone: 253952 pages used for memmap
[    0.000000]   Normal zone: 16252928 pages, LIFO batch:31
[    0.000000] Initmem setup node 1 [mem 0x0000001080000000-0x000000207ffff=
fff]
[    0.000000] On node 1 totalpages: 16777216
[    0.000000]   Normal zone: 262144 pages used for memmap
[    0.000000]   Normal zone: 16777216 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57c000 (        fee00000)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24=
-47
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 4=
8-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 144 CPUs, 72 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57b000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff57a000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff579000 (fec40000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009c000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x76231000-0x762ddfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7a1d3000-0x7accefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7d6fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff3fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff400000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:144 nr_cpu_ids:14=
4 nr_node_ids:2
[    0.000000] PERCPU: Embedded 34 pages/cpu @ffff88103ec00000 s99736 r8192=
 d31336 u262144
[    0.000000] pcpu-alloc: s99736 r8192 d31336 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007=20
[    0.000000] pcpu-alloc: [0] 008 009 010 011 012 013 014 015=20
[    0.000000] pcpu-alloc: [0] 016 017 036 037 038 039 040 041=20
[    0.000000] pcpu-alloc: [0] 042 043 044 045 046 047 048 049=20
[    0.000000] pcpu-alloc: [0] 050 051 052 053 072 074 076 078=20
[    0.000000] pcpu-alloc: [0] 080 082 084 086 088 090 092 094=20
[    0.000000] pcpu-alloc: [0] 096 098 100 102 104 106 108 110=20
[    0.000000] pcpu-alloc: [0] 112 114 116 118 120 122 124 126=20
[    0.000000] pcpu-alloc: [0] 128 130 132 134 136 138 140 142=20
[    0.000000] pcpu-alloc: [1] 018 019 020 021 022 023 024 025=20
[    0.000000] pcpu-alloc: [1] 026 027 028 029 030 031 032 033=20
[    0.000000] pcpu-alloc: [1] 034 035 054 055 056 057 058 059=20
[    0.000000] pcpu-alloc: [1] 060 061 062 063 064 065 066 067=20
[    0.000000] pcpu-alloc: [1] 068 069 070 071 073 075 077 079=20
[    0.000000] pcpu-alloc: [1] 081 083 085 087 089 091 093 095=20
[    0.000000] pcpu-alloc: [1] 097 099 101 103 105 107 109 111=20
[    0.000000] pcpu-alloc: [1] 113 115 117 119 121 123 125 127=20
[    0.000000] pcpu-alloc: [1] 129 131 133 135 137 139 141 143=20
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Tota=
l pages: 33006158
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=3D/dev/ram0 user=3Daaron job=3D/lk=
p/scheduled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_64-rhel-cb8d=
05829190b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.yaml ARCH=3Dx=
86_64 kconfig=3Dx86_64-rhel branch=3Daaron/kim commit=3Dcb8d05829190b806ad3=
948ff9b9e08c8ba1daf63 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel/gcc-4.9/cb8d05829=
190b806ad3948ff9b9e08c8ba1daf63/vmlinuz-4.4.0-rc3-00025-gcb8d058 max_uptime=
=3D1121 RESULT_ROOT=3D/result/swap/performance-always-always/lkp-hsw-ep2/de=
bian-x86_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/cb8d05829190b806ad3948ff9b9e=
08c8ba1daf63/0 LKP_SERVER=3Dinn earlyprintk=3DttyS0,115200 systemd.log_leve=
l=3Derr debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal rw ip=3D::::lkp-hsw-ep2::dhcp
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 585728 bytes
[    0.000000] log_buf_len min size: 524288 bytes
[    0.000000] log_buf_len: 2097152 bytes
[    0.000000] early log buf free: 495268(94%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Memory: 131775292K/134120356K available (9002K kernel code, =
1768K rwdata, 4112K rodata, 1880K init, 2080K bss, 2345064K reserved, 0K cm=
a-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D144,=
 Nodes=3D2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D8192 to nr_cpu_ids=3D14=
4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=
=3D144
[    0.000000] NR_IRQS:524544 nr_irqs:2392 16
[    0.000000] 	Offload RCU callbacks from all CPUs
[    0.000000] 	Offload RCU callbacks from CPUs: 0-143.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] mempolicy: Enabling automatic NUMA balancing. Configure with=
 numa_balancing=3D or the kernel.numa_balancing sysctl
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2294.684 MHz processor
[    0.000076] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 4589.36 BogoMIPS (lpj=3D2294684)
[    0.011936] pid_max: default: 147456 minimum: 1152
[    0.017293] ACPI: Core revision 20150930
[    0.141308] ACPI: 4 ACPI AML tables successfully acquired and loaded
[    0.148588] Security Framework initialized
[    0.153158] SELinux:  Initializing.
[    0.157077] SELinux:  Starting in permissive mode
[    0.169208] Dentry cache hash table entries: 16777216 (order: 15, 134217=
728 bytes)
[    0.202336] Inode-cache hash table entries: 8388608 (order: 14, 67108864=
 bytes)
[    0.221102] Mount-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)
[    0.229102] Mountpoint-cache hash table entries: 262144 (order: 9, 20971=
52 bytes)
[    0.238466] Initializing cgroup subsys io
[    0.242952] Initializing cgroup subsys memory
[    0.247858] Initializing cgroup subsys devices
[    0.252826] Initializing cgroup subsys freezer
[    0.257793] Initializing cgroup subsys net_cls
[    0.262761] Initializing cgroup subsys perf_event
[    0.268020] Initializing cgroup subsys hugetlb
[    0.273056] CPU: Physical Processor ID: 0
[    0.277536] CPU: Processor Core ID: 0
[    0.282368] mce: CPU supports 22 MCE banks
[    0.286983] CPU0: Thermal monitoring enabled (TM1)
[    0.292346] process: using mwait in idle threads
[    0.297508] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
[    0.304315] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
[    0.312724] Freeing SMP alternatives memory: 32K (ffffffff82063000 - fff=
fffff8206b000)
[    0.323524] ftrace: allocating 33639 entries in 132 pages
[    0.344036] x2apic: IRQ remapping doesn't support X2APIC mode
[    0.350527] Switched APIC routing to physical flat.
[    0.355970] masked ExtINT on CPU#0
[    0.360198] ENABLING IO-APIC IRQs
[    0.363905] init IO_APIC IRQs
[    0.367222]  apic 8 pin 0 not connected
[    0.371513] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:0)
[    0.380362] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:0)
[    0.389202] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:0)
[    0.398043] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:0)
[    0.406884] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Ac=
tive:0 Dest:0)
[    0.415726] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:0)
[    0.424564] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:0)
[    0.433403] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:0)
[    0.442241] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:0)
[    0.451079] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 =
Active:0 Dest:0)
[    0.460111] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 =
Active:0 Dest:0)
[    0.469145] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:0)
[    0.478177] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:0)
[    0.487210] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:0)
[    0.496242] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:0)
[    0.505263]  apic 8 pin 16 not connected
[    0.509637]  apic 8 pin 17 not connected
[    0.514011]  apic 8 pin 18 not connected
[    0.518385]  apic 8 pin 19 not connected
[    0.522759]  apic 8 pin 20 not connected
[    0.527133]  apic 8 pin 21 not connected
[    0.531508]  apic 8 pin 22 not connected
[    0.535882]  apic 8 pin 23 not connected
[    0.540256]  apic 9 pin 0 not connected
[    0.544533]  apic 9 pin 1 not connected
[    0.548810]  apic 9 pin 2 not connected
[    0.553087]  apic 9 pin 3 not connected
[    0.557364]  apic 9 pin 4 not connected
[    0.561642]  apic 9 pin 5 not connected
[    0.565919]  apic 9 pin 6 not connected
[    0.570196]  apic 9 pin 7 not connected
[    0.574473]  apic 9 pin 8 not connected
[    0.578750]  apic 9 pin 9 not connected
[    0.583027]  apic 9 pin 10 not connected
[    0.587401]  apic 9 pin 11 not connected
[    0.591775]  apic 9 pin 12 not connected
[    0.596149]  apic 9 pin 13 not connected
[    0.600525]  apic 9 pin 14 not connected
[    0.604898]  apic 9 pin 15 not connected
[    0.609272]  apic 9 pin 16 not connected
[    0.613646]  apic 9 pin 17 not connected
[    0.618020]  apic 9 pin 18 not connected
[    0.622394]  apic 9 pin 19 not connected
[    0.626768]  apic 9 pin 20 not connected
[    0.631142]  apic 9 pin 21 not connected
[    0.635516]  apic 9 pin 22 not connected
[    0.639890]  apic 9 pin 23 not connected
[    0.644264]  apic 10 pin 0 not connected
[    0.648638]  apic 10 pin 1 not connected
[    0.653011]  apic 10 pin 2 not connected
[    0.657385]  apic 10 pin 3 not connected
[    0.661759]  apic 10 pin 4 not connected
[    0.666133]  apic 10 pin 5 not connected
[    0.670507]  apic 10 pin 6 not connected
[    0.674881]  apic 10 pin 7 not connected
[    0.679255]  apic 10 pin 8 not connected
[    0.683629]  apic 10 pin 9 not connected
[    0.688003]  apic 10 pin 10 not connected
[    0.692474]  apic 10 pin 11 not connected
[    0.696945]  apic 10 pin 12 not connected
[    0.701416]  apic 10 pin 13 not connected
[    0.705887]  apic 10 pin 14 not connected
[    0.710358]  apic 10 pin 15 not connected
[    0.714829]  apic 10 pin 16 not connected
[    0.719300]  apic 10 pin 17 not connected
[    0.723770]  apic 10 pin 18 not connected
[    0.728241]  apic 10 pin 19 not connected
[    0.732712]  apic 10 pin 20 not connected
[    0.737183]  apic 10 pin 21 not connected
[    0.741654]  apic 10 pin 22 not connected
[    0.746125]  apic 10 pin 23 not connected
[    0.750737] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.767455] TSC deadline timer enabled
[    0.771653] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2699 v3 @ 2.30GHz (fa=
mily: 0x6, model: 0x3f, stepping: 0x2)
[    0.782895] Performance Events: PEBS fmt2+, 16-deep LBR, Haswell events,=
 full-width counters, Intel PMU driver.
[    0.794263] ... version:                3
[    0.798742] ... bit width:              48
[    0.803311] ... generic registers:      4
[    0.807783] ... value mask:             0000ffffffffffff
[    0.813709] ... max period:             0000ffffffffffff
[    0.819635] ... fixed-purpose events:   3
[    0.824107] ... event mask:             000000070000000f
[    0.832738] x86: Booting SMP configuration:
[    0.837415] .... node  #0, CPUs:          #1
[    0.853867] masked ExtINT on CPU#1
[    0.865489] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.874583]    #2
[    0.888186] masked ExtINT on CPU#2
[    0.895235]    #3
[    0.908719] masked ExtINT on CPU#3
[    0.915801]    #4
[    0.929232] masked ExtINT on CPU#4
[    0.936325]    #5
[    0.949910] masked ExtINT on CPU#5
[    0.956974]    #6
[    0.970522] masked ExtINT on CPU#6
[    0.977565]    #7
[    0.991047] masked ExtINT on CPU#7
[    0.998104]    #8
[    1.011550] masked ExtINT on CPU#8
[    1.018601]    #9
[    1.032032] masked ExtINT on CPU#9
[    1.039130]   #10
[    1.052566] masked ExtINT on CPU#10
[    1.059730]   #11
[    1.073259] masked ExtINT on CPU#11
[    1.080465]   #12
[    1.094036] masked ExtINT on CPU#12
[    1.101270]   #13
[    1.114806] masked ExtINT on CPU#13
[    1.122037]   #14
[    1.135463] masked ExtINT on CPU#14
[    1.142641]   #15
[    1.156183] masked ExtINT on CPU#15
[    1.163382]   #16
[    1.176945] masked ExtINT on CPU#16
[    1.184169]   #17
[    1.197693] masked ExtINT on CPU#17
[    1.204941]=20
[    1.206616] .... node  #1, CPUs:    #18
[    1.223993] masked ExtINT on CPU#18
[    1.309555]   #19
[    1.323587] masked ExtINT on CPU#19
[    1.330746]   #20
[    1.344510] masked ExtINT on CPU#20
[    1.351632]   #21
[    1.365328] masked ExtINT on CPU#21
[    1.372432]   #22
[    1.385998] masked ExtINT on CPU#22
[    1.393106]   #23
[    1.406778] masked ExtINT on CPU#23
[    1.413830]   #24
[    1.427476] masked ExtINT on CPU#24
[    1.434527]   #25
[    1.448100] masked ExtINT on CPU#25
[    1.455139]   #26
[    1.468674] masked ExtINT on CPU#26
[    1.475740]   #27
[    1.489261] masked ExtINT on CPU#27
[    1.496346]   #28
[    1.509868] masked ExtINT on CPU#28
[    1.516935]   #29
[    1.530553] masked ExtINT on CPU#29
[    1.537655]   #30
[    1.551304] masked ExtINT on CPU#30
[    1.558441]   #31
[    1.572066] masked ExtINT on CPU#31
[    1.579191]   #32
[    1.592704] masked ExtINT on CPU#32
[    1.599786]   #33
[    1.613417] masked ExtINT on CPU#33
[    1.620517]   #34
[    1.634168] masked ExtINT on CPU#34
[    1.641294]   #35
[    1.654907] masked ExtINT on CPU#35
[    1.662039]=20
[    1.663710] .... node  #0, CPUs:    #36
[    1.680002] masked ExtINT on CPU#36
[    1.687163]   #37
[    1.700847] masked ExtINT on CPU#37
[    1.707968]   #38
[    1.721510] masked ExtINT on CPU#38
[    1.728619]   #39
[    1.742196] masked ExtINT on CPU#39
[    1.749338]   #40
[    1.762863] masked ExtINT on CPU#40
[    1.770006]   #41
[    1.783683] masked ExtINT on CPU#41
[    1.790808]   #42
[    1.804448] masked ExtINT on CPU#42
[    1.811549]   #43
[    1.825139] masked ExtINT on CPU#43
[    1.832246]   #44
[    1.845786] masked ExtINT on CPU#44
[    1.852908]   #45
[    1.866434] masked ExtINT on CPU#45
[    1.873590]   #46
[    1.887017] masked ExtINT on CPU#46
[    1.894148]   #47
[    1.907772] masked ExtINT on CPU#47
[    1.914949]   #48
[    1.928614] masked ExtINT on CPU#48
[    1.935810]   #49
[    1.949348] masked ExtINT on CPU#49
[    1.956537]   #50
[    1.970056] masked ExtINT on CPU#50
[    1.977199]   #51
[    1.990833] masked ExtINT on CPU#51
[    1.998003]   #52
[    2.011659] masked ExtINT on CPU#52
[    2.018842]   #53
[    2.032459] masked ExtINT on CPU#53
[    2.039672]=20
[    2.041344] .... node  #1, CPUs:    #54
[    2.057025] masked ExtINT on CPU#54
[    2.064103]   #55
[    2.077783] masked ExtINT on CPU#55
[    2.084827]   #56
[    2.098356] masked ExtINT on CPU#56
[    2.105409]   #57
[    2.118981] masked ExtINT on CPU#57
[    2.126043]   #58
[    2.139555] masked ExtINT on CPU#58
[    2.146651]   #59
[    2.160324] masked ExtINT on CPU#59
[    2.167381]   #60
[    2.181016] masked ExtINT on CPU#60
[    2.188064]   #61
[    2.201631] masked ExtINT on CPU#61
[    2.208674]   #62
[    2.222208] masked ExtINT on CPU#62
[    2.229271]   #63
[    2.242784] masked ExtINT on CPU#63
[    2.249873]   #64
[    2.263395] masked ExtINT on CPU#64
[    2.270467]   #65
[    2.284085] masked ExtINT on CPU#65
[    2.291180]   #66
[    2.304829] masked ExtINT on CPU#66
[    2.311966]   #67
[    2.325591] masked ExtINT on CPU#67
[    2.332711]   #68
[    2.346226] masked ExtINT on CPU#68
[    2.353299]   #69
[    2.366930] masked ExtINT on CPU#69
[    2.374025]   #70
[    2.387678] masked ExtINT on CPU#70
[    2.394805]   #71
[    2.408417] masked ExtINT on CPU#71
[    2.415452] x86: Booted up 2 nodes, 72 CPUs
[    2.420137] smpboot: Total of 72 processors activated (330811.27 BogoMIP=
S)
[    2.682977] devtmpfs: initialized
[    2.686758] Using 2GB memory block size for large-memory system
[    2.695202] evm: security.selinux
[    2.698909] evm: security.ima
[    2.702219] evm: security.capability
[    2.706367] PM: Registering ACPI NVS region [mem 0x7accf000-0x7b6fefff] =
(10682368 bytes)
[    2.715790] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 1911260446275000 ns
[    2.727116] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    2.734888] pinctrl core: initialized pinctrl subsystem
[    2.741597] NET: Registered protocol family 16
[    2.750411] cpuidle: using governor menu
[    2.754990] ACPI FADT declares the system doesn't support PCIe ASPM, so =
disable it
[    2.763450] ACPI: bus type PCI registered
[    2.767932] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    2.775285] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000=
-0x8fffffff] (base 0x80000000)
[    2.785683] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    2.793275] PCI: Using configuration type 1 for base access
[    2.801132] perf_event_intel: PMU erratum BJ122, BV98, HSD29 worked arou=
nd, HT is on
[    2.815702] ACPI: Added _OSI(Module Device)
[    2.820380] ACPI: Added _OSI(Processor Device)
[    2.825347] ACPI: Added _OSI(3.0 _SCP Extensions)
[    2.830597] ACPI: Added _OSI(Processor Aggregator Device)
[    2.855398] ACPI: Executed 1 blocks of module-level executable AML code
[    3.012053] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    3.022004] ACPI: Dynamic OEM Table Load:
[    3.026509] ACPI: PRAD 0x0000000000000000 000102 (v02 INTEL  SpsPrAgg 00=
000002 INTL 20130328)
[    3.068703] ACPI: Interpreter enabled
[    3.072805] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20150930/hwxface-580)
[    3.083128] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20150930/hwxface-580)
[    3.093443] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S3_] (20150930/hwxface-580)
[    3.103757] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S4_] (20150930/hwxface-580)
[    3.114084] ACPI: (supports S0 S5)
[    3.117887] ACPI: Using IOAPIC for interrupt routing
[    3.123470] HEST: Table parsing has been initialized.
[    3.129118] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    3.176796] ACPI: PCI Root Bridge [UNC1] (domain 0000 [bus ff])
[    3.183417] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    3.192557] acpi PNP0A03:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    3.199987] PCI host bridge to bus 0000:ff
[    3.204567] pci_bus 0000:ff: root bus resource [bus ff]
[    3.210412] pci 0000:ff:08.0: [8086:2f80] type 00 class 0x088000
[    3.217175] pci 0000:ff:08.2: [8086:2f32] type 00 class 0x110100
[    3.223927] pci 0000:ff:08.3: [8086:2f83] type 00 class 0x088000
[    3.230683] pci 0000:ff:09.0: [8086:2f90] type 00 class 0x088000
[    3.237435] pci 0000:ff:09.2: [8086:2f33] type 00 class 0x110100
[    3.244186] pci 0000:ff:09.3: [8086:2f93] type 00 class 0x088000
[    3.250940] pci 0000:ff:0b.0: [8086:2f81] type 00 class 0x088000
[    3.257688] pci 0000:ff:0b.1: [8086:2f36] type 00 class 0x110100
[    3.264436] pci 0000:ff:0b.2: [8086:2f37] type 00 class 0x110100
[    3.271188] pci 0000:ff:0c.0: [8086:2fe0] type 00 class 0x088000
[    3.277935] pci 0000:ff:0c.1: [8086:2fe1] type 00 class 0x088000
[    3.284687] pci 0000:ff:0c.2: [8086:2fe2] type 00 class 0x088000
[    3.291436] pci 0000:ff:0c.3: [8086:2fe3] type 00 class 0x088000
[    3.298177] pci 0000:ff:0c.4: [8086:2fe4] type 00 class 0x088000
[    3.304915] pci 0000:ff:0c.5: [8086:2fe5] type 00 class 0x088000
[    3.311664] pci 0000:ff:0c.6: [8086:2fe6] type 00 class 0x088000
[    3.318408] pci 0000:ff:0c.7: [8086:2fe7] type 00 class 0x088000
[    3.325159] pci 0000:ff:0d.0: [8086:2fe8] type 00 class 0x088000
[    3.331908] pci 0000:ff:0d.1: [8086:2fe9] type 00 class 0x088000
[    3.338652] pci 0000:ff:0d.2: [8086:2fea] type 00 class 0x088000
[    3.345398] pci 0000:ff:0d.3: [8086:2feb] type 00 class 0x088000
[    3.352147] pci 0000:ff:0d.4: [8086:2fec] type 00 class 0x088000
[    3.358887] pci 0000:ff:0d.5: [8086:2fed] type 00 class 0x088000
[    3.365635] pci 0000:ff:0d.6: [8086:2fee] type 00 class 0x088000
[    3.372374] pci 0000:ff:0d.7: [8086:2fef] type 00 class 0x088000
[    3.379125] pci 0000:ff:0e.0: [8086:2ff0] type 00 class 0x088000
[    3.385873] pci 0000:ff:0e.1: [8086:2ff1] type 00 class 0x088000
[    3.392630] pci 0000:ff:0f.0: [8086:2ff8] type 00 class 0x088000
[    3.399378] pci 0000:ff:0f.1: [8086:2ff9] type 00 class 0x088000
[    3.406126] pci 0000:ff:0f.2: [8086:2ffa] type 00 class 0x088000
[    3.412873] pci 0000:ff:0f.3: [8086:2ffb] type 00 class 0x088000
[    3.419621] pci 0000:ff:0f.4: [8086:2ffc] type 00 class 0x088000
[    3.426369] pci 0000:ff:0f.5: [8086:2ffd] type 00 class 0x088000
[    3.433121] pci 0000:ff:0f.6: [8086:2ffe] type 00 class 0x088000
[    3.439871] pci 0000:ff:10.0: [8086:2f1d] type 00 class 0x088000
[    3.446612] pci 0000:ff:10.1: [8086:2f34] type 00 class 0x110100
[    3.453362] pci 0000:ff:10.5: [8086:2f1e] type 00 class 0x088000
[    3.460111] pci 0000:ff:10.6: [8086:2f7d] type 00 class 0x110100
[    3.466850] pci 0000:ff:10.7: [8086:2f1f] type 00 class 0x088000
[    3.473600] pci 0000:ff:12.0: [8086:2fa0] type 00 class 0x088000
[    3.480351] pci 0000:ff:12.1: [8086:2f30] type 00 class 0x110100
[    3.487105] pci 0000:ff:12.4: [8086:2f60] type 00 class 0x088000
[    3.493855] pci 0000:ff:12.5: [8086:2f38] type 00 class 0x110100
[    3.500607] pci 0000:ff:13.0: [8086:2fa8] type 00 class 0x088000
[    3.507358] pci 0000:ff:13.1: [8086:2f71] type 00 class 0x088000
[    3.514111] pci 0000:ff:13.2: [8086:2faa] type 00 class 0x088000
[    3.520860] pci 0000:ff:13.3: [8086:2fab] type 00 class 0x088000
[    3.527612] pci 0000:ff:13.6: [8086:2fae] type 00 class 0x088000
[    3.534361] pci 0000:ff:13.7: [8086:2faf] type 00 class 0x088000
[    3.541109] pci 0000:ff:14.0: [8086:2fb0] type 00 class 0x088000
[    3.547859] pci 0000:ff:14.1: [8086:2fb1] type 00 class 0x088000
[    3.554613] pci 0000:ff:14.2: [8086:2fb2] type 00 class 0x088000
[    3.561363] pci 0000:ff:14.3: [8086:2fb3] type 00 class 0x088000
[    3.568115] pci 0000:ff:14.4: [8086:2fbc] type 00 class 0x088000
[    3.574864] pci 0000:ff:14.5: [8086:2fbd] type 00 class 0x088000
[    3.581613] pci 0000:ff:14.6: [8086:2fbe] type 00 class 0x088000
[    3.588364] pci 0000:ff:14.7: [8086:2fbf] type 00 class 0x088000
[    3.595114] pci 0000:ff:16.0: [8086:2f68] type 00 class 0x088000
[    3.601866] pci 0000:ff:16.1: [8086:2f79] type 00 class 0x088000
[    3.608619] pci 0000:ff:16.2: [8086:2f6a] type 00 class 0x088000
[    3.615368] pci 0000:ff:16.3: [8086:2f6b] type 00 class 0x088000
[    3.622122] pci 0000:ff:16.6: [8086:2f6e] type 00 class 0x088000
[    3.628869] pci 0000:ff:16.7: [8086:2f6f] type 00 class 0x088000
[    3.635619] pci 0000:ff:17.0: [8086:2fd0] type 00 class 0x088000
[    3.642370] pci 0000:ff:17.1: [8086:2fd1] type 00 class 0x088000
[    3.649116] pci 0000:ff:17.2: [8086:2fd2] type 00 class 0x088000
[    3.655868] pci 0000:ff:17.3: [8086:2fd3] type 00 class 0x088000
[    3.662623] pci 0000:ff:17.4: [8086:2fb8] type 00 class 0x088000
[    3.669373] pci 0000:ff:17.5: [8086:2fb9] type 00 class 0x088000
[    3.676125] pci 0000:ff:17.6: [8086:2fba] type 00 class 0x088000
[    3.682875] pci 0000:ff:17.7: [8086:2fbb] type 00 class 0x088000
[    3.689637] pci 0000:ff:1e.0: [8086:2f98] type 00 class 0x088000
[    3.696389] pci 0000:ff:1e.1: [8086:2f99] type 00 class 0x088000
[    3.703139] pci 0000:ff:1e.2: [8086:2f9a] type 00 class 0x088000
[    3.709890] pci 0000:ff:1e.3: [8086:2fc0] type 00 class 0x088000
[    3.716605] pci 0000:ff:1e.3: [Firmware Bug]: reg 0x10: invalid BAR (can=
't size)
[    3.724907] pci 0000:ff:1e.4: [8086:2f9c] type 00 class 0x088000
[    3.731662] pci 0000:ff:1f.0: [8086:2f88] type 00 class 0x088000
[    3.738416] pci 0000:ff:1f.2: [8086:2f8a] type 00 class 0x088000
[    3.745237] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus 7f])
[    3.751857] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    3.760998] acpi PNP0A03:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    3.768425] PCI host bridge to bus 0000:7f
[    3.773005] pci_bus 0000:7f: root bus resource [bus 7f]
[    3.778850] pci 0000:7f:08.0: [8086:2f80] type 00 class 0x088000
[    3.785606] pci 0000:7f:08.2: [8086:2f32] type 00 class 0x110100
[    3.792361] pci 0000:7f:08.3: [8086:2f83] type 00 class 0x088000
[    3.799119] pci 0000:7f:09.0: [8086:2f90] type 00 class 0x088000
[    3.805866] pci 0000:7f:09.2: [8086:2f33] type 00 class 0x110100
[    3.812619] pci 0000:7f:09.3: [8086:2f93] type 00 class 0x088000
[    3.819378] pci 0000:7f:0b.0: [8086:2f81] type 00 class 0x088000
[    3.826129] pci 0000:7f:0b.1: [8086:2f36] type 00 class 0x110100
[    3.832880] pci 0000:7f:0b.2: [8086:2f37] type 00 class 0x110100
[    3.839633] pci 0000:7f:0c.0: [8086:2fe0] type 00 class 0x088000
[    3.846383] pci 0000:7f:0c.1: [8086:2fe1] type 00 class 0x088000
[    3.853135] pci 0000:7f:0c.2: [8086:2fe2] type 00 class 0x088000
[    3.859886] pci 0000:7f:0c.3: [8086:2fe3] type 00 class 0x088000
[    3.866638] pci 0000:7f:0c.4: [8086:2fe4] type 00 class 0x088000
[    3.873391] pci 0000:7f:0c.5: [8086:2fe5] type 00 class 0x088000
[    3.880141] pci 0000:7f:0c.6: [8086:2fe6] type 00 class 0x088000
[    3.886891] pci 0000:7f:0c.7: [8086:2fe7] type 00 class 0x088000
[    3.893641] pci 0000:7f:0d.0: [8086:2fe8] type 00 class 0x088000
[    3.900384] pci 0000:7f:0d.1: [8086:2fe9] type 00 class 0x088000
[    3.907134] pci 0000:7f:0d.2: [8086:2fea] type 00 class 0x088000
[    3.913888] pci 0000:7f:0d.3: [8086:2feb] type 00 class 0x088000
[    3.920639] pci 0000:7f:0d.4: [8086:2fec] type 00 class 0x088000
[    3.927393] pci 0000:7f:0d.5: [8086:2fed] type 00 class 0x088000
[    3.934144] pci 0000:7f:0d.6: [8086:2fee] type 00 class 0x088000
[    3.940898] pci 0000:7f:0d.7: [8086:2fef] type 00 class 0x088000
[    3.947649] pci 0000:7f:0e.0: [8086:2ff0] type 00 class 0x088000
[    3.954403] pci 0000:7f:0e.1: [8086:2ff1] type 00 class 0x088000
[    3.961157] pci 0000:7f:0f.0: [8086:2ff8] type 00 class 0x088000
[    3.967909] pci 0000:7f:0f.1: [8086:2ff9] type 00 class 0x088000
[    3.974662] pci 0000:7f:0f.2: [8086:2ffa] type 00 class 0x088000
[    3.981416] pci 0000:7f:0f.3: [8086:2ffb] type 00 class 0x088000
[    3.988166] pci 0000:7f:0f.4: [8086:2ffc] type 00 class 0x088000
[    3.994916] pci 0000:7f:0f.5: [8086:2ffd] type 00 class 0x088000
[    4.001665] pci 0000:7f:0f.6: [8086:2ffe] type 00 class 0x088000
[    4.008420] pci 0000:7f:10.0: [8086:2f1d] type 00 class 0x088000
[    4.015171] pci 0000:7f:10.1: [8086:2f34] type 00 class 0x110100
[    4.021924] pci 0000:7f:10.5: [8086:2f1e] type 00 class 0x088000
[    4.028676] pci 0000:7f:10.6: [8086:2f7d] type 00 class 0x110100
[    4.035428] pci 0000:7f:10.7: [8086:2f1f] type 00 class 0x088000
[    4.042179] pci 0000:7f:12.0: [8086:2fa0] type 00 class 0x088000
[    4.048934] pci 0000:7f:12.1: [8086:2f30] type 00 class 0x110100
[    4.055688] pci 0000:7f:12.4: [8086:2f60] type 00 class 0x088000
[    4.062442] pci 0000:7f:12.5: [8086:2f38] type 00 class 0x110100
[    4.069198] pci 0000:7f:13.0: [8086:2fa8] type 00 class 0x088000
[    4.075955] pci 0000:7f:13.1: [8086:2f71] type 00 class 0x088000
[    4.082711] pci 0000:7f:13.2: [8086:2faa] type 00 class 0x088000
[    4.089467] pci 0000:7f:13.3: [8086:2fab] type 00 class 0x088000
[    4.096224] pci 0000:7f:13.6: [8086:2fae] type 00 class 0x088000
[    4.102977] pci 0000:7f:13.7: [8086:2faf] type 00 class 0x088000
[    4.109730] pci 0000:7f:14.0: [8086:2fb0] type 00 class 0x088000
[    4.116487] pci 0000:7f:14.1: [8086:2fb1] type 00 class 0x088000
[    4.123241] pci 0000:7f:14.2: [8086:2fb2] type 00 class 0x088000
[    4.129998] pci 0000:7f:14.3: [8086:2fb3] type 00 class 0x088000
[    4.136750] pci 0000:7f:14.4: [8086:2fbc] type 00 class 0x088000
[    4.143506] pci 0000:7f:14.5: [8086:2fbd] type 00 class 0x088000
[    4.150260] pci 0000:7f:14.6: [8086:2fbe] type 00 class 0x088000
[    4.157015] pci 0000:7f:14.7: [8086:2fbf] type 00 class 0x088000
[    4.163769] pci 0000:7f:16.0: [8086:2f68] type 00 class 0x088000
[    4.170524] pci 0000:7f:16.1: [8086:2f79] type 00 class 0x088000
[    4.177280] pci 0000:7f:16.2: [8086:2f6a] type 00 class 0x088000
[    4.184038] pci 0000:7f:16.3: [8086:2f6b] type 00 class 0x088000
[    4.190797] pci 0000:7f:16.6: [8086:2f6e] type 00 class 0x088000
[    4.197552] pci 0000:7f:16.7: [8086:2f6f] type 00 class 0x088000
[    4.204304] pci 0000:7f:17.0: [8086:2fd0] type 00 class 0x088000
[    4.211061] pci 0000:7f:17.1: [8086:2fd1] type 00 class 0x088000
[    4.217818] pci 0000:7f:17.2: [8086:2fd2] type 00 class 0x088000
[    4.224567] pci 0000:7f:17.3: [8086:2fd3] type 00 class 0x088000
[    4.231322] pci 0000:7f:17.4: [8086:2fb8] type 00 class 0x088000
[    4.238077] pci 0000:7f:17.5: [8086:2fb9] type 00 class 0x088000
[    4.244831] pci 0000:7f:17.6: [8086:2fba] type 00 class 0x088000
[    4.251587] pci 0000:7f:17.7: [8086:2fbb] type 00 class 0x088000
[    4.258350] pci 0000:7f:1e.0: [8086:2f98] type 00 class 0x088000
[    4.265104] pci 0000:7f:1e.1: [8086:2f99] type 00 class 0x088000
[    4.271855] pci 0000:7f:1e.2: [8086:2f9a] type 00 class 0x088000
[    4.278609] pci 0000:7f:1e.3: [8086:2fc0] type 00 class 0x088000
[    4.285325] pci 0000:7f:1e.3: [Firmware Bug]: reg 0x10: invalid BAR (can=
't size)
[    4.293627] pci 0000:7f:1e.4: [8086:2f9c] type 00 class 0x088000
[    4.300388] pci 0000:7f:1f.0: [8086:2f88] type 00 class 0x088000
[    4.307144] pci 0000:7f:1f.2: [8086:2f8a] type 00 class 0x088000
[    4.332927] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7e])
[    4.339838] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    4.350995] acpi PNP0A08:00: _OSC: platform does not support [AER]
[    4.358935] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    4.367491] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    4.376860] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000=
-0x000cbfff window] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
[    4.391815] PCI host bridge to bus 0000:00
[    4.396395] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    4.403978] pci_bus 0000:00: root bus resource [io  0x1000-0x7fff window]
[    4.411562] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    4.419925] pci_bus 0000:00: root bus resource [mem 0x90000000-0xc7ffbff=
f window]
[    4.428279] pci_bus 0000:00: root bus resource [mem 0x380000000000-0x383=
fffffffff window]
[    4.437406] pci_bus 0000:00: root bus resource [bus 00-7e]
[    4.443532] pci 0000:00:00.0: [8086:2f00] type 00 class 0x060000
[    4.450371] pci 0000:00:01.0: [8086:2f02] type 01 class 0x060400
[    4.457125] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    4.464004] pci 0000:00:01.0: System wakeup disabled by ACPI
[    4.470359] pci 0000:00:02.0: [8086:2f04] type 01 class 0x060400
[    4.477112] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    4.483989] pci 0000:00:02.0: System wakeup disabled by ACPI
[    4.490341] pci 0000:00:02.2: [8086:2f06] type 01 class 0x060400
[    4.497085] pci 0000:00:02.2: PME# supported from D0 D3hot D3cold
[    4.503967] pci 0000:00:02.2: System wakeup disabled by ACPI
[    4.510324] pci 0000:00:03.0: [8086:2f08] type 01 class 0x060400
[    4.517074] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    4.523950] pci 0000:00:03.0: System wakeup disabled by ACPI
[    4.530306] pci 0000:00:03.2: [8086:2f0a] type 01 class 0x060400
[    4.537059] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
[    4.543937] pci 0000:00:03.2: System wakeup disabled by ACPI
[    4.550291] pci 0000:00:04.0: [8086:2f20] type 00 class 0x088000
[    4.557016] pci 0000:00:04.0: reg 0x10: [mem 0x383ffff2c000-0x383ffff2ff=
ff 64bit]
[    4.565491] pci 0000:00:04.1: [8086:2f21] type 00 class 0x088000
[    4.572215] pci 0000:00:04.1: reg 0x10: [mem 0x383ffff28000-0x383ffff2bf=
ff 64bit]
[    4.580688] pci 0000:00:04.2: [8086:2f22] type 00 class 0x088000
[    4.587413] pci 0000:00:04.2: reg 0x10: [mem 0x383ffff24000-0x383ffff27f=
ff 64bit]
[    4.595889] pci 0000:00:04.3: [8086:2f23] type 00 class 0x088000
[    4.602613] pci 0000:00:04.3: reg 0x10: [mem 0x383ffff20000-0x383ffff23f=
ff 64bit]
[    4.611085] pci 0000:00:04.4: [8086:2f24] type 00 class 0x088000
[    4.617811] pci 0000:00:04.4: reg 0x10: [mem 0x383ffff1c000-0x383ffff1ff=
ff 64bit]
[    4.626282] pci 0000:00:04.5: [8086:2f25] type 00 class 0x088000
[    4.633008] pci 0000:00:04.5: reg 0x10: [mem 0x383ffff18000-0x383ffff1bf=
ff 64bit]
[    4.641482] pci 0000:00:04.6: [8086:2f26] type 00 class 0x088000
[    4.648207] pci 0000:00:04.6: reg 0x10: [mem 0x383ffff14000-0x383ffff17f=
ff 64bit]
[    4.656678] pci 0000:00:04.7: [8086:2f27] type 00 class 0x088000
[    4.663402] pci 0000:00:04.7: reg 0x10: [mem 0x383ffff10000-0x383ffff13f=
ff 64bit]
[    4.671874] pci 0000:00:05.0: [8086:2f28] type 00 class 0x088000
[    4.678698] pci 0000:00:05.1: [8086:2f29] type 00 class 0x088000
[    4.685530] pci 0000:00:05.2: [8086:2f2a] type 00 class 0x088000
[    4.692350] pci 0000:00:05.4: [8086:2f2c] type 00 class 0x080020
[    4.699072] pci 0000:00:05.4: reg 0x10: [mem 0x91d06000-0x91d06fff]
[    4.706204] pci 0000:00:11.0: [8086:8d7c] type 00 class 0xff0000
[    4.713094] pci 0000:00:11.1: [8086:8d7d] type 00 class 0x0c0500
[    4.719825] pci 0000:00:11.1: reg 0x10: [mem 0x91d05000-0x91d05fff]
[    4.726849] pci 0000:00:11.1: reg 0x20: [io  0x3060-0x307f]
[    4.733211] pci 0000:00:11.4: [8086:8d62] type 00 class 0x010601
[    4.739939] pci 0000:00:11.4: reg 0x10: [io  0x3098-0x309f]
[    4.746165] pci 0000:00:11.4: reg 0x14: [io  0x30cc-0x30cf]
[    4.752390] pci 0000:00:11.4: reg 0x18: [io  0x3090-0x3097]
[    4.758616] pci 0000:00:11.4: reg 0x1c: [io  0x30c8-0x30cb]
[    4.764841] pci 0000:00:11.4: reg 0x20: [io  0x3020-0x303f]
[    4.771067] pci 0000:00:11.4: reg 0x24: [mem 0x91d00000-0x91d007ff]
[    4.778092] pci 0000:00:11.4: PME# supported from D3hot
[    4.784027] pci 0000:00:14.0: [8086:8d31] type 00 class 0x0c0330
[    4.790751] pci 0000:00:14.0: reg 0x10: [mem 0x383ffff00000-0x383ffff0ff=
ff 64bit]
[    4.799148] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    4.805747] pci 0000:00:14.0: System wakeup disabled by ACPI
[    4.812113] pci 0000:00:16.0: [8086:8d3a] type 00 class 0x078000
[    4.818842] pci 0000:00:16.0: reg 0x10: [mem 0x383ffff33000-0x383ffff330=
0f 64bit]
[    4.827251] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    4.834156] pci 0000:00:16.1: [8086:8d3b] type 00 class 0x078000
[    4.840884] pci 0000:00:16.1: reg 0x10: [mem 0x383ffff32000-0x383ffff320=
0f 64bit]
[    4.849285] pci 0000:00:16.1: PME# supported from D0 D3hot D3cold
[    4.856193] pci 0000:00:1a.0: [8086:8d2d] type 00 class 0x0c0320
[    4.862922] pci 0000:00:1a.0: reg 0x10: [mem 0x91d02000-0x91d023ff]
[    4.869983] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    4.876873] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    4.883240] pci 0000:00:1c.0: [8086:8d16] type 01 class 0x060400
[    4.890007] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    4.896867] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    4.903241] pci 0000:00:1d.0: [8086:8d26] type 00 class 0x0c0320
[    4.909971] pci 0000:00:1d.0: reg 0x10: [mem 0x91d01000-0x91d013ff]
[    4.917032] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    4.923917] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    4.930284] pci 0000:00:1f.0: [8086:8d44] type 00 class 0x060100
[    4.937183] pci 0000:00:1f.2: [8086:8d02] type 00 class 0x010601
[    4.943906] pci 0000:00:1f.2: reg 0x10: [io  0x30c0-0x30c7]
[    4.950121] pci 0000:00:1f.2: reg 0x14: [io  0x30dc-0x30df]
[    4.956346] pci 0000:00:1f.2: reg 0x18: [io  0x30b8-0x30bf]
[    4.962571] pci 0000:00:1f.2: reg 0x1c: [io  0x30d8-0x30db]
[    4.968796] pci 0000:00:1f.2: reg 0x20: [io  0x3040-0x305f]
[    4.975020] pci 0000:00:1f.2: reg 0x24: [mem 0x91d04000-0x91d047ff]
[    4.982040] pci 0000:00:1f.2: PME# supported from D3hot
[    4.987970] pci 0000:00:1f.3: [8086:8d22] type 00 class 0x0c0500
[    4.994687] pci 0000:00:1f.3: reg 0x10: [mem 0x383ffff31000-0x383ffff310=
ff 64bit]
[    5.003065] pci 0000:00:1f.3: reg 0x20: [io  0x3000-0x301f]
[    5.009563] pci 0000:00:01.0: PCI bridge to [bus 01]
[    5.015286] pci 0000:00:02.0: PCI bridge to [bus 02]
[    5.021019] pci 0000:03:00.0: [8086:1528] type 00 class 0x020000
[    5.027754] pci 0000:03:00.0: reg 0x10: [mem 0x383fffc00000-0x383fffdfff=
ff 64bit pref]
[    5.036604] pci 0000:03:00.0: reg 0x18: [io  0x2020-0x203f]
[    5.042843] pci 0000:03:00.0: reg 0x20: [mem 0x383fffe04000-0x383fffe07f=
ff 64bit pref]
[    5.051731] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    5.058563] pci 0000:03:00.0: reg 0x184: [mem 0x91900000-0x91903fff 64bi=
t]
[    5.066246] pci 0000:03:00.0: VF(n) BAR0 space: [mem 0x91900000-0x919fff=
ff 64bit] (contains BAR0 for 64 VFs)
[    5.077236] pci 0000:03:00.0: reg 0x190: [mem 0x91a00000-0x91a03fff 64bi=
t]
[    5.084909] pci 0000:03:00.0: VF(n) BAR3 space: [mem 0x91a00000-0x91afff=
ff 64bit] (contains BAR3 for 64 VFs)
[    5.096073] pci 0000:03:00.1: [8086:1528] type 00 class 0x020000
[    5.102807] pci 0000:03:00.1: reg 0x10: [mem 0x383fffa00000-0x383fffbfff=
ff 64bit pref]
[    5.111657] pci 0000:03:00.1: reg 0x18: [io  0x2000-0x201f]
[    5.117897] pci 0000:03:00.1: reg 0x20: [mem 0x383fffe00000-0x383fffe03f=
ff 64bit pref]
[    5.126782] pci 0000:03:00.1: PME# supported from D0 D3hot D3cold
[    5.133610] pci 0000:03:00.1: reg 0x184: [mem 0x91b00000-0x91b03fff 64bi=
t]
[    5.141292] pci 0000:03:00.1: VF(n) BAR0 space: [mem 0x91b00000-0x91bfff=
ff 64bit] (contains BAR0 for 64 VFs)
[    5.152282] pci 0000:03:00.1: reg 0x190: [mem 0x91c00000-0x91c03fff 64bi=
t]
[    5.159964] pci 0000:03:00.1: VF(n) BAR3 space: [mem 0x91c00000-0x91cfff=
ff 64bit] (contains BAR3 for 64 VFs)
[    5.171644] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[    5.177484] pci 0000:00:02.2:   bridge window [io  0x2000-0x2fff]
[    5.184295] pci 0000:00:02.2:   bridge window [mem 0x91900000-0x91cfffff]
[    5.191881] pci 0000:00:02.2:   bridge window [mem 0x383fffa00000-0x383f=
ffefffff 64bit pref]
[    5.201480] pci 0000:00:03.0: PCI bridge to [bus 05]
[    5.207196] pci 0000:00:03.2: PCI bridge to [bus 06]
[    5.212819] pci 0000:07:00.0: [102b:0522] type 00 class 0x030000
[    5.219568] pci 0000:07:00.0: reg 0x10: [mem 0x90000000-0x90ffffff pref]
[    5.227061] pci 0000:07:00.0: reg 0x14: [mem 0x91800000-0x91803fff]
[    5.234067] pci 0000:07:00.0: reg 0x18: [mem 0x91000000-0x917fffff]
[    5.241113] pci 0000:07:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    5.250617] pci 0000:00:1c.0: PCI bridge to [bus 07]
[    5.256162] pci 0000:00:1c.0:   bridge window [mem 0x91000000-0x918fffff]
[    5.263742] pci 0000:00:1c.0:   bridge window [mem 0x90000000-0x90ffffff=
 64bit pref]
[    5.272424] pci_bus 0000:00: on NUMA node 0
[    5.277537] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.287095] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.296664] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.306234] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.315805] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.325376] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.334947] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.344517] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    5.354378] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 80-fe])
[    5.361288] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    5.371015] acpi PNP0A08:01: _OSC: platform does not support [AER]
[    5.378941] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    5.387496] acpi PNP0A08:01: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    5.396820] PCI host bridge to bus 0000:80
[    5.401400] pci_bus 0000:80: root bus resource [io  0x03b0-0x03df window]
[    5.408986] pci_bus 0000:80: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    5.417346] pci_bus 0000:80: root bus resource [io  0x8000-0xffff window]
[    5.424923] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xfbffbff=
f window]
[    5.433283] pci_bus 0000:80: root bus resource [mem 0x384000000000-0x387=
fffffffff window]
[    5.442420] pci_bus 0000:80: root bus resource [bus 80-fe]
[    5.448549] pci 0000:80:04.0: [8086:2f20] type 00 class 0x088000
[    5.455274] pci 0000:80:04.0: reg 0x10: [mem 0x387ffff1c000-0x387ffff1ff=
ff 64bit]
[    5.463720] pci 0000:80:04.1: [8086:2f21] type 00 class 0x088000
[    5.470443] pci 0000:80:04.1: reg 0x10: [mem 0x387ffff18000-0x387ffff1bf=
ff 64bit]
[    5.478890] pci 0000:80:04.2: [8086:2f22] type 00 class 0x088000
[    5.485614] pci 0000:80:04.2: reg 0x10: [mem 0x387ffff14000-0x387ffff17f=
ff 64bit]
[    5.494055] pci 0000:80:04.3: [8086:2f23] type 00 class 0x088000
[    5.500777] pci 0000:80:04.3: reg 0x10: [mem 0x387ffff10000-0x387ffff13f=
ff 64bit]
[    5.509222] pci 0000:80:04.4: [8086:2f24] type 00 class 0x088000
[    5.515945] pci 0000:80:04.4: reg 0x10: [mem 0x387ffff0c000-0x387ffff0ff=
ff 64bit]
[    5.524389] pci 0000:80:04.5: [8086:2f25] type 00 class 0x088000
[    5.531112] pci 0000:80:04.5: reg 0x10: [mem 0x387ffff08000-0x387ffff0bf=
ff 64bit]
[    5.539557] pci 0000:80:04.6: [8086:2f26] type 00 class 0x088000
[    5.546278] pci 0000:80:04.6: reg 0x10: [mem 0x387ffff04000-0x387ffff07f=
ff 64bit]
[    5.554721] pci 0000:80:04.7: [8086:2f27] type 00 class 0x088000
[    5.561444] pci 0000:80:04.7: reg 0x10: [mem 0x387ffff00000-0x387ffff03f=
ff 64bit]
[    5.569889] pci 0000:80:05.0: [8086:2f28] type 00 class 0x088000
[    5.576685] pci 0000:80:05.1: [8086:2f29] type 00 class 0x088000
[    5.583489] pci 0000:80:05.2: [8086:2f2a] type 00 class 0x088000
[    5.590283] pci 0000:80:05.4: [8086:2f2c] type 00 class 0x080020
[    5.597004] pci 0000:80:05.4: reg 0x10: [mem 0xc8000000-0xc8000fff]
[    5.604097] pci_bus 0000:80: on NUMA node 2
[    5.609136] ACPI: Enabled 4 GPEs in block 00 to 3F
[    5.614635] vgaarb: setting as boot device: PCI:0000:07:00.0
[    5.620952] vgaarb: device added: PCI:0000:07:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    5.629994] vgaarb: loaded
[    5.633011] vgaarb: bridge control possible 0000:07:00.0
[    5.639030] SCSI subsystem initialized
[    5.643243] ACPI: bus type USB registered
[    5.647737] usbcore: registered new interface driver usbfs
[    5.653873] usbcore: registered new interface driver hub
[    5.659989] usbcore: registered new device driver usb
[    5.665662] pps_core: LinuxPPS API ver. 1 registered
[    5.671201] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    5.681408] PTP clock support registered
[    5.686115] PCI: Using ACPI for IRQ routing
[    5.694766] PCI: pci_cache_line_size set to 64 bytes
[    5.700501] e820: reserve RAM buffer [mem 0x0009b400-0x0009ffff]
[    5.707211] e820: reserve RAM buffer [mem 0x76231000-0x77ffffff]
[    5.713916] e820: reserve RAM buffer [mem 0x7a1d3000-0x7bffffff]
[    5.720619] e820: reserve RAM buffer [mem 0x7b800000-0x7bffffff]
[    5.727464] NetLabel: Initializing
[    5.731267] NetLabel:  domain hash size =3D 128
[    5.736127] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    5.741679] NetLabel:  unlabeled traffic allowed by default
[    5.748006] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    5.754999] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    5.763676] clocksource: Switched to clocksource hpet
[    5.780940] pnp: PnP ACPI init
[    5.785203] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    5.792603] system 00:01: [io  0x0500-0x053f] has been reserved
[    5.799214] system 00:01: [io  0x0400-0x047f] could not be reserved
[    5.806211] system 00:01: [io  0x0540-0x057f] has been reserved
[    5.812818] system 00:01: [io  0x0600-0x061f] has been reserved
[    5.819430] system 00:01: [io  0x0ca0-0x0ca5] has been reserved
[    5.826040] system 00:01: [io  0x0880-0x0883] has been reserved
[    5.832648] system 00:01: [io  0x0800-0x081f] has been reserved
[    5.839257] system 00:01: [mem 0xfed1c000-0xfed3ffff] could not be reser=
ved
[    5.847023] system 00:01: [mem 0xfed45000-0xfed8bfff] has been reserved
[    5.854410] system 00:01: [mem 0xff000000-0xffffffff] could not be reser=
ved
[    5.862191] system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
[    5.869577] system 00:01: [mem 0xfed12000-0xfed1200f] has been reserved
[    5.876971] system 00:01: [mem 0xfed12010-0xfed1201f] has been reserved
[    5.884355] system 00:01: [mem 0xfed1b000-0xfed1bfff] has been reserved
[    5.891743] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    5.899543] pnp 00:02: Plug and Play ACPI device, IDs PNP0501 (active)
[    5.907051] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
[    5.914675] pnp: PnP ACPI: found 4 devices
[    5.925973] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, m=
ax_idle_ns: 2085701024 ns
[    5.935897] pci 0000:07:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffff=
ff pref]: no compatible bridge window
[    5.947024] pci 0000:00:01.0: PCI bridge to [bus 01]
[    5.952578] pci 0000:00:02.0: PCI bridge to [bus 02]
[    5.958132] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[    5.963973] pci 0000:00:02.2:   bridge window [io  0x2000-0x2fff]
[    5.970779] pci 0000:00:02.2:   bridge window [mem 0x91900000-0x91cfffff]
[    5.978358] pci 0000:00:02.2:   bridge window [mem 0x383fffa00000-0x383f=
ffefffff 64bit pref]
[    5.987780] pci 0000:00:03.0: PCI bridge to [bus 05]
[    5.993335] pci 0000:00:03.2: PCI bridge to [bus 06]
[    5.998894] pci 0000:07:00.0: BAR 6: assigned [mem 0x91810000-0x9181ffff=
 pref]
[    6.006961] pci 0000:00:1c.0: PCI bridge to [bus 07]
[    6.012514] pci 0000:00:1c.0:   bridge window [mem 0x91000000-0x918fffff]
[    6.020094] pci 0000:00:1c.0:   bridge window [mem 0x90000000-0x90ffffff=
 64bit pref]
[    6.028745] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    6.035650] pci_bus 0000:00: resource 5 [io  0x1000-0x7fff window]
[    6.042552] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    6.050237] pci_bus 0000:00: resource 7 [mem 0x90000000-0xc7ffbfff windo=
w]
[    6.057912] pci_bus 0000:00: resource 8 [mem 0x380000000000-0x383fffffff=
ff window]
[    6.066372] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    6.072593] pci_bus 0000:03: resource 1 [mem 0x91900000-0x91cfffff]
[    6.079592] pci_bus 0000:03: resource 2 [mem 0x383fffa00000-0x383fffefff=
ff 64bit pref]
[    6.088438] pci_bus 0000:07: resource 1 [mem 0x91000000-0x918fffff]
[    6.095443] pci_bus 0000:07: resource 2 [mem 0x90000000-0x90ffffff 64bit=
 pref]
[    6.103517] pci_bus 0000:80: resource 4 [io  0x03b0-0x03df window]
[    6.110425] pci_bus 0000:80: resource 5 [mem 0x000a0000-0x000bffff windo=
w]
[    6.118092] pci_bus 0000:80: resource 6 [io  0x8000-0xffff window]
[    6.124992] pci_bus 0000:80: resource 7 [mem 0xc8000000-0xfbffbfff windo=
w]
[    6.132669] pci_bus 0000:80: resource 8 [mem 0x384000000000-0x387fffffff=
ff window]
[    6.141232] NET: Registered protocol family 2
[    6.146943] TCP established hash table entries: 524288 (order: 10, 41943=
04 bytes)
[    6.155914] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    6.163530] TCP: Hash tables configured (established 524288 bind 65536)
[    6.171123] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[    6.178501] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[    6.186701] NET: Registered protocol family 1
[    6.191924] RPC: Registered named UNIX socket transport module.
[    6.198546] RPC: Registered udp transport module.
[    6.203799] RPC: Registered tcp transport module.
[    6.209054] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.216552] pci 0000:07:00.0: Video device with shadowed ROM
[    6.222895] PCI: CLS 32 bytes, default 64
[    6.227422] Unpacking initramfs...
[    8.312662] Freeing initrd memory: 140540K (ffff8820756c1000 - ffff88207=
e000000)
[    8.320941] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    8.328143] software IO TLB [mem 0x72231000-0x76231000] (64MB) mapped at=
 [ffff880072231000-ffff880076230fff]
[    8.339374] RAPL PMU detected, API unit is 2^-32 Joules, 3 fixed counter=
s 655360 ms ovfl timer
[    8.349001] hw unit of domain pp0-core 2^-14 Joules
[    8.354447] hw unit of domain package 2^-14 Joules
[    8.359785] hw unit of domain dram 2^-16 Joules
[    8.364877] Intel CQM monitoring enabled
[    8.379255] futex hash table entries: 65536 (order: 10, 4194304 bytes)
[    8.387113] audit: initializing netlink subsys (disabled)
[    8.393175] audit: type=3D2000 audit(1449452189.085:1): initialized
[    8.400758] Initialise system trusted keyring
[    8.405829] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    8.414116] zbud: loaded
[    8.417175] VFS: Disk quotas dquot_6.6.0
[    8.421664] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    8.430243] SGI XFS with ACLs, security attributes, no debug enabled
[    8.438448] 9p: Installing v9fs 9p2000 file system support
[    8.444731] Key type big_key registered
[    8.449024] SELinux:  Registering netfilter hooks
[    8.458292] NET: Registered protocol family 38
[    8.463268] Key type asymmetric registered
[    8.467851] Asymmetric key parser 'x509' registered
[    8.473338] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 249)
[    8.481842] io scheduler noop registered
[    8.486237] io scheduler deadline registered (default)
[    8.491999] io scheduler cfq registered
[    8.496644] IOAPIC[1]: Set routing entry (9-23 -> 0x41 -> IRQ 24 Mode:1 =
Active:1 Dest:0)
[    8.505975] IOAPIC[1]: Set routing entry (9-23 -> 0x61 -> IRQ 24 Mode:1 =
Active:1 Dest:0)
[    8.515257] IOAPIC[1]: Set routing entry (9-23 -> 0x81 -> IRQ 24 Mode:1 =
Active:1 Dest:0)
[    8.524537] IOAPIC[1]: Set routing entry (9-23 -> 0xa1 -> IRQ 24 Mode:1 =
Active:1 Dest:0)
[    8.533835] IOAPIC[1]: Set routing entry (9-23 -> 0xc1 -> IRQ 24 Mode:1 =
Active:1 Dest:0)
[    8.543109] IOAPIC[0]: Set routing entry (8-19 -> 0xe1 -> IRQ 19 Mode:1 =
Active:1 Dest:0)
[    8.552352] pcieport 0000:00:01.0: Signaling PME through PCIe PME interr=
upt
[    8.560140] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
[    8.567646] pcieport 0000:00:02.0: Signaling PME through PCIe PME interr=
upt
[    8.575428] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[    8.582921] pcieport 0000:00:02.2: Signaling PME through PCIe PME interr=
upt
[    8.590705] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[    8.598002] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
[    8.605292] pcie_pme 0000:00:02.2:pcie01: service driver pcie_pme loaded
[    8.612796] pcieport 0000:00:03.0: Signaling PME through PCIe PME interr=
upt
[    8.620577] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[    8.628077] pcieport 0000:00:03.2: Signaling PME through PCIe PME interr=
upt
[    8.635859] pcie_pme 0000:00:03.2:pcie01: service driver pcie_pme loaded
[    8.643366] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interr=
upt
[    8.651146] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[    8.658428] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[    8.665916] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    8.672149] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    8.679574] intel_idle: MWAIT substates: 0x2120
[    8.684639] intel_idle: v0.4 model 0x3F
[    8.688921] intel_idle: lapic_timer_reliable_states 0xffffffff
[    8.697943] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    8.706215] ACPI: Power Button [PWRF]
[    8.806929] ERST: Error Record Serialization Table (ERST) support is ini=
tialized.
[    8.815302] pstore: Registered erst as persistent store backend
[    8.822347] GHES: APEI firmware first mode is enabled by APEI bit and WH=
EA _OSC.
[    8.830784] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    8.858547] 00:02: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    8.887558] 00:03: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D 115200) =
is a 16550A
[    8.896370] Non-volatile memory driver v1.3
[    8.901134] Linux agpgart interface v0.103
[    8.912737] IOAPIC[0]: Set routing entry (8-16 -> 0x42 -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[    8.921841] mei_me 0000:00:16.0: Device doesn't have valid ME Interface
[    8.929665] rdac: device handler registered
[    8.934500] hp_sw: device handler registered
[    8.939275] emc: device handler registered
[    8.943856] alua: device handler registered
[    8.948570] libphy: Fixed MDIO Bus: probed
[    8.953226] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[    8.961101] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    8.967546] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    8.974067] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    8.980712] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.=
0-k
[    8.988496] igb: Copyright (c) 2007-2014 Intel Corporation.
[    8.994759] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 4.2.1-k
[    9.003315] ixgbe: Copyright (c) 1999-2015 Intel Corporation.
[    9.009829] IOAPIC[1]: Set routing entry (9-13 -> 0x52 -> IRQ 30 Mode:1 =
Active:1 Dest:0)
[    9.262063] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count =3D 6=
3, Tx Queue count =3D 63
[    9.308108] ixgbe 0000:03:00.0: PCI Express bandwidth of 32GT/s available
[    9.315701] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss=
:20%)
[    9.338748] tsc: Refined TSC clocksource calibration: 2294.704 MHz
[    9.345686] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x211=
3aa29134, max_idle_ns: 440795259492 ns
[    9.347991] ixgbe 0000:03:00.0: MAC: 3, PHY: 0, PBA No: 000000-000
[    9.347993] ixgbe 0000:03:00.0: 00:1e:67:dc:1e:b1
[    9.498572] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
[    9.505959] IOAPIC[1]: Set routing entry (9-10 -> 0xa7 -> IRQ 30 Mode:1 =
Active:1 Dest:0)
[    9.758114] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count =3D 6=
3, Tx Queue count =3D 63
[    9.804148] ixgbe 0000:03:00.1: PCI Express bandwidth of 32GT/s available
[    9.811750] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss=
:20%)
[    9.844103] ixgbe 0000:03:00.1: MAC: 3, PHY: 0, PBA No: 000000-000
[    9.851023] ixgbe 0000:03:00.1: 00:1e:67:dc:1e:b2
[   10.005786] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
[   10.013215] usbcore: registered new interface driver catc
[   10.019260] usbcore: registered new interface driver kaweth
[   10.025490] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[   10.033756] usbcore: registered new interface driver pegasus
[   10.040086] usbcore: registered new interface driver rtl8150
[   10.046416] usbcore: registered new interface driver asix
[   10.052457] usbcore: registered new interface driver cdc_ether
[   10.058981] usbcore: registered new interface driver cdc_eem
[   10.065312] usbcore: registered new interface driver dm9601
[   10.071547] usbcore: registered new interface driver smsc75xx
[   10.077976] usbcore: registered new interface driver smsc95xx
[   10.084403] usbcore: registered new interface driver gl620a
[   10.090635] usbcore: registered new interface driver net1080
[   10.096963] usbcore: registered new interface driver plusb
[   10.103098] usbcore: registered new interface driver rndis_host
[   10.109721] usbcore: registered new interface driver cdc_subset
[   10.116341] usbcore: registered new interface driver zaurus
[   10.122574] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[   10.130848] usbcore: registered new interface driver int51x1
[   10.137178] usbcore: registered new interface driver ipheth
[   10.143411] usbcore: registered new interface driver sierra_net
[   10.150228] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   10.157542] ehci-pci: EHCI PCI platform driver
[   10.162669] IOAPIC[0]: Set routing entry (8-18 -> 0x2d -> IRQ 18 Mode:1 =
Active:1 Dest:0)
[   10.171906] ehci-pci 0000:00:1a.0: EHCI Host Controller
[   10.177882] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus =
number 1
[   10.186153] ehci-pci 0000:00:1a.0: debug port 2
[   10.195117] ehci-pci 0000:00:1a.0: cache line size of 32 is not supported
[   10.202717] ehci-pci 0000:00:1a.0: irq 18, io mem 0x91d02000
[   10.214730] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[   10.221208] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   10.228795] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   10.236868] usb usb1: Product: EHCI Host Controller
[   10.242317] usb usb1: Manufacturer: Linux 4.4.0-rc3-00025-gcb8d058 ehci_=
hcd
[   10.250097] usb usb1: SerialNumber: 0000:00:1a.0
[   10.255419] hub 1-0:1.0: USB hub found
[   10.259611] hub 1-0:1.0: 2 ports detected
[   10.264387] ehci-pci 0000:00:1d.0: EHCI Host Controller
[   10.270339] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus =
number 2
[   10.278616] ehci-pci 0000:00:1d.0: debug port 2
[   10.287587] ehci-pci 0000:00:1d.0: cache line size of 32 is not supported
[   10.295169] ehci-pci 0000:00:1d.0: irq 18, io mem 0x91d01000
[   10.306737] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[   10.313200] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   10.320779] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   10.328852] usb usb2: Product: EHCI Host Controller
[   10.334298] usb usb2: Manufacturer: Linux 4.4.0-rc3-00025-gcb8d058 ehci_=
hcd
[   10.342078] usb usb2: SerialNumber: 0000:00:1d.0
[   10.347360] hub 2-0:1.0: USB hub found
[   10.351560] hub 2-0:1.0: 2 ports detected
[   10.356164] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   10.363086] ohci-pci: OHCI PCI platform driver
[   10.368089] uhci_hcd: USB Universal Host Controller Interface driver
[   10.375273] clocksource: Switched to clocksource tsc
[   10.375401] IOAPIC[0]: Set routing entry (8-19 -> 0x4d -> IRQ 19 Mode:1 =
Active:1 Dest:0)
[   10.375432] xhci_hcd 0000:00:14.0: xHCI Host Controller
[   10.375483] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus =
number 3
[   10.376624] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x1=
00 quirks 0x00009810
[   10.376628] xhci_hcd 0000:00:14.0: cache line size of 32 is not supported
[   10.376677] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   10.376678] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   10.376679] usb usb3: Product: xHCI Host Controller
[   10.376680] usb usb3: Manufacturer: Linux 4.4.0-rc3-00025-gcb8d058 xhci-=
hcd
[   10.376680] usb usb3: SerialNumber: 0000:00:14.0
[   10.376821] hub 3-0:1.0: USB hub found
[   10.376845] hub 3-0:1.0: 15 ports detected
[   10.379334] xhci_hcd 0000:00:14.0: xHCI Host Controller
[   10.379390] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus =
number 4
[   10.379419] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0003
[   10.379420] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   10.379421] usb usb4: Product: xHCI Host Controller
[   10.379422] usb usb4: Manufacturer: Linux 4.4.0-rc3-00025-gcb8d058 xhci-=
hcd
[   10.379423] usb usb4: SerialNumber: 0000:00:14.0
[   10.379490] hub 4-0:1.0: USB hub found
[   10.379504] hub 4-0:1.0: 6 ports detected
[   10.380731] usbcore: registered new interface driver usbserial
[   10.380736] usbcore: registered new interface driver usbserial_generic
[   10.380740] usbserial: USB Serial support registered for generic
[   10.380757] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   10.565710] usb 1-1: new high-speed USB device number 2 using ehci-pci
[   10.657708] usb 2-1: new high-speed USB device number 2 using ehci-pci
[   10.687113] usb 1-1: New USB device found, idVendor=3D8087, idProduct=3D=
800a
[   10.694599] usb 1-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[   10.702723] hub 1-1:1.0: USB hub found
[   10.706951] hub 1-1:1.0: 6 ports detected
[   10.731720] usb 3-3: new full-speed USB device number 2 using xhci_hcd
[   10.779129] usb 2-1: New USB device found, idVendor=3D8087, idProduct=3D=
8002
[   10.786616] usb 2-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[   10.794849] hub 2-1:1.0: USB hub found
[   10.799077] hub 2-1:1.0: 8 ports detected
[   10.862400] usb 3-3: New USB device found, idVendor=3D14dd, idProduct=3D=
1005
[   10.869898] usb 3-3: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   10.877873] usb 3-3: Product: D2CIM-VUSB
[   10.882250] usb 3-3: Manufacturer: Raritan
[   10.886821] usb 3-3: SerialNumber: 7C07478CDFA473C
[   10.892252] usb 3-3: ep 0x81 - rounding interval to 64 microframes, ep d=
esc says 80 microframes
[   10.923133] i8042: Can't read CTR while initializing i8042
[   10.929269] i8042: probe of i8042 failed with error -5
[   10.935093] mousedev: PS/2 mouse device common for all mice
[   10.941523] rtc_cmos 00:00: RTC can wake from S4
[   10.946832] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   10.953686] rtc_cmos 00:00: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[   10.962328] IOAPIC[0]: Set routing entry (8-17 -> 0x5d -> IRQ 17 Mode:1 =
Active:1 Dest:0)
[   10.971510] i801_smbus 0000:00:11.1: SMBus using PCI interrupt
[   10.980900] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[   10.989695] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   10.995955] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by=
 hardware/BIOS
[   11.004801] iTCO_vendor_support: vendor-support=3D0
[   11.010070] Intel P-state driver initializing.
[   11.019758] hidraw: raw HID events driver (C) Jiri Kosina
[   11.031937] input: Raritan D2CIM-VUSB as /devices/pci0000:00/0000:00:14.=
0/usb3/3-3/3-3:1.0/0003:14DD:1005.0001/input/input1
[   11.055725] usb 3-9: new full-speed USB device number 3 using xhci_hcd
[   11.095032] hid-generic 0003:14DD:1005.0001: input,hidraw0: USB HID v1.1=
1 Keyboard [Raritan D2CIM-VUSB] on usb-0000:00:14.0-3/input0
[   11.108378] usbcore: registered new interface driver usbhid
[   11.114611] usbhid: USB HID core driver
[   11.119217] drop_monitor: Initializing network drop monitor service
[   11.126585] Initializing XFRM netlink socket
[   11.131692] NET: Registered protocol family 10
[   11.137808] NET: Registered protocol family 17
[   11.142801] 9pnet: Installing 9P2000 support
[   11.150484] ... APIC ID:      00000000 (0)
[   11.155070] ... APIC VERSION: 01060015
[   11.159269] 000000000000000000000000000000000000000000000000000000000000=
0000
[   11.167241] 000000000200200000002000000000000000000000000000000200000000=
0000
[   11.175205] 000000000000000000000000000000000000000000000000000000000000=
8000
[   11.183172]=20
[   11.184845] number of MP IRQ sources: 15.
[   11.189334] number of IO-APIC #8 registers: 24.
[   11.194400] number of IO-APIC #9 registers: 24.
[   11.199465] number of IO-APIC #10 registers: 24.
[   11.204619] testing the IO APIC.......................
[   11.210368] IO APIC #8......
[   11.213581] .... register #00: 08000000
[   11.217869] .......    : physical APIC id: 08
[   11.222741] .......    : Delivery Type: 0
[   11.227223] .......    : LTS          : 0
[   11.231698] .... register #01: 00=00170020
[   11.entries: 17
[   11.241621] .......     : PRQ implemented: 0
[  =00 11.246385] ...R=00Q redirection tn=0000, disabled, e(0)
[   11.266834]  pin01, enabled , edge , high, V(31), IRR(0), S(0), physical=
, D(00), M(0)
[   11.267462] usb 3-9: New USB device found, idVendor=3D046b, idProduct=3D=
ff10
[   11.267464] usb 3-9: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   11.267466] usb 3-9: Product: Virtual Keyboard and Mouse
[   11.267477] usb 3-9: Manufacturer: American Megatrends Inc.
[   11.267479] usb 3-9: SerialNumber: serial
[   11.267636] usb 3-9: ep 0x81 - rounding interval to 64 microframes, ep d=
esc says 80 microframes
[   11.268946] input: American Megatrends Inc. Virtual Keyboard and Mouse a=
s /devices/pci0000:00/0000:00:14.0/usb3/3-9/3-9:1.0/0003:046B:FF10.0002/inp=
ut/input2
[   11.319040] hid-generic 0003:046B:FF10.0002: input,hidraw1: USB HID v1.1=
0 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-000=
0:00:14.0-9/input0
[   11.320176] input: American Megatrends Inc. Virtual Keyboard and Mouse a=
s /devices/pci0000:00/0000:00:14.0/usb3/3-9/3-9:1.1/0003:046B:FF10.0003/inp=
ut/input3
[   11.320354] hid-generic 0003:046B:FF10.0003: input,hidraw2: USB HID v1.1=
0 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:0=
0:14.0-9/input1
[   11.381336]  pin02, enabled , edge , high, V(30), IRR(0), S(0), physical=
, D(00), M(0)
[   11.390078]  pin03, enabled , edge , high, V(33), IRR(0), S(0), physical=
, D(00), M(0)
[   11.398821]  pin04, enabled , edge , high, V(34), IRR(0), S(0), physical=
, D(00), M(0)
[   11.407563]  pin05, enabled , edge , high, V(35), IRR(0), S(0), physical=
, D(00), M(0)
[   11.416298]  pin06, enabled , edge , high, V(36), IRR(0), S(0), physical=
, D(00), M(0)
[   11.425040]  pin07, enabled , edge , high, V(37), IRR(0), S(0), physical=
, D(00), M(0)
[   11.433773]  pin08, enabled , edge , high, V(38), IRR(0), S(0), physical=
, D(00), M(0)
[   11.442515]  pin09, enabled , level, high, V(39), IRR(0), S(0), physical=
, D(00), M(0)
[   11.451259]  pin0a, enabled , edge , high, V(3A), IRR(0), S(0), physical=
, D(00), M(0)
[   11.460002]  pin0b, enabled , edge , high, V(3B), IRR(0), S(0), physical=
, D(00), M(0)
[   11.468746]  pin0c, enabled , edge , high, V(3C), IRR(0), S(0), physical=
, D(00), M(0)
[   11.477488]  pin0d, enabled , edge , high, V(3D), IRR(0), S(0), physical=
, D(00), M(0)
[   11.486224]  pin0e, enabled , edge , high, V(3E), IRR(0), S(0), physical=
, D(00), M(0)
[   11.494968]  pin0f, enabled , edge , high, V(3F), IRR(0), S(0), physical=
, D(00), M(0)
[   11.503711]  pin10, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.512453]  pin11, enabled , level, low , V(5D), IRR(0), S(0), physical=
, D(00), M(0)
[   11.521188]  pin12, enabled , level, low , V(2D), IRR(0), S(0), physical=
, D(00), M(0)
[   11.529931]  pin13, enabled , level, low , V(4D), IRR(0), S(0), physical=
, D(00), M(0)
[   11.538675]  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.547427]  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.556169]  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.564912]  pin17, disabled, edge , high, V(1A), IRR(0), S(0), remapped=
, I(303AE075),  Z(2)
[   11.574333] IO APIC #9......
[   11.577546] .... register #00: 09000000
[   11.581825] .......    : physical APIC id: 09
[   11.586686] .......    : Delivery Type: 0
[   11.591159] .......    : LTS          : 0
[   11.595632] .... register #01: 00170020
[   11.599912] .......     : max redirection entries: 17
[   11.605546] .......     : PRQ implemented: 0
[   11.610308] .......     : IO APIC version: 20
[   11.615169] .... register #02: 00000000
[   11.619445] .......     : arbitration: 00
[   11.623919] .... register #03: 00000001
[   11.628196] .......     : Boot DT    : 1
[   11.632571] .... IRQ redirection table:
[   11.636851] IOAPIC 1:
[   11.639386]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.648135]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.656886]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.665636]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.674385]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.683133]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.691882]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.700631]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.709380]  pin08, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.718129]  pin09, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.726879]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.735628]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.744377]  pin0c, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.753127]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.761875]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.770624]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.779373]  pin10, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.788123]  pin11, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.796874]  pin12, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.805615]  pin13, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.814356]  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.823106]  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.831846]  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.840595]  pin17, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.849345] IO APIC #10......
[   11.852661] .... register #00: 0A000000
[   11.856938] .......    : physical APIC id: 0A
[   11.861799] .......    : Delivery Type: 0
[   11.866271] .......    : LTS          : 0
[   11.870745] .... register #01: 00170020
[   11.875025] .......     : max redirection entries: 17
[   11.880662] .......     : PRQ implemented: 0
[   11.885424] .......     : IO APIC version: 20
[   11.890286] .... register #02: 00000000
[   11.894563] .......     : arbitration: 00
[   11.899034] .... register #03: 00000001
[   11.903313] .......     : Boot DT    : 1
[   11.907688] .... IRQ redirection table:
[   11.911965] IOAPIC 2:
[   11.914500]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.923249]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.931990]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.940743]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.949495]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.958249]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.967001]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.975753]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.984504]  pin08, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   11.993258]  pin09, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.002008]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.010762]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.019516]  pin0c, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.028269]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.037021]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.045774]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.054526]  pin10, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.063280]  pin11, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.072031]  pin12, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.080784]  pin13, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.089537]  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.098289]  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.107042]  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.115795]  pin17, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   12.124545] IRQ to pin mappings:
[   12.128156] IRQ0 -> 0:2
[   12.130929] IRQ1 -> 0:1
[   12.133682] IRQ3 -> 0:3
[   12.136439] IRQ4 -> 0:4
[   12.139199] IRQ5 -> 0:5
[   12.141958] IRQ6 -> 0:6
[   12.144709] IRQ7 -> 0:7
[   12.147457] IRQ8 -> 0:8
[   12.150209] IRQ9 -> 0:9
[   12.152968] IRQ10 -> 0:10
[   12.155922] IRQ11 -> 0:11
[   12.158869] IRQ12 -> 0:12
[   12.161820] IRQ13 -> 0:13
[   12.164766] IRQ14 -> 0:14
[   12.167714] IRQ15 -> 0:15
[   12.170656] IRQ17 -> 0:17
[   12.173593] IRQ18 -> 0:18
[   12.176549] IRQ19 -> 0:19
[   12.179505] .................................... done.
[   12.185434] registered taskstats version 1
[   12.190024] Loading compiled-in X.509 certificates
[   12.195444] zswap: loaded using pool lzo/zbud
[   12.203227] Key type trusted registered
[   12.212645] Key type encrypted registered
[   12.217157] ima: No TPM chip found, activating TPM-bypass!
[   12.223420] evm: HMAC attrs: 0x1
[   12.229069] rtc_cmos 00:00: setting system clock to 2015-12-07 01:36:37 =
UTC (1449452197)
[   12.515039] pps pps0: new PPS source ptp0
[   12.519534] ixgbe 0000:03:00.0: registered PHC device on eth0
[   12.637876] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   12.662815] ixgbe 0000:03:00.0 eth0: NIC Link is Up 1 Gbps, Flow Control=
: RX/TX
[   12.920351] pps pps1: new PPS source ptp1
[   12.924849] ixgbe 0000:03:00.1: registered PHC device on eth1
[   13.041916] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.048965] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   13.058736] Sending DHCP requests ., OK
[   13.100857] IP-Config: Got DHCP answer from 192.168.1.1, my address is 1=
92.168.1.173
[   13.110237] ixgbe 0000:03:00.1: removed PHC on eth1
[   13.443236] IP-Config: Complete:
[   13.446864]      device=3Deth0, hwaddr=3D00:1e:67:dc:1e:b1, ipaddr=3D192=
=2E168.1.173, mask=3D255.255.255.0, gw=3D192.168.1.1
[   13.458240]      host=3Dlkp-hsw-ep2, domain=3Dintel.com, nis-domain=3D(n=
one)
[   13.465539]      bootserver=3D192.168.1.1, rootserver=3D192.168.1.1, roo=
tpath=3D
[   13.473034]      nameserver0=3D192.168.1.1
[   13.477663] PM: Hibernation image not present or could not be loaded.
[   13.487385] Freeing unused kernel memory: 1880K (ffffffff81e8d000 - ffff=
ffff82063000)
[   13.499032] systemd[1]: RTC configured in localtime, applying delta of 4=
80 minutes to system time.
[   13.510233] random: systemd urandom read with 14 bits of entropy availab=
le
[   13.539197] systemd-default-display-manager-generator[653]: No /etc/X11/=
default-display-manager file, nothing to generate
[   13.539499] systemd-gpt-auto-generator[654]: Root file system not on a (=
single) block device.
[   13.539821] systemd-fstab-generator[655]: Parsing /etc/fstab
[   13.539902] systemd-rc-local-generator[656]: Automatically adding rc-loc=
al.service.
[   13.540289] systemd-sysv-generator[657]: Looking for unit files in (high=
er priority first):
[   13.540292] systemd-sysv-generator[657]: 	/etc/systemd/system
[   13.540294] systemd-sysv-generator[657]: 	/run/systemd/system
[   13.540296] systemd-sysv-generator[657]: 	/usr/local/lib/systemd/system
[   13.540298] systemd-sysv-generator[657]: 	/lib/systemd/system
[   13.540300] systemd-sysv-generator[657]: 	/usr/lib/systemd/system
[   13.540313] systemd-sysv-generator[657]: Looking for SysV init scripts i=
n:
[   13.540315] systemd-sysv-generator[657]: 	/etc/init.d
[   13.540318] systemd-sysv-generator[657]: Looking for SysV rcN.d links in:
[   13.540320] systemd-sysv-generator[657]: 	/etc
[   13.542222] systemd-sysv-generator[657]: Ignoring S03mountdevsubfs.sh sy=
mlink in rcS.d, not generating mountdevsubfs.service.
[   13.542228] systemd-sysv-generator[657]: Ignoring S10udev-finish symlink=
 in rcS.d, not generating udev-finish.service.
[   13.542232] systemd-sysv-generator[657]: Ignoring S16x11-common symlink =
in rcS.d, not generating x11-common.service.
[   13.542237] systemd-sysv-generator[657]: Ignoring S10procps symlink in r=
cS.d, not generating procps.service.
[   13.542241] systemd-sysv-generator[657]: Ignoring S14mountnfs.sh symlink=
 in rcS.d, not generating mountnfs.service.
[   13.542246] systemd-sysv-generator[657]: Ignoring S15mountnfs-bootclean.=
sh symlink in rcS.d, not generating mountnfs-bootclean.service.
[   13.542251] systemd-sysv-generator[657]: Ignoring S07checkroot-bootclean=
=2Esh symlink in rcS.d, not generating checkroot-bootclean.service.
[   13.542255] systemd-sysv-generator[657]: Ignoring S05checkroot.sh symlin=
k in rcS.d, not generating checkroot.service.
[   13.542262] systemd-sysv-generator[657]: Ignoring S04hwclock.sh symlink =
in rcS.d, not generating hwclock.service.
[   13.542268] systemd-sysv-generator[657]: Ignoring S09mountall-bootclean.=
sh symlink in rcS.d, not generating mountall-bootclean.service.
[   13.542272] systemd-sysv-generator[657]: Ignoring S10urandom symlink in =
rcS.d, not generating urandom.service.
[   13.542276] systemd-sysv-generator[657]: Ignoring S07kmod symlink in rcS=
=2Ed, not generating kmod.service.
[   13.542280] systemd-sysv-generator[657]: Ignoring S16bootmisc.sh symlink=
 in rcS.d, not generating bootmisc.service.
[   13.542284] systemd-sysv-generator[657]: Ignoring S01mountkernfs.sh syml=
ink in rcS.d, not generating mountkernfs.service.
[   13.542288] systemd-sysv-generator[657]: Ignoring S01hostname.sh symlink=
 in rcS.d, not generating hostname.service.
[   13.542292] systemd-sysv-generator[657]: Ignoring S02udev symlink in rcS=
=2Ed, not generating udev.service.
[   13.542297] systemd-sysv-generator[657]: Ignoring S06checkfs.sh symlink =
in rcS.d, not generating checkfs.service.
[   13.542301] systemd-sysv-generator[657]: Ignoring S08mountall.sh symlink=
 in rcS.d, not generating mountall.service.
[   13.542319] systemd-sysv-generator[657]: Ignoring K02ipmievd symlink in =
rc1.d, not generating ipmievd.service.
[   13.542323] systemd-sysv-generator[657]: Ignoring S01bootlogs symlink in=
 rc1.d, not generating bootlogs.service.
[   13.542328] systemd-sysv-generator[657]: Ignoring S01killprocs symlink i=
n rc1.d, not generating killprocs.service.
[   13.542332] systemd-sysv-generator[657]: Ignoring S01motd symlink in rc1=
=2Ed, not generating motd.service.
[   13.542336] systemd-sysv-generator[657]: Ignoring K02mdadm symlink in rc=
1.d, not generating mdadm.service.
[   13.542343] systemd-sysv-generator[657]: Ignoring S02single symlink in r=
c1.d, not generating single.service.
[   13.542349] systemd-sysv-generator[657]: Ignoring K01watchdog symlink in=
 rc1.d, not generating watchdog.service.
[   13.542369] systemd-sysv-generator[657]: Ignoring S77lkp-bootstrap symli=
nk in rc2.d, not generating lkp-bootstrap.service.
[   13.542373] systemd-sysv-generator[657]: Ignoring S15wd_keepalive symlin=
k in rc2.d, not generating wd_keepalive.service.
[   13.542376] systemd-sysv-generator[657]: Ignoring S01bootlogs symlink in=
 rc2.d, not generating bootlogs.service.
[   13.542384] systemd-sysv-generator[657]: Ignoring S15ssh symlink in rc2.=
d, not generating ssh.service.
[   13.542387] systemd-sysv-generator[657]: Ignoring S15dbus symlink in rc2=
=2Ed, not generating dbus.service.
[   13.542394] systemd-sysv-generator[657]: Ignoring S16watchdog symlink in=
 rc2.d, not generating watchdog.service.
[   13.542398] systemd-sysv-generator[657]: Ignoring S01motd symlink in rc2=
=2Ed, not generating motd.service.
[   13.542405] systemd-sysv-generator[657]: Ignoring S16rmnologin symlink i=
n rc2.d, not generating rmnologin.service.
[   13.542409] systemd-sysv-generator[657]: Ignoring S15cron symlink in rc2=
=2Ed, not generating cron.service.
[   13.542413] systemd-sysv-generator[657]: Ignoring S01mdadm symlink in rc=
2.d, not generating mdadm.service.
[   13.542417] systemd-sysv-generator[657]: Ignoring S15ipmievd symlink in =
rc2.d, not generating ipmievd.service.
[   13.542422] systemd-sysv-generator[657]: Ignoring S16rc.local symlink in=
 rc2.d, not generating rc.local.service.
[   13.542440] systemd-sysv-generator[657]: Ignoring S15wd_keepalive symlin=
k in rc3.d, not generating wd_keepalive.service.
[   13.542444] systemd-sysv-generator[657]: Ignoring S01bootlogs symlink in=
 rc3.d, not generating bootlogs.service.
[   13.542451] systemd-sysv-generator[657]: Ignoring S15ssh symlink in rc3.=
d, not generating ssh.service.
[   13.542454] systemd-sysv-generator[657]: Ignoring S15dbus symlink in rc3=
=2Ed, not generating dbus.service.
[   13.542461] systemd-sysv-generator[657]: Ignoring S16watchdog symlink in=
 rc3.d, not generating watchdog.service.
[   13.542465] systemd-sysv-generator[657]: Ignoring S01motd symlink in rc3=
=2Ed, not generating motd.service.
[   13.542471] systemd-sysv-generator[657]: Ignoring S16rmnologin symlink i=
n rc3.d, not generating rmnologin.service.
[   13.542475] systemd-sysv-generator[657]: Ignoring S15cron symlink in rc3=
=2Ed, not generating cron.service.
[   13.542479] systemd-sysv-generator[657]: Ignoring S01mdadm symlink in rc=
3.d, not generating mdadm.service.
[   13.542482] systemd-sysv-generator[657]: Ignoring S15ipmievd symlink in =
rc3.d, not generating ipmievd.service.
[   13.542488] systemd-sysv-generator[657]: Ignoring S16rc.local symlink in=
 rc3.d, not generating rc.local.service.
[   13.542505] systemd-sysv-generator[657]: Ignoring S15wd_keepalive symlin=
k in rc4.d, not generating wd_keepalive.service.
[   13.542509] systemd-sysv-generator[657]: Ignoring S01bootlogs symlink in=
 rc4.d, not generating bootlogs.service.
[   13.542515] systemd-sysv-generator[657]: Ignoring S15ssh symlink in rc4.=
d, not generating ssh.service.
[   13.542519] systemd-sysv-generator[657]: Ignoring S15dbus symlink in rc4=
=2Ed, not generating dbus.service.
[   13.542525] systemd-sysv-generator[657]: Ignoring S16watchdog symlink in=
 rc4.d, not generating watchdog.service.
[   13.542529] systemd-sysv-generator[657]: Ignoring S01motd symlink in rc4=
=2Ed, not generating motd.service.
[   13.542536] systemd-sysv-generator[657]: Ignoring S16rmnologin symlink i=
n rc4.d, not generating rmnologin.service.
[   13.542539] systemd-sysv-generator[657]: Ignoring S15cron symlink in rc4=
=2Ed, not generating cron.service.
[   13.542543] systemd-sysv-generator[657]: Ignoring S01mdadm symlink in rc=
4.d, not generating mdadm.service.
[   13.542547] systemd-sysv-generator[657]: Ignoring S15ipmievd symlink in =
rc4.d, not generating ipmievd.service.
[   13.542552] systemd-sysv-generator[657]: Ignoring S16rc.local symlink in=
 rc4.d, not generating rc.local.service.
[   13.542569] systemd-sysv-generator[657]: Ignoring S15wd_keepalive symlin=
k in rc5.d, not generating wd_keepalive.service.
[   13.542573] systemd-sysv-generator[657]: Ignoring S01bootlogs symlink in=
 rc5.d, not generating bootlogs.service.
[   13.542579] systemd-sysv-generator[657]: Ignoring S15ssh symlink in rc5.=
d, not generating ssh.service.
[   13.542583] systemd-sysv-generator[657]: Ignoring S15dbus symlink in rc5=
=2Ed, not generating dbus.service.
[   13.542589] systemd-sysv-generator[657]: Ignoring S16watchdog symlink in=
 rc5.d, not generating watchdog.service.
[   13.542593] systemd-sysv-generator[657]: Ignoring S01motd symlink in rc5=
=2Ed, not generating motd.service.
[   13.542599] systemd-sysv-generator[657]: Ignoring S16rmnologin symlink i=
n rc5.d, not generating rmnologin.service.
[   13.542603] systemd-sysv-generator[657]: Ignoring S15cron symlink in rc5=
=2Ed, not generating cron.service.
[   13.542606] systemd-sysv-generator[657]: Ignoring S01mdadm symlink in rc=
5.d, not generating mdadm.service.
[   13.542610] systemd-sysv-generator[657]: Ignoring S15ipmievd symlink in =
rc5.d, not generating ipmievd.service.
[   13.542619] systemd-sysv-generator[657]: Ignoring S16rc.local symlink in=
 rc5.d, not generating rc.local.service.
[   13.542637] systemd-sysv-generator[657]: Ignoring K02ipmievd symlink in =
rc0.d, not generating ipmievd.service.
[   13.542643] systemd-sysv-generator[657]: Ignoring K09umountroot symlink =
in rc0.d, not generating umountroot.service.
[   13.542648] systemd-sysv-generator[657]: Ignoring K10mdadm-waitidle syml=
ink in rc0.d, not generating mdadm-waitidle.service.
[   13.542652] systemd-sysv-generator[657]: Ignoring K11halt symlink in rc0=
=2Ed, not generating halt.service.
[   13.542656] systemd-sysv-generator[657]: Ignoring K04sendsigs symlink in=
 rc0.d, not generating sendsigs.service.
[   13.542660] systemd-sysv-generator[657]: Ignoring K02mdadm symlink in rc=
0.d, not generating mdadm.service.
[   13.542664] systemd-sysv-generator[657]: Ignoring K08umountfs symlink in=
 rc0.d, not generating umountfs.service.
[   13.542670] systemd-sysv-generator[657]: Ignoring K05umountnfs.sh symlin=
k in rc0.d, not generating umountnfs.service.
[   13.542674] systemd-sysv-generator[657]: Ignoring K02urandom symlink in =
rc0.d, not generating urandom.service.
[   13.542690] systemd-sysv-generator[657]: Ignoring K07hwclock.sh symlink =
in rc0.d, not generating hwclock.service.
[   13.542695] systemd-sysv-generator[657]: Ignoring K01watchdog symlink in=
 rc0.d, not generating watchdog.service.
[   13.542714] systemd-sysv-generator[657]: Ignoring K02ipmievd symlink in =
rc6.d, not generating ipmievd.service.
[   13.542720] systemd-sysv-generator[657]: Ignoring K09umountroot symlink =
in rc6.d, not generating umountroot.service.
[   13.542726] systemd-sysv-generator[657]: Ignoring K10mdadm-waitidle syml=
ink in rc6.d, not generating mdadm-waitidle.service.
[   13.542731] systemd-sysv-generator[657]: Ignoring K04sendsigs symlink in=
 rc6.d, not generating sendsigs.service.
[   13.542734] systemd-sysv-generator[657]: Ignoring K12reboot symlink in r=
c6.d, not generating reboot.service.
[   13.542738] systemd-sysv-generator[657]: Ignoring K02mdadm symlink in rc=
6.d, not generating mdadm.service.
[   13.542742] systemd-sysv-generator[657]: Ignoring K08umountfs symlink in=
 rc6.d, not generating umountfs.service.
[   13.542749] systemd-sysv-generator[657]: Ignoring K05umountnfs.sh symlin=
k in rc6.d, not generating umountnfs.service.
[   13.542753] systemd-sysv-generator[657]: Ignoring K02urandom symlink in =
rc6.d, not generating urandom.service.
[   13.542758] systemd-sysv-generator[657]: Ignoring K07hwclock.sh symlink =
in rc6.d, not generating hwclock.service.
[   13.542765] systemd-sysv-generator[657]: Ignoring K01watchdog symlink in=
 rc6.d, not generating watchdog.service.
[   24.761883] systemd-modules-load[665]: apply: /etc/modules-load.d/module=
s.conf
[   24.764231] systemd-journald[670]: Fixed max_use=3D4.0G max_size=3D128.0=
M min_size=3D4.0M keep_free=3D4.0G
[   24.766463] systemd-journald[670]: Reserving 233016 entries in hash tabl=
e.
[   24.769568] systemd-journald[670]: Vacuuming...
[   24.769589] systemd-journald[670]: Vacuuming done, freed 0 bytes
[   24.769826] systemd-journald[670]: Flushing /dev/kmsg...
[   24.771558] systemd-journald[670]: Compressed data object 878 -> 592
[   24.782834] systemd-journald[670]: Compressed data object 885 -> 596
[   24.841496] systemd-journald[670]: systemd-journald running as pid 670
[   24.895583] systemd-udevd[682]: starting version 215
[   24.971505] systemd-journald[670]: Received request to flush runtime jou=
rnal from PID 1
[   24.980708] systemd-journald[670]: Vacuuming...
[   24.985805] systemd-journald[670]: Vacuuming done, freed 0 bytes

=3D=3D> /tmp/stdout <=3D=3D

=3D=3D> /tmp/stderr <=3D=3D
LKP: HOSTNAME lkp-hsw-ep2, MAC 00:1e:67:dc:1e:b1, kernel 4.4.0-rc3-00025-gc=
b8d058 1, serial console /dev/ttyS0

=3D=3D> /tmp/stdout <=3D=3D
Kernel te
[   25.046108] ipmi message handler version 39.2
sts: Boot OK!
[   25.053284] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   25.053478] IPMI System Interface driver.
[   25.053545] ipmi_si: probing via SMBIOS
[   25.053546] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[   25.053548] ipmi_si: Adding SMBIOS-specified kcs state machine
[   25.053550] ipmi_si: probing via SPMI
[   25.053551] ipmi_si: SPMI: io 0xca2 regsize 1 spacing 1 irq 0
[   25.053552] ipmi_si: Adding SPMI-specified kcs state machine duplicate i=
nterface
[   25.053553] ipmi_si: Trying SMBIOS-specified kcs state machine at i/o ad=
dress 0xca2, slave address 0x20, irq 0
[   25.055796] power_meter ACPI000D:00: Found ACPI power meter.
[   25.055871] power_meter ACPI000D:00: Ignoring unsafe software power cap!
[   25.056161] wmi: Mapper loaded
[   25.130376] ipmi device interface
[   25.130380] EDAC MC: Ver: 3.0.0
[   25.137968] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   25.146338] EDAC sbridge: Seeking for: PCI ID 8086:2fa0
[   25.146345] EDAC sbridge: Seeking for: PCI ID 8086:2fa0
[   25.146351] EDAC sbridge: Seeking for: PCI ID 8086:2fa0
[   25.146358] EDAC sbridge: Seeking for: PCI ID 8086:2ffc
[   25.146361] EDAC sbridge: Seeking for: PCI ID 8086:2ffc
[   25.146366] EDAC sbridge: Seeking for: PCI ID 8086:2ffc
[   25.146370] EDAC sbridge: Seeking for: PCI ID 8086:2ffd
[   25.146373] EDAC sbridge: Seeking for: PCI ID 8086:2ffd
[   25.146378] EDAC sbridge: Seeking for: PCI ID 8086:2ffd
[   25.146381] EDAC sbridge: Seeking for: PCI ID 8086:2f60
[   25.146384] EDAC sbridge: Seeking for: PCI ID 8086:2f60
[   25.146389] EDAC sbridge: Seeking for: PCI ID 8086:2f60
[   25.146392] EDAC sbridge: Seeking for: PCI ID 8086:2fa8
[   25.146395] EDAC sbridge: Seeking for: PCI ID 8086:2fa8
[   25.146400] EDAC sbridge: Seeking for: PCI ID 8086:2fa8
[   25.146403] EDAC sbridge: Seeking for: PCI ID 8086:2f71
[   25.146407] EDAC sbridge: Seeking for: PCI ID 8086:2f71
[   25.146411] EDAC sbridge: Seeking for: PCI ID 8086:2f71
[   25.146414] EDAC sbridge: Seeking for: PCI ID 8086:2faa
[   25.146418] EDAC sbridge: Seeking for: PCI ID 8086:2faa
[   25.146422] EDAC sbridge: Seeking for: PCI ID 8086:2faa
[   25.146426] EDAC sbridge: Seeking for: PCI ID 8086:2fab
[   25.146429] EDAC sbridge: Seeking for: PCI ID 8086:2fab
[   25.146433] EDAC sbridge: Seeking for: PCI ID 8086:2fab
[   25.146438] EDAC sbridge: Seeking for: PCI ID 8086:2fac
[   25.146447] EDAC sbridge: Seeking for: PCI ID 8086:2fad
[   25.146455] EDAC sbridge: Seeking for: PCI ID 8086:2fbd
[   25.146458] EDAC sbridge: Seeking for: PCI ID 8086:2fbd
[   25.146463] EDAC sbridge: Seeking for: PCI ID 8086:2fbd
[   25.146466] EDAC sbridge: Seeking for: PCI ID 8086:2fbf
[   25.146469] EDAC sbridge: Seeking for: PCI ID 8086:2fbf
[   25.146474] EDAC sbridge: Seeking for: PCI ID 8086:2fbf
[   25.146477] EDAC sbridge: Seeking for: PCI ID 8086:2fb9
[   25.146481] EDAC sbridge: Seeking for: PCI ID 8086:2fb9
[   25.146486] EDAC sbridge: Seeking for: PCI ID 8086:2fb9
[   25.146488] EDAC sbridge: Seeking for: PCI ID 8086:2fbb
[   25.146492] EDAC sbridge: Seeking for: PCI ID 8086:2fbb
[   25.146497] EDAC sbridge: Seeking for: PCI ID 8086:2fbb
[   25.146499] EDAC sbridge: Seeking for: PCI ID 8086:2f68
[   25.146503] EDAC sbridge: Seeking for: PCI ID 8086:2f68
[   25.146507] EDAC sbridge: Seeking for: PCI ID 8086:2f68
[   25.146510] EDAC sbridge: Seeking for: PCI ID 8086:2f79
[   25.146514] EDAC sbridge: Seeking for: PCI ID 8086:2f79
[   25.146518] EDAC sbridge: Seeking for: PCI ID 8086:2f79
[   25.146521] EDAC sbridge: Seeking for: PCI ID 8086:2f6a
[   25.146525] EDAC sbridge: Seeking for: PCI ID 8086:2f6a
[   25.146529] EDAC sbridge: Seeking for: PCI ID 8086:2f6a
[   25.146532] EDAC sbridge: Seeking for: PCI ID 8086:2f6b
[   25.146539] EDAC sbridge: Seeking for: PCI ID 8086:2f6b
[   25.146543] EDAC sbridge: Seeking for: PCI ID 8086:2f6b
[   25.146546] EDAC sbridge: Seeking for: PCI ID 8086:2f6c
[   25.146553] EDAC sbridge: Seeking for: PCI ID 8086:2f6d
[   25.146729] libata version 3.00 loaded.
[   25.146833] EDAC MC0: Giving out device to module sbridge_edac.c control=
ler Haswell Socket#0: DEV 0000:ff:12.0 (POLLED)
[   25.147146] EDAC MC1: Giving out device to module sbridge_edac.c control=
ler Haswell Socket#1: DEV 0000:7f:12.0 (POLLED)
[   25.147146] EDAC sbridge:  Ver: 1.1.1=20
[   25.171350] ipmi_si ipmi_si.0: Found new BMC (man_id: 0x000157, prod_id:=
 0x006f, dev_id: 0x21)
[   25.171360] ipmi_si ipmi_si.0: IPMI kcs interface initialized
[   25.368757] IOAPIC[0]: Set routing entry (8-16 -> 0x47 -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[   25.368761] ahci 0000:00:11.4: version 3.0
[   25.368988] ahci 0000:00:11.4: AHCI 0001.0300 32 slots 4 ports 6 Gbps 0x=
f impl SATA mode
[   25.368990] ahci 0000:00:11.4: flags: 64bit ncq led clo pio slum part em=
s apst=20
[   25.375369] scsi host0: ahci
[   25.375562] scsi host1: ahci
[   25.375691] scsi host2: ahci
[   25.375823] scsi host3: ahci
[   25.375865] ata1: SATA max UDMA/133 abar m2048@0x91d00000 port 0x91d0010=
0 irq 30
[   25.375866] ata2: SATA max UDMA/133 abar m2048@0x91d00000 port 0x91d0018=
0 irq 30
[   25.375869] ata3: SATA max UDMA/133 abar m2048@0x91d00000 port 0x91d0020=
0 irq 30
[   25.375872] ata4: SATA max UDMA/133 abar m2048@0x91d00000 port 0x91d0028=
0 irq 30
[   25.375989] IOAPIC[0]: Set routing entry (8-16 -> 0x67 -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[   25.376200] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x=
3f impl SATA mode
[   25.376202] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part em=
s apst=20
[   25.386769] scsi host4: ahci
[   25.386891] scsi host5: ahci
[   25.386995] scsi host6: ahci
[   25.387103] scsi host7: ahci
[   25.387197] scsi host8: ahci
[   25.387282] scsi host9: ahci
[   25.387322] ata5: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d0410=
0 irq 159
[   25.387323] ata6: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d0418=
0 irq 159
[   25.387326] ata7: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d0420=
0 irq 159
[   25.387328] ata8: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d0428=
0 irq 159
[   25.387330] ata9: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d0430=
0 irq 159
[   25.387332] ata10: SATA max UDMA/133 abar m2048@0x91d04000 port 0x91d043=
80 irq 159
[   25.466517] Error: Driver 'pcspkr' is already registered, aborting...
[   25.654732] AVX2 version of gcm_enc/dec engaged.
[   25.654732] AES CTR mode by8 optimization enabled
[   25.655045] [drm] Initialized drm 1.1.0 20060810
[   25.680813] ata2: SATA link down (SStatus 0 SControl 300)
[   25.682811] ata1: SATA link down (SStatus 0 SControl 300)
[   25.682842] ata4: SATA link down (SStatus 0 SControl 300)
[   25.682871] ata3: SATA link down (SStatus 0 SControl 300)
[   25.691804] ata7: SATA link down (SStatus 0 SControl 300)
[   25.691827] ata8: SATA link down (SStatus 0 SControl 300)
[   25.691852] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[   25.691876] ata9: SATA link down (SStatus 0 SControl 300)
[   25.691902] ata10: SATA link down (SStatus 0 SControl 300)
[   25.691924] ata6: SATA link down (SStatus 0 SControl 300)
[   25.692604] ata5.00: ATA-9: ST1000NM0033-9ZM173, SN04, max UDMA/133
[   25.692606] ata5.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32=
), AA
[   25.693507] ata5.00: configured for UDMA/133
[   25.693901] scsi 4:0:0:0: Direct-Access     ATA      ST1000NM0033-9ZM SN=
04 PQ: 0 ANSI: 5
[   25.784606] sd 4:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 =
TB/931 GiB)
[   25.793217] sd 4:0:0:0: [sda] Write Protect is off
[   25.793221] sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   25.793229] sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   25.812052] sd 4:0:0:0: [sda] Attached SCSI disk
[   25.857094] sd 4:0:0:0: Attached scsi generic sg0 type 0
[   25.877961] IOAPIC[0]: Set routing entry (8-16 -> 0x87 -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[   25.895698] [TTM] Zone  kernel: Available graphics memory: 65958872 kiB
[   25.903157] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[   25.910478] [TTM] Initializing pool allocator
[   25.915374] [TTM] Initializing DMA pool allocator
[   25.955479] random: nonblocking pool is initialized
[   26.013663] [drm:drm_edid_block_valid [drm]] *ERROR* EDID checksum is in=
valid, remainder is 130
[   26.023390] Raw EDID:
[   26.025940]  	00 ff ff ff ff ff ff 00 ff ff ff ff ff ff ff ff
[   26.032367]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.038796]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.045222]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.051648]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.058072]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.064499]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.070924]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.131347] [drm:drm_edid_block_valid [drm]] *ERROR* EDID checksum is in=
valid, remainder is 130
[   26.141069] Raw EDID:
[   26.143605]  	00 ff ff ff ff ff ff 00 ff ff ff ff ff ff ff ff
[   26.150023]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.156447]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.162862]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.169276]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.175699]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.182123]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.188548]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.248944] [drm:drm_edid_block_valid [drm]] *ERROR* EDID checksum is in=
valid, remainder is 130
[   26.258665] Raw EDID:
[   26.261203]  	00 ff ff ff ff ff ff 00 ff ff ff ff ff ff ff ff
[   26.267616]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.274030]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.280451]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.286866]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.293289]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.299710]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.306132]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.366495] [drm:drm_edid_block_valid [drm]] *ERROR* EDID checksum is in=
valid, remainder is 130
[   26.376217] Raw EDID:
[   26.378760]  	00 ff ff ff ff ff ff 00 ff ff ff ff ff ff ff ff
[   26.385174]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.391595]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.398017]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.404439]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.410854]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.417277]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.423701]  	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   26.430125] mgag200 0000:07:00.0: VGA-1: EDID block 0 invalid.
[   26.436843] fbcon: mgadrmfb (fb0) is primary device
[   26.436905] Console: switching to colour frame buffer device 128x48
[   26.687847] mgag200 0000:07:00.0: fb0: mgadrmfb frame buffer device
[   26.698856] [drm] Initialized mgag200 1.0.0 20110418 for 0000:07:00.0 on=
 minor 0
 7 Dec 16:41:43 ntpdate[996]: step time server 192.168.1.1 offset 54286.715=
611 sec
[   31.922514] netpoll: netconsole: local port 6665
[   31.927724] netpoll: netconsole: local IPv4 address 0.0.0.0
[   31.934003] netpoll: netconsole: interface 'eth0'
[   31.939287] netpoll: netconsole: remote port 6669
[   31.944580] netpoll: netconsole: remote IPv4 address 192.168.1.1
[   31.951331] netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:=
ff
[   31.959059] netpoll: netconsole: local IP 192.168.1.173
[=00   31.970305] cvodm4t-3.yaml
run-job /lkp/scheduled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_6=
4-rhel-cb8d05829190b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.ya=
ml
wget --local-encoding=3DUTF-8 --retry-connrefused --waitretry 1000 --tries =
1000 http://inn:80/~aaron/cgi-bin/lkp-jobfile-append-var?job_file=3D/lkp/sc=
heduled/lkp-hsw-ep2/vip_swap-performance-always-always-x86_64-rhel-cb8d0582=
9190b806ad3948ff9b9e08c8ba1daf63-20151207-55614-1vodm4t-3.yaml&job_state=3D=
running -q -O /dev/null
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu0/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu1/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu10/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu11/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu12/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu13/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu14/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu15/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu16/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu17/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu18/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu19/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu2/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu20/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu21/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu22/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu23/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu24/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu25/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu26/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu27/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu28/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu29/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu3/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu30/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu31/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu32/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu33/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu34/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu35/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu36/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu37/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu38/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu39/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu4/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu40/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu41/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu42/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu43/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu44/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu45/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu46/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu47/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu48/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu49/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu5/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu50/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu51/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu52/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu53/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu54/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu55/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu56/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu57/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu58/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu59/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu6/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu60/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu61/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu62/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu63/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu64/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu65/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu66/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu67/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu68/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu69/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu7/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu70/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu71/cpufre=
q/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu8/cpufreq=
/scaling_governor
2015-12-07 16:41:44 echo performance > /sys/devices/system/cpu/cpu9/cpufreq=
/scaling_governor
kernel.softlockup_panic =3D 0
[   56.142174] scsi_debug:sdebug_driver_probe: host protection
[   56.148763] scsi host10: scsi_debug, version 1.85 [20141022], dev_size_m=
b=3D102184, opts=3D0x0
[   56.158681] scsi 10:0:0:0: Direct-Access     Linux    scsi_debug       0=
184 PQ: 0 ANSI: 6
[   56.168364] sd 10:0:0:0: Attached scsi generic sg1 type 0
[   56.170079] sd 10:0:0:0: [sdb] 209272832 512-byte logical blocks: (107 G=
B/99.7 GiB)
[   56.171124] sd 10:0:0:0: [sdb] Write Protect is off
[   56.171126] sd 10:0:0:0: [sdb] Mode Sense: 73 00 10 08
[   56.173077] sd 10:0:0:0: [sdb] Write cache: enabled, read cache: enabled=
, supports DPO and FUA
[   56.194074] sd 10:0:0:0: [sdb] Attached SCSI disk
kernel.softlockup_panic =3D 1
Setting up swapspace version 1, size =3D 104636412 KiB
no label, UUID=3D865b7c44-a2c1-4970-8a58-53d57773ea23
[   56.290253] Adding 104636412k swap on /dev/sdb.  Priority:-1 extents:1 a=
cross:104636412k SSFS
[   58.080962] BUG: unable to handle kernel paging request at ffffea0082000=
018
[   58.089124] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   58.096109] PGD 107ffd6067 PUD 207f7d5067 PMD 0=20
[   58.101569] Oops: 0000 [#1] SMP=20
[   58.105460] Modules linked in: scsi_debug rpcsec_gss_krb5 auth_rpcgss nf=
sv4 dns_resolver netconsole x86_pkg_temp_thermal coretemp mgag200 ttm kvm_i=
ntel drm_kms_helper syscopyarea sysfillrect sysimgblt kvm fb_sys_fops irqby=
pass sg crct10dif_pclmul crc32_pclmul crc32c_intel sd_mod aesni_intel lrw g=
f128mul snd_pcm snd_timer ahci snd libahci soundcore sb_edac drm pcspkr ipm=
i_devintf glue_helper edac_core libata ablk_helper ipmi_si shpchp cryptd wm=
i ipmi_msghandler acpi_power_meter acpi_pad
[   58.155622] CPU: 61 PID: 1537 Comm: usemem Not tainted 4.4.0-rc3-00025-g=
cb8d058 #1
[   58.164425] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS SE5=
C610.86B.01.01.0008.021120151325 02/11/2015
[   58.176451] task: ffff882075d18000 ti: ffff882075a30000 task.ti: ffff882=
075a30000
[   58.185188] RIP: 0010:[<ffffffff81193f29>]  [<ffffffff81193f29>] compact=
ion_alloc+0xf9/0x270
[   58.195018] RSP: 0000:ffff882075a33940  EFLAGS: 00010286
[   58.201354] RAX: ffff88207ffdcd80 RBX: ffff882075a33ac0 RCX: ffff88207ff=
dcd80
[   58.209737] RDX: 0000000002080000 RSI: ffff882075a33ac0 RDI: ffff882075a=
33ac0
[   58.218127] RBP: ffff882075a33990 R08: ffffea0082000000 R09: 00000000000=
00000
[   58.226525] R10: 0000000000000000 R11: 000000000001ae88 R12: ffffea00820=
00000
[   58.234931] R13: ffffea0042060780 R14: 0000000002080000 R15: 00000000020=
80000
[   58.243336] FS:  00007ff48fb26700(0000) GS:ffff882034a40000(0000) knlGS:=
0000000000000000
[   58.252822] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   58.259695] CR2: ffffea0082000018 CR3: 000000207cf1f000 CR4: 00000000001=
406e0
[   58.268134] Stack:
[   58.270852]  ffff882075a34000 0000000001081a00 ffffffff81193196 ffff8820=
7ffdcd80
[   58.279677]  0000000002080000 ffffea00420607c0 ffff882075a33ac0 ffffea00=
42060780
[   58.288559]  ffffea00420607e0 ffff88207ffdcd80 ffff882075a33a20 ffffffff=
811d092e
[   58.297397] Call Trace:
[   58.300641]  [<ffffffff81193196>] ? update_pageblock_skip+0x56/0xa0
[   58.308164]  [<ffffffff811d092e>] migrate_pages+0x28e/0x7b0
[   58.314911]  [<ffffffff811931e0>] ? update_pageblock_skip+0xa0/0xa0
[   58.322445]  [<ffffffff81193e30>] ? __pageblock_pfn_to_page+0xe0/0xe0
[   58.330179]  [<ffffffff8119552b>] compact_zone+0x3db/0x890
[   58.336847]  [<ffffffff81195a4d>] compact_zone_order+0x6d/0x90
[   58.343906]  [<ffffffff81174f44>] ? get_page_from_freelist+0xd4/0xa20
[   58.351649]  [<ffffffff81195cdc>] try_to_compact_pages+0xec/0x210
[   58.358989]  [<ffffffff811758cd>] __alloc_pages_direct_compact+0x3d/0x110
[   58.367113]  [<ffffffff81175f06>] __alloc_pages_nodemask+0x566/0xb40
[   58.374743]  [<ffffffff811c0271>] alloc_pages_vma+0x1d1/0x230
[   58.381688]  [<ffffffff811d5d27>] do_huge_pmd_anonymous_page+0x107/0x3f0
[   58.389700]  [<ffffffff8119ecda>] handle_mm_fault+0x178a/0x1940
[   58.396838]  [<ffffffff81063c4d>] __do_page_fault+0x1ad/0x410
[   58.403779]  [<ffffffff81063edf>] do_page_fault+0x2f/0x80
[   58.410324]  [<ffffffff818c7fc8>] page_fault+0x28/0x30
[   58.416576] Code: 90 00 00 00 48 8b 45 c8 4d 89 e0 83 b8 50 05 00 00 01 =
74 12 48 8b 55 c8 4c 89 f6 4c 89 ff e8 2f fe ff ff 49 89 c0 4d 85 c0 74 47 =
<41> 8b 40 18 83 f8 80 75 0a 49 8b 40 30 48 83 f8 08 77 34 48 b8=20
[   58.439542] RIP  [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   58.446894]  RSP <ffff882075a33940>
[   58.451324] CR2: ffffea0082000018
[   58.455548] ---[ end trace bb8db33be33beba8 ]---
[   58.463022] Kernel panic - not syncing: Fatal exception
[   58.469513] Kernel Offset: disabled
ACPI MEMORY or I/O RESET_REG.

--FCuugMFkClbJLl1L--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
