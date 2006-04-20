Date: Thu, 20 Apr 2006 19:27:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 6/5] mm: find_vm_area locking fixes
Message-ID: <20060420172735.GC21660@wotan.suse.de>
References: <20060228202202.14172.60409.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060228202202.14172.60409.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Bite the bullet and try to get the locking correct the first^Wsecond time.

(subtle bugs like area->flagas modification not having the right memory
consistency could be a nightmare to track down)

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -256,16 +256,15 @@ struct vm_struct *get_vm_area_node(unsig
 	return __get_vm_area_node(size, flags, VMALLOC_START, VMALLOC_END, node);
 }
 
-static struct vm_struct *find_vm_area(void *addr)
+/* Caller must hold vmlist_lock */
+static struct vm_struct *__find_vm_area(void *addr)
 {
 	struct vm_struct *tmp;
 
-	write_lock(&vmlist_lock);
 	for (tmp = vmlist; tmp != NULL; tmp = tmp->next) {
 		 if (tmp->addr == addr)
 			break;
 	}
-	write_unlock(&vmlist_lock);
 
 	return tmp;
 }
@@ -529,9 +528,10 @@ void *vmalloc_user(unsigned long size)
 	void *ret;
 
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
-	area = find_vm_area(ret);
-	BUG_ON(!area);
+	write_lock(&vmlist_lock);
+	area = __find_vm_area(ret);
 	area->flags |= VM_USERMAP;
+	write_unlock(&vmlist_lock);
 
 	return ret;
 }
@@ -604,9 +604,10 @@ void *vmalloc_32_user(unsigned long size
 	void *ret;
 
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
-	area = find_vm_area(ret);
-	BUG_ON(!area);
+	write_lock(&vmlist_lock);
+	area = __find_vm_area(ret);
 	area->flags |= VM_USERMAP;
+	write_unlock(&vmlist_lock);
 
 	return ret;
 }
@@ -712,15 +713,17 @@ int remap_vmalloc_range(struct vm_area_s
 	if ((PAGE_SIZE-1) & (unsigned long)addr)
 		return -EINVAL;
 
-	area = find_vm_area(addr);
+	read_lock(&vmlist_lock);
+	area = __find_vm_area(addr);
 	if (!area)
-		return -EINVAL;
+		goto out_einval_locked;
 
 	if (!(area->flags & VM_USERMAP))
-		return -EINVAL;
+		goto out_einval_locked;
 
 	if (usize + (pgoff << PAGE_SHIFT) > area->size - PAGE_SIZE)
-		return -EINVAL;
+		goto out_einval_locked;
+	read_unlock(&vmlist_lock);
 
 	addr = (void *)((unsigned long)addr + (pgoff << PAGE_SHIFT));
 	do {
@@ -738,6 +741,10 @@ int remap_vmalloc_range(struct vm_area_s
 	vma->vm_flags |= VM_RESERVED;
 
 	return ret;
+
+out_einval_locked:
+	read_unlock(&vmlist_lock);
+	return -EINVAL;
 }
 EXPORT_SYMBOL(remap_vmalloc_range);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
