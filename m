Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE0C6B014C
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:43:39 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so5381397eek.40
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:43:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w5si24595793eeg.69.2014.03.18.19.43.36
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 19:43:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH RESEND -mm 1/2] mm: add !pte_present() check on existing hugetlb_entry callbacks
Date: Tue, 18 Mar 2014 22:29:38 -0400
Message-Id: <1395196179-4075-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page table walker doesn't check non-present hugetlb entry in common path,
so hugetlb_entry() callbacks must check it. The reason for this behavior
is that some callers want to handle it in its own way.

However, some callers don't check it now, which causes unpredictable result,
for example when we have a race between migrating hugepage and reading
/proc/pid/numa_maps. This patch fixes it by adding !pte_present checks on
buggy callbacks.

This bug exists for years and got visible by introducing hugepage migration.

ChangeLog v2:
- fix if condition (check !pte_present() instead of pte_present())

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.12+
---
 fs/proc/task_mmu.c | 3 +++
 mm/mempolicy.c     | 6 +++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git v3.14-rc7-mmotm-2014-03-18-16-37.orig/fs/proc/task_mmu.c v3.14-rc7-mmotm-2014-03-18-16-37/fs/proc/task_mmu.c
index d9d9d4f41544..f75ce811d430 100644
--- v3.14-rc7-mmotm-2014-03-18-16-37.orig/fs/proc/task_mmu.c
+++ v3.14-rc7-mmotm-2014-03-18-16-37/fs/proc/task_mmu.c
@@ -1300,6 +1300,9 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
 	if (pte_none(*pte))
 		return 0;
 
+	if (!pte_present(*pte))
+		return 0;
+
 	page = pte_page(*pte);
 	if (!page)
 		return 0;
diff --git v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
index af635c458dee..9d2ef4111a4c 100644
--- v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c
+++ v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
@@ -524,8 +524,12 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
 	unsigned long flags = qp->flags;
 	int nid;
 	struct page *page;
+	pte_t entry;
 
-	page = pte_page(huge_ptep_get(pte));
+	entry = huge_ptep_get(pte);
+	if (!pte_present(entry))
+		return 0;
+	page = pte_page(entry);
 	nid = page_to_nid(page);
 	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 		return 0;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
