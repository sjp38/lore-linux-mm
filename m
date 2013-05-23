Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7D7886B0034
	for <linux-mm@kvack.org>; Thu, 23 May 2013 10:34:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BD206.3040603@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-13-git-send-email-kirill.shutemov@linux.intel.com>
 <519BD206.3040603@sr71.net>
Subject: Re: [PATCHv4 12/39] thp, mm: rewrite add_to_page_cache_locked() to
 support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130523143656.B8B73E0090@blue.fi.intel.com>
Date: Thu, 23 May 2013 17:36:56 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
> > page for the specified index and HPAGE_CACHE_NR-1 tail pages for
> > following indexes.
> 
> The really nice way to do these patches is refactor them, first, with no
> behavior change, in one patch, the introduce the new support in the
> second one.

I've split it into two patches.

> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 61158ac..b0c7c8c 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -460,39 +460,62 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >  		pgoff_t offset, gfp_t gfp_mask)
> >  {
> >  	int error;
> > +	int i, nr;
> >  
> >  	VM_BUG_ON(!PageLocked(page));
> >  	VM_BUG_ON(PageSwapBacked(page));
> >  
> > +	/* memory cgroup controller handles thp pages on its side */
> >  	error = mem_cgroup_cache_charge(page, current->mm,
> >  					gfp_mask & GFP_RECLAIM_MASK);
> >  	if (error)
> > -		goto out;
> > -
> > -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > -	if (error == 0) {
> > -		page_cache_get(page);
> > -		page->mapping = mapping;
> > -		page->index = offset;
> > +		return error;
> >  
> > -		spin_lock_irq(&mapping->tree_lock);
> > -		error = radix_tree_insert(&mapping->page_tree, offset, page);
> > -		if (likely(!error)) {
> > -			mapping->nrpages++;
> > -			__inc_zone_page_state(page, NR_FILE_PAGES);
> > -			spin_unlock_irq(&mapping->tree_lock);
> > -			trace_mm_filemap_add_to_page_cache(page);
> > -		} else {
> > -			page->mapping = NULL;
> > -			/* Leave page->index set: truncation relies upon it */
> > -			spin_unlock_irq(&mapping->tree_lock);
> > -			mem_cgroup_uncharge_cache_page(page);
> > -			page_cache_release(page);
> > -		}
> > -		radix_tree_preload_end();
> > -	} else
> > +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
> > +		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
> > +		nr = hpage_nr_pages(page);
> > +	} else {
> > +		BUG_ON(PageTransHuge(page));
> > +		nr = 1;
> > +	}
> 
> Why can't this just be
> 
> 		nr = hpage_nr_pages(page);
> 
> Are you trying to optimize for the THP=y, but THP-pagecache=n case?

Yes, I try to optimize for the case.

> > +		if (error)
> > +			goto err;
> 
> I know it's not a super-common thing in the kernel, but could you call
> this "insert_err" or something?

I've changed it to err_insert.

> > +	}
> > +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
> > +	if (PageTransHuge(page))
> > +		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
> > +	mapping->nrpages += nr;
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	radix_tree_preload_end();
> > +	trace_mm_filemap_add_to_page_cache(page);
> > +	return 0;
> > +err:
> > +	if (i != 0)
> > +		error = -ENOSPC; /* no space for a huge page */
> > +	page_cache_release(page + i);
> > +	page[i].mapping = NULL;
> 
> I guess it's a slight behaviour change (I think it's harmless) but if
> you delay doing the page_cache_get() and page[i].mapping= until after
> the radix tree insertion, you can avoid these two lines.

Hm. I don't think it's safe. The spinlock protects radix-tree against
modification, but find_get_page() can see it just after
radix_tree_insert().

The page is locked and IIUC never uptodate at this point, so nobody will
be able to do much with it, but leave it without valid ->mapping is a bad
idea.

> > +	for (i--; i >= 0; i--) {
> 
> I kinda glossed over that initial "i--".  It might be worth a quick
> comment to call it out.

Okay.

> > +		/* Leave page->index set: truncation relies upon it */
> > +		page[i].mapping = NULL;
> > +		radix_tree_delete(&mapping->page_tree, offset + i);
> > +		page_cache_release(page + i);
> > +	}
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	radix_tree_preload_end();
> > +	mem_cgroup_uncharge_cache_page(page);
> >  	return error;
> >  }
> 
> FWIW, I think you can move the radix_tree_preload_end() up a bit.  I
> guess it won't make any practical difference since you're holding a
> spinlock, but it at least makes the point that you're not depending on
> it any more.

Good point.

> I'm also trying to figure out how and when you'd actually have to unroll
> a partial-huge-page worth of radix_tree_insert().  In the small-page
> case, you can collide with another guy inserting in to the page cache.
> But, can that happen in the _middle_ of a THP?

E.g. if you enable THP after some uptime, the mapping can contain small pages
already.
Or if a process map the file with bad alignement (MAP_FIXED) and touch the
area, it will get small pages.

> Despite my nits, the code still looks correct here, so:
> 
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

The incremental diff for the patch is below. I guess it's still valid to
use your ack, right?

diff --git a/mm/filemap.c b/mm/filemap.c
index f643062..d004331 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -492,29 +492,33 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		error = radix_tree_insert(&mapping->page_tree,
 				offset + i, page + i);
 		if (error)
-			goto err;
+			goto err_insert;
 	}
+	radix_tree_preload_end();
 	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
 	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
 	mapping->nrpages += nr;
 	spin_unlock_irq(&mapping->tree_lock);
-	radix_tree_preload_end();
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
-err:
+err_insert:
+	radix_tree_preload_end();
 	if (i != 0)
 		error = -ENOSPC; /* no space for a huge page */
+
+	/* page[i] was not inserted to tree, handle separately */
 	page_cache_release(page + i);
 	page[i].mapping = NULL;
-	for (i--; i >= 0; i--) {
+	i--;
+
+	for (; i >= 0; i--) {
 		/* Leave page->index set: truncation relies upon it */
 		page[i].mapping = NULL;
 		radix_tree_delete(&mapping->page_tree, offset + i);
 		page_cache_release(page + i);
 	}
 	spin_unlock_irq(&mapping->tree_lock);
-	radix_tree_preload_end();
 	mem_cgroup_uncharge_cache_page(page);
 	return error;
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
