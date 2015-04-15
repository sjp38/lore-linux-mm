Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1A66B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 09:16:01 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so14902865vnb.5
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:16:00 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id zr4si2899889obc.42.2015.04.15.06.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 06:16:00 -0700 (PDT)
Message-ID: <552E6486.6070705@hp.com>
Date: Wed, 15 Apr 2015 09:15:50 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Content-Type: multipart/mixed;
 boundary="------------020105070300010700010500"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------020105070300010700010500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 04/13/2015 06:16 AM, Mel Gorman wrote:
> Memory initialisation had been identified as one of the reasons why large
> machines take a long time to boot. Patches were posted a long time ago
> that attempted to move deferred initialisation into the page allocator
> paths. This was rejected on the grounds it should not be necessary to hurt
> the fast paths to parallelise initialisation. This series reuses much of
> the work from that time but defers the initialisation of memory to kswapd
> so that one thread per node initialises memory local to that node. The
> issue is that on the machines I tested with, memory initialisation was not
> a major contributor to boot times. I'm posting the RFC to both review the
> series and see if it actually helps users of very large machines.
>
> After applying the series and setting the appropriate Kconfig variable I
> see this in the boot log on a 64G machine
>
> [    7.383764] kswapd 0 initialised deferred memory in 188ms
> [    7.404253] kswapd 1 initialised deferred memory in 208ms
> [    7.411044] kswapd 3 initialised deferred memory in 216ms
> [    7.411551] kswapd 2 initialised deferred memory in 216ms
>
> On a 1TB machine, I see
>
> [   11.913324] kswapd 0 initialised deferred memory in 1168ms
> [   12.220011] kswapd 2 initialised deferred memory in 1476ms
> [   12.245369] kswapd 3 initialised deferred memory in 1500ms
> [   12.271680] kswapd 1 initialised deferred memory in 1528ms
>
> Once booted the machine appears to work as normal. Boot times were measured
> from the time shutdown was called until ssh was available again.  In the
> 64G case, the boot time savings are negligible. On the 1TB machine, the
> savings were 10 seconds (about 8% improvement on kernel times but 1-2%
> overall as POST takes so long).
>
> It would be nice if the people that have access to really large machines
> would test this series and report back if the complexity is justified.
>
> Patches are against 4.0-rc7.
>
>   Documentation/kernel-parameters.txt |   8 +
>   arch/ia64/mm/numa.c                 |  19 +-
>   arch/x86/Kconfig                    |   2 +
>   include/linux/memblock.h            |  18 ++
>   include/linux/mm.h                  |   8 +-
>   include/linux/mmzone.h              |  37 +++-
>   init/main.c                         |   1 +
>   mm/Kconfig                          |  29 +++
>   mm/bootmem.c                        |   6 +-
>   mm/internal.h                       |  23 ++-
>   mm/memblock.c                       |  34 ++-
>   mm/mm_init.c                        |   9 +-
>   mm/nobootmem.c                      |   7 +-
>   mm/page_alloc.c                     | 398 +++++++++++++++++++++++++++++++-----
>   mm/vmscan.c                         |   6 +-
>   15 files changed, 507 insertions(+), 98 deletions(-)
>

I had included your patch with the 4.0 kernel and booted up a 16-socket 
12-TB machine. I measured the elapsed time from the elilo prompt to the 
availability of ssh login. Without the patch, the bootup time was 404s. 
It was reduced to 298s with the patch. So there was about 100s reduction 
in bootup time (1/4 of the total).

However, there were 2 bootup problems in the dmesg log that needed to be 
addressed.
1. There were 2 vmalloc allocation failures:
[    2.284686] vmalloc: allocation failure, allocated 16578404352 of 
17179873280 bytes
[   10.399938] vmalloc: allocation failure, allocated 7970922496 of 
8589938688 bytes

2. There were 2 soft lockup warnings:
[   57.319453] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! 
[swapper/0:1]
[   85.409263] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! 
[swapper/0:1]

Once those problems are fixed, the patch should be in a pretty good 
shape. I have attached the dmesg log for your reference.

Cheers,
Longman

--------------020105070300010700010500
Content-Type: text/plain;
 name="dmesg-4.0-Mel-mm-patch.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg-4.0-Mel-mm-patch.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp (root@hawk041os1) (gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux) ) #1 SMP Tue Apr 14 17:38:39 MDT 2015
[    0.000000] Command line: BOOT_IMAGE=dev000:\efi\SuSE\vmlinuz-4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp root=/dev/disk/by-id/scsi-3600c0ff0001a841e1d12f65401000000-part3  noresume resume=/dev/disk/by-id/scsi-3600c0ff0001a841e1d12f65401000000-part2 splash=silent crashkernel=1536M-:768M showopts intel_idle.max_cstate=1 selinux=0 console=ttyS0,115200
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000008dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000008e000-0x000000000008ffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000090000-0x000000000009ffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000006d00bfff] usable
[    0.000000] BIOS-e820: [mem 0x000000006d00c000-0x000000006d017fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000006d018000-0x000000006f3fbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000006f3fc000-0x000000006f3fefff] reserved
[    0.000000] BIOS-e820: [mem 0x000000006f3ff000-0x0000000078bfefff] usable
[    0.000000] BIOS-e820: [mem 0x0000000078bff000-0x00000000790fefff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000790ff000-0x00000000798fefff] unusable
[    0.000000] BIOS-e820: [mem 0x00000000798ff000-0x00000000799fefff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000799ff000-0x000000007bdfefff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007bdff000-0x000000007bffefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bfff000-0x000000007bffffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000080000000-0x000000008fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ff1fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000100000fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x0000000100001000-0x000000c07fffffff] usable
[    0.000000] BIOS-e820: [mem 0x000000e000000000-0x000000e000000fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000e000001000-0x00000c1fffffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000fdfe0000000-0x00000fdfffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe060000000-0x00000fe07fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe0e0000000-0x00000fe0ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe160000000-0x00000fe17fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe1e0000000-0x00000fe1ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe260000000-0x00000fe27fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe2e0000000-0x00000fe2ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe360000000-0x00000fe37fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe3e0000000-0x00000fe3ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe460000000-0x00000fe47fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe4e0000000-0x00000fe4ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe560000000-0x00000fe57fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe5e0000000-0x00000fe5ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe660000000-0x00000fe67fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe6e0000000-0x00000fe6ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe760000000-0x00000fe77fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000fe7e0000000-0x00000fe7ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] efi: EFI v2.31 by HP
[    0.000000] efi:  ACPI=0x7bffe000  ACPI 2.0=0x7bffe014  SMBIOS=0x799f8000 
[    0.000000] efi: mem00: [Boot Code          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000000000-0x0000000000001000) (0MB)
[    0.000000] efi: mem01: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000001000-0x000000000008e000) (0MB)
[    0.000000] efi: mem02: [Reserved           |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000000008e000-0x0000000000090000) (0MB)
[    0.000000] efi: mem03: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000090000-0x00000000000a0000) (0MB)
[    0.000000] efi: mem04: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000100000-0x0000000000900000) (8MB)
[    0.000000] efi: mem05: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000900000-0x000000005c800000) (1471MB)
[    0.000000] efi: mem06: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000005c800000-0x000000005cc00000) (4MB)
[    0.000000] efi: mem07: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000005cc00000-0x000000006b30a000) (231MB)
[    0.000000] efi: mem08: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006b30a000-0x000000006d00c000) (29MB)
[    0.000000] efi: mem09: [Reserved           |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006d00c000-0x000000006d018000) (0MB)
[    0.000000] efi: mem10: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006d018000-0x000000006f3fc000) (35MB)
[    0.000000] efi: mem11: [Reserved           |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006f3fc000-0x000000006f3ff000) (0MB)
[    0.000000] efi: mem12: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006f3ff000-0x0000000072496000) (48MB)
[    0.000000] efi: mem13: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000072496000-0x00000000729d3000) (5MB)
[    0.000000] efi: mem14: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729d3000-0x00000000729e2000) (0MB)
[    0.000000] efi: mem15: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729e2000-0x00000000729e5000) (0MB)
[    0.000000] efi: mem16: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729e5000-0x00000000729e6000) (0MB)
[    0.000000] efi: mem17: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729e6000-0x00000000729f2000) (0MB)
[    0.000000] efi: mem18: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729f2000-0x00000000729f3000) (0MB)
[    0.000000] efi: mem19: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000729f3000-0x0000000073221000) (8MB)
[    0.000000] efi: mem20: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073221000-0x0000000073223000) (0MB)
[    0.000000] efi: mem21: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073223000-0x0000000073e72000) (12MB)
[    0.000000] efi: mem22: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073e72000-0x0000000073eb3000) (0MB)
[    0.000000] efi: mem23: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073eb3000-0x0000000073ee2000) (0MB)
[    0.000000] efi: mem24: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073ee2000-0x0000000073efc000) (0MB)
[    0.000000] efi: mem25: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073efc000-0x0000000073f23000) (0MB)
[    0.000000] efi: mem26: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f23000-0x0000000073f2f000) (0MB)
[    0.000000] efi: mem27: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f2f000-0x0000000073f30000) (0MB)
[    0.000000] efi: mem28: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f30000-0x0000000073f33000) (0MB)
[    0.000000] efi: mem29: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f33000-0x0000000073f52000) (0MB)
[    0.000000] efi: mem30: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f52000-0x0000000073f6a000) (0MB)
[    0.000000] efi: mem31: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000073f6a000-0x000000007415a000) (1MB)
[    0.000000] efi: mem32: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000007415a000-0x000000007416e000) (0MB)
[    0.000000] efi: mem33: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000007416e000-0x00000000773ff000) (50MB)
[    0.000000] efi: mem34: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000773ff000-0x00000000777e1000) (3MB)
[    0.000000] efi: mem35: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000777e1000-0x00000000777ff000) (0MB)
[    0.000000] efi: mem36: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000777ff000-0x0000000077bbf000) (3MB)
[    0.000000] efi: mem37: [Loader Code        |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000077bbf000-0x0000000077bff000) (0MB)
[    0.000000] efi: mem38: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000077bff000-0x000000007823c000) (6MB)
[    0.000000] efi: mem39: [Boot Code          |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000007823c000-0x0000000078bff000) (9MB)
[    0.000000] efi: mem40: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000078bff000-0x00000000790ff000) (5MB)
[    0.000000] efi: mem41: [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x00000000790ff000-0x00000000798ff000) (8MB)
[    0.000000] efi: mem42: [Reserved           |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000798ff000-0x00000000799ff000) (1MB)
[    0.000000] efi: mem43: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000799ff000-0x000000007bdff000) (36MB)
[    0.000000] efi: mem44: [ACPI Reclaim Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000007bdff000-0x000000007bfff000) (2MB)
[    0.000000] efi: mem45: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000007bfff000-0x000000007c000000) (0MB)
[    0.000000] efi: mem46: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000100000000-0x0000000100001000) (0MB)
[    0.000000] efi: mem47: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000100001000-0x000000c080000000) (784383MB)
[    0.000000] efi: mem48: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000e000000000-0x000000e000001000) (0MB)
[    0.000000] efi: mem49: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000e000001000-0x00000c2000000000) (11796479MB)
[    0.000000] efi: mem50: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x0000000080000000-0x0000000090000000) (256MB)
[    0.000000] efi: mem51: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000000fed1c000-0x00000000fed20000) (0MB)
[    0.000000] efi: mem52: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000000ff000000-0x00000000ff200000) (2MB)
[    0.000000] efi: mem53: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fdfe0000000-0x00000fe000000000) (512MB)
[    0.000000] efi: mem54: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe060000000-0x00000fe080000000) (512MB)
[    0.000000] efi: mem55: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe0e0000000-0x00000fe100000000) (512MB)
[    0.000000] efi: mem56: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe160000000-0x00000fe180000000) (512MB)
[    0.000000] efi: mem57: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe1e0000000-0x00000fe200000000) (512MB)
[    0.000000] efi: mem58: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe260000000-0x00000fe280000000) (512MB)
[    0.000000] efi: mem59: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe2e0000000-0x00000fe300000000) (512MB)
[    0.000000] efi: mem60: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe360000000-0x00000fe380000000) (512MB)
[    0.000000] efi: mem61: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe3e0000000-0x00000fe400000000) (512MB)
[    0.000000] efi: mem62: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe460000000-0x00000fe480000000) (512MB)
[    0.000000] efi: mem63: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe4e0000000-0x00000fe500000000) (512MB)
[    0.000000] efi: mem64: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe560000000-0x00000fe580000000) (512MB)
[    0.000000] efi: mem65: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe5e0000000-0x00000fe600000000) (512MB)
[    0.000000] efi: mem66: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe660000000-0x00000fe680000000) (512MB)
[    0.000000] efi: mem67: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe6e0000000-0x00000fe700000000) (512MB)
[    0.000000] efi: mem68: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe760000000-0x00000fe780000000) (512MB)
[    0.000000] efi: mem69: [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC] range=[0x00000fe7e0000000-0x00000fe800000000) (512MB)
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn = 0xc2000000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   1 base 0F0000000000 mask 3F8000000000 uncachable
[    0.000000]   2 base 0F8000000000 mask 3FC000000000 uncachable
[    0.000000]   3 base 0FC000000000 mask 3FE000000000 uncachable
[    0.000000]   4 base 0FE000000000 mask 3FF000000000 uncachable
[    0.000000]   5 base 0000FF000000 mask 3FFFFFE00000 uncachable
[    0.000000]   6 base 0FDF80000000 mask 3FFF80000000 uncachable
[    0.000000]   7 base 0FE000000000 mask 3FF800000000 uncachable
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
[    0.000000] x2apic: enabled by BIOS, switching to x2apic ops
[    0.000000] e820: last_pfn = 0x7c000 max_arch_pfn = 0x400000000
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 28672
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01e1f000, 0x01e1ffff] PGTABLE
[    0.000000] BRK [0x01e20000, 0x01e20fff] PGTABLE
[    0.000000] BRK [0x01e21000, 0x01e21fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xc1fffe00000-0xc1fffffffff]
[    0.000000]  [mem 0xc1fffe00000-0xc1fffffffff] page 1G
[    0.000000] BRK [0x01e22000, 0x01e22fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xc1fe0000000-0xc1fffdfffff]
[    0.000000]  [mem 0xc1fe0000000-0xc1fffdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0xc0000000000-0xc1fdfffffff]
[    0.000000]  [mem 0xc0000000000-0xc1fdfffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0x6d00bfff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x6cffffff] page 2M
[    0.000000]  [mem 0x6d000000-0x6d00bfff] page 4k
[    0.000000] init_memory_mapping: [mem 0x6d018000-0x6f3fbfff]
[    0.000000]  [mem 0x6d018000-0x6d1fffff] page 4k
[    0.000000]  [mem 0x6d200000-0x6f1fffff] page 2M
[    0.000000]  [mem 0x6f200000-0x6f3fbfff] page 4k
[    0.000000] BRK [0x01e23000, 0x01e23fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x6f3ff000-0x78bfefff]
[    0.000000]  [mem 0x6f3ff000-0x6f3fffff] page 4k
[    0.000000]  [mem 0x6f400000-0x789fffff] page 2M
[    0.000000]  [mem 0x78a00000-0x78bfefff] page 4k
[    0.000000] BRK [0x01e24000, 0x01e24fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x7bfff000-0x7bffffff]
[    0.000000]  [mem 0x7bfff000-0x7bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100001000-0xc07fffffff]
[    0.000000]  [mem 0x100001000-0x1001fffff] page 4k
[    0.000000]  [mem 0x100200000-0x13fffffff] page 2M
[    0.000000]  [mem 0x140000000-0xc07fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0xe000001000-0xbffffffffff]
[    0.000000]  [mem 0xe000001000-0xe0001fffff] page 4k
[    0.000000]  [mem 0xe000200000-0xe03fffffff] page 2M
[    0.000000]  [mem 0xe040000000-0xbffffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x6b30a000-0x6d00bfff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000007BFFE014 000024 (v02 HP    )
[    0.000000] ACPI: XSDT 0x000000007BF18188 0000DC (v01 HP     03010201 00000002 MSFT 01000013)
[    0.000000] ACPI: FACP 0x000000007BFFB000 00010C (v05 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: DSDT 0x000000007BFEC000 000814 (v02 HP     CORE     00000002 HPAG 00020000)
[    0.000000] ACPI: FACS 0x000000007BDF1000 000040
[    0.000000] ACPI: MCEJ 0x000000007BFFC000 000130 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: HPET 0x000000007BFFA000 000038 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: MCFG 0x000000007BFF9000 00003C (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: SLIT 0x000000007BFF8000 00012C (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: APIC 0x000000007BFF4000 0035E0 (v03 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: SRAT 0x000000007BFF1000 002FD8 (v02 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: SPMI 0x000000007BFF0000 000040 (v05 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: SPCR 0x000000007BFEF000 000050 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: DBGP 0x000000007BFEE000 000034 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: RASF 0x000000007BFED000 000030 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BFD2000 019FB9 (v02 HP     BLADE000 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BFB8000 0196F0 (v02 HP     BLADE001 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF9E000 0196D9 (v02 HP     BLADE002 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF84000 0196D9 (v02 HP     BLADE003 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF6A000 0196D9 (v02 HP     BLADE004 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF50000 0196D9 (v02 HP     BLADE005 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF36000 0196D9 (v02 HP     BLADE006 00000002 HPAG 00020000)
[    0.000000] ACPI: SSDT 0x000000007BF1C000 0196D9 (v02 HP     BLADE007 00000002 HPAG 00020000)
[    0.000000] ACPI: DMAR 0x000000007BF1A000 000CF8 (v01 HP     03010201 00000002 HPAG 00020000)
[    0.000000] ACPI: HEST 0x000000007BF19000 000184 (v01 INTEL           00000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000007BFFD000 000030 (v01 INTEL           00000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000007BF17000 000150 (v01 INTEL           00000001 INTL 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] System requires x2apic physical mode
[    0.000000] Setting APIC routing to physical x2apic.
[    0.000000] SRAT: PXM 0 -> APIC 0x0000 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0001 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0002 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0003 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0004 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0005 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0006 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0007 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0008 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0009 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000e -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x000f -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0010 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0011 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0012 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0013 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0014 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0015 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0016 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0017 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0018 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0019 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x001a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x001b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x001c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x001d -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x0020 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0021 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0022 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0023 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0024 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0025 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0026 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0027 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0028 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0029 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002e -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x002f -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0030 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0031 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0032 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0033 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0034 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0035 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0036 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0037 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0038 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x0039 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x003a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x003b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x003c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x003d -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x0040 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0041 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0042 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0043 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0044 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0045 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0046 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0047 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0048 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0049 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004c -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004d -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004e -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x004f -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0050 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0051 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0052 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0053 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0054 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0055 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0056 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0057 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0058 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x0059 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x005a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x005b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x005c -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x005d -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x0060 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0061 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0062 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0063 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0064 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0065 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0066 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0067 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0068 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0069 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006c -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006d -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006e -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x006f -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0070 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0071 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0072 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0073 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0074 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0075 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0076 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0077 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0078 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x0079 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x007a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x007b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x007c -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x007d -> Node 3
[    0.000000] SRAT: PXM 4 -> APIC 0x0080 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0081 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0082 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0083 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0084 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0085 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0086 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0087 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0088 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0089 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008a -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008b -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008c -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008d -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008e -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x008f -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0090 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0091 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0092 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0093 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0094 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0095 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0096 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0097 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0098 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x0099 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x009a -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x009b -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x009c -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 0x009d -> Node 4
[    0.000000] SRAT: PXM 5 -> APIC 0x00a0 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a1 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a2 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a3 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a4 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a5 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a6 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a7 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a8 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00a9 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00aa -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00ab -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00ac -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00ad -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00ae -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00af -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b0 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b1 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b2 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b3 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b4 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b5 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b6 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b7 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b8 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00b9 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00ba -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00bb -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00bc -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 0x00bd -> Node 5
[    0.000000] SRAT: PXM 6 -> APIC 0x00c0 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c1 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c2 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c3 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c4 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c5 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c6 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c7 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c8 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00c9 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00ca -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00cb -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00cc -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00cd -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00ce -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00cf -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d0 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d1 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d2 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d3 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d4 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d5 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d6 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d7 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d8 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00d9 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00da -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00db -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00dc -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 0x00dd -> Node 6
[    0.000000] SRAT: PXM 7 -> APIC 0x00e0 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e1 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e2 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e3 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e4 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e5 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e6 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e7 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e8 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00e9 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00ea -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00eb -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00ec -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00ed -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00ee -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00ef -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f0 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f1 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f2 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f3 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f4 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f5 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f6 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f7 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f8 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00f9 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00fa -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00fb -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00fc -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 0x00fd -> Node 7
[    0.000000] SRAT: PXM 8 -> APIC 0x0100 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0101 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0102 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0103 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0104 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0105 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0106 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0107 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0108 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0109 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010a -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010b -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010c -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010d -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010e -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x010f -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0110 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0111 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0112 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0113 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0114 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0115 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0116 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0117 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0118 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x0119 -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x011a -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x011b -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x011c -> Node 8
[    0.000000] SRAT: PXM 8 -> APIC 0x011d -> Node 8
[    0.000000] SRAT: PXM 9 -> APIC 0x0120 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0121 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0122 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0123 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0124 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0125 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0126 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0127 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0128 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0129 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012a -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012b -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012c -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012d -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012e -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x012f -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0130 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0131 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0132 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0133 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0134 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0135 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0136 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0137 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0138 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x0139 -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x013a -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x013b -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x013c -> Node 9
[    0.000000] SRAT: PXM 9 -> APIC 0x013d -> Node 9
[    0.000000] SRAT: PXM 10 -> APIC 0x0140 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0141 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0142 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0143 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0144 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0145 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0146 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0147 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0148 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0149 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014a -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014b -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014c -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014d -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014e -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x014f -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0150 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0151 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0152 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0153 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0154 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0155 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0156 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0157 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0158 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x0159 -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x015a -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x015b -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x015c -> Node 10
[    0.000000] SRAT: PXM 10 -> APIC 0x015d -> Node 10
[    0.000000] SRAT: PXM 11 -> APIC 0x0160 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0161 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0162 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0163 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0164 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0165 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0166 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0167 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0168 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0169 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016a -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016b -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016c -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016d -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016e -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x016f -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0170 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0171 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0172 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0173 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0174 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0175 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0176 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0177 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0178 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x0179 -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x017a -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x017b -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x017c -> Node 11
[    0.000000] SRAT: PXM 11 -> APIC 0x017d -> Node 11
[    0.000000] SRAT: PXM 12 -> APIC 0x0180 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0181 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0182 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0183 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0184 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0185 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0186 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0187 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0188 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0189 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018a -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018b -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018c -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018d -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018e -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x018f -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0190 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0191 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0192 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0193 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0194 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0195 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0196 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0197 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0198 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x0199 -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x019a -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x019b -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x019c -> Node 12
[    0.000000] SRAT: PXM 12 -> APIC 0x019d -> Node 12
[    0.000000] SRAT: PXM 13 -> APIC 0x01a0 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a1 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a2 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a3 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a4 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a5 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a6 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a7 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a8 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01a9 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01aa -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01ab -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01ac -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01ad -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01ae -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01af -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b0 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b1 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b2 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b3 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b4 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b5 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b6 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b7 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b8 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01b9 -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01ba -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01bb -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01bc -> Node 13
[    0.000000] SRAT: PXM 13 -> APIC 0x01bd -> Node 13
[    0.000000] SRAT: PXM 14 -> APIC 0x01c0 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c1 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c2 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c3 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c4 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c5 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c6 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c7 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c8 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01c9 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01ca -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01cb -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01cc -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01cd -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01ce -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01cf -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d0 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d1 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d2 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d3 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d4 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d5 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d6 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d7 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d8 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01d9 -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01da -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01db -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01dc -> Node 14
[    0.000000] SRAT: PXM 14 -> APIC 0x01dd -> Node 14
[    0.000000] SRAT: PXM 15 -> APIC 0x01e0 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e1 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e2 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e3 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e4 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e5 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e6 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e7 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e8 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01e9 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01ea -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01eb -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01ec -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01ed -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01ee -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01ef -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f0 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f1 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f2 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f3 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f4 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f5 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f6 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f7 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f8 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01f9 -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01fa -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01fb -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01fc -> Node 15
[    0.000000] SRAT: PXM 15 -> APIC 0x01fd -> Node 15
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0xc07fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0xe000000000-0x19fffffffff]
[    0.000000] SRAT: Node 2 PXM 2 [mem 0x1a000000000-0x25fffffffff]
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x26000000000-0x31fffffffff]
[    0.000000] SRAT: Node 4 PXM 4 [mem 0x32000000000-0x3dfffffffff]
[    0.000000] SRAT: Node 5 PXM 5 [mem 0x3e000000000-0x49fffffffff]
[    0.000000] SRAT: Node 6 PXM 6 [mem 0x4a000000000-0x55fffffffff]
[    0.000000] SRAT: Node 7 PXM 7 [mem 0x56000000000-0x61fffffffff]
[    0.000000] SRAT: Node 8 PXM 8 [mem 0x62000000000-0x6dfffffffff]
[    0.000000] SRAT: Node 9 PXM 9 [mem 0x6e000000000-0x79fffffffff]
[    0.000000] SRAT: Node 10 PXM 10 [mem 0x7a000000000-0x85fffffffff]
[    0.000000] SRAT: Node 11 PXM 11 [mem 0x86000000000-0x91fffffffff]
[    0.000000] SRAT: Node 12 PXM 12 [mem 0x92000000000-0x9dfffffffff]
[    0.000000] SRAT: Node 13 PXM 13 [mem 0x9e000000000-0xa9fffffffff]
[    0.000000] SRAT: Node 14 PXM 14 [mem 0xaa000000000-0xb5fffffffff]
[    0.000000] SRAT: Node 15 PXM 15 [mem 0xb6000000000-0xc1fffffffff]
[    0.000000] NUMA: Initialized distance table, cnt=16
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0xc07fffffff] -> [mem 0x00000000-0xc07fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0xc07ffda000-0xc07fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x19ffffda000-0x19fffffffff]
[    0.000000] NODE_DATA(2) allocated [mem 0x25ffffda000-0x25fffffffff]
[    0.000000] NODE_DATA(3) allocated [mem 0x31ffffda000-0x31fffffffff]
[    0.000000] NODE_DATA(4) allocated [mem 0x3dffffda000-0x3dfffffffff]
[    0.000000] NODE_DATA(5) allocated [mem 0x49ffffda000-0x49fffffffff]
[    0.000000] NODE_DATA(6) allocated [mem 0x55ffffda000-0x55fffffffff]
[    0.000000] NODE_DATA(7) allocated [mem 0x61ffffda000-0x61fffffffff]
[    0.000000] NODE_DATA(8) allocated [mem 0x6dffffda000-0x6dfffffffff]
[    0.000000] NODE_DATA(9) allocated [mem 0x79ffffda000-0x79fffffffff]
[    0.000000] NODE_DATA(10) allocated [mem 0x85ffffda000-0x85fffffffff]
[    0.000000] NODE_DATA(11) allocated [mem 0x91ffffda000-0x91fffffffff]
[    0.000000] NODE_DATA(12) allocated [mem 0x9dffffda000-0x9dfffffffff]
[    0.000000] NODE_DATA(13) allocated [mem 0xa9ffffda000-0xa9fffffffff]
[    0.000000] NODE_DATA(14) allocated [mem 0xb5ffffda000-0xb5fffffffff]
[    0.000000] NODE_DATA(15) allocated [mem 0xc1ffffbb000-0xc1ffffe0fff]
[    0.000000] Reserving 768MB of memory at 128MB for crashkernel (System RAM: 12582795MB)
[    0.000000]  [ffffea0000000000-ffffea02a1bfffff] PMD -> [ffff88bd7fe00000-ffff88c01fdfffff] on node 0
[    0.000000]  [ffffea0310000000-ffffea05afffffff] PMD -> [ffff899cffe00000-ffff899f9fdfffff] on node 1
[    0.000000]  [ffffea05b0000000-ffffea084fffffff] PMD -> [ffff8a5cffe00000-ffff8a5f9fdfffff] on node 2
[    0.000000]  [ffffea0850000000-ffffea0aefffffff] PMD -> [ffff8b1cffe00000-ffff8b1f9fdfffff] on node 3
[    0.000000]  [ffffea0af0000000-ffffea0d8fffffff] PMD -> [ffff8bdcffe00000-ffff8bdf9fdfffff] on node 4
[    0.000000]  [ffffea0d90000000-ffffea102fffffff] PMD -> [ffff8c9cffe00000-ffff8c9f9fdfffff] on node 5
[    0.000000]  [ffffea1030000000-ffffea12cfffffff] PMD -> [ffff8d5cffe00000-ffff8d5f9fdfffff] on node 6
[    0.000000]  [ffffea12d0000000-ffffea156fffffff] PMD -> [ffff8e1cffe00000-ffff8e1f9fdfffff] on node 7
[    0.000000]  [ffffea1570000000-ffffea180fffffff] PMD -> [ffff8edcffe00000-ffff8edf9fdfffff] on node 8
[    0.000000]  [ffffea1810000000-ffffea1aafffffff] PMD -> [ffff8f9cffe00000-ffff8f9f9fdfffff] on node 9
[    0.000000]  [ffffea1ab0000000-ffffea1d4fffffff] PMD -> [ffff905cffe00000-ffff905f9fdfffff] on node 10
[    0.000000]  [ffffea1d50000000-ffffea1fefffffff] PMD -> [ffff911cffe00000-ffff911f9fdfffff] on node 11
[    0.000000]  [ffffea1ff0000000-ffffea228fffffff] PMD -> [ffff91dcffe00000-ffff91df9fdfffff] on node 12
[    0.000000]  [ffffea2290000000-ffffea252fffffff] PMD -> [ffff929cffe00000-ffff929f9fdfffff] on node 13
[    0.000000]  [ffffea2530000000-ffffea27cfffffff] PMD -> [ffff935cffe00000-ffff935f9fdfffff] on node 14
[    0.000000]  [ffffea27d0000000-ffffea2a6fffffff] PMD -> [ffff941cff600000-ffff941f9f5fffff] on node 15
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000c1fffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000008dfff]
[    0.000000]   node   0: [mem 0x0000000000090000-0x000000000009ffff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000006d00bfff]
[    0.000000]   node   0: [mem 0x000000006d018000-0x000000006f3fbfff]
[    0.000000]   node   0: [mem 0x000000006f3ff000-0x0000000078bfefff]
[    0.000000]   node   0: [mem 0x000000007bfff000-0x000000007bffffff]
[    0.000000]   node   0: [mem 0x0000000100001000-0x000000c07fffffff]
[    0.000000]   node   1: [mem 0x000000e000001000-0x0000019fffffffff]
[    0.000000]   node   2: [mem 0x000001a000000000-0x0000025fffffffff]
[    0.000000]   node   3: [mem 0x0000026000000000-0x0000031fffffffff]
[    0.000000]   node   4: [mem 0x0000032000000000-0x000003dfffffffff]
[    0.000000]   node   5: [mem 0x000003e000000000-0x0000049fffffffff]
[    0.000000]   node   6: [mem 0x000004a000000000-0x0000055fffffffff]
[    0.000000]   node   7: [mem 0x0000056000000000-0x0000061fffffffff]
[    0.000000]   node   8: [mem 0x0000062000000000-0x000006dfffffffff]
[    0.000000]   node   9: [mem 0x000006e000000000-0x0000079fffffffff]
[    0.000000]   node  10: [mem 0x000007a000000000-0x0000085fffffffff]
[    0.000000]   node  11: [mem 0x0000086000000000-0x0000091fffffffff]
[    0.000000]   node  12: [mem 0x0000092000000000-0x000009dfffffffff]
[    0.000000]   node  13: [mem 0x000009e000000000-0x00000a9fffffffff]
[    0.000000]   node  14: [mem 0x00000aa000000000-0x00000b5fffffffff]
[    0.000000]   node  15: [mem 0x00000b6000000000-0x00000c1fffffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000c07fffffff]
[    0.000000] On node 0 totalpages: 201296781
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 23 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 6706 pages used for memmap
[    0.000000]   DMA32 zone: 490481 pages, LIFO batch:31
[    0.000000]   Normal zone: 2745344 pages used for memmap
[    0.000000]   Normal zone: 200802303 pages, LIFO batch:31
[    0.000000] Initmem setup node 1 [mem 0x000000e000001000-0x0000019fffffffff]
[    0.000000] On node 1 totalpages: 201326591
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326591 pages, LIFO batch:31
[    0.000000] Initmem setup node 2 [mem 0x000001a000000000-0x0000025fffffffff]
[    0.000000] On node 2 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 3 [mem 0x0000026000000000-0x0000031fffffffff]
[    0.000000] On node 3 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 4 [mem 0x0000032000000000-0x000003dfffffffff]
[    0.000000] On node 4 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 5 [mem 0x000003e000000000-0x0000049fffffffff]
[    0.000000] On node 5 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 6 [mem 0x000004a000000000-0x0000055fffffffff]
[    0.000000] On node 6 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 7 [mem 0x0000056000000000-0x0000061fffffffff]
[    0.000000] On node 7 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 8 [mem 0x0000062000000000-0x000006dfffffffff]
[    0.000000] On node 8 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 9 [mem 0x000006e000000000-0x0000079fffffffff]
[    0.000000] On node 9 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 10 [mem 0x000007a000000000-0x0000085fffffffff]
[    0.000000] On node 10 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 11 [mem 0x0000086000000000-0x0000091fffffffff]
[    0.000000] On node 11 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 12 [mem 0x0000092000000000-0x000009dfffffffff]
[    0.000000] On node 12 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 13 [mem 0x000009e000000000-0x00000a9fffffffff]
[    0.000000] On node 13 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 14 [mem 0x00000aa000000000-0x00000b5fffffffff]
[    0.000000] On node 14 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] Initmem setup node 15 [mem 0x00000b6000000000-0x00000c1fffffffff]
[    0.000000] On node 15 totalpages: 201326592
[    0.000000]   Normal zone: 2752512 pages used for memmap
[    0.000000]   Normal zone: 201326592 pages, LIFO batch:31
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] System requires x2apic physical mode
[    0.000000] ACPI: X2APIC (apic_id[0x00] uid[0x00] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x02] uid[0x02] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x04] uid[0x04] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x06] uid[0x06] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x08] uid[0x08] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0a] uid[0x0a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0c] uid[0x0c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0e] uid[0x0e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10] uid[0x10] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12] uid[0x12] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14] uid[0x14] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16] uid[0x16] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18] uid[0x18] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a] uid[0x1a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c] uid[0x1c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x20] uid[0x24] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x22] uid[0x26] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x24] uid[0x28] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x26] uid[0x2a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x28] uid[0x2c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2a] uid[0x2e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2c] uid[0x30] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2e] uid[0x32] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x30] uid[0x34] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x32] uid[0x36] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x34] uid[0x38] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x36] uid[0x3a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x38] uid[0x3c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x3a] uid[0x3e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x3c] uid[0x40] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x40] uid[0x48] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x42] uid[0x4a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x44] uid[0x4c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x46] uid[0x4e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x48] uid[0x50] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4a] uid[0x52] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4c] uid[0x54] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4e] uid[0x56] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x50] uid[0x58] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x52] uid[0x5a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x54] uid[0x5c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x56] uid[0x5e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x58] uid[0x60] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x5a] uid[0x62] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x5c] uid[0x64] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x60] uid[0x6c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x62] uid[0x6e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x64] uid[0x70] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x66] uid[0x72] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x68] uid[0x74] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6a] uid[0x76] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6c] uid[0x78] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6e] uid[0x7a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x70] uid[0x7c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x72] uid[0x7e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x74] uid[0x80] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x76] uid[0x82] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x78] uid[0x84] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x7a] uid[0x86] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x7c] uid[0x88] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x80] uid[0x90] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x82] uid[0x92] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x84] uid[0x94] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x86] uid[0x96] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x88] uid[0x98] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8a] uid[0x9a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8c] uid[0x9c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8e] uid[0x9e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x90] uid[0xa0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x92] uid[0xa2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x94] uid[0xa4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x96] uid[0xa6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x98] uid[0xa8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x9a] uid[0xaa] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x9c] uid[0xac] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa0] uid[0xb4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa2] uid[0xb6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa4] uid[0xb8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa6] uid[0xba] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa8] uid[0xbc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xaa] uid[0xbe] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xac] uid[0xc0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xae] uid[0xc2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb0] uid[0xc4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb2] uid[0xc6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb4] uid[0xc8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb6] uid[0xca] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb8] uid[0xcc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xba] uid[0xce] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xbc] uid[0xd0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc0] uid[0xd8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc2] uid[0xda] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc4] uid[0xdc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc6] uid[0xde] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc8] uid[0xe0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xca] uid[0xe2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xcc] uid[0xe4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xce] uid[0xe6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd0] uid[0xe8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd2] uid[0xea] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd4] uid[0xec] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd6] uid[0xee] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd8] uid[0xf0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xda] uid[0xf2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xdc] uid[0xf4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe0] uid[0xfc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe2] uid[0xfe] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe4] uid[0x100] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe6] uid[0x102] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe8] uid[0x104] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xea] uid[0x106] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xec] uid[0x108] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xee] uid[0x10a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf0] uid[0x10c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf2] uid[0x10e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf4] uid[0x110] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf6] uid[0x112] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf8] uid[0x114] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xfa] uid[0x116] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xfc] uid[0x118] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x100] uid[0x120] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x102] uid[0x122] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x104] uid[0x124] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x106] uid[0x126] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x108] uid[0x128] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10a] uid[0x12a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10c] uid[0x12c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10e] uid[0x12e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x110] uid[0x130] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x112] uid[0x132] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x114] uid[0x134] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x116] uid[0x136] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x118] uid[0x138] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x11a] uid[0x13a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x11c] uid[0x13c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x120] uid[0x144] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x122] uid[0x146] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x124] uid[0x148] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x126] uid[0x14a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x128] uid[0x14c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12a] uid[0x14e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12c] uid[0x150] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12e] uid[0x152] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x130] uid[0x154] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x132] uid[0x156] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x134] uid[0x158] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x136] uid[0x15a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x138] uid[0x15c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x13a] uid[0x15e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x13c] uid[0x160] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x140] uid[0x168] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x142] uid[0x16a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x144] uid[0x16c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x146] uid[0x16e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x148] uid[0x170] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14a] uid[0x172] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14c] uid[0x174] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14e] uid[0x176] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x150] uid[0x178] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x152] uid[0x17a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x154] uid[0x17c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x156] uid[0x17e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x158] uid[0x180] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x15a] uid[0x182] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x15c] uid[0x184] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x160] uid[0x18c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x162] uid[0x18e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x164] uid[0x190] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x166] uid[0x192] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x168] uid[0x194] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16a] uid[0x196] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16c] uid[0x198] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16e] uid[0x19a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x170] uid[0x19c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x172] uid[0x19e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x174] uid[0x1a0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x176] uid[0x1a2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x178] uid[0x1a4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x17a] uid[0x1a6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x17c] uid[0x1a8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x180] uid[0x1b0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x182] uid[0x1b2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x184] uid[0x1b4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x186] uid[0x1b6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x188] uid[0x1b8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18a] uid[0x1ba] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18c] uid[0x1bc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18e] uid[0x1be] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x190] uid[0x1c0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x192] uid[0x1c2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x194] uid[0x1c4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x196] uid[0x1c6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x198] uid[0x1c8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x19a] uid[0x1ca] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x19c] uid[0x1cc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a0] uid[0x1d4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a2] uid[0x1d6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a4] uid[0x1d8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a6] uid[0x1da] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a8] uid[0x1dc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1aa] uid[0x1de] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ac] uid[0x1e0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ae] uid[0x1e2] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b0] uid[0x1e4] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b2] uid[0x1e6] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b4] uid[0x1e8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b6] uid[0x1ea] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b8] uid[0x1ec] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ba] uid[0x1ee] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1bc] uid[0x1f0] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c0] uid[0x1f8] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c2] uid[0x1fa] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c4] uid[0x1fc] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c6] uid[0x1fe] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c8] uid[0x200] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ca] uid[0x202] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1cc] uid[0x204] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ce] uid[0x206] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d0] uid[0x208] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d2] uid[0x20a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d4] uid[0x20c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d6] uid[0x20e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d8] uid[0x210] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1da] uid[0x212] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1dc] uid[0x214] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e0] uid[0x21c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e2] uid[0x21e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e4] uid[0x220] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e6] uid[0x222] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e8] uid[0x224] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ea] uid[0x226] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ec] uid[0x228] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ee] uid[0x22a] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f0] uid[0x22c] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f2] uid[0x22e] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f4] uid[0x230] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f6] uid[0x232] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f8] uid[0x234] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1fa] uid[0x236] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1fc] uid[0x238] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x01] uid[0x01] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x03] uid[0x03] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x05] uid[0x05] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x07] uid[0x07] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x09] uid[0x09] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0b] uid[0x0b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0d] uid[0x0d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x0f] uid[0x0f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x11] uid[0x11] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x13] uid[0x13] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x15] uid[0x15] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x17] uid[0x17] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x19] uid[0x19] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b] uid[0x1b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d] uid[0x1d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x21] uid[0x25] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x23] uid[0x27] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x25] uid[0x29] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x27] uid[0x2b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x29] uid[0x2d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2b] uid[0x2f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2d] uid[0x31] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x2f] uid[0x33] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x31] uid[0x35] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x33] uid[0x37] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x35] uid[0x39] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x37] uid[0x3b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x39] uid[0x3d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x3b] uid[0x3f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x3d] uid[0x41] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x41] uid[0x49] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x43] uid[0x4b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x45] uid[0x4d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x47] uid[0x4f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x49] uid[0x51] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4b] uid[0x53] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4d] uid[0x55] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x4f] uid[0x57] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x51] uid[0x59] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x53] uid[0x5b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x55] uid[0x5d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x57] uid[0x5f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x59] uid[0x61] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x5b] uid[0x63] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x5d] uid[0x65] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x61] uid[0x6d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x63] uid[0x6f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x65] uid[0x71] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x67] uid[0x73] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x69] uid[0x75] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6b] uid[0x77] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6d] uid[0x79] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x6f] uid[0x7b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x71] uid[0x7d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x73] uid[0x7f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x75] uid[0x81] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x77] uid[0x83] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x79] uid[0x85] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x7b] uid[0x87] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x7d] uid[0x89] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x81] uid[0x91] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x83] uid[0x93] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x85] uid[0x95] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x87] uid[0x97] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x89] uid[0x99] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8b] uid[0x9b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8d] uid[0x9d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x8f] uid[0x9f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x91] uid[0xa1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x93] uid[0xa3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x95] uid[0xa5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x97] uid[0xa7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x99] uid[0xa9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x9b] uid[0xab] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x9d] uid[0xad] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa1] uid[0xb5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa3] uid[0xb7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa5] uid[0xb9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa7] uid[0xbb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xa9] uid[0xbd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xab] uid[0xbf] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xad] uid[0xc1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xaf] uid[0xc3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb1] uid[0xc5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb3] uid[0xc7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb5] uid[0xc9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb7] uid[0xcb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xb9] uid[0xcd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xbb] uid[0xcf] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xbd] uid[0xd1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc1] uid[0xd9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc3] uid[0xdb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc5] uid[0xdd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc7] uid[0xdf] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xc9] uid[0xe1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xcb] uid[0xe3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xcd] uid[0xe5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xcf] uid[0xe7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd1] uid[0xe9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd3] uid[0xeb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd5] uid[0xed] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd7] uid[0xef] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xd9] uid[0xf1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xdb] uid[0xf3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xdd] uid[0xf5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe1] uid[0xfd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe3] uid[0xff] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe5] uid[0x101] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe7] uid[0x103] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xe9] uid[0x105] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xeb] uid[0x107] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xed] uid[0x109] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xef] uid[0x10b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf1] uid[0x10d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf3] uid[0x10f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf5] uid[0x111] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf7] uid[0x113] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xf9] uid[0x115] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xfb] uid[0x117] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0xfd] uid[0x119] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x101] uid[0x121] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x103] uid[0x123] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x105] uid[0x125] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x107] uid[0x127] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x109] uid[0x129] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10b] uid[0x12b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10d] uid[0x12d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x10f] uid[0x12f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x111] uid[0x131] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x113] uid[0x133] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x115] uid[0x135] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x117] uid[0x137] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x119] uid[0x139] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x11b] uid[0x13b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x11d] uid[0x13d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x121] uid[0x145] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x123] uid[0x147] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x125] uid[0x149] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x127] uid[0x14b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x129] uid[0x14d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12b] uid[0x14f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12d] uid[0x151] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x12f] uid[0x153] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x131] uid[0x155] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x133] uid[0x157] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x135] uid[0x159] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x137] uid[0x15b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x139] uid[0x15d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x13b] uid[0x15f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x13d] uid[0x161] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x141] uid[0x169] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x143] uid[0x16b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x145] uid[0x16d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x147] uid[0x16f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x149] uid[0x171] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14b] uid[0x173] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14d] uid[0x175] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x14f] uid[0x177] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x151] uid[0x179] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x153] uid[0x17b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x155] uid[0x17d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x157] uid[0x17f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x159] uid[0x181] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x15b] uid[0x183] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x15d] uid[0x185] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x161] uid[0x18d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x163] uid[0x18f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x165] uid[0x191] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x167] uid[0x193] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x169] uid[0x195] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16b] uid[0x197] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16d] uid[0x199] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x16f] uid[0x19b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x171] uid[0x19d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x173] uid[0x19f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x175] uid[0x1a1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x177] uid[0x1a3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x179] uid[0x1a5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x17b] uid[0x1a7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x17d] uid[0x1a9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x181] uid[0x1b1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x183] uid[0x1b3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x185] uid[0x1b5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x187] uid[0x1b7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x189] uid[0x1b9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18b] uid[0x1bb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18d] uid[0x1bd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x18f] uid[0x1bf] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x191] uid[0x1c1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x193] uid[0x1c3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x195] uid[0x1c5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x197] uid[0x1c7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x199] uid[0x1c9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x19b] uid[0x1cb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x19d] uid[0x1cd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a1] uid[0x1d5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a3] uid[0x1d7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a5] uid[0x1d9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a7] uid[0x1db] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1a9] uid[0x1dd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ab] uid[0x1df] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ad] uid[0x1e1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1af] uid[0x1e3] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b1] uid[0x1e5] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b3] uid[0x1e7] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b5] uid[0x1e9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b7] uid[0x1eb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1b9] uid[0x1ed] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1bb] uid[0x1ef] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1bd] uid[0x1f1] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c1] uid[0x1f9] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c3] uid[0x1fb] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c5] uid[0x1fd] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c7] uid[0x1ff] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1c9] uid[0x201] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1cb] uid[0x203] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1cd] uid[0x205] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1cf] uid[0x207] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d1] uid[0x209] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d3] uid[0x20b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d5] uid[0x20d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d7] uid[0x20f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1d9] uid[0x211] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1db] uid[0x213] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1dd] uid[0x215] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e1] uid[0x21d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e3] uid[0x21f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e5] uid[0x221] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e7] uid[0x223] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1e9] uid[0x225] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1eb] uid[0x227] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ed] uid[0x229] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1ef] uid[0x22b] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f1] uid[0x22d] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f3] uid[0x22f] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f5] uid[0x231] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f7] uid[0x233] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1f9] uid[0x235] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1fb] uid[0x237] enabled)
[    0.000000] ACPI: X2APIC (apic_id[0x1fd] uid[0x239] enabled)
[    0.000000] ACPI: X2APIC_NMI (uid[0x00] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x01] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x02] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x03] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x04] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x05] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x06] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x07] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x08] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x09] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x0f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x11] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x13] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x18] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x24] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x25] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x26] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x27] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x28] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x29] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x2f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x30] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x31] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x32] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x33] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x34] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x35] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x36] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x37] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x38] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x39] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x3f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x40] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x41] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x48] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x49] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x4f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x50] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x51] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x52] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x53] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x54] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x55] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x56] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x57] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x58] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x59] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x5f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x60] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x61] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x62] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x63] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x64] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x65] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x6c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x6d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x6e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x6f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x70] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x71] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x72] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x73] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x74] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x75] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x76] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x77] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x78] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x79] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x7f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x80] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x81] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x82] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x83] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x84] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x85] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x86] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x87] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x88] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x89] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x90] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x91] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x92] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x93] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x94] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x95] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x96] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x97] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x98] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x99] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x9f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xa9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xaa] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xab] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xac] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xad] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xb9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xba] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xbb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xbc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xbd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xbe] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xbf] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xc9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xca] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xcb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xcc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xcd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xce] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xcf] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xd0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xd1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xd8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xd9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xda] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xdb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xdc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xdd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xde] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xdf] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xe9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xea] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xeb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xec] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xed] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xee] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xef] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xf5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xfc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xfd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xfe] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0xff] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x100] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x101] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x102] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x103] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x104] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x105] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x106] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x107] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x108] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x109] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x10f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x110] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x111] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x112] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x113] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x114] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x115] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x116] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x117] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x118] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x119] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x120] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x121] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x122] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x123] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x124] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x125] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x126] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x127] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x128] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x129] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x12f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x130] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x131] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x132] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x133] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x134] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x135] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x136] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x137] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x138] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x139] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x13a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x13b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x13c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x13d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x144] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x145] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x146] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x147] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x148] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x149] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x14f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x150] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x151] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x152] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x153] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x154] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x155] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x156] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x157] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x158] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x159] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x15f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x160] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x161] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x168] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x169] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x16f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x170] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x171] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x172] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x173] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x174] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x175] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x176] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x177] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x178] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x179] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x17f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x180] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x181] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x182] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x183] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x184] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x185] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x18c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x18d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x18e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x18f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x190] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x191] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x192] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x193] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x194] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x195] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x196] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x197] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x198] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x199] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x19f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1a9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1b9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ba] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1bb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1bc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1bd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1be] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1bf] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1c9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ca] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1cb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1cc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1cd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1d9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1da] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1db] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1dc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1dd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1de] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1df] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e2] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e3] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e4] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e5] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e6] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e7] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1e9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ea] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1eb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ec] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ed] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ee] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ef] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1f0] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1f1] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1f8] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1f9] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1fa] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1fb] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1fc] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1fd] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1fe] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x1ff] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x200] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x201] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x202] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x203] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x204] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x205] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x206] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x207] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x208] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x209] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x20f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x210] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x211] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x212] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x213] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x214] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x215] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x21c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x21d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x21e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x21f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x220] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x221] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x222] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x223] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x224] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x225] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x226] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x227] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x228] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x229] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22a] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22b] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22c] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22d] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22e] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x22f] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x230] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x231] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x232] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x233] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x234] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x235] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x236] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x237] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x238] high level lint[0x1])
[    0.000000] ACPI: X2APIC_NMI (uid[0x239] high level lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec04000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec04000, GSI 48-71
[    0.000000] ACPI: IOAPIC (id[0x0b] address[0xfec08000] gsi_base[72])
[    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec08000, GSI 72-95
[    0.000000] ACPI: IOAPIC (id[0x0c] address[0xfec09000] gsi_base[96])
[    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfec09000, GSI 96-119
[    0.000000] ACPI: IOAPIC (id[0x0d] address[0xfec0c000] gsi_base[120])
[    0.000000] IOAPIC[5]: apic_id 13, version 32, address 0xfec0c000, GSI 120-143
[    0.000000] ACPI: IOAPIC (id[0x0e] address[0xfec10000] gsi_base[144])
[    0.000000] IOAPIC[6]: apic_id 14, version 32, address 0xfec10000, GSI 144-167
[    0.000000] ACPI: IOAPIC (id[0x0f] address[0xfec11000] gsi_base[168])
[    0.000000] IOAPIC[7]: apic_id 15, version 32, address 0xfec11000, GSI 168-191
[    0.000000] ACPI: IOAPIC (id[0x10] address[0xfec14000] gsi_base[192])
[    0.000000] IOAPIC[8]: apic_id 16, version 32, address 0xfec14000, GSI 192-215
[    0.000000] ACPI: IOAPIC (id[0x11] address[0xfec18000] gsi_base[216])
[    0.000000] IOAPIC[9]: apic_id 17, version 32, address 0xfec18000, GSI 216-239
[    0.000000] ACPI: IOAPIC (id[0x12] address[0xfec19000] gsi_base[240])
[    0.000000] IOAPIC[10]: apic_id 18, version 32, address 0xfec19000, GSI 240-263
[    0.000000] ACPI: IOAPIC (id[0x13] address[0xfec1c000] gsi_base[264])
[    0.000000] IOAPIC[11]: apic_id 19, version 32, address 0xfec1c000, GSI 264-287
[    0.000000] ACPI: IOAPIC (id[0x14] address[0xfec20000] gsi_base[288])
[    0.000000] IOAPIC[12]: apic_id 20, version 32, address 0xfec20000, GSI 288-311
[    0.000000] ACPI: IOAPIC (id[0x15] address[0xfec21000] gsi_base[312])
[    0.000000] IOAPIC[13]: apic_id 21, version 32, address 0xfec21000, GSI 312-335
[    0.000000] ACPI: IOAPIC (id[0x16] address[0xfec24000] gsi_base[336])
[    0.000000] IOAPIC[14]: apic_id 22, version 32, address 0xfec24000, GSI 336-359
[    0.000000] ACPI: IOAPIC (id[0x17] address[0xfec28000] gsi_base[360])
[    0.000000] IOAPIC[15]: apic_id 23, version 32, address 0xfec28000, GSI 360-383
[    0.000000] ACPI: IOAPIC (id[0x18] address[0xfec29000] gsi_base[384])
[    0.000000] IOAPIC[16]: apic_id 24, version 32, address 0xfec29000, GSI 384-407
[    0.000000] ACPI: IOAPIC (id[0x19] address[0xfec2c000] gsi_base[408])
[    0.000000] IOAPIC[17]: apic_id 25, version 32, address 0xfec2c000, GSI 408-431
[    0.000000] ACPI: IOAPIC (id[0x1a] address[0xfec30000] gsi_base[432])
[    0.000000] IOAPIC[18]: apic_id 26, version 32, address 0xfec30000, GSI 432-455
[    0.000000] ACPI: IOAPIC (id[0x1b] address[0xfec31000] gsi_base[456])
[    0.000000] IOAPIC[19]: apic_id 27, version 32, address 0xfec31000, GSI 456-479
[    0.000000] ACPI: IOAPIC (id[0x1c] address[0xfec34000] gsi_base[480])
[    0.000000] IOAPIC[20]: apic_id 28, version 32, address 0xfec34000, GSI 480-503
[    0.000000] ACPI: IOAPIC (id[0x1d] address[0xfec38000] gsi_base[504])
[    0.000000] IOAPIC[21]: apic_id 29, version 32, address 0xfec38000, GSI 504-527
[    0.000000] ACPI: IOAPIC (id[0x1e] address[0xfec39000] gsi_base[528])
[    0.000000] IOAPIC[22]: apic_id 30, version 32, address 0xfec39000, GSI 528-551
[    0.000000] ACPI: IOAPIC (id[0x1f] address[0xfec3c000] gsi_base[552])
[    0.000000] IOAPIC[23]: apic_id 31, version 32, address 0xfec3c000, GSI 552-575
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: Allowing 480 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0008e000-0x0008ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x6d00c000-0x6d017fff]
[    0.000000] PM: Registered nosave memory: [mem 0x6f3fc000-0x6f3fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x78bff000-0x790fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x790ff000-0x798fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x798ff000-0x799fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x799ff000-0x7bdfefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bdff000-0x7bffefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7c000000-0x7fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x80000000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xff1fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff200000-0xffffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x100000000-0x100000fff]
[    0.000000] PM: Registered nosave memory: [mem 0xc080000000-0xdfffffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe000000000-0xe000000fff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:480 nr_cpu_ids:480 nr_node_ids:16
[    0.000000] PERCPU: Embedded 29 pages/cpu @ffff88c07fa00000 s80536 r8192 d30056 u131072
[    0.000000] pcpu-alloc: s80536 r8192 d30056 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [00] 000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 240 
[    0.000000] pcpu-alloc: [00] 241 242 243 244 245 246 247 248 249 250 251 252 253 254 --- --- 
[    0.000000] pcpu-alloc: [01] 015 016 017 018 019 020 021 022 023 024 025 026 027 028 029 255 
[    0.000000] pcpu-alloc: [01] 256 257 258 259 260 261 262 263 264 265 266 267 268 269 --- --- 
[    0.000000] pcpu-alloc: [02] 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 270 
[    0.000000] pcpu-alloc: [02] 271 272 273 274 275 276 277 278 279 280 281 282 283 284 --- --- 
[    0.000000] pcpu-alloc: [03] 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 285 
[    0.000000] pcpu-alloc: [03] 286 287 288 289 290 291 292 293 294 295 296 297 298 299 --- --- 
[    0.000000] pcpu-alloc: [04] 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 300 
[    0.000000] pcpu-alloc: [04] 301 302 303 304 305 306 307 308 309 310 311 312 313 314 --- --- 
[    0.000000] pcpu-alloc: [05] 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 315 
[    0.000000] pcpu-alloc: [05] 316 317 318 319 320 321 322 323 324 325 326 327 328 329 --- --- 
[    0.000000] pcpu-alloc: [06] 090 091 092 093 094 095 096 097 098 099 100 101 102 103 104 330 
[    0.000000] pcpu-alloc: [06] 331 332 333 334 335 336 337 338 339 340 341 342 343 344 --- --- 
[    0.000000] pcpu-alloc: [07] 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 345 
[    0.000000] pcpu-alloc: [07] 346 347 348 349 350 351 352 353 354 355 356 357 358 359 --- --- 
[    0.000000] pcpu-alloc: [08] 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 360 
[    0.000000] pcpu-alloc: [08] 361 362 363 364 365 366 367 368 369 370 371 372 373 374 --- --- 
[    0.000000] pcpu-alloc: [09] 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 375 
[    0.000000] pcpu-alloc: [09] 376 377 378 379 380 381 382 383 384 385 386 387 388 389 --- --- 
[    0.000000] pcpu-alloc: [10] 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 390 
[    0.000000] pcpu-alloc: [10] 391 392 393 394 395 396 397 398 399 400 401 402 403 404 --- --- 
[    0.000000] pcpu-alloc: [11] 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 405 
[    0.000000] pcpu-alloc: [11] 406 407 408 409 410 411 412 413 414 415 416 417 418 419 --- --- 
[    0.000000] pcpu-alloc: [12] 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 420 
[    0.000000] pcpu-alloc: [12] 421 422 423 424 425 426 427 428 429 430 431 432 433 434 --- --- 
[    0.000000] pcpu-alloc: [13] 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 435 
[    0.000000] pcpu-alloc: [13] 436 437 438 439 440 441 442 443 444 445 446 447 448 449 --- --- 
[    0.000000] pcpu-alloc: [14] 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 450 
[    0.000000] pcpu-alloc: [14] 451 452 453 454 455 456 457 458 459 460 461 462 463 464 --- --- 
[    0.000000] pcpu-alloc: [15] 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 465 
[    0.000000] pcpu-alloc: [15] 466 467 468 469 470 471 472 473 474 475 476 477 478 479 --- --- 
[    0.000000] Built 16 zonelists in Node order, mobility grouping on.  Total pages: 3177155851
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=dev000:\efi\SuSE\vmlinuz-4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp root=/dev/disk/by-id/scsi-3600c0ff0001a841e1d12f65401000000-part3  noresume resume=/dev/disk/by-id/scsi-3600c0ff0001a841e1d12f65401000000-part2 splash=silent crashkernel=1536M-:768M showopts intel_idle.max_cstate=1 selinux=0 console=ttyS0,115200
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 1961984 bytes
[    0.000000] log_buf_len min size: 262144 bytes
[    0.000000] log_buf_len: 4194304 bytes
[    0.000000] early log buf free: 132560(50%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standard form
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] Memory: 16237952K/12884782640K available (5240K kernel code, 1020K rwdata, 2672K rodata, 1632K init, 1516K bss, 177258348K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Additional per-CPU info printed with stalls.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=480.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=480
[    0.000000] NR_IRQS:524544 nr_irqs:13648 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2793.681 MHz processor
[    0.000527] Calibrating delay loop (skipped), value calculated using timer frequency.. 5587.36 BogoMIPS (lpj=11174724)
[    0.012334] pid_max: default: 491520 minimum: 3840
[    0.018503] ACPI: Core revision 20150204
[    0.186741] ACPI: All ACPI Tables successfully acquired
[    0.201020] Security Framework initialized
[    0.205592] AppArmor: AppArmor initialized
[    2.284686] vmalloc: allocation failure, allocated 16578404352 of 17179873280 bytes
[    2.293123] swapper/0: page allocation failure: order:0, mode:0x20
[    2.299966] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #1
[    2.309357] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[    2.319613]  ffffffff817fc7d8 ffffffff81a03d78 ffffffff81515019 ffffffff81a03e08
[    2.327820]  ffffffff81135d52 ffffffff00000018 ffffffff81a03e18 ffffffff81a03db8
[    2.336009]  00000000003dc266 ffffffff817fc7d8 ffffffff81a03d88 ffffffff81a03e08
[    2.344197] Call Trace:
[    2.346949]  [<ffffffff81515019>] dump_stack+0x68/0x77
[    2.352647]  [<ffffffff81135d52>] warn_alloc_failed+0xe2/0x140
[    2.359120]  [<ffffffff81177575>] ? alloc_pages_current+0x145/0x160
[    2.366062]  [<ffffffff81168b5f>] __vmalloc_area_node+0x17f/0x230
[    2.372773]  [<ffffffff81168cbd>] __vmalloc_node_range+0xad/0xc0
[    2.379437]  [<ffffffff81b3ccbd>] ? alloc_large_system_hash+0x11a/0x27a
[    2.386725]  [<ffffffff81168d09>] __vmalloc_node+0x39/0x40
[    2.392767]  [<ffffffff81b3ccbd>] ? alloc_large_system_hash+0x11a/0x27a
[    2.400050]  [<ffffffff81168e8d>] __vmalloc+0x1d/0x20
[    2.405613]  [<ffffffff81b3ccbd>] alloc_large_system_hash+0x11a/0x27a
[    2.412720]  [<ffffffff81b4393f>] vfs_caches_init+0xf3/0x139
[    2.418960]  [<ffffffff81b47306>] ? security_init+0x42/0x58
[    2.425137]  [<ffffffff81b162c6>] start_kernel+0x31d/0x420
[    2.431178]  [<ffffffff81b15da2>] ? set_init_arg+0x6c/0x6c
[    2.437223]  [<ffffffff81b154d1>] x86_64_start_reservations+0x1b/0x32
[    2.444318]  [<ffffffff81b15634>] x86_64_start_kernel+0x14c/0x153
[    2.451034] Mem-Info:
[    2.453535] Node 0 DMA per-cpu:
[    2.457011] CPU    0: hi:    0, btch:   1 usd:   0
[    2.462291] Node 0 DMA32 per-cpu:
[    2.465953] CPU    0: hi:  186, btch:  31 usd:  23
[    2.471233] Node 0 Normal per-cpu:
[    2.474986] CPU    0: hi:    0, btch:   1 usd:   0
[    2.480267] Node 1 Normal per-cpu:
[    2.484022] CPU    0: hi:  186, btch:  31 usd:  20
[    2.489302] Node 2 Normal per-cpu:
[    2.493054] CPU    0: hi:  186, btch:  31 usd:  20
[    2.498332] Node 3 Normal per-cpu:
[    2.502084] CPU    0: hi:  186, btch:  31 usd:  20
[    2.507365] Node 4 Normal per-cpu:
[    2.511119] CPU    0: hi:  186, btch:  31 usd:  20
[    2.516401] Node 5 Normal per-cpu:
[    2.520155] CPU    0: hi:  186, btch:  31 usd:  20
[    2.525433] Node 6 Normal per-cpu:
[    2.529185] CPU    0: hi:  186, btch:  31 usd:  20
[    2.534463] Node 7 Normal per-cpu:
[    2.538216] CPU    0: hi:  186, btch:  31 usd:  20
[    2.543494] Node 8 Normal per-cpu:
[    2.547247] CPU    0: hi:  186, btch:  31 usd:  20
[    2.552528] Node 9 Normal per-cpu:
[    2.556282] CPU    0: hi:  186, btch:  31 usd:  20
[    2.561560] Node 10 Normal per-cpu:
[    2.565410] CPU    0: hi:  186, btch:  31 usd:  20
[    2.570696] Node 11 Normal per-cpu:
[    2.574537] CPU    0: hi:  186, btch:  31 usd:  20
[    2.579815] Node 12 Normal per-cpu:
[    2.583661] CPU    0: hi:  186, btch:  31 usd:  20
[    2.588940] Node 13 Normal per-cpu:
[    2.592793] CPU    0: hi:  186, btch:  31 usd:  20
[    2.598070] Node 14 Normal per-cpu:
[    2.601919] CPU    0: hi:  186, btch:  31 usd:  20
[    2.607196] Node 15 Normal per-cpu:
[    2.611048] CPU    0: hi:  186, btch:  31 usd:  20
[    2.616340] active_anon:0 inactive_anon:0 isolated_anon:0
[    2.616340]  active_file:0 inactive_file:0 isolated_file:0
[    2.616340]  unevictable:0 dirty:0 writeback:0 unstable:0
[    2.616340]  free:0 slab_reclaimable:1 slab_unreclaimable:2823
[    2.616340]  mapped:0 shmem:0 pagetables:0 bounce:0
[    2.616340]  free_cma:0
[    2.648679] Node 0 DMA free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.690981] lowmem_reserve[]: 0 0 0 0
[    2.695049] Node 0 DMA32 free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1961924kB managed:362348kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:944kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.738012] lowmem_reserve[]: 0 0 0 0
[    2.742082] Node 0 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:803209212kB managed:0kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.784673] lowmem_reserve[]: 0 0 0 0
[    2.788741] Node 1 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306364kB managed:1179644kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:680kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.832078] lowmem_reserve[]: 0 0 0 0
[    2.836145] Node 2 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.879480] lowmem_reserve[]: 0 0 0 0
[    2.883548] Node 3 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:680kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.926886] lowmem_reserve[]: 0 0 0 0
[    2.930954] Node 4 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    2.974298] lowmem_reserve[]: 0 0 0 0
[    2.978366] Node 5 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.021710] lowmem_reserve[]: 0 0 0 0
[    3.025778] Node 6 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.069123] lowmem_reserve[]: 0 0 0 0
[    3.073193] Node 7 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:700kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.116545] lowmem_reserve[]: 0 0 0 0
[    3.120615] Node 8 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:688kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.163954] lowmem_reserve[]: 0 0 0 0
[    3.168024] Node 9 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.211362] lowmem_reserve[]: 0 0 0 0
[    3.215433] Node 10 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.258870] lowmem_reserve[]: 0 0 0 0
[    3.262938] Node 11 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:688kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.306376] lowmem_reserve[]: 0 0 0 0
[    3.310443] Node 12 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.353881] lowmem_reserve[]: 0 0 0 0
[    3.357949] Node 13 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:684kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.401387] lowmem_reserve[]: 0 0 0 0
[    3.405457] Node 14 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:688kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.448887] lowmem_reserve[]: 0 0 0 0
[    3.452954] Node 15 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:688kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.496392] lowmem_reserve[]: 0 0 0 0
[    3.500463] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.511888] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.523496] Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.535201] Node 1 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.546906] Node 2 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.558618] Node 3 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.570340] Node 4 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.582041] Node 5 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.593741] Node 6 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.605443] Node 7 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.617145] Node 8 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.628856] Node 9 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.640555] Node 10 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.652368] Node 11 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.664171] Node 12 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.675959] Node 13 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.687757] Node 14 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.699553] Node 15 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[    3.711363] 0 total pagecache pages
[    3.715210] 0 pages in swap cache
[    3.718865] Swap cache stats: add 0, delete 0, find 0/0
[    3.724624] Free swap  = 0kB
[    3.727787] Total swap = 0kB
[    3.730960] 3221195660 pages RAM
[    3.734513] 0 pages HighMem/MovableOnly
[    3.738740] 3217136172 pages reserved
[    3.742771] 0 pages hwpoisoned
[    5.906506] Dentry cache hash table entries: 1073741824 (order: 21, 8589934592 bytes)
[   10.399938] vmalloc: allocation failure, allocated 7970922496 of 8589938688 bytes
[   10.408183] swapper/0: page allocation failure: order:0, mode:0x20
[   10.414995] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #1
[   10.424396] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[   10.434661]  ffffffff817fc7d8 ffffffff81a03d48 ffffffff81515019 ffffffff81a03dd8
[   10.442851]  ffffffff81135d52 ffffffff00000018 ffffffff81a03de8 ffffffff81a03d88
[   10.451038]  00000000001db1aa ffffffff817fc7d8 ffffffff81a03d58 ffffffff81a03dd8
[   10.459229] Call Trace:
[   10.461969]  [<ffffffff81515019>] dump_stack+0x68/0x77
[   10.467632]  [<ffffffff81135d52>] warn_alloc_failed+0xe2/0x140
[   10.474099]  [<ffffffff81177575>] ? alloc_pages_current+0x145/0x160
[   10.481044]  [<ffffffff81168b5f>] __vmalloc_area_node+0x17f/0x230
[   10.487760]  [<ffffffff81168cbd>] __vmalloc_node_range+0xad/0xc0
[   10.494423]  [<ffffffff81b3ccbd>] ? alloc_large_system_hash+0x11a/0x27a
[   10.501708]  [<ffffffff81168d09>] __vmalloc_node+0x39/0x40
[   10.507757]  [<ffffffff81b3ccbd>] ? alloc_large_system_hash+0x11a/0x27a
[   10.515041]  [<ffffffff81168e8d>] __vmalloc+0x1d/0x20
[   10.520618]  [<ffffffff81b3ccbd>] alloc_large_system_hash+0x11a/0x27a
[   10.527742]  [<ffffffff81b43acd>] inode_init+0x7d/0xbc
[   10.533406]  [<ffffffff81b438b7>] vfs_caches_init+0x6b/0x139
[   10.539658]  [<ffffffff81b47306>] ? security_init+0x42/0x58
[   10.545836]  [<ffffffff81b162c6>] start_kernel+0x31d/0x420
[   10.551877]  [<ffffffff81b15da2>] ? set_init_arg+0x6c/0x6c
[   10.557921]  [<ffffffff81b154d1>] x86_64_start_reservations+0x1b/0x32
[   10.565014]  [<ffffffff81b15634>] x86_64_start_kernel+0x14c/0x153
[   10.571730] Mem-Info:
[   10.574246] Node 0 DMA per-cpu:
[   10.577720] CPU    0: hi:    0, btch:   1 usd:   0
[   10.582998] Node 0 DMA32 per-cpu:
[   10.586660] CPU    0: hi:  186, btch:  31 usd:  30
[   10.591940] Node 0 Normal per-cpu:
[   10.595696] CPU    0: hi:    0, btch:   1 usd:   0
[   10.600974] Node 1 Normal per-cpu:
[   10.604736] CPU    0: hi:  186, btch:  31 usd:  30
[   10.610014] Node 2 Normal per-cpu:
[   10.613766] CPU    0: hi:  186, btch:  31 usd:  30
[   10.619045] Node 3 Normal per-cpu:
[   10.622796] CPU    0: hi:  186, btch:  31 usd:  30
[   10.628074] Node 4 Normal per-cpu:
[   10.631827] CPU    0: hi:  186, btch:  31 usd:  30
[   10.637105] Node 5 Normal per-cpu:
[   10.640858] CPU    0: hi:  186, btch:  31 usd:  30
[   10.646136] Node 6 Normal per-cpu:
[   10.649889] CPU    0: hi:  186, btch:  31 usd:  30
[   10.655166] Node 7 Normal per-cpu:
[   10.658919] CPU    0: hi:  186, btch:  31 usd:  30
[   10.664197] Node 8 Normal per-cpu:
[   10.667949] CPU    0: hi:  186, btch:  31 usd:  30
[   10.673227] Node 9 Normal per-cpu:
[   10.676979] CPU    0: hi:  186, btch:  31 usd:  30
[   10.682260] Node 10 Normal per-cpu:
[   10.686109] CPU    0: hi:  186, btch:  31 usd:  30
[   10.691388] Node 11 Normal per-cpu:
[   10.695236] CPU    0: hi:  186, btch:  31 usd:  30
[   10.700518] Node 12 Normal per-cpu:
[   10.704366] CPU    0: hi:  186, btch:  31 usd:  30
[   10.709644] Node 13 Normal per-cpu:
[   10.713492] CPU    0: hi:  186, btch:  31 usd:  30
[   10.718770] Node 14 Normal per-cpu:
[   10.722620] CPU    0: hi:  186, btch:  31 usd:  30
[   10.727897] Node 15 Normal per-cpu:
[   10.731748] CPU    0: hi:  186, btch:  31 usd:  30
[   10.737031] active_anon:0 inactive_anon:0 isolated_anon:0
[   10.737031]  active_file:0 inactive_file:0 isolated_file:0
[   10.737031]  unevictable:0 dirty:0 writeback:0 unstable:0
[   10.737031]  free:0 slab_reclaimable:1 slab_unreclaimable:2838
[   10.737031]  mapped:0 shmem:0 pagetables:0 bounce:0
[   10.737031]  free_cma:0
[   10.769371] Node 0 DMA free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   10.811665] lowmem_reserve[]: 0 0 0 0
[   10.815735] Node 0 DMA32 free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1961924kB managed:362348kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:944kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   10.858707] lowmem_reserve[]: 0 0 0 0
[   10.862775] Node 0 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:803209212kB managed:0kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   10.905346] lowmem_reserve[]: 0 0 0 0
[   10.909414] Node 1 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306364kB managed:1179644kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:684kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   10.952753] lowmem_reserve[]: 0 0 0 0
[   10.956824] Node 2 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.000174] lowmem_reserve[]: 0 0 0 0
[   11.004244] Node 3 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:684kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.047587] lowmem_reserve[]: 0 0 0 0
[   11.051659] Node 4 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.095002] lowmem_reserve[]: 0 0 0 0
[   11.099071] Node 5 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:700kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.142410] lowmem_reserve[]: 0 0 0 0
[   11.146478] Node 6 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:700kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.189813] lowmem_reserve[]: 0 0 0 0
[   11.193882] Node 7 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:704kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.237220] lowmem_reserve[]: 0 0 0 0
[   11.241287] Node 8 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.284632] lowmem_reserve[]: 0 0 0 0
[   11.288701] Node 9 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.332049] lowmem_reserve[]: 0 0 0 0
[   11.336115] Node 10 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.379581] lowmem_reserve[]: 0 0 0 0
[   11.383653] Node 11 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.427101] lowmem_reserve[]: 0 0 0 0
[   11.431170] Node 12 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:696kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.474599] lowmem_reserve[]: 0 0 0 0
[   11.478666] Node 13 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:688kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.522100] lowmem_reserve[]: 0 0 0 0
[   11.526168] Node 14 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.569599] lowmem_reserve[]: 0 0 0 0
[   11.573666] Node 15 Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:805306368kB managed:1048576kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:692kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   11.617104] lowmem_reserve[]: 0 0 0 0
[   11.621173] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.632610] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.644224] Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.655931] Node 1 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.667660] Node 2 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.679369] Node 3 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.691071] Node 4 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.702779] Node 5 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.714486] Node 6 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.726195] Node 7 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.737890] Node 8 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.749597] Node 9 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.761302] Node 10 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.773109] Node 11 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.784909] Node 12 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.796711] Node 13 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.808513] Node 14 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.820312] Node 15 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   11.832118] 0 total pagecache pages
[   11.835969] 0 pages in swap cache
[   11.839621] Swap cache stats: add 0, delete 0, find 0/0
[   11.845373] Free swap  = 0kB
[   11.848544] Total swap = 0kB
[   11.851720] 3221195660 pages RAM
[   11.855273] 0 pages HighMem/MovableOnly
[   11.859495] 3217136172 pages reserved
[   11.863530] 0 pages hwpoisoned
[   12.888579] Inode-cache hash table entries: 536870912 (order: 20, 4294967296 bytes)
[   14.686660] Mount-cache hash table entries: 33554432 (order: 16, 268435456 bytes)
[   14.725414] Mountpoint-cache hash table entries: 33554432 (order: 16, 268435456 bytes)
[   14.974657] Initializing cgroup subsys blkio
[   14.979408] Initializing cgroup subsys devices
[   14.984337] Initializing cgroup subsys freezer
[   14.989279] Initializing cgroup subsys net_cls
[   14.994185] Initializing cgroup subsys perf_event
[   15.000262] CPU: Physical Processor ID: 0
[   15.004682] CPU: Processor Core ID: 0
[   15.009592] mce: CPU supports 32 MCE banks
[   15.014165] CPU0: Thermal monitoring enabled (TM1)
[   15.019487] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[   15.025528] Last level dTLB entries: 4KB 512, 2MB 0, 4MB 0, 1GB 4
[   15.033163] Freeing SMP alternatives memory: 20K (ffffffff81c99000 - ffffffff81c9e000)
[   15.047700] dmar: Host address width 44
[   15.051929] dmar: DRHD base: 0x00000093ff8000 flags: 0x0
[   15.057843] dmar: IOMMU 0: reg_base_addr 93ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.066752] dmar: DRHD base: 0x00000097ff8000 flags: 0x0
[   15.072652] dmar: IOMMU 1: reg_base_addr 97ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.081566] dmar: DRHD base: 0x0000009bff8000 flags: 0x0
[   15.087479] dmar: IOMMU 2: reg_base_addr 9bff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.096393] dmar: DRHD base: 0x0000009fff8000 flags: 0x0
[   15.102297] dmar: IOMMU 3: reg_base_addr 9fff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.111206] dmar: DRHD base: 0x000000a3ff8000 flags: 0x0
[   15.117109] dmar: IOMMU 4: reg_base_addr a3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.126023] dmar: DRHD base: 0x000000a7ff8000 flags: 0x0
[   15.131933] dmar: IOMMU 5: reg_base_addr a7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.140843] dmar: DRHD base: 0x000000abff8000 flags: 0x0
[   15.146749] dmar: IOMMU 6: reg_base_addr abff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.155660] dmar: DRHD base: 0x000000afff8000 flags: 0x0
[   15.161571] dmar: IOMMU 7: reg_base_addr afff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.170480] dmar: DRHD base: 0x000000b3ff8000 flags: 0x0
[   15.176378] dmar: IOMMU 8: reg_base_addr b3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.185292] dmar: DRHD base: 0x000000b7ff8000 flags: 0x0
[   15.191202] dmar: IOMMU 9: reg_base_addr b7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.200111] dmar: DRHD base: 0x000000bbff8000 flags: 0x0
[   15.206011] dmar: IOMMU 10: reg_base_addr bbff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.215019] dmar: DRHD base: 0x000000bfff8000 flags: 0x0
[   15.220927] dmar: IOMMU 11: reg_base_addr bfff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.229932] dmar: DRHD base: 0x000000c3ff8000 flags: 0x0
[   15.235844] dmar: IOMMU 12: reg_base_addr c3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.244854] dmar: DRHD base: 0x000000c7ff8000 flags: 0x0
[   15.250765] dmar: IOMMU 13: reg_base_addr c7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.259770] dmar: DRHD base: 0x000000cbff8000 flags: 0x0
[   15.265677] dmar: IOMMU 14: reg_base_addr cbff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.274681] dmar: DRHD base: 0x000000cfff8000 flags: 0x0
[   15.280590] dmar: IOMMU 15: reg_base_addr cfff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   15.289600] dmar: RMRR base: 0x00000079906000 end: 0x00000079908fff
[   15.296510] dmar: RMRR base: 0x00000079903000 end: 0x00000079905fff
[   15.303415] dmar: RMRR base: 0x00000079900000 end: 0x00000079902fff
[   15.310319] dmar: RMRR base: 0x0000006f3fc000 end: 0x0000006f3fefff
[   15.317235] dmar: RMRR base: 0x0000006d015000 end: 0x0000006d017fff
[   15.324135] dmar: RMRR base: 0x0000006d012000 end: 0x0000006d014fff
[   15.331043] dmar: RMRR base: 0x0000006d00f000 end: 0x0000006d011fff
[   15.337945] dmar: RMRR base: 0x0000006d00c000 end: 0x0000006d00efff
[   15.344848] dmar: ATSR flags: 0x0
[   15.348503] dmar: ATSR flags: 0x0
[   15.352154] dmar: ATSR flags: 0x0
[   15.355805] dmar: ATSR flags: 0x0
[   15.359460] dmar: ATSR flags: 0x0
[   15.363113] dmar: ATSR flags: 0x0
[   15.366765] dmar: ATSR flags: 0x0
[   15.370408] dmar: ATSR flags: 0x0
[   15.374057] dmar: ATSR flags: 0x0
[   15.377706] dmar: ATSR flags: 0x0
[   15.381361] dmar: ATSR flags: 0x0
[   15.385012] dmar: ATSR flags: 0x0
[   15.388663] dmar: ATSR flags: 0x0
[   15.392318] dmar: ATSR flags: 0x0
[   15.395972] dmar: ATSR flags: 0x0
[   15.399621] dmar: ATSR flags: 0x0
[   15.403270] dmar: RHSA base: 0x00000093ff8000 proximity domain: 0x0
[   15.410181] dmar: RHSA base: 0x00000097ff8000 proximity domain: 0x1
[   15.417084] dmar: RHSA base: 0x0000009bff8000 proximity domain: 0x2
[   15.423989] dmar: RHSA base: 0x0000009fff8000 proximity domain: 0x3
[   15.430891] dmar: RHSA base: 0x000000a3ff8000 proximity domain: 0x4
[   15.437792] dmar: RHSA base: 0x000000a7ff8000 proximity domain: 0x5
[   15.444698] dmar: RHSA base: 0x000000abff8000 proximity domain: 0x6
[   15.451602] dmar: RHSA base: 0x000000afff8000 proximity domain: 0x7
[   15.458503] dmar: RHSA base: 0x000000b3ff8000 proximity domain: 0x8
[   15.465407] dmar: RHSA base: 0x000000b7ff8000 proximity domain: 0x9
[   15.472310] dmar: RHSA base: 0x000000bbff8000 proximity domain: 0xa
[   15.479211] dmar: RHSA base: 0x000000bfff8000 proximity domain: 0xb
[   15.486111] dmar: RHSA base: 0x000000c3ff8000 proximity domain: 0xc
[   15.493011] dmar: RHSA base: 0x000000c7ff8000 proximity domain: 0xd
[   15.499913] dmar: RHSA base: 0x000000cbff8000 proximity domain: 0xe
[   15.506815] dmar: RHSA base: 0x000000cfff8000 proximity domain: 0xf
[   15.513749] IOAPIC id 31 under DRHD base  0xcfff8000 IOMMU 15
[   15.520088] IOAPIC id 29 under DRHD base  0xcbff8000 IOMMU 14
[   15.526418] IOAPIC id 30 under DRHD base  0xcbff8000 IOMMU 14
[   15.532750] IOAPIC id 28 under DRHD base  0xc7ff8000 IOMMU 13
[   15.539079] IOAPIC id 26 under DRHD base  0xc3ff8000 IOMMU 12
[   15.545409] IOAPIC id 27 under DRHD base  0xc3ff8000 IOMMU 12
[   15.551736] IOAPIC id 25 under DRHD base  0xbfff8000 IOMMU 11
[   15.558062] IOAPIC id 23 under DRHD base  0xbbff8000 IOMMU 10
[   15.564389] IOAPIC id 24 under DRHD base  0xbbff8000 IOMMU 10
[   15.570730] IOAPIC id 22 under DRHD base  0xb7ff8000 IOMMU 9
[   15.576967] IOAPIC id 20 under DRHD base  0xb3ff8000 IOMMU 8
[   15.583203] IOAPIC id 21 under DRHD base  0xb3ff8000 IOMMU 8
[   15.589435] IOAPIC id 19 under DRHD base  0xafff8000 IOMMU 7
[   15.595668] IOAPIC id 17 under DRHD base  0xabff8000 IOMMU 6
[   15.601903] IOAPIC id 18 under DRHD base  0xabff8000 IOMMU 6
[   15.608136] IOAPIC id 16 under DRHD base  0xa7ff8000 IOMMU 5
[   15.614368] IOAPIC id 14 under DRHD base  0xa3ff8000 IOMMU 4
[   15.620600] IOAPIC id 15 under DRHD base  0xa3ff8000 IOMMU 4
[   15.626832] IOAPIC id 13 under DRHD base  0x9fff8000 IOMMU 3
[   15.633070] IOAPIC id 11 under DRHD base  0x9bff8000 IOMMU 2
[   15.639301] IOAPIC id 12 under DRHD base  0x9bff8000 IOMMU 2
[   15.645532] IOAPIC id 10 under DRHD base  0x97ff8000 IOMMU 1
[   15.651767] IOAPIC id 8 under DRHD base  0x93ff8000 IOMMU 0
[   15.657902] IOAPIC id 9 under DRHD base  0x93ff8000 IOMMU 0
[   15.664039] HPET id 0 under DRHD base 0x93ff8000
[   15.687048] Queued invalidation will be enabled to support x2apic and Intr-remapping.
[   15.695944] Enabled IRQ remapping in x2apic mode
[   15.701040] System requires x2apic physical mode
[   15.716693] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[   15.763052] TSC deadline timer enabled
[   15.763198] smpboot: CPU0: Intel(R) Xeon(R) CPU E7-2890 v2 @ 2.80GHz (fam: 06, model: 3e, stepping: 07)
[   15.774782] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
[   15.786170] ... version:                3
[   15.790580] ... bit width:              48
[   15.795084] ... generic registers:      4
[   15.799491] ... value mask:             0000ffffffffffff
[   15.805336] ... max period:             0000ffffffffffff
[   15.811180] ... fixed-purpose events:   3
[   15.815589] ... event mask:             000000070000000f
[   15.851365] x86: Booting SMP configuration:
[   15.855972] .... node   #0, CPUs:          #1   #2   #3   #4   #5   #6   #7   #8   #9  #10  #11  #12  #13  #14
[   16.112377] .... node   #1, CPUs:    #15  #16  #17  #18  #19  #20  #21  #22  #23  #24  #25  #26  #27  #28  #29
[   16.486971] .... node   #2, CPUs:    #30  #31  #32  #33  #34  #35  #36  #37  #38  #39  #40  #41  #42  #43  #44
[   16.856824] .... node   #3, CPUs:    #45  #46  #47  #48  #49  #50  #51  #52  #53  #54  #55  #56  #57  #58  #59
[   17.226718] .... node   #4, CPUs:    #60  #61  #62  #63  #64  #65  #66  #67  #68  #69  #70  #71  #72  #73  #74
[   17.597408] .... node   #5, CPUs:    #75  #76  #77  #78  #79  #80  #81  #82  #83  #84  #85  #86  #87  #88  #89
[   17.968076] .... node   #6, CPUs:    #90  #91  #92  #93  #94  #95  #96  #97  #98  #99 #100 #101 #102 #103 #104
[   18.339749] .... node   #7, CPUs:   #105 #106 #107 #108 #109 #110 #111 #112 #113 #114 #115 #116 #117 #118 #119
[   18.711346] .... node   #8, CPUs:   #120 #121 #122 #123 #124 #125 #126 #127 #128 #129 #130 #131 #132 #133 #134
[   19.082522] .... node   #9, CPUs:   #135 #136 #137 #138 #139 #140 #141 #142 #143 #144 #145 #146 #147 #148 #149
[   19.453541] .... node  #10, CPUs:   #150 #151 #152 #153 #154 #155 #156 #157 #158 #159 #160 #161 #162 #163 #164
[   19.824519] .... node  #11, CPUs:   #165 #166 #167 #168 #169 #170 #171 #172 #173 #174 #175 #176 #177 #178 #179
[   20.194962] .... node  #12, CPUs:   #180 #181 #182 #183 #184 #185 #186 #187 #188 #189 #190 #191 #192 #193 #194
[   20.565836] .... node  #13, CPUs:   #195 #196 #197 #198 #199 #200 #201 #202 #203 #204 #205 #206 #207 #208 #209
[   20.936085] .... node  #14, CPUs:   #210 #211 #212 #213 #214 #215 #216 #217 #218 #219 #220 #221 #222 #223 #224
[   21.306359] .... node  #15, CPUs:   #225 #226 #227 #228 #229 #230 #231 #232 #233 #234 #235 #236 #237 #238 #239
[   21.677568] .... node   #0, CPUs:   #240 #241 #242 #243 #244 #245 #246 #247 #248 #249 #250 #251 #252 #253 #254
[   21.958498] .... node   #1, CPUs:   #255 #256 #257 #258 #259 #260 #261 #262 #263 #264 #265 #266 #267 #268 #269
[   22.242977] .... node   #2, CPUs:   #270 #271 #272 #273 #274 #275 #276 #277 #278 #279 #280 #281 #282 #283 #284
[   22.527220] .... node   #3, CPUs:   #285 #286 #287 #288 #289 #290 #291 #292 #293 #294 #295 #296 #297 #298 #299
[   22.810068] .... node   #4, CPUs:   #300 #301 #302 #303 #304 #305 #306 #307 #308 #309 #310 #311 #312 #313 #314
[   23.093580] .... node   #5, CPUs:   #315 #316 #317 #318 #319 #320 #321 #322 #323 #324 #325 #326 #327 #328 #329
[   23.377767] .... node   #6, CPUs:   #330 #331 #332 #333 #334 #335 #336 #337 #338 #339 #340 #341 #342 #343 #344
[   23.661100] .... node   #7, CPUs:   #345 #346 #347 #348 #349 #350 #351 #352 #353 #354 #355 #356 #357 #358 #359
[   23.947770] .... node   #8, CPUs:   #360 #361 #362 #363 #364 #365 #366 #367 #368 #369 #370 #371 #372 #373 #374
[   24.231541] .... node   #9, CPUs:   #375 #376 #377 #378 #379 #380 #381 #382 #383 #384 #385 #386 #387 #388 #389
[   24.517184] .... node  #10, CPUs:   #390 #391 #392 #393 #394 #395 #396 #397 #398 #399 #400 #401 #402 #403 #404
[   24.801586] .... node  #11, CPUs:   #405 #406 #407 #408 #409 #410 #411 #412 #413 #414 #415 #416 #417 #418 #419
[   25.086203] .... node  #12, CPUs:   #420 #421 #422 #423 #424 #425 #426 #427 #428 #429 #430 #431 #432 #433 #434
[   25.370832] .... node  #13, CPUs:   #435 #436 #437 #438 #439 #440 #441 #442 #443 #444 #445 #446 #447 #448 #449
[   25.656063] .... node  #14, CPUs:   #450 #451 #452 #453 #454 #455 #456 #457 #458 #459 #460 #461 #462 #463 #464
[   25.941621] .... node  #15, CPUs:   #465 #466 #467 #468 #469 #470 #471 #472 #473 #474 #475 #476 #477 #478 #479
[   26.225867] x86: Booted up 16 nodes, 480 CPUs
[   26.230947] smpboot: Total of 480 processors activated (2684895.42 BogoMIPS)
[   29.199692] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[   29.280989] devtmpfs: initialized
[   29.285264] Using 2GB memory block size for large-memory system
[   29.634005] PM: Registering ACPI NVS region [mem 0x799ff000-0x7bdfefff] (37748736 bytes)
[   29.646850] PM: Registering ACPI NVS region [mem 0x100000000-0x100000fff] (4096 bytes)
[   29.655571] PM: Registering ACPI NVS region [mem 0xe000000000-0xe000000fff] (4096 bytes)
[   29.685659] RTC time:  0:35:33, date: 04/15/15
[   29.696370] NET: Registered protocol family 16
[   29.717300] cpuidle: using governor ladder
[   29.737919] cpuidle: using governor menu
[   29.742624] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[   29.750958] ACPI: bus type PCI registered
[   29.759637] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
[   29.769885] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[   29.778085] PCI: Using configuration type 1 for base access
[   57.319453] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [swapper/0:1]
[   57.327502] Modules linked in:
[   57.330877] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #1
[   57.340255] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[   57.350502] task: ffff89a02b3f4010 ti: ffff89a02b3f8000 task.ti: ffff89a02b3f8000
[   57.358734] RIP: 0010:[<ffffffff813cf7b2>]  [<ffffffff813cf7b2>] register_mem_sect_under_node+0x72/0xd0
[   57.369089] RSP: 0000:ffff89a02b3fbd38  EFLAGS: 00000246
[   57.374934] RAX: ffffea0000000000 RBX: ffff89a02b3fbcf8 RCX: 000000006193c507
[   57.382783] RDX: ffffea15585319a8 RSI: 0000000000000007 RDI: ffff92a02c630800
[   57.390634] RBP: ffff89a02b3fbd48 R08: 000000006197ffff R09: ffff8a6029f10db8
[   57.398483] R10: ffff93602c6ef748 R11: dead000000200200 R12: ffffffff8150c1fd
[   57.406336] R13: ffff89a02b3fbcc8 R14: 0000000000000010 R15: ffffffff8150c06c
[   57.414188] FS:  0000000000000000(0000) GS:ffff88c07fa20000(0000) knlGS:0000000000000000
[   57.423090] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   57.429408] CR2: 0000000000000000 CR3: 0000000001a0e000 CR4: 00000000001406e0
[   57.437259] Stack:
[   57.439467]  0000000061900000 ffff92a02c630800 ffff89a02b3fbd88 ffffffff813cf8b3
[   57.447639]  ffff89a02b3fbd68 0000000000000007 00000000000001e0 0000000000000007
[   57.455810]  000000000000edc0 ffffffff81af6940 ffff89a02b3fbdc8 ffffffff813cfadf
[   57.463985] Call Trace:
[   57.466678]  [<ffffffff813cf8b3>] link_mem_sections+0xa3/0xe0
[   57.473000]  [<ffffffff813cfadf>] register_one_node+0xef/0x140
[   57.479422]  [<ffffffff81b1c753>] ? enable_cpu0_hotplug+0x15/0x15
[   57.486125]  [<ffffffff81b1c78f>] topology_init+0x3c/0xa1
[   57.492069]  [<ffffffff81000288>] do_one_initcall+0xb8/0x1d0
[   57.498293]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   57.505286]  [<ffffffff81b15a21>] do_basic_setup+0xaf/0xd5
[   57.511320]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   57.518317]  [<ffffffff81b347d4>] ? sched_init_smp+0x140/0x147
[   57.524734]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
[   57.531535]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   57.537281]  [<ffffffff8150cf09>] kernel_init+0x9/0xf0
[   57.542944]  [<ffffffff815196c8>] ret_from_fork+0x58/0x90
[   57.548886]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   57.554635] Code: 48 c1 e0 12 48 29 c2 48 b8 00 00 00 00 00 ea ff ff 48 8d 54 02 20 0f 1f 00 48 83 3a 00 74 0c 48 8b 42 e0 48 c1 e8 36 39 c6 74 1e <48> 83 c1 01 48 83 c2 38 49 39 c8 73 e1 31 c0 5b 41 5c c9 c3 66 
[   85.409263] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [swapper/0:1]
[   85.417311] Modules linked in:
[   85.420687] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G             L  4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #1
[   85.431407] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[   85.441651] task: ffff89a02b3f4010 ti: ffff89a02b3f8000 task.ti: ffff89a02b3f8000
[   85.449884] RIP: 0010:[<ffffffff813cf7a4>]  [<ffffffff813cf7a4>] register_mem_sect_under_node+0x64/0xd0
[   85.460235] RSP: 0000:ffff89a02b3fbd38  EFLAGS: 00000246
[   85.466077] RAX: ffffea0000000000 RBX: ffff89a02b3fbcf8 RCX: 00000000b67c072e
[   85.473930] RDX: ffffea27eb219230 RSI: 000000000000000f RDI: ffff93602c682800
[   85.481780] RBP: ffff89a02b3fbd48 R08: 00000000b67fffff R09: ffff8fa02c721e50
[   85.489633] R10: ffff8a6028dfc658 R11: dead000000200200 R12: ffffffff8150c1fd
[   85.497485] R13: ffff89a02b3fbcc8 R14: ffff90602c75c0a0 R15: ffff89a02b3fbca8
[   85.505336] FS:  0000000000000000(0000) GS:ffff88c07fa20000(0000) knlGS:0000000000000000
[   85.514236] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   85.520554] CR2: 0000000000000000 CR3: 0000000001a0e000 CR4: 00000000001406e0
[   85.528410] Stack:
[   85.530622]  00000000b6780000 ffff93602c682800 ffff89a02b3fbd88 ffffffff813cf8b3
[   85.538794]  ffff89a02b3fbd68 000000000000000f 00000000000001e0 000000000000000f
[   85.546970]  000000000000edc0 ffffffff81af6940 ffff89a02b3fbdc8 ffffffff813cfadf
[   85.555145] Call Trace:
[   85.557838]  [<ffffffff813cf8b3>] link_mem_sections+0xa3/0xe0
[   85.564158]  [<ffffffff813cfadf>] register_one_node+0xef/0x140
[   85.570579]  [<ffffffff81b1c753>] ? enable_cpu0_hotplug+0x15/0x15
[   85.577282]  [<ffffffff81b1c78f>] topology_init+0x3c/0xa1
[   85.583226]  [<ffffffff81000288>] do_one_initcall+0xb8/0x1d0
[   85.589451]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   85.596440]  [<ffffffff81b15a21>] do_basic_setup+0xaf/0xd5
[   85.602472]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   85.609469]  [<ffffffff81b347d4>] ? sched_init_smp+0x140/0x147
[   85.615884]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
[   85.622686]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   85.628435]  [<ffffffff8150cf09>] kernel_init+0x9/0xf0
[   85.634091]  [<ffffffff815196c8>] ret_from_fork+0x58/0x90
[   85.640031]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   85.645775] Code: e1 0f 4c 39 c1 77 3f 48 89 d0 48 c1 e2 15 48 c1 e0 12 48 29 c2 48 b8 00 00 00 00 00 ea ff ff 48 8d 54 02 20 0f 1f 00 48 83 3a 00 <74> 0c 48 8b 42 e0 48 c1 e8 36 39 c6 74 1e 48 83 c1 01 48 83 c2 
[   89.533681] ACPI: Added _OSI(Module Device)
[   89.538300] ACPI: Added _OSI(Processor Device)
[   89.543195] ACPI: Added _OSI(3.0 _SCP Extensions)
[   89.548376] ACPI: Added _OSI(Processor Aggregator Device)
[   89.984747] ACPI: Interpreter enabled
[   89.988791] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150204/hwxface-580)
[   89.998963] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150204/hwxface-580)
[   90.009138] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20150204/hwxface-580)
[   90.019316] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20150204/hwxface-580)
[   90.029504] ACPI: (supports S0 S5)
[   90.033249] ACPI: Using IOAPIC for interrupt routing
[   90.039151] HEST: Table parsing has been initialized.
[   90.044711] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[   90.233580] ACPI: PCI Root Bridge [IO00] (domain 0000 [bus 00-0f])
[   90.240388] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.249533] acpi PNP0A08:00: PCIe AER handled by firmware
[   90.255712] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.264297] PCI host bridge to bus 0000:00
[   90.268810] pci_bus 0000:00: root bus resource [bus 00-0f]
[   90.274847] pci_bus 0000:00: root bus resource [io  0x1000-0x3fff window]
[   90.282321] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[   90.289801] pci_bus 0000:00: root bus resource [mem 0x90000000-0x93efffff window]
[   90.298038] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[   90.306280] pci_bus 0000:00: root bus resource [mem 0xfed00000-0xfedfffff window]
[   90.314521] pci_bus 0000:00: root bus resource [mem 0xfc000000000-0xfc07fffffff window]
[   90.323338] pci_bus 0000:00: root bus resource [mem 0xfe000000000-0xfe07fffffff window]
[   90.332176] pci 0000:00:00.0: [8086:0e00] type 00 class 0x060000
[   90.332262] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[   90.332465] pci 0000:00:02.0: [8086:0e04] type 01 class 0x060400
[   90.332567] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[   90.332762] pci 0000:00:02.2: [8086:0e06] type 01 class 0x060400
[   90.332859] pci 0000:00:02.2: PME# supported from D0 D3hot D3cold
[   90.333060] pci 0000:00:03.0: [8086:0e08] type 01 class 0x060400
[   90.333159] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[   90.333355] pci 0000:00:04.0: [8086:0e20] type 00 class 0x088000
[   90.333377] pci 0000:00:04.0: reg 0x10: [mem 0xfc07ff1c000-0xfc07ff1ffff 64bit]
[   90.333601] pci 0000:00:04.1: [8086:0e21] type 00 class 0x088000
[   90.333620] pci 0000:00:04.1: reg 0x10: [mem 0xfc07ff18000-0xfc07ff1bfff 64bit]
[   90.333841] pci 0000:00:04.2: [8086:0e22] type 00 class 0x088000
[   90.333861] pci 0000:00:04.2: reg 0x10: [mem 0xfc07ff14000-0xfc07ff17fff 64bit]
[   90.334082] pci 0000:00:04.3: [8086:0e23] type 00 class 0x088000
[   90.334099] pci 0000:00:04.3: reg 0x10: [mem 0xfc07ff10000-0xfc07ff13fff 64bit]
[   90.334323] pci 0000:00:04.4: [8086:0e24] type 00 class 0x088000
[   90.334340] pci 0000:00:04.4: reg 0x10: [mem 0xfc07ff0c000-0xfc07ff0ffff 64bit]
[   90.334555] pci 0000:00:04.5: [8086:0e25] type 00 class 0x088000
[   90.334573] pci 0000:00:04.5: reg 0x10: [mem 0xfc07ff08000-0xfc07ff0bfff 64bit]
[   90.334796] pci 0000:00:04.6: [8086:0e26] type 00 class 0x088000
[   90.334815] pci 0000:00:04.6: reg 0x10: [mem 0xfc07ff04000-0xfc07ff07fff 64bit]
[   90.335049] pci 0000:00:04.7: [8086:0e27] type 00 class 0x088000
[   90.335067] pci 0000:00:04.7: reg 0x10: [mem 0xfc07ff00000-0xfc07ff03fff 64bit]
[   90.335293] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[   90.335408] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[   90.335596] pci 0000:00:1c.0: [8086:1d1e] type 01 class 0x060400
[   90.335694] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[   90.335888] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[   90.335914] pci 0000:00:1d.0: reg 0x10: [mem 0x90700000-0x907003ff]
[   90.336020] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[   90.336219] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[   90.336600] pci 0000:01:00.0: [8086:10f8] type 00 class 0x020000
[   90.336612] pci 0000:01:00.0: reg 0x10: [mem 0x90500000-0x905fffff]
[   90.336627] pci 0000:01:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.336637] pci 0000:01:00.0: reg 0x1c: [mem 0x90604000-0x90607fff]
[   90.336656] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0007ffff pref]
[   90.336706] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[   90.336740] pci 0000:01:00.0: reg 0x184: [mem 0xfc07fa00000-0xfc07fa03fff 64bit pref]
[   90.336753] pci 0000:01:00.0: reg 0x190: [mem 0xfc07f900000-0xfc07f903fff 64bit pref]
[   90.336949] pci 0000:01:00.1: [8086:10f8] type 00 class 0x020000
[   90.336963] pci 0000:01:00.1: reg 0x10: [mem 0x90400000-0x904fffff]
[   90.336976] pci 0000:01:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.336986] pci 0000:01:00.1: reg 0x1c: [mem 0x90600000-0x90603fff]
[   90.337005] pci 0000:01:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.337053] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[   90.337084] pci 0000:01:00.1: reg 0x184: [mem 0xfc07f800000-0xfc07f803fff 64bit pref]
[   90.337098] pci 0000:01:00.1: reg 0x190: [mem 0xfc07f700000-0xfc07f703fff 64bit pref]
[   90.344250] pci 0000:00:02.0: PCI bridge to [bus 01-02]
[   90.350011] pci 0000:00:02.0:   bridge window [mem 0x90400000-0x906fffff]
[   90.350017] pci 0000:00:02.0:   bridge window [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   90.350162] pci 0000:03:00.0: [8086:10f8] type 00 class 0x020000
[   90.350174] pci 0000:03:00.0: reg 0x10: [mem 0x90200000-0x902fffff]
[   90.350189] pci 0000:03:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.350197] pci 0000:03:00.0: reg 0x1c: [mem 0x90304000-0x90307fff]
[   90.350215] pci 0000:03:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.350270] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[   90.350303] pci 0000:03:00.0: reg 0x184: [mem 0xfc07fe00000-0xfc07fe03fff 64bit pref]
[   90.350316] pci 0000:03:00.0: reg 0x190: [mem 0xfc07fd00000-0xfc07fd03fff 64bit pref]
[   90.350508] pci 0000:03:00.1: [8086:10f8] type 00 class 0x020000
[   90.350519] pci 0000:03:00.1: reg 0x10: [mem 0x90100000-0x901fffff]
[   90.350535] pci 0000:03:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.350542] pci 0000:03:00.1: reg 0x1c: [mem 0x90300000-0x90303fff]
[   90.350565] pci 0000:03:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.350623] pci 0000:03:00.1: PME# supported from D0 D3hot D3cold
[   90.350650] pci 0000:03:00.1: reg 0x184: [mem 0xfc07fc00000-0xfc07fc03fff 64bit pref]
[   90.350666] pci 0000:03:00.1: reg 0x190: [mem 0xfc07fb00000-0xfc07fb03fff 64bit pref]
[   90.358046] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[   90.363823] pci 0000:00:02.2:   bridge window [mem 0x90100000-0x903fffff]
[   90.363829] pci 0000:00:02.2:   bridge window [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   90.363962] pci 0000:00:03.0: PCI bridge to [bus 05]
[   90.369567] pci 0000:00:11.0: PCI bridge to [bus 06]
[   90.375187] pci 0000:07:00.0: [103c:3306] type 00 class 0x088000
[   90.375214] pci 0000:07:00.0: reg 0x10: [io  0x1400-0x14ff]
[   90.375231] pci 0000:07:00.0: reg 0x14: [mem 0x93a8c000-0x93a8c1ff]
[   90.375251] pci 0000:07:00.0: reg 0x18: [io  0x1200-0x12ff]
[   90.375567] pci 0000:07:00.1: [102b:0533] type 00 class 0x030000
[   90.375594] pci 0000:07:00.1: reg 0x10: [mem 0x92000000-0x92ffffff pref]
[   90.375611] pci 0000:07:00.1: reg 0x14: [mem 0x93a88000-0x93a8bfff]
[   90.375629] pci 0000:07:00.1: reg 0x18: [mem 0x93000000-0x937fffff]
[   90.375943] pci 0000:07:00.2: [103c:3307] type 00 class 0x088000
[   90.375971] pci 0000:07:00.2: reg 0x10: [io  0x1000-0x10ff]
[   90.375987] pci 0000:07:00.2: reg 0x14: [mem 0x93a8c400-0x93a8c4ff]
[   90.376003] pci 0000:07:00.2: reg 0x18: [mem 0x93800000-0x938fffff]
[   90.376019] pci 0000:07:00.2: reg 0x1c: [mem 0x93a00000-0x93a7ffff]
[   90.376039] pci 0000:07:00.2: reg 0x20: [mem 0x93a80000-0x93a87fff]
[   90.376058] pci 0000:07:00.2: reg 0x24: [mem 0x93900000-0x939fffff]
[   90.376075] pci 0000:07:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   90.376166] pci 0000:07:00.2: PME# supported from D0 D3hot D3cold
[   90.376358] pci 0000:07:00.4: [103c:3300] type 00 class 0x0c0300
[   90.376444] pci 0000:07:00.4: reg 0x20: [io  0x1500-0x151f]
[   90.387107] pci 0000:00:1c.0: PCI bridge to [bus 07]
[   90.392577] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[   90.392583] pci 0000:00:1c.0:   bridge window [mem 0x92000000-0x93efffff]
[   90.392593] pci 0000:00:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   90.392651] pci_bus 0000:00: on NUMA node 0
[   90.392656] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
[   90.401035] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.410509] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.419952] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.429399] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.438825] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.448266] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.457710] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.467147] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   90.476545] ACPI: PCI Root Bridge [IO01] (domain 0000 [bus 10-1f])
[   90.483353] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.492482] acpi PNP0A08:01: PCIe AER handled by firmware
[   90.498687] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.507263] PCI host bridge to bus 0000:10
[   90.511774] pci_bus 0000:10: root bus resource [bus 10-1f]
[   90.517812] pci_bus 0000:10: root bus resource [io  0x4000-0x7fff window]
[   90.525282] pci_bus 0000:10: root bus resource [mem 0x94000000-0x97ff7fff window]
[   90.533517] pci_bus 0000:10: root bus resource [mem 0xfc400000000-0xfc47fffffff window]
[   90.542348] pci 0000:10:02.0: [8086:0e04] type 01 class 0x060400
[   90.542455] pci 0000:10:02.0: PME# supported from D0 D3hot D3cold
[   90.542645] pci 0000:10:02.2: [8086:0e06] type 01 class 0x060400
[   90.542744] pci 0000:10:02.2: PME# supported from D0 D3hot D3cold
[   90.542946] pci 0000:10:03.0: [8086:0e08] type 01 class 0x060400
[   90.543048] pci 0000:10:03.0: PME# supported from D0 D3hot D3cold
[   90.543231] pci 0000:10:04.0: [8086:0e20] type 00 class 0x088000
[   90.543250] pci 0000:10:04.0: reg 0x10: [mem 0xfc47ff1c000-0xfc47ff1ffff 64bit]
[   90.543473] pci 0000:10:04.1: [8086:0e21] type 00 class 0x088000
[   90.543491] pci 0000:10:04.1: reg 0x10: [mem 0xfc47ff18000-0xfc47ff1bfff 64bit]
[   90.543715] pci 0000:10:04.2: [8086:0e22] type 00 class 0x088000
[   90.543733] pci 0000:10:04.2: reg 0x10: [mem 0xfc47ff14000-0xfc47ff17fff 64bit]
[   90.543944] pci 0000:10:04.3: [8086:0e23] type 00 class 0x088000
[   90.543964] pci 0000:10:04.3: reg 0x10: [mem 0xfc47ff10000-0xfc47ff13fff 64bit]
[   90.544179] pci 0000:10:04.4: [8086:0e24] type 00 class 0x088000
[   90.544197] pci 0000:10:04.4: reg 0x10: [mem 0xfc47ff0c000-0xfc47ff0ffff 64bit]
[   90.544415] pci 0000:10:04.5: [8086:0e25] type 00 class 0x088000
[   90.544435] pci 0000:10:04.5: reg 0x10: [mem 0xfc47ff08000-0xfc47ff0bfff 64bit]
[   90.544645] pci 0000:10:04.6: [8086:0e26] type 00 class 0x088000
[   90.544662] pci 0000:10:04.6: reg 0x10: [mem 0xfc47ff04000-0xfc47ff07fff 64bit]
[   90.544918] pci 0000:10:04.7: [8086:0e27] type 00 class 0x088000
[   90.544936] pci 0000:10:04.7: reg 0x10: [mem 0xfc47ff00000-0xfc47ff03fff 64bit]
[   90.545280] pci 0000:10:02.0: PCI bridge to [bus 11]
[   90.550870] pci 0000:10:02.2: PCI bridge to [bus 12]
[   90.556459] pci 0000:13:00.0: [1077:2031] type 00 class 0x0c0400
[   90.556475] pci 0000:13:00.0: reg 0x10: [mem 0xfc47fe0a000-0xfc47fe0bfff 64bit pref]
[   90.556486] pci 0000:13:00.0: reg 0x18: [mem 0xfc47fe04000-0xfc47fe07fff 64bit pref]
[   90.556500] pci 0000:13:00.0: reg 0x20: [mem 0xfc47fd00000-0xfc47fdfffff 64bit pref]
[   90.556508] pci 0000:13:00.0: reg 0x30: [mem 0x00000000-0x0003ffff pref]
[   90.556559] pci 0000:13:00.0: PME# supported from D3cold
[   90.556737] pci 0000:13:00.1: [1077:2031] type 00 class 0x0c0400
[   90.556753] pci 0000:13:00.1: reg 0x10: [mem 0xfc47fe08000-0xfc47fe09fff 64bit pref]
[   90.556767] pci 0000:13:00.1: reg 0x18: [mem 0xfc47fe00000-0xfc47fe03fff 64bit pref]
[   90.556778] pci 0000:13:00.1: reg 0x20: [mem 0xfc47fc00000-0xfc47fcfffff 64bit pref]
[   90.556785] pci 0000:13:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   90.556833] pci 0000:13:00.1: PME# supported from D3cold
[   90.557032] pci 0000:10:03.0: PCI bridge to [bus 13]
[   90.562507] pci 0000:10:03.0:   bridge window [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   90.562535] pci_bus 0000:10: on NUMA node 1
[   90.562537] acpi PNP0A08:01: Disabling ASPM (FADT indicates it is unsupported)
[   90.579381] ACPI: PCI Root Bridge [IO02] (domain 0000 [bus 20-2f])
[   90.586188] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.595318] acpi PNP0A08:02: PCIe AER handled by firmware
[   90.601487] acpi PNP0A08:02: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.610060] PCI host bridge to bus 0000:20
[   90.614571] pci_bus 0000:20: root bus resource [bus 20-2f]
[   90.620608] pci_bus 0000:20: root bus resource [io  0x8000-0xbfff window]
[   90.628081] pci_bus 0000:20: root bus resource [mem 0x98000000-0x9befffff window]
[   90.636318] pci_bus 0000:20: root bus resource [mem 0xf0800000000-0xf087fffffff window]
[   90.645143] pci 0000:20:00.0: [8086:0e00] type 00 class 0x060000
[   90.645238] pci 0000:20:00.0: PME# supported from D0 D3hot D3cold
[   90.645440] pci 0000:20:02.0: [8086:0e04] type 01 class 0x060400
[   90.645548] pci 0000:20:02.0: PME# supported from D0 D3hot D3cold
[   90.645752] pci 0000:20:02.2: [8086:0e06] type 01 class 0x060400
[   90.645862] pci 0000:20:02.2: PME# supported from D0 D3hot D3cold
[   90.646063] pci 0000:20:03.0: [8086:0e08] type 01 class 0x060400
[   90.646172] pci 0000:20:03.0: PME# supported from D0 D3hot D3cold
[   90.646355] pci 0000:20:04.0: [8086:0e20] type 00 class 0x088000
[   90.646375] pci 0000:20:04.0: reg 0x10: [mem 0xf087ff1c000-0xf087ff1ffff 64bit]
[   90.646604] pci 0000:20:04.1: [8086:0e21] type 00 class 0x088000
[   90.646623] pci 0000:20:04.1: reg 0x10: [mem 0xf087ff18000-0xf087ff1bfff 64bit]
[   90.646860] pci 0000:20:04.2: [8086:0e22] type 00 class 0x088000
[   90.646879] pci 0000:20:04.2: reg 0x10: [mem 0xf087ff14000-0xf087ff17fff 64bit]
[   90.647146] pci 0000:20:04.3: [8086:0e23] type 00 class 0x088000
[   90.647170] pci 0000:20:04.3: reg 0x10: [mem 0xf087ff10000-0xf087ff13fff 64bit]
[   90.647403] pci 0000:20:04.4: [8086:0e24] type 00 class 0x088000
[   90.647422] pci 0000:20:04.4: reg 0x10: [mem 0xf087ff0c000-0xf087ff0ffff 64bit]
[   90.647662] pci 0000:20:04.5: [8086:0e25] type 00 class 0x088000
[   90.647682] pci 0000:20:04.5: reg 0x10: [mem 0xf087ff08000-0xf087ff0bfff 64bit]
[   90.647921] pci 0000:20:04.6: [8086:0e26] type 00 class 0x088000
[   90.647940] pci 0000:20:04.6: reg 0x10: [mem 0xf087ff04000-0xf087ff07fff 64bit]
[   90.648177] pci 0000:20:04.7: [8086:0e27] type 00 class 0x088000
[   90.648198] pci 0000:20:04.7: reg 0x10: [mem 0xf087ff00000-0xf087ff03fff 64bit]
[   90.648440] pci 0000:20:11.0: [8086:1d3e] type 01 class 0x060400
[   90.648570] pci 0000:20:11.0: PME# supported from D0 D3hot D3cold
[   90.648745] pci 0000:20:1c.0: [8086:1d1e] type 01 class 0x060400
[   90.648854] pci 0000:20:1c.0: PME# supported from D0 D3hot D3cold
[   90.649060] pci 0000:20:1d.0: [8086:1d26] type 00 class 0x0c0320
[   90.649085] pci 0000:20:1d.0: reg 0x10: [mem 0x98600000-0x986003ff]
[   90.649203] pci 0000:20:1d.0: PME# supported from D0 D3hot D3cold
[   90.649387] pci 0000:20:1f.0: [8086:1d41] type 00 class 0x060100
[   90.649788] pci 0000:21:00.0: [8086:10f8] type 00 class 0x020000
[   90.649803] pci 0000:21:00.0: reg 0x10: [mem 0x98400000-0x984fffff]
[   90.649817] pci 0000:21:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.649825] pci 0000:21:00.0: reg 0x1c: [mem 0x98504000-0x98507fff]
[   90.649846] pci 0000:21:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.649909] pci 0000:21:00.0: PME# supported from D0 D3hot D3cold
[   90.649951] pci 0000:21:00.0: reg 0x184: [mem 0xf087fa00000-0xf087fa03fff 64bit pref]
[   90.649967] pci 0000:21:00.0: reg 0x190: [mem 0xf087f900000-0xf087f903fff 64bit pref]
[   90.650154] pci 0000:21:00.1: [8086:10f8] type 00 class 0x020000
[   90.650170] pci 0000:21:00.1: reg 0x10: [mem 0x98300000-0x983fffff]
[   90.650184] pci 0000:21:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.650191] pci 0000:21:00.1: reg 0x1c: [mem 0x98500000-0x98503fff]
[   90.650212] pci 0000:21:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.650271] pci 0000:21:00.1: PME# supported from D0 D3hot D3cold
[   90.650301] pci 0000:21:00.1: reg 0x184: [mem 0xf087f800000-0xf087f803fff 64bit pref]
[   90.650319] pci 0000:21:00.1: reg 0x190: [mem 0xf087f700000-0xf087f703fff 64bit pref]
[   90.657176] pci 0000:20:02.0: PCI bridge to [bus 21-22]
[   90.662948] pci 0000:20:02.0:   bridge window [mem 0x98300000-0x985fffff]
[   90.662957] pci 0000:20:02.0:   bridge window [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   90.663098] pci 0000:23:00.0: [8086:10f8] type 00 class 0x020000
[   90.663111] pci 0000:23:00.0: reg 0x10: [mem 0x98100000-0x981fffff]
[   90.663125] pci 0000:23:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.663133] pci 0000:23:00.0: reg 0x1c: [mem 0x98204000-0x98207fff]
[   90.663156] pci 0000:23:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.663216] pci 0000:23:00.0: PME# supported from D0 D3hot D3cold
[   90.663255] pci 0000:23:00.0: reg 0x184: [mem 0xf087fe00000-0xf087fe03fff 64bit pref]
[   90.663271] pci 0000:23:00.0: reg 0x190: [mem 0xf087fd00000-0xf087fd03fff 64bit pref]
[   90.663479] pci 0000:23:00.1: [8086:10f8] type 00 class 0x020000
[   90.663492] pci 0000:23:00.1: reg 0x10: [mem 0x98000000-0x980fffff]
[   90.663506] pci 0000:23:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.663514] pci 0000:23:00.1: reg 0x1c: [mem 0x98200000-0x98203fff]
[   90.663535] pci 0000:23:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.663594] pci 0000:23:00.1: PME# supported from D0 D3hot D3cold
[   90.663630] pci 0000:23:00.1: reg 0x184: [mem 0xf087fc00000-0xf087fc03fff 64bit pref]
[   90.663645] pci 0000:23:00.1: reg 0x190: [mem 0xf087fb00000-0xf087fb03fff 64bit pref]
[   90.670981] pci 0000:20:02.2: PCI bridge to [bus 23-24]
[   90.676758] pci 0000:20:02.2:   bridge window [mem 0x98000000-0x982fffff]
[   90.676770] pci 0000:20:02.2:   bridge window [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   90.676903] pci 0000:20:03.0: PCI bridge to [bus 25]
[   90.682509] pci 0000:20:11.0: PCI bridge to [bus 26]
[   90.688118] pci 0000:27:00.0: [103c:3306] type 00 class 0x088000
[   90.688149] pci 0000:27:00.0: reg 0x10: [io  0x0000-0x00ff]
[   90.688169] pci 0000:27:00.0: reg 0x14: [mem 0x9bd88000-0x9bd881ff]
[   90.688186] pci 0000:27:00.0: reg 0x18: [io  0x0000-0x00ff]
[   90.688515] pci 0000:27:00.2: [103c:3307] type 00 class 0x088000
[   90.688544] pci 0000:27:00.2: reg 0x10: [io  0x0000-0x00ff]
[   90.688561] pci 0000:27:00.2: reg 0x14: [mem 0x9bd88400-0x9bd884ff]
[   90.688580] pci 0000:27:00.2: reg 0x18: [mem 0x9bb00000-0x9bbfffff]
[   90.688597] pci 0000:27:00.2: reg 0x1c: [mem 0x9bd00000-0x9bd7ffff]
[   90.688614] pci 0000:27:00.2: reg 0x20: [mem 0x9bd80000-0x9bd87fff]
[   90.688631] pci 0000:27:00.2: reg 0x24: [mem 0x9bc00000-0x9bcfffff]
[   90.688652] pci 0000:27:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   90.688744] pci 0000:27:00.2: PME# supported from D0 D3hot D3cold
[   90.700021] pci 0000:20:1c.0: PCI bridge to [bus 27]
[   90.705509] pci 0000:20:1c.0:   bridge window [mem 0x9bb00000-0x9befffff]
[   90.705516] pci 0000:20:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   90.705572] pci_bus 0000:20: on NUMA node 2
[   90.705574] acpi PNP0A08:02: Disabling ASPM (FADT indicates it is unsupported)
[   90.713718] ACPI: PCI Root Bridge [IO03] (domain 0000 [bus 30-3f])
[   90.720522] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.729654] acpi PNP0A08:03: PCIe AER handled by firmware
[   90.735831] acpi PNP0A08:03: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.744411] PCI host bridge to bus 0000:30
[   90.748919] pci_bus 0000:30: root bus resource [bus 30-3f]
[   90.754955] pci_bus 0000:30: root bus resource [io  0xc000-0xffff window]
[   90.762430] pci_bus 0000:30: root bus resource [mem 0x9c000000-0x9fff7fff window]
[   90.770667] pci_bus 0000:30: root bus resource [mem 0xf0c00000000-0xf0c7fffffff window]
[   90.779504] pci 0000:30:02.0: [8086:0e04] type 01 class 0x060400
[   90.779613] pci 0000:30:02.0: PME# supported from D0 D3hot D3cold
[   90.779838] pci 0000:30:02.2: [8086:0e06] type 01 class 0x060400
[   90.779953] pci 0000:30:02.2: PME# supported from D0 D3hot D3cold
[   90.780167] pci 0000:30:03.0: [8086:0e08] type 01 class 0x060400
[   90.780277] pci 0000:30:03.0: PME# supported from D0 D3hot D3cold
[   90.780484] pci 0000:30:04.0: [8086:0e20] type 00 class 0x088000
[   90.780507] pci 0000:30:04.0: reg 0x10: [mem 0xf0c7ff1c000-0xf0c7ff1ffff 64bit]
[   90.780760] pci 0000:30:04.1: [8086:0e21] type 00 class 0x088000
[   90.780780] pci 0000:30:04.1: reg 0x10: [mem 0xf0c7ff18000-0xf0c7ff1bfff 64bit]
[   90.781000] pci 0000:30:04.2: [8086:0e22] type 00 class 0x088000
[   90.781020] pci 0000:30:04.2: reg 0x10: [mem 0xf0c7ff14000-0xf0c7ff17fff 64bit]
[   90.781270] pci 0000:30:04.3: [8086:0e23] type 00 class 0x088000
[   90.781292] pci 0000:30:04.3: reg 0x10: [mem 0xf0c7ff10000-0xf0c7ff13fff 64bit]
[   90.781522] pci 0000:30:04.4: [8086:0e24] type 00 class 0x088000
[   90.781541] pci 0000:30:04.4: reg 0x10: [mem 0xf0c7ff0c000-0xf0c7ff0ffff 64bit]
[   90.781775] pci 0000:30:04.5: [8086:0e25] type 00 class 0x088000
[   90.781795] pci 0000:30:04.5: reg 0x10: [mem 0xf0c7ff08000-0xf0c7ff0bfff 64bit]
[   90.782026] pci 0000:30:04.6: [8086:0e26] type 00 class 0x088000
[   90.782045] pci 0000:30:04.6: reg 0x10: [mem 0xf0c7ff04000-0xf0c7ff07fff 64bit]
[   90.782282] pci 0000:30:04.7: [8086:0e27] type 00 class 0x088000
[   90.782304] pci 0000:30:04.7: reg 0x10: [mem 0xf0c7ff00000-0xf0c7ff03fff 64bit]
[   90.782635] pci 0000:30:02.0: PCI bridge to [bus 31]
[   90.788227] pci 0000:30:02.2: PCI bridge to [bus 32]
[   90.793822] pci 0000:33:00.0: [1077:2031] type 00 class 0x0c0400
[   90.793839] pci 0000:33:00.0: reg 0x10: [mem 0xf0c7fe0a000-0xf0c7fe0bfff 64bit pref]
[   90.793854] pci 0000:33:00.0: reg 0x18: [mem 0xf0c7fe04000-0xf0c7fe07fff 64bit pref]
[   90.793866] pci 0000:33:00.0: reg 0x20: [mem 0xf0c7fd00000-0xf0c7fdfffff 64bit pref]
[   90.793874] pci 0000:33:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   90.793933] pci 0000:33:00.0: PME# supported from D3cold
[   90.794099] pci 0000:33:00.1: [1077:2031] type 00 class 0x0c0400
[   90.794116] pci 0000:33:00.1: reg 0x10: [mem 0xf0c7fe08000-0xf0c7fe09fff 64bit pref]
[   90.794128] pci 0000:33:00.1: reg 0x18: [mem 0xf0c7fe00000-0xf0c7fe03fff 64bit pref]
[   90.794142] pci 0000:33:00.1: reg 0x20: [mem 0xf0c7fc00000-0xf0c7fcfffff 64bit pref]
[   90.794151] pci 0000:33:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   90.794206] pci 0000:33:00.1: PME# supported from D3cold
[   90.794412] pci 0000:30:03.0: PCI bridge to [bus 33]
[   90.799883] pci 0000:30:03.0:   bridge window [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   90.799916] pci_bus 0000:30: on NUMA node 3
[   90.799918] acpi PNP0A08:03: Disabling ASPM (FADT indicates it is unsupported)
[   90.817361] ACPI: PCI Root Bridge [IO04] (domain 0000 [bus 40-4f])
[   90.824164] acpi PNP0A08:04: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.833294] acpi PNP0A08:04: PCIe AER handled by firmware
[   90.839484] acpi PNP0A08:04: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.848049] PCI host bridge to bus 0000:40
[   90.852557] pci_bus 0000:40: root bus resource [bus 40-4f]
[   90.858592] pci_bus 0000:40: root bus resource [mem 0xa0000000-0xa3efffff window]
[   90.866826] pci_bus 0000:40: root bus resource [mem 0xf1000000000-0xf107fffffff window]
[   90.875658] pci 0000:40:00.0: [8086:0e00] type 00 class 0x060000
[   90.875758] pci 0000:40:00.0: PME# supported from D0 D3hot D3cold
[   90.875942] pci 0000:40:02.0: [8086:0e04] type 01 class 0x060400
[   90.876050] pci 0000:40:02.0: PME# supported from D0 D3hot D3cold
[   90.876252] pci 0000:40:02.2: [8086:0e06] type 01 class 0x060400
[   90.876358] pci 0000:40:02.2: PME# supported from D0 D3hot D3cold
[   90.876579] pci 0000:40:03.0: [8086:0e08] type 01 class 0x060400
[   90.876692] pci 0000:40:03.0: PME# supported from D0 D3hot D3cold
[   90.876879] pci 0000:40:04.0: [8086:0e20] type 00 class 0x088000
[   90.876903] pci 0000:40:04.0: reg 0x10: [mem 0xf107ff1c000-0xf107ff1ffff 64bit]
[   90.877121] pci 0000:40:04.1: [8086:0e21] type 00 class 0x088000
[   90.877144] pci 0000:40:04.1: reg 0x10: [mem 0xf107ff18000-0xf107ff1bfff 64bit]
[   90.877395] pci 0000:40:04.2: [8086:0e22] type 00 class 0x088000
[   90.877416] pci 0000:40:04.2: reg 0x10: [mem 0xf107ff14000-0xf107ff17fff 64bit]
[   90.877669] pci 0000:40:04.3: [8086:0e23] type 00 class 0x088000
[   90.877688] pci 0000:40:04.3: reg 0x10: [mem 0xf107ff10000-0xf107ff13fff 64bit]
[   90.877923] pci 0000:40:04.4: [8086:0e24] type 00 class 0x088000
[   90.877943] pci 0000:40:04.4: reg 0x10: [mem 0xf107ff0c000-0xf107ff0ffff 64bit]
[   90.878196] pci 0000:40:04.5: [8086:0e25] type 00 class 0x088000
[   90.878215] pci 0000:40:04.5: reg 0x10: [mem 0xf107ff08000-0xf107ff0bfff 64bit]
[   90.878441] pci 0000:40:04.6: [8086:0e26] type 00 class 0x088000
[   90.878460] pci 0000:40:04.6: reg 0x10: [mem 0xf107ff04000-0xf107ff07fff 64bit]
[   90.878687] pci 0000:40:04.7: [8086:0e27] type 00 class 0x088000
[   90.878708] pci 0000:40:04.7: reg 0x10: [mem 0xf107ff00000-0xf107ff03fff 64bit]
[   90.878938] pci 0000:40:11.0: [8086:1d3e] type 01 class 0x060400
[   90.879059] pci 0000:40:11.0: PME# supported from D0 D3hot D3cold
[   90.879250] pci 0000:40:1c.0: [8086:1d1e] type 01 class 0x060400
[   90.879360] pci 0000:40:1c.0: PME# supported from D0 D3hot D3cold
[   90.879564] pci 0000:40:1d.0: [8086:1d26] type 00 class 0x0c0320
[   90.879590] pci 0000:40:1d.0: reg 0x10: [mem 0xa0600000-0xa06003ff]
[   90.879708] pci 0000:40:1d.0: PME# supported from D0 D3hot D3cold
[   90.879885] pci 0000:40:1f.0: [8086:1d41] type 00 class 0x060100
[   90.880262] pci 0000:41:00.0: [8086:10f8] type 00 class 0x020000
[   90.880279] pci 0000:41:00.0: reg 0x10: [mem 0xa0400000-0xa04fffff]
[   90.880293] pci 0000:41:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.880302] pci 0000:41:00.0: reg 0x1c: [mem 0xa0504000-0xa0507fff]
[   90.880322] pci 0000:41:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.880383] pci 0000:41:00.0: PME# supported from D0 D3hot D3cold
[   90.880424] pci 0000:41:00.0: reg 0x184: [mem 0xf107fa00000-0xf107fa03fff 64bit pref]
[   90.880439] pci 0000:41:00.0: reg 0x190: [mem 0xf107f900000-0xf107f903fff 64bit pref]
[   90.880626] pci 0000:41:00.1: [8086:10f8] type 00 class 0x020000
[   90.880642] pci 0000:41:00.1: reg 0x10: [mem 0xa0300000-0xa03fffff]
[   90.880660] pci 0000:41:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.880668] pci 0000:41:00.1: reg 0x1c: [mem 0xa0500000-0xa0503fff]
[   90.880688] pci 0000:41:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.880744] pci 0000:41:00.1: PME# supported from D0 D3hot D3cold
[   90.880780] pci 0000:41:00.1: reg 0x184: [mem 0xf107f800000-0xf107f803fff 64bit pref]
[   90.880795] pci 0000:41:00.1: reg 0x190: [mem 0xf107f700000-0xf107f703fff 64bit pref]
[   90.891701] pci 0000:40:02.0: PCI bridge to [bus 41-42]
[   90.897476] pci 0000:40:02.0:   bridge window [mem 0xa0300000-0xa05fffff]
[   90.897485] pci 0000:40:02.0:   bridge window [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   90.897632] pci 0000:43:00.0: [8086:10f8] type 00 class 0x020000
[   90.897645] pci 0000:43:00.0: reg 0x10: [mem 0xa0100000-0xa01fffff]
[   90.897659] pci 0000:43:00.0: reg 0x18: [io  0x0000-0x001f]
[   90.897669] pci 0000:43:00.0: reg 0x1c: [mem 0xa0204000-0xa0207fff]
[   90.897690] pci 0000:43:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.897751] pci 0000:43:00.0: PME# supported from D0 D3hot D3cold
[   90.897787] pci 0000:43:00.0: reg 0x184: [mem 0xf107fe00000-0xf107fe03fff 64bit pref]
[   90.897805] pci 0000:43:00.0: reg 0x190: [mem 0xf107fd00000-0xf107fd03fff 64bit pref]
[   90.898005] pci 0000:43:00.1: [8086:10f8] type 00 class 0x020000
[   90.898021] pci 0000:43:00.1: reg 0x10: [mem 0xa0000000-0xa00fffff]
[   90.898035] pci 0000:43:00.1: reg 0x18: [io  0x0000-0x001f]
[   90.898042] pci 0000:43:00.1: reg 0x1c: [mem 0xa0200000-0xa0203fff]
[   90.898062] pci 0000:43:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   90.898119] pci 0000:43:00.1: PME# supported from D0 D3hot D3cold
[   90.898154] pci 0000:43:00.1: reg 0x184: [mem 0xf107fc00000-0xf107fc03fff 64bit pref]
[   90.898170] pci 0000:43:00.1: reg 0x190: [mem 0xf107fb00000-0xf107fb03fff 64bit pref]
[   90.905515] pci 0000:40:02.2: PCI bridge to [bus 43-44]
[   90.911293] pci 0000:40:02.2:   bridge window [mem 0xa0000000-0xa02fffff]
[   90.911302] pci 0000:40:02.2:   bridge window [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   90.911433] pci 0000:40:03.0: PCI bridge to [bus 45]
[   90.917036] pci 0000:40:11.0: PCI bridge to [bus 46]
[   90.922655] pci 0000:47:00.0: [103c:3306] type 00 class 0x088000
[   90.922687] pci 0000:47:00.0: reg 0x10: [io  0x0000-0x00ff]
[   90.922703] pci 0000:47:00.0: reg 0x14: [mem 0xa3d88000-0xa3d881ff]
[   90.922720] pci 0000:47:00.0: reg 0x18: [io  0x0000-0x00ff]
[   90.923038] pci 0000:47:00.2: [103c:3307] type 00 class 0x088000
[   90.923066] pci 0000:47:00.2: reg 0x10: [io  0x0000-0x00ff]
[   90.923085] pci 0000:47:00.2: reg 0x14: [mem 0xa3d88400-0xa3d884ff]
[   90.923102] pci 0000:47:00.2: reg 0x18: [mem 0xa3b00000-0xa3bfffff]
[   90.923120] pci 0000:47:00.2: reg 0x1c: [mem 0xa3d00000-0xa3d7ffff]
[   90.923140] pci 0000:47:00.2: reg 0x20: [mem 0xa3d80000-0xa3d87fff]
[   90.923157] pci 0000:47:00.2: reg 0x24: [mem 0xa3c00000-0xa3cfffff]
[   90.923175] pci 0000:47:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   90.923267] pci 0000:47:00.2: PME# supported from D0 D3hot D3cold
[   90.930573] pci 0000:40:1c.0: PCI bridge to [bus 47]
[   90.936041] pci 0000:40:1c.0:   bridge window [mem 0xa3b00000-0xa3efffff]
[   90.936048] pci 0000:40:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   90.936104] pci_bus 0000:40: on NUMA node 4
[   90.936106] acpi PNP0A08:04: Disabling ASPM (FADT indicates it is unsupported)
[   90.944247] ACPI: PCI Root Bridge [IO05] (domain 0000 [bus 50-5f])
[   90.951054] acpi PNP0A08:05: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   90.960179] acpi PNP0A08:05: PCIe AER handled by firmware
[   90.966362] acpi PNP0A08:05: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   90.974916] PCI host bridge to bus 0000:50
[   90.979424] pci_bus 0000:50: root bus resource [bus 50-5f]
[   90.985461] pci_bus 0000:50: root bus resource [mem 0xa4000000-0xa7ff7fff window]
[   90.993704] pci_bus 0000:50: root bus resource [mem 0xf1400000000-0xf147fffffff window]
[   91.002540] pci 0000:50:02.0: [8086:0e04] type 01 class 0x060400
[   91.002649] pci 0000:50:02.0: PME# supported from D0 D3hot D3cold
[   91.002838] pci 0000:50:02.2: [8086:0e06] type 01 class 0x060400
[   91.002946] pci 0000:50:02.2: PME# supported from D0 D3hot D3cold
[   91.003146] pci 0000:50:03.0: [8086:0e08] type 01 class 0x060400
[   91.003255] pci 0000:50:03.0: PME# supported from D0 D3hot D3cold
[   91.003475] pci 0000:50:04.0: [8086:0e20] type 00 class 0x088000
[   91.003498] pci 0000:50:04.0: reg 0x10: [mem 0xf147ff1c000-0xf147ff1ffff 64bit]
[   91.003730] pci 0000:50:04.1: [8086:0e21] type 00 class 0x088000
[   91.003751] pci 0000:50:04.1: reg 0x10: [mem 0xf147ff18000-0xf147ff1bfff 64bit]
[   91.003960] pci 0000:50:04.2: [8086:0e22] type 00 class 0x088000
[   91.003979] pci 0000:50:04.2: reg 0x10: [mem 0xf147ff14000-0xf147ff17fff 64bit]
[   91.004203] pci 0000:50:04.3: [8086:0e23] type 00 class 0x088000
[   91.004226] pci 0000:50:04.3: reg 0x10: [mem 0xf147ff10000-0xf147ff13fff 64bit]
[   91.004446] pci 0000:50:04.4: [8086:0e24] type 00 class 0x088000
[   91.004465] pci 0000:50:04.4: reg 0x10: [mem 0xf147ff0c000-0xf147ff0ffff 64bit]
[   91.004696] pci 0000:50:04.5: [8086:0e25] type 00 class 0x088000
[   91.004715] pci 0000:50:04.5: reg 0x10: [mem 0xf147ff08000-0xf147ff0bfff 64bit]
[   91.004928] pci 0000:50:04.6: [8086:0e26] type 00 class 0x088000
[   91.004948] pci 0000:50:04.6: reg 0x10: [mem 0xf147ff04000-0xf147ff07fff 64bit]
[   91.005159] pci 0000:50:04.7: [8086:0e27] type 00 class 0x088000
[   91.005180] pci 0000:50:04.7: reg 0x10: [mem 0xf147ff00000-0xf147ff03fff 64bit]
[   91.005507] pci 0000:50:02.0: PCI bridge to [bus 51]
[   91.011088] pci 0000:50:02.2: PCI bridge to [bus 52]
[   91.016693] pci 0000:53:00.0: [1077:2031] type 00 class 0x0c0400
[   91.016711] pci 0000:53:00.0: reg 0x10: [mem 0xf147fe0a000-0xf147fe0bfff 64bit pref]
[   91.016723] pci 0000:53:00.0: reg 0x18: [mem 0xf147fe04000-0xf147fe07fff 64bit pref]
[   91.016735] pci 0000:53:00.0: reg 0x20: [mem 0xf147fd00000-0xf147fdfffff 64bit pref]
[   91.016743] pci 0000:53:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.016803] pci 0000:53:00.0: PME# supported from D3cold
[   91.016990] pci 0000:53:00.1: [1077:2031] type 00 class 0x0c0400
[   91.017009] pci 0000:53:00.1: reg 0x10: [mem 0xf147fe08000-0xf147fe09fff 64bit pref]
[   91.017021] pci 0000:53:00.1: reg 0x18: [mem 0xf147fe00000-0xf147fe03fff 64bit pref]
[   91.017033] pci 0000:53:00.1: reg 0x20: [mem 0xf147fc00000-0xf147fcfffff 64bit pref]
[   91.017044] pci 0000:53:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.017100] pci 0000:53:00.1: PME# supported from D3cold
[   91.017294] pci 0000:50:03.0: PCI bridge to [bus 53]
[   91.022764] pci 0000:50:03.0:   bridge window [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   91.022798] pci_bus 0000:50: on NUMA node 5
[   91.022800] acpi PNP0A08:05: Disabling ASPM (FADT indicates it is unsupported)
[   91.040863] ACPI: PCI Root Bridge [IO06] (domain 0000 [bus 60-6f])
[   91.047666] acpi PNP0A08:06: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.056789] acpi PNP0A08:06: PCIe AER handled by firmware
[   91.062984] acpi PNP0A08:06: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.071556] PCI host bridge to bus 0000:60
[   91.076066] pci_bus 0000:60: root bus resource [bus 60-6f]
[   91.082102] pci_bus 0000:60: root bus resource [mem 0xa8000000-0xabefffff window]
[   91.090337] pci_bus 0000:60: root bus resource [mem 0xf1800000000-0xf187fffffff window]
[   91.099167] pci 0000:60:00.0: [8086:0e00] type 00 class 0x060000
[   91.099258] pci 0000:60:00.0: PME# supported from D0 D3hot D3cold
[   91.099464] pci 0000:60:02.0: [8086:0e04] type 01 class 0x060400
[   91.099573] pci 0000:60:02.0: PME# supported from D0 D3hot D3cold
[   91.099758] pci 0000:60:02.2: [8086:0e06] type 01 class 0x060400
[   91.099865] pci 0000:60:02.2: PME# supported from D0 D3hot D3cold
[   91.100061] pci 0000:60:03.0: [8086:0e08] type 01 class 0x060400
[   91.100174] pci 0000:60:03.0: PME# supported from D0 D3hot D3cold
[   91.100363] pci 0000:60:04.0: [8086:0e20] type 00 class 0x088000
[   91.100383] pci 0000:60:04.0: reg 0x10: [mem 0xf187ff1c000-0xf187ff1ffff 64bit]
[   91.100615] pci 0000:60:04.1: [8086:0e21] type 00 class 0x088000
[   91.100636] pci 0000:60:04.1: reg 0x10: [mem 0xf187ff18000-0xf187ff1bfff 64bit]
[   91.100865] pci 0000:60:04.2: [8086:0e22] type 00 class 0x088000
[   91.100885] pci 0000:60:04.2: reg 0x10: [mem 0xf187ff14000-0xf187ff17fff 64bit]
[   91.101119] pci 0000:60:04.3: [8086:0e23] type 00 class 0x088000
[   91.101140] pci 0000:60:04.3: reg 0x10: [mem 0xf187ff10000-0xf187ff13fff 64bit]
[   91.101378] pci 0000:60:04.4: [8086:0e24] type 00 class 0x088000
[   91.101397] pci 0000:60:04.4: reg 0x10: [mem 0xf187ff0c000-0xf187ff0ffff 64bit]
[   91.101631] pci 0000:60:04.5: [8086:0e25] type 00 class 0x088000
[   91.101655] pci 0000:60:04.5: reg 0x10: [mem 0xf187ff08000-0xf187ff0bfff 64bit]
[   91.101891] pci 0000:60:04.6: [8086:0e26] type 00 class 0x088000
[   91.101910] pci 0000:60:04.6: reg 0x10: [mem 0xf187ff04000-0xf187ff07fff 64bit]
[   91.102163] pci 0000:60:04.7: [8086:0e27] type 00 class 0x088000
[   91.102194] pci 0000:60:04.7: reg 0x10: [mem 0xf187ff00000-0xf187ff03fff 64bit]
[   91.102445] pci 0000:60:11.0: [8086:1d3e] type 01 class 0x060400
[   91.102566] pci 0000:60:11.0: PME# supported from D0 D3hot D3cold
[   91.102768] pci 0000:60:1c.0: [8086:1d1e] type 01 class 0x060400
[   91.102878] pci 0000:60:1c.0: PME# supported from D0 D3hot D3cold
[   91.103099] pci 0000:60:1d.0: [8086:1d26] type 00 class 0x0c0320
[   91.103127] pci 0000:60:1d.0: reg 0x10: [mem 0xa8600000-0xa86003ff]
[   91.103245] pci 0000:60:1d.0: PME# supported from D0 D3hot D3cold
[   91.103420] pci 0000:60:1f.0: [8086:1d41] type 00 class 0x060100
[   91.103839] pci 0000:61:00.0: [8086:10f8] type 00 class 0x020000
[   91.103853] pci 0000:61:00.0: reg 0x10: [mem 0xa8400000-0xa84fffff]
[   91.103868] pci 0000:61:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.103876] pci 0000:61:00.0: reg 0x1c: [mem 0xa8504000-0xa8507fff]
[   91.103899] pci 0000:61:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.103956] pci 0000:61:00.0: PME# supported from D0 D3hot D3cold
[   91.104000] pci 0000:61:00.0: reg 0x184: [mem 0xf187fa00000-0xf187fa03fff 64bit pref]
[   91.104016] pci 0000:61:00.0: reg 0x190: [mem 0xf187f900000-0xf187f903fff 64bit pref]
[   91.104212] pci 0000:61:00.1: [8086:10f8] type 00 class 0x020000
[   91.104224] pci 0000:61:00.1: reg 0x10: [mem 0xa8300000-0xa83fffff]
[   91.104238] pci 0000:61:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.104246] pci 0000:61:00.1: reg 0x1c: [mem 0xa8500000-0xa8503fff]
[   91.104266] pci 0000:61:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.104324] pci 0000:61:00.1: PME# supported from D0 D3hot D3cold
[   91.104354] pci 0000:61:00.1: reg 0x184: [mem 0xf187f800000-0xf187f803fff 64bit pref]
[   91.104370] pci 0000:61:00.1: reg 0x190: [mem 0xf187f700000-0xf187f703fff 64bit pref]
[   91.111201] pci 0000:60:02.0: PCI bridge to [bus 61-62]
[   91.116974] pci 0000:60:02.0:   bridge window [mem 0xa8300000-0xa85fffff]
[   91.116983] pci 0000:60:02.0:   bridge window [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   91.117148] pci 0000:63:00.0: [8086:10f8] type 00 class 0x020000
[   91.117161] pci 0000:63:00.0: reg 0x10: [mem 0xa8100000-0xa81fffff]
[   91.117175] pci 0000:63:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.117185] pci 0000:63:00.0: reg 0x1c: [mem 0xa8204000-0xa8207fff]
[   91.117208] pci 0000:63:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.117265] pci 0000:63:00.0: PME# supported from D0 D3hot D3cold
[   91.117305] pci 0000:63:00.0: reg 0x184: [mem 0xf187fe00000-0xf187fe03fff 64bit pref]
[   91.117321] pci 0000:63:00.0: reg 0x190: [mem 0xf187fd00000-0xf187fd03fff 64bit pref]
[   91.117507] pci 0000:63:00.1: [8086:10f8] type 00 class 0x020000
[   91.117520] pci 0000:63:00.1: reg 0x10: [mem 0xa8000000-0xa80fffff]
[   91.117533] pci 0000:63:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.117541] pci 0000:63:00.1: reg 0x1c: [mem 0xa8200000-0xa8203fff]
[   91.117562] pci 0000:63:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.117627] pci 0000:63:00.1: PME# supported from D0 D3hot D3cold
[   91.117667] pci 0000:63:00.1: reg 0x184: [mem 0xf187fc00000-0xf187fc03fff 64bit pref]
[   91.117682] pci 0000:63:00.1: reg 0x190: [mem 0xf187fb00000-0xf187fb03fff 64bit pref]
[   91.129020] pci 0000:60:02.2: PCI bridge to [bus 63-64]
[   91.134797] pci 0000:60:02.2:   bridge window [mem 0xa8000000-0xa82fffff]
[   91.134806] pci 0000:60:02.2:   bridge window [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   91.134946] pci 0000:60:03.0: PCI bridge to [bus 65]
[   91.140542] pci 0000:60:11.0: PCI bridge to [bus 66]
[   91.146173] pci 0000:67:00.0: [103c:3306] type 00 class 0x088000
[   91.146202] pci 0000:67:00.0: reg 0x10: [io  0x0000-0x00ff]
[   91.146219] pci 0000:67:00.0: reg 0x14: [mem 0xabd88000-0xabd881ff]
[   91.146236] pci 0000:67:00.0: reg 0x18: [io  0x0000-0x00ff]
[   91.146573] pci 0000:67:00.2: [103c:3307] type 00 class 0x088000
[   91.146600] pci 0000:67:00.2: reg 0x10: [io  0x0000-0x00ff]
[   91.146620] pci 0000:67:00.2: reg 0x14: [mem 0xabd88400-0xabd884ff]
[   91.146637] pci 0000:67:00.2: reg 0x18: [mem 0xabb00000-0xabbfffff]
[   91.146654] pci 0000:67:00.2: reg 0x1c: [mem 0xabd00000-0xabd7ffff]
[   91.146671] pci 0000:67:00.2: reg 0x20: [mem 0xabd80000-0xabd87fff]
[   91.146690] pci 0000:67:00.2: reg 0x24: [mem 0xabc00000-0xabcfffff]
[   91.146707] pci 0000:67:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   91.146800] pci 0000:67:00.2: PME# supported from D0 D3hot D3cold
[   91.154051] pci 0000:60:1c.0: PCI bridge to [bus 67]
[   91.159535] pci 0000:60:1c.0:   bridge window [mem 0xabb00000-0xabefffff]
[   91.159542] pci 0000:60:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   91.159598] pci_bus 0000:60: on NUMA node 6
[   91.159599] acpi PNP0A08:06: Disabling ASPM (FADT indicates it is unsupported)
[   91.167739] ACPI: PCI Root Bridge [IO07] (domain 0000 [bus 70-7b])
[   91.174551] acpi PNP0A08:07: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.183689] acpi PNP0A08:07: PCIe AER handled by firmware
[   91.189869] acpi PNP0A08:07: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.198428] PCI host bridge to bus 0000:70
[   91.202936] pci_bus 0000:70: root bus resource [bus 70-7b]
[   91.208975] pci_bus 0000:70: root bus resource [mem 0xac000000-0xafff7fff window]
[   91.217214] pci_bus 0000:70: root bus resource [mem 0xf1c00000000-0xf1c7fffffff window]
[   91.226052] pci 0000:70:02.0: [8086:0e04] type 01 class 0x060400
[   91.226178] pci 0000:70:02.0: PME# supported from D0 D3hot D3cold
[   91.226345] pci 0000:70:02.2: [8086:0e06] type 01 class 0x060400
[   91.226455] pci 0000:70:02.2: PME# supported from D0 D3hot D3cold
[   91.226646] pci 0000:70:03.0: [8086:0e08] type 01 class 0x060400
[   91.226758] pci 0000:70:03.0: PME# supported from D0 D3hot D3cold
[   91.226939] pci 0000:70:04.0: [8086:0e20] type 00 class 0x088000
[   91.226962] pci 0000:70:04.0: reg 0x10: [mem 0xf1c7ff1c000-0xf1c7ff1ffff 64bit]
[   91.227183] pci 0000:70:04.1: [8086:0e21] type 00 class 0x088000
[   91.227204] pci 0000:70:04.1: reg 0x10: [mem 0xf1c7ff18000-0xf1c7ff1bfff 64bit]
[   91.227437] pci 0000:70:04.2: [8086:0e22] type 00 class 0x088000
[   91.227457] pci 0000:70:04.2: reg 0x10: [mem 0xf1c7ff14000-0xf1c7ff17fff 64bit]
[   91.227699] pci 0000:70:04.3: [8086:0e23] type 00 class 0x088000
[   91.227718] pci 0000:70:04.3: reg 0x10: [mem 0xf1c7ff10000-0xf1c7ff13fff 64bit]
[   91.227927] pci 0000:70:04.4: [8086:0e24] type 00 class 0x088000
[   91.227946] pci 0000:70:04.4: reg 0x10: [mem 0xf1c7ff0c000-0xf1c7ff0ffff 64bit]
[   91.228193] pci 0000:70:04.5: [8086:0e25] type 00 class 0x088000
[   91.228213] pci 0000:70:04.5: reg 0x10: [mem 0xf1c7ff08000-0xf1c7ff0bfff 64bit]
[   91.228423] pci 0000:70:04.6: [8086:0e26] type 00 class 0x088000
[   91.228442] pci 0000:70:04.6: reg 0x10: [mem 0xf1c7ff04000-0xf1c7ff07fff 64bit]
[   91.228662] pci 0000:70:04.7: [8086:0e27] type 00 class 0x088000
[   91.228685] pci 0000:70:04.7: reg 0x10: [mem 0xf1c7ff00000-0xf1c7ff03fff 64bit]
[   91.229049] pci 0000:70:02.0: PCI bridge to [bus 71]
[   91.234634] pci 0000:70:02.2: PCI bridge to [bus 72]
[   91.240237] pci 0000:73:00.0: [1077:2031] type 00 class 0x0c0400
[   91.240254] pci 0000:73:00.0: reg 0x10: [mem 0xf1c7fe0a000-0xf1c7fe0bfff 64bit pref]
[   91.240268] pci 0000:73:00.0: reg 0x18: [mem 0xf1c7fe04000-0xf1c7fe07fff 64bit pref]
[   91.240279] pci 0000:73:00.0: reg 0x20: [mem 0xf1c7fd00000-0xf1c7fdfffff 64bit pref]
[   91.240288] pci 0000:73:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.240344] pci 0000:73:00.0: PME# supported from D3cold
[   91.240556] pci 0000:73:00.1: [1077:2031] type 00 class 0x0c0400
[   91.240572] pci 0000:73:00.1: reg 0x10: [mem 0xf1c7fe08000-0xf1c7fe09fff 64bit pref]
[   91.240584] pci 0000:73:00.1: reg 0x18: [mem 0xf1c7fe00000-0xf1c7fe03fff 64bit pref]
[   91.240596] pci 0000:73:00.1: reg 0x20: [mem 0xf1c7fc00000-0xf1c7fcfffff 64bit pref]
[   91.240607] pci 0000:73:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.240658] pci 0000:73:00.1: PME# supported from D3cold
[   91.240848] pci 0000:70:03.0: PCI bridge to [bus 73]
[   91.246319] pci 0000:70:03.0:   bridge window [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   91.246350] pci_bus 0000:70: on NUMA node 7
[   91.246352] acpi PNP0A08:07: Disabling ASPM (FADT indicates it is unsupported)
[   91.264939] ACPI: PCI Root Bridge [IO08] (domain 0000 [bus 84-8f])
[   91.271745] acpi PNP0A08:08: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.280872] acpi PNP0A08:08: PCIe AER handled by firmware
[   91.287055] acpi PNP0A08:08: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.295608] PCI host bridge to bus 0000:84
[   91.300119] pci_bus 0000:84: root bus resource [bus 84-8f]
[   91.306159] pci_bus 0000:84: root bus resource [mem 0xb0000000-0xb3efffff window]
[   91.314400] pci_bus 0000:84: root bus resource [mem 0xf2000000000-0xf207fffffff window]
[   91.323225] pci 0000:84:00.0: [8086:0e00] type 00 class 0x060000
[   91.323316] pci 0000:84:00.0: PME# supported from D0 D3hot D3cold
[   91.323514] pci 0000:84:02.0: [8086:0e04] type 01 class 0x060400
[   91.323622] pci 0000:84:02.0: PME# supported from D0 D3hot D3cold
[   91.323810] pci 0000:84:02.2: [8086:0e06] type 01 class 0x060400
[   91.323918] pci 0000:84:02.2: PME# supported from D0 D3hot D3cold
[   91.324112] pci 0000:84:03.0: [8086:0e08] type 01 class 0x060400
[   91.324225] pci 0000:84:03.0: PME# supported from D0 D3hot D3cold
[   91.324417] pci 0000:84:04.0: [8086:0e20] type 00 class 0x088000
[   91.324437] pci 0000:84:04.0: reg 0x10: [mem 0xf207ff1c000-0xf207ff1ffff 64bit]
[   91.324683] pci 0000:84:04.1: [8086:0e21] type 00 class 0x088000
[   91.324706] pci 0000:84:04.1: reg 0x10: [mem 0xf207ff18000-0xf207ff1bfff 64bit]
[   91.324927] pci 0000:84:04.2: [8086:0e22] type 00 class 0x088000
[   91.324946] pci 0000:84:04.2: reg 0x10: [mem 0xf207ff14000-0xf207ff17fff 64bit]
[   91.325176] pci 0000:84:04.3: [8086:0e23] type 00 class 0x088000
[   91.325197] pci 0000:84:04.3: reg 0x10: [mem 0xf207ff10000-0xf207ff13fff 64bit]
[   91.325413] pci 0000:84:04.4: [8086:0e24] type 00 class 0x088000
[   91.325432] pci 0000:84:04.4: reg 0x10: [mem 0xf207ff0c000-0xf207ff0ffff 64bit]
[   91.325667] pci 0000:84:04.5: [8086:0e25] type 00 class 0x088000
[   91.325688] pci 0000:84:04.5: reg 0x10: [mem 0xf207ff08000-0xf207ff0bfff 64bit]
[   91.325935] pci 0000:84:04.6: [8086:0e26] type 00 class 0x088000
[   91.325955] pci 0000:84:04.6: reg 0x10: [mem 0xf207ff04000-0xf207ff07fff 64bit]
[   91.326188] pci 0000:84:04.7: [8086:0e27] type 00 class 0x088000
[   91.326209] pci 0000:84:04.7: reg 0x10: [mem 0xf207ff00000-0xf207ff03fff 64bit]
[   91.326461] pci 0000:84:11.0: [8086:1d3e] type 01 class 0x060400
[   91.326584] pci 0000:84:11.0: PME# supported from D0 D3hot D3cold
[   91.326778] pci 0000:84:1c.0: [8086:1d1e] type 01 class 0x060400
[   91.326885] pci 0000:84:1c.0: PME# supported from D0 D3hot D3cold
[   91.327074] pci 0000:84:1d.0: [8086:1d26] type 00 class 0x0c0320
[   91.327104] pci 0000:84:1d.0: reg 0x10: [mem 0xb0600000-0xb06003ff]
[   91.327222] pci 0000:84:1d.0: PME# supported from D0 D3hot D3cold
[   91.327390] pci 0000:84:1f.0: [8086:1d41] type 00 class 0x060100
[   91.327814] pci 0000:85:00.0: [8086:10f8] type 00 class 0x020000
[   91.327829] pci 0000:85:00.0: reg 0x10: [mem 0xb0400000-0xb04fffff]
[   91.327843] pci 0000:85:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.327851] pci 0000:85:00.0: reg 0x1c: [mem 0xb0504000-0xb0507fff]
[   91.327872] pci 0000:85:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.327932] pci 0000:85:00.0: PME# supported from D0 D3hot D3cold
[   91.327974] pci 0000:85:00.0: reg 0x184: [mem 0xf207fa00000-0xf207fa03fff 64bit pref]
[   91.327989] pci 0000:85:00.0: reg 0x190: [mem 0xf207f900000-0xf207f903fff 64bit pref]
[   91.328176] pci 0000:85:00.1: [8086:10f8] type 00 class 0x020000
[   91.328188] pci 0000:85:00.1: reg 0x10: [mem 0xb0300000-0xb03fffff]
[   91.328203] pci 0000:85:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.328211] pci 0000:85:00.1: reg 0x1c: [mem 0xb0500000-0xb0503fff]
[   91.328237] pci 0000:85:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.328293] pci 0000:85:00.1: PME# supported from D0 D3hot D3cold
[   91.328327] pci 0000:85:00.1: reg 0x184: [mem 0xf207f800000-0xf207f803fff 64bit pref]
[   91.328345] pci 0000:85:00.1: reg 0x190: [mem 0xf207f700000-0xf207f703fff 64bit pref]
[   91.335262] pci 0000:84:02.0: PCI bridge to [bus 85-86]
[   91.341018] pci 0000:84:02.0:   bridge window [mem 0xb0300000-0xb05fffff]
[   91.341028] pci 0000:84:02.0:   bridge window [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   91.341186] pci 0000:87:00.0: [8086:10f8] type 00 class 0x020000
[   91.341202] pci 0000:87:00.0: reg 0x10: [mem 0xb0100000-0xb01fffff]
[   91.341216] pci 0000:87:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.341224] pci 0000:87:00.0: reg 0x1c: [mem 0xb0204000-0xb0207fff]
[   91.341247] pci 0000:87:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.341310] pci 0000:87:00.0: PME# supported from D0 D3hot D3cold
[   91.341346] pci 0000:87:00.0: reg 0x184: [mem 0xf207fe00000-0xf207fe03fff 64bit pref]
[   91.341361] pci 0000:87:00.0: reg 0x190: [mem 0xf207fd00000-0xf207fd03fff 64bit pref]
[   91.341560] pci 0000:87:00.1: [8086:10f8] type 00 class 0x020000
[   91.341577] pci 0000:87:00.1: reg 0x10: [mem 0xb0000000-0xb00fffff]
[   91.341592] pci 0000:87:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.341599] pci 0000:87:00.1: reg 0x1c: [mem 0xb0200000-0xb0203fff]
[   91.341620] pci 0000:87:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.341683] pci 0000:87:00.1: PME# supported from D0 D3hot D3cold
[   91.341720] pci 0000:87:00.1: reg 0x184: [mem 0xf207fc00000-0xf207fc03fff 64bit pref]
[   91.341735] pci 0000:87:00.1: reg 0x190: [mem 0xf207fb00000-0xf207fb03fff 64bit pref]
[   91.349054] pci 0000:84:02.2: PCI bridge to [bus 87-88]
[   91.354829] pci 0000:84:02.2:   bridge window [mem 0xb0000000-0xb02fffff]
[   91.354841] pci 0000:84:02.2:   bridge window [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   91.354971] pci 0000:84:03.0: PCI bridge to [bus 89]
[   91.360561] pci 0000:84:11.0: PCI bridge to [bus 8a]
[   91.366201] pci 0000:8b:00.0: [103c:3306] type 00 class 0x088000
[   91.366233] pci 0000:8b:00.0: reg 0x10: [io  0x0000-0x00ff]
[   91.366253] pci 0000:8b:00.0: reg 0x14: [mem 0xb3d88000-0xb3d881ff]
[   91.366269] pci 0000:8b:00.0: reg 0x18: [io  0x0000-0x00ff]
[   91.366589] pci 0000:8b:00.2: [103c:3307] type 00 class 0x088000
[   91.366618] pci 0000:8b:00.2: reg 0x10: [io  0x0000-0x00ff]
[   91.366635] pci 0000:8b:00.2: reg 0x14: [mem 0xb3d88400-0xb3d884ff]
[   91.366656] pci 0000:8b:00.2: reg 0x18: [mem 0xb3b00000-0xb3bfffff]
[   91.366673] pci 0000:8b:00.2: reg 0x1c: [mem 0xb3d00000-0xb3d7ffff]
[   91.366691] pci 0000:8b:00.2: reg 0x20: [mem 0xb3d80000-0xb3d87fff]
[   91.366708] pci 0000:8b:00.2: reg 0x24: [mem 0xb3c00000-0xb3cfffff]
[   91.366725] pci 0000:8b:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   91.366817] pci 0000:8b:00.2: PME# supported from D0 D3hot D3cold
[   91.378074] pci 0000:84:1c.0: PCI bridge to [bus 8b]
[   91.383558] pci 0000:84:1c.0:   bridge window [mem 0xb3b00000-0xb3efffff]
[   91.383565] pci 0000:84:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   91.383621] pci_bus 0000:84: on NUMA node 8
[   91.383622] acpi PNP0A08:08: Disabling ASPM (FADT indicates it is unsupported)
[   91.391755] ACPI: PCI Root Bridge [IO09] (domain 0000 [bus 90-9f])
[   91.398560] acpi PNP0A08:09: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.407692] acpi PNP0A08:09: PCIe AER handled by firmware
[   91.413865] acpi PNP0A08:09: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.422430] PCI host bridge to bus 0000:90
[   91.426941] pci_bus 0000:90: root bus resource [bus 90-9f]
[   91.432977] pci_bus 0000:90: root bus resource [mem 0xb4000000-0xb7ff7fff window]
[   91.441216] pci_bus 0000:90: root bus resource [mem 0xf2400000000-0xf247fffffff window]
[   91.450047] pci 0000:90:02.0: [8086:0e04] type 01 class 0x060400
[   91.450157] pci 0000:90:02.0: PME# supported from D0 D3hot D3cold
[   91.450358] pci 0000:90:02.2: [8086:0e06] type 01 class 0x060400
[   91.450467] pci 0000:90:02.2: PME# supported from D0 D3hot D3cold
[   91.450671] pci 0000:90:03.0: [8086:0e08] type 01 class 0x060400
[   91.450781] pci 0000:90:03.0: PME# supported from D0 D3hot D3cold
[   91.450960] pci 0000:90:04.0: [8086:0e20] type 00 class 0x088000
[   91.450983] pci 0000:90:04.0: reg 0x10: [mem 0xf247ff1c000-0xf247ff1ffff 64bit]
[   91.451225] pci 0000:90:04.1: [8086:0e21] type 00 class 0x088000
[   91.451246] pci 0000:90:04.1: reg 0x10: [mem 0xf247ff18000-0xf247ff1bfff 64bit]
[   91.451497] pci 0000:90:04.2: [8086:0e22] type 00 class 0x088000
[   91.451517] pci 0000:90:04.2: reg 0x10: [mem 0xf247ff14000-0xf247ff17fff 64bit]
[   91.451744] pci 0000:90:04.3: [8086:0e23] type 00 class 0x088000
[   91.451763] pci 0000:90:04.3: reg 0x10: [mem 0xf247ff10000-0xf247ff13fff 64bit]
[   91.451983] pci 0000:90:04.4: [8086:0e24] type 00 class 0x088000
[   91.452002] pci 0000:90:04.4: reg 0x10: [mem 0xf247ff0c000-0xf247ff0ffff 64bit]
[   91.452224] pci 0000:90:04.5: [8086:0e25] type 00 class 0x088000
[   91.452244] pci 0000:90:04.5: reg 0x10: [mem 0xf247ff08000-0xf247ff0bfff 64bit]
[   91.452476] pci 0000:90:04.6: [8086:0e26] type 00 class 0x088000
[   91.452495] pci 0000:90:04.6: reg 0x10: [mem 0xf247ff04000-0xf247ff07fff 64bit]
[   91.452724] pci 0000:90:04.7: [8086:0e27] type 00 class 0x088000
[   91.452745] pci 0000:90:04.7: reg 0x10: [mem 0xf247ff00000-0xf247ff03fff 64bit]
[   91.453098] pci 0000:90:02.0: PCI bridge to [bus 91]
[   91.458685] pci 0000:90:02.2: PCI bridge to [bus 92]
[   91.464286] pci 0000:93:00.0: [1077:2031] type 00 class 0x0c0400
[   91.464303] pci 0000:93:00.0: reg 0x10: [mem 0xf247fe0a000-0xf247fe0bfff 64bit pref]
[   91.464320] pci 0000:93:00.0: reg 0x18: [mem 0xf247fe04000-0xf247fe07fff 64bit pref]
[   91.464335] pci 0000:93:00.0: reg 0x20: [mem 0xf247fd00000-0xf247fdfffff 64bit pref]
[   91.464343] pci 0000:93:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.464400] pci 0000:93:00.0: PME# supported from D3cold
[   91.464601] pci 0000:93:00.1: [1077:2031] type 00 class 0x0c0400
[   91.464618] pci 0000:93:00.1: reg 0x10: [mem 0xf247fe08000-0xf247fe09fff 64bit pref]
[   91.464630] pci 0000:93:00.1: reg 0x18: [mem 0xf247fe00000-0xf247fe03fff 64bit pref]
[   91.464642] pci 0000:93:00.1: reg 0x20: [mem 0xf247fc00000-0xf247fcfffff 64bit pref]
[   91.464651] pci 0000:93:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.464710] pci 0000:93:00.1: PME# supported from D3cold
[   91.464910] pci 0000:90:03.0: PCI bridge to [bus 93]
[   91.470380] pci 0000:90:03.0:   bridge window [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   91.470412] pci_bus 0000:90: on NUMA node 9
[   91.470413] acpi PNP0A08:09: Disabling ASPM (FADT indicates it is unsupported)
[   91.489531] ACPI: PCI Root Bridge [IO0A] (domain 0000 [bus a0-af])
[   91.496340] acpi PNP0A08:0a: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.505466] acpi PNP0A08:0a: PCIe AER handled by firmware
[   91.511627] acpi PNP0A08:0a: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.520212] PCI host bridge to bus 0000:a0
[   91.524721] pci_bus 0000:a0: root bus resource [bus a0-af]
[   91.530759] pci_bus 0000:a0: root bus resource [mem 0xb8000000-0xbbefffff window]
[   91.538996] pci_bus 0000:a0: root bus resource [mem 0xf2800000000-0xf287fffffff window]
[   91.547821] pci 0000:a0:00.0: [8086:0e00] type 00 class 0x060000
[   91.547909] pci 0000:a0:00.0: PME# supported from D0 D3hot D3cold
[   91.548112] pci 0000:a0:02.0: [8086:0e04] type 01 class 0x060400
[   91.548221] pci 0000:a0:02.0: PME# supported from D0 D3hot D3cold
[   91.548467] pci 0000:a0:02.2: [8086:0e06] type 01 class 0x060400
[   91.548576] pci 0000:a0:02.2: PME# supported from D0 D3hot D3cold
[   91.548775] pci 0000:a0:03.0: [8086:0e08] type 01 class 0x060400
[   91.548887] pci 0000:a0:03.0: PME# supported from D0 D3hot D3cold
[   91.549094] pci 0000:a0:04.0: [8086:0e20] type 00 class 0x088000
[   91.549114] pci 0000:a0:04.0: reg 0x10: [mem 0xf287ff1c000-0xf287ff1ffff 64bit]
[   91.549349] pci 0000:a0:04.1: [8086:0e21] type 00 class 0x088000
[   91.549370] pci 0000:a0:04.1: reg 0x10: [mem 0xf287ff18000-0xf287ff1bfff 64bit]
[   91.549599] pci 0000:a0:04.2: [8086:0e22] type 00 class 0x088000
[   91.549619] pci 0000:a0:04.2: reg 0x10: [mem 0xf287ff14000-0xf287ff17fff 64bit]
[   91.549861] pci 0000:a0:04.3: [8086:0e23] type 00 class 0x088000
[   91.549882] pci 0000:a0:04.3: reg 0x10: [mem 0xf287ff10000-0xf287ff13fff 64bit]
[   91.550101] pci 0000:a0:04.4: [8086:0e24] type 00 class 0x088000
[   91.550120] pci 0000:a0:04.4: reg 0x10: [mem 0xf287ff0c000-0xf287ff0ffff 64bit]
[   91.550354] pci 0000:a0:04.5: [8086:0e25] type 00 class 0x088000
[   91.550375] pci 0000:a0:04.5: reg 0x10: [mem 0xf287ff08000-0xf287ff0bfff 64bit]
[   91.550616] pci 0000:a0:04.6: [8086:0e26] type 00 class 0x088000
[   91.550635] pci 0000:a0:04.6: reg 0x10: [mem 0xf287ff04000-0xf287ff07fff 64bit]
[   91.550854] pci 0000:a0:04.7: [8086:0e27] type 00 class 0x088000
[   91.550876] pci 0000:a0:04.7: reg 0x10: [mem 0xf287ff00000-0xf287ff03fff 64bit]
[   91.551111] pci 0000:a0:11.0: [8086:1d3e] type 01 class 0x060400
[   91.551233] pci 0000:a0:11.0: PME# supported from D0 D3hot D3cold
[   91.551411] pci 0000:a0:1c.0: [8086:1d1e] type 01 class 0x060400
[   91.551520] pci 0000:a0:1c.0: PME# supported from D0 D3hot D3cold
[   91.551712] pci 0000:a0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   91.551740] pci 0000:a0:1d.0: reg 0x10: [mem 0xb8600000-0xb86003ff]
[   91.551858] pci 0000:a0:1d.0: PME# supported from D0 D3hot D3cold
[   91.552057] pci 0000:a0:1f.0: [8086:1d41] type 00 class 0x060100
[   91.552450] pci 0000:a1:00.0: [8086:10f8] type 00 class 0x020000
[   91.552462] pci 0000:a1:00.0: reg 0x10: [mem 0xb8400000-0xb84fffff]
[   91.552481] pci 0000:a1:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.552488] pci 0000:a1:00.0: reg 0x1c: [mem 0xb8504000-0xb8507fff]
[   91.552510] pci 0000:a1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.552567] pci 0000:a1:00.0: PME# supported from D0 D3hot D3cold
[   91.552611] pci 0000:a1:00.0: reg 0x184: [mem 0xf287fa00000-0xf287fa03fff 64bit pref]
[   91.552627] pci 0000:a1:00.0: reg 0x190: [mem 0xf287f900000-0xf287f903fff 64bit pref]
[   91.552827] pci 0000:a1:00.1: [8086:10f8] type 00 class 0x020000
[   91.552840] pci 0000:a1:00.1: reg 0x10: [mem 0xb8300000-0xb83fffff]
[   91.552854] pci 0000:a1:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.552865] pci 0000:a1:00.1: reg 0x1c: [mem 0xb8500000-0xb8503fff]
[   91.552886] pci 0000:a1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.552941] pci 0000:a1:00.1: PME# supported from D0 D3hot D3cold
[   91.552972] pci 0000:a1:00.1: reg 0x184: [mem 0xf287f800000-0xf287f803fff 64bit pref]
[   91.552987] pci 0000:a1:00.1: reg 0x190: [mem 0xf287f700000-0xf287f703fff 64bit pref]
[   91.559857] pci 0000:a0:02.0: PCI bridge to [bus a1-a2]
[   91.565628] pci 0000:a0:02.0:   bridge window [mem 0xb8300000-0xb85fffff]
[   91.565637] pci 0000:a0:02.0:   bridge window [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   91.565785] pci 0000:a3:00.0: [8086:10f8] type 00 class 0x020000
[   91.565799] pci 0000:a3:00.0: reg 0x10: [mem 0xb8100000-0xb81fffff]
[   91.565814] pci 0000:a3:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.565821] pci 0000:a3:00.0: reg 0x1c: [mem 0xb8204000-0xb8207fff]
[   91.565845] pci 0000:a3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.565902] pci 0000:a3:00.0: PME# supported from D0 D3hot D3cold
[   91.565943] pci 0000:a3:00.0: reg 0x184: [mem 0xf287fe00000-0xf287fe03fff 64bit pref]
[   91.565958] pci 0000:a3:00.0: reg 0x190: [mem 0xf287fd00000-0xf287fd03fff 64bit pref]
[   91.566157] pci 0000:a3:00.1: [8086:10f8] type 00 class 0x020000
[   91.566169] pci 0000:a3:00.1: reg 0x10: [mem 0xb8000000-0xb80fffff]
[   91.566183] pci 0000:a3:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.566191] pci 0000:a3:00.1: reg 0x1c: [mem 0xb8200000-0xb8203fff]
[   91.566212] pci 0000:a3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.566270] pci 0000:a3:00.1: PME# supported from D0 D3hot D3cold
[   91.566306] pci 0000:a3:00.1: reg 0x184: [mem 0xf287fc00000-0xf287fc03fff 64bit pref]
[   91.566322] pci 0000:a3:00.1: reg 0x190: [mem 0xf287fb00000-0xf287fb03fff 64bit pref]
[   91.573661] pci 0000:a0:02.2: PCI bridge to [bus a3-a4]
[   91.579435] pci 0000:a0:02.2:   bridge window [mem 0xb8000000-0xb82fffff]
[   91.579444] pci 0000:a0:02.2:   bridge window [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   91.579560] pci 0000:a0:03.0: PCI bridge to [bus a5]
[   91.585165] pci 0000:a0:11.0: PCI bridge to [bus a6]
[   91.590799] pci 0000:a7:00.0: [103c:3306] type 00 class 0x088000
[   91.590831] pci 0000:a7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   91.590851] pci 0000:a7:00.0: reg 0x14: [mem 0xbbd88000-0xbbd881ff]
[   91.590867] pci 0000:a7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   91.591189] pci 0000:a7:00.2: [103c:3307] type 00 class 0x088000
[   91.591217] pci 0000:a7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   91.591237] pci 0000:a7:00.2: reg 0x14: [mem 0xbbd88400-0xbbd884ff]
[   91.591256] pci 0000:a7:00.2: reg 0x18: [mem 0xbbb00000-0xbbbfffff]
[   91.591273] pci 0000:a7:00.2: reg 0x1c: [mem 0xbbd00000-0xbbd7ffff]
[   91.591290] pci 0000:a7:00.2: reg 0x20: [mem 0xbbd80000-0xbbd87fff]
[   91.591307] pci 0000:a7:00.2: reg 0x24: [mem 0xbbc00000-0xbbcfffff]
[   91.591324] pci 0000:a7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   91.591417] pci 0000:a7:00.2: PME# supported from D0 D3hot D3cold
[   91.602677] pci 0000:a0:1c.0: PCI bridge to [bus a7]
[   91.608163] pci 0000:a0:1c.0:   bridge window [mem 0xbbb00000-0xbbefffff]
[   91.608170] pci 0000:a0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   91.608230] pci_bus 0000:a0: on NUMA node 10
[   91.608235] acpi PNP0A08:0a: Disabling ASPM (FADT indicates it is unsupported)
[   91.616395] ACPI: PCI Root Bridge [IO0B] (domain 0000 [bus b0-bf])
[   91.623203] acpi PNP0A08:0b: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.632334] acpi PNP0A08:0b: PCIe AER handled by firmware
[   91.638524] acpi PNP0A08:0b: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.647109] PCI host bridge to bus 0000:b0
[   91.651618] pci_bus 0000:b0: root bus resource [bus b0-bf]
[   91.657654] pci_bus 0000:b0: root bus resource [mem 0xbc000000-0xbfff7fff window]
[   91.665891] pci_bus 0000:b0: root bus resource [mem 0xf2c00000000-0xf2c7fffffff window]
[   91.674718] pci 0000:b0:02.0: [8086:0e04] type 01 class 0x060400
[   91.674827] pci 0000:b0:02.0: PME# supported from D0 D3hot D3cold
[   91.675008] pci 0000:b0:02.2: [8086:0e06] type 01 class 0x060400
[   91.675113] pci 0000:b0:02.2: PME# supported from D0 D3hot D3cold
[   91.675318] pci 0000:b0:03.0: [8086:0e08] type 01 class 0x060400
[   91.675429] pci 0000:b0:03.0: PME# supported from D0 D3hot D3cold
[   91.675632] pci 0000:b0:04.0: [8086:0e20] type 00 class 0x088000
[   91.675655] pci 0000:b0:04.0: reg 0x10: [mem 0xf2c7ff1c000-0xf2c7ff1ffff 64bit]
[   91.675923] pci 0000:b0:04.1: [8086:0e21] type 00 class 0x088000
[   91.675942] pci 0000:b0:04.1: reg 0x10: [mem 0xf2c7ff18000-0xf2c7ff1bfff 64bit]
[   91.676161] pci 0000:b0:04.2: [8086:0e22] type 00 class 0x088000
[   91.676181] pci 0000:b0:04.2: reg 0x10: [mem 0xf2c7ff14000-0xf2c7ff17fff 64bit]
[   91.676423] pci 0000:b0:04.3: [8086:0e23] type 00 class 0x088000
[   91.676442] pci 0000:b0:04.3: reg 0x10: [mem 0xf2c7ff10000-0xf2c7ff13fff 64bit]
[   91.676698] pci 0000:b0:04.4: [8086:0e24] type 00 class 0x088000
[   91.676718] pci 0000:b0:04.4: reg 0x10: [mem 0xf2c7ff0c000-0xf2c7ff0ffff 64bit]
[   91.676936] pci 0000:b0:04.5: [8086:0e25] type 00 class 0x088000
[   91.676957] pci 0000:b0:04.5: reg 0x10: [mem 0xf2c7ff08000-0xf2c7ff0bfff 64bit]
[   91.677184] pci 0000:b0:04.6: [8086:0e26] type 00 class 0x088000
[   91.677203] pci 0000:b0:04.6: reg 0x10: [mem 0xf2c7ff04000-0xf2c7ff07fff 64bit]
[   91.677437] pci 0000:b0:04.7: [8086:0e27] type 00 class 0x088000
[   91.677464] pci 0000:b0:04.7: reg 0x10: [mem 0xf2c7ff00000-0xf2c7ff03fff 64bit]
[   91.677806] pci 0000:b0:02.0: PCI bridge to [bus b1]
[   91.683404] pci 0000:b0:02.2: PCI bridge to [bus b2]
[   91.689014] pci 0000:b3:00.0: [1077:2031] type 00 class 0x0c0400
[   91.689032] pci 0000:b3:00.0: reg 0x10: [mem 0xf2c7fe0a000-0xf2c7fe0bfff 64bit pref]
[   91.689043] pci 0000:b3:00.0: reg 0x18: [mem 0xf2c7fe04000-0xf2c7fe07fff 64bit pref]
[   91.689055] pci 0000:b3:00.0: reg 0x20: [mem 0xf2c7fd00000-0xf2c7fdfffff 64bit pref]
[   91.689063] pci 0000:b3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.689119] pci 0000:b3:00.0: PME# supported from D3cold
[   91.689321] pci 0000:b3:00.1: [1077:2031] type 00 class 0x0c0400
[   91.689340] pci 0000:b3:00.1: reg 0x10: [mem 0xf2c7fe08000-0xf2c7fe09fff 64bit pref]
[   91.689352] pci 0000:b3:00.1: reg 0x18: [mem 0xf2c7fe00000-0xf2c7fe03fff 64bit pref]
[   91.689364] pci 0000:b3:00.1: reg 0x20: [mem 0xf2c7fc00000-0xf2c7fcfffff 64bit pref]
[   91.689372] pci 0000:b3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.689424] pci 0000:b3:00.1: PME# supported from D3cold
[   91.689651] pci 0000:b0:03.0: PCI bridge to [bus b3]
[   91.695125] pci 0000:b0:03.0:   bridge window [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   91.695156] pci_bus 0000:b0: on NUMA node 11
[   91.695158] acpi PNP0A08:0b: Disabling ASPM (FADT indicates it is unsupported)
[   91.714799] ACPI: PCI Root Bridge [IO0C] (domain 0000 [bus c0-cf])
[   91.721614] acpi PNP0A08:0c: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.730743] acpi PNP0A08:0c: PCIe AER handled by firmware
[   91.736933] acpi PNP0A08:0c: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.745510] PCI host bridge to bus 0000:c0
[   91.750021] pci_bus 0000:c0: root bus resource [bus c0-cf]
[   91.756059] pci_bus 0000:c0: root bus resource [mem 0xc0000000-0xc3efffff window]
[   91.764292] pci_bus 0000:c0: root bus resource [mem 0xf3000000000-0xf307fffffff window]
[   91.773117] pci 0000:c0:00.0: [8086:0e00] type 00 class 0x060000
[   91.773207] pci 0000:c0:00.0: PME# supported from D0 D3hot D3cold
[   91.773419] pci 0000:c0:02.0: [8086:0e04] type 01 class 0x060400
[   91.773526] pci 0000:c0:02.0: PME# supported from D0 D3hot D3cold
[   91.773724] pci 0000:c0:02.2: [8086:0e06] type 01 class 0x060400
[   91.773831] pci 0000:c0:02.2: PME# supported from D0 D3hot D3cold
[   91.774030] pci 0000:c0:03.0: [8086:0e08] type 01 class 0x060400
[   91.774146] pci 0000:c0:03.0: PME# supported from D0 D3hot D3cold
[   91.774335] pci 0000:c0:04.0: [8086:0e20] type 00 class 0x088000
[   91.774355] pci 0000:c0:04.0: reg 0x10: [mem 0xf307ff1c000-0xf307ff1ffff 64bit]
[   91.774591] pci 0000:c0:04.1: [8086:0e21] type 00 class 0x088000
[   91.774615] pci 0000:c0:04.1: reg 0x10: [mem 0xf307ff18000-0xf307ff1bfff 64bit]
[   91.774845] pci 0000:c0:04.2: [8086:0e22] type 00 class 0x088000
[   91.774864] pci 0000:c0:04.2: reg 0x10: [mem 0xf307ff14000-0xf307ff17fff 64bit]
[   91.775110] pci 0000:c0:04.3: [8086:0e23] type 00 class 0x088000
[   91.775129] pci 0000:c0:04.3: reg 0x10: [mem 0xf307ff10000-0xf307ff13fff 64bit]
[   91.775381] pci 0000:c0:04.4: [8086:0e24] type 00 class 0x088000
[   91.775400] pci 0000:c0:04.4: reg 0x10: [mem 0xf307ff0c000-0xf307ff0ffff 64bit]
[   91.775624] pci 0000:c0:04.5: [8086:0e25] type 00 class 0x088000
[   91.775645] pci 0000:c0:04.5: reg 0x10: [mem 0xf307ff08000-0xf307ff0bfff 64bit]
[   91.775890] pci 0000:c0:04.6: [8086:0e26] type 00 class 0x088000
[   91.775913] pci 0000:c0:04.6: reg 0x10: [mem 0xf307ff04000-0xf307ff07fff 64bit]
[   91.776152] pci 0000:c0:04.7: [8086:0e27] type 00 class 0x088000
[   91.776173] pci 0000:c0:04.7: reg 0x10: [mem 0xf307ff00000-0xf307ff03fff 64bit]
[   91.776406] pci 0000:c0:11.0: [8086:1d3e] type 01 class 0x060400
[   91.776528] pci 0000:c0:11.0: PME# supported from D0 D3hot D3cold
[   91.776725] pci 0000:c0:1c.0: [8086:1d1e] type 01 class 0x060400
[   91.776830] pci 0000:c0:1c.0: PME# supported from D0 D3hot D3cold
[   91.777035] pci 0000:c0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   91.777066] pci 0000:c0:1d.0: reg 0x10: [mem 0xc0600000-0xc06003ff]
[   91.777184] pci 0000:c0:1d.0: PME# supported from D0 D3hot D3cold
[   91.777367] pci 0000:c0:1f.0: [8086:1d41] type 00 class 0x060100
[   91.777777] pci 0000:c1:00.0: [8086:10f8] type 00 class 0x020000
[   91.777791] pci 0000:c1:00.0: reg 0x10: [mem 0xc0400000-0xc04fffff]
[   91.777808] pci 0000:c1:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.777816] pci 0000:c1:00.0: reg 0x1c: [mem 0xc0504000-0xc0507fff]
[   91.777837] pci 0000:c1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.777897] pci 0000:c1:00.0: PME# supported from D0 D3hot D3cold
[   91.777936] pci 0000:c1:00.0: reg 0x184: [mem 0xf307fa00000-0xf307fa03fff 64bit pref]
[   91.777952] pci 0000:c1:00.0: reg 0x190: [mem 0xf307f900000-0xf307f903fff 64bit pref]
[   91.778142] pci 0000:c1:00.1: [8086:10f8] type 00 class 0x020000
[   91.778154] pci 0000:c1:00.1: reg 0x10: [mem 0xc0300000-0xc03fffff]
[   91.778173] pci 0000:c1:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.778184] pci 0000:c1:00.1: reg 0x1c: [mem 0xc0500000-0xc0503fff]
[   91.778204] pci 0000:c1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.778260] pci 0000:c1:00.1: PME# supported from D0 D3hot D3cold
[   91.778293] pci 0000:c1:00.1: reg 0x184: [mem 0xf307f800000-0xf307f803fff 64bit pref]
[   91.778312] pci 0000:c1:00.1: reg 0x190: [mem 0xf307f700000-0xf307f703fff 64bit pref]
[   91.785150] pci 0000:c0:02.0: PCI bridge to [bus c1-c2]
[   91.790922] pci 0000:c0:02.0:   bridge window [mem 0xc0300000-0xc05fffff]
[   91.790929] pci 0000:c0:02.0:   bridge window [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   91.791093] pci 0000:c3:00.0: [8086:10f8] type 00 class 0x020000
[   91.791109] pci 0000:c3:00.0: reg 0x10: [mem 0xc0100000-0xc01fffff]
[   91.791123] pci 0000:c3:00.0: reg 0x18: [io  0x0000-0x001f]
[   91.791131] pci 0000:c3:00.0: reg 0x1c: [mem 0xc0204000-0xc0207fff]
[   91.791152] pci 0000:c3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.791217] pci 0000:c3:00.0: PME# supported from D0 D3hot D3cold
[   91.791259] pci 0000:c3:00.0: reg 0x184: [mem 0xf307fe00000-0xf307fe03fff 64bit pref]
[   91.791274] pci 0000:c3:00.0: reg 0x190: [mem 0xf307fd00000-0xf307fd03fff 64bit pref]
[   91.791491] pci 0000:c3:00.1: [8086:10f8] type 00 class 0x020000
[   91.791505] pci 0000:c3:00.1: reg 0x10: [mem 0xc0000000-0xc00fffff]
[   91.791523] pci 0000:c3:00.1: reg 0x18: [io  0x0000-0x001f]
[   91.791531] pci 0000:c3:00.1: reg 0x1c: [mem 0xc0200000-0xc0203fff]
[   91.791552] pci 0000:c3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   91.791614] pci 0000:c3:00.1: PME# supported from D0 D3hot D3cold
[   91.791650] pci 0000:c3:00.1: reg 0x184: [mem 0xf307fc00000-0xf307fc03fff 64bit pref]
[   91.791665] pci 0000:c3:00.1: reg 0x190: [mem 0xf307fb00000-0xf307fb03fff 64bit pref]
[   91.802962] pci 0000:c0:02.2: PCI bridge to [bus c3-c4]
[   91.808718] pci 0000:c0:02.2:   bridge window [mem 0xc0000000-0xc02fffff]
[   91.808728] pci 0000:c0:02.2:   bridge window [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   91.808850] pci 0000:c0:03.0: PCI bridge to [bus c5]
[   91.814461] pci 0000:c0:11.0: PCI bridge to [bus c6]
[   91.820100] pci 0000:c7:00.0: [103c:3306] type 00 class 0x088000
[   91.820129] pci 0000:c7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   91.820146] pci 0000:c7:00.0: reg 0x14: [mem 0xc3d88000-0xc3d881ff]
[   91.820163] pci 0000:c7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   91.820469] pci 0000:c7:00.2: [103c:3307] type 00 class 0x088000
[   91.820497] pci 0000:c7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   91.820516] pci 0000:c7:00.2: reg 0x14: [mem 0xc3d88400-0xc3d884ff]
[   91.820536] pci 0000:c7:00.2: reg 0x18: [mem 0xc3b00000-0xc3bfffff]
[   91.820553] pci 0000:c7:00.2: reg 0x1c: [mem 0xc3d00000-0xc3d7ffff]
[   91.820570] pci 0000:c7:00.2: reg 0x20: [mem 0xc3d80000-0xc3d87fff]
[   91.820587] pci 0000:c7:00.2: reg 0x24: [mem 0xc3c00000-0xc3cfffff]
[   91.820604] pci 0000:c7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   91.820698] pci 0000:c7:00.2: PME# supported from D0 D3hot D3cold
[   91.827994] pci 0000:c0:1c.0: PCI bridge to [bus c7]
[   91.833464] pci 0000:c0:1c.0:   bridge window [mem 0xc3b00000-0xc3efffff]
[   91.833471] pci 0000:c0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   91.833529] pci_bus 0000:c0: on NUMA node 12
[   91.833531] acpi PNP0A08:0c: Disabling ASPM (FADT indicates it is unsupported)
[   91.841693] ACPI: PCI Root Bridge [IO0D] (domain 0000 [bus d0-df])
[   91.848498] acpi PNP0A08:0d: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.857639] acpi PNP0A08:0d: PCIe AER handled by firmware
[   91.863813] acpi PNP0A08:0d: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.872376] PCI host bridge to bus 0000:d0
[   91.876883] pci_bus 0000:d0: root bus resource [bus d0-df]
[   91.882918] pci_bus 0000:d0: root bus resource [mem 0xc4000000-0xc7ff7fff window]
[   91.891157] pci_bus 0000:d0: root bus resource [mem 0xf3400000000-0xf347fffffff window]
[   91.900004] pci 0000:d0:02.0: [8086:0e04] type 01 class 0x060400
[   91.900120] pci 0000:d0:02.0: PME# supported from D0 D3hot D3cold
[   91.900312] pci 0000:d0:02.2: [8086:0e06] type 01 class 0x060400
[   91.900418] pci 0000:d0:02.2: PME# supported from D0 D3hot D3cold
[   91.900633] pci 0000:d0:03.0: [8086:0e08] type 01 class 0x060400
[   91.900750] pci 0000:d0:03.0: PME# supported from D0 D3hot D3cold
[   91.900952] pci 0000:d0:04.0: [8086:0e20] type 00 class 0x088000
[   91.900972] pci 0000:d0:04.0: reg 0x10: [mem 0xf347ff1c000-0xf347ff1ffff 64bit]
[   91.901208] pci 0000:d0:04.1: [8086:0e21] type 00 class 0x088000
[   91.901229] pci 0000:d0:04.1: reg 0x10: [mem 0xf347ff18000-0xf347ff1bfff 64bit]
[   91.901453] pci 0000:d0:04.2: [8086:0e22] type 00 class 0x088000
[   91.901472] pci 0000:d0:04.2: reg 0x10: [mem 0xf347ff14000-0xf347ff17fff 64bit]
[   91.901714] pci 0000:d0:04.3: [8086:0e23] type 00 class 0x088000
[   91.901734] pci 0000:d0:04.3: reg 0x10: [mem 0xf347ff10000-0xf347ff13fff 64bit]
[   91.901960] pci 0000:d0:04.4: [8086:0e24] type 00 class 0x088000
[   91.901979] pci 0000:d0:04.4: reg 0x10: [mem 0xf347ff0c000-0xf347ff0ffff 64bit]
[   91.902202] pci 0000:d0:04.5: [8086:0e25] type 00 class 0x088000
[   91.902221] pci 0000:d0:04.5: reg 0x10: [mem 0xf347ff08000-0xf347ff0bfff 64bit]
[   91.902468] pci 0000:d0:04.6: [8086:0e26] type 00 class 0x088000
[   91.902489] pci 0000:d0:04.6: reg 0x10: [mem 0xf347ff04000-0xf347ff07fff 64bit]
[   91.902718] pci 0000:d0:04.7: [8086:0e27] type 00 class 0x088000
[   91.902739] pci 0000:d0:04.7: reg 0x10: [mem 0xf347ff00000-0xf347ff03fff 64bit]
[   91.903102] pci 0000:d0:02.0: PCI bridge to [bus d1]
[   91.908696] pci 0000:d0:02.2: PCI bridge to [bus d2]
[   91.914303] pci 0000:d3:00.0: [1077:2031] type 00 class 0x0c0400
[   91.914321] pci 0000:d3:00.0: reg 0x10: [mem 0xf347fe0a000-0xf347fe0bfff 64bit pref]
[   91.914333] pci 0000:d3:00.0: reg 0x18: [mem 0xf347fe04000-0xf347fe07fff 64bit pref]
[   91.914349] pci 0000:d3:00.0: reg 0x20: [mem 0xf347fd00000-0xf347fdfffff 64bit pref]
[   91.914361] pci 0000:d3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.914417] pci 0000:d3:00.0: PME# supported from D3cold
[   91.914611] pci 0000:d3:00.1: [1077:2031] type 00 class 0x0c0400
[   91.914627] pci 0000:d3:00.1: reg 0x10: [mem 0xf347fe08000-0xf347fe09fff 64bit pref]
[   91.914640] pci 0000:d3:00.1: reg 0x18: [mem 0xf347fe00000-0xf347fe03fff 64bit pref]
[   91.914652] pci 0000:d3:00.1: reg 0x20: [mem 0xf347fc00000-0xf347fcfffff 64bit pref]
[   91.914661] pci 0000:d3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   91.914716] pci 0000:d3:00.1: PME# supported from D3cold
[   91.914929] pci 0000:d0:03.0: PCI bridge to [bus d3]
[   91.920402] pci 0000:d0:03.0:   bridge window [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   91.920434] pci_bus 0000:d0: on NUMA node 13
[   91.920435] acpi PNP0A08:0d: Disabling ASPM (FADT indicates it is unsupported)
[   91.941350] ACPI: PCI Root Bridge [IO0E] (domain 0000 [bus e0-ef])
[   91.948158] acpi PNP0A08:0e: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   91.957291] acpi PNP0A08:0e: PCIe AER handled by firmware
[   91.963460] acpi PNP0A08:0e: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   91.972030] PCI host bridge to bus 0000:e0
[   91.976538] pci_bus 0000:e0: root bus resource [bus e0-ef]
[   91.982577] pci_bus 0000:e0: root bus resource [mem 0xc8000000-0xcbefffff window]
[   91.990811] pci_bus 0000:e0: root bus resource [mem 0xf3800000000-0xf387fffffff window]
[   91.999638] pci 0000:e0:00.0: [8086:0e00] type 00 class 0x060000
[   91.999728] pci 0000:e0:00.0: PME# supported from D0 D3hot D3cold
[   91.999919] pci 0000:e0:02.0: [8086:0e04] type 01 class 0x060400
[   92.000031] pci 0000:e0:02.0: PME# supported from D0 D3hot D3cold
[   92.000222] pci 0000:e0:02.2: [8086:0e06] type 01 class 0x060400
[   92.000329] pci 0000:e0:02.2: PME# supported from D0 D3hot D3cold
[   92.000533] pci 0000:e0:03.0: [8086:0e08] type 01 class 0x060400
[   92.000644] pci 0000:e0:03.0: PME# supported from D0 D3hot D3cold
[   92.000846] pci 0000:e0:04.0: [8086:0e20] type 00 class 0x088000
[   92.000866] pci 0000:e0:04.0: reg 0x10: [mem 0xf387ff1c000-0xf387ff1ffff 64bit]
[   92.001100] pci 0000:e0:04.1: [8086:0e21] type 00 class 0x088000
[   92.001121] pci 0000:e0:04.1: reg 0x10: [mem 0xf387ff18000-0xf387ff1bfff 64bit]
[   92.001341] pci 0000:e0:04.2: [8086:0e22] type 00 class 0x088000
[   92.001361] pci 0000:e0:04.2: reg 0x10: [mem 0xf387ff14000-0xf387ff17fff 64bit]
[   92.001602] pci 0000:e0:04.3: [8086:0e23] type 00 class 0x088000
[   92.001622] pci 0000:e0:04.3: reg 0x10: [mem 0xf387ff10000-0xf387ff13fff 64bit]
[   92.001849] pci 0000:e0:04.4: [8086:0e24] type 00 class 0x088000
[   92.001868] pci 0000:e0:04.4: reg 0x10: [mem 0xf387ff0c000-0xf387ff0ffff 64bit]
[   92.002108] pci 0000:e0:04.5: [8086:0e25] type 00 class 0x088000
[   92.002129] pci 0000:e0:04.5: reg 0x10: [mem 0xf387ff08000-0xf387ff0bfff 64bit]
[   92.002351] pci 0000:e0:04.6: [8086:0e26] type 00 class 0x088000
[   92.002372] pci 0000:e0:04.6: reg 0x10: [mem 0xf387ff04000-0xf387ff07fff 64bit]
[   92.002612] pci 0000:e0:04.7: [8086:0e27] type 00 class 0x088000
[   92.002631] pci 0000:e0:04.7: reg 0x10: [mem 0xf387ff00000-0xf387ff03fff 64bit]
[   92.002859] pci 0000:e0:11.0: [8086:1d3e] type 01 class 0x060400
[   92.002981] pci 0000:e0:11.0: PME# supported from D0 D3hot D3cold
[   92.003182] pci 0000:e0:1c.0: [8086:1d1e] type 01 class 0x060400
[   92.003290] pci 0000:e0:1c.0: PME# supported from D0 D3hot D3cold
[   92.003502] pci 0000:e0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   92.003530] pci 0000:e0:1d.0: reg 0x10: [mem 0xc8600000-0xc86003ff]
[   92.003648] pci 0000:e0:1d.0: PME# supported from D0 D3hot D3cold
[   92.003824] pci 0000:e0:1f.0: [8086:1d41] type 00 class 0x060100
[   92.004228] pci 0000:e1:00.0: [8086:10f8] type 00 class 0x020000
[   92.004243] pci 0000:e1:00.0: reg 0x10: [mem 0xc8400000-0xc84fffff]
[   92.004260] pci 0000:e1:00.0: reg 0x18: [io  0x0000-0x001f]
[   92.004268] pci 0000:e1:00.0: reg 0x1c: [mem 0xc8504000-0xc8507fff]
[   92.004289] pci 0000:e1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   92.004349] pci 0000:e1:00.0: PME# supported from D0 D3hot D3cold
[   92.004390] pci 0000:e1:00.0: reg 0x184: [mem 0xf387fa00000-0xf387fa03fff 64bit pref]
[   92.004408] pci 0000:e1:00.0: reg 0x190: [mem 0xf387f900000-0xf387f903fff 64bit pref]
[   92.004577] pci 0000:e1:00.1: [8086:10f8] type 00 class 0x020000
[   92.004589] pci 0000:e1:00.1: reg 0x10: [mem 0xc8300000-0xc83fffff]
[   92.004606] pci 0000:e1:00.1: reg 0x18: [io  0x0000-0x001f]
[   92.004617] pci 0000:e1:00.1: reg 0x1c: [mem 0xc8500000-0xc8503fff]
[   92.004637] pci 0000:e1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   92.004695] pci 0000:e1:00.1: PME# supported from D0 D3hot D3cold
[   92.004725] pci 0000:e1:00.1: reg 0x184: [mem 0xf387f800000-0xf387f803fff 64bit pref]
[   92.004740] pci 0000:e1:00.1: reg 0x190: [mem 0xf387f700000-0xf387f703fff 64bit pref]
[   92.015684] pci 0000:e0:02.0: PCI bridge to [bus e1-e2]
[   92.021460] pci 0000:e0:02.0:   bridge window [mem 0xc8300000-0xc85fffff]
[   92.021466] pci 0000:e0:02.0:   bridge window [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   92.021617] pci 0000:e3:00.0: [8086:10f8] type 00 class 0x020000
[   92.021631] pci 0000:e3:00.0: reg 0x10: [mem 0xc8100000-0xc81fffff]
[   92.021645] pci 0000:e3:00.0: reg 0x18: [io  0x0000-0x001f]
[   92.021653] pci 0000:e3:00.0: reg 0x1c: [mem 0xc8204000-0xc8207fff]
[   92.021676] pci 0000:e3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   92.021733] pci 0000:e3:00.0: PME# supported from D0 D3hot D3cold
[   92.021777] pci 0000:e3:00.0: reg 0x184: [mem 0xf387fe00000-0xf387fe03fff 64bit pref]
[   92.021792] pci 0000:e3:00.0: reg 0x190: [mem 0xf387fd00000-0xf387fd03fff 64bit pref]
[   92.021982] pci 0000:e3:00.1: [8086:10f8] type 00 class 0x020000
[   92.021994] pci 0000:e3:00.1: reg 0x10: [mem 0xc8000000-0xc80fffff]
[   92.022008] pci 0000:e3:00.1: reg 0x18: [io  0x0000-0x001f]
[   92.022016] pci 0000:e3:00.1: reg 0x1c: [mem 0xc8200000-0xc8203fff]
[   92.022037] pci 0000:e3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   92.022096] pci 0000:e3:00.1: PME# supported from D0 D3hot D3cold
[   92.022128] pci 0000:e3:00.1: reg 0x184: [mem 0xf387fc00000-0xf387fc03fff 64bit pref]
[   92.022147] pci 0000:e3:00.1: reg 0x190: [mem 0xf387fb00000-0xf387fb03fff 64bit pref]
[   92.029495] pci 0000:e0:02.2: PCI bridge to [bus e3-e4]
[   92.035251] pci 0000:e0:02.2:   bridge window [mem 0xc8000000-0xc82fffff]
[   92.035260] pci 0000:e0:02.2:   bridge window [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   92.035383] pci 0000:e0:03.0: PCI bridge to [bus e5]
[   92.040973] pci 0000:e0:11.0: PCI bridge to [bus e6]
[   92.046585] pci 0000:e7:00.0: [103c:3306] type 00 class 0x088000
[   92.046614] pci 0000:e7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   92.046631] pci 0000:e7:00.0: reg 0x14: [mem 0xcbd88000-0xcbd881ff]
[   92.046652] pci 0000:e7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   92.046972] pci 0000:e7:00.2: [103c:3307] type 00 class 0x088000
[   92.047000] pci 0000:e7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   92.047019] pci 0000:e7:00.2: reg 0x14: [mem 0xcbd88400-0xcbd884ff]
[   92.047039] pci 0000:e7:00.2: reg 0x18: [mem 0xcbb00000-0xcbbfffff]
[   92.047056] pci 0000:e7:00.2: reg 0x1c: [mem 0xcbd00000-0xcbd7ffff]
[   92.047073] pci 0000:e7:00.2: reg 0x20: [mem 0xcbd80000-0xcbd87fff]
[   92.047091] pci 0000:e7:00.2: reg 0x24: [mem 0xcbc00000-0xcbcfffff]
[   92.047110] pci 0000:e7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   92.047203] pci 0000:e7:00.2: PME# supported from D0 D3hot D3cold
[   92.054496] pci 0000:e0:1c.0: PCI bridge to [bus e7]
[   92.059962] pci 0000:e0:1c.0:   bridge window [mem 0xcbb00000-0xcbefffff]
[   92.059969] pci 0000:e0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   92.060029] pci_bus 0000:e0: on NUMA node 14
[   92.060030] acpi PNP0A08:0e: Disabling ASPM (FADT indicates it is unsupported)
[   92.068183] ACPI: PCI Root Bridge [IO0F] (domain 0000 [bus f0-ff])
[   92.074991] acpi PNP0A08:0f: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   92.084127] acpi PNP0A08:0f: PCIe AER handled by firmware
[   92.090312] acpi PNP0A08:0f: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   92.098885] PCI host bridge to bus 0000:f0
[   92.103392] pci_bus 0000:f0: root bus resource [bus f0-ff]
[   92.109427] pci_bus 0000:f0: root bus resource [mem 0xcc000000-0xcfff7fff window]
[   92.117663] pci_bus 0000:f0: root bus resource [mem 0xf3c00000000-0xf3c7fffffff window]
[   92.126491] pci 0000:f0:02.0: [8086:0e04] type 01 class 0x060400
[   92.126607] pci 0000:f0:02.0: PME# supported from D0 D3hot D3cold
[   92.126797] pci 0000:f0:02.2: [8086:0e06] type 01 class 0x060400
[   92.126902] pci 0000:f0:02.2: PME# supported from D0 D3hot D3cold
[   92.127077] pci 0000:f0:03.0: [8086:0e08] type 01 class 0x060400
[   92.127191] pci 0000:f0:03.0: PME# supported from D0 D3hot D3cold
[   92.127371] pci 0000:f0:04.0: [8086:0e20] type 00 class 0x088000
[   92.127393] pci 0000:f0:04.0: reg 0x10: [mem 0xf3c7ff1c000-0xf3c7ff1ffff 64bit]
[   92.127621] pci 0000:f0:04.1: [8086:0e21] type 00 class 0x088000
[   92.127642] pci 0000:f0:04.1: reg 0x10: [mem 0xf3c7ff18000-0xf3c7ff1bfff 64bit]
[   92.127879] pci 0000:f0:04.2: [8086:0e22] type 00 class 0x088000
[   92.127898] pci 0000:f0:04.2: reg 0x10: [mem 0xf3c7ff14000-0xf3c7ff17fff 64bit]
[   92.128124] pci 0000:f0:04.3: [8086:0e23] type 00 class 0x088000
[   92.128145] pci 0000:f0:04.3: reg 0x10: [mem 0xf3c7ff10000-0xf3c7ff13fff 64bit]
[   92.128368] pci 0000:f0:04.4: [8086:0e24] type 00 class 0x088000
[   92.128387] pci 0000:f0:04.4: reg 0x10: [mem 0xf3c7ff0c000-0xf3c7ff0ffff 64bit]
[   92.128614] pci 0000:f0:04.5: [8086:0e25] type 00 class 0x088000
[   92.128635] pci 0000:f0:04.5: reg 0x10: [mem 0xf3c7ff08000-0xf3c7ff0bfff 64bit]
[   92.128872] pci 0000:f0:04.6: [8086:0e26] type 00 class 0x088000
[   92.128891] pci 0000:f0:04.6: reg 0x10: [mem 0xf3c7ff04000-0xf3c7ff07fff 64bit]
[   92.129120] pci 0000:f0:04.7: [8086:0e27] type 00 class 0x088000
[   92.129140] pci 0000:f0:04.7: reg 0x10: [mem 0xf3c7ff00000-0xf3c7ff03fff 64bit]
[   92.129496] pci 0000:f0:02.0: PCI bridge to [bus f1]
[   92.135097] pci 0000:f0:02.2: PCI bridge to [bus f2]
[   92.140688] pci 0000:f3:00.0: [1077:2031] type 00 class 0x0c0400
[   92.140706] pci 0000:f3:00.0: reg 0x10: [mem 0xf3c7fe0a000-0xf3c7fe0bfff 64bit pref]
[   92.140720] pci 0000:f3:00.0: reg 0x18: [mem 0xf3c7fe04000-0xf3c7fe07fff 64bit pref]
[   92.140735] pci 0000:f3:00.0: reg 0x20: [mem 0xf3c7fd00000-0xf3c7fdfffff 64bit pref]
[   92.140743] pci 0000:f3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   92.140797] pci 0000:f3:00.0: PME# supported from D3cold
[   92.140987] pci 0000:f3:00.1: [1077:2031] type 00 class 0x0c0400
[   92.141005] pci 0000:f3:00.1: reg 0x10: [mem 0xf3c7fe08000-0xf3c7fe09fff 64bit pref]
[   92.141020] pci 0000:f3:00.1: reg 0x18: [mem 0xf3c7fe00000-0xf3c7fe03fff 64bit pref]
[   92.141031] pci 0000:f3:00.1: reg 0x20: [mem 0xf3c7fc00000-0xf3c7fcfffff 64bit pref]
[   92.141039] pci 0000:f3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   92.141094] pci 0000:f3:00.1: PME# supported from D3cold
[   92.141305] pci 0000:f0:03.0: PCI bridge to [bus f3]
[   92.146775] pci 0000:f0:03.0:   bridge window [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   92.146806] pci_bus 0000:f0: on NUMA node 15
[   92.146808] acpi PNP0A08:0f: Disabling ASPM (FADT indicates it is unsupported)
[   92.154971] ACPI: Enabled 1 GPEs in block 80 to FF
[   92.160872] vgaarb: setting as boot device: PCI:0000:07:00.1
[   92.167120] vgaarb: device added: PCI:0000:07:00.1,decodes=io+mem,owns=io+mem,locks=none
[   92.176394] vgaarb: loaded
[   92.179373] vgaarb: bridge control possible 0000:07:00.1
[   92.195236] PCI: Using ACPI for IRQ routing
[   92.200184] PCI: Discovered peer bus 0f
[   92.204411] PCI: root bus 0f: using default resources
[   92.204416] PCI: Probing PCI hardware (bus 0f)
[   92.204725] PCI host bridge to bus 0000:0f
[   92.209244] pci_bus 0000:0f: root bus resource [io  0x0000-0xffff]
[   92.216046] pci_bus 0000:0f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.223998] pci_bus 0000:0f: No busn resource found for root bus, will use [bus 0f-ff]
[   92.232717] pci_bus 0000:0f: busn_res: can not insert [bus 0f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 00-0f])
[   92.232743] pci 0000:0f:08.0: [8086:0e80] type 00 class 0x088000
[   92.233020] pci 0000:0f:08.2: [8086:0e32] type 00 class 0x110100
[   92.233322] pci 0000:0f:09.0: [8086:0e90] type 00 class 0x088000
[   92.233536] pci 0000:0f:09.2: [8086:0e33] type 00 class 0x110100
[   92.233731] pci 0000:0f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.233899] pci 0000:0f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.234067] pci 0000:0f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.234224] pci 0000:0f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.234394] pci 0000:0f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.234555] pci 0000:0f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.234713] pci 0000:0f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.234857] pci 0000:0f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.235002] pci 0000:0f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.235153] pci 0000:0f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.235298] pci 0000:0f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.235475] pci 0000:0f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.235638] pci 0000:0f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.235800] pci 0000:0f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.235948] pci 0000:0f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.236093] pci 0000:0f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.236247] pci 0000:0f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.236391] pci 0000:0f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.236543] pci 0000:0f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.236699] pci 0000:0f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.236867] pci 0000:0f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.237026] pci 0000:0f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.237184] pci 0000:0f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.237359] pci 0000:0f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.237547] pci 0000:0f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.237737] pci 0000:0f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.237922] pci 0000:0f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.238100] pci 0000:0f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.238281] pci 0000:0f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.238463] pci 0000:0f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.238651] pci 0000:0f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.238845] pci 0000:0f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.239033] pci 0000:0f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.239227] pci 0000:0f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.239407] pci 0000:0f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.239572] pci 0000:0f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.239747] pci 0000:0f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.239920] pci 0000:0f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.240097] pci 0000:0f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.240291] pci 0000:0f:11.2: [8086:0efa] type 00 class 0x088000
[   92.240473] pci 0000:0f:11.4: [8086:0efc] type 00 class 0x088000
[   92.240659] pci 0000:0f:11.5: [8086:0efd] type 00 class 0x088000
[   92.240851] pci 0000:0f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.241017] pci 0000:0f:13.1: [8086:0e34] type 00 class 0x110100
[   92.241200] pci 0000:0f:13.4: [8086:0e81] type 00 class 0x088000
[   92.241355] pci 0000:0f:13.5: [8086:0e36] type 00 class 0x110100
[   92.241526] pci 0000:0f:13.6: [8086:0e37] type 00 class 0x110100
[   92.241678] pci 0000:0f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.241859] pci 0000:0f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.242008] pci 0000:0f:16.2: [8086:0eca] type 00 class 0x088000
[   92.242182] pci 0000:0f:18.0: [8086:0e40] type 00 class 0x088000
[   92.242324] pci 0000:0f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.242491] pci 0000:0f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.242653] pci 0000:0f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.242829] pci 0000:0f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.243016] pci 0000:0f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.243208] pci 0000:0f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.243380] pci 0000:0f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.243578] pci 0000:0f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.243757] pci 0000:0f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.243944] pci 0000:0f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.244125] pci 0000:0f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.244312] pci 0000:0f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.244504] pci 0000:0f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.244688] pci 0000:0f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.244893] pci 0000:0f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.245081] pci 0000:0f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.245266] pci 0000:0f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.245448] pci 0000:0f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.245643] pci 0000:0f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.245830] pci 0000:0f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.246009] pci 0000:0f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.246194] pci 0000:0f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.246383] pci 0000:0f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.246564] pci_bus 0000:0f: busn_res: [bus 0f-ff] end is updated to 0f
[   92.246566] pci_bus 0000:0f: busn_res: can not insert [bus 0f] under domain [bus 00-ff] (conflicts with (null) [bus 00-0f])
[   92.246810] PCI: Discovered peer bus 1f
[   92.251033] PCI: root bus 1f: using default resources
[   92.251035] PCI: Probing PCI hardware (bus 1f)
[   92.251155] PCI host bridge to bus 0000:1f
[   92.255663] pci_bus 0000:1f: root bus resource [io  0x0000-0xffff]
[   92.262464] pci_bus 0000:1f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.270418] pci_bus 0000:1f: No busn resource found for root bus, will use [bus 1f-ff]
[   92.279140] pci_bus 0000:1f: busn_res: can not insert [bus 1f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 10-1f])
[   92.279160] pci 0000:1f:08.0: [8086:0e80] type 00 class 0x088000
[   92.279324] pci 0000:1f:08.2: [8086:0e32] type 00 class 0x110100
[   92.279487] pci 0000:1f:09.0: [8086:0e90] type 00 class 0x088000
[   92.279651] pci 0000:1f:09.2: [8086:0e33] type 00 class 0x110100
[   92.279807] pci 0000:1f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.279967] pci 0000:1f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.280119] pci 0000:1f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.280293] pci 0000:1f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.280449] pci 0000:1f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.280618] pci 0000:1f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.280769] pci 0000:1f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.280937] pci 0000:1f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.281111] pci 0000:1f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.281276] pci 0000:1f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.281419] pci 0000:1f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.281584] pci 0000:1f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.281726] pci 0000:1f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.281879] pci 0000:1f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.282006] pci 0000:1f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.282163] pci 0000:1f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.282331] pci 0000:1f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.282485] pci 0000:1f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.282644] pci 0000:1f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.282807] pci 0000:1f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.282958] pci 0000:1f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.283118] pci 0000:1f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.283295] pci 0000:1f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.283477] pci 0000:1f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.283664] pci 0000:1f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.283840] pci 0000:1f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.284028] pci 0000:1f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.284201] pci 0000:1f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.284390] pci 0000:1f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.284569] pci 0000:1f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.284755] pci 0000:1f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.284951] pci 0000:1f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.285118] pci 0000:1f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.285294] pci 0000:1f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.285479] pci 0000:1f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.285665] pci 0000:1f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.285844] pci 0000:1f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.286032] pci 0000:1f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.286194] pci 0000:1f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.286370] pci 0000:1f:11.2: [8086:0efa] type 00 class 0x088000
[   92.286535] pci 0000:1f:11.4: [8086:0efc] type 00 class 0x088000
[   92.286697] pci 0000:1f:11.5: [8086:0efd] type 00 class 0x088000
[   92.286883] pci 0000:1f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.287037] pci 0000:1f:13.1: [8086:0e34] type 00 class 0x110100
[   92.287215] pci 0000:1f:13.4: [8086:0e81] type 00 class 0x088000
[   92.287386] pci 0000:1f:13.5: [8086:0e36] type 00 class 0x110100
[   92.287542] pci 0000:1f:13.6: [8086:0e37] type 00 class 0x110100
[   92.287714] pci 0000:1f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.287870] pci 0000:1f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.288028] pci 0000:1f:16.2: [8086:0eca] type 00 class 0x088000
[   92.288212] pci 0000:1f:18.0: [8086:0e40] type 00 class 0x088000
[   92.288394] pci 0000:1f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.288556] pci 0000:1f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.288714] pci 0000:1f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.288887] pci 0000:1f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.289080] pci 0000:1f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.289272] pci 0000:1f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.289445] pci 0000:1f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.289630] pci 0000:1f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.289812] pci 0000:1f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.289994] pci 0000:1f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.290163] pci 0000:1f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.290333] pci 0000:1f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.290522] pci 0000:1f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.290700] pci 0000:1f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.290872] pci 0000:1f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.291060] pci 0000:1f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.291243] pci 0000:1f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.291427] pci 0000:1f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.291606] pci 0000:1f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.291803] pci 0000:1f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.291986] pci 0000:1f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.292171] pci 0000:1f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.292334] pci 0000:1f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.292504] pci_bus 0000:1f: busn_res: [bus 1f-ff] end is updated to 1f
[   92.292506] pci_bus 0000:1f: busn_res: can not insert [bus 1f] under domain [bus 00-ff] (conflicts with (null) [bus 10-1f])
[   92.292835] PCI: Discovered peer bus 2f
[   92.297054] PCI: root bus 2f: using default resources
[   92.297064] PCI: Probing PCI hardware (bus 2f)
[   92.297172] PCI host bridge to bus 0000:2f
[   92.301676] pci_bus 0000:2f: root bus resource [io  0x0000-0xffff]
[   92.308482] pci_bus 0000:2f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.316430] pci_bus 0000:2f: No busn resource found for root bus, will use [bus 2f-ff]
[   92.325146] pci_bus 0000:2f: busn_res: can not insert [bus 2f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 20-2f])
[   92.325174] pci 0000:2f:08.0: [8086:0e80] type 00 class 0x088000
[   92.325348] pci 0000:2f:08.2: [8086:0e32] type 00 class 0x110100
[   92.325516] pci 0000:2f:09.0: [8086:0e90] type 00 class 0x088000
[   92.325694] pci 0000:2f:09.2: [8086:0e33] type 00 class 0x110100
[   92.325852] pci 0000:2f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.326026] pci 0000:2f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.326183] pci 0000:2f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.326352] pci 0000:2f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.326512] pci 0000:2f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.326652] pci 0000:2f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.326793] pci 0000:2f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.326941] pci 0000:2f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.327086] pci 0000:2f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.327231] pci 0000:2f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.327408] pci 0000:2f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.327556] pci 0000:2f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.327714] pci 0000:2f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.327858] pci 0000:2f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.328027] pci 0000:2f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.328208] pci 0000:2f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.328378] pci 0000:2f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.328511] pci 0000:2f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.328678] pci 0000:2f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.328813] pci 0000:2f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.328983] pci 0000:2f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.329123] pci 0000:2f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.329319] pci 0000:2f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.329470] pci 0000:2f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.329673] pci 0000:2f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.329855] pci 0000:2f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.330051] pci 0000:2f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.330242] pci 0000:2f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.330426] pci 0000:2f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.330615] pci 0000:2f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.330796] pci 0000:2f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.330974] pci 0000:2f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.331132] pci 0000:2f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.331303] pci 0000:2f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.331498] pci 0000:2f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.331667] pci 0000:2f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.331852] pci 0000:2f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.332034] pci 0000:2f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.332214] pci 0000:2f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.332410] pci 0000:2f:11.2: [8086:0efa] type 00 class 0x088000
[   92.332584] pci 0000:2f:11.4: [8086:0efc] type 00 class 0x088000
[   92.332766] pci 0000:2f:11.5: [8086:0efd] type 00 class 0x088000
[   92.332942] pci 0000:2f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.333135] pci 0000:2f:13.1: [8086:0e34] type 00 class 0x110100
[   92.333307] pci 0000:2f:13.4: [8086:0e81] type 00 class 0x088000
[   92.333462] pci 0000:2f:13.5: [8086:0e36] type 00 class 0x110100
[   92.333605] pci 0000:2f:13.6: [8086:0e37] type 00 class 0x110100
[   92.333752] pci 0000:2f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.333910] pci 0000:2f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.334071] pci 0000:2f:16.2: [8086:0eca] type 00 class 0x088000
[   92.334248] pci 0000:2f:18.0: [8086:0e40] type 00 class 0x088000
[   92.334410] pci 0000:2f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.334597] pci 0000:2f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.334752] pci 0000:2f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.334920] pci 0000:2f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.335106] pci 0000:2f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.335282] pci 0000:2f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.335458] pci 0000:2f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.335639] pci 0000:2f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.335806] pci 0000:2f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.335975] pci 0000:2f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.336129] pci 0000:2f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.336324] pci 0000:2f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.336506] pci 0000:2f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.336699] pci 0000:2f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.336887] pci 0000:2f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.337084] pci 0000:2f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.337293] pci 0000:2f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.337481] pci 0000:2f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.337665] pci 0000:2f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.337845] pci 0000:2f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.338018] pci 0000:2f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.338209] pci 0000:2f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.338382] pci 0000:2f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.338561] pci_bus 0000:2f: busn_res: [bus 2f-ff] end is updated to 2f
[   92.338563] pci_bus 0000:2f: busn_res: can not insert [bus 2f] under domain [bus 00-ff] (conflicts with (null) [bus 20-2f])
[   92.338804] PCI: Discovered peer bus 3f
[   92.343029] PCI: root bus 3f: using default resources
[   92.343035] PCI: Probing PCI hardware (bus 3f)
[   92.343172] PCI host bridge to bus 0000:3f
[   92.347681] pci_bus 0000:3f: root bus resource [io  0x0000-0xffff]
[   92.354482] pci_bus 0000:3f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.362432] pci_bus 0000:3f: No busn resource found for root bus, will use [bus 3f-ff]
[   92.371156] pci_bus 0000:3f: busn_res: can not insert [bus 3f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 30-3f])
[   92.371182] pci 0000:3f:08.0: [8086:0e80] type 00 class 0x088000
[   92.371336] pci 0000:3f:08.2: [8086:0e32] type 00 class 0x110100
[   92.371496] pci 0000:3f:09.0: [8086:0e90] type 00 class 0x088000
[   92.371660] pci 0000:3f:09.2: [8086:0e33] type 00 class 0x110100
[   92.371816] pci 0000:3f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.371978] pci 0000:3f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.372130] pci 0000:3f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.372264] pci 0000:3f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.372425] pci 0000:3f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.372575] pci 0000:3f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.372731] pci 0000:3f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.372859] pci 0000:3f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.373012] pci 0000:3f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.373167] pci 0000:3f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.373320] pci 0000:3f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.373458] pci 0000:3f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.373616] pci 0000:3f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.373771] pci 0000:3f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.373923] pci 0000:3f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.374086] pci 0000:3f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.374233] pci 0000:3f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.374403] pci 0000:3f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.374575] pci 0000:3f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.374736] pci 0000:3f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.374877] pci 0000:3f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.375019] pci 0000:3f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.375188] pci 0000:3f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.375372] pci 0000:3f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.375543] pci 0000:3f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.375729] pci 0000:3f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.375900] pci 0000:3f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.376073] pci 0000:3f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.376262] pci 0000:3f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.376463] pci 0000:3f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.376645] pci 0000:3f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.376829] pci 0000:3f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.377031] pci 0000:3f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.377219] pci 0000:3f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.377400] pci 0000:3f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.377569] pci 0000:3f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.377744] pci 0000:3f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.377913] pci 0000:3f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.378089] pci 0000:3f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.378269] pci 0000:3f:11.2: [8086:0efa] type 00 class 0x088000
[   92.378443] pci 0000:3f:11.4: [8086:0efc] type 00 class 0x088000
[   92.378618] pci 0000:3f:11.5: [8086:0efd] type 00 class 0x088000
[   92.378791] pci 0000:3f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.378943] pci 0000:3f:13.1: [8086:0e34] type 00 class 0x110100
[   92.379090] pci 0000:3f:13.4: [8086:0e81] type 00 class 0x088000
[   92.379245] pci 0000:3f:13.5: [8086:0e36] type 00 class 0x110100
[   92.379390] pci 0000:3f:13.6: [8086:0e37] type 00 class 0x110100
[   92.379534] pci 0000:3f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.379668] pci 0000:3f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.379824] pci 0000:3f:16.2: [8086:0eca] type 00 class 0x088000
[   92.379968] pci 0000:3f:18.0: [8086:0e40] type 00 class 0x088000
[   92.380130] pci 0000:3f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.380292] pci 0000:3f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.380456] pci 0000:3f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.380629] pci 0000:3f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.380819] pci 0000:3f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.381003] pci 0000:3f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.381193] pci 0000:3f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.381383] pci 0000:3f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.381553] pci 0000:3f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.381717] pci 0000:3f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.381896] pci 0000:3f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.382090] pci 0000:3f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.382255] pci 0000:3f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.382434] pci 0000:3f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.382625] pci 0000:3f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.382785] pci 0000:3f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.382979] pci 0000:3f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.383154] pci 0000:3f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.383341] pci 0000:3f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.383521] pci 0000:3f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.383703] pci 0000:3f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.383879] pci 0000:3f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.384041] pci 0000:3f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.384229] pci_bus 0000:3f: busn_res: [bus 3f-ff] end is updated to 3f
[   92.384232] pci_bus 0000:3f: busn_res: can not insert [bus 3f] under domain [bus 00-ff] (conflicts with (null) [bus 30-3f])
[   92.384559] PCI: Discovered peer bus 4f
[   92.388784] PCI: root bus 4f: using default resources
[   92.388787] PCI: Probing PCI hardware (bus 4f)
[   92.388914] PCI host bridge to bus 0000:4f
[   92.393421] pci_bus 0000:4f: root bus resource [io  0x0000-0xffff]
[   92.400224] pci_bus 0000:4f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.408174] pci_bus 0000:4f: No busn resource found for root bus, will use [bus 4f-ff]
[   92.416888] pci_bus 0000:4f: busn_res: can not insert [bus 4f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 40-4f])
[   92.416915] pci 0000:4f:08.0: [8086:0e80] type 00 class 0x088000
[   92.417072] pci 0000:4f:08.2: [8086:0e32] type 00 class 0x110100
[   92.417236] pci 0000:4f:09.0: [8086:0e90] type 00 class 0x088000
[   92.417393] pci 0000:4f:09.2: [8086:0e33] type 00 class 0x110100
[   92.417560] pci 0000:4f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.417703] pci 0000:4f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.417866] pci 0000:4f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.418020] pci 0000:4f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.418172] pci 0000:4f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.418324] pci 0000:4f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.418493] pci 0000:4f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.418653] pci 0000:4f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.418823] pci 0000:4f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.418995] pci 0000:4f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.419179] pci 0000:4f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.419318] pci 0000:4f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.419482] pci 0000:4f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.419623] pci 0000:4f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.419785] pci 0000:4f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.419932] pci 0000:4f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.420086] pci 0000:4f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.420232] pci 0000:4f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.420396] pci 0000:4f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.420552] pci 0000:4f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.420711] pci 0000:4f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.420871] pci 0000:4f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.421029] pci 0000:4f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.421194] pci 0000:4f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.421391] pci 0000:4f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.421569] pci 0000:4f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.421760] pci 0000:4f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.421940] pci 0000:4f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.422107] pci 0000:4f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.422302] pci 0000:4f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.422469] pci 0000:4f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.422655] pci 0000:4f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.422816] pci 0000:4f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.422986] pci 0000:4f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.423155] pci 0000:4f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.423342] pci 0000:4f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.423520] pci 0000:4f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.423693] pci 0000:4f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.423872] pci 0000:4f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.424052] pci 0000:4f:11.2: [8086:0efa] type 00 class 0x088000
[   92.424232] pci 0000:4f:11.4: [8086:0efc] type 00 class 0x088000
[   92.424398] pci 0000:4f:11.5: [8086:0efd] type 00 class 0x088000
[   92.424564] pci 0000:4f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.424709] pci 0000:4f:13.1: [8086:0e34] type 00 class 0x110100
[   92.424872] pci 0000:4f:13.4: [8086:0e81] type 00 class 0x088000
[   92.425024] pci 0000:4f:13.5: [8086:0e36] type 00 class 0x110100
[   92.425191] pci 0000:4f:13.6: [8086:0e37] type 00 class 0x110100
[   92.425349] pci 0000:4f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.425494] pci 0000:4f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.425651] pci 0000:4f:16.2: [8086:0eca] type 00 class 0x088000
[   92.425804] pci 0000:4f:18.0: [8086:0e40] type 00 class 0x088000
[   92.425960] pci 0000:4f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.426124] pci 0000:4f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.426300] pci 0000:4f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.426472] pci 0000:4f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.426644] pci 0000:4f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.426826] pci 0000:4f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.427003] pci 0000:4f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.427175] pci 0000:4f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.427359] pci 0000:4f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.427560] pci 0000:4f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.427743] pci 0000:4f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.427945] pci 0000:4f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.428126] pci 0000:4f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.428322] pci 0000:4f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.428507] pci 0000:4f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.428675] pci 0000:4f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.428868] pci 0000:4f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.429037] pci 0000:4f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.429223] pci 0000:4f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.429407] pci 0000:4f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.429572] pci 0000:4f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.429755] pci 0000:4f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.429931] pci 0000:4f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.430096] pci_bus 0000:4f: busn_res: [bus 4f-ff] end is updated to 4f
[   92.430098] pci_bus 0000:4f: busn_res: can not insert [bus 4f] under domain [bus 00-ff] (conflicts with (null) [bus 40-4f])
[   92.430344] PCI: Discovered peer bus 5f
[   92.434567] PCI: root bus 5f: using default resources
[   92.434571] PCI: Probing PCI hardware (bus 5f)
[   92.434712] PCI host bridge to bus 0000:5f
[   92.439220] pci_bus 0000:5f: root bus resource [io  0x0000-0xffff]
[   92.446018] pci_bus 0000:5f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.453973] pci_bus 0000:5f: No busn resource found for root bus, will use [bus 5f-ff]
[   92.462693] pci_bus 0000:5f: busn_res: can not insert [bus 5f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 50-5f])
[   92.462719] pci 0000:5f:08.0: [8086:0e80] type 00 class 0x088000
[   92.462906] pci 0000:5f:08.2: [8086:0e32] type 00 class 0x110100
[   92.463064] pci 0000:5f:09.0: [8086:0e90] type 00 class 0x088000
[   92.463217] pci 0000:5f:09.2: [8086:0e33] type 00 class 0x110100
[   92.463382] pci 0000:5f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.463542] pci 0000:5f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.463702] pci 0000:5f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.463852] pci 0000:5f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.464011] pci 0000:5f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.464152] pci 0000:5f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.464312] pci 0000:5f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.464461] pci 0000:5f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.464622] pci 0000:5f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.464775] pci 0000:5f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.464919] pci 0000:5f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.465066] pci 0000:5f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.465205] pci 0000:5f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.465367] pci 0000:5f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.465522] pci 0000:5f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.465665] pci 0000:5f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.465805] pci 0000:5f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.465958] pci 0000:5f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.466111] pci 0000:5f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.466268] pci 0000:5f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.466404] pci 0000:5f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.466548] pci 0000:5f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.466721] pci 0000:5f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.466893] pci 0000:5f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.467080] pci 0000:5f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.467273] pci 0000:5f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.467429] pci 0000:5f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.467612] pci 0000:5f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.467780] pci 0000:5f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.467966] pci 0000:5f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.468148] pci 0000:5f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.468327] pci 0000:5f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.468513] pci 0000:5f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.468701] pci 0000:5f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.468881] pci 0000:5f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.469057] pci 0000:5f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.469239] pci 0000:5f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.469428] pci 0000:5f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.469620] pci 0000:5f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.469788] pci 0000:5f:11.2: [8086:0efa] type 00 class 0x088000
[   92.469958] pci 0000:5f:11.4: [8086:0efc] type 00 class 0x088000
[   92.470141] pci 0000:5f:11.5: [8086:0efd] type 00 class 0x088000
[   92.470319] pci 0000:5f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.470485] pci 0000:5f:13.1: [8086:0e34] type 00 class 0x110100
[   92.470632] pci 0000:5f:13.4: [8086:0e81] type 00 class 0x088000
[   92.470812] pci 0000:5f:13.5: [8086:0e36] type 00 class 0x110100
[   92.470958] pci 0000:5f:13.6: [8086:0e37] type 00 class 0x110100
[   92.471123] pci 0000:5f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.471278] pci 0000:5f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.471441] pci 0000:5f:16.2: [8086:0eca] type 00 class 0x088000
[   92.471643] pci 0000:5f:18.0: [8086:0e40] type 00 class 0x088000
[   92.471805] pci 0000:5f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.471955] pci 0000:5f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.472104] pci 0000:5f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.472281] pci 0000:5f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.472473] pci 0000:5f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.472671] pci 0000:5f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.472844] pci 0000:5f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.473029] pci 0000:5f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.473198] pci 0000:5f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.473393] pci 0000:5f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.473567] pci 0000:5f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.473756] pci 0000:5f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.473939] pci 0000:5f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.474118] pci 0000:5f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.474304] pci 0000:5f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.474480] pci 0000:5f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.474645] pci 0000:5f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.474858] pci 0000:5f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.475071] pci 0000:5f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.475254] pci 0000:5f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.475449] pci 0000:5f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.475601] pci 0000:5f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.475787] pci 0000:5f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.475950] pci_bus 0000:5f: busn_res: [bus 5f-ff] end is updated to 5f
[   92.475956] pci_bus 0000:5f: busn_res: can not insert [bus 5f] under domain [bus 00-ff] (conflicts with (null) [bus 50-5f])
[   92.476285] PCI: Discovered peer bus 6f
[   92.480506] PCI: root bus 6f: using default resources
[   92.480509] PCI: Probing PCI hardware (bus 6f)
[   92.480638] PCI host bridge to bus 0000:6f
[   92.485143] pci_bus 0000:6f: root bus resource [io  0x0000-0xffff]
[   92.491949] pci_bus 0000:6f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.499905] pci_bus 0000:6f: No busn resource found for root bus, will use [bus 6f-ff]
[   92.508620] pci_bus 0000:6f: busn_res: can not insert [bus 6f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 60-6f])
[   92.508637] pci 0000:6f:08.0: [8086:0e80] type 00 class 0x088000
[   92.508826] pci 0000:6f:08.2: [8086:0e32] type 00 class 0x110100
[   92.508996] pci 0000:6f:09.0: [8086:0e90] type 00 class 0x088000
[   92.509164] pci 0000:6f:09.2: [8086:0e33] type 00 class 0x110100
[   92.509331] pci 0000:6f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.509478] pci 0000:6f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.509627] pci 0000:6f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.509758] pci 0000:6f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.509930] pci 0000:6f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.510067] pci 0000:6f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.510219] pci 0000:6f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.510356] pci 0000:6f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.510495] pci 0000:6f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.510641] pci 0000:6f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.510801] pci 0000:6f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.510958] pci 0000:6f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.511114] pci 0000:6f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.511265] pci 0000:6f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.511417] pci 0000:6f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.511569] pci 0000:6f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.511733] pci 0000:6f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.511882] pci 0000:6f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.512027] pci 0000:6f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.512187] pci 0000:6f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.512334] pci 0000:6f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.512499] pci 0000:6f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.512653] pci 0000:6f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.512831] pci 0000:6f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.513013] pci 0000:6f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.513193] pci 0000:6f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.513384] pci 0000:6f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.513564] pci 0000:6f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.513734] pci 0000:6f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.513907] pci 0000:6f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.514072] pci 0000:6f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.514247] pci 0000:6f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.514412] pci 0000:6f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.514594] pci 0000:6f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.514812] pci 0000:6f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.514981] pci 0000:6f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.515173] pci 0000:6f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.515340] pci 0000:6f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.515515] pci 0000:6f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.515703] pci 0000:6f:11.2: [8086:0efa] type 00 class 0x088000
[   92.515879] pci 0000:6f:11.4: [8086:0efc] type 00 class 0x088000
[   92.516052] pci 0000:6f:11.5: [8086:0efd] type 00 class 0x088000
[   92.516249] pci 0000:6f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.516403] pci 0000:6f:13.1: [8086:0e34] type 00 class 0x110100
[   92.516546] pci 0000:6f:13.4: [8086:0e81] type 00 class 0x088000
[   92.516724] pci 0000:6f:13.5: [8086:0e36] type 00 class 0x110100
[   92.516892] pci 0000:6f:13.6: [8086:0e37] type 00 class 0x110100
[   92.517036] pci 0000:6f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.517195] pci 0000:6f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.517354] pci 0000:6f:16.2: [8086:0eca] type 00 class 0x088000
[   92.517525] pci 0000:6f:18.0: [8086:0e40] type 00 class 0x088000
[   92.517683] pci 0000:6f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.517840] pci 0000:6f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.517998] pci 0000:6f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.518183] pci 0000:6f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.518346] pci 0000:6f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.518541] pci 0000:6f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.518706] pci 0000:6f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.518908] pci 0000:6f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.519082] pci 0000:6f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.519250] pci 0000:6f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.519430] pci 0000:6f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.519592] pci 0000:6f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.519778] pci 0000:6f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.519974] pci 0000:6f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.520154] pci 0000:6f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.520332] pci 0000:6f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.520499] pci 0000:6f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.520673] pci 0000:6f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.520849] pci 0000:6f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.521029] pci 0000:6f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.521230] pci 0000:6f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.521411] pci 0000:6f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.521586] pci 0000:6f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.521764] pci_bus 0000:6f: busn_res: [bus 6f-ff] end is updated to 6f
[   92.521766] pci_bus 0000:6f: busn_res: can not insert [bus 6f] under domain [bus 00-ff] (conflicts with (null) [bus 60-6f])
[   92.521930] PCI: Discovered peer bus 7b
[   92.526151] PCI: root bus 7b: using default resources
[   92.526156] PCI: Probing PCI hardware (bus 7b)
[   92.526267] PCI host bridge to bus 0000:7b
[   92.530774] pci_bus 0000:7b: root bus resource [io  0x0000-0xffff]
[   92.537576] pci_bus 0000:7b: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.545524] pci_bus 0000:7b: No busn resource found for root bus, will use [bus 7b-ff]
[   92.554241] pci_bus 0000:7b: busn_res: can not insert [bus 7b-ff] under domain [bus 00-ff] (conflicts with (null) [bus 70-7b])
[   92.554257] pci 0000:7b:08.0: [8086:0e80] type 00 class 0x088000
[   92.554421] pci 0000:7b:08.2: [8086:0e32] type 00 class 0x110100
[   92.554579] pci 0000:7b:09.0: [8086:0e90] type 00 class 0x088000
[   92.554736] pci 0000:7b:09.2: [8086:0e33] type 00 class 0x110100
[   92.554861] pci 0000:7b:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.555010] pci 0000:7b:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.555158] pci 0000:7b:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.555309] pci 0000:7b:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.555458] pci 0000:7b:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.555627] pci 0000:7b:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.555770] pci 0000:7b:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.555910] pci 0000:7b:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.556062] pci 0000:7b:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.556228] pci 0000:7b:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.556388] pci 0000:7b:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.556530] pci 0000:7b:0c.5: [8086:0eea] type 00 class 0x088000
[   92.556671] pci 0000:7b:0c.6: [8086:0eec] type 00 class 0x088000
[   92.556826] pci 0000:7b:0c.7: [8086:0eee] type 00 class 0x088000
[   92.556987] pci 0000:7b:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.557145] pci 0000:7b:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.557314] pci 0000:7b:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.557478] pci 0000:7b:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.557622] pci 0000:7b:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.557786] pci 0000:7b:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.557929] pci 0000:7b:0d.6: [8086:0eed] type 00 class 0x088000
[   92.558078] pci 0000:7b:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.558224] pci 0000:7b:0e.1: [8086:0e30] type 00 class 0x110100
[   92.558392] pci 0000:7b:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.558569] pci 0000:7b:0f.1: [8086:0e71] type 00 class 0x088000
[   92.558748] pci 0000:7b:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.558920] pci 0000:7b:0f.3: [8086:0eab] type 00 class 0x088000
[   92.559108] pci 0000:7b:0f.4: [8086:0eac] type 00 class 0x088000
[   92.559295] pci 0000:7b:0f.5: [8086:0ead] type 00 class 0x088000
[   92.559476] pci 0000:7b:10.0: [8086:0eb0] type 00 class 0x088000
[   92.559646] pci 0000:7b:10.1: [8086:0eb1] type 00 class 0x088000
[   92.559814] pci 0000:7b:10.2: [8086:0eb2] type 00 class 0x088000
[   92.559988] pci 0000:7b:10.3: [8086:0eb3] type 00 class 0x088000
[   92.560172] pci 0000:7b:10.4: [8086:0eb4] type 00 class 0x088000
[   92.560355] pci 0000:7b:10.5: [8086:0eb5] type 00 class 0x088000
[   92.560533] pci 0000:7b:10.6: [8086:0eb6] type 00 class 0x088000
[   92.560712] pci 0000:7b:10.7: [8086:0eb7] type 00 class 0x088000
[   92.560878] pci 0000:7b:11.0: [8086:0ef8] type 00 class 0x088000
[   92.561064] pci 0000:7b:11.1: [8086:0ef9] type 00 class 0x088000
[   92.561227] pci 0000:7b:11.2: [8086:0efa] type 00 class 0x088000
[   92.561407] pci 0000:7b:11.4: [8086:0efc] type 00 class 0x088000
[   92.561603] pci 0000:7b:11.5: [8086:0efd] type 00 class 0x088000
[   92.561788] pci 0000:7b:13.0: [8086:0e1d] type 00 class 0x088000
[   92.561949] pci 0000:7b:13.1: [8086:0e34] type 00 class 0x110100
[   92.562107] pci 0000:7b:13.4: [8086:0e81] type 00 class 0x088000
[   92.562275] pci 0000:7b:13.5: [8086:0e36] type 00 class 0x110100
[   92.562420] pci 0000:7b:13.6: [8086:0e37] type 00 class 0x110100
[   92.562579] pci 0000:7b:16.0: [8086:0ec8] type 00 class 0x088000
[   92.562733] pci 0000:7b:16.1: [8086:0ec9] type 00 class 0x088000
[   92.562908] pci 0000:7b:16.2: [8086:0eca] type 00 class 0x088000
[   92.563066] pci 0000:7b:18.0: [8086:0e40] type 00 class 0x088000
[   92.563229] pci 0000:7b:18.2: [8086:0e3a] type 00 class 0x110100
[   92.563395] pci 0000:7b:1c.0: [8086:0e60] type 00 class 0x088000
[   92.563560] pci 0000:7b:1c.1: [8086:0e38] type 00 class 0x110100
[   92.563744] pci 0000:7b:1d.0: [8086:0e68] type 00 class 0x088000
[   92.563927] pci 0000:7b:1d.1: [8086:0e79] type 00 class 0x088000
[   92.564112] pci 0000:7b:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.564293] pci 0000:7b:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.564457] pci 0000:7b:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.564629] pci 0000:7b:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.564801] pci 0000:7b:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.564984] pci 0000:7b:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.565157] pci 0000:7b:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.565341] pci 0000:7b:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.565524] pci 0000:7b:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.565696] pci 0000:7b:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.565875] pci 0000:7b:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.566051] pci 0000:7b:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.566226] pci 0000:7b:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.566409] pci 0000:7b:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.566598] pci 0000:7b:1f.4: [8086:0edc] type 00 class 0x088000
[   92.566778] pci 0000:7b:1f.5: [8086:0edd] type 00 class 0x088000
[   92.566965] pci 0000:7b:1f.6: [8086:0ede] type 00 class 0x088000
[   92.567142] pci 0000:7b:1f.7: [8086:0edf] type 00 class 0x088000
[   92.567306] pci_bus 0000:7b: busn_res: [bus 7b-ff] end is updated to 7b
[   92.567309] pci_bus 0000:7b: busn_res: can not insert [bus 7b] under domain [bus 00-ff] (conflicts with (null) [bus 70-7b])
[   92.567677] PCI: Discovered peer bus 8f
[   92.571898] PCI: root bus 8f: using default resources
[   92.571908] PCI: Probing PCI hardware (bus 8f)
[   92.572037] PCI host bridge to bus 0000:8f
[   92.576547] pci_bus 0000:8f: root bus resource [io  0x0000-0xffff]
[   92.583352] pci_bus 0000:8f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.591305] pci_bus 0000:8f: No busn resource found for root bus, will use [bus 8f-ff]
[   92.600020] pci_bus 0000:8f: busn_res: can not insert [bus 8f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 84-8f])
[   92.600038] pci 0000:8f:08.0: [8086:0e80] type 00 class 0x088000
[   92.600196] pci 0000:8f:08.2: [8086:0e32] type 00 class 0x110100
[   92.600347] pci 0000:8f:09.0: [8086:0e90] type 00 class 0x088000
[   92.600508] pci 0000:8f:09.2: [8086:0e33] type 00 class 0x110100
[   92.600660] pci 0000:8f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.600834] pci 0000:8f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.600969] pci 0000:8f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.601127] pci 0000:8f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.601269] pci 0000:8f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.601415] pci 0000:8f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.601572] pci 0000:8f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.601718] pci 0000:8f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.601872] pci 0000:8f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.602021] pci 0000:8f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.602156] pci 0000:8f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.602303] pci 0000:8f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.602460] pci 0000:8f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.602607] pci 0000:8f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.602751] pci 0000:8f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.602899] pci 0000:8f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.603052] pci 0000:8f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.603214] pci 0000:8f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.603372] pci 0000:8f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.603510] pci 0000:8f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.603660] pci 0000:8f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.603808] pci 0000:8f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.603964] pci 0000:8f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.604145] pci 0000:8f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.604331] pci 0000:8f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.604531] pci 0000:8f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.604697] pci 0000:8f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.604895] pci 0000:8f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.605071] pci 0000:8f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.605258] pci 0000:8f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.605429] pci 0000:8f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.605612] pci 0000:8f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.605786] pci 0000:8f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.605961] pci 0000:8f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.606162] pci 0000:8f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.606337] pci 0000:8f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.606517] pci 0000:8f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.606707] pci 0000:8f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.606867] pci 0000:8f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.607050] pci 0000:8f:11.2: [8086:0efa] type 00 class 0x088000
[   92.607228] pci 0000:8f:11.4: [8086:0efc] type 00 class 0x088000
[   92.607415] pci 0000:8f:11.5: [8086:0efd] type 00 class 0x088000
[   92.607584] pci 0000:8f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.607745] pci 0000:8f:13.1: [8086:0e34] type 00 class 0x110100
[   92.607901] pci 0000:8f:13.4: [8086:0e81] type 00 class 0x088000
[   92.608065] pci 0000:8f:13.5: [8086:0e36] type 00 class 0x110100
[   92.608218] pci 0000:8f:13.6: [8086:0e37] type 00 class 0x110100
[   92.608359] pci 0000:8f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.608505] pci 0000:8f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.608666] pci 0000:8f:16.2: [8086:0eca] type 00 class 0x088000
[   92.608830] pci 0000:8f:18.0: [8086:0e40] type 00 class 0x088000
[   92.609017] pci 0000:8f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.609193] pci 0000:8f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.609361] pci 0000:8f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.609566] pci 0000:8f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.609741] pci 0000:8f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.609923] pci 0000:8f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.610102] pci 0000:8f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.610280] pci 0000:8f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.610465] pci 0000:8f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.610627] pci 0000:8f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.610780] pci 0000:8f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.610955] pci 0000:8f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.611141] pci 0000:8f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.611316] pci 0000:8f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.611507] pci 0000:8f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.611674] pci 0000:8f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.611871] pci 0000:8f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.612061] pci 0000:8f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.612252] pci 0000:8f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.612455] pci 0000:8f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.612625] pci 0000:8f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.612801] pci 0000:8f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.612971] pci 0000:8f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.613138] pci_bus 0000:8f: busn_res: [bus 8f-ff] end is updated to 8f
[   92.613141] pci_bus 0000:8f: busn_res: can not insert [bus 8f] under domain [bus 00-ff] (conflicts with (null) [bus 84-8f])
[   92.613389] PCI: Discovered peer bus 9f
[   92.617612] PCI: root bus 9f: using default resources
[   92.617616] PCI: Probing PCI hardware (bus 9f)
[   92.617751] PCI host bridge to bus 0000:9f
[   92.622260] pci_bus 0000:9f: root bus resource [io  0x0000-0xffff]
[   92.629063] pci_bus 0000:9f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.637012] pci_bus 0000:9f: No busn resource found for root bus, will use [bus 9f-ff]
[   92.645728] pci_bus 0000:9f: busn_res: can not insert [bus 9f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 90-9f])
[   92.645755] pci 0000:9f:08.0: [8086:0e80] type 00 class 0x088000
[   92.645915] pci 0000:9f:08.2: [8086:0e32] type 00 class 0x110100
[   92.646092] pci 0000:9f:09.0: [8086:0e90] type 00 class 0x088000
[   92.646256] pci 0000:9f:09.2: [8086:0e33] type 00 class 0x110100
[   92.646424] pci 0000:9f:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.646573] pci 0000:9f:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.646742] pci 0000:9f:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.646896] pci 0000:9f:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.647075] pci 0000:9f:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.647210] pci 0000:9f:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.647366] pci 0000:9f:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.647522] pci 0000:9f:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.647659] pci 0000:9f:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.647823] pci 0000:9f:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.647975] pci 0000:9f:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.648132] pci 0000:9f:0c.5: [8086:0eea] type 00 class 0x088000
[   92.648279] pci 0000:9f:0c.6: [8086:0eec] type 00 class 0x088000
[   92.648427] pci 0000:9f:0c.7: [8086:0eee] type 00 class 0x088000
[   92.648574] pci 0000:9f:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.648729] pci 0000:9f:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.648885] pci 0000:9f:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.649038] pci 0000:9f:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.649189] pci 0000:9f:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.649334] pci 0000:9f:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.649494] pci 0000:9f:0d.6: [8086:0eed] type 00 class 0x088000
[   92.649644] pci 0000:9f:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.649813] pci 0000:9f:0e.1: [8086:0e30] type 00 class 0x110100
[   92.649983] pci 0000:9f:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.650153] pci 0000:9f:0f.1: [8086:0e71] type 00 class 0x088000
[   92.650338] pci 0000:9f:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.650513] pci 0000:9f:0f.3: [8086:0eab] type 00 class 0x088000
[   92.650709] pci 0000:9f:0f.4: [8086:0eac] type 00 class 0x088000
[   92.650887] pci 0000:9f:0f.5: [8086:0ead] type 00 class 0x088000
[   92.651075] pci 0000:9f:10.0: [8086:0eb0] type 00 class 0x088000
[   92.651253] pci 0000:9f:10.1: [8086:0eb1] type 00 class 0x088000
[   92.651430] pci 0000:9f:10.2: [8086:0eb2] type 00 class 0x088000
[   92.651607] pci 0000:9f:10.3: [8086:0eb3] type 00 class 0x088000
[   92.651796] pci 0000:9f:10.4: [8086:0eb4] type 00 class 0x088000
[   92.651975] pci 0000:9f:10.5: [8086:0eb5] type 00 class 0x088000
[   92.652151] pci 0000:9f:10.6: [8086:0eb6] type 00 class 0x088000
[   92.652323] pci 0000:9f:10.7: [8086:0eb7] type 00 class 0x088000
[   92.652488] pci 0000:9f:11.0: [8086:0ef8] type 00 class 0x088000
[   92.652647] pci 0000:9f:11.1: [8086:0ef9] type 00 class 0x088000
[   92.652812] pci 0000:9f:11.2: [8086:0efa] type 00 class 0x088000
[   92.652981] pci 0000:9f:11.4: [8086:0efc] type 00 class 0x088000
[   92.653151] pci 0000:9f:11.5: [8086:0efd] type 00 class 0x088000
[   92.653314] pci 0000:9f:13.0: [8086:0e1d] type 00 class 0x088000
[   92.653463] pci 0000:9f:13.1: [8086:0e34] type 00 class 0x110100
[   92.653611] pci 0000:9f:13.4: [8086:0e81] type 00 class 0x088000
[   92.653765] pci 0000:9f:13.5: [8086:0e36] type 00 class 0x110100
[   92.653915] pci 0000:9f:13.6: [8086:0e37] type 00 class 0x110100
[   92.654073] pci 0000:9f:16.0: [8086:0ec8] type 00 class 0x088000
[   92.654205] pci 0000:9f:16.1: [8086:0ec9] type 00 class 0x088000
[   92.654362] pci 0000:9f:16.2: [8086:0eca] type 00 class 0x088000
[   92.654524] pci 0000:9f:18.0: [8086:0e40] type 00 class 0x088000
[   92.654680] pci 0000:9f:18.2: [8086:0e3a] type 00 class 0x110100
[   92.654826] pci 0000:9f:1c.0: [8086:0e60] type 00 class 0x088000
[   92.654975] pci 0000:9f:1c.1: [8086:0e38] type 00 class 0x110100
[   92.655136] pci 0000:9f:1d.0: [8086:0e68] type 00 class 0x088000
[   92.655308] pci 0000:9f:1d.1: [8086:0e79] type 00 class 0x088000
[   92.655502] pci 0000:9f:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.655695] pci 0000:9f:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.655878] pci 0000:9f:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.656050] pci 0000:9f:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.656242] pci 0000:9f:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.656420] pci 0000:9f:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.656607] pci 0000:9f:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.656776] pci 0000:9f:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.656962] pci 0000:9f:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.657148] pci 0000:9f:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.657320] pci 0000:9f:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.657513] pci 0000:9f:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.657660] pci 0000:9f:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.657858] pci 0000:9f:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.658030] pci 0000:9f:1f.4: [8086:0edc] type 00 class 0x088000
[   92.658217] pci 0000:9f:1f.5: [8086:0edd] type 00 class 0x088000
[   92.658383] pci 0000:9f:1f.6: [8086:0ede] type 00 class 0x088000
[   92.658571] pci 0000:9f:1f.7: [8086:0edf] type 00 class 0x088000
[   92.658735] pci_bus 0000:9f: busn_res: [bus 9f-ff] end is updated to 9f
[   92.658737] pci_bus 0000:9f: busn_res: can not insert [bus 9f] under domain [bus 00-ff] (conflicts with (null) [bus 90-9f])
[   92.659072] PCI: Discovered peer bus af
[   92.663292] PCI: root bus af: using default resources
[   92.663295] PCI: Probing PCI hardware (bus af)
[   92.663424] PCI host bridge to bus 0000:af
[   92.667931] pci_bus 0000:af: root bus resource [io  0x0000-0xffff]
[   92.674733] pci_bus 0000:af: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.682686] pci_bus 0000:af: No busn resource found for root bus, will use [bus af-ff]
[   92.691405] pci_bus 0000:af: busn_res: can not insert [bus af-ff] under domain [bus 00-ff] (conflicts with (null) [bus a0-af])
[   92.691417] pci 0000:af:08.0: [8086:0e80] type 00 class 0x088000
[   92.691581] pci 0000:af:08.2: [8086:0e32] type 00 class 0x110100
[   92.691744] pci 0000:af:09.0: [8086:0e90] type 00 class 0x088000
[   92.691898] pci 0000:af:09.2: [8086:0e33] type 00 class 0x110100
[   92.692049] pci 0000:af:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.692199] pci 0000:af:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.692341] pci 0000:af:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.692489] pci 0000:af:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.692657] pci 0000:af:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.692807] pci 0000:af:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.692956] pci 0000:af:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.693098] pci 0000:af:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.693251] pci 0000:af:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.693406] pci 0000:af:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.693554] pci 0000:af:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.693690] pci 0000:af:0c.5: [8086:0eea] type 00 class 0x088000
[   92.693832] pci 0000:af:0c.6: [8086:0eec] type 00 class 0x088000
[   92.693965] pci 0000:af:0c.7: [8086:0eee] type 00 class 0x088000
[   92.694128] pci 0000:af:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.694270] pci 0000:af:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.694434] pci 0000:af:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.694582] pci 0000:af:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.694742] pci 0000:af:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.694888] pci 0000:af:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.695050] pci 0000:af:0d.6: [8086:0eed] type 00 class 0x088000
[   92.695206] pci 0000:af:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.695400] pci 0000:af:0e.1: [8086:0e30] type 00 class 0x110100
[   92.695562] pci 0000:af:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.695754] pci 0000:af:0f.1: [8086:0e71] type 00 class 0x088000
[   92.695935] pci 0000:af:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.696115] pci 0000:af:0f.3: [8086:0eab] type 00 class 0x088000
[   92.696280] pci 0000:af:0f.4: [8086:0eac] type 00 class 0x088000
[   92.696465] pci 0000:af:0f.5: [8086:0ead] type 00 class 0x088000
[   92.696640] pci 0000:af:10.0: [8086:0eb0] type 00 class 0x088000
[   92.696831] pci 0000:af:10.1: [8086:0eb1] type 00 class 0x088000
[   92.697005] pci 0000:af:10.2: [8086:0eb2] type 00 class 0x088000
[   92.697192] pci 0000:af:10.3: [8086:0eb3] type 00 class 0x088000
[   92.697365] pci 0000:af:10.4: [8086:0eb4] type 00 class 0x088000
[   92.697547] pci 0000:af:10.5: [8086:0eb5] type 00 class 0x088000
[   92.697730] pci 0000:af:10.6: [8086:0eb6] type 00 class 0x088000
[   92.697904] pci 0000:af:10.7: [8086:0eb7] type 00 class 0x088000
[   92.698085] pci 0000:af:11.0: [8086:0ef8] type 00 class 0x088000
[   92.698267] pci 0000:af:11.1: [8086:0ef9] type 00 class 0x088000
[   92.698440] pci 0000:af:11.2: [8086:0efa] type 00 class 0x088000
[   92.698624] pci 0000:af:11.4: [8086:0efc] type 00 class 0x088000
[   92.698798] pci 0000:af:11.5: [8086:0efd] type 00 class 0x088000
[   92.698983] pci 0000:af:13.0: [8086:0e1d] type 00 class 0x088000
[   92.699132] pci 0000:af:13.1: [8086:0e34] type 00 class 0x110100
[   92.699285] pci 0000:af:13.4: [8086:0e81] type 00 class 0x088000
[   92.699449] pci 0000:af:13.5: [8086:0e36] type 00 class 0x110100
[   92.699588] pci 0000:af:13.6: [8086:0e37] type 00 class 0x110100
[   92.699740] pci 0000:af:16.0: [8086:0ec8] type 00 class 0x088000
[   92.699901] pci 0000:af:16.1: [8086:0ec9] type 00 class 0x088000
[   92.700069] pci 0000:af:16.2: [8086:0eca] type 00 class 0x088000
[   92.700224] pci 0000:af:18.0: [8086:0e40] type 00 class 0x088000
[   92.700395] pci 0000:af:18.2: [8086:0e3a] type 00 class 0x110100
[   92.700571] pci 0000:af:1c.0: [8086:0e60] type 00 class 0x088000
[   92.700740] pci 0000:af:1c.1: [8086:0e38] type 00 class 0x110100
[   92.700911] pci 0000:af:1d.0: [8086:0e68] type 00 class 0x088000
[   92.701093] pci 0000:af:1d.1: [8086:0e79] type 00 class 0x088000
[   92.701276] pci 0000:af:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.701454] pci 0000:af:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.701662] pci 0000:af:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.701858] pci 0000:af:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.702051] pci 0000:af:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.702223] pci 0000:af:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.702394] pci 0000:af:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.702555] pci 0000:af:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.702733] pci 0000:af:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.702913] pci 0000:af:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.703101] pci 0000:af:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.703265] pci 0000:af:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.703448] pci 0000:af:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.703635] pci 0000:af:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.703815] pci 0000:af:1f.4: [8086:0edc] type 00 class 0x088000
[   92.703998] pci 0000:af:1f.5: [8086:0edd] type 00 class 0x088000
[   92.704197] pci 0000:af:1f.6: [8086:0ede] type 00 class 0x088000
[   92.704371] pci 0000:af:1f.7: [8086:0edf] type 00 class 0x088000
[   92.704552] pci_bus 0000:af: busn_res: [bus af-ff] end is updated to af
[   92.704555] pci_bus 0000:af: busn_res: can not insert [bus af] under domain [bus 00-ff] (conflicts with (null) [bus a0-af])
[   92.704801] PCI: Discovered peer bus bf
[   92.709028] PCI: root bus bf: using default resources
[   92.709030] PCI: Probing PCI hardware (bus bf)
[   92.709133] PCI host bridge to bus 0000:bf
[   92.713644] pci_bus 0000:bf: root bus resource [io  0x0000-0xffff]
[   92.720446] pci_bus 0000:bf: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.728414] pci_bus 0000:bf: No busn resource found for root bus, will use [bus bf-ff]
[   92.737133] pci_bus 0000:bf: busn_res: can not insert [bus bf-ff] under domain [bus 00-ff] (conflicts with (null) [bus b0-bf])
[   92.737148] pci 0000:bf:08.0: [8086:0e80] type 00 class 0x088000
[   92.737323] pci 0000:bf:08.2: [8086:0e32] type 00 class 0x110100
[   92.737465] pci 0000:bf:09.0: [8086:0e90] type 00 class 0x088000
[   92.737620] pci 0000:bf:09.2: [8086:0e33] type 00 class 0x110100
[   92.737775] pci 0000:bf:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.737921] pci 0000:bf:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.738072] pci 0000:bf:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.738227] pci 0000:bf:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.738372] pci 0000:bf:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.738524] pci 0000:bf:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.738672] pci 0000:bf:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.738821] pci 0000:bf:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.738971] pci 0000:bf:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.739111] pci 0000:bf:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.739262] pci 0000:bf:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.739424] pci 0000:bf:0c.5: [8086:0eea] type 00 class 0x088000
[   92.739552] pci 0000:bf:0c.6: [8086:0eec] type 00 class 0x088000
[   92.739692] pci 0000:bf:0c.7: [8086:0eee] type 00 class 0x088000
[   92.739841] pci 0000:bf:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.740006] pci 0000:bf:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.740152] pci 0000:bf:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.740305] pci 0000:bf:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.740449] pci 0000:bf:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.740594] pci 0000:bf:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.740733] pci 0000:bf:0d.6: [8086:0eed] type 00 class 0x088000
[   92.740867] pci 0000:bf:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.741022] pci 0000:bf:0e.1: [8086:0e30] type 00 class 0x110100
[   92.741187] pci 0000:bf:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.741371] pci 0000:bf:0f.1: [8086:0e71] type 00 class 0x088000
[   92.741586] pci 0000:bf:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.741776] pci 0000:bf:0f.3: [8086:0eab] type 00 class 0x088000
[   92.741967] pci 0000:bf:0f.4: [8086:0eac] type 00 class 0x088000
[   92.742157] pci 0000:bf:0f.5: [8086:0ead] type 00 class 0x088000
[   92.742347] pci 0000:bf:10.0: [8086:0eb0] type 00 class 0x088000
[   92.742536] pci 0000:bf:10.1: [8086:0eb1] type 00 class 0x088000
[   92.742721] pci 0000:bf:10.2: [8086:0eb2] type 00 class 0x088000
[   92.742892] pci 0000:bf:10.3: [8086:0eb3] type 00 class 0x088000
[   92.743059] pci 0000:bf:10.4: [8086:0eb4] type 00 class 0x088000
[   92.743240] pci 0000:bf:10.5: [8086:0eb5] type 00 class 0x088000
[   92.743395] pci 0000:bf:10.6: [8086:0eb6] type 00 class 0x088000
[   92.743575] pci 0000:bf:10.7: [8086:0eb7] type 00 class 0x088000
[   92.743742] pci 0000:bf:11.0: [8086:0ef8] type 00 class 0x088000
[   92.743913] pci 0000:bf:11.1: [8086:0ef9] type 00 class 0x088000
[   92.744084] pci 0000:bf:11.2: [8086:0efa] type 00 class 0x088000
[   92.744257] pci 0000:bf:11.4: [8086:0efc] type 00 class 0x088000
[   92.744437] pci 0000:bf:11.5: [8086:0efd] type 00 class 0x088000
[   92.744643] pci 0000:bf:13.0: [8086:0e1d] type 00 class 0x088000
[   92.744788] pci 0000:bf:13.1: [8086:0e34] type 00 class 0x110100
[   92.744964] pci 0000:bf:13.4: [8086:0e81] type 00 class 0x088000
[   92.745121] pci 0000:bf:13.5: [8086:0e36] type 00 class 0x110100
[   92.745284] pci 0000:bf:13.6: [8086:0e37] type 00 class 0x110100
[   92.745433] pci 0000:bf:16.0: [8086:0ec8] type 00 class 0x088000
[   92.745587] pci 0000:bf:16.1: [8086:0ec9] type 00 class 0x088000
[   92.745736] pci 0000:bf:16.2: [8086:0eca] type 00 class 0x088000
[   92.745898] pci 0000:bf:18.0: [8086:0e40] type 00 class 0x088000
[   92.746062] pci 0000:bf:18.2: [8086:0e3a] type 00 class 0x110100
[   92.746230] pci 0000:bf:1c.0: [8086:0e60] type 00 class 0x088000
[   92.746387] pci 0000:bf:1c.1: [8086:0e38] type 00 class 0x110100
[   92.746562] pci 0000:bf:1d.0: [8086:0e68] type 00 class 0x088000
[   92.746752] pci 0000:bf:1d.1: [8086:0e79] type 00 class 0x088000
[   92.746936] pci 0000:bf:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.747124] pci 0000:bf:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.747301] pci 0000:bf:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.747503] pci 0000:bf:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.747677] pci 0000:bf:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.747850] pci 0000:bf:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.748037] pci 0000:bf:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.748201] pci 0000:bf:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.748371] pci 0000:bf:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.748554] pci 0000:bf:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.748747] pci 0000:bf:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.748930] pci 0000:bf:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.749134] pci 0000:bf:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.749314] pci 0000:bf:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.749511] pci 0000:bf:1f.4: [8086:0edc] type 00 class 0x088000
[   92.749698] pci 0000:bf:1f.5: [8086:0edd] type 00 class 0x088000
[   92.749875] pci 0000:bf:1f.6: [8086:0ede] type 00 class 0x088000
[   92.750062] pci 0000:bf:1f.7: [8086:0edf] type 00 class 0x088000
[   92.750253] pci_bus 0000:bf: busn_res: [bus bf-ff] end is updated to bf
[   92.750256] pci_bus 0000:bf: busn_res: can not insert [bus bf] under domain [bus 00-ff] (conflicts with (null) [bus b0-bf])
[   92.750568] PCI: Discovered peer bus cf
[   92.754788] PCI: root bus cf: using default resources
[   92.754792] PCI: Probing PCI hardware (bus cf)
[   92.754907] PCI host bridge to bus 0000:cf
[   92.759414] pci_bus 0000:cf: root bus resource [io  0x0000-0xffff]
[   92.766216] pci_bus 0000:cf: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.774165] pci_bus 0000:cf: No busn resource found for root bus, will use [bus cf-ff]
[   92.782882] pci_bus 0000:cf: busn_res: can not insert [bus cf-ff] under domain [bus 00-ff] (conflicts with (null) [bus c0-cf])
[   92.782904] pci 0000:cf:08.0: [8086:0e80] type 00 class 0x088000
[   92.783074] pci 0000:cf:08.2: [8086:0e32] type 00 class 0x110100
[   92.783252] pci 0000:cf:09.0: [8086:0e90] type 00 class 0x088000
[   92.783401] pci 0000:cf:09.2: [8086:0e33] type 00 class 0x110100
[   92.783572] pci 0000:cf:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.783737] pci 0000:cf:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.783882] pci 0000:cf:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.784040] pci 0000:cf:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.784202] pci 0000:cf:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.784340] pci 0000:cf:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.784497] pci 0000:cf:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.784654] pci 0000:cf:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.784798] pci 0000:cf:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.784936] pci 0000:cf:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.785090] pci 0000:cf:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.785246] pci 0000:cf:0c.5: [8086:0eea] type 00 class 0x088000
[   92.785384] pci 0000:cf:0c.6: [8086:0eec] type 00 class 0x088000
[   92.785536] pci 0000:cf:0c.7: [8086:0eee] type 00 class 0x088000
[   92.785680] pci 0000:cf:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.785832] pci 0000:cf:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.785979] pci 0000:cf:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.786139] pci 0000:cf:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.786279] pci 0000:cf:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.786439] pci 0000:cf:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.786573] pci 0000:cf:0d.6: [8086:0eed] type 00 class 0x088000
[   92.786713] pci 0000:cf:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.786865] pci 0000:cf:0e.1: [8086:0e30] type 00 class 0x110100
[   92.787030] pci 0000:cf:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.787193] pci 0000:cf:0f.1: [8086:0e71] type 00 class 0x088000
[   92.787359] pci 0000:cf:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.787528] pci 0000:cf:0f.3: [8086:0eab] type 00 class 0x088000
[   92.787701] pci 0000:cf:0f.4: [8086:0eac] type 00 class 0x088000
[   92.787860] pci 0000:cf:0f.5: [8086:0ead] type 00 class 0x088000
[   92.788035] pci 0000:cf:10.0: [8086:0eb0] type 00 class 0x088000
[   92.788214] pci 0000:cf:10.1: [8086:0eb1] type 00 class 0x088000
[   92.788395] pci 0000:cf:10.2: [8086:0eb2] type 00 class 0x088000
[   92.788576] pci 0000:cf:10.3: [8086:0eb3] type 00 class 0x088000
[   92.788750] pci 0000:cf:10.4: [8086:0eb4] type 00 class 0x088000
[   92.788931] pci 0000:cf:10.5: [8086:0eb5] type 00 class 0x088000
[   92.789101] pci 0000:cf:10.6: [8086:0eb6] type 00 class 0x088000
[   92.789264] pci 0000:cf:10.7: [8086:0eb7] type 00 class 0x088000
[   92.789425] pci 0000:cf:11.0: [8086:0ef8] type 00 class 0x088000
[   92.789574] pci 0000:cf:11.1: [8086:0ef9] type 00 class 0x088000
[   92.789738] pci 0000:cf:11.2: [8086:0efa] type 00 class 0x088000
[   92.789916] pci 0000:cf:11.4: [8086:0efc] type 00 class 0x088000
[   92.790085] pci 0000:cf:11.5: [8086:0efd] type 00 class 0x088000
[   92.790267] pci 0000:cf:13.0: [8086:0e1d] type 00 class 0x088000
[   92.790411] pci 0000:cf:13.1: [8086:0e34] type 00 class 0x110100
[   92.790564] pci 0000:cf:13.4: [8086:0e81] type 00 class 0x088000
[   92.790708] pci 0000:cf:13.5: [8086:0e36] type 00 class 0x110100
[   92.790869] pci 0000:cf:13.6: [8086:0e37] type 00 class 0x110100
[   92.791030] pci 0000:cf:16.0: [8086:0ec8] type 00 class 0x088000
[   92.791186] pci 0000:cf:16.1: [8086:0ec9] type 00 class 0x088000
[   92.791340] pci 0000:cf:16.2: [8086:0eca] type 00 class 0x088000
[   92.791523] pci 0000:cf:18.0: [8086:0e40] type 00 class 0x088000
[   92.791673] pci 0000:cf:18.2: [8086:0e3a] type 00 class 0x110100
[   92.791835] pci 0000:cf:1c.0: [8086:0e60] type 00 class 0x088000
[   92.791995] pci 0000:cf:1c.1: [8086:0e38] type 00 class 0x110100
[   92.792167] pci 0000:cf:1d.0: [8086:0e68] type 00 class 0x088000
[   92.792334] pci 0000:cf:1d.1: [8086:0e79] type 00 class 0x088000
[   92.792514] pci 0000:cf:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.792694] pci 0000:cf:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.792870] pci 0000:cf:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.793041] pci 0000:cf:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.793211] pci 0000:cf:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.793382] pci 0000:cf:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.793551] pci 0000:cf:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.793726] pci 0000:cf:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.793918] pci 0000:cf:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.794112] pci 0000:cf:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.794287] pci 0000:cf:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.794463] pci 0000:cf:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.794635] pci 0000:cf:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.794807] pci 0000:cf:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.794990] pci 0000:cf:1f.4: [8086:0edc] type 00 class 0x088000
[   92.795161] pci 0000:cf:1f.5: [8086:0edd] type 00 class 0x088000
[   92.795332] pci 0000:cf:1f.6: [8086:0ede] type 00 class 0x088000
[   92.795497] pci 0000:cf:1f.7: [8086:0edf] type 00 class 0x088000
[   92.795666] pci_bus 0000:cf: busn_res: [bus cf-ff] end is updated to cf
[   92.795669] pci_bus 0000:cf: busn_res: can not insert [bus cf] under domain [bus 00-ff] (conflicts with (null) [bus c0-cf])
[   92.795880] PCI: Discovered peer bus df
[   92.800105] PCI: root bus df: using default resources
[   92.800112] PCI: Probing PCI hardware (bus df)
[   92.800223] PCI host bridge to bus 0000:df
[   92.804729] pci_bus 0000:df: root bus resource [io  0x0000-0xffff]
[   92.811531] pci_bus 0000:df: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.819478] pci_bus 0000:df: No busn resource found for root bus, will use [bus df-ff]
[   92.828192] pci_bus 0000:df: busn_res: can not insert [bus df-ff] under domain [bus 00-ff] (conflicts with (null) [bus d0-df])
[   92.828209] pci 0000:df:08.0: [8086:0e80] type 00 class 0x088000
[   92.828371] pci 0000:df:08.2: [8086:0e32] type 00 class 0x110100
[   92.828524] pci 0000:df:09.0: [8086:0e90] type 00 class 0x088000
[   92.828673] pci 0000:df:09.2: [8086:0e33] type 00 class 0x110100
[   92.828816] pci 0000:df:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.828947] pci 0000:df:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.829080] pci 0000:df:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.829216] pci 0000:df:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.829353] pci 0000:df:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.829490] pci 0000:df:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.829649] pci 0000:df:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.829777] pci 0000:df:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.829920] pci 0000:df:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.830052] pci 0000:df:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.830192] pci 0000:df:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.830330] pci 0000:df:0c.5: [8086:0eea] type 00 class 0x088000
[   92.830484] pci 0000:df:0c.6: [8086:0eec] type 00 class 0x088000
[   92.830629] pci 0000:df:0c.7: [8086:0eee] type 00 class 0x088000
[   92.830768] pci 0000:df:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.830906] pci 0000:df:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.831052] pci 0000:df:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.831199] pci 0000:df:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.831340] pci 0000:df:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.831493] pci 0000:df:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.831640] pci 0000:df:0d.6: [8086:0eed] type 00 class 0x088000
[   92.831788] pci 0000:df:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.831934] pci 0000:df:0e.1: [8086:0e30] type 00 class 0x110100
[   92.832097] pci 0000:df:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.832268] pci 0000:df:0f.1: [8086:0e71] type 00 class 0x088000
[   92.832428] pci 0000:df:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.832593] pci 0000:df:0f.3: [8086:0eab] type 00 class 0x088000
[   92.832750] pci 0000:df:0f.4: [8086:0eac] type 00 class 0x088000
[   92.832927] pci 0000:df:0f.5: [8086:0ead] type 00 class 0x088000
[   92.833084] pci 0000:df:10.0: [8086:0eb0] type 00 class 0x088000
[   92.833249] pci 0000:df:10.1: [8086:0eb1] type 00 class 0x088000
[   92.833409] pci 0000:df:10.2: [8086:0eb2] type 00 class 0x088000
[   92.833607] pci 0000:df:10.3: [8086:0eb3] type 00 class 0x088000
[   92.833771] pci 0000:df:10.4: [8086:0eb4] type 00 class 0x088000
[   92.833940] pci 0000:df:10.5: [8086:0eb5] type 00 class 0x088000
[   92.834113] pci 0000:df:10.6: [8086:0eb6] type 00 class 0x088000
[   92.834285] pci 0000:df:10.7: [8086:0eb7] type 00 class 0x088000
[   92.834467] pci 0000:df:11.0: [8086:0ef8] type 00 class 0x088000
[   92.834632] pci 0000:df:11.1: [8086:0ef9] type 00 class 0x088000
[   92.834807] pci 0000:df:11.2: [8086:0efa] type 00 class 0x088000
[   92.834982] pci 0000:df:11.4: [8086:0efc] type 00 class 0x088000
[   92.835139] pci 0000:df:11.5: [8086:0efd] type 00 class 0x088000
[   92.835313] pci 0000:df:13.0: [8086:0e1d] type 00 class 0x088000
[   92.835464] pci 0000:df:13.1: [8086:0e34] type 00 class 0x110100
[   92.835610] pci 0000:df:13.4: [8086:0e81] type 00 class 0x088000
[   92.835750] pci 0000:df:13.5: [8086:0e36] type 00 class 0x110100
[   92.835892] pci 0000:df:13.6: [8086:0e37] type 00 class 0x110100
[   92.836043] pci 0000:df:16.0: [8086:0ec8] type 00 class 0x088000
[   92.836179] pci 0000:df:16.1: [8086:0ec9] type 00 class 0x088000
[   92.836331] pci 0000:df:16.2: [8086:0eca] type 00 class 0x088000
[   92.836489] pci 0000:df:18.0: [8086:0e40] type 00 class 0x088000
[   92.836656] pci 0000:df:18.2: [8086:0e3a] type 00 class 0x110100
[   92.836806] pci 0000:df:1c.0: [8086:0e60] type 00 class 0x088000
[   92.836954] pci 0000:df:1c.1: [8086:0e38] type 00 class 0x110100
[   92.837115] pci 0000:df:1d.0: [8086:0e68] type 00 class 0x088000
[   92.837269] pci 0000:df:1d.1: [8086:0e79] type 00 class 0x088000
[   92.837439] pci 0000:df:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.837614] pci 0000:df:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.837787] pci 0000:df:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.837940] pci 0000:df:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.838113] pci 0000:df:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.838260] pci 0000:df:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.838418] pci 0000:df:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.838572] pci 0000:df:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.838756] pci 0000:df:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.838939] pci 0000:df:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.839103] pci 0000:df:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.839265] pci 0000:df:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.839415] pci 0000:df:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.839579] pci 0000:df:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.839736] pci 0000:df:1f.4: [8086:0edc] type 00 class 0x088000
[   92.839907] pci 0000:df:1f.5: [8086:0edd] type 00 class 0x088000
[   92.840075] pci 0000:df:1f.6: [8086:0ede] type 00 class 0x088000
[   92.840246] pci 0000:df:1f.7: [8086:0edf] type 00 class 0x088000
[   92.840396] pci_bus 0000:df: busn_res: [bus df-ff] end is updated to df
[   92.840398] pci_bus 0000:df: busn_res: can not insert [bus df] under domain [bus 00-ff] (conflicts with (null) [bus d0-df])
[   92.840735] PCI: Discovered peer bus ef
[   92.844957] PCI: root bus ef: using default resources
[   92.844963] PCI: Probing PCI hardware (bus ef)
[   92.845091] PCI host bridge to bus 0000:ef
[   92.849597] pci_bus 0000:ef: root bus resource [io  0x0000-0xffff]
[   92.856399] pci_bus 0000:ef: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.864352] pci_bus 0000:ef: No busn resource found for root bus, will use [bus ef-ff]
[   92.873075] pci_bus 0000:ef: busn_res: can not insert [bus ef-ff] under domain [bus 00-ff] (conflicts with (null) [bus e0-ef])
[   92.873099] pci 0000:ef:08.0: [8086:0e80] type 00 class 0x088000
[   92.873268] pci 0000:ef:08.2: [8086:0e32] type 00 class 0x110100
[   92.873437] pci 0000:ef:09.0: [8086:0e90] type 00 class 0x088000
[   92.873608] pci 0000:ef:09.2: [8086:0e33] type 00 class 0x110100
[   92.873786] pci 0000:ef:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.873947] pci 0000:ef:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.874109] pci 0000:ef:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.874266] pci 0000:ef:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.874435] pci 0000:ef:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.874589] pci 0000:ef:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.874751] pci 0000:ef:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.874897] pci 0000:ef:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.875040] pci 0000:ef:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.875186] pci 0000:ef:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.875334] pci 0000:ef:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.875488] pci 0000:ef:0c.5: [8086:0eea] type 00 class 0x088000
[   92.875623] pci 0000:ef:0c.6: [8086:0eec] type 00 class 0x088000
[   92.875757] pci 0000:ef:0c.7: [8086:0eee] type 00 class 0x088000
[   92.875903] pci 0000:ef:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.876038] pci 0000:ef:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.876174] pci 0000:ef:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.876344] pci 0000:ef:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.876482] pci 0000:ef:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.876644] pci 0000:ef:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.876782] pci 0000:ef:0d.6: [8086:0eed] type 00 class 0x088000
[   92.876943] pci 0000:ef:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.877111] pci 0000:ef:0e.1: [8086:0e30] type 00 class 0x110100
[   92.877286] pci 0000:ef:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.877463] pci 0000:ef:0f.1: [8086:0e71] type 00 class 0x088000
[   92.877643] pci 0000:ef:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.877816] pci 0000:ef:0f.3: [8086:0eab] type 00 class 0x088000
[   92.877989] pci 0000:ef:0f.4: [8086:0eac] type 00 class 0x088000
[   92.878175] pci 0000:ef:0f.5: [8086:0ead] type 00 class 0x088000
[   92.878351] pci 0000:ef:10.0: [8086:0eb0] type 00 class 0x088000
[   92.878529] pci 0000:ef:10.1: [8086:0eb1] type 00 class 0x088000
[   92.878699] pci 0000:ef:10.2: [8086:0eb2] type 00 class 0x088000
[   92.878863] pci 0000:ef:10.3: [8086:0eb3] type 00 class 0x088000
[   92.879040] pci 0000:ef:10.4: [8086:0eb4] type 00 class 0x088000
[   92.879216] pci 0000:ef:10.5: [8086:0eb5] type 00 class 0x088000
[   92.879380] pci 0000:ef:10.6: [8086:0eb6] type 00 class 0x088000
[   92.879555] pci 0000:ef:10.7: [8086:0eb7] type 00 class 0x088000
[   92.879741] pci 0000:ef:11.0: [8086:0ef8] type 00 class 0x088000
[   92.879920] pci 0000:ef:11.1: [8086:0ef9] type 00 class 0x088000
[   92.880093] pci 0000:ef:11.2: [8086:0efa] type 00 class 0x088000
[   92.880263] pci 0000:ef:11.4: [8086:0efc] type 00 class 0x088000
[   92.880433] pci 0000:ef:11.5: [8086:0efd] type 00 class 0x088000
[   92.880610] pci 0000:ef:13.0: [8086:0e1d] type 00 class 0x088000
[   92.880751] pci 0000:ef:13.1: [8086:0e34] type 00 class 0x110100
[   92.880905] pci 0000:ef:13.4: [8086:0e81] type 00 class 0x088000
[   92.881062] pci 0000:ef:13.5: [8086:0e36] type 00 class 0x110100
[   92.881231] pci 0000:ef:13.6: [8086:0e37] type 00 class 0x110100
[   92.881389] pci 0000:ef:16.0: [8086:0ec8] type 00 class 0x088000
[   92.881547] pci 0000:ef:16.1: [8086:0ec9] type 00 class 0x088000
[   92.881726] pci 0000:ef:16.2: [8086:0eca] type 00 class 0x088000
[   92.881903] pci 0000:ef:18.0: [8086:0e40] type 00 class 0x088000
[   92.882053] pci 0000:ef:18.2: [8086:0e3a] type 00 class 0x110100
[   92.882239] pci 0000:ef:1c.0: [8086:0e60] type 00 class 0x088000
[   92.882397] pci 0000:ef:1c.1: [8086:0e38] type 00 class 0x110100
[   92.882578] pci 0000:ef:1d.0: [8086:0e68] type 00 class 0x088000
[   92.882753] pci 0000:ef:1d.1: [8086:0e79] type 00 class 0x088000
[   92.882938] pci 0000:ef:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.883104] pci 0000:ef:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.883274] pci 0000:ef:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.883447] pci 0000:ef:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.883656] pci 0000:ef:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.883819] pci 0000:ef:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.883983] pci 0000:ef:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.884164] pci 0000:ef:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.884342] pci 0000:ef:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.884499] pci 0000:ef:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.884687] pci 0000:ef:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.884859] pci 0000:ef:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.885033] pci 0000:ef:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.885222] pci 0000:ef:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.885404] pci 0000:ef:1f.4: [8086:0edc] type 00 class 0x088000
[   92.885565] pci 0000:ef:1f.5: [8086:0edd] type 00 class 0x088000
[   92.885751] pci 0000:ef:1f.6: [8086:0ede] type 00 class 0x088000
[   92.885919] pci 0000:ef:1f.7: [8086:0edf] type 00 class 0x088000
[   92.886107] pci_bus 0000:ef: busn_res: [bus ef-ff] end is updated to ef
[   92.886110] pci_bus 0000:ef: busn_res: can not insert [bus ef] under domain [bus 00-ff] (conflicts with (null) [bus e0-ef])
[   92.886360] PCI: Discovered peer bus ff
[   92.890580] PCI: root bus ff: using default resources
[   92.890582] PCI: Probing PCI hardware (bus ff)
[   92.890698] PCI host bridge to bus 0000:ff
[   92.895209] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[   92.902015] pci_bus 0000:ff: root bus resource [mem 0x00000000-0x3fffffffffff]
[   92.909961] pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
[   92.918679] pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus f0-ff])
[   92.918694] pci 0000:ff:08.0: [8086:0e80] type 00 class 0x088000
[   92.918857] pci 0000:ff:08.2: [8086:0e32] type 00 class 0x110100
[   92.919019] pci 0000:ff:09.0: [8086:0e90] type 00 class 0x088000
[   92.919183] pci 0000:ff:09.2: [8086:0e33] type 00 class 0x110100
[   92.919342] pci 0000:ff:0a.0: [8086:0ec0] type 00 class 0x088000
[   92.919496] pci 0000:ff:0a.1: [8086:0ec1] type 00 class 0x088000
[   92.919646] pci 0000:ff:0a.2: [8086:0ec2] type 00 class 0x088000
[   92.919805] pci 0000:ff:0a.3: [8086:0ec3] type 00 class 0x088000
[   92.919947] pci 0000:ff:0b.0: [8086:0e1e] type 00 class 0x088000
[   92.920100] pci 0000:ff:0b.3: [8086:0e1f] type 00 class 0x088000
[   92.920263] pci 0000:ff:0c.0: [8086:0ee0] type 00 class 0x088000
[   92.920405] pci 0000:ff:0c.1: [8086:0ee2] type 00 class 0x088000
[   92.920555] pci 0000:ff:0c.2: [8086:0ee4] type 00 class 0x088000
[   92.920704] pci 0000:ff:0c.3: [8086:0ee6] type 00 class 0x088000
[   92.920857] pci 0000:ff:0c.4: [8086:0ee8] type 00 class 0x088000
[   92.920998] pci 0000:ff:0c.5: [8086:0eea] type 00 class 0x088000
[   92.921139] pci 0000:ff:0c.6: [8086:0eec] type 00 class 0x088000
[   92.921293] pci 0000:ff:0c.7: [8086:0eee] type 00 class 0x088000
[   92.921448] pci 0000:ff:0d.0: [8086:0ee1] type 00 class 0x088000
[   92.921601] pci 0000:ff:0d.1: [8086:0ee3] type 00 class 0x088000
[   92.921759] pci 0000:ff:0d.2: [8086:0ee5] type 00 class 0x088000
[   92.921925] pci 0000:ff:0d.3: [8086:0ee7] type 00 class 0x088000
[   92.922064] pci 0000:ff:0d.4: [8086:0ee9] type 00 class 0x088000
[   92.922230] pci 0000:ff:0d.5: [8086:0eeb] type 00 class 0x088000
[   92.922386] pci 0000:ff:0d.6: [8086:0eed] type 00 class 0x088000
[   92.922532] pci 0000:ff:0e.0: [8086:0ea0] type 00 class 0x088000
[   92.922714] pci 0000:ff:0e.1: [8086:0e30] type 00 class 0x110100
[   92.922865] pci 0000:ff:0f.0: [8086:0ea8] type 00 class 0x088000
[   92.923050] pci 0000:ff:0f.1: [8086:0e71] type 00 class 0x088000
[   92.923232] pci 0000:ff:0f.2: [8086:0eaa] type 00 class 0x088000
[   92.923411] pci 0000:ff:0f.3: [8086:0eab] type 00 class 0x088000
[   92.923586] pci 0000:ff:0f.4: [8086:0eac] type 00 class 0x088000
[   92.923769] pci 0000:ff:0f.5: [8086:0ead] type 00 class 0x088000
[   92.923937] pci 0000:ff:10.0: [8086:0eb0] type 00 class 0x088000
[   92.924108] pci 0000:ff:10.1: [8086:0eb1] type 00 class 0x088000
[   92.924301] pci 0000:ff:10.2: [8086:0eb2] type 00 class 0x088000
[   92.924462] pci 0000:ff:10.3: [8086:0eb3] type 00 class 0x088000
[   92.924641] pci 0000:ff:10.4: [8086:0eb4] type 00 class 0x088000
[   92.924829] pci 0000:ff:10.5: [8086:0eb5] type 00 class 0x088000
[   92.925013] pci 0000:ff:10.6: [8086:0eb6] type 00 class 0x088000
[   92.925183] pci 0000:ff:10.7: [8086:0eb7] type 00 class 0x088000
[   92.925363] pci 0000:ff:11.0: [8086:0ef8] type 00 class 0x088000
[   92.925532] pci 0000:ff:11.1: [8086:0ef9] type 00 class 0x088000
[   92.925705] pci 0000:ff:11.2: [8086:0efa] type 00 class 0x088000
[   92.925890] pci 0000:ff:11.4: [8086:0efc] type 00 class 0x088000
[   92.926057] pci 0000:ff:11.5: [8086:0efd] type 00 class 0x088000
[   92.926235] pci 0000:ff:13.0: [8086:0e1d] type 00 class 0x088000
[   92.926389] pci 0000:ff:13.1: [8086:0e34] type 00 class 0x110100
[   92.926551] pci 0000:ff:13.4: [8086:0e81] type 00 class 0x088000
[   92.926702] pci 0000:ff:13.5: [8086:0e36] type 00 class 0x110100
[   92.926848] pci 0000:ff:13.6: [8086:0e37] type 00 class 0x110100
[   92.927017] pci 0000:ff:16.0: [8086:0ec8] type 00 class 0x088000
[   92.927173] pci 0000:ff:16.1: [8086:0ec9] type 00 class 0x088000
[   92.927328] pci 0000:ff:16.2: [8086:0eca] type 00 class 0x088000
[   92.927483] pci 0000:ff:18.0: [8086:0e40] type 00 class 0x088000
[   92.927643] pci 0000:ff:18.2: [8086:0e3a] type 00 class 0x110100
[   92.927823] pci 0000:ff:1c.0: [8086:0e60] type 00 class 0x088000
[   92.927985] pci 0000:ff:1c.1: [8086:0e38] type 00 class 0x110100
[   92.928161] pci 0000:ff:1d.0: [8086:0e68] type 00 class 0x088000
[   92.928345] pci 0000:ff:1d.1: [8086:0e79] type 00 class 0x088000
[   92.928532] pci 0000:ff:1d.2: [8086:0e6a] type 00 class 0x088000
[   92.928705] pci 0000:ff:1d.3: [8086:0e6b] type 00 class 0x088000
[   92.928898] pci 0000:ff:1d.4: [8086:0e6c] type 00 class 0x088000
[   92.929108] pci 0000:ff:1d.5: [8086:0e6d] type 00 class 0x088000
[   92.929293] pci 0000:ff:1e.0: [8086:0ef0] type 00 class 0x088000
[   92.929478] pci 0000:ff:1e.1: [8086:0ef1] type 00 class 0x088000
[   92.929661] pci 0000:ff:1e.2: [8086:0ef2] type 00 class 0x088000
[   92.929841] pci 0000:ff:1e.3: [8086:0ef3] type 00 class 0x088000
[   92.930013] pci 0000:ff:1e.4: [8086:0ef4] type 00 class 0x088000
[   92.930209] pci 0000:ff:1e.5: [8086:0ef5] type 00 class 0x088000
[   92.930390] pci 0000:ff:1e.6: [8086:0ef6] type 00 class 0x088000
[   92.930585] pci 0000:ff:1e.7: [8086:0ef7] type 00 class 0x088000
[   92.930765] pci 0000:ff:1f.0: [8086:0ed8] type 00 class 0x088000
[   92.930941] pci 0000:ff:1f.1: [8086:0ed9] type 00 class 0x088000
[   92.931131] pci 0000:ff:1f.4: [8086:0edc] type 00 class 0x088000
[   92.931319] pci 0000:ff:1f.5: [8086:0edd] type 00 class 0x088000
[   92.931506] pci 0000:ff:1f.6: [8086:0ede] type 00 class 0x088000
[   92.931694] pci 0000:ff:1f.7: [8086:0edf] type 00 class 0x088000
[   92.931869] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
[   92.931872] pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus f0-ff])
[   92.931892] PCI: pci_cache_line_size set to 64 bytes
[   92.934948] e820: reserve RAM buffer [mem 0x0008e000-0x0008ffff]
[   92.934952] e820: reserve RAM buffer [mem 0x6d00c000-0x6fffffff]
[   92.934954] e820: reserve RAM buffer [mem 0x6f3fc000-0x6fffffff]
[   92.934956] e820: reserve RAM buffer [mem 0x78bff000-0x7bffffff]
[   92.936154] NetLabel: Initializing
[   92.939900] NetLabel:  domain hash size = 128
[   92.944699] NetLabel:  protocols = UNLABELED CIPSOv4
[   92.950214] NetLabel:  unlabeled traffic allowed by default
[   92.956460] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[   92.963354] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[   92.974959] Switched to clocksource hpet
[   93.018930] AppArmor: AppArmor Filesystem Enabled
[   93.024484] pnp: PnP ACPI init
[   93.031447] pnp 00:00: Plug and Play ACPI device, IDs IPI0001 (active)
[   93.031882] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[   93.048024] pnp: PnP ACPI: found 2 devices
[   93.060066] pci 0000:01:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.070994] pci 0000:03:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.081920] pci 0000:03:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.092851] pci 0000:13:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.103784] pci 0000:21:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.114715] pci 0000:21:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.125649] pci 0000:23:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.136577] pci 0000:23:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.147506] pci 0000:33:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.158436] pci 0000:33:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.169365] pci 0000:41:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.180296] pci 0000:41:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.191218] pci 0000:43:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.202141] pci 0000:43:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.213071] pci 0000:53:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.223996] pci 0000:53:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.234928] pci 0000:61:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.245858] pci 0000:61:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.256784] pci 0000:63:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.267711] pci 0000:63:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.278640] pci 0000:73:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.289570] pci 0000:73:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.300494] pci 0000:85:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.311427] pci 0000:85:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.322356] pci 0000:87:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.333279] pci 0000:87:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.344212] pci 0000:93:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.355143] pci 0000:93:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.366067] pci 0000:a1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.376993] pci 0000:a1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.387926] pci 0000:a3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.398854] pci 0000:a3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.409784] pci 0000:b3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.420712] pci 0000:b3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.431655] pci 0000:c1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.442580] pci 0000:c1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.453507] pci 0000:c3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.464440] pci 0000:c3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.475370] pci 0000:d3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.486294] pci 0000:d3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.497223] pci 0000:e1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.508154] pci 0000:e1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.519081] pci 0000:e3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.530013] pci 0000:e3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   93.540942] pci 0000:f3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.551866] pci 0000:f3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   93.562911] pci 0000:00:02.0: BAR 13: assigned [io  0x2000-0x2fff]
[   93.569730] pci 0000:00:02.2: BAR 13: assigned [io  0x3000-0x3fff]
[   93.576564] pci 0000:01:00.0: BAR 6: assigned [mem 0x90680000-0x906fffff pref]
[   93.584524] pci 0000:01:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   93.592293] pci 0000:01:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   93.600449] pci 0000:01:00.0: BAR 2: assigned [io  0x2000-0x201f]
[   93.607174] pci 0000:01:00.1: BAR 2: assigned [io  0x2020-0x203f]
[   93.613897] pci 0000:00:02.0: PCI bridge to [bus 01-02]
[   93.619659] pci 0000:00:02.0:   bridge window [io  0x2000-0x2fff]
[   93.626379] pci 0000:00:02.0:   bridge window [mem 0x90400000-0x906fffff]
[   93.633870] pci 0000:00:02.0:   bridge window [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   93.642992] pci 0000:03:00.0: BAR 6: assigned [mem 0x90380000-0x903fffff pref]
[   93.650951] pci 0000:03:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   93.658721] pci 0000:03:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   93.666877] pci 0000:03:00.0: BAR 2: assigned [io  0x3000-0x301f]
[   93.673597] pci 0000:03:00.1: BAR 2: assigned [io  0x3020-0x303f]
[   93.680315] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[   93.686077] pci 0000:00:02.2:   bridge window [io  0x3000-0x3fff]
[   93.692799] pci 0000:00:02.2:   bridge window [mem 0x90100000-0x903fffff]
[   93.700282] pci 0000:00:02.2:   bridge window [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   93.709395] pci 0000:00:03.0: PCI bridge to [bus 05]
[   93.714880] pci 0000:00:11.0: PCI bridge to [bus 06]
[   93.720369] pci 0000:07:00.2: BAR 6: assigned [mem 0x93a90000-0x93a9ffff pref]
[   93.728330] pci 0000:00:1c.0: PCI bridge to [bus 07]
[   93.733804] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[   93.740526] pci 0000:00:1c.0:   bridge window [mem 0x92000000-0x93efffff]
[   93.748016] pci_bus 0000:00: resource 4 [io  0x1000-0x3fff window]
[   93.748019] pci_bus 0000:00: resource 5 [io  0x0000-0x0cf7 window]
[   93.748020] pci_bus 0000:00: resource 6 [mem 0x90000000-0x93efffff window]
[   93.748024] pci_bus 0000:00: resource 7 [mem 0x000a0000-0x000bffff window]
[   93.748027] pci_bus 0000:00: resource 8 [mem 0xfed00000-0xfedfffff window]
[   93.748029] pci_bus 0000:00: resource 9 [mem 0xfc000000000-0xfc07fffffff window]
[   93.748030] pci_bus 0000:00: resource 10 [mem 0xfe000000000-0xfe07fffffff window]
[   93.748032] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[   93.748034] pci_bus 0000:01: resource 1 [mem 0x90400000-0x906fffff]
[   93.748035] pci_bus 0000:01: resource 2 [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   93.748038] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[   93.748039] pci_bus 0000:03: resource 1 [mem 0x90100000-0x903fffff]
[   93.748040] pci_bus 0000:03: resource 2 [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   93.748052] pci_bus 0000:07: resource 0 [io  0x1000-0x1fff]
[   93.748053] pci_bus 0000:07: resource 1 [mem 0x92000000-0x93efffff]
[   93.748081] pci 0000:10:03.0: BAR 14: assigned [mem 0x94000000-0x940fffff]
[   93.755662] pci 0000:10:02.0: PCI bridge to [bus 11]
[   93.761150] pci 0000:10:02.2: PCI bridge to [bus 12]
[   93.766643] pci 0000:13:00.0: BAR 6: assigned [mem 0x94000000-0x9403ffff pref]
[   93.774607] pci 0000:13:00.1: BAR 6: assigned [mem 0x94040000-0x9407ffff pref]
[   93.782572] pci 0000:10:03.0: PCI bridge to [bus 13]
[   93.788055] pci 0000:10:03.0:   bridge window [mem 0x94000000-0x940fffff]
[   93.795541] pci 0000:10:03.0:   bridge window [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   93.804654] pci_bus 0000:10: resource 4 [io  0x4000-0x7fff window]
[   93.804656] pci_bus 0000:10: resource 5 [mem 0x94000000-0x97ff7fff window]
[   93.804663] pci_bus 0000:10: resource 6 [mem 0xfc400000000-0xfc47fffffff window]
[   93.804665] pci_bus 0000:13: resource 1 [mem 0x94000000-0x940fffff]
[   93.804667] pci_bus 0000:13: resource 2 [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   93.804722] pci 0000:20:02.0: BAR 13: assigned [io  0x8000-0x8fff]
[   93.811535] pci 0000:20:02.2: BAR 13: assigned [io  0x9000-0x9fff]
[   93.818349] pci 0000:20:1c.0: BAR 13: assigned [io  0xa000-0xafff]
[   93.825170] pci 0000:21:00.0: BAR 6: assigned [mem 0x98580000-0x985fffff pref]
[   93.833128] pci 0000:21:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   93.840895] pci 0000:21:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   93.849052] pci 0000:21:00.0: BAR 2: assigned [io  0x8000-0x801f]
[   93.855770] pci 0000:21:00.1: BAR 2: assigned [io  0x8020-0x803f]
[   93.862486] pci 0000:20:02.0: PCI bridge to [bus 21-22]
[   93.868247] pci 0000:20:02.0:   bridge window [io  0x8000-0x8fff]
[   93.874967] pci 0000:20:02.0:   bridge window [mem 0x98300000-0x985fffff]
[   93.882450] pci 0000:20:02.0:   bridge window [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   93.891564] pci 0000:23:00.0: BAR 6: assigned [mem 0x98280000-0x982fffff pref]
[   93.899523] pci 0000:23:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   93.907295] pci 0000:23:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   93.915449] pci 0000:23:00.0: BAR 2: assigned [io  0x9000-0x901f]
[   93.922168] pci 0000:23:00.1: BAR 2: assigned [io  0x9020-0x903f]
[   93.928886] pci 0000:20:02.2: PCI bridge to [bus 23-24]
[   93.934647] pci 0000:20:02.2:   bridge window [io  0x9000-0x9fff]
[   93.941369] pci 0000:20:02.2:   bridge window [mem 0x98000000-0x982fffff]
[   93.948857] pci 0000:20:02.2:   bridge window [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   93.957969] pci 0000:20:03.0: PCI bridge to [bus 25]
[   93.963453] pci 0000:20:11.0: PCI bridge to [bus 26]
[   93.968949] pci 0000:27:00.2: BAR 6: assigned [mem 0x9bd90000-0x9bd9ffff pref]
[   93.976912] pci 0000:27:00.0: BAR 0: assigned [io  0xa000-0xa0ff]
[   93.983640] pci 0000:27:00.0: BAR 2: assigned [io  0xa400-0xa4ff]
[   93.990362] pci 0000:27:00.2: BAR 0: assigned [io  0xa800-0xa8ff]
[   93.997081] pci 0000:20:1c.0: PCI bridge to [bus 27]
[   94.002562] pci 0000:20:1c.0:   bridge window [io  0xa000-0xafff]
[   94.009286] pci 0000:20:1c.0:   bridge window [mem 0x9bb00000-0x9befffff]
[   94.016775] pci_bus 0000:20: resource 4 [io  0x8000-0xbfff window]
[   94.016777] pci_bus 0000:20: resource 5 [mem 0x98000000-0x9befffff window]
[   94.016778] pci_bus 0000:20: resource 6 [mem 0xf0800000000-0xf087fffffff window]
[   94.016780] pci_bus 0000:21: resource 0 [io  0x8000-0x8fff]
[   94.016782] pci_bus 0000:21: resource 1 [mem 0x98300000-0x985fffff]
[   94.016783] pci_bus 0000:21: resource 2 [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   94.016786] pci_bus 0000:23: resource 0 [io  0x9000-0x9fff]
[   94.016787] pci_bus 0000:23: resource 1 [mem 0x98000000-0x982fffff]
[   94.016788] pci_bus 0000:23: resource 2 [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   94.016791] pci_bus 0000:27: resource 0 [io  0xa000-0xafff]
[   94.016792] pci_bus 0000:27: resource 1 [mem 0x9bb00000-0x9befffff]
[   94.016825] pci 0000:30:03.0: BAR 14: assigned [mem 0x9c000000-0x9c0fffff]
[   94.024402] pci 0000:30:02.0: PCI bridge to [bus 31]
[   94.029888] pci 0000:30:02.2: PCI bridge to [bus 32]
[   94.035377] pci 0000:33:00.0: BAR 6: assigned [mem 0x9c000000-0x9c03ffff pref]
[   94.043339] pci 0000:33:00.1: BAR 6: assigned [mem 0x9c040000-0x9c07ffff pref]
[   94.051299] pci 0000:30:03.0: PCI bridge to [bus 33]
[   94.056774] pci 0000:30:03.0:   bridge window [mem 0x9c000000-0x9c0fffff]
[   94.064258] pci 0000:30:03.0:   bridge window [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   94.073369] pci_bus 0000:30: resource 4 [io  0xc000-0xffff window]
[   94.073371] pci_bus 0000:30: resource 5 [mem 0x9c000000-0x9fff7fff window]
[   94.073372] pci_bus 0000:30: resource 6 [mem 0xf0c00000000-0xf0c7fffffff window]
[   94.073375] pci_bus 0000:33: resource 1 [mem 0x9c000000-0x9c0fffff]
[   94.073377] pci_bus 0000:33: resource 2 [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   94.073432] pci 0000:40:02.0: BAR 13: no space for [io  size 0x1000]
[   94.080437] pci 0000:40:02.0: BAR 13: failed to assign [io  size 0x1000]
[   94.087830] pci 0000:40:02.2: BAR 13: no space for [io  size 0x1000]
[   94.094835] pci 0000:40:02.2: BAR 13: failed to assign [io  size 0x1000]
[   94.102225] pci 0000:40:1c.0: BAR 13: no space for [io  size 0x1000]
[   94.109232] pci 0000:40:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   94.116623] pci 0000:41:00.0: BAR 6: assigned [mem 0xa0580000-0xa05fffff pref]
[   94.124585] pci 0000:41:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.132353] pci 0000:41:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.140508] pci 0000:41:00.0: BAR 2: no space for [io  size 0x0020]
[   94.147417] pci 0000:41:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.154713] pci 0000:41:00.1: BAR 2: no space for [io  size 0x0020]
[   94.161624] pci 0000:41:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.168915] pci 0000:40:02.0: PCI bridge to [bus 41-42]
[   94.174677] pci 0000:40:02.0:   bridge window [mem 0xa0300000-0xa05fffff]
[   94.182162] pci 0000:40:02.0:   bridge window [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   94.191278] pci 0000:43:00.0: BAR 6: assigned [mem 0xa0280000-0xa02fffff pref]
[   94.199237] pci 0000:43:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.207003] pci 0000:43:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.215155] pci 0000:43:00.0: BAR 2: no space for [io  size 0x0020]
[   94.222064] pci 0000:43:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.229354] pci 0000:43:00.1: BAR 2: no space for [io  size 0x0020]
[   94.236262] pci 0000:43:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.243551] pci 0000:40:02.2: PCI bridge to [bus 43-44]
[   94.249318] pci 0000:40:02.2:   bridge window [mem 0xa0000000-0xa02fffff]
[   94.256801] pci 0000:40:02.2:   bridge window [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   94.265912] pci 0000:40:03.0: PCI bridge to [bus 45]
[   94.271400] pci 0000:40:11.0: PCI bridge to [bus 46]
[   94.276902] pci 0000:47:00.2: BAR 6: assigned [mem 0xa3d90000-0xa3d9ffff pref]
[   94.284863] pci 0000:47:00.0: BAR 0: no space for [io  size 0x0100]
[   94.291773] pci 0000:47:00.0: BAR 0: failed to assign [io  size 0x0100]
[   94.299062] pci 0000:47:00.0: BAR 2: no space for [io  size 0x0100]
[   94.305970] pci 0000:47:00.0: BAR 2: failed to assign [io  size 0x0100]
[   94.313265] pci 0000:47:00.2: BAR 0: no space for [io  size 0x0100]
[   94.320173] pci 0000:47:00.2: BAR 0: failed to assign [io  size 0x0100]
[   94.327463] pci 0000:40:1c.0: PCI bridge to [bus 47]
[   94.332942] pci 0000:40:1c.0:   bridge window [mem 0xa3b00000-0xa3efffff]
[   94.340431] pci_bus 0000:40: Some PCI device resources are unassigned, try booting with pci=realloc
[   94.350398] pci_bus 0000:40: resource 4 [mem 0xa0000000-0xa3efffff window]
[   94.350399] pci_bus 0000:40: resource 5 [mem 0xf1000000000-0xf107fffffff window]
[   94.350402] pci_bus 0000:41: resource 1 [mem 0xa0300000-0xa05fffff]
[   94.350403] pci_bus 0000:41: resource 2 [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   94.350406] pci_bus 0000:43: resource 1 [mem 0xa0000000-0xa02fffff]
[   94.350407] pci_bus 0000:43: resource 2 [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   94.350411] pci_bus 0000:47: resource 1 [mem 0xa3b00000-0xa3efffff]
[   94.350447] pci 0000:50:03.0: BAR 14: assigned [mem 0xa4000000-0xa40fffff]
[   94.358030] pci 0000:50:02.0: PCI bridge to [bus 51]
[   94.363515] pci 0000:50:02.2: PCI bridge to [bus 52]
[   94.368999] pci 0000:53:00.0: BAR 6: assigned [mem 0xa4000000-0xa403ffff pref]
[   94.376961] pci 0000:53:00.1: BAR 6: assigned [mem 0xa4040000-0xa407ffff pref]
[   94.384924] pci 0000:50:03.0: PCI bridge to [bus 53]
[   94.390404] pci 0000:50:03.0:   bridge window [mem 0xa4000000-0xa40fffff]
[   94.397887] pci 0000:50:03.0:   bridge window [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   94.406998] pci_bus 0000:50: resource 4 [mem 0xa4000000-0xa7ff7fff window]
[   94.406999] pci_bus 0000:50: resource 5 [mem 0xf1400000000-0xf147fffffff window]
[   94.407003] pci_bus 0000:53: resource 1 [mem 0xa4000000-0xa40fffff]
[   94.407004] pci_bus 0000:53: resource 2 [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   94.407047] pci 0000:60:02.0: BAR 13: no space for [io  size 0x1000]
[   94.414051] pci 0000:60:02.0: BAR 13: failed to assign [io  size 0x1000]
[   94.421442] pci 0000:60:02.2: BAR 13: no space for [io  size 0x1000]
[   94.428447] pci 0000:60:02.2: BAR 13: failed to assign [io  size 0x1000]
[   94.435835] pci 0000:60:1c.0: BAR 13: no space for [io  size 0x1000]
[   94.442841] pci 0000:60:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   94.450231] pci 0000:61:00.0: BAR 6: assigned [mem 0xa8580000-0xa85fffff pref]
[   94.458192] pci 0000:61:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.465960] pci 0000:61:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.474110] pci 0000:61:00.0: BAR 2: no space for [io  size 0x0020]
[   94.481022] pci 0000:61:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.488321] pci 0000:61:00.1: BAR 2: no space for [io  size 0x0020]
[   94.495229] pci 0000:61:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.502519] pci 0000:60:02.0: PCI bridge to [bus 61-62]
[   94.508281] pci 0000:60:02.0:   bridge window [mem 0xa8300000-0xa85fffff]
[   94.515764] pci 0000:60:02.0:   bridge window [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   94.524890] pci 0000:63:00.0: BAR 6: assigned [mem 0xa8280000-0xa82fffff pref]
[   94.532852] pci 0000:63:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.540623] pci 0000:63:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.548780] pci 0000:63:00.0: BAR 2: no space for [io  size 0x0020]
[   94.555692] pci 0000:63:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.562985] pci 0000:63:00.1: BAR 2: no space for [io  size 0x0020]
[   94.569895] pci 0000:63:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.577192] pci 0000:60:02.2: PCI bridge to [bus 63-64]
[   94.582959] pci 0000:60:02.2:   bridge window [mem 0xa8000000-0xa82fffff]
[   94.590442] pci 0000:60:02.2:   bridge window [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   94.599554] pci 0000:60:03.0: PCI bridge to [bus 65]
[   94.605038] pci 0000:60:11.0: PCI bridge to [bus 66]
[   94.610528] pci 0000:67:00.2: BAR 6: assigned [mem 0xabd90000-0xabd9ffff pref]
[   94.618489] pci 0000:67:00.0: BAR 0: no space for [io  size 0x0100]
[   94.625397] pci 0000:67:00.0: BAR 0: failed to assign [io  size 0x0100]
[   94.632695] pci 0000:67:00.0: BAR 2: no space for [io  size 0x0100]
[   94.639604] pci 0000:67:00.0: BAR 2: failed to assign [io  size 0x0100]
[   94.646900] pci 0000:67:00.2: BAR 0: no space for [io  size 0x0100]
[   94.653808] pci 0000:67:00.2: BAR 0: failed to assign [io  size 0x0100]
[   94.661102] pci 0000:60:1c.0: PCI bridge to [bus 67]
[   94.666579] pci 0000:60:1c.0:   bridge window [mem 0xabb00000-0xabefffff]
[   94.674076] pci_bus 0000:60: Some PCI device resources are unassigned, try booting with pci=realloc
[   94.684049] pci_bus 0000:60: resource 4 [mem 0xa8000000-0xabefffff window]
[   94.684051] pci_bus 0000:60: resource 5 [mem 0xf1800000000-0xf187fffffff window]
[   94.684053] pci_bus 0000:61: resource 1 [mem 0xa8300000-0xa85fffff]
[   94.684055] pci_bus 0000:61: resource 2 [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   94.684058] pci_bus 0000:63: resource 1 [mem 0xa8000000-0xa82fffff]
[   94.684062] pci_bus 0000:63: resource 2 [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   94.684065] pci_bus 0000:67: resource 1 [mem 0xabb00000-0xabefffff]
[   94.684097] pci 0000:70:03.0: BAR 14: assigned [mem 0xac000000-0xac0fffff]
[   94.691678] pci 0000:70:02.0: PCI bridge to [bus 71]
[   94.697161] pci 0000:70:02.2: PCI bridge to [bus 72]
[   94.702649] pci 0000:73:00.0: BAR 6: assigned [mem 0xac000000-0xac03ffff pref]
[   94.710610] pci 0000:73:00.1: BAR 6: assigned [mem 0xac040000-0xac07ffff pref]
[   94.718574] pci 0000:70:03.0: PCI bridge to [bus 73]
[   94.724054] pci 0000:70:03.0:   bridge window [mem 0xac000000-0xac0fffff]
[   94.731539] pci 0000:70:03.0:   bridge window [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   94.740654] pci_bus 0000:70: resource 4 [mem 0xac000000-0xafff7fff window]
[   94.740656] pci_bus 0000:70: resource 5 [mem 0xf1c00000000-0xf1c7fffffff window]
[   94.740663] pci_bus 0000:73: resource 1 [mem 0xac000000-0xac0fffff]
[   94.740664] pci_bus 0000:73: resource 2 [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   94.740709] pci 0000:84:02.0: BAR 13: no space for [io  size 0x1000]
[   94.747713] pci 0000:84:02.0: BAR 13: failed to assign [io  size 0x1000]
[   94.755102] pci 0000:84:02.2: BAR 13: no space for [io  size 0x1000]
[   94.762108] pci 0000:84:02.2: BAR 13: failed to assign [io  size 0x1000]
[   94.769494] pci 0000:84:1c.0: BAR 13: no space for [io  size 0x1000]
[   94.776496] pci 0000:84:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   94.783894] pci 0000:85:00.0: BAR 6: assigned [mem 0xb0580000-0xb05fffff pref]
[   94.791856] pci 0000:85:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.799624] pci 0000:85:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.807775] pci 0000:85:00.0: BAR 2: no space for [io  size 0x0020]
[   94.814688] pci 0000:85:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.821984] pci 0000:85:00.1: BAR 2: no space for [io  size 0x0020]
[   94.828893] pci 0000:85:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.836188] pci 0000:84:02.0: PCI bridge to [bus 85-86]
[   94.841950] pci 0000:84:02.0:   bridge window [mem 0xb0300000-0xb05fffff]
[   94.849438] pci 0000:84:02.0:   bridge window [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   94.858556] pci 0000:87:00.0: BAR 6: assigned [mem 0xb0280000-0xb02fffff pref]
[   94.866517] pci 0000:87:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   94.874285] pci 0000:87:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   94.882438] pci 0000:87:00.0: BAR 2: no space for [io  size 0x0020]
[   94.889349] pci 0000:87:00.0: BAR 2: failed to assign [io  size 0x0020]
[   94.896643] pci 0000:87:00.1: BAR 2: no space for [io  size 0x0020]
[   94.903550] pci 0000:87:00.1: BAR 2: failed to assign [io  size 0x0020]
[   94.910846] pci 0000:84:02.2: PCI bridge to [bus 87-88]
[   94.916607] pci 0000:84:02.2:   bridge window [mem 0xb0000000-0xb02fffff]
[   94.924090] pci 0000:84:02.2:   bridge window [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   94.933202] pci 0000:84:03.0: PCI bridge to [bus 89]
[   94.938686] pci 0000:84:11.0: PCI bridge to [bus 8a]
[   94.944182] pci 0000:8b:00.2: BAR 6: assigned [mem 0xb3d90000-0xb3d9ffff pref]
[   94.952141] pci 0000:8b:00.0: BAR 0: no space for [io  size 0x0100]
[   94.959051] pci 0000:8b:00.0: BAR 0: failed to assign [io  size 0x0100]
[   94.966342] pci 0000:8b:00.0: BAR 2: no space for [io  size 0x0100]
[   94.973252] pci 0000:8b:00.0: BAR 2: failed to assign [io  size 0x0100]
[   94.980554] pci 0000:8b:00.2: BAR 0: no space for [io  size 0x0100]
[   94.987465] pci 0000:8b:00.2: BAR 0: failed to assign [io  size 0x0100]
[   94.994761] pci 0000:84:1c.0: PCI bridge to [bus 8b]
[   95.000240] pci 0000:84:1c.0:   bridge window [mem 0xb3b00000-0xb3efffff]
[   95.007731] pci_bus 0000:84: Some PCI device resources are unassigned, try booting with pci=realloc
[   95.017702] pci_bus 0000:84: resource 4 [mem 0xb0000000-0xb3efffff window]
[   95.017703] pci_bus 0000:84: resource 5 [mem 0xf2000000000-0xf207fffffff window]
[   95.017706] pci_bus 0000:85: resource 1 [mem 0xb0300000-0xb05fffff]
[   95.017707] pci_bus 0000:85: resource 2 [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   95.017713] pci_bus 0000:87: resource 1 [mem 0xb0000000-0xb02fffff]
[   95.017716] pci_bus 0000:87: resource 2 [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   95.017719] pci_bus 0000:8b: resource 1 [mem 0xb3b00000-0xb3efffff]
[   95.017753] pci 0000:90:03.0: BAR 14: assigned [mem 0xb4000000-0xb40fffff]
[   95.025332] pci 0000:90:02.0: PCI bridge to [bus 91]
[   95.030820] pci 0000:90:02.2: PCI bridge to [bus 92]
[   95.036304] pci 0000:93:00.0: BAR 6: assigned [mem 0xb4000000-0xb403ffff pref]
[   95.044264] pci 0000:93:00.1: BAR 6: assigned [mem 0xb4040000-0xb407ffff pref]
[   95.052225] pci 0000:90:03.0: PCI bridge to [bus 93]
[   95.057705] pci 0000:90:03.0:   bridge window [mem 0xb4000000-0xb40fffff]
[   95.065193] pci 0000:90:03.0:   bridge window [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   95.074306] pci_bus 0000:90: resource 4 [mem 0xb4000000-0xb7ff7fff window]
[   95.074308] pci_bus 0000:90: resource 5 [mem 0xf2400000000-0xf247fffffff window]
[   95.074310] pci_bus 0000:93: resource 1 [mem 0xb4000000-0xb40fffff]
[   95.074311] pci_bus 0000:93: resource 2 [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   95.074360] pci 0000:a0:02.0: BAR 13: no space for [io  size 0x1000]
[   95.081361] pci 0000:a0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   95.088751] pci 0000:a0:02.2: BAR 13: no space for [io  size 0x1000]
[   95.095756] pci 0000:a0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   95.103149] pci 0000:a0:1c.0: BAR 13: no space for [io  size 0x1000]
[   95.110152] pci 0000:a0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   95.117549] pci 0000:a1:00.0: BAR 6: assigned [mem 0xb8580000-0xb85fffff pref]
[   95.125510] pci 0000:a1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.133278] pci 0000:a1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.141427] pci 0000:a1:00.0: BAR 2: no space for [io  size 0x0020]
[   95.148333] pci 0000:a1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.155633] pci 0000:a1:00.1: BAR 2: no space for [io  size 0x0020]
[   95.162545] pci 0000:a1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.169839] pci 0000:a0:02.0: PCI bridge to [bus a1-a2]
[   95.175603] pci 0000:a0:02.0:   bridge window [mem 0xb8300000-0xb85fffff]
[   95.183094] pci 0000:a0:02.0:   bridge window [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   95.192210] pci 0000:a3:00.0: BAR 6: assigned [mem 0xb8280000-0xb82fffff pref]
[   95.200170] pci 0000:a3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.207940] pci 0000:a3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.216094] pci 0000:a3:00.0: BAR 2: no space for [io  size 0x0020]
[   95.223003] pci 0000:a3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.230296] pci 0000:a3:00.1: BAR 2: no space for [io  size 0x0020]
[   95.237204] pci 0000:a3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.244496] pci 0000:a0:02.2: PCI bridge to [bus a3-a4]
[   95.250262] pci 0000:a0:02.2:   bridge window [mem 0xb8000000-0xb82fffff]
[   95.257747] pci 0000:a0:02.2:   bridge window [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   95.266858] pci 0000:a0:03.0: PCI bridge to [bus a5]
[   95.272345] pci 0000:a0:11.0: PCI bridge to [bus a6]
[   95.277836] pci 0000:a7:00.2: BAR 6: assigned [mem 0xbbd90000-0xbbd9ffff pref]
[   95.285801] pci 0000:a7:00.0: BAR 0: no space for [io  size 0x0100]
[   95.292712] pci 0000:a7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   95.300001] pci 0000:a7:00.0: BAR 2: no space for [io  size 0x0100]
[   95.306906] pci 0000:a7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   95.314200] pci 0000:a7:00.2: BAR 0: no space for [io  size 0x0100]
[   95.321114] pci 0000:a7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   95.328407] pci 0000:a0:1c.0: PCI bridge to [bus a7]
[   95.333886] pci 0000:a0:1c.0:   bridge window [mem 0xbbb00000-0xbbefffff]
[   95.341375] pci_bus 0000:a0: Some PCI device resources are unassigned, try booting with pci=realloc
[   95.351341] pci_bus 0000:a0: resource 4 [mem 0xb8000000-0xbbefffff window]
[   95.351343] pci_bus 0000:a0: resource 5 [mem 0xf2800000000-0xf287fffffff window]
[   95.351344] pci_bus 0000:a1: resource 1 [mem 0xb8300000-0xb85fffff]
[   95.351346] pci_bus 0000:a1: resource 2 [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   95.351352] pci_bus 0000:a3: resource 1 [mem 0xb8000000-0xb82fffff]
[   95.351357] pci_bus 0000:a3: resource 2 [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   95.351360] pci_bus 0000:a7: resource 1 [mem 0xbbb00000-0xbbefffff]
[   95.351394] pci 0000:b0:03.0: BAR 14: assigned [mem 0xbc000000-0xbc0fffff]
[   95.358972] pci 0000:b0:02.0: PCI bridge to [bus b1]
[   95.364457] pci 0000:b0:02.2: PCI bridge to [bus b2]
[   95.369948] pci 0000:b3:00.0: BAR 6: assigned [mem 0xbc000000-0xbc03ffff pref]
[   95.377910] pci 0000:b3:00.1: BAR 6: assigned [mem 0xbc040000-0xbc07ffff pref]
[   95.385870] pci 0000:b0:03.0: PCI bridge to [bus b3]
[   95.391350] pci 0000:b0:03.0:   bridge window [mem 0xbc000000-0xbc0fffff]
[   95.398838] pci 0000:b0:03.0:   bridge window [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   95.407950] pci_bus 0000:b0: resource 4 [mem 0xbc000000-0xbfff7fff window]
[   95.407951] pci_bus 0000:b0: resource 5 [mem 0xf2c00000000-0xf2c7fffffff window]
[   95.407953] pci_bus 0000:b3: resource 1 [mem 0xbc000000-0xbc0fffff]
[   95.407955] pci_bus 0000:b3: resource 2 [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   95.408000] pci 0000:c0:02.0: BAR 13: no space for [io  size 0x1000]
[   95.415000] pci 0000:c0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   95.422386] pci 0000:c0:02.2: BAR 13: no space for [io  size 0x1000]
[   95.429390] pci 0000:c0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   95.436779] pci 0000:c0:1c.0: BAR 13: no space for [io  size 0x1000]
[   95.443783] pci 0000:c0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   95.451172] pci 0000:c1:00.0: BAR 6: assigned [mem 0xc0580000-0xc05fffff pref]
[   95.459132] pci 0000:c1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.466904] pci 0000:c1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.475056] pci 0000:c1:00.0: BAR 2: no space for [io  size 0x0020]
[   95.481964] pci 0000:c1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.489253] pci 0000:c1:00.1: BAR 2: no space for [io  size 0x0020]
[   95.496167] pci 0000:c1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.503463] pci 0000:c0:02.0: PCI bridge to [bus c1-c2]
[   95.509224] pci 0000:c0:02.0:   bridge window [mem 0xc0300000-0xc05fffff]
[   95.516707] pci 0000:c0:02.0:   bridge window [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   95.525829] pci 0000:c3:00.0: BAR 6: assigned [mem 0xc0280000-0xc02fffff pref]
[   95.533791] pci 0000:c3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.541558] pci 0000:c3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.549709] pci 0000:c3:00.0: BAR 2: no space for [io  size 0x0020]
[   95.556616] pci 0000:c3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.563908] pci 0000:c3:00.1: BAR 2: no space for [io  size 0x0020]
[   95.570815] pci 0000:c3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.578106] pci 0000:c0:02.2: PCI bridge to [bus c3-c4]
[   95.583869] pci 0000:c0:02.2:   bridge window [mem 0xc0000000-0xc02fffff]
[   95.591351] pci 0000:c0:02.2:   bridge window [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   95.600466] pci 0000:c0:03.0: PCI bridge to [bus c5]
[   95.605951] pci 0000:c0:11.0: PCI bridge to [bus c6]
[   95.611444] pci 0000:c7:00.2: BAR 6: assigned [mem 0xc3d90000-0xc3d9ffff pref]
[   95.619405] pci 0000:c7:00.0: BAR 0: no space for [io  size 0x0100]
[   95.626316] pci 0000:c7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   95.633608] pci 0000:c7:00.0: BAR 2: no space for [io  size 0x0100]
[   95.640514] pci 0000:c7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   95.647806] pci 0000:c7:00.2: BAR 0: no space for [io  size 0x0100]
[   95.654713] pci 0000:c7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   95.662006] pci 0000:c0:1c.0: PCI bridge to [bus c7]
[   95.667484] pci 0000:c0:1c.0:   bridge window [mem 0xc3b00000-0xc3efffff]
[   95.674972] pci_bus 0000:c0: Some PCI device resources are unassigned, try booting with pci=realloc
[   95.684944] pci_bus 0000:c0: resource 4 [mem 0xc0000000-0xc3efffff window]
[   95.684946] pci_bus 0000:c0: resource 5 [mem 0xf3000000000-0xf307fffffff window]
[   95.684950] pci_bus 0000:c1: resource 1 [mem 0xc0300000-0xc05fffff]
[   95.684952] pci_bus 0000:c1: resource 2 [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   95.684954] pci_bus 0000:c3: resource 1 [mem 0xc0000000-0xc02fffff]
[   95.684955] pci_bus 0000:c3: resource 2 [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   95.684957] pci_bus 0000:c7: resource 1 [mem 0xc3b00000-0xc3efffff]
[   95.684993] pci 0000:d0:03.0: BAR 14: assigned [mem 0xc4000000-0xc40fffff]
[   95.692574] pci 0000:d0:02.0: PCI bridge to [bus d1]
[   95.698059] pci 0000:d0:02.2: PCI bridge to [bus d2]
[   95.703547] pci 0000:d3:00.0: BAR 6: assigned [mem 0xc4000000-0xc403ffff pref]
[   95.711506] pci 0000:d3:00.1: BAR 6: assigned [mem 0xc4040000-0xc407ffff pref]
[   95.719466] pci 0000:d0:03.0: PCI bridge to [bus d3]
[   95.724941] pci 0000:d0:03.0:   bridge window [mem 0xc4000000-0xc40fffff]
[   95.732430] pci 0000:d0:03.0:   bridge window [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   95.741549] pci_bus 0000:d0: resource 4 [mem 0xc4000000-0xc7ff7fff window]
[   95.741550] pci_bus 0000:d0: resource 5 [mem 0xf3400000000-0xf347fffffff window]
[   95.741552] pci_bus 0000:d3: resource 1 [mem 0xc4000000-0xc40fffff]
[   95.741554] pci_bus 0000:d3: resource 2 [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   95.741612] pci 0000:e0:02.0: BAR 13: no space for [io  size 0x1000]
[   95.748613] pci 0000:e0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   95.756007] pci 0000:e0:02.2: BAR 13: no space for [io  size 0x1000]
[   95.763010] pci 0000:e0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   95.770401] pci 0000:e0:1c.0: BAR 13: no space for [io  size 0x1000]
[   95.777404] pci 0000:e0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   95.784803] pci 0000:e1:00.0: BAR 6: assigned [mem 0xc8580000-0xc85fffff pref]
[   95.792766] pci 0000:e1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.800541] pci 0000:e1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.808694] pci 0000:e1:00.0: BAR 2: no space for [io  size 0x0020]
[   95.815600] pci 0000:e1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.822898] pci 0000:e1:00.1: BAR 2: no space for [io  size 0x0020]
[   95.829806] pci 0000:e1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.837101] pci 0000:e0:02.0: PCI bridge to [bus e1-e2]
[   95.842863] pci 0000:e0:02.0:   bridge window [mem 0xc8300000-0xc85fffff]
[   95.850347] pci 0000:e0:02.0:   bridge window [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   95.859471] pci 0000:e3:00.0: BAR 6: assigned [mem 0xc8280000-0xc82fffff pref]
[   95.867435] pci 0000:e3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   95.875202] pci 0000:e3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   95.883352] pci 0000:e3:00.0: BAR 2: no space for [io  size 0x0020]
[   95.890261] pci 0000:e3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   95.897553] pci 0000:e3:00.1: BAR 2: no space for [io  size 0x0020]
[   95.904462] pci 0000:e3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   95.911754] pci 0000:e0:02.2: PCI bridge to [bus e3-e4]
[   95.917517] pci 0000:e0:02.2:   bridge window [mem 0xc8000000-0xc82fffff]
[   95.925004] pci 0000:e0:02.2:   bridge window [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   95.934116] pci 0000:e0:03.0: PCI bridge to [bus e5]
[   95.939603] pci 0000:e0:11.0: PCI bridge to [bus e6]
[   95.945097] pci 0000:e7:00.2: BAR 6: assigned [mem 0xcbd90000-0xcbd9ffff pref]
[   95.953058] pci 0000:e7:00.0: BAR 0: no space for [io  size 0x0100]
[   95.959964] pci 0000:e7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   95.967257] pci 0000:e7:00.0: BAR 2: no space for [io  size 0x0100]
[   95.974164] pci 0000:e7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   95.981456] pci 0000:e7:00.2: BAR 0: no space for [io  size 0x0100]
[   95.988370] pci 0000:e7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   95.995665] pci 0000:e0:1c.0: PCI bridge to [bus e7]
[   96.001142] pci 0000:e0:1c.0:   bridge window [mem 0xcbb00000-0xcbefffff]
[   96.008631] pci_bus 0000:e0: Some PCI device resources are unassigned, try booting with pci=realloc
[   96.018605] pci_bus 0000:e0: resource 4 [mem 0xc8000000-0xcbefffff window]
[   96.018607] pci_bus 0000:e0: resource 5 [mem 0xf3800000000-0xf387fffffff window]
[   96.018611] pci_bus 0000:e1: resource 1 [mem 0xc8300000-0xc85fffff]
[   96.018613] pci_bus 0000:e1: resource 2 [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   96.018615] pci_bus 0000:e3: resource 1 [mem 0xc8000000-0xc82fffff]
[   96.018617] pci_bus 0000:e3: resource 2 [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   96.018619] pci_bus 0000:e7: resource 1 [mem 0xcbb00000-0xcbefffff]
[   96.018655] pci 0000:f0:03.0: BAR 14: assigned [mem 0xcc000000-0xcc0fffff]
[   96.026231] pci 0000:f0:02.0: PCI bridge to [bus f1]
[   96.031717] pci 0000:f0:02.2: PCI bridge to [bus f2]
[   96.037209] pci 0000:f3:00.0: BAR 6: assigned [mem 0xcc000000-0xcc03ffff pref]
[   96.045170] pci 0000:f3:00.1: BAR 6: assigned [mem 0xcc040000-0xcc07ffff pref]
[   96.053129] pci 0000:f0:03.0: PCI bridge to [bus f3]
[   96.058606] pci 0000:f0:03.0:   bridge window [mem 0xcc000000-0xcc0fffff]
[   96.066094] pci 0000:f0:03.0:   bridge window [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   96.075210] pci_bus 0000:f0: resource 4 [mem 0xcc000000-0xcfff7fff window]
[   96.075211] pci_bus 0000:f0: resource 5 [mem 0xf3c00000000-0xf3c7fffffff window]
[   96.075213] pci_bus 0000:f3: resource 1 [mem 0xcc000000-0xcc0fffff]
[   96.075215] pci_bus 0000:f3: resource 2 [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   96.075225] pci_bus 0000:0f: resource 4 [io  0x0000-0xffff]
[   96.075227] pci_bus 0000:0f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075241] pci_bus 0000:1f: resource 4 [io  0x0000-0xffff]
[   96.075243] pci_bus 0000:1f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075255] pci_bus 0000:2f: resource 4 [io  0x0000-0xffff]
[   96.075256] pci_bus 0000:2f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075274] pci_bus 0000:3f: resource 4 [io  0x0000-0xffff]
[   96.075275] pci_bus 0000:3f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075294] pci_bus 0000:4f: resource 4 [io  0x0000-0xffff]
[   96.075296] pci_bus 0000:4f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075314] pci_bus 0000:5f: resource 4 [io  0x0000-0xffff]
[   96.075316] pci_bus 0000:5f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075330] pci_bus 0000:6f: resource 4 [io  0x0000-0xffff]
[   96.075332] pci_bus 0000:6f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075343] pci_bus 0000:7b: resource 4 [io  0x0000-0xffff]
[   96.075345] pci_bus 0000:7b: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075356] pci_bus 0000:8f: resource 4 [io  0x0000-0xffff]
[   96.075357] pci_bus 0000:8f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075376] pci_bus 0000:9f: resource 4 [io  0x0000-0xffff]
[   96.075377] pci_bus 0000:9f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075393] pci_bus 0000:af: resource 4 [io  0x0000-0xffff]
[   96.075395] pci_bus 0000:af: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075406] pci_bus 0000:bf: resource 4 [io  0x0000-0xffff]
[   96.075408] pci_bus 0000:bf: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075425] pci_bus 0000:cf: resource 4 [io  0x0000-0xffff]
[   96.075427] pci_bus 0000:cf: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075438] pci_bus 0000:df: resource 4 [io  0x0000-0xffff]
[   96.075440] pci_bus 0000:df: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075455] pci_bus 0000:ef: resource 4 [io  0x0000-0xffff]
[   96.075457] pci_bus 0000:ef: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.075469] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
[   96.075471] pci_bus 0000:ff: resource 5 [mem 0x00000000-0x3fffffffffff]
[   96.082109] NET: Registered protocol family 2
[   96.097014] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
[   96.109303] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[   96.117676] TCP: Hash tables configured (established 524288 bind 65536)
[   96.125083] TCP: reno registered
[   96.129293] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[   96.137577] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[   96.152144] NET: Registered protocol family 1
[   96.158073] pci 0000:07:00.1: Video device with shadowed ROM
[   96.164966] PCI: CLS 64 bytes, default 64
[   96.165149] Unpacking initramfs...
[   96.742054] Freeing initrd memory: 29704K (ffff88006b30a000 - ffff88006d00c000)
[   96.750193] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   96.757296] software IO TLB [mem 0x6730a000-0x6b30a000] (64MB) mapped at [ffff88006730a000-ffff88006b309fff]
[   96.961999] RAPL PMU detected, hw unit 2^-16 Joules, API unit is 2^-32 Joules, 3 fixed counters 163840 ms ovfl timer
[   97.036339] Scanning for low memory corruption every 60 seconds
[   97.071804] futex hash table entries: 131072 (order: 11, 8388608 bytes)
[   97.084426] Initialise system trusted keyring
[   97.090784] audit: initializing netlink subsys (disabled)
[   97.096796] audit: type=2000 audit(1429058183.520:1): initialized
[   97.115466] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   97.123835] VFS: Disk quotas dquot_6.5.2
[   97.130063] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   97.144846] alg: No test for stdrng (krng)
[   97.149429] Key type asymmetric registered
[   97.154006] Asymmetric key parser 'x509' registered
[   97.159559] bounce: pool size: 64 pages
[   97.165372] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[   97.176282] io scheduler noop registered
[   97.180615] io scheduler deadline registered
[   97.187159] io scheduler cfq registered (default)
[   97.253005] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
[   97.260694] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[   97.267898] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[   97.275119] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   97.275308] pcieport 0000:00:02.2: Signaling PME through PCIe PME interrupt
[   97.282986] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[   97.290193] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
[   97.297424] pcie_pme 0000:00:02.2:pcie01: service driver pcie_pme loaded
[   97.297614] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[   97.305292] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   97.305370] pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
[   97.313058] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
[   97.313205] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[   97.320896] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[   97.328102] pci 0000:07:00.1: Signaling PME through PCIe PME interrupt
[   97.335318] pci 0000:07:00.2: Signaling PME through PCIe PME interrupt
[   97.342526] pci 0000:07:00.4: Signaling PME through PCIe PME interrupt
[   97.349751] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   97.349944] pcieport 0000:10:02.0: Signaling PME through PCIe PME interrupt
[   97.357639] pcie_pme 0000:10:02.0:pcie01: service driver pcie_pme loaded
[   97.357746] pcieport 0000:10:02.2: Signaling PME through PCIe PME interrupt
[   97.365440] pcie_pme 0000:10:02.2:pcie01: service driver pcie_pme loaded
[   97.365586] pcieport 0000:10:03.0: Signaling PME through PCIe PME interrupt
[   97.373266] pci 0000:13:00.0: Signaling PME through PCIe PME interrupt
[   97.380479] pci 0000:13:00.1: Signaling PME through PCIe PME interrupt
[   97.387700] pcie_pme 0000:10:03.0:pcie01: service driver pcie_pme loaded
[   97.387886] pcieport 0000:20:02.0: Signaling PME through PCIe PME interrupt
[   97.395571] pci 0000:21:00.0: Signaling PME through PCIe PME interrupt
[   97.402780] pci 0000:21:00.1: Signaling PME through PCIe PME interrupt
[   97.410006] pcie_pme 0000:20:02.0:pcie01: service driver pcie_pme loaded
[   97.410202] pcieport 0000:20:02.2: Signaling PME through PCIe PME interrupt
[   97.417886] pci 0000:23:00.0: Signaling PME through PCIe PME interrupt
[   97.425096] pci 0000:23:00.1: Signaling PME through PCIe PME interrupt
[   97.432613] pcie_pme 0000:20:02.2:pcie01: service driver pcie_pme loaded
[   97.432796] pcieport 0000:20:03.0: Signaling PME through PCIe PME interrupt
[   97.440475] pcie_pme 0000:20:03.0:pcie01: service driver pcie_pme loaded
[   97.440579] pcieport 0000:20:11.0: Signaling PME through PCIe PME interrupt
[   97.448273] pcie_pme 0000:20:11.0:pcie01: service driver pcie_pme loaded
[   97.448420] pcieport 0000:20:1c.0: Signaling PME through PCIe PME interrupt
[   97.456104] pci 0000:27:00.0: Signaling PME through PCIe PME interrupt
[   97.463314] pci 0000:27:00.2: Signaling PME through PCIe PME interrupt
[   97.470541] pcie_pme 0000:20:1c.0:pcie01: service driver pcie_pme loaded
[   97.470743] pcieport 0000:30:02.0: Signaling PME through PCIe PME interrupt
[   97.478427] pcie_pme 0000:30:02.0:pcie01: service driver pcie_pme loaded
[   97.478539] pcieport 0000:30:02.2: Signaling PME through PCIe PME interrupt
[   97.486243] pcie_pme 0000:30:02.2:pcie01: service driver pcie_pme loaded
[   97.486389] pcieport 0000:30:03.0: Signaling PME through PCIe PME interrupt
[   97.494074] pci 0000:33:00.0: Signaling PME through PCIe PME interrupt
[   97.501282] pci 0000:33:00.1: Signaling PME through PCIe PME interrupt
[   97.508502] pcie_pme 0000:30:03.0:pcie01: service driver pcie_pme loaded
[   97.508700] pcieport 0000:40:02.0: Signaling PME through PCIe PME interrupt
[   97.516383] pci 0000:41:00.0: Signaling PME through PCIe PME interrupt
[   97.523596] pci 0000:41:00.1: Signaling PME through PCIe PME interrupt
[   97.530825] pcie_pme 0000:40:02.0:pcie01: service driver pcie_pme loaded
[   97.531019] pcieport 0000:40:02.2: Signaling PME through PCIe PME interrupt
[   97.538696] pci 0000:43:00.0: Signaling PME through PCIe PME interrupt
[   97.545908] pci 0000:43:00.1: Signaling PME through PCIe PME interrupt
[   97.553133] pcie_pme 0000:40:02.2:pcie01: service driver pcie_pme loaded
[   97.553322] pcieport 0000:40:03.0: Signaling PME through PCIe PME interrupt
[   97.561006] pcie_pme 0000:40:03.0:pcie01: service driver pcie_pme loaded
[   97.561107] pcieport 0000:40:11.0: Signaling PME through PCIe PME interrupt
[   97.568793] pcie_pme 0000:40:11.0:pcie01: service driver pcie_pme loaded
[   97.568944] pcieport 0000:40:1c.0: Signaling PME through PCIe PME interrupt
[   97.576625] pci 0000:47:00.0: Signaling PME through PCIe PME interrupt
[   97.583837] pci 0000:47:00.2: Signaling PME through PCIe PME interrupt
[   97.591058] pcie_pme 0000:40:1c.0:pcie01: service driver pcie_pme loaded
[   97.591255] pcieport 0000:50:02.0: Signaling PME through PCIe PME interrupt
[   97.598940] pcie_pme 0000:50:02.0:pcie01: service driver pcie_pme loaded
[   97.599039] pcieport 0000:50:02.2: Signaling PME through PCIe PME interrupt
[   97.606726] pcie_pme 0000:50:02.2:pcie01: service driver pcie_pme loaded
[   97.606870] pcieport 0000:50:03.0: Signaling PME through PCIe PME interrupt
[   97.614565] pci 0000:53:00.0: Signaling PME through PCIe PME interrupt
[   97.621776] pci 0000:53:00.1: Signaling PME through PCIe PME interrupt
[   97.628994] pcie_pme 0000:50:03.0:pcie01: service driver pcie_pme loaded
[   97.629184] pcieport 0000:60:02.0: Signaling PME through PCIe PME interrupt
[   97.636861] pci 0000:61:00.0: Signaling PME through PCIe PME interrupt
[   97.644084] pci 0000:61:00.1: Signaling PME through PCIe PME interrupt
[   97.651301] pcie_pme 0000:60:02.0:pcie01: service driver pcie_pme loaded
[   97.651495] pcieport 0000:60:02.2: Signaling PME through PCIe PME interrupt
[   97.659177] pci 0000:63:00.0: Signaling PME through PCIe PME interrupt
[   97.666382] pci 0000:63:00.1: Signaling PME through PCIe PME interrupt
[   97.673600] pcie_pme 0000:60:02.2:pcie01: service driver pcie_pme loaded
[   97.673792] pcieport 0000:60:03.0: Signaling PME through PCIe PME interrupt
[   97.681474] pcie_pme 0000:60:03.0:pcie01: service driver pcie_pme loaded
[   97.681573] pcieport 0000:60:11.0: Signaling PME through PCIe PME interrupt
[   97.689260] pcie_pme 0000:60:11.0:pcie01: service driver pcie_pme loaded
[   97.689397] pcieport 0000:60:1c.0: Signaling PME through PCIe PME interrupt
[   97.697074] pci 0000:67:00.0: Signaling PME through PCIe PME interrupt
[   97.704286] pci 0000:67:00.2: Signaling PME through PCIe PME interrupt
[   97.711505] pcie_pme 0000:60:1c.0:pcie01: service driver pcie_pme loaded
[   97.711699] pcieport 0000:70:02.0: Signaling PME through PCIe PME interrupt
[   97.719387] pcie_pme 0000:70:02.0:pcie01: service driver pcie_pme loaded
[   97.719499] pcieport 0000:70:02.2: Signaling PME through PCIe PME interrupt
[   97.727186] pcie_pme 0000:70:02.2:pcie01: service driver pcie_pme loaded
[   97.727340] pcieport 0000:70:03.0: Signaling PME through PCIe PME interrupt
[   97.735026] pci 0000:73:00.0: Signaling PME through PCIe PME interrupt
[   97.742247] pci 0000:73:00.1: Signaling PME through PCIe PME interrupt
[   97.749474] pcie_pme 0000:70:03.0:pcie01: service driver pcie_pme loaded
[   97.749663] pcieport 0000:84:02.0: Signaling PME through PCIe PME interrupt
[   97.757342] pci 0000:85:00.0: Signaling PME through PCIe PME interrupt
[   97.764551] pci 0000:85:00.1: Signaling PME through PCIe PME interrupt
[   97.771774] pcie_pme 0000:84:02.0:pcie01: service driver pcie_pme loaded
[   97.771980] pcieport 0000:84:02.2: Signaling PME through PCIe PME interrupt
[   97.779671] pci 0000:87:00.0: Signaling PME through PCIe PME interrupt
[   97.786878] pci 0000:87:00.1: Signaling PME through PCIe PME interrupt
[   97.794094] pcie_pme 0000:84:02.2:pcie01: service driver pcie_pme loaded
[   97.794283] pcieport 0000:84:03.0: Signaling PME through PCIe PME interrupt
[   97.801969] pcie_pme 0000:84:03.0:pcie01: service driver pcie_pme loaded
[   97.802075] pcieport 0000:84:11.0: Signaling PME through PCIe PME interrupt
[   97.809762] pcie_pme 0000:84:11.0:pcie01: service driver pcie_pme loaded
[   97.809912] pcieport 0000:84:1c.0: Signaling PME through PCIe PME interrupt
[   97.817591] pci 0000:8b:00.0: Signaling PME through PCIe PME interrupt
[   97.824799] pci 0000:8b:00.2: Signaling PME through PCIe PME interrupt
[   97.832022] pcie_pme 0000:84:1c.0:pcie01: service driver pcie_pme loaded
[   97.832220] pcieport 0000:90:02.0: Signaling PME through PCIe PME interrupt
[   97.839901] pcie_pme 0000:90:02.0:pcie01: service driver pcie_pme loaded
[   97.840007] pcieport 0000:90:02.2: Signaling PME through PCIe PME interrupt
[   97.847691] pcie_pme 0000:90:02.2:pcie01: service driver pcie_pme loaded
[   97.847837] pcieport 0000:90:03.0: Signaling PME through PCIe PME interrupt
[   97.855528] pci 0000:93:00.0: Signaling PME through PCIe PME interrupt
[   97.862741] pci 0000:93:00.1: Signaling PME through PCIe PME interrupt
[   97.869973] pcie_pme 0000:90:03.0:pcie01: service driver pcie_pme loaded
[   97.870163] pcieport 0000:a0:02.0: Signaling PME through PCIe PME interrupt
[   97.877842] pci 0000:a1:00.0: Signaling PME through PCIe PME interrupt
[   97.885049] pci 0000:a1:00.1: Signaling PME through PCIe PME interrupt
[   97.892269] pcie_pme 0000:a0:02.0:pcie01: service driver pcie_pme loaded
[   97.892466] pcieport 0000:a0:02.2: Signaling PME through PCIe PME interrupt
[   97.900156] pci 0000:a3:00.0: Signaling PME through PCIe PME interrupt
[   97.907362] pci 0000:a3:00.1: Signaling PME through PCIe PME interrupt
[   97.914584] pcie_pme 0000:a0:02.2:pcie01: service driver pcie_pme loaded
[   97.914779] pcieport 0000:a0:03.0: Signaling PME through PCIe PME interrupt
[   97.922468] pcie_pme 0000:a0:03.0:pcie01: service driver pcie_pme loaded
[   97.922564] pcieport 0000:a0:11.0: Signaling PME through PCIe PME interrupt
[   97.930252] pcie_pme 0000:a0:11.0:pcie01: service driver pcie_pme loaded
[   97.930398] pcieport 0000:a0:1c.0: Signaling PME through PCIe PME interrupt
[   97.938078] pci 0000:a7:00.0: Signaling PME through PCIe PME interrupt
[   97.945291] pci 0000:a7:00.2: Signaling PME through PCIe PME interrupt
[   97.952513] pcie_pme 0000:a0:1c.0:pcie01: service driver pcie_pme loaded
[   97.952714] pcieport 0000:b0:02.0: Signaling PME through PCIe PME interrupt
[   97.960407] pcie_pme 0000:b0:02.0:pcie01: service driver pcie_pme loaded
[   97.960506] pcieport 0000:b0:02.2: Signaling PME through PCIe PME interrupt
[   97.968191] pcie_pme 0000:b0:02.2:pcie01: service driver pcie_pme loaded
[   97.968351] pcieport 0000:b0:03.0: Signaling PME through PCIe PME interrupt
[   97.976029] pci 0000:b3:00.0: Signaling PME through PCIe PME interrupt
[   97.983241] pci 0000:b3:00.1: Signaling PME through PCIe PME interrupt
[   97.990459] pcie_pme 0000:b0:03.0:pcie01: service driver pcie_pme loaded
[   97.990657] pcieport 0000:c0:02.0: Signaling PME through PCIe PME interrupt
[   97.998352] pci 0000:c1:00.0: Signaling PME through PCIe PME interrupt
[   98.001022] tsc: Refined TSC clocksource calibration: 2793.676 MHz
[   98.012380] pci 0000:c1:00.1: Signaling PME through PCIe PME interrupt
[   98.019598] pcie_pme 0000:c0:02.0:pcie01: service driver pcie_pme loaded
[   98.019790] pcieport 0000:c0:02.2: Signaling PME through PCIe PME interrupt
[   98.027475] pci 0000:c3:00.0: Signaling PME through PCIe PME interrupt
[   98.034684] pci 0000:c3:00.1: Signaling PME through PCIe PME interrupt
[   98.041909] pcie_pme 0000:c0:02.2:pcie01: service driver pcie_pme loaded
[   98.042086] pcieport 0000:c0:03.0: Signaling PME through PCIe PME interrupt
[   98.049773] pcie_pme 0000:c0:03.0:pcie01: service driver pcie_pme loaded
[   98.049882] pcieport 0000:c0:11.0: Signaling PME through PCIe PME interrupt
[   98.057571] pcie_pme 0000:c0:11.0:pcie01: service driver pcie_pme loaded
[   98.057710] pcieport 0000:c0:1c.0: Signaling PME through PCIe PME interrupt
[   98.065387] pci 0000:c7:00.0: Signaling PME through PCIe PME interrupt
[   98.072603] pci 0000:c7:00.2: Signaling PME through PCIe PME interrupt
[   98.079825] pcie_pme 0000:c0:1c.0:pcie01: service driver pcie_pme loaded
[   98.080019] pcieport 0000:d0:02.0: Signaling PME through PCIe PME interrupt
[   98.087708] pcie_pme 0000:d0:02.0:pcie01: service driver pcie_pme loaded
[   98.087802] pcieport 0000:d0:02.2: Signaling PME through PCIe PME interrupt
[   98.095487] pcie_pme 0000:d0:02.2:pcie01: service driver pcie_pme loaded
[   98.095640] pcieport 0000:d0:03.0: Signaling PME through PCIe PME interrupt
[   98.103326] pci 0000:d3:00.0: Signaling PME through PCIe PME interrupt
[   98.110542] pci 0000:d3:00.1: Signaling PME through PCIe PME interrupt
[   98.117760] pcie_pme 0000:d0:03.0:pcie01: service driver pcie_pme loaded
[   98.117950] pcieport 0000:e0:02.0: Signaling PME through PCIe PME interrupt
[   98.125641] pci 0000:e1:00.0: Signaling PME through PCIe PME interrupt
[   98.132854] pci 0000:e1:00.1: Signaling PME through PCIe PME interrupt
[   98.140071] pcie_pme 0000:e0:02.0:pcie01: service driver pcie_pme loaded
[   98.140262] pcieport 0000:e0:02.2: Signaling PME through PCIe PME interrupt
[   98.147942] pci 0000:e3:00.0: Signaling PME through PCIe PME interrupt
[   98.155151] pci 0000:e3:00.1: Signaling PME through PCIe PME interrupt
[   98.162368] pcie_pme 0000:e0:02.2:pcie01: service driver pcie_pme loaded
[   98.162560] pcieport 0000:e0:03.0: Signaling PME through PCIe PME interrupt
[   98.170243] pcie_pme 0000:e0:03.0:pcie01: service driver pcie_pme loaded
[   98.170344] pcieport 0000:e0:11.0: Signaling PME through PCIe PME interrupt
[   98.178032] pcie_pme 0000:e0:11.0:pcie01: service driver pcie_pme loaded
[   98.178188] pcieport 0000:e0:1c.0: Signaling PME through PCIe PME interrupt
[   98.185869] pci 0000:e7:00.0: Signaling PME through PCIe PME interrupt
[   98.193078] pci 0000:e7:00.2: Signaling PME through PCIe PME interrupt
[   98.200297] pcie_pme 0000:e0:1c.0:pcie01: service driver pcie_pme loaded
[   98.200487] pcieport 0000:f0:02.0: Signaling PME through PCIe PME interrupt
[   98.208177] pcie_pme 0000:f0:02.0:pcie01: service driver pcie_pme loaded
[   98.208275] pcieport 0000:f0:02.2: Signaling PME through PCIe PME interrupt
[   98.215960] pcie_pme 0000:f0:02.2:pcie01: service driver pcie_pme loaded
[   98.216113] pcieport 0000:f0:03.0: Signaling PME through PCIe PME interrupt
[   98.223794] pci 0000:f3:00.0: Signaling PME through PCIe PME interrupt
[   98.231011] pci 0000:f3:00.1: Signaling PME through PCIe PME interrupt
[   98.238227] pcie_pme 0000:f0:03.0:pcie01: service driver pcie_pme loaded
[   98.239720] efifb: probing for efifb
[   98.243917] efifb: framebuffer at 0x92000000, mapped to 0xffffc90332c00000, using 6144k, total 8192k
[   98.254003] efifb: mode is 1024x768x32, linelength=4096, pages=1
[   98.260639] efifb: scrolling: redraw
[   98.264595] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[   98.302924] Console: switching to colour frame buffer device 128x48
[   98.341354] fb0: EFI VGA frame buffer device
[   98.346191] intel_idle: MWAIT substates: 0x1120
[   98.346196] intel_idle: v0.4 model 0x3E
[   98.346197] intel_idle: lapic_timer_reliable_states 0xffffffff
[   98.346209] intel_idle: max_cstate 1 reached
[   98.373983] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[   98.382468] Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
[   98.410340] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   98.424068] Non-volatile memory driver v1.3
[   98.428805] Linux agpgart interface v0.103
[   98.441678] libphy: Fixed MDIO Bus: probed
[   98.446294] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   99.514219] i8042: No controller found
[   99.520321] Switched to clocksource tsc
[   99.520360] mousedev: PS/2 mouse device common for all mice
[   99.520802] EFI Variables Facility v0.08 2004-May-17
[   99.566316] pstore: Registered efi as persistent store backend
[   99.566457] TCP: cubic registered
[   99.566548] Key type dns_resolver registered
[   99.610387] Loading compiled-in X.509 certificates
[   99.616457] Loaded X.509 cert 'Magrathea: Glacier signing key: ece216f5f1a582c6b1182929d8adfc5f88d373f2'
[   99.627039] registered taskstats version 1
[   99.631783] AppArmor: AppArmor sha1 policy hashing enabled
[   99.660926]   Magic number: 11:140:557
[   99.666296] clockevents clockevent8: hash matches
[   99.673957] container HPQ0003:21: hash matches
[   99.680109] acpi HPQ0003:21: hash matches
[   99.685549] memory memory5840: hash matches
[   99.690675] memory memory5394: hash matches
[   99.696212] memory memory4558: hash matches
[   99.702252] memory memory3272: hash matches
[   99.708079] memory memory2181: hash matches
[   99.713612] memory memory1345: hash matches
[   99.719055] memory memory558: hash matches
[   99.728058] Freeing unused kernel memory: 1632K (ffffffff81b01000 - ffffffff81c99000)
[   99.736684] Write protecting the kernel read-only data: 10240k
[   99.746502] Freeing unused kernel memory: 892K (ffff880001521000 - ffff880001600000)
[   99.757416] Freeing unused kernel memory: 1424K (ffff88000189c000 - ffff880001a00000)
[   99.874304] dm_mod: module verification failed: signature and/or required key missing - tainting kernel
[   99.890741] device-mapper: uevent: version 1.0.3
[   99.897366] device-mapper: ioctl: 4.30.0-ioctl (2014-12-22) initialised: dm-devel@redhat.com
[   99.962797] SCSI subsystem initialized
[   99.976537] emc: device handler registered
[   99.998630] rdac: device handler registered
[  100.020349] hp_sw: device handler registered
[  100.042473] alua: device handler registered
[  100.053751] udev: starting version 147
[  100.453449] ACPI: bus type USB registered
[  100.457938] usbcore: registered new interface driver usbfs
[  100.464043] usbcore: registered new interface driver hub
[  100.473869] usbcore: registered new device driver usb
[  100.507496] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.16-k.
[  100.517360] qla2xxx [0000:13:00.0]-011c: : MSI-X vector count: 31.
[  100.524166] qla2xxx [0000:13:00.0]-001d: : Found an ISP2031 irq 118 iobase 0xffffc90332b92000.
[  100.559344] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[  100.618563] uhci_hcd: USB Universal Host Controller Interface driver
[  100.627092] uhci_hcd 0000:07:00.4: UHCI Host Controller
[  100.632888] uhci_hcd 0000:07:00.4: new USB bus registered, assigned bus number 1
[  100.641063] uhci_hcd 0000:07:00.4: detected 8 ports
[  100.646438] uhci_hcd 0000:07:00.4: port count misdetected? forcing to 2 ports
[  100.654368] uhci_hcd 0000:07:00.4: irq 16, io base 0x00001500
[  100.660869] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[  100.668345] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  100.676302] usb usb1: Product: UHCI Host Controller
[  100.681674] usb usb1: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp uhci_hcd
[  100.690489] usb usb1: SerialNumber: 0000:07:00.4
[  100.696169] hub 1-0:1.0: USB hub found
[  100.700480] hub 1-0:1.0: 2 ports detected
[  100.729951] kswapd 1 initialised deferred memory in 3616ms
[  100.731558] kswapd 0 initialised deferred memory in 3616ms
[  100.740379] kswapd 15 initialised deferred memory in 3624ms
[  100.744127] kswapd 9 initialised deferred memory in 3624ms
[  100.745797] kswapd 13 initialised deferred memory in 3628ms
[  100.747732] kswapd 3 initialised deferred memory in 3632ms
[  100.748695] kswapd 12 initialised deferred memory in 3632ms
[  100.751505] kswapd 8 initialised deferred memory in 3632ms
[  100.751515] kswapd 4 initialised deferred memory in 3636ms
[  100.754394] kswapd 7 initialised deferred memory in 3636ms
[  100.756033] kswapd 14 initialised deferred memory in 3636ms
[  100.757678] kswapd 5 initialised deferred memory in 3644ms
[  100.757691] kswapd 6 initialised deferred memory in 3644ms
[  100.759441] kswapd 10 initialised deferred memory in 3640ms
[  100.760048] kswapd 11 initialised deferred memory in 3640ms
[  100.767978] kswapd 2 initialised deferred memory in 3652ms
[  101.970035] scsi host0: qla2xxx
[  102.726887] qla2xxx [0000:13:00.0]-500a:0: LOOP UP detected (8 Gbps).
[  103.387690] qla2xxx [0000:13:00.0]-00fb:0: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  103.396443] qla2xxx [0000:13:00.0]-00fc:0: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.0 hdma+ host#=0 fw=7.03.01 (d0d5).
[  103.408741] qla2xxx [0000:13:00.1]-011c: : MSI-X vector count: 31.
[  103.415556] qla2xxx [0000:13:00.1]-001d: : Found an ISP2031 irq 121 iobase 0xffffc90332ba0000.
[  103.986269] scsi 0:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  103.995626] scsi 0:0:0:0: alua: supports implicit TPGS
[  104.001425] scsi 0:0:0:0: alua: port group 01 rel port 05
[  104.007445] scsi 0:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[  104.015979] scsi 0:0:0:0: alua: Attached
[  104.021790] scsi 0:0:0:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.031143] scsi 0:0:0:1: alua: supports implicit TPGS
[  104.037053] scsi 0:0:0:1: alua: port group 01 rel port 05
[  104.043077] scsi 0:0:0:1: alua: port group 01 state N non-preferred supports tolusNA
[  104.051604] scsi 0:0:0:1: alua: Attached
[  104.056424] scsi 0:0:0:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.065712] scsi 0:0:0:2: alua: supports implicit TPGS
[  104.071667] scsi 0:0:0:2: alua: port group 01 rel port 05
[  104.077705] scsi 0:0:0:2: alua: port group 01 state N non-preferred supports tolusNA
[  104.086231] scsi 0:0:0:2: alua: Attached
[  104.091031] scsi 0:0:0:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.100312] scsi 0:0:0:3: alua: supports implicit TPGS
[  104.106218] scsi 0:0:0:3: alua: port group 01 rel port 05
[  104.112254] scsi 0:0:0:3: alua: port group 01 state N non-preferred supports tolusNA
[  104.120789] scsi 0:0:0:3: alua: Attached
[  104.126462] scsi 0:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.135812] scsi 0:0:1:0: alua: supports implicit TPGS
[  104.141617] scsi 0:0:1:0: alua: port group 00 rel port 01
[  104.147680] scsi 0:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  104.155827] scsi 0:0:1:0: alua: Attached
[  104.161203] scsi 0:0:1:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.170513] scsi 0:0:1:1: alua: supports implicit TPGS
[  104.176312] scsi 0:0:1:1: alua: port group 00 rel port 01
[  104.182333] scsi 0:0:1:1: alua: port group 00 state A preferred supports tolusNA
[  104.190480] scsi 0:0:1:1: alua: Attached
[  104.195271] scsi 0:0:1:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.204458] scsi 0:0:1:2: alua: supports implicit TPGS
[  104.210253] scsi 0:0:1:2: alua: port group 00 rel port 01
[  104.216272] scsi 0:0:1:2: alua: port group 00 state A preferred supports tolusNA
[  104.224414] scsi 0:0:1:2: alua: Attached
[  104.229375] scsi 0:0:1:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  104.238565] scsi 0:0:1:3: alua: supports implicit TPGS
[  104.244365] scsi 0:0:1:3: alua: port group 00 rel port 01
[  104.250380] scsi 0:0:1:3: alua: port group 00 state A preferred supports tolusNA
[  104.258523] scsi 0:0:1:3: alua: Attached
[  104.845585] scsi host1: qla2xxx
[  105.621888] qla2xxx [0000:13:00.1]-500a:1: LOOP UP detected (8 Gbps).
[  106.279280] qla2xxx [0000:13:00.1]-00fb:1: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  106.288002] qla2xxx [0000:13:00.1]-00fc:1: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.1 hdma+ host#=1 fw=7.03.01 (d0d5).
[  106.300571] qla2xxx [0000:33:00.0]-011c: : MSI-X vector count: 31.
[  106.307404] qla2xxx [0000:33:00.0]-001d: : Found an ISP2031 irq 124 iobase 0xffffc90332ba4000.
[  106.861931] scsi 1:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.871225] scsi 1:0:0:0: alua: supports implicit TPGS
[  106.877011] scsi 1:0:0:0: alua: port group 01 rel port 05
[  106.883018] scsi 1:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  106.891161] scsi 1:0:0:0: alua: Attached
[  106.896947] scsi 1:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.906132] scsi 1:0:1:0: alua: supports implicit TPGS
[  106.911892] scsi 1:0:1:0: alua: port group 00 rel port 01
[  106.917891] scsi 1:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  106.926034] scsi 1:0:1:0: alua: Attached
[  107.757220] scsi host2: qla2xxx
[  108.533781] qla2xxx [0000:33:00.0]-500a:2: LOOP UP detected (8 Gbps).
[  109.194919] qla2xxx [0000:33:00.0]-00fb:2: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  109.203645] qla2xxx [0000:33:00.0]-00fc:2: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.0 hdma+ host#=2 fw=7.03.01 (d0d5).
[  109.215562] qla2xxx [0000:33:00.1]-011c: : MSI-X vector count: 31.
[  109.222368] qla2xxx [0000:33:00.1]-001d: : Found an ISP2031 irq 127 iobase 0xffffc90332bbe000.
[  109.773499] scsi 2:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.782985] scsi 2:0:0:0: alua: supports implicit TPGS
[  109.788885] scsi 2:0:0:0: alua: port group 01 rel port 05
[  109.794951] scsi 2:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[  109.803482] scsi 2:0:0:0: alua: Attached
[  109.808888] scsi 2:0:0:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.818471] scsi 2:0:0:100: alua: supports implicit TPGS
[  109.824554] scsi 2:0:0:100: alua: port group 01 rel port 05
[  109.830780] scsi 2:0:0:100: alua: port group 01 state N non-preferred supports tolusNA
[  109.839505] scsi 2:0:0:100: alua: Attached
[  109.844623] scsi 2:0:0:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.854101] scsi 2:0:0:101: alua: supports implicit TPGS
[  109.860187] scsi 2:0:0:101: alua: port group 01 rel port 05
[  109.866408] scsi 2:0:0:101: alua: port group 01 state N non-preferred supports tolusNA
[  109.875127] scsi 2:0:0:101: alua: Attached
[  109.880326] scsi 2:0:0:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.889707] scsi 2:0:0:102: alua: supports implicit TPGS
[  109.895696] scsi 2:0:0:102: alua: port group 01 rel port 05
[  109.901911] scsi 2:0:0:102: alua: port group 01 state N non-preferred supports tolusNA
[  109.910628] scsi 2:0:0:102: alua: Attached
[  109.915674] scsi 2:0:0:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.925053] scsi 2:0:0:103: alua: supports implicit TPGS
[  109.931046] scsi 2:0:0:103: alua: port group 01 rel port 05
[  109.937263] scsi 2:0:0:103: alua: port group 01 state N non-preferred supports tolusNA
[  109.945980] scsi 2:0:0:103: alua: Attached
[  109.950923] scsi 2:0:0:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.960305] scsi 2:0:0:104: alua: supports implicit TPGS
[  109.966293] scsi 2:0:0:104: alua: port group 01 rel port 05
[  109.972506] scsi 2:0:0:104: alua: port group 01 state N non-preferred supports tolusNA
[  109.981224] scsi 2:0:0:104: alua: Attached
[  109.986458] scsi 2:0:0:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.995840] scsi 2:0:0:105: alua: supports implicit TPGS
[  110.001822] scsi 2:0:0:105: alua: port group 01 rel port 05
[  110.008029] scsi 2:0:0:105: alua: port group 01 state N non-preferred supports tolusNA
[  110.016746] scsi 2:0:0:105: alua: Attached
[  110.021749] scsi 2:0:0:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.031144] scsi 2:0:0:106: alua: supports implicit TPGS
[  110.037138] scsi 2:0:0:106: alua: port group 01 rel port 05
[  110.043351] scsi 2:0:0:106: alua: port group 01 state N non-preferred supports tolusNA
[  110.052063] scsi 2:0:0:106: alua: Attached
[  110.057070] scsi 2:0:0:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.066455] scsi 2:0:0:107: alua: supports implicit TPGS
[  110.072447] scsi 2:0:0:107: alua: port group 01 rel port 05
[  110.078660] scsi 2:0:0:107: alua: port group 01 state N non-preferred supports tolusNA
[  110.087375] scsi 2:0:0:107: alua: Attached
[  110.092542] scsi 2:0:0:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.101933] scsi 2:0:0:108: alua: supports implicit TPGS
[  110.107927] scsi 2:0:0:108: alua: port group 01 rel port 05
[  110.114142] scsi 2:0:0:108: alua: port group 01 state N non-preferred supports tolusNA
[  110.122855] scsi 2:0:0:108: alua: Attached
[  110.127898] scsi 2:0:0:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.137420] scsi 2:0:0:109: alua: supports implicit TPGS
[  110.143386] scsi 2:0:0:109: alua: port group 01 rel port 05
[  110.149584] scsi 2:0:0:109: alua: port group 01 state N non-preferred supports tolusNA
[  110.158309] scsi 2:0:0:109: alua: Attached
[  110.163312] scsi 2:0:0:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.172714] scsi 2:0:0:110: alua: supports implicit TPGS
[  110.178704] scsi 2:0:0:110: alua: port group 01 rel port 05
[  110.184913] scsi 2:0:0:110: alua: port group 01 state N non-preferred supports tolusNA
[  110.193630] scsi 2:0:0:110: alua: Attached
[  110.198858] scsi 2:0:0:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.208388] scsi 2:0:0:111: alua: supports implicit TPGS
[  110.214382] scsi 2:0:0:111: alua: port group 01 rel port 05
[  110.220588] scsi 2:0:0:111: alua: port group 01 state N non-preferred supports tolusNA
[  110.229301] scsi 2:0:0:111: alua: Attached
[  110.234272] scsi 2:0:0:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.243660] scsi 2:0:0:112: alua: supports implicit TPGS
[  110.249648] scsi 2:0:0:112: alua: port group 01 rel port 05
[  110.255855] scsi 2:0:0:112: alua: port group 01 state N non-preferred supports tolusNA
[  110.264570] scsi 2:0:0:112: alua: Attached
[  110.269534] scsi 2:0:0:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.278912] scsi 2:0:0:113: alua: supports implicit TPGS
[  110.284902] scsi 2:0:0:113: alua: port group 01 rel port 05
[  110.291123] scsi 2:0:0:113: alua: port group 01 state N non-preferred supports tolusNA
[  110.299845] scsi 2:0:0:113: alua: Attached
[  110.305191] scsi 2:0:0:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.314521] scsi 2:0:0:114: alua: supports implicit TPGS
[  110.320470] scsi 2:0:0:114: alua: port group 01 rel port 05
[  110.326663] scsi 2:0:0:114: alua: port group 01 state N non-preferred supports tolusNA
[  110.335386] scsi 2:0:0:114: alua: Attached
[  110.340595] scsi 2:0:0:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.349909] scsi 2:0:0:115: alua: supports implicit TPGS
[  110.355860] scsi 2:0:0:115: alua: port group 01 rel port 05
[  110.362047] scsi 2:0:0:115: alua: port group 01 state N non-preferred supports tolusNA
[  110.370769] scsi 2:0:0:115: alua: Attached
[  110.375759] scsi 2:0:0:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.385071] scsi 2:0:0:116: alua: supports implicit TPGS
[  110.391021] scsi 2:0:0:116: alua: port group 01 rel port 05
[  110.397210] scsi 2:0:0:116: alua: port group 01 state N non-preferred supports tolusNA
[  110.405932] scsi 2:0:0:116: alua: Attached
[  110.410926] scsi 2:0:0:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.420237] scsi 2:0:0:117: alua: supports implicit TPGS
[  110.426189] scsi 2:0:0:117: alua: port group 01 rel port 05
[  110.432378] scsi 2:0:0:117: alua: port group 01 state N non-preferred supports tolusNA
[  110.441106] scsi 2:0:0:117: alua: Attached
[  110.446251] scsi 2:0:0:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.455574] scsi 2:0:0:118: alua: supports implicit TPGS
[  110.461526] scsi 2:0:0:118: alua: port group 01 rel port 05
[  110.467718] scsi 2:0:0:118: alua: port group 01 state N non-preferred supports tolusNA
[  110.476438] scsi 2:0:0:118: alua: Attached
[  110.481404] scsi 2:0:0:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.490712] scsi 2:0:0:119: alua: supports implicit TPGS
[  110.496674] scsi 2:0:0:119: alua: port group 01 rel port 05
[  110.502862] scsi 2:0:0:119: alua: port group 01 state N non-preferred supports tolusNA
[  110.511576] scsi 2:0:0:119: alua: Attached
[  110.517061] scsi 2:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.526251] scsi 2:0:1:0: alua: supports implicit TPGS
[  110.532012] scsi 2:0:1:0: alua: port group 00 rel port 01
[  110.538018] scsi 2:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  110.546163] scsi 2:0:1:0: alua: Attached
[  110.552305] scsi 2:0:1:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.561631] scsi 2:0:1:100: alua: supports implicit TPGS
[  110.567751] scsi 2:0:1:100: alua: port group 00 rel port 01
[  110.573945] scsi 2:0:1:100: alua: port group 00 state A preferred supports tolusNA
[  110.582283] scsi 2:0:1:100: alua: Attached
[  110.587698] scsi 2:0:1:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.597019] scsi 2:0:1:101: alua: supports implicit TPGS
[  110.602972] scsi 2:0:1:101: alua: port group 00 rel port 01
[  110.609156] scsi 2:0:1:101: alua: port group 00 state A preferred supports tolusNA
[  110.617496] scsi 2:0:1:101: alua: Attached
[  110.622485] scsi 2:0:1:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.631800] scsi 2:0:1:102: alua: supports implicit TPGS
[  110.637758] scsi 2:0:1:102: alua: port group 00 rel port 01
[  110.643951] scsi 2:0:1:102: alua: port group 00 state A preferred supports tolusNA
[  110.652288] scsi 2:0:1:102: alua: Attached
[  110.657453] scsi 2:0:1:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.666789] scsi 2:0:1:103: alua: supports implicit TPGS
[  110.672931] scsi 2:0:1:103: alua: port group 00 rel port 01
[  110.673056] scsi host3: qla2xxx
[  110.682601] scsi 2:0:1:103: alua: port group 00 state A preferred supports tolusNA
[  110.690943] scsi 2:0:1:103: alua: Attached
[  110.696595] scsi 2:0:1:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.705909] scsi 2:0:1:104: alua: supports implicit TPGS
[  110.711864] scsi 2:0:1:104: alua: port group 00 rel port 01
[  110.718053] scsi 2:0:1:104: alua: port group 00 state A preferred supports tolusNA
[  110.726388] scsi 2:0:1:104: alua: Attached
[  110.731638] scsi 2:0:1:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.740958] scsi 2:0:1:105: alua: supports implicit TPGS
[  110.746908] scsi 2:0:1:105: alua: port group 00 rel port 01
[  110.753096] scsi 2:0:1:105: alua: port group 00 state A preferred supports tolusNA
[  110.761433] scsi 2:0:1:105: alua: Attached
[  110.766405] scsi 2:0:1:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.775725] scsi 2:0:1:106: alua: supports implicit TPGS
[  110.781693] scsi 2:0:1:106: alua: port group 00 rel port 01
[  110.787880] scsi 2:0:1:106: alua: port group 00 state A preferred supports tolusNA
[  110.796218] scsi 2:0:1:106: alua: Attached
[  110.801238] scsi 2:0:1:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.810545] scsi 2:0:1:107: alua: supports implicit TPGS
[  110.816498] scsi 2:0:1:107: alua: port group 00 rel port 01
[  110.822684] scsi 2:0:1:107: alua: port group 00 state A preferred supports tolusNA
[  110.831023] scsi 2:0:1:107: alua: Attached
[  110.836000] scsi 2:0:1:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.845320] scsi 2:0:1:108: alua: supports implicit TPGS
[  110.851269] scsi 2:0:1:108: alua: port group 00 rel port 01
[  110.857467] scsi 2:0:1:108: alua: port group 00 state A preferred supports tolusNA
[  110.865808] scsi 2:0:1:108: alua: Attached
[  110.871152] scsi 2:0:1:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.880465] scsi 2:0:1:109: alua: supports implicit TPGS
[  110.886425] scsi 2:0:1:109: alua: port group 00 rel port 01
[  110.892612] scsi 2:0:1:109: alua: port group 00 state A preferred supports tolusNA
[  110.900954] scsi 2:0:1:109: alua: Attached
[  110.905930] scsi 2:0:1:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.915246] scsi 2:0:1:110: alua: supports implicit TPGS
[  110.921200] scsi 2:0:1:110: alua: port group 00 rel port 01
[  110.927387] scsi 2:0:1:110: alua: port group 00 state A preferred supports tolusNA
[  110.935724] scsi 2:0:1:110: alua: Attached
[  110.940699] scsi 2:0:1:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.950009] scsi 2:0:1:111: alua: supports implicit TPGS
[  110.955962] scsi 2:0:1:111: alua: port group 00 rel port 01
[  110.962154] scsi 2:0:1:111: alua: port group 00 state A preferred supports tolusNA
[  110.970495] scsi 2:0:1:111: alua: Attached
[  110.975734] scsi 2:0:1:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  110.985056] scsi 2:0:1:112: alua: supports implicit TPGS
[  110.991010] scsi 2:0:1:112: alua: port group 00 rel port 01
[  110.997200] scsi 2:0:1:112: alua: port group 00 state A preferred supports tolusNA
[  111.005537] scsi 2:0:1:112: alua: Attached
[  111.010518] scsi 2:0:1:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.019830] scsi 2:0:1:113: alua: supports implicit TPGS
[  111.025783] scsi 2:0:1:113: alua: port group 00 rel port 01
[  111.031972] scsi 2:0:1:113: alua: port group 00 state A preferred supports tolusNA
[  111.040311] scsi 2:0:1:113: alua: Attached
[  111.045310] scsi 2:0:1:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.054626] scsi 2:0:1:114: alua: supports implicit TPGS
[  111.060576] scsi 2:0:1:114: alua: port group 00 rel port 01
[  111.066765] scsi 2:0:1:114: alua: port group 00 state A preferred supports tolusNA
[  111.075107] scsi 2:0:1:114: alua: Attached
[  111.080247] scsi 2:0:1:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.089561] scsi 2:0:1:115: alua: supports implicit TPGS
[  111.095518] scsi 2:0:1:115: alua: port group 00 rel port 01
[  111.101710] scsi 2:0:1:115: alua: port group 00 state A preferred supports tolusNA
[  111.110046] scsi 2:0:1:115: alua: Attached
[  111.115013] scsi 2:0:1:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.124324] scsi 2:0:1:116: alua: supports implicit TPGS
[  111.130272] scsi 2:0:1:116: alua: port group 00 rel port 01
[  111.136462] scsi 2:0:1:116: alua: port group 00 state A preferred supports tolusNA
[  111.144801] scsi 2:0:1:116: alua: Attached
[  111.149737] scsi 2:0:1:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.159050] scsi 2:0:1:117: alua: supports implicit TPGS
[  111.165021] scsi 2:0:1:117: alua: port group 00 rel port 01
[  111.171212] scsi 2:0:1:117: alua: port group 00 state A preferred supports tolusNA
[  111.179551] scsi 2:0:1:117: alua: Attached
[  111.184595] scsi 2:0:1:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.193911] scsi 2:0:1:118: alua: supports implicit TPGS
[  111.199866] scsi 2:0:1:118: alua: port group 00 rel port 01
[  111.206054] scsi 2:0:1:118: alua: port group 00 state A preferred supports tolusNA
[  111.214384] scsi 2:0:1:118: alua: Attached
[  111.219356] scsi 2:0:1:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  111.228668] scsi 2:0:1:119: alua: supports implicit TPGS
[  111.234627] scsi 2:0:1:119: alua: port group 00 rel port 01
[  111.240821] scsi 2:0:1:119: alua: port group 00 state A preferred supports tolusNA
[  111.249154] scsi 2:0:1:119: alua: Attached
[  111.428399] qla2xxx [0000:33:00.1]-500a:3: LOOP UP detected (8 Gbps).
[  112.078494] qla2xxx [0000:33:00.1]-00fb:3: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  112.087221] qla2xxx [0000:33:00.1]-00fc:3: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.1 hdma+ host#=3 fw=7.03.01 (d0d5).
[  112.099956] qla2xxx [0000:53:00.0]-011c: : MSI-X vector count: 31.
[  112.106801] qla2xxx [0000:53:00.0]-001d: : Found an ISP2031 irq 130 iobase 0xffffc90332bd0000.
[  112.689199] scsi 3:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  112.698434] scsi 3:0:0:0: alua: supports implicit TPGS
[  112.704221] scsi 3:0:0:0: alua: port group 01 rel port 05
[  112.710222] scsi 3:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  112.718362] scsi 3:0:0:0: alua: Attached
[  112.723957] scsi 3:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  112.733131] scsi 3:0:1:0: alua: supports implicit TPGS
[  112.738891] scsi 3:0:1:0: alua: port group 00 rel port 01
[  112.744887] scsi 3:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  112.753031] scsi 3:0:1:0: alua: Attached
[  113.552467] scsi host4: qla2xxx
[  114.311867] qla2xxx [0000:53:00.0]-500a:4: LOOP UP detected (8 Gbps).
[  114.974137] qla2xxx [0000:53:00.0]-00fb:4: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  114.982869] qla2xxx [0000:53:00.0]-00fc:4: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.0 hdma+ host#=4 fw=7.03.01 (d0d5).
[  114.994775] qla2xxx [0000:53:00.1]-011c: : MSI-X vector count: 31.
[  115.001581] qla2xxx [0000:53:00.1]-001d: : Found an ISP2031 irq 133 iobase 0xffffc90332bd4000.
[  115.568805] scsi 4:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  115.578090] scsi 4:0:0:0: alua: supports implicit TPGS
[  115.583893] scsi 4:0:0:0: alua: port group 01 rel port 05
[  115.589910] scsi 4:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  115.598049] scsi 4:0:0:0: alua: Attached
[  115.603460] scsi 4:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  115.612697] scsi 4:0:1:0: alua: supports implicit TPGS
[  115.618490] scsi 4:0:1:0: alua: port group 00 rel port 01
[  115.624510] scsi 4:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  115.632652] scsi 4:0:1:0: alua: Attached
[  116.432009] scsi host5: qla2xxx
[  117.202042] qla2xxx [0000:53:00.1]-500a:5: LOOP UP detected (8 Gbps).
[  117.853692] qla2xxx [0000:53:00.1]-00fb:5: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  117.862421] qla2xxx [0000:53:00.1]-00fc:5: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.1 hdma+ host#=5 fw=7.03.01 (d0d5).
[  117.875174] qla2xxx [0000:73:00.0]-011c: : MSI-X vector count: 31.
[  117.882017] qla2xxx [0000:73:00.0]-001d: : Found an ISP2031 irq 136 iobase 0xffffc90332bde000.
[  118.448493] scsi 5:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  118.457793] scsi 5:0:0:0: alua: supports implicit TPGS
[  118.463571] scsi 5:0:0:0: alua: port group 01 rel port 05
[  118.469575] scsi 5:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  118.477715] scsi 5:0:0:0: alua: Attached
[  118.483651] scsi 5:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  118.492831] scsi 5:0:1:0: alua: supports implicit TPGS
[  118.498592] scsi 5:0:1:0: alua: port group 00 rel port 01
[  118.504587] scsi 5:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  118.512733] scsi 5:0:1:0: alua: Attached
[  119.331654] scsi host6: qla2xxx
[  120.108648] qla2xxx [0000:73:00.0]-500a:6: LOOP UP detected (8 Gbps).
[  120.761359] qla2xxx [0000:73:00.0]-00fb:6: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  120.770090] qla2xxx [0000:73:00.0]-00fc:6: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.0 hdma+ host#=6 fw=7.03.01 (d0d5).
[  120.781998] qla2xxx [0000:73:00.1]-011c: : MSI-X vector count: 31.
[  120.788805] qla2xxx [0000:73:00.1]-001d: : Found an ISP2031 irq 139 iobase 0xffffc90332bee000.
[  121.348047] scsi 6:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  121.357345] scsi 6:0:0:0: alua: supports implicit TPGS
[  121.363153] scsi 6:0:0:0: alua: port group 01 rel port 05
[  121.369175] scsi 6:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  121.377319] scsi 6:0:0:0: alua: Attached
[  121.383080] scsi 6:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  121.392319] scsi 6:0:1:0: alua: supports implicit TPGS
[  121.398118] scsi 6:0:1:0: alua: port group 00 rel port 01
[  121.404134] scsi 6:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  121.412277] scsi 6:0:1:0: alua: Attached
[  122.215253] scsi host7: qla2xxx
[  122.990715] qla2xxx [0000:73:00.1]-500a:7: LOOP UP detected (8 Gbps).
[  123.644918] qla2xxx [0000:73:00.1]-00fb:7: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  123.653646] qla2xxx [0000:73:00.1]-00fc:7: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.1 hdma+ host#=7 fw=7.03.01 (d0d5).
[  123.666355] qla2xxx [0000:93:00.0]-011c: : MSI-X vector count: 31.
[  123.673199] qla2xxx [0000:93:00.0]-001d: : Found an ISP2031 irq 142 iobase 0xffffc90332bf8000.
[  124.231592] scsi 7:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  124.240931] scsi 7:0:0:0: alua: supports implicit TPGS
[  124.246710] scsi 7:0:0:0: alua: port group 01 rel port 05
[  124.252713] scsi 7:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  124.260858] scsi 7:0:0:0: alua: Attached
[  124.266914] scsi 7:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  124.276106] scsi 7:0:1:0: alua: supports implicit TPGS
[  124.281873] scsi 7:0:1:0: alua: port group 00 rel port 01
[  124.287870] scsi 7:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  124.296017] scsi 7:0:1:0: alua: Attached
[  125.122896] scsi host8: qla2xxx
[  125.900403] qla2xxx [0000:93:00.0]-500a:8: LOOP UP detected (8 Gbps).
[  126.556597] qla2xxx [0000:93:00.0]-00fb:8: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  126.565319] qla2xxx [0000:93:00.0]-00fc:8: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.0 hdma+ host#=8 fw=7.03.01 (d0d5).
[  126.577239] qla2xxx [0000:93:00.1]-011c: : MSI-X vector count: 31.
[  126.584047] qla2xxx [0000:93:00.1]-001d: : Found an ISP2031 irq 145 iobase 0xffffc90332bfc000.
[  127.139258] scsi 8:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  127.148546] scsi 8:0:0:0: alua: supports implicit TPGS
[  127.154356] scsi 8:0:0:0: alua: port group 01 rel port 05
[  127.160377] scsi 8:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  127.168516] scsi 8:0:0:0: alua: Attached
[  127.173915] scsi 8:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  127.183154] scsi 8:0:1:0: alua: supports implicit TPGS
[  127.188970] scsi 8:0:1:0: alua: port group 00 rel port 01
[  127.195004] scsi 8:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  127.203148] scsi 8:0:1:0: alua: Attached
[  128.014483] scsi host9: qla2xxx
[  128.774823] qla2xxx [0000:93:00.1]-500a:9: LOOP UP detected (8 Gbps).
[  129.424128] qla2xxx [0000:93:00.1]-00fb:9: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  129.432853] qla2xxx [0000:93:00.1]-00fc:9: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.1 hdma+ host#=9 fw=7.03.01 (d0d5).
[  129.445617] qla2xxx [0000:b3:00.0]-011c: : MSI-X vector count: 31.
[  129.452483] qla2xxx [0000:b3:00.0]-001d: : Found an ISP2031 irq 148 iobase 0xffffc90333202000.
[  130.030878] scsi 9:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  130.040202] scsi 9:0:0:0: alua: supports implicit TPGS
[  130.045978] scsi 9:0:0:0: alua: port group 01 rel port 05
[  130.051983] scsi 9:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  130.060130] scsi 9:0:0:0: alua: Attached
[  130.066114] scsi 9:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  130.075295] scsi 9:0:1:0: alua: supports implicit TPGS
[  130.081055] scsi 9:0:1:0: alua: port group 00 rel port 01
[  130.087051] scsi 9:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  130.095195] scsi 9:0:1:0: alua: Attached
[  130.898095] scsi host10: qla2xxx
[  131.675441] qla2xxx [0000:b3:00.0]-500a:10: LOOP UP detected (8 Gbps).
[  132.323791] qla2xxx [0000:b3:00.0]-00fb:10: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  132.333112] qla2xxx [0000:b3:00.0]-00fc:10: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.0 hdma+ host#=10 fw=7.03.01 (d0d5).
[  132.346744] qla2xxx [0000:b3:00.1]-011c: : MSI-X vector count: 31.
[  132.354838] qla2xxx [0000:b3:00.1]-001d: : Found an ISP2031 irq 151 iobase 0xffffc90333206000.
[  132.913561] scsi 10:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  132.924521] scsi 10:0:0:0: alua: supports implicit TPGS
[  132.931417] scsi 10:0:0:0: alua: port group 01 rel port 05
[  132.938911] scsi 10:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  132.948603] scsi 10:0:0:0: alua: Attached
[  132.956131] scsi 10:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  132.967024] scsi 10:0:1:0: alua: supports implicit TPGS
[  132.974114] scsi 10:0:1:0: alua: port group 00 rel port 01
[  132.981530] scsi 10:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  132.991211] scsi 10:0:1:0: alua: Attached
[  133.586009] [drm] Initialized drm 1.1.0 20060810
[  133.622862] checking generic (92000000 600000) vs hw (92000000 1000000)
[  133.622864] fb: switching to mgag200drmfb from EFI VGA
[  133.628991] Console: switching to colour dummy device 80x25
[  133.647716] [TTM] Zone  kernel: Available graphics memory: 6353844726 kiB
[  133.656307] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[  133.665021] [TTM] Initializing pool allocator
[  133.671358] [TTM] Initializing DMA pool allocator
[  133.707089] fbcon: mgadrmfb (fb0) is primary device
[  133.785680] scsi host11: qla2xxx
[  133.829623] Console: switching to colour frame buffer device 128x48
[  133.880495] mgag200 0000:07:00.1: fb0: mgadrmfb frame buffer device
[  133.888916] mgag200 0000:07:00.1: registered panic notifier
[  133.917712] [drm] Initialized mgag200 1.0.0 20110418 for 0000:07:00.1 on minor 0
[  134.545281] qla2xxx [0000:b3:00.1]-500a:11: LOOP UP detected (8 Gbps).
[  135.199344] qla2xxx [0000:b3:00.1]-00fb:11: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  135.208164] qla2xxx [0000:b3:00.1]-00fc:11: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.1 hdma+ host#=11 fw=7.03.01 (d0d5).
[  135.220526] qla2xxx [0000:d3:00.0]-011c: : MSI-X vector count: 31.
[  135.227360] qla2xxx [0000:d3:00.0]-001d: : Found an ISP2031 irq 154 iobase 0xffffc90332c00000.
[  135.802089] scsi 11:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  135.811558] scsi 11:0:0:0: alua: supports implicit TPGS
[  135.817433] scsi 11:0:0:0: alua: port group 01 rel port 05
[  135.823532] scsi 11:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  135.831776] scsi 11:0:0:0: alua: Attached
[  135.837880] scsi 11:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  135.847171] scsi 11:0:1:0: alua: supports implicit TPGS
[  135.853032] scsi 11:0:1:0: alua: port group 00 rel port 01
[  135.859126] scsi 11:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  135.867369] scsi 11:0:1:0: alua: Attached
[  136.673296] scsi host12: qla2xxx
[  137.432664] qla2xxx [0000:d3:00.0]-500a:12: LOOP UP detected (8 Gbps).
[  138.078931] qla2xxx [0000:d3:00.0]-00fb:12: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  138.087750] qla2xxx [0000:d3:00.0]-00fc:12: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.0 hdma+ host#=12 fw=7.03.01 (d0d5).
[  138.099836] qla2xxx [0000:d3:00.1]-011c: : MSI-X vector count: 31.
[  138.106642] qla2xxx [0000:d3:00.1]-001d: : Found an ISP2031 irq 157 iobase 0xffffc90332c04000.
[  138.688781] scsi 12:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  138.698395] scsi 12:0:0:0: alua: supports implicit TPGS
[  138.704263] scsi 12:0:0:0: alua: port group 01 rel port 05
[  138.710357] scsi 12:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  138.718603] scsi 12:0:0:0: alua: Attached
[  138.724214] scsi 12:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  138.733482] scsi 12:0:1:0: alua: supports implicit TPGS
[  138.739341] scsi 12:0:1:0: alua: port group 00 rel port 01
[  138.745436] scsi 12:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  138.753683] scsi 12:0:1:0: alua: Attached
[  139.536885] scsi host13: qla2xxx
[  140.298800] qla2xxx [0000:d3:00.1]-500a:13: LOOP UP detected (8 Gbps).
[  140.946506] qla2xxx [0000:d3:00.1]-00fb:13: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  140.955327] qla2xxx [0000:d3:00.1]-00fc:13: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.1 hdma+ host#=13 fw=7.03.01 (d0d5).
[  140.968175] qla2xxx [0000:f3:00.0]-011c: : MSI-X vector count: 31.
[  140.975014] qla2xxx [0000:f3:00.0]-001d: : Found an ISP2031 irq 160 iobase 0xffffc90332c0e000.
[  141.552482] scsi 13:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  141.562044] scsi 13:0:0:0: alua: supports implicit TPGS
[  141.567915] scsi 13:0:0:0: alua: port group 01 rel port 05
[  141.574012] scsi 13:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  141.582252] scsi 13:0:0:0: alua: Attached
[  141.587883] scsi 13:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  141.597144] scsi 13:0:1:0: alua: supports implicit TPGS
[  141.603008] scsi 13:0:1:0: alua: port group 00 rel port 01
[  141.609099] scsi 13:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  141.617343] scsi 13:0:1:0: alua: Attached
[  142.424482] scsi host14: qla2xxx
[  143.184711] qla2xxx [0000:f3:00.0]-500a:14: LOOP UP detected (8 Gbps).
[  143.838140] qla2xxx [0000:f3:00.0]-00fb:14: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  143.846967] qla2xxx [0000:f3:00.0]-00fc:14: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.0 hdma+ host#=14 fw=7.03.01 (d0d5).
[  143.859238] qla2xxx [0000:f3:00.1]-011c: : MSI-X vector count: 31.
[  143.866046] qla2xxx [0000:f3:00.1]-001d: : Found an ISP2031 irq 163 iobase 0xffffc90332c1e000.
[  144.440822] scsi 14:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  144.450189] scsi 14:0:0:0: alua: supports implicit TPGS
[  144.456085] scsi 14:0:0:0: alua: port group 01 rel port 05
[  144.462196] scsi 14:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  144.470441] scsi 14:0:0:0: alua: Attached
[  144.476301] scsi 14:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  144.485628] scsi 14:0:1:0: alua: supports implicit TPGS
[  144.491534] scsi 14:0:1:0: alua: port group 00 rel port 01
[  144.497652] scsi 14:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  144.505891] scsi 14:0:1:0: alua: Attached
[  145.284033] scsi host15: qla2xxx
[  146.064321] qla2xxx [0000:f3:00.1]-500a:15: LOOP UP detected (8 Gbps).
[  146.717705] qla2xxx [0000:f3:00.1]-00fb:15: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  146.726526] qla2xxx [0000:f3:00.1]-00fc:15: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.1 hdma+ host#=15 fw=7.03.01 (d0d5).
[  146.755915] sd 0:0:0:0: [sda] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  146.755931] sd 0:0:0:1: [sdb] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  146.756344] sd 0:0:0:1: [sdb] Write Protect is off
[  146.756346] sd 0:0:0:1: [sdb] Mode Sense: ef 00 00 08
[  146.756354] sd 0:0:0:2: [sdc] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  146.756591] sd 0:0:0:1: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.756607] sd 0:0:0:3: [sdd] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[  146.756686] sd 0:0:1:0: [sde] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  146.756789] sd 0:0:0:2: [sdc] Write Protect is off
[  146.756791] sd 0:0:0:2: [sdc] Mode Sense: ef 00 00 08
[  146.757029] sd 0:0:0:3: [sdd] Write Protect is off
[  146.757031] sd 0:0:0:3: [sdd] Mode Sense: ef 00 00 08
[  146.757036] sd 0:0:0:2: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.757075] sd 0:0:1:0: [sde] Write Protect is off
[  146.757077] sd 0:0:1:0: [sde] Mode Sense: ef 00 00 08
[  146.757165] sd 0:0:1:1: [sdf] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  146.757170] sd 0:0:0:3: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.757216] sd 0:0:1:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.757555] sd 0:0:1:1: [sdf] Write Protect is off
[  146.757557] sd 0:0:1:1: [sdf] Mode Sense: ef 00 00 08
[  146.757671] sd 0:0:1:2: [sdg] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  146.757766] sd 0:0:1:1: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.758062] sd 0:0:1:3: [sdh] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[  146.758190] sd 0:0:1:2: [sdg] Write Protect is off
[  146.758192] sd 0:0:1:2: [sdg] Mode Sense: ef 00 00 08
[  146.758430] sd 0:0:1:2: [sdg] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.758509] sd 0:0:1:3: [sdh] Write Protect is off
[  146.758511] sd 0:0:1:3: [sdh] Mode Sense: ef 00 00 08
[  146.758788] sd 0:0:1:3: [sdh] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.759052] random: nonblocking pool is initialized
[  146.759240] sd 2:0:0:0: [sdi] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  146.759248] sd 2:0:0:100: [sdj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759258] sd 2:0:0:101: [sdk] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759263] sd 2:0:0:102: [sdl] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759281] sd 2:0:0:103: [sdm] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759567] sd 2:0:0:104: [sdn] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759757] sd 2:0:0:105: [sdo] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.759762] sd 2:0:0:0: [sdi] Write Protect is off
[  146.759764] sd 2:0:0:0: [sdi] Mode Sense: ef 00 00 08
[  146.759769] sd 2:0:0:100: [sdj] Write Protect is off
[  146.759772] sd 2:0:0:100: [sdj] Mode Sense: ef 00 00 08
[  146.759840] sd 2:0:0:101: [sdk] Write Protect is off
[  146.759843] sd 2:0:0:101: [sdk] Mode Sense: ef 00 00 08
[  146.759850] sd 2:0:0:102: [sdl] Write Protect is off
[  146.759853] sd 2:0:0:102: [sdl] Mode Sense: ef 00 00 08
[  146.759872] sd 2:0:0:103: [sdm] Write Protect is off
[  146.759875] sd 2:0:0:103: [sdm] Mode Sense: ef 00 00 08
[  146.760078] sd 2:0:0:0: [sdi] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760085] sd 2:0:0:100: [sdj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760091] sd 2:0:0:101: [sdk] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760101] sd 2:0:0:102: [sdl] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760107] sd 2:0:0:104: [sdn] Write Protect is off
[  146.760109] sd 2:0:0:104: [sdn] Mode Sense: ef 00 00 08
[  146.760117] sd 2:0:0:103: [sdm] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760293] sd 2:0:0:106: [sdp] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.760312] sd 2:0:0:105: [sdo] Write Protect is off
[  146.760315] sd 2:0:0:105: [sdo] Mode Sense: ef 00 00 08
[  146.760456] sd 2:0:0:104: [sdn] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760585] sd 2:0:0:107: [sdq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.760600] sd 2:0:0:105: [sdo] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.760896] sd 2:0:0:106: [sdp] Write Protect is off
[  146.760898] sd 2:0:0:106: [sdp] Mode Sense: ef 00 00 08
[  146.760902] sd 2:0:0:108: [sdr] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.761141]  sdg: sdg1 sdg2 sdg3
[  146.761166] sd 2:0:0:107: [sdq] Write Protect is off
[  146.761173] sd 2:0:0:107: [sdq] Mode Sense: ef 00 00 08
[  146.761190] sd 2:0:0:106: [sdp] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.761509] sd 2:0:0:107: [sdq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.761569] sd 2:0:0:108: [sdr] Write Protect is off
[  146.761571] sd 2:0:0:108: [sdr] Mode Sense: ef 00 00 08
[  146.761955]  sdc: sdc1 sdc2 sdc3
[  146.761985] sd 2:0:0:108: [sdr] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.762283] sd 2:0:0:109: [sds] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.762957] sd 2:0:0:109: [sds] Write Protect is off
[  146.762959] sd 2:0:0:109: [sds] Mode Sense: ef 00 00 08
[  146.762987] sd 0:0:1:2: [sdg] Attached SCSI disk
[  146.763293] sd 2:0:0:109: [sds] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.763322] sd 2:0:0:110: [sdt] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.763659] sd 2:0:0:111: [sdu] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.763899] sd 2:0:0:110: [sdt] Write Protect is off
[  146.763901] sd 2:0:0:110: [sdt] Mode Sense: ef 00 00 08
[  146.763906] sd 2:0:0:112: [sdv] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.764133] sd 2:0:0:110: [sdt] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.764158] sd 2:0:0:111: [sdu] Write Protect is off
[  146.764160] sd 2:0:0:111: [sdu] Mode Sense: ef 00 00 08
[  146.764215] sd 0:0:0:2: [sdc] Attached SCSI disk
[  146.764217] sd 2:0:0:113: [sdw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.764354] sd 2:0:0:114: [sdx] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.764382] sd 2:0:0:112: [sdv] Write Protect is off
[  146.764383] sd 2:0:0:112: [sdv] Mode Sense: ef 00 00 08
[  146.764389] sd 2:0:0:111: [sdu] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.764440] sd 2:0:0:115: [sdy] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.764584] sd 2:0:0:112: [sdv] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.764610] sd 2:0:0:116: [sdz] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.764617] sd 2:0:0:113: [sdw] Write Protect is off
[  146.764619] sd 2:0:0:113: [sdw] Mode Sense: ef 00 00 08
[  146.764737] sd 2:0:0:114: [sdx] Write Protect is off
[  146.764739] sd 2:0:0:114: [sdx] Mode Sense: ef 00 00 08
[  146.764869] sd 2:0:0:113: [sdw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.764875] sd 2:0:0:115: [sdy] Write Protect is off
[  146.764878] sd 2:0:0:115: [sdy] Mode Sense: ef 00 00 08
[  146.764997] sd 2:0:0:117: [sdaa] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.765043] sd 2:0:0:114: [sdx] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.765072] sd 2:0:0:116: [sdz] Write Protect is off
[  146.765074] sd 2:0:0:116: [sdz] Mode Sense: ef 00 00 08
[  146.765154] sd 2:0:0:115: [sdy] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.765229] sd 2:0:0:118: [sdab] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.765335] sd 2:0:0:116: [sdz] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.765507] sd 2:0:0:117: [sdaa] Write Protect is off
[  146.765510] sd 2:0:0:117: [sdaa] Mode Sense: ef 00 00 08
[  146.765521] sd 2:0:0:119: [sdac] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.765771] sd 2:0:1:0: [sdad] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  146.765773] sd 2:0:0:118: [sdab] Write Protect is off
[  146.765775] sd 2:0:0:118: [sdab] Mode Sense: ef 00 00 08
[  146.765821] sd 2:0:0:117: [sdaa] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.766142] sd 2:0:0:118: [sdab] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.766217] sd 2:0:1:100: [sdae] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.766267] sd 2:0:0:119: [sdac] Write Protect is off
[  146.766269] sd 2:0:0:119: [sdac] Mode Sense: ef 00 00 08
[  146.766314] sd 2:0:1:0: [sdad] Write Protect is off
[  146.766316] sd 2:0:1:0: [sdad] Mode Sense: ef 00 00 08
[  146.766380] sd 2:0:1:101: [sdaf] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.766516] sd 2:0:0:119: [sdac] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.766554] sd 2:0:1:0: [sdad] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.766668] sd 2:0:1:100: [sdae] Write Protect is off
[  146.766669] sd 2:0:1:100: [sdae] Mode Sense: ef 00 00 08
[  146.766871] sd 2:0:1:101: [sdaf] Write Protect is off
[  146.766873] sd 2:0:1:101: [sdaf] Mode Sense: ef 00 00 08
[  146.767021] sd 2:0:1:100: [sdae] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.767027] sd 2:0:1:102: [sdag] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.767187] sd 2:0:1:101: [sdaf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.767353]  sde: sde1 sde2 sde3
[  146.767825] sd 2:0:1:102: [sdag] Write Protect is off
[  146.767826] sd 2:0:1:102: [sdag] Mode Sense: ef 00 00 08
[  146.767839] sd 2:0:1:103: [sdah] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.768119] sd 2:0:1:102: [sdag] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.768606] sd 2:0:1:103: [sdah] Write Protect is off
[  146.768608] sd 2:0:1:103: [sdah] Mode Sense: ef 00 00 08
[  146.768848] sd 2:0:0:102: [sdl] Attached SCSI disk
[  146.768922] sd 2:0:1:103: [sdah] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.769177] sd 2:0:1:104: [sdai] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.769466] sd 0:0:1:0: [sde] Attached SCSI disk
[  146.769562] sd 2:0:1:104: [sdai] Write Protect is off
[  146.769564] sd 2:0:1:104: [sdai] Mode Sense: ef 00 00 08
[  146.769656] sd 2:0:1:105: [sdaj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.769791] sd 2:0:1:104: [sdai] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.769867] sd 2:0:0:103: [sdm] Attached SCSI disk
[  146.770020] sd 2:0:1:105: [sdaj] Write Protect is off
[  146.770021] sd 2:0:1:105: [sdaj] Mode Sense: ef 00 00 08
[  146.770045] sd 2:0:1:106: [sdak] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.770258] sd 2:0:1:105: [sdaj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.770498] sd 2:0:1:106: [sdak] Write Protect is off
[  146.770500] sd 2:0:1:106: [sdak] Mode Sense: ef 00 00 08
[  146.770801] sd 2:0:1:106: [sdak] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.771309] sd 2:0:1:102: [sdag] Attached SCSI disk
[  146.771561] sd 2:0:1:107: [sdal] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772001] sd 2:0:1:108: [sdam] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772140] sd 2:0:1:107: [sdal] Write Protect is off
[  146.772142] sd 2:0:1:107: [sdal] Mode Sense: ef 00 00 08
[  146.772158] sd 2:0:1:109: [sdan] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772299] sd 2:0:0:114: [sdx] Attached SCSI disk
[  146.772325] sd 2:0:1:103: [sdah] Attached SCSI disk
[  146.772356] sd 2:0:1:110: [sdao] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772366] sd 2:0:1:107: [sdal] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.772381] sd 2:0:1:108: [sdam] Write Protect is off
[  146.772383] sd 2:0:1:108: [sdam] Mode Sense: ef 00 00 08
[  146.772564] sd 2:0:1:111: [sdap] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772570] sd 2:0:1:113: [sdar] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772580] sd 2:0:1:112: [sdaq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.772608] sd 2:0:1:109: [sdan] Write Protect is off
[  146.772610] sd 2:0:1:109: [sdan] Mode Sense: ef 00 00 08
[  146.772635] sd 2:0:1:108: [sdam] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.772838] sd 2:0:1:110: [sdao] Write Protect is off
[  146.772840] sd 2:0:1:110: [sdao] Mode Sense: ef 00 00 08
[  146.772874] sd 2:0:1:109: [sdan] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.772988] sd 2:0:1:114: [sdas] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.773034] sd 2:0:1:111: [sdap] Write Protect is off
[  146.773037] sd 2:0:1:111: [sdap] Mode Sense: ef 00 00 08
[  146.773042] sd 2:0:0:105: [sdo] Attached SCSI disk
[  146.773050] sd 2:0:1:113: [sdar] Write Protect is off
[  146.773052] sd 2:0:1:113: [sdar] Mode Sense: ef 00 00 08
[  146.773069] sd 2:0:1:110: [sdao] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.773095] sd 2:0:1:112: [sdaq] Write Protect is off
[  146.773098] sd 2:0:1:112: [sdaq] Mode Sense: ef 00 00 08
[  146.773182] sd 2:0:1:115: [sdat] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.773259] sd 2:0:1:111: [sdap] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.773266] sd 2:0:1:116: [sdau] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.773281] sd 2:0:1:113: [sdar] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.773376] sd 2:0:1:112: [sdaq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.773585] sd 2:0:1:114: [sdas] Write Protect is off
[  146.773586] sd 2:0:1:114: [sdas] Mode Sense: ef 00 00 08
[  146.773598] sd 2:0:1:105: [sdaj] Attached SCSI disk
[  146.773792] sd 2:0:1:115: [sdat] Write Protect is off
[  146.773795] sd 2:0:1:115: [sdat] Mode Sense: ef 00 00 08
[  146.773859] sd 2:0:1:114: [sdas] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.773875] sd 2:0:1:117: [sdav] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.773887] sd 2:0:1:116: [sdau] Write Protect is off
[  146.773894] sd 2:0:1:116: [sdau] Mode Sense: ef 00 00 08
[  146.774278] sd 2:0:1:115: [sdat] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.774381] sd 2:0:1:116: [sdau] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.774393] sd 2:0:1:118: [sdaw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.774440] sd 2:0:1:119: [sdax] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  146.774687] sd 2:0:1:117: [sdav] Write Protect is off
[  146.774689] sd 2:0:1:117: [sdav] Mode Sense: ef 00 00 08
[  146.774707] sd 2:0:0:109: [sds] Attached SCSI disk
[  146.775048] sd 2:0:1:117: [sdav] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.775073] sd 2:0:1:118: [sdaw] Write Protect is off
[  146.775075] sd 2:0:1:118: [sdaw] Mode Sense: ef 00 00 08
[  146.775090] sd 2:0:1:119: [sdax] Write Protect is off
[  146.775092] sd 2:0:1:119: [sdax] Mode Sense: ef 00 00 08
[  146.775441] sd 2:0:1:118: [sdaw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.775458] sd 2:0:0:113: [sdw] Attached SCSI disk
[  146.775469] sd 2:0:1:119: [sdax] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  146.776195]  sdh: sdh1 sdh2 sdh3 sdh4 sdh5
[  146.776624]  sdd: sdd1 sdd2 sdd3 sdd4 sdd5
[  146.776678] sd 2:0:0:100: [sdj] Attached SCSI disk
[  146.777029] sd 2:0:1:109: [sdan] Attached SCSI disk
[  146.777049] sd 2:0:1:100: [sdae] Attached SCSI disk
[  146.777649]  sdf: sdf1 sdf2 sdf3
[  146.777844] sd 2:0:1:113: [sdar] Attached SCSI disk
[  146.777953]  sdb: sdb1 sdb2 sdb3
[  146.778106] sd 2:0:1:114: [sdas] Attached SCSI disk
[  146.778373] sd 0:0:1:3: [sdh] Attached SCSI disk
[  146.778403] sd 2:0:0:107: [sdq] Attached SCSI disk
[  146.778410] sd 2:0:1:107: [sdal] Attached SCSI disk
[  146.778629] sd 0:0:0:3: [sdd] Attached SCSI disk
[  146.779184] sd 0:0:1:1: [sdf] Attached SCSI disk
[  146.779456] sd 0:0:0:1: [sdb] Attached SCSI disk
[  146.780312] sd 2:0:1:115: [sdat] Attached SCSI disk
[  146.780319] sd 2:0:0:115: [sdy] Attached SCSI disk
[  146.781495] sd 2:0:1:119: [sdax] Attached SCSI disk
[  146.781616] sd 2:0:0:119: [sdac] Attached SCSI disk
[  146.782432] sd 2:0:1:116: [sdau] Attached SCSI disk
[  146.782490] sd 2:0:0:116: [sdz] Attached SCSI disk
[  146.784250] sd 2:0:0:101: [sdk] Attached SCSI disk
[  146.784274] sd 2:0:1:101: [sdaf] Attached SCSI disk
[  146.786077]  sdad: sdad1 sdad2 sdad3
[  146.786489]  sdi: sdi1 sdi2 sdi3
[  146.786498] sd 2:0:1:118: [sdaw] Attached SCSI disk
[  146.786509] sd 2:0:0:118: [sdab] Attached SCSI disk
[  146.787672] sd 2:0:1:0: [sdad] Attached SCSI disk
[  146.788221] sd 2:0:0:0: [sdi] Attached SCSI disk
[  146.788382] sd 2:0:0:104: [sdn] Attached SCSI disk
[  146.788391] sd 2:0:1:104: [sdai] Attached SCSI disk
[  146.790525] sd 2:0:0:108: [sdr] Attached SCSI disk
[  146.790533] sd 2:0:1:108: [sdam] Attached SCSI disk
[  146.792940] sd 2:0:0:112: [sdv] Attached SCSI disk
[  146.793028] sd 2:0:1:112: [sdaq] Attached SCSI disk
[  146.794724] sd 2:0:1:110: [sdao] Attached SCSI disk
[  146.794779] sd 2:0:0:110: [sdt] Attached SCSI disk
[  146.796412] sd 2:0:0:117: [sdaa] Attached SCSI disk
[  146.796469] sd 2:0:1:117: [sdav] Attached SCSI disk
[  146.798906] sd 2:0:1:106: [sdak] Attached SCSI disk
[  146.798913] sd 2:0:0:106: [sdp] Attached SCSI disk
[  146.802763] sd 2:0:0:111: [sdu] Attached SCSI disk
[  146.802818] sd 2:0:1:111: [sdap] Attached SCSI disk
[  147.299609] scsi 15:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  147.301198] scsi 15:0:0:0: alua: supports implicit TPGS
[  147.301427] scsi 15:0:0:0: alua: port group 01 rel port 05
[  147.301484] scsi 15:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  147.301485] scsi 15:0:0:0: alua: Attached
[  148.270607] sd 0:0:0:0: [sda] Write Protect is off
[  148.275894] sd 0:0:0:0: [sda] Mode Sense: ef 00 00 08
[  148.276022] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  148.288448]  sda: sda1 sda2 sda3
[  148.289569] scsi 15:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  148.289828] scsi 15:0:1:0: alua: supports implicit TPGS
[  148.289929] scsi 15:0:1:0: alua: port group 00 rel port 01
[  148.289981] scsi 15:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  148.289982] scsi 15:0:1:0: alua: Attached
[  148.327211] sd 0:0:0:0: [sda] Attached SCSI disk
[  148.650410] xor: automatically using best checksumming function:
[  148.696133]    avx       : 20860.000 MB/sec
[  148.780242] raid6: sse2x1    7468 MB/s
[  148.852332] raid6: sse2x2    9300 MB/s
[  148.924423] raid6: sse2x4   11149 MB/s
[  148.928549] raid6: using algorithm sse2x4 (11149 MB/s)
[  148.934208] raid6: using ssse3x2 recovery algorithm
[  149.328743] device-mapper: multipath: version 1.8.0 loaded
[  149.352866] device-mapper: multipath round-robin: version 1.0.0 loaded
[  149.377246] device-mapper: multipath queue-length: version 0.1.0 loaded
[  149.407725] device-mapper: multipath service-time: version 0.2.0 loaded
[  152.894846] kjournald starting.  Commit interval 5 seconds
[  152.895244] EXT3-fs (dm-13): using internal journal
[  152.895248] EXT3-fs (dm-13): mounted filesystem with ordered data mode
[  154.594900] udev: starting version 147
[  155.011444] ipmi message handler version 39.2
[  155.012586] rtc_cmos 00:01: RTC can wake from S4
[  155.056565] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[  155.063525] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[  155.074200] IPMI System Interface driver.
[  155.097193] ipmi_si: probing via ACPI
[  155.101261] ipmi_si 00:00: [mem 0xfe062110000-0xfe062110002] regsize 1 spacing 1 irq 20
[  155.110074] ipmi_si: Adding ACPI-specified bt state machine
[  155.116872] ipmi_si: probing via SPMI
[  155.120903] ipmi_si: SPMI: mem 0xfe062110000 regsize 1 spacing 1 irq 20
[  155.128217] ipmi_si: Adding SPMI-specified bt state machine duplicate interface
[  155.136285] ipmi_si: Trying ACPI-specified bt state machine at mem address 0xfe062110000, slave address 0x0, irq 20
[  155.168321] ipmi_si 00:00: Using irq 20
[  155.196449] IPMI BT: req2rsp=6 secs retries=16
[  155.252700] ipmi_si 00:00: Found new BMC (man_id: 0x00000b, prod_id: 0x1002, dev_id: 0x40)
[  155.262165] ipmi_si 00:00: IPMI bt interface initialized
[  155.619818] dca service started, version 1.12.1
[  155.634305] lpc_ich 0000:20:1f.0: I/O space for ACPI uninitialized
[  155.635911] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[  155.638448] ACPI: Power Button [PWRB]
[  155.654372] lpc_ich 0000:20:1f.0: No MFD cells added
[  155.660952] lpc_ich 0000:40:1f.0: I/O space for ACPI uninitialized
[  155.667774] lpc_ich 0000:40:1f.0: No MFD cells added
[  155.674263] lpc_ich 0000:60:1f.0: I/O space for ACPI uninitialized
[  155.681081] lpc_ich 0000:60:1f.0: No MFD cells added
[  155.689743] lpc_ich 0000:84:1f.0: I/O space for ACPI uninitialized
[  155.696560] lpc_ich 0000:84:1f.0: No MFD cells added
[  155.702417] lpc_ich 0000:a0:1f.0: I/O space for ACPI uninitialized
[  155.709241] lpc_ich 0000:a0:1f.0: No MFD cells added
[  155.710140] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: NMI decoding initialized, allow kernel dump: ON (default = 1/ON)
[  155.713118] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: 1.3.3, timer margin: 30 seconds (nowayout=0).
[  155.737331] lpc_ich 0000:c0:1f.0: I/O space for ACPI uninitialized
[  155.744153] lpc_ich 0000:c0:1f.0: No MFD cells added
[  155.749729] lpc_ich 0000:e0:1f.0: I/O space for ACPI uninitialized
[  155.756549] lpc_ich 0000:e0:1f.0: No MFD cells added
[  155.763383] ioatdma: Intel(R) QuickData Technology Driver 4.00
[  155.773286] pps_core: LinuxPPS API ver. 1 registered
[  155.778756] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[  155.808821] ehci-pci: EHCI PCI platform driver
[  155.816330] ehci-pci 0000:00:1d.0: EHCI Host Controller
[  155.822131] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[  155.830313] ehci-pci 0000:00:1d.0: debug port 2
[  155.839239] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[  155.839267] ehci-pci 0000:00:1d.0: irq 23, io mem 0x90700000
[  155.846391] PTP clock support registered
[  155.857399] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[  155.864941] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[  155.872441] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  155.880409] usb usb2: Product: EHCI Host Controller
[  155.885796] usb usb2: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  155.894620] usb usb2: SerialNumber: 0000:00:1d.0
[  155.900565] hub 2-0:1.0: USB hub found
[  155.904708] hub 2-0:1.0: 2 ports detected
[  155.905595] ses 1:0:0:0: Attached Enclosure device
[  155.905615] ses 1:0:1:0: Attached Enclosure device
[  155.905923] ses 3:0:0:0: Attached Enclosure device
[  155.906139] ses 3:0:1:0: Attached Enclosure device
[  155.906398] ses 4:0:0:0: Attached Enclosure device
[  155.906641] ses 4:0:1:0: Attached Enclosure device
[  155.906885] ses 5:0:0:0: Attached Enclosure device
[  155.907119] ses 5:0:1:0: Attached Enclosure device
[  155.907352] ses 6:0:0:0: Attached Enclosure device
[  155.907596] ses 6:0:1:0: Attached Enclosure device
[  155.907827] ses 7:0:0:0: Attached Enclosure device
[  155.908071] ses 7:0:1:0: Attached Enclosure device
[  155.908088] ses 8:0:0:0: Attached Enclosure device
[  155.908103] ses 8:0:1:0: Attached Enclosure device
[  155.908116] ses 9:0:0:0: Attached Enclosure device
[  155.908128] ses 9:0:1:0: Attached Enclosure device
[  155.908139] ses 10:0:0:0: Attached Enclosure device
[  155.908156] ses 10:0:1:0: Attached Enclosure device
[  155.908172] ses 11:0:0:0: Attached Enclosure device
[  155.908205] ses 11:0:1:0: Attached Enclosure device
[  155.908233] ses 12:0:0:0: Attached Enclosure device
[  155.908253] ses 12:0:1:0: Attached Enclosure device
[  155.908272] ses 13:0:0:0: Attached Enclosure device
[  155.908298] ses 13:0:1:0: Attached Enclosure device
[  155.908317] ses 14:0:0:0: Attached Enclosure device
[  155.908334] ses 14:0:1:0: Attached Enclosure device
[  155.908355] ses 15:0:0:0: Attached Enclosure device
[  155.908373] ses 15:0:1:0: Attached Enclosure device
[  155.994294] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  155.994565] sd 0:0:0:1: Attached scsi generic sg1 type 0
[  155.994801] sd 0:0:0:2: Attached scsi generic sg2 type 0
[  155.995038] sd 0:0:0:3: Attached scsi generic sg3 type 0
[  155.995312] sd 0:0:1:0: Attached scsi generic sg4 type 0
[  155.995578] sd 0:0:1:1: Attached scsi generic sg5 type 0
[  155.995839] sd 0:0:1:2: Attached scsi generic sg6 type 0
[  155.996123] sd 0:0:1:3: Attached scsi generic sg7 type 0
[  155.996365] ses 1:0:0:0: Attached scsi generic sg8 type 13
[  155.996600] ses 1:0:1:0: Attached scsi generic sg9 type 13
[  155.996849] sd 2:0:0:0: Attached scsi generic sg10 type 0
[  155.997132] sd 2:0:0:100: Attached scsi generic sg11 type 0
[  155.997469] sd 2:0:0:101: Attached scsi generic sg12 type 0
[  155.997739] sd 2:0:0:102: Attached scsi generic sg13 type 0
[  155.997972] sd 2:0:0:103: Attached scsi generic sg14 type 0
[  155.998209] sd 2:0:0:104: Attached scsi generic sg15 type 0
[  155.998460] sd 2:0:0:105: Attached scsi generic sg16 type 0
[  155.998761] sd 2:0:0:106: Attached scsi generic sg17 type 0
[  155.999092] sd 2:0:0:107: Attached scsi generic sg18 type 0
[  155.999374] sd 2:0:0:108: Attached scsi generic sg19 type 0
[  155.999695] sd 2:0:0:109: Attached scsi generic sg20 type 0
[  155.999928] sd 2:0:0:110: Attached scsi generic sg21 type 0
[  156.000163] sd 2:0:0:111: Attached scsi generic sg22 type 0
[  156.000397] sd 2:0:0:112: Attached scsi generic sg23 type 0
[  156.000730] sd 2:0:0:113: Attached scsi generic sg24 type 0
[  156.001072] sd 2:0:0:114: Attached scsi generic sg25 type 0
[  156.001409] sd 2:0:0:115: Attached scsi generic sg26 type 0
[  156.001668] sd 2:0:0:116: Attached scsi generic sg27 type 0
[  156.003155] sd 2:0:0:117: Attached scsi generic sg28 type 0
[  156.003564] sd 2:0:0:118: Attached scsi generic sg29 type 0
[  156.003983] sd 2:0:0:119: Attached scsi generic sg30 type 0
[  156.004489] sd 2:0:1:0: Attached scsi generic sg31 type 0
[  156.004923] sd 2:0:1:100: Attached scsi generic sg32 type 0
[  156.005793] sd 2:0:1:101: Attached scsi generic sg33 type 0
[  156.006364] sd 2:0:1:102: Attached scsi generic sg34 type 0
[  156.006597] sd 2:0:1:103: Attached scsi generic sg35 type 0
[  156.006887] sd 2:0:1:104: Attached scsi generic sg36 type 0
[  156.007187] sd 2:0:1:105: Attached scsi generic sg37 type 0
[  156.007533] sd 2:0:1:106: Attached scsi generic sg38 type 0
[  156.007847] sd 2:0:1:107: Attached scsi generic sg39 type 0
[  156.008089] sd 2:0:1:108: Attached scsi generic sg40 type 0
[  156.008325] sd 2:0:1:109: Attached scsi generic sg41 type 0
[  156.008558] sd 2:0:1:110: Attached scsi generic sg42 type 0
[  156.008837] sd 2:0:1:111: Attached scsi generic sg43 type 0
[  156.009170] sd 2:0:1:112: Attached scsi generic sg44 type 0
[  156.009473] sd 2:0:1:113: Attached scsi generic sg45 type 0
[  156.009705] sd 2:0:1:114: Attached scsi generic sg46 type 0
[  156.009933] sd 2:0:1:115: Attached scsi generic sg47 type 0
[  156.010181] sd 2:0:1:116: Attached scsi generic sg48 type 0
[  156.010489] sd 2:0:1:117: Attached scsi generic sg49 type 0
[  156.010782] sd 2:0:1:118: Attached scsi generic sg50 type 0
[  156.011100] sd 2:0:1:119: Attached scsi generic sg51 type 0
[  156.011406] ses 3:0:0:0: Attached scsi generic sg52 type 13
[  156.011636] ses 3:0:1:0: Attached scsi generic sg53 type 13
[  156.011878] ses 4:0:0:0: Attached scsi generic sg54 type 13
[  156.012116] ses 4:0:1:0: Attached scsi generic sg55 type 13
[  156.012431] ses 5:0:0:0: Attached scsi generic sg56 type 13
[  156.012726] ses 5:0:1:0: Attached scsi generic sg57 type 13
[  156.013024] ses 6:0:0:0: Attached scsi generic sg58 type 13
[  156.013283] ses 6:0:1:0: Attached scsi generic sg59 type 13
[  156.013551] ses 7:0:0:0: Attached scsi generic sg60 type 13
[  156.013948] ses 7:0:1:0: Attached scsi generic sg61 type 13
[  156.014434] ses 8:0:0:0: Attached scsi generic sg62 type 13
[  156.014897] ses 8:0:1:0: Attached scsi generic sg63 type 13
[  156.015410] ses 9:0:0:0: Attached scsi generic sg64 type 13
[  156.015842] ses 9:0:1:0: Attached scsi generic sg65 type 13
[  156.016264] ses 10:0:0:0: Attached scsi generic sg66 type 13
[  156.016678] ses 10:0:1:0: Attached scsi generic sg67 type 13
[  156.017191] ses 11:0:0:0: Attached scsi generic sg68 type 13
[  156.017575] ses 11:0:1:0: Attached scsi generic sg69 type 13
[  156.018162] ses 12:0:0:0: Attached scsi generic sg70 type 13
[  156.018473] ses 12:0:1:0: Attached scsi generic sg71 type 13
[  156.018714] ses 13:0:0:0: Attached scsi generic sg72 type 13
[  156.018957] ses 13:0:1:0: Attached scsi generic sg73 type 13
[  156.019201] ses 14:0:0:0: Attached scsi generic sg74 type 13
[  156.019525] ses 14:0:1:0: Attached scsi generic sg75 type 13
[  156.019883] ses 15:0:0:0: Attached scsi generic sg76 type 13
[  156.020180] ses 15:0:1:0: Attached scsi generic sg77 type 13
[  156.032098] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.0.1-k
[  156.032099] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[  156.498481] iTCO_vendor_support: vendor-support=0
[  156.564228] ehci-pci 0000:20:1d.0: EHCI Host Controller
[  156.570093] ehci-pci 0000:20:1d.0: new USB bus registered, assigned bus number 3
[  156.578271] ehci-pci 0000:20:1d.0: debug port 2
[  156.587196] ehci-pci 0000:20:1d.0: cache line size of 64 is not supported
[  156.587236] ehci-pci 0000:20:1d.0: irq 327, io mem 0x98600000
[  156.602353] ehci-pci 0000:20:1d.0: USB 2.0 started, EHCI 1.00
[  156.608955] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[  156.616437] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  156.624403] usb usb3: Product: EHCI Host Controller
[  156.629798] usb usb3: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  156.638620] usb usb3: SerialNumber: 0000:20:1d.0
[  156.663193] ixgbe 0000:01:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.672620] ixgbe 0000:01:00.0: PCI Express bandwidth of 32GT/s available
[  156.680095] ixgbe 0000:01:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.688285] ixgbe 0000:01:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  156.695087] ixgbe 0000:01:00.0: 38:ea:a7:91:1b:74
[  156.794128] hub 3-0:1.0: USB hub found
[  156.798353] hub 3-0:1.0: 2 ports detected
[  156.914554] usb 2-1: new high-speed USB device number 2 using ehci-pci
[  156.919578] ehci-pci 0000:40:1d.0: EHCI Host Controller
[  156.919611] ehci-pci 0000:40:1d.0: new USB bus registered, assigned bus number 4
[  156.919644] ehci-pci 0000:40:1d.0: debug port 2
[  156.923590] ehci-pci 0000:40:1d.0: cache line size of 64 is not supported
[  156.923643] ehci-pci 0000:40:1d.0: irq 392, io mem 0xa0600000
[  156.934457] ehci-pci 0000:40:1d.0: USB 2.0 started, EHCI 1.00
[  156.934724] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[  156.934725] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  156.934727] usb usb4: Product: EHCI Host Controller
[  156.934729] usb usb4: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  156.934730] usb usb4: SerialNumber: 0000:40:1d.0
[  156.940718] hub 4-0:1.0: USB hub found
[  156.940735] hub 4-0:1.0: 2 ports detected
[  156.946819] ehci-pci 0000:60:1d.0: EHCI Host Controller
[  156.946851] ehci-pci 0000:60:1d.0: new USB bus registered, assigned bus number 5
[  156.946878] ehci-pci 0000:60:1d.0: debug port 2
[  156.950837] ehci-pci 0000:60:1d.0: cache line size of 64 is not supported
[  156.950882] ehci-pci 0000:60:1d.0: irq 393, io mem 0xa8600000
[  156.953912] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[  156.954614] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[  156.956621] input: PC Speaker as /devices/platform/pcspkr/input/input1
[  156.962587] ehci-pci 0000:60:1d.0: USB 2.0 started, EHCI 1.00
[  156.962881] usb usb5: New USB device found, idVendor=1d6b, idProduct=0002
[  156.962883] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  156.962885] usb usb5: Product: EHCI Host Controller
[  156.962886] usb usb5: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  156.962887] usb usb5: SerialNumber: 0000:60:1d.0
[  156.964834] hub 5-0:1.0: USB hub found
[  156.964853] hub 5-0:1.0: 2 ports detected
[  156.968617] ehci-pci 0000:84:1d.0: EHCI Host Controller
[  156.968644] ehci-pci 0000:84:1d.0: new USB bus registered, assigned bus number 6
[  156.968675] ehci-pci 0000:84:1d.0: debug port 2
[  156.972605] ehci-pci 0000:84:1d.0: cache line size of 64 is not supported
[  156.972654] ehci-pci 0000:84:1d.0: irq 394, io mem 0xb0600000
[  156.982544] ehci-pci 0000:84:1d.0: USB 2.0 started, EHCI 1.00
[  156.982683] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
[  156.982686] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  156.982688] usb usb6: Product: EHCI Host Controller
[  156.982690] usb usb6: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  156.982692] usb usb6: SerialNumber: 0000:84:1d.0
[  156.983183] hub 6-0:1.0: USB hub found
[  156.983204] hub 6-0:1.0: 2 ports detected
[  156.986473] ehci-pci 0000:a0:1d.0: EHCI Host Controller
[  156.986597] ehci-pci 0000:a0:1d.0: new USB bus registered, assigned bus number 7
[  156.986624] ehci-pci 0000:a0:1d.0: debug port 2
[  156.990561] ehci-pci 0000:a0:1d.0: cache line size of 64 is not supported
[  156.990608] ehci-pci 0000:a0:1d.0: irq 395, io mem 0xb8600000
[  157.002571] ehci-pci 0000:a0:1d.0: USB 2.0 started, EHCI 1.00
[  157.002688] usb usb7: New USB device found, idVendor=1d6b, idProduct=0002
[  157.002689] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  157.002691] usb usb7: Product: EHCI Host Controller
[  157.002692] usb usb7: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  157.002693] usb usb7: SerialNumber: 0000:a0:1d.0
[  157.003070] hub 7-0:1.0: USB hub found
[  157.003086] hub 7-0:1.0: 2 ports detected
[  157.006441] ehci-pci 0000:c0:1d.0: EHCI Host Controller
[  157.006468] ehci-pci 0000:c0:1d.0: new USB bus registered, assigned bus number 8
[  157.006567] ehci-pci 0000:c0:1d.0: debug port 2
[  157.010512] ehci-pci 0000:c0:1d.0: cache line size of 64 is not supported
[  157.010627] ehci-pci 0000:c0:1d.0: irq 396, io mem 0xc0600000
[  157.022552] ehci-pci 0000:c0:1d.0: USB 2.0 started, EHCI 1.00
[  157.022700] usb usb8: New USB device found, idVendor=1d6b, idProduct=0002
[  157.022702] usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  157.022704] usb usb8: Product: EHCI Host Controller
[  157.022706] usb usb8: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  157.022707] usb usb8: SerialNumber: 0000:c0:1d.0
[  157.023203] hub 8-0:1.0: USB hub found
[  157.023224] hub 8-0:1.0: 2 ports detected
[  157.026804] ehci-pci 0000:e0:1d.0: EHCI Host Controller
[  157.026832] ehci-pci 0000:e0:1d.0: new USB bus registered, assigned bus number 9
[  157.026863] ehci-pci 0000:e0:1d.0: debug port 2
[  157.030818] ehci-pci 0000:e0:1d.0: cache line size of 64 is not supported
[  157.030859] ehci-pci 0000:e0:1d.0: irq 397, io mem 0xc8600000
[  157.042595] ehci-pci 0000:e0:1d.0: USB 2.0 started, EHCI 1.00
[  157.042747] usb usb9: New USB device found, idVendor=1d6b, idProduct=0002
[  157.042749] usb usb9: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  157.042751] usb usb9: Product: EHCI Host Controller
[  157.042753] usb usb9: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  157.042755] usb usb9: SerialNumber: 0000:e0:1d.0
[  157.043305] hub 9-0:1.0: USB hub found
[  157.043324] hub 9-0:1.0: 2 ports detected
[  157.222840] usb 3-1: new high-speed USB device number 2 using ehci-pci
[  157.254918] usb 4-1: new high-speed USB device number 2 using ehci-pci
[  157.274991] usb 5-1: new high-speed USB device number 2 using ehci-pci
[  157.294926] usb 6-1: new high-speed USB device number 2 using ehci-pci
[  157.318982] usb 7-1: new high-speed USB device number 2 using ehci-pci
[  157.335045] usb 8-1: new high-speed USB device number 2 using ehci-pci
[  157.355029] usb 9-1: new high-speed USB device number 2 using ehci-pci
[  157.407350] usb 3-1: New USB device found, idVendor=8087, idProduct=0024
[  157.407355] usb 3-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.429068] hub 3-1:1.0: USB hub found
[  157.436199] hub 3-1:1.0: 8 ports detected
[  157.450885] usb 4-1: New USB device found, idVendor=8087, idProduct=0024
[  157.450889] usb 4-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.458816] usb 5-1: New USB device found, idVendor=8087, idProduct=0024
[  157.458820] usb 5-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.459008] hub 4-1:1.0: USB hub found
[  157.463010] hub 4-1:1.0: 8 ports detected
[  157.463133] hub 5-1:1.0: USB hub found
[  157.467478] hub 5-1:1.0: 8 ports detected
[  157.467485] usb 6-1: New USB device found, idVendor=8087, idProduct=0024
[  157.467488] usb 6-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.475067] hub 6-1:1.0: USB hub found
[  157.482834] hub 6-1:1.0: 8 ports detected
[  157.498268] usb 8-1: New USB device found, idVendor=8087, idProduct=0024
[  157.498271] usb 8-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.502494] usb 7-1: New USB device found, idVendor=8087, idProduct=0024
[  157.502501] usb 7-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.502665] hub 8-1:1.0: USB hub found
[  157.506984] hub 8-1:1.0: 8 ports detected
[  157.507034] hub 7-1:1.0: USB hub found
[  157.511212] hub 7-1:1.0: 8 ports detected
[  157.535288] usb 9-1: New USB device found, idVendor=8087, idProduct=0024
[  157.535292] usb 9-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.539801] hub 9-1:1.0: USB hub found
[  157.547238] hub 9-1:1.0: 8 ports detected
[  157.684055] ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
[  157.747997] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[  157.755404] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.763851] hub 2-1:1.0: USB hub found
[  157.783714] usb 3-1.3: new high-speed USB device number 3 using ehci-pci
[  157.797941] ixgbe 0000:01:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.807287] usb 5-1.3: new high-speed USB device number 3 using ehci-pci
[  157.807392] ixgbe 0000:01:00.1: PCI Express bandwidth of 32GT/s available
[  157.807394] ixgbe 0000:01:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.807759] ixgbe 0000:01:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  157.807760] ixgbe 0000:01:00.1: 38:ea:a7:91:1b:75
[  157.807822] usb 4-1.3: new high-speed USB device number 3 using ehci-pci
[  157.808176] hub 2-1:1.0: 8 ports detected
[  157.817003] usb 6-1.3: new high-speed USB device number 3 using ehci-pci
[  157.843718] usb 7-1.3: new high-speed USB device number 3 using ehci-pci
[  157.847891] usb 8-1.3: new high-speed USB device number 3 using ehci-pci
[  157.847895] ixgbe 0000:01:00.1: Intel(R) 10 Gigabit Network Connection
[  157.879858] usb 9-1.3: new high-speed USB device number 3 using ehci-pci
[  157.888160] usb 3-1.3: device descriptor read/64, error -71
[  157.901006] usb 4-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.908240] usb 6-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.908243] usb 6-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.908884] hub 6-1.3:1.0: USB hub found
[  157.909056] hub 6-1.3:1.0: 2 ports detected
[  157.933136] usb 4-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.940469] usb 7-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.940471] usb 7-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.940980] hub 7-1.3:1.0: USB hub found
[  157.941138] hub 7-1.3:1.0: 2 ports detected
[  157.944199] usb 8-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.944201] usb 8-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.944630] hub 8-1.3:1.0: USB hub found
[  157.944839] hub 8-1.3:1.0: 2 ports detected
[  157.947175] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.947309] ixgbe 0000:03:00.0: PCI Express bandwidth of 32GT/s available
[  157.947311] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.947648] ixgbe 0000:03:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  157.947650] ixgbe 0000:03:00.0: 38:ea:a7:8c:db:b8
[  157.976669] usb 9-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.976670] usb 9-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.977180] hub 9-1.3:1.0: USB hub found
[  157.977485] hub 9-1.3:1.0: 2 ports detected
[  157.987785] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
[  157.988342] usb 5-1.3: New USB device found, idVendor=0424, idProduct=2660
[  157.988344] usb 5-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  157.988830] hub 5-1.3:1.0: USB hub found
[  157.989009] hub 5-1.3:1.0: 2 ports detected
[  158.083566] hub 4-1.3:1.0: USB hub found
[  158.086087] usb 3-1.3: device descriptor read/64, error -71
[  158.094147] hub 4-1.3:1.0: 2 ports detected
[  158.107158] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.116633] ixgbe 0000:03:00.1: PCI Express bandwidth of 32GT/s available
[  158.124117] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.132328] ixgbe 0000:03:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  158.139140] ixgbe 0000:03:00.1: 38:ea:a7:8c:db:b9
[  158.144973] usb 2-1.3: new high-speed USB device number 3 using ehci-pci
[  158.188043] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
[  158.244644] usb 2-1.3: New USB device found, idVendor=0424, idProduct=2660
[  158.252218] usb 2-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  158.261478] hub 2-1.3:1.0: USB hub found
[  158.265815] usb 3-1.3: new high-speed USB device number 4 using ehci-pci
[  158.265947] hub 2-1.3:1.0: 2 ports detected
[  158.296503] ixgbe 0000:21:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.305947] ixgbe 0000:21:00.0: PCI Express bandwidth of 32GT/s available
[  158.313422] ixgbe 0000:21:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.321577] ixgbe 0000:21:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  158.328383] ixgbe 0000:21:00.0: 38:ea:a7:91:65:ac
[  158.364299] usb 3-1.3: device descriptor read/64, error -71
[  158.372192] ixgbe 0000:21:00.0: Intel(R) 10 Gigabit Network Connection
[  158.482152] ixgbe 0000:21:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.491584] ixgbe 0000:21:00.1: PCI Express bandwidth of 32GT/s available
[  158.499061] ixgbe 0000:21:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.507252] ixgbe 0000:21:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  158.514059] ixgbe 0000:21:00.1: 38:ea:a7:91:65:ad
[  158.556550] usb 3-1.3: device descriptor read/64, error -71
[  158.560594] ixgbe 0000:21:00.1: Intel(R) 10 Gigabit Network Connection
[  158.663915] ixgbe 0000:23:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.673341] ixgbe 0000:23:00.0: PCI Express bandwidth of 32GT/s available
[  158.680816] ixgbe 0000:23:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.688995] ixgbe 0000:23:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  158.695801] ixgbe 0000:23:00.0: 38:ea:a7:8c:db:a8
[  158.744761] ixgbe 0000:23:00.0: Intel(R) 10 Gigabit Network Connection
[  158.744933] usb 3-1.3: new high-speed USB device number 5 using ehci-pci
[  158.872676] ixgbe 0000:23:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.882090] ixgbe 0000:23:00.1: PCI Express bandwidth of 32GT/s available
[  158.889567] ixgbe 0000:23:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.897723] ixgbe 0000:23:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  158.904529] ixgbe 0000:23:00.1: 38:ea:a7:8c:db:a9
[  158.949056] ixgbe 0000:23:00.1: Intel(R) 10 Gigabit Network Connection
[  159.060628] ixgbe 0000:41:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.070059] ixgbe 0000:41:00.0: PCI Express bandwidth of 32GT/s available
[  159.077542] ixgbe 0000:41:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.085746] ixgbe 0000:41:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  159.092550] ixgbe 0000:41:00.0: 38:ea:a7:91:22:e4
[  159.141290] ixgbe 0000:41:00.0: Intel(R) 10 Gigabit Network Connection
[  159.165329] usb 3-1.3: device not accepting address 5, error -71
[  159.241765] usb 3-1.3: new high-speed USB device number 6 using ehci-pci
[  159.251019] Btrfs loaded
[  159.251303] ixgbe 0000:41:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.251439] ixgbe 0000:41:00.1: PCI Express bandwidth of 32GT/s available
[  159.251441] ixgbe 0000:41:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.251779] ixgbe 0000:41:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  159.251782] ixgbe 0000:41:00.1: 38:ea:a7:91:22:e5
[  159.293607] ixgbe 0000:41:00.1: Intel(R) 10 Gigabit Network Connection
[  159.400678] ixgbe 0000:43:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.410094] ixgbe 0000:43:00.0: PCI Express bandwidth of 32GT/s available
[  159.417589] ixgbe 0000:43:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.425745] ixgbe 0000:43:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  159.432548] ixgbe 0000:43:00.0: 38:ea:a7:8b:21:d8
[  159.481694] ixgbe 0000:43:00.0: Intel(R) 10 Gigabit Network Connection
[  159.606727] ixgbe 0000:43:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.616146] ixgbe 0000:43:00.1: PCI Express bandwidth of 32GT/s available
[  159.623623] ixgbe 0000:43:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.631778] ixgbe 0000:43:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  159.638589] ixgbe 0000:43:00.1: 38:ea:a7:8b:21:d9
[  159.661842] usb 3-1.3: device not accepting address 6, error -71
[  159.664470] ixgbe 0000:43:00.1: Intel(R) 10 Gigabit Network Connection
[  159.675816] usb 3-1-port3: unable to enumerate USB device
[  159.767230] ixgbe 0000:61:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.776698] ixgbe 0000:61:00.0: PCI Express bandwidth of 32GT/s available
[  159.784173] ixgbe 0000:61:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.792363] ixgbe 0000:61:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  159.799172] ixgbe 0000:61:00.0: 38:ea:a7:91:65:40
[  159.846266] ixgbe 0000:61:00.0: Intel(R) 10 Gigabit Network Connection
[  159.958346] ixgbe 0000:61:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.967773] ixgbe 0000:61:00.1: PCI Express bandwidth of 32GT/s available
[  159.975244] ixgbe 0000:61:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.983441] ixgbe 0000:61:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  159.990281] ixgbe 0000:61:00.1: 38:ea:a7:91:65:41
[  160.038219] ixgbe 0000:61:00.1: Intel(R) 10 Gigabit Network Connection
[  160.145513] ixgbe 0000:63:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  160.154928] ixgbe 0000:63:00.0: PCI Express bandwidth of 32GT/s available
[  160.162403] ixgbe 0000:63:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  160.170564] ixgbe 0000:63:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  160.177378] ixgbe 0000:63:00.0: 38:ea:a7:8c:df:c4
[  160.219583] ixgbe 0000:63:00.0: Intel(R) 10 Gigabit Network Connection
[  160.386080] ixgbe 0000:63:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  160.395494] ixgbe 0000:63:00.1: PCI Express bandwidth of 32GT/s available
[  160.402973] ixgbe 0000:63:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  160.411145] ixgbe 0000:63:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  160.417949] ixgbe 0000:63:00.1: 38:ea:a7:8c:df:c5
[  160.467173] ixgbe 0000:63:00.1: Intel(R) 10 Gigabit Network Connection
[  160.580818] ixgbe 0000:85:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  160.590252] ixgbe 0000:85:00.0: PCI Express bandwidth of 32GT/s available
[  160.597735] ixgbe 0000:85:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  160.605888] ixgbe 0000:85:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[  160.612694] ixgbe 0000:85:00.0: 38:ea:a7:31:7a:30
[  160.659150] ixgbe 0000:85:00.0: Intel(R) 10 Gigabit Network Connection
[  160.768189] ixgbe 0000:85:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  160.777607] ixgbe 0000:85:00.1: PCI Express bandwidth of 32GT/s available
[  160.785086] ixgbe 0000:85:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  160.793245] ixgbe 0000:85:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[  160.800050] ixgbe 0000:85:00.1: 38:ea:a7:31:7a:31
[  160.847241] ixgbe 0000:85:00.1: Intel(R) 10 Gigabit Network Connection
[  160.954925] ixgbe 0000:87:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  160.964342] ixgbe 0000:87:00.0: PCI Express bandwidth of 32GT/s available
[  160.971818] ixgbe 0000:87:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  160.979976] ixgbe 0000:87:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  160.986781] ixgbe 0000:87:00.0: 38:ea:a7:8b:22:00
[  161.027922] ixgbe 0000:87:00.0: Intel(R) 10 Gigabit Network Connection
[  161.157710] ixgbe 0000:87:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  161.167136] ixgbe 0000:87:00.1: PCI Express bandwidth of 32GT/s available
[  161.174611] ixgbe 0000:87:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  161.182769] ixgbe 0000:87:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  161.189577] ixgbe 0000:87:00.1: 38:ea:a7:8b:22:01
[  161.237245] ixgbe 0000:87:00.1: Intel(R) 10 Gigabit Network Connection
[  161.349983] ixgbe 0000:a1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  161.359418] ixgbe 0000:a1:00.0: PCI Express bandwidth of 32GT/s available
[  161.366896] ixgbe 0000:a1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  161.375054] ixgbe 0000:a1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  161.381860] ixgbe 0000:a1:00.0: 38:ea:a7:91:65:d8
[  161.428192] ixgbe 0000:a1:00.0: Intel(R) 10 Gigabit Network Connection
[  161.540899] ixgbe 0000:a1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  161.550329] ixgbe 0000:a1:00.1: PCI Express bandwidth of 32GT/s available
[  161.557804] ixgbe 0000:a1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  161.565958] ixgbe 0000:a1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  161.572763] ixgbe 0000:a1:00.1: 38:ea:a7:91:65:d9
[  161.620570] ixgbe 0000:a1:00.1: Intel(R) 10 Gigabit Network Connection
[  161.735155] ixgbe 0000:a3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  161.744726] ixgbe 0000:a3:00.0: PCI Express bandwidth of 32GT/s available
[  161.752200] ixgbe 0000:a3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  161.760432] ixgbe 0000:a3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  161.767238] ixgbe 0000:a3:00.0: 38:ea:a7:8b:30:fc
[  161.816731] ixgbe 0000:a3:00.0: Intel(R) 10 Gigabit Network Connection
[  161.947917] ixgbe 0000:a3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  161.957340] ixgbe 0000:a3:00.1: PCI Express bandwidth of 32GT/s available
[  161.964814] ixgbe 0000:a3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  161.973004] ixgbe 0000:a3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  161.979806] ixgbe 0000:a3:00.1: 38:ea:a7:8b:30:fd
[  162.028887] ixgbe 0000:a3:00.1: Intel(R) 10 Gigabit Network Connection
[  162.143128] ixgbe 0000:c1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  162.152575] ixgbe 0000:c1:00.0: PCI Express bandwidth of 32GT/s available
[  162.160058] ixgbe 0000:c1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  162.168255] ixgbe 0000:c1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  162.175060] ixgbe 0000:c1:00.0: 38:ea:a7:91:1a:54
[  162.221430] ixgbe 0000:c1:00.0: Intel(R) 10 Gigabit Network Connection
[  162.335858] ixgbe 0000:c1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  162.345301] ixgbe 0000:c1:00.1: PCI Express bandwidth of 32GT/s available
[  162.352789] ixgbe 0000:c1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  162.360943] ixgbe 0000:c1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  162.367750] ixgbe 0000:c1:00.1: 38:ea:a7:91:1a:55
[  162.409332] ixgbe 0000:c1:00.1: Intel(R) 10 Gigabit Network Connection
[  162.518951] ixgbe 0000:c3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  162.528379] ixgbe 0000:c3:00.0: PCI Express bandwidth of 32GT/s available
[  162.535854] ixgbe 0000:c3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  162.544050] ixgbe 0000:c3:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  162.550857] ixgbe 0000:c3:00.0: 38:ea:a7:8c:e6:64
[  162.595297] ixgbe 0000:c3:00.0: Intel(R) 10 Gigabit Network Connection
[  162.729931] ixgbe 0000:c3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  162.739385] ixgbe 0000:c3:00.1: PCI Express bandwidth of 32GT/s available
[  162.746861] ixgbe 0000:c3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  162.755020] ixgbe 0000:c3:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  162.761825] ixgbe 0000:c3:00.1: 38:ea:a7:8c:e6:65
[  162.809850] ixgbe 0000:c3:00.1: Intel(R) 10 Gigabit Network Connection
[  162.918834] ixgbe 0000:e1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  162.928278] ixgbe 0000:e1:00.0: PCI Express bandwidth of 32GT/s available
[  162.935754] ixgbe 0000:e1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  162.943910] ixgbe 0000:e1:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[  162.950715] ixgbe 0000:e1:00.0: 38:ea:a7:31:7e:f8
[  162.995376] ixgbe 0000:e1:00.0: Intel(R) 10 Gigabit Network Connection
[  163.107176] ixgbe 0000:e1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  163.116600] ixgbe 0000:e1:00.1: PCI Express bandwidth of 32GT/s available
[  163.124073] ixgbe 0000:e1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  163.132262] ixgbe 0000:e1:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[  163.139065] ixgbe 0000:e1:00.1: 38:ea:a7:31:7e:f9
[  163.186018] ixgbe 0000:e1:00.1: Intel(R) 10 Gigabit Network Connection
[  163.298487] ixgbe 0000:e3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  163.307902] ixgbe 0000:e3:00.0: PCI Express bandwidth of 32GT/s available
[  163.315385] ixgbe 0000:e3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  163.323574] ixgbe 0000:e3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  163.330376] ixgbe 0000:e3:00.0: 38:ea:a7:8b:27:f4
[  163.378423] ixgbe 0000:e3:00.0: Intel(R) 10 Gigabit Network Connection
[  163.507747] ixgbe 0000:e3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  163.517215] ixgbe 0000:e3:00.1: PCI Express bandwidth of 32GT/s available
[  163.524691] ixgbe 0000:e3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  163.532876] ixgbe 0000:e3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  163.539683] ixgbe 0000:e3:00.1: 38:ea:a7:8b:27:f5
[  163.587065] ixgbe 0000:e3:00.1: Intel(R) 10 Gigabit Network Connection
[  169.831072] BTRFS: device fsid 7a5749b3-f733-4f1a-b0f7-1b89677ced55 devid 1 transid 1217 /dev/dm-9
[  169.851366] BTRFS: device fsid 078e55c8-0f7f-4dfd-bab3-0e10cc542cac devid 1 transid 15960 /dev/dm-19
[  169.977097] Adding 8385532k swap on /dev/mapper/3600c0ff0001a841e1d12f65401000000_part2.  Priority:-1 extents:1 across:8385532k 
[  170.784366] multipathd (44286): /proc/44286/oom_adj is deprecated, please use /proc/44286/oom_score_adj instead.
[  172.709068] loop: module loaded
[  175.069741] fuse init (API version 7.23)
[  177.320788] audit: type=1400 audit(1429058263.645:2): apparmor="STATUS" operation="profile_load" name="/bin/ping" pid=45393 comm="apparmor_parser"
[  177.375460] audit: type=1400 audit(1429058263.697:3): apparmor="STATUS" operation="profile_load" name="/sbin/klogd" pid=45398 comm="apparmor_parser"
[  177.450204] audit: type=1400 audit(1429058263.773:4): apparmor="STATUS" operation="profile_load" name="/sbin/syslog-ng" pid=45402 comm="apparmor_parser"
[  177.531433] audit: type=1400 audit(1429058263.853:5): apparmor="STATUS" operation="profile_load" name="/sbin/syslogd" pid=45406 comm="apparmor_parser"
[  177.577024] audit: type=1400 audit(1429058263.901:6): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-explicit-grant-helper" pid=45411 comm="apparmor_parser"
[  177.656592] audit: type=1400 audit(1429058263.981:7): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-grant-helper" pid=45415 comm="apparmor_parser"
[  177.723004] audit: type=1400 audit(1429058264.045:8): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-grant-helper-pam" pid=45419 comm="apparmor_parser"
[  177.792836] audit: type=1400 audit(1429058264.117:9): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-read-auth-helper" pid=45423 comm="apparmor_parser"
[  177.842896] audit: type=1400 audit(1429058264.165:10): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-resolve-exe-helper" pid=45427 comm="apparmor_parser"
[  177.894794] audit: type=1400 audit(1429058264.217:11): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-revoke-helper" pid=45431 comm="apparmor_parser"
[  189.442620] NET: Registered protocol family 17
[  189.726776] ixgbe 0000:01:00.0: registered PHC device on eth0
[  189.728511] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: None
[  204.050699] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[  204.050711] EDD information not available.
[  209.978852] mgag200 0000:07:00.1: Invalid ROM contents

--------------020105070300010700010500--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
