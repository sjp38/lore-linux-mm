Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B1ACE6B009A
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 06:33:04 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514B3F24.3070006@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com>
 <514B3F24.3070006@sr71.net>
Subject: Re: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked()
 to support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130322103438.46C5FE0085@blue.fi.intel.com>
Date: Fri, 22 Mar 2013 12:34:38 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
> > page for the specified index and HPAGE_CACHE_NR-1 tail pages for
> > following indexes.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/filemap.c |   76 ++++++++++++++++++++++++++++++++++++++++------------------
> >  1 file changed, 53 insertions(+), 23 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 2d99191..6bac9e2 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -447,6 +447,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >  		pgoff_t offset, gfp_t gfp_mask)
> >  {
> >  	int error;
> > +	int nr = 1;
> >  
> >  	VM_BUG_ON(!PageLocked(page));
> >  	VM_BUG_ON(PageSwapBacked(page));
> > @@ -454,32 +455,61 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >  	error = mem_cgroup_cache_charge(page, current->mm,
> >  					gfp_mask & GFP_RECLAIM_MASK);
> >  	if (error)
> > -		goto out;
> > +		return error;
> >  
> > -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > -	if (error == 0) {
> > -		page_cache_get(page);
> > -		page->mapping = mapping;
> > -		page->index = offset;
> > +	if (PageTransHuge(page)) {
> > +		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
> > +		nr = HPAGE_CACHE_NR;
> > +	}
> 
> That seems like a slightly odd place to put a BUILD_BUG_ON().  I guess
> it doesn't matter to some degree, but does putting it inside the if()
> imply anything?

It actually matters.

HPAGE_CACHE_NR is BUILD_BUG() if !CONFIG_TRANSPARENT_HUGEPAGE, so we need
to hide it inside 'if (PageTransHuge(page))'. PageTransHuge(page) is 0 in
compile time if !CONFIG_TRANSPARENT_HUGEPAGE, so compiler can be smart and
optimize out the check.

> > +	error = radix_tree_preload_count(nr, gfp_mask & ~__GFP_HIGHMEM);
> > +	if (error) {
> > +		mem_cgroup_uncharge_cache_page(page);
> > +		return error;
> > +	}
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
> 
> I do really like how this rewrite de-indents this code. :)

:)

> > +	page_cache_get(page);
> > +	spin_lock_irq(&mapping->tree_lock);
> > +	page->mapping = mapping;
> > +	page->index = offset;
> > +	error = radix_tree_insert(&mapping->page_tree, offset, page);
> > +	if (unlikely(error))
> > +		goto err;
> > +	if (PageTransHuge(page)) {
> > +		int i;
> > +		for (i = 1; i < HPAGE_CACHE_NR; i++) {
> > +			page_cache_get(page + i);
> > +			page[i].index = offset + i;
> 
> Is it OK to leave page->mapping unset for these?

Good catch, thanks.
Seems nobody really use it, since I haven't got any oops, but we need to
set it anyway.

> > +			error = radix_tree_insert(&mapping->page_tree,
> > +					offset + i, page + i);
> > +			if (error) {
> > +				page_cache_release(page + i);
> > +				break;
> > +			}
> >  		}
> 
> Throughout all this new code, I'd really challenge you to try as much as
> possible to minimize the code stuck under "if (PageTransHuge(page))".

I put thp-related code under the 'if' intentionally to be able to optimize
it out if !CONFIG_TRANSPARENT_HUGEPAGE. The config option is disabled by
default.

> For instance, could you change the for() loop a bit and have it shared
> between both cases, like:
> 
> > +	for (i = 0; i < nr; i++) {
> > +		page_cache_get(page + i);
> > +		page[i].index = offset + i;
> > +		error = radix_tree_insert(&mapping->page_tree,
> > +				offset + i, page + i);
> > +		if (error) {
> > +			page_cache_release(page + i);
> > +			break;
> > +		}
> >  	}
> 
> > -		radix_tree_preload_end();
> > -	} else
> > -		mem_cgroup_uncharge_cache_page(page);
> > -out:
> > +		if (error) {
> > +			error = ENOSPC; /* no space for a huge page */
> > +			for (i--; i > 0; i--) {
> > +				radix_tree_delete(&mapping->page_tree,
> > +						offset + i);
> > +				page_cache_release(page + i);
> > +			}
> > +			radix_tree_delete(&mapping->page_tree, offset);
> 
> I wonder if this would look any nicer if you just did all the
> page_cache_get()s for the entire huge page along with the head page, and
> then released them all in one place.  I think it might shrink the error
> handling paths here.
> 
> > +			goto err;
> > +		}
> > +	}
> > +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
> > +	mapping->nrpages += nr;
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	trace_mm_filemap_add_to_page_cache(page);
> 
> Do we need to change the tracing to make sure it notes that these were
> or weren't huge pages?

Hm.. I guess we just need to add page order to the trace.

> > +	radix_tree_preload_end();
> > +	return 0;
> > +err:
> > +	page->mapping = NULL;
> > +	/* Leave page->index set: truncation relies upon it */
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	radix_tree_preload_end();
> > +	mem_cgroup_uncharge_cache_page(page);
> > +	page_cache_release(page);
> >  	return error;
> >  }
> >  EXPORT_SYMBOL(add_to_page_cache_locked);
> 
> Does the cgroup code know how to handle these large pages internally
> somehow?  It looks like the charge/uncharge is only being done for the
> head page.

It can. We only need to remove PageCompound() check there. Patch is in
git.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
