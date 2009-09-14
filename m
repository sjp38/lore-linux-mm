Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40CF86B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 09:27:29 -0400 (EDT)
Date: Mon, 14 Sep 2009 14:27:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/8] mm: follow_hugetlb_page flags
Message-ID: <20090914132737.GB11778@csn.ul.ie>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072235360.15430@sister.anvils> <20090909113143.GG24614@csn.ul.ie> <Pine.LNX.4.64.0909131548001.22865@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909131548001.22865@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 13, 2009 at 04:35:44PM +0100, Hugh Dickins wrote:
> On Wed, 9 Sep 2009, Mel Gorman wrote:
> > On Mon, Sep 07, 2009 at 10:37:14PM +0100, Hugh Dickins wrote:
> > > 
> > > (Alternatively, since hugetlb pages aren't swapped out under pressure,
> > > you could save more dump space by arguing that a page not yet faulted
> > > into this process cannot be relevant to the dump; but that would be
> > > more surprising.)
> > 
> > It would be more surprising. It's an implementation detail that hugetlb
> > pages cannot be swapped out and someone reading the dump shouldn't have
> > to be aware of it. It's better to treat non-faulted pages as if they
> > were zero-filled.
> 
> Oh sure, I did mean that the non-faulted pages should be zero-filled,
> just stored (on those filesystems which support them) by holes in the
> file instead of zero-filled blocks (just as the dump tries to do with
> other zero pages). It would mess up the alignment with ELF headers
> to leave them out completely.
> 

Oh right, now I get you.

> But it would still be a change in convention which might surprise
> someone (pages of hugetlb file in the dump appearing as zeroed where
> the underlying hugetlb file is known to contain non-zero data), and
> there's already hugetlb dump filters for saving space on those areas.
> So I'm not anxious to pursue that parenthetical alternative, just
> admitting that we've got a choice of what to do here.
> 

Grand.

> > > @@ -2016,6 +2016,23 @@ static struct page *hugetlbfs_pagecache_
> > >  	return find_lock_page(mapping, idx);
> > >  }
> > >  
> > > +/* Return whether there is a pagecache page to back given address within VMA */
> > > +static bool hugetlbfs_backed(struct hstate *h,
> > > +			struct vm_area_struct *vma, unsigned long address)
> > > +{
> > > +	struct address_space *mapping;
> > > +	pgoff_t idx;
> > > +	struct page *page;
> > > +
> > > +	mapping = vma->vm_file->f_mapping;
> > > +	idx = vma_hugecache_offset(h, vma, address);
> > > +
> > > +	page = find_get_page(mapping, idx);
> > > +	if (page)
> > > +		put_page(page);
> > > +	return page != NULL;
> > > +}
> > > +
> > 
> > It's a total nit-pick, but this is very similar to
> > hugetlbfs_pagecache_page(). It would have been nice to have them nearby
> 
> Indeed!  That's why I placed it just after hugetlbfs_pagecache_page ;)
> 

Oops, sorry.

> > and called something like hugetlbfs_pagecache_present()
> 
> Can call it that if you prefer, either name suits me.
> 

I don't feel strongly enough to ask for a new version. If this is not
the final version that is merged, then a name-change would be nice.
Otherwise, it's not worth the hassle.

> > or else reuse
> > the function and have the caller unlock_page but it's probably not worth
> > addressing.
> 
> I did originally want to do it that way, but the caller is holding
> page_table_lock, so cannot lock_page there.
> 

Gack, fair point. If there is another version, a comment to that effect
wouldn't hurt.

> > >  int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  			struct page **pages, struct vm_area_struct **vmas,
> > >  			unsigned long *position, int *length, int i,
> > > -			int write)
> > > +			unsigned int flags)
> > 
> > Total aside, but in line with gfp_t flags, is there a case for having
> > foll_t type for FOLL_* ?
> 
> Perhaps some case, but it's the wrong side of my boredom threshold!
> Even get_user_pages is much less widely used than the functions where
> gfp flags and page order were getting muddled up.  (foll_t itself
> would not have helped, but maybe such a change would have saved me time
> debugging the hang in an earlier version of this patch: eventually I saw
> I was passing VM_FAULT_WRITE instead of FAULT_FLAG_WRITE to hugetlb_fault.)
> 

I guess it's something to have on the back-boiler. If bugs of that
nature happen a few times, then the effort would be justified. As you
say, the gfp flags are much wider used.

> > > +		/*
> > > +		 * When coredumping, it suits get_dump_page if we just return
> > > +		 * an error if there's a hole and no huge pagecache to back it.
> > > +		 */
> > > +		if (absent &&
> > > +		    ((flags & FOLL_DUMP) && !hugetlbfs_backed(h, vma, vaddr))) {
> > > +			remainder = 0;
> > > +			break;
> > > +		}
> > 
> > Does this break an assumption of get_user_pages() whereby when there are
> > holes, the corresponding pages are NULL but the following pages are still
> > checked? I guess the caller is informed ultimately that the read was only
> > partial but offhand I don't know if that's generally expected or not.
> 
> Sorry, I don't understand.  get_user_pages() doesn't return any NULL
> pages within the count it says was successful - Kamezawa-san had a patch
> and flag which did so, and we might go that way, but it's not the case
> at present is it? 

No, it's not but for some reason, I thought it was. On re-examination,
what you are doing makes sense for the current implementation.

> And follow_hugetlb_page() seems to be setting every
> pages[i] within the count to something non-NULL.
> 
> > 
> > Or is your comment saying that because the only caller using FOLL_DUMP is
> > get_dump_page() using an array of one page, it doesn't care and the case is
> > just not worth dealing with?
> 
> Yes, that's more like it, but what case?  Oh, the case where first pages
> are okay, then we hit a hole.  Right, that case doesn't actually arise
> with FOLL_DUMP because of its sole user.
> 

And nothing else other than core dumping will be using FOLL_DUMP so
there should be no assumptions broken.

> Perhaps my comment confuses because at first I had BUG_ON(remainder != 1)
> in there, and wrote that comment, and returned -EFAULT; then later moved
> the "i? i: -EFAULT" business down to the bottom and couldn't see any need
> to assume remainder 1 any more.  But the comment on "error" rather than
> "error or short count" remains.  But if I do change that to "error or
> short count" it'll be a bit odd, because in practice it is always error.
> 
> But it does seem that we've confused each other: what to say instead?
> 

/*
 * When core-dumping, it's suits the get_dump_page() if an error is
 * returned if there is a hole and no huge pagecache to back it.
 * get_dump_page() is concerned with individual pages and by
 * returning the page as an error, the core dump file still gets
 * zeros but a hugepage allocation is avoided.
 */

?

Sorry for the noise, my review wasn't as careful as it should have been.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
