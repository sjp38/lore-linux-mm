Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02A1E6B05DE
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 06:15:01 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so16338763pgq.12
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 03:15:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184-v6sor4011779pgi.55.2018.11.08.03.14.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 03:14:59 -0800 (PST)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH] mm:vmalloc add vm_struct for vm_map_ram
Date: Thu,  8 Nov 2018 19:14:49 +0800
Message-Id: <1541675689-13363-1-git-send-email-huangzhaoyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>, David Rientjes <rientjes@google.com>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

There is no caller and pages information etc for the area which is
created by vm_map_ram as well as the page count > VMAP_MAX_ALLOC.
Add them on in this commit.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
---
 mm/vmalloc.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cfea25b..819b690 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -45,7 +45,8 @@ struct vfree_deferred {
 static DEFINE_PER_CPU(struct vfree_deferred, vfree_deferred);
 
 static void __vunmap(const void *, int);
-
+static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
+			      unsigned long flags, const void *caller);
 static void free_work(struct work_struct *w)
 {
 	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
@@ -1138,6 +1139,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	BUG_ON(!va);
 	debug_check_no_locks_freed((void *)va->va_start,
 				    (va->va_end - va->va_start));
+	kfree(va->vm);
 	free_unmap_vmap_area(va);
 }
 EXPORT_SYMBOL(vm_unmap_ram);
@@ -1170,6 +1172,8 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 		addr = (unsigned long)mem;
 	} else {
 		struct vmap_area *va;
+		struct vm_struct *area;
+
 		va = alloc_vmap_area(size, PAGE_SIZE,
 				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
 		if (IS_ERR(va))
@@ -1177,11 +1181,17 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 
 		addr = va->va_start;
 		mem = (void *)addr;
+		area = kzalloc_node(sizeof(*area), GFP_KERNEL, node);
+		if (likely(area)) {
+			setup_vmalloc_vm(area, va, 0, __builtin_return_address(0));
+			va->flags &= ~VM_VM_AREA;
+		}
 	}
 	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
+
 	return mem;
 }
 EXPORT_SYMBOL(vm_map_ram);
@@ -2688,19 +2698,19 @@ static int s_show(struct seq_file *m, void *p)
 	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
 	 */
-	if (!(va->flags & VM_VM_AREA)) {
-		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
-			(void *)va->va_start, (void *)va->va_end,
-			va->va_end - va->va_start,
-			va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
-
+	if (!(va->flags & VM_VM_AREA) && !va->vm)
 		return 0;
-	}
 
 	v = va->vm;
 
-	seq_printf(m, "0x%pK-0x%pK %7ld",
-		v->addr, v->addr + v->size, v->size);
+	if (!(va->flags & VM_VM_AREA))
+		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
+				(void *)va->va_start, (void *)va->va_end,
+				va->va_end - va->va_start,
+				va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
+	else
+		seq_printf(m, "0x%pK-0x%pK %7ld",
+				v->addr, v->addr + v->size, v->size);
 
 	if (v->caller)
 		seq_printf(m, " %pS", v->caller);
-- 
1.9.1
