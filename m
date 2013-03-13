Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 660346B0036
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 04:08:20 -0400 (EDT)
Date: Wed, 13 Mar 2013 17:08:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: page_alloc: remove branch operation in
 free_pages_prepare()
Message-ID: <20130313080816.GA4219@lge.com>
References: <1362644480-18381-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.LNX.2.00.1303071050080.6087@eggly.anvils>
 <20130308004550.GA19010@lge.com>
 <alpine.LNX.2.00.1303071745001.7553@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1303071745001.7553@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Hugh.

On Thu, Mar 07, 2013 at 06:01:26PM -0800, Hugh Dickins wrote:
> On Fri, 8 Mar 2013, Joonsoo Kim wrote:
> > On Thu, Mar 07, 2013 at 10:54:15AM -0800, Hugh Dickins wrote:
> > > On Thu, 7 Mar 2013, Joonsoo Kim wrote:
> > > 
> > > > When we found that the flag has a bit of PAGE_FLAGS_CHECK_AT_PREP,
> > > > we reset the flag. If we always reset the flag, we can reduce one
> > > > branch operation. So remove it.
> > > > 
> > > > Cc: Hugh Dickins <hughd@google.com>
> > > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > I don't object to this patch.  But certainly I would have written it
> > > that way in order not to dirty a cacheline unnecessarily.  It may be
> > > obvious to you that the cacheline in question is almost always already
> > > dirty, and the branch almost always more expensive.  But I'll leave that
> > > to you, and to those who know more about these subtle costs than I do.
> > 
> > Yes. I already think about that. I thought that even if a cacheline is
> > not dirty at this time, we always touch the 'struct page' in
> > set_freepage_migratetype() a little later, so dirtying is not the problem.
> 
> I expect that a very high proportion of user pages have
> PG_uptodate to be cleared here; and there's also the recently added
> page_nid_reset_last(), which will dirty the flags or a nearby field
> when CONFIG_NUMA_BALANCING.  Those argue in favour of your patch.
> 

Ah... I totally missed it.

> > 
> > But, now, I re-think this and decide to drop this patch.
> > The reason is that 'struct page' of 'compound pages' may not be dirty
> > at this time and will not be dirty at later time.
> 
> Actual compound pages would have PG_head or PG_tail or PG_compound
> to be cleared there, I believe (check if I'm right on that).  The
> questionable case is the ordinary order>0 case without __GFP_COMP
> (and page_nid_reset_last() is applied to each subpage of those).
>

Yes.

> > So this patch is bad idea.
> 
> I'm not so sure.  I doubt your patch will make a giant improvement
> in kernel performance!  But it might make a little - maybe you just
> need to give some numbers from perf to justify it (but I'm easily
> dazzled by numbers - don't expect me to judge the result).

Okay.
Thanks for enlightening comment.
Now, I don't have any idea to collect a performance result for this patch.
When I have more time, I try to think it.

Thanks.

> 
> Hugh
> 
> > 
> > Is there any comments?
> > 
> > Thanks.
> > 
> > > Hugh
> > > 
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 8fcced7..778f2a9 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -614,8 +614,7 @@ static inline int free_pages_check(struct page *page)
> > > >  		return 1;
> > > >  	}
> > > >  	page_nid_reset_last(page);
> > > > -	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> > > > -		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > > > +	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > > >  	return 0;
> > > >  }
> > > >  
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
