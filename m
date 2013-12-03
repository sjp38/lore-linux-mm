Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3FC6B003D
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 20:59:18 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2229750pab.29
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 17:59:17 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id sl10si20649124pab.99.2013.12.02.17.59.15
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 17:59:16 -0800 (PST)
Date: Tue, 3 Dec 2013 11:01:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/9] mm/rmap: recompute pgoff for huge page
Message-ID: <20131203020141.GA31168@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20131202144434.2afc2b5bb69f2b4b45608e4e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131202144434.2afc2b5bb69f2b4b45608e4e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 02, 2013 at 02:44:34PM -0800, Andrew Morton wrote:
> On Thu, 28 Nov 2013 16:48:38 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > We have to recompute pgoff if the given page is huge, since result based
> > on HPAGE_SIZE is not approapriate for scanning the vma interval tree, as
> > shown by commit 36e4f20af833 ("hugetlb: do not use vma_hugecache_offset()
> > for vma_prio_tree_foreach") and commit 369a713e ("rmap: recompute pgoff
> > for unmapping huge page").
> > 
> > ...
> >
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1714,6 +1714,10 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
> >  
> >  	if (!mapping)
> >  		return ret;
> > +
> > +	if (PageHuge(page))
> > +		pgoff = page->index << compound_order(page);
> > +
> >  	mutex_lock(&mapping->i_mmap_mutex);
> >  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
> >  		unsigned long address = vma_address(page, vma);
> 
> a)  Can't we just do this?
> 
> --- a/mm/rmap.c~mm-rmap-recompute-pgoff-for-huge-page-fix
> +++ a/mm/rmap.c
> @@ -1708,16 +1708,13 @@ static int rmap_walk_file(struct page *p
>  		struct vm_area_struct *, unsigned long, void *), void *arg)
>  {
>  	struct address_space *mapping = page->mapping;
> -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	pgoff_t pgoff = page->index << compound_order(page);
>  	struct vm_area_struct *vma;
>  	int ret = SWAP_AGAIN;
>  
>  	if (!mapping)
>  		return ret;
>  
> -	if (PageHuge(page))
> -		pgoff = page->index << compound_order(page);
> -
>  	mutex_lock(&mapping->i_mmap_mutex);
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address = vma_address(page, vma);
> 
> compound_order() does the right thing for all styles of page, yes?

Yes. I will change.

> 
> b) If that PageHuge() test you added the correct thing to use?
> 
> /*
>  * PageHuge() only returns true for hugetlbfs pages, but not for normal or
>  * transparent huge pages.  See the PageTransHuge() documentation for more
>  * details.
>  */
> 
>    Obviously we won't be encountering transparent huge pages here,
>    but what's the best future-safe approach?

compound_order() also works for transparent huge pages, so it may be safe way.

> I hate that PageHuge() oddity with a passion!  Maybe it would be better
> if it was called PageHugetlbfs.

I also think that PageHuge() is odd name.
It has only 50 call sites. Let's change it :)

Thanks.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
