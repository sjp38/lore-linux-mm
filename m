Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 87E5F6B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 11:58:38 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so292450dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 08:58:37 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 2/3] ARM: static_vm: introduce an infrastructure for static mapped area
Date: Thu, 15 Nov 2012 01:55:53 +0900
Message-Id: <1352912154-16210-3-git-send-email-js1304@gmail.com>
In-Reply-To: <1352912154-16210-1-git-send-email-js1304@gmail.com>
References: <1352912154-16210-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

In current implementation, we used ARM-specific flag, that is,
VM_ARM_STATIC_MAPPING, for distinguishing ARM specific static mapped area.
The purpose of static mapped area is to re-use static mapped area when
entire physical address range of the ioremap request can be covered
by this area.

This implementation causes needless overhead for some cases.
We unnecessarily iterate vmlist for finding matched area even if there
is no static mapped area. And if there are some static mapped areas,
iterating whole vmlist is not preferable.
In fact, it is not a critical problem, because ioremap is not frequently
used. But reducing overhead is better idea.

Another reason for doing this work is for removing architecture dependency
on vmalloc layer. I think that vmlist and vmlist_lock is internal data
structure for vmalloc layer. Some codes for debugging and stat inevitably
use vmlist and vmlist_lock. But it is preferable that they are used outside
of vmalloc.c as least as possible.

Now, I introduce an ARM-specific infrastructure for static mapped area. In
the following patch, we will use this and resolve above mentioned problem.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/arm/include/asm/mach/static_vm.h b/arch/arm/include/asm/mach/static_vm.h
new file mode 100644
index 0000000..1bb6604
--- /dev/null
+++ b/arch/arm/include/asm/mach/static_vm.h
@@ -0,0 +1,45 @@
+/*
+ * arch/arm/include/asm/mach/static_vm.h
+ *
+ * Copyright (C) 2012 LG Electronics, Joonsoo Kim <js1304@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#ifndef _ASM_MACH_STATIC_VM_H
+#define _ASM_MACH_STATIC_VM_H
+
+#include <linux/types.h>
+#include <linux/vmalloc.h>
+
+struct static_vm {
+	struct static_vm	*next;
+	void			*vaddr;
+	unsigned long		size;
+	unsigned long		flags;
+	phys_addr_t		paddr;
+	const void		*caller;
+};
+
+extern struct static_vm *static_vmlist;
+extern spinlock_t static_vmlist_lock;
+
+extern struct static_vm *find_static_vm_paddr(phys_addr_t paddr,
+			size_t size, unsigned long flags);
+extern struct static_vm *find_static_vm_vaddr(void *vaddr, unsigned long flags);
+extern void init_static_vm(struct static_vm *static_vm,
+			struct vm_struct *vm, unsigned long flags);
+extern void insert_static_vm(struct static_vm *vm);
+
+#endif /* _ASM_MACH_STATIC_VM_H */
diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
index 4e333fa..57b329a 100644
--- a/arch/arm/mm/Makefile
+++ b/arch/arm/mm/Makefile
@@ -6,7 +6,7 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   iomap.o
 
 obj-$(CONFIG_MMU)		+= fault-armv.o flush.o idmap.o ioremap.o \
-				   mmap.o pgd.o mmu.o
+				   mmap.o pgd.o mmu.o static_vm.o
 
 ifneq ($(CONFIG_MMU),y)
 obj-y				+= nommu.o
diff --git a/arch/arm/mm/static_vm.c b/arch/arm/mm/static_vm.c
new file mode 100644
index 0000000..d7677cf
--- /dev/null
+++ b/arch/arm/mm/static_vm.c
@@ -0,0 +1,97 @@
+/*
+ * arch/arm/mm/static_vm.c
+ *
+ * Copyright (C) 2012 LG Electronics, Joonsoo Kim <js1304@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/spinlock.h>
+
+#include <asm/mach/static_vm.h>
+
+struct static_vm *static_vmlist;
+DEFINE_SPINLOCK(static_vmlist_lock);
+
+struct static_vm *find_static_vm_paddr(phys_addr_t paddr,
+			size_t size, unsigned long flags)
+{
+	struct static_vm *area;
+
+	spin_lock(&static_vmlist_lock);
+	for (area = static_vmlist; area; area = area->next) {
+		if ((area->flags & flags) != flags)
+			continue;
+
+		if (area->paddr > paddr ||
+			paddr + size - 1 > area->paddr + area->size - 1)
+			continue;
+
+		spin_unlock(&static_vmlist_lock);
+		return area;
+	}
+	spin_unlock(&static_vmlist_lock);
+
+	return NULL;
+}
+
+struct static_vm *find_static_vm_vaddr(void *vaddr, unsigned long flags)
+{
+	struct static_vm *area;
+
+	spin_lock(&static_vmlist_lock);
+	for (area = static_vmlist; area; area = area->next) {
+		/* static_vmlist is ascending order */
+		if (area->vaddr > vaddr)
+			break;
+
+		if ((area->flags & flags) != flags)
+			continue;
+
+		if (area->vaddr <= vaddr && area->vaddr + area->size > vaddr) {
+			spin_unlock(&static_vmlist_lock);
+			return area;
+		}
+	}
+	spin_unlock(&static_vmlist_lock);
+
+	return NULL;
+}
+
+void init_static_vm(struct static_vm *static_vm,
+				struct vm_struct *vm, unsigned long flags)
+{
+	static_vm->vaddr = vm->addr;
+	static_vm->size = vm->size;
+	static_vm->paddr = vm->phys_addr;
+	static_vm->caller = vm->caller;
+	static_vm->flags = flags;
+}
+
+void insert_static_vm(struct static_vm *vm)
+{
+	struct static_vm *tmp, **p;
+
+	spin_lock(&static_vmlist_lock);
+	for (p = &static_vmlist; (tmp = *p) != NULL; p = &tmp->next) {
+		if (tmp->vaddr >= vm->vaddr) {
+			BUG_ON(tmp->vaddr < vm->vaddr + vm->size);
+			break;
+		} else
+			BUG_ON(tmp->vaddr + tmp->size > vm->vaddr);
+	}
+	vm->next = *p;
+	*p = vm;
+	spin_unlock(&static_vmlist_lock);
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
