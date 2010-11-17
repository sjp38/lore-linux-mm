Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 73A298D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 07:24:26 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oAHCOMxA032641
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:22 -0800
Received: from yxm8 (yxm8.prod.google.com [10.190.4.8])
	by hpaq14.eem.corp.google.com with ESMTP id oAHCODI3017549
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:21 -0800
Received: by yxm8 with SMTP id 8so1107834yxm.21
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:21 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/3] do_wp_page: clarify dirty_page handling
Date: Wed, 17 Nov 2010 04:23:57 -0800
Message-Id: <1289996638-21439-3-git-send-email-walken@google.com>
In-Reply-To: <1289996638-21439-1-git-send-email-walken@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

Reorganize the code so that dirty pages are handled closer to the place
that makes them dirty (handling write fault into shared, writable VMAs).
No behavior changes.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memory.c |   72 +++++++++++++++++++++++++++++++---------------------------
 1 files changed, 38 insertions(+), 34 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 810a75f..d4c0c2e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2227,8 +2227,45 @@ reuse:
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, page_table);
+		pte_unmap_unlock(page_table, ptl);
 		ret |= VM_FAULT_WRITE;
-		goto unlock;
+
+		if (!dirty_page)
+			return ret;
+
+		/*
+		 * Yes, Virginia, this is actually required to prevent a race
+		 * with clear_page_dirty_for_io() from clearing the page dirty
+		 * bit after it clear all dirty ptes, but before a racing
+		 * do_wp_page installs a dirty pte.
+		 *
+		 * do_no_page is protected similarly.
+		 */
+		if (!page_mkwrite) {
+			wait_on_page_locked(dirty_page);
+			set_page_dirty_balance(dirty_page, page_mkwrite);
+		}
+		put_page(dirty_page);
+		if (page_mkwrite) {
+			struct address_space *mapping = dirty_page->mapping;
+
+			set_page_dirty(dirty_page);
+			unlock_page(dirty_page);
+			page_cache_release(dirty_page);
+			if (mapping)	{
+				/*
+				 * Some device drivers do not set page.mapping
+				 * but still dirty their pages
+				 */
+				balance_dirty_pages_ratelimited(mapping);
+			}
+		}
+
+		/* file_update_time outside page_lock */
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
+
+		return ret;
 	}
 
 	/*
@@ -2334,39 +2371,6 @@ gotten:
 		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	if (dirty_page) {
-		/*
-		 * Yes, Virginia, this is actually required to prevent a race
-		 * with clear_page_dirty_for_io() from clearing the page dirty
-		 * bit after it clear all dirty ptes, but before a racing
-		 * do_wp_page installs a dirty pte.
-		 *
-		 * do_no_page is protected similarly.
-		 */
-		if (!page_mkwrite) {
-			wait_on_page_locked(dirty_page);
-			set_page_dirty_balance(dirty_page, page_mkwrite);
-		}
-		put_page(dirty_page);
-		if (page_mkwrite) {
-			struct address_space *mapping = dirty_page->mapping;
-
-			set_page_dirty(dirty_page);
-			unlock_page(dirty_page);
-			page_cache_release(dirty_page);
-			if (mapping)	{
-				/*
-				 * Some device drivers do not set page.mapping
-				 * but still dirty their pages
-				 */
-				balance_dirty_pages_ratelimited(mapping);
-			}
-		}
-
-		/* file_update_time outside page_lock */
-		if (vma->vm_file)
-			file_update_time(vma->vm_file);
-	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
