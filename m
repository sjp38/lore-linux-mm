Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 754B16B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 21:42:00 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6767950dak.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 18:41:59 -0700 (PDT)
Date: Fri, 18 May 2012 18:41:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
In-Reply-To: <alpine.LSU.2.00.1205142101420.2196@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205181753310.9617@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils> <20120514161330.def0ac52.akpm@linux-foundation.org> <alpine.LSU.2.00.1205142101420.2196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 May 2012, Hugh Dickins wrote:
> On Mon, 14 May 2012, Andrew Morton wrote:
> > On Sat, 12 May 2012 04:59:56 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > > 
> > > We'd like to continue to support GMA500, so now add a new
> > > shmem_should_replace_page() check on the zone when about to move
> > > a page from swapcache to filecache (in swapin and swapoff cases),
> > > with shmem_replace_page() to allocate and substitute a suitable page
> > > (given gma500/gem.c's mapping_set_gfp_mask GFP_KERNEL | __GFP_DMA32).
> > >  
> ...
> > > +	gfp = mapping_gfp_mask(mapping);
> > > +	if (shmem_should_replace_page(*pagep, gfp)) {
> > > +		mutex_unlock(&shmem_swaplist_mutex);
> > > +		error = shmem_replace_page(pagep, gfp, info, index);
> > > +		mutex_lock(&shmem_swaplist_mutex);
> > > +		/*
> > > +		 * We needed to drop mutex to make that restrictive page
> > > +		 * allocation; but the inode might already be freed by now,
> > > +		 * and we cannot refer to inode or mapping or info to check.
> > > +		 * However, we do hold page lock on the PageSwapCache page,
> > > +		 * so can check if that still has our reference remaining.
> > > +		 */
> > > +		if (!page_swapcount(*pagep))
> > > +			error = -ENOENT;
> > 
> > This has my head spinning a bit.  What is "our reference"?  I'd expect
> > that to mean a temporary reference which was taken by this thread of
> > control.
> 
> (I'm sure you'll prefer a reworking of that comment in an incremental
> fixes patch, but let me try to explain better here too.)
> 
> No, I didn't mean a temporary reference taken by this (swapoff) thread,
> but the reference (swap entry) which has just been located in the inode's
> radix_tree, just before this hunk: which would be tracked by page_swapcount
> 1 (there's also a page swapcache bit in the swap_map along with the count,
> corresponding to the reference from the swapcache page itself, but that's
> not included in page_swapcount).
> 
> > But such a thing has no relevance when trying to determine
> > the state of the page and/or data structures which refer to it.
> 
> I don't understand you there, but maybe it won't matter.
> 
> > 
> > Also, what are we trying to determine here with this test?  Whether the
> > page was removed from swapcache under our feet?  Presumably not, as it
> > is locked.
> > 
> > So perhaps you could spell out in more detail what we're trying to do
> > here, and what contributes to page_swapcount() here?
> 
> The danger here is that the inode we're dealing with has gone through
> shmem_evict_inode() while we dropped shmem_swaplist_mutex: inode was
> certainly in use before, and shmem_swaplist_mutex (together with inode
> being on shmem_swaplist) holds it up from being evicted and freed; but
> once we drop the mutex, it could go away at any moment.  We cannot
> determine that by looking at struct inode or struct address_space or
> struct shmem_inode_info, they're all part of what would be freed;
> but we cannot proceed to shmem_add_to_page_cache() once they're freed.
> How to tell whether it's been freed?
> 
> Once upon a time I "solved" it with igrab() and iput(), but Konstantin
> demonstrated how that gives no safety against unmounting, and I remain
> reluctant to go back to relying upon filesystem semantics to solve this.
> 
> It occurred to me that the inode cannot be freed until that radix_tree
> entry has been removed (by shmem_evict_inode's shmem_truncate_range),
> and the act or removing that entry (free_swap_and_cache) brings
> page_swapcount down from 1 to 0.
> 
> You're thinking that the page cannot be removed from swapcache while
> we hold page lock: correct, but... free_swap_and_cache() only does a
> trylock_page(), and happily leaves the swapcache page to be garbage
> collected later if it cannot get the page lock.  (And I certainly
> would not want to change it to wait for page lock.)  So, the inode
> can get evicted while the page is still in swapcache: the page lock
> gives no protection against that, until the page itself gets into
> the radix_tree.
> 
> I doubt that writing this essay into a comment there will be the
> right thing to do (and I may still be losing you); but I shall try
> to rewrite it, and if there's one missing fact that needs highlighting,
> it probably is that last, that free_swap_and_cache() only does a trylock,
> so our page lock does not protect the inode from eviction.
> 
> (At this moment, I can't think what is the relevance of my comment
> "we do hold page lock on the PageSwapCache page": in other contexts it
> would be important, but here in swapoff we know that that swap cannot
> get reused, or not before we're done.)
> 
> > > @@ -660,7 +679,14 @@ int shmem_unuse(swp_entry_t swap, struct
> > >  	struct list_head *this, *next;
> > >  	struct shmem_inode_info *info;
> > >  	int found = 0;
> > > -	int error;
> > > +	int error = 0;
> > > +
> > > +	/*
> > > +	 * There's a faint possibility that swap page was replaced before
> > > +	 * caller locked it: it will come back later with the right page.
> > 
> > So a caller locked the page then failed to check that it's still the
> > right sort of page?  Shouldn't the caller locally clean up its own mess
> > rather than requiring a callee to know about the caller's intricate
> > shortcomings?
> 
> The caller being try_to_unuse().  You're certainly not the first to argue
> that way.  Perhaps I'm a bit perverse, in letting code which works even
> in the surprising cases, remain as it is without weeding out those
> surprising cases.  And on this occasion didn't want to add an additional
> dependence on a slight subtle change in mm/swapfile.c functionality.
> 
> Hmm, yes, I do still prefer to have the check here in shmem.c:
> particularly since it is this "shmem_replace_page" business which is
> increasing the likelihood of such a race, and making further demands
> on it (if we're going to make the copied page PageSwapCache, then we
> need to be sure that the page it's replacing was PageSwapCache - though
> that's something I need to think through again in the light of the race
> which I thought of in responding to Cong).
> 
> > > +	newpage = shmem_alloc_page(gfp, info, index);
> > > +	if (!newpage)
> > > +		return -ENOMEM;
> > > +	VM_BUG_ON(shmem_should_replace_page(newpage, gfp));
> > > +
> > > +	*pagep = newpage;
> > > +	page_cache_get(newpage);
> > > +	copy_highpage(newpage, oldpage);
> > 
> > copy_highpage() doesn't do flush_dcache_page() - did we need copy_user_highpage()?
> 
> Ooh, I'm pretty sure you're right that we do need flush_dcache_page()
> there: good catch, thank you.  We can't use copy_user_highpage() because
> in general we don't know any address and vma; but should be following the
> shmem_getpage_gfp() pattern of clear_highpage+flush_dcache_page+SetUptodate.
> 
> > 
> > shmem_replace_page() is a fairly generic and unexceptional sounding
> > thing.  Methinks shmem_substitute_page() would be a better name.
> 
> Okay, shmem_replace_page() seemed appropriate to me (especially thinking
> of it as "re-place"), but I don't mind changing to shmem_substitute_page().
> 
> The flush_dcache_page() addition is important, but until people are
> using GMA500 on ARM or something (I doubt that combination) with more
> than 4GB, this code is not coming into play - so I'm not breaking anyone's
> system if it sneaks into linux-next before I fix that.
> 
> The main thing I need to think through quietly is the slippery swap race:
> I'll send you an incremental patch to fix all these up once I'm satisfied
> on that.

I promised you an incremental, but that's not really possible because of
the name changes from "replace" to "substitute".  So I'll be sending you
a v2 patch in a moment, to replace (or substitute for) the original 1/10.

It responds to feedback comment:

1. "substitute" instead of "replace" [akpm]
2. more explanation of page_swapcount test [akpm]
3. flush_dcache_page after copy_highpage [akpm]
4. removal of excessive VM_BUG_ONs [wangcong]
5. check page_private before and error path within substitute_page [hughd]

See below for a diff from v1 for review, omitting replace->substitute mods.

Please don't be disappointed if I send you a further patch to
shmem_substitute_page() in the weeks ahead: although the page_private
checks I've added in this one make it very very very unlikely, and its
consequence very probably benign, there is still a surprising (never
observed) race by which shmem_getpage_gfp() could get hold of someone
else's swap.

It's correctly resolved by shmem_add_to_page_cache(), but by that time
we have already done a mem_cgroup charge, and now also this substitution.
It would be better to rearrange a little here, to eliminate all chance of
that surprise: I hoped to complete that earlier, but now think I'd better
get the safer intermediate version to you first.

Thanks,
Hugh

---
 mm/shmem.c |   57 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 20 deletions(-)

--- 3045N.orig/mm/shmem.c	2012-05-17 16:28:43.278076430 -0700
+++ 3045N/mm/shmem.c	2012-05-18 16:28:33.642198028 -0700
@@ -636,10 +636,21 @@ static int shmem_unuse_inode(struct shme
 		mutex_lock(&shmem_swaplist_mutex);
 		/*
 		 * We needed to drop mutex to make that restrictive page
-		 * allocation; but the inode might already be freed by now,
-		 * and we cannot refer to inode or mapping or info to check.
-		 * However, we do hold page lock on the PageSwapCache page,
-		 * so can check if that still has our reference remaining.
+		 * allocation, but the inode might have been freed while we
+		 * dropped it: although a racing shmem_evict_inode() cannot
+		 * complete without emptying the radix_tree, our page lock
+		 * on this swapcache page is not enough to prevent that -
+		 * free_swap_and_cache() of our swap entry will only
+		 * trylock_page(), removing swap from radix_tree whatever.
+		 *
+		 * We must not proceed to shmem_add_to_page_cache() if the
+		 * inode has been freed, but of course we cannot rely on
+		 * inode or mapping or info to check that.  However, we can
+		 * safely check if our swap entry is still in use (and here
+		 * it can't have got reused for another page): if it's still
+		 * in use, then the inode cannot have been freed yet, and we
+		 * can safely proceed (if it's no longer in use, that tells
+		 * nothing about the inode, but we don't need to unuse swap).
 		 */
 		if (!page_swapcount(*pagep))
 			error = -ENOENT;
@@ -683,9 +694,9 @@ int shmem_unuse(swp_entry_t swap, struct
 
 	/*
 	 * There's a faint possibility that swap page was substituted before
-	 * caller locked it: it will come back later with the right page.
+	 * caller locked it: caller will come back later with the right page.
 	 */
-	if (unlikely(!PageSwapCache(page)))
+	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
 		goto out;
 
 	/*
@@ -916,21 +927,15 @@ static int shmem_substitute_page(struct
 	newpage = shmem_alloc_page(gfp, info, index);
 	if (!newpage)
 		return -ENOMEM;
-	VM_BUG_ON(shmem_should_substitute_page(newpage, gfp));
 
-	*pagep = newpage;
 	page_cache_get(newpage);
 	copy_highpage(newpage, oldpage);
+	flush_dcache_page(newpage);
 
-	VM_BUG_ON(!PageLocked(oldpage));
 	__set_page_locked(newpage);
-	VM_BUG_ON(!PageUptodate(oldpage));
 	SetPageUptodate(newpage);
-	VM_BUG_ON(!PageSwapBacked(oldpage));
 	SetPageSwapBacked(newpage);
-	VM_BUG_ON(!swap_index);
 	set_page_private(newpage, swap_index);
-	VM_BUG_ON(!PageSwapCache(oldpage));
 	SetPageSwapCache(newpage);
 
 	/*
@@ -940,13 +945,24 @@ static int shmem_substitute_page(struct
 	spin_lock_irq(&swap_mapping->tree_lock);
 	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
 								   newpage);
-	__inc_zone_page_state(newpage, NR_FILE_PAGES);
-	__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	if (!error) {
+		__inc_zone_page_state(newpage, NR_FILE_PAGES);
+		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	}
 	spin_unlock_irq(&swap_mapping->tree_lock);
-	BUG_ON(error);
 
-	mem_cgroup_replace_page_cache(oldpage, newpage);
-	lru_cache_add_anon(newpage);
+	if (unlikely(error)) {
+		/*
+		 * Is this possible?  I think not, now that our callers check
+		 * both PageSwapCache and page_private after getting page lock;
+		 * but be defensive.  Reverse old to newpage for clear and free.
+		 */
+		oldpage = newpage;
+	} else {
+		mem_cgroup_replace_page_cache(oldpage, newpage);
+		lru_cache_add_anon(newpage);
+		*pagep = newpage;
+	}
 
 	ClearPageSwapCache(oldpage);
 	set_page_private(oldpage, 0);
@@ -954,7 +970,7 @@ static int shmem_substitute_page(struct
 	unlock_page(oldpage);
 	page_cache_release(oldpage);
 	page_cache_release(oldpage);
-	return 0;
+	return error;
 }
 
 /*
@@ -1025,7 +1041,8 @@ repeat:
 
 		/* We have to do this with page locked to prevent races */
 		lock_page(page);
-		if (!PageSwapCache(page) || page->mapping) {
+		if (!PageSwapCache(page) || page_private(page) != swap.val ||
+		    page->mapping) {
 			error = -EEXIST;	/* try again */
 			goto failed;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
