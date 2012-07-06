Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 840AF6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 03:35:33 -0400 (EDT)
Message-ID: <4FF693F6.8070505@huawei.com>
Date: Fri, 6 Jul 2012 15:29:58 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050942540.4984@router.home> <4FF5B909.30409@gmail.com> <alpine.DEB.2.00.1207051229490.8670@router.home>
In-Reply-To: <alpine.DEB.2.00.1207051229490.8670@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jiang Liu <liuj97@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012-7-6 1:36, Christoph Lameter wrote:
> On Thu, 5 Jul 2012, Jiang Liu wrote:
> 
>> 	I think here PageSlab() is used to check whether a page hosting a memory
>> object is managed/allocated by the slab allocator. If it's allocated by slab
>> allocator, we could use kfree() to free the object.
> 
> This is BS (here? what does that refer to). Could you please respond to my
> email?
> 
>> 	We encountered this issue when trying to implement physical memory hot-removal.
>> After removing a memory device, we need to tear down memory management structures
>> of the removed memory device. Those memory management structures may be allocated
>> by bootmem allocator at boot time, or allocated by slab allocator at runtime when
>> hot-adding memory device. So in our case, PageSlab() is used to distinguish between
>> bootmem allocator and slab allocator. With SLUB, some pages will never be released
>> due to the issue described above.
> 
> Trying to be more detailed that in my last email:
> 
> These compound pages could also be allocated by any other kernel subsystem
> for metadata purposes and they will never be marked as slab pages. These
> generic structures generally cannot be removed.
> 
> For the slab allocators: Only kmalloc memory uses the unmarked compound
> pages and those kmalloc objects are never recoverable. You can only
> recover objects that are in slabs marked reclaimable and those are
> properly marked as slab pages.
> 
> AFAICT the patchset is pointless.
Hi Chris,
	Seems there's a big misunderstanding here. 
	We are not trying to use PageSlab() as a common mechanism to check
whether a page could be migrated/removed. For that, we still rely on 
ZONE_MOVABLE, MIGRATE_RECLAIM, MIGRATE_MOVABLE, MIGRATE_CMA to migrate or
reclaim pages for hot-removing.
	Originally the patch is aimed to fix an issue encountered when 
hot-removing a hot-added memory device. Currently memory hotplug is only
supported with SPARSE memory model. After offlining all pages of a memory
section, we need to free resources used by "struct mem_section" itself.
That is to free section_mem_map and pageblock_flags. For memory section
created at boot time, section_mem_map and pageblock_flags are allocated
from bootmem. For memory section created at runtime, section_mem_map
and pageblock_flags are allocated from slab. So when freeing these
resources, we use PageSlab() to tell whether there are allocated from slab.
So free_section_usemap() has following code snippet.
{
        usemap_page = virt_to_page(usemap);
        /*
         * Check to see if allocation came from hot-plug-add
         */
        if (PageSlab(usemap_page)) {
                kfree(usemap);
                if (memmap)
                        __kfree_section_memmap(memmap, PAGES_PER_SECTION);
                return;
        }

        /*
         * The usemap came from bootmem. This is packed with other usemaps
         * on the section which has pgdat at boot time. Just keep it as is now.
         */

        if (memmap) {
                struct page *memmap_page;
                memmap_page = virt_to_page(memmap);

                nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
                        >> PAGE_SHIFT;

                free_map_bootmem(memmap_page, nr_pages);
        }
}

	Here if usemap is allocated from SLUB but PageSlab() incorrectly return
false, we will try to free pages allocated from slab as bootmem pages. That will
confuse the memory hotplug logic.

	And when fixing this issue, we found some other usages of PageSlab() may
have the same issue. For example:
	1) /proc/kpageflags and /proc/kpagecount may return incorrect result for
pages allocated by slab.
	2) DRBD has following comments. At first glance, it seems that it's 
	dangerous if PageSlab() to return false for pages allocated by slab.
	(With more thinking, the comments is a little out of date because now
	put_page/get_page already correctly handle compound pages, so it should
	be OK to send pages allocated from slab.)
        /* e.g. XFS meta- & log-data is in slab pages, which have a
         * page_count of 0 and/or have PageSlab() set.
         * we cannot use send_page for those, as that does get_page();
         * put_page(); and would cause either a VM_BUG directly, or
         * __page_cache_release a page that would actually still be referenced
         * by someone, leading to some obscure delayed Oops somewhere else. */
        if (disable_sendpage || (page_count(page) < 1) || PageSlab(page))
                return _drbd_no_send_page(mdev, page, offset, size, msg_flags);

	3) show_mem() on ARM and unicore32 reports much less pages used by slab
	if SLUB/SLOB is used instead of SLAB because SLUB/SLOB doesn't mark big
	compound pages with PG_slab flag.

	So we worked out the patch set to address these issues. We also found
