Date: Thu, 18 Nov 2004 17:40:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: fast path for anonymous memory allocation
In-Reply-To: <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch conflicts with the page fault scalability patch but I could not
leave this stone unturned. No significant performance increases so
this is just for the record in case someone else gets the same wild idea.

The patch implements a fastpath where the page_table_lock is not dropped
in do_anonymous_page. The fastpath steals a page from the hot or cold
lists to get a page quickly.

Results (4 GB and 32 GB allocation on up to 32 processors gradually
incrementing the number of processors)

with patch:
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  4  10    1    0.524s     24.524s  25.005s104653.150 104642.920
  4  10    2    0.456s     29.458s  15.082s 87629.462 165633.410
  4  10    4    0.453s     37.064s  11.002s 69872.279 237796.809
  4  10    8    0.574s     99.258s  15.003s 26258.236 174308.765
  4  10   16    2.171s    279.211s  21.001s  9316.271 124721.683
  4  10   32    2.544s    741.273s  27.093s  3524.299  93827.660

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 32  10    1    4.124s    358.469s 362.061s 57837.481  57834.144
 32  10    2    4.217s    440.333s 235.043s 47174.609  89076.709
 32  10    4    3.778s    321.754s 100.069s 64422.222 208270.694
 32  10    8    3.830s    789.580s 117.067s 26432.116 178211.592
 32  10   16    3.921s   2360.026s 170.021s  8871.395 123203.040
 32  10   32    9.140s   6213.944s 224.068s  3369.955  93338.297

w/o patch:
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  4  10    1    0.449s     24.992s  25.044s103038.282 103022.448
  4  10    2    0.448s     30.290s  16.027s 85282.541 161110.770
  4  10    4    0.420s     38.700s  11.061s 67008.319 225702.353
  4  10    8    0.612s     93.862s  14.059s 27747.547 179564.131
  4  10   16    1.554s    265.199s  20.016s  9827.180 129994.843
  4  10   32    8.088s    657.280s  25.074s  3939.826 101822.835

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 32  10    1    3.966s    366.840s 370.082s 56556.456  56553.456
 32  10    2    3.604s    319.004s 172.058s 65006.086 121511.453
 32  10    4    3.705s    341.550s 106.007s 60741.936 197704.486
 32  10    8    3.597s    809.711s 119.021s 25785.427 175917.674
 32  10   16    5.886s   2238.122s 163.084s  9345.560 127998.973
 32  10   32   21.748s   5458.983s 201.062s  3826.409 104011.521

Only a minimal increase if at all. At the high end the patch leads to
even more contention.

Index: linux-2.6.9/mm/memory.c
===================================================================
--- linux-2.6.9.orig/mm/memory.c	2004-11-18 12:25:49.000000000 -0800
+++ linux-2.6.9/mm/memory.c	2004-11-18 16:53:01.000000000 -0800
@@ -1436,28 +1436,56 @@

 	/* Read-only mapping of ZERO_PAGE. */
 	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
-
 	/* ..except if it's a write access */
 	if (write_access) {
+		struct per_cpu_pageset *pageset;
+		unsigned long flags;
+		int temperature;
+
 		/* Allocate our own private page. */
 		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
-
-		if (unlikely(anon_vma_prepare(vma)))
-			goto no_mem;
-		page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
-		if (!page)
-			goto no_mem;
-		clear_user_highpage(page, addr);
-
-		spin_lock(&mm->page_table_lock);
-		page_table = pte_offset_map(pmd, addr);

-		if (!pte_none(*page_table)) {
-			pte_unmap(page_table);
-			page_cache_release(page);
+		/* This is not numa compatible yet! */
+		pageset = NODE_DATA(numa_node_id())->node_zonelists[GFP_HIGHUSER & GFP_ZONEMASK].zones[0]->pageset+smp_processor_id();
+
+		/* Fastpath for the case that the anonvma is already setup and there are
+		 * pages available in the per_cpu_pageset for this node. If so steal
+		 * pages from the pageset and avoid dropping the page_table_lock.
+		 */
+		local_irq_save(flags);
+		temperature=1;
+		if (vma->anon_vma && (pageset->pcp[temperature].count || pageset->pcp[--temperature].count)) {
+			/* Fastpath for hot/cold pages */
+			page = list_entry(pageset->pcp[temperature].list.next, struct page, lru);
+			list_del(&page->lru);
+			pageset->pcp[temperature].count--;
+			local_irq_restore(flags);
+			page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
+				1 << PG_referenced | 1 << PG_arch_1 |
+				1 << PG_checked | 1 << PG_mappedtodisk);
+		        page->private = 0;
+		        set_page_count(page, 1);
+			/* We skipped updating the zone statistics !*/
+		} else {
+			/* Slow path */
+			local_irq_restore(flags);
 			spin_unlock(&mm->page_table_lock);
-			goto out;
+
+			if (unlikely(anon_vma_prepare(vma)))
+				goto no_mem;
+			page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
+			if (!page)
+				goto no_mem;
+
+			spin_lock(&mm->page_table_lock);
+			page_table = pte_offset_map(pmd, addr);
+
+			if (!pte_none(*page_table)) {
+				pte_unmap(page_table);
+				page_cache_release(page);
+				spin_unlock(&mm->page_table_lock);
+				goto out;
+			}
 		}
 		mm->rss++;
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
@@ -1473,7 +1501,10 @@

 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
+
 	spin_unlock(&mm->page_table_lock);
+	if (write_access)
+		clear_user_highpage(page, addr);
 out:
 	return VM_FAULT_MINOR;
 no_mem:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
