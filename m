Date: Thu, 12 Jun 2008 22:15:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.26-rc5-mm2 (swap_state.c:77)
In-Reply-To: <20080612152905.6cb294ae@cuia.bos.redhat.com>
Message-ID: <Pine.LNX.4.64.0806122131330.10415@blonde.site>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
 <200806101848.22237.nickpiggin@yahoo.com.au> <20080611140902.544e59ec@bree.surriel.com>
 <200806120958.38545.nickpiggin@yahoo.com.au> <20080612152905.6cb294ae@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008, Rik van Riel wrote:
> On Thu, 12 Jun 2008 09:58:38 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > > Does loopback over tmpfs use a different allocation path?
> > 
> > I'm sorry, hmm I didn't look closely enough and forgot that
> > write_begin/write_end requires the callee to allocate the page
> > as well, and that Hugh had nicely unified most of that.
> > 
> > So maybe it's not that. It's pretty easy to hit I found with
> > ext2 mounted over loopback on a tmpfs file.

The loop-on-tmpfs write side is okay nowaways, but the read side
still has to use shmem_readpage, with page passed in from splice.

> Turns out the loopback driver uses splice, which moves
> the pages from one place to another.  This is why you
> were seeing the problem with loopback, but not with
> just a really big file on tmpfs.
> 
> I'm trying to make sense of all the splice code now
> and will send fix as soon as I know how to fix this
> problem in a nice way.

There's no need to make sense of all the splice code, it's just
that it's doing add_to_page_cache_lru (on a page not marked as
SwapBacked), then shmem and swap_state consistency relies on it
as having been marked as SwapBacked.  Normally, yes, shmem_getpage
is the one that allocates the page, but in this case it's already
been done outside, awkward (and long predates loop's use of splice).

It's remarkably hard to correct the LRU of a page once it's been
launched towards one.  Is it still on this cpu's pagevec?  Have we
been preempted and it's on another cpu's pagevec?  If it's reached
the LRU, has vmscan whisked it off for a moment, even though it's
PageLocked?  Until now it's been that the LRUs are self-correcting,
but these patches move away from that.

I don't know how to fix this problem in a nice way.  For the moment,
to proceed with testing, I'm using the hack below.  But perhaps that
screws things up for the other !mapping_cap_account_dirty filesystems
e.g. ramfs, I just haven't tried them yet - nor shall in the next
couple of days.

It could be turned into a proper bdi check of its own, instead of
parasiting off cap_account_dirty.  But I'm not yet convinced by any
of the PageSwapBacked stuff, so currently preferring a quick hack
to a grand scheme.

It's not clear to me why tmpfs file pages should be counted as anon
pages rather than file pages; though it is clear that switching their
LRU midstream, when swizzled to swap, can have implementation problems.

I don't really get why SwapBacked is the important consideration:
I can see that you may want different balancing for pages mapped
into userspace from pages just cached in kernel; but SwapBacked?

Am I right to think that the memcontrol stuff is now all broken,
because memcontrol.c hasn't yet been converted to the more LRUs?
Certainly I'm now hanging when trying to run in a restricted memcg.

Unrelated fix to compiler warning and silly /proc/meminfo numbers
below too, that one raises fewer questions!

Hugh

--- 2.6.26-rc5-mm3/mm/filemap.c	2008-06-12 11:03:35.000000000 +0100
+++ linux/mm/filemap.c	2008-06-12 21:28:43.000000000 +0100
@@ -496,6 +496,8 @@ int add_to_page_cache_lru(struct page *p
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
 	if (ret == 0) {
+		if (!mapping_cap_account_dirty(mapping))
+			SetPageSwapBacked(page);
 		if (page_is_file_cache(page))
 			lru_cache_add_file(page);
 		else
--- 2.6.26-rc5-mm3/fs/proc/proc_misc.c	2008-06-12 11:03:28.000000000 +0100
+++ linux/fs/proc/proc_misc.c	2008-06-12 16:58:34.000000000 +0100
@@ -216,7 +216,7 @@ static int meminfo_read_proc(char *page,
 		K(pages[LRU_INACTIVE_FILE]),
 #ifdef CONFIG_UNEVICTABLE_LRU
 		K(pages[LRU_UNEVICTABLE]),
-		K(pages[NR_MLOCK]),
+		K(global_page_state(NR_MLOCK)),
 #endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