other possible usages of the proposed macro. 
	For example, if the memory backing a "struct resource" structure is
allocated from bootmem, __release_region() shouldn't free the memory into 
slab allocator, otherwise it will trigger panic as below. This issue is 
reproducible when hot-removing a memory device present at boot time on x86
platforms. On x86 platforms, e820_reserve_resources() allocates bootmem for
all physical memory resources present at boot time. Later when those memory
devices are hot-removed, __release_region() will try to free  memory from
bootmem into slab, so trigger the panic. And a proposed fix is:
diff --git a/kernel/resource.c b/kernel/resource.c
index e1d2b8e..a40c11b 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -19,6 +19,7 @@
 #include <linux/seq_file.h>
 #include <linux/device.h>
 #include <linux/pfn.h>
+#include <linux/mm.h>
 #include <asm/io.h>


@@ -947,7 +948,8 @@ void __release_region(struct resource *parent, resource_size_t start,
                        write_unlock(&resource_lock);
                        if (res->flags & IORESOURCE_MUXED)
                                wake_up(&muxed_resource_wait);
-                       kfree(res);
+                       if (mem_managed_by_slab(res))
+                               kfree(res);
                        return;
                }
                p = &res->sibling;


------------[ cut here ]------------
kernel BUG at mm/slub.c:3471!
invalid opcode: 0000 [#1] SMP
CPU 2
Modules linked in: module(O+) cpufreq_conservative cpufreq_userspace
cpufreq_powersave acpi_cpufreq mperf fuse loop dm_mod coretemp igb bnx2
tpm_tis i2c_i801 serio_raw microcode tpm sg tpm_bios i2c_core dca iTCO_wdt
iTCO_vendor_support pcspkr button mptctl usbhid hid uhci_hcd ehci_hcd usbcore
usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan ide_pci_generic ide_core
ata_generic ata_piix libata thermal processor thermal_sys hwmon mptsas
mptscsih mptbase scsi_transport_sas scsi_mod

Pid: 30857, comm: insmod Tainted: G           O 3.4.0-rc4-memory-hotplug+ #10
Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA
RIP: 0010:[<ffffffff810d245f>]  [<ffffffff810d245f>] kfree+0x49/0xb1
RSP: 0018:ffff880c1bbd1ec8  EFLAGS: 00010246
RAX: 0060000000000400 RBX: ffff880c3ffbee60 RCX: 0000000000000082
RDX: ffffea0000000000 RSI: 0000000100000000 RDI: ffffea0030ffef80
RBP: ffff880c1bbd1ed8 R08: ffff880c1bbd1de8 R09: ffff880627802700
R10: ffffffff810c16a4 R11: 0000000000013a90 R12: ffff880c3ffbee50
R13: 0000000100000000 R14: 0000000c3fffffff R15: 0000000000000002
FS:  00007fe63ca906f0(0000) GS:ffff880627c40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fe63caca000 CR3: 000000061b2e4000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process insmod (pid: 30857, threadinfo ffff880c1bbd0000, task
ffff880c1e08ca70)
Stack:
 ffff880c3ffbee60 ffff880c3ffbee50 ffff880c1bbd1f08 ffffffff810313d0
 ffffffffa00e8090 0000000000025feb ffffffffa00ea000 0000000000000000
 ffff880c1bbd1f18 ffffffffa00ea032 ffff880c1bbd1f48 ffffffff8100020c
Call Trace:
 [<ffffffff810313d0>] __release_region+0x88/0xb4
 [<ffffffffa00ea000>] ? 0xffffffffa00e9fff
 [<ffffffffa00ea032>] test_module_init+0x32/0x36 [module]
 [<ffffffff8100020c>] do_one_initcall+0x7c/0x130
 [<ffffffff8106e9ac>] sys_init_module+0x7c/0x1c4
 [<ffffffff81310a22>] system_call_fastpath+0x16/0x1b
Code: ba 00 00 00 00 00 ea ff ff 48 c1 e0 06 48 8d 3c 10 48 8b 07 66 85 c0 79
04 48 8b 7f 30 48 8b 07 84 c0 78 12 66 f7 07 00 c0 75 04 <0f> 0b eb fe e8 44
30 fd ff eb 58 4c 8b 55 08 4c 8b 4f 30 49 8b
RIP  [<ffffffff810d245f>] kfree+0x49/0xb1
 RSP <ffff880c1bbd1ec8>
---[ end trace f5e0eba731c4d41e ]---

	Thanks!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
