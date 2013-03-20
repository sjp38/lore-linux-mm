Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B242D6B0039
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:03:57 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] x86-64: fall back to regular page vmemmap on allocation failure
Date: Wed, 20 Mar 2013 14:03:32 -0400
Message-Id: <1363802612-32127-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
References: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Memory hotplug can happen on a machine under load, memory shortness
and fragmentation, so huge page allocations for the vmemmap are not
guaranteed to succeed.

Try to fall back to regular pages before failing the hotplug event
completely.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/init_64.c | 51 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 21 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 134c85d..e2e7afb 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1286,11 +1286,14 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 						unsigned long end, int node)
 {
 	unsigned long addr;
+	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 
-	for (addr = start; addr < end; addr += PMD_SIZE) {
+	for (addr = start; addr < end; addr = next) {
+		next = pmd_addr_end(addr, end);
+
 		pgd = vmemmap_pgd_populate(addr, node);
 		if (!pgd)
 			return -ENOMEM;
@@ -1301,31 +1304,37 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 
 		pmd = pmd_offset(pud, addr);
 		if (pmd_none(*pmd)) {
-			pte_t entry;
 			void *p;
 
 			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
-			if (!p)
-				return -ENOMEM;
-
-			entry = pfn_pte(__pa(p) >> PAGE_SHIFT,
-					PAGE_KERNEL_LARGE);
-			set_pmd(pmd, __pmd(pte_val(entry)));
-
-			/* check to see if we have contiguous blocks */
-			if (p_end != p || node_start != node) {
-				if (p_start)
-					printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
-					       addr_start, addr_end-1, p_start, p_end-1, node_start);
-				addr_start = addr;
-				node_start = node;
-				p_start = p;
-			}
+			if (p) {
+				pte_t entry;
+
+				entry = pfn_pte(__pa(p) >> PAGE_SHIFT,
+						PAGE_KERNEL_LARGE);
+				set_pmd(pmd, __pmd(pte_val(entry)));
+
+				/* check to see if we have contiguous blocks */
+				if (p_end != p || node_start != node) {
+					if (p_start)
+						printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
+						       addr_start, addr_end-1, p_start, p_end-1, node_start);
+					addr_start = addr;
+					node_start = node;
+					p_start = p;
+				}
 
-			addr_end = addr + PMD_SIZE;
-			p_end = p + PMD_SIZE;
-		} else
+				addr_end = addr + PMD_SIZE;
+				p_end = p + PMD_SIZE;
+				continue;
+			}
+		} else if (pmd_large(*pmd)) {
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
+			continue;
+		}
+		pr_warn_once("vmemmap: falling back to regular page backing\n");
+		if (vmemmap_populate_basepages(addr, next, node))
+			return -ENOMEM;
 	}
 	return 0;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
