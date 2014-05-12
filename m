Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 772E26B0035
	for <linux-mm@kvack.org>; Sun, 11 May 2014 23:06:17 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so3256464pad.25
        for <linux-mm@kvack.org>; Sun, 11 May 2014 20:06:17 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0241.outbound.protection.outlook.com. [207.46.163.241])
        by mx.google.com with ESMTPS id qe5si5647904pbc.109.2014.05.11.20.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 11 May 2014 20:06:15 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [RFC][PATCH 1/2] mm/vmalloc: Add IO mapping space reused interface.
Date: Mon, 12 May 2014 10:19:54 +0800
Message-ID: <1399861195-21087-2-git-send-email-superlibj8301@gmail.com>
In-Reply-To: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Richard Lee <superlibj8301@gmail.com>, Richard Lee <superlibj@gmail.com>

For the IO mapping, for the same physical address space maybe
mapped more than one time, for example, in some SoCs:
0x20000000 ~ 0x20001000: are global control IO physical map,
and this range space will be used by many drivers.
And then if each driver will do the same ioremap operation, we
will waste to much malloc virtual spaces.

This patch add the IO mapping space reusing interface:
- find_vm_area_paddr: used to find the exsit vmalloc area using
  the IO physical address.
- vm_area_is_aready_to_free: before vfree the IO mapped areas
  using this to do the check that if this area is used by more
  than one consumer.

Signed-off-by: Richard Lee <superlibj@gmail.com>
---
 include/linux/vmalloc.h |  5 ++++
 mm/vmalloc.c            | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 4b8a891..2b811f6 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -34,6 +34,7 @@ struct vm_struct {
 	struct page		**pages;
 	unsigned int		nr_pages;
 	phys_addr_t		phys_addr;
+	unsigned int		used;
 	const void		*caller;
 };
 
@@ -100,6 +101,10 @@ static inline size_t get_vm_area_size(const struct vm_struct *area)
 	return area->size - PAGE_SIZE;
 }
 
+extern int vm_area_is_aready_to_free(phys_addr_t addr);
+struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
+				     unsigned long *offset,
+				     unsigned long flags);
 extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
 extern struct vm_struct *get_vm_area_caller(unsigned long size,
 					unsigned long flags, const void *caller);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bf233b2..f75b7b3 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1293,6 +1293,7 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
+	vm->used = 1;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
@@ -1383,6 +1384,68 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 				  NUMA_NO_NODE, GFP_KERNEL, caller);
 }
 
+int vm_area_is_aready_to_free(phys_addr_t addr)
+{
+	struct vmap_area *va;
+
+	va = find_vmap_area((unsigned long)addr);
+	if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
+		return 1;
+
+	if (va->vm->used <= 1)
+		return 1;
+
+	--va->vm->used;
+
+	return 0;
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
+ *	Search for the kernel VM area, whoes physical address starting at @paddr,
+ *	and if the exsit VM area's size is large enough, then just return it, or
+ *	return NULL.
+ */
+struct vm_struct *find_vm_area_paddr(phys_addr_t paddr, size_t size,
+				     unsigned long *offset,
+				     unsigned long flags)
+{
+	struct vmap_area *va;
+
+	if (!(flags & VM_IOREMAP))
+		return NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+		phys_addr_t phys_addr;
+
+		if (!va || !(va->flags & VM_VM_AREA) || !va->vm)
+			continue;
+
+		phys_addr = va->vm->phys_addr;
+
+		if (paddr < phys_addr || paddr + size > phys_addr + va->vm->size)
+			continue;
+
+		*offset = paddr - phys_addr;
+
+		if (va->vm->flags & VM_IOREMAP && va->vm->size >= size) {
+			va->vm->used++;
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
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
