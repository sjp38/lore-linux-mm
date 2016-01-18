Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 12FD16B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 04:46:09 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id q63so159940897pfb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:46:09 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id z68si38671062pfi.34.2016.01.18.01.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 01:46:08 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id uo6so417345340pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:46:08 -0800 (PST)
Date: Mon, 18 Jan 2016 01:45:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
In-Reply-To: <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1601180133050.5730@eggly.anvils>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com> <1447181081-30056-2-git-send-email-aarcange@redhat.com> <alpine.LSU.2.11.1601141356080.13199@eggly.anvils> <20160116174953.GU31137@redhat.com>
 <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 18 Jan 2016, Hugh Dickins wrote:
> On Sat, 16 Jan 2016, Andrea Arcangeli wrote:
> > On Thu, Jan 14, 2016 at 03:36:56PM -0800, Hugh Dickins wrote:
> > > 
> > > You've got me fired up.  Mel's recent 72b252aed506 "mm: send one IPI per
> > > CPU to TLB flush all entries after unmapping pages" and nearby commits
> > > are very much to the point here; but because his first draft was unsafe
> > > in the page migration area, he dropped that, and ended up submitting
> > > for page reclaim alone.
> > > 
> > > That's the first low-hanging fruit: we should apply Mel's batching
> > > to page migration; and it's become clear enough in my mind, that I'm
> > > now impatient to try it myself (but maybe Mel will respond if he has
> > > a patch for it already).  If I can't post a patch for that early next
> > > week, someone else take over (or preempt me); yes, there's all kinds
> > > of other things I should be doing instead, but this is too tempting.
> > > 
> > > That can help, not just KSM's long chains, but most other migration of
> > > mapped pages too.  (The KSM case is particularly easy, because those
> > > pages are known to be mapped write-protected, and its long chains can
> > > benefit just from batching on the single page; but in general, I
> > > believe we want to batch across pages there too, when we can.)
> 
> I'll send that, but I wasn't able to take it as far as I'd hoped,
> not for the file-backed pages anyway.

Here's what I did against v4.4, haven't looked at current git yet.
And there's an XXX where I found the MR_MEMORY_FAILURE case a little
confusing, so didn't yet add back the necessary variant code for that.
But I was probably too excited above, overestimating the significance
of the IPIs here.

--- v4.4/mm/migrate.c	2016-01-10 15:01:32.000000000 -0800
+++ linux/mm/migrate.c	2016-01-18 01:28:26.861853142 -0800
@@ -887,8 +887,21 @@ static int __unmap_and_move(struct page
 		/* Establish migration ptes */
 		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma,
 				page);
-		try_to_unmap(page,
+		try_to_unmap(page, TTU_BATCH_FLUSH|
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		/*
+		 * We must flush TLBs before copying the page if a pte was
+		 * dirty, because otherwise further mods could be made to page
+		 * without faulting, and never copied to newpage.  That's true
+		 * of anon and file pages; but it's even worse for a file page,
+		 * because once newpage is unlocked, it can be written via the
+		 * pagecache, and those mods must be visible through its ptes.
+		 * We could hold newpage lock for longer, but how much longer?
+		 */
+		if (PageAnon(page))
+			try_to_unmap_flush_dirty();
+		else
+			try_to_unmap_flush();
 		page_was_mapped = 1;
 	}
 
@@ -927,8 +940,7 @@ out:
 static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				   free_page_t put_new_page,
 				   unsigned long private, struct page *page,
-				   int force, enum migrate_mode mode,
-				   enum migrate_reason reason)
+				   int force, enum migrate_mode mode)
 {
 	int rc = MIGRATEPAGE_SUCCESS;
 	int *result = NULL;
@@ -950,27 +962,7 @@ static ICE_noinline int unmap_and_move(n
 	rc = __unmap_and_move(page, newpage, force, mode);
 	if (rc == MIGRATEPAGE_SUCCESS)
 		put_new_page = NULL;
-
 out:
-	if (rc != -EAGAIN) {
-		/*
-		 * A page that has been migrated has all references
-		 * removed and will be freed. A page that has not been
-		 * migrated will have kepts its references and be
-		 * restored.
-		 */
-		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE) {
-			put_page(page);
-			if (!test_set_page_hwpoison(page))
-				num_poisoned_pages_inc();
-		} else
-			putback_lru_page(page);
-	}
-
 	/*
 	 * If migration was not successful and there's a freeing callback, use
 	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
@@ -1029,10 +1021,8 @@ static int unmap_and_move_huge_page(new_
 	 * tables or check whether the hugepage is pmd-based or not before
 	 * kicking migration.
 	 */
-	if (!hugepage_migration_supported(page_hstate(hpage))) {
-		putback_active_hugepage(hpage);
+	if (!hugepage_migration_supported(page_hstate(hpage)))
 		return -ENOSYS;
-	}
 
 	new_hpage = get_new_page(hpage, private, &result);
 	if (!new_hpage)
@@ -1051,8 +1041,9 @@ static int unmap_and_move_huge_page(new_
 		goto put_anon;
 
 	if (page_mapped(hpage)) {
-		try_to_unmap(hpage,
+		try_to_unmap(hpage, TTU_BATCH_FLUSH|
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		try_to_unmap_flush();
 		page_was_mapped = 1;
 	}
 
@@ -1076,9 +1067,6 @@ put_anon:
 
 	unlock_page(hpage);
 out:
-	if (rc != -EAGAIN)
-		putback_active_hugepage(hpage);
-
 	/*
 	 * If migration was not successful and there's a freeing callback, use
 	 * it.  Otherwise, put_page() will drop the reference grabbed during
@@ -1123,6 +1111,7 @@ int migrate_pages(struct list_head *from
 		free_page_t put_new_page, unsigned long private,
 		enum migrate_mode mode, int reason)
 {
+	LIST_HEAD(putback_pages);
 	int retry = 1;
 	int nr_failed = 0;
 	int nr_succeeded = 0;
@@ -1147,8 +1136,20 @@ int migrate_pages(struct list_head *from
 						pass > 2, mode);
 			else
 				rc = unmap_and_move(get_new_page, put_new_page,
-						private, page, pass > 2, mode,
-						reason);
+						private, page, pass > 2, mode);
+
+			if (rc != -EAGAIN) {
+				/*
+				 * A page that has been migrated has had all
+				 * references removed and will be freed once
+				 * TLBs have been flushed. A page that has not
+				 * been migrated will have kept its references
+				 * and been restored.
+				 *
+				 * XXX: Get the MR_MEMORY_FAILURE case right.
+				 */
+				list_move_tail(&page->lru, &putback_pages);
+			}
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1183,6 +1184,10 @@ out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
+	try_to_unmap_flush();
+	putback_movable_pages(&putback_pages);
+	/* But our caller has to putback the -EAGAIN pages left on from list */
+
 	return rc;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
