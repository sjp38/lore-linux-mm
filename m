Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 84C096B0078
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 12:29:52 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 29 of 31] memcg huge memory
Message-Id: <5947c12b5dfc91731556.1264439960@v2.random>
In-Reply-To: <patchbomb.1264439931@v2.random>
References: <patchbomb.1264439931@v2.random>
Date: Mon, 25 Jan 2010 18:19:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add memcg charge/uncharge to hugepage faults in huge_memory.c.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -212,6 +212,7 @@ static int __do_huge_pmd_anonymous_page(
 	VM_BUG_ON(!PageCompound(page));
 	pgtable = pte_alloc_one(mm, address);
 	if (unlikely(!pgtable)) {
+		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		return VM_FAULT_OOM;
 	}
@@ -229,6 +230,7 @@ static int __do_huge_pmd_anonymous_page(
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_none(*pmd))) {
 		spin_unlock(&mm->page_table_lock);
+		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		pte_free(mm, pgtable);
 	} else {
@@ -266,6 +268,10 @@ int do_huge_pmd_anonymous_page(struct mm
 		page = alloc_hugepage(transparent_hugepage_defrag(vma));
 		if (unlikely(!page))
 			goto out;
+		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+			put_page(page);
+			goto out;
+		}
 
 		return __do_huge_pmd_anonymous_page(mm, vma, address, pmd,
 						    page, haddr);
@@ -366,9 +372,15 @@ static int do_huge_pmd_wp_page_fallback(
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
@@ -427,8 +439,10 @@ out:
 
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
@@ -470,6 +484,11 @@ int do_huge_pmd_wp_page(struct mm_struct
 		goto out;
 	}
 
+	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
+		put_page(new_page);
+		ret |= VM_FAULT_OOM;
+		goto out;
+	}
 	copy_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
@@ -481,9 +500,10 @@ int do_huge_pmd_wp_page(struct mm_struct
 	smp_wmb();
 
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
