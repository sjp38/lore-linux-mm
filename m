Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 141496B0062
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:33:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 8/8] mm, vmalloc: remove list management of vmlist after initializing vmalloc
Date: Wed, 13 Mar 2013 15:33:00 +0900
Message-Id: <1363156381-2881-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Bob Liu <lliubbo@gmail.com>, Pekka Enberg <penberg@kernel.org>, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <js1304@gmail.com>

Now, there is no need to maintain vmlist after initializing vmalloc.
So remove related code and data structure.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7e63984..151da8a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -273,10 +273,6 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
-/*** Old vmalloc interfaces ***/
-static DEFINE_RWLOCK(vmlist_lock);
-static struct vm_struct *vmlist;
-
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -318,7 +314,7 @@ static void __insert_vmap_area(struct vmap_area *va)
 	rb_link_node(&va->rb_node, parent, p);
 	rb_insert_color(&va->rb_node, &vmap_area_root);
 
-	/* address-sort this list so it is usable like the vmlist */
+	/* address-sort this list */
 	tmp = rb_prev(&va->rb_node);
 	if (tmp) {
 		struct vmap_area *prev;
@@ -1130,6 +1126,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 }
 EXPORT_SYMBOL(vm_map_ram);
 
+static struct vm_struct *vmlist __initdata;
 /**
  * vm_area_add_early - add vmap area early during boot
  * @vm: vm_struct to add
@@ -1301,10 +1298,8 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	spin_unlock(&vmap_area_lock);
 }
 
-static void insert_vmalloc_vmlist(struct vm_struct *vm)
+static void clear_vm_unlist(struct vm_struct *vm)
 {
-	struct vm_struct *tmp, **p;
-
 	/*
 	 * Before removing VM_UNLIST,
 	 * we should make sure that vm has proper values.
@@ -1312,22 +1307,13 @@ static void insert_vmalloc_vmlist(struct vm_struct *vm)
 	 */
 	smp_wmb();
 	vm->flags &= ~VM_UNLIST;
-
-	write_lock(&vmlist_lock);
-	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
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
+	clear_vm_unlist(vm);
 }
 
 static struct vm_struct *__get_vm_area_node(unsigned long size,
@@ -1370,10 +1356,9 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 
 	/*
 	 * When this function is called from __vmalloc_node_range,
-	 * we do not add vm_struct to vmlist here to avoid
-	 * accessing uninitialized members of vm_struct such as
-	 * pages and nr_pages fields. They will be set later.
-	 * To distinguish it from others, we use a VM_UNLIST flag.
+	 * we add VM_UNLIST flag to avoid accessing uninitialized
+	 * members of vm_struct such as pages and nr_pages fields.
+	 * They will be set later.
 	 */
 	if (flags & VM_UNLIST)
 		setup_vmalloc_vm(area, va, flags, caller);
@@ -1462,20 +1447,6 @@ struct vm_struct *remove_vm_area(const void *addr)
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
-			for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
-				;
-			*p = tmp->next;
-			write_unlock(&vmlist_lock);
-		}
-
 		vmap_debug_free_range(va->va_start, va->va_end);
 		free_unmap_vmap_area(va);
 		vm->size -= PAGE_SIZE;
@@ -1695,10 +1666,11 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 		return NULL;
 
 	/*
-	 * In this function, newly allocated vm_struct is not added
-	 * to vmlist at __get_vm_area_node(). so, it is added here.
+	 * In this function, newly allocated vm_struct has VM_UNLIST flag.
+	 * It means that vm_struct is not fully initialized.
+	 * Now, it is fully initialized, so remove this flag here.
 	 */
-	insert_vmalloc_vmlist(area);
+	clear_vm_unlist(area);
 
 	/*
 	 * A ref_count = 3 is needed because the vm_struct and vmap_area
@@ -2594,7 +2566,7 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		if (!counters)
 			return;
 
-		/* Pair with smp_wmb() in insert_vmalloc_vmlist() */
+		/* Pair with smp_wmb() in clear_vm_unlist() */
 		smp_rmb();
 		if (v->flags & VM_UNLIST)
 			return;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
