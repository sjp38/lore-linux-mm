Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2CE66B038A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 12:02:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g70so61572061lfh.4
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:02:59 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id u139si7748841lff.291.2017.03.19.09.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 09:02:57 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
 <20170319151837.GD12414@dhcp22.suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
Date: Sun, 19 Mar 2017 17:02:44 +0100
MIME-Version: 1.0
In-Reply-To: <20170319151837.GD12414@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 19.03.2017 16:18, Michal Hocko wrote:
> On Fri 17-03-17 21:08:31, Gerhard Wiesinger wrote:
>> On 17.03.2017 18:13, Michal Hocko wrote:
>>> On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
>>> [...]
>>>> Why does the kernel prefer to swapin/out and not use
>>>>
>>>> a.) the free memory?
>>> It will use all the free memory up to min watermark which is set up
>>> based on min_free_kbytes.
>> Makes sense, how is /proc/sys/vm/min_free_kbytes default value calculated?
> See init_per_zone_wmark_min
>
>>>> b.) the buffer/cache?
>>> the memory reclaim is strongly biased towards page cache and we try to
>>> avoid swapout as much as possible (see get_scan_count).
>> If I understand it correctly, swapping is preferred over dropping the
>> cache, right. Can this behaviour be changed to prefer dropping the
>> cache to some minimum amount?  Is this also configurable in a way?
> No, we enforce swapping if the amount of free + file pages are below the
> cumulative high watermark.
>
>> (As far as I remember e.g. kernel 2.4 dropped the caches well).
>>
>>>> There is ~100M memory available but kernel swaps all the time ...
>>>>
>>>> Any ideas?
>>>>
>>>> Kernel: 4.9.14-200.fc25.x86_64
>>>>
>>>> top - 17:33:43 up 28 min,  3 users,  load average: 3.58, 1.67, 0.89
>>>> Tasks: 145 total,   4 running, 141 sleeping,   0 stopped,   0 zombie
>>>> %Cpu(s): 19.1 us, 56.2 sy,  0.0 ni,  4.3 id, 13.4 wa, 2.0 hi,  0.3 si,  4.7
>>>> st
>>>> KiB Mem :   230076 total,    61508 free,   123472 used,    45096 buff/cache
>>>>
>>>> procs -----------memory---------- ---swap-- -----io---- -system--
>>>> ------cpu-----
>>>>   r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy id wa st
>>>>   3  5 303916  60372    328  43864 27828  200 41420   236 6984 11138 11 47  6 23 14
>>> I am really surprised to see any reclaim at all. 26% of free memory
>>> doesn't sound as if we should do a reclaim at all. Do you have an
>>> unusual configuration of /proc/sys/vm/min_free_kbytes ? Or is there
>>> anything running inside a memory cgroup with a small limit?
>> nothing special set regarding /proc/sys/vm/min_free_kbytes (default values),
>> detailed config below. Regarding cgroups, none of I know. How to check (I
>> guess nothing is set because cg* commands are not available)?
> be careful because systemd started to use some controllers. You can
> easily check cgroup mount points.

See below.

>
>> /proc/sys/vm/min_free_kbytes
>> 45056
> So at least 45M will be kept reserved for the system. Your data
> indicated you had more memory. How does /proc/zoneinfo look like?
> Btw. you seem to be using fc kernel, are there any patches applied on
> top of Linus tree? Could you try to retest vanilla kernel?


System looks normally now, FYI (e.g. now permanent swapping)


free
               total        used        free      shared buff/cache   
available
Mem:         349076      154112       41560         184 153404      148716
Swap:       2064380      831844     1232536

cat /proc/zoneinfo

