Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 20FA66B002B
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 03:43:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: fix NR_ISOLATED_[ANON|FILE] mismatch
Date: Wed, 19 Sep 2012 16:45:35 +0900
Message-Id: <1348040735-3897-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>

When I looked at zone stat mismatch problem, I found
migrate_to_node doesn't decrease NR_ISOLATED_[ANON|FILE]
if check_range fails.

It can make system hang out.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/mempolicy.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3d64b36..6bf0860 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -953,16 +953,16 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	vma = check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
-	if (IS_ERR(vma))
-		return PTR_ERR(vma);
-
-	if (!list_empty(&pagelist)) {
+	if (IS_ERR(vma)) {
+		err = PTR_ERR(vma);
+		goto out;
+	}
+	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest,
 							false, MIGRATE_SYNC);
-		if (err)
-			putback_lru_pages(&pagelist);
-	}
-
+out:
+	if (err)
+		putback_lru_pages(&pagelist);
 	return err;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
