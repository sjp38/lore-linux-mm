From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051005083846.4308.37575.sendpatchset@cherry.local>
Subject: [PATCH] i386: srat and numaq cleanup
Date: Wed,  5 Oct 2005 17:39:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Cleanup the i386 NUMA code by creating inline no-op functions for
get_memcfg_numaq/srat() and get_zholes_size_numaq/srat().

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

Applies on top of linux-2.6.14-rc2-git8-mhp1

 arch/i386/kernel/srat.c   |   10 ++++++++--
 include/asm-i386/mmzone.h |   26 +++++++++++++++++---------
 include/asm-i386/numaq.h  |   10 ++++++++--
 include/asm-i386/srat.h   |   15 ++++++++++-----
 4 files changed, 43 insertions(+), 18 deletions(-)

--- from-0002/arch/i386/kernel/srat.c
+++ to-work/arch/i386/kernel/srat.c	2005-10-05 16:49:00.000000000 +0900
@@ -56,6 +56,7 @@ struct node_memory_chunk_s {
 static struct node_memory_chunk_s node_memory_chunk[MAXCHUNKS];
 
 static int num_memory_chunks;		/* total number of memory chunks */
+static int has_srat;
 static int zholes_size_init;
 static unsigned long zholes_size[MAX_NUMNODES * MAX_NR_ZONES];
 
@@ -317,7 +318,7 @@ out_fail:
 	return 0;
 }
 
-int __init get_memcfg_from_srat(void)
+int __init get_memcfg_srat(void)
 {
 	struct acpi_table_header *header = NULL;
 	struct acpi_table_rsdp *rsdp = NULL;
@@ -403,6 +404,8 @@ int __init get_memcfg_from_srat(void)
 			continue;
 
 		/* we've found the srat table. don't need to look at any more tables */
+		has_srat = 1;
+
 		return acpi20_parse_srat((struct acpi_table_srat *)header);
 	}
 out_err:
@@ -449,8 +452,11 @@ static void __init get_zholes_init(void)
 	}
 }
 
-unsigned long * __init get_zholes_size(int nid)
+unsigned long * __init get_zholes_size_srat(int nid)
 {
+	if (!has_srat)
+		return NULL;
+
 	if (!zholes_size_init) {
 		zholes_size_init++;
 		get_zholes_init();
--- from-0041/include/asm-i386/mmzone.h
+++ to-work/include/asm-i386/mmzone.h	2005-10-05 16:49:00.000000000 +0900
@@ -12,11 +12,8 @@
 extern struct pglist_data *node_data[];
 #define NODE_DATA(nid)	(node_data[nid])
 
-#ifdef CONFIG_X86_NUMAQ
-	#include <asm/numaq.h>
-#else	/* summit or generic arch */
-	#include <asm/srat.h>
-#endif
+#include <asm/numaq.h>
+#include <asm/srat.h>
 
 extern int get_memcfg_numa_flat(void );
 /*
@@ -26,17 +23,28 @@ extern int get_memcfg_numa_flat(void );
  */
 static inline void get_memcfg_numa(void)
 {
-#ifdef CONFIG_X86_NUMAQ
 	if (get_memcfg_numaq())
 		return;
-#elif defined(CONFIG_ACPI_SRAT)
-	if (get_memcfg_from_srat())
+
+	if (get_memcfg_srat())
 		return;
-#endif
 
 	get_memcfg_numa_flat();
 }
 
+static inline unsigned long *get_zholes_size(int nid)
+{
+	unsigned long *ret;
+
+	if ((ret = get_zholes_size_numaq(nid)))
+		return ret;
+
+	if ((ret = get_zholes_size_srat(nid)))
+		return ret;
+
+	return NULL;
+}
+
 extern int early_pfn_to_nid(unsigned long pfn);
 extern void __init remap_numa_kva(void);
 extern unsigned long calculate_numa_remap_pages(void);
--- from-0001/include/asm-i386/numaq.h
+++ to-work/include/asm-i386/numaq.h	2005-10-05 16:49:00.000000000 +0900
@@ -155,10 +155,16 @@ struct sys_cfg_data {
         struct	eachquadmem eq[MAX_NUMNODES];	/* indexed by quad id */
 };
 
-static inline unsigned long *get_zholes_size(int nid)
+#else /* CONFIG_X86_NUMAQ */
+
+static inline int get_memcfg_numaq(void) { return 0; }
+
+#endif /* CONFIG_X86_NUMAQ */
+
+static inline unsigned long *get_zholes_size_numaq(int nid)
 {
 	return NULL;
 }
-#endif /* CONFIG_X86_NUMAQ */
+
 #endif /* NUMAQ_H */
 
--- from-0001/include/asm-i386/srat.h
+++ to-work/include/asm-i386/srat.h	2005-10-05 16:49:00.000000000 +0900
@@ -27,11 +27,16 @@
 #ifndef _ASM_SRAT_H_
 #define _ASM_SRAT_H_
 
-#ifndef CONFIG_ACPI_SRAT
-#error CONFIG_ACPI_SRAT not defined, and srat.h header has been included
-#endif
+#ifdef CONFIG_ACPI_SRAT
 
-extern int get_memcfg_from_srat(void);
-extern unsigned long *get_zholes_size(int);
+extern int get_memcfg_srat(void);
+extern unsigned long *get_zholes_size_srat(int);
+
+#else /* CONFIG_ACPI_SRAT */
+
+static inline int get_memcfg_srat(void) { return 0; }
+static inline unsigned long *get_zholes_size_srat(int nid) { return NULL; }
+
+#endif /* CONFIG_ACPI_SRAT */
 
 #endif /* _ASM_SRAT_H_ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
