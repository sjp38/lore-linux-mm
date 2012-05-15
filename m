Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 811336B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 00:08:05 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so10068715pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 21:08:04 -0700 (PDT)
Date: Mon, 14 May 2012 21:07:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
In-Reply-To: <20120514161330.def0ac52.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1205142101420.2196@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils> <20120514161330.def0ac52.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 May 2012, Andrew Morton wrote:
> On Sat, 12 May 2012 04:59:56 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > We'd like to continue to support GMA500, so now add a new
> > shmem_should_replace_page() check on the zone when about to move
> > a page from swapcache to filecache (in swapin and swapoff cases),
> > with shmem_replace_page() to allocate and substitute a suitable page
> > (given gma500/gem.c's mapping_set_gfp_mask GFP_KERNEL | __GFP_DMA32).
> >  
...
> > +	gfp = mapping_gfp_mask(mapping);
> > +	if (shmem_should_replace_page(*pagep, gfp)) {
> > +		mutex_unlock(&shmem_swaplist_mutex);
> > +		error = shmem_replace_page(pagep, gfp, info, index);
> > +		mutex_lock(&shmem_swaplist_mutex);
> > +		/*
> > +		 * We needed to drop mutex to make that restrictive page
> > +		 * allocation; but the inode might already be freed by now,
> > +		 * and we cannot refer to inode or mapping or info to check.
> > +		 * However, we do hold page lock on the PageSwapCache page,
> > +		 * so can check if that still has our reference remaining.
> > +		 */
> > +		if (!page_swapcount(*pagep))
> > +			error = -ENOENT;
> 
> This has my head spinning a bit.  What is "our reference"?  I'd expect
> that to mean a temporary reference which was taken by this thread of
> control.

(I'm sure you'll prefer a reworking of that comment in an incremental
fixes patch, but let me try to explain better here too.)

No, I didn't mean a temporary reference taken by this (swapoff) thread,
but the reference (swap entry) which has just been located in the inode's
radix_tree, just before this hunk: which would be tracked by page_swapcount
1 (there's also a page swapcache bit in the swap_map along with the count,
corresponding to the reference from the swapcache page itself, but that's
not included in page_swapcount).

> But such a thing has no relevance when trying to determine
> the state of the page and/or data structures which refer to it.

I don't understand you there, but maybe it won't matter.

> 
> Also, what are we trying to determine here with this test?  Whether the
> page was removed from swapcache under our feet?  Presumably not, as it
> is locked.
> 
> So perhaps you could spell out in more detail what we're trying to do
> here, and what contributes to page_swapcount() here?

The danger here is that the inode we're dealing with has gone through
shmem_evict_inode() while we dropped shmem_swaplist_mutex: inode was
certainly in use before, and shmem_swaplist_mutex (together with inode
being on shmem_swaplist) holds it up from being evicted and freed; but
once we drop the mutex, it could go away at any moment.  We cannot
determine that by looking at struct inode or struct address_space or
struct shmem_inode_info, they're all part of what would be freed;
but we cannot proceed to shmem_add_to_page_cache() once they're freed.
How to tell whether it's been freed?

Once upon a time I "solved" it with igrab() and iput(), but Konstantin
demonstrated how that gives no safety against unmounting, and I remain
reluctant to go back to relying upon filesystem semantics to solve this.

It occurred to me that the inode cannot be freed until that radix_tree
entry has been removed (by shmem_evict_inode's shmem_truncate_range),
and the act or removing that entry (free_swap_and_cache) brings
page_swapcount down from 1 to 0.

You're thinking that the page cannot be removed from swapcache while
we hold page lock: correct, but... free_swap_and_cache() only does a
trylock_page(), and happily leaves the swapcache page to be garbage
collected later if it cannot get the page lock.  (And I certainly
would not want to change it to wait for page lock.)  So, the inode
can get evicted while the page is still in swapcache: the page lock
gives no protection against that, until the page itself gets into
the radix_tree.

I doubt that writing this essay into a comment there will be the
right thing to do (and I may still be losing you); but I shall try
to rewrite it, and if there's one missing fact that needs highlighting,
it probably is that last, that free_swap_and_cache() only does a trylock,
so our page lock does not protect the inode from eviction.

(At this moment, I can't think what is the relevance of my comment
"we do hold page lock on the PageSwapCache page": in other contexts it
would be important, but here in swapoff we know that that swap cannot
get reused, or not before we're done.)

> > @@ -660,7 +679,14 @@ int shmem_unuse(swp_entry_t swap, struct
> >  	struct list_head *this, *next;
> >  	struct shmem_inode_info *info;
> >  	int found = 0;
> > -	int error;
> > +	int error = 0;
> > +
> > +	/*
> > +	 * There's a faint possibility that swap page was replaced before
> > +	 * caller locked it: it will come back later with the right page.
> 
> So a caller locked the page then failed to check that it's still the
> right sort of page?  Shouldn't the caller locally clean up its own mess
> rather than requiring a callee to know about the caller's intricate
> shortcomings?

The caller being try_to_unuse().  You're certainly not the first to argue
that way.  Perhaps I'm a bit perverse, in letting code which works even
in the surprising cases, remain as it is without weeding out those
surprising cases.  And on this occasion didn't want to add an additional
dependence on a slight subtle change in mm/swapfile.c functionality.

Hmm, yes, I do still prefer to have the check here in shmem.c:
particularly since it is this "shmem_replace_page" business which is
increasing the likelihood of such a race, and making further demands
on it (if we're going to make the copied page PageSwapCache, then we
need to be sure that the page it's replacing was PageSwapCache - though
that's something I need to think through again in the light of the race
which I thought of in responding to Cong).

> > +	newpage = shmem_alloc_page(gfp, info, index);
> > +	if (!newpage)
> > +		return -ENOMEM;
> > +	VM_BUG_ON(shmem_should_replace_page(newpage, gfp));
> > +
> > +	*pagep = newpage;
> > +	page_cache_get(newpage);
> > +	copy_highpage(newpage, oldpage);
> 
> copy_highpage() doesn't do flush_dcache_page() - did we need copy_user_highpage()?

Ooh, I'm pretty sure you're right that we do need flush_dcache_page()
there: good catch, thank you.  We can't use copy_user_highpage() because
in general we don't know any address and vma; but should be following the
shmem_getpage_gfp() pattern of clear_highpage+flush_dcache_page+SetUptodate.

> 
> shmem_replace_page() is a fairly generic and unexceptional sounding
> thing.  Methinks shmem_substitute_page() would be a better name.

Okay, shmem_replace_page() seemed appropriate to me (especially thinking
of it as "re-place"), but I don't mind changing to shmem_substitute_page().

The flush_dcache_page() addition is important, but until people are
using GMA500 on ARM or something (I doubt that combination) with more
than 4GB, this code is not coming into play - so I'm not breaking anyone's
system if it sneaks into linux-next before I fix that.

The main thing I need to think through quietly is the slippery swap race:
I'll send you an incremental patch to fix all these up once I'm satisfied
on that.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
