Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 9975E6B0081
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:34:58 -0400 (EDT)
Date: Thu, 10 May 2012 14:34:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/1] page_alloc.c: remove argument to
 pageblock_default_order
Message-ID: <20120510133454.GG9004@csn.ul.ie>
References: <1336065312-2891-1-git-send-email-rajman.mekaco@gmail.com>
 <20120503163749.d24bf07f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120503163749.d24bf07f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rajman mekaco <rajman.mekaco@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org

On Thu, May 03, 2012 at 04:37:49PM -0700, Andrew Morton wrote:
> On Thu,  3 May 2012 22:45:12 +0530
> rajman mekaco <rajman.mekaco@gmail.com> wrote:
> 
> > When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined, then
> > pageblock_default_order has an argument to it.
> > 
> > However, free_area_init_core will call it without any argument
> > anyway.
> > 
> > Remove the argument to pageblock_default_order when
> > CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined.
> > 
> > Signed-off-by: rajman mekaco <rajman.mekaco@gmail.com>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a712fb9..4b95412 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4274,7 +4274,7 @@ static inline void __init set_pageblock_order(unsigned int order)
> >   * at compile-time. See include/linux/pageblock-flags.h for the values of
> >   * pageblock_order based on the kernel config
> >   */
> > -static inline int pageblock_default_order(unsigned int order)
> > +static inline int pageblock_default_order(void)
> >  {
> >  	return MAX_ORDER-1;
> >  }
> 
> Interesting.  It has been that way since at least 3.1.
> 

/me slaps self

> It didn't break the build because pageblock_default_order() is only
> ever invoked by set_pageblock_order(), with:
> 
> 	set_pageblock_order(pageblock_default_order());
> 
> and set_pageblock_order() is a macro:
> 
> #define set_pageblock_order(x)	do {} while (0)
> 
> There's yet another reason not to use macros, dammit - they hide bugs.
> 
> 
> Mel, can you have a think about this please?  Can we just kill off
> pageblock_default_order() and fold its guts into
> set_pageblock_order(void)?  Only ia64 and powerpc can define
> CONFIG_HUGETLB_PAGE_SIZE_VARIABLE.
> 

This looks reasonable to me.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
