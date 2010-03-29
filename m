Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2E8B06B01AD
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 10:02:33 -0400 (EDT)
Date: Mon, 29 Mar 2010 16:01:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
Message-ID: <20100329140125.GT5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <6a19c093c020d009e736.1269622839@v2.random>
 <4BACEBF8.90909@redhat.com>
 <20100326172321.GA5825@random.random>
 <alpine.LSU.2.00.1003262113310.8896@sister.anvils>
 <20100327010818.GI5825@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100327010818.GI5825@random.random>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sat, Mar 27, 2010 at 02:08:18AM +0100, Andrea Arcangeli wrote:
> more familiar with, only takes the PG_lock during page_wrprotect! Why
> do you keep the PG_lock during replace_page too? do_wp_page can't run
> as we re-verify the pte didn't change. Maybe is just to be safer?

I re-read it and I can't see any valid reason to hold the PG_lock
after write_protect_page returns. The only reason we added the PG_lock
is needed is to abort the page merging if there's any GUP pin on the
page. And so we must prevent the swapcache to alter the page_count
while we read PageSwapCache and we include it in the page_count
comparison. We also must read the pte value inside that critical
section to re-check it later inside replace_page with pte_same with
the PT lock hold to serialize against the VM.

So I think returning to the previous locking should be the preferred
way. What do you think? I don't think the fact kpage can be swapped
can affect it, "page" should always be a regular anon page and never a
ksm page. Otherwise it would be futile to try to wrprotect it in the
first place for example.

Let me know if you think something like this could be ok, and I'll
send it to Andrew separately (not more mixed with the rest).

Thanks again for spotting it ;).
Andrea

Subject: don't leave orhpaned swap cache after ksm merging

From: Andrea Arcangeli <aarcange@redhat.com>

When swapcache is replaced by a ksm page don't leave orhpaned swap cache.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
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
@@ -872,22 +883,20 @@ static int try_to_merge_one_page(struct 
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
 		munlock_vma_page(page);
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
