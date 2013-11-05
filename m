Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1E53E6B00A2
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 18:38:30 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id x10so9242822pdj.40
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:38:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.156])
        by mx.google.com with SMTP id gn4si15017508pbc.351.2013.11.05.15.38.27
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 15:38:28 -0800 (PST)
Date: Wed, 6 Nov 2013 00:42:17 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-ID: <20131105224217.GC20167@shutemov.name>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org


[ sorry, resend to all ]

On Tue, Nov 05, 2013 at 03:01:45PM -0800, Andrew Morton wrote:
> On Tue, 22 Oct 2013 14:53:59 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > If DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC are enabled spinlock_t on x86_64
> > is 72 bytes. For page->ptl they will be allocated from kmalloc-96 slab,
> > so we loose 24 on each. An average system can easily allocate few tens
> > thousands of page->ptl and overhead is significant.
> > 
> > Let's create a separate slab for page->ptl allocation to solve this.
> > 
> > ...
> >
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -4332,11 +4332,19 @@ void copy_user_huge_page(struct page *dst, struct page *src,
> >  #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
> >  
> >  #if USE_SPLIT_PTE_PTLOCKS
> > +struct kmem_cache *page_ptl_cachep;
> > +void __init ptlock_cache_init(void)
> > +{
> > +	if (sizeof(spinlock_t) > sizeof(long))
> > +		page_ptl_cachep = kmem_cache_create("page->ptl",
> > +				sizeof(spinlock_t), 0, SLAB_PANIC, NULL);
> > +}
> 
> Confused.  If (sizeof(spinlock_t) > sizeof(long)) happens to be false
> then the kernel will later crash.  It would be better to use BUILD_BUG_ON()
> here, if that works.  Otherwise BUG_ON.

if (sizeof(spinlock_t) > sizeof(long)) is false, we don't need dynamicly
allocate page->ptl. It's embedded to struct page itself. __ptlock_alloc()
never called in this case.

> Also, we have the somewhat silly KMEM_CACHE() macro, but it looks
> inapplicable here?

The first argument of KMEM_CACHE() is struct name, but we have typedef
here.

> >  bool __ptlock_alloc(struct page *page)
> >  {
> >  	spinlock_t *ptl;
> >  
> > -	ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
> > +	ptl = kmem_cache_alloc(page_ptl_cachep, GFP_KERNEL);
> >  	if (!ptl)
> >  		return false;
> >  	page->ptl = (unsigned long)ptl;
> > @@ -4346,6 +4354,6 @@ bool __ptlock_alloc(struct page *page)
> >  void __ptlock_free(struct page *page)
> >  {
> >  	if (sizeof(spinlock_t) > sizeof(page->ptl))
> > -		kfree((spinlock_t *)page->ptl);
> > +		kmem_cache_free(page_ptl_cachep, (spinlock_t *)page->ptl);
> 
> A void* cast would suffice here, but I suppose the spinlock_t* cast has
> some documentation value.

Right.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
