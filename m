Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 114CD6B0037
	for <linux-mm@kvack.org>; Thu, 30 May 2013 09:18:06 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BE3B6.6070902@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-20-git-send-email-kirill.shutemov@linux.intel.com>
 <519BE3B6.6070902@sr71.net>
Subject: Re: [PATCHv4 19/39] thp, mm: allocate huge pages in
 grab_cache_page_write_begin()
Content-Transfer-Encoding: 7bit
Message-Id: <20130530132035.BFE0FE0090@blue.fi.intel.com>
Date: Thu, 30 May 2013 16:20:35 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > Try to allocate huge page if flags has AOP_FLAG_TRANSHUGE.
> 
> Why do we need this flag?

I don't see other way to indicate grab_cache_page_write_begin(), that we
want THP here.

> When might we set it, and when would we not set it?  What kinds of
> callers need to check for and act on it?

The decision whether allocate huge page or not is up to filesystem. In
ramfs case we just use mapping_can_have_hugepages(), on other filesystem
check might be more complicated.

> Some of this, at least, needs to make it in to the comment by the #define.

Sorry, I fail to see what kind of comment you want me to add there.

> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -194,6 +194,9 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
> >  #define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
> >  #define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
> >  
> > +#define THP_WRITE_ALLOC		({ BUILD_BUG(); 0; })
> > +#define THP_WRITE_ALLOC_FAILED	({ BUILD_BUG(); 0; })
> 
> Doesn't this belong in the previous patch?

Yes. Fixed.

> >  #define hpage_nr_pages(x) 1
> >  
> >  #define transparent_hugepage_enabled(__vma) 0
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index 2e86251..8feeecc 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -270,8 +270,15 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
> >  unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
> >  			int tag, unsigned int nr_pages, struct page **pages);
> >  
> > -struct page *grab_cache_page_write_begin(struct address_space *mapping,
> > +struct page *__grab_cache_page_write_begin(struct address_space *mapping,
> >  			pgoff_t index, unsigned flags);
> > +static inline struct page *grab_cache_page_write_begin(
> > +		struct address_space *mapping, pgoff_t index, unsigned flags)
> > +{
> > +	if (!transparent_hugepage_pagecache() && (flags & AOP_FLAG_TRANSHUGE))
> > +		return NULL;
> > +	return __grab_cache_page_write_begin(mapping, index, flags);
> > +}
> 
> OK, so there's some of the behavior.
> 
> Could you also call out why you refactored this code?  It seems like
> you're trying to optimize for the case where AOP_FLAG_TRANSHUGE isn't
> set and where the compiler knows that it isn't set.
> 
> Could you talk a little bit about the cases that you're thinking of here?

I just tried to make it cheaper for !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
case, but it seems not worth it: the only user call it from
'if (mapping_can_have_hugepages())', so I'll drop this.

> >  /*
> >   * Returns locked page at given index in given cache, creating it if needed.
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 9ea46a4..e086ef0 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2309,25 +2309,44 @@ EXPORT_SYMBOL(generic_file_direct_write);
> >   * Find or create a page at the given pagecache position. Return the locked
> >   * page. This function is specifically for buffered writes.
> >   */
> > -struct page *grab_cache_page_write_begin(struct address_space *mapping,
> > -					pgoff_t index, unsigned flags)
> > +struct page *__grab_cache_page_write_begin(struct address_space *mapping,
> > +		pgoff_t index, unsigned flags)
> >  {
> >  	int status;
> >  	gfp_t gfp_mask;
> >  	struct page *page;
> >  	gfp_t gfp_notmask = 0;
> > +	bool thp = (flags & AOP_FLAG_TRANSHUGE) &&
> > +		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
> 
> Instead of 'thp', how about 'must_use_thp'?  The flag seems to be a
> pretty strong edict rather than a hint, so it should be reflected in the
> variables derived from it.

Ok.

> "IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)" has also popped up
> enough times in the code that it's probably time to start thinking about
> shortening it up.  It's a wee bit verbose.

I'll leave it as is for now. Probably come back later.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
