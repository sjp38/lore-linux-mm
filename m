Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 63C146B0036
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 06:26:01 -0400 (EDT)
Date: Thu, 13 Jun 2013 18:25:49 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [iput] BUG: Bad page state in process rm pfn:0b0ce
Message-ID: <20130613102549.GD31394@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg in linux-next and the first bad commit is

commit eeb9bfc39ed70ee5c389d6c9be555588e1284e62
Author: Mel Gorman <mgorman@suse.de>
Date:   Thu Jun 6 10:40:03 2013 +1000

    mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru
    
    Similar to __pagevec_lru_add, this patch removes the LRU parameter from
    __lru_cache_add and lru_cache_add_lru as the caller does not control the
    exact LRU the page gets added to.  lru_cache_add_lru gets renamed to
    lru_cache_add the name is silly without the lru parameter.  With the
    parameter removed, it is required that the caller indicate if they want
    the page added to the active or inactive list by setting or clearing
    PageActive respectively.
    
    [akpm@linux-foundation.org: Suggested the patch]
    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Cc: Jan Kara <jack@suse.cz>
    Cc: Rik van Riel <riel@redhat.com>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>
    Cc: Andrew Perepechko <anserper@ya.ru>
    Cc: Robin Dong <sanbai@taobao.com>
    Cc: Theodore Tso <tytso@mit.edu>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: Bernd Schubert <bernd.schubert@fastmail.fm>
    Cc: David Howells <dhowells@redhat.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This shows up reliably in every boot:

[   70.190744] Out of memory: Kill process 197 (trinity-child1) score 52 or sacrifice child
[   70.192202] Killed process 197 (trinity-child1) total-vm:21528kB, anon-rss:7672kB, file-rss:524kB
 * Asking all remaining processes to terminate...       
killall5[225]: mount returned non-zero exit status
killall5[225]: /proc not mounted, failed to mount.

mount: proc has wrong device number or fs type proc not supported
killall5[233]: mount returned non-zero exit status
killall5[233]: /proc not mounted, failed to mount.
 * All processes ended within 1 seconds....       
/etc/rc6.d/S40umountfs: line 20: /proc/mounts: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
umount: /var/run: not mounted
[   84.212960] BUG: Bad page state in process rm  pfn:0b0c9
[   84.214682] page:ffff88000d646240 count:0 mapcount:0 mapping:          (null) index:0x0
[   84.216883] page flags: 0x20000000004c(referenced|uptodate|active)
[   84.218697] CPU: 1 PID: 283 Comm: rm Not tainted 3.10.0-rc4-04361-geeb9bfc #49
[   84.220729]  ffff88000d646240 ffff88000d179bb8 ffffffff82562956 ffff88000d179bd8
[   84.223242]  ffffffff811333f1 000020000000004c ffff88000d646240 ffff88000d179c28
[   84.225387]  ffffffff811346a4 ffff880000270000 0000000000000000 0000000000000006
[   84.227294] Call Trace:
[   84.227867]  [<ffffffff82562956>] dump_stack+0x27/0x30
[   84.229045]  [<ffffffff811333f1>] bad_page+0x130/0x158
[   84.230261]  [<ffffffff811346a4>] free_pages_prepare+0x8b/0x1e3
[   84.231765]  [<ffffffff8113542a>] free_hot_cold_page+0x28/0x1cf
[   84.233171]  [<ffffffff82585830>] ? _raw_spin_unlock_irqrestore+0x6b/0xc6
[   84.234822]  [<ffffffff81135b59>] free_hot_cold_page_list+0x30/0x5a
[   84.236311]  [<ffffffff8113a4ed>] release_pages+0x251/0x267
[   84.237653]  [<ffffffff8112a88d>] ? delete_from_page_cache+0x48/0x9e
[   84.239142]  [<ffffffff8113ad93>] __pagevec_release+0x2b/0x3d
[   84.240473]  [<ffffffff8113b45a>] truncate_inode_pages_range+0x1b0/0x7ce
[   84.242032]  [<ffffffff810e76ab>] ? put_lock_stats.isra.20+0x1c/0x53
[   84.243480]  [<ffffffff810e77f5>] ? lock_release_holdtime+0x113/0x11f
[   84.244935]  [<ffffffff8113ba8c>] truncate_inode_pages+0x14/0x1d
[   84.246337]  [<ffffffff8119b3ef>] evict+0x11f/0x232
[   84.247501]  [<ffffffff8119c527>] iput+0x1a5/0x218
[   84.248607]  [<ffffffff8118f015>] do_unlinkat+0x19b/0x25a
[   84.249828]  [<ffffffff810ea993>] ? trace_hardirqs_on_caller+0x210/0x2ce
[   84.251382]  [<ffffffff8144372e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   84.252879]  [<ffffffff8118f10d>] SyS_unlinkat+0x39/0x4c
[   84.254174]  [<ffffffff825874d6>] system_call_fastpath+0x1a/0x1f
[   84.255596] Disabling lock debugging due to kernel taint


git bisect start 1f6587114a689a5d7fdfb0d4abc818117e3182a5 v3.9 --
git bisect good 9992ba72327fa0d8bdc9fb624e80f5cce338a711  # 11:22     30+  Merge tag 'sound-3.10' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect good 165b199f615ff5cbbd2a241526673d8643bedc30  # 11:38     30+  Merge remote-tracking branch 'asoc/topic/sn95031' into asoc-next
git bisect good a9ee2e0f380766c3edaa0c00513a2a3771472322  # 11:52     30+  Merge remote-tracking branch 'watchdog/master'
git bisect good bfc5068e4692d31dc4d17b1e290ca67fe6c331e8  # 12:15     30+  Merge remote-tracking branch 'mailbox/dbx500-prcmu-mailbox'
git bisect good 66cb7925f318acb04983ffc13faed70edacf7709  # 12:39     30+  Merge remote-tracking branch 'samsung/for-next'
git bisect  bad 1051b6d30fb5ad5fe0db180edccf86c2bc9f04a6  # 12:46      0-  mm/tile: prepare for removing num_physpages and simplify mem_init()
git bisect good 351c52b20c1545f39e578dc38ecde2c5068c2dc6  # 12:57     30+  drivers/scsi/dmx3191d.c: convert to module_pci_driver
git bisect good 35f49632f32139ddf803dcb35173898e8fb2f8d8  # 13:20     30+  vmcore-allow-user-process-to-remap-elf-note-segment-buffer-fix
git bisect  bad 47856ff3aa81669131eaae77bfdc11d74de82d68  # 13:30      0-  mm: report available pages as "MemTotal" for each NUMA node
git bisect  bad e923a66867a8b39da16382f81547193046d2fc6f  # 13:37      0-  mm/hugetlb: remove hugetlb_prefault
git bisect  bad eeb9bfc39ed70ee5c389d6c9be555588e1284e62  # 13:44      0-  mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru
git bisect good 0436c4fab7d0f5441fe7307f52801a573ba61f4a  # 13:53     30+  memcg: update TODO list in Documentation
git bisect good f8d52137ba38f8a2770dea83a25a642efa2d0beb  # 14:03     30+  mm: pagevec: defer deciding which LRU to add a page to until pagevec drain time
git bisect good ebf2ee3010dedb4177eee18e01be00b5a7b0bc24  # 14:14     30+  mm: remove lru parameter from __pagevec_lru_add and remove parts of pagevec API
git bisect good ebf2ee3010dedb4177eee18e01be00b5a7b0bc24  # 14:37     90+  mm: remove lru parameter from __pagevec_lru_add and remove parts of pagevec API
git bisect  bad 5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96  # 14:37      0-  INFO: suspicious RCU usage.
git bisect good ca47554a03c18011f31a5566878d072793c049ab  # 15:06     90+  Revert "mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
git bisect good 26e04462c8b78d079d3231396ec72d58a14f114b  # 15:45     90+  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect  bad c04efed734409f5a44715b54a6ca1b54b0ccf215  # 15:53      0-  Add linux-next specific files for 20130607

Thanks,
Fengguang

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-kbuild-29587-20130612221718-3.10.0-rc4-04726-g5e81a2f-17"

