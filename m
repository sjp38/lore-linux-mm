Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9046B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 16:17:08 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4SKH68Q026661
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:17:06 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by hpaq3.eem.corp.google.com with ESMTP id p4SKH3DO004666
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:17:05 -0700
Received: by pzk4 with SMTP id 4so1242242pzk.28
        for <linux-mm@kvack.org>; Sat, 28 May 2011 13:17:03 -0700 (PDT)
Date: Sat, 28 May 2011 13:17:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix kernel BUG at mm/rmap.c:1017!
Message-ID: <alpine.LSU.2.00.1105281314220.13319@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I've hit the "address >= vma->vm_end" check in do_page_add_anon_rmap()
just once.  The stack showed khugepaged allocation trying to compact
pages: the call to page_add_anon_rmap() coming from remove_migration_pte().

That path holds anon_vma lock, but does not hold mmap_sem: it can
therefore race with a split_vma(), and in commit 5f70b962ccc2 "mmap:
avoid unnecessary anon_vma lock" we just took away the anon_vma lock
protection when adjusting vma->vm_end.

I don't think that particular BUG_ON ever caught anything interesting,
so better replace it by a comment, than reinstate the anon_vma locking.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/rmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/mm/rmap.c	2011-05-27 19:05:27.000000000 -0700
+++ linux/mm/rmap.c	2011-05-27 20:07:44.601361236 -0700
@@ -1014,7 +1014,7 @@ void do_page_add_anon_rmap(struct page *
 		return;
 
 	VM_BUG_ON(!PageLocked(page));
-	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address, exclusive);
 	else
@@ -1709,7 +1709,7 @@ void hugepage_add_anon_rmap(struct page
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
-	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	/* address might be in next vma when migration races vma_adjust */
 	first = atomic_inc_and_test(&page->_mapcount);
 	if (first)
 		__hugepage_set_anon_rmap(page, vma, address, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