Node 0, zone      DMA
   per-node stats
       nr_inactive_anon 9543
       nr_active_anon 22105
       nr_inactive_file 9877
       nr_active_file 13416
       nr_unevictable 0
       nr_isolated_anon 0
       nr_isolated_file 0
       nr_pages_scanned 0
       workingset_refault 1926013
       workingset_activate 707166
       workingset_nodereclaim 187276
       nr_anon_pages 11429
       nr_mapped    6852
       nr_file_pages 46772
       nr_dirty     1
       nr_writeback 0
       nr_writeback_temp 0
       nr_shmem     46
       nr_shmem_hugepages 0
       nr_shmem_pmdmapped 0
       nr_anon_transparent_hugepages 0
       nr_unstable  0
       nr_vmscan_write 3319047
       nr_vmscan_immediate_reclaim 32363
       nr_dirtied   222115
       nr_written   3537529
   pages free     3110
         min      27
         low      33
         high     39
    node_scanned  0
         spanned  4095
         present  3998
         managed  3977
       nr_free_pages 3110
       nr_zone_inactive_anon 18
       nr_zone_active_anon 3
       nr_zone_inactive_file 51
       nr_zone_active_file 75
       nr_zone_unevictable 0
       nr_zone_write_pending 0
       nr_mlock     0
       nr_slab_reclaimable 214
       nr_slab_unreclaimable 289
       nr_page_table_pages 185
       nr_kernel_stack 16
       nr_bounce    0
       nr_zspages   0
       numa_hit     1214071
       numa_miss    0
       numa_foreign 0
       numa_interleave 0
       numa_local   1214071
       numa_other   0
       nr_free_cma  0
         protection: (0, 306, 306, 306, 306)
   pagesets
     cpu: 0
               count: 0
               high:  0
               batch: 1
   vm stats threshold: 4
     cpu: 1
               count: 0
               high:  0
               batch: 1
   vm stats threshold: 4
   node_unreclaimable:  0
   start_pfn:           1
   node_inactive_ratio: 0
Node 0, zone    DMA32
   pages free     7921
         min      546
         low      682
         high     818
    node_scanned  0
         spanned  94172
         present  94172
         managed  83292
       nr_free_pages 7921
       nr_zone_inactive_anon 9525
       nr_zone_active_anon 22102
       nr_zone_inactive_file 9826
       nr_zone_active_file 13341
       nr_zone_unevictable 0
       nr_zone_write_pending 1
       nr_mlock     0
       nr_slab_reclaimable 5829
       nr_slab_unreclaimable 8622
       nr_page_table_pages 2638
       nr_kernel_stack 2208
       nr_bounce    0
       nr_zspages   0
       numa_hit     23125334
       numa_miss    0
       numa_foreign 0
       numa_interleave 14307
       numa_local   23125334
       numa_other   0
       nr_free_cma  0
         protection: (0, 0, 0, 0, 0)
   pagesets
     cpu: 0
               count: 17
               high:  90
               batch: 15
   vm stats threshold: 12
     cpu: 1
               count: 55
               high:  90
               batch: 15
   vm stats threshold: 12
   node_unreclaimable:  0
   start_pfn:           4096
   node_inactive_ratio: 0

