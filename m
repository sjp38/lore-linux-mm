Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 3BED56B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 23:38:53 -0500 (EST)
Date: Mon, 24 Dec 2012 23:38:51 -0500 (EST)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
In-Reply-To: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
Subject: kernel BUG at mm/huge_memory.c:1798!
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

Hello all,

I found the below kernel bug using latest mainline(637704cbc95),
my hardware has 2 numa nodes, and it's easy to reproduce the issue
using LTP test case: "# ./mmap10 -a -s -c 200":

[root@localhost linux]# cat .config | grep NUMA
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_NUMA_BALANCING=y
# CONFIG_X86_NUMACHIP is not set
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
# CONFIG_NUMA_EMU is not set
CONFIG_USE_PERCPU_NUMA_NODE_ID=y
CONFIG_ACPI_NUMA=y

-----------------------------------------------------------
[  588.143072] mapcount 0 page_mapcount 3
[  588.147471] ------------[ cut here ]------------
[  588.152856] kernel BUG at mm/huge_memory.c:1798!
[  588.158125] invalid opcode: 0000 [#1] SMP 
[  588.162882] Modules linked in: ip6table_filter ip6_tables ebtable_nat ebtables bnep bluetooth rfkill iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter ip_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi vfat fat dm_mirror dm_region_hash dm_log dm_mod cdc_ether iTCO_wdt i7core_edac coretemp usbnet iTCO_vendor_support mii crc32c_intel edac_core lpc_ich shpchp ioatdma mfd_core i2c_i801 pcspkr serio_raw bnx2 microcode dca vhost_net tun macvtap macvlan kvm_intel kvm uinput mgag200 sr_mod cdrom i2c_algo_bit sd_mod drm_kms_helper crc_t10dif ata_generic pata_acpi ttm ata_piix drm libata i2c_core megaraid_sas

[  588.246517] CPU 1 
[  588.248636] Pid: 23217, comm: mmap10 Not tainted 3.8.0-rc1mainline+ #17 IBM IBM System x3400 M3 Server -[7379I08]-/69Y4356     
[  588.262171] RIP: 0010:[<ffffffff8118fac7>]  [<ffffffff8118fac7>] __split_huge_page+0x677/0x6d0
[  588.272067] RSP: 0000:ffff88017a03fc08  EFLAGS: 00010293
[  588.278235] RAX: 0000000000000003 RBX: ffff88027a6c22e0 RCX: 00000000000034d2
[  588.286394] RDX: 000000000000748b RSI: 0000000000000046 RDI: 0000000000000246
[  588.294216] RBP: ffff88017a03fcb8 R08: ffffffff819d2440 R09: 000000000000054a
[  588.302441] R10: 0000000000aaaaaa R11: 00000000ffffffff R12: 0000000000000000
[  588.310495] R13: 00007f4f11a00000 R14: ffff880179e96e00 R15: ffffea0005c08000
[  588.318640] FS:  00007f4f11f4a740(0000) GS:ffff88017bc20000(0000) knlGS:0000000000000000
[  588.327894] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  588.334569] CR2: 00000037e9ebb404 CR3: 000000017a436000 CR4: 00000000000007e0
[  588.342718] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  588.350861] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  588.359134] Process mmap10 (pid: 23217, threadinfo ffff88017a03e000, task ffff880172dd32e0)
[  588.368667] Stack:
[  588.370960]  ffff88017a540ec8 ffff88017a03fc20 ffffffff816017b5 ffff88017a03fc88
[  588.379566]  ffffffff812fa014 0000000000000000 ffff880279ebd5c0 00000000f4f11a4c
[  588.388150]  00000007f4f11f49 00000007f4f11a00 ffff88017a540ef0 ffff88017a540ee8
[  588.396711] Call Trace:
[  588.455106]  [<ffffffff816017b5>] ? rwsem_down_read_failed+0x15/0x17
[  588.518106]  [<ffffffff812fa014>] ? call_rwsem_down_read_failed+0x14/0x30
[  588.580897]  [<ffffffff815ffc04>] ? down_read+0x24/0x2b
[  588.642630]  [<ffffffff8118fb88>] split_huge_page+0x68/0xb0
[  588.703814]  [<ffffffff81190ed4>] __split_huge_page_pmd+0x134/0x330
[  588.766064]  [<ffffffff8104b997>] ? pte_alloc_one+0x37/0x50
[  588.826460]  [<ffffffff81191121>] split_huge_page_pmd_mm+0x51/0x60
[  588.887746]  [<ffffffff8119116b>] split_huge_page_address+0x3b/0x50
[  588.948673]  [<ffffffff8119121c>] __vma_adjust_trans_huge+0x9c/0xf0
[  589.008660]  [<ffffffff811650f4>] vma_adjust+0x684/0x750
[  589.066328]  [<ffffffff811653ba>] __split_vma.isra.28+0x1fa/0x220
[  589.123497]  [<ffffffff810135d1>] ? __switch_to+0x181/0x4a0
[  589.180704]  [<ffffffff811661a9>] do_munmap+0xf9/0x420
[  589.237461]  [<ffffffff8160026c>] ? __schedule+0x3cc/0x7b0
[  589.294520]  [<ffffffff8116651e>] vm_munmap+0x4e/0x70
[  589.350784]  [<ffffffff8116741b>] sys_munmap+0x2b/0x40
[  589.406971]  [<ffffffff8160a159>] system_call_fastpath+0x16/0x1b
[  589.464792] Code: 49 8b 07 a9 00 00 00 01 75 f4 e9 2d fb ff ff 41 8b 4f 18 8b 75 8c 48 c7 c7 f8 27 81 81 31 c0 83 c1 01 e8 df 63 46 00 0f 0b 0f 0b <0f> 0b 41 8b 57 18 8b 75 8c 48 c7 c7 d8 27 81 81 31 c0 83 c2 01 
[  589.595165] RIP  [<ffffffff8118fac7>] __split_huge_page+0x677/0x6d0
[  589.656000]  RSP <ffff88017a03fc08>
[  589.713937] ---[ end trace bff29bee67936f30 ]---


-- 
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
