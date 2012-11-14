Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A4FC36B005D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 11:58:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so462886pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 08:58:32 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 1/3] ARM: vmregion: remove vmregion code entirely
Date: Thu, 15 Nov 2012 01:55:52 +0900
Message-Id: <1352912154-16210-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1352912154-16210-1-git-send-email-js1304@gmail.com>
References: <1352912154-16210-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

Now, there is no user for vmregion.
So remove it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
index 8a9c4cb..4e333fa 100644
--- a/arch/arm/mm/Makefile
+++ b/arch/arm/mm/Makefile
@@ -6,7 +6,7 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   iomap.o
 
 obj-$(CONFIG_MMU)		+= fault-armv.o flush.o idmap.o ioremap.o \
-				   mmap.o pgd.o mmu.o vmregion.o
+				   mmap.o pgd.o mmu.o
 
 ifneq ($(CONFIG_MMU),y)
 obj-y				+= nommu.o
diff --git a/arch/arm/mm/vmregion.c b/arch/arm/mm/vmregion.c
deleted file mode 100644
index a631016..0000000
--- a/arch/arm/mm/vmregion.c
+++ /dev/null
@@ -1,205 +0,0 @@
-#include <linux/fs.h>
-#include <linux/spinlock.h>
-#include <linux/list.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/slab.h>
-
-#include "vmregion.h"
-
-/*
- * VM region handling support.
- *
- * This should become something generic, handling VM region allocations for
- * vmalloc and similar (ioremap, module space, etc).
- *
- * I envisage vmalloc()'s supporting vm_struct becoming:
- *
- *  struct vm_struct {
- *    struct vmregion	region;
- *    unsigned long	flags;
- *    struct page	**pages;
- *    unsigned int	nr_pages;
- *    unsigned long	phys_addr;
- *  };
- *
- * get_vm_area() would then call vmregion_alloc with an appropriate
- * struct vmregion head (eg):
- *
- *  struct vmregion vmalloc_head = {
- *	.vm_list	= LIST_HEAD_INIT(vmalloc_head.vm_list),
- *	.vm_start	= VMALLOC_START,
- *	.vm_end		= VMALLOC_END,
- *  };
- *
- * However, vmalloc_head.vm_start is variable (typically, it is dependent on
- * the amount of RAM found at boot time.)  I would imagine that get_vm_area()
- * would have to initialise this each time prior to calling vmregion_alloc().
- */
-
-struct arm_vmregion *
-arm_vmregion_alloc(struct arm_vmregion_head *head, size_t align,
-		   size_t size, gfp_t gfp, const void *caller)
-{
-	unsigned long start = head->vm_start, addr = head->vm_end;
-	unsigned long flags;
-	struct arm_vmregion *c, *new;
-
-	if (head->vm_end - head->vm_start < size) {
-		printk(KERN_WARNING "%s: allocation too big (requested %#x)\n",
-			__func__, size);
-		goto out;
-	}
-
-	new = kmalloc(sizeof(struct arm_vmregion), gfp);
-	if (!new)
-		goto out;
-
-	new->caller = caller;
-
-	spin_lock_irqsave(&head->vm_lock, flags);
-
-	addr = rounddown(addr - size, align);
-	list_for_each_entry_reverse(c, &head->vm_list, vm_list) {
-		if (addr >= c->vm_end)
-			goto found;
-		addr = rounddown(c->vm_start - size, align);
-		if (addr < start)
-			goto nospc;
-	}
-
- found:
-	/*
-	 * Insert this entry after the one we found.
-	 */
-	list_add(&new->vm_list, &c->vm_list);
-	new->vm_start = addr;
-	new->vm_end = addr + size;
-	new->vm_active = 1;
-
-	spin_unlock_irqrestore(&head->vm_lock, flags);
-	return new;
-
- nospc:
-	spin_unlock_irqrestore(&head->vm_lock, flags);
-	kfree(new);
- out:
-	return NULL;
-}
-
-static struct arm_vmregion *__arm_vmregion_find(struct arm_vmregion_head *head, unsigned long addr)
-{
-	struct arm_vmregion *c;
-
-	list_for_each_entry(c, &head->vm_list, vm_list) {
-		if (c->vm_active && c->vm_start == addr)
-			goto out;
-	}
-	c = NULL;
- out:
-	return c;
-}
-
-struct arm_vmregion *arm_vmregion_find(struct arm_vmregion_head *head, unsigned long addr)
-{
-	struct arm_vmregion *c;
-	unsigned long flags;
-
-	spin_lock_irqsave(&head->vm_lock, flags);
-	c = __arm_vmregion_find(head, addr);
-	spin_unlock_irqrestore(&head->vm_lock, flags);
-	return c;
-}
-
-struct arm_vmregion *arm_vmregion_find_remove(struct arm_vmregion_head *head, unsigned long addr)
-{
-	struct arm_vmregion *c;
-	unsigned long flags;
-
-	spin_lock_irqsave(&head->vm_lock, flags);
-	c = __arm_vmregion_find(head, addr);
-	if (c)
-		c->vm_active = 0;
-	spin_unlock_irqrestore(&head->vm_lock, flags);
-	return c;
-}
-
-void arm_vmregion_free(struct arm_vmregion_head *head, struct arm_vmregion *c)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&head->vm_lock, flags);
-	list_del(&c->vm_list);
-	spin_unlock_irqrestore(&head->vm_lock, flags);
-
-	kfree(c);
-}
-
-#ifdef CONFIG_PROC_FS
-static int arm_vmregion_show(struct seq_file *m, void *p)
-{
-	struct arm_vmregion *c = list_entry(p, struct arm_vmregion, vm_list);
-
-	seq_printf(m, "0x%08lx-0x%08lx %7lu", c->vm_start, c->vm_end,
-		c->vm_end - c->vm_start);
-	if (c->caller)
-		seq_printf(m, " %pS", (void *)c->caller);
-	seq_putc(m, '\n');
-	return 0;
-}
-
-static void *arm_vmregion_start(struct seq_file *m, loff_t *pos)
-{
-	struct arm_vmregion_head *h = m->private;
-	spin_lock_irq(&h->vm_lock);
-	return seq_list_start(&h->vm_list, *pos);
-}
-
-static void *arm_vmregion_next(struct seq_file *m, void *p, loff_t *pos)
-{
-	struct arm_vmregion_head *h = m->private;
-	return seq_list_next(p, &h->vm_list, pos);
-}
-
-static void arm_vmregion_stop(struct seq_file *m, void *p)
-{
-	struct arm_vmregion_head *h = m->private;
-	spin_unlock_irq(&h->vm_lock);
-}
-
-static const struct seq_operations arm_vmregion_ops = {
-	.start	= arm_vmregion_start,
-	.stop	= arm_vmregion_stop,
-	.next	= arm_vmregion_next,
-	.show	= arm_vmregion_show,
-};
-
-static int arm_vmregion_open(struct inode *inode, struct file *file)
-{
-	struct arm_vmregion_head *h = PDE(inode)->data;
-	int ret = seq_open(file, &arm_vmregion_ops);
-	if (!ret) {
-		struct seq_file *m = file->private_data;
-		m->private = h;
-	}
-	return ret;
-}
-
-static const struct file_operations arm_vmregion_fops = {
-	.open	= arm_vmregion_open,
-	.read	= seq_read,
-	.llseek	= seq_lseek,
-	.release = seq_release,
-};
-
-int arm_vmregion_create_proc(const char *path, struct arm_vmregion_head *h)
-{
-	proc_create_data(path, S_IRUSR, NULL, &arm_vmregion_fops, h);
-	return 0;
-}
-#else
-int arm_vmregion_create_proc(const char *path, struct arm_vmregion_head *h)
-{
-	return 0;
-}
-#endif
diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h
deleted file mode 100644
index 0f5a5f2..0000000
--- a/arch/arm/mm/vmregion.h
+++ /dev/null
@@ -1,31 +0,0 @@
-#ifndef VMREGION_H
-#define VMREGION_H
-
-#include <linux/spinlock.h>
-#include <linux/list.h>
-
-struct page;
-
-struct arm_vmregion_head {
-	spinlock_t		vm_lock;
-	struct list_head	vm_list;
-	unsigned long		vm_start;
-	unsigned long		vm_end;
-};
-
-struct arm_vmregion {
-	struct list_head	vm_list;
-	unsigned long		vm_start;
-	unsigned long		vm_end;
-	int			vm_active;
-	const void		*caller;
-};
-
-struct arm_vmregion *arm_vmregion_alloc(struct arm_vmregion_head *, size_t, size_t, gfp_t, const void *);
-struct arm_vmregion *arm_vmregion_find(struct arm_vmregion_head *, unsigned long);
-struct arm_vmregion *arm_vmregion_find_remove(struct arm_vmregion_head *, unsigned long);
-void arm_vmregion_free(struct arm_vmregion_head *, struct arm_vmregion *);
-
-int arm_vmregion_create_proc(const char *, struct arm_vmregion_head *);
-
-#endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
