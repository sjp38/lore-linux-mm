Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E62006B0047
	for <linux-mm@kvack.org>; Sat,  2 Oct 2010 20:49:09 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o930n7xu015347
	for <linux-mm@kvack.org>; Sat, 2 Oct 2010 17:49:07 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq3.eem.corp.google.com with ESMTP id o930n5MP030708
	for <linux-mm@kvack.org>; Sat, 2 Oct 2010 17:49:05 -0700
Received: by pxi10 with SMTP id 10so1266852pxi.33
        for <linux-mm@kvack.org>; Sat, 02 Oct 2010 17:49:04 -0700 (PDT)
Date: Sat, 2 Oct 2010 17:49:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] ksm: fix bad user data when swapping
Message-ID: <alpine.LSU.2.00.1010021746180.27679@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Building under memory pressure, with KSM on 2.6.36-rc5, collapsed with
an internal compiler error: typically indicating an error in swapping.

Perhaps there's a timing issue which makes it now more likely, perhaps
it's just a long time since I tried for so long: this bug goes back to
KSM swapping in 2.6.33.

Notice how reuse_swap_page() allows an exclusive page to be reused, but
only does SetPageDirty if it can delete it from swap cache right then -
if it's currently under Writeback, it has to be left in cache and we
don't SetPageDirty, but the page can be reused.  Fine, the dirty bit
will get set in the pte; but notice how zap_pte_range() does not bother
to transfer pte_dirty to page_dirty when unmapping a PageAnon.

If KSM chooses to share such a page, it will look like a clean copy of
swapcache, and not be written out to swap when its memory is needed;
then stale data read back from swap when it's needed again.

We could fix this in reuse_swap_page() (or even refuse to reuse a
page under writeback), but it's more honest to fix my oversight in
KSM's write_protect_page().  Several days of testing on three machines
confirms that this fixes the issue they showed.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/ksm.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- 2.6.36-rc6/mm/ksm.c	2010-09-12 17:34:03.000000000 -0700
+++ linux/mm/ksm.c	2010-09-28 23:27:05.000000000 -0700
@@ -712,7 +712,7 @@ static int write_protect_page(struct vm_
 	if (!ptep)
 		goto out;
 
-	if (pte_write(*ptep)) {
+	if (pte_write(*ptep) || pte_dirty(*ptep)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
@@ -735,7 +735,9 @@ static int write_protect_page(struct vm_
 			set_pte_at(mm, addr, ptep, entry);
 			goto out_unlock;
 		}
-		entry = pte_wrprotect(entry);
+		if (pte_dirty(entry))
+			set_page_dirty(page);
+		entry = pte_mkclean(pte_wrprotect(entry));
 		set_pte_at_notify(mm, addr, ptep, entry);
 	}
 	*orig_pte = *ptep;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
