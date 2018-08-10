Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C45FC6B000A
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:26:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4-v6so7112844wrt.2
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 05:26:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11-v6sor350856wmc.75.2018.08.10.05.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 05:26:56 -0700 (PDT)
Date: Fri, 10 Aug 2018 14:26:54 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding
 memory
Message-ID: <20180810122654.GA21049@techadventures.net>
References: <20180809025409.31552-1-rashmica.g@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180809025409.31552-1-rashmica.g@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, akpm@linux-foundation.org, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, malat@debian.org, bhelgaas@google.com, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rppt@linux.vnet.ibm.com

On Thu, Aug 09, 2018 at 12:54:09PM +1000, Rashmica Gupta wrote:
> When hot-removing memory release_mem_region_adjustable() splits
> iomem resources if they are not the exact size of the memory being
> hot-deleted. Adding this memory back to the kernel adds a new
> resource.
> 
> Eg a node has memory 0x0 - 0xfffffffff. Offlining and hot-removing
> 1GB from 0xf40000000 results in the single resource 0x0-0xfffffffff being
> split into two resources: 0x0-0xf3fffffff and 0xf80000000-0xfffffffff.
> 
> When we hot-add the memory back we now have three resources:
> 0x0-0xf3fffffff, 0xf40000000-0xf7fffffff, and 0xf80000000-0xfffffffff.
> 
> Now if we try to remove some memory that overlaps these resources,
> like 2GB from 0xf40000000, release_mem_region_adjustable() fails as it
> expects the chunk of memory to be within the boundaries of a single
> resource.
> 
> This patch adds a function request_resource_and_merge(). This is called
> instead of request_resource_conflict() when registering a resource in
> add_memory(). It calls request_resource_conflict() and if hot-removing is
> enabled (if it isn't we won't get resource fragmentation) we attempt to
> merge contiguous resources on the node.
> 
> Signed-off-by: Rashmica Gupta <rashmica.g@gmail.com>

Hi Rashmica,

Unfortunately this patch breaks memory-hotplug.

It makes my kernel go boom when hot-adding memory via qemu:

Way to reproduce it:

# connect to a qemu console
# add hot memory:

(qemu) object_add memory-backend-ram,id=ram0,size=1G
(qemu) device_add pc-dimm,id=dimm2,memdev=ram0,node=1

and...

