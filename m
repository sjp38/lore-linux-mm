Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id C84956B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 04:45:11 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3348677pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 01:45:11 -0700 (PDT)
Date: Fri, 1 Jun 2012 01:44:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <20120601023107.GA19445@redhat.com>
Message-ID: <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 May 2012, Dave Jones wrote:
> On Wed, May 30, 2012 at 08:57:40PM -0400, Dave Jones wrote:
>  > On Wed, May 30, 2012 at 12:33:17PM -0400, Dave Jones wrote:
>  >  > Just saw this on Linus tree as of 731a7378b81c2f5fa88ca1ae20b83d548d5613dc
>  >  > 
>  >  > WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()

I did see your reports, and noted to come back to them, but sad to say I
hadn't even made time to check out line 1990 of mm/page-writeback.c: ah,
that WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));

>  >  > Pid: 35, comm: khugepaged Not tainted 3.4.0+ #75
>  >  > Call Trace:
>  >  >  [<ffffffff81146bda>] __set_page_dirty_nobuffers+0x13a/0x170
>  >  >  [<ffffffff81193322>] migrate_page_copy+0x1e2/0x260
>  > 
>  > Seems this can be triggered from mmap, as well as from khugepaged..
>  > 
>  > WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
>  > Pid: 1171, comm: trinity-child4 Not tainted 3.4.0+ #38
>  > Call Trace:
>  >  [<ffffffff8114b4ea>] __set_page_dirty_nobuffers+0x13a/0x170
>  >  [<ffffffff81197db2>] migrate_page_copy+0x1e2/0x260
>  > 
>  > I'd bisect this, but it takes a few hours to trigger, which makes it hard
>  > to distinguish between 'good kernel' and 'hasn't triggered yet'.
> 
> So I bisected it anyway, and it led to ...

Thanks so much for taking the trouble.

> 
> 3f31d07571eeea18a7d34db9af21d2285b807a17 is the first bad commit
> commit 3f31d07571eeea18a7d34db9af21d2285b807a17
> Author: Hugh Dickins <hughd@google.com>
> Date:   Tue May 29 15:06:40 2012 -0700
> 
>     mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
>     
>     Now tmpfs supports hole-punching via fallocate(), switch madvise_remove()
>     to use do_fallocate() instead of vmtruncate_range(): which extends
>     madvise(,,MADV_REMOVE) support from tmpfs to ext4, ocfs2 and xfs.
> 
> Hugh ?

Ow, you've caught me.

> 
> I'll repeat the bisect tomorrow just to be sure. (It took all day, even though
> there were only a half dozen bisect points, as I ran the test for an hour on
> each build to see what fell out).
> 
> Here's what I found..
> 
> git bisect start 'mm/'
> # bad: [4b395d7ea79472ac240ee8768b4930ca9ce096ef] Merge /home/davej/src/git-trees/kernel/linux
> git bisect bad 4b395d7ea79472ac240ee8768b4930ca9ce096ef
> # good: [76e10d158efb6d4516018846f60c2ab5501900bc] Linux 3.4
> git bisect good 76e10d158efb6d4516018846f60c2ab5501900bc
> # good: [c6785b6bf1b2a4b47238b24ee56f61e27c3af682] mm: bootmem: rename alloc_bootmem_core to alloc_bootmem_bdata
> git bisect good c6785b6bf1b2a4b47238b24ee56f61e27c3af682
> # bad: [89abfab133ef1f5902abafb744df72793213ac19] mm/memcg: move reclaim_stat into lruvec
> git bisect bad 89abfab133ef1f5902abafb744df72793213ac19
> # bad: [4fb5ef089b288942c6fc3f85c4ecb4016c1aa4c3] tmpfs: support SEEK_DATA and SEEK_HOLE
> git bisect bad 4fb5ef089b288942c6fc3f85c4ecb4016c1aa4c3
> # good: [bde05d1ccd512696b09db9dd2e5f33ad19152605] shmem: replace page if mapping excludes its zone
> git bisect good bde05d1ccd512696b09db9dd2e5f33ad19152605
> # bad: [3f31d07571eeea18a7d34db9af21d2285b807a17] mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
> git bisect bad 3f31d07571eeea18a7d34db9af21d2285b807a17
> # good: [ec9516fbc5fa814014991e1ae7f8860127122105] tmpfs: optimize clearing when writing
> git bisect good ec9516fbc5fa814014991e1ae7f8860127122105
> # good: [83e4fa9c16e4af7122e31be3eca5d57881d236fe] tmpfs: support fallocate FALLOC_FL_PUNCH_HOLE
> git bisect good 83e4fa9c16e4af7122e31be3eca5d57881d236fe

That puzzled me for quite a while: it seemed so much more likely that
your bisection would converge on the commit which comes a few later,
1635f6a74152 "tmpfs: undo fallocation on failure", where indeed I do
start to play around with tmpfs pages unlocked while !PageUptodate.

And yes, they're PageDirty !PagePrivate, so migration could very well
end up trying to migrate one and hitting line 1990.  It's an aberration
of migrate_page_copy(), that it uses __set_page_dirty_nobuffers() on
mappings which would never normally go that way at all (I discovered
this last year, when I experimented with radix_tree tags for swap in
tmpfs, and hit upon this rare case where page migration sets a dirty
tag for a tmpfs page, despite tmpfs never using tags).

One half of the patch at the bottom should fix that: I'm not sure that
it's the fix we actually want (a mapping_cap_account_dirty test might
be more appropriate, but it's easier just to test a page flag here);
but it should be good to shed more light on the problem.

Because your bisection converged on a commit a few before I introduced
that bug - and although it was a difficult bisection, you would be very
unlikely to mistake a good for bad: the danger was the other way around.

