Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9EFD1900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 19:48:57 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3GNmqse008202
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 16:48:55 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq2.eem.corp.google.com with ESMTP id p3GNmnCp006614
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 16:48:51 -0700
Received: by pwi10 with SMTP id 10so1851424pwi.28
        for <linux-mm@kvack.org>; Sat, 16 Apr 2011 16:48:49 -0700 (PDT)
Date: Sat, 16 Apr 2011 16:48:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: make read-only accessors take const parameters
In-Reply-To: <1302861377-8048-2-git-send-email-ext-phil.2.carmody@nokia.com>
Message-ID: <alpine.DEB.2.00.1104161609380.827@chino.kir.corp.google.com>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com> <1302861377-8048-2-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Apr 2011, Phil Carmody wrote:

> Pulling out bits from flags and atomic_read() do not modify
> anything, nor do we want to modify anything. We can extend that
> insight to clients. This makes static code analysis easier.
> 
> I'm not happy with the _ro bloat, but at least it doesn't change
> the size of the generated code. An alternative would be a type-
> less macro.
> 

The only advantage I can see by doing this is that functions calling these 
helpers can mark their struct page * formals or automatic variables with 
const as well.

That's only worthwhile if you have actual usecases where these newly-
converted helpers generate more efficient code as a result of being able 
to be marked const themselves.  If that's the case, then they should 
be proposed as an individual patch with both the caller and the helper 
being marked const at the same time.

It doesn't really matter that these helpers are all inline since the 
qualifiers will still be enforced at compile time.

> Also cleaned up some unnecessary (brackets).
> 

These cleanups can be pushed through the trivial tree if you're 
interested, email Jiri Kosina <trivial@kernel.org>.

> Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
> ---
>  include/linux/mm.h         |   27 +++++++++++++++++----------
>  include/linux/page-flags.h |    8 ++++----
>  2 files changed, 21 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 692dbae..7134563 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -353,9 +353,16 @@ static inline struct page *compound_head(struct page *page)
>  	return page;
>  }
>  
> -static inline int page_count(struct page *page)
> +static inline const struct page *compound_head_ro(const struct page *page)
>  {
> -	return atomic_read(&compound_head(page)->_count);
> +	if (unlikely(PageTail(page)))
> +		return page->first_page;
> +	return page;
> +}
> +
> +static inline int page_count(const struct page *page)
> +{
> +	return atomic_read(&compound_head_ro(page)->_count);
>  }
>  
>  static inline void get_page(struct page *page)

Adding this excess code, however, is unnecessary since no caller of 
page_count() is optimized to use a const struct page * itself; if such an 
optimization actually exists, then it would need to be demonstrated with 
data before we'd want to add this extra function.

If you'd like to propose a patch for the remainder of the 
"struct page *" -> "const struct page *" changes in this email, then 
there's no downside and could potentially be useful in the future for 
callers, so you can add my

	Acked-by: David Rientjes <rientjes@google.com>

to such a patch.

 [ Please separate out the trivial changes by removing the brackets, 
   though, and submit them to Jiri instead. ]

> @@ -638,7 +645,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
>  #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
>  
> -static inline enum zone_type page_zonenum(struct page *page)
> +static inline enum zone_type page_zonenum(const struct page *page)
>  {
>  	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
>  }
> @@ -651,7 +658,7 @@ static inline enum zone_type page_zonenum(struct page *page)
>   * We guarantee only that it will return the same value for two
>   * combinable pages in a zone.
>   */
> -static inline int page_zone_id(struct page *page)
> +static inline int page_zone_id(const struct page *page)
>  {
>  	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
>  }
> @@ -786,7 +793,7 @@ static inline void *page_rmapping(struct page *page)
>  	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
>  }
>  
> -static inline int PageAnon(struct page *page)
> +static inline int PageAnon(const struct page *page)
>  {
>  	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
>  }
> @@ -809,20 +816,20 @@ static inline pgoff_t page_index(struct page *page)
>   */
>  static inline void reset_page_mapcount(struct page *page)
>  {
> -	atomic_set(&(page)->_mapcount, -1);
> +	atomic_set(&page->_mapcount, -1);
>  }
>  
> -static inline int page_mapcount(struct page *page)
> +static inline int page_mapcount(const struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	return atomic_read(&page->_mapcount) + 1;
>  }
>  
>  /*
>   * Return true if this page is mapped into pagetables.
>   */
> -static inline int page_mapped(struct page *page)
> +static inline int page_mapped(const struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) >= 0;
> +	return atomic_read(&page->_mapcount) >= 0;
>  }
>  
>  /*
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 811183d..7f8e553 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -135,7 +135,7 @@ enum pageflags {
>   * Macros to create function definitions for page flags
>   */
>  #define TESTPAGEFLAG(uname, lname)					\
> -static inline int Page##uname(struct page *page) 			\
> +static inline int Page##uname(const struct page *page)			\
>  			{ return test_bit(PG_##lname, &page->flags); }
>  
>  #define SETPAGEFLAG(uname, lname)					\
> @@ -173,7 +173,7 @@ static inline int __TestClearPage##uname(struct page *page)		\
>  	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
>  
>  #define PAGEFLAG_FALSE(uname) 						\
> -static inline int Page##uname(struct page *page) 			\
> +static inline int Page##uname(const struct page *page)			\
>  			{ return 0; }
>  
>  #define TESTSCFLAG(uname, lname)					\
> @@ -345,7 +345,7 @@ static inline void set_page_writeback(struct page *page)
>  __PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
>  __PAGEFLAG(Tail, tail)
>  
> -static inline int PageCompound(struct page *page)
> +static inline int PageCompound(const struct page *page)
>  {
>  	return page->flags & ((1L << PG_head) | (1L << PG_tail));
>  
> @@ -379,7 +379,7 @@ __PAGEFLAG(Head, compound)
>   */
>  #define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))
>  
> -static inline int PageTail(struct page *page)
> +static inline int PageTail(const struct page *page)
>  {
>  	return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
