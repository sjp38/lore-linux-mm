Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EAF1A620017
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:05 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 10/12] mm: Check for an empty VMA list in rmap_walk_anon
Date: Fri, 12 Feb 2010 12:00:57 +0000
Message-Id: <1265976059-7459-11-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There appears to be a race in rmap_walk_anon() that can be triggered by using
page migration under heavy load on pages that do not belong to the process
doing the migration - e.g. during memory compaction. The bug triggered is
a NULL pointer deference in list_for_each_entry().

I believe what is happening is that rmap_walk() is called but the process
exits before the lock gets taken. rmap_walk_anon() by design is not holding
the mmap_sem which would have guaranteed its existance.  There is a comment
explaining the locking (or lack thereof) decision but the reasoning is not
very clear.

This patch checks if the VMA list is empty after the lock is taken which
avoids the race. It should be reviewed by people more familiar with
migration to confirm this is a sufficient or if the locking decisions
around rmap_walk() need to be revisited.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/rmap.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 278cd27..b468d5f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1237,6 +1237,14 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
+
+	/*
+	 * While the anon_vma may still exist, there is no guarantee
+	 * the VMAs still do.
+	 */
+	if (list_empty(&anon_vma->head))
+		goto out_anon_unlock;
+
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1245,6 +1253,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		if (ret != SWAP_AGAIN)
 			break;
 	}
+
+out_anon_unlock:
 	spin_unlock(&anon_vma->lock);
 	return ret;
 }
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
