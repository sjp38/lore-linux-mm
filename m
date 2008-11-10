Message-Id: <20081110133840.983317000@suse.de>
References: <20081110133515.011510000@suse.de>
Date: Tue, 11 Nov 2008 00:35:20 +1100
From: npiggin@suse.de
Subject: [patch 5/7] mm: vmalloc improve vmallocinfo
Content-Disposition: inline; filename=mm-vmalloc-vmallocinfo-improve.patch
Sender: owner-linux-mm@kvack.org
From: Glauber Costa <glommer@redhat.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com
List-ID: <linux-mm.kvack.org>

If we do that, output of files like /proc/vmallocinfo will show things like
"vmalloc_32", "vmalloc_user", or whomever the caller was as the caller. This
info is not as useful as the real caller of the allocation.

So, proposal is to call __vmalloc_node node directly, with matching parameters
to save the caller information

Signed-off-by: Glauber Costa <glommer@redhat.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/vmalloc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -1356,7 +1356,8 @@ void *vmalloc_user(unsigned long size)
 	struct vm_struct *area;
 	void *ret;
 
-	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
+	ret = __vmalloc_node(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+			     PAGE_KERNEL, -1, __builtin_return_address(0));
 	if (ret) {
 		area = find_vm_area(ret);
 		area->flags |= VM_USERMAP;
@@ -1401,7 +1402,8 @@ EXPORT_SYMBOL(vmalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC);
+	return __vmalloc_node(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
+			      -1, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
@@ -1421,7 +1423,8 @@ void *vmalloc_exec(unsigned long size)
  */
 void *vmalloc_32(unsigned long size)
 {
-	return __vmalloc(size, GFP_VMALLOC32, PAGE_KERNEL);
+	return __vmalloc_node(size, GFP_VMALLOC32, PAGE_KERNEL,
+			      -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_32);
 
@@ -1437,7 +1440,8 @@ void *vmalloc_32_user(unsigned long size
 	struct vm_struct *area;
 	void *ret;
 
-	ret = __vmalloc(size, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL);
+	ret = __vmalloc_node(size, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
+			     -1, __builtin_return_address(0));
 	if (ret) {
 		area = find_vm_area(ret);
 		area->flags |= VM_USERMAP;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
