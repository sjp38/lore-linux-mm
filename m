Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C40DB6B0098
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:21 -0500 (EST)
Message-Id: <20100309194316.650729518@redhat.com>
Date: Tue, 09 Mar 2010 20:39:32 +0100
From: aarcange@redhat.com
Subject: [patch 31/35] pmd_trans_huge migrate bugcheck
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=pmd_trans_huge_migrate
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

No pmd_trans_huge should ever materialize in migration ptes areas, because
we split the hugepage before migration ptes are instantiated.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/huge_mm.h |    5 +++++
 mm/migrate.c            |    5 +++++
 2 files changed, 10 insertions(+)

--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -113,6 +113,10 @@ static inline int PageTransHuge(struct p
 	VM_BUG_ON(PageTail(page));
 	return PageHead(page);
 }
+static inline int PageTransCompound(struct page *page)
+{
+	return PageCompound(page);
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUG(); 0; })
@@ -132,6 +136,7 @@ static inline int split_huge_page(struct
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
 #define PageTransHuge(page) 0
+#define PageTransCompound(page) 0
 static inline int hugepage_madvise(unsigned long *vm_flags)
 {
 	BUG_ON(0);
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -99,6 +99,7 @@ static int remove_migration_pte(struct p
 		goto out;
 
 	pmd = pmd_offset(pud, addr);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (!pmd_present(*pmd))
 		goto out;
 
@@ -815,6 +816,10 @@ static int do_move_page_to_node_array(st
 		if (PageReserved(page) || PageKsm(page))
 			goto put_and_set;
 
+		if (unlikely(PageTransCompound(page)))
+			if (unlikely(split_huge_page(page)))
+				goto put_and_set;
+
 		pp->page = page;
 		err = page_to_nid(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
