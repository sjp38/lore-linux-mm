Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 977666B0071
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:13 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/8] bail out when the page is in VOLATILE vma
Date: Thu,  3 Jan 2013 13:28:01 +0900
Message-Id: <1357187286-18759-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

If we found a page is in VOLATILE vma, hurry up discarding
instead of access bit check because it's very unlikey working set.

Next patch will use it.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 402d9da..fea01cd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -695,10 +695,12 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (!pte)
 			goto out;
 
-		if (vma->vm_flags & VM_LOCKED) {
+		if ((vma->vm_flags & VM_LOCKED) ||
+				(vma->vm_flags & VM_VOLATILE)) {
 			pte_unmap_unlock(pte, ptl);
 			*mapcount = 0;	/* break early from loop */
-			*vm_flags |= VM_LOCKED;
+			*vm_flags |= (vma->vm_flags & VM_LOCKED ?
+					VM_LOCKED : VM_VOLATILE);
 			goto out;
 		}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
