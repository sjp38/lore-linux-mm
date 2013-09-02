Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B6A836B0033
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 23:45:57 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id k18so4646561oag.40
        for <linux-mm@kvack.org>; Sun, 01 Sep 2013 20:45:56 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] mm: thp: khugepaged: add policy for finding target node
Date: Mon,  2 Sep 2013 11:45:42 +0800
Message-Id: <1378093542-31971-2-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, davidoff@qedmf.net, Bob Liu <bob.liu@oracle.com>

Currently khugepaged will try to merge HPAGE_PMD_NR normal pages to a huge page
which is allocated from the node of the first normal page, this policy is very
rough and may affect userland applications.
Andrew Davidoff reported a related issue several days ago.

Using "numactl --interleave=all ./test" to run the testcase, but the result
wasn't not as expected.
cat /proc/2814/numa_maps:
7f50bd440000 interleave:0-3 anon=51403 dirty=51403 N0=435 N1=435 N2=435
N3=50098
The end results showed that most pages are from Node3 instead of interleave
among node0-3 which was unreasonable.

This patch adds a more complicated policy.
When searching HPAGE_PMD_NR normal pages, record which node those pages come
from. Alway allocate hugepage from the node with the max record. If several
nodes have the same max record, try to interleave among them.

After this patch the result was as expected:
7f78399c0000 interleave:0-3 anon=51403 dirty=51403 N0=12723 N1=12723 N2=13235
N3=12722

The simple testcase is like this:
#include<stdio.h>
#include<stdlib.h>

int main() {
	char *p;
	int i;
	int j;

	for (i=0; i < 200; i++) {
		p = (char *)malloc(1048576);
		printf("malloc done\n");

		if (p == 0) {
			printf("Out of memory\n");
			return 1;
		}
		for (j=0; j < 1048576; j++) {
			p[j] = 'A';
		}
		printf("touched memory\n");

		sleep(1);
	}
	printf("enter sleep\n");
	while(1) {
		sleep(100);
	}
}

Reported-by: Andrew Davidoff <davidoff@qedmf.net>
Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 mm/huge_memory.c |   50 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 41 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7448cf9..86c7f0d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2144,7 +2144,33 @@ static void khugepaged_alloc_sleep(void)
 			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
 }
 
+static int khugepaged_node_load[MAX_NUMNODES];
 #ifdef CONFIG_NUMA
+static int last_khugepaged_target_node = NUMA_NO_NODE;
+static int khugepaged_find_target_node(void)
+{
+	int i, target_node = 0, max_value = 1;
+
+	/* find first node with most normal pages hit */
+	for (i = 0; i < MAX_NUMNODES; i++)
+		if (khugepaged_node_load[i] > max_value) {
+			max_value = khugepaged_node_load[i];
+			target_node = i;
+		}
+
+	/* do some balance if several nodes have the same hit number */
+	if (target_node <= last_khugepaged_target_node) {
+		for (i = last_khugepaged_target_node + 1; i < MAX_NUMNODES; i++)
+			if (max_value == khugepaged_node_load[i]) {
+				target_node = i;
+				break;
+			}
+	}
+
+	last_khugepaged_target_node = target_node;
+	return target_node;
+}
+
 static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 {
 	if (IS_ERR(*hpage)) {
@@ -2178,9 +2204,8 @@ static struct page
 	 * mmap_sem in read mode is good idea also to allow greater
 	 * scalability.
 	 */
-	*hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
-				      node, __GFP_OTHER_NODE);
-
+	*hpage = alloc_pages_exact_node(node, alloc_hugepage_gfpmask(
+			khugepaged_defrag(), __GFP_OTHER_NODE), HPAGE_PMD_ORDER);
 	/*
 	 * After allocating the hugepage, release the mmap_sem read lock in
 	 * preparation for taking it in write mode.
@@ -2196,6 +2221,11 @@ static struct page
 	return *hpage;
 }
 #else
+static int khugepaged_find_target_node(void)
+{
+	return 0;
+}
+
 static inline struct page *alloc_hugepage(int defrag)
 {
 	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
@@ -2405,6 +2435,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (pmd_trans_huge(*pmd))
 		goto out;
 
+	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
@@ -2421,12 +2452,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		if (unlikely(!page))
 			goto out_unmap;
 		/*
-		 * Chose the node of the first page. This could
-		 * be more sophisticated and look at more pages,
-		 * but isn't for now.
+		 * Chose the node of most normal pages hit, record this
+		 * informaction to khugepaged_node_load[]
 		 */
-		if (node == NUMA_NO_NODE)
-			node = page_to_nid(page);
+		node = page_to_nid(page);
+		khugepaged_node_load[node]++;
 		VM_BUG_ON(PageCompound(page));
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
@@ -2441,9 +2471,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		ret = 1;
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-	if (ret)
+	if (ret) {
+		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
 		collapse_huge_page(mm, address, hpage, vma, node);
+	}
 out:
 	return ret;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