[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.10.0-rc4-04726-g5e81a2f (kbuild@athens) (gcc version 4.7.2 (Debian 4.7.2-4) ) #17 SMP PREEMPT Wed Jun 12 22:20:58 CST 2013
[    0.000000] Command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day/.vmlinuz-5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96-20130612222221-9-kbuild branch=wfg/0day  BOOT_IMAGE=/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/vmlinuz-3.10.0-rc4-04726-g5e81a2f
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x04f4f000, 0x04f4ffff] PGTABLE
[    0.000000] BRK [0x04f50000, 0x04f50fff] PGTABLE
[    0.000000] BRK [0x04f51000, 0x04f51fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0e600000-0x0e7fffff]
[    0.000000]  [mem 0x0e600000-0x0e7fffff] page 4k
[    0.000000] BRK [0x04f52000, 0x04f52fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0e5fffff]
[    0.000000]  [mem 0x0c000000-0x0e5fffff] page 4k
[    0.000000] BRK [0x04f53000, 0x04f53fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x0bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e800000-0x0fffdfff]
[    0.000000]  [mem 0x0e800000-0x0fffdfff] page 4k
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127628(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65424
[    0.000000]   DMA32 zone: 1024 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 65424 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:4096 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 472 pages/cpu @ffff88000da00000 s1909440 r0 d23872 u2097152
[    0.000000] pcpu-alloc: s1909440 r0 d23872 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64379
[    0.000000] Kernel command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day/.vmlinuz-5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96-20130612222221-9-kbuild branch=wfg/0day  BOOT_IMAGE=/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/vmlinuz-3.10.0-rc4-04726-g5e81a2f
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 155776K/261696K available (22066K kernel code, 7695K rwdata, 12272K rodata, 2920K init, 19712K bss, 105920K reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 
[    0.000000] NR_IRQS:262400 nr_irqs:512 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2693.582 MHz processor
[    0.006669] Calibrating delay loop (skipped), value calculated using timer frequency.. 5389.62 BogoMIPS (lpj=8978606)
[    0.008735] pid_max: default: 32768 minimum: 301
[    0.010141] Mount-cache hash table entries: 256
[    0.011588] Initializing cgroup subsys debug
[    0.013349] Initializing cgroup subsys devices
[    0.014267] Initializing cgroup subsys blkio
[    0.015113] Initializing cgroup subsys net_prio
[    0.016013] Initializing cgroup subsys hugetlb
[    0.016762] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.016762] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.016762] tlb_flushall_shift: 6
[    0.019498] debug: unmapping init [mem 0xffffffff83c04000-0xffffffff83c0efff]
[    0.020048] ACPI: Core revision 20130418
[    0.024888] ACPI: All ACPI Tables successfully acquired
[    0.026162] Getting VERSION: 50014
[    0.026680] Getting VERSION: 50014
[    0.027353] Getting ID: 0
[    0.027893] Getting ID: ff000000
[    0.028542] Getting LVT0: 8700
[    0.029139] Getting LVT1: 8400
[    0.030060] enabled ExtINT on CPU#0
[    0.031679] ENABLING IO-APIC IRQs
[    0.032341] init IO_APIC IRQs
[    0.032945]  apic 2 pin 0 not connected
[    0.033358] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.034925] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.036696] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.038289] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.040027] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.041595] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.043360] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.044938] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.046693] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.048252] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.050026] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.051612] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.053360] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.054967] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.056547] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.056689]  apic 2 pin 16 not connected
[    0.057445]  apic 2 pin 17 not connected
[    0.058195]  apic 2 pin 18 not connected
[    0.060005]  apic 2 pin 19 not connected
[    0.060762]  apic 2 pin 20 not connected
[    0.061513]  apic 2 pin 21 not connected
[    0.062264]  apic 2 pin 22 not connected
[    0.063339]  apic 2 pin 23 not connected
[    0.064278] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.099149] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 06, stepping: 01)
[    0.101317] Using local APIC timer interrupts.
[    0.101317] calibrating APIC timer ...
[    0.106666] ... lapic delta = 6249846
[    0.106666] ... PM-Timer delta = 357944
[    0.106666] ... PM-Timer result ok
[    0.106666] ..... delta 6249846
[    0.106666] ..... mult: 268428868
[    0.106666] ..... calibration result: 3333251
[    0.106666] ..... CPU clock speed is 2693.2405 MHz.
[    0.106666] ..... host bus clock speed is 1000.0251 MHz.
[    0.106743] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.130104] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.136945] SMP alternatives: lockdep: fixing up alternatives
[    0.138354] smpboot: Booting Node   0, Processors  #1 OK
[    0.009999] masked ExtINT on CPU#1
[    0.240145] Brought up 2 CPUs
[    0.240742] ----------------
[    0.241283] | NMI testsuite:
[    0.241831] --------------------
[    0.242431]   remote IPI:  ok  |
[    0.250235]    local IPI:  ok  |
[    0.270018] --------------------
[    0.270669] Good, all   2 testcases passed! |
[    0.271477] ---------------------------------
[    0.272290] smpboot: Total of 2 processors activated (10778.30 BogoMIPS)
[    0.274834] devtmpfs: initialized
[    0.279754] xor: measuring software checksum speed
[    0.313337]    prefetch64-sse: 10989.600 MB/sec
[    0.346670]    generic_sse:  9271.200 MB/sec
[    0.347470] xor: using function: prefetch64-sse (10989.600 MB/sec)
[    0.349039] regulator-dummy: no parameters
[    0.350065] NET: Registered protocol family 16
[    0.381067] ACPI: bus type PCI registered
[    0.381901] PCI: Using configuration type 1 for base access
[    0.408506] bio: create slab <bio-0> at 0
[    0.463355] raid6: sse2x1    3616 MB/s
[    0.520019] raid6: sse2x2    4012 MB/s
[    0.576684] raid6: sse2x4    4264 MB/s
[    0.577417] raid6: using algorithm sse2x4 (4264 MB/s)
[    0.578363] raid6: using intx1 recovery algorithm
[    0.579512] ACPI: Added _OSI(Module Device)
[    0.580007] ACPI: Added _OSI(Processor Device)
[    0.580846] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.581721] ACPI: Added _OSI(Processor Aggregator Device)
[    0.585619] ACPI: EC: Look up EC in DSDT
[    0.592421] ACPI: Interpreter enabled
[    0.593150] ACPI: (supports S0 S5)
[    0.593338] ACPI: Using IOAPIC for interrupt routing
[    0.594294] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.609440] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.610223] PCI host bridge to bus 0000:00
[    0.611003] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.612021] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.613339] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.614479] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.615746] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfebfffff]
[    0.616749] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.618735] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.620767] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.624388] pci 0000:00:01.1: reg 0x20: [io  0xc1e0-0xc1ef]
[    0.626622] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.627218] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.628572] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.630343] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.636739] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.639114] pci 0000:00:02.0: reg 0x14: [mem 0xfebe0000-0xfebe0fff]
[    0.645385] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    0.647526] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.649353] pci 0000:00:03.0: reg 0x10: [io  0xc1c0-0xc1df]
[    0.650623] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    0.655513] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    0.657191] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.658993] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.660636] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.665168] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    0.666834] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.668708] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    0.670344] pci 0000:00:05.0: reg 0x14: [mem 0xfebe2000-0xfebe2fff]
[    0.675217] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.677011] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.678713] pci 0000:00:06.0: reg 0x14: [mem 0xfebe3000-0xfebe3fff]
[    0.684001] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.685841] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.687311] pci 0000:00:07.0: reg 0x14: [mem 0xfebe4000-0xfebe4fff]
[    0.692469] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.694046] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    0.695721] pci 0000:00:08.0: reg 0x14: [mem 0xfebe5000-0xfebe5fff]
[    0.701101] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.703827] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    0.705659] pci 0000:00:09.0: reg 0x14: [mem 0xfebe6000-0xfebe6fff]
[    0.710591] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.712430] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.713980] pci 0000:00:0a.0: reg 0x14: [mem 0xfebe7000-0xfebe7fff]
[    0.719187] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.720391] pci 0000:00:0b.0: reg 0x10: [mem 0xfebe8000-0xfebe800f]
[    0.724586] pci_bus 0000:00: on NUMA node 0
[    0.725394] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.726678] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.730360] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.732413] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.733923] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.735336] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.737017] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.739278] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.740016] ACPI: \_SB_.PCI0: notify handler is installed
[    0.741172] Found 1 acpi root devices
[    0.743651] ACPI: No dock devices found.
[    0.745640] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.746680] vgaarb: loaded
[    0.747196] vgaarb: bridge control possible 0000:00:02.0
[    0.749329] SCSI subsystem initialized
[    0.750309] libata version 3.00 loaded.
[    0.751129] ACPI: bus type USB registered
[    0.751952] usbcore: registered new interface driver usbfs
[    0.753376] usbcore: registered new interface driver hub
[    0.754599] usbcore: registered new device driver usb
[    0.755849] pps_core: LinuxPPS API ver. 1 registered
[    0.756672] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.758395] PTP clock support registered
[    0.759502] EDAC MC: Ver: 3.0.0
[    0.760484] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.761933] wmi: Mapper loaded
[    0.762636] Advanced Linux Sound Architecture Driver Initialized.
[    0.763369] PCI: Using ACPI for IRQ routing
[    0.764194] PCI: pci_cache_line_size set to 64 bytes
[    0.765457] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.766682] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.768553] Bluetooth: Core ver 2.16
[    0.770042] NET: Registered protocol family 31
[    0.770879] Bluetooth: HCI device and connection manager initialized
[    0.772080] Bluetooth: HCI socket layer initialized
[    0.773148] Bluetooth: L2CAP socket layer initialized
[    0.773387] Bluetooth: SCO socket layer initialized
[    0.774604] nfc: nfc_init: NFC Core ver 0.1
[    0.775825] NET: Registered protocol family 39
[    0.778082] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.781579] Switching to clocksource hpet
[    0.782803] FS-Cache: Loaded
[    0.783333] CacheFiles: Loaded
[    0.783333] pnp: PnP ACPI init
[    0.783333] ACPI: bus type PNP registered
[    0.783403] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    0.785033] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.786374] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    0.788037] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.789350] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    0.791090] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.792393] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    0.794010] pnp 00:03: [dma 2]
[    0.794664] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.796043] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    0.797715] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.799067] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    0.800726] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.802443] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.804116] pnp: PnP ACPI: found 7 devices
[    0.804886] ACPI: bus type PNP unregistered
[    0.812516] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.813665] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.814699] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.815857] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfebfffff]
[    0.817172] NET: Registered protocol family 1
[    0.818017] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.819126] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.820316] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.821493] pci 0000:00:02.0: Boot video device
[    0.822467] PCI: CLS 0 bytes, default 64
[    0.823635] Trying to unpack rootfs image as initramfs...
[    1.719865] debug: unmapping init [mem 0xffff88000e8d6000-0xffff88000ffeffff]
[    1.750766] DMA-API: preallocated 65536 debug entries
[    1.751712] DMA-API: debugging enabled by kernel config
[    1.755286] camellia-x86_64: performance on this CPU would be suboptimal: disabling camellia-x86_64.
[    1.755305] cryptomgr_test (35) used greatest stack depth: 6072 bytes left
[    1.758291] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    1.760472] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    1.763924] cryptomgr_probe (43) used greatest stack depth: 5800 bytes left
[    1.765594] cryptomgr_test (42) used greatest stack depth: 5272 bytes left
[    1.766205] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.766206] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.766209] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.766210] AVX or AES-NI instructions are not detected.
[    1.766210] AVX instructions are not detected.
[    1.766211] AVX instructions are not detected.
[    1.766211] AVX instructions are not detected.
[    1.766212] AVX2 or AES-NI instructions are not detected.
[    1.767720] Initializing RT-Tester: OK
[    1.767725] audit: initializing netlink socket (disabled)
[    1.767785] type=2000 audit(1371046551.763:1): initialized
[    1.768374] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.772405] JFS: nTxBlock = 1217, nTxLock = 9736
[    1.774903] NILFS version 2 loaded
[    1.775374] bio: create slab <bio-1> at 1
[    1.783173] Running btrfs free space cache tests
[    1.784156] Running extent only tests
[    1.784886] Running bitmap only tests
[    1.785611] Running bitmap and extent tests
[    1.786427] Free space cache tests finished
[    1.787319] Btrfs loaded
[    1.789046] GFS2 installed
[    1.789580] msgmni has been set to 304
[    1.804827] alg: No test for crc32 (crc32-table)
[    1.807164] alg: No test for stdrng (krng)
[    1.808766] NET: Registered protocol family 38
[    1.809676] Key type asymmetric registered
[    1.810688] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.812341] io scheduler noop registered
[    1.813102] io scheduler deadline registered
[    1.814149] io scheduler cfq registered (default)
[    1.815033] test_string_helpers: Running tests...
[    1.816813] nvidiafb_setup START
[    1.817789] vmlfb: initializing
[    1.818429] Could not find Carillo Ranch MCH device.
[    1.819414] no IO addresses supplied
[    1.820421] hgafb: HGA card not detected.
[    1.821188] hgafb: probe of hgafb.0 failed with error -22
[    1.822831] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM (4096 kB) at 0xfc000000
[    1.825061] usbcore: registered new interface driver udlfb
[    1.826119] usbcore: registered new interface driver smscufx
[    1.828154] uvesafb: failed to execute /sbin/v86d
[    1.829037] uvesafb: make sure that the v86d helper is installed and executable
[    1.830485] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    1.831716] uvesafb: vbe_init() failed with -22
[    1.832560] uvesafb: probe of uvesafb.0 failed with error -22
[    1.834104] ipmi message handler version 39.2
[    1.834948] IPMI System Interface driver.
[    1.835768] ipmi_si: Adding default-specified kcs state machine
[    1.836994] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    1.838828] ipmi_si: Interface detection failed
[    1.846794] ipmi_si: Adding default-specified smic state machine
[    1.847965] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    1.849807] ipmi_si: Interface detection failed
[    1.863438] ipmi_si: Adding default-specified bt state machine
[    1.864571] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    1.866392] ipmi_si: Interface detection failed
[    1.880211] ipmi_si: Unable to find any System Interface(s)
[    1.881309] IPMI Watchdog: driver initialized
[    1.882121] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    1.883840] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.885231] ACPI: Power Button [PWRF]
[    1.887602] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.888705] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[    1.890398] virtio-pci 0000:00:03.0: setting latency timer to 64
[    1.892785] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    1.893945] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[    1.895476] virtio-pci 0000:00:05.0: setting latency timer to 64
[    1.898092] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    1.899195] virtio-pci 0000:00:06.0: setting latency timer to 64
[    1.901542] virtio-pci 0000:00:07.0: setting latency timer to 64
[    1.904084] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    1.905183] virtio-pci 0000:00:08.0: setting latency timer to 64
[    1.907513] virtio-pci 0000:00:09.0: setting latency timer to 64
[    1.909784] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    1.991421] HDLC line discipline maxframe=4096
[    1.992724] N_HDLC line discipline registered.
[    1.994155] r3964: Philips r3964 Driver $Revision: 1.10 $
[    1.995716] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled

