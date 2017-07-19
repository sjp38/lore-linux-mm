Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B834D6B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:44:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so46563137pfe.11
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 03:44:12 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id j4si4157286pgt.49.2017.07.19.03.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 03:44:11 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id d193so6477003pgc.2
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 03:44:11 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH] mm/vmalloc: add vm_struct for vm_map_ram area
Date: Wed, 19 Jul 2017 18:44:03 +0800
Message-Id: <1500461043-7414-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

/proc/vmallocinfo will not show the area allocated by vm_map_ram, which
will make confusion when debug. Add vm_struct for them and show them in
proc.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/vmalloc.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e..4a2e93c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -46,6 +46,9 @@ struct vfree_deferred {
 
 static void __vunmap(const void *, int);
 
+static void setup_vmap_ram_vm(struct vm_struct *vm, struct vmap_area *va,
+				unsigned long flags, const void *caller);
+
 static void free_work(struct work_struct *w)
 {
 	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
@@ -315,6 +318,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 /*** Global kva allocator ***/
 
 #define VM_VM_AREA	0x04
+#define VM_VM_RAM	0x08
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -1141,6 +1145,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 
 	va = find_vmap_area(addr);
 	BUG_ON(!va);
+	kfree(va->vm);
 	free_unmap_vmap_area(va);
 }
 EXPORT_SYMBOL(vm_unmap_ram);
@@ -1173,6 +1178,12 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 		addr = (unsigned long)mem;
 	} else {
 		struct vmap_area *va;
+		struct vm_struct *area;
+
+		area = kzalloc_node(sizeof(*area), GFP_KERNEL, node);
+		if (unlikely(!area))
+			return NULL;
+
 		va = alloc_vmap_area(size, PAGE_SIZE,
 				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
 		if (IS_ERR(va))
@@ -1180,6 +1191,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 
 		addr = va->va_start;
 		mem = (void *)addr;
+		setup_vmap_ram_vm(area, va, 0, __builtin_return_address(0));
 	}
 	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
 		vm_unmap_ram(mem, count);
@@ -1362,6 +1374,19 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	spin_unlock(&vmap_area_lock);
 }
 
+static void setup_vmap_ram_vm(struct vm_struct *vm, struct vmap_area *va,
+			      unsigned long flags, const void *caller)
+{
+	spin_lock(&vmap_area_lock);
+	vm->flags = flags;
+	vm->addr = (void *)va->va_start;
+	vm->size = va->va_end - va->va_start;
+	vm->caller = caller;
+	va->vm = vm;
+	va->flags |= VM_VM_RAM;
+	spin_unlock(&vmap_area_lock);
+}
+
 static void clear_vm_uninitialized_flag(struct vm_struct *vm)
 {
 	/*
@@ -2698,7 +2723,7 @@ static int s_show(struct seq_file *m, void *p)
 	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
 	 */
-	if (!(va->flags & VM_VM_AREA))
+	if (!(va->flags & (VM_VM_AREA | VM_VM_RAM)))
 		return 0;
 
 	v = va->vm;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