So I'm wondering if your trinity fuzzer happens to succeed a lot more
often on madvise MADV_REMOVEs than fallocate FALLOC_FL_PUNCH_HOLEs, and
the bug you converged on is not in tmpfs, but in ext4 (or xfs? or ocfs2?),
which began to support MADV_REMOVE with that commit.

So the second half of the patch should show which filesystem's page is
involved when you hit the WARN_ON - unless the first half of the patch
turns out to stop the warnings completely, in which case I need to think
harder about what was going on in tmpfs, and whether it matters.

Or another possibility is that the bad commit doesn't actually touch mm
at all: you were doing a bisection just on mm/ changes, weren't you?

> 
> This has been a challenge to bisect additionally because I'm not sure if the other mm
> bug I reported in the last few days (the list_debug/list_add corruption warnings in the
> compaction code) are related or not.

At present I suspect they're not related; but may change my mind.

> Sometimes during the bisect these errors happened
> in pairs, sometimes only together.

Sometimes in pairs, sometimes together?  I don't understand.

And are "these errors" the list debug warnings,
or list debug warnings and Line 1990 warnings?

> The 'good' builds showed no errors at all.
> 
> As a reminder, the list_add corruption looks like this...
> 
> WARNING: at lib/list_debug.c:29 __list_add+0x6c/0x90()
> list_add corruption. next->prev should be prev (ffff88014e5d9ed8), but was ffffea0004f48360. (next=ffffea0004b23920).
> Pid: 24594, comm: trinity-child1 Not tainted 3.4.0+ #42
> Call Trace:
>  [<ffffffff81048fdf>] warn_slowpath_common+0x7f/0xc0
>  [<ffffffff810490d6>] warn_slowpath_fmt+0x46/0x50
>  [<ffffffff810b767d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff813259dc>] __list_add+0x6c/0x90
>  [<ffffffff8114591d>] move_freepages_block+0x16d/0x190
>  [<ffffffff81165773>] suitable_migration_target.isra.14+0x1b3/0x1d0
>  [<ffffffff81165cab>] compaction_alloc+0x1db/0x2f0
>  [<ffffffff81198357>] migrate_pages+0xc7/0x540
>  [<ffffffff81165ad0>] ? isolate_freepages_block+0x260/0x260
>  [<ffffffff81166946>] compact_zone+0x216/0x480
>  [<ffffffff81166e8d>] compact_zone_order+0x8d/0xd0
>  [<ffffffff81149565>] ? get_page_from_freelist+0x565/0x970
>  [<ffffffff81166f99>] try_to_compact_pages+0xc9/0x140
>  [<ffffffff8163b7f2>] __alloc_pages_direct_compact+0xaa/0x1d0
>  [<ffffffff81149f7b>] __alloc_pages_nodemask+0x60b/0xab0
>  [<ffffffff810b12d8>] ? trace_hardirqs_off_caller+0x28/0xc0
>  [<ffffffff810b4c00>] ? __lock_acquire+0x2f0/0x1aa0
>  [<ffffffff81189ce6>] alloc_pages_vma+0xb6/0x190
>  [<ffffffff8119cd83>] do_huge_pmd_anonymous_page+0x133/0x310
>  [<ffffffff8116c0a2>] handle_mm_fault+0x242/0x2e0
>  [<ffffffff8116c352>] __get_user_pages+0x142/0x560
>  [<ffffffff81171a18>] ? mmap_region+0x3f8/0x630
>  [<ffffffff8116c822>] get_user_pages+0x52/0x60
>  [<ffffffff8116d712>] make_pages_present+0x92/0xc0
>  [<ffffffff811719c6>] mmap_region+0x3a6/0x630
>  [<ffffffff81050a3c>] ? do_setitimer+0x1cc/0x310
>  [<ffffffff81171fad>] do_mmap_pgoff+0x35d/0x3b0
>  [<ffffffff81172066>] ? sys_mmap_pgoff+0x66/0x240
>  [<ffffffff81172084>] sys_mmap_pgoff+0x84/0x240
>  [<ffffffff8131f31e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff81006ca2>] sys_mmap+0x22/0x30
>  [<ffffffff8164e012>] system_call_fastpath+0x16/0x1b
> ---[ end trace b606ea2a53bf1425 ]---
> 
> On an affected kernel, it'll show up within an hour of fuzzing on a fast machine.

Please give this patch a try (preferably on current git), and let us know.

Thanks,
Hugh

--- 3.4.0+/mm/migrate.c	2012-05-27 10:01:43.104049010 -0700
+++ linux/mm/migrate.c	2012-06-01 00:10:58.080098749 -0700
@@ -436,7 +436,10 @@ void migrate_page_copy(struct page *newp
 		 * is actually a signal that all of the page has become dirty.
 		 * Whereas only part of our page may be dirty.
 		 */
-		__set_page_dirty_nobuffers(newpage);
+		if (PageSwapBacked(page))
+			SetPageDirty(newpage);
+		else
+			__set_page_dirty_nobuffers(newpage);
  	}
 
 	mlock_migrate_page(newpage, page);
--- 3.4.0+/mm/page-writeback.c	2012-05-29 08:09:58.304806782 -0700
+++ linux/mm/page-writeback.c	2012-06-01 00:23:43.984116973 -0700
@@ -1987,7 +1987,10 @@ int __set_page_dirty_nobuffers(struct pa
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
-			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
+			if (WARN_ON(!PagePrivate(page) && !PageUptodate(page)))
+				print_symbol(KERN_WARNING
+				    "mapping->a_ops->writepage: %s\n",
+				    (unsigned long)mapping->a_ops->writepage);
 			account_page_dirtied(page, mapping);
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