[    2.277097] MOXA Intellio family driver version 6.0k
[    2.278093] MOXA Smartio/Industio family driver version 2.0.5
[    2.279190] Initializing Nozomi driver 2.1d
[    2.280143] RocketPort device driver module, version 2.09, 12-June-2003
[    2.281404] No rocketport ports found; unloading driver
[    2.282739] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    2.284168] ac.o: No PCI boards found.
[    2.284846] ac.o: For an ISA board you must supply memory and irq parameters.
[    2.286188] ppdev: user-space parallel port driver
[    2.287195] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    2.288162] smapi::smapi_init, ERROR invalid usSmapiID
[    2.289099] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[    2.290864] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[    2.292171] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    2.293305] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    2.295008] Hangcheck: Using getrawmonotonic().
[    2.295878] [drm:drm_core_init] *ERROR* Cannot create /proc/dri
[    2.298553] Floppy drive(s): fd0 is 1.44M
[    2.305905] brd: module loaded
[    2.309749] loop: module loaded
[    2.310519] Compaq SMART2 Driver (v 2.6.0)
[    2.311567] MM: desc_per_page = 128
[    2.313001] FDC 0 is a S82078B
[    2.314038] virtio-pci 0000:00:05.0: irq 40 for MSI/MSI-X
[    2.315441] virtio-pci 0000:00:05.0: irq 41 for MSI/MSI-X
[    2.345219]  vda: unknown partition table
[    2.347106] virtio-pci 0000:00:06.0: irq 42 for MSI/MSI-X
[    2.348438] virtio-pci 0000:00:06.0: irq 43 for MSI/MSI-X
[    2.373005]  vdb: unknown partition table
[    2.374806] virtio-pci 0000:00:07.0: irq 44 for MSI/MSI-X
[    2.376195] virtio-pci 0000:00:07.0: irq 45 for MSI/MSI-X
[    2.404786]  vdc: unknown partition table
[    2.406073] virtio-pci 0000:00:08.0: irq 46 for MSI/MSI-X
[    2.407190] virtio-pci 0000:00:08.0: irq 47 for MSI/MSI-X
[    2.437884]  vdd: unknown partition table
[    2.439261] virtio-pci 0000:00:09.0: irq 48 for MSI/MSI-X
[    2.440387] virtio-pci 0000:00:09.0: irq 49 for MSI/MSI-X
[    2.469710]  vde: unknown partition table
[    2.471110] virtio-pci 0000:00:0a.0: irq 50 for MSI/MSI-X
[    2.472165] virtio-pci 0000:00:0a.0: irq 51 for MSI/MSI-X
[    2.496885]  vdf: unknown partition table
[    2.497996] mtip32xx Version 1.2.6os3
[    2.498813] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    2.500310] lkdtm: No crash points registered, enable through debugfs
[    2.501533] Phantom Linux Driver, version n0.9.8, init OK
[    2.503271] usbcore: registered new interface driver viperboard
[    2.504550] usbcore: registered new interface driver pn533
[    2.505563] Uniform Multi-Platform E-IDE driver
[    2.506498] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    2.507974] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    2.509285] pci 0000:00:01.1: setting latency timer to 64
[    2.510380]     ide0: BM-DMA at 0xc1e0-0xc1e7
[    2.511249]     ide1: BM-DMA at 0xc1e8-0xc1ef
[    2.512076] Probing IDE interface ide0...
[    2.756846] tsc: Refined TSC clocksource calibration: 2693.508 MHz
[    2.758072] Switching to clocksource tsc
[    3.053548] Probing IDE interface ide1...
[    3.756813] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    4.397158] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    4.399997] hdc: MWDMA2 mode selected
[    4.401984] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.404021] ide1 at 0x170-0x177,0x376 on irq 15
[    4.413513] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    4.420347] ide-cd driver 5.00
[    4.424270] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[    4.427968] cdrom: Uniform CD-ROM driver Revision: 3.20
[    4.435341] Loading iSCSI transport class v2.0-870.
[    4.446495] fnic: Cisco FCoE HBA Driver, ver 1.5.0.22
[    4.449031] fnic: Successfully Initialized Trace Buffer
[    4.453683] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.14 (Mar 08, 2013)
[    4.465722] Adaptec aacraid driver 1.2-0[30200]-ms
[    4.468397] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    4.471741] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[    4.474624] scsi: <fdomain> Detection failed (no card)
[    4.480464] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.05.00.03-k.
[    4.482673] iscsi: registered transport (qla4xxx)
[    4.483888] QLogic iSCSI HBA Driver
[    4.484740] Brocade BFA FC/FCOE SCSI driver - version: 3.1.2.1
[    4.486254] csiostor: Chelsio FCoE driver 1.0.0
[    4.487779] DC390: clustering now enabled by default. If you get problems load
[    4.489518]        with "disable_clustering=1" and report to maintainers
[    4.491302] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    4.493254] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    4.495030] mpt2sas version 14.100.00.00 loaded
[    4.496423] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    4.498052] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    4.499744] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[    4.501599] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[    4.503525] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (November 16, 2012)
[    4.505457] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    4.507269] iscsi: registered transport (be2iscsi)
[    4.508451] In beiscsi_module_init, tt=ffffffff83522980
[    4.510079] SCSI Media Changer driver v0.25 
[    4.511216] osd: LOADED open-osd 0.2.1
[    4.526639] scsi_debug: host protection
[    4.527658] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[    4.530636] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[    4.535299] Error: Driver 'pata_platform' is already registered, aborting...
[    4.537148] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
[    4.539588] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    4.540786] SSFDC read-only Flash Translation layer
[    4.541029] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[    4.541133] slram: not enough parameters.
[    4.541138] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[    4.541156] pmc551: not detected
[    4.541226] Spectra MTD driver built on Jun 12 2013 @ 22:04:08
[    4.548659] sd 0:0:0:0: [sda] Write Protect is off
[    4.549859] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    4.556758] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[    4.563472] No valid DiskOnChip devices found
[    4.565417] HSI/SSI char device loaded
[    4.566649] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[    4.571334] libphy: Fixed MDIO Bus: probed
[    4.573188] tun: Universal TUN/TAP device driver, 1.6
[    4.574747] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    4.580315]  sda: unknown partition table
[    4.581674] virtio-pci 0000:00:03.0: irq 52 for MSI/MSI-X
[    4.583325] virtio-pci 0000:00:03.0: irq 53 for MSI/MSI-X
[    4.584534] virtio-pci 0000:00:03.0: irq 54 for MSI/MSI-X
[    4.596783] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.631956] arcnet loaded.
[    4.631962] arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
[    4.631964] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[    4.631965] arcnet: raw mode (`r') encapsulation support loaded.
[    4.631967] arcnet: cap mode (`c') encapsulation support loaded.
[    4.631977] arcnet: COM90xx chipset support
[    4.632346] S1: No ARCnet cards found.
[    4.632385] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[    4.632386] E-mail me if you actually test this driver, please!
[    4.632388]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[    4.632395] arcnet: COM20020 PCI support
[    4.632530] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[    4.632762] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.16 (Dec 05, 2012)
[    4.633054] Brocade 10G Ethernet driver - version: 3.2.21.1
[    4.633576] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[    4.633760] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[    4.634043] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    4.634045] e100: Copyright(c) 1999-2006 Intel Corporation
[    4.634112] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.3-k
[    4.634114] igb: Copyright (c) 2007-2013 Intel Corporation.
[    4.634178] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.2-k
[    4.634179] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    4.634244] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.13.10-k
[    4.634245] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[    4.634356] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[    4.634358] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    4.634419] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    4.634877] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[    4.634993] Solarflare NET driver v3.2
[    4.635491] PPP generic driver version 2.4.2
[    4.690552] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
[    4.697526] SLIP linefill/keepalive option.
[    4.699320] hdlc: HDLC support module revision 1.22
[    4.701430] x25_asy: X.25 async: version 0.00 ALPHA (dynamic channels, max=256)
[    4.704452] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[    4.706888] LAPB Ethernet driver version 0.02
[    4.708251] airo(): Probing for PCI adapters
[    4.709445] airo(): Finished probing for PCI adapters
[    4.711546] Loaded prism54 driver, version 1.2
[    4.713555] usbcore: registered new interface driver zd1201
[    4.715905] usbcore: registered new interface driver i2400m_usb
[    4.723648] ieee802154fakelb ieee802154fakelb: added ieee802154 hardware
[    4.726581] usbcore: registered new interface driver catc
[    4.728874] usbcore: registered new interface driver kaweth
[    4.731154] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
[    4.733554] usbcore: registered new interface driver pegasus
[    4.734886] usbcore: registered new interface driver rtl8150
[    4.737112] hso: /c/kernel-tests/src/tip/drivers/net/usb/hso.c: Option Wireless
[    4.740383] usbcore: registered new interface driver hso
[    4.742598] usbcore: registered new interface driver ax88179_178a
[    4.745185] usbcore: registered new interface driver cdc_ether
[    4.747565] usbcore: registered new interface driver cdc_eem
[    4.749904] usbcore: registered new interface driver dm9601
[    4.752341] usbcore: registered new interface driver smsc75xx
[    4.754252] usbcore: registered new interface driver smsc95xx
[    4.756565] usbcore: registered new interface driver net1080
[    4.758914] usbcore: registered new interface driver plusb
[    4.761220] usbcore: registered new interface driver rndis_host
[    4.763201] usbcore: registered new interface driver cdc_subset
[    4.764646] usbcore: registered new interface driver zaurus
[    4.766033] usbcore: registered new interface driver cdc_phonet
[    4.768331] usbcore: registered new interface driver kalmia
[    4.770555] usbcore: registered new interface driver cx82310_eth
[    4.772952] usbcore: registered new interface driver cdc_ncm
[    4.775245] usbcore: registered new interface driver qmi_wwan
[    4.777645] usbcore: registered new interface driver cdc_mbim
[    4.780539] usbcore: registered new interface driver hwa-rc
[    4.782769] usbcore: registered new interface driver i1480-dfu-usb
[    4.785219] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.787730] ehci-pci: EHCI PCI platform driver
[    4.789613] uhci_hcd: USB Universal Host Controller Interface driver
[    4.792506] driver u132_hcd
[    4.794203] usbcore: registered new interface driver hwa-hc
[    4.796347] usbcore: registered new interface driver wusb-cbaf
[    4.798596] usbcore: registered new interface driver cdc_acm
[    4.800805] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    4.804138] usbcore: registered new interface driver cdc_wdm
[    4.806255] usbcore: registered new interface driver usb-storage
[    4.808578] usbcore: registered new interface driver ums-datafab
[    4.810883] usbcore: registered new interface driver ums_eneub6250
[    4.813411] usbcore: registered new interface driver ums-freecom
[    4.815995] usbcore: registered new interface driver ums-isd200
[    4.818375] usbcore: registered new interface driver ums-jumpshot
[    4.820892] usbcore: registered new interface driver ums-karma
[    4.823182] usbcore: registered new interface driver ums-onetouch
[    4.825664] usbcore: registered new interface driver ums-realtek
[    4.828307] usbcore: registered new interface driver ums-sddr09
[    4.830686] usbcore: registered new interface driver ums-sddr55
[    4.833087] usbcore: registered new interface driver microtekX6
[    4.835681] usbcore: registered new interface driver usbserial
[    4.838145] usbcore: registered new interface driver usbserial_generic
[    4.840853] usbserial: USB Serial support registered for generic
[    4.843312] usbcore: registered new interface driver ark3116
[    4.845703] usbserial: USB Serial support registered for ark3116
[    4.848266] usbcore: registered new interface driver ch341
[    4.850612] usbserial: USB Serial support registered for ch341-uart
[    4.853154] usbcore: registered new interface driver cp210x
[    4.855459] usbserial: USB Serial support registered for cp210x
[    4.857888] usbcore: registered new interface driver cypress_m8
[    4.860315] usbserial: USB Serial support registered for DeLorme Earthmate USB
[    4.863168] usbserial: USB Serial support registered for HID->COM RS232 Adapter
[    4.866020] usbserial: USB Serial support registered for Nokia CA-42 V2 Adapter
[    4.868964] usbcore: registered new interface driver usb_debug
[    4.871353] usbserial: USB Serial support registered for debug
[    4.873734] usbcore: registered new interface driver digi_acceleport
[    4.876311] usbserial: USB Serial support registered for Digi 2 port USB adapter
[    4.879233] usbserial: USB Serial support registered for Digi 4 port USB adapter
[    4.882173] usbcore: registered new interface driver empeg
[    4.884421] usbserial: USB Serial support registered for empeg
[    4.886794] usbcore: registered new interface driver f81232
[    4.889007] usbserial: USB Serial support registered for f81232
[    4.891326] usbcore: registered new interface driver ftdi_sio
[    4.893600] usbserial: USB Serial support registered for FTDI USB Serial Device
[    4.896394] usbcore: registered new interface driver funsoft
[    4.898718] usbserial: USB Serial support registered for funsoft
[    4.901060] usbcore: registered new interface driver garmin_gps
[    4.903489] usbserial: USB Serial support registered for Garmin GPS usb/tty
[    4.906362] usbcore: registered new interface driver ir_usb
[    4.908578] usbserial: USB Serial support registered for IR Dongle
[    4.911085] usbcore: registered new interface driver iuu_phoenix
[    4.913529] usbserial: USB Serial support registered for iuu_phoenix
[    4.916135] usbcore: registered new interface driver keyspan
[    4.918502] usbserial: USB Serial support registered for Keyspan - (without firmware)
[    4.921560] usbserial: USB Serial support registered for Keyspan 1 port adapter
[    4.924486] usbserial: USB Serial support registered for Keyspan 2 port adapter
[    4.927283] usbserial: USB Serial support registered for Keyspan 4 port adapter
[    4.930290] usbcore: registered new interface driver mct_u232
[    4.932631] usbserial: USB Serial support registered for MCT U232
[    4.935148] usbcore: registered new interface driver mos7840
[    4.937362] usbserial: USB Serial support registered for Moschip 7840/7820 USB Serial Driver
[    4.940802] usbcore: registered new interface driver navman
[    4.943017] usbserial: USB Serial support registered for navman
[    4.945457] usbcore: registered new interface driver omninet
[    4.947760] usbserial: USB Serial support registered for ZyXEL - omni.net lcd plus usb
[    4.950745] usbcore: registered new interface driver opticon
[    4.952986] usbserial: USB Serial support registered for opticon
[    4.955466] usbcore: registered new interface driver oti6858
[    4.957783] usbserial: USB Serial support registered for oti6858
[    4.960183] usbcore: registered new interface driver pl2303
[    4.962442] usbserial: USB Serial support registered for pl2303
[    4.964816] usbcore: registered new interface driver qcaux
[    4.967114] usbserial: USB Serial support registered for qcaux
[    4.969467] usbcore: registered new interface driver quatech2
[    4.971771] usbserial: USB Serial support registered for Quatech 2nd gen USB to Serial Driver
[    4.975081] usbcore: registered new interface driver safe_serial
[    4.977514] usbserial: USB Serial support registered for safe_serial
[    4.980138] usbcore: registered new interface driver sierra
[    4.982434] usbserial: USB Serial support registered for Sierra USB modem
[    4.985250] usbcore: registered new interface driver spcp8x5
[    4.987600] usbserial: USB Serial support registered for SPCP8x5
[    4.990061] usbcore: registered new interface driver ssu100
[    4.992311] usbserial: USB Serial support registered for Quatech SSU-100 USB to Serial Driver
[    4.995806] usbcore: registered new interface driver symbolserial
[    4.998336] usbserial: USB Serial support registered for symbol
[    5.000698] usbcore: registered new interface driver visor
[    5.002699] usbserial: USB Serial support registered for Handspring Visor / Palm OS
[    5.005532] usbserial: USB Serial support registered for Sony Clie 5.0
[    5.008229] usbserial: USB Serial support registered for Sony Clie 3.5
[    5.010894] usbcore: registered new interface driver wishbone_serial
[    5.013208] usbserial: USB Serial support registered for wishbone_serial
[    5.016014] usbcore: registered new interface driver whiteheat
[    5.018322] usbserial: USB Serial support registered for Connect Tech - WhiteHEAT - (prerenumeration)
[    5.021972] usbserial: USB Serial support registered for Connect Tech - WhiteHEAT
[    5.024893] usbcore: registered new interface driver vivopay_serial
[    5.027521] usbserial: USB Serial support registered for vivopay-serial
[    5.030224] usbcore: registered new interface driver xsens_mt
[    5.032448] usbserial: USB Serial support registered for xsens_mt
[    5.034880] usbcore: registered new interface driver zio
[    5.037065] usbserial: USB Serial support registered for zio
[    5.039271] usbcore: registered new interface driver adutux
[    5.041579] usbcore: registered new interface driver appledisplay
[    5.043808] usbcore: registered new interface driver cypress_cy7c63
[    5.046125] usbcore: registered new interface driver cytherm
[    5.048416] usbcore: registered new interface driver emi62 - firmware loader
[    5.051207] driver ftdi-elan
[    5.053257] usbcore: registered new interface driver ftdi-elan
[    5.054651] usbcore: registered new interface driver idmouse
[    5.056073] usbcore: registered new interface driver iowarrior
[    5.058481] usbcore: registered new interface driver isight_firmware
[    5.061038] usbcore: registered new interface driver usblcd
[    5.063177] usbcore: registered new interface driver usbled
[    5.065388] usbcore: registered new interface driver trancevibrator
[    5.067971] usbcore: registered new interface driver uss720
[    5.070215] uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
[    5.073906] uss720: NOTE: this is a special purpose driver to allow nonstandard
[    5.076890] uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
[    5.079790] uss720: If you just want to connect to a printer, use usblp instead
[    5.083014] usbcore: registered new interface driver yurex
[    5.085201] usbcore: registered new interface driver sisusb
[    5.088729] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[    5.091702] dummy_hcd dummy_hcd.0: Dummy host controller
[    5.094080] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[    5.097666] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    5.100351] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.103028] usb usb1: Product: Dummy host controller
[    5.104999] usb usb1: Manufacturer: Linux 3.10.0-rc4-04726-g5e81a2f dummy_hcd
[    5.107841] usb usb1: SerialNumber: dummy_hcd.0
[    5.112742] hub 1-0:1.0: USB hub found
[    5.113882] hub 1-0:1.0: 1 port detected
[    5.116521] g_ether gadget: using random self ethernet address
[    5.117990] g_ether gadget: using random host ethernet address
[    5.119785] usb0: MAC c6:75:cf:d6:f5:99
[    5.120826] usb0: HOST MAC b2:38:d8:c8:b4:54
[    5.121967] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[    5.123652] g_ether gadget: g_ether ready
[    5.124878] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    5.128748] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.131416] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.133670] parkbd: no such parport
[    5.136175] mousedev: PS/2 mouse device common for all mice
[    5.138906] evbug: Connected device: input0 (Power Button at LNXPWRBN/button/input0)
[    5.143286] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    5.147107] evbug: Connected device: input1 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[    5.151713] usbcore: registered new interface driver usb_acecad
[    5.154123] usbcore: registered new interface driver aiptek
[    5.156461] usbcore: registered new interface driver gtco
[    5.158727] usbcore: registered new interface driver kbtab
[    5.161352] usbcore: registered new interface driver usbtouchscreen
[    5.164493] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    5.167102] usbcore: registered new interface driver ati_remote2
[    5.169540] usbcore: registered new interface driver ims_pcu
[    5.172353] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    5.175371] evbug: Connected device: input2 (PC Speaker at isa0061/input0)
[    5.178200] usbcore: registered new interface driver powermate
[    5.180887] I2O subsystem v1.325
[    5.182228] i2o: max drivers = 8
[    5.186301] I2O Bus Adapter OSM v1.317
[    5.187905] I2O SCSI Peripheral OSM v1.316
[    5.189677] i2c /dev entries driver
[    5.191978] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[    5.274435] i2c-parport-light: adapter type unspecified
[    5.276532] usbcore: registered new interface driver i2c-tiny-usb
[    5.279166] smssdio: Siano SMS1xxx SDIO driver
[    5.280864] smssdio: Copyright Pierre Ossman
[    5.282539] pps_parport: parallel port PPS client
[    5.284623] Driver for 1-wire Dallas network protocol.
[    5.287435] power_supply test_ac: uevent
[    5.288882] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    5.290987] power_supply test_ac: prop ONLINE=1
[    5.292814] power_supply test_ac: power_supply_changed
[    5.294902] power_supply test_ac: power_supply_changed_work
[    5.297137] power_supply test_ac: power_supply_update_gen_leds 1
[    5.299428] power_supply test_ac: uevent
[    5.300275] power_supply test_battery: uevent
[    5.300279] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    5.300294] power_supply test_battery: prop STATUS=Discharging
[    5.300299] power_supply test_battery: prop CHARGE_TYPE=Fast
[    5.300302] power_supply test_battery: prop HEALTH=Good
[    5.300306] power_supply test_battery: prop PRESENT=1
[    5.300310] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    5.300314] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    5.300319] power_supply test_battery: prop CHARGE_FULL=100
[    5.300323] power_supply test_battery: prop CHARGE_NOW=50
[    5.300326] power_supply test_battery: prop CAPACITY=50
[    5.300329] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    5.300339] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    5.300343] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    5.300347] power_supply test_battery: prop MODEL_NAME=Test battery
[    5.300350] power_supply test_battery: prop MANUFACTURER=Linux
[    5.300354] power_supply test_battery: prop SERIAL_NUMBER=3.10.0-rc4-04726-g5e81a2f
[    5.300358] power_supply test_battery: prop TEMP=26
[    5.300361] power_supply test_battery: prop VOLTAGE_NOW=3300
[    5.300830] power_supply test_battery: power_supply_changed
[    5.300856] power_supply test_battery: power_supply_changed_work
[    5.300865] power_supply test_battery: power_supply_update_bat_leds 2
[    5.300876] power_supply test_battery: uevent
[    5.300878] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    5.300906] power_supply test_battery: prop STATUS=Discharging
[    5.300911] power_supply test_battery: prop CHARGE_TYPE=Fast
[    5.300914] power_supply test_battery: prop HEALTH=Good
[    5.300918] power_supply test_battery: prop PRESENT=1
[    5.300921] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    5.300925] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    5.300929] power_supply test_battery: prop CHARGE_FULL=100
[    5.300933] power_supply test_battery: prop CHARGE_NOW=50
[    5.300953] power_supply test_battery: prop CAPACITY=50
[    5.300957] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    5.300961] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    5.300964] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    5.300969] power_supply test_battery: prop MODEL_NAME=Test battery
[    5.300972] power_supply test_battery: prop MANUFACTURER=Linux
[    5.300976] power_supply test_battery: prop SERIAL_NUMBER=3.10.0-rc4-04726-g5e81a2f
[    5.300979] power_supply test_battery: prop TEMP=26
[    5.300982] power_supply test_battery: prop VOLTAGE_NOW=3300
[    5.301080] power_supply test_usb: uevent
[    5.301082] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    5.301098] power_supply test_usb: prop ONLINE=1
[    5.301116] power_supply test_usb: power_supply_changed
[    5.301155] power_supply test_usb: power_supply_changed_work
[    5.301163] power_supply test_usb: power_supply_update_gen_leds 1
[    5.301169] power_supply test_usb: uevent
[    5.301172] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    5.301179] power_supply test_usb: prop ONLINE=1
[    5.406929] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    5.409102] power_supply test_ac: prop ONLINE=1
[    5.516797] usb 1-1: new high-speed USB device number 2 using dummy_hcd
[    5.533465] w83793: Detection failed at check vendor id
[    5.553562] w83793: Detection failed at check vendor id
[    5.573499] w83793: Detection failed at check vendor id
[    5.593443] w83793: Detection failed at check vendor id
[    5.606803] i2c i2c-0: w83795: Detection failed at addr 0x2c, check bank
[    5.620142] i2c i2c-0: w83795: Detection failed at addr 0x2d, check bank
[    5.636797] i2c i2c-0: w83795: Detection failed at addr 0x2e, check bank
[    5.650136] i2c i2c-0: w83795: Detection failed at addr 0x2f, check bank
[    5.663490] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.670118] usb 1-1: Dual-Role OTG device on HNP port
[    5.673431] usb 1-1: New USB device found, idVendor=0525, idProduct=a4a1
[    5.675632] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    5.678024] usb 1-1: Product: Ethernet Gadget
[    5.679412] usb 1-1: Manufacturer: Linux 3.10.0-rc4-04726-g5e81a2f with dummy_udc
[    5.680180] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.686749] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[    5.696862] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.700742] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, b2:38:d8:c8:b4:54
[    5.713506] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.726849] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.740194] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.753535] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.766871] i2c i2c-0: Detection of w83781d chip failed at step 3
[    5.850232] detect failed, chip not detected!
[    5.876873] detect failed, chip not detected!
[    5.903556] detect failed, chip not detected!
[    5.936811] detect failed, chip not detected!
[    5.963466] detect failed, chip not detected!
[    5.990150] detect failed, chip not detected!
[    6.016839] detect failed, chip not detected!
[    6.043489] detect failed, chip not detected!
[    6.070158] detect failed, chip not detected!
[    6.083481] i2c i2c-0: ADM1025 detection failed at 0x2c
[    6.096822] i2c i2c-0: ADM1025 detection failed at 0x2d
[    6.110122] i2c i2c-0: ADM1025 detection failed at 0x2e
[    6.133483] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff and VERSTEP: 0xff
[    6.135835] i2c i2c-0: Autodetecting device at 0,0x2c...
[    6.137615] i2c i2c-0: Autodetection failed
[    6.163507] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff and VERSTEP: 0xff
[    6.168637] i2c i2c-0: Autodetecting device at 0,0x2d...
[    6.170431] i2c i2c-0: Autodetection failed
[    6.190180] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff and VERSTEP: 0xff
[    6.192222] i2c i2c-0: Autodetecting device at 0,0x2e...
[    6.193581] i2c i2c-0: Autodetection failed
[    6.653533] applesmc: supported laptop not found!
[    6.655084] applesmc: driver init failed (ret=-19)!
[    6.953683] f71882fg: Not a Fintek device
[    6.955199] f71882fg: Not a Fintek device
[   12.180162] i2c i2c-0: LM83 detection failed at 0x18
[   12.193485] i2c i2c-0: LM83 detection failed at 0x19
[   12.210161] i2c i2c-0: LM83 detection failed at 0x1a
[   12.223476] i2c i2c-0: LM83 detection failed at 0x29
[   12.236818] i2c i2c-0: LM83 detection failed at 0x2a
[   12.250150] i2c i2c-0: LM83 detection failed at 0x2b
[   12.263488] i2c i2c-0: LM83 detection failed at 0x4c
[   12.276828] i2c i2c-0: LM83 detection failed at 0x4d
[   12.290162] i2c i2c-0: LM83 detection failed at 0x4e
[   12.310151] i2c i2c-0: Detecting device at 0x2c with COMPANY: 0xff and VERSTEP: 0xff
[   12.312832] i2c i2c-0: Autodetection failed: unsupported version
[   12.333525] i2c i2c-0: Detecting device at 0x2d with COMPANY: 0xff and VERSTEP: 0xff
[   12.335190] i2c i2c-0: Autodetection failed: unsupported version
[   12.356858] i2c i2c-0: Detecting device at 0x2e with COMPANY: 0xff and VERSTEP: 0xff
[   12.359335] i2c i2c-0: Autodetection failed: unsupported version
[   12.434809] i2c i2c-0: Unsupported chip at 0x18 (man_id=0xFF, chip_id=0xFF)
[   12.476826] i2c i2c-0: Unsupported chip at 0x19 (man_id=0xFF, chip_id=0xFF)
[   12.510171] i2c i2c-0: Unsupported chip at 0x1a (man_id=0xFF, chip_id=0xFF)
[   12.544155] i2c i2c-0: Unsupported chip at 0x29 (man_id=0xFF, chip_id=0xFF)
[   12.576834] i2c i2c-0: Unsupported chip at 0x2a (man_id=0xFF, chip_id=0xFF)
[   12.610157] i2c i2c-0: Unsupported chip at 0x2b (man_id=0xFF, chip_id=0xFF)
[   12.644111] i2c i2c-0: Unsupported chip at 0x48 (man_id=0xFF, chip_id=0xFF)
[   12.680196] i2c i2c-0: Unsupported chip at 0x49 (man_id=0xFF, chip_id=0xFF)
[   12.713563] i2c i2c-0: Unsupported chip at 0x4a (man_id=0xFF, chip_id=0xFF)
[   12.750225] i2c i2c-0: Unsupported chip at 0x4b (man_id=0xFF, chip_id=0xFF)
[   12.783557] i2c i2c-0: Unsupported chip at 0x4c (man_id=0xFF, chip_id=0xFF)
[   12.816876] i2c i2c-0: Unsupported chip at 0x4d (man_id=0xFF, chip_id=0xFF)
[   12.850193] i2c i2c-0: Unsupported chip at 0x4e (man_id=0xFF, chip_id=0xFF)
[   12.893533] i2c i2c-0: Unsupported chip at 0x4f (man_id=0xFF, chip_id=0xFF)
[   13.093530] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   13.106879] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   13.120192] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   13.296829] i2c i2c-0: MAX1619 detection failed at 0x18
[   13.323524] i2c i2c-0: MAX1619 detection failed at 0x19
[   13.350226] i2c i2c-0: MAX1619 detection failed at 0x1a
[   13.376961] i2c i2c-0: MAX1619 detection failed at 0x29
[   13.403534] i2c i2c-0: MAX1619 detection failed at 0x2a
[   13.430231] i2c i2c-0: MAX1619 detection failed at 0x2b
[   13.456905] i2c i2c-0: MAX1619 detection failed at 0x4c
[   13.483559] i2c i2c-0: MAX1619 detection failed at 0x4d
[   13.510238] i2c i2c-0: MAX1619 detection failed at 0x4e
[   13.813711] pc87360: PC8736x not detected, module not inserted
[   13.833521] i2c i2c-0: SMSC47M192 detection failed at 0x2c
[   13.854117] i2c i2c-0: SMSC47M192 detection failed at 0x2d
[   13.866873] i2c i2c-0: amc6821_detect called.
[   13.886847] i2c i2c-0: amc6821: detection failed at 0x18.
[   13.893554] i2c i2c-0: amc6821_detect called.
[   13.907200] i2c i2c-0: amc6821: detection failed at 0x19.
[   13.913490] i2c i2c-0: amc6821_detect called.
[   13.926842] i2c i2c-0: amc6821: detection failed at 0x1a.
[   13.933490] i2c i2c-0: amc6821_detect called.
[   13.950210] i2c i2c-0: amc6821: detection failed at 0x2c.
[   13.963541] i2c i2c-0: amc6821_detect called.
[   13.976860] i2c i2c-0: amc6821: detection failed at 0x2d.
[   13.983540] i2c i2c-0: amc6821_detect called.
[   13.996870] i2c i2c-0: amc6821: detection failed at 0x2e.
[   14.003513] i2c i2c-0: amc6821_detect called.
[   14.016862] i2c i2c-0: amc6821: detection failed at 0x4c.
[   14.023688] i2c i2c-0: amc6821_detect called.
[   14.036839] i2c i2c-0: amc6821: detection failed at 0x4d.
[   14.043513] i2c i2c-0: amc6821_detect called.
[   14.056867] i2c i2c-0: amc6821: detection failed at 0x4e.
[   14.113558] i2c i2c-0: w83l785ts: Read 0xff from register 0x40.
[   14.115512] i2c i2c-0: W83L785TS-S detection failed at 0x2e
[   14.130208] i2c i2c-0: W83L786NG detection failed at 0x2e
[   14.143579] i2c i2c-0: W83L786NG detection failed at 0x2f
[   14.145745] intel_powerclamp: Intel powerclamp does not run on family 15 model 6
[   14.148916] usbcore: registered new interface driver pcwd_usb
[   14.151210] advantechwdt: WDT driver for Advantech single board computer initialising
[   14.154964] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   14.157464] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   14.159478] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   14.162093] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[   14.164596] ib700wdt: WDT driver for IB700 single board computer initialising
[   14.169495] ib700wdt: START method I/O 443 is not available
[   14.175743] ib700wdt: probe of ib700wdt failed with error -5
[   14.179299] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   14.186288] wafer5823wdt: I/O address 0x0443 already in use
[   14.188518] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   14.191215] i6300esb: cannot register miscdev on minor=130 (err=-16)
[   14.193695] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[   14.196502] it87_wdt: no device
[   14.197875] pc87413_wdt: Version 1.1 at io 0x2E
[   14.199623] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   14.202169] sbc8360: failed to register misc device
[   14.204030] cpu5wdt: misc_register failed
[   14.205482] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   14.209735] smsc37b787_wdt: Unable to register miscdev on minor 130
[   14.212141] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[   14.215795] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[   14.218502] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[   14.221039] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   14.223395] w83697hf_wdt: watchdog not found at address 0x2e
[   14.225461] w83697hf_wdt: No W83697HF/HG could be found
[   14.227516] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[   14.230558] w83697ug_wdt: No W83697UG/UF could be found
[   14.232511] w83877f_wdt: I/O address 0x0443 already in use
[   14.234580] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   14.236815] machzwd: no ZF-Logic found
[   14.237696] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   14.239685] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[   14.242604] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[   14.249260] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   14.252055] md: linear personality registered for level -1
[   14.253489] md: raid0 personality registered for level 0
[   14.254800] md: raid10 personality registered for level 10
[   14.256244] md: raid6 personality registered for level 6
[   14.257659] md: raid5 personality registered for level 5
[   14.258993] md: raid4 personality registered for level 4
[   14.260358] md: faulty personality registered for level -5
[   14.269593] Bluetooth: Virtual HCI driver ver 1.3
[   14.275692] usbcore: registered new interface driver bcm203x
[   14.277597] usbcore: registered new interface driver bfusb
[   14.278918] usbcore: registered new interface driver btusb
[   14.280031] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   14.281806] usbcore: registered new interface driver ath3k
[   14.283888] EDAC DEBUG: i82975x_init: i82975x pci_get_device fail
[   14.286060] EDAC DEBUG: i3000_init: i3000 pci_get_device fail
[   14.288222] EDAC DEBUG: i3200_init: i3200 pci_get_device fail
[   14.290344] EDAC DEBUG: x38_init: x38 pci_get_device fail
[   14.292199] cpuidle: using governor ladder
[   14.293611] cpuidle: using governor menu
[   14.295057] sdhci: Secure Digital Host Controller Interface driver
[   14.297101] sdhci: Copyright(c) Pierre Ossman
[   14.298767] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   14.300824] wbsd: Copyright(c) Pierre Ossman
[   14.302520] usbcore: registered new interface driver ushc
[   14.304462] sdhci-pltfm: SDHCI platform and OF driver helper
[   17.710197]  (null): enodev DEV ADDR = 0xFF
[   17.711858] ledtrig-cpu: registered to indicate activity on CPUs
[   17.722482] ib_qib: Unable to register ipathfs
[   17.731342] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   17.737928] usbcore: registered new interface driver usbkbd
[   17.740250] usbcore: registered new interface driver usbmouse
[   17.742657] msi_laptop: Brightness ignored, must be controlled by ACPI video driver
[   17.746353] compal_laptop: Motherboard not recognized (You could try the module's force-parameter)
[   17.749820] dell_wmi: No known WMI GUID found
[   17.751485] dell_wmi_aio: No known WMI GUID found
[   17.753279] acer_wmi: Acer Laptop ACPI-WMI Extras
[   17.755051] acer_wmi: No or unsupported WMI interface, unable to load
[   17.758121] hdaps: supported laptop not found!
[   17.759707] hdaps: driver init failed (ret=-19)!
[   17.762592] FUJ02B1: call_fext_func: FUNC interface is not present
[   17.764840] fujitsu_laptop: driver 0.6.0 successfully loaded
[   17.767141] msi_wmi: This machine doesn't have neither MSI-hotkeys nor backlight through WMI
[   17.770149] intel_oaktrail: Platform not recognized (You could try the module's force-parameter)Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
[   17.783155] aedsp16: I/O, IRQ and DMA are mandatory
[   17.785226] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[   17.787614] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
[   17.790526] ad1848: No ISAPnP cards found, trying standard ones...
[   17.792889] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen 1993-1996
[   17.795835] I/O, IRQ, DMA and type are mandatory
[   17.797761] sb: Init: Starting Probe...
[   17.799177] sb: Init: Done
[   17.800307] uart6850: irq and io must be set.
[   17.801956] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, Rob Hooft 1993-1996
[   17.805219] MIDI Loopback device driver
[   17.813806] ASIHPI driver 4.10.01
[   17.818072] usbcore: registered new interface driver snd-usb-usx2y
[   17.820654] usbcore: registered new interface driver snd-usb-caiaq
[   17.823035] usbcore: registered new interface driver snd-usb-6fire
[   17.834237] NET: Registered protocol family 26
[   17.836278] NET: Registered protocol family 15
[   17.838353] NET: Registered protocol family 4
[   17.840234] NET: Registered protocol family 9
[   17.841805] X.25 for Linux Version 0.2
[   17.844028] Bluetooth: RFCOMM TTY layer initialized
[   17.846128] Bluetooth: RFCOMM socket layer initialized
[   17.848371] Bluetooth: RFCOMM ver 1.11
[   17.849899] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   17.851263] Bluetooth: BNEP filters: protocol multicast
[   17.852951] Bluetooth: BNEP socket layer initialized
[   17.855337] 8021q: 802.1Q VLAN Support v1.8
[   17.857226] NET: Registered protocol family 36
[   17.859245] Key type dns_resolver registered
[   17.861025] openvswitch: Open vSwitch switching datapath
[   17.863491] mpls_gso: MPLS GSO support
[   17.866808] 
[   17.866808] printing PIC contents
[   17.868674] ... PIC  IMR: ffff
[   17.869909] ... PIC  IRR: 9053
[   17.871207] ... PIC  ISR: 0000
[   17.872461] ... PIC ELCR: 0c00
[   17.873724] printing local APIC contents on CPU#0/0:
[   17.875701] ... APIC ID:      00000000 (0)
[   17.877019] ... APIC VERSION: 00050014
[   17.877019] ... APIC TASKPRI: 00000000 (00)
[   17.877019] ... APIC PROCPRI: 00000000
[   17.877019] ... APIC LDR: 01000000
[   17.877019] ... APIC DFR: ffffffff
[   17.877019] ... APIC SPIV: 000001ff
[   17.877019] ... APIC ISR field:
[   17.877019] 0000000000000000000000000000000000000000000000000000000000000000
[   17.877019] ... APIC TMR field:
[   17.877019] 0000000000000000000000000000000000000000000000000000000000000000
[   17.877019] ... APIC IRR field:
[   17.877019] 0000000000000000000000000000000000000000000000000000000000008000
[   17.877019] ... APIC ESR: 00000000
[   17.877019] ... APIC ICR: 000008fd
[   17.877019] ... APIC ICR2: 02000000
[   17.877019] ... APIC LVTT: 000000ef
[   17.877019] ... APIC LVTPC: 00010000
[   17.877019] ... APIC LVT0: 00010700
[   17.877019] ... APIC LVT1: 00000400
[   17.877019] ... APIC LVTERR: 000000fe
[   17.877019] ... APIC TMICT: 0002d60f
[   17.877019] ... APIC TMCCT: 00000000
[   17.877019] ... APIC TDCR: 00000003
[   17.877019] 
[   17.915717] number of MP IRQ sources: 15.
[   17.917382] number of IO-APIC #2 registers: 24.
[   17.919144] testing the IO APIC.......................
[   17.921247] IO APIC #2......
[   17.922434] .... register #00: 00000000
[   17.923959] .......    : physical APIC id: 00
[   17.925665] .......    : Delivery Type: 0
[   17.927343] .......    : LTS          : 0
[   17.928988] .... register #01: 00170011
[   17.930517] .......     : max redirection entries: 17
[   17.932541] .......     : PRQ implemented: 0
[   17.934332] .......     : IO APIC version: 11
[   17.936115] .... register #02: 00000000
[   17.937661] .......     : arbitration: 00
[   17.939298] .... IRQ redirection table:
[   17.940910] 1    0    0   0   0    0    0    00
[   17.942711] 0    0    0   0   0    1    1    31
[   17.944577] 0    0    0   0   0    1    1    30
[   17.946442] 1    0    0   0   0    1    1    33
[   17.948326] 1    0    0   0   0    1    1    34
[   17.950170] 1    1    0   0   0    1    1    35
[   17.951978] 0    0    0   0   0    1    1    36
[   17.953793] 1    0    0   0   0    1    1    37
[   17.955600] 1    0    0   0   0    1    1    38
[   17.957536] 0    1    0   0   0    1    1    39
[   17.959363] 1    1    0   0   0    1    1    3A
[   17.961242] 1    1    0   0   0    1    1    3B
[   17.963088] 0    0    0   0   0    1    1    3C
[   17.964894] 1    0    0   0   0    1    1    3D
[   17.966794] 0    0    0   0   0    1    1    3E
[   17.968644] 0    0    0   0   0    1    1    3F
[   17.970520] 1    0    0   0   0    0    0    00
[   17.972325] 1    0    0   0   0    0    0    00
[   17.974191] 1    0    0   0   0    0    0    00
[   17.975881] 1    0    0   0   0    0    0    00
[   17.977621] 1    0    0   0   0    0    0    00
[   17.979475] 1    0    0   0   0    0    0    00
[   17.981340] 1    0    0   0   0    0    0    00
[   17.983086] 1    0    0   0   0    0    0    00
[   17.984884] IRQ to pin mappings:
[   17.986238] IRQ0 -> 0:2
[   17.987363] IRQ1 -> 0:1
[   17.988441] IRQ3 -> 0:3
[   17.989543] IRQ4 -> 0:4
[   17.990690] IRQ5 -> 0:5
[   17.991745] IRQ6 -> 0:6
[   17.993013] IRQ7 -> 0:7
[   17.994077] IRQ8 -> 0:8
[   17.995166] IRQ9 -> 0:9
[   17.996334] IRQ10 -> 0:10
[   17.997559] IRQ11 -> 0:11
[   17.998695] IRQ12 -> 0:12
[   17.999820] IRQ13 -> 0:13
[   18.001035] IRQ14 -> 0:14
[   18.002177] IRQ15 -> 0:15
[   18.003244] .................................... done.
[   18.007306] registered taskstats version 1
[   18.012479] Key type encrypted registered
[   18.018683] console [netcon0] enabled
[   18.020179] netconsole: network logging started
[   18.021975] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[   18.025096] ALSA device list:
[   18.026285]   No soundcards found.
[   18.032464] debug: unmapping init [mem 0xffffffff8392a000-0xffffffff83c03fff]
/bin/sh: /proc/self/fd/9: No such file or directory
[   18.128490] umount (171) used greatest stack depth: 5240 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[   31.754063] CPA self-test:
[   31.757222]  4k 65534 large 0 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.802236]  4k 65534 large 0 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.833908]  4k 65534 large 0 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.836430] ok.
[   55.703515] warning: process `trinity-child1' used the deprecated sysctl system call with 
[   61.739446] trinity-child1 (184) used greatest stack depth: 5200 bytes left
[   73.930887] trinity-child0 invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[   73.933944] CPU: 0 PID: 196 Comm: trinity-child0 Not tainted 3.10.0-rc4-04726-g5e81a2f #17
[   73.936869]  ffff880000aa1b30 ffff88000d8e1a98 ffffffff82563b91 ffff88000d8e1fd8
[   73.939571]  ffff880000aa1430 ffff88000d8e1b38 ffffffff8255f61b ffff88000d8e1ac8
[   73.942445]  ffffffff810ea9cb 0000000000000206 ffffffff832750c0 ffff88000d8e1ad8
[   73.945422] Call Trace:
[   73.946408]  [<ffffffff82563b91>] dump_stack+0x95/0x102
[   73.948341]  [<ffffffff8255f61b>] dump_header.isra.12+0x85/0x2ef
[   73.950495]  [<ffffffff810ea9cb>] ? trace_hardirqs_on_caller+0x210/0x2ce
[   73.952903]  [<ffffffff810eaaa4>] ? trace_hardirqs_on+0x1b/0x24
[   73.955188]  [<ffffffff82586af1>] ? _raw_spin_unlock_irqrestore+0x8c/0xc6
[   73.957709]  [<ffffffff8143cdf8>] ? ___ratelimit+0x158/0x18c
[   73.959739]  [<ffffffff8112f2de>] oom_kill_process+0xa8/0x4f1
[   73.961928]  [<ffffffff810e76e3>] ? put_lock_stats.isra.20+0x1c/0x53
[   73.964371]  [<ffffffff810e782d>] ? lock_release_holdtime+0x113/0x11f
[   73.966765]  [<ffffffff8112fd64>] out_of_memory+0x38e/0x3c5
[   73.968775]  [<ffffffff81134514>] __alloc_pages_nodemask+0x82b/0x994
[   73.970906]  [<ffffffff8114ed71>] handle_pte_fault+0x1f7/0x9ee
[   73.973165]  [<ffffffff810311a7>] ? __do_page_fault+0x61f/0x6a7
[   73.975229]  [<ffffffff8114f8c9>] handle_mm_fault+0x1b6/0x1cc
[   73.977128]  [<ffffffff81031200>] __do_page_fault+0x678/0x6a7
[   73.979095]  [<ffffffff810ce445>] ? sched_clock_local+0x15/0xb9
[   73.981291]  [<ffffffff810ce6ad>] ? sched_clock_cpu+0x13f/0x15f
[   73.983446]  [<ffffffff81157a53>] ? SyS_brk+0x187/0x213
[   73.985153]  [<ffffffff810e7521>] ? get_lock_stats+0x35/0x6b
[   73.987207]  [<ffffffff810e76e3>] ? put_lock_stats.isra.20+0x1c/0x53
[   73.989301]  [<ffffffff810e782d>] ? lock_release_holdtime+0x113/0x11f
[   73.991611]  [<ffffffff81031295>] do_page_fault+0x39/0x60
[   73.993615]  [<ffffffff825881af>] page_fault+0x1f/0x30
[   73.995477] Mem-Info:
[   73.996381] DMA32 per-cpu:
[   73.997394] CPU    0: hi:   42, btch:   7 usd:  44
[   73.999108] CPU    1: hi:   42, btch:   7 usd:  47
[   74.000789] active_anon:2428 inactive_anon:0 isolated_anon:0
[   74.000789]  active_file:0 inactive_file:2 isolated_file:0
[   74.000789]  unevictable:22609 dirty:0 writeback:0 unstable:0
[   74.000789]  free:381 slab_reclaimable:4214 slab_unreclaimable:5852
[   74.000789]  mapped:529 shmem:2 pagetables:112 bounce:0
[   74.000789]  free_cma:0
[   74.011495] DMA32 free:1524kB min:1576kB low:1968kB high:2364kB active_anon:9712kB inactive_anon:0kB active_file:0kB inactive_file:8kB unevictable:90436kB isolated(anon):0kB isolated(file):0kB present:261696kB managed:155776kB mlocked:8kB dirty:0kB writeback:0kB mapped:2116kB shmem:8kB slab_reclaimable:16856kB slab_unreclaimable:23408kB kernel_stack:824kB pagetables:448kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:53 all_unreclaimable? yes
[   74.025944] lowmem_reserve[]: 0 0 0
[   74.027343] DMA32: 0*4kB 0*8kB 0*16kB 1*32kB (R) 1*64kB (R) 1*128kB (R) 1*256kB (R) 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 1504kB
[   74.032051] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   74.035074] 22617 total pagecache pages
[   74.036412] 0 pages in swap cache
[   74.037672] Swap cache stats: add 0, delete 0, find 0/0
[   74.039445] Free swap  = 0kB
[   74.040415] Total swap = 0kB
[   74.043789] 65533 pages RAM
[   74.044810] 26589 pages reserved
[   74.045933] 4803 pages shared
[   74.047048] 36732 pages non-shared
[   74.048225] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[   74.050864] [  158]     0   158     4464      366      14        0             0 rc.local
[   74.053722] [  163]     0   163     1073      151       8        0             0 run-parts
[   74.056484] [  164]     0   164     4464      360      13        0             0 99-trinity
[   74.059231] [  174] 65534   174     4643     1271      14        0             0 trinity
[   74.061987] [  175]     0   175     1075      131       8        0             0 sleep
[   74.064736] [  178] 65534   178     4643     1169      14        0             0 trinity-watchdo
[   74.067841] [  195] 65534   195     4643     1234      14        0             0 trinity-child1
[   74.070628] [  196] 65534   196     5602     2198      16        0             0 trinity-child0
[   74.073684] Out of memory: Kill process 196 (trinity-child0) score 56 or sacrifice child
[   74.076465] Killed process 196 (trinity-child0) total-vm:22408kB, anon-rss:8260kB, file-rss:532kB
[   74.085512] trinity-child0 (196) used greatest stack depth: 4920 bytes left
 * Asking all remaining processes to terminate...       
killall5[221]: mount returned non-zero exit status
killall5[221]: /proc not mounted, failed to mount.

mount: proc has wrong device number or fs type proc not supported
killall5[229]: mount returned non-zero exit status
killall5[229]: /proc not mounted, failed to mount.
 * All processes ended within 1 seconds....       
/etc/rc6.d/S40umountfs: line 20: /proc/mounts: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
umount: /var/run: not mounted
[   83.899529] BUG: Bad page state in process rm  pfn:0b0ce
[   83.902401] page:ffff88000d646380 count:0 mapcount:0 mapping:          (null) index:0x0
[   83.905130] page flags: 0x20000000004c(referenced|uptodate|active)
[   83.907576] CPU: 0 PID: 279 Comm: rm Not tainted 3.10.0-rc4-04726-g5e81a2f #17
[   83.909891]  ffff88000d646380 ffff880007d65bb8 ffffffff82563b91 0000000000000007
[   83.912509]  ffff88000d646380 ffff880007d65bd8 ffffffff81133510 000020000000004c
[   83.915197]  ffff88000d646380 ffff880007d65c28 ffffffff811347c3 ffff8800009d0000
[   83.917867] Call Trace:
[   83.918674]  [<ffffffff82563b91>] dump_stack+0x95/0x102
[   83.920405]  [<ffffffff81133510>] bad_page+0x130/0x158
[   83.922041]  [<ffffffff811347c3>] free_pages_prepare+0x8b/0x1e3
[   83.923856]  [<ffffffff81135549>] free_hot_cold_page+0x28/0x1cf
[   83.925661]  [<ffffffff82586ad0>] ? _raw_spin_unlock_irqrestore+0x6b/0xc6
[   83.927812]  [<ffffffff81135c92>] free_hot_cold_page_list+0x30/0x5a
[   83.929670]  [<ffffffff8113a625>] release_pages+0x251/0x267
[   83.931468]  [<ffffffff8112a945>] ? delete_from_page_cache+0x48/0x9e
[   83.933549]  [<ffffffff8113aecb>] __pagevec_release+0x2b/0x3d
[   83.935380]  [<ffffffff8113b592>] truncate_inode_pages_range+0x1b0/0x7ce
[   83.937582]  [<ffffffff810e76e3>] ? put_lock_stats.isra.20+0x1c/0x53
[   83.939564]  [<ffffffff810e782d>] ? lock_release_holdtime+0x113/0x11f
[   83.941762]  [<ffffffff8113bbc4>] truncate_inode_pages+0x14/0x1d
[   83.943793]  [<ffffffff8119b7ab>] evict+0x11f/0x233
[   83.945296]  [<ffffffff8119c946>] iput+0x1a5/0x217
[   83.946837]  [<ffffffff8118f559>] do_unlinkat+0x19b/0x25a
[   83.948456]  [<ffffffff810ea9cb>] ? trace_hardirqs_on_caller+0x210/0x2ce
[   83.950504]  [<ffffffff8144492e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   83.952476]  [<ffffffff8118f651>] SyS_unlinkat+0x39/0x4c
[   83.954178]  [<ffffffff82588756>] system_call_fastpath+0x1a/0x1f
[   83.956018] Disabling lock debugging due to kernel taint
umount: /var/lock: not mounted
umount: /dev/shm: not mounted
mount: / is busy
 * Will now restart
[   84.017709] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[   84.023646] Restarting system.
[   84.024629] reboot: machine restart
Elapsed time: 90

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bisect-5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96-x86_64-randconfig-a07-0612-BUG:-Bad-page-state-in-process-37783.log"

git checkout 1f6587114a689a5d7fdfb0d4abc818117e3182a5
Previous HEAD position was 5e81a2f... INFO: suspicious RCU usage.
HEAD is now at 1f65871... ipc: move rcu lock out of ipc_addid
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:1f6587114a689a5d7fdfb0d4abc818117e3182a5:bisect-net
 TEST FAILURE
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-athens-59899-20130613090214-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-18432-20130612211951-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-22437-20130612214601-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-22585-20130612211941-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-30057-20130612211915-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-30395-20130612211931-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-35568-20130612211942-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-37816-20130612211929-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-49336-20130612214604-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-lkp-nex04-60125-20130612214644-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-roam-19964-20130612225228-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-roam-22615-20130612225234-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-roam-35397-20130612225409-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-roam-38538-20130612225349-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-vp-26388-20130612222847-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-vp-29181-20130612222847-3.10.0-rc4-04725-g1f65871-18
/kernel/x86_64-randconfig-a07-0612/1f6587114a689a5d7fdfb0d4abc818117e3182a5/dmesg-kvm-xbm-25729-20130612225520-3.10.0-rc4-04725-g1f65871-18

bisect: bad commit 1f6587114a689a5d7fdfb0d4abc818117e3182a5
git checkout v3.9
Previous HEAD position was 1f65871... ipc: move rcu lock out of ipc_addid
HEAD is now at c1be5a5... Linux 3.9
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:c1be5a5b1b355d40e6cf79cc979eb66dafa24ad1:bisect-net

2013-06-13-10:33:18 c1be5a5b1b355d40e6cf79cc979eb66dafa24ad1 compiling
560 real  2323 user  186 sys  447.63% cpu 	x86_64-randconfig-a07-0612

2013-06-13-10:42:56 detecting boot state 3.9.0...	1	4	7....	10..	15	16	17	19	22	27	30 SUCCESS

bisect: good commit v3.9
git bisect start 1f6587114a689a5d7fdfb0d4abc818117e3182a5 v3.9 --
Previous HEAD position was c1be5a5... Linux 3.9
HEAD is now at 805a6af... Linux 3.2
Bisecting: 9209 revisions left to test after this (roughly 13 steps)
[9992ba72327fa0d8bdc9fb624e80f5cce338a711] Merge tag 'sound-3.10' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect run /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:9992ba72327fa0d8bdc9fb624e80f5cce338a711:bisect-net

2013-06-13-10:53:24 9992ba72327fa0d8bdc9fb624e80f5cce338a711 compiling
312 real  2438 user  190 sys  840.88% cpu 	x86_64-randconfig-a07-0612

2013-06-13-10:58:54 detecting boot state 3.9.0-09316-g9992ba7....	1.	2	4	5...	6	7.....	8..	9.	10....	11....	12	14.	15	17	19	21	22	24	26	28	29	30 SUCCESS

Bisecting: 4606 revisions left to test after this (roughly 12 steps)
[165b199f615ff5cbbd2a241526673d8643bedc30] Merge remote-tracking branch 'asoc/topic/sn95031' into asoc-next
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:165b199f615ff5cbbd2a241526673d8643bedc30:bisect-net

2013-06-13-11:22:30 165b199f615ff5cbbd2a241526673d8643bedc30 compiling
313 real  2442 user  185 sys  839.58% cpu 	x86_64-randconfig-a07-0612

2013-06-13-11:27:58 detecting boot state 3.10.0-rc4-00118-g165b199...	1	2	6	8	9	12	14.	15	19	20.	22.	23	24	27	29	30 SUCCESS

Bisecting: 2290 revisions left to test after this (roughly 11 steps)
[a9ee2e0f380766c3edaa0c00513a2a3771472322] Merge remote-tracking branch 'watchdog/master'
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:a9ee2e0f380766c3edaa0c00513a2a3771472322:bisect-net

2013-06-13-11:39:05 a9ee2e0f380766c3edaa0c00513a2a3771472322 compiling
305 real  2384 user  180 sys  839.23% cpu 	x86_64-randconfig-a07-0612

2013-06-13-11:44:30 detecting boot state 3.10.0-rc4-02434-ga9ee2e0....	1	7	9.	11	15	16	22	26	27	30 SUCCESS

Bisecting: 1170 revisions left to test after this (roughly 10 steps)
[bfc5068e4692d31dc4d17b1e290ca67fe6c331e8] Merge remote-tracking branch 'mailbox/dbx500-prcmu-mailbox'
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:bfc5068e4692d31dc4d17b1e290ca67fe6c331e8:bisect-net

2013-06-13-11:52:06 bfc5068e4692d31dc4d17b1e290ca67fe6c331e8 compiling
302 real  2414 user  185 sys  860.55% cpu 	x86_64-randconfig-a07-0612

2013-06-13-11:57:25 detecting boot state 3.10.0-rc4-03554-gbfc5068.....	2...	3	4.	6	7	11.	13	14..	16...	18	19	20.	22.	24	26	27	28	29.	30 SUCCESS

Bisecting: 595 revisions left to test after this (roughly 9 steps)
[66cb7925f318acb04983ffc13faed70edacf7709] Merge remote-tracking branch 'samsung/for-next'
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:66cb7925f318acb04983ffc13faed70edacf7709:bisect-net

2013-06-13-12:15:59 66cb7925f318acb04983ffc13faed70edacf7709 compiling
287 real  2430 user  183 sys  910.06% cpu 	x86_64-randconfig-a07-0612

2013-06-13-12:20:59 detecting boot state 3.10.0-rc4-04129-g66cb792...	5	6	8.	10	16.	20	22	28......................	30 SUCCESS

Bisecting: 297 revisions left to test after this (roughly 8 steps)
[1051b6d30fb5ad5fe0db180edccf86c2bc9f04a6] mm/tile: prepare for removing num_physpages and simplify mem_init()
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:1051b6d30fb5ad5fe0db180edccf86c2bc9f04a6:bisect-net

2013-06-13-12:39:03 1051b6d30fb5ad5fe0db180edccf86c2bc9f04a6 compiling
293 real  2430 user  183 sys  892.43% cpu 	x86_64-randconfig-a07-0612

2013-06-13-12:44:10 detecting boot state 3.10.0-rc4-04427-g1051b6d..... TEST FAILURE
dmesg-kvm-vp-26573-20130613124817-3.10.0-rc4-04427-g1051b6d-44
dmesg-kvm-vp-30907-20130613124818-3.10.0-rc4-04427-g1051b6d-44
dmesg-kvm-xgwo-22547-20130613124559-3.10.0-rc4-04427-g1051b6d-44

Bisecting: 148 revisions left to test after this (roughly 7 steps)
[351c52b20c1545f39e578dc38ecde2c5068c2dc6] drivers/scsi/dmx3191d.c: convert to module_pci_driver
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:351c52b20c1545f39e578dc38ecde2c5068c2dc6:bisect-net

2013-06-13-12:46:42 351c52b20c1545f39e578dc38ecde2c5068c2dc6 compiling
289 real  2466 user  183 sys  914.03% cpu 	x86_64-randconfig-a07-0612

2013-06-13-12:51:40 detecting boot state 3.10.0-rc4-04278-g351c52b...	1	2	5.	7	9	15	22	30 SUCCESS

Bisecting: 74 revisions left to test after this (roughly 6 steps)
[35f49632f32139ddf803dcb35173898e8fb2f8d8] vmcore-allow-user-process-to-remap-elf-note-segment-buffer-fix
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:35f49632f32139ddf803dcb35173898e8fb2f8d8:bisect-net

2013-06-13-12:57:42 35f49632f32139ddf803dcb35173898e8fb2f8d8 compiling
299 real  2412 user  186 sys  867.00% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:02:57 detecting boot state 3.10.0-rc4-04352-g35f4963...	3	4.	7	8..	9	13	14	15.	16	24	25.	26	27.............	30 SUCCESS

Bisecting: 37 revisions left to test after this (roughly 5 steps)
[47856ff3aa81669131eaae77bfdc11d74de82d68] mm: report available pages as "MemTotal" for each NUMA node
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:47856ff3aa81669131eaae77bfdc11d74de82d68:bisect-net

2013-06-13-13:20:28 47856ff3aa81669131eaae77bfdc11d74de82d68 compiling
469 real  2391 user  185 sys  549.36% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:28:31 detecting boot state 3.10.0-rc4-04389-g47856ff.... TEST FAILURE
dmesg-kvm-roam-29380-20130613133045-3.10.0-rc4-04389-g47856ff-47
dmesg-kvm-waimea-3709-20130613133325-3.10.0-rc4-04389-g47856ff-47
dmesg-kvm-waimea-3785-20130613133329-3.10.0-rc4-04389-g47856ff-47
dmesg-kvm-waimea-26529-20130613133334-3.10.0-rc4-04389-g47856ff-47

Bisecting: 18 revisions left to test after this (roughly 4 steps)
[e923a66867a8b39da16382f81547193046d2fc6f] mm/hugetlb: remove hugetlb_prefault
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:e923a66867a8b39da16382f81547193046d2fc6f:bisect-net

2013-06-13-13:30:33 e923a66867a8b39da16382f81547193046d2fc6f compiling
282 real  2439 user  193 sys  930.92% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:35:30 detecting boot state 3.10.0-rc4-04370-ge923a66.... TEST FAILURE
dmesg-kvm-kbuild-28150-20130613133058-3.10.0-rc4-04370-ge923a66-48

Bisecting: 8 revisions left to test after this (roughly 3 steps)
[eeb9bfc39ed70ee5c389d6c9be555588e1284e62] mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:eeb9bfc39ed70ee5c389d6c9be555588e1284e62:bisect-net

2013-06-13-13:37:32 eeb9bfc39ed70ee5c389d6c9be555588e1284e62 compiling
282 real  2403 user  188 sys  919.15% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:42:27 detecting boot state 3.10.0-rc4-04361-geeb9bfc.... TEST FAILURE
dmesg-kvm-roam-840-20130613134440-3.10.0-rc4-04361-geeb9bfc-49
dmesg-kvm-waimea-26279-20130613134725-3.10.0-rc4-04361-geeb9bfc-49
dmesg-kvm-kbuild-45346-20130613133759-3.10.0-rc4-04361-geeb9bfc-49

Bisecting: 4 revisions left to test after this (roughly 2 steps)
[0436c4fab7d0f5441fe7307f52801a573ba61f4a] memcg: update TODO list in Documentation
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:0436c4fab7d0f5441fe7307f52801a573ba61f4a:bisect-net

2013-06-13-13:44:28 0436c4fab7d0f5441fe7307f52801a573ba61f4a compiling
295 real  2445 user  195 sys  894.53% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:49:38 detecting boot state 3.10.0-rc4-04356-g0436c4f...	3	10	17	26	30 SUCCESS

Bisecting: 2 revisions left to test after this (roughly 1 step)
[f8d52137ba38f8a2770dea83a25a642efa2d0beb] mm: pagevec: defer deciding which LRU to add a page to until pagevec drain time
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:f8d52137ba38f8a2770dea83a25a642efa2d0beb:bisect-net

2013-06-13-13:53:39 f8d52137ba38f8a2770dea83a25a642efa2d0beb compiling
279 real  2447 user  189 sys  945.12% cpu 	x86_64-randconfig-a07-0612

2013-06-13-13:58:33 detecting boot state 3.10.0-rc4-04358-gf8d5213....	10	15	23	25	28	30 SUCCESS

Bisecting: 0 revisions left to test after this (roughly 1 step)
[ebf2ee3010dedb4177eee18e01be00b5a7b0bc24] mm: remove lru parameter from __pagevec_lru_add and remove parts of pagevec API
running /c/kernel-tests/bisect-test-boot-failure.sh /home/wfg/mmotm/obj-bisect
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:ebf2ee3010dedb4177eee18e01be00b5a7b0bc24:bisect-net

2013-06-13-14:03:38 ebf2ee3010dedb4177eee18e01be00b5a7b0bc24 compiling
307 real  2442 user  184 sys  854.42% cpu 	x86_64-randconfig-a07-0612

2013-06-13-14:09:08 detecting boot state 3.10.0-rc4-04360-gebf2ee3...	7	13	18.	26	29	30 SUCCESS

eeb9bfc39ed70ee5c389d6c9be555588e1284e62 is the first bad commit
commit eeb9bfc39ed70ee5c389d6c9be555588e1284e62
Author: Mel Gorman <mgorman@suse.de>
Date:   Thu Jun 6 10:40:03 2013 +1000

    mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru
    
    Similar to __pagevec_lru_add, this patch removes the LRU parameter from
    __lru_cache_add and lru_cache_add_lru as the caller does not control the
    exact LRU the page gets added to.  lru_cache_add_lru gets renamed to
    lru_cache_add the name is silly without the lru parameter.  With the
    parameter removed, it is required that the caller indicate if they want
    the page added to the active or inactive list by setting or clearing
    PageActive respectively.
    
    [akpm@linux-foundation.org: Suggested the patch]
    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Cc: Jan Kara <jack@suse.cz>
    Cc: Rik van Riel <riel@redhat.com>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>
    Cc: Andrew Perepechko <anserper@ya.ru>
    Cc: Robin Dong <sanbai@taobao.com>
    Cc: Theodore Tso <tytso@mit.edu>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: Bernd Schubert <bernd.schubert@fastmail.fm>
    Cc: David Howells <dhowells@redhat.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

:040000 040000 a518294218cba5c61d1781e8570fa54d283f141e ff4d738f224ea0388c012879b98eece6971b6f3d M	include
:040000 040000 bcbf21c3d4af91ea64cc29c8741454670df737db 0386cf87757a754237d31b1a196a5d16424e4aac M	mm
bisect run success
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:ebf2ee3010dedb4177eee18e01be00b5a7b0bc24:bisect-net

2013-06-13-14:14:10 ebf2ee3010dedb4177eee18e01be00b5a7b0bc24 reuse /kernel/x86_64-randconfig-a07-0612/ebf2ee3010dedb4177eee18e01be00b5a7b0bc24/vmlinuz-3.10.0-rc4-04360-gebf2ee3

2013-06-13-14:14:10 detecting boot state ...	5	20	22	26	32.	37	43	47	50	54	62	64	70	75	80	86	87..........	88..............	90 SUCCESS

ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96:bisect-net
 TEST FAILURE
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-40192-20130613103014-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-40752-20130613103122-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-41232-20130613103022-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-49242-20130613103014-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-53156-20130613103000-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-63292-20130613103135-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-inn-756-20130613103115-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-26019-20130613102646-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-29587-20130612221718-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-31462-20130612221727-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-31646-20130612221748-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-31824-20130612221750-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-32060-20130613102704-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-48678-20130613102656-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-50871-20130613102645-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-kbuild-60163-20130613102708-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-vp-26337-20130613103403-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-vp-27184-20130613103410-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-vp-29406-20130613103417-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-vp-29613-20130612222602-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-vp-35805-20130612222604-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-waimea-26426-20130612222705-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-waimea-28588-20130613103557-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-waimea-3347-20130613103624-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-waimea-3709-20130612222652-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-xbm-25474-20130612222532-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-xgwo-19317-20130613103410-3.10.0-rc4-04726-g5e81a2f-17
/kernel/x86_64-randconfig-a07-0612/5e81a2f5e9ffa505e6ad649a9b1b1b7e03b61b96/dmesg-kvm-xgwo-22026-20130613103406-3.10.0-rc4-04726-g5e81a2f-17

[detached HEAD ca47554] Revert "mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
 4 files changed, 20 insertions(+), 16 deletions(-)
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:ca47554a03c18011f31a5566878d072793c049ab:bisect-net

2013-06-13-14:37:43 ca47554a03c18011f31a5566878d072793c049ab compiling

2013-06-13-14:42:45 detecting boot state 3.10.0-rc4-04727-gca47554...	3	6	11	13	15	18	22.	23	24.	25	28	29	33	36	38	48	51	52	54	59	63	64	69.	72	74	80	84	89............	90 SUCCESS


========= upstream =========
Fetching linus
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:26e04462c8b78d079d3231396ec72d58a14f114b:bisect-net

2013-06-13-15:06:23 26e04462c8b78d079d3231396ec72d58a14f114b reuse /kernel/x86_64-randconfig-a07-0612/26e04462c8b78d079d3231396ec72d58a14f114b/vmlinuz-3.10.0-rc5-00167-g26e0446

2013-06-13-15:06:23 detecting boot state ...	11	12.	20	21	23.	26	28	30	32.	33..	34	36...	40	42	44	45.	47	48.	49	57.	58	63	65	67	68	69.	70	72	76	80	82	85.	89.............................	90 SUCCESS


========= linux-next =========
Fetching next
ls -a /kernel-tests/run-queue/kvm/x86_64-randconfig-a07-0612/wfg:0day:c04efed734409f5a44715b54a6ca1b54b0ccf215:bisect-net

2013-06-13-15:45:58 c04efed734409f5a44715b54a6ca1b54b0ccf215 compiling

2013-06-13-15:51:34 detecting boot state 3.10.0-rc4-next-20130607-05001-gc04efed.... TEST FAILURE
dmesg-kvm-kbuild-35055-20130613154650-3.10.0-rc4-next-20130607-05001-gc04efed-54
dmesg-kvm-kbuild-60163-20130613154651-3.10.0-rc4-next-20130607-05001-gc04efed-54
dmesg-kvm-kbuild-29205-20130613154705-3.10.0-rc4-next-20130607-05001-gc04efed-54


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.10.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
# CONFIG_AUDITSYSCALL is not set
CONFIG_AUDIT_LOGINUID_IMMUTABLE=y
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
# CONFIG_TICK_CPU_ACCOUNTING is not set
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_RCU_USER_QS=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
CONFIG_UIDGID_CONVERTED=y
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_SLUB_DEBUG is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
# CONFIG_HYPERVISOR_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=4096
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_DIRECT_GBPAGES is not set
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_I2C=y
# CONFIG_ACPI_PROCESSOR is not set
CONFIG_ACPI_IPMI=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
CONFIG_PCIEPORTBUS=y
# CONFIG_PCIEAER is not set
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_PERFORMANCE=y
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
# CONFIG_PCI_ATS is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
# CONFIG_RAPIDIO_DMA_ENGINE is not set
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
# CONFIG_RAPIDIO_TSI568 is not set
CONFIG_RAPIDIO_CPS_GEN2=y
CONFIG_RAPIDIO_TSI500=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_SUB_POLICY=y
# CONFIG_XFRM_MIGRATE is not set
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NETPRIO_CGROUP=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTSDIO=y
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIBCM203X=y
# CONFIG_BT_HCIBPA10X is not set
CONFIG_BT_HCIBFUSB=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
# CONFIG_BT_MRVL_SDIO is not set
CONFIG_BT_ATH3K=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_NFC=y
# CONFIG_NFC_NCI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
CONFIG_MTD_MAP_BANK_WIDTH_8=y
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
CONFIG_MTD_MAP_BANK_WIDTH_32=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_SC520CDP is not set
# CONFIG_MTD_NETSC520 is not set
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_SBC_GXX is not set
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
CONFIG_MTD_PMC551_DEBUG=y
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_M25P80 is not set
# CONFIG_MTD_SST25L is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
CONFIG_MTD_SM_COMMON=y
CONFIG_MTD_NAND_DENALI=y
CONFIG_MTD_NAND_DENALI_PCI=y
CONFIG_MTD_NAND_DENALI_DT=y
CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=0xFF108018
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH is not set
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_NANDSIM is not set
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_ALAUDA is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_UBI is not set
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
CONFIG_BLK_CPQ_DA=y
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_XIP=y
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
# CONFIG_BLOCKCONSOLE is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_ATMEL_PWM=y
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_INTEL_MID_PTI=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ICS932S401 is not set
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
# CONFIG_CS5535_CLOCK_EVENT_SRC is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_BMP085=y
# CONFIG_BMP085_I2C is not set
CONFIG_BMP085_SPI=y
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_IDE_GD is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
CONFIG_BLK_DEV_OFFBOARD=y
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_JMICRON=y
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
CONFIG_BLK_DEV_SVWKS=y
# CONFIG_BLK_DEV_SIIMAGE is not set
CONFIG_BLK_DEV_SIS5513=y
CONFIG_BLK_DEV_SLC90E66=y
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_ENCLOSURE is not set
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
CONFIG_SCSI_BNX2X_FCOE=y
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
# CONFIG_SCSI_MVSAS_TASKLET is not set
CONFIG_SCSI_MVUMI=y
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS_LOGGING=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
# CONFIG_SCSI_MPT3SAS_LOGGING is not set
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PCI=y
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
# CONFIG_SCSI_EATA_LINKED_COMMANDS is not set
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
# CONFIG_SCSI_INITIO is not set
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_IPR=y
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_CHELSIO_FCOE=y
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
# CONFIG_ATA_ACPI is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
# CONFIG_SATA_RCAR is not set
CONFIG_SATA_SIL=y
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
CONFIG_SATA_VIA=y
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
CONFIG_PATA_CS5536=y
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=y
CONFIG_PATA_HPT37X=y
CONFIG_PATA_HPT3X2N=y
CONFIG_PATA_HPT3X3=y
CONFIG_PATA_HPT3X3_DMA=y
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
# CONFIG_PATA_NETCELL is not set
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
CONFIG_PATA_RADISYS=y
# CONFIG_PATA_RDC is not set
CONFIG_PATA_SC1200=y
# CONFIG_PATA_SCH is not set
CONFIG_PATA_SERVERWORKS=y
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=y
# CONFIG_PATA_TOSHIBA is not set
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=y
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PLATFORM=y
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
# CONFIG_MD_RAID1 is not set
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
# CONFIG_MD_MULTIPATH is not set
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_EDEBUG is not set
CONFIG_BCACHE_CLOSURES_DEBUG=y
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
# CONFIG_I2O_EXT_ADAPTEC is not set
# CONFIG_I2O_CONFIG is not set
CONFIG_I2O_BUS=y
# CONFIG_I2O_BLOCK is not set
CONFIG_I2O_SCSI=y
# CONFIG_I2O_PROC is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_DUMMY is not set
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
CONFIG_MII=y
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
CONFIG_NET_TEAM_MODE_ROUNDROBIN=y
CONFIG_NET_TEAM_MODE_RANDOM=y
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=y
# CONFIG_NET_TEAM_MODE_LOADBALANCE is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_RIONET is not set
CONFIG_TUN=y
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
CONFIG_SUNGEM_PHY=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
# CONFIG_ARCNET_RIM_I is not set
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6060=y
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_ALTEON is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
CONFIG_PCNET32=y
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
CONFIG_NET_CALXEDA_XGMAC=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=y
CONFIG_DE2104X_DSL=0
# CONFIG_TULIP is not set
# CONFIG_DE4X5 is not set
# CONFIG_WINBOND_840 is not set
# CONFIG_DM9102 is not set
CONFIG_ULI526X=y
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
CONFIG_SUNDANCE=y
CONFIG_SUNDANCE_MMIO=y
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
# CONFIG_NET_VENDOR_EXAR is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
CONFIG_IGB=y
# CONFIG_IGB_HWMON is not set
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_IXGBEVF is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_CORE=y
# CONFIG_MLX4_DEBUG is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MICROCHIP is not set
CONFIG_FEALNX=y
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
CONFIG_ETHOC=y
# CONFIG_NET_PACKET_ENGINE is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_SFC=y
CONFIG_SFC_MTD=y
# CONFIG_SFC_MCDI_MON is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
CONFIG_SMSC911X=y
# CONFIG_SMSC911X_ARCH_HOOKS is not set
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
CONFIG_CASSINI=y
# CONFIG_NIU is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
CONFIG_DEFXX_MMIO=y
# CONFIG_SKFP is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
CONFIG_BCM87XX_PHY=y
# CONFIG_ICPLUS_PHY is not set
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=y
# CONFIG_PPP_BSDCOMP is not set
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_FILTER=y
# CONFIG_PPP_MPPE is not set
CONFIG_PPP_MULTILINK=y
# CONFIG_PPPOE is not set
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
# CONFIG_USB_NET_AX8817X is not set
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
# CONFIG_USB_NET_GL620A is not set
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
# CONFIG_USB_NET_MCS7830 is not set
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
# CONFIG_USB_ALI_M5632 is not set
# CONFIG_USB_AN2720 is not set
CONFIG_USB_BELKIN=y
# CONFIG_USB_ARMLINUX is not set
# CONFIG_USB_EPSON2888 is not set
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
CONFIG_USB_NET_QMI_WWAN=y
CONFIG_USB_HSO=y
# CONFIG_USB_NET_INT51X1 is not set
CONFIG_USB_CDC_PHONET=y
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PRISM54=y
CONFIG_USB_ZD1201=y
# CONFIG_HOSTAP is not set
# CONFIG_WL_TI is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
# CONFIG_HDLC_CISCO is not set
CONFIG_HDLC_FR=y
# CONFIG_HDLC_PPP is not set
CONFIG_HDLC_X25=y
CONFIG_PCI200SYN=y
CONFIG_WANXL=y
CONFIG_PC300TOO=y
# CONFIG_FARSYNC is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_LAPBETHER=y
CONFIG_X25_ASY=y
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKEHARD is not set
CONFIG_IEEE802154_FAKELB=y
# CONFIG_IEEE802154_AT86RF230 is not set
CONFIG_IEEE802154_MRF24J40=y
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_SAMSUNG=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=y
# CONFIG_TABLET_USB_WACOM is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
# CONFIG_TOUCHSCREEN_AD7877 is not set
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_AD7879_SPI=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP_SPI=y
CONFIG_TOUCHSCREEN_DA9034=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
CONFIG_TOUCHSCREEN_PIXCIR=y
# CONFIG_TOUCHSCREEN_WM831X is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
# CONFIG_TOUCHSCREEN_WM9712 is not set
# CONFIG_TOUCHSCREEN_WM9713 is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
# CONFIG_TOUCHSCREEN_MC13783 is not set
# CONFIG_TOUCHSCREEN_USB_EGALAX is not set
# CONFIG_TOUCHSCREEN_USB_PANJIT is not set
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
# CONFIG_TOUCHSCREEN_USB_GUNZE is not set
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
# CONFIG_TOUCHSCREEN_USB_IDEALTEK is not set
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
# CONFIG_TOUCHSCREEN_USB_ELO is not set
# CONFIG_TOUCHSCREEN_USB_E2I is not set
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
# CONFIG_TOUCHSCREEN_USB_ETT_TC45USB is not set
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_W90X900 is not set
CONFIG_TOUCHSCREEN_PCAP=y
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_ARIZONA_HAPTICS is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX8925_ONKEY=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_PWM_BEEPER=y
CONFIG_INPUT_WM831X_ON=y
CONFIG_INPUT_PCAP=y
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
CONFIG_NOZOMI=y
CONFIG_ISI=y
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_MFD_HSU=y
CONFIG_SERIAL_MFD_HSU_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_TIMBERDALE is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_GENERIC_ADC_BATTERY=y
# CONFIG_MAX8925_POWER is not set
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_WM97XX is not set
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_SMB347=y
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_MC13783_ADC is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
# CONFIG_GEODE_WDT is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
# CONFIG_HPWDT_NMI_DECODING is not set
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_MFD_CROS_EC_SPI is not set
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_LPC_ICH is not set
CONFIG_LPC_SCH=y
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_DUMMY=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ARIZONA is not set
# CONFIG_REGULATOR_DA903X is not set
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8925=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_PCAP=y
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LP8788 is not set
CONFIG_REGULATOR_S2MPS11=y
# CONFIG_REGULATOR_S5M8767 is not set
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8994=y
CONFIG_REGULATOR_AS3711=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
# CONFIG_CYPRESS_FIRMWARE is not set
CONFIG_SMS_SIANO_MDTV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_TTM is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_MGA=y
CONFIG_DRM_VIA=y
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
# CONFIG_FB_MATROX_MYSTIQUE is not set
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_ATMEL_PWM is not set
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_MAX8925=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP5520 is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_LM3630=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
# CONFIG_SND_SEQ_HRTIMER_DEFAULT is not set
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_AC97_CODEC=y
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
# CONFIG_SND_ALS300 is not set
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
# CONFIG_SND_ATIIXP_MODEM is not set
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=y
# CONFIG_SND_CS46XX_NEW_DSP is not set
CONFIG_SND_CS5530=y
CONFIG_SND_CS5535AUDIO=y
CONFIG_SND_CTXFI=y
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
CONFIG_SND_GINA24=y
# CONFIG_SND_LAYLA24 is not set
CONFIG_SND_MONA=y
CONFIG_SND_MIA=y
CONFIG_SND_ECHO3G=y
CONFIG_SND_INDIGO=y
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
CONFIG_SND_ES1938=y
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_FM801=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
# CONFIG_SND_HDA_INPUT_BEEP is not set
# CONFIG_SND_HDA_INPUT_JACK is not set
# CONFIG_SND_HDA_PATCH_LOADER is not set
# CONFIG_SND_HDA_CODEC_REALTEK is not set
# CONFIG_SND_HDA_CODEC_ANALOG is not set
# CONFIG_SND_HDA_CODEC_SIGMATEL is not set
CONFIG_SND_HDA_CODEC_VIA=y
# CONFIG_SND_HDA_CODEC_HDMI is not set
# CONFIG_SND_HDA_CODEC_CIRRUS is not set
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
# CONFIG_SND_HDA_CODEC_CA0110 is not set
# CONFIG_SND_HDA_CODEC_CA0132 is not set
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
CONFIG_SND_NM256=y
# CONFIG_SND_PCXHR is not set
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=y
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
CONFIG_SND_VIRTUOSO=y
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_SPI=y
# CONFIG_SND_AT73C213 is not set
CONFIG_SND_USB=y
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_UA101 is not set
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
CONFIG_SND_USB_CAIAQ_INPUT=y
# CONFIG_SND_USB_US122L is not set
CONFIG_SND_USB_6FIRE=y
CONFIG_SND_SOC=y
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_DESIGNWARE_I2S=y
CONFIG_SND_SOC_I2C_AND_SPI=y
CONFIG_SND_SOC_ALL_CODECS=y
CONFIG_SND_SOC_ARIZONA=y
CONFIG_SND_SOC_WM_HUBS=y
CONFIG_SND_SOC_WM_ADSP=y
CONFIG_SND_SOC_AB8500_CODEC=y
CONFIG_SND_SOC_AD1836=y
CONFIG_SND_SOC_AD193X=y
CONFIG_SND_SOC_AD73311=y
CONFIG_SND_SOC_ADAU1373=y
CONFIG_SND_SOC_ADAV80X=y
CONFIG_SND_SOC_ADS117X=y
CONFIG_SND_SOC_AK4104=y
CONFIG_SND_SOC_AK4535=y
CONFIG_SND_SOC_AK4641=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK4671=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_ALC5632=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L52=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CX20442=y
CONFIG_SND_SOC_JZ4740_CODEC=y
CONFIG_SND_SOC_L3=y
CONFIG_SND_SOC_DA7210=y
CONFIG_SND_SOC_DA7213=y
CONFIG_SND_SOC_DA732X=y
CONFIG_SND_SOC_DA9055=y
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_ISABELLE=y
CONFIG_SND_SOC_LM49453=y
CONFIG_SND_SOC_MAX98088=y
CONFIG_SND_SOC_MAX98090=y
CONFIG_SND_SOC_MAX98095=y
CONFIG_SND_SOC_MAX9850=y
CONFIG_SND_SOC_HDMI_CODEC=y
CONFIG_SND_SOC_PCM3008=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2518=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA529=y
CONFIG_SND_SOC_TAS5086=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC26=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC3X=y
CONFIG_SND_SOC_TLV320DAC33=y
CONFIG_SND_SOC_UDA134X=y
CONFIG_SND_SOC_UDA1380=y
CONFIG_SND_SOC_WL1273=y
CONFIG_SND_SOC_WM0010=y
CONFIG_SND_SOC_WM1250_EV1=y
CONFIG_SND_SOC_WM2000=y
CONFIG_SND_SOC_WM2200=y
CONFIG_SND_SOC_WM5100=y
CONFIG_SND_SOC_WM5102=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8727=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8770=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8900=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8904=y
CONFIG_SND_SOC_WM8940=y
CONFIG_SND_SOC_WM8955=y
CONFIG_SND_SOC_WM8960=y
CONFIG_SND_SOC_WM8961=y
CONFIG_SND_SOC_WM8962=y
CONFIG_SND_SOC_WM8971=y
CONFIG_SND_SOC_WM8974=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_WM8983=y
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_WM8988=y
CONFIG_SND_SOC_WM8990=y
CONFIG_SND_SOC_WM8991=y
CONFIG_SND_SOC_WM8993=y
CONFIG_SND_SOC_WM8994=y
CONFIG_SND_SOC_WM8995=y
CONFIG_SND_SOC_WM8996=y
CONFIG_SND_SOC_WM9081=y
CONFIG_SND_SOC_WM9090=y
CONFIG_SND_SOC_LM4857=y
CONFIG_SND_SOC_MAX9768=y
CONFIG_SND_SOC_MAX9877=y
CONFIG_SND_SOC_MC13783=y
CONFIG_SND_SOC_ML26124=y
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
CONFIG_SOUND_TRACEINIT=y
CONFIG_SOUND_DMAP=y
CONFIG_SOUND_VMIDI=y
# CONFIG_SOUND_TRIX is not set
CONFIG_SOUND_MSS=y
# CONFIG_SOUND_MPU401 is not set
CONFIG_SOUND_PAS=y
# CONFIG_PAS_JOYSTICK is not set
CONFIG_SOUND_PSS=y
CONFIG_PSS_MIXER=y
# CONFIG_SOUND_SB is not set
CONFIG_SOUND_YM3812=y
CONFIG_SOUND_UART6850=y
CONFIG_SOUND_AEDSP16=y
CONFIG_SC6600=y
# CONFIG_SC6600_JOY is not set
CONFIG_SC6600_CDROM=4
CONFIG_SC6600_CDROMBASE=0
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
# CONFIG_HID_EZKEY is not set
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_PS3REMOTE=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
# CONFIG_USB_HID is not set
CONFIG_HID_PID=y

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=y
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
CONFIG_USB_OXU210HP_HCD=y
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
# CONFIG_USB_PRINTER is not set
CONFIG_USB_WDM=y
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=y
# CONFIG_REALTEK_AUTOPM is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
# CONFIG_USB_STORAGE_USBAT is not set
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
# CONFIG_USB_STORAGE_ALAUDA is not set
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
CONFIG_USB_STORAGE_ENE_UB6250=y

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=y
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
CONFIG_USB_SERIAL_ARK3116=y
# CONFIG_USB_SERIAL_BELKIN is not set
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_FUNSOFT=y
CONFIG_USB_SERIAL_VISOR=y
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=y
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_GARMIN=y
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=y
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
CONFIG_USB_SERIAL_MOS7840=y
# CONFIG_USB_SERIAL_MOTOROLA is not set
CONFIG_USB_SERIAL_NAVMAN=y
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=y
# CONFIG_USB_SERIAL_HP4X is not set
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
# CONFIG_USB_SERIAL_SIEMENS_MPI is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_VIVOPAY_SERIAL=y
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_ZIO=y
CONFIG_USB_SERIAL_WISHBONE=y
# CONFIG_USB_SERIAL_ZTE is not set
CONFIG_USB_SERIAL_SSU100=y
CONFIG_USB_SERIAL_QT2=y
# CONFIG_USB_SERIAL_FLASHLOADER is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_OMAP_CONTROL_USB=y
CONFIG_OMAP_USB3=y
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
CONFIG_SAMSUNG_USB3PHY=y
CONFIG_USB_ISP1301=y
# CONFIG_USB_RCAR_PHY is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_M66592=y
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
CONFIG_USB_NET2280=y
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
CONFIG_USB_ETH=y
# CONFIG_USB_ETH_RNDIS is not set
# CONFIG_USB_ETH_EEM is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=y
CONFIG_MMC_SDHCI_PLTFM=y
# CONFIG_MMC_SDHCI_PXAV3 is not set
CONFIG_MMC_SDHCI_PXAV2=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
CONFIG_MMC_REALTEK_PCI=y
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_ATMEL_PWM=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA9633=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_ADP5520 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_ACCESSIBILITY=y
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=y
CONFIG_INFINIBAND_QIB=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_OCRDMA=y
CONFIG_INFINIBAND_SRP=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=y
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
# CONFIG_UIO_NETX is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
# CONFIG_ACERHDF is not set
CONFIG_ASUS_LAPTOP=y
# CONFIG_DELL_LAPTOP is not set
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_AIO=y
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_LAPTOP_DEBUG=y
CONFIG_FUJITSU_TABLET=y
CONFIG_AMILO_RFKILL=y
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
# CONFIG_SONYPI_COMPAT is not set
CONFIG_IDEAPAD_LAPTOP=y
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
# CONFIG_SAMSUNG_Q10 is not set
CONFIG_APPLE_GMUX=y
# CONFIG_PVPANIC is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_DEBUG is not set
CONFIG_COMMON_CLK_WM831X=y
# CONFIG_COMMON_CLK_SI5351 is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_MBOX_KFIFO_SIZE=256
CONFIG_MBOX_DATA_SIZE=4
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_ARIZONA=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_KXSD9 is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
# CONFIG_AD7298 is not set
CONFIG_AD7923=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7476=y
CONFIG_AD7887=y
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1363=y
# CONFIG_MCP320X is not set
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
CONFIG_AD5421=y
CONFIG_AD5624R_SPI=y
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5504=y
# CONFIG_AD5755 is not set
CONFIG_AD5764=y
# CONFIG_AD5791 is not set
CONFIG_AD5686=y
# CONFIG_MAX517 is not set
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16136=y
# CONFIG_ADXRS450 is not set
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
# CONFIG_ADIS16480 is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y
# CONFIG_INV_MPU6050_IIO is not set

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_SENSORS_LM3533=y
CONFIG_SENSORS_TSL2563=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
# CONFIG_IIO_ST_MAGN_3AXIS is not set

#
# Triggers - standalone
#
# CONFIG_IIO_SYSFS_TRIGGER is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
# CONFIG_EXT3_FS_POSIX_ACL is not set
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
CONFIG_JFS_DEBUG=y
CONFIG_JFS_STATISTICS=y
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
CONFIG_BTRFS_FS_RUN_SANITY_TESTS=y
CONFIG_BTRFS_DEBUG=y
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_DEBUG=y
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_MAGIC_SYSRQ is not set
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_PREEMPT=y
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_BUGVERBOSE is not set
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_PROVE_RCU_DELAY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_VERBOSE=y
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_BUILD_DOCSRC=y
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
CONFIG_CPA_DEBUG=y
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
# CONFIG_CRYPTO_DES is not set
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_ISDN_DRV_LOOP is not set

--Nq2Wo0NMKNjxTN9z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