kernel: BUG: unable to handle kernel paging request at 0000000000029ce8
kernel: PGD 0 P4D 0 
kernel: Oops: 0000 [#1] SMP PTI
kernel: CPU: 1 PID: 7 Comm: kworker/u4:0 Tainted: G            E     4.18.0-rc8-next-20180810-1-default+ #292
kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
kernel: Workqueue: kacpi_hotplug acpi_hotplug_work_fn
kernel: RIP: 0010:request_resource_and_merge+0x51/0x120
kernel: Code: df e8 13 e6 ff ff c6 05 bc eb 50 01 00 48 85 c0 74 09 5b 5d 41 5c 41 5d 41 5e c3 4a 8b 04 e5 40 e6 00 82 48 c7 c7 d0 70 58 82 <4c> 8b a8 e8 9c 02 00 4d 89 ec 4c 03 a8 f8 9c 02 00 e8 89 aa 57 00
kernel: RSP: 0018:ffffc90000367d48 EFLAGS: 00010246
kernel: RAX: 0000000000000000 RBX: ffffffff81e4e060 RCX: 000000013fffffff
kernel: RDX: 0000000100000000 RSI: ffff880077467580 RDI: ffffffff825870d0
kernel: RBP: ffff880077467580 R08: ffff88007ffabcf0 R09: ffff880077467580
kernel: R10: 0000000000000000 R11: ffff8800376eec09 R12: 0000000000000001
kernel: R13: 0000000040000000 R14: 0000000000000001 R15: 0000000000000001
kernel: FS:  0000000000000000(0000) GS:ffff88007db00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000029ce8 CR3: 00000000783ac000 CR4: 00000000000006a0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kernel: Call Trace:
kernel:  add_memory+0x68/0x120
kernel:  acpi_memory_device_add+0x134/0x2e0
kernel:  acpi_bus_attach+0xd9/0x190
kernel:  acpi_bus_scan+0x37/0x70
kernel:  acpi_device_hotplug+0x389/0x4e0
kernel:  acpi_hotplug_work_fn+0x1a/0x30
kernel:  process_one_work+0x15f/0x350
kernel:  worker_thread+0x49/0x3e0
kernel:  kthread+0xf5/0x130
kernel:  ? max_active_store+0x60/0x60
kernel:  ? kthread_bind+0x10/0x10
kernel:  ret_from_fork+0x35/0x40
kernel: Modules linked in: af_packet(E) xt_tcpudp(E) ipt_REJECT(E) xt_conntrack(E) nf_conntrack(E) nf_defrag_ipv4(E) ip_set(E) nfnetlink(E) ebtable_nat(E) ebtable_broute(E) bridge(E) stp(E) llc(E) iptable_mangle(E) iptable_raw(E) iptable_security(E) ebtable_filter(E) ebtables(E) iptable_filter(E) ip_tables(E) x_tables(E) bochs_drm(E) ttm(E) drm_kms_helper(E) drm(E) virtio_net(E) net_failover(E) i2c_piix4(E) parport_pc(E) parport(E) failover(E) syscopyarea(E) sysfillrect(E) sysimgblt(E) fb_sys_fops(E) nfit(E) libnvdimm(E) button(E) pcspkr(E) btrfs(E) libcrc32c(E) xor(E) zstd_decompress(E) zstd_compress(E) xxhash(E) raid6_pq(E) sd_mod(E) ata_generic(E) ata_piix(E) ahci(E) libahci(E) virtio_pci(E) virtio_ring(E) virtio(E) serio_raw(E) libata(E) sg(E) scsi_mod(E) autofs4(E)
kernel: CR2: 0000000000029ce8
kernel: ---[ end trace be1a8c4d1824ebf4 ]---
kernel: RIP: 0010:request_resource_and_merge+0x51/0x120
kernel: Code: df e8 13 e6 ff ff c6 05 bc eb 50 01 00 48 85 c0 74 09 5b 5d 41 5c 41 5d 41 5e c3 4a 8b 04 e5 40 e6 00 82 48 c7 c7 d0 70 58 82 <4c> 8b a8 e8 9c 02 00 4d 89 ec 4c 03 a8 f8 9c 02 00 e8 89 aa 57 00
kernel: RSP: 0018:ffffc90000367d48 EFLAGS: 00010246
kernel: RAX: 0000000000000000 RBX: ffffffff81e4e060 RCX: 000000013fffffff
kernel: RDX: 0000000100000000 RSI: ffff880077467580 RDI: ffffffff825870d0
kernel: RBP: ffff880077467580 R08: ffff88007ffabcf0 R09: ffff880077467580
kernel: R10: 0000000000000000 R11: ffff8800376eec09 R12: 0000000000000001
kernel: R13: 0000000040000000 R14: 0000000000000001 R15: 0000000000000001
kernel: FS:  0000000000000000(0000) GS:ffff88007db00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000000000029ce8 CR3: 00000000783ac000 CR4: 00000000000006a0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


The problem is in this function you added:

+static void merge_node_resources(int nid, struct resource *parent)
+{
+       struct resource *res;
+       uint64_t start_addr;
+       uint64_t end_addr;
+       int ret;
+
+       start_addr = node_start_pfn(nid) << PAGE_SHIFT;
+       end_addr = node_end_pfn(nid) << PAGE_SHIFT;


node_start_pfn() calls NODE_DATA(nid), which then tries to get the node_data[] structure,
and then try to dereference a value in there.
This will only work for node's that are already online, but if you are adding memory
to a new node, this will blow up.

In the case we are adding memory from a node which is not onlined yet, we online it later on
in add_memory_resource:

add_memore_resource
 __try_online_node
  hotadd_new_pgdat


static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
{
        struct pglist_data *pgdat;
        unsigned long start_pfn = PFN_DOWN(start);

        pgdat = NODE_DATA(nid);
        if (!pgdat) {
                pgdat = arch_alloc_nodedata(nid);
                if (!pgdat)
                        return NULL;

                arch_refresh_nodedata(nid, pgdat);
        }
	...
	...

I did not have time to think about a fix for that, so unless we come up with something,
this will have to be reverted for 4.18.

Thanks
-- 
Oscar Salvador
SUSE L3
