Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48E496B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:03:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y7so9907275wrc.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:03:21 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r15si14460227wrr.217.2017.02.17.12.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:03:20 -0800 (PST)
Date: Fri, 17 Feb 2017 15:03:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217200313.GA30923@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217002717.GA93163@shli-mbp.local>
 <20170217160154.GA23735@cmpxchg.org>
 <20170217184340.GA26984@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217184340.GA26984@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 17, 2017 at 10:43:41AM -0800, Shaohua Li wrote:
> On Fri, Feb 17, 2017 at 11:01:54AM -0500, Johannes Weiner wrote:
> > On Thu, Feb 16, 2017 at 04:27:18PM -0800, Shaohua Li wrote:
> > > On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> > > > On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > > > >  		unlock_page(page);
> > > > >  		list_add(&page->lru, &ret_pages);
> > > > >  		continue;
> > > > > @@ -1303,6 +1313,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > > > >  		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
> > > > >  			try_to_free_swap(page);
> > > > >  		VM_BUG_ON_PAGE(PageActive(page), page);
> > > > > +		if (lazyfree)
> > > > > +			clear_page_lazyfree(page);
> > > > 
> > > > Can we leave simply leave the page alone here? The only way we get to
> > > > this point is if somebody is reading the invalidated page. It's weird
> > > > for a lazyfreed page to become active, but it doesn't seem to warrant
> > > > active intervention here.
> > > 
> > > So the unmap fails here probably because the page is dirty, which means the
> > > page is written recently. It makes sense to assume the page is hot.
> > 
> > Ah, good point.
> > 
> > But can we handle that explicitly please? Like above, I don't want to
> > undo the data invalidation just because somebody read the invalid data
> > a bunch of times and it has the access bits set. We should only re-set
> > the PageSwapBacked based on whether the page is actually dirty.
> > 
> > Maybe along the lines of SWAP_MLOCK we could add SWAP_DIRTY when TTU
> > fails because the page is dirty, and then have a cull_dirty: label in
> > shrink_page_list handle the lazy rescue of a reused MADV_FREE page?
> > 
> > This should work well with removing the mapping || lazyfree check when
> > calling TTU. Then TTU can fail on dirty && !mapping, which is a much
> > more obvious way of expressing it IMO - "This page contains valid data
> > but there is no mapping that backs it once we unmap it. Abort."
> > 
> > That's mostly why I'm in favor of removing the idea of a "lazyfree"
> > page as much as possible. IMO this whole thing becomes much more
> > understandable - and less bolted on to the side of the VM - when we
> > express it in existing concepts the VM uses for data integrity.
> 
> Ok, it makes sense to only reset the PageSwapBacked bit for dirty page. In this
> way, we jump to activate_locked for SWAP_DIRTY || (SWAP_FAIL && pagelazyfree)
> and jump to activate_locked for SWAP_FAIL && !pagelazyfree. Is this what you
> want to do? This will add extra checks for SWAP_FAIL. I'm not sure if this is
> really worthy because it's rare the MADV_FREE page is read.

Yes, for SWAP_DIRTY jump to activate_locked or have its own label that
sets PG_swapbacked again and moves the page back to the proper LRU.

SWAP_FAIL of an anon && !swapbacked && !dirty && referenced page can
be ignored IMO. This happens only when the user is reading invalid
data over and over, I see no reason to optimize for that. We activate
a MADV_FREE page, which is weird, but not a correctness issue, right?

Just to clarify, right now we have this:

---

SWAP_FAIL (failure on pte, swap, lazyfree):
  if pagelazyfree:
    clear pagelazyfree
  activate

SWAP_SUCCESS:
  regular reclaim

SWAP_LZFREE (success on lazyfree when page and ptes are all clean):
  free page

---

What I'm proposing is to separate lazyfree failure out from SWAP_FAIL
into its own branch. Then merge lazyfree success into SWAP_SUCCESS:

---

SWAP_FAIL (failure on pte, swap):
  activate

SWAP_SUCCESS:
  if anon && !swapbacked:
    free manually
  else:
    __remove_mapping()

SWAP_DIRTY (anon && !swapbacked && dirty):
  set swapbacked
  putback/activate

---

This way we have a mostly unified success path (we might later be able
to refactor __remove_mapping to split refcounting from mapping stuff
to remove the last trace of difference), and SWAP_DIRTY follows the
same type of delayed LRU fixup as we do for SWAP_MLOCK right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
