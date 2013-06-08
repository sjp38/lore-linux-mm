Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4EDB86B0031
	for <linux-mm@kvack.org>; Sat,  8 Jun 2013 04:43:26 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y14so2796322pdi.2
        for <linux-mm@kvack.org>; Sat, 08 Jun 2013 01:43:25 -0700 (PDT)
Message-ID: <51B2EEA3.5020808@gmail.com>
Date: Sat, 08 Jun 2013 16:43:15 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH -mm 1/2] mm, vmalloc: Rename VM_UNLIST to VM_UNINITIALIZED
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

VM_UNLIST was used to indicate that the vm_struct is not listed
in vmlist. But after commit 4341fa4:
  mm, vmalloc: remove list management of vmlist after initializing vmalloc
, the meaning of this flag changed. It now means the vm_struct
is not fully initialized. So renaming it to VM_UNINITIALIZED
seems more reasonable.

Also change clear_vm_unlist to clear_vm_uninitialized_flag.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/vmalloc.h |   12 ++++++------
 mm/vmalloc.c            |   18 +++++++++---------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index dd0a2c8..4b8a891 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -10,12 +10,12 @@
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 
 /* bits in flags of vmalloc's vm_struct below */
-#define VM_IOREMAP	0x00000001	/* ioremap() and friends */
-#define VM_ALLOC	0x00000002	/* vmalloc() */
-#define VM_MAP		0x00000004	/* vmap()ed pages */
-#define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
-#define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
-#define VM_UNLIST	0x00000020	/* vm_struct is not listed in vmlist */
+#define VM_IOREMAP		0x00000001	/* ioremap() and friends */
+#define VM_ALLOC		0x00000002	/* vmalloc() */
+#define VM_MAP			0x00000004	/* vmap()ed pages */
+#define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
+#define VM_VPAGES		0x00000010	/* buffer for pages was vmalloc'ed */
+#define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9a0d711..fe41a4f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1311,15 +1311,15 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	spin_unlock(&vmap_area_lock);
 }
 
-static void clear_vm_unlist(struct vm_struct *vm)
+static void clear_vm_uninitialized_flag(struct vm_struct *vm)
 {
 	/*
-	 * Before removing VM_UNLIST,
+	 * Before removing VM_UNINITIALIZED,
 	 * we should make sure that vm has proper values.
 	 * Pair with smp_rmb() in show_numa_info().
 	 */
 	smp_wmb();
-	vm->flags &= ~VM_UNLIST;
+	vm->flags &= ~VM_UNINITIALIZED;
 }
 
 static struct vm_struct *__get_vm_area_node(unsigned long size,
@@ -1657,7 +1657,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		goto fail;
 
-	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNLIST,
+	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED,
 				  start, end, node, gfp_mask, caller);
 	if (!area)
 		goto fail;
@@ -1667,11 +1667,11 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 		goto fail;
 
 	/*
-	 * In this function, newly allocated vm_struct has VM_UNLIST flag.
-	 * It means that vm_struct is not fully initialized.
+	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
+	 * flag. It means that vm_struct is not fully initialized.
 	 * Now, it is fully initialized, so remove this flag here.
 	 */
-	clear_vm_unlist(area);
+	clear_vm_uninitialized_flag(area);
 
 	/*
 	 * A ref_count = 3 is needed because the vm_struct and vmap_area
@@ -2591,9 +2591,9 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		if (!counters)
 			return;
 
-		/* Pair with smp_wmb() in clear_vm_unlist() */
+		/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
 		smp_rmb();
-		if (v->flags & VM_UNLIST)
+		if (v->flags & VM_UNINITIALIZED)
 			return;
 
 		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
