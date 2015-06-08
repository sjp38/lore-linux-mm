Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DD0A86B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:13:29 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so101749277wgb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:13:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp13si793092wic.64.2015.06.08.05.07.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:05 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 12/16] mm: provide early_memremap_ro to establish read-only mapping
Date: Mon,  8 Jun 2015 14:06:53 +0200
Message-Id: <1433765217-16333-13-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
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
