Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2EA44060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:02:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so2735507wmd.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:02:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b203si2160861wme.154.2017.02.17.08.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:02:02 -0800 (PST)
Date: Fri, 17 Feb 2017 11:01:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217160154.GA23735@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217002717.GA93163@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217002717.GA93163@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Feb 16, 2017 at 04:27:18PM -0800, Shaohua Li wrote:
> On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> > On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > > @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
> > >  	 * Anonymous pages are not handled by flushers and must be written
> > >  	 * from reclaim context. Do not stall reclaim based on them
> > >  	 */
> > > -	if (!page_is_file_cache(page)) {
> > > +	if (!page_is_file_cache(page) || page_is_lazyfree(page)) {
> > 
> > Do we need this? MADV_FREE clears the dirty bit off the page; we could
> > just let them go through with the function without any special-casing.
> 
> this is just to zero dirty and writeback

Okay, I assumed that the page would always be !dirty && !writeback
here anyway, so we might as well fall through and check those bits.

But a previously failed TTU might have moved a pte dirty bit to the
page, so yes, we do need to filter for anon && !swapbacked here.

> > > @@ -1142,7 +1144,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		 * The page is mapped into the page tables of one or more
> > >  		 * processes. Try to unmap it here.
> > >  		 */
> > > -		if (page_mapped(page) && mapping) {
> > > +		if (page_mapped(page) && (mapping || lazyfree)) {
> > 
> > Do we actually need to filter for mapping || lazyfree? If we fail to
> > allocate swap, we don't reach here. If the page is a truncated file
> > page, ttu returns pretty much instantly with SWAP_AGAIN. We should be
> > able to just check for page_mapped() alone, no?
> 
> checking the mapping is faster than running into try_to_unamp, right?

!mapping should be a rare case. In reclaim code, I think it's better
to keep it simple than to optimize away the rare function call.

> > > @@ -1154,7 +1156,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  			case SWAP_MLOCK:
> > >  				goto cull_mlocked;
> > >  			case SWAP_LZFREE:
> > > -				goto lazyfree;
> > > +				/* follow __remove_mapping for reference */
> > > +				if (page_ref_freeze(page, 1)) {
> > > +					if (!PageDirty(page))
> > > +						goto lazyfree;
> > > +					else
> > > +						page_ref_unfreeze(page, 1);
> > > +				}
> > > +				goto keep_locked;
> > >  			case SWAP_SUCCESS:
> > >  				; /* try to free the page below */
> > 
> > This is a similar situation.
> > 
> > Can we let the page go through the regular __remove_mapping() process
> > and simply have that function check for PageAnon && !PageSwapBacked?
> 
> That will make the code more complicated. We don't call __remove_mapping if
> !mapping. And we need to do bypass in __remove_mapping, for example, avoid
> taking mapping->lock.

True, we won't get around a separate freeing path as long as the
refcount handling is intertwined with the mapping removal like that :/

What we should be able to do, however, is remove at least SWAP_LZFREE
and stick with SWAP_SUCCESS. On success, we can fall through up until
we do the __remove_mapping call. The page isn't dirty, so we skip that
PageDirty block; the page doesn't have private data, so we skip that
block too. And then we can branch on PageAnon && !PageSwapBacked that
does our alternate freeing path or __remove_mapping for others.

> > > @@ -1294,6 +1302,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  cull_mlocked:
> > >  		if (PageSwapCache(page))
> > >  			try_to_free_swap(page);
> > > +		if (lazyfree)
> > > +			clear_page_lazyfree(page);
> > 
> > Why cancel the MADV_FREE state? The combination seems non-sensical,
> > but we can simply retain the invalidated state while the page goes to
> > the unevictable list; munlock should move it back to inactive_file.
> 
> This depends on the policy. If user locks the page, I think it's reasonable to
> assume the page is hot, so it doesn't make sense to treat the page lazyfree.

I think the key issue is whether the page contains valid data, not
whether it is hot. When we clear the dirty bits along with
PageSwapBacked, we're declaring the data in the page invalid. There is
no practical usecase to mlock a page with invalid data, sure, but the
act of mlocking a page doesn't make its contents suddenly valid again.

I.e. I'd stick with the pure data integrity perspective here. That's
clearer and less error prone than intermingling it with eviction
policy, to avoid accidents where we lose valid data.

> > >  		unlock_page(page);
> > >  		list_add(&page->lru, &ret_pages);
> > >  		continue;
> > > @@ -1303,6 +1313,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
> > >  			try_to_free_swap(page);
> > >  		VM_BUG_ON_PAGE(PageActive(page), page);
> > > +		if (lazyfree)
> > > +			clear_page_lazyfree(page);
> > 
> > This is similar too.
> > 
> > Can we leave simply leave the page alone here? The only way we get to
> > this point is if somebody is reading the invalidated page. It's weird
> > for a lazyfreed page to become active, but it doesn't seem to warrant
> > active intervention here.
> 
> So the unmap fails here probably because the page is dirty, which means the
> page is written recently. It makes sense to assume the page is hot.

Ah, good point.

But can we handle that explicitly please? Like above, I don't want to
undo the data invalidation just because somebody read the invalid data
a bunch of times and it has the access bits set. We should only re-set
the PageSwapBacked based on whether the page is actually dirty.

Maybe along the lines of SWAP_MLOCK we could add SWAP_DIRTY when TTU
fails because the page is dirty, and then have a cull_dirty: label in
shrink_page_list handle the lazy rescue of a reused MADV_FREE page?

This should work well with removing the mapping || lazyfree check when
calling TTU. Then TTU can fail on dirty && !mapping, which is a much
more obvious way of expressing it IMO - "This page contains valid data
but there is no mapping that backs it once we unmap it. Abort."

That's mostly why I'm in favor of removing the idea of a "lazyfree"
page as much as possible. IMO this whole thing becomes much more
understandable - and less bolted on to the side of the VM - when we
express it in existing concepts the VM uses for data integrity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
