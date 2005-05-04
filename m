Subject: [2/3] add memory present for ppc64
Message-Id: <E1DTQVJ-0002WU-Fd@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 04 May 2005 21:29:57 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc64-dev@ozlabs.org, paulus@samba.org, anton@samba.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, haveblue@us.ibm.com, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Provide hooks for PPC64 to allow memory models to be informed
of installed memory areas.  This allows SPARSEMEM to instantiate
mem_map for the populated areas.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Martin Bligh <mbligh@aracnet.com>
---
 Kconfig   |    4 ++--
 mm/numa.c |    3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/ppc64/Kconfig current/arch/ppc64/Kconfig
--- reference/arch/ppc64/Kconfig	2005-05-04 20:54:50.000000000 +0100
+++ current/arch/ppc64/Kconfig	2005-05-04 20:54:50.000000000 +0100
@@ -212,8 +212,8 @@ config ARCH_FLATMEM_ENABLE
 source "mm/Kconfig"
 
 config HAVE_ARCH_EARLY_PFN_TO_NID
-	bool
-	default y
+	def_bool y
+	depends on NEED_MULTIPLE_NODES
 
 # Some NUMA nodes have memory ranges that span
 # other nodes.  Even though a pfn is valid and
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/ppc64/mm/numa.c current/arch/ppc64/mm/numa.c
--- reference/arch/ppc64/mm/numa.c	2005-04-11 19:33:15.000000000 +0100
+++ current/arch/ppc64/mm/numa.c	2005-05-04 20:54:50.000000000 +0100
@@ -440,6 +440,8 @@ new_range:
 		for (i = start ; i < (start+size); i += MEMORY_INCREMENT)
 			numa_memory_lookup_table[i >> MEMORY_INCREMENT_SHIFT] =
 				numa_domain;
+		memory_present(numa_domain, start >> PAGE_SHIFT,
+						(start + size) >> PAGE_SHIFT);
 
 		if (--ranges)
 			goto new_range;
@@ -481,6 +483,7 @@ static void __init setup_nonnuma(void)
 
 	for (i = 0 ; i < top_of_ram; i += MEMORY_INCREMENT)
 		numa_memory_lookup_table[i >> MEMORY_INCREMENT_SHIFT] = 0;
+	memory_present(0, 0, init_node_data[0].node_end_pfn);
 }
 
 static void __init dump_numa_topology(void)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
