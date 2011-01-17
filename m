Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 596B38D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 00:12:05 -0500 (EST)
Date: Mon, 17 Jan 2011 06:11:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hunting an IO hang
Message-ID: <20110117051135.GI9506@random.random>
References: <1295225684-sup-7168@think>
 <AANLkTikBamG2NG6j-z9fyTx=mk6NXFEE7LpB5z9s6ufr@mail.gmail.com>
 <4D339C87.30100@fusionio.com>
 <1295228148-sup-7379@think>
 <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think>
 <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295231547-sup-8036@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 16, 2011 at 09:41:41PM -0500, Chris Mason wrote:
> Excerpts from Andrew Morton's message of 2011-01-16 21:30:00 -0500:
> > (lots of cc's added)
> > 
> > On Sun, 16 Jan 2011 21:07:40 -0500 Chris Mason <chris.mason@oracle.com> wrote:
> > 
> > > Excerpts from Linus Torvalds's message of 2011-01-16 20:53:04 -0500:
> > > > .. except I actually didn't add Andrew to the cc after all.
> > > > 
> > > > NOW I did.
> > > > 
> > > > Oh, and if you can repeat this and bisect it, it would obviously be
> > > > great. But that sounds rather painful.
> > > 
> > > Ok, so I've got 3 different problems in 3 totally different areas.
> > > I'm running w/kvm, but this VM is very stable with 2.6.37.  Running
> > > Linus' current git it goes boom in exotic ways, this time it was only on
> > > ext3, btrfs code never loaded.
> > > 
> > > Linus, if you're planning on rc1 tonight I'll send my pull request out
> > > the door.  Otherwise I'd prefer to fix this and send my pull after
> > > actually getting a long btrfs run on the current code.
> > > 
> > > Next up, CONFIG_DEBUG*, always an adventure on rc1 kernels ;)
> > > 
> > > WARNING: at lib/list_debug.c:57 list_del+0xc0/0xed()
> > > Hardware name: Bochs
> > > list_del corruption. next->prev should be ffffea000010cde0, but was ffff88007cff6bc8
> > > Modules linked in:
> > > Pid: 524, comm: kswapd0 Not tainted 2.6.37-josef+ #180
> > > Call Trace:
> > >  [<ffffffff8106ec94>] ? warn_slowpath_common+0x85/0x9d
> > >  [<ffffffff8106ed4f>] ? warn_slowpath_fmt+0x46/0x48
> > >  [<ffffffff81263d6c>] ? list_del+0xc0/0xed
> > >  [<ffffffff81106d9d>] ? migrate_pages+0x26f/0x357
> > >  [<ffffffff81100e18>] ? compaction_alloc+0x0/0x2dc
> > >  [<ffffffff8110150d>] ? compact_zone+0x391/0x5c4
> > >  [<ffffffff81101905>] ? compact_zone_order+0xc2/0xd1
> > >  [<ffffffff815c321e>] ? _raw_spin_unlock+0xe/0x10
> > >  [<ffffffff810dc446>] ? kswapd+0x5c8/0x88f
> > >  [<ffffffff810dbe7e>] ? kswapd+0x0/0x88f
> > >  [<ffffffff81089ce8>] ? kthread+0x82/0x8a
> > >  [<ffffffff810347d4>] ? kernel_thread_helper+0x4/0x10
> > >  [<ffffffff81089c66>] ? kthread+0x0/0x8a
> > >  [<ffffffff810347d0>] ? kernel_thread_helper+0x0/0x10
> > > ---[ end trace 5c6b7933d16b301f ]---
> > 
> > uh-oh.  Does disabling CONFIG_COMPACTION make this go away (requires
> > disabling CONFIG_TRANSPARENT_HUGEPAGE first).
> 
> We'll see.  I gave THP this same run of tests back in November, it
> passed without any problems (after fixing the related btrfs migration
> bug).  All of the crashes I've seen this weekend had this in the
> .config:
> 
> # CONFIG_TRANSPARENT_HUGEPAGE is not set
> CONFIG_COMPACTION=y
> CONFIG_MIGRATION=y

I think it's unrelated but reading commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab if page_count(page) == 1 we
leave the page in the lru but we return 0 (so the caller of
migrate_pages won't call putback_lru_pages to actually free the page,
however compaction would free it because it checks if the list is
empty and it ignores the migrate_pages retval). And in
mm/memory-failure.c:1419, nobody is calling putback_lru_pages (it
seems a missing bit from that older patch). They seem just two memleak
unrelated to the above though.

NOTE: with the last changes compaction is used for all order > 0 and
even from kswapd, so you will now be able to trigger bugs in
compaction or migration even with THP off. However I'm surprised that
you have issues with compaction...

I'm posting this for Minchan to review (not meant for merging, untested).

======
Subject: when migrate_pages returns 0, all pages must have been released

From: Andrea Arcangeli <aarcange@redhat.com>

In some cases migrate_pages could return zero while still leaving a
few pages in the pagelist (and some caller wouldn't notice it has to
call putback_lru_pages).

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
index 46fe8cc..bea2a34 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -611,6 +611,14 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	return rc;
 }
 
+static void unmap_and_move_release_page(struct page *page)
+{
+	list_del(&page->lru);
+	dec_zone_page_state(page, NR_ISOLATED_ANON +
+			    page_is_file_cache(page));
+	putback_lru_page(page);
+}
+
 /*
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
@@ -631,11 +639,14 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
+		unmap_and_move_release_page(page);
 		goto move_newpage;
 	}
 	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page(page)))
+		if (unlikely(split_huge_page(page))) {
+			unmap_and_move_release_page(page);
 			goto move_newpage;
+		}
 
 	/* prepare cgroup just returns 0 or -ENOMEM */
 	rc = -EAGAIN;
@@ -779,10 +790,7 @@ unlock:
  		 * migrated will have kepts its references and be
  		 * restored.
  		 */
- 		list_del(&page->lru);
-		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-		putback_lru_page(page);
+		unmap_and_move_release_page(page);
 	}
 
 move_newpage:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
