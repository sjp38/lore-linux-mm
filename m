Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0PG5r2H012957
	for <linux-mm@kvack.org>; Fri, 25 Jan 2008 11:05:53 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PG5cM0063664
	for <linux-mm@kvack.org>; Fri, 25 Jan 2008 09:05:47 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PG5cLX012628
	for <linux-mm@kvack.org>; Fri, 25 Jan 2008 09:05:38 -0700
Subject: [RFC][PATCH] remove section mappinng
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Fri, 25 Jan 2008 08:05:05 -0800
Message-Id: <1201277105.26929.36.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev@ozlabs.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, anton@au1.ibm.com, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Paul/Ben/Anton,

As part of making memory remove working on ppc64, I need the code to
remove htab mappings for the section of the memory.

Here is the code I cooked up, it seems to be working fine.
But I have concerns where I need your help.

In order to invalidate htab entries, we need to find the "slot".
But I can only find the hpte group. Is it okay to invalidate the
first entry in the group ? Do I need to invalidate the entire group ?

Please help, as I would like to push this for 2.6.25/2.6.26.

Thanks,
Badari

For memory remove, we need to remove htab mapping. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 arch/powerpc/mm/hash_utils_64.c |   32 ++++++++++++++++++++++++++++++++
 include/asm-powerpc/sparsemem.h |    1 +
 2 files changed, 33 insertions(+)

Index: linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c
===================================================================
--- linux-2.6.24-rc8.orig/arch/powerpc/mm/hash_utils_64.c	2008-01-17 09:47:37.000000000 -0800
+++ linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c	2008-01-25 07:57:48.000000000 -0800
@@ -191,6 +191,33 @@ int htab_bolt_mapping(unsigned long vsta
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
+	for (vaddr = vstart; vaddr < vend; vaddr += step) {
+		unsigned long hash, hpteg;
+		unsigned long vsid = get_kernel_vsid(vaddr, ssize);
+		unsigned long va = hpt_va(vaddr, vsid, ssize);
+
+		hash = hpt_hash(va, shift, ssize);
+		hpteg = ((hash & htab_hash_mask) * HPTES_PER_GROUP);
+
+		/*
+		 * HELP - how do I find the slot ? Is it okay to
+		 * invalidates only first entry ? Do I need to
+		 * remove entire group instead ?
+		 */
+		BUG_ON(!ppc_md.hpte_invalidate);
+		ppc_md.hpte_invalidate(hpteg, va, psize, ssize, 0);
+	}
+}
+
 static int __init htab_dt_scan_seg_sizes(unsigned long node,
 					 const char *uname, int depth,
 					 void *data)
@@ -436,6 +463,11 @@ void create_section_mapping(unsigned lon
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
+++ linux-2.6.24-rc8/include/asm-powerpc/sparsemem.h	2008-01-24 16:20:17.000000000 -0800
@@ -20,6 +20,7 @@
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 extern void create_section_mapping(unsigned long start, unsigned long end);
+extern void remove_section_mapping(unsigned long start, unsigned long end);
 #ifdef CONFIG_NUMA
 extern int hot_add_scn_to_nid(unsigned long scn_addr);
 #else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
