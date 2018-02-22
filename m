Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4126B02E0
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 09:15:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so1016393wmh.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 06:15:18 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m46si316527edc.116.2018.02.22.06.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 06:15:16 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/1] crash vmalloc_to_page()
Date: Thu, 22 Feb 2018 16:13:24 +0200
Message-ID: <20180222141324.5696-2-igor.stoppa@huawei.com>
In-Reply-To: <20180222141324.5696-1-igor.stoppa@huawei.com>
References: <20180222141324.5696-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

this patch, when used with the config file for 0day kernel test for
i386, against 4.16-rc2, causes the following:

...

[    8.686470] [TTM] Initializing DMA pool allocator
[    8.691148] WARNING: CPU: 0 PID: 1 at mm/vmalloc.c:301 vmalloc_to_page+0x360/0x370
[    8.692185] Modules linked in:
[    8.692599] CPU: 0 PID: 1 Comm: swapper Not tainted 4.16.0-rc2-00062-g79c0ef3e85c0-dirty #69
[    8.693736] EIP: vmalloc_to_page+0x360/0x370
[    8.694336] EFLAGS: 00210286 CPU: 0
[    8.694808] EAX: 00000001 EBX: 80000190 ECX: 00000000 EDX: 00000001
[    8.695621] ESI: 00000001 EDI: 82473630 EBP: 951f7a70 ESP: 951f7a58
[    8.696436]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    8.697139] CR0: 80050033 CR2: 00000000 CR3: 02477000 CR4: 000006b0
[    8.697965] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    8.698780] DR6: fffe0ff0 DR7: 00000400
[    8.699287] Call Trace:
[    8.699624]  find_vm_area+0x75/0x90
[    8.700126]  ? kfree+0x4bb/0x4d0
[    8.700577]  iounmap+0x57/0x1b0
[    8.700742]  ttm_mem_reg_iounmap+0x67/0x70
[    8.700742]  ttm_bo_move_memcpy+0x3e1/0x6a0
[    8.700742]  ? unmap_mapping_pages+0x91/0x160
[    8.700742]  ttm_bo_handle_move_mem+0x4ed/0x510
[    8.700742]  ? ttm_bo_mem_space+0x53f/0x5d0
[    8.700742]  ttm_bo_validate+0x22f/0x290
[    8.700742]  bochs_bo_pin+0x1c1/0x230
[    8.700742]  bochsfb_create+0x249/0x500
[    8.700742]  __drm_fb_helper_initial_config_and_unlock+0x2b1/0x5e0
[    8.700742]  drm_fb_helper_initial_config+0x52/0x60
[    8.700742]  bochs_fbdev_init+0xc4/0xf0
[    8.700742]  bochs_load+0xe3/0xf0
[    8.700742]  drm_dev_register+0x155/0x2d0
[    8.700742]  ? pci_enable_device_flags+0x179/0x1f0
[    8.700742]  drm_get_pci_dev+0x10b/0x270
[    8.700742]  bochs_pci_probe+0xfc/0x150
[    8.700742]  pci_device_probe+0x113/0x1c0
[    8.700742]  ? devices_kset_move_last+0xd0/0x150
[    8.700742]  driver_probe_device+0x566/0x830
[    8.700742]  ? pci_match_id+0x9/0xd0
[    8.700742]  ? pci_match_device+0x12d/0x150
[    8.700742]  __driver_attach+0x1b9/0x230
[    8.700742]  ? driver_probe_device+0x830/0x830
[    8.700742]  bus_for_each_dev+0x6f/0xc0
[    8.700742]  driver_attach+0x1e/0x20
[    8.700742]  ? driver_probe_device+0x830/0x830
[    8.700742]  bus_add_driver+0x227/0x3e0
[    8.700742]  ? pci_bus_num_vf+0x20/0x20
[    8.700742]  driver_register+0xa4/0x190
[    8.700742]  ? vgem_init+0x34f/0x34f
[    8.700742]  __pci_register_driver+0x50/0x60
[    8.700742]  bochs_init+0x44/0x46
[    8.700742]  do_one_initcall+0x4d/0x200
[    8.700742]  ? parse_args+0x243/0x4b0
[    8.700742]  ? kernel_init_freeable+0xc9/0x19f
[    8.700742]  kernel_init_freeable+0xe6/0x19f
[    8.700742]  ? rest_init+0x140/0x140
[    8.700742]  kernel_init+0x10/0x180
[    8.700742]  ? schedule_tail_wrapper+0x9/0xc
[    8.700742]  ret_from_fork+0x2e/0x38
[    8.700742] Code: 0c 89 c1 5b 0f ac d1 0c 8d 04 89 8d 04 c6 5e 5f 5d c3 89 f6 8d bc 27 00 00 00 00 0f 0b 8d b6 00 00 00 00 0f 0b e9 7d fd ff ff 90 <0f> 0b e9 9c fe ff ff 89 f6 8d bc 27 00 00 00 00 55 89 e5 e8 7c
[    8.700742] ---[ end trace dd335d17375dacda ]---
[    8.726216] struct page =   (null)
[    8.726523] bochs-drm 0000:00:02.0: fb0: bochsdrmfb frame buffer device
[    8.727887] [drm] Initialized bochs-drm 1.0.0 20130925 for 0000:00:02.0 on minor 1

...
---
 mm/vmalloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..7bd188947ffd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1469,8 +1469,11 @@ struct vm_struct *find_vm_area(const void *addr)
 	struct vmap_area *va;
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA)
+	if (va && va->flags & VM_VM_AREA) {
+		if (is_vmalloc_addr(addr))
+			pr_err("struct page = %p", vmalloc_to_page(addr));
 		return va->vm;
+	}
 
 	return NULL;
 }
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
