Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7EB6B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 19:38:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b22so472021043pfd.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 16:38:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o1si73907523pgc.285.2017.01.04.16.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 16:38:45 -0800 (PST)
Subject: [PATCH] mm: fix devm_memremap_pages crash, use mem_hotplug_{begin,
 done}
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jan 2017 16:34:38 -0800
Message-ID: <148357647831.9498.12606007370121652979.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Both arch_add_memory() and arch_remove_memory() expect a single threaded
context.

For example, arch/x86/mm/init_64.c::kernel_physical_mapping_init() does
not hold any locks over this check and branch:

    if (pgd_val(*pgd)) {
    	pud = (pud_t *)pgd_page_vaddr(*pgd);
    	paddr_last = phys_pud_init(pud, __pa(vaddr),
    				   __pa(vaddr_end),
    				   page_size_mask);
    	continue;
    }

    pud = alloc_low_page();
    paddr_last = phys_pud_init(pud, __pa(vaddr), __pa(vaddr_end),
    			   page_size_mask);

The result is that two threads calling devm_memremap_pages()
simultaneously can end up colliding on pgd initialization. This leads to
crash signatures like the following where the loser of the race
initializes the wrong pgd entry:

    BUG: unable to handle kernel paging request at ffff888ebfff0000
    IP: [<ffffffff8149e1e6>] memcpy_erms+0x6/0x10
    PGD 2f8e8fc067 PUD 0 /* <---- Invalid PUD */
    Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
    CPU: 54 PID: 3818 Comm: systemd-udevd Not tainted 4.6.7+ #13
    task: ffff882fac290040 ti: ffff882f887a4000 task.ti: ffff882f887a4000
    RIP: 0010:[<ffffffff8149e1e6>]  [<ffffffff8149e1e6>] memcpy_erms+0x6/0x10
    [..]
    Call Trace:
     [<ffffffffc0119045>] ? pmem_do_bvec+0x205/0x370 [nd_pmem]
     [<ffffffff8145b82a>] ? blk_queue_enter+0x3a/0x280
     [<ffffffffc0119418>] pmem_rw_page+0x38/0x80 [nd_pmem]
     [<ffffffff812b1c94>] bdev_read_page+0x84/0xb0

Hold the standard memory hotplug mutex over calls to
arch_{add,remove}_memory().

Cc: <stable@vger.kernel.org>
Cc: Christoph Hellwig <hch@lst.de>
Fixes: 41e94a851304 ("add devm_memremap_pages")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index b501e390bb34..9ecedc28b928 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -246,7 +246,9 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
+	mem_hotplug_done();
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
@@ -358,7 +360,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
+	mem_hotplug_begin();
 	error = arch_add_memory(nid, align_start, align_size, true);
+	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
