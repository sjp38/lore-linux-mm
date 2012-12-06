Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 507426B009B
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:12:16 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4804276pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:12:16 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 7/8] mm, vmalloc: makes vmlist only for kexec
Date: Fri,  7 Dec 2012 01:09:34 +0900
Message-Id: <1354810175-4338-8-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Eric Biederman <ebiederm@xmission.com>

Although our intention remove vmlist entirely, but there is one exception.
kexec use vmlist symbol, and we can't remove it, because it is related to
userspace program. When kexec dumps system information, it write vmlist
address and vm_struct's address offset. In userspace program, these
information is used for getting first address in vmalloc space. Then it
dumps memory content in vmalloc space which is higher than this address.
For supporting this optimization, we should maintain a vmlist.

But this doesn't means that we should maintain full vmlist.
Just one vm_struct for vmlist is sufficient.
So use vmlist_early for full chain of vm_struct and assign a dummy_vm
to vmlist for supporting kexec.

Cc: Eric Biederman <ebiederm@xmission.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f134950..8a1b959 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -272,6 +272,27 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+/*** Old vmalloc interfaces ***/
+DEFINE_RWLOCK(vmlist_lock);
+/* vmlist is only for kexec */
+struct vm_struct *vmlist;
+static struct vm_struct dummy_vm;
+
+/* This is only for kexec.
+ * It wants to know first vmalloc address for optimization */
+static void setup_vmlist(void)
+{
+	struct vmap_area *va;
+
+	if (list_empty(&vmap_area_list)) {
+		vmlist = NULL;
+	} else {
+		va = list_entry((&vmap_area_list)->next, typeof(*va), list);
+		dummy_vm.addr = (void *)va->va_start;
+		vmlist = &dummy_vm;
+	}
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -313,7 +334,7 @@ static void __insert_vmap_area(struct vmap_area *va)
 	rb_link_node(&va->rb_node, parent, p);
 	rb_insert_color(&va->rb_node, &vmap_area_root);
 
-	/* address-sort this list so it is usable like the vmlist */
+	/* address-sort this list so it is usable like the vmlist_early */
 	tmp = rb_prev(&va->rb_node);
 	if (tmp) {
 		struct vmap_area *prev;
@@ -321,6 +342,8 @@ static void __insert_vmap_area(struct vmap_area *va)
 		list_add_rcu(&va->list, &prev->list);
 	} else
 		list_add_rcu(&va->list, &vmap_area_list);
+
+	setup_vmlist();
 }
 
 static void purge_vmap_area_lazy(void);
@@ -485,6 +508,8 @@ static void __free_vmap_area(struct vmap_area *va)
 		vmap_area_pcpu_hole = max(vmap_area_pcpu_hole, va->va_end);
 
 	kfree_rcu(va, rcu_head);
+
+	setup_vmlist();
 }
 
 /*
@@ -1125,11 +1150,13 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 }
 EXPORT_SYMBOL(vm_map_ram);
 
+static struct vm_struct *vmlist_early;
+
 /**
  * vm_area_add_early - add vmap area early during boot
  * @vm: vm_struct to add
  *
- * This function is used to add fixed kernel vm area to vmlist before
+ * This function is used to add fixed kernel vm area to vmlist_early before
  * vmalloc_init() is called.  @vm->addr, @vm->size, and @vm->flags
  * should contain proper values and the other fields should be zero.
  *
@@ -1140,7 +1167,7 @@ void __init vm_area_add_early(struct vm_struct *vm)
 	struct vm_struct *tmp, **p;
 
 	BUG_ON(vmap_initialized);
-	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
+	for (p = &vmlist_early; (tmp = *p) != NULL; p = &tmp->next) {
 		if (tmp->addr >= vm->addr) {
 			BUG_ON(tmp->addr < vm->addr + vm->size);
 			break;
@@ -1190,8 +1217,8 @@ void __init vmalloc_init(void)
 		INIT_LIST_HEAD(&vbq->free);
 	}
 
-	/* Import existing vmlist entries. */
-	for (tmp = vmlist; tmp; tmp = tmp->next) {
+	/* Import existing vmlist_early entries. */
+	for (tmp = vmlist_early; tmp; tmp = tmp->next) {
 		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
 		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
@@ -1283,10 +1310,6 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
 
-/*** Old vmalloc interfaces ***/
-DEFINE_RWLOCK(vmlist_lock);
-struct vm_struct *vmlist;
-
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
@@ -1313,7 +1336,7 @@ static void insert_vmalloc_vmlist(struct vm_struct *vm)
 	vm->flags &= ~VM_UNLIST;
 
 	write_lock(&vmlist_lock);
-	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
+	for (p = &vmlist_early; (tmp = *p) != NULL; p = &tmp->next) {
 		if (tmp->addr >= vm->addr)
 			break;
 	}
@@ -1369,7 +1392,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 
 	/*
 	 * When this function is called from __vmalloc_node_range,
-	 * we do not add vm_struct to vmlist here to avoid
+	 * we do not add vm_struct to vmlist_early here to avoid
 	 * accessing uninitialized members of vm_struct such as
 	 * pages and nr_pages fields. They will be set later.
 	 * To distinguish it from others, we use a VM_UNLIST flag.
@@ -1468,7 +1491,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 			 * confliction is maintained by vmap.)
 			 */
 			write_lock(&vmlist_lock);
-			for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
+			for (p = &vmlist_early; (tmp = *p) != vm;
+							p = &tmp->next)
 				;
 			*p = tmp->next;
 			write_unlock(&vmlist_lock);
@@ -1694,7 +1718,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	/*
 	 * In this function, newly allocated vm_struct is not added
-	 * to vmlist at __get_vm_area_node(). so, it is added here.
+	 * to vmlist_early at __get_vm_area_node(). so, it is added here.
 	 */
 	insert_vmalloc_vmlist(area);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
