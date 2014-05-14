Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 74A026B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:07:16 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so1451542pbc.38
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:07:16 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0111.outbound.protection.outlook.com. [65.55.169.111])
        by mx.google.com with ESMTPS id hh2si1310983pac.43.2014.05.14.02.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 May 2014 02:07:15 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [PATCHv2 1/2] mm/vmalloc: Add IO mapping space reused interface support.
Date: Wed, 14 May 2014 16:18:51 +0800
Message-ID: <1400055532-13134-2-git-send-email-superlibj8301@gmail.com>
In-Reply-To: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
References: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, arnd@arndb.de, robherring2@gmail.com
Cc: lauraa@codeaurora.org, akpm@linux-foundation.org, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj8301@gmail.com>

For the IO mapping, the same physical address space maybe
mapped more than one time, for example, in some SoCs:
  - 0x20001000 ~ 0x20001400 --> 1KB for Dev1
  - 0x20001400 ~ 0x20001800 --> 1KB for Dev2
  and the page size is 4KB.

Then both Dev1 and Dev2 will do ioremap operations, and the IO
vmalloc area's virtual address will be aligned down to 4KB, and
the size will be aligned up to 4KB. That's to say, only one
4KB size's vmalloc area could contain Dev1 and Dev2 IO mapping area
at the same time.

For this case, we can ioremap only one time, and the later ioremap
operation will just return the exist vmalloc area.

Signed-off-by: Richard Lee <superlibj8301@gmail.com>
---
 include/linux/vmalloc.h |  5 +++
 mm/vmalloc.c            | 82 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 4b8a891..a53b70f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_VMALLOC_H
 #define _LINUX_VMALLOC_H
 
+#include <linux/atomic.h>
 #include <linux/spinlock.h>
 #include <linux/init.h>
 #include <linux/list.h>
@@ -34,6 +35,7 @@ struct vm_struct {
 	struct page		**pages;
 	unsigned int		nr_pages;
 	phys_addr_t		phys_addr;
+	atomic_t		used;
 	const void		*caller;
 };
 
@@ -100,6 +102,9 @@ static inline size_t get_vm_area_size(const struct vm_struct *area)
 	return area->size - PAGE_SIZE;
 }
 
+extern struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
+				     unsigned long *offset,
+				     unsigned long flags);
 extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
 extern struct vm_struct *get_vm_area_caller(unsigned long size,
 					unsigned long flags, const void *caller);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bf233b2..cf0093c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1293,6 +1293,7 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
+	atomic_set(&vm->used, 1);
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
@@ -1383,6 +1384,84 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 				  NUMA_NO_NODE, GFP_KERNEL, caller);
 }
 
+static int vm_area_used_inc(struct vm_struct *area)
+{
+	if (!(area->flags & VM_IOREMAP))
+		return -EINVAL;
+
+	atomic_add(1, &area->used);
+
+	return atomic_read(&va->vm->used);
+}
+
+static int vm_area_used_dec(const void *addr)
+{
+	struct vmap_area *va;
+
+	va = find_vmap_area((unsigned long)addr);
+	if (!va || !(va->flags & VM_VM_AREA))
+		return 0;
+
+	if (!(va->vm->flags & VM_IOREMAP))
+		return 0;
+
+	atomic_sub(1, &va->vm->used);
+
+	return atomic_read(&va->vm->used);
+}
+
+/**
+ *	find_vm_area_paddr  -  find a continuous kernel virtual area using the
+ *			physical addreess.
+ *	@paddr:		base physical address
+ *	@size:		size of the physical area range
+ *	@offset:	the start offset of the vm area
+ *	@flags:		%VM_IOREMAP for I/O mappings
+ *
+ *	Search for the kernel VM area, whoes physical address starting at
+ *	@paddr, and if the exsit VM area's size is large enough, then return
+ *	it with increasing the 'used' counter, or return NULL.
+ */
+struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
+				     unsigned long *offset,
+				     unsigned long flags)
+{
+	struct vmap_area *va;
+	int off;
+
+	if (!(flags & VM_IOREMAP))
+		return NULL;
+
+	size = PAGE_ALIGN((paddr & ~PAGE_MASK) + size);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+		phys_addr_t phys_addr;
+
+		if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
+			continue;
+
+		if (!(va->vm->flags & VM_IOREMAP))
+			continue;
+
+		phys_addr = va->vm->phys_addr;
+
+		off = (paddr & PAGE_MASK) - (phys_addr & PAGE_MASK);
+		if (off < 0)
+			continue;
+
+		if (off + size <= va->vm->size - PAGE_SIZE) {
+			*offset = off + (paddr & ~PAGE_MASK);
+			vm_area_used_inc(va->vm);
+			rcu_read_unlock();
+			return va->vm;
+		}
+	}
+	rcu_read_unlock();
+
+	return NULL;
+}
+
 /**
  *	find_vm_area  -  find a continuous kernel virtual area
  *	@addr:		base address
@@ -1443,6 +1522,9 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
+	if (vm_area_used_dec(addr))
+		return;
+
 	area = remove_vm_area(addr);
 	if (unlikely(!area)) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
