Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D95C86B0070
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:57:45 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so13819407pdb.18
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 04:57:45 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id fs12si1065034pdb.56.2014.12.16.04.57.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 16 Dec 2014 04:57:44 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGO00JPZEUTB650@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Dec 2014 13:01:41 +0000 (GMT)
From: Dmitry Safonov <d.safonov@partner.samsung.com>
Subject: [RFC PATCH] mm: vmalloc: remove ioremap align constraint
Date: Tue, 16 Dec 2014 15:57:11 +0300
Message-id: <1418734631-7933-1-git-send-email-d.safonov@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Nicolas Pitre <nicolas.pitre@linaro.org>, James Bottomley <JBottomley@parallels.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Dyasly Sergey <s.dyasly@samsung.com>

ioremap uses __get_vm_area_node which sets alignment to fls of requested size.
I couldn't find any reason for such big align. Does it decrease TLB misses?
What am I missing?

Alignment restriction for ioremap region was introduced with the commit:

> Author: James Bottomley <jejb@mulgrave.(none)>
> Date:   Wed Jun 30 11:11:14 2004 -0500
> 
>     Add vmalloc alignment constraints
> 
>     vmalloc is used by ioremap() to get regions for
>     remapping I/O space.  To feed these regions back
>     into a __get_free_pages() type memory allocator,
>     they are expected to have more alignment than
>     get_vm_area() proves.  So add additional alignment
>     constraints for VM_IOREMAP.
> 
>     Signed-off-by: James Bottomley <James.Bottomley@SteelEye.com>

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: James Bottomley <JBottomley@parallels.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dyasly Sergey <s.dyasly@samsung.com>
Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
---
 arch/arm/include/asm/memory.h       | 5 -----
 arch/unicore32/include/asm/memory.h | 5 -----
 include/linux/vmalloc.h             | 8 --------
 mm/vmalloc.c                        | 2 --
 4 files changed, 20 deletions(-)

diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index 184def0..b333245 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -78,11 +78,6 @@
  */
 #define XIP_VIRT_ADDR(physaddr)  (MODULES_VADDR + ((physaddr) & 0x000fffff))
 
-/*
- * Allow 16MB-aligned ioremap pages
- */
-#define IOREMAP_MAX_ORDER	24
-
 #else /* CONFIG_MMU */
 
 /*
diff --git a/arch/unicore32/include/asm/memory.h b/arch/unicore32/include/asm/memory.h
index debafc4..ffae189 100644
--- a/arch/unicore32/include/asm/memory.h
+++ b/arch/unicore32/include/asm/memory.h
@@ -46,11 +46,6 @@
 #define MODULES_END		(PAGE_OFFSET)
 
 /*
- * Allow 16MB-aligned ioremap pages
- */
-#define IOREMAP_MAX_ORDER	24
-
-/*
  * Physical vs virtual RAM address space conversion.  These are
  * private definitions which should NOT be used outside memory.h
  * files.  Use virt_to_phys/phys_to_virt/__pa/__va instead.
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index b87696f..2f428e8 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -18,14 +18,6 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
-/*
- * Maximum alignment for ioremap() regions.
- * Can be overriden by arch-specific value.
- */
-#ifndef IOREMAP_MAX_ORDER
-#define IOREMAP_MAX_ORDER	(7 + PAGE_SHIFT)	/* 128 pages */
-#endif
-
 struct vm_struct {
 	struct vm_struct	*next;
 	void			*addr;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 39c3388..c4f480dd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1313,8 +1313,6 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 	struct vm_struct *area;
 
 	BUG_ON(in_interrupt());
-	if (flags & VM_IOREMAP)
-		align = 1ul << clamp(fls(size), PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
