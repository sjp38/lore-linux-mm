Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 509F55F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 22:23:41 -0400 (EDT)
Date: Thu, 16 Apr 2009 04:23:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-ID: <20090416022357.GB22216@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de> <20090415082507.GA23674@wotan.suse.de> <20090415183847.d4fa1efb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415183847.d4fa1efb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here's an incremental patch.

--
On Wed, Apr 15, 2009 at 06:38:47PM -0700, Andrew Morton wrote:
> Whoa.  Running file_update_time() under lock_page() opens a whole can
> of worms, doesn't it?  That thing can do journal commits and all sorts
> of stuff.  And I don't think this ordering is necessary here?

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 mm/memory.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2105,9 +2105,6 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
-		if (vma->vm_file)
-			file_update_time(vma->vm_file);
-
 		/*
 		 * Yes, Virginia, this is actually required to prevent a race
 		 * with clear_page_dirty_for_io() from clearing the page dirty
@@ -2129,6 +2126,10 @@ unlock:
 			page_cache_release(dirty_page);
 			balance_dirty_pages_ratelimited(mapping);
 		}
+
+		/* file_update_time outside page_lock */
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
 	}
 	return ret;
 oom_free_new:
@@ -2760,15 +2761,16 @@ out:
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
 
-		if (vma->vm_file)
-			file_update_time(vma->vm_file);
-
 		if (set_page_dirty(dirty_page))
 			page_mkwrite = 1;
 		unlock_page(dirty_page);
 		put_page(dirty_page);
 		if (page_mkwrite)
 			balance_dirty_pages_ratelimited(mapping);
+
+		/* file_update_time outside page_lock */
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
 	} else {
 		unlock_page(vmf.page);
 		if (anon)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
