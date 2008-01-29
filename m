Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0T0X2kM013451
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 19:33:02 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0T0X2kk109548
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 17:33:02 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0T0X1Ro021033
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 17:33:01 -0700
Subject: Re: [-mm PATCH] updates for hotplug memory remove
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1201566682.29357.15.camel@dyn9047017100.beaverton.ibm.com>
References: <1201566682.29357.15.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Jan 2008 16:35:45 -0800
Message-Id: <1201566946.29357.18.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-01-28 at 16:31 -0800, Badari Pulavarty wrote:


> 2) Can you replace the following patch with this ?
> 
> add-remove_memory-for-ppc64-2.patch
> 
> I found that, I do need arch-specific hooks to get the memory remove
> working on ppc64 LPAR. Earlier, I tried to make remove_memory() arch
> neutral, but we do need arch specific hooks.
> 
> Thanks,
> Badari

Andrew,

Here is the patch which provides arch-specific code to complete memory
remove on ppc64 LPAR. So far, it works fine in my testing - but waiting
for ppc-experts for review and completeness. 

FYI.

Thanks,
Badari

For memory remove, we need to clean up htab mappings for the
section of the memory we are removing.

This patch implements support for removing htab bolted mappings
for ppc64 lpar. Other sub-archs, may need to implement similar
functionality for the hotplug memory remove to work. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 arch/powerpc/mm/hash_utils_64.c       |   23 +++++++++++++++++++++++
 arch/powerpc/mm/mem.c                 |    4 +++-
 arch/powerpc/platforms/pseries/lpar.c |   15 +++++++++++++++
 include/asm-powerpc/machdep.h         |    2 ++
 include/asm-powerpc/sparsemem.h       |    1 +
 5 files changed, 44 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c
===================================================================
--- linux-2.6.24-rc8.orig/arch/powerpc/mm/hash_utils_64.c	2008-01-25 08:04:32.000000000 -0800
+++ linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c	2008-01-28 11:45:40.000000000 -0800
@@ -191,6 +191,24 @@ int htab_bolt_mapping(unsigned long vsta
 	return ret < 0 ? ret : 0;
 }
 
+static void htab_remove_mapping(unsigned long vstart, unsigned long vend,
+		      int psize, int ssize)
+{
+	unsigned long vaddr;
+	unsigned int step, shift;
+
+	shift = mmu_psize_defs[psize].shift;
+	step = 1 << shift;
+
+	if (!ppc_md.hpte_removebolted) {
+		printk("Sub-arch doesn't implement hpte_removebolted\n");
+		return;
+	}
+
+	for (vaddr = vstart; vaddr < vend; vaddr += step)
+		ppc_md.hpte_removebolted(vaddr, psize, ssize);
+}
+
 static int __init htab_dt_scan_seg_sizes(unsigned long node,
 					 const char *uname, int depth,
 					 void *data)
@@ -436,6 +454,11 @@ void create_section_mapping(unsigned lon
 			_PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_COHERENT | PP_RWXX,
 			mmu_linear_psize, mmu_kernel_ssize));
 }
+
+void remove_section_mapping(unsigned long start, unsigned long end)
+{
+	htab_remove_mapping(start, end, mmu_linear_psize, mmu_kernel_ssize);
+}
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 static inline void make_bl(unsigned int *insn_addr, void *func)
Index: linux-2.6.24-rc8/include/asm-powerpc/sparsemem.h
===================================================================
--- linux-2.6.24-rc8.orig/include/asm-powerpc/sparsemem.h	2008-01-15 20:22:48.000000000 -0800
+++ linux-2.6.24-rc8/include/asm-powerpc/sparsemem.h	2008-01-25 08:18:11.000000000 -0800
@@ -20,6 +20,7 @@
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 extern void create_section_mapping(unsigned long start, unsigned long end);
+extern void remove_section_mapping(unsigned long start, unsigned long end);
 #ifdef CONFIG_NUMA
 extern int hot_add_scn_to_nid(unsigned long scn_addr);
 #else
Index: linux-2.6.24-rc8/arch/powerpc/mm/mem.c
===================================================================
--- linux-2.6.24-rc8.orig/arch/powerpc/mm/mem.c	2008-01-25 08:16:37.000000000 -0800
+++ linux-2.6.24-rc8/arch/powerpc/mm/mem.c	2008-01-25 08:20:33.000000000 -0800
@@ -156,7 +156,9 @@ int remove_memory(u64 start, u64 size)
 	ret = offline_pages(start_pfn, end_pfn, 120 * HZ);
 	if (ret)
 		goto out;
-	/* Arch-specific calls go here - next patch */
+
+	start = (unsigned long)__va(start);
+	remove_section_mapping(start, start + size);
 out:
 	return ret;
 }
Index: linux-2.6.24-rc8/arch/powerpc/platforms/pseries/lpar.c
===================================================================
--- linux-2.6.24-rc8.orig/arch/powerpc/platforms/pseries/lpar.c	2008-01-15 20:22:48.000000000 -0800
+++ linux-2.6.24-rc8/arch/powerpc/platforms/pseries/lpar.c	2008-01-28 14:10:58.000000000 -0800
@@ -520,6 +520,20 @@ static void pSeries_lpar_hpte_invalidate
 	BUG_ON(lpar_rc != H_SUCCESS);
 }
 
+static void pSeries_lpar_hpte_removebolted(unsigned long ea,
+					   int psize, int ssize)
+{
+	unsigned long slot, vsid, va;
+
+	vsid = get_kernel_vsid(ea, ssize);
+	va = hpt_va(ea, vsid, ssize);
+
+	slot = pSeries_lpar_hpte_find(va, psize, ssize);
+	BUG_ON(slot == -1);
+
+	pSeries_lpar_hpte_invalidate(slot, va, psize, ssize, 0);
+}
+
 /* Flag bits for H_BULK_REMOVE */
 #define HBR_REQUEST	0x4000000000000000UL
 #define HBR_RESPONSE	0x8000000000000000UL
@@ -597,6 +611,7 @@ void __init hpte_init_lpar(void)
 	ppc_md.hpte_updateboltedpp = pSeries_lpar_hpte_updateboltedpp;
 	ppc_md.hpte_insert	= pSeries_lpar_hpte_insert;
 	ppc_md.hpte_remove	= pSeries_lpar_hpte_remove;
+	ppc_md.hpte_removebolted = pSeries_lpar_hpte_removebolted;
 	ppc_md.flush_hash_range	= pSeries_lpar_flush_hash_range;
 	ppc_md.hpte_clear_all   = pSeries_lpar_hptab_clear;
 }
Index: linux-2.6.24-rc8/include/asm-powerpc/machdep.h
===================================================================
--- linux-2.6.24-rc8.orig/include/asm-powerpc/machdep.h	2008-01-25 08:04:41.000000000 -0800
+++ linux-2.6.24-rc8/include/asm-powerpc/machdep.h	2008-01-28 11:45:17.000000000 -0800
@@ -68,6 +68,8 @@ struct machdep_calls {
 				       unsigned long vflags,
 				       int psize, int ssize);
 	long		(*hpte_remove)(unsigned long hpte_group);
+	void            (*hpte_removebolted)(unsigned long ea,
+					     int psize, int ssize);
 	void		(*flush_hash_range)(unsigned long number, int local);
 
 	/* special for kexec, to be called in real mode, linar mapping is


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
