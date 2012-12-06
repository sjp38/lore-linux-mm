Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D7E886B0096
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:12:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so4763156pad.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:12:20 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 8/8] mm, vmalloc: remove list management operation after initializing vmalloc
Date: Fri,  7 Dec 2012 01:09:35 +0900
Message-Id: <1354810175-4338-9-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

Now, there is no need to maintain vmlist_early after initializing vmalloc.
So remove related code and data structure.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 698b1e5..10d19c9 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -130,7 +130,6 @@ extern long vwrite(char *buf, char *addr, unsigned long count);
 /*
  *	Internals.  Dont't use..
  */
-extern rwlock_t vmlist_lock;
 extern struct vm_struct *vmlist;
 extern __init void vm_area_add_early(struct vm_struct *vm);
 extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8a1b959..957a098 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -272,8 +272,6 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
-/*** Old vmalloc interfaces ***/
-DEFINE_RWLOCK(vmlist_lock);
 /* vmlist is only for kexec */
 struct vm_struct *vmlist;
 static struct vm_struct dummy_vm;
@@ -334,7 +332,7 @@ static void __insert_vmap_area(struct vmap_area *va)
 	rb_link_node(&va->rb_node, parent, p);
 	rb_insert_color(&va->rb_node, &vmap_area_root);
 
-	/* address-sort this list so it is usable like the vmlist_early */
+	/* address-sort this list */
 	tmp = rb_prev(&va->rb_node);
 	if (tmp) {
 		struct vmap_area *prev;
@@ -1150,7 +1148,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 }
 EXPORT_SYMBOL(vm_map_ram);
 
-static struct vm_struct *vmlist_early;
+static struct vm_struct *vmlist_early __initdata;
 
 /**
  * vm_area_add_early - add vmap area early during boot
@@ -1323,7 +1321,7 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	spin_unlock(&vmap_area_lock);
 }
 
-static void insert_vmalloc_vmlist(struct vm_struct *vm)
+static void remove_vm_unlist(struct vm_struct *vm)
 {
 	struct vm_struct *tmp, **p;
 
@@ -1334,22 +1332,13 @@ static void insert_vmalloc_vmlist(struct vm_struct *vm)
 	 */
 	smp_wmb();
 	vm->flags &= ~VM_UNLIST;
-
-	write_lock(&vmlist_lock);
-	for (p = &vmlist_early; (tmp = *p) != NULL; p = &tmp->next) {
-		if (tmp->addr >= vm->addr)
-			break;
-	}
-	vm->next = *p;
-	*p = vm;
-	write_unlock(&vmlist_lock);
 }
 
 static void insert_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
 	setup_vmalloc_vm(vm, va, flags, caller);
-	insert_vmalloc_vmlist(vm);
+	remove_vm_unlist(vm);
 }
 
 static struct vm_struct *__get_vm_area_node(unsigned long size,
@@ -1392,10 +1381,9 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 
 	/*
 	 * When this function is called from __vmalloc_node_range,
-	 * we do not add vm_struct to vmlist_early here to avoid
-	 * accessing uninitialized members of vm_struct such as
-	 * pages and nr_pages fields. They will be set later.
-	 * To distinguish it from others, we use a VM_UNLIST flag.
+	 * we add VM_UNLIST flag to avoid accessing uninitialized
+	 * members of vm_struct such as pages and nr_pages fields.
+	 * They will be set later.
 	 */
 	if (flags & VM_UNLIST)
 		setup_vmalloc_vm(area, va, flags, caller);
@@ -1483,21 +1471,6 @@ struct vm_struct *remove_vm_area(const void *addr)
 		va->flags &= ~VM_VM_AREA;
 		spin_unlock(&vmap_area_lock);
 
-		if (!(vm->flags & VM_UNLIST)) {
-			struct vm_struct *tmp, **p;
-			/*
-			 * remove from list and disallow access to
-			 * this vm_struct before unmap. (address range
-			 * confliction is maintained by vmap.)
-			 */
-			write_lock(&vmlist_lock);
-			for (p = &vmlist_early; (tmp = *p) != vm;
-							p = &tmp->next)
-				;
-			*p = tmp->next;
-			write_unlock(&vmlist_lock);
-		}
-
 		vmap_debug_free_range(va->va_start, va->va_end);
 		free_unmap_vmap_area(va);
 		vm->size -= PAGE_SIZE;
@@ -1717,10 +1690,11 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 		return NULL;
 
 	/*
-	 * In this function, newly allocated vm_struct is not added
-	 * to vmlist_early at __get_vm_area_node(). so, it is added here.
+	 * In this function, newly allocated vm_struct has VM_UNLIST flag.
+	 * It means that vm_struct is not fully initialized.
+	 * Now, it is fully initialized, so remove this flag here.
 	 */
-	insert_vmalloc_vmlist(area);
+	remove_vm_unlist(area);
 
 	/*
 	 * A ref_count = 3 is needed because the vm_struct and vmap_area
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
