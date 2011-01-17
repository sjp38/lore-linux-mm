Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B52CD8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 09:26:45 -0500 (EST)
Date: Mon, 17 Jan 2011 15:26:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hunting an IO hang
Message-ID: <20110117142614.GP9506@random.random>
References: <AANLkTikBamG2NG6j-z9fyTx=mk6NXFEE7LpB5z9s6ufr@mail.gmail.com>
 <4D339C87.30100@fusionio.com>
 <1295228148-sup-7379@think>
 <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think>
 <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think>
 <20110117051135.GI9506@random.random>
 <1295273312-sup-6780@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295273312-sup-6780@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 09:10:15AM -0500, Chris Mason wrote:
> Excerpts from Andrea Arcangeli's message of 2011-01-17 00:11:35 -0500:
> 
> [ crashes under load ]
> 
> > 
> > NOTE: with the last changes compaction is used for all order > 0 and
> > even from kswapd, so you will now be able to trigger bugs in
> > compaction or migration even with THP off. However I'm surprised that
> > you have issues with compaction...
> 
> I know I mentioned this in another email, but it is kind of buried in
> other context.  I reproduced my crash with CONFIG_COMPACTION and
> CONFIG_MIGRATION off.

Ok, then it was an accident the page->lru got corrupted during
migration and it has nothing to do with migration/compaction/thp. This
makes sense because we should have noticed long ago if something
wasn't stable there.

I reworked the fix for the two memleaks I found while reviewing
migration code for this bug (unrelated) introduced by the commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab. It was enough to move the
goto to fix this without having to add a new function (it's
functionally identical to the one I sent before). It also wouldn't
leak memory if it was compaction invoking migrate_pages (only other
callers checking the retval of migrate_pages instead of list_empty,
could leak memory). As said before, this couldn't explain your
problem, and this is only a code review fix, I never triggered this.

This is still only for review for Minchan, not meant for inclusion
yet.

===
Subject: when migrate_pages returns 0, all pages must have been released

From: Andrea Arcangeli <aarcange@redhat.com>

In some cases migrate_pages could return zero while still leaving a
few pages in the pagelist (and some caller wouldn't notice it has to
call putback_lru_pages after commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab).

Add one missing putback_lru_pages not added by commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 548fbd7..75398b0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1419,6 +1419,7 @@ int soft_offline_page(struct page *page, int flags)
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
 								0, true);
 		if (ret) {
+			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
 			if (ret > 0)
diff --git a/mm/migrate.c b/mm/migrate.c
index 46fe8cc..7d34237 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -772,6 +772,7 @@ uncharge:
 unlock:
 	unlock_page(page);
 
+move_newpage:
 	if (rc != -EAGAIN) {
  		/*
  		 * A page that has been migrated has all references
@@ -785,8 +786,6 @@ unlock:
 		putback_lru_page(page);
 	}
 
-move_newpage:
-
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
