Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D97176B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:59:33 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w17so771792iow.23
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:59:33 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x12si2645323iod.175.2018.02.15.08.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 08:59:32 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 1/6] mm/memory_hotplug: enforce block size aligned range check
Date: Thu, 15 Feb 2018 11:59:15 -0500
Message-Id: <20180215165920.8570-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180215165920.8570-1-pasha.tatashin@oracle.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Start qemu with the following arguments:

-m 64G,slots=2,maxmem=66G -object memory-backend-ram,id=mem1,size=2G

Which boots machine with 64G and adds a device mem1 with 2G that can be
hotplugged later.

Also make sure that .config has the following options turned on:

CONFIG_MEMORY_HOTPLUG
CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
CONFIG_ACPI_HOTPLUG_MEMORY

Using the qemu monitor hotplug the memory:

(qemu) device_add pc-dimm,id=dimm1,memdev=mem1

The operation will fail with the following trace:

WARNING: CPU: 0 PID: 91 at drivers/base/memory.c:205
pages_correctly_reserved+0xe6/0x110
Modules linked in:
CPU: 0 PID: 91 Comm: systemd-udevd Not tainted 4.16.0-rc1_pt_master #29
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
RIP: 0010:pages_correctly_reserved+0xe6/0x110
RSP: 0018:ffffbe5086b53d98 EFLAGS: 00010246
RAX: ffff9acb3fff3180 RBX: ffff9acaf7646038 RCX: 0000000000000800
RDX: ffff9acb3fff3000 RSI: 0000000000000218 RDI: 00000000010c0000
RBP: 0000000001080000 R08: ffffe81f83000040 R09: 0000000001100000
R10: ffff9acb3fff6000 R11: 0000000000000246 R12: 0000000000080000
R13: 0000000000000000 R14: ffffbe5086b53f08 R15: ffff9acaf7506f20
FS:  00007fd7f20da8c0(0000) GS:ffff9acb3fc00000(0000) knlGS:000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fd7f20f2000 CR3: 0000000ff7ac2001 CR4: 00000000001606f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 memory_subsys_online+0x44/0xa0
 device_online+0x51/0x80
 store_mem_state+0x5e/0xe0
 kernfs_fop_write+0xfa/0x170
 __vfs_write+0x2e/0x150
 ? __inode_security_revalidate+0x47/0x60
 ? selinux_file_permission+0xd5/0x130
 ? _cond_resched+0x10/0x20
 vfs_write+0xa8/0x1a0
 ? find_vma+0x54/0x60
 SyS_write+0x4d/0xb0
 do_syscall_64+0x5d/0x110
 entry_SYSCALL_64_after_hwframe+0x21/0x86
RIP: 0033:0x7fd7f0d3a840
RSP: 002b:00007fff5db77c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 00007fd7f0d3a840
RDX: 0000000000000006 RSI: 00007fd7f20f2000 RDI: 0000000000000007
RBP: 00007fd7f20f2000 R08: 000055db265c4ab0 R09: 00007fd7f20da8c0
R10: 0000000000000006 R11: 0000000000000246 R12: 000055db265c49d0
R13: 0000000000000006 R14: 000055db265c5510 R15: 000000000000000b
Code: fe ff ff 07 00 77 24 48 89 f8 48 c1 e8 17 49 8b 14 c2 48 85 d2 74 14
40 0f b6 c6 49 81 c0 00 00 20 00 48 c1 e0 04 48 01 d0 75 93 <0f> ff 31 c0
c3 b8 01 00 00 00 c3 31 d2 48 c7 c7 b0 32 67 a6 31
---[ end trace 6203bc4f1a5d30e8 ]---

The problem is detected in: drivers/base/memory.c

static bool pages_correctly_reserved(unsigned long start_pfn)
                 if (WARN_ON_ONCE(!pfn_valid(pfn)))

This function loops through every section in the newly added memory block
and verifies that the first pfn in each section is valid, meaning section
exists, has mapping (struct page array), and is online.

The block size on x86 is usually 128M, but when machine is booted with
more than 64G of memory the block size is changed to 2G:

$ cat /sys/devices/system/memory/block_size_bytes
80000000

or

$ dmesg | grep "block size"
[    0.086469] x86/mm: Memory block size: 2048MB

During memory hotplug, and hotremove we verify that the range is section
size aligned, but we actually must verify that it is block size aligned,
because that is the proper unit for hotplug operations.  See:
Documentation/memory-hotplug.txt

So, when the start_pfn of newly added memory is not block size aligned, we
can get a memory block with partially populated sections.

In our case the start_pfn starts from the last_pfn (end of physical
memory).

$ dmesg | grep last_pfn
[    0.000000] e820: last_pfn = 0x1040000 max_arch_pfn = 0x400000000

0x1040000 == 65G, and so is not 2G aligned!

The fix is to enforce that memory that is hotplugged and hotremoved is
block size aligned.

With this fix, running the above sequence yield to the following result:

(qemu) device_add pc-dimm,id=dimm1,memdev=mem1
Block size [0x80000000] unaligned hotplug range: start 0x1040000000,
							size 0x80000000
acpi PNP0C80:00: add_memory failed
acpi PNP0C80:00: acpi_memory_enable_device() error
acpi PNP0C80:00: Enumeration failure

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b2bd52ff7605..565048f496f7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1083,15 +1083,16 @@ int try_online_node(int nid)
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-	u64 start_pfn = PFN_DOWN(start);
+	unsigned long block_sz = memory_block_size_bytes();
+	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
 	u64 nr_pages = size >> PAGE_SHIFT;
+	u64 start_pfn = PFN_DOWN(start);
 
-	/* Memory range must be aligned with section */
-	if ((start_pfn & ~PAGE_SECTION_MASK) ||
-	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
-		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
-				(unsigned long long)start,
-				(unsigned long long)size);
+	/* memory range must be block size aligned */
+	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
+	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
+		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
+		       block_sz, start, size);
 		return -EINVAL;
 	}
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
