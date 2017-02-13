Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFA936B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:17:55 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x1so44183362lff.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:17:55 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id b62si14222540wrd.98.2017.02.13.07.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 07:17:54 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id r18so20121490wmd.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:17:54 -0800 (PST)
Date: Mon, 13 Feb 2017 18:17:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 07/37] filemap: allocate huge page in
 page_cache_read(), if allowed
Message-ID: <20170213151751.GD20394@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-8-kirill.shutemov@linux.intel.com>
 <20170209211835.GV2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209211835.GV2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 09, 2017 at 01:18:35PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 26, 2017 at 02:57:49PM +0300, Kirill A. Shutemov wrote:
> > Later we can add logic to accumulate information from shadow entires to
> > return to caller (average eviction time?).
> 
> I would say minimum rather than average.  That will become the refault
> time of the entire page, so minimum would probably have us making better
> decisions?

Yes, makes sense.

> > +	/* Wipe shadow entires */
> > +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
> > +			page->index) {
> > +		if (iter.index >= page->index + hpage_nr_pages(page))
> > +			break;
> >  
> >  		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
> > -		if (!radix_tree_exceptional_entry(p))
> > +		if (!p)
> > +			continue;
> 
> Just FYI, this can't happen.  You're holding the tree lock so nobody
> else gets to remove things from the tree.  radix_tree_for_each_slot()
> only gives you the full slots; it skips the empty ones for you.  I'm
> OK if you want to leave it in out of an abundance of caution.

I'll drop it.

> > +		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
> > +				workingset_update_node, mapping);
> 
> I may add an update_node argument to radix_tree_join at some point,
> so you can use it here.  Or maybe we don't need to do that, and what
> you have here works just fine.
> 
> >  		mapping->nrexceptional--;
> 
> ... because adjusting the exceptional count is going to be a pain.

Yeah..

> > +	error = __radix_tree_insert(&mapping->page_tree,
> > +			page->index, compound_order(page), page);
> > +	/* This shouldn't happen */
> > +	if (WARN_ON_ONCE(error))
> > +		return error;
> 
> A lesser man would have just ignored the return value from
> __radix_tree_insert.  I salute you.
> 
> > @@ -2078,18 +2155,34 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
> >  {
> >  	struct address_space *mapping = file->f_mapping;
> >  	struct page *page;
> > +	pgoff_t hoffset;
> >  	int ret;
> >  
> >  	do {
> > -		page = __page_cache_alloc(gfp_mask|__GFP_COLD);
> > +		page = page_cache_alloc_huge(mapping, offset, gfp_mask);
> > +no_huge:
> > +		if (!page)
> > +			page = __page_cache_alloc(gfp_mask|__GFP_COLD);
> >  		if (!page)
> >  			return -ENOMEM;
> >  
> > -		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask & GFP_KERNEL);
> > -		if (ret == 0)
> > +		if (PageTransHuge(page))
> > +			hoffset = round_down(offset, HPAGE_PMD_NR);
> > +		else
> > +			hoffset = offset;
> > +
> > +		ret = add_to_page_cache_lru(page, mapping, hoffset,
> > +				gfp_mask & GFP_KERNEL);
> > +
> > +		if (ret == -EEXIST && PageTransHuge(page)) {
> > +			put_page(page);
> > +			page = NULL;
> > +			goto no_huge;
> > +		} else if (ret == 0) {
> >  			ret = mapping->a_ops->readpage(file, page);
> > -		else if (ret == -EEXIST)
> > +		} else if (ret == -EEXIST) {
> >  			ret = 0; /* losing race to add is OK */
> > +		}
> >  
> >  		put_page(page);
> 
> If the filesystem returns AOP_TRUNCATED_PAGE, you'll go round this loop
> again trying the huge page again, even if the huge page didn't work
> the first time.  I would tend to think that if the huge page failed the
> first time, we shouldn't try it again, so I propose this:

AOP_TRUNCATED_PAGE is positive, so I don't see how you avoid try_huge on
second iteration. Hm?

> 
>         struct address_space *mapping = file->f_mapping;
>         struct page *page;
>         pgoff_t index;
>         int ret;
>         bool try_huge = true;
> 
>         do {
>                 if (try_huge) {
>                         page = page_cache_alloc_huge(gfp_mask|__GFP_COLD);
>                         if (page)
>                                 index = round_down(offset, HPAGE_PMD_NR);
>                         else
>                                 try_huge = false;
>                 }
> 
>                 if (!try_huge) {
>                         page = __page_cache_alloc(gfp_mask|__GFP_COLD);
>                         index = offset;
>                 }
> 
>                 if (!page)
>                         return -ENOMEM;
> 
>                 ret = add_to_page_cache_lru(page, mapping, index,
>                                                         gfp_mask & GFP_KERNEL);
>                 if (ret < 0) {
>                         if (try_huge) {
>                                 try_huge = false;
>                                 ret = AOP_TRUNCATED_PAGE;
>                         } else if (ret == -EEXIST)
>                                 ret = 0; /* losing race to add is OK */
>                 } else {
>                         ret = mapping->a_ops->readpage(file, page);
>                 }
> 
>                 put_page(page);
>         } while (ret == AOP_TRUNCATED_PAGE);
> 
> But ... maybe it's OK to retry the huge page.  I mean, not many
> filesystems return AOP_TRUNCATED_PAGE, and they only do so rarely.

What about this:

	struct address_space *mapping = file->f_mapping;
	struct page *page;
	pgoff_t hoffset;
	int ret;
	bool try_huge = true;

	do {
		if (try_huge) {
			page = page_cache_alloc_huge(mapping, offset, gfp_mask);
			hoffset = round_down(offset, HPAGE_PMD_NR);

			/* Try to allocate huge page once */
			try_huge = false;
		}

		if (!page) {
			page = __page_cache_alloc(gfp_mask|__GFP_COLD);
			hoffset = offset;
		}

		if (!page)
			return -ENOMEM;

		ret = add_to_page_cache_lru(page, mapping, hoffset,
				gfp_mask & GFP_KERNEL);

		if (ret == -EEXIST && PageTransHuge(page)) {
			/* Retry with small page */
			put_page(page);
			page = NULL;
			continue;
		} else if (ret == 0) {
			ret = mapping->a_ops->readpage(file, page);
		} else if (ret == -EEXIST) {
			ret = 0; /* losing race to add is OK */
		}

		put_page(page);
	} while (ret == AOP_TRUNCATED_PAGE);

	return ret;


> Anyway, I'm fine with the patch going in as-is.  I just wanted to type out
> my review notes.
> 
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Thanks!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
