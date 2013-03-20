Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CFD236B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:03:54 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] x86-64: use vmemmap_populate_basepages() for !pse setups
Date: Wed, 20 Mar 2013 14:03:31 -0400
Message-Id: <1363802612-32127-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
References: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

We already have generic code to allocate vmemmap with regular pages,
use it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/init_64.c | 81 ++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 43 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 1acba7e..134c85d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1282,17 +1282,15 @@ static long __meminitdata addr_start, addr_end;
 static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+static int __meminit vmemmap_populate_hugepages(unsigned long start,
+						unsigned long end, int node)
 {
 	unsigned long addr;
-	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 
-	for (addr = start; addr < end; addr = next) {
-		void *p = NULL;
-
+	for (addr = start; addr < end; addr += PMD_SIZE) {
 		pgd = vmemmap_pgd_populate(addr, node);
 		if (!pgd)
 			return -ENOMEM;
@@ -1301,53 +1299,50 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (!pud)
 			return -ENOMEM;
 
-		if (!cpu_has_pse) {
-			next = (addr + PAGE_SIZE) & PAGE_MASK;
-			pmd = vmemmap_pmd_populate(pud, addr, node);
-
-			if (!pmd)
-				return -ENOMEM;
-
-			p = vmemmap_pte_populate(pmd, addr, node);
+		pmd = pmd_offset(pud, addr);
+		if (pmd_none(*pmd)) {
+			pte_t entry;
+			void *p;
 
+			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (!p)
 				return -ENOMEM;
-		} else {
-			next = pmd_addr_end(addr, end);
 
-			pmd = pmd_offset(pud, addr);
-			if (pmd_none(*pmd)) {
-				pte_t entry;
-
-				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
-				if (!p)
-					return -ENOMEM;
-
-				entry = pfn_pte(__pa(p) >> PAGE_SHIFT,
-						PAGE_KERNEL_LARGE);
-				set_pmd(pmd, __pmd(pte_val(entry)));
-
-				/* check to see if we have contiguous blocks */
-				if (p_end != p || node_start != node) {
-					if (p_start)
-						printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
-						       addr_start, addr_end-1, p_start, p_end-1, node_start);
-					addr_start = addr;
-					node_start = node;
-					p_start = p;
-				}
-
-				addr_end = addr + PMD_SIZE;
-				p_end = p + PMD_SIZE;
-			} else
-				vmemmap_verify((pte_t *)pmd, node, addr, next);
-		}
+			entry = pfn_pte(__pa(p) >> PAGE_SHIFT,
+					PAGE_KERNEL_LARGE);
+			set_pmd(pmd, __pmd(pte_val(entry)));
+
+			/* check to see if we have contiguous blocks */
+			if (p_end != p || node_start != node) {
+				if (p_start)
+					printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
+					       addr_start, addr_end-1, p_start, p_end-1, node_start);
+				addr_start = addr;
+				node_start = node;
+				p_start = p;
+			}
 
+			addr_end = addr + PMD_SIZE;
+			p_end = p + PMD_SIZE;
+		} else
+			vmemmap_verify((pte_t *)pmd, node, addr, next);
 	}
-	sync_global_pgds(start, end - 1);
 	return 0;
 }
 
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+{
+	int err;
+
+	if (cpu_has_pse)
+		err = vmemmap_populate_hugepages(start, end, node);
+	else
+		err = vmemmap_populate_basepages(start, end, node);
+	if (!err)
+		sync_global_pgds(start, end - 1);
+	return err;
+}
+
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HAVE_BOOTMEM_INFO_NODE)
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
