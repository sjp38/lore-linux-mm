Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C9A76900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:44:04 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so98870980pab.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:44:04 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id sm2si3291018pac.214.2015.02.03.09.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:55 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ7000SZIRTR350@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:53 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 16/19] mm: vmalloc: pass additional vm_flags to
 __vmalloc_node_range()
Date: Tue, 03 Feb 2015 20:43:09 +0300
Message-id: <1422985392-28652-17-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "supporter:S390" <linux390@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:MIPS" <linux-mips@linux-mips.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:S390" <linux-s390@vger.kernel.org>, "open list:SPARC + UltraSPAR..." <sparclinux@vger.kernel.org>

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

Now we have VM_NO_GUARD flag disabling guard page, so we need to
pass into __vmalloc_node_range(). Add new parameter 'vm_flags'
to __vmalloc_node_range() function.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/arm/kernel/module.c       |  2 +-
 arch/arm64/kernel/module.c     |  4 ++--
 arch/mips/kernel/module.c      |  2 +-
 arch/parisc/kernel/module.c    |  2 +-
 arch/s390/kernel/module.c      |  2 +-
 arch/sparc/kernel/module.c     |  2 +-
 arch/unicore32/kernel/module.c |  2 +-
 arch/x86/kernel/module.c       |  2 +-
 include/linux/vmalloc.h        |  4 +++-
 mm/vmalloc.c                   | 10 ++++++----
 10 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
index bea7db9..2e11961 100644
--- a/arch/arm/kernel/module.c
+++ b/arch/arm/kernel/module.c
@@ -41,7 +41,7 @@
 void *module_alloc(unsigned long size)
 {
 	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				GFP_KERNEL, PAGE_KERNEL_EXEC, NUMA_NO_NODE,
+				GFP_KERNEL, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 }
 #endif
diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
index 9b6f71d..67bf410 100644
--- a/arch/arm64/kernel/module.c
+++ b/arch/arm64/kernel/module.c
@@ -35,8 +35,8 @@
 void *module_alloc(unsigned long size)
 {
 	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				    GFP_KERNEL, PAGE_KERNEL_EXEC, NUMA_NO_NODE,
-				    __builtin_return_address(0));
+				    GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
+				    NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 enum aarch64_reloc_op {
diff --git a/arch/mips/kernel/module.c b/arch/mips/kernel/module.c
index 2a52568..1833f51 100644
--- a/arch/mips/kernel/module.c
+++ b/arch/mips/kernel/module.c
@@ -47,7 +47,7 @@ static DEFINE_SPINLOCK(dbe_lock);
 void *module_alloc(unsigned long size)
 {
 	return __vmalloc_node_range(size, 1, MODULE_START, MODULE_END,
-				GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
+				GFP_KERNEL, PAGE_KERNEL, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 }
 #endif
diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index 5822e8e..3c63a82 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -219,7 +219,7 @@ void *module_alloc(unsigned long size)
 	 * init_data correctly */
 	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
 				    GFP_KERNEL | __GFP_HIGHMEM,
-				    PAGE_KERNEL_RWX, NUMA_NO_NODE,
+				    PAGE_KERNEL_RWX, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 }
 
diff --git a/arch/s390/kernel/module.c b/arch/s390/kernel/module.c
index 409d152..36154a2 100644
--- a/arch/s390/kernel/module.c
+++ b/arch/s390/kernel/module.c
@@ -50,7 +50,7 @@ void *module_alloc(unsigned long size)
 	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
 	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				    GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
+				    GFP_KERNEL, PAGE_KERNEL, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 }
 #endif
diff --git a/arch/sparc/kernel/module.c b/arch/sparc/kernel/module.c
index 97655e0..192a617 100644
--- a/arch/sparc/kernel/module.c
+++ b/arch/sparc/kernel/module.c
@@ -29,7 +29,7 @@ static void *module_map(unsigned long size)
 	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
 	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
+				GFP_KERNEL, PAGE_KERNEL, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 }
 #else
diff --git a/arch/unicore32/kernel/module.c b/arch/unicore32/kernel/module.c
index dc41f6d..e191b34 100644
--- a/arch/unicore32/kernel/module.c
+++ b/arch/unicore32/kernel/module.c
@@ -25,7 +25,7 @@
 void *module_alloc(unsigned long size)
 {
 	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				GFP_KERNEL, PAGE_KERNEL_EXEC, NUMA_NO_NODE,
+				GFP_KERNEL, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 }
 
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index e69f988..e830e61 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -88,7 +88,7 @@ void *module_alloc(unsigned long size)
 	return __vmalloc_node_range(size, 1,
 				    MODULES_VADDR + get_module_load_offset(),
 				    MODULES_END, GFP_KERNEL | __GFP_HIGHMEM,
-				    PAGE_KERNEL_EXEC, NUMA_NO_NODE,
+				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 }
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 1526fe7..7d7acb3 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -76,7 +76,9 @@ extern void *vmalloc_32_user(unsigned long size);
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
 extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
-			pgprot_t prot, int node, const void *caller);
+			pgprot_t prot, unsigned long vm_flags, int node,
+			const void *caller);
+
 extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2e74e99..35b25e1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1619,6 +1619,7 @@ fail:
  *	@end:		vm area range end
  *	@gfp_mask:	flags for the page level allocator
  *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
  *	@node:		node to use for allocation or NUMA_NO_NODE
  *	@caller:	caller's return address
  *
@@ -1628,7 +1629,8 @@ fail:
  */
 void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
-			pgprot_t prot, int node, const void *caller)
+			pgprot_t prot, unsigned long vm_flags, int node,
+			const void *caller)
 {
 	struct vm_struct *area;
 	void *addr;
@@ -1638,8 +1640,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		goto fail;
 
-	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED,
-				  start, end, node, gfp_mask, caller);
+	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
+				vm_flags, start, end, node, gfp_mask, caller);
 	if (!area)
 		goto fail;
 
@@ -1688,7 +1690,7 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    int node, const void *caller)
 {
 	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
-				gfp_mask, prot, node, caller);
+				gfp_mask, prot, 0, node, caller);
 }
 
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
