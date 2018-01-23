Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4EC800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:55:27 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id q21so10441lfa.14
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:55:27 -0800 (PST)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::190])
        by mx.google.com with ESMTPS id v24si6810922ljc.109.2018.01.23.02.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 02:55:25 -0800 (PST)
Subject: [PATCH 1/4] vmalloc: add vm_flags argument to internal
 __vmalloc_node()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 23 Jan 2018 13:55:22 +0300
Message-ID: <151670492223.658225.4605377710524021456.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

This allows to set VM_USERMAP in vmalloc_user() and vmalloc_32_user()
directly at allocation and avoid find_vm_area() call.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmalloc.c |   54 +++++++++++++++++++++---------------------------------
 1 file changed, 21 insertions(+), 33 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..cece3fb33cef 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1662,7 +1662,9 @@ EXPORT_SYMBOL(vmap);
 
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
+			    unsigned long vm_flags,
 			    int node, const void *caller);
+
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
@@ -1681,7 +1683,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
 		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
-				PAGE_KERNEL, node, area->caller);
+				       PAGE_KERNEL, 0, node, area->caller);
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
 	}
@@ -1752,7 +1754,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 		goto fail;
 
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
-				vm_flags, start, end, node, gfp_mask, caller);
+				  vm_flags, start, end, node, gfp_mask, caller);
 	if (!area)
 		goto fail;
 
@@ -1783,6 +1785,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	@align:		desired alignment
  *	@gfp_mask:	flags for the page level allocator
  *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
  *	@node:		node to use for allocation or NUMA_NO_NODE
  *	@caller:	caller's return address
  *
@@ -1799,15 +1802,16 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  */
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
+			    unsigned long vm_flags,
 			    int node, const void *caller)
 {
 	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
-				gfp_mask, prot, 0, node, caller);
+				gfp_mask, prot, vm_flags, node, caller);
 }
 
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 {
-	return __vmalloc_node(size, 1, gfp_mask, prot, NUMA_NO_NODE,
+	return __vmalloc_node(size, 1, gfp_mask, prot, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 }
 EXPORT_SYMBOL(__vmalloc);
@@ -1815,15 +1819,15 @@ EXPORT_SYMBOL(__vmalloc);
 static inline void *__vmalloc_node_flags(unsigned long size,
 					int node, gfp_t flags)
 {
-	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
-					node, __builtin_return_address(0));
+	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, 0, node,
+			      __builtin_return_address(0));
 }
 
 
 void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags,
 				  void *caller)
 {
-	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, node, caller);
+	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, 0, node, caller);
 }
 
 /**
@@ -1868,18 +1872,9 @@ EXPORT_SYMBOL(vzalloc);
  */
 void *vmalloc_user(unsigned long size)
 {
-	struct vm_struct *area;
-	void *ret;
-
-	ret = __vmalloc_node(size, SHMLBA,
-			     GFP_KERNEL | __GFP_ZERO,
-			     PAGE_KERNEL, NUMA_NO_NODE,
-			     __builtin_return_address(0));
-	if (ret) {
-		area = find_vm_area(ret);
-		area->flags |= VM_USERMAP;
-	}
-	return ret;
+	return __vmalloc_node(size, SHMLBA, GFP_KERNEL | __GFP_ZERO,
+			      PAGE_KERNEL, VM_USERMAP, NUMA_NO_NODE,
+			      __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_user);
 
@@ -1896,8 +1891,8 @@ EXPORT_SYMBOL(vmalloc_user);
  */
 void *vmalloc_node(unsigned long size, int node)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL,
-					node, __builtin_return_address(0));
+	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL, 0, node,
+			      __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_node);
 
@@ -1938,7 +1933,7 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
+	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
 			      NUMA_NO_NODE, __builtin_return_address(0));
 }
 
@@ -1959,7 +1954,7 @@ void *vmalloc_exec(unsigned long size)
  */
 void *vmalloc_32(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_VMALLOC32, PAGE_KERNEL,
+	return __vmalloc_node(size, 1, GFP_VMALLOC32, PAGE_KERNEL, 0,
 			      NUMA_NO_NODE, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_32);
@@ -1973,16 +1968,9 @@ EXPORT_SYMBOL(vmalloc_32);
  */
 void *vmalloc_32_user(unsigned long size)
 {
-	struct vm_struct *area;
-	void *ret;
-
-	ret = __vmalloc_node(size, 1, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
-			     NUMA_NO_NODE, __builtin_return_address(0));
-	if (ret) {
-		area = find_vm_area(ret);
-		area->flags |= VM_USERMAP;
-	}
-	return ret;
+	return __vmalloc_node(size, 1, GFP_VMALLOC32 | __GFP_ZERO,
+			      PAGE_KERNEL, VM_USERMAP, NUMA_NO_NODE,
+			      __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_32_user);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