mount | grep cgroup
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup 
(rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/blkio type cgroup 
(rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup 
(rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/cpuset type cgroup 
(rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup 
(rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/hugetlb type cgroup 
(rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/pids type cgroup 
(rw,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/memory type cgroup 
(rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/perf_event type cgroup 
(rw,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/devices type cgroup 
(rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup 
(rw,nosuid,nodev,noexec,relatime,freezer)

There are patches (see below), but as far as I saw nothing regarding the 
issues which happen.


BTW: Does it make sense to reduce lower limit for low mem VMs? e.g.

echo "10000" > /proc/sys/vm/min_free_kbytes


Thnx.

Ciao,

Gerhard

https://koji.fedoraproject.org/koji/buildinfo?buildID=870215

## Patches needed for building this package

# build tweak for build ID magic, even for -vanilla
Patch001: kbuild-AFTER_LINK.patch

## compile fixes

# ongoing complaint, full discussion delayed until ksummit/plumbers
Patch002: 0001-iio-Use-event-header-from-kernel-tree.patch

%if !%{nopatches}

# Git trees.

# Standalone patches

# a tempory patch for QCOM hardware enablement. Will be gone by end of 
2016/F-26 GA
Patch420: qcom-QDF2432-tmp-errata.patch

# http://www.spinics.net/lists/arm-kernel/msg490981.html
Patch421: geekbox-v4-device-tree-support.patch

# http://www.spinics.net/lists/linux-tegra/msg26029.html
Patch422: usb-phy-tegra-Add-38.4MHz-clock-table-entry.patch

# Fix OMAP4 (pandaboard)
Patch423: arm-revert-mmc-omap_hsmmc-Use-dma_request_chan-for-reque.patch

# Not particularly happy we don't yet have a proper upstream resolution 
this is the right direction
# https://www.spinics.net/lists/arm-kernel/msg535191.html
Patch424: arm64-mm-Fix-memmap-to-be-initialized-for-the-entire-section.patch

# http://patchwork.ozlabs.org/patch/587554/
Patch425: ARM-tegra-usb-no-reset.patch

Patch426: AllWinner-net-emac.patch

# http://www.spinics.net/lists/devicetree/msg163238.html
Patch430: bcm2837-initial-support.patch

# http://www.spinics.net/lists/dri-devel/msg132235.html
Patch433: 
drm-vc4-Fix-OOPSes-from-trying-to-cache-a-partially-constructed-BO..patch

# bcm283x mmc for wifi 
http://www.spinics.net/lists/arm-kernel/msg567077.html
Patch434: bcm283x-mmc-bcm2835.patch

# Upstream fixes for i2c/serial/ethernet MAC addresses
Patch435: bcm283x-fixes.patch

# https://lists.freedesktop.org/archives/dri-devel/2017-February/133823.html
Patch436: vc4-fix-vblank-cursor-update-issue.patch

# http://www.spinics.net/lists/arm-kernel/msg552554.html
Patch438: arm-imx6-hummingboard2.patch

Patch460: lib-cpumask-Make-CPUMASK_OFFSTACK-usable-without-deb.patch

Patch466: input-kill-stupid-messages.patch

Patch467: die-floppy-die.patch

Patch468: no-pcspkr-modalias.patch

Patch470: silence-fbcon-logo.patch

Patch471: Kbuild-Add-an-option-to-enable-GCC-VTA.patch

Patch472: crash-driver.patch

Patch473: efi-lockdown.patch

Patch487: Add-EFI-signature-data-types.patch

Patch488: Add-an-EFI-signature-blob-parser-and-key-loader.patch

# This doesn't apply. It seems like it could be replaced by
# 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5ac7eace2d00eab5ae0e9fdee63e38aee6001f7c
# which has an explicit line about blacklisting
Patch489: KEYS-Add-a-system-blacklist-keyring.patch

Patch490: MODSIGN-Import-certificates-from-UEFI-Secure-Boot.patch

Patch491: MODSIGN-Support-not-importing-certs-from-db.patch

Patch493: drm-i915-hush-check-crtc-state.patch

Patch494: disable-i8042-check-on-apple-mac.patch

Patch495: lis3-improve-handling-of-null-rate.patch

Patch497: scsi-sd_revalidate_disk-prevent-NULL-ptr-deref.patch

Patch498: criu-no-expert.patch

Patch499: ath9k-rx-dma-stop-check.patch

Patch500: xen-pciback-Don-t-disable-PCI_COMMAND-on-PCI-device-.patch

Patch501: Input-synaptics-pin-3-touches-when-the-firmware-repo.patch

Patch502: firmware-Drop-WARN-from-usermodehelper_read_trylock-.patch

# Patch503: drm-i915-turn-off-wc-mmaps.patch

Patch509: MODSIGN-Don-t-try-secure-boot-if-EFI-runtime-is-disa.patch

#CVE-2016-3134 rhbz 1317383 1317384
Patch665: netfilter-x_tables-deal-with-bogus-nextoffset-values.patch

# grabbed from mailing list
Patch667: 
v3-Revert-tty-serial-pl011-add-ttyAMA-for-matching-pl011-console.patch

# END OF PATCH DEFINITIONS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
