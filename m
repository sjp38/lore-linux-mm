Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 52A626B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:15:52 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so2344652pac.13
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:15:52 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id dx4si14647447pbb.90.2015.01.18.22.15.49
        for <linux-mm@kvack.org>;
        Sun, 18 Jan 2015 22:15:51 -0800 (PST)
Date: Mon, 19 Jan 2015 15:16:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/2] mm: don't use compound_head() in
 virt_to_head_page()
Message-ID: <20150119061637.GB11473@js1304-P5Q-DELUXE>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1421307633-24045-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20150115171646.8fec31e2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115171646.8fec31e2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jan 15, 2015 at 05:16:46PM -0800, Andrew Morton wrote:
> On Thu, 15 Jan 2015 16:40:33 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > compound_head() is implemented with assumption that there would be
> > race condition when checking tail flag. This assumption is only true
> > when we try to access arbitrary positioned struct page.
> > 
> > The situation that virt_to_head_page() is called is different case.
> > We call virt_to_head_page() only in the range of allocated pages,
> > so there is no race condition on tail flag. In this case, we don't
> > need to handle race condition and we can reduce overhead slightly.
> > This patch implements compound_head_fast() which is similar with
> > compound_head() except tail flag race handling. And then,
> > virt_to_head_page() uses this optimized function to improve performance.
> > 
> > I saw 1.8% win in a fast-path loop over kmem_cache_alloc/free,
> > (14.063 ns -> 13.810 ns) if target object is on tail page.
> >
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -453,6 +453,13 @@ static inline struct page *compound_head(struct page *page)
> >  	return page;
> >  }
> >  
> > +static inline struct page *compound_head_fast(struct page *page)
> > +{
> > +	if (unlikely(PageTail(page)))
> > +		return page->first_page;
> > +	return page;
> > +}
> 
> Can we please have some code comments which let people know when they
> should and shouldn't use compound_head_fast()?  I shouldn't have to say
> this :(

Okay.
> 
> >  /*
> >   * The atomic page->_mapcount, starts from -1: so that transitions
> >   * both from it and to it can be tracked, using atomic_inc_and_test
> > @@ -531,7 +538,8 @@ static inline void get_page(struct page *page)
> >  static inline struct page *virt_to_head_page(const void *x)
> >  {
> >  	struct page *page = virt_to_page(x);
> > -	return compound_head(page);
> > +
> > +	return compound_head_fast(page);
> 
> And perhaps some explanation here as to why virt_to_head_page() can
> safely use compound_head_fast().  There's an assumption here that
> nobody will be dismantling the compound page while virt_to_head_page()
> is in progress, yes?  And this assumption also holds for the calling
> code, because otherwise the virt_to_head_page() return value is kinda
> meaningless.
> 
> This is tricky stuff - let's spell it out carefully.

Okay.

I already sent v3 and it would have proper code comments.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
