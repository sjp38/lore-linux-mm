Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3C4316B0073
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:11:57 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4804276pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:11:56 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 1/8] mm, vmalloc: change iterating a vmlist to find_vm_area()
Date: Fri,  7 Dec 2012 01:09:28 +0900
Message-Id: <1354810175-4338-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Chris Metcalf <cmetcalf@tilera.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

The purpose of iterating a vmlist is finding vm area with specific
virtual address. find_vm_area() is provided for this purpose
and more efficient, because it uses a rbtree.
So change it.

Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index de0de0c..862782d 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -592,12 +592,7 @@ void iounmap(volatile void __iomem *addr_in)
 	   in parallel. Reuse of the virtual address is prevented by
 	   leaving it in the global lists until we're done with it.
 	   cpa takes care of the direct mappings. */
-	read_lock(&vmlist_lock);
-	for (p = vmlist; p; p = p->next) {
-		if (p->addr == addr)
-			break;
-	}
-	read_unlock(&vmlist_lock);
+	p = find_vm_area((void *)addr);
 
 	if (!p) {
 		pr_err("iounmap: bad address %p\n", addr);
diff --git a/arch/unicore32/mm/ioremap.c b/arch/unicore32/mm/ioremap.c
index b7a6055..13068ee 100644
--- a/arch/unicore32/mm/ioremap.c
+++ b/arch/unicore32/mm/ioremap.c
@@ -235,7 +235,7 @@ EXPORT_SYMBOL(__uc32_ioremap_cached);
 void __uc32_iounmap(volatile void __iomem *io_addr)
 {
 	void *addr = (void *)(PAGE_MASK & (unsigned long)io_addr);
-	struct vm_struct **p, *tmp;
+	struct vm_struct *vm;
 
 	/*
 	 * If this is a section based mapping we need to handle it
@@ -244,17 +244,10 @@ void __uc32_iounmap(volatile void __iomem *io_addr)
 	 * all the mappings before the area can be reclaimed
 	 * by someone else.
 	 */
-	write_lock(&vmlist_lock);
-	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
-		if ((tmp->flags & VM_IOREMAP) && (tmp->addr == addr)) {
-			if (tmp->flags & VM_UNICORE_SECTION_MAPPING) {
-				unmap_area_sections((unsigned long)tmp->addr,
-						    tmp->size);
-			}
-			break;
-		}
-	}
-	write_unlock(&vmlist_lock);
+	vm = find_vm_area(addr);
+	if (vm && (vm->flags & VM_IOREMAP) &&
+		(vm->flags & VM_UNICORE_SECTION_MAPPING))
+		unmap_area_sections((unsigned long)vm->addr, vm->size);
 
 	vunmap(addr);
 }
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 78fe3f1..9a1e658 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -282,12 +282,7 @@ void iounmap(volatile void __iomem *addr)
 	   in parallel. Reuse of the virtual address is prevented by
 	   leaving it in the global lists until we're done with it.
 	   cpa takes care of the direct mappings. */
-	read_lock(&vmlist_lock);
-	for (p = vmlist; p; p = p->next) {
-		if (p->addr == (void __force *)addr)
-			break;
-	}
-	read_unlock(&vmlist_lock);
+	p = find_vm_area((void __force *)addr);
 
 	if (!p) {
 		printk(KERN_ERR "iounmap: bad address %p\n", addr);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
