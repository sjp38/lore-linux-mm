Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD876B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 14:21:04 -0400 (EDT)
Received: by pdea3 with SMTP id a3so100520354pde.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:21:04 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id co1si13232461pad.63.2015.04.16.11.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 11:21:03 -0700 (PDT)
Message-ID: <552FFD83.5030901@hp.com>
Date: Thu, 16 Apr 2015 14:20:51 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
References: <1428920226-18147-1-git-send-email-mgorman@suse.de> <552E6486.6070705@hp.com> <20150415133826.GF14842@suse.de>
In-Reply-To: <20150415133826.GF14842@suse.de>
Content-Type: multipart/mixed;
 boundary="------------000903060906050605050501"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------000903060906050605050501
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

On 04/15/2015 09:38 AM, Mel Gorman wrote:
>> However, there were 2 bootup problems in the dmesg log that needed
>> to be addressed.
>> 1. There were 2 vmalloc allocation failures:
>> [    2.284686] vmalloc: allocation failure, allocated 16578404352 of
>> 17179873280 bytes
>> [   10.399938] vmalloc: allocation failure, allocated 7970922496 of
>> 8589938688 bytes
>>
>> 2. There were 2 soft lockup warnings:
>> [   57.319453] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s!
>> [swapper/0:1]
>> [   85.409263] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s!
>> [swapper/0:1]
>>
>> Once those problems are fixed, the patch should be in a pretty good
>> shape. I have attached the dmesg log for your reference.
>>
> The obvious conclusion is that initialising 1G per node is not enough for
> really large machines. Can you try this on top? It's untested but should
> work. The low value was chosen because it happened to work and I wanted
> to get test coverage on common hardware but broke is broke.
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f2c96d02662f..6b3bec304e35 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -276,9 +276,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>   	if (pgdat->first_deferred_pfn != ULONG_MAX)
>   		return false;
>
> -	/* Initialise at least 1G per zone */
> +	/* Initialise at least 32G per node */
>   	(*nr_initialised)++;
> -	if (*nr_initialised>  (1UL<<  (30 - PAGE_SHIFT))&&
> +	if (*nr_initialised>  (32UL<<  (30 - PAGE_SHIFT))&&
>   	(pfn&  (PAGES_PER_SECTION - 1)) == 0) {
>   		pgdat->first_deferred_pfn = pfn;
>   		return false;
>
>
I applied the patch and the boot time was 299s instead of 298s, so 
practically the same. The two issues that I discussed about previously 
were both gone. Attached is the new dmesg log for your reference.

Cheers,
Longman

--------------000903060906050605050501
Content-Type: text/plain;
 name="dmesg-4.0-Mel-mm-patch-2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg-4.0-Mel-mm-patch-2.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp (root@hawk041os1) (gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux) ) #2 SMP Thu Apr 16 09:56:50 MDT 2015
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
[    0.000000] efi: mem07: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x000000005cc00000-0x000000006b309000) (231MB)
[    0.000000] efi: mem08: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000006b309000-0x000000006d00c000) (29MB)
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
[    0.000000] efi: mem34: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000773ff000-0x00000000777de000) (3MB)
[    0.000000] efi: mem35: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000777de000-0x00000000777ff000) (0MB)
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
[    0.000000] RAMDISK: [mem 0x6b309000-0x6d00bfff]
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
[    0.000000] Memory: 537952112K/12884782640K available (5240K kernel code, 1020K rwdata, 2672K rodata, 1632K init, 1516K bss, 177258352K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Additional per-CPU info printed with stalls.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=480.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=480
[    0.000000] NR_IRQS:524544 nr_irqs:13648 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2793.646 MHz processor
[    0.000542] Calibrating delay loop (skipped), value calculated using timer frequency.. 5587.29 BogoMIPS (lpj=11174584)
[    0.012344] pid_max: default: 491520 minimum: 3840
[    0.018535] ACPI: Core revision 20150204
[    0.195962] ACPI: All ACPI Tables successfully acquired
[    0.209998] Security Framework initialized
[    0.214567] AppArmor: AppArmor initialized
[    2.332401] Dentry cache hash table entries: 2147483648 (order: 22, 17179869184 bytes)
[   10.331850] Inode-cache hash table entries: 1073741824 (order: 21, 8589934592 bytes)
[   13.857918] Mount-cache hash table entries: 33554432 (order: 16, 268435456 bytes)
[   13.895913] Mountpoint-cache hash table entries: 33554432 (order: 16, 268435456 bytes)
[   14.133018] Initializing cgroup subsys blkio
[   14.137729] Initializing cgroup subsys devices
[   14.142647] Initializing cgroup subsys freezer
[   14.147584] Initializing cgroup subsys net_cls
[   14.152516] Initializing cgroup subsys perf_event
[   14.158600] CPU: Physical Processor ID: 0
[   14.163021] CPU: Processor Core ID: 0
[   14.167935] mce: CPU supports 32 MCE banks
[   14.172535] CPU0: Thermal monitoring enabled (TM1)
[   14.177855] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[   14.183895] Last level dTLB entries: 4KB 512, 2MB 0, 4MB 0, 1GB 4
[   14.191506] Freeing SMP alternatives memory: 20K (ffffffff81c99000 - ffffffff81c9e000)
[   14.206303] dmar: Host address width 44
[   14.210531] dmar: DRHD base: 0x00000093ff8000 flags: 0x0
[   14.216435] dmar: IOMMU 0: reg_base_addr 93ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.225346] dmar: DRHD base: 0x00000097ff8000 flags: 0x0
[   14.231254] dmar: IOMMU 1: reg_base_addr 97ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.240163] dmar: DRHD base: 0x0000009bff8000 flags: 0x0
[   14.246072] dmar: IOMMU 2: reg_base_addr 9bff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.254982] dmar: DRHD base: 0x0000009fff8000 flags: 0x0
[   14.260896] dmar: IOMMU 3: reg_base_addr 9fff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.269805] dmar: DRHD base: 0x000000a3ff8000 flags: 0x0
[   14.275708] dmar: IOMMU 4: reg_base_addr a3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.284621] dmar: DRHD base: 0x000000a7ff8000 flags: 0x0
[   14.290524] dmar: IOMMU 5: reg_base_addr a7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.299434] dmar: DRHD base: 0x000000abff8000 flags: 0x0
[   14.305310] dmar: IOMMU 6: reg_base_addr abff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.314219] dmar: DRHD base: 0x000000afff8000 flags: 0x0
[   14.320116] dmar: IOMMU 7: reg_base_addr afff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.329028] dmar: DRHD base: 0x000000b3ff8000 flags: 0x0
[   14.334935] dmar: IOMMU 8: reg_base_addr b3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.343843] dmar: DRHD base: 0x000000b7ff8000 flags: 0x0
[   14.349751] dmar: IOMMU 9: reg_base_addr b7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.358659] dmar: DRHD base: 0x000000bbff8000 flags: 0x0
[   14.364560] dmar: IOMMU 10: reg_base_addr bbff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.373569] dmar: DRHD base: 0x000000bfff8000 flags: 0x0
[   14.379474] dmar: IOMMU 11: reg_base_addr bfff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.388480] dmar: DRHD base: 0x000000c3ff8000 flags: 0x0
[   14.394359] dmar: IOMMU 12: reg_base_addr c3ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.403369] dmar: DRHD base: 0x000000c7ff8000 flags: 0x0
[   14.409256] dmar: IOMMU 13: reg_base_addr c7ff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.418269] dmar: DRHD base: 0x000000cbff8000 flags: 0x0
[   14.424176] dmar: IOMMU 14: reg_base_addr cbff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.433183] dmar: DRHD base: 0x000000cfff8000 flags: 0x0
[   14.439083] dmar: IOMMU 15: reg_base_addr cfff8000 ver 1:0 cap d2078c106f0466 ecap f020de
[   14.448093] dmar: RMRR base: 0x00000079906000 end: 0x00000079908fff
[   14.454998] dmar: RMRR base: 0x00000079903000 end: 0x00000079905fff
[   14.461897] dmar: RMRR base: 0x00000079900000 end: 0x00000079902fff
[   14.468797] dmar: RMRR base: 0x0000006f3fc000 end: 0x0000006f3fefff
[   14.475714] dmar: RMRR base: 0x0000006d015000 end: 0x0000006d017fff
[   14.482614] dmar: RMRR base: 0x0000006d012000 end: 0x0000006d014fff
[   14.489528] dmar: RMRR base: 0x0000006d00f000 end: 0x0000006d011fff
[   14.496428] dmar: RMRR base: 0x0000006d00c000 end: 0x0000006d00efff
[   14.503332] dmar: ATSR flags: 0x0
[   14.506983] dmar: ATSR flags: 0x0
[   14.510634] dmar: ATSR flags: 0x0
[   14.514285] dmar: ATSR flags: 0x0
[   14.517936] dmar: ATSR flags: 0x0
[   14.521594] dmar: ATSR flags: 0x0
[   14.525241] dmar: ATSR flags: 0x0
[   14.528891] dmar: ATSR flags: 0x0
[   14.532544] dmar: ATSR flags: 0x0
[   14.536196] dmar: ATSR flags: 0x0
[   14.539845] dmar: ATSR flags: 0x0
[   14.543499] dmar: ATSR flags: 0x0
[   14.547148] dmar: ATSR flags: 0x0
[   14.550798] dmar: ATSR flags: 0x0
[   14.554448] dmar: ATSR flags: 0x0
[   14.558097] dmar: ATSR flags: 0x0
[   14.561747] dmar: RHSA base: 0x00000093ff8000 proximity domain: 0x0
[   14.568660] dmar: RHSA base: 0x00000097ff8000 proximity domain: 0x1
[   14.575561] dmar: RHSA base: 0x0000009bff8000 proximity domain: 0x2
[   14.582462] dmar: RHSA base: 0x0000009fff8000 proximity domain: 0x3
[   14.589364] dmar: RHSA base: 0x000000a3ff8000 proximity domain: 0x4
[   14.596268] dmar: RHSA base: 0x000000a7ff8000 proximity domain: 0x5
[   14.603168] dmar: RHSA base: 0x000000abff8000 proximity domain: 0x6
[   14.610067] dmar: RHSA base: 0x000000afff8000 proximity domain: 0x7
[   14.616968] dmar: RHSA base: 0x000000b3ff8000 proximity domain: 0x8
[   14.623874] dmar: RHSA base: 0x000000b7ff8000 proximity domain: 0x9
[   14.630775] dmar: RHSA base: 0x000000bbff8000 proximity domain: 0xa
[   14.637677] dmar: RHSA base: 0x000000bfff8000 proximity domain: 0xb
[   14.644578] dmar: RHSA base: 0x000000c3ff8000 proximity domain: 0xc
[   14.651481] dmar: RHSA base: 0x000000c7ff8000 proximity domain: 0xd
[   14.658381] dmar: RHSA base: 0x000000cbff8000 proximity domain: 0xe
[   14.665283] dmar: RHSA base: 0x000000cfff8000 proximity domain: 0xf
[   14.672213] IOAPIC id 31 under DRHD base  0xcfff8000 IOMMU 15
[   14.678549] IOAPIC id 29 under DRHD base  0xcbff8000 IOMMU 14
[   14.684883] IOAPIC id 30 under DRHD base  0xcbff8000 IOMMU 14
[   14.691215] IOAPIC id 28 under DRHD base  0xc7ff8000 IOMMU 13
[   14.697544] IOAPIC id 26 under DRHD base  0xc3ff8000 IOMMU 12
[   14.703873] IOAPIC id 27 under DRHD base  0xc3ff8000 IOMMU 12
[   14.710202] IOAPIC id 25 under DRHD base  0xbfff8000 IOMMU 11
[   14.716529] IOAPIC id 23 under DRHD base  0xbbff8000 IOMMU 10
[   14.722858] IOAPIC id 24 under DRHD base  0xbbff8000 IOMMU 10
[   14.729188] IOAPIC id 22 under DRHD base  0xb7ff8000 IOMMU 9
[   14.735419] IOAPIC id 20 under DRHD base  0xb3ff8000 IOMMU 8
[   14.741649] IOAPIC id 21 under DRHD base  0xb3ff8000 IOMMU 8
[   14.747880] IOAPIC id 19 under DRHD base  0xafff8000 IOMMU 7
[   14.754115] IOAPIC id 17 under DRHD base  0xabff8000 IOMMU 6
[   14.760348] IOAPIC id 18 under DRHD base  0xabff8000 IOMMU 6
[   14.766581] IOAPIC id 16 under DRHD base  0xa7ff8000 IOMMU 5
[   14.772814] IOAPIC id 14 under DRHD base  0xa3ff8000 IOMMU 4
[   14.779045] IOAPIC id 15 under DRHD base  0xa3ff8000 IOMMU 4
[   14.785278] IOAPIC id 13 under DRHD base  0x9fff8000 IOMMU 3
[   14.791510] IOAPIC id 11 under DRHD base  0x9bff8000 IOMMU 2
[   14.797741] IOAPIC id 12 under DRHD base  0x9bff8000 IOMMU 2
[   14.803972] IOAPIC id 10 under DRHD base  0x97ff8000 IOMMU 1
[   14.810206] IOAPIC id 8 under DRHD base  0x93ff8000 IOMMU 0
[   14.816344] IOAPIC id 9 under DRHD base  0x93ff8000 IOMMU 0
[   14.822479] HPET id 0 under DRHD base 0x93ff8000
[   14.844457] Queued invalidation will be enabled to support x2apic and Intr-remapping.
[   14.853352] Enabled IRQ remapping in x2apic mode
[   14.858458] System requires x2apic physical mode
[   14.873440] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[   14.919795] TSC deadline timer enabled
[   14.919943] smpboot: CPU0: Intel(R) Xeon(R) CPU E7-2890 v2 @ 2.80GHz (fam: 06, model: 3e, stepping: 07)
[   14.931523] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
[   14.942906] ... version:                3
[   14.947318] ... bit width:              48
[   14.951820] ... generic registers:      4
[   14.956232] ... value mask:             0000ffffffffffff
[   14.962074] ... max period:             0000ffffffffffff
[   14.967919] ... fixed-purpose events:   3
[   14.972331] ... event mask:             000000070000000f
[   14.999411] x86: Booting SMP configuration:
[   15.004018] .... node   #0, CPUs:          #1   #2   #3   #4   #5   #6   #7   #8   #9  #10  #11  #12  #13  #14
[   15.240932] .... node   #1, CPUs:    #15  #16  #17  #18  #19  #20  #21  #22  #23  #24  #25  #26  #27  #28  #29
[   15.607841] .... node   #2, CPUs:    #30  #31  #32  #33  #34  #35  #36  #37  #38  #39  #40  #41  #42  #43  #44
[   15.976528] .... node   #3, CPUs:    #45  #46  #47  #48  #49  #50  #51  #52  #53  #54  #55  #56  #57  #58  #59
[   16.345479] .... node   #4, CPUs:    #60  #61  #62  #63  #64  #65  #66  #67  #68  #69  #70  #71  #72  #73  #74
[   16.714505] .... node   #5, CPUs:    #75  #76  #77  #78  #79  #80  #81  #82  #83  #84  #85  #86  #87  #88  #89
[   17.084496] .... node   #6, CPUs:    #90  #91  #92  #93  #94  #95  #96  #97  #98  #99 #100 #101 #102 #103 #104
[   17.454170] .... node   #7, CPUs:   #105 #106 #107 #108 #109 #110 #111 #112 #113 #114 #115 #116 #117 #118 #119
[   17.824647] .... node   #8, CPUs:   #120 #121 #122 #123 #124 #125 #126 #127 #128 #129 #130 #131 #132 #133 #134
[   18.194298] .... node   #9, CPUs:   #135 #136 #137 #138 #139 #140 #141 #142 #143 #144 #145 #146 #147 #148 #149
[   18.564007] .... node  #10, CPUs:   #150 #151 #152 #153 #154 #155 #156 #157 #158 #159 #160 #161 #162 #163 #164
[   18.933726] .... node  #11, CPUs:   #165 #166 #167 #168 #169 #170 #171 #172 #173 #174 #175 #176 #177 #178 #179
[   19.303187] .... node  #12, CPUs:   #180 #181 #182 #183 #184 #185 #186 #187 #188 #189 #190 #191 #192 #193 #194
[   19.672767] .... node  #13, CPUs:   #195 #196 #197 #198 #199 #200 #201 #202 #203 #204 #205 #206 #207 #208 #209
[   20.042091] .... node  #14, CPUs:   #210 #211 #212 #213 #214 #215 #216 #217 #218 #219 #220 #221 #222 #223 #224
[   20.411259] .... node  #15, CPUs:   #225 #226 #227 #228 #229 #230 #231 #232 #233 #234 #235 #236 #237 #238 #239
[   20.780857] .... node   #0, CPUs:   #240 #241 #242 #243 #244 #245 #246 #247 #248 #249 #250 #251 #252 #253 #254
[   21.036562] .... node   #1, CPUs:   #255 #256 #257 #258 #259 #260 #261 #262 #263 #264 #265 #266 #267 #268 #269
[   21.318174] .... node   #2, CPUs:   #270 #271 #272 #273 #274 #275 #276 #277 #278 #279 #280 #281 #282 #283 #284
[   21.599493] .... node   #3, CPUs:   #285 #286 #287 #288 #289 #290 #291 #292 #293 #294 #295 #296 #297 #298 #299
[   21.881536] .... node   #4, CPUs:   #300 #301 #302 #303 #304 #305 #306 #307 #308 #309 #310 #311 #312 #313 #314
[   22.163800] .... node   #5, CPUs:   #315 #316 #317 #318 #319 #320 #321 #322 #323 #324 #325 #326 #327 #328 #329
[   22.446271] .... node   #6, CPUs:   #330 #331 #332 #333 #334 #335 #336 #337 #338 #339 #340 #341 #342 #343 #344
[   22.729575] .... node   #7, CPUs:   #345 #346 #347 #348 #349 #350 #351 #352 #353 #354 #355 #356 #357 #358 #359
[   23.013097] .... node   #8, CPUs:   #360 #361 #362 #363 #364 #365 #366 #367 #368 #369 #370 #371 #372 #373 #374
[   23.296810] .... node   #9, CPUs:   #375 #376 #377 #378 #379 #380 #381 #382 #383 #384 #385 #386 #387 #388 #389
[   23.580160] .... node  #10, CPUs:   #390 #391 #392 #393 #394 #395 #396 #397 #398 #399 #400 #401 #402 #403 #404
[   23.863959] .... node  #11, CPUs:   #405 #406 #407 #408 #409 #410 #411 #412 #413 #414 #415 #416 #417 #418 #419
[   24.147551] .... node  #12, CPUs:   #420 #421 #422 #423 #424 #425 #426 #427 #428 #429 #430 #431 #432 #433 #434
[   24.430851] .... node  #13, CPUs:   #435 #436 #437 #438 #439 #440 #441 #442 #443 #444 #445 #446 #447 #448 #449
[   24.714476] .... node  #14, CPUs:   #450 #451 #452 #453 #454 #455 #456 #457 #458 #459 #460 #461 #462 #463 #464
[   24.997861] .... node  #15, CPUs:   #465 #466 #467 #468 #469 #470 #471 #472 #473 #474 #475 #476 #477 #478 #479
[   25.280331] x86: Booted up 16 nodes, 480 CPUs
[   25.285403] smpboot: Total of 480 processors activated (2684713.77 BogoMIPS)
[   28.198657] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[   28.276362] devtmpfs: initialized
[   28.280577] Using 2GB memory block size for large-memory system
[   28.624788] PM: Registering ACPI NVS region [mem 0x799ff000-0x7bdfefff] (37748736 bytes)
[   28.636575] PM: Registering ACPI NVS region [mem 0x100000000-0x100000fff] (4096 bytes)
[   28.645420] PM: Registering ACPI NVS region [mem 0xe000000000-0xe000000fff] (4096 bytes)
[   28.674678] RTC time: 16:38:50, date: 04/16/15
[   28.685068] NET: Registered protocol family 16
[   28.705999] cpuidle: using governor ladder
[   28.726551] cpuidle: using governor menu
[   28.731140] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[   28.739486] ACPI: bus type PCI registered
[   28.747966] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
[   28.758215] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[   28.766308] PCI: Using configuration type 1 for base access
[   56.319228] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [swapper/0:1]
[   56.327285] Modules linked in:
[   56.330655] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #2
[   56.340036] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[   56.350282] task: ffff88089d782010 ti: ffff88089d784000 task.ti: ffff88089d784000
[   56.358515] RIP: 0010:[<ffffffff813cf7a4>]  [<ffffffff813cf7a4>] register_mem_sect_under_node+0x64/0xd0
[   56.368869] RSP: 0000:ffff88089d787d38  EFLAGS: 00000246
[   56.374711] RAX: ffffea0000000000 RBX: ffff88089d787cf8 RCX: 0000000064e71128
[   56.382564] RDX: ffffea16128bc0e0 RSI: 0000000000000008 RDI: ffff91279c0b4000
[   56.390417] RBP: ffff88089d787d48 R08: 0000000064e7ffff R09: ffff8fa79d102448
[   56.398268] R10: ffff8ee79c6046d0 R11: dead000000200200 R12: ffffffff8150c1fd
[   56.406116] R13: ffff88089d787cc8 R14: ffffffffffffff10 R15: ffff8a679c0b4240
[   56.413967] FS:  0000000000000000(0000) GS:ffff88c07fa20000(0000) knlGS:0000000000000000
[   56.422867] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   56.429190] CR2: 0000000000000000 CR3: 0000000001a0e000 CR4: 00000000001406e0
[   56.437038] Stack:
[   56.439250]  0000000064e00000 ffff91279c0b4000 ffff88089d787d88 ffffffff813cf8b3
[   56.447419]  ffff88089d787d68 0000000000000008 00000000000001e0 0000000000000008
[   56.455588]  000000000000edc0 ffffffff81af6940 ffff88089d787dc8 ffffffff813cfadf
[   56.463761] Call Trace:
[   56.466452]  [<ffffffff813cf8b3>] link_mem_sections+0xa3/0xe0
[   56.472778]  [<ffffffff813cfadf>] register_one_node+0xef/0x140
[   56.479201]  [<ffffffff81b1c753>] ? enable_cpu0_hotplug+0x15/0x15
[   56.485906]  [<ffffffff81b1c78f>] topology_init+0x3c/0xa1
[   56.491850]  [<ffffffff81000288>] do_one_initcall+0xb8/0x1d0
[   56.498075]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   56.505086]  [<ffffffff81b15a21>] do_basic_setup+0xaf/0xd5
[   56.511119]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   56.518118]  [<ffffffff81b347d4>] ? sched_init_smp+0x140/0x147
[   56.524536]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
[   56.531345]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   56.537095]  [<ffffffff8150cf09>] kernel_init+0x9/0xf0
[   56.542755]  [<ffffffff815196c8>] ret_from_fork+0x58/0x90
[   56.548694]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   56.554439] Code: e1 0f 4c 39 c1 77 3f 48 89 d0 48 c1 e2 15 48 c1 e0 12 48 29 c2 48 b8 00 00 00 00 00 ea ff ff 48 8d 54 02 20 0f 1f 00 48 83 3a 00 <74> 0c 48 8b 42 e0 48 c1 e8 36 39 c6 74 1e 48 83 c1 01 48 83 c2 
[   84.401361] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [swapper/0:1]
[   84.409408] Modules linked in:
[   84.412777] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G             L  4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp #2
[   84.423497] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 006.000.042 SFW: 015.099.000 04/01/2015
[   84.433737] task: ffff88089d782010 ti: ffff88089d784000 task.ti: ffff88089d784000
[   84.441969] RIP: 0010:[<ffffffff813cf7a4>]  [<ffffffff813cf7a4>] register_mem_sect_under_node+0x64/0xd0
[   84.452327] RSP: 0000:ffff88089d787d38  EFLAGS: 00000246
[   84.458170] RAX: ffffea0000000000 RBX: ffff88089d787cf8 RCX: 00000000bc8d1729
[   84.466023] RDX: ffffea293edd1118 RSI: 000000000000000f RDI: ffff89a79c1b4000
[   84.473874] RBP: ffff88089d787d48 R08: 00000000bc8fffff R09: ffff8ee79c597f40
[   84.481723] R10: ffff89a79c1a8dd8 R11: dead000000200200 R12: ffffffff8150c1fd
[   84.489571] R13: ffff88089d787cc8 R14: ffff8d679c2274d8 R15: ffff88089d787ca8
[   84.497424] FS:  0000000000000000(0000) GS:ffff88c07fa20000(0000) knlGS:0000000000000000
[   84.506325] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   84.512644] CR2: 0000000000000000 CR3: 0000000001a0e000 CR4: 00000000001406e0
[   84.520493] Stack:
[   84.522702]  00000000bc880000 ffff89a79c1b4000 ffff88089d787d88 ffffffff813cf8b3
[   84.530870]  ffff88089d787d68 000000000000000f 00000000000001e0 000000000000000f
[   84.539039]  000000000000edc0 ffffffff81af6940 ffff88089d787dc8 ffffffff813cfadf
[   84.547207] Call Trace:
[   84.549906]  [<ffffffff813cf8b3>] link_mem_sections+0xa3/0xe0
[   84.556231]  [<ffffffff813cfadf>] register_one_node+0xef/0x140
[   84.562658]  [<ffffffff81b1c753>] ? enable_cpu0_hotplug+0x15/0x15
[   84.569360]  [<ffffffff81b1c78f>] topology_init+0x3c/0xa1
[   84.575302]  [<ffffffff81000288>] do_one_initcall+0xb8/0x1d0
[   84.581528]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   84.588517]  [<ffffffff81b15a21>] do_basic_setup+0xaf/0xd5
[   84.594551]  [<ffffffff81b15cde>] ? kernel_init_freeable+0x297/0x297
[   84.601546]  [<ffffffff81b347d4>] ? sched_init_smp+0x140/0x147
[   84.607963]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
[   84.614774]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   84.620521]  [<ffffffff8150cf09>] kernel_init+0x9/0xf0
[   84.626177]  [<ffffffff815196c8>] ret_from_fork+0x58/0x90
[   84.632116]  [<ffffffff8150cf00>] ? rest_init+0x80/0x80
[   84.637862] Code: e1 0f 4c 39 c1 77 3f 48 89 d0 48 c1 e2 15 48 c1 e0 12 48 29 c2 48 b8 00 00 00 00 00 ea ff ff 48 8d 54 02 20 0f 1f 00 48 83 3a 00 <74> 0c 48 8b 42 e0 48 c1 e8 36 39 c6 74 1e 48 83 c1 01 48 83 c2 
[   86.516417] ACPI: Added _OSI(Module Device)
[   86.521024] ACPI: Added _OSI(Processor Device)
[   86.525915] ACPI: Added _OSI(3.0 _SCP Extensions)
[   86.531088] ACPI: Added _OSI(Processor Aggregator Device)
[   86.974439] ACPI: Interpreter enabled
[   86.978475] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150204/hwxface-580)
[   86.988648] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150204/hwxface-580)
[   86.998820] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20150204/hwxface-580)
[   87.008993] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20150204/hwxface-580)
[   87.019170] ACPI: (supports S0 S5)
[   87.022909] ACPI: Using IOAPIC for interrupt routing
[   87.028674] HEST: Table parsing has been initialized.
[   87.034240] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[   87.222949] ACPI: PCI Root Bridge [IO00] (domain 0000 [bus 00-0f])
[   87.229758] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.238897] acpi PNP0A08:00: PCIe AER handled by firmware
[   87.245077] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.253628] PCI host bridge to bus 0000:00
[   87.258141] pci_bus 0000:00: root bus resource [bus 00-0f]
[   87.264182] pci_bus 0000:00: root bus resource [io  0x1000-0x3fff window]
[   87.271658] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[   87.279136] pci_bus 0000:00: root bus resource [mem 0x90000000-0x93efffff window]
[   87.287381] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[   87.295625] pci_bus 0000:00: root bus resource [mem 0xfed00000-0xfedfffff window]
[   87.303863] pci_bus 0000:00: root bus resource [mem 0xfc000000000-0xfc07fffffff window]
[   87.312674] pci_bus 0000:00: root bus resource [mem 0xfe000000000-0xfe07fffffff window]
[   87.321501] pci 0000:00:00.0: [8086:0e00] type 00 class 0x060000
[   87.321590] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[   87.321785] pci 0000:00:02.0: [8086:0e04] type 01 class 0x060400
[   87.321881] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[   87.322074] pci 0000:00:02.2: [8086:0e06] type 01 class 0x060400
[   87.322170] pci 0000:00:02.2: PME# supported from D0 D3hot D3cold
[   87.322356] pci 0000:00:03.0: [8086:0e08] type 01 class 0x060400
[   87.322458] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[   87.322653] pci 0000:00:04.0: [8086:0e20] type 00 class 0x088000
[   87.322680] pci 0000:00:04.0: reg 0x10: [mem 0xfc07ff1c000-0xfc07ff1ffff 64bit]
[   87.322899] pci 0000:00:04.1: [8086:0e21] type 00 class 0x088000
[   87.322917] pci 0000:00:04.1: reg 0x10: [mem 0xfc07ff18000-0xfc07ff1bfff 64bit]
[   87.323146] pci 0000:00:04.2: [8086:0e22] type 00 class 0x088000
[   87.323164] pci 0000:00:04.2: reg 0x10: [mem 0xfc07ff14000-0xfc07ff17fff 64bit]
[   87.323384] pci 0000:00:04.3: [8086:0e23] type 00 class 0x088000
[   87.323403] pci 0000:00:04.3: reg 0x10: [mem 0xfc07ff10000-0xfc07ff13fff 64bit]
[   87.323612] pci 0000:00:04.4: [8086:0e24] type 00 class 0x088000
[   87.323629] pci 0000:00:04.4: reg 0x10: [mem 0xfc07ff0c000-0xfc07ff0ffff 64bit]
[   87.323840] pci 0000:00:04.5: [8086:0e25] type 00 class 0x088000
[   87.323861] pci 0000:00:04.5: reg 0x10: [mem 0xfc07ff08000-0xfc07ff0bfff 64bit]
[   87.324076] pci 0000:00:04.6: [8086:0e26] type 00 class 0x088000
[   87.324094] pci 0000:00:04.6: reg 0x10: [mem 0xfc07ff04000-0xfc07ff07fff 64bit]
[   87.324302] pci 0000:00:04.7: [8086:0e27] type 00 class 0x088000
[   87.324321] pci 0000:00:04.7: reg 0x10: [mem 0xfc07ff00000-0xfc07ff03fff 64bit]
[   87.324559] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[   87.324680] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[   87.324857] pci 0000:00:1c.0: [8086:1d1e] type 01 class 0x060400
[   87.324958] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[   87.325151] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[   87.325174] pci 0000:00:1d.0: reg 0x10: [mem 0x90700000-0x907003ff]
[   87.325279] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[   87.325440] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[   87.325815] pci 0000:01:00.0: [8086:10f8] type 00 class 0x020000
[   87.325827] pci 0000:01:00.0: reg 0x10: [mem 0x90500000-0x905fffff]
[   87.325840] pci 0000:01:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.325847] pci 0000:01:00.0: reg 0x1c: [mem 0x90604000-0x90607fff]
[   87.325866] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0007ffff pref]
[   87.325916] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[   87.325952] pci 0000:01:00.0: reg 0x184: [mem 0xfc07fa00000-0xfc07fa03fff 64bit pref]
[   87.325969] pci 0000:01:00.0: reg 0x190: [mem 0xfc07f900000-0xfc07f903fff 64bit pref]
[   87.326163] pci 0000:01:00.1: [8086:10f8] type 00 class 0x020000
[   87.326174] pci 0000:01:00.1: reg 0x10: [mem 0x90400000-0x904fffff]
[   87.326190] pci 0000:01:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.326197] pci 0000:01:00.1: reg 0x1c: [mem 0x90600000-0x90603fff]
[   87.326216] pci 0000:01:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.326268] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[   87.326298] pci 0000:01:00.1: reg 0x184: [mem 0xfc07f800000-0xfc07f803fff 64bit pref]
[   87.326315] pci 0000:01:00.1: reg 0x190: [mem 0xfc07f700000-0xfc07f703fff 64bit pref]
[   87.333577] pci 0000:00:02.0: PCI bridge to [bus 01-02]
[   87.339334] pci 0000:00:02.0:   bridge window [mem 0x90400000-0x906fffff]
[   87.339343] pci 0000:00:02.0:   bridge window [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   87.339477] pci 0000:03:00.0: [8086:10f8] type 00 class 0x020000
[   87.339490] pci 0000:03:00.0: reg 0x10: [mem 0x90200000-0x902fffff]
[   87.339502] pci 0000:03:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.339509] pci 0000:03:00.0: reg 0x1c: [mem 0x90304000-0x90307fff]
[   87.339530] pci 0000:03:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.339582] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[   87.339618] pci 0000:03:00.0: reg 0x184: [mem 0xfc07fe00000-0xfc07fe03fff 64bit pref]
[   87.339632] pci 0000:03:00.0: reg 0x190: [mem 0xfc07fd00000-0xfc07fd03fff 64bit pref]
[   87.339808] pci 0000:03:00.1: [8086:10f8] type 00 class 0x020000
[   87.339822] pci 0000:03:00.1: reg 0x10: [mem 0x90100000-0x901fffff]
[   87.339835] pci 0000:03:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.339841] pci 0000:03:00.1: reg 0x1c: [mem 0x90300000-0x90303fff]
[   87.339860] pci 0000:03:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.339918] pci 0000:03:00.1: PME# supported from D0 D3hot D3cold
[   87.339950] pci 0000:03:00.1: reg 0x184: [mem 0xfc07fc00000-0xfc07fc03fff 64bit pref]
[   87.339964] pci 0000:03:00.1: reg 0x190: [mem 0xfc07fb00000-0xfc07fb03fff 64bit pref]
[   87.347371] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[   87.353148] pci 0000:00:02.2:   bridge window [mem 0x90100000-0x903fffff]
[   87.353157] pci 0000:00:02.2:   bridge window [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   87.353271] pci 0000:00:03.0: PCI bridge to [bus 05]
[   87.358863] pci 0000:00:11.0: PCI bridge to [bus 06]
[   87.364485] pci 0000:07:00.0: [103c:3306] type 00 class 0x088000
[   87.364513] pci 0000:07:00.0: reg 0x10: [io  0x1400-0x14ff]
[   87.364532] pci 0000:07:00.0: reg 0x14: [mem 0x93a8c000-0x93a8c1ff]
[   87.364548] pci 0000:07:00.0: reg 0x18: [io  0x1200-0x12ff]
[   87.364847] pci 0000:07:00.1: [102b:0533] type 00 class 0x030000
[   87.364874] pci 0000:07:00.1: reg 0x10: [mem 0x92000000-0x92ffffff pref]
[   87.364895] pci 0000:07:00.1: reg 0x14: [mem 0x93a88000-0x93a8bfff]
[   87.364914] pci 0000:07:00.1: reg 0x18: [mem 0x93000000-0x937fffff]
[   87.365217] pci 0000:07:00.2: [103c:3307] type 00 class 0x088000
[   87.365244] pci 0000:07:00.2: reg 0x10: [io  0x1000-0x10ff]
[   87.365263] pci 0000:07:00.2: reg 0x14: [mem 0x93a8c400-0x93a8c4ff]
[   87.365282] pci 0000:07:00.2: reg 0x18: [mem 0x93800000-0x938fffff]
[   87.365298] pci 0000:07:00.2: reg 0x1c: [mem 0x93a00000-0x93a7ffff]
[   87.365315] pci 0000:07:00.2: reg 0x20: [mem 0x93a80000-0x93a87fff]
[   87.365331] pci 0000:07:00.2: reg 0x24: [mem 0x93900000-0x939fffff]
[   87.365348] pci 0000:07:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   87.365436] pci 0000:07:00.2: PME# supported from D0 D3hot D3cold
[   87.365613] pci 0000:07:00.4: [103c:3300] type 00 class 0x0c0300
[   87.365697] pci 0000:07:00.4: reg 0x20: [io  0x1500-0x151f]
[   87.376394] pci 0000:00:1c.0: PCI bridge to [bus 07]
[   87.381861] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[   87.381865] pci 0000:00:1c.0:   bridge window [mem 0x92000000-0x93efffff]
[   87.381871] pci 0000:00:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   87.381929] pci_bus 0000:00: on NUMA node 0
[   87.381930] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
[   87.390302] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.399747] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.409178] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.418622] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.428064] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.437503] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.446949] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.456384] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[   87.465774] ACPI: PCI Root Bridge [IO01] (domain 0000 [bus 10-1f])
[   87.472579] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.481711] acpi PNP0A08:01: PCIe AER handled by firmware
[   87.487898] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.496492] PCI host bridge to bus 0000:10
[   87.500999] pci_bus 0000:10: root bus resource [bus 10-1f]
[   87.507039] pci_bus 0000:10: root bus resource [io  0x4000-0x7fff window]
[   87.514512] pci_bus 0000:10: root bus resource [mem 0x94000000-0x97ff7fff window]
[   87.522752] pci_bus 0000:10: root bus resource [mem 0xfc400000000-0xfc47fffffff window]
[   87.531576] pci 0000:10:02.0: [8086:0e04] type 01 class 0x060400
[   87.531678] pci 0000:10:02.0: PME# supported from D0 D3hot D3cold
[   87.531895] pci 0000:10:02.2: [8086:0e06] type 01 class 0x060400
[   87.531995] pci 0000:10:02.2: PME# supported from D0 D3hot D3cold
[   87.532176] pci 0000:10:03.0: [8086:0e08] type 01 class 0x060400
[   87.532278] pci 0000:10:03.0: PME# supported from D0 D3hot D3cold
[   87.532478] pci 0000:10:04.0: [8086:0e20] type 00 class 0x088000
[   87.532500] pci 0000:10:04.0: reg 0x10: [mem 0xfc47ff1c000-0xfc47ff1ffff 64bit]
[   87.532708] pci 0000:10:04.1: [8086:0e21] type 00 class 0x088000
[   87.532729] pci 0000:10:04.1: reg 0x10: [mem 0xfc47ff18000-0xfc47ff1bfff 64bit]
[   87.532944] pci 0000:10:04.2: [8086:0e22] type 00 class 0x088000
[   87.532963] pci 0000:10:04.2: reg 0x10: [mem 0xfc47ff14000-0xfc47ff17fff 64bit]
[   87.533180] pci 0000:10:04.3: [8086:0e23] type 00 class 0x088000
[   87.533201] pci 0000:10:04.3: reg 0x10: [mem 0xfc47ff10000-0xfc47ff13fff 64bit]
[   87.533409] pci 0000:10:04.4: [8086:0e24] type 00 class 0x088000
[   87.533428] pci 0000:10:04.4: reg 0x10: [mem 0xfc47ff0c000-0xfc47ff0ffff 64bit]
[   87.533644] pci 0000:10:04.5: [8086:0e25] type 00 class 0x088000
[   87.533665] pci 0000:10:04.5: reg 0x10: [mem 0xfc47ff08000-0xfc47ff0bfff 64bit]
[   87.533869] pci 0000:10:04.6: [8086:0e26] type 00 class 0x088000
[   87.533887] pci 0000:10:04.6: reg 0x10: [mem 0xfc47ff04000-0xfc47ff07fff 64bit]
[   87.534102] pci 0000:10:04.7: [8086:0e27] type 00 class 0x088000
[   87.534126] pci 0000:10:04.7: reg 0x10: [mem 0xfc47ff00000-0xfc47ff03fff 64bit]
[   87.534430] pci 0000:10:02.0: PCI bridge to [bus 11]
[   87.540021] pci 0000:10:02.2: PCI bridge to [bus 12]
[   87.545599] pci 0000:13:00.0: [1077:2031] type 00 class 0x0c0400
[   87.545616] pci 0000:13:00.0: reg 0x10: [mem 0xfc47fe0a000-0xfc47fe0bfff 64bit pref]
[   87.545630] pci 0000:13:00.0: reg 0x18: [mem 0xfc47fe04000-0xfc47fe07fff 64bit pref]
[   87.545640] pci 0000:13:00.0: reg 0x20: [mem 0xfc47fd00000-0xfc47fdfffff 64bit pref]
[   87.545649] pci 0000:13:00.0: reg 0x30: [mem 0x00000000-0x0003ffff pref]
[   87.545703] pci 0000:13:00.0: PME# supported from D3cold
[   87.545901] pci 0000:13:00.1: [1077:2031] type 00 class 0x0c0400
[   87.545919] pci 0000:13:00.1: reg 0x10: [mem 0xfc47fe08000-0xfc47fe09fff 64bit pref]
[   87.545929] pci 0000:13:00.1: reg 0x18: [mem 0xfc47fe00000-0xfc47fe03fff 64bit pref]
[   87.545940] pci 0000:13:00.1: reg 0x20: [mem 0xfc47fc00000-0xfc47fcfffff 64bit pref]
[   87.545952] pci 0000:13:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   87.546001] pci 0000:13:00.1: PME# supported from D3cold
[   87.546203] pci 0000:10:03.0: PCI bridge to [bus 13]
[   87.551676] pci 0000:10:03.0:   bridge window [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   87.551708] pci_bus 0000:10: on NUMA node 1
[   87.551709] acpi PNP0A08:01: Disabling ASPM (FADT indicates it is unsupported)
[   87.567966] ACPI: PCI Root Bridge [IO02] (domain 0000 [bus 20-2f])
[   87.574777] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.583908] acpi PNP0A08:02: PCIe AER handled by firmware
[   87.590100] acpi PNP0A08:02: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.598653] PCI host bridge to bus 0000:20
[   87.603160] pci_bus 0000:20: root bus resource [bus 20-2f]
[   87.609196] pci_bus 0000:20: root bus resource [io  0x8000-0xbfff window]
[   87.616667] pci_bus 0000:20: root bus resource [mem 0x98000000-0x9befffff window]
[   87.624902] pci_bus 0000:20: root bus resource [mem 0xf0800000000-0xf087fffffff window]
[   87.633729] pci 0000:20:00.0: [8086:0e00] type 00 class 0x060000
[   87.633817] pci 0000:20:00.0: PME# supported from D0 D3hot D3cold
[   87.633984] pci 0000:20:02.0: [8086:0e04] type 01 class 0x060400
[   87.634093] pci 0000:20:02.0: PME# supported from D0 D3hot D3cold
[   87.634290] pci 0000:20:02.2: [8086:0e06] type 01 class 0x060400
[   87.634399] pci 0000:20:02.2: PME# supported from D0 D3hot D3cold
[   87.634597] pci 0000:20:03.0: [8086:0e08] type 01 class 0x060400
[   87.634711] pci 0000:20:03.0: PME# supported from D0 D3hot D3cold
[   87.634903] pci 0000:20:04.0: [8086:0e20] type 00 class 0x088000
[   87.634927] pci 0000:20:04.0: reg 0x10: [mem 0xf087ff1c000-0xf087ff1ffff 64bit]
[   87.635154] pci 0000:20:04.1: [8086:0e21] type 00 class 0x088000
[   87.635173] pci 0000:20:04.1: reg 0x10: [mem 0xf087ff18000-0xf087ff1bfff 64bit]
[   87.635400] pci 0000:20:04.2: [8086:0e22] type 00 class 0x088000
[   87.635419] pci 0000:20:04.2: reg 0x10: [mem 0xf087ff14000-0xf087ff17fff 64bit]
[   87.635630] pci 0000:20:04.3: [8086:0e23] type 00 class 0x088000
[   87.635653] pci 0000:20:04.3: reg 0x10: [mem 0xf087ff10000-0xf087ff13fff 64bit]
[   87.635878] pci 0000:20:04.4: [8086:0e24] type 00 class 0x088000
[   87.635899] pci 0000:20:04.4: reg 0x10: [mem 0xf087ff0c000-0xf087ff0ffff 64bit]
[   87.636136] pci 0000:20:04.5: [8086:0e25] type 00 class 0x088000
[   87.636155] pci 0000:20:04.5: reg 0x10: [mem 0xf087ff08000-0xf087ff0bfff 64bit]
[   87.636382] pci 0000:20:04.6: [8086:0e26] type 00 class 0x088000
[   87.636403] pci 0000:20:04.6: reg 0x10: [mem 0xf087ff04000-0xf087ff07fff 64bit]
[   87.636634] pci 0000:20:04.7: [8086:0e27] type 00 class 0x088000
[   87.636655] pci 0000:20:04.7: reg 0x10: [mem 0xf087ff00000-0xf087ff03fff 64bit]
[   87.636902] pci 0000:20:11.0: [8086:1d3e] type 01 class 0x060400
[   87.637023] pci 0000:20:11.0: PME# supported from D0 D3hot D3cold
[   87.637229] pci 0000:20:1c.0: [8086:1d1e] type 01 class 0x060400
[   87.637343] pci 0000:20:1c.0: PME# supported from D0 D3hot D3cold
[   87.637544] pci 0000:20:1d.0: [8086:1d26] type 00 class 0x0c0320
[   87.637569] pci 0000:20:1d.0: reg 0x10: [mem 0x98600000-0x986003ff]
[   87.637686] pci 0000:20:1d.0: PME# supported from D0 D3hot D3cold
[   87.637852] pci 0000:20:1f.0: [8086:1d41] type 00 class 0x060100
[   87.638245] pci 0000:21:00.0: [8086:10f8] type 00 class 0x020000
[   87.638258] pci 0000:21:00.0: reg 0x10: [mem 0x98400000-0x984fffff]
[   87.638272] pci 0000:21:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.638280] pci 0000:21:00.0: reg 0x1c: [mem 0x98504000-0x98507fff]
[   87.638305] pci 0000:21:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.638360] pci 0000:21:00.0: PME# supported from D0 D3hot D3cold
[   87.638396] pci 0000:21:00.0: reg 0x184: [mem 0xf087fa00000-0xf087fa03fff 64bit pref]
[   87.638411] pci 0000:21:00.0: reg 0x190: [mem 0xf087f900000-0xf087f903fff 64bit pref]
[   87.638610] pci 0000:21:00.1: [8086:10f8] type 00 class 0x020000
[   87.638624] pci 0000:21:00.1: reg 0x10: [mem 0x98300000-0x983fffff]
[   87.638637] pci 0000:21:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.638646] pci 0000:21:00.1: reg 0x1c: [mem 0x98500000-0x98503fff]
[   87.638666] pci 0000:21:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.638727] pci 0000:21:00.1: PME# supported from D0 D3hot D3cold
[   87.638763] pci 0000:21:00.1: reg 0x184: [mem 0xf087f800000-0xf087f803fff 64bit pref]
[   87.638778] pci 0000:21:00.1: reg 0x190: [mem 0xf087f700000-0xf087f703fff 64bit pref]
[   87.649769] pci 0000:20:02.0: PCI bridge to [bus 21-22]
[   87.655550] pci 0000:20:02.0:   bridge window [mem 0x98300000-0x985fffff]
[   87.655561] pci 0000:20:02.0:   bridge window [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   87.655701] pci 0000:23:00.0: [8086:10f8] type 00 class 0x020000
[   87.655714] pci 0000:23:00.0: reg 0x10: [mem 0x98100000-0x981fffff]
[   87.655727] pci 0000:23:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.655735] pci 0000:23:00.0: reg 0x1c: [mem 0x98204000-0x98207fff]
[   87.655759] pci 0000:23:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.655816] pci 0000:23:00.0: PME# supported from D0 D3hot D3cold
[   87.655852] pci 0000:23:00.0: reg 0x184: [mem 0xf087fe00000-0xf087fe03fff 64bit pref]
[   87.655868] pci 0000:23:00.0: reg 0x190: [mem 0xf087fd00000-0xf087fd03fff 64bit pref]
[   87.656071] pci 0000:23:00.1: [8086:10f8] type 00 class 0x020000
[   87.656087] pci 0000:23:00.1: reg 0x10: [mem 0x98000000-0x980fffff]
[   87.656101] pci 0000:23:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.656108] pci 0000:23:00.1: reg 0x1c: [mem 0x98200000-0x98203fff]
[   87.656133] pci 0000:23:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.656193] pci 0000:23:00.1: PME# supported from D0 D3hot D3cold
[   87.656224] pci 0000:23:00.1: reg 0x184: [mem 0xf087fc00000-0xf087fc03fff 64bit pref]
[   87.656242] pci 0000:23:00.1: reg 0x190: [mem 0xf087fb00000-0xf087fb03fff 64bit pref]
[   87.663587] pci 0000:20:02.2: PCI bridge to [bus 23-24]
[   87.669365] pci 0000:20:02.2:   bridge window [mem 0x98000000-0x982fffff]
[   87.669372] pci 0000:20:02.2:   bridge window [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   87.669488] pci 0000:20:03.0: PCI bridge to [bus 25]
[   87.675082] pci 0000:20:11.0: PCI bridge to [bus 26]
[   87.680723] pci 0000:27:00.0: [103c:3306] type 00 class 0x088000
[   87.680751] pci 0000:27:00.0: reg 0x10: [io  0x0000-0x00ff]
[   87.680768] pci 0000:27:00.0: reg 0x14: [mem 0x9bd88000-0x9bd881ff]
[   87.680785] pci 0000:27:00.0: reg 0x18: [io  0x0000-0x00ff]
[   87.681166] pci 0000:27:00.2: [103c:3307] type 00 class 0x088000
[   87.681194] pci 0000:27:00.2: reg 0x10: [io  0x0000-0x00ff]
[   87.681211] pci 0000:27:00.2: reg 0x14: [mem 0x9bd88400-0x9bd884ff]
[   87.681228] pci 0000:27:00.2: reg 0x18: [mem 0x9bb00000-0x9bbfffff]
[   87.681247] pci 0000:27:00.2: reg 0x1c: [mem 0x9bd00000-0x9bd7ffff]
[   87.681264] pci 0000:27:00.2: reg 0x20: [mem 0x9bd80000-0x9bd87fff]
[   87.681281] pci 0000:27:00.2: reg 0x24: [mem 0x9bc00000-0x9bcfffff]
[   87.681298] pci 0000:27:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   87.681392] pci 0000:27:00.2: PME# supported from D0 D3hot D3cold
[   87.688592] pci 0000:20:1c.0: PCI bridge to [bus 27]
[   87.694086] pci 0000:20:1c.0:   bridge window [mem 0x9bb00000-0x9befffff]
[   87.694093] pci 0000:20:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   87.694149] pci_bus 0000:20: on NUMA node 2
[   87.694151] acpi PNP0A08:02: Disabling ASPM (FADT indicates it is unsupported)
[   87.702295] ACPI: PCI Root Bridge [IO03] (domain 0000 [bus 30-3f])
[   87.709103] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.718241] acpi PNP0A08:03: PCIe AER handled by firmware
[   87.724466] acpi PNP0A08:03: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.733038] PCI host bridge to bus 0000:30
[   87.737545] pci_bus 0000:30: root bus resource [bus 30-3f]
[   87.743583] pci_bus 0000:30: root bus resource [io  0xc000-0xffff window]
[   87.751058] pci_bus 0000:30: root bus resource [mem 0x9c000000-0x9fff7fff window]
[   87.759300] pci_bus 0000:30: root bus resource [mem 0xf0c00000000-0xf0c7fffffff window]
[   87.768130] pci 0000:30:02.0: [8086:0e04] type 01 class 0x060400
[   87.768240] pci 0000:30:02.0: PME# supported from D0 D3hot D3cold
[   87.768442] pci 0000:30:02.2: [8086:0e06] type 01 class 0x060400
[   87.768547] pci 0000:30:02.2: PME# supported from D0 D3hot D3cold
[   87.768741] pci 0000:30:03.0: [8086:0e08] type 01 class 0x060400
[   87.768854] pci 0000:30:03.0: PME# supported from D0 D3hot D3cold
[   87.769042] pci 0000:30:04.0: [8086:0e20] type 00 class 0x088000
[   87.769065] pci 0000:30:04.0: reg 0x10: [mem 0xf0c7ff1c000-0xf0c7ff1ffff 64bit]
[   87.769298] pci 0000:30:04.1: [8086:0e21] type 00 class 0x088000
[   87.769317] pci 0000:30:04.1: reg 0x10: [mem 0xf0c7ff18000-0xf0c7ff1bfff 64bit]
[   87.769553] pci 0000:30:04.2: [8086:0e22] type 00 class 0x088000
[   87.769575] pci 0000:30:04.2: reg 0x10: [mem 0xf0c7ff14000-0xf0c7ff17fff 64bit]
[   87.769802] pci 0000:30:04.3: [8086:0e23] type 00 class 0x088000
[   87.769821] pci 0000:30:04.3: reg 0x10: [mem 0xf0c7ff10000-0xf0c7ff13fff 64bit]
[   87.770069] pci 0000:30:04.4: [8086:0e24] type 00 class 0x088000
[   87.770090] pci 0000:30:04.4: reg 0x10: [mem 0xf0c7ff0c000-0xf0c7ff0ffff 64bit]
[   87.770318] pci 0000:30:04.5: [8086:0e25] type 00 class 0x088000
[   87.770338] pci 0000:30:04.5: reg 0x10: [mem 0xf0c7ff08000-0xf0c7ff0bfff 64bit]
[   87.770562] pci 0000:30:04.6: [8086:0e26] type 00 class 0x088000
[   87.770581] pci 0000:30:04.6: reg 0x10: [mem 0xf0c7ff04000-0xf0c7ff07fff 64bit]
[   87.770813] pci 0000:30:04.7: [8086:0e27] type 00 class 0x088000
[   87.770833] pci 0000:30:04.7: reg 0x10: [mem 0xf0c7ff00000-0xf0c7ff03fff 64bit]
[   87.771157] pci 0000:30:02.0: PCI bridge to [bus 31]
[   87.776740] pci 0000:30:02.2: PCI bridge to [bus 32]
[   87.782330] pci 0000:33:00.0: [1077:2031] type 00 class 0x0c0400
[   87.782349] pci 0000:33:00.0: reg 0x10: [mem 0xf0c7fe0a000-0xf0c7fe0bfff 64bit pref]
[   87.782361] pci 0000:33:00.0: reg 0x18: [mem 0xf0c7fe04000-0xf0c7fe07fff 64bit pref]
[   87.782376] pci 0000:33:00.0: reg 0x20: [mem 0xf0c7fd00000-0xf0c7fdfffff 64bit pref]
[   87.782385] pci 0000:33:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   87.782445] pci 0000:33:00.0: PME# supported from D3cold
[   87.782647] pci 0000:33:00.1: [1077:2031] type 00 class 0x0c0400
[   87.782664] pci 0000:33:00.1: reg 0x10: [mem 0xf0c7fe08000-0xf0c7fe09fff 64bit pref]
[   87.782676] pci 0000:33:00.1: reg 0x18: [mem 0xf0c7fe00000-0xf0c7fe03fff 64bit pref]
[   87.782688] pci 0000:33:00.1: reg 0x20: [mem 0xf0c7fc00000-0xf0c7fcfffff 64bit pref]
[   87.782696] pci 0000:33:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   87.782747] pci 0000:33:00.1: PME# supported from D3cold
[   87.782934] pci 0000:30:03.0: PCI bridge to [bus 33]
[   87.788410] pci 0000:30:03.0:   bridge window [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   87.788441] pci_bus 0000:30: on NUMA node 3
[   87.788443] acpi PNP0A08:03: Disabling ASPM (FADT indicates it is unsupported)
[   87.805443] ACPI: PCI Root Bridge [IO04] (domain 0000 [bus 40-4f])
[   87.812254] acpi PNP0A08:04: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.821389] acpi PNP0A08:04: PCIe AER handled by firmware
[   87.827580] acpi PNP0A08:04: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.836149] PCI host bridge to bus 0000:40
[   87.840659] pci_bus 0000:40: root bus resource [bus 40-4f]
[   87.846700] pci_bus 0000:40: root bus resource [mem 0xa0000000-0xa3efffff window]
[   87.854945] pci_bus 0000:40: root bus resource [mem 0xf1000000000-0xf107fffffff window]
[   87.863774] pci 0000:40:00.0: [8086:0e00] type 00 class 0x060000
[   87.863865] pci 0000:40:00.0: PME# supported from D0 D3hot D3cold
[   87.864059] pci 0000:40:02.0: [8086:0e04] type 01 class 0x060400
[   87.864167] pci 0000:40:02.0: PME# supported from D0 D3hot D3cold
[   87.864371] pci 0000:40:02.2: [8086:0e06] type 01 class 0x060400
[   87.864477] pci 0000:40:02.2: PME# supported from D0 D3hot D3cold
[   87.864662] pci 0000:40:03.0: [8086:0e08] type 01 class 0x060400
[   87.864773] pci 0000:40:03.0: PME# supported from D0 D3hot D3cold
[   87.864948] pci 0000:40:04.0: [8086:0e20] type 00 class 0x088000
[   87.864971] pci 0000:40:04.0: reg 0x10: [mem 0xf107ff1c000-0xf107ff1ffff 64bit]
[   87.865201] pci 0000:40:04.1: [8086:0e21] type 00 class 0x088000
[   87.865220] pci 0000:40:04.1: reg 0x10: [mem 0xf107ff18000-0xf107ff1bfff 64bit]
[   87.865444] pci 0000:40:04.2: [8086:0e22] type 00 class 0x088000
[   87.865465] pci 0000:40:04.2: reg 0x10: [mem 0xf107ff14000-0xf107ff17fff 64bit]
[   87.865685] pci 0000:40:04.3: [8086:0e23] type 00 class 0x088000
[   87.865705] pci 0000:40:04.3: reg 0x10: [mem 0xf107ff10000-0xf107ff13fff 64bit]
[   87.865931] pci 0000:40:04.4: [8086:0e24] type 00 class 0x088000
[   87.865956] pci 0000:40:04.4: reg 0x10: [mem 0xf107ff0c000-0xf107ff0ffff 64bit]
[   87.866180] pci 0000:40:04.5: [8086:0e25] type 00 class 0x088000
[   87.866199] pci 0000:40:04.5: reg 0x10: [mem 0xf107ff08000-0xf107ff0bfff 64bit]
[   87.866421] pci 0000:40:04.6: [8086:0e26] type 00 class 0x088000
[   87.866442] pci 0000:40:04.6: reg 0x10: [mem 0xf107ff04000-0xf107ff07fff 64bit]
[   87.866656] pci 0000:40:04.7: [8086:0e27] type 00 class 0x088000
[   87.866676] pci 0000:40:04.7: reg 0x10: [mem 0xf107ff00000-0xf107ff03fff 64bit]
[   87.866908] pci 0000:40:11.0: [8086:1d3e] type 01 class 0x060400
[   87.867030] pci 0000:40:11.0: PME# supported from D0 D3hot D3cold
[   87.867208] pci 0000:40:1c.0: [8086:1d1e] type 01 class 0x060400
[   87.867316] pci 0000:40:1c.0: PME# supported from D0 D3hot D3cold
[   87.867523] pci 0000:40:1d.0: [8086:1d26] type 00 class 0x0c0320
[   87.867549] pci 0000:40:1d.0: reg 0x10: [mem 0xa0600000-0xa06003ff]
[   87.867665] pci 0000:40:1d.0: PME# supported from D0 D3hot D3cold
[   87.867836] pci 0000:40:1f.0: [8086:1d41] type 00 class 0x060100
[   87.868224] pci 0000:41:00.0: [8086:10f8] type 00 class 0x020000
[   87.868238] pci 0000:41:00.0: reg 0x10: [mem 0xa0400000-0xa04fffff]
[   87.868254] pci 0000:41:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.868262] pci 0000:41:00.0: reg 0x1c: [mem 0xa0504000-0xa0507fff]
[   87.868283] pci 0000:41:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.868338] pci 0000:41:00.0: PME# supported from D0 D3hot D3cold
[   87.868374] pci 0000:41:00.0: reg 0x184: [mem 0xf107fa00000-0xf107fa03fff 64bit pref]
[   87.868391] pci 0000:41:00.0: reg 0x190: [mem 0xf107f900000-0xf107f903fff 64bit pref]
[   87.868586] pci 0000:41:00.1: [8086:10f8] type 00 class 0x020000
[   87.868599] pci 0000:41:00.1: reg 0x10: [mem 0xa0300000-0xa03fffff]
[   87.868613] pci 0000:41:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.868623] pci 0000:41:00.1: reg 0x1c: [mem 0xa0500000-0xa0503fff]
[   87.868643] pci 0000:41:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.868702] pci 0000:41:00.1: PME# supported from D0 D3hot D3cold
[   87.868736] pci 0000:41:00.1: reg 0x184: [mem 0xf107f800000-0xf107f803fff 64bit pref]
[   87.868751] pci 0000:41:00.1: reg 0x190: [mem 0xf107f700000-0xf107f703fff 64bit pref]
[   87.875845] pci 0000:40:02.0: PCI bridge to [bus 41-42]
[   87.881604] pci 0000:40:02.0:   bridge window [mem 0xa0300000-0xa05fffff]
[   87.881613] pci 0000:40:02.0:   bridge window [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   87.881742] pci 0000:43:00.0: [8086:10f8] type 00 class 0x020000
[   87.881757] pci 0000:43:00.0: reg 0x10: [mem 0xa0100000-0xa01fffff]
[   87.881773] pci 0000:43:00.0: reg 0x18: [io  0x0000-0x001f]
[   87.881781] pci 0000:43:00.0: reg 0x1c: [mem 0xa0204000-0xa0207fff]
[   87.881803] pci 0000:43:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.881868] pci 0000:43:00.0: PME# supported from D0 D3hot D3cold
[   87.881907] pci 0000:43:00.0: reg 0x184: [mem 0xf107fe00000-0xf107fe03fff 64bit pref]
[   87.881925] pci 0000:43:00.0: reg 0x190: [mem 0xf107fd00000-0xf107fd03fff 64bit pref]
[   87.882129] pci 0000:43:00.1: [8086:10f8] type 00 class 0x020000
[   87.882141] pci 0000:43:00.1: reg 0x10: [mem 0xa0000000-0xa00fffff]
[   87.882155] pci 0000:43:00.1: reg 0x18: [io  0x0000-0x001f]
[   87.882166] pci 0000:43:00.1: reg 0x1c: [mem 0xa0200000-0xa0203fff]
[   87.882186] pci 0000:43:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   87.882245] pci 0000:43:00.1: PME# supported from D0 D3hot D3cold
[   87.882277] pci 0000:43:00.1: reg 0x184: [mem 0xf107fc00000-0xf107fc03fff 64bit pref]
[   87.882297] pci 0000:43:00.1: reg 0x190: [mem 0xf107fb00000-0xf107fb03fff 64bit pref]
[   87.889642] pci 0000:40:02.2: PCI bridge to [bus 43-44]
[   87.895419] pci 0000:40:02.2:   bridge window [mem 0xa0000000-0xa02fffff]
[   87.895425] pci 0000:40:02.2:   bridge window [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   87.895540] pci 0000:40:03.0: PCI bridge to [bus 45]
[   87.901138] pci 0000:40:11.0: PCI bridge to [bus 46]
[   87.906760] pci 0000:47:00.0: [103c:3306] type 00 class 0x088000
[   87.906789] pci 0000:47:00.0: reg 0x10: [io  0x0000-0x00ff]
[   87.906806] pci 0000:47:00.0: reg 0x14: [mem 0xa3d88000-0xa3d881ff]
[   87.906825] pci 0000:47:00.0: reg 0x18: [io  0x0000-0x00ff]
[   87.907133] pci 0000:47:00.2: [103c:3307] type 00 class 0x088000
[   87.907164] pci 0000:47:00.2: reg 0x10: [io  0x0000-0x00ff]
[   87.907181] pci 0000:47:00.2: reg 0x14: [mem 0xa3d88400-0xa3d884ff]
[   87.907198] pci 0000:47:00.2: reg 0x18: [mem 0xa3b00000-0xa3bfffff]
[   87.907218] pci 0000:47:00.2: reg 0x1c: [mem 0xa3d00000-0xa3d7ffff]
[   87.907237] pci 0000:47:00.2: reg 0x20: [mem 0xa3d80000-0xa3d87fff]
[   87.907255] pci 0000:47:00.2: reg 0x24: [mem 0xa3c00000-0xa3cfffff]
[   87.907272] pci 0000:47:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   87.907365] pci 0000:47:00.2: PME# supported from D0 D3hot D3cold
[   87.918676] pci 0000:40:1c.0: PCI bridge to [bus 47]
[   87.924145] pci 0000:40:1c.0:   bridge window [mem 0xa3b00000-0xa3efffff]
[   87.924152] pci 0000:40:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   87.924209] pci_bus 0000:40: on NUMA node 4
[   87.924211] acpi PNP0A08:04: Disabling ASPM (FADT indicates it is unsupported)
[   87.932348] ACPI: PCI Root Bridge [IO05] (domain 0000 [bus 50-5f])
[   87.939151] acpi PNP0A08:05: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   87.948284] acpi PNP0A08:05: PCIe AER handled by firmware
[   87.954466] acpi PNP0A08:05: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   87.963043] PCI host bridge to bus 0000:50
[   87.967554] pci_bus 0000:50: root bus resource [bus 50-5f]
[   87.973591] pci_bus 0000:50: root bus resource [mem 0xa4000000-0xa7ff7fff window]
[   87.981826] pci_bus 0000:50: root bus resource [mem 0xf1400000000-0xf147fffffff window]
[   87.990651] pci 0000:50:02.0: [8086:0e04] type 01 class 0x060400
[   87.990762] pci 0000:50:02.0: PME# supported from D0 D3hot D3cold
[   87.990952] pci 0000:50:02.2: [8086:0e06] type 01 class 0x060400
[   87.991061] pci 0000:50:02.2: PME# supported from D0 D3hot D3cold
[   87.991248] pci 0000:50:03.0: [8086:0e08] type 01 class 0x060400
[   87.991362] pci 0000:50:03.0: PME# supported from D0 D3hot D3cold
[   87.991539] pci 0000:50:04.0: [8086:0e20] type 00 class 0x088000
[   87.991562] pci 0000:50:04.0: reg 0x10: [mem 0xf147ff1c000-0xf147ff1ffff 64bit]
[   87.991788] pci 0000:50:04.1: [8086:0e21] type 00 class 0x088000
[   87.991808] pci 0000:50:04.1: reg 0x10: [mem 0xf147ff18000-0xf147ff1bfff 64bit]
[   87.992036] pci 0000:50:04.2: [8086:0e22] type 00 class 0x088000
[   87.992057] pci 0000:50:04.2: reg 0x10: [mem 0xf147ff14000-0xf147ff17fff 64bit]
[   87.992259] pci 0000:50:04.3: [8086:0e23] type 00 class 0x088000
[   87.992279] pci 0000:50:04.3: reg 0x10: [mem 0xf147ff10000-0xf147ff13fff 64bit]
[   87.992495] pci 0000:50:04.4: [8086:0e24] type 00 class 0x088000
[   87.992516] pci 0000:50:04.4: reg 0x10: [mem 0xf147ff0c000-0xf147ff0ffff 64bit]
[   87.992740] pci 0000:50:04.5: [8086:0e25] type 00 class 0x088000
[   87.992759] pci 0000:50:04.5: reg 0x10: [mem 0xf147ff08000-0xf147ff0bfff 64bit]
[   87.992984] pci 0000:50:04.6: [8086:0e26] type 00 class 0x088000
[   87.993007] pci 0000:50:04.6: reg 0x10: [mem 0xf147ff04000-0xf147ff07fff 64bit]
[   87.993221] pci 0000:50:04.7: [8086:0e27] type 00 class 0x088000
[   87.993240] pci 0000:50:04.7: reg 0x10: [mem 0xf147ff00000-0xf147ff03fff 64bit]
[   87.993573] pci 0000:50:02.0: PCI bridge to [bus 51]
[   87.999152] pci 0000:50:02.2: PCI bridge to [bus 52]
[   88.004756] pci 0000:53:00.0: [1077:2031] type 00 class 0x0c0400
[   88.004774] pci 0000:53:00.0: reg 0x10: [mem 0xf147fe0a000-0xf147fe0bfff 64bit pref]
[   88.004786] pci 0000:53:00.0: reg 0x18: [mem 0xf147fe04000-0xf147fe07fff 64bit pref]
[   88.004798] pci 0000:53:00.0: reg 0x20: [mem 0xf147fd00000-0xf147fdfffff 64bit pref]
[   88.004810] pci 0000:53:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.004868] pci 0000:53:00.0: PME# supported from D3cold
[   88.005046] pci 0000:53:00.1: [1077:2031] type 00 class 0x0c0400
[   88.005063] pci 0000:53:00.1: reg 0x10: [mem 0xf147fe08000-0xf147fe09fff 64bit pref]
[   88.005077] pci 0000:53:00.1: reg 0x18: [mem 0xf147fe00000-0xf147fe03fff 64bit pref]
[   88.005089] pci 0000:53:00.1: reg 0x20: [mem 0xf147fc00000-0xf147fcfffff 64bit pref]
[   88.005098] pci 0000:53:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.005156] pci 0000:53:00.1: PME# supported from D3cold
[   88.005338] pci 0000:50:03.0: PCI bridge to [bus 53]
[   88.010812] pci 0000:50:03.0:   bridge window [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   88.010847] pci_bus 0000:50: on NUMA node 5
[   88.010849] acpi PNP0A08:05: Disabling ASPM (FADT indicates it is unsupported)
[   88.028476] ACPI: PCI Root Bridge [IO06] (domain 0000 [bus 60-6f])
[   88.035282] acpi PNP0A08:06: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.044416] acpi PNP0A08:06: PCIe AER handled by firmware
[   88.050580] acpi PNP0A08:06: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.059151] PCI host bridge to bus 0000:60
[   88.063656] pci_bus 0000:60: root bus resource [bus 60-6f]
[   88.069695] pci_bus 0000:60: root bus resource [mem 0xa8000000-0xabefffff window]
[   88.077930] pci_bus 0000:60: root bus resource [mem 0xf1800000000-0xf187fffffff window]
[   88.086757] pci 0000:60:00.0: [8086:0e00] type 00 class 0x060000
[   88.086847] pci 0000:60:00.0: PME# supported from D0 D3hot D3cold
[   88.087054] pci 0000:60:02.0: [8086:0e04] type 01 class 0x060400
[   88.087170] pci 0000:60:02.0: PME# supported from D0 D3hot D3cold
[   88.087355] pci 0000:60:02.2: [8086:0e06] type 01 class 0x060400
[   88.087463] pci 0000:60:02.2: PME# supported from D0 D3hot D3cold
[   88.087654] pci 0000:60:03.0: [8086:0e08] type 01 class 0x060400
[   88.087764] pci 0000:60:03.0: PME# supported from D0 D3hot D3cold
[   88.087946] pci 0000:60:04.0: [8086:0e20] type 00 class 0x088000
[   88.087968] pci 0000:60:04.0: reg 0x10: [mem 0xf187ff1c000-0xf187ff1ffff 64bit]
[   88.088195] pci 0000:60:04.1: [8086:0e21] type 00 class 0x088000
[   88.088214] pci 0000:60:04.1: reg 0x10: [mem 0xf187ff18000-0xf187ff1bfff 64bit]
[   88.088437] pci 0000:60:04.2: [8086:0e22] type 00 class 0x088000
[   88.088458] pci 0000:60:04.2: reg 0x10: [mem 0xf187ff14000-0xf187ff17fff 64bit]
[   88.088676] pci 0000:60:04.3: [8086:0e23] type 00 class 0x088000
[   88.088696] pci 0000:60:04.3: reg 0x10: [mem 0xf187ff10000-0xf187ff13fff 64bit]
[   88.088905] pci 0000:60:04.4: [8086:0e24] type 00 class 0x088000
[   88.088926] pci 0000:60:04.4: reg 0x10: [mem 0xf187ff0c000-0xf187ff0ffff 64bit]
[   88.089142] pci 0000:60:04.5: [8086:0e25] type 00 class 0x088000
[   88.089161] pci 0000:60:04.5: reg 0x10: [mem 0xf187ff08000-0xf187ff0bfff 64bit]
[   88.089365] pci 0000:60:04.6: [8086:0e26] type 00 class 0x088000
[   88.089385] pci 0000:60:04.6: reg 0x10: [mem 0xf187ff04000-0xf187ff07fff 64bit]
[   88.089603] pci 0000:60:04.7: [8086:0e27] type 00 class 0x088000
[   88.089622] pci 0000:60:04.7: reg 0x10: [mem 0xf187ff00000-0xf187ff03fff 64bit]
[   88.089849] pci 0000:60:11.0: [8086:1d3e] type 01 class 0x060400
[   88.089971] pci 0000:60:11.0: PME# supported from D0 D3hot D3cold
[   88.090140] pci 0000:60:1c.0: [8086:1d1e] type 01 class 0x060400
[   88.090254] pci 0000:60:1c.0: PME# supported from D0 D3hot D3cold
[   88.090461] pci 0000:60:1d.0: [8086:1d26] type 00 class 0x0c0320
[   88.090486] pci 0000:60:1d.0: reg 0x10: [mem 0xa8600000-0xa86003ff]
[   88.090600] pci 0000:60:1d.0: PME# supported from D0 D3hot D3cold
[   88.090776] pci 0000:60:1f.0: [8086:1d41] type 00 class 0x060100
[   88.091156] pci 0000:61:00.0: [8086:10f8] type 00 class 0x020000
[   88.091169] pci 0000:61:00.0: reg 0x10: [mem 0xa8400000-0xa84fffff]
[   88.091184] pci 0000:61:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.091194] pci 0000:61:00.0: reg 0x1c: [mem 0xa8504000-0xa8507fff]
[   88.091217] pci 0000:61:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.091272] pci 0000:61:00.0: PME# supported from D0 D3hot D3cold
[   88.091309] pci 0000:61:00.0: reg 0x184: [mem 0xf187fa00000-0xf187fa03fff 64bit pref]
[   88.091325] pci 0000:61:00.0: reg 0x190: [mem 0xf187f900000-0xf187f903fff 64bit pref]
[   88.091503] pci 0000:61:00.1: [8086:10f8] type 00 class 0x020000
[   88.091520] pci 0000:61:00.1: reg 0x10: [mem 0xa8300000-0xa83fffff]
[   88.091533] pci 0000:61:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.091542] pci 0000:61:00.1: reg 0x1c: [mem 0xa8500000-0xa8503fff]
[   88.091565] pci 0000:61:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.091622] pci 0000:61:00.1: PME# supported from D0 D3hot D3cold
[   88.091656] pci 0000:61:00.1: reg 0x184: [mem 0xf187f800000-0xf187f803fff 64bit pref]
[   88.091671] pci 0000:61:00.1: reg 0x190: [mem 0xf187f700000-0xf187f703fff 64bit pref]
[   88.102800] pci 0000:60:02.0: PCI bridge to [bus 61-62]
[   88.108580] pci 0000:60:02.0:   bridge window [mem 0xa8300000-0xa85fffff]
[   88.108589] pci 0000:60:02.0:   bridge window [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   88.108714] pci 0000:63:00.0: [8086:10f8] type 00 class 0x020000
[   88.108726] pci 0000:63:00.0: reg 0x10: [mem 0xa8100000-0xa81fffff]
[   88.108745] pci 0000:63:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.108755] pci 0000:63:00.0: reg 0x1c: [mem 0xa8204000-0xa8207fff]
[   88.108775] pci 0000:63:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.108835] pci 0000:63:00.0: PME# supported from D0 D3hot D3cold
[   88.108874] pci 0000:63:00.0: reg 0x184: [mem 0xf187fe00000-0xf187fe03fff 64bit pref]
[   88.108892] pci 0000:63:00.0: reg 0x190: [mem 0xf187fd00000-0xf187fd03fff 64bit pref]
[   88.109078] pci 0000:63:00.1: [8086:10f8] type 00 class 0x020000
[   88.109091] pci 0000:63:00.1: reg 0x10: [mem 0xa8000000-0xa80fffff]
[   88.109108] pci 0000:63:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.109115] pci 0000:63:00.1: reg 0x1c: [mem 0xa8200000-0xa8203fff]
[   88.109138] pci 0000:63:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.109193] pci 0000:63:00.1: PME# supported from D0 D3hot D3cold
[   88.109224] pci 0000:63:00.1: reg 0x184: [mem 0xf187fc00000-0xf187fc03fff 64bit pref]
[   88.109240] pci 0000:63:00.1: reg 0x190: [mem 0xf187fb00000-0xf187fb03fff 64bit pref]
[   88.116635] pci 0000:60:02.2: PCI bridge to [bus 63-64]
[   88.122395] pci 0000:60:02.2:   bridge window [mem 0xa8000000-0xa82fffff]
[   88.122401] pci 0000:60:02.2:   bridge window [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   88.122520] pci 0000:60:03.0: PCI bridge to [bus 65]
[   88.128111] pci 0000:60:11.0: PCI bridge to [bus 66]
[   88.133726] pci 0000:67:00.0: [103c:3306] type 00 class 0x088000
[   88.133754] pci 0000:67:00.0: reg 0x10: [io  0x0000-0x00ff]
[   88.133771] pci 0000:67:00.0: reg 0x14: [mem 0xabd88000-0xabd881ff]
[   88.133790] pci 0000:67:00.0: reg 0x18: [io  0x0000-0x00ff]
[   88.134092] pci 0000:67:00.2: [103c:3307] type 00 class 0x088000
[   88.134120] pci 0000:67:00.2: reg 0x10: [io  0x0000-0x00ff]
[   88.134136] pci 0000:67:00.2: reg 0x14: [mem 0xabd88400-0xabd884ff]
[   88.134153] pci 0000:67:00.2: reg 0x18: [mem 0xabb00000-0xabbfffff]
[   88.134170] pci 0000:67:00.2: reg 0x1c: [mem 0xabd00000-0xabd7ffff]
[   88.134190] pci 0000:67:00.2: reg 0x20: [mem 0xabd80000-0xabd87fff]
[   88.134210] pci 0000:67:00.2: reg 0x24: [mem 0xabc00000-0xabcfffff]
[   88.134227] pci 0000:67:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   88.134319] pci 0000:67:00.2: PME# supported from D0 D3hot D3cold
[   88.141615] pci 0000:60:1c.0: PCI bridge to [bus 67]
[   88.147087] pci 0000:60:1c.0:   bridge window [mem 0xabb00000-0xabefffff]
[   88.147094] pci 0000:60:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   88.147151] pci_bus 0000:60: on NUMA node 6
[   88.147152] acpi PNP0A08:06: Disabling ASPM (FADT indicates it is unsupported)
[   88.155298] ACPI: PCI Root Bridge [IO07] (domain 0000 [bus 70-7b])
[   88.162100] acpi PNP0A08:07: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.171243] acpi PNP0A08:07: PCIe AER handled by firmware
[   88.177428] acpi PNP0A08:07: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.185987] PCI host bridge to bus 0000:70
[   88.190497] pci_bus 0000:70: root bus resource [bus 70-7b]
[   88.196535] pci_bus 0000:70: root bus resource [mem 0xac000000-0xafff7fff window]
[   88.204772] pci_bus 0000:70: root bus resource [mem 0xf1c00000000-0xf1c7fffffff window]
[   88.213602] pci 0000:70:02.0: [8086:0e04] type 01 class 0x060400
[   88.213712] pci 0000:70:02.0: PME# supported from D0 D3hot D3cold
[   88.213898] pci 0000:70:02.2: [8086:0e06] type 01 class 0x060400
[   88.214006] pci 0000:70:02.2: PME# supported from D0 D3hot D3cold
[   88.214182] pci 0000:70:03.0: [8086:0e08] type 01 class 0x060400
[   88.214291] pci 0000:70:03.0: PME# supported from D0 D3hot D3cold
[   88.214478] pci 0000:70:04.0: [8086:0e20] type 00 class 0x088000
[   88.214498] pci 0000:70:04.0: reg 0x10: [mem 0xf1c7ff1c000-0xf1c7ff1ffff 64bit]
[   88.214755] pci 0000:70:04.1: [8086:0e21] type 00 class 0x088000
[   88.214774] pci 0000:70:04.1: reg 0x10: [mem 0xf1c7ff18000-0xf1c7ff1bfff 64bit]
[   88.214997] pci 0000:70:04.2: [8086:0e22] type 00 class 0x088000
[   88.215019] pci 0000:70:04.2: reg 0x10: [mem 0xf1c7ff14000-0xf1c7ff17fff 64bit]
[   88.215230] pci 0000:70:04.3: [8086:0e23] type 00 class 0x088000
[   88.215250] pci 0000:70:04.3: reg 0x10: [mem 0xf1c7ff10000-0xf1c7ff13fff 64bit]
[   88.215476] pci 0000:70:04.4: [8086:0e24] type 00 class 0x088000
[   88.215495] pci 0000:70:04.4: reg 0x10: [mem 0xf1c7ff0c000-0xf1c7ff0ffff 64bit]
[   88.215716] pci 0000:70:04.5: [8086:0e25] type 00 class 0x088000
[   88.215735] pci 0000:70:04.5: reg 0x10: [mem 0xf1c7ff08000-0xf1c7ff0bfff 64bit]
[   88.215966] pci 0000:70:04.6: [8086:0e26] type 00 class 0x088000
[   88.215987] pci 0000:70:04.6: reg 0x10: [mem 0xf1c7ff04000-0xf1c7ff07fff 64bit]
[   88.216229] pci 0000:70:04.7: [8086:0e27] type 00 class 0x088000
[   88.216250] pci 0000:70:04.7: reg 0x10: [mem 0xf1c7ff00000-0xf1c7ff03fff 64bit]
[   88.216607] pci 0000:70:02.0: PCI bridge to [bus 71]
[   88.222203] pci 0000:70:02.2: PCI bridge to [bus 72]
[   88.227795] pci 0000:73:00.0: [1077:2031] type 00 class 0x0c0400
[   88.227813] pci 0000:73:00.0: reg 0x10: [mem 0xf1c7fe0a000-0xf1c7fe0bfff 64bit pref]
[   88.227825] pci 0000:73:00.0: reg 0x18: [mem 0xf1c7fe04000-0xf1c7fe07fff 64bit pref]
[   88.227837] pci 0000:73:00.0: reg 0x20: [mem 0xf1c7fd00000-0xf1c7fdfffff 64bit pref]
[   88.227848] pci 0000:73:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.227906] pci 0000:73:00.0: PME# supported from D3cold
[   88.228104] pci 0000:73:00.1: [1077:2031] type 00 class 0x0c0400
[   88.228120] pci 0000:73:00.1: reg 0x10: [mem 0xf1c7fe08000-0xf1c7fe09fff 64bit pref]
[   88.228132] pci 0000:73:00.1: reg 0x18: [mem 0xf1c7fe00000-0xf1c7fe03fff 64bit pref]
[   88.228144] pci 0000:73:00.1: reg 0x20: [mem 0xf1c7fc00000-0xf1c7fcfffff 64bit pref]
[   88.228153] pci 0000:73:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.228204] pci 0000:73:00.1: PME# supported from D3cold
[   88.228385] pci 0000:70:03.0: PCI bridge to [bus 73]
[   88.233855] pci 0000:70:03.0:   bridge window [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   88.233889] pci_bus 0000:70: on NUMA node 7
[   88.233890] acpi PNP0A08:07: Disabling ASPM (FADT indicates it is unsupported)
[   88.252055] ACPI: PCI Root Bridge [IO08] (domain 0000 [bus 84-8f])
[   88.258859] acpi PNP0A08:08: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.267992] acpi PNP0A08:08: PCIe AER handled by firmware
[   88.274191] acpi PNP0A08:08: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.282765] PCI host bridge to bus 0000:84
[   88.287273] pci_bus 0000:84: root bus resource [bus 84-8f]
[   88.293311] pci_bus 0000:84: root bus resource [mem 0xb0000000-0xb3efffff window]
[   88.301551] pci_bus 0000:84: root bus resource [mem 0xf2000000000-0xf207fffffff window]
[   88.310383] pci 0000:84:00.0: [8086:0e00] type 00 class 0x060000
[   88.310474] pci 0000:84:00.0: PME# supported from D0 D3hot D3cold
[   88.310669] pci 0000:84:02.0: [8086:0e04] type 01 class 0x060400
[   88.310779] pci 0000:84:02.0: PME# supported from D0 D3hot D3cold
[   88.310973] pci 0000:84:02.2: [8086:0e06] type 01 class 0x060400
[   88.311082] pci 0000:84:02.2: PME# supported from D0 D3hot D3cold
[   88.311273] pci 0000:84:03.0: [8086:0e08] type 01 class 0x060400
[   88.311383] pci 0000:84:03.0: PME# supported from D0 D3hot D3cold
[   88.311557] pci 0000:84:04.0: [8086:0e20] type 00 class 0x088000
[   88.311577] pci 0000:84:04.0: reg 0x10: [mem 0xf207ff1c000-0xf207ff1ffff 64bit]
[   88.311845] pci 0000:84:04.1: [8086:0e21] type 00 class 0x088000
[   88.311864] pci 0000:84:04.1: reg 0x10: [mem 0xf207ff18000-0xf207ff1bfff 64bit]
[   88.312106] pci 0000:84:04.2: [8086:0e22] type 00 class 0x088000
[   88.312127] pci 0000:84:04.2: reg 0x10: [mem 0xf207ff14000-0xf207ff17fff 64bit]
[   88.312347] pci 0000:84:04.3: [8086:0e23] type 00 class 0x088000
[   88.312366] pci 0000:84:04.3: reg 0x10: [mem 0xf207ff10000-0xf207ff13fff 64bit]
[   88.312587] pci 0000:84:04.4: [8086:0e24] type 00 class 0x088000
[   88.312609] pci 0000:84:04.4: reg 0x10: [mem 0xf207ff0c000-0xf207ff0ffff 64bit]
[   88.312827] pci 0000:84:04.5: [8086:0e25] type 00 class 0x088000
[   88.312850] pci 0000:84:04.5: reg 0x10: [mem 0xf207ff08000-0xf207ff0bfff 64bit]
[   88.313062] pci 0000:84:04.6: [8086:0e26] type 00 class 0x088000
[   88.313084] pci 0000:84:04.6: reg 0x10: [mem 0xf207ff04000-0xf207ff07fff 64bit]
[   88.313309] pci 0000:84:04.7: [8086:0e27] type 00 class 0x088000
[   88.313332] pci 0000:84:04.7: reg 0x10: [mem 0xf207ff00000-0xf207ff03fff 64bit]
[   88.313566] pci 0000:84:11.0: [8086:1d3e] type 01 class 0x060400
[   88.313686] pci 0000:84:11.0: PME# supported from D0 D3hot D3cold
[   88.313876] pci 0000:84:1c.0: [8086:1d1e] type 01 class 0x060400
[   88.313987] pci 0000:84:1c.0: PME# supported from D0 D3hot D3cold
[   88.314184] pci 0000:84:1d.0: [8086:1d26] type 00 class 0x0c0320
[   88.314210] pci 0000:84:1d.0: reg 0x10: [mem 0xb0600000-0xb06003ff]
[   88.314326] pci 0000:84:1d.0: PME# supported from D0 D3hot D3cold
[   88.314498] pci 0000:84:1f.0: [8086:1d41] type 00 class 0x060100
[   88.314895] pci 0000:85:00.0: [8086:10f8] type 00 class 0x020000
[   88.314908] pci 0000:85:00.0: reg 0x10: [mem 0xb0400000-0xb04fffff]
[   88.314922] pci 0000:85:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.314933] pci 0000:85:00.0: reg 0x1c: [mem 0xb0504000-0xb0507fff]
[   88.314953] pci 0000:85:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.315012] pci 0000:85:00.0: PME# supported from D0 D3hot D3cold
[   88.315052] pci 0000:85:00.0: reg 0x184: [mem 0xf207fa00000-0xf207fa03fff 64bit pref]
[   88.315067] pci 0000:85:00.0: reg 0x190: [mem 0xf207f900000-0xf207f903fff 64bit pref]
[   88.315265] pci 0000:85:00.1: [8086:10f8] type 00 class 0x020000
[   88.315278] pci 0000:85:00.1: reg 0x10: [mem 0xb0300000-0xb03fffff]
[   88.315292] pci 0000:85:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.315300] pci 0000:85:00.1: reg 0x1c: [mem 0xb0500000-0xb0503fff]
[   88.315320] pci 0000:85:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.315381] pci 0000:85:00.1: PME# supported from D0 D3hot D3cold
[   88.315416] pci 0000:85:00.1: reg 0x184: [mem 0xf207f800000-0xf207f803fff 64bit pref]
[   88.315431] pci 0000:85:00.1: reg 0x190: [mem 0xf207f700000-0xf207f703fff 64bit pref]
[   88.322416] pci 0000:84:02.0: PCI bridge to [bus 85-86]
[   88.328191] pci 0000:84:02.0:   bridge window [mem 0xb0300000-0xb05fffff]
[   88.328202] pci 0000:84:02.0:   bridge window [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   88.328331] pci 0000:87:00.0: [8086:10f8] type 00 class 0x020000
[   88.328344] pci 0000:87:00.0: reg 0x10: [mem 0xb0100000-0xb01fffff]
[   88.328361] pci 0000:87:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.328368] pci 0000:87:00.0: reg 0x1c: [mem 0xb0204000-0xb0207fff]
[   88.328393] pci 0000:87:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.328451] pci 0000:87:00.0: PME# supported from D0 D3hot D3cold
[   88.328487] pci 0000:87:00.0: reg 0x184: [mem 0xf207fe00000-0xf207fe03fff 64bit pref]
[   88.328505] pci 0000:87:00.0: reg 0x190: [mem 0xf207fd00000-0xf207fd03fff 64bit pref]
[   88.328710] pci 0000:87:00.1: [8086:10f8] type 00 class 0x020000
[   88.328726] pci 0000:87:00.1: reg 0x10: [mem 0xb0000000-0xb00fffff]
[   88.328740] pci 0000:87:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.328751] pci 0000:87:00.1: reg 0x1c: [mem 0xb0200000-0xb0203fff]
[   88.328772] pci 0000:87:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.328835] pci 0000:87:00.1: PME# supported from D0 D3hot D3cold
[   88.328866] pci 0000:87:00.1: reg 0x184: [mem 0xf207fc00000-0xf207fc03fff 64bit pref]
[   88.328884] pci 0000:87:00.1: reg 0x190: [mem 0xf207fb00000-0xf207fb03fff 64bit pref]
[   88.336228] pci 0000:84:02.2: PCI bridge to [bus 87-88]
[   88.342003] pci 0000:84:02.2:   bridge window [mem 0xb0000000-0xb02fffff]
[   88.342009] pci 0000:84:02.2:   bridge window [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   88.342129] pci 0000:84:03.0: PCI bridge to [bus 89]
[   88.347758] pci 0000:84:11.0: PCI bridge to [bus 8a]
[   88.353388] pci 0000:8b:00.0: [103c:3306] type 00 class 0x088000
[   88.353417] pci 0000:8b:00.0: reg 0x10: [io  0x0000-0x00ff]
[   88.353434] pci 0000:8b:00.0: reg 0x14: [mem 0xb3d88000-0xb3d881ff]
[   88.353451] pci 0000:8b:00.0: reg 0x18: [io  0x0000-0x00ff]
[   88.353772] pci 0000:8b:00.2: [103c:3307] type 00 class 0x088000
[   88.353803] pci 0000:8b:00.2: reg 0x10: [io  0x0000-0x00ff]
[   88.353819] pci 0000:8b:00.2: reg 0x14: [mem 0xb3d88400-0xb3d884ff]
[   88.353837] pci 0000:8b:00.2: reg 0x18: [mem 0xb3b00000-0xb3bfffff]
[   88.353856] pci 0000:8b:00.2: reg 0x1c: [mem 0xb3d00000-0xb3d7ffff]
[   88.353876] pci 0000:8b:00.2: reg 0x20: [mem 0xb3d80000-0xb3d87fff]
[   88.353893] pci 0000:8b:00.2: reg 0x24: [mem 0xb3c00000-0xb3cfffff]
[   88.353911] pci 0000:8b:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   88.354008] pci 0000:8b:00.2: PME# supported from D0 D3hot D3cold
[   88.361295] pci 0000:84:1c.0: PCI bridge to [bus 8b]
[   88.366762] pci 0000:84:1c.0:   bridge window [mem 0xb3b00000-0xb3efffff]
[   88.366769] pci 0000:84:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   88.366825] pci_bus 0000:84: on NUMA node 8
[   88.366826] acpi PNP0A08:08: Disabling ASPM (FADT indicates it is unsupported)
[   88.374996] ACPI: PCI Root Bridge [IO09] (domain 0000 [bus 90-9f])
[   88.381803] acpi PNP0A08:09: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.390942] acpi PNP0A08:09: PCIe AER handled by firmware
[   88.397142] acpi PNP0A08:09: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.405711] PCI host bridge to bus 0000:90
[   88.410225] pci_bus 0000:90: root bus resource [bus 90-9f]
[   88.416261] pci_bus 0000:90: root bus resource [mem 0xb4000000-0xb7ff7fff window]
[   88.424500] pci_bus 0000:90: root bus resource [mem 0xf2400000000-0xf247fffffff window]
[   88.433348] pci 0000:90:02.0: [8086:0e04] type 01 class 0x060400
[   88.433460] pci 0000:90:02.0: PME# supported from D0 D3hot D3cold
[   88.433693] pci 0000:90:02.2: [8086:0e06] type 01 class 0x060400
[   88.433807] pci 0000:90:02.2: PME# supported from D0 D3hot D3cold
[   88.433980] pci 0000:90:03.0: [8086:0e08] type 01 class 0x060400
[   88.434099] pci 0000:90:03.0: PME# supported from D0 D3hot D3cold
[   88.434291] pci 0000:90:04.0: [8086:0e20] type 00 class 0x088000
[   88.434315] pci 0000:90:04.0: reg 0x10: [mem 0xf247ff1c000-0xf247ff1ffff 64bit]
[   88.434521] pci 0000:90:04.1: [8086:0e21] type 00 class 0x088000
[   88.434540] pci 0000:90:04.1: reg 0x10: [mem 0xf247ff18000-0xf247ff1bfff 64bit]
[   88.434756] pci 0000:90:04.2: [8086:0e22] type 00 class 0x088000
[   88.434775] pci 0000:90:04.2: reg 0x10: [mem 0xf247ff14000-0xf247ff17fff 64bit]
[   88.435016] pci 0000:90:04.3: [8086:0e23] type 00 class 0x088000
[   88.435039] pci 0000:90:04.3: reg 0x10: [mem 0xf247ff10000-0xf247ff13fff 64bit]
[   88.435263] pci 0000:90:04.4: [8086:0e24] type 00 class 0x088000
[   88.435284] pci 0000:90:04.4: reg 0x10: [mem 0xf247ff0c000-0xf247ff0ffff 64bit]
[   88.435515] pci 0000:90:04.5: [8086:0e25] type 00 class 0x088000
[   88.435534] pci 0000:90:04.5: reg 0x10: [mem 0xf247ff08000-0xf247ff0bfff 64bit]
[   88.435759] pci 0000:90:04.6: [8086:0e26] type 00 class 0x088000
[   88.435778] pci 0000:90:04.6: reg 0x10: [mem 0xf247ff04000-0xf247ff07fff 64bit]
[   88.436000] pci 0000:90:04.7: [8086:0e27] type 00 class 0x088000
[   88.436019] pci 0000:90:04.7: reg 0x10: [mem 0xf247ff00000-0xf247ff03fff 64bit]
[   88.436362] pci 0000:90:02.0: PCI bridge to [bus 91]
[   88.441969] pci 0000:90:02.2: PCI bridge to [bus 92]
[   88.447592] pci 0000:93:00.0: [1077:2031] type 00 class 0x0c0400
[   88.447612] pci 0000:93:00.0: reg 0x10: [mem 0xf247fe0a000-0xf247fe0bfff 64bit pref]
[   88.447624] pci 0000:93:00.0: reg 0x18: [mem 0xf247fe04000-0xf247fe07fff 64bit pref]
[   88.447637] pci 0000:93:00.0: reg 0x20: [mem 0xf247fd00000-0xf247fdfffff 64bit pref]
[   88.447645] pci 0000:93:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.447704] pci 0000:93:00.0: PME# supported from D3cold
[   88.447928] pci 0000:93:00.1: [1077:2031] type 00 class 0x0c0400
[   88.447945] pci 0000:93:00.1: reg 0x10: [mem 0xf247fe08000-0xf247fe09fff 64bit pref]
[   88.447958] pci 0000:93:00.1: reg 0x18: [mem 0xf247fe00000-0xf247fe03fff 64bit pref]
[   88.447970] pci 0000:93:00.1: reg 0x20: [mem 0xf247fc00000-0xf247fcfffff 64bit pref]
[   88.447981] pci 0000:93:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.448042] pci 0000:93:00.1: PME# supported from D3cold
[   88.448225] pci 0000:90:03.0: PCI bridge to [bus 93]
[   88.453699] pci 0000:90:03.0:   bridge window [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   88.453736] pci_bus 0000:90: on NUMA node 9
[   88.453738] acpi PNP0A08:09: Disabling ASPM (FADT indicates it is unsupported)
[   88.472751] ACPI: PCI Root Bridge [IO0A] (domain 0000 [bus a0-af])
[   88.479556] acpi PNP0A08:0a: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.488701] acpi PNP0A08:0a: PCIe AER handled by firmware
[   88.494885] acpi PNP0A08:0a: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.503455] PCI host bridge to bus 0000:a0
[   88.507964] pci_bus 0000:a0: root bus resource [bus a0-af]
[   88.514003] pci_bus 0000:a0: root bus resource [mem 0xb8000000-0xbbefffff window]
[   88.522243] pci_bus 0000:a0: root bus resource [mem 0xf2800000000-0xf287fffffff window]
[   88.531074] pci 0000:a0:00.0: [8086:0e00] type 00 class 0x060000
[   88.531166] pci 0000:a0:00.0: PME# supported from D0 D3hot D3cold
[   88.531357] pci 0000:a0:02.0: [8086:0e04] type 01 class 0x060400
[   88.531466] pci 0000:a0:02.0: PME# supported from D0 D3hot D3cold
[   88.531642] pci 0000:a0:02.2: [8086:0e06] type 01 class 0x060400
[   88.531752] pci 0000:a0:02.2: PME# supported from D0 D3hot D3cold
[   88.531934] pci 0000:a0:03.0: [8086:0e08] type 01 class 0x060400
[   88.532044] pci 0000:a0:03.0: PME# supported from D0 D3hot D3cold
[   88.532251] pci 0000:a0:04.0: [8086:0e20] type 00 class 0x088000
[   88.532272] pci 0000:a0:04.0: reg 0x10: [mem 0xf287ff1c000-0xf287ff1ffff 64bit]
[   88.532483] pci 0000:a0:04.1: [8086:0e21] type 00 class 0x088000
[   88.532502] pci 0000:a0:04.1: reg 0x10: [mem 0xf287ff18000-0xf287ff1bfff 64bit]
[   88.532738] pci 0000:a0:04.2: [8086:0e22] type 00 class 0x088000
[   88.532761] pci 0000:a0:04.2: reg 0x10: [mem 0xf287ff14000-0xf287ff17fff 64bit]
[   88.532976] pci 0000:a0:04.3: [8086:0e23] type 00 class 0x088000
[   88.532995] pci 0000:a0:04.3: reg 0x10: [mem 0xf287ff10000-0xf287ff13fff 64bit]
[   88.533208] pci 0000:a0:04.4: [8086:0e24] type 00 class 0x088000
[   88.533229] pci 0000:a0:04.4: reg 0x10: [mem 0xf287ff0c000-0xf287ff0ffff 64bit]
[   88.533436] pci 0000:a0:04.5: [8086:0e25] type 00 class 0x088000
[   88.533456] pci 0000:a0:04.5: reg 0x10: [mem 0xf287ff08000-0xf287ff0bfff 64bit]
[   88.533686] pci 0000:a0:04.6: [8086:0e26] type 00 class 0x088000
[   88.533705] pci 0000:a0:04.6: reg 0x10: [mem 0xf287ff04000-0xf287ff07fff 64bit]
[   88.533923] pci 0000:a0:04.7: [8086:0e27] type 00 class 0x088000
[   88.533943] pci 0000:a0:04.7: reg 0x10: [mem 0xf287ff00000-0xf287ff03fff 64bit]
[   88.534186] pci 0000:a0:11.0: [8086:1d3e] type 01 class 0x060400
[   88.534307] pci 0000:a0:11.0: PME# supported from D0 D3hot D3cold
[   88.534530] pci 0000:a0:1c.0: [8086:1d1e] type 01 class 0x060400
[   88.534636] pci 0000:a0:1c.0: PME# supported from D0 D3hot D3cold
[   88.534842] pci 0000:a0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   88.534867] pci 0000:a0:1d.0: reg 0x10: [mem 0xb8600000-0xb86003ff]
[   88.534982] pci 0000:a0:1d.0: PME# supported from D0 D3hot D3cold
[   88.535176] pci 0000:a0:1f.0: [8086:1d41] type 00 class 0x060100
[   88.535573] pci 0000:a1:00.0: [8086:10f8] type 00 class 0x020000
[   88.535586] pci 0000:a1:00.0: reg 0x10: [mem 0xb8400000-0xb84fffff]
[   88.535601] pci 0000:a1:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.535611] pci 0000:a1:00.0: reg 0x1c: [mem 0xb8504000-0xb8507fff]
[   88.535631] pci 0000:a1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.535690] pci 0000:a1:00.0: PME# supported from D0 D3hot D3cold
[   88.535729] pci 0000:a1:00.0: reg 0x184: [mem 0xf287fa00000-0xf287fa03fff 64bit pref]
[   88.535744] pci 0000:a1:00.0: reg 0x190: [mem 0xf287f900000-0xf287f903fff 64bit pref]
[   88.535925] pci 0000:a1:00.1: [8086:10f8] type 00 class 0x020000
[   88.535937] pci 0000:a1:00.1: reg 0x10: [mem 0xb8300000-0xb83fffff]
[   88.535951] pci 0000:a1:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.535959] pci 0000:a1:00.1: reg 0x1c: [mem 0xb8500000-0xb8503fff]
[   88.535982] pci 0000:a1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.536039] pci 0000:a1:00.1: PME# supported from D0 D3hot D3cold
[   88.536072] pci 0000:a1:00.1: reg 0x184: [mem 0xf287f800000-0xf287f803fff 64bit pref]
[   88.536087] pci 0000:a1:00.1: reg 0x190: [mem 0xf287f700000-0xf287f703fff 64bit pref]
[   88.543106] pci 0000:a0:02.0: PCI bridge to [bus a1-a2]
[   88.548882] pci 0000:a0:02.0:   bridge window [mem 0xb8300000-0xb85fffff]
[   88.548890] pci 0000:a0:02.0:   bridge window [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   88.549027] pci 0000:a3:00.0: [8086:10f8] type 00 class 0x020000
[   88.549040] pci 0000:a3:00.0: reg 0x10: [mem 0xb8100000-0xb81fffff]
[   88.549057] pci 0000:a3:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.549068] pci 0000:a3:00.0: reg 0x1c: [mem 0xb8204000-0xb8207fff]
[   88.549088] pci 0000:a3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.549149] pci 0000:a3:00.0: PME# supported from D0 D3hot D3cold
[   88.549186] pci 0000:a3:00.0: reg 0x184: [mem 0xf287fe00000-0xf287fe03fff 64bit pref]
[   88.549204] pci 0000:a3:00.0: reg 0x190: [mem 0xf287fd00000-0xf287fd03fff 64bit pref]
[   88.549388] pci 0000:a3:00.1: [8086:10f8] type 00 class 0x020000
[   88.549400] pci 0000:a3:00.1: reg 0x10: [mem 0xb8000000-0xb80fffff]
[   88.549414] pci 0000:a3:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.549422] pci 0000:a3:00.1: reg 0x1c: [mem 0xb8200000-0xb8203fff]
[   88.549445] pci 0000:a3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.549502] pci 0000:a3:00.1: PME# supported from D0 D3hot D3cold
[   88.549533] pci 0000:a3:00.1: reg 0x184: [mem 0xf287fc00000-0xf287fc03fff 64bit pref]
[   88.549548] pci 0000:a3:00.1: reg 0x190: [mem 0xf287fb00000-0xf287fb03fff 64bit pref]
[   88.556917] pci 0000:a0:02.2: PCI bridge to [bus a3-a4]
[   88.562694] pci 0000:a0:02.2:   bridge window [mem 0xb8000000-0xb82fffff]
[   88.562700] pci 0000:a0:02.2:   bridge window [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   88.562834] pci 0000:a0:03.0: PCI bridge to [bus a5]
[   88.568452] pci 0000:a0:11.0: PCI bridge to [bus a6]
[   88.574093] pci 0000:a7:00.0: [103c:3306] type 00 class 0x088000
[   88.574122] pci 0000:a7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   88.574139] pci 0000:a7:00.0: reg 0x14: [mem 0xbbd88000-0xbbd881ff]
[   88.574156] pci 0000:a7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   88.574470] pci 0000:a7:00.2: [103c:3307] type 00 class 0x088000
[   88.574504] pci 0000:a7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   88.574521] pci 0000:a7:00.2: reg 0x14: [mem 0xbbd88400-0xbbd884ff]
[   88.574538] pci 0000:a7:00.2: reg 0x18: [mem 0xbbb00000-0xbbbfffff]
[   88.574555] pci 0000:a7:00.2: reg 0x1c: [mem 0xbbd00000-0xbbd7ffff]
[   88.574574] pci 0000:a7:00.2: reg 0x20: [mem 0xbbd80000-0xbbd87fff]
[   88.574594] pci 0000:a7:00.2: reg 0x24: [mem 0xbbc00000-0xbbcfffff]
[   88.574611] pci 0000:a7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   88.574709] pci 0000:a7:00.2: PME# supported from D0 D3hot D3cold
[   88.581985] pci 0000:a0:1c.0: PCI bridge to [bus a7]
[   88.587454] pci 0000:a0:1c.0:   bridge window [mem 0xbbb00000-0xbbefffff]
[   88.587461] pci 0000:a0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   88.587518] pci_bus 0000:a0: on NUMA node 10
[   88.587520] acpi PNP0A08:0a: Disabling ASPM (FADT indicates it is unsupported)
[   88.595667] ACPI: PCI Root Bridge [IO0B] (domain 0000 [bus b0-bf])
[   88.602473] acpi PNP0A08:0b: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.611617] acpi PNP0A08:0b: PCIe AER handled by firmware
[   88.617816] acpi PNP0A08:0b: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.626385] PCI host bridge to bus 0000:b0
[   88.630895] pci_bus 0000:b0: root bus resource [bus b0-bf]
[   88.636936] pci_bus 0000:b0: root bus resource [mem 0xbc000000-0xbfff7fff window]
[   88.645173] pci_bus 0000:b0: root bus resource [mem 0xf2c00000000-0xf2c7fffffff window]
[   88.654000] pci 0000:b0:02.0: [8086:0e04] type 01 class 0x060400
[   88.654109] pci 0000:b0:02.0: PME# supported from D0 D3hot D3cold
[   88.654296] pci 0000:b0:02.2: [8086:0e06] type 01 class 0x060400
[   88.654403] pci 0000:b0:02.2: PME# supported from D0 D3hot D3cold
[   88.654619] pci 0000:b0:03.0: [8086:0e08] type 01 class 0x060400
[   88.654728] pci 0000:b0:03.0: PME# supported from D0 D3hot D3cold
[   88.654898] pci 0000:b0:04.0: [8086:0e20] type 00 class 0x088000
[   88.654919] pci 0000:b0:04.0: reg 0x10: [mem 0xf2c7ff1c000-0xf2c7ff1ffff 64bit]
[   88.655129] pci 0000:b0:04.1: [8086:0e21] type 00 class 0x088000
[   88.655148] pci 0000:b0:04.1: reg 0x10: [mem 0xf2c7ff18000-0xf2c7ff1bfff 64bit]
[   88.655369] pci 0000:b0:04.2: [8086:0e22] type 00 class 0x088000
[   88.655390] pci 0000:b0:04.2: reg 0x10: [mem 0xf2c7ff14000-0xf2c7ff17fff 64bit]
[   88.655608] pci 0000:b0:04.3: [8086:0e23] type 00 class 0x088000
[   88.655627] pci 0000:b0:04.3: reg 0x10: [mem 0xf2c7ff10000-0xf2c7ff13fff 64bit]
[   88.655846] pci 0000:b0:04.4: [8086:0e24] type 00 class 0x088000
[   88.655868] pci 0000:b0:04.4: reg 0x10: [mem 0xf2c7ff0c000-0xf2c7ff0ffff 64bit]
[   88.656078] pci 0000:b0:04.5: [8086:0e25] type 00 class 0x088000
[   88.656099] pci 0000:b0:04.5: reg 0x10: [mem 0xf2c7ff08000-0xf2c7ff0bfff 64bit]
[   88.656307] pci 0000:b0:04.6: [8086:0e26] type 00 class 0x088000
[   88.656326] pci 0000:b0:04.6: reg 0x10: [mem 0xf2c7ff04000-0xf2c7ff07fff 64bit]
[   88.656550] pci 0000:b0:04.7: [8086:0e27] type 00 class 0x088000
[   88.656576] pci 0000:b0:04.7: reg 0x10: [mem 0xf2c7ff00000-0xf2c7ff03fff 64bit]
[   88.656919] pci 0000:b0:02.0: PCI bridge to [bus b1]
[   88.662495] pci 0000:b0:02.2: PCI bridge to [bus b2]
[   88.668095] pci 0000:b3:00.0: [1077:2031] type 00 class 0x0c0400
[   88.668114] pci 0000:b3:00.0: reg 0x10: [mem 0xf2c7fe0a000-0xf2c7fe0bfff 64bit pref]
[   88.668126] pci 0000:b3:00.0: reg 0x18: [mem 0xf2c7fe04000-0xf2c7fe07fff 64bit pref]
[   88.668138] pci 0000:b3:00.0: reg 0x20: [mem 0xf2c7fd00000-0xf2c7fdfffff 64bit pref]
[   88.668146] pci 0000:b3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.668205] pci 0000:b3:00.0: PME# supported from D3cold
[   88.668374] pci 0000:b3:00.1: [1077:2031] type 00 class 0x0c0400
[   88.668390] pci 0000:b3:00.1: reg 0x10: [mem 0xf2c7fe08000-0xf2c7fe09fff 64bit pref]
[   88.668402] pci 0000:b3:00.1: reg 0x18: [mem 0xf2c7fe00000-0xf2c7fe03fff 64bit pref]
[   88.668414] pci 0000:b3:00.1: reg 0x20: [mem 0xf2c7fc00000-0xf2c7fcfffff 64bit pref]
[   88.668429] pci 0000:b3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.668484] pci 0000:b3:00.1: PME# supported from D3cold
[   88.668661] pci 0000:b0:03.0: PCI bridge to [bus b3]
[   88.674133] pci 0000:b0:03.0:   bridge window [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   88.674167] pci_bus 0000:b0: on NUMA node 11
[   88.674168] acpi PNP0A08:0b: Disabling ASPM (FADT indicates it is unsupported)
[   88.693407] ACPI: PCI Root Bridge [IO0C] (domain 0000 [bus c0-cf])
[   88.700211] acpi PNP0A08:0c: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.709334] acpi PNP0A08:0c: PCIe AER handled by firmware
[   88.715534] acpi PNP0A08:0c: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.724082] PCI host bridge to bus 0000:c0
[   88.728589] pci_bus 0000:c0: root bus resource [bus c0-cf]
[   88.734624] pci_bus 0000:c0: root bus resource [mem 0xc0000000-0xc3efffff window]
[   88.742857] pci_bus 0000:c0: root bus resource [mem 0xf3000000000-0xf307fffffff window]
[   88.751680] pci 0000:c0:00.0: [8086:0e00] type 00 class 0x060000
[   88.751771] pci 0000:c0:00.0: PME# supported from D0 D3hot D3cold
[   88.751956] pci 0000:c0:02.0: [8086:0e04] type 01 class 0x060400
[   88.752063] pci 0000:c0:02.0: PME# supported from D0 D3hot D3cold
[   88.752254] pci 0000:c0:02.2: [8086:0e06] type 01 class 0x060400
[   88.752360] pci 0000:c0:02.2: PME# supported from D0 D3hot D3cold
[   88.752556] pci 0000:c0:03.0: [8086:0e08] type 01 class 0x060400
[   88.752668] pci 0000:c0:03.0: PME# supported from D0 D3hot D3cold
[   88.752854] pci 0000:c0:04.0: [8086:0e20] type 00 class 0x088000
[   88.752874] pci 0000:c0:04.0: reg 0x10: [mem 0xf307ff1c000-0xf307ff1ffff 64bit]
[   88.753103] pci 0000:c0:04.1: [8086:0e21] type 00 class 0x088000
[   88.753125] pci 0000:c0:04.1: reg 0x10: [mem 0xf307ff18000-0xf307ff1bfff 64bit]
[   88.753356] pci 0000:c0:04.2: [8086:0e22] type 00 class 0x088000
[   88.753376] pci 0000:c0:04.2: reg 0x10: [mem 0xf307ff14000-0xf307ff17fff 64bit]
[   88.753602] pci 0000:c0:04.3: [8086:0e23] type 00 class 0x088000
[   88.753621] pci 0000:c0:04.3: reg 0x10: [mem 0xf307ff10000-0xf307ff13fff 64bit]
[   88.753863] pci 0000:c0:04.4: [8086:0e24] type 00 class 0x088000
[   88.753884] pci 0000:c0:04.4: reg 0x10: [mem 0xf307ff0c000-0xf307ff0ffff 64bit]
[   88.754105] pci 0000:c0:04.5: [8086:0e25] type 00 class 0x088000
[   88.754128] pci 0000:c0:04.5: reg 0x10: [mem 0xf307ff08000-0xf307ff0bfff 64bit]
[   88.754360] pci 0000:c0:04.6: [8086:0e26] type 00 class 0x088000
[   88.754380] pci 0000:c0:04.6: reg 0x10: [mem 0xf307ff04000-0xf307ff07fff 64bit]
[   88.754606] pci 0000:c0:04.7: [8086:0e27] type 00 class 0x088000
[   88.754625] pci 0000:c0:04.7: reg 0x10: [mem 0xf307ff00000-0xf307ff03fff 64bit]
[   88.754860] pci 0000:c0:11.0: [8086:1d3e] type 01 class 0x060400
[   88.754981] pci 0000:c0:11.0: PME# supported from D0 D3hot D3cold
[   88.755165] pci 0000:c0:1c.0: [8086:1d1e] type 01 class 0x060400
[   88.755272] pci 0000:c0:1c.0: PME# supported from D0 D3hot D3cold
[   88.755476] pci 0000:c0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   88.755502] pci 0000:c0:1d.0: reg 0x10: [mem 0xc0600000-0xc06003ff]
[   88.755616] pci 0000:c0:1d.0: PME# supported from D0 D3hot D3cold
[   88.755799] pci 0000:c0:1f.0: [8086:1d41] type 00 class 0x060100
[   88.756186] pci 0000:c1:00.0: [8086:10f8] type 00 class 0x020000
[   88.756200] pci 0000:c1:00.0: reg 0x10: [mem 0xc0400000-0xc04fffff]
[   88.756214] pci 0000:c1:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.756222] pci 0000:c1:00.0: reg 0x1c: [mem 0xc0504000-0xc0507fff]
[   88.756246] pci 0000:c1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.756304] pci 0000:c1:00.0: PME# supported from D0 D3hot D3cold
[   88.756343] pci 0000:c1:00.0: reg 0x184: [mem 0xf307fa00000-0xf307fa03fff 64bit pref]
[   88.756359] pci 0000:c1:00.0: reg 0x190: [mem 0xf307f900000-0xf307f903fff 64bit pref]
[   88.756547] pci 0000:c1:00.1: [8086:10f8] type 00 class 0x020000
[   88.756566] pci 0000:c1:00.1: reg 0x10: [mem 0xc0300000-0xc03fffff]
[   88.756580] pci 0000:c1:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.756587] pci 0000:c1:00.1: reg 0x1c: [mem 0xc0500000-0xc0503fff]
[   88.756608] pci 0000:c1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.756666] pci 0000:c1:00.1: PME# supported from D0 D3hot D3cold
[   88.756703] pci 0000:c1:00.1: reg 0x184: [mem 0xf307f800000-0xf307f803fff 64bit pref]
[   88.756718] pci 0000:c1:00.1: reg 0x190: [mem 0xf307f700000-0xf307f703fff 64bit pref]
[   88.763719] pci 0000:c0:02.0: PCI bridge to [bus c1-c2]
[   88.769494] pci 0000:c0:02.0:   bridge window [mem 0xc0300000-0xc05fffff]
[   88.769500] pci 0000:c0:02.0:   bridge window [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   88.769646] pci 0000:c3:00.0: [8086:10f8] type 00 class 0x020000
[   88.769659] pci 0000:c3:00.0: reg 0x10: [mem 0xc0100000-0xc01fffff]
[   88.769673] pci 0000:c3:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.769680] pci 0000:c3:00.0: reg 0x1c: [mem 0xc0204000-0xc0207fff]
[   88.769704] pci 0000:c3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.769761] pci 0000:c3:00.0: PME# supported from D0 D3hot D3cold
[   88.769797] pci 0000:c3:00.0: reg 0x184: [mem 0xf307fe00000-0xf307fe03fff 64bit pref]
[   88.769815] pci 0000:c3:00.0: reg 0x190: [mem 0xf307fd00000-0xf307fd03fff 64bit pref]
[   88.769978] pci 0000:c3:00.1: [8086:10f8] type 00 class 0x020000
[   88.769994] pci 0000:c3:00.1: reg 0x10: [mem 0xc0000000-0xc00fffff]
[   88.770008] pci 0000:c3:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.770019] pci 0000:c3:00.1: reg 0x1c: [mem 0xc0200000-0xc0203fff]
[   88.770039] pci 0000:c3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.770098] pci 0000:c3:00.1: PME# supported from D0 D3hot D3cold
[   88.770131] pci 0000:c3:00.1: reg 0x184: [mem 0xf307fc00000-0xf307fc03fff 64bit pref]
[   88.770147] pci 0000:c3:00.1: reg 0x190: [mem 0xf307fb00000-0xf307fb03fff 64bit pref]
[   88.777529] pci 0000:c0:02.2: PCI bridge to [bus c3-c4]
[   88.783304] pci 0000:c0:02.2:   bridge window [mem 0xc0000000-0xc02fffff]
[   88.783313] pci 0000:c0:02.2:   bridge window [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   88.783446] pci 0000:c0:03.0: PCI bridge to [bus c5]
[   88.789041] pci 0000:c0:11.0: PCI bridge to [bus c6]
[   88.794680] pci 0000:c7:00.0: [103c:3306] type 00 class 0x088000
[   88.794712] pci 0000:c7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   88.794729] pci 0000:c7:00.0: reg 0x14: [mem 0xc3d88000-0xc3d881ff]
[   88.794745] pci 0000:c7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   88.795059] pci 0000:c7:00.2: [103c:3307] type 00 class 0x088000
[   88.795090] pci 0000:c7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   88.795107] pci 0000:c7:00.2: reg 0x14: [mem 0xc3d88400-0xc3d884ff]
[   88.795124] pci 0000:c7:00.2: reg 0x18: [mem 0xc3b00000-0xc3bfffff]
[   88.795142] pci 0000:c7:00.2: reg 0x1c: [mem 0xc3d00000-0xc3d7ffff]
[   88.795161] pci 0000:c7:00.2: reg 0x20: [mem 0xc3d80000-0xc3d87fff]
[   88.795178] pci 0000:c7:00.2: reg 0x24: [mem 0xc3c00000-0xc3cfffff]
[   88.795195] pci 0000:c7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   88.795288] pci 0000:c7:00.2: PME# supported from D0 D3hot D3cold
[   88.802549] pci 0000:c0:1c.0: PCI bridge to [bus c7]
[   88.808042] pci 0000:c0:1c.0:   bridge window [mem 0xc3b00000-0xc3efffff]
[   88.808049] pci 0000:c0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   88.808105] pci_bus 0000:c0: on NUMA node 12
[   88.808107] acpi PNP0A08:0c: Disabling ASPM (FADT indicates it is unsupported)
[   88.816255] ACPI: PCI Root Bridge [IO0D] (domain 0000 [bus d0-df])
[   88.823061] acpi PNP0A08:0d: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.832184] acpi PNP0A08:0d: PCIe AER handled by firmware
[   88.838348] acpi PNP0A08:0d: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.846898] PCI host bridge to bus 0000:d0
[   88.851407] pci_bus 0000:d0: root bus resource [bus d0-df]
[   88.857446] pci_bus 0000:d0: root bus resource [mem 0xc4000000-0xc7ff7fff window]
[   88.865684] pci_bus 0000:d0: root bus resource [mem 0xf3400000000-0xf347fffffff window]
[   88.874515] pci 0000:d0:02.0: [8086:0e04] type 01 class 0x060400
[   88.874625] pci 0000:d0:02.0: PME# supported from D0 D3hot D3cold
[   88.874812] pci 0000:d0:02.2: [8086:0e06] type 01 class 0x060400
[   88.874918] pci 0000:d0:02.2: PME# supported from D0 D3hot D3cold
[   88.875116] pci 0000:d0:03.0: [8086:0e08] type 01 class 0x060400
[   88.875230] pci 0000:d0:03.0: PME# supported from D0 D3hot D3cold
[   88.875409] pci 0000:d0:04.0: [8086:0e20] type 00 class 0x088000
[   88.875432] pci 0000:d0:04.0: reg 0x10: [mem 0xf347ff1c000-0xf347ff1ffff 64bit]
[   88.875662] pci 0000:d0:04.1: [8086:0e21] type 00 class 0x088000
[   88.875681] pci 0000:d0:04.1: reg 0x10: [mem 0xf347ff18000-0xf347ff1bfff 64bit]
[   88.875891] pci 0000:d0:04.2: [8086:0e22] type 00 class 0x088000
[   88.875910] pci 0000:d0:04.2: reg 0x10: [mem 0xf347ff14000-0xf347ff17fff 64bit]
[   88.876141] pci 0000:d0:04.3: [8086:0e23] type 00 class 0x088000
[   88.876163] pci 0000:d0:04.3: reg 0x10: [mem 0xf347ff10000-0xf347ff13fff 64bit]
[   88.876373] pci 0000:d0:04.4: [8086:0e24] type 00 class 0x088000
[   88.876395] pci 0000:d0:04.4: reg 0x10: [mem 0xf347ff0c000-0xf347ff0ffff 64bit]
[   88.876641] pci 0000:d0:04.5: [8086:0e25] type 00 class 0x088000
[   88.876661] pci 0000:d0:04.5: reg 0x10: [mem 0xf347ff08000-0xf347ff0bfff 64bit]
[   88.876874] pci 0000:d0:04.6: [8086:0e26] type 00 class 0x088000
[   88.876893] pci 0000:d0:04.6: reg 0x10: [mem 0xf347ff04000-0xf347ff07fff 64bit]
[   88.877116] pci 0000:d0:04.7: [8086:0e27] type 00 class 0x088000
[   88.877136] pci 0000:d0:04.7: reg 0x10: [mem 0xf347ff00000-0xf347ff03fff 64bit]
[   88.877469] pci 0000:d0:02.0: PCI bridge to [bus d1]
[   88.883057] pci 0000:d0:02.2: PCI bridge to [bus d2]
[   88.888654] pci 0000:d3:00.0: [1077:2031] type 00 class 0x0c0400
[   88.888675] pci 0000:d3:00.0: reg 0x10: [mem 0xf347fe0a000-0xf347fe0bfff 64bit pref]
[   88.888690] pci 0000:d3:00.0: reg 0x18: [mem 0xf347fe04000-0xf347fe07fff 64bit pref]
[   88.888702] pci 0000:d3:00.0: reg 0x20: [mem 0xf347fd00000-0xf347fdfffff 64bit pref]
[   88.888711] pci 0000:d3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.888770] pci 0000:d3:00.0: PME# supported from D3cold
[   88.888957] pci 0000:d3:00.1: [1077:2031] type 00 class 0x0c0400
[   88.888973] pci 0000:d3:00.1: reg 0x10: [mem 0xf347fe08000-0xf347fe09fff 64bit pref]
[   88.888985] pci 0000:d3:00.1: reg 0x18: [mem 0xf347fe00000-0xf347fe03fff 64bit pref]
[   88.889000] pci 0000:d3:00.1: reg 0x20: [mem 0xf347fc00000-0xf347fcfffff 64bit pref]
[   88.889009] pci 0000:d3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   88.889064] pci 0000:d3:00.1: PME# supported from D3cold
[   88.889242] pci 0000:d0:03.0: PCI bridge to [bus d3]
[   88.894713] pci 0000:d0:03.0:   bridge window [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   88.894749] pci_bus 0000:d0: on NUMA node 13
[   88.894750] acpi PNP0A08:0d: Disabling ASPM (FADT indicates it is unsupported)
[   88.915447] ACPI: PCI Root Bridge [IO0E] (domain 0000 [bus e0-ef])
[   88.922251] acpi PNP0A08:0e: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   88.931388] acpi PNP0A08:0e: PCIe AER handled by firmware
[   88.937578] acpi PNP0A08:0e: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   88.946169] PCI host bridge to bus 0000:e0
[   88.950677] pci_bus 0000:e0: root bus resource [bus e0-ef]
[   88.956713] pci_bus 0000:e0: root bus resource [mem 0xc8000000-0xcbefffff window]
[   88.964952] pci_bus 0000:e0: root bus resource [mem 0xf3800000000-0xf387fffffff window]
[   88.973780] pci 0000:e0:00.0: [8086:0e00] type 00 class 0x060000
[   88.973872] pci 0000:e0:00.0: PME# supported from D0 D3hot D3cold
[   88.974062] pci 0000:e0:02.0: [8086:0e04] type 01 class 0x060400
[   88.974174] pci 0000:e0:02.0: PME# supported from D0 D3hot D3cold
[   88.974368] pci 0000:e0:02.2: [8086:0e06] type 01 class 0x060400
[   88.974479] pci 0000:e0:02.2: PME# supported from D0 D3hot D3cold
[   88.974668] pci 0000:e0:03.0: [8086:0e08] type 01 class 0x060400
[   88.974781] pci 0000:e0:03.0: PME# supported from D0 D3hot D3cold
[   88.974953] pci 0000:e0:04.0: [8086:0e20] type 00 class 0x088000
[   88.974974] pci 0000:e0:04.0: reg 0x10: [mem 0xf387ff1c000-0xf387ff1ffff 64bit]
[   88.975201] pci 0000:e0:04.1: [8086:0e21] type 00 class 0x088000
[   88.975221] pci 0000:e0:04.1: reg 0x10: [mem 0xf387ff18000-0xf387ff1bfff 64bit]
[   88.975456] pci 0000:e0:04.2: [8086:0e22] type 00 class 0x088000
[   88.975476] pci 0000:e0:04.2: reg 0x10: [mem 0xf387ff14000-0xf387ff17fff 64bit]
[   88.975706] pci 0000:e0:04.3: [8086:0e23] type 00 class 0x088000
[   88.975727] pci 0000:e0:04.3: reg 0x10: [mem 0xf387ff10000-0xf387ff13fff 64bit]
[   88.975950] pci 0000:e0:04.4: [8086:0e24] type 00 class 0x088000
[   88.975969] pci 0000:e0:04.4: reg 0x10: [mem 0xf387ff0c000-0xf387ff0ffff 64bit]
[   88.976207] pci 0000:e0:04.5: [8086:0e25] type 00 class 0x088000
[   88.976228] pci 0000:e0:04.5: reg 0x10: [mem 0xf387ff08000-0xf387ff0bfff 64bit]
[   88.976454] pci 0000:e0:04.6: [8086:0e26] type 00 class 0x088000
[   88.976473] pci 0000:e0:04.6: reg 0x10: [mem 0xf387ff04000-0xf387ff07fff 64bit]
[   88.976699] pci 0000:e0:04.7: [8086:0e27] type 00 class 0x088000
[   88.976718] pci 0000:e0:04.7: reg 0x10: [mem 0xf387ff00000-0xf387ff03fff 64bit]
[   88.976966] pci 0000:e0:11.0: [8086:1d3e] type 01 class 0x060400
[   88.977086] pci 0000:e0:11.0: PME# supported from D0 D3hot D3cold
[   88.977273] pci 0000:e0:1c.0: [8086:1d1e] type 01 class 0x060400
[   88.977380] pci 0000:e0:1c.0: PME# supported from D0 D3hot D3cold
[   88.977580] pci 0000:e0:1d.0: [8086:1d26] type 00 class 0x0c0320
[   88.977606] pci 0000:e0:1d.0: reg 0x10: [mem 0xc8600000-0xc86003ff]
[   88.977725] pci 0000:e0:1d.0: PME# supported from D0 D3hot D3cold
[   88.977892] pci 0000:e0:1f.0: [8086:1d41] type 00 class 0x060100
[   88.978277] pci 0000:e1:00.0: [8086:10f8] type 00 class 0x020000
[   88.978291] pci 0000:e1:00.0: reg 0x10: [mem 0xc8400000-0xc84fffff]
[   88.978305] pci 0000:e1:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.978313] pci 0000:e1:00.0: reg 0x1c: [mem 0xc8504000-0xc8507fff]
[   88.978336] pci 0000:e1:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.978391] pci 0000:e1:00.0: PME# supported from D0 D3hot D3cold
[   88.978427] pci 0000:e1:00.0: reg 0x184: [mem 0xf387fa00000-0xf387fa03fff 64bit pref]
[   88.978442] pci 0000:e1:00.0: reg 0x190: [mem 0xf387f900000-0xf387f903fff 64bit pref]
[   88.978616] pci 0000:e1:00.1: [8086:10f8] type 00 class 0x020000
[   88.978632] pci 0000:e1:00.1: reg 0x10: [mem 0xc8300000-0xc83fffff]
[   88.978645] pci 0000:e1:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.978653] pci 0000:e1:00.1: reg 0x1c: [mem 0xc8500000-0xc8503fff]
[   88.978674] pci 0000:e1:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.978734] pci 0000:e1:00.1: PME# supported from D0 D3hot D3cold
[   88.978770] pci 0000:e1:00.1: reg 0x184: [mem 0xf387f800000-0xf387f803fff 64bit pref]
[   88.978786] pci 0000:e1:00.1: reg 0x190: [mem 0xf387f700000-0xf387f703fff 64bit pref]
[   88.989828] pci 0000:e0:02.0: PCI bridge to [bus e1-e2]
[   88.995604] pci 0000:e0:02.0:   bridge window [mem 0xc8300000-0xc85fffff]
[   88.995613] pci 0000:e0:02.0:   bridge window [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   88.995749] pci 0000:e3:00.0: [8086:10f8] type 00 class 0x020000
[   88.995762] pci 0000:e3:00.0: reg 0x10: [mem 0xc8100000-0xc81fffff]
[   88.995777] pci 0000:e3:00.0: reg 0x18: [io  0x0000-0x001f]
[   88.995788] pci 0000:e3:00.0: reg 0x1c: [mem 0xc8204000-0xc8207fff]
[   88.995811] pci 0000:e3:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.995867] pci 0000:e3:00.0: PME# supported from D0 D3hot D3cold
[   88.995904] pci 0000:e3:00.0: reg 0x184: [mem 0xf387fe00000-0xf387fe03fff 64bit pref]
[   88.995919] pci 0000:e3:00.0: reg 0x190: [mem 0xf387fd00000-0xf387fd03fff 64bit pref]
[   88.996103] pci 0000:e3:00.1: [8086:10f8] type 00 class 0x020000
[   88.996116] pci 0000:e3:00.1: reg 0x10: [mem 0xc8000000-0xc80fffff]
[   88.996129] pci 0000:e3:00.1: reg 0x18: [io  0x0000-0x001f]
[   88.996138] pci 0000:e3:00.1: reg 0x1c: [mem 0xc8200000-0xc8203fff]
[   88.996161] pci 0000:e3:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[   88.996219] pci 0000:e3:00.1: PME# supported from D0 D3hot D3cold
[   88.996249] pci 0000:e3:00.1: reg 0x184: [mem 0xf387fc00000-0xf387fc03fff 64bit pref]
[   88.996265] pci 0000:e3:00.1: reg 0x190: [mem 0xf387fb00000-0xf387fb03fff 64bit pref]
[   89.003641] pci 0000:e0:02.2: PCI bridge to [bus e3-e4]
[   89.009423] pci 0000:e0:02.2:   bridge window [mem 0xc8000000-0xc82fffff]
[   89.009432] pci 0000:e0:02.2:   bridge window [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   89.009550] pci 0000:e0:03.0: PCI bridge to [bus e5]
[   89.015152] pci 0000:e0:11.0: PCI bridge to [bus e6]
[   89.020773] pci 0000:e7:00.0: [103c:3306] type 00 class 0x088000
[   89.020801] pci 0000:e7:00.0: reg 0x10: [io  0x0000-0x00ff]
[   89.020818] pci 0000:e7:00.0: reg 0x14: [mem 0xcbd88000-0xcbd881ff]
[   89.020835] pci 0000:e7:00.0: reg 0x18: [io  0x0000-0x00ff]
[   89.021153] pci 0000:e7:00.2: [103c:3307] type 00 class 0x088000
[   89.021182] pci 0000:e7:00.2: reg 0x10: [io  0x0000-0x00ff]
[   89.021201] pci 0000:e7:00.2: reg 0x14: [mem 0xcbd88400-0xcbd884ff]
[   89.021218] pci 0000:e7:00.2: reg 0x18: [mem 0xcbb00000-0xcbbfffff]
[   89.021235] pci 0000:e7:00.2: reg 0x1c: [mem 0xcbd00000-0xcbd7ffff]
[   89.021252] pci 0000:e7:00.2: reg 0x20: [mem 0xcbd80000-0xcbd87fff]
[   89.021272] pci 0000:e7:00.2: reg 0x24: [mem 0xcbc00000-0xcbcfffff]
[   89.021289] pci 0000:e7:00.2: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[   89.021385] pci 0000:e7:00.2: PME# supported from D0 D3hot D3cold
[   89.028663] pci 0000:e0:1c.0: PCI bridge to [bus e7]
[   89.034152] pci 0000:e0:1c.0:   bridge window [mem 0xcbb00000-0xcbefffff]
[   89.034162] pci 0000:e0:1c.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
[   89.034218] pci_bus 0000:e0: on NUMA node 14
[   89.034220] acpi PNP0A08:0e: Disabling ASPM (FADT indicates it is unsupported)
[   89.042386] ACPI: PCI Root Bridge [IO0F] (domain 0000 [bus f0-ff])
[   89.049190] acpi PNP0A08:0f: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[   89.058321] acpi PNP0A08:0f: PCIe AER handled by firmware
[   89.064532] acpi PNP0A08:0f: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
[   89.073114] PCI host bridge to bus 0000:f0
[   89.077624] pci_bus 0000:f0: root bus resource [bus f0-ff]
[   89.083664] pci_bus 0000:f0: root bus resource [mem 0xcc000000-0xcfff7fff window]
[   89.091901] pci_bus 0000:f0: root bus resource [mem 0xf3c00000000-0xf3c7fffffff window]
[   89.100728] pci 0000:f0:02.0: [8086:0e04] type 01 class 0x060400
[   89.100838] pci 0000:f0:02.0: PME# supported from D0 D3hot D3cold
[   89.101020] pci 0000:f0:02.2: [8086:0e06] type 01 class 0x060400
[   89.101131] pci 0000:f0:02.2: PME# supported from D0 D3hot D3cold
[   89.101332] pci 0000:f0:03.0: [8086:0e08] type 01 class 0x060400
[   89.101445] pci 0000:f0:03.0: PME# supported from D0 D3hot D3cold
[   89.101629] pci 0000:f0:04.0: [8086:0e20] type 00 class 0x088000
[   89.101652] pci 0000:f0:04.0: reg 0x10: [mem 0xf3c7ff1c000-0xf3c7ff1ffff 64bit]
[   89.101887] pci 0000:f0:04.1: [8086:0e21] type 00 class 0x088000
[   89.101906] pci 0000:f0:04.1: reg 0x10: [mem 0xf3c7ff18000-0xf3c7ff1bfff 64bit]
[   89.102134] pci 0000:f0:04.2: [8086:0e22] type 00 class 0x088000
[   89.102154] pci 0000:f0:04.2: reg 0x10: [mem 0xf3c7ff14000-0xf3c7ff17fff 64bit]
[   89.102374] pci 0000:f0:04.3: [8086:0e23] type 00 class 0x088000
[   89.102393] pci 0000:f0:04.3: reg 0x10: [mem 0xf3c7ff10000-0xf3c7ff13fff 64bit]
[   89.102619] pci 0000:f0:04.4: [8086:0e24] type 00 class 0x088000
[   89.102639] pci 0000:f0:04.4: reg 0x10: [mem 0xf3c7ff0c000-0xf3c7ff0ffff 64bit]
[   89.102876] pci 0000:f0:04.5: [8086:0e25] type 00 class 0x088000
[   89.102898] pci 0000:f0:04.5: reg 0x10: [mem 0xf3c7ff08000-0xf3c7ff0bfff 64bit]
[   89.103110] pci 0000:f0:04.6: [8086:0e26] type 00 class 0x088000
[   89.103129] pci 0000:f0:04.6: reg 0x10: [mem 0xf3c7ff04000-0xf3c7ff07fff 64bit]
[   89.103354] pci 0000:f0:04.7: [8086:0e27] type 00 class 0x088000
[   89.103378] pci 0000:f0:04.7: reg 0x10: [mem 0xf3c7ff00000-0xf3c7ff03fff 64bit]
[   89.103735] pci 0000:f0:02.0: PCI bridge to [bus f1]
[   89.109339] pci 0000:f0:02.2: PCI bridge to [bus f2]
[   89.114940] pci 0000:f3:00.0: [1077:2031] type 00 class 0x0c0400
[   89.114958] pci 0000:f3:00.0: reg 0x10: [mem 0xf3c7fe0a000-0xf3c7fe0bfff 64bit pref]
[   89.114973] pci 0000:f3:00.0: reg 0x18: [mem 0xf3c7fe04000-0xf3c7fe07fff 64bit pref]
[   89.114984] pci 0000:f3:00.0: reg 0x20: [mem 0xf3c7fd00000-0xf3c7fdfffff 64bit pref]
[   89.114993] pci 0000:f3:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   89.115050] pci 0000:f3:00.0: PME# supported from D3cold
[   89.115247] pci 0000:f3:00.1: [1077:2031] type 00 class 0x0c0400
[   89.115263] pci 0000:f3:00.1: reg 0x10: [mem 0xf3c7fe08000-0xf3c7fe09fff 64bit pref]
[   89.115275] pci 0000:f3:00.1: reg 0x18: [mem 0xf3c7fe00000-0xf3c7fe03fff 64bit pref]
[   89.115290] pci 0000:f3:00.1: reg 0x20: [mem 0xf3c7fc00000-0xf3c7fcfffff 64bit pref]
[   89.115298] pci 0000:f3:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[   89.115353] pci 0000:f3:00.1: PME# supported from D3cold
[   89.115546] pci 0000:f0:03.0: PCI bridge to [bus f3]
[   89.121019] pci 0000:f0:03.0:   bridge window [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   89.121052] pci_bus 0000:f0: on NUMA node 15
[   89.121054] acpi PNP0A08:0f: Disabling ASPM (FADT indicates it is unsupported)
[   89.129233] ACPI: Enabled 1 GPEs in block 80 to FF
[   89.135162] vgaarb: setting as boot device: PCI:0000:07:00.1
[   89.141405] vgaarb: device added: PCI:0000:07:00.1,decodes=io+mem,owns=io+mem,locks=none
[   89.150690] vgaarb: loaded
[   89.153671] vgaarb: bridge control possible 0000:07:00.1
[   89.170336] PCI: Using ACPI for IRQ routing
[   89.175284] PCI: Discovered peer bus 0f
[   89.179511] PCI: root bus 0f: using default resources
[   89.179516] PCI: Probing PCI hardware (bus 0f)
[   89.179897] PCI host bridge to bus 0000:0f
[   89.184416] pci_bus 0000:0f: root bus resource [io  0x0000-0xffff]
[   89.191221] pci_bus 0000:0f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.199174] pci_bus 0000:0f: No busn resource found for root bus, will use [bus 0f-ff]
[   89.207900] pci_bus 0000:0f: busn_res: can not insert [bus 0f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 00-0f])
[   89.207930] pci 0000:0f:08.0: [8086:0e80] type 00 class 0x088000
[   89.208260] pci 0000:0f:08.2: [8086:0e32] type 00 class 0x110100
[   89.208509] pci 0000:0f:09.0: [8086:0e90] type 00 class 0x088000
[   89.208698] pci 0000:0f:09.2: [8086:0e33] type 00 class 0x110100
[   89.208882] pci 0000:0f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.209068] pci 0000:0f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.209269] pci 0000:0f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.209451] pci 0000:0f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.209638] pci 0000:0f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.209804] pci 0000:0f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.209953] pci 0000:0f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.210115] pci 0000:0f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.210271] pci 0000:0f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.210442] pci 0000:0f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.210607] pci 0000:0f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.210851] pci 0000:0f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.211016] pci 0000:0f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.211186] pci 0000:0f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.211364] pci 0000:0f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.211516] pci 0000:0f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.211682] pci 0000:0f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.211856] pci 0000:0f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.212031] pci 0000:0f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.212211] pci 0000:0f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.212375] pci 0000:0f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.212545] pci 0000:0f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.212713] pci 0000:0f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.212878] pci 0000:0f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.213078] pci 0000:0f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.213276] pci 0000:0f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.213462] pci 0000:0f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.213627] pci 0000:0f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.213829] pci 0000:0f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.214009] pci 0000:0f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.214183] pci 0000:0f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.214379] pci 0000:0f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.214564] pci 0000:0f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.214750] pci 0000:0f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.214943] pci 0000:0f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.215134] pci 0000:0f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.215320] pci 0000:0f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.215503] pci 0000:0f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.215676] pci 0000:0f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.215845] pci 0000:0f:11.2: [8086:0efa] type 00 class 0x088000
[   89.216039] pci 0000:0f:11.4: [8086:0efc] type 00 class 0x088000
[   89.216214] pci 0000:0f:11.5: [8086:0efd] type 00 class 0x088000
[   89.216396] pci 0000:0f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.216571] pci 0000:0f:13.1: [8086:0e34] type 00 class 0x110100
[   89.216733] pci 0000:0f:13.4: [8086:0e81] type 00 class 0x088000
[   89.216888] pci 0000:0f:13.5: [8086:0e36] type 00 class 0x110100
[   89.217041] pci 0000:0f:13.6: [8086:0e37] type 00 class 0x110100
[   89.217216] pci 0000:0f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.217363] pci 0000:0f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.217509] pci 0000:0f:16.2: [8086:0eca] type 00 class 0x088000
[   89.217686] pci 0000:0f:18.0: [8086:0e40] type 00 class 0x088000
[   89.217864] pci 0000:0f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.218035] pci 0000:0f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.218205] pci 0000:0f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.218373] pci 0000:0f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.218553] pci 0000:0f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.218732] pci 0000:0f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.218897] pci 0000:0f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.219059] pci 0000:0f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.219237] pci 0000:0f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.219450] pci 0000:0f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.219622] pci 0000:0f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.219817] pci 0000:0f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.219991] pci 0000:0f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.220187] pci 0000:0f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.220377] pci 0000:0f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.220559] pci 0000:0f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.220742] pci 0000:0f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.220925] pci 0000:0f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.221114] pci 0000:0f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.221305] pci 0000:0f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.221491] pci 0000:0f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.221662] pci 0000:0f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.221829] pci 0000:0f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.222002] pci_bus 0000:0f: busn_res: [bus 0f-ff] end is updated to 0f
[   89.222004] pci_bus 0000:0f: busn_res: can not insert [bus 0f] under domain [bus 00-ff] (conflicts with (null) [bus 00-0f])
[   89.222247] PCI: Discovered peer bus 1f
[   89.226470] PCI: root bus 1f: using default resources
[   89.226473] PCI: Probing PCI hardware (bus 1f)
[   89.226583] PCI host bridge to bus 0000:1f
[   89.231098] pci_bus 0000:1f: root bus resource [io  0x0000-0xffff]
[   89.237902] pci_bus 0000:1f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.245856] pci_bus 0000:1f: No busn resource found for root bus, will use [bus 1f-ff]
[   89.254569] pci_bus 0000:1f: busn_res: can not insert [bus 1f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 10-1f])
[   89.254593] pci 0000:1f:08.0: [8086:0e80] type 00 class 0x088000
[   89.254749] pci 0000:1f:08.2: [8086:0e32] type 00 class 0x110100
[   89.254903] pci 0000:1f:09.0: [8086:0e90] type 00 class 0x088000
[   89.255080] pci 0000:1f:09.2: [8086:0e33] type 00 class 0x110100
[   89.255295] pci 0000:1f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.255537] pci 0000:1f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.255702] pci 0000:1f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.255854] pci 0000:1f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.256024] pci 0000:1f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.256183] pci 0000:1f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.256342] pci 0000:1f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.256507] pci 0000:1f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.256661] pci 0000:1f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.256809] pci 0000:1f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.256964] pci 0000:1f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.257132] pci 0000:1f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.257296] pci 0000:1f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.257447] pci 0000:1f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.257608] pci 0000:1f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.257769] pci 0000:1f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.257931] pci 0000:1f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.258079] pci 0000:1f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.258233] pci 0000:1f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.258392] pci 0000:1f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.258540] pci 0000:1f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.258700] pci 0000:1f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.258884] pci 0000:1f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.259060] pci 0000:1f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.259252] pci 0000:1f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.259424] pci 0000:1f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.259612] pci 0000:1f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.259782] pci 0000:1f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.259974] pci 0000:1f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.260151] pci 0000:1f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.260340] pci 0000:1f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.260517] pci 0000:1f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.260698] pci 0000:1f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.260874] pci 0000:1f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.261068] pci 0000:1f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.261246] pci 0000:1f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.261431] pci 0000:1f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.261592] pci 0000:1f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.261767] pci 0000:1f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.261942] pci 0000:1f:11.2: [8086:0efa] type 00 class 0x088000
[   89.262127] pci 0000:1f:11.4: [8086:0efc] type 00 class 0x088000
[   89.262308] pci 0000:1f:11.5: [8086:0efd] type 00 class 0x088000
[   89.262482] pci 0000:1f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.262633] pci 0000:1f:13.1: [8086:0e34] type 00 class 0x110100
[   89.262784] pci 0000:1f:13.4: [8086:0e81] type 00 class 0x088000
[   89.262946] pci 0000:1f:13.5: [8086:0e36] type 00 class 0x110100
[   89.263105] pci 0000:1f:13.6: [8086:0e37] type 00 class 0x110100
[   89.263247] pci 0000:1f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.263419] pci 0000:1f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.263571] pci 0000:1f:16.2: [8086:0eca] type 00 class 0x088000
[   89.263735] pci 0000:1f:18.0: [8086:0e40] type 00 class 0x088000
[   89.263890] pci 0000:1f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.264059] pci 0000:1f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.264229] pci 0000:1f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.264407] pci 0000:1f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.264583] pci 0000:1f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.264766] pci 0000:1f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.264935] pci 0000:1f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.265114] pci 0000:1f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.265287] pci 0000:1f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.265476] pci 0000:1f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.265641] pci 0000:1f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.265817] pci 0000:1f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.265998] pci 0000:1f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.266176] pci 0000:1f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.266361] pci 0000:1f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.266538] pci 0000:1f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.266728] pci 0000:1f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.266912] pci 0000:1f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.267102] pci 0000:1f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.267287] pci 0000:1f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.267478] pci 0000:1f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.267672] pci 0000:1f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.267843] pci 0000:1f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.268017] pci_bus 0000:1f: busn_res: [bus 1f-ff] end is updated to 1f
[   89.268021] pci_bus 0000:1f: busn_res: can not insert [bus 1f] under domain [bus 00-ff] (conflicts with (null) [bus 10-1f])
[   89.268313] PCI: Discovered peer bus 2f
[   89.272536] PCI: root bus 2f: using default resources
[   89.272542] PCI: Probing PCI hardware (bus 2f)
[   89.272664] PCI host bridge to bus 0000:2f
[   89.277174] pci_bus 0000:2f: root bus resource [io  0x0000-0xffff]
[   89.283974] pci_bus 0000:2f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.291924] pci_bus 0000:2f: No busn resource found for root bus, will use [bus 2f-ff]
[   89.300640] pci_bus 0000:2f: busn_res: can not insert [bus 2f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 20-2f])
[   89.300656] pci 0000:2f:08.0: [8086:0e80] type 00 class 0x088000
[   89.300811] pci 0000:2f:08.2: [8086:0e32] type 00 class 0x110100
[   89.300967] pci 0000:2f:09.0: [8086:0e90] type 00 class 0x088000
[   89.301130] pci 0000:2f:09.2: [8086:0e33] type 00 class 0x110100
[   89.301287] pci 0000:2f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.301435] pci 0000:2f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.301579] pci 0000:2f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.301721] pci 0000:2f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.301874] pci 0000:2f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.302030] pci 0000:2f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.302167] pci 0000:2f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.302309] pci 0000:2f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.302473] pci 0000:2f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.302613] pci 0000:2f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.302761] pci 0000:2f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.302898] pci 0000:2f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.303041] pci 0000:2f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.303169] pci 0000:2f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.303323] pci 0000:2f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.303486] pci 0000:2f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.303649] pci 0000:2f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.303808] pci 0000:2f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.303953] pci 0000:2f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.304089] pci 0000:2f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.304218] pci 0000:2f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.304350] pci 0000:2f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.304509] pci 0000:2f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.304674] pci 0000:2f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.304829] pci 0000:2f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.304995] pci 0000:2f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.305151] pci 0000:2f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.305317] pci 0000:2f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.305493] pci 0000:2f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.305673] pci 0000:2f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.305845] pci 0000:2f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.306010] pci 0000:2f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.306180] pci 0000:2f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.306359] pci 0000:2f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.306524] pci 0000:2f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.306685] pci 0000:2f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.306861] pci 0000:2f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.307034] pci 0000:2f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.307187] pci 0000:2f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.307346] pci 0000:2f:11.2: [8086:0efa] type 00 class 0x088000
[   89.307512] pci 0000:2f:11.4: [8086:0efc] type 00 class 0x088000
[   89.307674] pci 0000:2f:11.5: [8086:0efd] type 00 class 0x088000
[   89.307838] pci 0000:2f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.307985] pci 0000:2f:13.1: [8086:0e34] type 00 class 0x110100
[   89.308119] pci 0000:2f:13.4: [8086:0e81] type 00 class 0x088000
[   89.308255] pci 0000:2f:13.5: [8086:0e36] type 00 class 0x110100
[   89.308400] pci 0000:2f:13.6: [8086:0e37] type 00 class 0x110100
[   89.308543] pci 0000:2f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.308687] pci 0000:2f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.308824] pci 0000:2f:16.2: [8086:0eca] type 00 class 0x088000
[   89.308972] pci 0000:2f:18.0: [8086:0e40] type 00 class 0x088000
[   89.309122] pci 0000:2f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.309280] pci 0000:2f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.309419] pci 0000:2f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.309580] pci 0000:2f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.309733] pci 0000:2f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.309890] pci 0000:2f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.310065] pci 0000:2f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.310221] pci 0000:2f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.310396] pci 0000:2f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.310548] pci 0000:2f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.310716] pci 0000:2f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.310881] pci 0000:2f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.311038] pci 0000:2f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.311185] pci 0000:2f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.311355] pci 0000:2f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.311566] pci 0000:2f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.311721] pci 0000:2f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.311878] pci 0000:2f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.312039] pci 0000:2f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.312214] pci 0000:2f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.312386] pci 0000:2f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.312541] pci 0000:2f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.312701] pci 0000:2f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.312865] pci_bus 0000:2f: busn_res: [bus 2f-ff] end is updated to 2f
[   89.312871] pci_bus 0000:2f: busn_res: can not insert [bus 2f] under domain [bus 00-ff] (conflicts with (null) [bus 20-2f])
[   89.313079] PCI: Discovered peer bus 3f
[   89.317300] PCI: root bus 3f: using default resources
[   89.317306] PCI: Probing PCI hardware (bus 3f)
[   89.317428] PCI host bridge to bus 0000:3f
[   89.321935] pci_bus 0000:3f: root bus resource [io  0x0000-0xffff]
[   89.328740] pci_bus 0000:3f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.336693] pci_bus 0000:3f: No busn resource found for root bus, will use [bus 3f-ff]
[   89.345410] pci_bus 0000:3f: busn_res: can not insert [bus 3f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 30-3f])
[   89.345424] pci 0000:3f:08.0: [8086:0e80] type 00 class 0x088000
[   89.345588] pci 0000:3f:08.2: [8086:0e32] type 00 class 0x110100
[   89.345738] pci 0000:3f:09.0: [8086:0e90] type 00 class 0x088000
[   89.345907] pci 0000:3f:09.2: [8086:0e33] type 00 class 0x110100
[   89.346052] pci 0000:3f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.346215] pci 0000:3f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.346359] pci 0000:3f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.346517] pci 0000:3f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.346658] pci 0000:3f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.346814] pci 0000:3f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.346956] pci 0000:3f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.347124] pci 0000:3f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.347268] pci 0000:3f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.347415] pci 0000:3f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.347564] pci 0000:3f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.347712] pci 0000:3f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.347863] pci 0000:3f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.348018] pci 0000:3f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.348162] pci 0000:3f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.348298] pci 0000:3f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.348448] pci 0000:3f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.348600] pci 0000:3f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.348742] pci 0000:3f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.348893] pci 0000:3f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.349038] pci 0000:3f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.349199] pci 0000:3f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.349360] pci 0000:3f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.349521] pci 0000:3f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.349682] pci 0000:3f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.349851] pci 0000:3f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.350026] pci 0000:3f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.350198] pci 0000:3f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.350357] pci 0000:3f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.350527] pci 0000:3f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.350689] pci 0000:3f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.350849] pci 0000:3f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.351022] pci 0000:3f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.351205] pci 0000:3f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.351367] pci 0000:3f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.351524] pci 0000:3f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.351702] pci 0000:3f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.351882] pci 0000:3f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.352053] pci 0000:3f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.352222] pci 0000:3f:11.2: [8086:0efa] type 00 class 0x088000
[   89.352391] pci 0000:3f:11.4: [8086:0efc] type 00 class 0x088000
[   89.352576] pci 0000:3f:11.5: [8086:0efd] type 00 class 0x088000
[   89.352760] pci 0000:3f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.352906] pci 0000:3f:13.1: [8086:0e34] type 00 class 0x110100
[   89.353064] pci 0000:3f:13.4: [8086:0e81] type 00 class 0x088000
[   89.353223] pci 0000:3f:13.5: [8086:0e36] type 00 class 0x110100
[   89.353377] pci 0000:3f:13.6: [8086:0e37] type 00 class 0x110100
[   89.353537] pci 0000:3f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.353682] pci 0000:3f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.353839] pci 0000:3f:16.2: [8086:0eca] type 00 class 0x088000
[   89.354002] pci 0000:3f:18.0: [8086:0e40] type 00 class 0x088000
[   89.354158] pci 0000:3f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.354326] pci 0000:3f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.354481] pci 0000:3f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.354651] pci 0000:3f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.354815] pci 0000:3f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.354979] pci 0000:3f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.355142] pci 0000:3f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.355314] pci 0000:3f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.355465] pci 0000:3f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.355648] pci 0000:3f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.355821] pci 0000:3f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.355986] pci 0000:3f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.356192] pci 0000:3f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.356358] pci 0000:3f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.356504] pci 0000:3f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.356687] pci 0000:3f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.356865] pci 0000:3f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.357028] pci 0000:3f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.357195] pci 0000:3f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.357378] pci 0000:3f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.357532] pci 0000:3f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.357701] pci 0000:3f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.357887] pci 0000:3f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.358048] pci_bus 0000:3f: busn_res: [bus 3f-ff] end is updated to 3f
[   89.358050] pci_bus 0000:3f: busn_res: can not insert [bus 3f] under domain [bus 00-ff] (conflicts with (null) [bus 30-3f])
[   89.358373] PCI: Discovered peer bus 4f
[   89.362599] PCI: root bus 4f: using default resources
[   89.362603] PCI: Probing PCI hardware (bus 4f)
[   89.362712] PCI host bridge to bus 0000:4f
[   89.367218] pci_bus 0000:4f: root bus resource [io  0x0000-0xffff]
[   89.374020] pci_bus 0000:4f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.381969] pci_bus 0000:4f: No busn resource found for root bus, will use [bus 4f-ff]
[   89.390689] pci_bus 0000:4f: busn_res: can not insert [bus 4f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 40-4f])
[   89.390707] pci 0000:4f:08.0: [8086:0e80] type 00 class 0x088000
[   89.390872] pci 0000:4f:08.2: [8086:0e32] type 00 class 0x110100
[   89.391040] pci 0000:4f:09.0: [8086:0e90] type 00 class 0x088000
[   89.391207] pci 0000:4f:09.2: [8086:0e33] type 00 class 0x110100
[   89.391360] pci 0000:4f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.391516] pci 0000:4f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.391663] pci 0000:4f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.391844] pci 0000:4f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.392005] pci 0000:4f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.392155] pci 0000:4f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.392298] pci 0000:4f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.392448] pci 0000:4f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.392610] pci 0000:4f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.392754] pci 0000:4f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.392904] pci 0000:4f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.393062] pci 0000:4f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.393214] pci 0000:4f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.393354] pci 0000:4f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.393494] pci 0000:4f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.393639] pci 0000:4f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.393792] pci 0000:4f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.393928] pci 0000:4f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.394080] pci 0000:4f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.394225] pci 0000:4f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.394377] pci 0000:4f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.394525] pci 0000:4f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.394667] pci 0000:4f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.394827] pci 0000:4f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.395000] pci 0000:4f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.395169] pci 0000:4f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.395342] pci 0000:4f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.395523] pci 0000:4f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.395676] pci 0000:4f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.395875] pci 0000:4f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.396071] pci 0000:4f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.396255] pci 0000:4f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.396431] pci 0000:4f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.396619] pci 0000:4f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.396800] pci 0000:4f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.396978] pci 0000:4f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.397147] pci 0000:4f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.397325] pci 0000:4f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.397491] pci 0000:4f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.397679] pci 0000:4f:11.2: [8086:0efa] type 00 class 0x088000
[   89.397855] pci 0000:4f:11.4: [8086:0efc] type 00 class 0x088000
[   89.398030] pci 0000:4f:11.5: [8086:0efd] type 00 class 0x088000
[   89.398208] pci 0000:4f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.398355] pci 0000:4f:13.1: [8086:0e34] type 00 class 0x110100
[   89.398500] pci 0000:4f:13.4: [8086:0e81] type 00 class 0x088000
[   89.398642] pci 0000:4f:13.5: [8086:0e36] type 00 class 0x110100
[   89.398813] pci 0000:4f:13.6: [8086:0e37] type 00 class 0x110100
[   89.398973] pci 0000:4f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.399126] pci 0000:4f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.399280] pci 0000:4f:16.2: [8086:0eca] type 00 class 0x088000
[   89.399427] pci 0000:4f:18.0: [8086:0e40] type 00 class 0x088000
[   89.399549] pci 0000:4f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.399725] pci 0000:4f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.399890] pci 0000:4f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.400048] pci 0000:4f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.400224] pci 0000:4f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.400396] pci 0000:4f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.400550] pci 0000:4f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.400726] pci 0000:4f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.400894] pci 0000:4f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.401068] pci 0000:4f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.401262] pci 0000:4f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.401425] pci 0000:4f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.401618] pci 0000:4f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.401801] pci 0000:4f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.401963] pci 0000:4f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.402158] pci 0000:4f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.402342] pci 0000:4f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.402515] pci 0000:4f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.402687] pci 0000:4f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.402864] pci 0000:4f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.403036] pci 0000:4f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.403229] pci 0000:4f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.403397] pci 0000:4f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.403570] pci_bus 0000:4f: busn_res: [bus 4f-ff] end is updated to 4f
[   89.403572] pci_bus 0000:4f: busn_res: can not insert [bus 4f] under domain [bus 00-ff] (conflicts with (null) [bus 40-4f])
[   89.403817] PCI: Discovered peer bus 5f
[   89.408038] PCI: root bus 5f: using default resources
[   89.408043] PCI: Probing PCI hardware (bus 5f)
[   89.408171] PCI host bridge to bus 0000:5f
[   89.412680] pci_bus 0000:5f: root bus resource [io  0x0000-0xffff]
[   89.419483] pci_bus 0000:5f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.427460] pci_bus 0000:5f: No busn resource found for root bus, will use [bus 5f-ff]
[   89.436175] pci_bus 0000:5f: busn_res: can not insert [bus 5f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 50-5f])
[   89.436213] pci 0000:5f:08.0: [8086:0e80] type 00 class 0x088000
[   89.436389] pci 0000:5f:08.2: [8086:0e32] type 00 class 0x110100
[   89.436552] pci 0000:5f:09.0: [8086:0e90] type 00 class 0x088000
[   89.436719] pci 0000:5f:09.2: [8086:0e33] type 00 class 0x110100
[   89.436870] pci 0000:5f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.437045] pci 0000:5f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.437182] pci 0000:5f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.437340] pci 0000:5f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.437495] pci 0000:5f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.437645] pci 0000:5f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.437792] pci 0000:5f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.437945] pci 0000:5f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.438085] pci 0000:5f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.438222] pci 0000:5f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.438361] pci 0000:5f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.438528] pci 0000:5f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.438669] pci 0000:5f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.438813] pci 0000:5f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.438969] pci 0000:5f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.439105] pci 0000:5f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.439253] pci 0000:5f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.439404] pci 0000:5f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.439543] pci 0000:5f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.439682] pci 0000:5f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.439832] pci 0000:5f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.439976] pci 0000:5f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.440140] pci 0000:5f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.440296] pci 0000:5f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.440464] pci 0000:5f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.440623] pci 0000:5f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.440782] pci 0000:5f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.440959] pci 0000:5f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.441147] pci 0000:5f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.441322] pci 0000:5f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.441486] pci 0000:5f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.441675] pci 0000:5f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.441844] pci 0000:5f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.442011] pci 0000:5f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.442181] pci 0000:5f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.442351] pci 0000:5f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.442535] pci 0000:5f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.442703] pci 0000:5f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.442864] pci 0000:5f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.443029] pci 0000:5f:11.2: [8086:0efa] type 00 class 0x088000
[   89.443282] pci 0000:5f:11.4: [8086:0efc] type 00 class 0x088000
[   89.443468] pci 0000:5f:11.5: [8086:0efd] type 00 class 0x088000
[   89.443634] pci 0000:5f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.443782] pci 0000:5f:13.1: [8086:0e34] type 00 class 0x110100
[   89.443933] pci 0000:5f:13.4: [8086:0e81] type 00 class 0x088000
[   89.444063] pci 0000:5f:13.5: [8086:0e36] type 00 class 0x110100
[   89.444243] pci 0000:5f:13.6: [8086:0e37] type 00 class 0x110100
[   89.444416] pci 0000:5f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.444557] pci 0000:5f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.444707] pci 0000:5f:16.2: [8086:0eca] type 00 class 0x088000
[   89.444868] pci 0000:5f:18.0: [8086:0e40] type 00 class 0x088000
[   89.445027] pci 0000:5f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.445179] pci 0000:5f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.445352] pci 0000:5f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.445518] pci 0000:5f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.445690] pci 0000:5f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.445866] pci 0000:5f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.446047] pci 0000:5f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.446220] pci 0000:5f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.446387] pci 0000:5f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.446562] pci 0000:5f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.446750] pci 0000:5f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.446932] pci 0000:5f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.447096] pci 0000:5f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.447279] pci 0000:5f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.447463] pci 0000:5f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.447651] pci 0000:5f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.447822] pci 0000:5f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.448007] pci 0000:5f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.448209] pci 0000:5f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.448390] pci 0000:5f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.448561] pci 0000:5f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.448748] pci 0000:5f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.448945] pci 0000:5f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.449129] pci_bus 0000:5f: busn_res: [bus 5f-ff] end is updated to 5f
[   89.449132] pci_bus 0000:5f: busn_res: can not insert [bus 5f] under domain [bus 00-ff] (conflicts with (null) [bus 50-5f])
[   89.449457] PCI: Discovered peer bus 6f
[   89.453679] PCI: root bus 6f: using default resources
[   89.453686] PCI: Probing PCI hardware (bus 6f)
[   89.453815] PCI host bridge to bus 0000:6f
[   89.458322] pci_bus 0000:6f: root bus resource [io  0x0000-0xffff]
[   89.465125] pci_bus 0000:6f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.473074] pci_bus 0000:6f: No busn resource found for root bus, will use [bus 6f-ff]
[   89.481792] pci_bus 0000:6f: busn_res: can not insert [bus 6f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 60-6f])
[   89.481818] pci 0000:6f:08.0: [8086:0e80] type 00 class 0x088000
[   89.481972] pci 0000:6f:08.2: [8086:0e32] type 00 class 0x110100
[   89.482136] pci 0000:6f:09.0: [8086:0e90] type 00 class 0x088000
[   89.482317] pci 0000:6f:09.2: [8086:0e33] type 00 class 0x110100
[   89.482490] pci 0000:6f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.482653] pci 0000:6f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.482811] pci 0000:6f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.482969] pci 0000:6f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.483124] pci 0000:6f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.483264] pci 0000:6f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.483406] pci 0000:6f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.483555] pci 0000:6f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.483704] pci 0000:6f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.483881] pci 0000:6f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.484044] pci 0000:6f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.484198] pci 0000:6f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.484345] pci 0000:6f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.484504] pci 0000:6f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.484677] pci 0000:6f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.484831] pci 0000:6f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.484975] pci 0000:6f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.485131] pci 0000:6f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.485279] pci 0000:6f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.485440] pci 0000:6f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.485592] pci 0000:6f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.485735] pci 0000:6f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.485888] pci 0000:6f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.486061] pci 0000:6f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.486228] pci 0000:6f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.486405] pci 0000:6f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.486585] pci 0000:6f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.486772] pci 0000:6f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.486941] pci 0000:6f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.487131] pci 0000:6f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.487297] pci 0000:6f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.487481] pci 0000:6f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.487671] pci 0000:6f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.487835] pci 0000:6f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.488029] pci 0000:6f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.488203] pci 0000:6f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.488402] pci 0000:6f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.488582] pci 0000:6f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.488750] pci 0000:6f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.488921] pci 0000:6f:11.2: [8086:0efa] type 00 class 0x088000
[   89.489105] pci 0000:6f:11.4: [8086:0efc] type 00 class 0x088000
[   89.489270] pci 0000:6f:11.5: [8086:0efd] type 00 class 0x088000
[   89.489457] pci 0000:6f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.489609] pci 0000:6f:13.1: [8086:0e34] type 00 class 0x110100
[   89.489766] pci 0000:6f:13.4: [8086:0e81] type 00 class 0x088000
[   89.489933] pci 0000:6f:13.5: [8086:0e36] type 00 class 0x110100
[   89.490070] pci 0000:6f:13.6: [8086:0e37] type 00 class 0x110100
[   89.490218] pci 0000:6f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.490378] pci 0000:6f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.490520] pci 0000:6f:16.2: [8086:0eca] type 00 class 0x088000
[   89.490685] pci 0000:6f:18.0: [8086:0e40] type 00 class 0x088000
[   89.490846] pci 0000:6f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.491007] pci 0000:6f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.491163] pci 0000:6f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.491348] pci 0000:6f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.491520] pci 0000:6f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.491693] pci 0000:6f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.491903] pci 0000:6f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.492088] pci 0000:6f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.492271] pci 0000:6f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.492465] pci 0000:6f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.492660] pci 0000:6f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.492831] pci 0000:6f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.492997] pci 0000:6f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.493174] pci 0000:6f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.493356] pci 0000:6f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.493522] pci 0000:6f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.493695] pci 0000:6f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.493878] pci 0000:6f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.494060] pci 0000:6f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.494243] pci 0000:6f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.494429] pci 0000:6f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.494603] pci 0000:6f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.494773] pci 0000:6f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.494951] pci_bus 0000:6f: busn_res: [bus 6f-ff] end is updated to 6f
[   89.494954] pci_bus 0000:6f: busn_res: can not insert [bus 6f] under domain [bus 00-ff] (conflicts with (null) [bus 60-6f])
[   89.495115] PCI: Discovered peer bus 7b
[   89.499334] PCI: root bus 7b: using default resources
[   89.499344] PCI: Probing PCI hardware (bus 7b)
[   89.499466] PCI host bridge to bus 0000:7b
[   89.503972] pci_bus 0000:7b: root bus resource [io  0x0000-0xffff]
[   89.510776] pci_bus 0000:7b: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.518732] pci_bus 0000:7b: No busn resource found for root bus, will use [bus 7b-ff]
[   89.527453] pci_bus 0000:7b: busn_res: can not insert [bus 7b-ff] under domain [bus 00-ff] (conflicts with (null) [bus 70-7b])
[   89.527471] pci 0000:7b:08.0: [8086:0e80] type 00 class 0x088000
[   89.527646] pci 0000:7b:08.2: [8086:0e32] type 00 class 0x110100
[   89.527791] pci 0000:7b:09.0: [8086:0e90] type 00 class 0x088000
[   89.527938] pci 0000:7b:09.2: [8086:0e33] type 00 class 0x110100
[   89.528134] pci 0000:7b:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.528292] pci 0000:7b:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.528435] pci 0000:7b:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.528620] pci 0000:7b:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.528762] pci 0000:7b:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.528914] pci 0000:7b:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.529060] pci 0000:7b:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.529227] pci 0000:7b:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.529369] pci 0000:7b:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.529519] pci 0000:7b:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.529666] pci 0000:7b:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.529807] pci 0000:7b:0c.5: [8086:0eea] type 00 class 0x088000
[   89.529952] pci 0000:7b:0c.6: [8086:0eec] type 00 class 0x088000
[   89.530111] pci 0000:7b:0c.7: [8086:0eee] type 00 class 0x088000
[   89.530256] pci 0000:7b:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.530404] pci 0000:7b:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.530548] pci 0000:7b:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.530695] pci 0000:7b:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.530860] pci 0000:7b:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.531015] pci 0000:7b:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.531175] pci 0000:7b:0d.6: [8086:0eed] type 00 class 0x088000
[   89.531324] pci 0000:7b:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.531494] pci 0000:7b:0e.1: [8086:0e30] type 00 class 0x110100
[   89.531655] pci 0000:7b:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.531837] pci 0000:7b:0f.1: [8086:0e71] type 00 class 0x088000
[   89.532043] pci 0000:7b:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.532217] pci 0000:7b:0f.3: [8086:0eab] type 00 class 0x088000
[   89.532398] pci 0000:7b:0f.4: [8086:0eac] type 00 class 0x088000
[   89.532564] pci 0000:7b:0f.5: [8086:0ead] type 00 class 0x088000
[   89.532722] pci 0000:7b:10.0: [8086:0eb0] type 00 class 0x088000
[   89.532922] pci 0000:7b:10.1: [8086:0eb1] type 00 class 0x088000
[   89.533107] pci 0000:7b:10.2: [8086:0eb2] type 00 class 0x088000
[   89.533266] pci 0000:7b:10.3: [8086:0eb3] type 00 class 0x088000
[   89.533445] pci 0000:7b:10.4: [8086:0eb4] type 00 class 0x088000
[   89.533622] pci 0000:7b:10.5: [8086:0eb5] type 00 class 0x088000
[   89.533795] pci 0000:7b:10.6: [8086:0eb6] type 00 class 0x088000
[   89.533971] pci 0000:7b:10.7: [8086:0eb7] type 00 class 0x088000
[   89.534153] pci 0000:7b:11.0: [8086:0ef8] type 00 class 0x088000
[   89.534325] pci 0000:7b:11.1: [8086:0ef9] type 00 class 0x088000
[   89.534490] pci 0000:7b:11.2: [8086:0efa] type 00 class 0x088000
[   89.534673] pci 0000:7b:11.4: [8086:0efc] type 00 class 0x088000
[   89.534842] pci 0000:7b:11.5: [8086:0efd] type 00 class 0x088000
[   89.535031] pci 0000:7b:13.0: [8086:0e1d] type 00 class 0x088000
[   89.535166] pci 0000:7b:13.1: [8086:0e34] type 00 class 0x110100
[   89.535322] pci 0000:7b:13.4: [8086:0e81] type 00 class 0x088000
[   89.535476] pci 0000:7b:13.5: [8086:0e36] type 00 class 0x110100
[   89.535619] pci 0000:7b:13.6: [8086:0e37] type 00 class 0x110100
[   89.535770] pci 0000:7b:16.0: [8086:0ec8] type 00 class 0x088000
[   89.535913] pci 0000:7b:16.1: [8086:0ec9] type 00 class 0x088000
[   89.536095] pci 0000:7b:16.2: [8086:0eca] type 00 class 0x088000
[   89.536254] pci 0000:7b:18.0: [8086:0e40] type 00 class 0x088000
[   89.536415] pci 0000:7b:18.2: [8086:0e3a] type 00 class 0x110100
[   89.536569] pci 0000:7b:1c.0: [8086:0e60] type 00 class 0x088000
[   89.536737] pci 0000:7b:1c.1: [8086:0e38] type 00 class 0x110100
[   89.536877] pci 0000:7b:1d.0: [8086:0e68] type 00 class 0x088000
[   89.537056] pci 0000:7b:1d.1: [8086:0e79] type 00 class 0x088000
[   89.537231] pci 0000:7b:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.537397] pci 0000:7b:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.537562] pci 0000:7b:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.537747] pci 0000:7b:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.537907] pci 0000:7b:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.538086] pci 0000:7b:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.538245] pci 0000:7b:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.538421] pci 0000:7b:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.538596] pci 0000:7b:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.538768] pci 0000:7b:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.538943] pci 0000:7b:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.539124] pci 0000:7b:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.539313] pci 0000:7b:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.539502] pci 0000:7b:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.539682] pci 0000:7b:1f.4: [8086:0edc] type 00 class 0x088000
[   89.539854] pci 0000:7b:1f.5: [8086:0edd] type 00 class 0x088000
[   89.540095] pci 0000:7b:1f.6: [8086:0ede] type 00 class 0x088000
[   89.540273] pci 0000:7b:1f.7: [8086:0edf] type 00 class 0x088000
[   89.540449] pci_bus 0000:7b: busn_res: [bus 7b-ff] end is updated to 7b
[   89.540451] pci_bus 0000:7b: busn_res: can not insert [bus 7b] under domain [bus 00-ff] (conflicts with (null) [bus 70-7b])
[   89.540810] PCI: Discovered peer bus 8f
[   89.545034] PCI: root bus 8f: using default resources
[   89.545038] PCI: Probing PCI hardware (bus 8f)
[   89.545146] PCI host bridge to bus 0000:8f
[   89.549655] pci_bus 0000:8f: root bus resource [io  0x0000-0xffff]
[   89.556457] pci_bus 0000:8f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.564404] pci_bus 0000:8f: No busn resource found for root bus, will use [bus 8f-ff]
[   89.573122] pci_bus 0000:8f: busn_res: can not insert [bus 8f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 84-8f])
[   89.573143] pci 0000:8f:08.0: [8086:0e80] type 00 class 0x088000
[   89.573310] pci 0000:8f:08.2: [8086:0e32] type 00 class 0x110100
[   89.573450] pci 0000:8f:09.0: [8086:0e90] type 00 class 0x088000
[   89.573631] pci 0000:8f:09.2: [8086:0e33] type 00 class 0x110100
[   89.573787] pci 0000:8f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.573961] pci 0000:8f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.574109] pci 0000:8f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.574256] pci 0000:8f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.574406] pci 0000:8f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.574560] pci 0000:8f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.574721] pci 0000:8f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.574872] pci 0000:8f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.575015] pci 0000:8f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.575177] pci 0000:8f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.575332] pci 0000:8f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.575487] pci 0000:8f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.575626] pci 0000:8f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.575772] pci 0000:8f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.575913] pci 0000:8f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.576073] pci 0000:8f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.576226] pci 0000:8f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.576379] pci 0000:8f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.576536] pci 0000:8f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.576694] pci 0000:8f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.576846] pci 0000:8f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.576997] pci 0000:8f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.577166] pci 0000:8f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.577340] pci 0000:8f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.577509] pci 0000:8f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.577685] pci 0000:8f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.577855] pci 0000:8f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.578028] pci 0000:8f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.578204] pci 0000:8f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.578385] pci 0000:8f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.578542] pci 0000:8f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.578719] pci 0000:8f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.578903] pci 0000:8f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.579073] pci 0000:8f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.579250] pci 0000:8f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.579429] pci 0000:8f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.579609] pci 0000:8f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.579791] pci 0000:8f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.579940] pci 0000:8f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.580130] pci 0000:8f:11.2: [8086:0efa] type 00 class 0x088000
[   89.580333] pci 0000:8f:11.4: [8086:0efc] type 00 class 0x088000
[   89.580509] pci 0000:8f:11.5: [8086:0efd] type 00 class 0x088000
[   89.580695] pci 0000:8f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.580867] pci 0000:8f:13.1: [8086:0e34] type 00 class 0x110100
[   89.581038] pci 0000:8f:13.4: [8086:0e81] type 00 class 0x088000
[   89.581199] pci 0000:8f:13.5: [8086:0e36] type 00 class 0x110100
[   89.581354] pci 0000:8f:13.6: [8086:0e37] type 00 class 0x110100
[   89.581503] pci 0000:8f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.581652] pci 0000:8f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.581803] pci 0000:8f:16.2: [8086:0eca] type 00 class 0x088000
[   89.581987] pci 0000:8f:18.0: [8086:0e40] type 00 class 0x088000
[   89.582136] pci 0000:8f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.582309] pci 0000:8f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.582470] pci 0000:8f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.582643] pci 0000:8f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.582817] pci 0000:8f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.582997] pci 0000:8f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.583174] pci 0000:8f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.583345] pci 0000:8f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.583544] pci 0000:8f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.583718] pci 0000:8f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.583894] pci 0000:8f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.584082] pci 0000:8f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.584278] pci 0000:8f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.584463] pci 0000:8f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.584644] pci 0000:8f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.584810] pci 0000:8f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.584992] pci 0000:8f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.585177] pci 0000:8f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.585348] pci 0000:8f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.585539] pci 0000:8f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.585732] pci 0000:8f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.585893] pci 0000:8f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.586068] pci 0000:8f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.586242] pci_bus 0000:8f: busn_res: [bus 8f-ff] end is updated to 8f
[   89.586245] pci_bus 0000:8f: busn_res: can not insert [bus 8f] under domain [bus 00-ff] (conflicts with (null) [bus 84-8f])
[   89.586493] PCI: Discovered peer bus 9f
[   89.590714] PCI: root bus 9f: using default resources
[   89.590717] PCI: Probing PCI hardware (bus 9f)
[   89.590836] PCI host bridge to bus 0000:9f
[   89.595343] pci_bus 0000:9f: root bus resource [io  0x0000-0xffff]
[   89.602146] pci_bus 0000:9f: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.610098] pci_bus 0000:9f: No busn resource found for root bus, will use [bus 9f-ff]
[   89.618816] pci_bus 0000:9f: busn_res: can not insert [bus 9f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 90-9f])
[   89.618831] pci 0000:9f:08.0: [8086:0e80] type 00 class 0x088000
[   89.619021] pci 0000:9f:08.2: [8086:0e32] type 00 class 0x110100
[   89.619178] pci 0000:9f:09.0: [8086:0e90] type 00 class 0x088000
[   89.619357] pci 0000:9f:09.2: [8086:0e33] type 00 class 0x110100
[   89.619519] pci 0000:9f:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.619663] pci 0000:9f:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.619811] pci 0000:9f:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.619979] pci 0000:9f:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.620158] pci 0000:9f:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.620315] pci 0000:9f:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.620480] pci 0000:9f:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.620651] pci 0000:9f:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.620808] pci 0000:9f:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.620956] pci 0000:9f:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.621090] pci 0000:9f:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.621256] pci 0000:9f:0c.5: [8086:0eea] type 00 class 0x088000
[   89.621392] pci 0000:9f:0c.6: [8086:0eec] type 00 class 0x088000
[   89.621563] pci 0000:9f:0c.7: [8086:0eee] type 00 class 0x088000
[   89.621702] pci 0000:9f:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.621850] pci 0000:9f:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.621989] pci 0000:9f:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.622139] pci 0000:9f:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.622280] pci 0000:9f:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.622438] pci 0000:9f:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.622590] pci 0000:9f:0d.6: [8086:0eed] type 00 class 0x088000
[   89.622748] pci 0000:9f:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.622907] pci 0000:9f:0e.1: [8086:0e30] type 00 class 0x110100
[   89.623064] pci 0000:9f:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.623235] pci 0000:9f:0f.1: [8086:0e71] type 00 class 0x088000
[   89.623417] pci 0000:9f:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.623583] pci 0000:9f:0f.3: [8086:0eab] type 00 class 0x088000
[   89.623760] pci 0000:9f:0f.4: [8086:0eac] type 00 class 0x088000
[   89.623936] pci 0000:9f:0f.5: [8086:0ead] type 00 class 0x088000
[   89.624153] pci 0000:9f:10.0: [8086:0eb0] type 00 class 0x088000
[   89.624337] pci 0000:9f:10.1: [8086:0eb1] type 00 class 0x088000
[   89.624521] pci 0000:9f:10.2: [8086:0eb2] type 00 class 0x088000
[   89.624698] pci 0000:9f:10.3: [8086:0eb3] type 00 class 0x088000
[   89.624884] pci 0000:9f:10.4: [8086:0eb4] type 00 class 0x088000
[   89.625077] pci 0000:9f:10.5: [8086:0eb5] type 00 class 0x088000
[   89.625250] pci 0000:9f:10.6: [8086:0eb6] type 00 class 0x088000
[   89.625423] pci 0000:9f:10.7: [8086:0eb7] type 00 class 0x088000
[   89.625613] pci 0000:9f:11.0: [8086:0ef8] type 00 class 0x088000
[   89.625775] pci 0000:9f:11.1: [8086:0ef9] type 00 class 0x088000
[   89.625951] pci 0000:9f:11.2: [8086:0efa] type 00 class 0x088000
[   89.626129] pci 0000:9f:11.4: [8086:0efc] type 00 class 0x088000
[   89.626300] pci 0000:9f:11.5: [8086:0efd] type 00 class 0x088000
[   89.626479] pci 0000:9f:13.0: [8086:0e1d] type 00 class 0x088000
[   89.626622] pci 0000:9f:13.1: [8086:0e34] type 00 class 0x110100
[   89.626784] pci 0000:9f:13.4: [8086:0e81] type 00 class 0x088000
[   89.626946] pci 0000:9f:13.5: [8086:0e36] type 00 class 0x110100
[   89.627104] pci 0000:9f:13.6: [8086:0e37] type 00 class 0x110100
[   89.627272] pci 0000:9f:16.0: [8086:0ec8] type 00 class 0x088000
[   89.627442] pci 0000:9f:16.1: [8086:0ec9] type 00 class 0x088000
[   89.627599] pci 0000:9f:16.2: [8086:0eca] type 00 class 0x088000
[   89.627781] pci 0000:9f:18.0: [8086:0e40] type 00 class 0x088000
[   89.627968] pci 0000:9f:18.2: [8086:0e3a] type 00 class 0x110100
[   89.628128] pci 0000:9f:1c.0: [8086:0e60] type 00 class 0x088000
[   89.628317] pci 0000:9f:1c.1: [8086:0e38] type 00 class 0x110100
[   89.628543] pci 0000:9f:1d.0: [8086:0e68] type 00 class 0x088000
[   89.628728] pci 0000:9f:1d.1: [8086:0e79] type 00 class 0x088000
[   89.628902] pci 0000:9f:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.629089] pci 0000:9f:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.629262] pci 0000:9f:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.629400] pci 0000:9f:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.629596] pci 0000:9f:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.629778] pci 0000:9f:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.629934] pci 0000:9f:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.630099] pci 0000:9f:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.630270] pci 0000:9f:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.630453] pci 0000:9f:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.630637] pci 0000:9f:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.630835] pci 0000:9f:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.631003] pci 0000:9f:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.631201] pci 0000:9f:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.631375] pci 0000:9f:1f.4: [8086:0edc] type 00 class 0x088000
[   89.631532] pci 0000:9f:1f.5: [8086:0edd] type 00 class 0x088000
[   89.631722] pci 0000:9f:1f.6: [8086:0ede] type 00 class 0x088000
[   89.631896] pci 0000:9f:1f.7: [8086:0edf] type 00 class 0x088000
[   89.632066] pci_bus 0000:9f: busn_res: [bus 9f-ff] end is updated to 9f
[   89.632069] pci_bus 0000:9f: busn_res: can not insert [bus 9f] under domain [bus 00-ff] (conflicts with (null) [bus 90-9f])
[   89.632399] PCI: Discovered peer bus af
[   89.636629] PCI: root bus af: using default resources
[   89.636632] PCI: Probing PCI hardware (bus af)
[   89.636748] PCI host bridge to bus 0000:af
[   89.641257] pci_bus 0000:af: root bus resource [io  0x0000-0xffff]
[   89.648063] pci_bus 0000:af: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.656012] pci_bus 0000:af: No busn resource found for root bus, will use [bus af-ff]
[   89.664733] pci_bus 0000:af: busn_res: can not insert [bus af-ff] under domain [bus 00-ff] (conflicts with (null) [bus a0-af])
[   89.664748] pci 0000:af:08.0: [8086:0e80] type 00 class 0x088000
[   89.664917] pci 0000:af:08.2: [8086:0e32] type 00 class 0x110100
[   89.665075] pci 0000:af:09.0: [8086:0e90] type 00 class 0x088000
[   89.665259] pci 0000:af:09.2: [8086:0e33] type 00 class 0x110100
[   89.665414] pci 0000:af:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.665576] pci 0000:af:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.665735] pci 0000:af:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.665883] pci 0000:af:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.666037] pci 0000:af:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.666194] pci 0000:af:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.666345] pci 0000:af:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.666491] pci 0000:af:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.666647] pci 0000:af:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.666797] pci 0000:af:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.666946] pci 0000:af:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.667104] pci 0000:af:0c.5: [8086:0eea] type 00 class 0x088000
[   89.667262] pci 0000:af:0c.6: [8086:0eec] type 00 class 0x088000
[   89.667406] pci 0000:af:0c.7: [8086:0eee] type 00 class 0x088000
[   89.667550] pci 0000:af:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.667696] pci 0000:af:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.667849] pci 0000:af:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.667997] pci 0000:af:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.668146] pci 0000:af:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.668294] pci 0000:af:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.668430] pci 0000:af:0d.6: [8086:0eed] type 00 class 0x088000
[   89.668603] pci 0000:af:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.668783] pci 0000:af:0e.1: [8086:0e30] type 00 class 0x110100
[   89.668928] pci 0000:af:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.669122] pci 0000:af:0f.1: [8086:0e71] type 00 class 0x088000
[   89.669298] pci 0000:af:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.669489] pci 0000:af:0f.3: [8086:0eab] type 00 class 0x088000
[   89.669668] pci 0000:af:0f.4: [8086:0eac] type 00 class 0x088000
[   89.669845] pci 0000:af:0f.5: [8086:0ead] type 00 class 0x088000
[   89.670024] pci 0000:af:10.0: [8086:0eb0] type 00 class 0x088000
[   89.670201] pci 0000:af:10.1: [8086:0eb1] type 00 class 0x088000
[   89.670367] pci 0000:af:10.2: [8086:0eb2] type 00 class 0x088000
[   89.670544] pci 0000:af:10.3: [8086:0eb3] type 00 class 0x088000
[   89.670700] pci 0000:af:10.4: [8086:0eb4] type 00 class 0x088000
[   89.670872] pci 0000:af:10.5: [8086:0eb5] type 00 class 0x088000
[   89.671047] pci 0000:af:10.6: [8086:0eb6] type 00 class 0x088000
[   89.671219] pci 0000:af:10.7: [8086:0eb7] type 00 class 0x088000
[   89.671390] pci 0000:af:11.0: [8086:0ef8] type 00 class 0x088000
[   89.671575] pci 0000:af:11.1: [8086:0ef9] type 00 class 0x088000
[   89.671748] pci 0000:af:11.2: [8086:0efa] type 00 class 0x088000
[   89.671927] pci 0000:af:11.4: [8086:0efc] type 00 class 0x088000
[   89.672076] pci 0000:af:11.5: [8086:0efd] type 00 class 0x088000
[   89.672301] pci 0000:af:13.0: [8086:0e1d] type 00 class 0x088000
[   89.672465] pci 0000:af:13.1: [8086:0e34] type 00 class 0x110100
[   89.672613] pci 0000:af:13.4: [8086:0e81] type 00 class 0x088000
[   89.672771] pci 0000:af:13.5: [8086:0e36] type 00 class 0x110100
[   89.672926] pci 0000:af:13.6: [8086:0e37] type 00 class 0x110100
[   89.673083] pci 0000:af:16.0: [8086:0ec8] type 00 class 0x088000
[   89.673250] pci 0000:af:16.1: [8086:0ec9] type 00 class 0x088000
[   89.673393] pci 0000:af:16.2: [8086:0eca] type 00 class 0x088000
[   89.673552] pci 0000:af:18.0: [8086:0e40] type 00 class 0x088000
[   89.673700] pci 0000:af:18.2: [8086:0e3a] type 00 class 0x110100
[   89.673882] pci 0000:af:1c.0: [8086:0e60] type 00 class 0x088000
[   89.674045] pci 0000:af:1c.1: [8086:0e38] type 00 class 0x110100
[   89.674225] pci 0000:af:1d.0: [8086:0e68] type 00 class 0x088000
[   89.674419] pci 0000:af:1d.1: [8086:0e79] type 00 class 0x088000
[   89.674595] pci 0000:af:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.674776] pci 0000:af:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.674978] pci 0000:af:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.675168] pci 0000:af:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.675343] pci 0000:af:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.675524] pci 0000:af:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.675693] pci 0000:af:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.675884] pci 0000:af:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.676057] pci 0000:af:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.676235] pci 0000:af:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.676444] pci 0000:af:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.676683] pci 0000:af:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.676858] pci 0000:af:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.677037] pci 0000:af:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.677222] pci 0000:af:1f.4: [8086:0edc] type 00 class 0x088000
[   89.677407] pci 0000:af:1f.5: [8086:0edd] type 00 class 0x088000
[   89.677576] pci 0000:af:1f.6: [8086:0ede] type 00 class 0x088000
[   89.677762] pci 0000:af:1f.7: [8086:0edf] type 00 class 0x088000
[   89.677915] pci_bus 0000:af: busn_res: [bus af-ff] end is updated to af
[   89.677918] pci_bus 0000:af: busn_res: can not insert [bus af] under domain [bus 00-ff] (conflicts with (null) [bus a0-af])
[   89.678167] PCI: Discovered peer bus bf
[   89.682389] PCI: root bus bf: using default resources
[   89.682399] PCI: Probing PCI hardware (bus bf)
[   89.682523] PCI host bridge to bus 0000:bf
[   89.687030] pci_bus 0000:bf: root bus resource [io  0x0000-0xffff]
[   89.693835] pci_bus 0000:bf: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.701788] pci_bus 0000:bf: No busn resource found for root bus, will use [bus bf-ff]
[   89.710514] pci_bus 0000:bf: busn_res: can not insert [bus bf-ff] under domain [bus 00-ff] (conflicts with (null) [bus b0-bf])
[   89.710525] pci 0000:bf:08.0: [8086:0e80] type 00 class 0x088000
[   89.710697] pci 0000:bf:08.2: [8086:0e32] type 00 class 0x110100
[   89.710868] pci 0000:bf:09.0: [8086:0e90] type 00 class 0x088000
[   89.711032] pci 0000:bf:09.2: [8086:0e33] type 00 class 0x110100
[   89.711183] pci 0000:bf:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.711324] pci 0000:bf:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.711464] pci 0000:bf:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.711614] pci 0000:bf:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.711775] pci 0000:bf:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.711931] pci 0000:bf:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.712091] pci 0000:bf:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.712232] pci 0000:bf:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.712393] pci 0000:bf:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.712560] pci 0000:bf:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.712714] pci 0000:bf:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.712868] pci 0000:bf:0c.5: [8086:0eea] type 00 class 0x088000
[   89.713031] pci 0000:bf:0c.6: [8086:0eec] type 00 class 0x088000
[   89.713170] pci 0000:bf:0c.7: [8086:0eee] type 00 class 0x088000
[   89.713339] pci 0000:bf:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.713480] pci 0000:bf:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.713631] pci 0000:bf:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.713813] pci 0000:bf:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.713974] pci 0000:bf:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.714125] pci 0000:bf:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.714294] pci 0000:bf:0d.6: [8086:0eed] type 00 class 0x088000
[   89.714447] pci 0000:bf:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.714612] pci 0000:bf:0e.1: [8086:0e30] type 00 class 0x110100
[   89.714775] pci 0000:bf:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.714947] pci 0000:bf:0f.1: [8086:0e71] type 00 class 0x088000
[   89.715122] pci 0000:bf:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.715292] pci 0000:bf:0f.3: [8086:0eab] type 00 class 0x088000
[   89.715471] pci 0000:bf:0f.4: [8086:0eac] type 00 class 0x088000
[   89.715653] pci 0000:bf:0f.5: [8086:0ead] type 00 class 0x088000
[   89.715828] pci 0000:bf:10.0: [8086:0eb0] type 00 class 0x088000
[   89.716000] pci 0000:bf:10.1: [8086:0eb1] type 00 class 0x088000
[   89.716179] pci 0000:bf:10.2: [8086:0eb2] type 00 class 0x088000
[   89.716354] pci 0000:bf:10.3: [8086:0eb3] type 00 class 0x088000
[   89.716557] pci 0000:bf:10.4: [8086:0eb4] type 00 class 0x088000
[   89.716740] pci 0000:bf:10.5: [8086:0eb5] type 00 class 0x088000
[   89.716919] pci 0000:bf:10.6: [8086:0eb6] type 00 class 0x088000
[   89.717093] pci 0000:bf:10.7: [8086:0eb7] type 00 class 0x088000
[   89.717268] pci 0000:bf:11.0: [8086:0ef8] type 00 class 0x088000
[   89.717454] pci 0000:bf:11.1: [8086:0ef9] type 00 class 0x088000
[   89.717619] pci 0000:bf:11.2: [8086:0efa] type 00 class 0x088000
[   89.717810] pci 0000:bf:11.4: [8086:0efc] type 00 class 0x088000
[   89.717992] pci 0000:bf:11.5: [8086:0efd] type 00 class 0x088000
[   89.718172] pci 0000:bf:13.0: [8086:0e1d] type 00 class 0x088000
[   89.718324] pci 0000:bf:13.1: [8086:0e34] type 00 class 0x110100
[   89.718470] pci 0000:bf:13.4: [8086:0e81] type 00 class 0x088000
[   89.718632] pci 0000:bf:13.5: [8086:0e36] type 00 class 0x110100
[   89.718769] pci 0000:bf:13.6: [8086:0e37] type 00 class 0x110100
[   89.718943] pci 0000:bf:16.0: [8086:0ec8] type 00 class 0x088000
[   89.719095] pci 0000:bf:16.1: [8086:0ec9] type 00 class 0x088000
[   89.719255] pci 0000:bf:16.2: [8086:0eca] type 00 class 0x088000
[   89.719422] pci 0000:bf:18.0: [8086:0e40] type 00 class 0x088000
[   89.719589] pci 0000:bf:18.2: [8086:0e3a] type 00 class 0x110100
[   89.719754] pci 0000:bf:1c.0: [8086:0e60] type 00 class 0x088000
[   89.719911] pci 0000:bf:1c.1: [8086:0e38] type 00 class 0x110100
[   89.720083] pci 0000:bf:1d.0: [8086:0e68] type 00 class 0x088000
[   89.720260] pci 0000:bf:1d.1: [8086:0e79] type 00 class 0x088000
[   89.720445] pci 0000:bf:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.720627] pci 0000:bf:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.720802] pci 0000:bf:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.720975] pci 0000:bf:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.721171] pci 0000:bf:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.721353] pci 0000:bf:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.721532] pci 0000:bf:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.721701] pci 0000:bf:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.721892] pci 0000:bf:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.722052] pci 0000:bf:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.722225] pci 0000:bf:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.722404] pci 0000:bf:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.722593] pci 0000:bf:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.722763] pci 0000:bf:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.722949] pci 0000:bf:1f.4: [8086:0edc] type 00 class 0x088000
[   89.723133] pci 0000:bf:1f.5: [8086:0edd] type 00 class 0x088000
[   89.723314] pci 0000:bf:1f.6: [8086:0ede] type 00 class 0x088000
[   89.723492] pci 0000:bf:1f.7: [8086:0edf] type 00 class 0x088000
[   89.723667] pci_bus 0000:bf: busn_res: [bus bf-ff] end is updated to bf
[   89.723670] pci_bus 0000:bf: busn_res: can not insert [bus bf] under domain [bus 00-ff] (conflicts with (null) [bus b0-bf])
[   89.724000] PCI: Discovered peer bus cf
[   89.728220] PCI: root bus cf: using default resources
[   89.728224] PCI: Probing PCI hardware (bus cf)
[   89.728322] PCI host bridge to bus 0000:cf
[   89.732838] pci_bus 0000:cf: root bus resource [io  0x0000-0xffff]
[   89.739645] pci_bus 0000:cf: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.747598] pci_bus 0000:cf: No busn resource found for root bus, will use [bus cf-ff]
[   89.756312] pci_bus 0000:cf: busn_res: can not insert [bus cf-ff] under domain [bus 00-ff] (conflicts with (null) [bus c0-cf])
[   89.756330] pci 0000:cf:08.0: [8086:0e80] type 00 class 0x088000
[   89.756517] pci 0000:cf:08.2: [8086:0e32] type 00 class 0x110100
[   89.756685] pci 0000:cf:09.0: [8086:0e90] type 00 class 0x088000
[   89.756852] pci 0000:cf:09.2: [8086:0e33] type 00 class 0x110100
[   89.757008] pci 0000:cf:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.757177] pci 0000:cf:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.757327] pci 0000:cf:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.757485] pci 0000:cf:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.757630] pci 0000:cf:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.757783] pci 0000:cf:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.757927] pci 0000:cf:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.758073] pci 0000:cf:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.758231] pci 0000:cf:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.758397] pci 0000:cf:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.758555] pci 0000:cf:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.758708] pci 0000:cf:0c.5: [8086:0eea] type 00 class 0x088000
[   89.758861] pci 0000:cf:0c.6: [8086:0eec] type 00 class 0x088000
[   89.758999] pci 0000:cf:0c.7: [8086:0eee] type 00 class 0x088000
[   89.759157] pci 0000:cf:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.759301] pci 0000:cf:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.759473] pci 0000:cf:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.759629] pci 0000:cf:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.759786] pci 0000:cf:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.759947] pci 0000:cf:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.760109] pci 0000:cf:0d.6: [8086:0eed] type 00 class 0x088000
[   89.760280] pci 0000:cf:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.760461] pci 0000:cf:0e.1: [8086:0e30] type 00 class 0x110100
[   89.760626] pci 0000:cf:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.760830] pci 0000:cf:0f.1: [8086:0e71] type 00 class 0x088000
[   89.761033] pci 0000:cf:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.761220] pci 0000:cf:0f.3: [8086:0eab] type 00 class 0x088000
[   89.761388] pci 0000:cf:0f.4: [8086:0eac] type 00 class 0x088000
[   89.761572] pci 0000:cf:0f.5: [8086:0ead] type 00 class 0x088000
[   89.761740] pci 0000:cf:10.0: [8086:0eb0] type 00 class 0x088000
[   89.761924] pci 0000:cf:10.1: [8086:0eb1] type 00 class 0x088000
[   89.762101] pci 0000:cf:10.2: [8086:0eb2] type 00 class 0x088000
[   89.762274] pci 0000:cf:10.3: [8086:0eb3] type 00 class 0x088000
[   89.762454] pci 0000:cf:10.4: [8086:0eb4] type 00 class 0x088000
[   89.762645] pci 0000:cf:10.5: [8086:0eb5] type 00 class 0x088000
[   89.762815] pci 0000:cf:10.6: [8086:0eb6] type 00 class 0x088000
[   89.763003] pci 0000:cf:10.7: [8086:0eb7] type 00 class 0x088000
[   89.763175] pci 0000:cf:11.0: [8086:0ef8] type 00 class 0x088000
[   89.763361] pci 0000:cf:11.1: [8086:0ef9] type 00 class 0x088000
[   89.763536] pci 0000:cf:11.2: [8086:0efa] type 00 class 0x088000
[   89.763710] pci 0000:cf:11.4: [8086:0efc] type 00 class 0x088000
[   89.763868] pci 0000:cf:11.5: [8086:0efd] type 00 class 0x088000
[   89.764058] pci 0000:cf:13.0: [8086:0e1d] type 00 class 0x088000
[   89.764194] pci 0000:cf:13.1: [8086:0e34] type 00 class 0x110100
[   89.764341] pci 0000:cf:13.4: [8086:0e81] type 00 class 0x088000
[   89.764475] pci 0000:cf:13.5: [8086:0e36] type 00 class 0x110100
[   89.764629] pci 0000:cf:13.6: [8086:0e37] type 00 class 0x110100
[   89.764798] pci 0000:cf:16.0: [8086:0ec8] type 00 class 0x088000
[   89.764981] pci 0000:cf:16.1: [8086:0ec9] type 00 class 0x088000
[   89.765134] pci 0000:cf:16.2: [8086:0eca] type 00 class 0x088000
[   89.765296] pci 0000:cf:18.0: [8086:0e40] type 00 class 0x088000
[   89.765445] pci 0000:cf:18.2: [8086:0e3a] type 00 class 0x110100
[   89.765606] pci 0000:cf:1c.0: [8086:0e60] type 00 class 0x088000
[   89.765779] pci 0000:cf:1c.1: [8086:0e38] type 00 class 0x110100
[   89.765924] pci 0000:cf:1d.0: [8086:0e68] type 00 class 0x088000
[   89.766102] pci 0000:cf:1d.1: [8086:0e79] type 00 class 0x088000
[   89.766269] pci 0000:cf:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.766443] pci 0000:cf:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.766617] pci 0000:cf:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.766790] pci 0000:cf:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.766952] pci 0000:cf:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.767142] pci 0000:cf:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.767319] pci 0000:cf:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.767491] pci 0000:cf:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.767671] pci 0000:cf:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.767910] pci 0000:cf:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.768091] pci 0000:cf:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.768300] pci 0000:cf:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.768510] pci 0000:cf:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.768692] pci 0000:cf:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.768950] pci 0000:cf:1f.4: [8086:0edc] type 00 class 0x088000
[   89.769118] pci 0000:cf:1f.5: [8086:0edd] type 00 class 0x088000
[   89.769306] pci 0000:cf:1f.6: [8086:0ede] type 00 class 0x088000
[   89.769496] pci 0000:cf:1f.7: [8086:0edf] type 00 class 0x088000
[   89.769662] pci_bus 0000:cf: busn_res: [bus cf-ff] end is updated to cf
[   89.769664] pci_bus 0000:cf: busn_res: can not insert [bus cf] under domain [bus 00-ff] (conflicts with (null) [bus c0-cf])
[   89.769910] PCI: Discovered peer bus df
[   89.774137] PCI: root bus df: using default resources
[   89.774141] PCI: Probing PCI hardware (bus df)
[   89.774256] PCI host bridge to bus 0000:df
[   89.778768] pci_bus 0000:df: root bus resource [io  0x0000-0xffff]
[   89.785572] pci_bus 0000:df: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.793525] pci_bus 0000:df: No busn resource found for root bus, will use [bus df-ff]
[   89.802247] pci_bus 0000:df: busn_res: can not insert [bus df-ff] under domain [bus 00-ff] (conflicts with (null) [bus d0-df])
[   89.802268] pci 0000:df:08.0: [8086:0e80] type 00 class 0x088000
[   89.802432] pci 0000:df:08.2: [8086:0e32] type 00 class 0x110100
[   89.802595] pci 0000:df:09.0: [8086:0e90] type 00 class 0x088000
[   89.802743] pci 0000:df:09.2: [8086:0e33] type 00 class 0x110100
[   89.802897] pci 0000:df:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.803062] pci 0000:df:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.803213] pci 0000:df:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.803374] pci 0000:df:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.803513] pci 0000:df:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.803656] pci 0000:df:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.803802] pci 0000:df:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.803974] pci 0000:df:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.804112] pci 0000:df:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.804286] pci 0000:df:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.804431] pci 0000:df:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.804592] pci 0000:df:0c.5: [8086:0eea] type 00 class 0x088000
[   89.804739] pci 0000:df:0c.6: [8086:0eec] type 00 class 0x088000
[   89.804901] pci 0000:df:0c.7: [8086:0eee] type 00 class 0x088000
[   89.805047] pci 0000:df:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.805205] pci 0000:df:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.805368] pci 0000:df:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.805521] pci 0000:df:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.805649] pci 0000:df:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.805777] pci 0000:df:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.805921] pci 0000:df:0d.6: [8086:0eed] type 00 class 0x088000
[   89.806068] pci 0000:df:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.806232] pci 0000:df:0e.1: [8086:0e30] type 00 class 0x110100
[   89.806408] pci 0000:df:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.806598] pci 0000:df:0f.1: [8086:0e71] type 00 class 0x088000
[   89.806764] pci 0000:df:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.806931] pci 0000:df:0f.3: [8086:0eab] type 00 class 0x088000
[   89.807091] pci 0000:df:0f.4: [8086:0eac] type 00 class 0x088000
[   89.807260] pci 0000:df:0f.5: [8086:0ead] type 00 class 0x088000
[   89.807437] pci 0000:df:10.0: [8086:0eb0] type 00 class 0x088000
[   89.807608] pci 0000:df:10.1: [8086:0eb1] type 00 class 0x088000
[   89.807783] pci 0000:df:10.2: [8086:0eb2] type 00 class 0x088000
[   89.807972] pci 0000:df:10.3: [8086:0eb3] type 00 class 0x088000
[   89.808140] pci 0000:df:10.4: [8086:0eb4] type 00 class 0x088000
[   89.808311] pci 0000:df:10.5: [8086:0eb5] type 00 class 0x088000
[   89.808508] pci 0000:df:10.6: [8086:0eb6] type 00 class 0x088000
[   89.808702] pci 0000:df:10.7: [8086:0eb7] type 00 class 0x088000
[   89.808865] pci 0000:df:11.0: [8086:0ef8] type 00 class 0x088000
[   89.809048] pci 0000:df:11.1: [8086:0ef9] type 00 class 0x088000
[   89.809224] pci 0000:df:11.2: [8086:0efa] type 00 class 0x088000
[   89.809392] pci 0000:df:11.4: [8086:0efc] type 00 class 0x088000
[   89.809566] pci 0000:df:11.5: [8086:0efd] type 00 class 0x088000
[   89.809730] pci 0000:df:13.0: [8086:0e1d] type 00 class 0x088000
[   89.809888] pci 0000:df:13.1: [8086:0e34] type 00 class 0x110100
[   89.810044] pci 0000:df:13.4: [8086:0e81] type 00 class 0x088000
[   89.810201] pci 0000:df:13.5: [8086:0e36] type 00 class 0x110100
[   89.810367] pci 0000:df:13.6: [8086:0e37] type 00 class 0x110100
[   89.810535] pci 0000:df:16.0: [8086:0ec8] type 00 class 0x088000
[   89.810689] pci 0000:df:16.1: [8086:0ec9] type 00 class 0x088000
[   89.810841] pci 0000:df:16.2: [8086:0eca] type 00 class 0x088000
[   89.810992] pci 0000:df:18.0: [8086:0e40] type 00 class 0x088000
[   89.811146] pci 0000:df:18.2: [8086:0e3a] type 00 class 0x110100
[   89.811327] pci 0000:df:1c.0: [8086:0e60] type 00 class 0x088000
[   89.811498] pci 0000:df:1c.1: [8086:0e38] type 00 class 0x110100
[   89.811661] pci 0000:df:1d.0: [8086:0e68] type 00 class 0x088000
[   89.811836] pci 0000:df:1d.1: [8086:0e79] type 00 class 0x088000
[   89.811999] pci 0000:df:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.812186] pci 0000:df:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.812352] pci 0000:df:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.812542] pci 0000:df:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.812744] pci 0000:df:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.812944] pci 0000:df:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.813123] pci 0000:df:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.813295] pci 0000:df:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.813458] pci 0000:df:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.813639] pci 0000:df:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.813805] pci 0000:df:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.813978] pci 0000:df:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.814150] pci 0000:df:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.814331] pci 0000:df:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.814515] pci 0000:df:1f.4: [8086:0edc] type 00 class 0x088000
[   89.814713] pci 0000:df:1f.5: [8086:0edd] type 00 class 0x088000
[   89.814891] pci 0000:df:1f.6: [8086:0ede] type 00 class 0x088000
[   89.815075] pci 0000:df:1f.7: [8086:0edf] type 00 class 0x088000
[   89.815247] pci_bus 0000:df: busn_res: [bus df-ff] end is updated to df
[   89.815250] pci_bus 0000:df: busn_res: can not insert [bus df] under domain [bus 00-ff] (conflicts with (null) [bus d0-df])
[   89.815580] PCI: Discovered peer bus ef
[   89.819802] PCI: root bus ef: using default resources
[   89.819807] PCI: Probing PCI hardware (bus ef)
[   89.819936] PCI host bridge to bus 0000:ef
[   89.824468] pci_bus 0000:ef: root bus resource [io  0x0000-0xffff]
[   89.831280] pci_bus 0000:ef: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.839235] pci_bus 0000:ef: No busn resource found for root bus, will use [bus ef-ff]
[   89.847950] pci_bus 0000:ef: busn_res: can not insert [bus ef-ff] under domain [bus 00-ff] (conflicts with (null) [bus e0-ef])
[   89.847972] pci 0000:ef:08.0: [8086:0e80] type 00 class 0x088000
[   89.848126] pci 0000:ef:08.2: [8086:0e32] type 00 class 0x110100
[   89.848283] pci 0000:ef:09.0: [8086:0e90] type 00 class 0x088000
[   89.848446] pci 0000:ef:09.2: [8086:0e33] type 00 class 0x110100
[   89.848630] pci 0000:ef:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.848785] pci 0000:ef:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.848933] pci 0000:ef:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.849076] pci 0000:ef:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.849226] pci 0000:ef:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.849377] pci 0000:ef:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.849521] pci 0000:ef:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.849681] pci 0000:ef:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.849827] pci 0000:ef:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.849971] pci 0000:ef:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.850130] pci 0000:ef:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.850301] pci 0000:ef:0c.5: [8086:0eea] type 00 class 0x088000
[   89.850449] pci 0000:ef:0c.6: [8086:0eec] type 00 class 0x088000
[   89.850602] pci 0000:ef:0c.7: [8086:0eee] type 00 class 0x088000
[   89.850749] pci 0000:ef:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.850902] pci 0000:ef:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.851062] pci 0000:ef:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.851216] pci 0000:ef:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.851358] pci 0000:ef:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.851509] pci 0000:ef:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.851658] pci 0000:ef:0d.6: [8086:0eed] type 00 class 0x088000
[   89.851804] pci 0000:ef:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.851962] pci 0000:ef:0e.1: [8086:0e30] type 00 class 0x110100
[   89.852121] pci 0000:ef:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.852298] pci 0000:ef:0f.1: [8086:0e71] type 00 class 0x088000
[   89.852474] pci 0000:ef:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.852688] pci 0000:ef:0f.3: [8086:0eab] type 00 class 0x088000
[   89.852866] pci 0000:ef:0f.4: [8086:0eac] type 00 class 0x088000
[   89.853022] pci 0000:ef:0f.5: [8086:0ead] type 00 class 0x088000
[   89.853210] pci 0000:ef:10.0: [8086:0eb0] type 00 class 0x088000
[   89.853398] pci 0000:ef:10.1: [8086:0eb1] type 00 class 0x088000
[   89.853568] pci 0000:ef:10.2: [8086:0eb2] type 00 class 0x088000
[   89.853743] pci 0000:ef:10.3: [8086:0eb3] type 00 class 0x088000
[   89.853918] pci 0000:ef:10.4: [8086:0eb4] type 00 class 0x088000
[   89.854102] pci 0000:ef:10.5: [8086:0eb5] type 00 class 0x088000
[   89.854290] pci 0000:ef:10.6: [8086:0eb6] type 00 class 0x088000
[   89.854469] pci 0000:ef:10.7: [8086:0eb7] type 00 class 0x088000
[   89.854657] pci 0000:ef:11.0: [8086:0ef8] type 00 class 0x088000
[   89.854824] pci 0000:ef:11.1: [8086:0ef9] type 00 class 0x088000
[   89.855008] pci 0000:ef:11.2: [8086:0efa] type 00 class 0x088000
[   89.855183] pci 0000:ef:11.4: [8086:0efc] type 00 class 0x088000
[   89.855345] pci 0000:ef:11.5: [8086:0efd] type 00 class 0x088000
[   89.855527] pci 0000:ef:13.0: [8086:0e1d] type 00 class 0x088000
[   89.855675] pci 0000:ef:13.1: [8086:0e34] type 00 class 0x110100
[   89.855834] pci 0000:ef:13.4: [8086:0e81] type 00 class 0x088000
[   89.855994] pci 0000:ef:13.5: [8086:0e36] type 00 class 0x110100
[   89.856156] pci 0000:ef:13.6: [8086:0e37] type 00 class 0x110100
[   89.856303] pci 0000:ef:16.0: [8086:0ec8] type 00 class 0x088000
[   89.856458] pci 0000:ef:16.1: [8086:0ec9] type 00 class 0x088000
[   89.856618] pci 0000:ef:16.2: [8086:0eca] type 00 class 0x088000
[   89.856772] pci 0000:ef:18.0: [8086:0e40] type 00 class 0x088000
[   89.856943] pci 0000:ef:18.2: [8086:0e3a] type 00 class 0x110100
[   89.857114] pci 0000:ef:1c.0: [8086:0e60] type 00 class 0x088000
[   89.857279] pci 0000:ef:1c.1: [8086:0e38] type 00 class 0x110100
[   89.857434] pci 0000:ef:1d.0: [8086:0e68] type 00 class 0x088000
[   89.857634] pci 0000:ef:1d.1: [8086:0e79] type 00 class 0x088000
[   89.857805] pci 0000:ef:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.857968] pci 0000:ef:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.858145] pci 0000:ef:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.858313] pci 0000:ef:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.858487] pci 0000:ef:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.858668] pci 0000:ef:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.858838] pci 0000:ef:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.859029] pci 0000:ef:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.859203] pci 0000:ef:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.859376] pci 0000:ef:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.859543] pci 0000:ef:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.859736] pci 0000:ef:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.859914] pci 0000:ef:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.860090] pci 0000:ef:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.860280] pci 0000:ef:1f.4: [8086:0edc] type 00 class 0x088000
[   89.860463] pci 0000:ef:1f.5: [8086:0edd] type 00 class 0x088000
[   89.860640] pci 0000:ef:1f.6: [8086:0ede] type 00 class 0x088000
[   89.860817] pci 0000:ef:1f.7: [8086:0edf] type 00 class 0x088000
[   89.861027] pci_bus 0000:ef: busn_res: [bus ef-ff] end is updated to ef
[   89.861030] pci_bus 0000:ef: busn_res: can not insert [bus ef] under domain [bus 00-ff] (conflicts with (null) [bus e0-ef])
[   89.861278] PCI: Discovered peer bus ff
[   89.865505] PCI: root bus ff: using default resources
[   89.865509] PCI: Probing PCI hardware (bus ff)
[   89.865645] PCI host bridge to bus 0000:ff
[   89.870155] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[   89.876956] pci_bus 0000:ff: root bus resource [mem 0x00000000-0x3fffffffffff]
[   89.884908] pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
[   89.893626] pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus f0-ff])
[   89.893654] pci 0000:ff:08.0: [8086:0e80] type 00 class 0x088000
[   89.893814] pci 0000:ff:08.2: [8086:0e32] type 00 class 0x110100
[   89.893992] pci 0000:ff:09.0: [8086:0e90] type 00 class 0x088000
[   89.894152] pci 0000:ff:09.2: [8086:0e33] type 00 class 0x110100
[   89.894323] pci 0000:ff:0a.0: [8086:0ec0] type 00 class 0x088000
[   89.894491] pci 0000:ff:0a.1: [8086:0ec1] type 00 class 0x088000
[   89.894651] pci 0000:ff:0a.2: [8086:0ec2] type 00 class 0x088000
[   89.894828] pci 0000:ff:0a.3: [8086:0ec3] type 00 class 0x088000
[   89.894987] pci 0000:ff:0b.0: [8086:0e1e] type 00 class 0x088000
[   89.895147] pci 0000:ff:0b.3: [8086:0e1f] type 00 class 0x088000
[   89.895315] pci 0000:ff:0c.0: [8086:0ee0] type 00 class 0x088000
[   89.895461] pci 0000:ff:0c.1: [8086:0ee2] type 00 class 0x088000
[   89.895616] pci 0000:ff:0c.2: [8086:0ee4] type 00 class 0x088000
[   89.895783] pci 0000:ff:0c.3: [8086:0ee6] type 00 class 0x088000
[   89.895934] pci 0000:ff:0c.4: [8086:0ee8] type 00 class 0x088000
[   89.896087] pci 0000:ff:0c.5: [8086:0eea] type 00 class 0x088000
[   89.896220] pci 0000:ff:0c.6: [8086:0eec] type 00 class 0x088000
[   89.896373] pci 0000:ff:0c.7: [8086:0eee] type 00 class 0x088000
[   89.896553] pci 0000:ff:0d.0: [8086:0ee1] type 00 class 0x088000
[   89.896711] pci 0000:ff:0d.1: [8086:0ee3] type 00 class 0x088000
[   89.896864] pci 0000:ff:0d.2: [8086:0ee5] type 00 class 0x088000
[   89.897019] pci 0000:ff:0d.3: [8086:0ee7] type 00 class 0x088000
[   89.897172] pci 0000:ff:0d.4: [8086:0ee9] type 00 class 0x088000
[   89.897333] pci 0000:ff:0d.5: [8086:0eeb] type 00 class 0x088000
[   89.897501] pci 0000:ff:0d.6: [8086:0eed] type 00 class 0x088000
[   89.897661] pci 0000:ff:0e.0: [8086:0ea0] type 00 class 0x088000
[   89.897813] pci 0000:ff:0e.1: [8086:0e30] type 00 class 0x110100
[   89.897977] pci 0000:ff:0f.0: [8086:0ea8] type 00 class 0x088000
[   89.898163] pci 0000:ff:0f.1: [8086:0e71] type 00 class 0x088000
[   89.898338] pci 0000:ff:0f.2: [8086:0eaa] type 00 class 0x088000
[   89.898510] pci 0000:ff:0f.3: [8086:0eab] type 00 class 0x088000
[   89.898689] pci 0000:ff:0f.4: [8086:0eac] type 00 class 0x088000
[   89.898858] pci 0000:ff:0f.5: [8086:0ead] type 00 class 0x088000
[   89.899045] pci 0000:ff:10.0: [8086:0eb0] type 00 class 0x088000
[   89.899212] pci 0000:ff:10.1: [8086:0eb1] type 00 class 0x088000
[   89.899378] pci 0000:ff:10.2: [8086:0eb2] type 00 class 0x088000
[   89.899554] pci 0000:ff:10.3: [8086:0eb3] type 00 class 0x088000
[   89.899731] pci 0000:ff:10.4: [8086:0eb4] type 00 class 0x088000
[   89.899898] pci 0000:ff:10.5: [8086:0eb5] type 00 class 0x088000
[   89.900066] pci 0000:ff:10.6: [8086:0eb6] type 00 class 0x088000
[   89.900234] pci 0000:ff:10.7: [8086:0eb7] type 00 class 0x088000
[   89.900417] pci 0000:ff:11.0: [8086:0ef8] type 00 class 0x088000
[   89.900580] pci 0000:ff:11.1: [8086:0ef9] type 00 class 0x088000
[   89.900748] pci 0000:ff:11.2: [8086:0efa] type 00 class 0x088000
[   89.900925] pci 0000:ff:11.4: [8086:0efc] type 00 class 0x088000
[   89.901111] pci 0000:ff:11.5: [8086:0efd] type 00 class 0x088000
[   89.901287] pci 0000:ff:13.0: [8086:0e1d] type 00 class 0x088000
[   89.901444] pci 0000:ff:13.1: [8086:0e34] type 00 class 0x110100
[   89.901601] pci 0000:ff:13.4: [8086:0e81] type 00 class 0x088000
[   89.901756] pci 0000:ff:13.5: [8086:0e36] type 00 class 0x110100
[   89.901905] pci 0000:ff:13.6: [8086:0e37] type 00 class 0x110100
[   89.902058] pci 0000:ff:16.0: [8086:0ec8] type 00 class 0x088000
[   89.902205] pci 0000:ff:16.1: [8086:0ec9] type 00 class 0x088000
[   89.902352] pci 0000:ff:16.2: [8086:0eca] type 00 class 0x088000
[   89.902504] pci 0000:ff:18.0: [8086:0e40] type 00 class 0x088000
[   89.902680] pci 0000:ff:18.2: [8086:0e3a] type 00 class 0x110100
[   89.902830] pci 0000:ff:1c.0: [8086:0e60] type 00 class 0x088000
[   89.902989] pci 0000:ff:1c.1: [8086:0e38] type 00 class 0x110100
[   89.903173] pci 0000:ff:1d.0: [8086:0e68] type 00 class 0x088000
[   89.903350] pci 0000:ff:1d.1: [8086:0e79] type 00 class 0x088000
[   89.903528] pci 0000:ff:1d.2: [8086:0e6a] type 00 class 0x088000
[   89.903713] pci 0000:ff:1d.3: [8086:0e6b] type 00 class 0x088000
[   89.903889] pci 0000:ff:1d.4: [8086:0e6c] type 00 class 0x088000
[   89.904073] pci 0000:ff:1d.5: [8086:0e6d] type 00 class 0x088000
[   89.904255] pci 0000:ff:1e.0: [8086:0ef0] type 00 class 0x088000
[   89.904433] pci 0000:ff:1e.1: [8086:0ef1] type 00 class 0x088000
[   89.904629] pci 0000:ff:1e.2: [8086:0ef2] type 00 class 0x088000
[   89.904813] pci 0000:ff:1e.3: [8086:0ef3] type 00 class 0x088000
[   89.904985] pci 0000:ff:1e.4: [8086:0ef4] type 00 class 0x088000
[   89.905169] pci 0000:ff:1e.5: [8086:0ef5] type 00 class 0x088000
[   89.905342] pci 0000:ff:1e.6: [8086:0ef6] type 00 class 0x088000
[   89.905505] pci 0000:ff:1e.7: [8086:0ef7] type 00 class 0x088000
[   89.905702] pci 0000:ff:1f.0: [8086:0ed8] type 00 class 0x088000
[   89.905889] pci 0000:ff:1f.1: [8086:0ed9] type 00 class 0x088000
[   89.906071] pci 0000:ff:1f.4: [8086:0edc] type 00 class 0x088000
[   89.906268] pci 0000:ff:1f.5: [8086:0edd] type 00 class 0x088000
[   89.906440] pci 0000:ff:1f.6: [8086:0ede] type 00 class 0x088000
[   89.906615] pci 0000:ff:1f.7: [8086:0edf] type 00 class 0x088000
[   89.906784] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
[   89.906787] pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus f0-ff])
[   89.906809] PCI: pci_cache_line_size set to 64 bytes
[   89.909920] e820: reserve RAM buffer [mem 0x0008e000-0x0008ffff]
[   89.909925] e820: reserve RAM buffer [mem 0x6d00c000-0x6fffffff]
[   89.909927] e820: reserve RAM buffer [mem 0x6f3fc000-0x6fffffff]
[   89.909928] e820: reserve RAM buffer [mem 0x78bff000-0x7bffffff]
[   89.911069] NetLabel: Initializing
[   89.914820] NetLabel:  domain hash size = 128
[   89.919619] NetLabel:  protocols = UNLABELED CIPSOv4
[   89.925125] NetLabel:  unlabeled traffic allowed by default
[   89.931376] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[   89.938263] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[   89.950009] Switched to clocksource hpet
[   89.995678] AppArmor: AppArmor Filesystem Enabled
[   90.001216] pnp: PnP ACPI init
[   90.008471] pnp 00:00: Plug and Play ACPI device, IDs IPI0001 (active)
[   90.008961] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[   90.026866] pnp: PnP ACPI: found 2 devices
[   90.038574] pci 0000:01:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.049504] pci 0000:03:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.060438] pci 0000:03:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.071371] pci 0000:13:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.082306] pci 0000:21:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.093241] pci 0000:21:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.104174] pci 0000:23:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.115101] pci 0000:23:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.126032] pci 0000:33:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.136964] pci 0000:33:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.147892] pci 0000:41:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.158818] pci 0000:41:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.169751] pci 0000:43:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.180681] pci 0000:43:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.191608] pci 0000:53:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.202535] pci 0000:53:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.213464] pci 0000:61:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.224389] pci 0000:61:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.235318] pci 0000:63:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.246251] pci 0000:63:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.257180] pci 0000:73:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.268107] pci 0000:73:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.279040] pci 0000:85:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.289969] pci 0000:85:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.300895] pci 0000:87:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.311825] pci 0000:87:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.322757] pci 0000:93:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.333684] pci 0000:93:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.344615] pci 0000:a1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.355549] pci 0000:a1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.366478] pci 0000:a3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.377405] pci 0000:a3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.388337] pci 0000:b3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.399270] pci 0000:b3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.410198] pci 0000:c1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.421130] pci 0000:c1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.432063] pci 0000:c3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.442990] pci 0000:c3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.453920] pci 0000:d3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.464853] pci 0000:d3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.475784] pci 0000:e1:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.486710] pci 0000:e1:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.497642] pci 0000:e3:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.508577] pci 0000:e3:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[   90.519503] pci 0000:f3:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.530437] pci 0000:f3:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[   90.541484] pci 0000:00:02.0: BAR 13: assigned [io  0x2000-0x2fff]
[   90.548300] pci 0000:00:02.2: BAR 13: assigned [io  0x3000-0x3fff]
[   90.555129] pci 0000:01:00.0: BAR 6: assigned [mem 0x90680000-0x906fffff pref]
[   90.563096] pci 0000:01:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   90.570870] pci 0000:01:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   90.579026] pci 0000:01:00.0: BAR 2: assigned [io  0x2000-0x201f]
[   90.585749] pci 0000:01:00.1: BAR 2: assigned [io  0x2020-0x203f]
[   90.592472] pci 0000:00:02.0: PCI bridge to [bus 01-02]
[   90.598242] pci 0000:00:02.0:   bridge window [io  0x2000-0x2fff]
[   90.604971] pci 0000:00:02.0:   bridge window [mem 0x90400000-0x906fffff]
[   90.612455] pci 0000:00:02.0:   bridge window [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   90.621576] pci 0000:03:00.0: BAR 6: assigned [mem 0x90380000-0x903fffff pref]
[   90.629538] pci 0000:03:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   90.637309] pci 0000:03:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   90.645464] pci 0000:03:00.0: BAR 2: assigned [io  0x3000-0x301f]
[   90.652186] pci 0000:03:00.1: BAR 2: assigned [io  0x3020-0x303f]
[   90.658906] pci 0000:00:02.2: PCI bridge to [bus 03-04]
[   90.664672] pci 0000:00:02.2:   bridge window [io  0x3000-0x3fff]
[   90.671397] pci 0000:00:02.2:   bridge window [mem 0x90100000-0x903fffff]
[   90.678882] pci 0000:00:02.2:   bridge window [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   90.687995] pci 0000:00:03.0: PCI bridge to [bus 05]
[   90.693484] pci 0000:00:11.0: PCI bridge to [bus 06]
[   90.698974] pci 0000:07:00.2: BAR 6: assigned [mem 0x93a90000-0x93a9ffff pref]
[   90.706936] pci 0000:00:1c.0: PCI bridge to [bus 07]
[   90.712413] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[   90.719133] pci 0000:00:1c.0:   bridge window [mem 0x92000000-0x93efffff]
[   90.726626] pci_bus 0000:00: resource 4 [io  0x1000-0x3fff window]
[   90.726627] pci_bus 0000:00: resource 5 [io  0x0000-0x0cf7 window]
[   90.726629] pci_bus 0000:00: resource 6 [mem 0x90000000-0x93efffff window]
[   90.726630] pci_bus 0000:00: resource 7 [mem 0x000a0000-0x000bffff window]
[   90.726632] pci_bus 0000:00: resource 8 [mem 0xfed00000-0xfedfffff window]
[   90.726634] pci_bus 0000:00: resource 9 [mem 0xfc000000000-0xfc07fffffff window]
[   90.726635] pci_bus 0000:00: resource 10 [mem 0xfe000000000-0xfe07fffffff window]
[   90.726638] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[   90.726640] pci_bus 0000:01: resource 1 [mem 0x90400000-0x906fffff]
[   90.726641] pci_bus 0000:01: resource 2 [mem 0xfc07f700000-0xfc07fafffff 64bit pref]
[   90.726643] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[   90.726644] pci_bus 0000:03: resource 1 [mem 0x90100000-0x903fffff]
[   90.726646] pci_bus 0000:03: resource 2 [mem 0xfc07fb00000-0xfc07fefffff 64bit pref]
[   90.726648] pci_bus 0000:07: resource 0 [io  0x1000-0x1fff]
[   90.726649] pci_bus 0000:07: resource 1 [mem 0x92000000-0x93efffff]
[   90.726686] pci 0000:10:03.0: BAR 14: assigned [mem 0x94000000-0x940fffff]
[   90.734269] pci 0000:10:02.0: PCI bridge to [bus 11]
[   90.739757] pci 0000:10:02.2: PCI bridge to [bus 12]
[   90.745247] pci 0000:13:00.0: BAR 6: assigned [mem 0x94000000-0x9403ffff pref]
[   90.753209] pci 0000:13:00.1: BAR 6: assigned [mem 0x94040000-0x9407ffff pref]
[   90.761170] pci 0000:10:03.0: PCI bridge to [bus 13]
[   90.766649] pci 0000:10:03.0:   bridge window [mem 0x94000000-0x940fffff]
[   90.774135] pci 0000:10:03.0:   bridge window [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   90.783249] pci_bus 0000:10: resource 4 [io  0x4000-0x7fff window]
[   90.783251] pci_bus 0000:10: resource 5 [mem 0x94000000-0x97ff7fff window]
[   90.783252] pci_bus 0000:10: resource 6 [mem 0xfc400000000-0xfc47fffffff window]
[   90.783254] pci_bus 0000:13: resource 1 [mem 0x94000000-0x940fffff]
[   90.783256] pci_bus 0000:13: resource 2 [mem 0xfc47fc00000-0xfc47fefffff 64bit pref]
[   90.783308] pci 0000:20:02.0: BAR 13: assigned [io  0x8000-0x8fff]
[   90.790124] pci 0000:20:02.2: BAR 13: assigned [io  0x9000-0x9fff]
[   90.796941] pci 0000:20:1c.0: BAR 13: assigned [io  0xa000-0xafff]
[   90.803762] pci 0000:21:00.0: BAR 6: assigned [mem 0x98580000-0x985fffff pref]
[   90.811726] pci 0000:21:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   90.819499] pci 0000:21:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   90.827652] pci 0000:21:00.0: BAR 2: assigned [io  0x8000-0x801f]
[   90.834372] pci 0000:21:00.1: BAR 2: assigned [io  0x8020-0x803f]
[   90.841096] pci 0000:20:02.0: PCI bridge to [bus 21-22]
[   90.846863] pci 0000:20:02.0:   bridge window [io  0x8000-0x8fff]
[   90.853582] pci 0000:20:02.0:   bridge window [mem 0x98300000-0x985fffff]
[   90.861072] pci 0000:20:02.0:   bridge window [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   90.870194] pci 0000:23:00.0: BAR 6: assigned [mem 0x98280000-0x982fffff pref]
[   90.878157] pci 0000:23:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   90.885927] pci 0000:23:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   90.894079] pci 0000:23:00.0: BAR 2: assigned [io  0x9000-0x901f]
[   90.900797] pci 0000:23:00.1: BAR 2: assigned [io  0x9020-0x903f]
[   90.907518] pci 0000:20:02.2: PCI bridge to [bus 23-24]
[   90.913279] pci 0000:20:02.2:   bridge window [io  0x9000-0x9fff]
[   90.920002] pci 0000:20:02.2:   bridge window [mem 0x98000000-0x982fffff]
[   90.927488] pci 0000:20:02.2:   bridge window [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   90.936605] pci 0000:20:03.0: PCI bridge to [bus 25]
[   90.942093] pci 0000:20:11.0: PCI bridge to [bus 26]
[   90.947590] pci 0000:27:00.2: BAR 6: assigned [mem 0x9bd90000-0x9bd9ffff pref]
[   90.955555] pci 0000:27:00.0: BAR 0: assigned [io  0xa000-0xa0ff]
[   90.962277] pci 0000:27:00.0: BAR 2: assigned [io  0xa400-0xa4ff]
[   90.969002] pci 0000:27:00.2: BAR 0: assigned [io  0xa800-0xa8ff]
[   90.975725] pci 0000:20:1c.0: PCI bridge to [bus 27]
[   90.981200] pci 0000:20:1c.0:   bridge window [io  0xa000-0xafff]
[   90.987925] pci 0000:20:1c.0:   bridge window [mem 0x9bb00000-0x9befffff]
[   90.995417] pci_bus 0000:20: resource 4 [io  0x8000-0xbfff window]
[   90.995418] pci_bus 0000:20: resource 5 [mem 0x98000000-0x9befffff window]
[   90.995420] pci_bus 0000:20: resource 6 [mem 0xf0800000000-0xf087fffffff window]
[   90.995422] pci_bus 0000:21: resource 0 [io  0x8000-0x8fff]
[   90.995423] pci_bus 0000:21: resource 1 [mem 0x98300000-0x985fffff]
[   90.995425] pci_bus 0000:21: resource 2 [mem 0xf087f700000-0xf087fafffff 64bit pref]
[   90.995433] pci_bus 0000:23: resource 0 [io  0x9000-0x9fff]
[   90.995434] pci_bus 0000:23: resource 1 [mem 0x98000000-0x982fffff]
[   90.995435] pci_bus 0000:23: resource 2 [mem 0xf087fb00000-0xf087fefffff 64bit pref]
[   90.995438] pci_bus 0000:27: resource 0 [io  0xa000-0xafff]
[   90.995440] pci_bus 0000:27: resource 1 [mem 0x9bb00000-0x9befffff]
[   90.995474] pci 0000:30:03.0: BAR 14: assigned [mem 0x9c000000-0x9c0fffff]
[   91.003054] pci 0000:30:02.0: PCI bridge to [bus 31]
[   91.008541] pci 0000:30:02.2: PCI bridge to [bus 32]
[   91.014032] pci 0000:33:00.0: BAR 6: assigned [mem 0x9c000000-0x9c03ffff pref]
[   91.021993] pci 0000:33:00.1: BAR 6: assigned [mem 0x9c040000-0x9c07ffff pref]
[   91.029958] pci 0000:30:03.0: PCI bridge to [bus 33]
[   91.035435] pci 0000:30:03.0:   bridge window [mem 0x9c000000-0x9c0fffff]
[   91.042921] pci 0000:30:03.0:   bridge window [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   91.052037] pci_bus 0000:30: resource 4 [io  0xc000-0xffff window]
[   91.052039] pci_bus 0000:30: resource 5 [mem 0x9c000000-0x9fff7fff window]
[   91.052042] pci_bus 0000:30: resource 6 [mem 0xf0c00000000-0xf0c7fffffff window]
[   91.052044] pci_bus 0000:33: resource 1 [mem 0x9c000000-0x9c0fffff]
[   91.052046] pci_bus 0000:33: resource 2 [mem 0xf0c7fc00000-0xf0c7fefffff 64bit pref]
[   91.052094] pci 0000:40:02.0: BAR 13: no space for [io  size 0x1000]
[   91.059099] pci 0000:40:02.0: BAR 13: failed to assign [io  size 0x1000]
[   91.066489] pci 0000:40:02.2: BAR 13: no space for [io  size 0x1000]
[   91.073496] pci 0000:40:02.2: BAR 13: failed to assign [io  size 0x1000]
[   91.080888] pci 0000:40:1c.0: BAR 13: no space for [io  size 0x1000]
[   91.087893] pci 0000:40:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   91.095291] pci 0000:41:00.0: BAR 6: assigned [mem 0xa0580000-0xa05fffff pref]
[   91.103253] pci 0000:41:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.111023] pci 0000:41:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.119179] pci 0000:41:00.0: BAR 2: no space for [io  size 0x0020]
[   91.126088] pci 0000:41:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.133382] pci 0000:41:00.1: BAR 2: no space for [io  size 0x0020]
[   91.140292] pci 0000:41:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.147591] pci 0000:40:02.0: PCI bridge to [bus 41-42]
[   91.153359] pci 0000:40:02.0:   bridge window [mem 0xa0300000-0xa05fffff]
[   91.160846] pci 0000:40:02.0:   bridge window [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   91.169971] pci 0000:43:00.0: BAR 6: assigned [mem 0xa0280000-0xa02fffff pref]
[   91.177934] pci 0000:43:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.185709] pci 0000:43:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.193862] pci 0000:43:00.0: BAR 2: no space for [io  size 0x0020]
[   91.200773] pci 0000:43:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.208069] pci 0000:43:00.1: BAR 2: no space for [io  size 0x0020]
[   91.214982] pci 0000:43:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.222275] pci 0000:40:02.2: PCI bridge to [bus 43-44]
[   91.228039] pci 0000:40:02.2:   bridge window [mem 0xa0000000-0xa02fffff]
[   91.235527] pci 0000:40:02.2:   bridge window [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   91.244644] pci 0000:40:03.0: PCI bridge to [bus 45]
[   91.250135] pci 0000:40:11.0: PCI bridge to [bus 46]
[   91.255631] pci 0000:47:00.2: BAR 6: assigned [mem 0xa3d90000-0xa3d9ffff pref]
[   91.263594] pci 0000:47:00.0: BAR 0: no space for [io  size 0x0100]
[   91.270502] pci 0000:47:00.0: BAR 0: failed to assign [io  size 0x0100]
[   91.277798] pci 0000:47:00.0: BAR 2: no space for [io  size 0x0100]
[   91.284709] pci 0000:47:00.0: BAR 2: failed to assign [io  size 0x0100]
[   91.292005] pci 0000:47:00.2: BAR 0: no space for [io  size 0x0100]
[   91.298913] pci 0000:47:00.2: BAR 0: failed to assign [io  size 0x0100]
[   91.306207] pci 0000:40:1c.0: PCI bridge to [bus 47]
[   91.311686] pci 0000:40:1c.0:   bridge window [mem 0xa3b00000-0xa3efffff]
[   91.319179] pci_bus 0000:40: Some PCI device resources are unassigned, try booting with pci=realloc
[   91.329149] pci_bus 0000:40: resource 4 [mem 0xa0000000-0xa3efffff window]
[   91.329151] pci_bus 0000:40: resource 5 [mem 0xf1000000000-0xf107fffffff window]
[   91.329153] pci_bus 0000:41: resource 1 [mem 0xa0300000-0xa05fffff]
[   91.329154] pci_bus 0000:41: resource 2 [mem 0xf107f700000-0xf107fafffff 64bit pref]
[   91.329157] pci_bus 0000:43: resource 1 [mem 0xa0000000-0xa02fffff]
[   91.329158] pci_bus 0000:43: resource 2 [mem 0xf107fb00000-0xf107fefffff 64bit pref]
[   91.329164] pci_bus 0000:47: resource 1 [mem 0xa3b00000-0xa3efffff]
[   91.329201] pci 0000:50:03.0: BAR 14: assigned [mem 0xa4000000-0xa40fffff]
[   91.336781] pci 0000:50:02.0: PCI bridge to [bus 51]
[   91.342268] pci 0000:50:02.2: PCI bridge to [bus 52]
[   91.347760] pci 0000:53:00.0: BAR 6: assigned [mem 0xa4000000-0xa403ffff pref]
[   91.355725] pci 0000:53:00.1: BAR 6: assigned [mem 0xa4040000-0xa407ffff pref]
[   91.363687] pci 0000:50:03.0: PCI bridge to [bus 53]
[   91.369167] pci 0000:50:03.0:   bridge window [mem 0xa4000000-0xa40fffff]
[   91.376657] pci 0000:50:03.0:   bridge window [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   91.385778] pci_bus 0000:50: resource 4 [mem 0xa4000000-0xa7ff7fff window]
[   91.385780] pci_bus 0000:50: resource 5 [mem 0xf1400000000-0xf147fffffff window]
[   91.385782] pci_bus 0000:53: resource 1 [mem 0xa4000000-0xa40fffff]
[   91.385783] pci_bus 0000:53: resource 2 [mem 0xf147fc00000-0xf147fefffff 64bit pref]
[   91.385828] pci 0000:60:02.0: BAR 13: no space for [io  size 0x1000]
[   91.392831] pci 0000:60:02.0: BAR 13: failed to assign [io  size 0x1000]
[   91.400220] pci 0000:60:02.2: BAR 13: no space for [io  size 0x1000]
[   91.407224] pci 0000:60:02.2: BAR 13: failed to assign [io  size 0x1000]
[   91.414611] pci 0000:60:1c.0: BAR 13: no space for [io  size 0x1000]
[   91.421623] pci 0000:60:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   91.429017] pci 0000:61:00.0: BAR 6: assigned [mem 0xa8580000-0xa85fffff pref]
[   91.436980] pci 0000:61:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.444753] pci 0000:61:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.452910] pci 0000:61:00.0: BAR 2: no space for [io  size 0x0020]
[   91.459820] pci 0000:61:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.467118] pci 0000:61:00.1: BAR 2: no space for [io  size 0x0020]
[   91.474027] pci 0000:61:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.481325] pci 0000:60:02.0: PCI bridge to [bus 61-62]
[   91.487090] pci 0000:60:02.0:   bridge window [mem 0xa8300000-0xa85fffff]
[   91.494574] pci 0000:60:02.0:   bridge window [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   91.503694] pci 0000:63:00.0: BAR 6: assigned [mem 0xa8280000-0xa82fffff pref]
[   91.511662] pci 0000:63:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.519434] pci 0000:63:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.527591] pci 0000:63:00.0: BAR 2: no space for [io  size 0x0020]
[   91.534502] pci 0000:63:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.541798] pci 0000:63:00.1: BAR 2: no space for [io  size 0x0020]
[   91.548710] pci 0000:63:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.556003] pci 0000:60:02.2: PCI bridge to [bus 63-64]
[   91.561767] pci 0000:60:02.2:   bridge window [mem 0xa8000000-0xa82fffff]
[   91.569252] pci 0000:60:02.2:   bridge window [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   91.578364] pci 0000:60:03.0: PCI bridge to [bus 65]
[   91.583849] pci 0000:60:11.0: PCI bridge to [bus 66]
[   91.589344] pci 0000:67:00.2: BAR 6: assigned [mem 0xabd90000-0xabd9ffff pref]
[   91.597308] pci 0000:67:00.0: BAR 0: no space for [io  size 0x0100]
[   91.604218] pci 0000:67:00.0: BAR 0: failed to assign [io  size 0x0100]
[   91.611508] pci 0000:67:00.0: BAR 2: no space for [io  size 0x0100]
[   91.618418] pci 0000:67:00.0: BAR 2: failed to assign [io  size 0x0100]
[   91.625712] pci 0000:67:00.2: BAR 0: no space for [io  size 0x0100]
[   91.632621] pci 0000:67:00.2: BAR 0: failed to assign [io  size 0x0100]
[   91.639916] pci 0000:60:1c.0: PCI bridge to [bus 67]
[   91.645398] pci 0000:60:1c.0:   bridge window [mem 0xabb00000-0xabefffff]
[   91.652891] pci_bus 0000:60: Some PCI device resources are unassigned, try booting with pci=realloc
[   91.662863] pci_bus 0000:60: resource 4 [mem 0xa8000000-0xabefffff window]
[   91.662865] pci_bus 0000:60: resource 5 [mem 0xf1800000000-0xf187fffffff window]
[   91.662871] pci_bus 0000:61: resource 1 [mem 0xa8300000-0xa85fffff]
[   91.662874] pci_bus 0000:61: resource 2 [mem 0xf187f700000-0xf187fafffff 64bit pref]
[   91.662877] pci_bus 0000:63: resource 1 [mem 0xa8000000-0xa82fffff]
[   91.662878] pci_bus 0000:63: resource 2 [mem 0xf187fb00000-0xf187fefffff 64bit pref]
[   91.662881] pci_bus 0000:67: resource 1 [mem 0xabb00000-0xabefffff]
[   91.662918] pci 0000:70:03.0: BAR 14: assigned [mem 0xac000000-0xac0fffff]
[   91.670498] pci 0000:70:02.0: PCI bridge to [bus 71]
[   91.675986] pci 0000:70:02.2: PCI bridge to [bus 72]
[   91.681478] pci 0000:73:00.0: BAR 6: assigned [mem 0xac000000-0xac03ffff pref]
[   91.689439] pci 0000:73:00.1: BAR 6: assigned [mem 0xac040000-0xac07ffff pref]
[   91.697400] pci 0000:70:03.0: PCI bridge to [bus 73]
[   91.702878] pci 0000:70:03.0:   bridge window [mem 0xac000000-0xac0fffff]
[   91.710363] pci 0000:70:03.0:   bridge window [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   91.719478] pci_bus 0000:70: resource 4 [mem 0xac000000-0xafff7fff window]
[   91.719480] pci_bus 0000:70: resource 5 [mem 0xf1c00000000-0xf1c7fffffff window]
[   91.719482] pci_bus 0000:73: resource 1 [mem 0xac000000-0xac0fffff]
[   91.719484] pci_bus 0000:73: resource 2 [mem 0xf1c7fc00000-0xf1c7fefffff 64bit pref]
[   91.719531] pci 0000:84:02.0: BAR 13: no space for [io  size 0x1000]
[   91.726536] pci 0000:84:02.0: BAR 13: failed to assign [io  size 0x1000]
[   91.733927] pci 0000:84:02.2: BAR 13: no space for [io  size 0x1000]
[   91.740933] pci 0000:84:02.2: BAR 13: failed to assign [io  size 0x1000]
[   91.748324] pci 0000:84:1c.0: BAR 13: no space for [io  size 0x1000]
[   91.755330] pci 0000:84:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   91.762724] pci 0000:85:00.0: BAR 6: assigned [mem 0xb0580000-0xb05fffff pref]
[   91.770687] pci 0000:85:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.778458] pci 0000:85:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.786614] pci 0000:85:00.0: BAR 2: no space for [io  size 0x0020]
[   91.793526] pci 0000:85:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.800819] pci 0000:85:00.1: BAR 2: no space for [io  size 0x0020]
[   91.807728] pci 0000:85:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.815023] pci 0000:84:02.0: PCI bridge to [bus 85-86]
[   91.820787] pci 0000:84:02.0:   bridge window [mem 0xb0300000-0xb05fffff]
[   91.828273] pci 0000:84:02.0:   bridge window [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   91.837400] pci 0000:87:00.0: BAR 6: assigned [mem 0xb0280000-0xb02fffff pref]
[   91.845360] pci 0000:87:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   91.853131] pci 0000:87:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   91.861284] pci 0000:87:00.0: BAR 2: no space for [io  size 0x0020]
[   91.868197] pci 0000:87:00.0: BAR 2: failed to assign [io  size 0x0020]
[   91.875490] pci 0000:87:00.1: BAR 2: no space for [io  size 0x0020]
[   91.882402] pci 0000:87:00.1: BAR 2: failed to assign [io  size 0x0020]
[   91.889702] pci 0000:84:02.2: PCI bridge to [bus 87-88]
[   91.895467] pci 0000:84:02.2:   bridge window [mem 0xb0000000-0xb02fffff]
[   91.902953] pci 0000:84:02.2:   bridge window [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   91.912070] pci 0000:84:03.0: PCI bridge to [bus 89]
[   91.917558] pci 0000:84:11.0: PCI bridge to [bus 8a]
[   91.923063] pci 0000:8b:00.2: BAR 6: assigned [mem 0xb3d90000-0xb3d9ffff pref]
[   91.931027] pci 0000:8b:00.0: BAR 0: no space for [io  size 0x0100]
[   91.937945] pci 0000:8b:00.0: BAR 0: failed to assign [io  size 0x0100]
[   91.945239] pci 0000:8b:00.0: BAR 2: no space for [io  size 0x0100]
[   91.952152] pci 0000:8b:00.0: BAR 2: failed to assign [io  size 0x0100]
[   91.959448] pci 0000:8b:00.2: BAR 0: no space for [io  size 0x0100]
[   91.966356] pci 0000:8b:00.2: BAR 0: failed to assign [io  size 0x0100]
[   91.973650] pci 0000:84:1c.0: PCI bridge to [bus 8b]
[   91.979127] pci 0000:84:1c.0:   bridge window [mem 0xb3b00000-0xb3efffff]
[   91.986618] pci_bus 0000:84: Some PCI device resources are unassigned, try booting with pci=realloc
[   91.996589] pci_bus 0000:84: resource 4 [mem 0xb0000000-0xb3efffff window]
[   91.996591] pci_bus 0000:84: resource 5 [mem 0xf2000000000-0xf207fffffff window]
[   91.996593] pci_bus 0000:85: resource 1 [mem 0xb0300000-0xb05fffff]
[   91.996594] pci_bus 0000:85: resource 2 [mem 0xf207f700000-0xf207fafffff 64bit pref]
[   91.996596] pci_bus 0000:87: resource 1 [mem 0xb0000000-0xb02fffff]
[   91.996598] pci_bus 0000:87: resource 2 [mem 0xf207fb00000-0xf207fefffff 64bit pref]
[   91.996599] pci_bus 0000:8b: resource 1 [mem 0xb3b00000-0xb3efffff]
[   91.996643] pci 0000:90:03.0: BAR 14: assigned [mem 0xb4000000-0xb40fffff]
[   92.004223] pci 0000:90:02.0: PCI bridge to [bus 91]
[   92.009711] pci 0000:90:02.2: PCI bridge to [bus 92]
[   92.015203] pci 0000:93:00.0: BAR 6: assigned [mem 0xb4000000-0xb403ffff pref]
[   92.023167] pci 0000:93:00.1: BAR 6: assigned [mem 0xb4040000-0xb407ffff pref]
[   92.031133] pci 0000:90:03.0: PCI bridge to [bus 93]
[   92.036612] pci 0000:90:03.0:   bridge window [mem 0xb4000000-0xb40fffff]
[   92.044099] pci 0000:90:03.0:   bridge window [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   92.053215] pci_bus 0000:90: resource 4 [mem 0xb4000000-0xb7ff7fff window]
[   92.053220] pci_bus 0000:90: resource 5 [mem 0xf2400000000-0xf247fffffff window]
[   92.053226] pci_bus 0000:93: resource 1 [mem 0xb4000000-0xb40fffff]
[   92.053228] pci_bus 0000:93: resource 2 [mem 0xf247fc00000-0xf247fefffff 64bit pref]
[   92.053274] pci 0000:a0:02.0: BAR 13: no space for [io  size 0x1000]
[   92.060278] pci 0000:a0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   92.067672] pci 0000:a0:02.2: BAR 13: no space for [io  size 0x1000]
[   92.074677] pci 0000:a0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   92.082065] pci 0000:a0:1c.0: BAR 13: no space for [io  size 0x1000]
[   92.089076] pci 0000:a0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   92.096472] pci 0000:a1:00.0: BAR 6: assigned [mem 0xb8580000-0xb85fffff pref]
[   92.104434] pci 0000:a1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.112204] pci 0000:a1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.120360] pci 0000:a1:00.0: BAR 2: no space for [io  size 0x0020]
[   92.127272] pci 0000:a1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.134570] pci 0000:a1:00.1: BAR 2: no space for [io  size 0x0020]
[   92.141480] pci 0000:a1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.148779] pci 0000:a0:02.0: PCI bridge to [bus a1-a2]
[   92.154547] pci 0000:a0:02.0:   bridge window [mem 0xb8300000-0xb85fffff]
[   92.162034] pci 0000:a0:02.0:   bridge window [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   92.171149] pci 0000:a3:00.0: BAR 6: assigned [mem 0xb8280000-0xb82fffff pref]
[   92.179112] pci 0000:a3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.186885] pci 0000:a3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.195041] pci 0000:a3:00.0: BAR 2: no space for [io  size 0x0020]
[   92.201951] pci 0000:a3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.209243] pci 0000:a3:00.1: BAR 2: no space for [io  size 0x0020]
[   92.216152] pci 0000:a3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.223444] pci 0000:a0:02.2: PCI bridge to [bus a3-a4]
[   92.229208] pci 0000:a0:02.2:   bridge window [mem 0xb8000000-0xb82fffff]
[   92.236694] pci 0000:a0:02.2:   bridge window [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   92.245810] pci 0000:a0:03.0: PCI bridge to [bus a5]
[   92.251295] pci 0000:a0:11.0: PCI bridge to [bus a6]
[   92.256792] pci 0000:a7:00.2: BAR 6: assigned [mem 0xbbd90000-0xbbd9ffff pref]
[   92.264751] pci 0000:a7:00.0: BAR 0: no space for [io  size 0x0100]
[   92.271663] pci 0000:a7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   92.278963] pci 0000:a7:00.0: BAR 2: no space for [io  size 0x0100]
[   92.285874] pci 0000:a7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   92.293165] pci 0000:a7:00.2: BAR 0: no space for [io  size 0x0100]
[   92.300074] pci 0000:a7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   92.307366] pci 0000:a0:1c.0: PCI bridge to [bus a7]
[   92.312846] pci 0000:a0:1c.0:   bridge window [mem 0xbbb00000-0xbbefffff]
[   92.320337] pci_bus 0000:a0: Some PCI device resources are unassigned, try booting with pci=realloc
[   92.330307] pci_bus 0000:a0: resource 4 [mem 0xb8000000-0xbbefffff window]
[   92.330308] pci_bus 0000:a0: resource 5 [mem 0xf2800000000-0xf287fffffff window]
[   92.330314] pci_bus 0000:a1: resource 1 [mem 0xb8300000-0xb85fffff]
[   92.330316] pci_bus 0000:a1: resource 2 [mem 0xf287f700000-0xf287fafffff 64bit pref]
[   92.330317] pci_bus 0000:a3: resource 1 [mem 0xb8000000-0xb82fffff]
[   92.330319] pci_bus 0000:a3: resource 2 [mem 0xf287fb00000-0xf287fefffff 64bit pref]
[   92.330321] pci_bus 0000:a7: resource 1 [mem 0xbbb00000-0xbbefffff]
[   92.330363] pci 0000:b0:03.0: BAR 14: assigned [mem 0xbc000000-0xbc0fffff]
[   92.337942] pci 0000:b0:02.0: PCI bridge to [bus b1]
[   92.343428] pci 0000:b0:02.2: PCI bridge to [bus b2]
[   92.348919] pci 0000:b3:00.0: BAR 6: assigned [mem 0xbc000000-0xbc03ffff pref]
[   92.356882] pci 0000:b3:00.1: BAR 6: assigned [mem 0xbc040000-0xbc07ffff pref]
[   92.364844] pci 0000:b0:03.0: PCI bridge to [bus b3]
[   92.370324] pci 0000:b0:03.0:   bridge window [mem 0xbc000000-0xbc0fffff]
[   92.377811] pci 0000:b0:03.0:   bridge window [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   92.386924] pci_bus 0000:b0: resource 4 [mem 0xbc000000-0xbfff7fff window]
[   92.386925] pci_bus 0000:b0: resource 5 [mem 0xf2c00000000-0xf2c7fffffff window]
[   92.386931] pci_bus 0000:b3: resource 1 [mem 0xbc000000-0xbc0fffff]
[   92.386933] pci_bus 0000:b3: resource 2 [mem 0xf2c7fc00000-0xf2c7fefffff 64bit pref]
[   92.386982] pci 0000:c0:02.0: BAR 13: no space for [io  size 0x1000]
[   92.393987] pci 0000:c0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   92.401377] pci 0000:c0:02.2: BAR 13: no space for [io  size 0x1000]
[   92.408387] pci 0000:c0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   92.415941] pci 0000:c0:1c.0: BAR 13: no space for [io  size 0x1000]
[   92.422947] pci 0000:c0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   92.430349] pci 0000:c1:00.0: BAR 6: assigned [mem 0xc0580000-0xc05fffff pref]
[   92.438313] pci 0000:c1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.446083] pci 0000:c1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.454238] pci 0000:c1:00.0: BAR 2: no space for [io  size 0x0020]
[   92.461152] pci 0000:c1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.468449] pci 0000:c1:00.1: BAR 2: no space for [io  size 0x0020]
[   92.475358] pci 0000:c1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.482656] pci 0000:c0:02.0: PCI bridge to [bus c1-c2]
[   92.488420] pci 0000:c0:02.0:   bridge window [mem 0xc0300000-0xc05fffff]
[   92.495906] pci 0000:c0:02.0:   bridge window [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   92.505029] pci 0000:c3:00.0: BAR 6: assigned [mem 0xc0280000-0xc02fffff pref]
[   92.512990] pci 0000:c3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.520759] pci 0000:c3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.528913] pci 0000:c3:00.0: BAR 2: no space for [io  size 0x0020]
[   92.535825] pci 0000:c3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.543119] pci 0000:c3:00.1: BAR 2: no space for [io  size 0x0020]
[   92.550027] pci 0000:c3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.557323] pci 0000:c0:02.2: PCI bridge to [bus c3-c4]
[   92.563088] pci 0000:c0:02.2:   bridge window [mem 0xc0000000-0xc02fffff]
[   92.570573] pci 0000:c0:02.2:   bridge window [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   92.579687] pci 0000:c0:03.0: PCI bridge to [bus c5]
[   92.585172] pci 0000:c0:11.0: PCI bridge to [bus c6]
[   92.590668] pci 0000:c7:00.2: BAR 6: assigned [mem 0xc3d90000-0xc3d9ffff pref]
[   92.598629] pci 0000:c7:00.0: BAR 0: no space for [io  size 0x0100]
[   92.605538] pci 0000:c7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   92.612830] pci 0000:c7:00.0: BAR 2: no space for [io  size 0x0100]
[   92.619738] pci 0000:c7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   92.627031] pci 0000:c7:00.2: BAR 0: no space for [io  size 0x0100]
[   92.633939] pci 0000:c7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   92.641232] pci 0000:c0:1c.0: PCI bridge to [bus c7]
[   92.646713] pci 0000:c0:1c.0:   bridge window [mem 0xc3b00000-0xc3efffff]
[   92.654206] pci_bus 0000:c0: Some PCI device resources are unassigned, try booting with pci=realloc
[   92.664178] pci_bus 0000:c0: resource 4 [mem 0xc0000000-0xc3efffff window]
[   92.664180] pci_bus 0000:c0: resource 5 [mem 0xf3000000000-0xf307fffffff window]
[   92.664183] pci_bus 0000:c1: resource 1 [mem 0xc0300000-0xc05fffff]
[   92.664188] pci_bus 0000:c1: resource 2 [mem 0xf307f700000-0xf307fafffff 64bit pref]
[   92.664194] pci_bus 0000:c3: resource 1 [mem 0xc0000000-0xc02fffff]
[   92.664196] pci_bus 0000:c3: resource 2 [mem 0xf307fb00000-0xf307fefffff 64bit pref]
[   92.664199] pci_bus 0000:c7: resource 1 [mem 0xc3b00000-0xc3efffff]
[   92.664241] pci 0000:d0:03.0: BAR 14: assigned [mem 0xc4000000-0xc40fffff]
[   92.671825] pci 0000:d0:02.0: PCI bridge to [bus d1]
[   92.677311] pci 0000:d0:02.2: PCI bridge to [bus d2]
[   92.682806] pci 0000:d3:00.0: BAR 6: assigned [mem 0xc4000000-0xc403ffff pref]
[   92.690768] pci 0000:d3:00.1: BAR 6: assigned [mem 0xc4040000-0xc407ffff pref]
[   92.698732] pci 0000:d0:03.0: PCI bridge to [bus d3]
[   92.704215] pci 0000:d0:03.0:   bridge window [mem 0xc4000000-0xc40fffff]
[   92.711700] pci 0000:d0:03.0:   bridge window [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   92.720818] pci_bus 0000:d0: resource 4 [mem 0xc4000000-0xc7ff7fff window]
[   92.720820] pci_bus 0000:d0: resource 5 [mem 0xf3400000000-0xf347fffffff window]
[   92.720822] pci_bus 0000:d3: resource 1 [mem 0xc4000000-0xc40fffff]
[   92.720823] pci_bus 0000:d3: resource 2 [mem 0xf347fc00000-0xf347fefffff 64bit pref]
[   92.720874] pci 0000:e0:02.0: BAR 13: no space for [io  size 0x1000]
[   92.727879] pci 0000:e0:02.0: BAR 13: failed to assign [io  size 0x1000]
[   92.735270] pci 0000:e0:02.2: BAR 13: no space for [io  size 0x1000]
[   92.742275] pci 0000:e0:02.2: BAR 13: failed to assign [io  size 0x1000]
[   92.749670] pci 0000:e0:1c.0: BAR 13: no space for [io  size 0x1000]
[   92.756675] pci 0000:e0:1c.0: BAR 13: failed to assign [io  size 0x1000]
[   92.764073] pci 0000:e1:00.0: BAR 6: assigned [mem 0xc8580000-0xc85fffff pref]
[   92.772035] pci 0000:e1:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.779807] pci 0000:e1:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.787959] pci 0000:e1:00.0: BAR 2: no space for [io  size 0x0020]
[   92.794873] pci 0000:e1:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.802170] pci 0000:e1:00.1: BAR 2: no space for [io  size 0x0020]
[   92.809081] pci 0000:e1:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.816379] pci 0000:e0:02.0: PCI bridge to [bus e1-e2]
[   92.822149] pci 0000:e0:02.0:   bridge window [mem 0xc8300000-0xc85fffff]
[   92.829637] pci 0000:e0:02.0:   bridge window [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   92.838762] pci 0000:e3:00.0: BAR 6: assigned [mem 0xc8280000-0xc82fffff pref]
[   92.846723] pci 0000:e3:00.1: BAR 6: no space for [mem size 0x00080000 pref]
[   92.854491] pci 0000:e3:00.1: BAR 6: failed to assign [mem size 0x00080000 pref]
[   92.862648] pci 0000:e3:00.0: BAR 2: no space for [io  size 0x0020]
[   92.869560] pci 0000:e3:00.0: BAR 2: failed to assign [io  size 0x0020]
[   92.876858] pci 0000:e3:00.1: BAR 2: no space for [io  size 0x0020]
[   92.883768] pci 0000:e3:00.1: BAR 2: failed to assign [io  size 0x0020]
[   92.891066] pci 0000:e0:02.2: PCI bridge to [bus e3-e4]
[   92.896834] pci 0000:e0:02.2:   bridge window [mem 0xc8000000-0xc82fffff]
[   92.904324] pci 0000:e0:02.2:   bridge window [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   92.913435] pci 0000:e0:03.0: PCI bridge to [bus e5]
[   92.918923] pci 0000:e0:11.0: PCI bridge to [bus e6]
[   92.924424] pci 0000:e7:00.2: BAR 6: assigned [mem 0xcbd90000-0xcbd9ffff pref]
[   92.932387] pci 0000:e7:00.0: BAR 0: no space for [io  size 0x0100]
[   92.939296] pci 0000:e7:00.0: BAR 0: failed to assign [io  size 0x0100]
[   92.946589] pci 0000:e7:00.0: BAR 2: no space for [io  size 0x0100]
[   92.953498] pci 0000:e7:00.0: BAR 2: failed to assign [io  size 0x0100]
[   92.960790] pci 0000:e7:00.2: BAR 0: no space for [io  size 0x0100]
[   92.967701] pci 0000:e7:00.2: BAR 0: failed to assign [io  size 0x0100]
[   92.974991] pci 0000:e0:1c.0: PCI bridge to [bus e7]
[   92.980471] pci 0000:e0:1c.0:   bridge window [mem 0xcbb00000-0xcbefffff]
[   92.987957] pci_bus 0000:e0: Some PCI device resources are unassigned, try booting with pci=realloc
[   92.997930] pci_bus 0000:e0: resource 4 [mem 0xc8000000-0xcbefffff window]
[   92.997931] pci_bus 0000:e0: resource 5 [mem 0xf3800000000-0xf387fffffff window]
[   92.997933] pci_bus 0000:e1: resource 1 [mem 0xc8300000-0xc85fffff]
[   92.997935] pci_bus 0000:e1: resource 2 [mem 0xf387f700000-0xf387fafffff 64bit pref]
[   92.997940] pci_bus 0000:e3: resource 1 [mem 0xc8000000-0xc82fffff]
[   92.997946] pci_bus 0000:e3: resource 2 [mem 0xf387fb00000-0xf387fefffff 64bit pref]
[   92.997948] pci_bus 0000:e7: resource 1 [mem 0xcbb00000-0xcbefffff]
[   92.997980] pci 0000:f0:03.0: BAR 14: assigned [mem 0xcc000000-0xcc0fffff]
[   93.005559] pci 0000:f0:02.0: PCI bridge to [bus f1]
[   93.011046] pci 0000:f0:02.2: PCI bridge to [bus f2]
[   93.016540] pci 0000:f3:00.0: BAR 6: assigned [mem 0xcc000000-0xcc03ffff pref]
[   93.024503] pci 0000:f3:00.1: BAR 6: assigned [mem 0xcc040000-0xcc07ffff pref]
[   93.032468] pci 0000:f0:03.0: PCI bridge to [bus f3]
[   93.037944] pci 0000:f0:03.0:   bridge window [mem 0xcc000000-0xcc0fffff]
[   93.045431] pci 0000:f0:03.0:   bridge window [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   93.054547] pci_bus 0000:f0: resource 4 [mem 0xcc000000-0xcfff7fff window]
[   93.054549] pci_bus 0000:f0: resource 5 [mem 0xf3c00000000-0xf3c7fffffff window]
[   93.054551] pci_bus 0000:f3: resource 1 [mem 0xcc000000-0xcc0fffff]
[   93.054552] pci_bus 0000:f3: resource 2 [mem 0xf3c7fc00000-0xf3c7fefffff 64bit pref]
[   93.054563] pci_bus 0000:0f: resource 4 [io  0x0000-0xffff]
[   93.054565] pci_bus 0000:0f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054581] pci_bus 0000:1f: resource 4 [io  0x0000-0xffff]
[   93.054583] pci_bus 0000:1f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054597] pci_bus 0000:2f: resource 4 [io  0x0000-0xffff]
[   93.054598] pci_bus 0000:2f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054614] pci_bus 0000:3f: resource 4 [io  0x0000-0xffff]
[   93.054615] pci_bus 0000:3f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054627] pci_bus 0000:4f: resource 4 [io  0x0000-0xffff]
[   93.054629] pci_bus 0000:4f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054640] pci_bus 0000:5f: resource 4 [io  0x0000-0xffff]
[   93.054642] pci_bus 0000:5f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054653] pci_bus 0000:6f: resource 4 [io  0x0000-0xffff]
[   93.054655] pci_bus 0000:6f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054667] pci_bus 0000:7b: resource 4 [io  0x0000-0xffff]
[   93.054668] pci_bus 0000:7b: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054682] pci_bus 0000:8f: resource 4 [io  0x0000-0xffff]
[   93.054683] pci_bus 0000:8f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054700] pci_bus 0000:9f: resource 4 [io  0x0000-0xffff]
[   93.054702] pci_bus 0000:9f: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054718] pci_bus 0000:af: resource 4 [io  0x0000-0xffff]
[   93.054720] pci_bus 0000:af: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054736] pci_bus 0000:bf: resource 4 [io  0x0000-0xffff]
[   93.054737] pci_bus 0000:bf: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054750] pci_bus 0000:cf: resource 4 [io  0x0000-0xffff]
[   93.054752] pci_bus 0000:cf: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054765] pci_bus 0000:df: resource 4 [io  0x0000-0xffff]
[   93.054766] pci_bus 0000:df: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054778] pci_bus 0000:ef: resource 4 [io  0x0000-0xffff]
[   93.054780] pci_bus 0000:ef: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.054794] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
[   93.054795] pci_bus 0000:ff: resource 5 [mem 0x00000000-0x3fffffffffff]
[   93.061374] NET: Registered protocol family 2
[   93.078413] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
[   93.090676] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[   93.098791] TCP: Hash tables configured (established 524288 bind 65536)
[   93.106196] TCP: reno registered
[   93.110440] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[   93.118803] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[   93.134362] NET: Registered protocol family 1
[   93.140502] pci 0000:07:00.1: Video device with shadowed ROM
[   93.147979] PCI: CLS 64 bytes, default 64
[   93.148190] Unpacking initramfs...
[   93.720655] Freeing initrd memory: 29708K (ffff88006b309000 - ffff88006d00c000)
[   93.728802] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   93.735905] software IO TLB [mem 0x67309000-0x6b309000] (64MB) mapped at [ffff880067309000-ffff88006b308fff]
[   93.938693] RAPL PMU detected, hw unit 2^-16 Joules, API unit is 2^-32 Joules, 3 fixed counters 163840 ms ovfl timer
[   94.016815] Scanning for low memory corruption every 60 seconds
[   94.051999] futex hash table entries: 131072 (order: 11, 8388608 bytes)
[   94.065348] Initialise system trusted keyring
[   94.071706] audit: initializing netlink subsys (disabled)
[   94.077757] audit: type=2000 audit(1429202380.084:1): initialized
[   94.094998] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   94.103642] VFS: Disk quotas dquot_6.5.2
[   94.109874] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   94.124507] alg: No test for stdrng (krng)
[   94.129086] Key type asymmetric registered
[   94.133643] Asymmetric key parser 'x509' registered
[   94.139233] bounce: pool size: 64 pages
[   94.144962] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[   94.155741] io scheduler noop registered
[   94.160076] io scheduler deadline registered
[   94.166632] io scheduler cfq registered (default)
[   94.228557] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
[   94.236242] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[   94.243445] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[   94.250667] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   94.250857] pcieport 0000:00:02.2: Signaling PME through PCIe PME interrupt
[   94.258541] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[   94.265747] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
[   94.272969] pcie_pme 0000:00:02.2:pcie01: service driver pcie_pme loaded
[   94.273163] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[   94.280846] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   94.280927] pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
[   94.288610] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
[   94.288756] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[   94.296438] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[   94.303644] pci 0000:07:00.1: Signaling PME through PCIe PME interrupt
[   94.310853] pci 0000:07:00.2: Signaling PME through PCIe PME interrupt
[   94.318069] pci 0000:07:00.4: Signaling PME through PCIe PME interrupt
[   94.325286] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   94.325478] pcieport 0000:10:02.0: Signaling PME through PCIe PME interrupt
[   94.333163] pcie_pme 0000:10:02.0:pcie01: service driver pcie_pme loaded
[   94.333260] pcieport 0000:10:02.2: Signaling PME through PCIe PME interrupt
[   94.340946] pcie_pme 0000:10:02.2:pcie01: service driver pcie_pme loaded
[   94.341098] pcieport 0000:10:03.0: Signaling PME through PCIe PME interrupt
[   94.348781] pci 0000:13:00.0: Signaling PME through PCIe PME interrupt
[   94.355987] pci 0000:13:00.1: Signaling PME through PCIe PME interrupt
[   94.363248] pcie_pme 0000:10:03.0:pcie01: service driver pcie_pme loaded
[   94.363441] pcieport 0000:20:02.0: Signaling PME through PCIe PME interrupt
[   94.371119] pci 0000:21:00.0: Signaling PME through PCIe PME interrupt
[   94.378328] pci 0000:21:00.1: Signaling PME through PCIe PME interrupt
[   94.385546] pcie_pme 0000:20:02.0:pcie01: service driver pcie_pme loaded
[   94.385732] pcieport 0000:20:02.2: Signaling PME through PCIe PME interrupt
[   94.393414] pci 0000:23:00.0: Signaling PME through PCIe PME interrupt
[   94.400618] pci 0000:23:00.1: Signaling PME through PCIe PME interrupt
[   94.407837] pcie_pme 0000:20:02.2:pcie01: service driver pcie_pme loaded
[   94.408031] pcieport 0000:20:03.0: Signaling PME through PCIe PME interrupt
[   94.415710] pcie_pme 0000:20:03.0:pcie01: service driver pcie_pme loaded
[   94.415806] pcieport 0000:20:11.0: Signaling PME through PCIe PME interrupt
[   94.423494] pcie_pme 0000:20:11.0:pcie01: service driver pcie_pme loaded
[   94.423638] pcieport 0000:20:1c.0: Signaling PME through PCIe PME interrupt
[   94.431339] pci 0000:27:00.0: Signaling PME through PCIe PME interrupt
[   94.438549] pci 0000:27:00.2: Signaling PME through PCIe PME interrupt
[   94.445770] pcie_pme 0000:20:1c.0:pcie01: service driver pcie_pme loaded
[   94.445969] pcieport 0000:30:02.0: Signaling PME through PCIe PME interrupt
[   94.453650] pcie_pme 0000:30:02.0:pcie01: service driver pcie_pme loaded
[   94.453749] pcieport 0000:30:02.2: Signaling PME through PCIe PME interrupt
[   94.461432] pcie_pme 0000:30:02.2:pcie01: service driver pcie_pme loaded
[   94.461597] pcieport 0000:30:03.0: Signaling PME through PCIe PME interrupt
[   94.469278] pci 0000:33:00.0: Signaling PME through PCIe PME interrupt
[   94.476488] pci 0000:33:00.1: Signaling PME through PCIe PME interrupt
[   94.483708] pcie_pme 0000:30:03.0:pcie01: service driver pcie_pme loaded
[   94.483900] pcieport 0000:40:02.0: Signaling PME through PCIe PME interrupt
[   94.491580] pci 0000:41:00.0: Signaling PME through PCIe PME interrupt
[   94.498789] pci 0000:41:00.1: Signaling PME through PCIe PME interrupt
[   94.506012] pcie_pme 0000:40:02.0:pcie01: service driver pcie_pme loaded
[   94.506213] pcieport 0000:40:02.2: Signaling PME through PCIe PME interrupt
[   94.513894] pci 0000:43:00.0: Signaling PME through PCIe PME interrupt
[   94.521103] pci 0000:43:00.1: Signaling PME through PCIe PME interrupt
[   94.528319] pcie_pme 0000:40:02.2:pcie01: service driver pcie_pme loaded
[   94.528520] pcieport 0000:40:03.0: Signaling PME through PCIe PME interrupt
[   94.536202] pcie_pme 0000:40:03.0:pcie01: service driver pcie_pme loaded
[   94.536299] pcieport 0000:40:11.0: Signaling PME through PCIe PME interrupt
[   94.543984] pcie_pme 0000:40:11.0:pcie01: service driver pcie_pme loaded
[   94.544140] pcieport 0000:40:1c.0: Signaling PME through PCIe PME interrupt
[   94.551819] pci 0000:47:00.0: Signaling PME through PCIe PME interrupt
[   94.559034] pci 0000:47:00.2: Signaling PME through PCIe PME interrupt
[   94.566257] pcie_pme 0000:40:1c.0:pcie01: service driver pcie_pme loaded
[   94.566458] pcieport 0000:50:02.0: Signaling PME through PCIe PME interrupt
[   94.574137] pcie_pme 0000:50:02.0:pcie01: service driver pcie_pme loaded
[   94.574231] pcieport 0000:50:02.2: Signaling PME through PCIe PME interrupt
[   94.581922] pcie_pme 0000:50:02.2:pcie01: service driver pcie_pme loaded
[   94.582070] pcieport 0000:50:03.0: Signaling PME through PCIe PME interrupt
[   94.589748] pci 0000:53:00.0: Signaling PME through PCIe PME interrupt
[   94.596956] pci 0000:53:00.1: Signaling PME through PCIe PME interrupt
[   94.604182] pcie_pme 0000:50:03.0:pcie01: service driver pcie_pme loaded
[   94.604381] pcieport 0000:60:02.0: Signaling PME through PCIe PME interrupt
[   94.612062] pci 0000:61:00.0: Signaling PME through PCIe PME interrupt
[   94.619273] pci 0000:61:00.1: Signaling PME through PCIe PME interrupt
[   94.626491] pcie_pme 0000:60:02.0:pcie01: service driver pcie_pme loaded
[   94.626680] pcieport 0000:60:02.2: Signaling PME through PCIe PME interrupt
[   94.634359] pci 0000:63:00.0: Signaling PME through PCIe PME interrupt
[   94.641569] pci 0000:63:00.1: Signaling PME through PCIe PME interrupt
[   94.648785] pcie_pme 0000:60:02.2:pcie01: service driver pcie_pme loaded
[   94.648974] pcieport 0000:60:03.0: Signaling PME through PCIe PME interrupt
[   94.656655] pcie_pme 0000:60:03.0:pcie01: service driver pcie_pme loaded
[   94.656749] pcieport 0000:60:11.0: Signaling PME through PCIe PME interrupt
[   94.664433] pcie_pme 0000:60:11.0:pcie01: service driver pcie_pme loaded
[   94.664578] pcieport 0000:60:1c.0: Signaling PME through PCIe PME interrupt
[   94.672257] pci 0000:67:00.0: Signaling PME through PCIe PME interrupt
[   94.679470] pci 0000:67:00.2: Signaling PME through PCIe PME interrupt
[   94.686693] pcie_pme 0000:60:1c.0:pcie01: service driver pcie_pme loaded
[   94.686885] pcieport 0000:70:02.0: Signaling PME through PCIe PME interrupt
[   94.694566] pcie_pme 0000:70:02.0:pcie01: service driver pcie_pme loaded
[   94.694671] pcieport 0000:70:02.2: Signaling PME through PCIe PME interrupt
[   94.702357] pcie_pme 0000:70:02.2:pcie01: service driver pcie_pme loaded
[   94.702509] pcieport 0000:70:03.0: Signaling PME through PCIe PME interrupt
[   94.710191] pci 0000:73:00.0: Signaling PME through PCIe PME interrupt
[   94.717400] pci 0000:73:00.1: Signaling PME through PCIe PME interrupt
[   94.724621] pcie_pme 0000:70:03.0:pcie01: service driver pcie_pme loaded
[   94.724809] pcieport 0000:84:02.0: Signaling PME through PCIe PME interrupt
[   94.732491] pci 0000:85:00.0: Signaling PME through PCIe PME interrupt
[   94.739732] pci 0000:85:00.1: Signaling PME through PCIe PME interrupt
[   94.746957] pcie_pme 0000:84:02.0:pcie01: service driver pcie_pme loaded
[   94.747150] pcieport 0000:84:02.2: Signaling PME through PCIe PME interrupt
[   94.754831] pci 0000:87:00.0: Signaling PME through PCIe PME interrupt
[   94.762038] pci 0000:87:00.1: Signaling PME through PCIe PME interrupt
[   94.769258] pcie_pme 0000:84:02.2:pcie01: service driver pcie_pme loaded
[   94.769456] pcieport 0000:84:03.0: Signaling PME through PCIe PME interrupt
[   94.777140] pcie_pme 0000:84:03.0:pcie01: service driver pcie_pme loaded
[   94.777255] pcieport 0000:84:11.0: Signaling PME through PCIe PME interrupt
[   94.784944] pcie_pme 0000:84:11.0:pcie01: service driver pcie_pme loaded
[   94.785106] pcieport 0000:84:1c.0: Signaling PME through PCIe PME interrupt
[   94.792783] pci 0000:8b:00.0: Signaling PME through PCIe PME interrupt
[   94.799990] pci 0000:8b:00.2: Signaling PME through PCIe PME interrupt
[   94.807213] pcie_pme 0000:84:1c.0:pcie01: service driver pcie_pme loaded
[   94.807409] pcieport 0000:90:02.0: Signaling PME through PCIe PME interrupt
[   94.815094] pcie_pme 0000:90:02.0:pcie01: service driver pcie_pme loaded
[   94.815190] pcieport 0000:90:02.2: Signaling PME through PCIe PME interrupt
[   94.822877] pcie_pme 0000:90:02.2:pcie01: service driver pcie_pme loaded
[   94.823041] pcieport 0000:90:03.0: Signaling PME through PCIe PME interrupt
[   94.830723] pci 0000:93:00.0: Signaling PME through PCIe PME interrupt
[   94.837935] pci 0000:93:00.1: Signaling PME through PCIe PME interrupt
[   94.845152] pcie_pme 0000:90:03.0:pcie01: service driver pcie_pme loaded
[   94.845353] pcieport 0000:a0:02.0: Signaling PME through PCIe PME interrupt
[   94.853032] pci 0000:a1:00.0: Signaling PME through PCIe PME interrupt
[   94.860237] pci 0000:a1:00.1: Signaling PME through PCIe PME interrupt
[   94.867454] pcie_pme 0000:a0:02.0:pcie01: service driver pcie_pme loaded
[   94.867650] pcieport 0000:a0:02.2: Signaling PME through PCIe PME interrupt
[   94.875339] pci 0000:a3:00.0: Signaling PME through PCIe PME interrupt
[   94.882549] pci 0000:a3:00.1: Signaling PME through PCIe PME interrupt
[   94.889768] pcie_pme 0000:a0:02.2:pcie01: service driver pcie_pme loaded
[   94.889957] pcieport 0000:a0:03.0: Signaling PME through PCIe PME interrupt
[   94.897640] pcie_pme 0000:a0:03.0:pcie01: service driver pcie_pme loaded
[   94.897737] pcieport 0000:a0:11.0: Signaling PME through PCIe PME interrupt
[   94.905425] pcie_pme 0000:a0:11.0:pcie01: service driver pcie_pme loaded
[   94.905571] pcieport 0000:a0:1c.0: Signaling PME through PCIe PME interrupt
[   94.913248] pci 0000:a7:00.0: Signaling PME through PCIe PME interrupt
[   94.920457] pci 0000:a7:00.2: Signaling PME through PCIe PME interrupt
[   94.927679] pcie_pme 0000:a0:1c.0:pcie01: service driver pcie_pme loaded
[   94.927869] pcieport 0000:b0:02.0: Signaling PME through PCIe PME interrupt
[   94.935555] pcie_pme 0000:b0:02.0:pcie01: service driver pcie_pme loaded
[   94.935656] pcieport 0000:b0:02.2: Signaling PME through PCIe PME interrupt
[   94.943341] pcie_pme 0000:b0:02.2:pcie01: service driver pcie_pme loaded
[   94.943501] pcieport 0000:b0:03.0: Signaling PME through PCIe PME interrupt
[   94.951180] pci 0000:b3:00.0: Signaling PME through PCIe PME interrupt
[   94.958385] pci 0000:b3:00.1: Signaling PME through PCIe PME interrupt
[   94.965606] pcie_pme 0000:b0:03.0:pcie01: service driver pcie_pme loaded
[   94.965785] pcieport 0000:c0:02.0: Signaling PME through PCIe PME interrupt
[   94.973464] pci 0000:c1:00.0: Signaling PME through PCIe PME interrupt
[   94.976091] tsc: Refined TSC clocksource calibration: 2793.677 MHz
[   94.987491] pci 0000:c1:00.1: Signaling PME through PCIe PME interrupt
[   94.994705] pcie_pme 0000:c0:02.0:pcie01: service driver pcie_pme loaded
[   94.994900] pcieport 0000:c0:02.2: Signaling PME through PCIe PME interrupt
[   95.002589] pci 0000:c3:00.0: Signaling PME through PCIe PME interrupt
[   95.009794] pci 0000:c3:00.1: Signaling PME through PCIe PME interrupt
[   95.017016] pcie_pme 0000:c0:02.2:pcie01: service driver pcie_pme loaded
[   95.017206] pcieport 0000:c0:03.0: Signaling PME through PCIe PME interrupt
[   95.024881] pcie_pme 0000:c0:03.0:pcie01: service driver pcie_pme loaded
[   95.024979] pcieport 0000:c0:11.0: Signaling PME through PCIe PME interrupt
[   95.032668] pcie_pme 0000:c0:11.0:pcie01: service driver pcie_pme loaded
[   95.032806] pcieport 0000:c0:1c.0: Signaling PME through PCIe PME interrupt
[   95.040486] pci 0000:c7:00.0: Signaling PME through PCIe PME interrupt
[   95.047694] pci 0000:c7:00.2: Signaling PME through PCIe PME interrupt
[   95.054913] pcie_pme 0000:c0:1c.0:pcie01: service driver pcie_pme loaded
[   95.055101] pcieport 0000:d0:02.0: Signaling PME through PCIe PME interrupt
[   95.062786] pcie_pme 0000:d0:02.0:pcie01: service driver pcie_pme loaded
[   95.062877] pcieport 0000:d0:02.2: Signaling PME through PCIe PME interrupt
[   95.070559] pcie_pme 0000:d0:02.2:pcie01: service driver pcie_pme loaded
[   95.070716] pcieport 0000:d0:03.0: Signaling PME through PCIe PME interrupt
[   95.078396] pci 0000:d3:00.0: Signaling PME through PCIe PME interrupt
[   95.085602] pci 0000:d3:00.1: Signaling PME through PCIe PME interrupt
[   95.092825] pcie_pme 0000:d0:03.0:pcie01: service driver pcie_pme loaded
[   95.093007] pcieport 0000:e0:02.0: Signaling PME through PCIe PME interrupt
[   95.100683] pci 0000:e1:00.0: Signaling PME through PCIe PME interrupt
[   95.107895] pci 0000:e1:00.1: Signaling PME through PCIe PME interrupt
[   95.115117] pcie_pme 0000:e0:02.0:pcie01: service driver pcie_pme loaded
[   95.115308] pcieport 0000:e0:02.2: Signaling PME through PCIe PME interrupt
[   95.122990] pci 0000:e3:00.0: Signaling PME through PCIe PME interrupt
[   95.130199] pci 0000:e3:00.1: Signaling PME through PCIe PME interrupt
[   95.137419] pcie_pme 0000:e0:02.2:pcie01: service driver pcie_pme loaded
[   95.137602] pcieport 0000:e0:03.0: Signaling PME through PCIe PME interrupt
[   95.145283] pcie_pme 0000:e0:03.0:pcie01: service driver pcie_pme loaded
[   95.145393] pcieport 0000:e0:11.0: Signaling PME through PCIe PME interrupt
[   95.153079] pcie_pme 0000:e0:11.0:pcie01: service driver pcie_pme loaded
[   95.153219] pcieport 0000:e0:1c.0: Signaling PME through PCIe PME interrupt
[   95.160900] pci 0000:e7:00.0: Signaling PME through PCIe PME interrupt
[   95.168108] pci 0000:e7:00.2: Signaling PME through PCIe PME interrupt
[   95.175329] pcie_pme 0000:e0:1c.0:pcie01: service driver pcie_pme loaded
[   95.175519] pcieport 0000:f0:02.0: Signaling PME through PCIe PME interrupt
[   95.183200] pcie_pme 0000:f0:02.0:pcie01: service driver pcie_pme loaded
[   95.183291] pcieport 0000:f0:02.2: Signaling PME through PCIe PME interrupt
[   95.190975] pcie_pme 0000:f0:02.2:pcie01: service driver pcie_pme loaded
[   95.191135] pcieport 0000:f0:03.0: Signaling PME through PCIe PME interrupt
[   95.198815] pci 0000:f3:00.0: Signaling PME through PCIe PME interrupt
[   95.206024] pci 0000:f3:00.1: Signaling PME through PCIe PME interrupt
[   95.213239] pcie_pme 0000:f0:03.0:pcie01: service driver pcie_pme loaded
[   95.214927] efifb: probing for efifb
[   95.219132] efifb: framebuffer at 0x92000000, mapped to 0xffffc90634400000, using 6144k, total 8192k
[   95.229203] efifb: mode is 1024x768x32, linelength=4096, pages=1
[   95.235828] efifb: scrolling: redraw
[   95.239782] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[   95.277980] Console: switching to colour frame buffer device 128x48
[   95.316280] fb0: EFI VGA frame buffer device
[   95.321115] intel_idle: MWAIT substates: 0x1120
[   95.321119] intel_idle: v0.4 model 0x3E
[   95.321120] intel_idle: lapic_timer_reliable_states 0xffffffff
[   95.321131] intel_idle: max_cstate 1 reached
[   95.349886] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[   95.358388] Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
[   95.386228] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   95.400570] Non-volatile memory driver v1.3
[   95.405330] Linux agpgart interface v0.103
[   95.419091] libphy: Fixed MDIO Bus: probed
[   95.423721] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   96.497783] i8042: No controller found
[   96.503839] Switched to clocksource tsc
[   96.504133] mousedev: PS/2 mouse device common for all mice
[   96.504590] EFI Variables Facility v0.08 2004-May-17
[   96.550803] pstore: Registered efi as persistent store backend
[   96.550947] TCP: cubic registered
[   96.551046] Key type dns_resolver registered
[   96.597640] Loading compiled-in X.509 certificates
[   96.603717] Loaded X.509 cert 'Magrathea: Glacier signing key: ece216f5f1a582c6b1182929d8adfc5f88d373f2'
[   96.614307] registered taskstats version 1
[   96.619033] AppArmor: AppArmor sha1 policy hashing enabled
[   96.649054]   Magic number: 11:467:641
[   96.654761] msr msr108: hash matches
[   96.660112] pci 0000:2f:0f.4: hash matches
[   96.665200] container HPQ0003:81: hash matches
[   96.670220] pci_bus 0000:46: hash matches
[   96.675456] acpi HPQ0003:81: hash matches
[   96.681157] memory memory6059: hash matches
[   96.690599] memory memory1851: hash matches
[   96.701156] Freeing unused kernel memory: 1632K (ffffffff81b01000 - ffffffff81c99000)
[   96.709782] Write protecting the kernel read-only data: 10240k
[   96.719599] Freeing unused kernel memory: 892K (ffff880001521000 - ffff880001600000)
[   96.730491] Freeing unused kernel memory: 1424K (ffff88000189c000 - ffff880001a00000)
[   96.849213] dm_mod: module verification failed: signature and/or required key missing - tainting kernel
[   96.865641] device-mapper: uevent: version 1.0.3
[   96.872276] device-mapper: ioctl: 4.30.0-ioctl (2014-12-22) initialised: dm-devel@redhat.com
[   96.939720] SCSI subsystem initialized
[   96.952956] emc: device handler registered
[   96.973136] rdac: device handler registered
[   96.994895] hp_sw: device handler registered
[   97.015976] alua: device handler registered
[   97.027067] udev: starting version 147
[   97.448790] ACPI: bus type USB registered
[   97.453272] usbcore: registered new interface driver usbfs
[   97.459340] usbcore: registered new interface driver hub
[   97.469268] usbcore: registered new device driver usb
[   97.494464] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.16-k.
[   97.504351] qla2xxx [0000:13:00.0]-011c: : MSI-X vector count: 31.
[   97.511174] qla2xxx [0000:13:00.0]-001d: : Found an ISP2031 irq 118 iobase 0xffffc9063439e000.
[   97.568741] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   97.580439] kswapd 1 initialised deferred memory in 3484ms
[   97.598151] uhci_hcd: USB Universal Host Controller Interface driver
[   97.601462] kswapd 8 initialised deferred memory in 3504ms
[   97.605635] kswapd 2 initialised deferred memory in 3508ms
[   97.607042] kswapd 14 initialised deferred memory in 3508ms
[   97.608599] kswapd 11 initialised deferred memory in 3512ms
[   97.609877] kswapd 3 initialised deferred memory in 3512ms
[   97.610094] kswapd 9 initialised deferred memory in 3512ms
[   97.610493] kswapd 6 initialised deferred memory in 3512ms
[   97.610526] kswapd 5 initialised deferred memory in 3512ms
[   97.611569] kswapd 13 initialised deferred memory in 3516ms
[   97.612806] kswapd 4 initialised deferred memory in 3516ms
[   97.613441] kswapd 12 initialised deferred memory in 3516ms
[   97.614820] kswapd 7 initialised deferred memory in 3516ms
[   97.621479] kswapd 15 initialised deferred memory in 3524ms
[   97.622833] kswapd 10 initialised deferred memory in 3524ms
[   97.680706] kswapd 0 initialised deferred memory in 3588ms
[   97.697375] uhci_hcd 0000:07:00.4: UHCI Host Controller
[   97.703192] uhci_hcd 0000:07:00.4: new USB bus registered, assigned bus number 1
[   97.711359] uhci_hcd 0000:07:00.4: detected 8 ports
[   97.716730] uhci_hcd 0000:07:00.4: port count misdetected? forcing to 2 ports
[   97.724640] uhci_hcd 0000:07:00.4: irq 16, io base 0x00001500
[   97.731077] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[   97.738552] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   97.746502] usb usb1: Product: UHCI Host Controller
[   97.751871] usb usb1: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp uhci_hcd
[   97.760680] usb usb1: SerialNumber: 0000:07:00.4
[   97.766211] hub 1-0:1.0: USB hub found
[   97.770354] hub 1-0:1.0: 2 ports detected
[   98.965113] scsi host0: qla2xxx
[   99.722259] qla2xxx [0000:13:00.0]-500a:0: LOOP UP detected (8 Gbps).
[  100.374791] qla2xxx [0000:13:00.0]-00fb:0: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  100.383523] qla2xxx [0000:13:00.0]-00fc:0: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.0 hdma+ host#=0 fw=7.03.01 (d0d5).
[  100.395818] qla2xxx [0000:13:00.1]-011c: : MSI-X vector count: 31.
[  100.402628] qla2xxx [0000:13:00.1]-001d: : Found an ISP2031 irq 121 iobase 0xffffc906343a4000.
[  100.981398] scsi 0:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  100.990849] scsi 0:0:0:0: alua: supports implicit TPGS
[  100.996752] scsi 0:0:0:0: alua: port group 01 rel port 05
[  101.002796] scsi 0:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[  101.011335] scsi 0:0:0:0: alua: Attached
[  101.017251] scsi 0:0:0:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.026501] scsi 0:0:0:1: alua: supports implicit TPGS
[  101.032310] scsi 0:0:0:1: alua: port group 01 rel port 05
[  101.038333] scsi 0:0:0:1: alua: port group 01 state N non-preferred supports tolusNA
[  101.046859] scsi 0:0:0:1: alua: Attached
[  101.051641] scsi 0:0:0:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.060846] scsi 0:0:0:2: alua: supports implicit TPGS
[  101.066647] scsi 0:0:0:2: alua: port group 01 rel port 05
[  101.072668] scsi 0:0:0:2: alua: port group 01 state N non-preferred supports tolusNA
[  101.081196] scsi 0:0:0:2: alua: Attached
[  101.085951] scsi 0:0:0:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.095152] scsi 0:0:0:3: alua: supports implicit TPGS
[  101.100950] scsi 0:0:0:3: alua: port group 01 rel port 05
[  101.106968] scsi 0:0:0:3: alua: port group 01 state N non-preferred supports tolusNA
[  101.115496] scsi 0:0:0:3: alua: Attached
[  101.120872] scsi 0:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.130227] scsi 0:0:1:0: alua: supports implicit TPGS
[  101.136031] scsi 0:0:1:0: alua: port group 00 rel port 01
[  101.142097] scsi 0:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  101.150245] scsi 0:0:1:0: alua: Attached
[  101.155620] scsi 0:0:1:1: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.164936] scsi 0:0:1:1: alua: supports implicit TPGS
[  101.170741] scsi 0:0:1:1: alua: port group 00 rel port 01
[  101.176762] scsi 0:0:1:1: alua: port group 00 state A preferred supports tolusNA
[  101.184904] scsi 0:0:1:1: alua: Attached
[  101.189702] scsi 0:0:1:2: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.198909] scsi 0:0:1:2: alua: supports implicit TPGS
[  101.204711] scsi 0:0:1:2: alua: port group 00 rel port 01
[  101.210733] scsi 0:0:1:2: alua: port group 00 state A preferred supports tolusNA
[  101.218879] scsi 0:0:1:2: alua: Attached
[  101.223854] scsi 0:0:1:3: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  101.233057] scsi 0:0:1:3: alua: supports implicit TPGS
[  101.238857] scsi 0:0:1:3: alua: port group 00 rel port 01
[  101.244873] scsi 0:0:1:3: alua: port group 00 state A preferred supports tolusNA
[  101.253012] scsi 0:0:1:3: alua: Attached
[  101.828680] scsi host1: qla2xxx
[  102.605649] qla2xxx [0000:13:00.1]-500a:1: LOOP UP detected (8 Gbps).
[  103.262352] qla2xxx [0000:13:00.1]-00fb:1: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  103.271081] qla2xxx [0000:13:00.1]-00fc:1: ISP2031: PCIe (8.0GT/s x8) @ 0000:13:00.1 hdma+ host#=1 fw=7.03.01 (d0d5).
[  103.283627] qla2xxx [0000:33:00.0]-011c: : MSI-X vector count: 31.
[  103.290468] qla2xxx [0000:33:00.0]-001d: : Found an ISP2031 irq 124 iobase 0xffffc906343a8000.
[  103.845040] scsi 1:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  103.854322] scsi 1:0:0:0: alua: supports implicit TPGS
[  103.860102] scsi 1:0:0:0: alua: port group 01 rel port 05
[  103.866109] scsi 1:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  103.874254] scsi 1:0:0:0: alua: Attached
[  103.879888] scsi 1:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  103.889067] scsi 1:0:1:0: alua: supports implicit TPGS
[  103.894829] scsi 1:0:1:0: alua: port group 00 rel port 01
[  103.900825] scsi 1:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  103.908966] scsi 1:0:1:0: alua: Attached
[  104.740336] scsi host2: qla2xxx
[  105.509116] qla2xxx [0000:33:00.0]-500a:2: LOOP UP detected (8 Gbps).
[  106.157994] qla2xxx [0000:33:00.0]-00fb:2: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  106.166721] qla2xxx [0000:33:00.0]-00fc:2: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.0 hdma+ host#=2 fw=7.03.01 (d0d5).
[  106.178646] qla2xxx [0000:33:00.1]-011c: : MSI-X vector count: 31.
[  106.185460] qla2xxx [0000:33:00.1]-001d: : Found an ISP2031 irq 127 iobase 0xffffc906343b6000.
[  106.756588] scsi 2:0:0:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.765912] scsi 2:0:0:0: alua: supports implicit TPGS
[  106.771714] scsi 2:0:0:0: alua: port group 01 rel port 05
[  106.777738] scsi 2:0:0:0: alua: port group 01 state N non-preferred supports tolusNA
[  106.786262] scsi 2:0:0:0: alua: Attached
[  106.791677] scsi 2:0:0:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.801063] scsi 2:0:0:100: alua: supports implicit TPGS
[  106.807041] scsi 2:0:0:100: alua: port group 01 rel port 05
[  106.813242] scsi 2:0:0:100: alua: port group 01 state N non-preferred supports tolusNA
[  106.821963] scsi 2:0:0:100: alua: Attached
[  106.826934] scsi 2:0:0:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.836291] scsi 2:0:0:101: alua: supports implicit TPGS
[  106.842268] scsi 2:0:0:101: alua: port group 01 rel port 05
[  106.848470] scsi 2:0:0:101: alua: port group 01 state N non-preferred supports tolusNA
[  106.857189] scsi 2:0:0:101: alua: Attached
[  106.862306] scsi 2:0:0:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.871675] scsi 2:0:0:102: alua: supports implicit TPGS
[  106.877648] scsi 2:0:0:102: alua: port group 01 rel port 05
[  106.883851] scsi 2:0:0:102: alua: port group 01 state N non-preferred supports tolusNA
[  106.892572] scsi 2:0:0:102: alua: Attached
[  106.897574] scsi 2:0:0:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.906949] scsi 2:0:0:103: alua: supports implicit TPGS
[  106.912924] scsi 2:0:0:103: alua: port group 01 rel port 05
[  106.919126] scsi 2:0:0:103: alua: port group 01 state N non-preferred supports tolusNA
[  106.927845] scsi 2:0:0:103: alua: Attached
[  106.932794] scsi 2:0:0:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.942164] scsi 2:0:0:104: alua: supports implicit TPGS
[  106.948148] scsi 2:0:0:104: alua: port group 01 rel port 05
[  106.954352] scsi 2:0:0:104: alua: port group 01 state N non-preferred supports tolusNA
[  106.963070] scsi 2:0:0:104: alua: Attached
[  106.968262] scsi 2:0:0:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  106.977715] scsi 2:0:0:105: alua: supports implicit TPGS
[  106.983807] scsi 2:0:0:105: alua: port group 01 rel port 05
[  106.990036] scsi 2:0:0:105: alua: port group 01 state N non-preferred supports tolusNA
[  106.998768] scsi 2:0:0:105: alua: Attached
[  107.004041] scsi 2:0:0:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.013399] scsi 2:0:0:106: alua: supports implicit TPGS
[  107.019372] scsi 2:0:0:106: alua: port group 01 rel port 05
[  107.025576] scsi 2:0:0:106: alua: port group 01 state N non-preferred supports tolusNA
[  107.034296] scsi 2:0:0:106: alua: Attached
[  107.039235] scsi 2:0:0:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.048599] scsi 2:0:0:107: alua: supports implicit TPGS
[  107.054575] scsi 2:0:0:107: alua: port group 01 rel port 05
[  107.060774] scsi 2:0:0:107: alua: port group 01 state N non-preferred supports tolusNA
[  107.069498] scsi 2:0:0:107: alua: Attached
[  107.074620] scsi 2:0:0:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.084060] scsi 2:0:0:108: alua: supports implicit TPGS
[  107.090027] scsi 2:0:0:108: alua: port group 01 rel port 05
[  107.096245] scsi 2:0:0:108: alua: port group 01 state N non-preferred supports tolusNA
[  107.104974] scsi 2:0:0:108: alua: Attached
[  107.109960] scsi 2:0:0:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.119342] scsi 2:0:0:109: alua: supports implicit TPGS
[  107.125321] scsi 2:0:0:109: alua: port group 01 rel port 05
[  107.131527] scsi 2:0:0:109: alua: port group 01 state N non-preferred supports tolusNA
[  107.140243] scsi 2:0:0:109: alua: Attached
[  107.145183] scsi 2:0:0:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.154566] scsi 2:0:0:110: alua: supports implicit TPGS
[  107.160549] scsi 2:0:0:110: alua: port group 01 rel port 05
[  107.166755] scsi 2:0:0:110: alua: port group 01 state N non-preferred supports tolusNA
[  107.175473] scsi 2:0:0:110: alua: Attached
[  107.180649] scsi 2:0:0:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.190016] scsi 2:0:0:111: alua: supports implicit TPGS
[  107.196003] scsi 2:0:0:111: alua: port group 01 rel port 05
[  107.202209] scsi 2:0:0:111: alua: port group 01 state N non-preferred supports tolusNA
[  107.210928] scsi 2:0:0:111: alua: Attached
[  107.215874] scsi 2:0:0:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.225232] scsi 2:0:0:112: alua: supports implicit TPGS
[  107.231211] scsi 2:0:0:112: alua: port group 01 rel port 05
[  107.237421] scsi 2:0:0:112: alua: port group 01 state N non-preferred supports tolusNA
[  107.246140] scsi 2:0:0:112: alua: Attached
[  107.251106] scsi 2:0:0:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.260442] scsi 2:0:0:113: alua: supports implicit TPGS
[  107.266401] scsi 2:0:0:113: alua: port group 01 rel port 05
[  107.272594] scsi 2:0:0:113: alua: port group 01 state N non-preferred supports tolusNA
[  107.281318] scsi 2:0:0:113: alua: Attached
[  107.286517] scsi 2:0:0:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.295846] scsi 2:0:0:114: alua: supports implicit TPGS
[  107.301801] scsi 2:0:0:114: alua: port group 01 rel port 05
[  107.307989] scsi 2:0:0:114: alua: port group 01 state N non-preferred supports tolusNA
[  107.316706] scsi 2:0:0:114: alua: Attached
[  107.321893] scsi 2:0:0:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.331212] scsi 2:0:0:115: alua: supports implicit TPGS
[  107.337164] scsi 2:0:0:115: alua: port group 01 rel port 05
[  107.343349] scsi 2:0:0:115: alua: port group 01 state N non-preferred supports tolusNA
[  107.352073] scsi 2:0:0:115: alua: Attached
[  107.357053] scsi 2:0:0:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.366370] scsi 2:0:0:116: alua: supports implicit TPGS
[  107.372324] scsi 2:0:0:116: alua: port group 01 rel port 05
[  107.378515] scsi 2:0:0:116: alua: port group 01 state N non-preferred supports tolusNA
[  107.387233] scsi 2:0:0:116: alua: Attached
[  107.392196] scsi 2:0:0:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.401524] scsi 2:0:0:117: alua: supports implicit TPGS
[  107.407486] scsi 2:0:0:117: alua: port group 01 rel port 05
[  107.413679] scsi 2:0:0:117: alua: port group 01 state N non-preferred supports tolusNA
[  107.422403] scsi 2:0:0:117: alua: Attached
[  107.427379] scsi 2:0:0:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.436697] scsi 2:0:0:118: alua: supports implicit TPGS
[  107.442654] scsi 2:0:0:118: alua: port group 01 rel port 05
[  107.448842] scsi 2:0:0:118: alua: port group 01 state N non-preferred supports tolusNA
[  107.457561] scsi 2:0:0:118: alua: Attached
[  107.462544] scsi 2:0:0:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.471855] scsi 2:0:0:119: alua: supports implicit TPGS
[  107.477808] scsi 2:0:0:119: alua: port group 01 rel port 05
[  107.483996] scsi 2:0:0:119: alua: port group 01 state N non-preferred supports tolusNA
[  107.492720] scsi 2:0:0:119: alua: Attached
[  107.498030] scsi 2:0:1:0: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.507218] scsi 2:0:1:0: alua: supports implicit TPGS
[  107.512986] scsi 2:0:1:0: alua: port group 00 rel port 01
[  107.518986] scsi 2:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  107.527132] scsi 2:0:1:0: alua: Attached
[  107.533229] scsi 2:0:1:100: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.542559] scsi 2:0:1:100: alua: supports implicit TPGS
[  107.548701] scsi 2:0:1:100: alua: port group 00 rel port 01
[  107.554895] scsi 2:0:1:100: alua: port group 00 state A preferred supports tolusNA
[  107.563235] scsi 2:0:1:100: alua: Attached
[  107.568619] scsi 2:0:1:101: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.577934] scsi 2:0:1:101: alua: supports implicit TPGS
[  107.584032] scsi 2:0:1:101: alua: port group 00 rel port 01
[  107.590232] scsi 2:0:1:101: alua: port group 00 state A preferred supports tolusNA
[  107.598574] scsi 2:0:1:101: alua: Attached
[  107.603753] scsi 2:0:1:102: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.613068] scsi 2:0:1:102: alua: supports implicit TPGS
[  107.619013] scsi 2:0:1:102: alua: port group 00 rel port 01
[  107.625208] scsi 2:0:1:102: alua: port group 00 state A preferred supports tolusNA
[  107.633548] scsi 2:0:1:102: alua: Attached
[  107.638447] scsi host3: qla2xxx
[  107.642005] scsi 2:0:1:103: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.651515] scsi 2:0:1:103: alua: supports implicit TPGS
[  107.657476] scsi 2:0:1:103: alua: port group 00 rel port 01
[  107.663672] scsi 2:0:1:103: alua: port group 00 state A preferred supports tolusNA
[  107.672014] scsi 2:0:1:103: alua: Attached
[  107.677225] scsi 2:0:1:104: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.686545] scsi 2:0:1:104: alua: supports implicit TPGS
[  107.692497] scsi 2:0:1:104: alua: port group 00 rel port 01
[  107.698689] scsi 2:0:1:104: alua: port group 00 state A preferred supports tolusNA
[  107.707024] scsi 2:0:1:104: alua: Attached
[  107.712301] scsi 2:0:1:105: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.721613] scsi 2:0:1:105: alua: supports implicit TPGS
[  107.727574] scsi 2:0:1:105: alua: port group 00 rel port 01
[  107.733765] scsi 2:0:1:105: alua: port group 00 state A preferred supports tolusNA
[  107.742107] scsi 2:0:1:105: alua: Attached
[  107.747081] scsi 2:0:1:106: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.756394] scsi 2:0:1:106: alua: supports implicit TPGS
[  107.762356] scsi 2:0:1:106: alua: port group 00 rel port 01
[  107.768550] scsi 2:0:1:106: alua: port group 00 state A preferred supports tolusNA
[  107.776889] scsi 2:0:1:106: alua: Attached
[  107.781826] scsi 2:0:1:107: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.791138] scsi 2:0:1:107: alua: supports implicit TPGS
[  107.797098] scsi 2:0:1:107: alua: port group 00 rel port 01
[  107.803292] scsi 2:0:1:107: alua: port group 00 state A preferred supports tolusNA
[  107.811627] scsi 2:0:1:107: alua: Attached
[  107.816577] scsi 2:0:1:108: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.825918] scsi 2:0:1:108: alua: supports implicit TPGS
[  107.831885] scsi 2:0:1:108: alua: port group 00 rel port 01
[  107.838070] scsi 2:0:1:108: alua: port group 00 state A preferred supports tolusNA
[  107.846413] scsi 2:0:1:108: alua: Attached
[  107.851392] scsi 2:0:1:109: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.860712] scsi 2:0:1:109: alua: supports implicit TPGS
[  107.866668] scsi 2:0:1:109: alua: port group 00 rel port 01
[  107.872855] scsi 2:0:1:109: alua: port group 00 state A preferred supports tolusNA
[  107.881195] scsi 2:0:1:109: alua: Attached
[  107.886174] scsi 2:0:1:110: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.895487] scsi 2:0:1:110: alua: supports implicit TPGS
[  107.901443] scsi 2:0:1:110: alua: port group 00 rel port 01
[  107.907632] scsi 2:0:1:110: alua: port group 00 state A preferred supports tolusNA
[  107.915969] scsi 2:0:1:110: alua: Attached
[  107.920933] scsi 2:0:1:111: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.930255] scsi 2:0:1:111: alua: supports implicit TPGS
[  107.936224] scsi 2:0:1:111: alua: port group 00 rel port 01
[  107.942415] scsi 2:0:1:111: alua: port group 00 state A preferred supports tolusNA
[  107.950754] scsi 2:0:1:111: alua: Attached
[  107.955822] scsi 2:0:1:112: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.965139] scsi 2:0:1:112: alua: supports implicit TPGS
[  107.971097] scsi 2:0:1:112: alua: port group 00 rel port 01
[  107.977284] scsi 2:0:1:112: alua: port group 00 state A preferred supports tolusNA
[  107.985624] scsi 2:0:1:112: alua: Attached
[  107.990607] scsi 2:0:1:113: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  107.999934] scsi 2:0:1:113: alua: supports implicit TPGS
[  108.005893] scsi 2:0:1:113: alua: port group 00 rel port 01
[  108.012086] scsi 2:0:1:113: alua: port group 00 state A preferred supports tolusNA
[  108.020426] scsi 2:0:1:113: alua: Attached
[  108.025403] scsi 2:0:1:114: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.034723] scsi 2:0:1:114: alua: supports implicit TPGS
[  108.040673] scsi 2:0:1:114: alua: port group 00 rel port 01
[  108.046861] scsi 2:0:1:114: alua: port group 00 state A preferred supports tolusNA
[  108.055198] scsi 2:0:1:114: alua: Attached
[  108.060350] scsi 2:0:1:115: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.069675] scsi 2:0:1:115: alua: supports implicit TPGS
[  108.075632] scsi 2:0:1:115: alua: port group 00 rel port 01
[  108.081826] scsi 2:0:1:115: alua: port group 00 state A preferred supports tolusNA
[  108.090164] scsi 2:0:1:115: alua: Attached
[  108.095142] scsi 2:0:1:116: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.104467] scsi 2:0:1:116: alua: supports implicit TPGS
[  108.110421] scsi 2:0:1:116: alua: port group 00 rel port 01
[  108.116609] scsi 2:0:1:116: alua: port group 00 state A preferred supports tolusNA
[  108.124953] scsi 2:0:1:116: alua: Attached
[  108.129926] scsi 2:0:1:117: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.139241] scsi 2:0:1:117: alua: supports implicit TPGS
[  108.145200] scsi 2:0:1:117: alua: port group 00 rel port 01
[  108.151399] scsi 2:0:1:117: alua: port group 00 state A preferred supports tolusNA
[  108.159742] scsi 2:0:1:117: alua: Attached
[  108.164934] scsi 2:0:1:118: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.174249] scsi 2:0:1:118: alua: supports implicit TPGS
[  108.180200] scsi 2:0:1:118: alua: port group 00 rel port 01
[  108.186395] scsi 2:0:1:118: alua: port group 00 state A preferred supports tolusNA
[  108.194735] scsi 2:0:1:118: alua: Attached
[  108.199721] scsi 2:0:1:119: Direct-Access     HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  108.209030] scsi 2:0:1:119: alua: supports implicit TPGS
[  108.214987] scsi 2:0:1:119: alua: port group 00 rel port 01
[  108.221178] scsi 2:0:1:119: alua: port group 00 state A preferred supports tolusNA
[  108.229522] scsi 2:0:1:119: alua: Attached
[  108.411050] qla2xxx [0000:33:00.1]-500a:3: LOOP UP detected (8 Gbps).
[  109.069600] qla2xxx [0000:33:00.1]-00fb:3: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  109.078326] qla2xxx [0000:33:00.1]-00fc:3: ISP2031: PCIe (8.0GT/s x8) @ 0000:33:00.1 hdma+ host#=3 fw=7.03.01 (d0d5).
[  109.090980] qla2xxx [0000:53:00.0]-011c: : MSI-X vector count: 31.
[  109.097805] qla2xxx [0000:53:00.0]-001d: : Found an ISP2031 irq 130 iobase 0xffffc906343ce000.
[  109.656267] scsi 3:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.665521] scsi 3:0:0:0: alua: supports implicit TPGS
[  109.671305] scsi 3:0:0:0: alua: port group 01 rel port 05
[  109.677312] scsi 3:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  109.685462] scsi 3:0:0:0: alua: Attached
[  109.691027] scsi 3:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  109.700202] scsi 3:0:1:0: alua: supports implicit TPGS
[  109.705979] scsi 3:0:1:0: alua: port group 00 rel port 01
[  109.711982] scsi 3:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  109.720128] scsi 3:0:1:0: alua: Attached
[  110.543572] scsi host4: qla2xxx
[  111.302524] qla2xxx [0000:53:00.0]-500a:4: LOOP UP detected (8 Gbps).
[  111.949212] qla2xxx [0000:53:00.0]-00fb:4: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  111.957946] qla2xxx [0000:53:00.0]-00fc:4: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.0 hdma+ host#=4 fw=7.03.01 (d0d5).
[  111.969855] qla2xxx [0000:53:00.1]-011c: : MSI-X vector count: 31.
[  111.976660] qla2xxx [0000:53:00.1]-001d: : Found an ISP2031 irq 133 iobase 0xffffc906343de000.
[  112.559917] scsi 4:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  112.569231] scsi 4:0:0:0: alua: supports implicit TPGS
[  112.575046] scsi 4:0:0:0: alua: port group 01 rel port 05
[  112.581074] scsi 4:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  112.589228] scsi 4:0:0:0: alua: Attached
[  112.594909] scsi 4:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  112.604193] scsi 4:0:1:0: alua: supports implicit TPGS
[  112.610022] scsi 4:0:1:0: alua: port group 00 rel port 01
[  112.616048] scsi 4:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  112.624201] scsi 4:0:1:0: alua: Attached
[  113.407128] scsi host5: qla2xxx
[  114.165289] qla2xxx [0000:53:00.1]-500a:5: LOOP UP detected (8 Gbps).
[  114.816775] qla2xxx [0000:53:00.1]-00fb:5: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  114.825502] qla2xxx [0000:53:00.1]-00fc:5: ISP2031: PCIe (8.0GT/s x8) @ 0000:53:00.1 hdma+ host#=5 fw=7.03.01 (d0d5).
[  114.838189] qla2xxx [0000:73:00.0]-011c: : MSI-X vector count: 31.
[  114.845037] qla2xxx [0000:73:00.0]-001d: : Found an ISP2031 irq 136 iobase 0xffffc906343e8000.
[  115.423501] scsi 5:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  115.432770] scsi 5:0:0:0: alua: supports implicit TPGS
[  115.438550] scsi 5:0:0:0: alua: port group 01 rel port 05
[  115.444555] scsi 5:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  115.452701] scsi 5:0:0:0: alua: Attached
[  115.458371] scsi 5:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  115.467559] scsi 5:0:1:0: alua: supports implicit TPGS
[  115.473319] scsi 5:0:1:0: alua: port group 00 rel port 01
[  115.479319] scsi 5:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  115.487468] scsi 5:0:1:0: alua: Attached
[  116.294733] scsi host6: qla2xxx
[  117.053760] qla2xxx [0000:73:00.0]-500a:6: LOOP UP detected (8 Gbps).
[  117.704395] qla2xxx [0000:73:00.0]-00fb:6: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  117.713123] qla2xxx [0000:73:00.0]-00fc:6: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.0 hdma+ host#=6 fw=7.03.01 (d0d5).
[  117.725045] qla2xxx [0000:73:00.1]-011c: : MSI-X vector count: 31.
[  117.731853] qla2xxx [0000:73:00.1]-001d: : Found an ISP2031 irq 139 iobase 0xffffc906343ec000.
[  118.311104] scsi 6:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  118.320422] scsi 6:0:0:0: alua: supports implicit TPGS
[  118.326231] scsi 6:0:0:0: alua: port group 01 rel port 05
[  118.332257] scsi 6:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  118.340405] scsi 6:0:0:0: alua: Attached
[  118.346230] scsi 6:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  118.355495] scsi 6:0:1:0: alua: supports implicit TPGS
[  118.361304] scsi 6:0:1:0: alua: port group 00 rel port 01
[  118.367331] scsi 6:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  118.375472] scsi 6:0:1:0: alua: Attached
[  119.158296] scsi host7: qla2xxx
[  119.917497] qla2xxx [0000:73:00.1]-500a:7: LOOP UP detected (8 Gbps).
[  120.571960] qla2xxx [0000:73:00.1]-00fb:7: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  120.580691] qla2xxx [0000:73:00.1]-00fc:7: ISP2031: PCIe (8.0GT/s x8) @ 0000:73:00.1 hdma+ host#=7 fw=7.03.01 (d0d5).
[  120.593333] qla2xxx [0000:93:00.0]-011c: : MSI-X vector count: 31.
[  120.600166] qla2xxx [0000:93:00.0]-001d: : Found an ISP2031 irq 142 iobase 0xffffc906343f6000.
[  121.174664] scsi 7:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  121.183958] scsi 7:0:0:0: alua: supports implicit TPGS
[  121.189744] scsi 7:0:0:0: alua: port group 01 rel port 05
[  121.195755] scsi 7:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  121.203897] scsi 7:0:0:0: alua: Attached
[  121.209660] scsi 7:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  121.218851] scsi 7:0:1:0: alua: supports implicit TPGS
[  121.224620] scsi 7:0:1:0: alua: port group 00 rel port 01
[  121.230623] scsi 7:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  121.238767] scsi 7:0:1:0: alua: Attached
[  122.049907] scsi host8: qla2xxx
[  122.809185] qla2xxx [0000:93:00.0]-500a:8: LOOP UP detected (8 Gbps).
[  123.451578] qla2xxx [0000:93:00.0]-00fb:8: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  123.460323] qla2xxx [0000:93:00.0]-00fc:8: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.0 hdma+ host#=8 fw=7.03.01 (d0d5).
[  123.472266] qla2xxx [0000:93:00.1]-011c: : MSI-X vector count: 31.
[  123.479084] qla2xxx [0000:93:00.1]-001d: : Found an ISP2031 irq 145 iobase 0xffffc90634bbe000.
[  124.066309] scsi 8:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  124.075592] scsi 8:0:0:0: alua: supports implicit TPGS
[  124.081398] scsi 8:0:0:0: alua: port group 01 rel port 05
[  124.087425] scsi 8:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  124.095570] scsi 8:0:0:0: alua: Attached
[  124.101188] scsi 8:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  124.110459] scsi 8:0:1:0: alua: supports implicit TPGS
[  124.116262] scsi 8:0:1:0: alua: port group 00 rel port 01
[  124.122285] scsi 8:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  124.130430] scsi 8:0:1:0: alua: Attached
[  124.909496] scsi host9: qla2xxx
[  125.669773] qla2xxx [0000:93:00.1]-500a:9: LOOP UP detected (8 Gbps).
[  126.323160] qla2xxx [0000:93:00.1]-00fb:9: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  126.331889] qla2xxx [0000:93:00.1]-00fc:9: ISP2031: PCIe (8.0GT/s x8) @ 0000:93:00.1 hdma+ host#=9 fw=7.03.01 (d0d5).
[  126.344560] qla2xxx [0000:b3:00.0]-011c: : MSI-X vector count: 31.
[  126.351410] qla2xxx [0000:b3:00.0]-001d: : Found an ISP2031 irq 148 iobase 0xffffc90634bc8000.
[  126.925851] scsi 9:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  126.935150] scsi 9:0:0:0: alua: supports implicit TPGS
[  126.940934] scsi 9:0:0:0: alua: port group 01 rel port 05
[  126.946937] scsi 9:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  126.955083] scsi 9:0:0:0: alua: Attached
[  126.960687] scsi 9:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  126.969869] scsi 9:0:1:0: alua: supports implicit TPGS
[  126.975634] scsi 9:0:1:0: alua: port group 00 rel port 01
[  126.981634] scsi 9:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  126.989780] scsi 9:0:1:0: alua: Attached
[  127.797103] scsi host10: qla2xxx
[  128.574416] qla2xxx [0000:b3:00.0]-500a:10: LOOP UP detected (8 Gbps).
[  129.230783] qla2xxx [0000:b3:00.0]-00fb:10: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  129.240861] qla2xxx [0000:b3:00.0]-00fc:10: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.0 hdma+ host#=10 fw=7.03.01 (d0d5).
[  129.254487] qla2xxx [0000:b3:00.1]-011c: : MSI-X vector count: 31.
[  129.262585] qla2xxx [0000:b3:00.1]-001d: : Found an ISP2031 irq 151 iobase 0xffffc90634bcc000.
[  129.813453] scsi 10:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  129.822954] scsi 10:0:0:0: alua: supports implicit TPGS
[  129.829999] scsi 10:0:0:0: alua: port group 01 rel port 05
[  129.837486] scsi 10:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  129.847178] scsi 10:0:0:0: alua: Attached
[  129.854554] scsi 10:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  129.863987] scsi 10:0:1:0: alua: supports implicit TPGS
[  129.871073] scsi 10:0:1:0: alua: port group 00 rel port 01
[  129.878573] scsi 10:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  129.888262] scsi 10:0:1:0: alua: Attached
[  130.580169] [drm] Initialized drm 1.1.0 20060810
[  130.618608] checking generic (92000000 600000) vs hw (92000000 1000000)
[  130.618611] fb: switching to mgag200drmfb from EFI VGA
[  130.625452] Console: switching to colour dummy device 80x25
[  130.644247] [TTM] Zone  kernel: Available graphics memory: 6353844726 kiB
[  130.652794] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[  130.661499] [TTM] Initializing pool allocator
[  130.666311] [TTM] Initializing DMA pool allocator
[  130.692686] scsi host11: qla2xxx
[  130.702228] fbcon: mgadrmfb (fb0) is primary device
[  130.824738] Console: switching to colour frame buffer device 128x48
[  130.872472] mgag200 0000:07:00.1: fb0: mgadrmfb frame buffer device
[  130.880894] mgag200 0000:07:00.1: registered panic notifier
[  130.912863] [drm] Initialized mgag200 1.0.0 20110418 for 0000:07:00.1 on minor 0
[  131.454075] qla2xxx [0000:b3:00.1]-500a:11: LOOP UP detected (8 Gbps).
[  132.102349] qla2xxx [0000:b3:00.1]-00fb:11: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  132.111172] qla2xxx [0000:b3:00.1]-00fc:11: ISP2031: PCIe (8.0GT/s x8) @ 0000:b3:00.1 hdma+ host#=11 fw=7.03.01 (d0d5).
[  132.124010] qla2xxx [0000:d3:00.0]-011c: : MSI-X vector count: 31.
[  132.130866] qla2xxx [0000:d3:00.0]-001d: : Found an ISP2031 irq 154 iobase 0xffffc90634400000.
[  132.709070] scsi 11:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  132.718483] scsi 11:0:0:0: alua: supports implicit TPGS
[  132.724362] scsi 11:0:0:0: alua: port group 01 rel port 05
[  132.730472] scsi 11:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  132.738713] scsi 11:0:0:0: alua: Attached
[  132.744631] scsi 11:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  132.753916] scsi 11:0:1:0: alua: supports implicit TPGS
[  132.759778] scsi 11:0:1:0: alua: port group 00 rel port 01
[  132.765872] scsi 11:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  132.774114] scsi 11:0:1:0: alua: Attached
[  133.576320] scsi host12: qla2xxx
[  134.364864] qla2xxx [0000:d3:00.0]-500a:12: LOOP UP detected (8 Gbps).
[  135.018004] qla2xxx [0000:d3:00.0]-00fb:12: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  135.026831] qla2xxx [0000:d3:00.0]-00fc:12: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.0 hdma+ host#=12 fw=7.03.01 (d0d5).
[  135.038934] qla2xxx [0000:d3:00.1]-011c: : MSI-X vector count: 31.
[  135.045746] qla2xxx [0000:d3:00.1]-001d: : Found an ISP2031 irq 157 iobase 0xffffc90634404000.
[  135.592681] scsi 12:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  135.602075] scsi 12:0:0:0: alua: supports implicit TPGS
[  135.607974] scsi 12:0:0:0: alua: port group 01 rel port 05
[  135.614093] scsi 12:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  135.622334] scsi 12:0:0:0: alua: Attached
[  135.627998] scsi 12:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  135.637349] scsi 12:0:1:0: alua: supports implicit TPGS
[  135.643242] scsi 12:0:1:0: alua: port group 00 rel port 01
[  135.649359] scsi 12:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  135.657602] scsi 12:0:1:0: alua: Attached
[  136.475912] scsi host13: qla2xxx
[  137.254311] qla2xxx [0000:d3:00.1]-500a:13: LOOP UP detected (8 Gbps).
[  137.897580] qla2xxx [0000:d3:00.1]-00fb:13: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  137.906399] qla2xxx [0000:d3:00.1]-00fc:13: ISP2031: PCIe (8.0GT/s x8) @ 0000:d3:00.1 hdma+ host#=13 fw=7.03.01 (d0d5).
[  137.919291] qla2xxx [0000:f3:00.0]-011c: : MSI-X vector count: 31.
[  137.926119] qla2xxx [0000:f3:00.0]-001d: : Found an ISP2031 irq 160 iobase 0xffffc9063440e000.
[  138.492451] scsi 13:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  138.501978] scsi 13:0:0:0: alua: supports implicit TPGS
[  138.507851] scsi 13:0:0:0: alua: port group 01 rel port 05
[  138.513951] scsi 13:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  138.522194] scsi 13:0:0:0: alua: Attached
[  138.528368] scsi 13:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  138.537648] scsi 13:0:1:0: alua: supports implicit TPGS
[  138.543509] scsi 13:0:1:0: alua: port group 00 rel port 01
[  138.549602] scsi 13:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  138.557842] scsi 13:0:1:0: alua: Attached
[  139.375549] scsi host14: qla2xxx
[  140.135676] qla2xxx [0000:f3:00.0]-500a:14: LOOP UP detected (8 Gbps).
[  140.793222] qla2xxx [0000:f3:00.0]-00fb:14: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  140.802047] qla2xxx [0000:f3:00.0]-00fc:14: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.0 hdma+ host#=14 fw=7.03.01 (d0d5).
[  140.814351] qla2xxx [0000:f3:00.1]-011c: : MSI-X vector count: 31.
[  140.821161] qla2xxx [0000:f3:00.1]-001d: : Found an ISP2031 irq 163 iobase 0xffffc9063441e000.
[  141.391916] scsi 14:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  141.401313] scsi 14:0:0:0: alua: supports implicit TPGS
[  141.407216] scsi 14:0:0:0: alua: port group 01 rel port 05
[  141.413333] scsi 14:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  141.421574] scsi 14:0:0:0: alua: Attached
[  141.427268] scsi 14:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  141.436606] scsi 14:0:1:0: alua: supports implicit TPGS
[  141.442510] scsi 14:0:1:0: alua: port group 00 rel port 01
[  141.448627] scsi 14:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  141.456869] scsi 14:0:1:0: alua: Attached
[  142.239103] scsi host15: qla2xxx
[  142.998903] random: nonblocking pool is initialized
[  143.018151] qla2xxx [0000:f3:00.1]-500a:15: LOOP UP detected (8 Gbps).
[  143.664768] qla2xxx [0000:f3:00.1]-00fb:15: QLogic QMH2672 - HP QMH2672 16Gb 2P FC HBA.
[  143.673588] qla2xxx [0000:f3:00.1]-00fc:15: ISP2031: PCIe (8.0GT/s x8) @ 0000:f3:00.1 hdma+ host#=15 fw=7.03.01 (d0d5).
[  143.701811] sd 0:0:0:0: [sda] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  143.701856] sd 0:0:0:1: [sdb] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  143.702031] sd 0:0:0:2: [sdc] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  143.702138] sd 0:0:0:1: [sdb] Write Protect is off
[  143.702141] sd 0:0:0:1: [sdb] Mode Sense: ef 00 00 08
[  143.702279] sd 0:0:0:1: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.702327] sd 0:0:0:2: [sdc] Write Protect is off
[  143.702329] sd 0:0:0:2: [sdc] Mode Sense: ef 00 00 08
[  143.702390] sd 0:0:0:3: [sdd] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[  143.702484] sd 0:0:0:2: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.702772] sd 0:0:1:0: [sde] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  143.702876] sd 0:0:0:3: [sdd] Write Protect is off
[  143.702879] sd 0:0:0:3: [sdd] Mode Sense: ef 00 00 08
[  143.702997] sd 0:0:1:1: [sdf] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  143.703022] sd 0:0:0:3: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.703136] sd 0:0:1:0: [sde] Write Protect is off
[  143.703139] sd 0:0:1:0: [sde] Mode Sense: ef 00 00 08
[  143.703431] sd 0:0:1:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.703545] sd 0:0:1:1: [sdf] Write Protect is off
[  143.703547] sd 0:0:1:1: [sdf] Mode Sense: ef 00 00 08
[  143.703591] sd 0:0:1:2: [sdg] 195305472 512-byte logical blocks: (99.9 GB/93.1 GiB)
[  143.703870] sd 0:0:1:1: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.704233] sd 0:0:1:2: [sdg] Write Protect is off
[  143.704235] sd 0:0:1:2: [sdg] Mode Sense: ef 00 00 08
[  143.704437] sd 0:0:1:2: [sdg] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.706206] sd 0:0:1:3: [sdh] 1367179264 512-byte logical blocks: (699 GB/651 GiB)
[  143.706446] sd 2:0:0:0: [sdi] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  143.706675] sd 0:0:1:3: [sdh] Write Protect is off
[  143.706678] sd 0:0:1:3: [sdh] Mode Sense: ef 00 00 08
[  143.706749] sd 2:0:0:100: [sdj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.706787] sd 2:0:0:0: [sdi] Write Protect is off
[  143.706789] sd 2:0:0:0: [sdi] Mode Sense: ef 00 00 08
[  143.706903] sd 0:0:1:3: [sdh] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.706932] sd 2:0:0:0: [sdi] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.707079] sd 2:0:0:101: [sdk] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.707099] sd 2:0:0:100: [sdj] Write Protect is off
[  143.707101] sd 2:0:0:100: [sdj] Mode Sense: ef 00 00 08
[  143.707292] sd 2:0:0:100: [sdj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.707367] sd 2:0:0:102: [sdl] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.707413]  sdg: sdg1 sdg2 sdg3
[  143.707531]  sdc: sdc1 sdc2 sdc3
[  143.707583] sd 2:0:0:101: [sdk] Write Protect is off
[  143.707585] sd 2:0:0:101: [sdk] Mode Sense: ef 00 00 08
[  143.707741] sd 2:0:0:103: [sdm] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.707858] sd 2:0:0:104: [sdn] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.707861] sd 2:0:0:101: [sdk] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.707978] sd 2:0:0:102: [sdl] Write Protect is off
[  143.707981] sd 2:0:0:102: [sdl] Mode Sense: ef 00 00 08
[  143.708021] sd 2:0:0:105: [sdo] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.708215] sd 2:0:0:106: [sdp] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.708267] sd 2:0:0:103: [sdm] Write Protect is off
[  143.708269] sd 2:0:0:103: [sdm] Mode Sense: ef 00 00 08
[  143.708277] sd 2:0:0:102: [sdl] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.708468] sd 2:0:0:104: [sdn] Write Protect is off
[  143.708470] sd 2:0:0:104: [sdn] Mode Sense: ef 00 00 08
[  143.708518] sd 2:0:0:107: [sdq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.708535] sd 2:0:0:103: [sdm] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.708647] sd 2:0:0:105: [sdo] Write Protect is off
[  143.708649] sd 2:0:0:105: [sdo] Mode Sense: ef 00 00 08
[  143.708728] sd 2:0:0:104: [sdn] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.708739] sd 2:0:0:108: [sdr] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.708748] sd 2:0:0:106: [sdp] Write Protect is off
[  143.708750] sd 2:0:0:106: [sdp] Mode Sense: ef 00 00 08
[  143.708838] sd 2:0:0:109: [sds] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.708937] sd 2:0:0:105: [sdo] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.709330] sd 2:0:0:106: [sdp] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.709346] sd 2:0:0:107: [sdq] Write Protect is off
[  143.709348] sd 2:0:0:107: [sdq] Mode Sense: ef 00 00 08
[  143.709529] sd 2:0:0:110: [sdt] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.709669] sd 2:0:0:108: [sdr] Write Protect is off
[  143.709671] sd 2:0:0:108: [sdr] Mode Sense: ef 00 00 08
[  143.709703] sd 2:0:0:107: [sdq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.709733] sd 2:0:0:109: [sds] Write Protect is off
[  143.709736] sd 2:0:0:109: [sds] Mode Sense: ef 00 00 08
[  143.709766] sd 0:0:1:2: [sdg] Attached SCSI disk
[  143.710036] sd 2:0:0:108: [sdr] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.710106] sd 2:0:0:109: [sds] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.710120] sd 2:0:0:111: [sdu] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.710283] sd 0:0:0:2: [sdc] Attached SCSI disk
[  143.710300] sd 2:0:0:112: [sdv] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.710308] sd 2:0:0:110: [sdt] Write Protect is off
[  143.710310] sd 2:0:0:110: [sdt] Mode Sense: ef 00 00 08
[  143.710651] sd 2:0:0:113: [sdw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.710664] sd 2:0:0:110: [sdt] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.710913] sd 2:0:0:111: [sdu] Write Protect is off
[  143.710915] sd 2:0:0:111: [sdu] Mode Sense: ef 00 00 08
[  143.711110] sd 2:0:0:112: [sdv] Write Protect is off
[  143.711112] sd 2:0:0:112: [sdv] Mode Sense: ef 00 00 08
[  143.711332] sd 2:0:0:111: [sdu] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.711526] sd 2:0:0:113: [sdw] Write Protect is off
[  143.711528] sd 2:0:0:113: [sdw] Mode Sense: ef 00 00 08
[  143.711535] sd 2:0:0:112: [sdv] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.712015] sd 2:0:0:113: [sdw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.712046] sd 2:0:0:100: [sdj] Attached SCSI disk
[  143.712459] sd 2:0:0:114: [sdx] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.713526] sd 2:0:0:101: [sdk] Attached SCSI disk
[  143.713536] sd 2:0:0:114: [sdx] Write Protect is off
[  143.713538] sd 2:0:0:114: [sdx] Mode Sense: ef 00 00 08
[  143.713828]  sdh: sdh1 sdh2 sdh3 sdh4 sdh5
[  143.713962] sd 2:0:0:115: [sdy] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.713969] sd 2:0:0:114: [sdx] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.714284] sd 2:0:0:103: [sdm] Attached SCSI disk
[  143.714303] sd 2:0:0:102: [sdl] Attached SCSI disk
[  143.714779] sd 2:0:0:116: [sdz] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.714797] sd 2:0:0:104: [sdn] Attached SCSI disk
[  143.714814] sd 2:0:0:117: [sdaa] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.714843] sd 2:0:0:118: [sdab] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.714856] sd 2:0:0:115: [sdy] Write Protect is off
[  143.714858] sd 2:0:0:115: [sdy] Mode Sense: ef 00 00 08
[  143.715280] sd 2:0:0:119: [sdac] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.715309] sd 2:0:0:115: [sdy] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.715458] sd 2:0:0:106: [sdp] Attached SCSI disk
[  143.715490] sd 2:0:0:105: [sdo] Attached SCSI disk
[  143.715699] sd 2:0:0:116: [sdz] Write Protect is off
[  143.715702] sd 2:0:0:116: [sdz] Mode Sense: ef 00 00 08
[  143.715743] sd 2:0:1:0: [sdad] 136716288 512-byte logical blocks: (69.9 GB/65.1 GiB)
[  143.715757] sd 2:0:0:117: [sdaa] Write Protect is off
[  143.715760] sd 2:0:0:117: [sdaa] Mode Sense: ef 00 00 08
[  143.715764] sd 2:0:0:118: [sdab] Write Protect is off
[  143.715767] sd 2:0:0:118: [sdab] Mode Sense: ef 00 00 08
[  143.715951] sd 2:0:1:100: [sdae] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716006] sd 2:0:0:107: [sdq] Attached SCSI disk
[  143.716013] sd 2:0:0:108: [sdr] Attached SCSI disk
[  143.716022] sd 2:0:0:109: [sds] Attached SCSI disk
[  143.716098] sd 2:0:0:119: [sdac] Write Protect is off
[  143.716100] sd 2:0:0:119: [sdac] Mode Sense: ef 00 00 08
[  143.716112] sd 2:0:0:116: [sdz] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.716133] sd 2:0:0:117: [sdaa] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.716146] sd 2:0:0:118: [sdab] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.716196]  sdd: sdd1 sdd2 sdd3 sdd4 sdd5
[  143.716305] sd 2:0:1:101: [sdaf] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716375] sd 2:0:0:119: [sdac] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.716388] sd 2:0:0:110: [sdt] Attached SCSI disk
[  143.716413] sd 2:0:1:0: [sdad] Write Protect is off
[  143.716415] sd 2:0:1:0: [sdad] Mode Sense: ef 00 00 08
[  143.716528] sd 2:0:1:102: [sdag] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716540] sd 2:0:1:103: [sdah] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716580] sd 0:0:1:3: [sdh] Attached SCSI disk
[  143.716605] sd 2:0:1:100: [sdae] Write Protect is off
[  143.716607] sd 2:0:1:100: [sdae] Mode Sense: ef 00 00 08
[  143.716781] sd 2:0:1:104: [sdai] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716828] sd 2:0:1:0: [sdad] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.716929]  sdf: sdf1 sdf2 sdf3
[  143.716978] sd 2:0:1:105: [sdaj] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.716987] sd 2:0:1:100: [sdae] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.717020] sd 2:0:1:101: [sdaf] Write Protect is off
[  143.717022] sd 2:0:1:101: [sdaf] Mode Sense: ef 00 00 08
[  143.717267] sd 2:0:0:111: [sdu] Attached SCSI disk
[  143.717282] sd 2:0:1:102: [sdag] Write Protect is off
[  143.717284] sd 2:0:1:102: [sdag] Mode Sense: ef 00 00 08
[  143.717345] sd 2:0:1:103: [sdah] Write Protect is off
[  143.717347] sd 2:0:1:103: [sdah] Mode Sense: ef 00 00 08
[  143.717356] sd 2:0:1:101: [sdaf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.717394] sd 2:0:0:112: [sdv] Attached SCSI disk
[  143.717479] sd 2:0:1:104: [sdai] Write Protect is off
[  143.717482] sd 2:0:1:104: [sdai] Mode Sense: ef 00 00 08
[  143.717488] sd 2:0:1:106: [sdak] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.717589] sd 2:0:1:107: [sdal] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.717602] sd 2:0:1:102: [sdag] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.717637] sd 2:0:1:105: [sdaj] Write Protect is off
[  143.717640] sd 2:0:1:105: [sdaj] Mode Sense: ef 00 00 08
[  143.717696] sd 2:0:0:113: [sdw] Attached SCSI disk
[  143.717711] sd 2:0:1:103: [sdah] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.717768] sd 2:0:1:108: [sdam] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.717806] sd 2:0:1:104: [sdai] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.718066] sd 2:0:1:105: [sdaj] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.718078] sd 2:0:1:109: [sdan] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.718276] sd 2:0:1:106: [sdak] Write Protect is off
[  143.718279] sd 2:0:1:106: [sdak] Mode Sense: ef 00 00 08
[  143.718363] sd 2:0:1:107: [sdal] Write Protect is off
[  143.718365] sd 2:0:1:107: [sdal] Mode Sense: ef 00 00 08
[  143.718552]  sdb: sdb1 sdb2 sdb3
[  143.718593] sd 2:0:1:108: [sdam] Write Protect is off
[  143.718594] sd 2:0:1:108: [sdam] Mode Sense: ef 00 00 08
[  143.718605] sd 0:0:0:3: [sdd] Attached SCSI disk
[  143.718761] sd 2:0:1:106: [sdak] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.718792] sd 2:0:0:114: [sdx] Attached SCSI disk
[  143.718852] sd 2:0:1:107: [sdal] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.719086] sd 2:0:1:109: [sdan] Write Protect is off
[  143.719088] sd 2:0:1:109: [sdan] Mode Sense: ef 00 00 08
[  143.719101] sd 2:0:1:108: [sdam] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.719127] sd 2:0:1:110: [sdao] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.719369] sd 2:0:1:111: [sdap] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.719648] sd 2:0:1:109: [sdan] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.719834] sd 2:0:0:115: [sdy] Attached SCSI disk
[  143.720062] sd 0:0:1:1: [sdf] Attached SCSI disk
[  143.720208] sd 2:0:1:110: [sdao] Write Protect is off
[  143.720210] sd 2:0:1:110: [sdao] Mode Sense: ef 00 00 08
[  143.720224] sd 0:0:0:1: [sdb] Attached SCSI disk
[  143.720229]  sde: sde1 sde2 sde3
[  143.720295] sd 2:0:1:112: [sdaq] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.720310] sd 2:0:1:111: [sdap] Write Protect is off
[  143.720311] sd 2:0:1:111: [sdap] Mode Sense: ef 00 00 08
[  143.720446] sd 2:0:1:113: [sdar] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.720617] sd 2:0:1:110: [sdao] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.720648] sd 2:0:1:114: [sdas] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.720796] sd 2:0:1:111: [sdap] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.721200] sd 2:0:1:112: [sdaq] Write Protect is off
[  143.721202] sd 2:0:1:112: [sdaq] Mode Sense: ef 00 00 08
[  143.721212] sd 2:0:0:117: [sdaa] Attached SCSI disk
[  143.721275] sd 2:0:0:118: [sdab] Attached SCSI disk
[  143.721311] sd 2:0:1:113: [sdar] Write Protect is off
[  143.721313] sd 2:0:1:113: [sdar] Mode Sense: ef 00 00 08
[  143.721567] sd 2:0:1:114: [sdas] Write Protect is off
[  143.721569] sd 2:0:1:114: [sdas] Mode Sense: ef 00 00 08
[  143.721600] sd 2:0:1:115: [sdat] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.721642] sd 2:0:1:112: [sdaq] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.721652] sd 2:0:1:116: [sdau] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.721684] sd 2:0:0:119: [sdac] Attached SCSI disk
[  143.721711] sd 2:0:1:117: [sdav] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.721779] sd 2:0:1:113: [sdar] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.721798] sd 2:0:0:116: [sdz] Attached SCSI disk
[  143.722236] sd 2:0:1:114: [sdas] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.722295] sd 0:0:1:0: [sde] Attached SCSI disk
[  143.722363] sd 2:0:1:118: [sdaw] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.722492] sd 2:0:1:119: [sdax] 1949696 512-byte logical blocks: (998 MB/952 MiB)
[  143.722710] sd 2:0:1:100: [sdae] Attached SCSI disk
[  143.722719] sd 2:0:1:115: [sdat] Write Protect is off
[  143.722721] sd 2:0:1:115: [sdat] Mode Sense: ef 00 00 08
[  143.722795] sd 2:0:1:116: [sdau] Write Protect is off
[  143.722797] sd 2:0:1:116: [sdau] Mode Sense: ef 00 00 08
[  143.722874] sd 2:0:1:117: [sdav] Write Protect is off
[  143.722876] sd 2:0:1:117: [sdav] Mode Sense: ef 00 00 08
[  143.723019] sd 2:0:1:101: [sdaf] Attached SCSI disk
[  143.723174] sd 2:0:1:115: [sdat] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.723226] sd 2:0:1:116: [sdau] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.723256] sd 2:0:1:118: [sdaw] Write Protect is off
[  143.723258] sd 2:0:1:118: [sdaw] Mode Sense: ef 00 00 08
[  143.723276] sd 2:0:1:102: [sdag] Attached SCSI disk
[  143.723303] sd 2:0:1:117: [sdav] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.723389] sd 2:0:1:119: [sdax] Write Protect is off
[  143.723391] sd 2:0:1:119: [sdax] Mode Sense: ef 00 00 08
[  143.723421] sd 2:0:1:104: [sdai] Attached SCSI disk
[  143.723464] sd 2:0:1:103: [sdah] Attached SCSI disk
[  143.723594] sd 2:0:1:118: [sdaw] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.723723] sd 2:0:1:119: [sdax] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  143.723818] sd 2:0:1:105: [sdaj] Attached SCSI disk
[  143.724044] sd 2:0:1:106: [sdak] Attached SCSI disk
[  143.724199] sd 2:0:1:107: [sdal] Attached SCSI disk
[  143.724214] sd 2:0:1:108: [sdam] Attached SCSI disk
[  143.724760] sd 2:0:1:109: [sdan] Attached SCSI disk
[  143.725494] sd 2:0:1:111: [sdap] Attached SCSI disk
[  143.725513] sd 2:0:1:110: [sdao] Attached SCSI disk
[  143.726094] sd 2:0:1:112: [sdaq] Attached SCSI disk
[  143.726240] sd 2:0:1:113: [sdar] Attached SCSI disk
[  143.726242]  sdad: sdad1 sdad2 sdad3
[  143.726248] sd 2:0:1:114: [sdas] Attached SCSI disk
[  143.726575]  sdi: sdi1 sdi2 sdi3
[  143.726935] sd 2:0:1:116: [sdau] Attached SCSI disk
[  143.726961] sd 2:0:1:115: [sdat] Attached SCSI disk
[  143.726975] sd 2:0:1:117: [sdav] Attached SCSI disk
[  143.727010] sd 2:0:1:118: [sdaw] Attached SCSI disk
[  143.727074] sd 2:0:1:119: [sdax] Attached SCSI disk
[  143.727819] sd 2:0:1:0: [sdad] Attached SCSI disk
[  143.728172] sd 2:0:0:0: [sdi] Attached SCSI disk
[  144.259541] scsi 15:0:0:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  144.260475] scsi 15:0:0:0: alua: supports implicit TPGS
[  144.260578] scsi 15:0:0:0: alua: port group 01 rel port 05
[  144.260632] scsi 15:0:0:0: alua: port group 01 state A preferred supports tolusNA
[  144.260633] scsi 15:0:0:0: alua: Attached
[  144.267804] scsi 15:0:1:0: Enclosure         HP       MSA 2040 SAN     G101 PQ: 0 ANSI: 5
[  144.270075] scsi 15:0:1:0: alua: supports implicit TPGS
[  144.270530] scsi 15:0:1:0: alua: port group 00 rel port 01
[  144.270886] scsi 15:0:1:0: alua: port group 00 state A preferred supports tolusNA
[  144.270887] scsi 15:0:1:0: alua: Attached
[  145.244616] sd 0:0:0:0: [sda] Write Protect is off
[  145.249908] sd 0:0:0:0: [sda] Mode Sense: ef 00 00 08
[  145.250040] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  145.262520]  sda: sda1 sda2 sda3
[  145.268156] sd 0:0:0:0: [sda] Attached SCSI disk
[  145.471251] xor: automatically using best checksumming function:
[  145.515053]    avx       : 20850.000 MB/sec
[  145.607177] raid6: sse2x1    7423 MB/s
[  145.679258] raid6: sse2x2    9200 MB/s
[  145.751347] raid6: sse2x4   11094 MB/s
[  145.755477] raid6: using algorithm sse2x4 (11094 MB/s)
[  145.761133] raid6: using ssse3x2 recovery algorithm
[  146.273245] device-mapper: multipath: version 1.8.0 loaded
[  146.296682] device-mapper: multipath round-robin: version 1.0.0 loaded
[  146.320568] device-mapper: multipath queue-length: version 0.1.0 loaded
[  146.353149] device-mapper: multipath service-time: version 0.2.0 loaded
[  149.755561] kjournald starting.  Commit interval 5 seconds
[  149.755971] EXT3-fs (dm-14): using internal journal
[  149.755974] EXT3-fs (dm-14): mounted filesystem with ordered data mode
[  151.408710] udev: starting version 147
[  151.721083] ipmi message handler version 39.2
[  151.808736] IPMI System Interface driver.
[  151.832012] ipmi_si: probing via ACPI
[  151.836109] ipmi_si 00:00: [mem 0xfe062110000-0xfe062110002] regsize 1 spacing 1 irq 20
[  151.844919] ipmi_si: Adding ACPI-specified bt state machine
[  151.852026] rtc_cmos 00:01: RTC can wake from S4
[  151.854006] ipmi_si: probing via SPMI
[  151.854008] ipmi_si: SPMI: mem 0xfe062110000 regsize 1 spacing 1 irq 20
[  151.854010] ipmi_si: Adding SPMI-specified bt state machine duplicate interface
[  151.854012] ipmi_si: Trying ACPI-specified bt state machine at mem address 0xfe062110000, slave address 0x0, irq 20
[  151.875128] ipmi_si 00:00: Using irq 20
[  151.903202] IPMI BT: req2rsp=6 secs retries=16
[  151.915657] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[  151.924573] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[  151.957694] ipmi_si 00:00: Found new BMC (man_id: 0x00000b, prod_id: 0x1002, dev_id: 0x40)
[  151.967169] ipmi_si 00:00: IPMI bt interface initialized
[  152.351515] dca service started, version 1.12.1
[  152.427609] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[  152.437204] ACPI: Power Button [PWRB]
[  152.440290] pps_core: LinuxPPS API ver. 1 registered
[  152.440291] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[  152.473082] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: NMI decoding initialized, allow kernel dump: ON (default = 1/ON)
[  152.487463] ehci-pci: EHCI PCI platform driver
[  152.488024] hpwdt 0000:07:00.0: HP Watchdog Timer Driver: 1.3.3, timer margin: 30 seconds (nowayout=0).
[  152.505957] ehci-pci 0000:00:1d.0: EHCI Host Controller
[  152.511730] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[  152.519904] ehci-pci 0000:00:1d.0: debug port 2
[  152.528811] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[  152.528850] ehci-pci 0000:00:1d.0: irq 23, io mem 0x90700000
[  152.543871] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[  152.550309] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[  152.557786] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.565737] usb usb2: Product: EHCI Host Controller
[  152.571106] usb usb2: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.579921] usb usb2: SerialNumber: 0000:00:1d.0
[  152.580243] ses 1:0:0:0: Attached Enclosure device
[  152.580266] ses 1:0:1:0: Attached Enclosure device
[  152.580475] ses 3:0:0:0: Attached Enclosure device
[  152.580578] ses 3:0:1:0: Attached Enclosure device
[  152.580721] ses 4:0:0:0: Attached Enclosure device
[  152.580865] ses 4:0:1:0: Attached Enclosure device
[  152.581014] ses 5:0:0:0: Attached Enclosure device
[  152.581166] ses 5:0:1:0: Attached Enclosure device
[  152.581302] ses 6:0:0:0: Attached Enclosure device
[  152.581451] ses 6:0:1:0: Attached Enclosure device
[  152.581473] ses 7:0:0:0: Attached Enclosure device
[  152.581487] ses 7:0:1:0: Attached Enclosure device
[  152.581503] ses 8:0:0:0: Attached Enclosure device
[  152.581521] ses 8:0:1:0: Attached Enclosure device
[  152.581534] ses 9:0:0:0: Attached Enclosure device
[  152.581549] ses 9:0:1:0: Attached Enclosure device
[  152.581566] ses 10:0:0:0: Attached Enclosure device
[  152.581583] ses 10:0:1:0: Attached Enclosure device
[  152.581600] ses 11:0:0:0: Attached Enclosure device
[  152.581618] ses 11:0:1:0: Attached Enclosure device
[  152.581636] ses 12:0:0:0: Attached Enclosure device
[  152.581654] ses 12:0:1:0: Attached Enclosure device
[  152.581673] ses 13:0:0:0: Attached Enclosure device
[  152.581689] ses 13:0:1:0: Attached Enclosure device
[  152.581707] ses 14:0:0:0: Attached Enclosure device
[  152.581722] ses 14:0:1:0: Attached Enclosure device
[  152.581742] ses 15:0:0:0: Attached Enclosure device
[  152.581761] ses 15:0:1:0: Attached Enclosure device
[  152.734196] hub 2-0:1.0: USB hub found
[  152.738341] hub 2-0:1.0: 2 ports detected
[  152.747524] ehci-pci 0000:20:1d.0: EHCI Host Controller
[  152.753331] ehci-pci 0000:20:1d.0: new USB bus registered, assigned bus number 3
[  152.761510] ehci-pci 0000:20:1d.0: debug port 2
[  152.770442] ehci-pci 0000:20:1d.0: cache line size of 64 is not supported
[  152.770495] ehci-pci 0000:20:1d.0: irq 166, io mem 0x98600000
[  152.777220] PTP clock support registered
[  152.788421] ehci-pci 0000:20:1d.0: USB 2.0 started, EHCI 1.00
[  152.794935] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[  152.802420] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.810373] usb usb3: Product: EHCI Host Controller
[  152.815745] usb usb3: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.824557] usb usb3: SerialNumber: 0000:20:1d.0
[  152.829850] hub 3-0:1.0: USB hub found
[  152.833992] hub 3-0:1.0: 2 ports detected
[  152.839775] lpc_ich 0000:20:1f.0: I/O space for ACPI uninitialized
[  152.843166] ehci-pci 0000:40:1d.0: EHCI Host Controller
[  152.843196] ehci-pci 0000:40:1d.0: new USB bus registered, assigned bus number 4
[  152.843225] ehci-pci 0000:40:1d.0: debug port 2
[  152.843417] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  152.843712] sd 0:0:0:1: Attached scsi generic sg1 type 0
[  152.844007] sd 0:0:0:2: Attached scsi generic sg2 type 0
[  152.844645] sd 0:0:0:3: Attached scsi generic sg3 type 0
[  152.844967] sd 0:0:1:0: Attached scsi generic sg4 type 0
[  152.845404] sd 0:0:1:1: Attached scsi generic sg5 type 0
[  152.845758] sd 0:0:1:2: Attached scsi generic sg6 type 0
[  152.846058] sd 0:0:1:3: Attached scsi generic sg7 type 0
[  152.846368] ses 1:0:0:0: Attached scsi generic sg8 type 13
[  152.846669] ses 1:0:1:0: Attached scsi generic sg9 type 13
[  152.846977] sd 2:0:0:0: Attached scsi generic sg10 type 0
[  152.847144] ehci-pci 0000:40:1d.0: cache line size of 64 is not supported
[  152.847195] ehci-pci 0000:40:1d.0: irq 167, io mem 0xa0600000
[  152.847348] sd 2:0:0:100: Attached scsi generic sg11 type 0
[  152.847720] sd 2:0:0:101: Attached scsi generic sg12 type 0
[  152.848056] sd 2:0:0:102: Attached scsi generic sg13 type 0
[  152.848598] sd 2:0:0:103: Attached scsi generic sg14 type 0
[  152.848914] sd 2:0:0:104: Attached scsi generic sg15 type 0
[  152.849209] sd 2:0:0:105: Attached scsi generic sg16 type 0
[  152.849501] sd 2:0:0:106: Attached scsi generic sg17 type 0
[  152.849818] sd 2:0:0:107: Attached scsi generic sg18 type 0
[  152.850180] sd 2:0:0:108: Attached scsi generic sg19 type 0
[  152.850537] sd 2:0:0:109: Attached scsi generic sg20 type 0
[  152.850834] sd 2:0:0:110: Attached scsi generic sg21 type 0
[  152.851119] sd 2:0:0:111: Attached scsi generic sg22 type 0
[  152.851405] sd 2:0:0:112: Attached scsi generic sg23 type 0
[  152.851749] sd 2:0:0:113: Attached scsi generic sg24 type 0
[  152.852089] sd 2:0:0:114: Attached scsi generic sg25 type 0
[  152.852619] sd 2:0:0:115: Attached scsi generic sg26 type 0
[  152.853000] sd 2:0:0:116: Attached scsi generic sg27 type 0
[  152.853445] sd 2:0:0:117: Attached scsi generic sg28 type 0
[  152.853842] sd 2:0:0:118: Attached scsi generic sg29 type 0
[  152.854260] sd 2:0:0:119: Attached scsi generic sg30 type 0
[  152.854709] sd 2:0:1:0: Attached scsi generic sg31 type 0
[  152.855203] sd 2:0:1:100: Attached scsi generic sg32 type 0
[  152.855673] sd 2:0:1:101: Attached scsi generic sg33 type 0
[  152.856080] sd 2:0:1:102: Attached scsi generic sg34 type 0
[  152.856316] ehci-pci 0000:40:1d.0: USB 2.0 started, EHCI 1.00
[  152.856425] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[  152.856428] sd 2:0:1:103: Attached scsi generic sg35 type 0
[  152.856431] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.856433] usb usb4: Product: EHCI Host Controller
[  152.856434] usb usb4: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.856435] usb usb4: SerialNumber: 0000:40:1d.0
[  152.856826] hub 4-0:1.0: USB hub found
[  152.856838] hub 4-0:1.0: 2 ports detected
[  152.856856] sd 2:0:1:104: Attached scsi generic sg36 type 0
[  152.857385] sd 2:0:1:105: Attached scsi generic sg37 type 0
[  152.857841] sd 2:0:1:106: Attached scsi generic sg38 type 0
[  152.858235] sd 2:0:1:107: Attached scsi generic sg39 type 0
[  152.858693] sd 2:0:1:108: Attached scsi generic sg40 type 0
[  152.859096] sd 2:0:1:109: Attached scsi generic sg41 type 0
[  152.859500] sd 2:0:1:110: Attached scsi generic sg42 type 0
[  152.859899] sd 2:0:1:111: Attached scsi generic sg43 type 0
[  152.860198] sd 2:0:1:112: Attached scsi generic sg44 type 0
[  152.860487] ehci-pci 0000:60:1d.0: EHCI Host Controller
[  152.860514] ehci-pci 0000:60:1d.0: new USB bus registered, assigned bus number 5
[  152.860533] sd 2:0:1:113: Attached scsi generic sg45 type 0
[  152.860543] ehci-pci 0000:60:1d.0: debug port 2
[  152.860830] sd 2:0:1:114: Attached scsi generic sg46 type 0
[  152.861078] sd 2:0:1:115: Attached scsi generic sg47 type 0
[  152.861338] sd 2:0:1:116: Attached scsi generic sg48 type 0
[  152.861597] sd 2:0:1:117: Attached scsi generic sg49 type 0
[  152.861885] sd 2:0:1:118: Attached scsi generic sg50 type 0
[  152.862211] sd 2:0:1:119: Attached scsi generic sg51 type 0
[  152.862544] ses 3:0:0:0: Attached scsi generic sg52 type 13
[  152.862798] ses 3:0:1:0: Attached scsi generic sg53 type 13
[  152.863052] ses 4:0:0:0: Attached scsi generic sg54 type 13
[  152.863316] ses 4:0:1:0: Attached scsi generic sg55 type 13
[  152.863629] ses 5:0:0:0: Attached scsi generic sg56 type 13
[  152.863953] ses 5:0:1:0: Attached scsi generic sg57 type 13
[  152.864505] ehci-pci 0000:60:1d.0: cache line size of 64 is not supported
[  152.864551] ehci-pci 0000:60:1d.0: irq 168, io mem 0xa8600000
[  152.864807] ses 6:0:0:0: Attached scsi generic sg58 type 13
[  152.865072] ses 6:0:1:0: Attached scsi generic sg59 type 13
[  152.865356] ses 7:0:0:0: Attached scsi generic sg60 type 13
[  152.866936] ses 7:0:1:0: Attached scsi generic sg61 type 13
[  152.867362] ses 8:0:0:0: Attached scsi generic sg62 type 13
[  152.867810] ses 8:0:1:0: Attached scsi generic sg63 type 13
[  152.868370] ses 9:0:0:0: Attached scsi generic sg64 type 13
[  152.868820] ses 9:0:1:0: Attached scsi generic sg65 type 13
[  152.869221] ses 10:0:0:0: Attached scsi generic sg66 type 13
[  152.869616] ses 10:0:1:0: Attached scsi generic sg67 type 13
[  152.869914] ses 11:0:0:0: Attached scsi generic sg68 type 13
[  152.870212] ses 11:0:1:0: Attached scsi generic sg69 type 13
[  152.870527] ses 12:0:0:0: Attached scsi generic sg70 type 13
[  152.870821] ses 12:0:1:0: Attached scsi generic sg71 type 13
[  152.871111] ses 13:0:0:0: Attached scsi generic sg72 type 13
[  152.871378] ses 13:0:1:0: Attached scsi generic sg73 type 13
[  152.871647] ses 14:0:0:0: Attached scsi generic sg74 type 13
[  152.871920] ses 14:0:1:0: Attached scsi generic sg75 type 13
[  152.872334] ses 15:0:0:0: Attached scsi generic sg76 type 13
[  152.872619] ses 15:0:1:0: Attached scsi generic sg77 type 13
[  152.877430] ioatdma: Intel(R) QuickData Technology Driver 4.00
[  152.880351] ehci-pci 0000:60:1d.0: USB 2.0 started, EHCI 1.00
[  152.880478] usb usb5: New USB device found, idVendor=1d6b, idProduct=0002
[  152.880480] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.880481] usb usb5: Product: EHCI Host Controller
[  152.880483] usb usb5: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.880484] usb usb5: SerialNumber: 0000:60:1d.0
[  152.880907] hub 5-0:1.0: USB hub found
[  152.880921] hub 5-0:1.0: 2 ports detected
[  152.889031] ehci-pci 0000:84:1d.0: EHCI Host Controller
[  152.889060] ehci-pci 0000:84:1d.0: new USB bus registered, assigned bus number 6
[  152.889090] ehci-pci 0000:84:1d.0: debug port 2
[  152.893017] ehci-pci 0000:84:1d.0: cache line size of 64 is not supported
[  152.893068] ehci-pci 0000:84:1d.0: irq 174, io mem 0xb0600000
[  152.904325] ehci-pci 0000:84:1d.0: USB 2.0 started, EHCI 1.00
[  152.904474] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
[  152.904476] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.904478] usb usb6: Product: EHCI Host Controller
[  152.904480] usb usb6: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.904482] usb usb6: SerialNumber: 0000:84:1d.0
[  152.904961] hub 6-0:1.0: USB hub found
[  152.904974] hub 6-0:1.0: 2 ports detected
[  152.913082] ehci-pci 0000:a0:1d.0: EHCI Host Controller
[  152.913112] ehci-pci 0000:a0:1d.0: new USB bus registered, assigned bus number 7
[  152.913142] ehci-pci 0000:a0:1d.0: debug port 2
[  152.917088] ehci-pci 0000:a0:1d.0: cache line size of 64 is not supported
[  152.917129] ehci-pci 0000:a0:1d.0: irq 190, io mem 0xb8600000
[  152.928468] ehci-pci 0000:a0:1d.0: USB 2.0 started, EHCI 1.00
[  152.928915] usb usb7: New USB device found, idVendor=1d6b, idProduct=0002
[  152.928917] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  152.928920] usb usb7: Product: EHCI Host Controller
[  152.928921] usb usb7: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  152.928923] usb usb7: SerialNumber: 0000:a0:1d.0
[  152.977364] hub 7-0:1.0: USB hub found
[  152.977380] hub 7-0:1.0: 2 ports detected
[  153.060549] usb 2-1: new high-speed USB device number 2 using ehci-pci
[  153.136673] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.0.1-k
[  153.136674] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[  153.168746] usb 4-1: new high-speed USB device number 2 using ehci-pci
[  153.174779] ehci-pci 0000:c0:1d.0: EHCI Host Controller
[  153.175104] ehci-pci 0000:c0:1d.0: new USB bus registered, assigned bus number 8
[  153.175133] ehci-pci 0000:c0:1d.0: debug port 2
[  153.179043] ehci-pci 0000:c0:1d.0: cache line size of 64 is not supported
[  153.179090] ehci-pci 0000:c0:1d.0: irq 192, io mem 0xc0600000
[  153.196730] usb 5-1: new high-speed USB device number 2 using ehci-pci
[  153.201267] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[  153.201270] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  153.220793] usb 6-1: new high-speed USB device number 2 using ehci-pci
[  153.237513] hub 2-1:1.0: USB hub found
[  153.237897] ixgbe 0000:01:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  153.238020] ixgbe 0000:01:00.0: PCI Express bandwidth of 32GT/s available
[  153.238022] ixgbe 0000:01:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  153.238320] ixgbe 0000:01:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  153.238322] ixgbe 0000:01:00.0: 38:ea:a7:91:1b:74
[  153.238703] hub 2-1:1.0: 8 ports detected
[  153.292894] ehci-pci 0000:c0:1d.0: USB 2.0 started, EHCI 1.00
[  153.293169] usb usb8: New USB device found, idVendor=1d6b, idProduct=0002
[  153.293171] usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  153.293172] usb usb8: Product: EHCI Host Controller
[  153.293173] usb usb8: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  153.293173] usb usb8: SerialNumber: 0000:c0:1d.0
[  153.374224] hub 8-0:1.0: USB hub found
[  153.374238] hub 8-0:1.0: 2 ports detected
[  153.394434] usb 4-1: New USB device found, idVendor=8087, idProduct=0024
[  153.394437] usb 4-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  153.402595] hub 4-1:1.0: USB hub found
[  153.402786] hub 4-1:1.0: 8 ports detected
[  153.409143] usb 7-1: new high-speed USB device number 2 using ehci-pci
[  153.410323] ehci-pci 0000:e0:1d.0: EHCI Host Controller
[  153.410596] ehci-pci 0000:e0:1d.0: new USB bus registered, assigned bus number 9
[  153.672775] ehci-pci 0000:e0:1d.0: debug port 2
[  153.673157] usb 6-1: New USB device found, idVendor=8087, idProduct=0024
[  153.673159] usb 6-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  153.673182] usb 5-1: New USB device found, idVendor=8087, idProduct=0024
[  153.673184] usb 5-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  153.673481] usb 7-1: New USB device found, idVendor=8087, idProduct=0024
[  153.673484] usb 7-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  153.675362] hub 6-1:1.0: USB hub found
[  153.675756] hub 6-1:1.0: 8 ports detected
[  153.676717] ehci-pci 0000:e0:1d.0: cache line size of 64 is not supported
[  153.676768] ehci-pci 0000:e0:1d.0: irq 257, io mem 0xc8600000
[  153.677399] usb 2-1.3: new high-speed USB device number 3 using ehci-pci
[  153.681721] hub 7-1:1.0: USB hub found
[  153.681870] hub 7-1:1.0: 8 ports detected
[  153.683841] hub 5-1:1.0: USB hub found
[  153.684009] hub 5-1:1.0: 8 ports detected
[  153.709495] usb 8-1: new high-speed USB device number 2 using ehci-pci
[  153.721481] ehci-pci 0000:e0:1d.0: USB 2.0 started, EHCI 1.00
[  153.722373] usb usb9: New USB device found, idVendor=1d6b, idProduct=0002
[  153.722374] usb usb9: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[  153.722375] usb usb9: Product: EHCI Host Controller
[  153.722376] usb usb9: Manufacturer: Linux 4.0.0-mm-0.47.50.1.8286.5.PTF-bigsmp ehci_hcd
[  153.722377] usb usb9: SerialNumber: 0000:e0:1d.0
[  153.731004] hub 9-0:1.0: USB hub found
[  153.731021] hub 9-0:1.0: 2 ports detected
[  153.770076] input: PC Speaker as /devices/platform/pcspkr/input/input1
[  153.872185] ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
[  153.949863] usb 4-1.3: new high-speed USB device number 3 using ehci-pci
[  154.007809] usb 2-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.007815] usb 8-1: New USB device found, idVendor=8087, idProduct=0024
[  154.007820] usb 2-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.007824] usb 8-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.010538] hub 8-1:1.0: USB hub found
[  154.010728] hub 8-1:1.0: 8 ports detected
[  154.043040] usb 6-1.3: new high-speed USB device number 3 using ehci-pci
[  154.046196] usb 4-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.046199] usb 4-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.049527] ixgbe 0000:01:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.049665] ixgbe 0000:01:00.1: PCI Express bandwidth of 32GT/s available
[  154.049667] ixgbe 0000:01:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.050013] ixgbe 0000:01:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  154.050015] ixgbe 0000:01:00.1: 38:ea:a7:91:1b:75
[  154.078555] hub 4-1.3:1.0: USB hub found
[  154.078742] hub 4-1.3:1.0: 2 ports detected
[  154.087713] hub 2-1.3:1.0: USB hub found
[  154.087752] hub 2-1.3:1.0: 2 ports detected
[  154.097428] ixgbe 0000:01:00.1: Intel(R) 10 Gigabit Network Connection
[  154.138498] usb 6-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.138501] usb 6-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.139017] hub 6-1.3:1.0: USB hub found
[  154.139156] hub 6-1.3:1.0: 2 ports detected
[  154.169965] lpc_ich 0000:20:1f.0: No MFD cells added
[  154.175565] lpc_ich 0000:40:1f.0: I/O space for ACPI uninitialized
[  154.182385] lpc_ich 0000:40:1f.0: No MFD cells added
[  154.187944] lpc_ich 0000:60:1f.0: I/O space for ACPI uninitialized
[  154.194763] lpc_ich 0000:60:1f.0: No MFD cells added
[  154.200329] lpc_ich 0000:84:1f.0: I/O space for ACPI uninitialized
[  154.206054] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.206345] ixgbe 0000:03:00.0: PCI Express bandwidth of 32GT/s available
[  154.206347] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.206685] ixgbe 0000:03:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  154.206686] ixgbe 0000:03:00.0: 38:ea:a7:8c:db:b8
[  154.243763] lpc_ich 0000:84:1f.0: No MFD cells added
[  154.249343] lpc_ich 0000:a0:1f.0: I/O space for ACPI uninitialized
[  154.249890] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
[  154.263443] lpc_ich 0000:a0:1f.0: No MFD cells added
[  154.269062] lpc_ich 0000:c0:1f.0: I/O space for ACPI uninitialized
[  154.275884] lpc_ich 0000:c0:1f.0: No MFD cells added
[  154.278314] usb 5-1.3: new high-speed USB device number 3 using ehci-pci
[  154.278322] usb 7-1.3: new high-speed USB device number 3 using ehci-pci
[  154.296210] lpc_ich 0000:e0:1f.0: I/O space for ACPI uninitialized
[  154.302275] usb 8-1.3: new high-speed USB device number 3 using ehci-pci
[  154.310426] lpc_ich 0000:e0:1f.0: No MFD cells added
[  154.318264] usb 9-1: new high-speed USB device number 2 using ehci-pci
[  154.357775] Btrfs loaded
[  154.367411] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.376929] ixgbe 0000:03:00.1: PCI Express bandwidth of 32GT/s available
[  154.384443] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.384464] usb 7-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.384467] usb 7-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.391047] usb 3-1: new high-speed USB device number 2 using ehci-pci
[  154.392425] hub 7-1.3:1.0: USB hub found
[  154.399954] hub 7-1.3:1.0: 2 ports detected
[  154.399961] usb 5-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.399963] usb 5-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.408130] hub 5-1.3:1.0: USB hub found
[  154.415625] hub 5-1.3:1.0: 2 ports detected
[  154.448863] usb 8-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.449175] ixgbe 0000:03:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  154.449177] ixgbe 0000:03:00.1: 38:ea:a7:8c:db:b9
[  154.467180] usb 9-1: New USB device found, idVendor=8087, idProduct=0024
[  154.467183] usb 9-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.467628] hub 9-1:1.0: USB hub found
[  154.467791] hub 9-1:1.0: 8 ports detected
[  154.492218] usb 8-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.492426] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
[  154.508017] hub 8-1.3:1.0: USB hub found
[  154.512554] hub 8-1.3:1.0: 2 ports detected
[  154.529089] usb 3-1: New USB device found, idVendor=8087, idProduct=0024
[  154.536512] usb 3-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.544730] hub 3-1:1.0: USB hub found
[  154.549028] hub 3-1:1.0: 8 ports detected
[  154.592416] ixgbe 0000:21:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.601847] ixgbe 0000:21:00.0: PCI Express bandwidth of 32GT/s available
[  154.609320] ixgbe 0000:21:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.617512] ixgbe 0000:21:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  154.624315] ixgbe 0000:21:00.0: 38:ea:a7:91:65:ac
[  154.670576] ixgbe 0000:21:00.0: Intel(R) 10 Gigabit Network Connection
[  154.739128] usb 9-1.3: new high-speed USB device number 3 using ehci-pci
[  154.787218] ixgbe 0000:21:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.796646] ixgbe 0000:21:00.1: PCI Express bandwidth of 32GT/s available
[  154.804121] ixgbe 0000:21:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.812317] ixgbe 0000:21:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  154.819119] ixgbe 0000:21:00.1: 38:ea:a7:91:65:ad
[  154.847939] usb 9-1.3: New USB device found, idVendor=0424, idProduct=2660
[  154.855519] usb 9-1.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[  154.864773] hub 9-1.3:1.0: USB hub found
[  154.866776] ixgbe 0000:21:00.1: Intel(R) 10 Gigabit Network Connection
[  154.876434] hub 9-1.3:1.0: 2 ports detected
[  154.895418] usb 3-1.3: new high-speed USB device number 3 using ehci-pci
[  154.965301] ixgbe 0000:23:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  154.974725] ixgbe 0000:23:00.0: PCI Express bandwidth of 32GT/s available
[  154.982197] ixgbe 0000:23:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  154.990393] ixgbe 0000:23:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  154.997198] ixgbe 0000:23:00.0: 38:ea:a7:8c:db:a8
[  155.003158] usb 3-1.3: device descriptor read/64, error -71
[  155.042621] ixgbe 0000:23:00.0: Intel(R) 10 Gigabit Network Connection
[  155.169242] ixgbe 0000:23:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  155.178670] ixgbe 0000:23:00.1: PCI Express bandwidth of 32GT/s available
[  155.186148] ixgbe 0000:23:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  155.194338] ixgbe 0000:23:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  155.201140] ixgbe 0000:23:00.1: 38:ea:a7:8c:db:a9
[  155.223446] usb 3-1.3: device descriptor read/64, error -71
[  155.249812] ixgbe 0000:23:00.1: Intel(R) 10 Gigabit Network Connection
[  155.358773] ixgbe 0000:41:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  155.368221] ixgbe 0000:41:00.0: PCI Express bandwidth of 32GT/s available
[  155.375699] ixgbe 0000:41:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  155.384037] ixgbe 0000:41:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  155.390842] ixgbe 0000:41:00.0: 38:ea:a7:91:22:e4
[  155.403659] usb 3-1.3: new high-speed USB device number 4 using ehci-pci
[  155.439567] ixgbe 0000:41:00.0: Intel(R) 10 Gigabit Network Connection
[  155.496437] usb 3-1.3: device descriptor read/64, error -71
[  155.552100] ixgbe 0000:41:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  155.561536] ixgbe 0000:41:00.1: PCI Express bandwidth of 32GT/s available
[  155.569013] ixgbe 0000:41:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  155.577306] ixgbe 0000:41:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  155.584117] ixgbe 0000:41:00.1: 38:ea:a7:91:22:e5
[  155.625751] ixgbe 0000:41:00.1: Intel(R) 10 Gigabit Network Connection
[  155.688547] usb 3-1.3: device descriptor read/64, error -71
[  155.734995] ixgbe 0000:43:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  155.744426] ixgbe 0000:43:00.0: PCI Express bandwidth of 32GT/s available
[  155.751955] ixgbe 0000:43:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  155.760140] ixgbe 0000:43:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  155.766948] ixgbe 0000:43:00.0: 38:ea:a7:8b:21:d8
[  155.816004] ixgbe 0000:43:00.0: Intel(R) 10 Gigabit Network Connection
[  155.868933] usb 3-1.3: new high-speed USB device number 5 using ehci-pci
[  155.936867] ixgbe 0000:43:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  155.946351] ixgbe 0000:43:00.1: PCI Express bandwidth of 32GT/s available
[  155.953827] ixgbe 0000:43:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  155.962053] ixgbe 0000:43:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  155.968860] ixgbe 0000:43:00.1: 38:ea:a7:8b:21:d9
[  156.010586] ixgbe 0000:43:00.1: Intel(R) 10 Gigabit Network Connection
[  156.120877] ixgbe 0000:61:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.130316] ixgbe 0000:61:00.0: PCI Express bandwidth of 32GT/s available
[  156.137792] ixgbe 0000:61:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.145990] ixgbe 0000:61:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  156.152793] ixgbe 0000:61:00.0: 38:ea:a7:91:65:40
[  156.200462] ixgbe 0000:61:00.0: Intel(R) 10 Gigabit Network Connection
[  156.292605] usb 3-1.3: device not accepting address 5, error -71
[  156.313099] ixgbe 0000:61:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.322529] ixgbe 0000:61:00.1: PCI Express bandwidth of 32GT/s available
[  156.330001] ixgbe 0000:61:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.338194] ixgbe 0000:61:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  156.344996] ixgbe 0000:61:00.1: 38:ea:a7:91:65:41
[  156.368865] usb 3-1.3: new high-speed USB device number 6 using ehci-pci
[  156.386559] ixgbe 0000:61:00.1: Intel(R) 10 Gigabit Network Connection
[  156.499673] ixgbe 0000:63:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.509104] ixgbe 0000:63:00.0: PCI Express bandwidth of 32GT/s available
[  156.516577] ixgbe 0000:63:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.524730] ixgbe 0000:63:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  156.531536] ixgbe 0000:63:00.0: 38:ea:a7:8c:df:c4
[  156.581035] ixgbe 0000:63:00.0: Intel(R) 10 Gigabit Network Connection
[  156.712576] ixgbe 0000:63:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.722005] ixgbe 0000:63:00.1: PCI Express bandwidth of 32GT/s available
[  156.729479] ixgbe 0000:63:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.737675] ixgbe 0000:63:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  156.744478] ixgbe 0000:63:00.1: 38:ea:a7:8c:df:c5
[  156.789214] usb 3-1.3: device not accepting address 6, error -71
[  156.793582] ixgbe 0000:63:00.1: Intel(R) 10 Gigabit Network Connection
[  156.803231] usb 3-1-port3: unable to enumerate USB device
[  156.898565] ixgbe 0000:85:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  156.908012] ixgbe 0000:85:00.0: PCI Express bandwidth of 32GT/s available
[  156.915485] ixgbe 0000:85:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  156.923680] ixgbe 0000:85:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[  156.930485] ixgbe 0000:85:00.0: 38:ea:a7:31:7a:30
[  156.977798] ixgbe 0000:85:00.0: Intel(R) 10 Gigabit Network Connection
[  157.090878] ixgbe 0000:85:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.100377] ixgbe 0000:85:00.1: PCI Express bandwidth of 32GT/s available
[  157.107851] ixgbe 0000:85:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.116040] ixgbe 0000:85:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[  157.122844] ixgbe 0000:85:00.1: 38:ea:a7:31:7a:31
[  157.169472] ixgbe 0000:85:00.1: Intel(R) 10 Gigabit Network Connection
[  157.279686] ixgbe 0000:87:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.289113] ixgbe 0000:87:00.0: PCI Express bandwidth of 32GT/s available
[  157.296585] ixgbe 0000:87:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.304775] ixgbe 0000:87:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  157.311580] ixgbe 0000:87:00.0: 38:ea:a7:8b:22:00
[  157.358160] ixgbe 0000:87:00.0: Intel(R) 10 Gigabit Network Connection
[  157.483311] ixgbe 0000:87:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.492733] ixgbe 0000:87:00.1: PCI Express bandwidth of 32GT/s available
[  157.500205] ixgbe 0000:87:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.508398] ixgbe 0000:87:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  157.515202] ixgbe 0000:87:00.1: 38:ea:a7:8b:22:01
[  157.562364] ixgbe 0000:87:00.1: Intel(R) 10 Gigabit Network Connection
[  157.672761] ixgbe 0000:a1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.682205] ixgbe 0000:a1:00.0: PCI Express bandwidth of 32GT/s available
[  157.689680] ixgbe 0000:a1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.697874] ixgbe 0000:a1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  157.704677] ixgbe 0000:a1:00.0: 38:ea:a7:91:65:d8
[  157.750425] ixgbe 0000:a1:00.0: Intel(R) 10 Gigabit Network Connection
[  157.863860] ixgbe 0000:a1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  157.873291] ixgbe 0000:a1:00.1: PCI Express bandwidth of 32GT/s available
[  157.880766] ixgbe 0000:a1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  157.888960] ixgbe 0000:a1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  157.895764] ixgbe 0000:a1:00.1: 38:ea:a7:91:65:d9
[  157.942722] ixgbe 0000:a1:00.1: Intel(R) 10 Gigabit Network Connection
[  158.052183] ixgbe 0000:a3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.061608] ixgbe 0000:a3:00.0: PCI Express bandwidth of 32GT/s available
[  158.069081] ixgbe 0000:a3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.077313] ixgbe 0000:a3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  158.084120] ixgbe 0000:a3:00.0: 38:ea:a7:8b:30:fc
[  158.128718] ixgbe 0000:a3:00.0: Intel(R) 10 Gigabit Network Connection
[  158.253417] ixgbe 0000:a3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.262847] ixgbe 0000:a3:00.1: PCI Express bandwidth of 32GT/s available
[  158.270322] ixgbe 0000:a3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.278510] ixgbe 0000:a3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  158.285315] ixgbe 0000:a3:00.1: 38:ea:a7:8b:30:fd
[  158.327135] ixgbe 0000:a3:00.1: Intel(R) 10 Gigabit Network Connection
[  158.436626] ixgbe 0000:c1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.446067] ixgbe 0000:c1:00.0: PCI Express bandwidth of 32GT/s available
[  158.453542] ixgbe 0000:c1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.461733] ixgbe 0000:c1:00.0: MAC: 2, PHY: 1, PBA No: G33590-012
[  158.468536] ixgbe 0000:c1:00.0: 38:ea:a7:91:1a:54
[  158.515264] ixgbe 0000:c1:00.0: Intel(R) 10 Gigabit Network Connection
[  158.627536] ixgbe 0000:c1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.636958] ixgbe 0000:c1:00.1: PCI Express bandwidth of 32GT/s available
[  158.644432] ixgbe 0000:c1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.652623] ixgbe 0000:c1:00.1: MAC: 2, PHY: 1, PBA No: G33590-012
[  158.659424] ixgbe 0000:c1:00.1: 38:ea:a7:91:1a:55
[  158.707324] ixgbe 0000:c1:00.1: Intel(R) 10 Gigabit Network Connection
[  158.816271] ixgbe 0000:c3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  158.825695] ixgbe 0000:c3:00.0: PCI Express bandwidth of 32GT/s available
[  158.833168] ixgbe 0000:c3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  158.841359] ixgbe 0000:c3:00.0: MAC: 2, PHY: 1, PBA No: G43498-007
[  158.848164] ixgbe 0000:c3:00.0: 38:ea:a7:8c:e6:64
[  158.896073] ixgbe 0000:c3:00.0: Intel(R) 10 Gigabit Network Connection
[  159.034923] ixgbe 0000:c3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.044353] ixgbe 0000:c3:00.1: PCI Express bandwidth of 32GT/s available
[  159.051828] ixgbe 0000:c3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.060021] ixgbe 0000:c3:00.1: MAC: 2, PHY: 1, PBA No: G43498-007
[  159.066826] ixgbe 0000:c3:00.1: 38:ea:a7:8c:e6:65
[  159.115933] ixgbe 0000:c3:00.1: Intel(R) 10 Gigabit Network Connection
[  159.230052] ixgbe 0000:e1:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.239570] ixgbe 0000:e1:00.0: PCI Express bandwidth of 32GT/s available
[  159.247044] ixgbe 0000:e1:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.255235] ixgbe 0000:e1:00.0: MAC: 2, PHY: 1, PBA No: G33590-000
[  159.262039] ixgbe 0000:e1:00.0: 38:ea:a7:31:7e:f8
[  159.308368] ixgbe 0000:e1:00.0: Intel(R) 10 Gigabit Network Connection
[  159.425131] ixgbe 0000:e1:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.434558] ixgbe 0000:e1:00.1: PCI Express bandwidth of 32GT/s available
[  159.442035] ixgbe 0000:e1:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.450229] ixgbe 0000:e1:00.1: MAC: 2, PHY: 1, PBA No: G33590-000
[  159.457032] ixgbe 0000:e1:00.1: 38:ea:a7:31:7e:f9
[  159.507091] ixgbe 0000:e1:00.1: Intel(R) 10 Gigabit Network Connection
[  159.620809] ixgbe 0000:e3:00.0: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.630243] ixgbe 0000:e3:00.0: PCI Express bandwidth of 32GT/s available
[  159.637720] ixgbe 0000:e3:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.645914] ixgbe 0000:e3:00.0: MAC: 2, PHY: 1, PBA No: G43498-000
[  159.652838] ixgbe 0000:e3:00.0: 38:ea:a7:8b:27:f4
[  159.703507] ixgbe 0000:e3:00.0: Intel(R) 10 Gigabit Network Connection
[  159.831949] ixgbe 0000:e3:00.1: Multiqueue Enabled: Rx Queue count = 63, Tx Queue count = 63
[  159.841382] ixgbe 0000:e3:00.1: PCI Express bandwidth of 32GT/s available
[  159.848855] ixgbe 0000:e3:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[  159.857044] ixgbe 0000:e3:00.1: MAC: 2, PHY: 1, PBA No: G43498-000
[  159.863847] ixgbe 0000:e3:00.1: 38:ea:a7:8b:27:f5
[  159.881138] ixgbe 0000:e3:00.1: Intel(R) 10 Gigabit Network Connection
[  161.869921] iTCO_vendor_support: vendor-support=0
[  161.920132] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[  161.926647] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[  162.411896] BTRFS: device fsid 7a5749b3-f733-4f1a-b0f7-1b89677ced55 devid 1 transid 1217 /dev/dm-9
[  162.456538] BTRFS: device fsid 078e55c8-0f7f-4dfd-bab3-0e10cc542cac devid 1 transid 19460 /dev/dm-20
[  164.994796] Adding 8385532k swap on /dev/mapper/3600c0ff0001a841e1d12f65401000000_part2.  Priority:-1 extents:1 across:8385532k 
[  165.630496] multipathd (43402): /proc/43402/oom_adj is deprecated, please use /proc/43402/oom_score_adj instead.
[  167.623061] loop: module loaded
[  170.066721] fuse init (API version 7.23)
[  172.222046] audit: type=1400 audit(1429202458.133:2): apparmor="STATUS" operation="profile_load" name="/bin/ping" pid=44530 comm="apparmor_parser"
[  172.278320] audit: type=1400 audit(1429202458.189:3): apparmor="STATUS" operation="profile_load" name="/sbin/klogd" pid=44535 comm="apparmor_parser"
[  172.350942] audit: type=1400 audit(1429202458.261:4): apparmor="STATUS" operation="profile_load" name="/sbin/syslog-ng" pid=44539 comm="apparmor_parser"
[  172.420686] audit: type=1400 audit(1429202458.333:5): apparmor="STATUS" operation="profile_load" name="/sbin/syslogd" pid=44543 comm="apparmor_parser"
[  172.468009] audit: type=1400 audit(1429202458.377:6): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-explicit-grant-helper" pid=44548 comm="apparmor_parser"
[  172.541254] audit: type=1400 audit(1429202458.453:7): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-grant-helper" pid=44552 comm="apparmor_parser"
[  172.612397] audit: type=1400 audit(1429202458.521:8): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-grant-helper-pam" pid=44556 comm="apparmor_parser"
[  172.684800] audit: type=1400 audit(1429202458.593:9): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-read-auth-helper" pid=44560 comm="apparmor_parser"
[  172.733105] audit: type=1400 audit(1429202458.645:10): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-resolve-exe-helper" pid=44564 comm="apparmor_parser"
[  172.784774] audit: type=1400 audit(1429202458.693:11): apparmor="STATUS" operation="profile_load" name="/usr/lib/PolicyKit/polkit-revoke-helper" pid=44568 comm="apparmor_parser"
[  184.483996] NET: Registered protocol family 17
[  184.769159] ixgbe 0000:01:00.0: registered PHC device on eth0
[  184.772218] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: None
[  198.833935] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[  198.833942] EDD information not available.
[  204.710514] mgag200 0000:07:00.1: Invalid ROM contents

--------------000903060906050605050501--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
