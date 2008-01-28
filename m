Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0SMGfLZ027159
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 17:16:41 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0SMGf87095008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 15:16:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0SMGeaJ004883
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 15:16:41 -0700
Subject: Re: [RFC][PATCH] remove section mappinng
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <18330.35819.738293.742989@cargo.ozlabs.ibm.com>
References: <1201277105.26929.36.camel@dyn9047017100.beaverton.ibm.com>
	 <18330.35819.738293.742989@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Jan 2008 14:19:24 -0800
Message-Id: <1201558765.29357.1.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, anton@au1.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-01-26 at 12:24 +1100, Paul Mackerras wrote:
> Badari Pulavarty writes:
> 
> > Here is the code I cooked up, it seems to be working fine.
> > But I have concerns where I need your help.
> > 
> > In order to invalidate htab entries, we need to find the "slot".
> > But I can only find the hpte group. Is it okay to invalidate the
> > first entry in the group ? Do I need to invalidate the entire group ?
> 
> You do need to find the correct slot.  (I suppose you could invalidate
> the entire group, but that would be pretty gross.)
> 
> Note that in the CONFIG_DEBUG_PAGEALLOC case we use 4k pages and keep
> a map of the slot numbers in linear_map_hash_slots[].  But in that
> case I assume that the generic code would have already unmapped all
> the pages of the LMB that you're trying to hot-unplug.
> 
> In the non-DEBUG_PAGEALLOC case on a System p machine, the hash table
> will be big enough that the linear mapping entries should always be in
> slot 0.  So just invalidating slot 0 would probably work in practice,
> but it seems pretty fragile.  We might want to use your new
> htab_remove_mapping() function on a bare-metal system with a smaller
> hash table in future, for instance.
> 
> Have a look at pSeries_lpar_hpte_updateboltedpp.  It calls
> pSeries_lpar_hpte_find to find the slot for a bolted HPTE.  You could
> do something similar.  In fact maybe the best approach is to do a
> pSeries_lpar_hpte_remove_bolted() and not try to solve the more
> general problem.

Paul,

Thank you for your input and suggestions. Does this look reasonable
to you ?

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
