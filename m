Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4AD16B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:01:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x2-v6so1923549wmc.3
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:01:10 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id c4-v6si1293034wmf.143.2018.05.23.01.01.09
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 01:01:09 -0700 (PDT)
Date: Wed, 23 May 2018 10:01:08 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC] trace when adding memory to an offline nod
Message-ID: <20180523080108.GA30350@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, dan.j.williams@intel.com

Hi guys,

while testing memhotplug, I spotted the following trace:

=====
linux kernel: WARNING: CPU: 0 PID: 64 at ./include/linux/gfp.h:467 vmemmap_alloc_block+0x4e/0xc9
linux kernel: Modules linked in: fuse(E) nf_log_ipv6(E) nf_log_ipv4(E) nf_log_common(E) xt_LOG(E) xt_limit(E) xt_pkttype(E) iscsi_ibft(E) iscsi_boot_sysfs(E) ip6t_REJECT(E) xt_tcpudp(E) nf_conntrack_ipv6(E) nf_defrag_ipv6(E) ip6table_raw(E) ipt_REJECT(E) iptable_raw(E) xt_CT(E) iptable_filter(E) ip6table_mangle(E) nf_conntrack_netbios_ns(E) nf_conntrack_broadcast(E) nf_conntrack_ipv4(E) nf_defrag_ipv4(E) ip_tables(E) xt_conntrack(E) nf_conntrack(E) ip6table_filter(E) ip6_tables(E) x_tables(E) bochs_drm(E) ttm(E) drm_kms_helper(E) drm(E) syscopyarea(E) sysfillrect(E) sysimgblt(E) fb_sys_fops(E) pcspkr(E) ppdev(E) i2c_piix4(E) joydev(E) parport_pc(E) parport(E) btrfs(E) libcrc32c(E) xor(E) zstd_decompress(E) zstd_compress(E) xxhash(E) raid6_pq(E) sr_mod(E) cdrom(E) sd_mod(E) ata_generic(E) ata_piix(E)
linux kernel:  ahci(E) libahci(E) floppy(E) serio_raw(E) libata(E) button(E) sg(E) dm_multipath(E) dm_mod(E) scsi_dh_rdac(E) scsi_dh_emc(E) scsi_dh_alua(E) scsi_mod(E) autofs4(E)
linux kernel: CPU: 0 PID: 64 Comm: kworker/u4:1 Tainted: G        W   E     4.17.0-rc5-next-20180517-1-default+ #66
linux kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
linux kernel: Workqueue: kacpi_hotplug acpi_hotplug_work_fn
linux kernel: RIP: 0010:vmemmap_alloc_block+0x4e/0xc9
linux kernel: Code: fb ff 8d 69 01 75 07 65 8b 1d 9d cb 93 7e 81 fb ff 03 00 00 76 02 0f 0b 48 63 c3 48 0f a3 05 c8 b1 b4 00 0f 92 c0 84 c0 75 02 <0f> 0b 31 c9 89 da 89 ee bf c0 06 40 01 e8 0f d1 ad ff 48 85 c0 74 
linux kernel: RSP: 0018:ffffc90000d03bf0 EFLAGS: 00010246
linux kernel: RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000008
linux kernel: RDX: 0000000000000000 RSI: 0000000000000001 RDI: 00000000000001ff
linux kernel: RBP: 0000000000000009 R08: 0000000000000001 R09: ffffc90000d03ae8
linux kernel: R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0006000000
linux kernel: R13: ffffea0005e00000 R14: ffffea0006000000 R15: 0000000000000001
linux kernel: FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
linux kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
linux kernel: CR2: 00007fa92a698018 CR3: 00000001184ce000 CR4: 00000000000006f0
linux kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
linux kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
linux kernel: Call Trace:
linux kernel:  vmemmap_populate+0xf2/0x2ae
linux kernel:  sparse_mem_map_populate+0x28/0x35
linux kernel:  sparse_add_one_section+0x4c/0x187
linux kernel:  __add_pages+0xe7/0x1a0
linux kernel:  add_pages+0x16/0x70
linux kernel:  add_memory_resource+0xa3/0x1d0
linux kernel:  add_memory+0xe4/0x110
linux kernel:  acpi_memory_device_add+0x134/0x2e0
linux kernel:  acpi_bus_attach+0xd9/0x190
linux kernel:  acpi_bus_scan+0x37/0x70
linux kernel:  acpi_device_hotplug+0x389/0x4e0
linux kernel:  acpi_hotplug_work_fn+0x1a/0x30
linux kernel:  process_one_work+0x146/0x340
linux kernel:  worker_thread+0x47/0x3e0
linux kernel:  kthread+0xf5/0x130
linux kernel:  ? max_active_store+0x60/0x60
linux kernel:  ? kthread_bind+0x10/0x10
linux kernel:  ret_from_fork+0x35/0x40
linux kernel: ---[ end trace 2e2241f4e2f2f018 ]---
====

This happens when adding memory to a node that is currently offline.

add_memory_resource()
{
	...
	new_node = !node_online(nid);
        if (new_node) {
                pgdat = hotadd_new_pgdat(nid, start);
                ret = -ENOMEM;
                if (!pgdat)
                        goto error;
        }

	ret = arch_add_memory(nid, start, size, NULL, true);
	node_set_online(nid);
	...
}

arch_add_memory() ends up in vmemmap_populate()->vmemmap_alloc_block_buf()->vmemmap_alloc_block()
vmemmap_alloc_block() calls alloc_pages_node()->__alloc_pages_node().
In __alloc_pages_node(), we have a check to see if the node where we are requesting
memory is onlined.

static inline struct page *
__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
{
	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
	VM_WARN_ON(!node_online(nid));
	...
}

But it is not, since we online the node after the call to arch_add_memory().

After thinking a while, I thought about 3 ways to go:

1) In case the memory is offlined, after allocating it, we can set some of its field
   to a "magic" value. 
   Something like:

   pgdat->node_present_pages = (-1UL)
	or
   pgdat->nr_zones = -1

   And later on, in __alloc_pages_node(), we can check for the magic value, and if it is set
   we do not check for VM_WARN_ON(!node_online(nid))


2) Move node_set_online() above arch_add_memory. Although I think we cannot really do that.
   I guess we could collide with someone seeing that we are online, when we are not 100%.


3) Live with it?

Any ideas?

Thanks
Oscar Salvador
