Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 66B5F6B0005
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 09:24:15 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id zm5so90525909pac.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 06:24:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hx6si6783082pac.95.2016.04.01.06.24.14
        for <linux-mm@kvack.org>;
        Fri, 01 Apr 2016 06:24:14 -0700 (PDT)
Date: Fri, 1 Apr 2016 14:24:07 +0100
From: Steve Capper <steve.capper@arm.com>
Subject: Re: [PATCH] mm: Exclude HugeTLB pages from THP page_mapped logic
Message-ID: <20160401132406.GA22462@e103986-lin>
References: <1459269581-21190-1-git-send-email-steve.capper@arm.com>
 <20160331160650.cfc0fa57e97a45e94bc023f4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160331160650.cfc0fa57e97a45e94bc023f4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dwoods@mellanox.com, mhocko@suse.com, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

On Thu, Mar 31, 2016 at 04:06:50PM -0700, Andrew Morton wrote:
> On Tue, 29 Mar 2016 17:39:41 +0100 Steve Capper <steve.capper@arm.com> wrote:
> 
> > HugeTLB pages cannot be split, thus use the compound_mapcount to
> > track rmaps.
> > 
> > Currently the page_mapped function will check the compound_mapcount, but
> 
> s/the page_mapped function/page_mapped()/.  It's so much simpler!

Thanks, agreed :-).

> 
> > will also go through the constituent pages of a THP compound page and
> > query the individual _mapcount's too.
> > 
> > Unfortunately, the page_mapped function does not distinguish between
> > HugeTLB and THP compound pages and assumes that a compound page always
> > needs to have HPAGE_PMD_NR pages querying.
> > 
> > For most cases when dealing with HugeTLB this is just inefficient, but
> > for scenarios where the HugeTLB page size is less than the pmd block
> > size (e.g. when using contiguous bit on ARM) this can lead to crashes.
> > 
> > This patch adjusts the page_mapped function such that we skip the
> > unnecessary THP reference checks for HugeTLB pages.
> > 
> > Fixes: e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount() for compound pages")
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
> > ---
> > 
> > Hi,
> > 
> > This patch is my approach to fixing a problem that unearthed with
> > HugeTLB pages on arm64. We ran with PAGE_SIZE=64KB and placed down 32
> > contiguous ptes to create 2MB HugeTLB pages. (We can provide hints to
> > the MMU that page table entries are contiguous thus larger TLB entries
> > can be used to represent them).
> 
> So which kernel version(s) need this patch?  I think both 4.4 and 4.5
> will crash in this manner?  Should we backport the fix into 4.4.x and
> 4.5.x?

We de-activated the contiguous hint support just before 4.5 (as we ran
into the problem too late). So no kernels are currently crashing due to
this. If this goes in, we can then re-enable contiguous hint on ARM.

> 
> >
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1031,6 +1031,8 @@ static inline bool page_mapped(struct page *page)
> >  	page = compound_head(page);
> >  	if (atomic_read(compound_mapcount_ptr(page)) >= 0)
> >  		return true;
> > +	if (PageHuge(page))
> > +		return false;
> >  	for (i = 0; i < hpage_nr_pages(page); i++) {
> >  		if (atomic_read(&page[i]._mapcount) >= 0)
> >  			return true;
> 
> page_mapped() is moronically huge.  Uninlining it saves 206 bytes per
> callsite. It has 40+ callsites.
> 
> 
> 
> 
> btw, is anyone else seeing this `make M=' breakage?
> 
> akpm3:/usr/src/25> make M=mm
> Makefile:679: Cannot use CONFIG_KCOV: -fsanitize-coverage=trace-pc is not supported by compiler
> 
>   WARNING: Symbol version dump ./Module.symvers
>            is missing; modules will have no dependencies and modversions.
> 
> make[1]: *** No rule to make target `mm/filemap.o', needed by `mm/built-in.o'.  Stop.
> make: *** [_module_mm] Error 2
> 
> It's a post-4.5 thing.

Sorry I have not yet tried out KCOV.

> 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm: uninline page_mapped()
> 
> It's huge.  Uninlining it saves 206 bytes per callsite.  Shaves 4924 bytes
> from the x86_64 allmodconfig vmlinux.
> 
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

The below looks reasonable to me, I don't have any benchmarks handy to
test for a performance regression on this though.

> 
>  include/linux/mm.h |   21 +--------------------
>  mm/util.c          |   22 ++++++++++++++++++++++
>  2 files changed, 23 insertions(+), 20 deletions(-)
> 
> diff -puN include/linux/mm.h~mm-uninline-page_mapped include/linux/mm.h
> --- a/include/linux/mm.h~mm-uninline-page_mapped
> +++ a/include/linux/mm.h
> @@ -1019,26 +1019,7 @@ static inline pgoff_t page_file_index(st
>  	return page->index;
>  }
>  
> -/*
> - * Return true if this page is mapped into pagetables.
> - * For compound page it returns true if any subpage of compound page is mapped.
> - */
> -static inline bool page_mapped(struct page *page)
> -{
> -	int i;
> -	if (likely(!PageCompound(page)))
> -		return atomic_read(&page->_mapcount) >= 0;
> -	page = compound_head(page);
> -	if (atomic_read(compound_mapcount_ptr(page)) >= 0)
> -		return true;
> -	if (PageHuge(page))
> -		return false;
> -	for (i = 0; i < hpage_nr_pages(page); i++) {
> -		if (atomic_read(&page[i]._mapcount) >= 0)
> -			return true;
> -	}
> -	return false;
> -}
> +bool page_mapped(struct page *page);
>  
>  /*
>   * Return true only if the page has been allocated with
> diff -puN mm/util.c~mm-uninline-page_mapped mm/util.c
> --- a/mm/util.c~mm-uninline-page_mapped
> +++ a/mm/util.c
> @@ -346,6 +346,28 @@ void *page_rmapping(struct page *page)
>  	return __page_rmapping(page);
>  }
>  
> +/*
> + * Return true if this page is mapped into pagetables.
> + * For compound page it returns true if any subpage of compound page is mapped.
> + */
> +bool page_mapped(struct page *page)
> +{
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >= 0;
> +	page = compound_head(page);
> +	if (atomic_read(compound_mapcount_ptr(page)) >= 0)
> +		return true;
> +	if (PageHuge(page))
> +		return false;
> +	for (i = 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >= 0)
> +			return true;
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL(page_mapped);
> +
>  struct anon_vma *page_anon_vma(struct page *page)
>  {
>  	unsigned long mapping;
> _
> 

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
