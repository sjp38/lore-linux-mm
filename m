From: Juergen Gross <jgross@suse.com>
Subject: [Patch V3 12/15] mm: provide early_memremap_ro to
	establish read-only mapping
Date: Mon, 20 Apr 2015 07:23:37 +0200
Message-ID: <1429507420-18201-13-git-send-email-jgross@suse.com>
References: <1429507420-18201-1-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1429507420-18201-1-git-send-email-jgross@suse.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
To: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.comlinux-mm, @kvack.org
Cc: Juergen Gross <jgross@suse.com>
List-Id: linux-mm.kvack.org

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
