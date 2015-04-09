Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9A60C6B006C
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 03:02:10 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so86318963wia.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 00:02:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh7si22611538wjc.45.2015.04.08.23.56.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 23:56:03 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V2 12/15] mm: provide early_memremap_ro to establish read-only mapping
Date: Thu,  9 Apr 2015 08:55:39 +0200
Message-Id: <1428562542-28488-13-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-1-git-send-email-jgross@suse.com>
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

During early boot as Xen pv domain the kernel needs to map some page
tables supplied by the hypervisor read only. This is needed to be
able to relocate some data structures conflicting with the physical
memory map especially on systems with huge RAM (above 512GB).

Provide the function early_memremap_ro() to provide this read only
mapping.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 include/asm-generic/early_ioremap.h |  2 ++
 include/asm-generic/fixmap.h        |  3 +++
 mm/early_ioremap.c                  | 11 +++++++++++
 3 files changed, 16 insertions(+)

diff --git a/include/asm-generic/early_ioremap.h b/include/asm-generic/early_ioremap.h
index a5de55c..316bd04 100644
--- a/include/asm-generic/early_ioremap.h
+++ b/include/asm-generic/early_ioremap.h
@@ -11,6 +11,8 @@ extern void __iomem *early_ioremap(resource_size_t phys_addr,
 				   unsigned long size);
 extern void *early_memremap(resource_size_t phys_addr,
 			    unsigned long size);
+extern void *early_memremap_ro(resource_size_t phys_addr,
+			       unsigned long size);
 extern void early_iounmap(void __iomem *addr, unsigned long size);
 extern void early_memunmap(void *addr, unsigned long size);
 
diff --git a/include/asm-generic/fixmap.h b/include/asm-generic/fixmap.h
index f23174f..d8cc637 100644
--- a/include/asm-generic/fixmap.h
+++ b/include/asm-generic/fixmap.h
@@ -46,6 +46,9 @@ static inline unsigned long virt_to_fix(const unsigned long vaddr)
 #ifndef FIXMAP_PAGE_NORMAL
 #define FIXMAP_PAGE_NORMAL PAGE_KERNEL
 #endif
+#ifndef FIXMAP_PAGE_RO
+#define FIXMAP_PAGE_RO PAGE_KERNEL_RO
+#endif
 #ifndef FIXMAP_PAGE_NOCACHE
 #define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_NOCACHE
 #endif
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index e10ccd2..e4ffaac 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -217,6 +217,12 @@ early_memremap(resource_size_t phys_addr, unsigned long size)
 	return (__force void *)__early_ioremap(phys_addr, size,
 					       FIXMAP_PAGE_NORMAL);
 }
+void __init *
+early_memremap_ro(resource_size_t phys_addr, unsigned long size)
+{
+	return (__force void *)__early_ioremap(phys_addr, size,
+					       FIXMAP_PAGE_RO);
+}
 #else /* CONFIG_MMU */
 
 void __init __iomem *
@@ -231,6 +237,11 @@ early_memremap(resource_size_t phys_addr, unsigned long size)
 {
 	return (void *)phys_addr;
 }
+void __init *
+early_memremap_ro(resource_size_t phys_addr, unsigned long size)
+{
+	return (void *)phys_addr;
+}
 
 void __init early_iounmap(void __iomem *addr, unsigned long size)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
