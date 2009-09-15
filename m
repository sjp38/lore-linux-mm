Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4926E6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:33:47 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:33:02 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/4] mm: hugetlbfs_pagecache_present
In-Reply-To: <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909152131530.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rename hugetlbfs_backed() to hugetlbfs_pagecache_present()
and add more comments, as suggested by Mel Gorman.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/hugetlb.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

--- mm1/mm/hugetlb.c	2009-09-14 16:34:37.000000000 +0100
+++ mm2/mm/hugetlb.c	2009-09-15 17:32:12.000000000 +0100
@@ -2016,8 +2016,11 @@ static struct page *hugetlbfs_pagecache_
 	return find_lock_page(mapping, idx);
 }
 
-/* Return whether there is a pagecache page to back given address within VMA */
-static bool hugetlbfs_backed(struct hstate *h,
+/*
+ * Return whether there is a pagecache page to back given address within VMA.
+ * Caller follow_hugetlb_page() holds page_table_lock so we cannot lock_page.
+ */
+static bool hugetlbfs_pagecache_present(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	struct address_space *mapping;
@@ -2254,10 +2257,13 @@ int follow_hugetlb_page(struct mm_struct
 
 		/*
 		 * When coredumping, it suits get_dump_page if we just return
-		 * an error if there's a hole and no huge pagecache to back it.
+		 * an error where there's an empty slot with no huge pagecache
+		 * to back it.  This way, we avoid allocating a hugepage, and
+		 * the sparse dumpfile avoids allocating disk blocks, but its
+		 * huge holes still show up with zeroes where they need to be.
 		 */
-		if (absent &&
-		    ((flags & FOLL_DUMP) && !hugetlbfs_backed(h, vma, vaddr))) {
+		if (absent && (flags & FOLL_DUMP) &&
+		    !hugetlbfs_pagecache_present(h, vma, vaddr)) {
 			remainder = 0;
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
