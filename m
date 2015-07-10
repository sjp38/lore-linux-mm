Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B0EEB6B0255
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:48:16 -0400 (EDT)
Received: by wgov12 with SMTP id v12so63938309wgo.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 05:48:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey5si15253703wjd.74.2015.07.10.05.48.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 05:48:15 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V5 12/16] mm: provide early_memremap_ro to establish read-only mapping
Date: Fri, 10 Jul 2015 14:47:57 +0200
Message-Id: <1436532481-1224-13-git-send-email-jgross@suse.com>
In-Reply-To: <1436532481-1224-1-git-send-email-jgross@suse.com>
References: <1436532481-1224-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com
Cc: Juergen Gross <jgross@suse.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-arch@vger.kernel.org

During early boot as Xen pv domain the kernel needs to map some page
tables supplied by the hypervisor read only. This is needed to be
able to relocate some data structures conflicting with the physical
memory map especially on systems with huge RAM (above 512GB).

Provide the function early_memremap_ro() to provide this read only
mapping.

Signed-off-by: Juergen Gross <jgross@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
---
 include/asm-generic/early_ioremap.h |  2 ++
 include/asm-generic/fixmap.h        |  3 +++
 mm/early_ioremap.c                  | 12 ++++++++++++
 3 files changed, 17 insertions(+)

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
index f23174f..1cbb833 100644
--- a/include/asm-generic/fixmap.h
+++ b/include/asm-generic/fixmap.h
@@ -46,6 +46,9 @@ static inline unsigned long virt_to_fix(const unsigned long vaddr)
 #ifndef FIXMAP_PAGE_NORMAL
 #define FIXMAP_PAGE_NORMAL PAGE_KERNEL
 #endif
+#if !defined(FIXMAP_PAGE_RO) && defined(PAGE_KERNEL_RO)
+#define FIXMAP_PAGE_RO PAGE_KERNEL_RO
+#endif
 #ifndef FIXMAP_PAGE_NOCACHE
 #define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_NOCACHE
 #endif
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index e10ccd2..0cfadaf 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -217,6 +217,13 @@ early_memremap(resource_size_t phys_addr, unsigned long size)
 	return (__force void *)__early_ioremap(phys_addr, size,
 					       FIXMAP_PAGE_NORMAL);
 }
+#ifdef FIXMAP_PAGE_RO
+void __init *
+early_memremap_ro(resource_size_t phys_addr, unsigned long size)
+{
+	return (__force void *)__early_ioremap(phys_addr, size, FIXMAP_PAGE_RO);
+}
+#endif
 #else /* CONFIG_MMU */
 
 void __init __iomem *
@@ -231,6 +238,11 @@ early_memremap(resource_size_t phys_addr, unsigned long size)
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
