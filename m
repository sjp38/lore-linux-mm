Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 510EA9000C1
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 12:50:09 -0400 (EDT)
Date: Tue, 12 Jul 2011 18:50:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: mm: do_wp_page recheck PageKsm after obtaining the page_lock,
 pte_same not enough
Message-ID: <20110712165003.GP23227@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Johannes Weiner <jweiner@redhat.com>

Hi Hugh,

what do you think about this?

===
Subject: mm: do_wp_page recheck PageKsm after obtaining the page_lock, pte_same not enough

From: Andrea Arcangeli <aarcange@redhat.com>

There seems to be a bug in do_wp_page that if not fixed, it would
lead to a Ksm shared page to be mapped read-write into some process pte leading
to random memory corruption in userland MADV_MEARGEABLE vmas.

If the orig_pte value was read by do_wp_page after
write_protect_page() (likely as if the pte wasn't originally read as
readonly by handle_pte_fault, do_wp_page wouldn't be called in the
first place), but if we reach lock_page() in the !PageKsm path (before
reuse_swap_page is called), but before set_page_stable_node() run (the
kpage == NULL case), the orig_pte wouldn't have changed (after
write_protect_page returned the pte doesn't change anymore and then we
release the page lock), and the pte_same() check would succeed, but
the old_page would have become a PageKsm already before releasing the
page lock in try_to_merge_one_page, so we shouldn't go ahead with
reuse_swap_page in do_wp_page in that case. But we do, and then we
reuse the wrprotected PageKsm in the stable tree allowing userland to
map it read-write. The PageKsm check I introduced below in memory.c
should close this race, it is enough to check the page is not Ksm to
know if we can takeover it or not after we obtain the page lock.

To say it in another way, the current and only PageKsm check in
do_wp_page in short is racy because it's run before trying to obtain
the page lock, so it could run before set_page_stable_node() had a
chance to run yet.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2454,7 +2454,8 @@ static int do_wp_page(struct mm_struct *
 			lock_page(old_page);
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			if (!pte_same(*page_table, orig_pte) ||
+			    PageKsm(old_page)) {
 				unlock_page(old_page);
 				goto unlock;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
