Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 109CD6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 04:12:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t126so66417117pgc.9
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 01:12:01 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id g125si30233940pfc.376.2017.06.05.01.11.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 01:12:00 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v2] vmalloc: show more detail info in vmallocinfo for clarify
Date: Mon, 5 Jun 2017 16:01:22 +0800
Message-ID: <1496649682-20710-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, zijun_hu@htc.com, mingo@kernel.org, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, chris@chris-wilson.co.uk, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

When ioremap a 67112960 bytes vm_area with the vmallocinfo:
 [..]
 0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
 0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap

we get the result:
 0xf1000000-0xf5001000 67112960 devm_ioremap+0x38/0x7c phys=40000000 ioremap

For the align for ioremap must be less than '1 << IOREMAP_MAX_ORDER':
	if (flags & VM_IOREMAP)
		align = 1ul << clamp_t(int, get_count_order_long(size),
			PAGE_SHIFT, IOREMAP_MAX_ORDER);

So it makes idiot like me a litter puzzle why jump the vm_area from
0xec800000-0xecbe1000 to 0xf1000000-0xf5001000, and leave
0xed000000-0xf1000000 as a big hole.

This is to show all of vm_area, including which is freeing but still in
vmap_area_list, to make it more clear about why we will get
0xf1000000-0xf5001000 int the above case. And we will get the
vmallocinfo like:
 [..]
 0xec79b000-0xec7fa000  389120 ftl_add_mtd+0x4d0/0x754 pages=94 vmalloc
 0xec800000-0xecbe1000 4067328 kbox_proc_mem_write+0x104/0x1c4 phys=8b520000 ioremap
 [..]
 0xece7c000-0xece7e000    8192 unpurged vm_area
 0xece7e000-0xece83000   20480 vm_map_ram
 0xf0099000-0xf00aa000   69632 vm_map_ram
after apply this patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
v2:
 - changed "freeing vm_area" to "unpurged vm_area" to be clearer  - Tim

 mm/vmalloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e..6ef021f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -314,6 +314,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 
 /*** Global kva allocator ***/
 
+#define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
@@ -1486,6 +1487,7 @@ struct vm_struct *remove_vm_area(const void *addr)
 		spin_lock(&vmap_area_lock);
 		va->vm = NULL;
 		va->flags &= ~VM_VM_AREA;
+		va->flags |= VM_LAZY_FREE;
 		spin_unlock(&vmap_area_lock);
 
 		vmap_debug_free_range(va->va_start, va->va_end);
@@ -2698,8 +2700,14 @@ static int s_show(struct seq_file *m, void *p)
 	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
 	 */
-	if (!(va->flags & VM_VM_AREA))
+	if (!(va->flags & VM_VM_AREA)) {
+		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
+			(void *)va->va_start, (void *)va->va_end,
+			va->va_end - va->va_start,
+			va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
+
 		return 0;
+	}
 
 	v = va->vm;
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
