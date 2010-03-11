Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DBCD56B00E7
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 12:23:49 -0500 (EST)
Date: Thu, 11 Mar 2010 11:23:40 -0600
From: Robin Holt <holt@sgi.com>
Subject: [Patch] mm/ksm.c is doing an unneeded _notify in
 write_protect_page.
Message-ID: <20100311172340.GD5685@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


ksm.c's write_protect_page implements a lockless means of verifying a
page does not have any users of the page which are not accounted for via
other kernel tracking means.  It does this by removing the writable pte
with TLB flushes, checking the page_count against the total known users,
and then using set_pte_at_notify to make it a read-only entry.

An unneeded mmu_notifier callout is made in the case where the known
users does not match the page_count.  In that event, we are inserting
the identical pte and there is no need for the set_pte_at_notify, but
rather the simpler set_pte_at suffices.

To: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Izik Eidus <ieidus@redhat.com>
Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Chris Wright <chrisw@redhat.com>
Cc: linux-mm@kvack.org

---

 mm/ksm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: ksm_remove_notify/mm/ksm.c
===================================================================
--- ksm_remove_notify.orig/mm/ksm.c	2010-03-11 11:21:57.000000000 -0600
+++ ksm_remove_notify/mm/ksm.c	2010-03-11 11:21:59.000000000 -0600
@@ -751,7 +751,7 @@ static int write_protect_page(struct vm_
 		 * page
 		 */
 		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
-			set_pte_at_notify(mm, addr, ptep, entry);
+			set_pte_at(mm, addr, ptep, entry);
 			goto out_unlock;
 		}
 		entry = pte_wrprotect(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
