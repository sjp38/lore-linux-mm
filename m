Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0A52C6B009B
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:12:11 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4804276pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:12:11 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 6/8] mm, vmalloc: iterate vmap_area_list, instead of vmlist, in vmallocinfo()
Date: Fri,  7 Dec 2012 01:09:33 +0900
Message-Id: <1354810175-4338-7-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

This patch is preparing step for removing vmlist entirely.
For above purpose, we change iterating a vmap_list codes to iterating a
vmap_area_list. It is somewhat trivial change, but just one thing
should be noticed.

Using vmap_area_list in vmallocinfo() introduce ordering problem in SMP
system. In s_show(), we retrieve some values from vm_struct. vm_struct's
values is not fully setup when va->vm is assigned. Full setup is notified
by removing VM_UNLIST flag without holding a lock. When we see that
VM_UNLIST is removed, it is not ensured that vm_struct has proper values
in view of other CPUs. So we need smp_[rw]mb for ensuring that proper
values is assigned when we see that VM_UNLIST is removed.

Therefore, this patch not only change a iteration list, but also add a
appropriate smp_[rw]mb to right places.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f7f4a35..f134950 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1304,7 +1304,14 @@ static void insert_vmalloc_vmlist(struct vm_struct *vm)
 {
 	struct vm_struct *tmp, **p;
 
+	/*
+	 * Before removing VM_UNLIST,
+	 * we should make sure that vm has proper values.
+	 * Pair with smp_rmb() in show_numa_info().
+	 */
+	smp_wmb();
 	vm->flags &= ~VM_UNLIST;
+
 	write_lock(&vmlist_lock);
 	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
 		if (tmp->addr >= vm->addr)
@@ -2539,19 +2546,19 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 
 #ifdef CONFIG_PROC_FS
 static void *s_start(struct seq_file *m, loff_t *pos)
-	__acquires(&vmlist_lock)
+	__acquires(&vmap_area_lock)
 {
 	loff_t n = *pos;
-	struct vm_struct *v;
+	struct vmap_area *va;
 
-	read_lock(&vmlist_lock);
-	v = vmlist;
-	while (n > 0 && v) {
+	spin_lock(&vmap_area_lock);
+	va = list_entry((&vmap_area_list)->next, typeof(*va), list);
+	while (n > 0 && &va->list != &vmap_area_list) {
 		n--;
-		v = v->next;
+		va = list_entry(va->list.next, typeof(*va), list);
 	}
-	if (!n)
-		return v;
+	if (!n && &va->list != &vmap_area_list)
+		return va;
 
 	return NULL;
 
@@ -2559,16 +2566,20 @@ static void *s_start(struct seq_file *m, loff_t *pos)
 
 static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	struct vm_struct *v = p;
+	struct vmap_area *va = p, *next;
 
 	++*pos;
-	return v->next;
+	next = list_entry(va->list.next, typeof(*va), list);
+	if (&next->list != &vmap_area_list)
+		return next;
+
+	return NULL;
 }
 
 static void s_stop(struct seq_file *m, void *p)
-	__releases(&vmlist_lock)
+	__releases(&vmap_area_lock)
 {
-	read_unlock(&vmlist_lock);
+	spin_unlock(&vmap_area_lock);
 }
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
@@ -2579,6 +2590,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		if (!counters)
 			return;
 
+		/* Pair with smp_wmb() in insert_vmalloc_vmlist() */
+		smp_rmb();
+		if (v->flags & VM_UNLIST)
+			return;
+
 		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
 
 		for (nr = 0; nr < v->nr_pages; nr++)
@@ -2592,36 +2608,50 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 
 static int s_show(struct seq_file *m, void *p)
 {
-	struct vm_struct *v = p;
+	struct vmap_area *va = p;
+	struct vm_struct *vm;
+
+	if (!(va->flags & VM_VM_AREA)) {
+		seq_printf(m, "0x%pK-0x%pK %7ld",
+			(void *)va->va_start, (void *)va->va_end,
+					va->va_end - va->va_start);
+		if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
+			seq_printf(m, " (freeing)");
+
+		seq_putc(m, '\n');
+		return 0;
+	}
+
+	vm = va->vm;
 
 	seq_printf(m, "0x%pK-0x%pK %7ld",
-		v->addr, v->addr + v->size, v->size);
+		vm->addr, vm->addr + vm->size, vm->size);
 
-	if (v->caller)
-		seq_printf(m, " %pS", v->caller);
+	if (vm->caller)
+		seq_printf(m, " %pS", vm->caller);
 
-	if (v->nr_pages)
-		seq_printf(m, " pages=%d", v->nr_pages);
+	if (vm->nr_pages)
+		seq_printf(m, " pages=%d", vm->nr_pages);
 
-	if (v->phys_addr)
-		seq_printf(m, " phys=%llx", (unsigned long long)v->phys_addr);
+	if (vm->phys_addr)
+		seq_printf(m, " phys=%llx", (unsigned long long)vm->phys_addr);
 
-	if (v->flags & VM_IOREMAP)
+	if (vm->flags & VM_IOREMAP)
 		seq_printf(m, " ioremap");
 
-	if (v->flags & VM_ALLOC)
+	if (vm->flags & VM_ALLOC)
 		seq_printf(m, " vmalloc");
 
-	if (v->flags & VM_MAP)
+	if (vm->flags & VM_MAP)
 		seq_printf(m, " vmap");
 
-	if (v->flags & VM_USERMAP)
+	if (vm->flags & VM_USERMAP)
 		seq_printf(m, " user");
 
-	if (v->flags & VM_VPAGES)
+	if (vm->flags & VM_VPAGES)
 		seq_printf(m, " vpages");
 
-	show_numa_info(m, v);
+	show_numa_info(m, vm);
 	seq_putc(m, '\n');
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
