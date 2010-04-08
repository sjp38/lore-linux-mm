Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D3B76B01EF
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:56:24 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 39 of 67] don't leave orhpaned swap cache after ksm merging
Message-Id: <2aff4b2014a8175867ff.1270691482@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

When swapcache is replaced by a ksm page don't leave orhpaned swap cache.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -817,7 +817,7 @@ static int replace_page(struct vm_area_s
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
 	page_remove_rmap(page);
-	put_page(page);
+	free_page_and_swap_cache(page);
 
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
@@ -863,7 +863,18 @@ static int try_to_merge_one_page(struct 
 	 * ptes are necessarily already write-protected.  But in either
 	 * case, we need to lock and check page_count is not raised.
 	 */
-	if (write_protect_page(vma, page, &orig_pte) == 0) {
+	err = write_protect_page(vma, page, &orig_pte);
+
+	/*
+	 * After this mapping is wrprotected we don't need further
+	 * checks for PageSwapCache vs page_count unlock_page(page)
+	 * and we rely only on the pte_same() check run under PT lock
+	 * to ensure the pte didn't change since when we wrprotected
+	 * it under PG_lock.
+	 */
+	unlock_page(page);
+
+	if (!err) {
 		if (!kpage) {
 			/*
 			 * While we hold page lock, upgrade page from
@@ -872,22 +883,22 @@ static int try_to_merge_one_page(struct 
 			 */
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
-			err = 0;
 		} else if (pages_identical(page, kpage))
 			err = replace_page(vma, page, kpage, orig_pte);
-	}
+	} else
+		err = -EFAULT;
 
 	if ((vma->vm_flags & VM_LOCKED) && kpage && !err) {
+		lock_page(page);	/* for LRU manipulation */
 		munlock_vma_page(page);
+		unlock_page(page);
 		if (!PageMlocked(kpage)) {
-			unlock_page(page);
 			lock_page(kpage);
 			mlock_vma_page(kpage);
-			page = kpage;		/* for final unlock */
+			unlock_page(kpage);
 		}
 	}
 
-	unlock_page(page);
 out:
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
