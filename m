Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A48A56B015E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:21:27 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 32 of 34] memcg huge memory
Message-Id: <3af632a32828d5721634.1268839174@v2.random>
In-Reply-To: <patchbomb.1268839142@v2.random>
References: <patchbomb.1268839142@v2.random>
Date: Wed, 17 Mar 2010 16:19:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add memcg charge/uncharge to hugepage faults in huge_memory.c.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -225,6 +225,7 @@ static int __do_huge_pmd_anonymous_page(
 	VM_BUG_ON(!PageCompound(page));
 	pgtable = pte_alloc_one(mm, haddr);
 	if (unlikely(!pgtable)) {
+		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		return VM_FAULT_OOM;
 	}
@@ -235,6 +236,7 @@ static int __do_huge_pmd_anonymous_page(
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_none(*pmd))) {
 		spin_unlock(&mm->page_table_lock);
+		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		pte_free(mm, pgtable);
 	} else {
@@ -278,6 +280,10 @@ int do_huge_pmd_anonymous_page(struct mm
 		page = alloc_hugepage(transparent_hugepage_defrag(vma));
 		if (unlikely(!page))
 			goto out;
+		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+			put_page(page);
+			goto out;
+		}
 
 		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
 	}
@@ -377,9 +383,15 @@ static int do_huge_pmd_wp_page_fallback(
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
 					  vma, address);
-		if (unlikely(!pages[i])) {
-			while (--i >= 0)
+		if (unlikely(!pages[i] ||
+			     mem_cgroup_newpage_charge(pages[i], mm,
+						       GFP_KERNEL))) {
+			if (pages[i])
 				put_page(pages[i]);
+			while (--i >= 0) {
+				mem_cgroup_uncharge_page(pages[i]);
+				put_page(pages[i]);
+			}
 			kfree(pages);
 			ret |= VM_FAULT_OOM;
 			goto out;
@@ -438,8 +450,10 @@ out:
 
 out_free_pages:
 	spin_unlock(&mm->page_table_lock);
-	for (i = 0; i < HPAGE_PMD_NR; i++)
+	for (i = 0; i < HPAGE_PMD_NR; i++) {
+		mem_cgroup_uncharge_page(pages[i]);
 		put_page(pages[i]);
+	}
 	kfree(pages);
 	goto out;
 }
@@ -482,13 +496,19 @@ int do_huge_pmd_wp_page(struct mm_struct
 		goto out;
 	}
 
+	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
+		put_page(new_page);
+		ret |= VM_FAULT_OOM;
+		goto out;
+	}
 	copy_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
+		mem_cgroup_uncharge_page(new_page);
 		put_page(new_page);
-	else {
+	} else {
 		pmd_t entry;
 		entry = mk_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
