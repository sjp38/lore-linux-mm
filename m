Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4A046B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 11:58:23 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id gt1so2060281wjc.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:58:23 -0800 (PST)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id z4si6776859wmb.59.2017.02.09.08.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 08:58:22 -0800 (PST)
Received: by mail-wr0-x241.google.com with SMTP id k90so12495948wrc.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 08:58:22 -0800 (PST)
Date: Thu, 9 Feb 2017 19:58:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 01/37] mm, shmem: swich huge tmpfs to multi-order
 radix-tree entries
Message-ID: <20170209165820.GA12768@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-2-kirill.shutemov@linux.intel.com>
 <20170209035727.GQ2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209035727.GQ2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Feb 08, 2017 at 07:57:27PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 26, 2017 at 02:57:43PM +0300, Kirill A. Shutemov wrote:
> > +++ b/include/linux/pagemap.h
> > @@ -332,6 +332,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
> >  			mapping_gfp_mask(mapping));
> >  }
> >  
> > +static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> > +{
> > +	VM_BUG_ON_PAGE(PageTail(page), page);
> > +	VM_BUG_ON_PAGE(page->index > offset, page);
> > +	VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) < offset,
> > +			page);
> > +	return page - page->index + offset;
> > +}
> 
> What would you think to:
> 
> static inline void check_page_index(struct page *page, pgoff_t offset)
> {
> 	VM_BUG_ON_PAGE(PageTail(page), page);
> 	VM_BUG_ON_PAGE(page->index > offset, page);
> 	VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> 			page);
> }
> 
> (I think I fixed an off-by-one error up there ...  if
> index + (1 << order) == offset, this is also a bug, right?
> because offset would then refer to the next page, not this page)

Right, thanks.

> 
> static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> {
> 	check_page_index(page, offset);
> 	return page + (offset - page->index);
> }
> 
> ... then you can use check_page_index down ...

Okay, makes sense.

> 
> > @@ -1250,7 +1233,6 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
> >  			put_page(page);
> >  			goto repeat;
> >  		}
> > -		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
> 
> ... here?

Ok.

> > @@ -1472,25 +1451,35 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
> >  			goto repeat;
> >  		}
> >  
> > +		/* For multi-order entries, find relevant subpage */
> > +		if (PageTransHuge(page)) {
> > +			VM_BUG_ON(index - page->index < 0);
> > +			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
> > +			page += index - page->index;
> > +		}
> 
> Use find_subpage() here?

Ok.

> >  		pages[ret] = page;
> >  		if (++ret == nr_pages)
> >  			break;
> > +		if (!PageTransCompound(page))
> > +			continue;
> > +		for (refs = 0; ret < nr_pages &&
> > +				(index + 1) % HPAGE_PMD_NR;
> > +				ret++, refs++, index++)
> > +			pages[ret] = ++page;
> > +		if (refs)
> > +			page_ref_add(compound_head(page), refs);
> > +		if (ret == nr_pages)
> > +			break;
> 
> Can we avoid referencing huge pages specifically in the page cache?  I'd
> like us to get to the point where we can put arbitrary compound pages into
> the page cache.  For example, I think this can be written as:
> 
> 		if (!PageCompound(page))
> 			continue;
> 		for (refs = 0; ret < nr_pages; refs++, index++) {
> 			if (index > page->index + (1 << compound_order(page)))
> 				break;
> 			pages[ret++] = ++page;
> 		}
> 		if (refs)
> 			page_ref_add(compound_head(page), refs);
> 		if (ret == nr_pages)
> 			break;

That's slightly more costly, but I guess that's fine.

> > @@ -1541,19 +1533,12 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
> >  
> > +		/* For multi-order entries, find relevant subpage */
> > +		if (PageTransHuge(page)) {
> > +			VM_BUG_ON(index - page->index < 0);
> > +			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
> > +			page += index - page->index;
> > +		}
> > +
> >  		pages[ret] = page;
> >  		if (++ret == nr_pages)
> >  			break;
> > +		if (!PageTransCompound(page))
> > +			continue;
> > +		for (refs = 0; ret < nr_pages &&
> > +				(index + 1) % HPAGE_PMD_NR;
> > +				ret++, refs++, index++)
> > +			pages[ret] = ++page;
> > +		if (refs)
> > +			page_ref_add(compound_head(page), refs);
> > +		if (ret == nr_pages)
> > +			break;
> >  	}
> >  	rcu_read_unlock();
> >  	return ret;
> 
> Ugh, the same code again.  Hmm ... we only need to modify 'ret' as a result
> of this ... so could we split it out like this?
> 
> static unsigned populate_pages(struct page **pages, unsigned i, unsigned max,
>                                 struct page *page)
> {
>         unsigned refs = 0;
>         for (;;) {
>                 pages[i++] = page;
>                 if (i == max)
>                         break;
>                 if (PageHead(page + 1))
>                         break;

Hm? PageHead()? No. The next page can head or small.

I *guess* we can get away with !PageTail(page + 1)...

>                 page++;
>                 refs++;
>         }
>         if (refs)
>                 page_ref_add(compound_head(page), refs);
>         return i;
> }
> 
> > +unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *indexp,
> >  			int tag, unsigned int nr_pages, struct page **pages)
> 
> >  			break;
> > +		if (!PageTransCompound(page))
> > +			continue;
> > +		for (refs = 0; ret < nr_pages &&
> > +				(index + 1) % HPAGE_PMD_NR;
> > +				ret++, refs++, index++)
> > +			pages[ret] = ++page;
> > +		if (refs)
> > +			page_ref_add(compound_head(page), refs);
> > +		if (ret == nr_pages)
> > +			break;
> >  	}
> 
> ... and again!
> 
> > @@ -2326,25 +2337,26 @@ void filemap_map_pages(struct vm_fault *vmf,
> > +		/* For multi-order entries, find relevant subpage */
> > +		if (PageTransHuge(page)) {
> > +			VM_BUG_ON(index - page->index < 0);
> > +			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
> > +			page += index - page->index;
> > +		}
> > +
> >  		if (!PageUptodate(page) ||
> >  				PageReadahead(page) ||
> 
> Readahead is PF_NO_COMPOUND ... so I don't see why this works?

We wouldn't see pages with readahead flag set/cleared until huge pages
support in ext4 is enabled at very end of the patchset.

> 
> > @@ -2378,8 +2390,14 @@ void filemap_map_pages(struct vm_fault *vmf,
> >  		/* Huge page is mapped? No need to proceed. */
> >  		if (pmd_trans_huge(*vmf->pmd))
> >  			break;
> > -		if (iter.index == end_pgoff)
> > +		if (index == end_pgoff)
> >  			break;
> > +		if (page && PageTransCompound(page) &&
> > +				(index & (HPAGE_PMD_NR - 1)) !=
> > +				HPAGE_PMD_NR - 1) {
> > +			index++;
> > +			goto repeat;
> 
> Do we really have to go all the way back to the beginning of the loop?  It'd
> be nice to be able to insert all of the relevant PTEs in a shorter loop here.
> We'd need to bump the reference count N more times, and I think we do need
> to check HWPoison for each subpage.

I'll look into it.

Thanks for review.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
