Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 898C4900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:44:02 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so99093751pad.10
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:44:02 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id rv7si3307661pbc.125.2015.02.03.09.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:51 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700HVUIRRX350@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:51 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 15/19] mm: vmalloc: add flag preventing guard hole
 allocation
Date: Tue, 03 Feb 2015 20:43:08 +0300
Message-id: <1422985392-28652-16-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

For instrumenting global variables KASan will shadow memory
backing memory for modules. So on module loading we will need
to allocate memory for shadow and map it at address in shadow
that corresponds to the address allocated in module_alloc().

__vmalloc_node_range() could be used for this purpose,
except it puts a guard hole after allocated area. Guard hole
in shadow memory should be a problem because at some future
point we might need to have a shadow memory at address
occupied by guard hole. So we could fail to allocate shadow
for module_alloc().

Add a new vm_struct flag 'VM_NO_GUARD' indicating that vm area
doesn't have a guard hole.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/vmalloc.h | 9 +++++++--
 mm/vmalloc.c            | 6 ++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index b87696f..1526fe7 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -16,6 +16,7 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
 #define VM_VPAGES		0x00000010	/* buffer for pages was vmalloc'ed */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
+#define VM_NO_GUARD		0x00000040      /* don't add guard page */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -96,8 +97,12 @@ void vmalloc_sync_all(void);
 
 static inline size_t get_vm_area_size(const struct vm_struct *area)
 {
-	/* return actual size without guard page */
-	return area->size - PAGE_SIZE;
+	if (!(area->flags & VM_NO_GUARD))
+		/* return actual size without guard page */
+		return area->size - PAGE_SIZE;
+	else
+		return area->size;
+
 }
 
 extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 39c3388..2e74e99 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1324,10 +1324,8 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 	if (unlikely(!area))
 		return NULL;
 
-	/*
-	 * We always allocate a guard page.
-	 */
-	size += PAGE_SIZE;
+	if (!(flags & VM_NO_GUARD))
+		size += PAGE_SIZE;
 
 	va = alloc_vmap_area(size, align, start, end, node, gfp_mask);
 	if (IS_ERR(va)) {
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
