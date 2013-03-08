Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id EF3E66B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 19:45:40 -0500 (EST)
Date: Fri, 8 Mar 2013 09:45:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: page_alloc: remove branch operation in
 free_pages_prepare()
Message-ID: <20130308004550.GA19010@lge.com>
References: <1362644480-18381-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.LNX.2.00.1303071050080.6087@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1303071050080.6087@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Hugh.

On Thu, Mar 07, 2013 at 10:54:15AM -0800, Hugh Dickins wrote:
> On Thu, 7 Mar 2013, Joonsoo Kim wrote:
> 
> > When we found that the flag has a bit of PAGE_FLAGS_CHECK_AT_PREP,
> > we reset the flag. If we always reset the flag, we can reduce one
> > branch operation. So remove it.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I don't object to this patch.  But certainly I would have written it
> that way in order not to dirty a cacheline unnecessarily.  It may be
> obvious to you that the cacheline in question is almost always already
> dirty, and the branch almost always more expensive.  But I'll leave that
> to you, and to those who know more about these subtle costs than I do.

Yes. I already think about that. I thought that even if a cacheline is
not dirty at this time, we always touch the 'struct page' in
set_freepage_migratetype() a little later, so dirtying is not the problem.

But, now, I re-think this and decide to drop this patch.
The reason is that 'struct page' of 'compound pages' may not be dirty
at this time and will not be dirty at later time.
So this patch is bad idea.

Is there any comments?

Thanks.

> Hugh
> 
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8fcced7..778f2a9 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -614,8 +614,7 @@ static inline int free_pages_check(struct page *page)
> >  		return 1;
> >  	}
> >  	page_nid_reset_last(page);
> > -	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> > -		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > +	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> >  	return 0;
> >  }
> >  
> 
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
