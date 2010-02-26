Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC3C96B007E
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:06 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK95t4020099
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500
Message-Id: <20100226200903.932549316@redhat.com>
Date: Fri, 26 Feb 2010 21:05:04 +0100
From: aarcange@redhat.com
Subject: [patch 31/35] pmd_trans_huge migrate bugcheck
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=pmd_trans_huge_migrate
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
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
