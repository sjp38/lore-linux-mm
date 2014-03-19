Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 375116B0149
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:43:39 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so5345730eek.21
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:43:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n7si24614630eeu.79.2014.03.18.19.43.36
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 19:43:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH RESEND -mm 2/2] mm/mempolicy.c: add comment in queue_pages_hugetlb()
Date: Tue, 18 Mar 2014 22:29:39 -0400
Message-Id: <1395196179-4075-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1395196179-4075-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1395196179-4075-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have a race where we try to migrate an invalid page, resulting in
hitting VM_BUG_ON_PAGE in isolate_huge_page().
queue_pages_hugetlb() is OK to fail, so let's check !PageHeadHuge to keep
invalid hugepage from queuing.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
index 9d2ef4111a4c..ae6e2d9dc855 100644
--- v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c
+++ v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
@@ -530,6 +530,17 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
 	if (!pte_present(entry))
 		return 0;
 	page = pte_page(entry);
+
+	/*
+	 * Trinity found that page could be a non-hugepage. This is an
+	 * unexpected behavior, but it's not clear how this problem happens.
+	 * So let's simply skip such corner case. Page migration can often
+	 * fail for various reasons, so it's ok to just skip the address
+	 * unsuitable to hugepage migration.
+	 */
+	if (!PageHeadHuge(page))
+		return 0;
+
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
