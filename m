Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 149BF8D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 14:59:12 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p1BJx7Lt020404
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 11:59:07 -0800
Received: from ywk9 (ywk9.prod.google.com [10.192.11.9])
	by wpaz21.hot.corp.google.com with ESMTP id p1BJx3KZ017038
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 11:59:06 -0800
Received: by ywk9 with SMTP id 9so1311651ywk.3
        for <linux-mm@kvack.org>; Fri, 11 Feb 2011 11:59:03 -0800 (PST)
Date: Fri, 11 Feb 2011 11:58:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
In-Reply-To: <20110211104906.GE3347@random.random>
Message-ID: <alpine.LSU.2.00.1102111132560.3814@sister.anvils>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com> <20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp> <20110209155246.69a7f3a1.kamezawa.hiroyu@jp.fujitsu.com> <20110209200728.GQ3347@random.random> <alpine.LSU.2.00.1102102243160.2331@sister.anvils>
 <20110211104906.GE3347@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Fri, 11 Feb 2011, Andrea Arcangeli wrote:
> On Thu, Feb 10, 2011 at 11:02:50PM -0800, Hugh Dickins wrote:
> > There is a separate little issue here, Andrea.
> > 
> > Although we went to some trouble for bad_page() to take the page out
> > of circulation yet let the system continue, your VM_BUG_ON(!PageBuddy)
> > inside __ClearPageBuddy(page), from two callsites in bad_page(), is
> > turning it into a fatal error when CONFIG_DEBUG_VM.
> 
> I see what you mean. Of course it is only a problem after bad_page
> already triggered.... but then it trigger an BUG_ON instead of only a
> bad_page.
> 
> > You could that only MM developers switch CONFIG_DEBUG_VM=y, and they
> > would like bad_page() to be fatal; maybe, but if so we should do that
> > as an intentional patch, rather than as an unexpected side-effect ;)
> 
> Fedora kernels are built with CONFIG_DEBUG_VM, all my kernels runs
> with CONFIG_DEBUG_VM too, so we want it to be as "production" as
> possible, and we don't want DEBUG_VM to decrease any reliability (only
> to increase it of course).

Oh, I hadn't realized Fedora use it.  I wonder if that's wise, I thought
Nick introduced it partly for the more expensive checks, and there might
be one or two of those around - those bad_range()s in page_alloc.c?

> 
> > I noticed this a few days ago, but hadn't quite decided whether just to
> > remove the VM_BUG_ON, or move it to __ClearPageBuddy's third callsite,
> > or... doesn't matter much.
> >
> > I do also wonder if PageBuddy would better be _mapcount -something else:
> > if we've got a miscounted page (itself unlikely of course), there's a
> > chance that its _mapcount will be further decremented after it has been
> > freed: whereupon it will go from -1 to -2, PageBuddy at present.  The
> > special avoidance of PageBuddy being that it can pull a whole block of
> > pages into misuse if its mistaken.
> 
> Agreed. What about the below?
> 
> =====
> Subject: mm: PageBuddy cleanups
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> bad_page could VM_BUG_ON(!PageBuddy(page)) inside __ClearPageBuddy().
> I prefer to keep the VM_BUG_ON for safety and to add a if to solve it.

Too much iffery: I ended up preferring it in rmv_page_order() myself.

> 
> Change the _mapcount value indicating PageBuddy from -2 to -1024 for more
> robusteness against page_mapcount() undeflows.

But the patch actually says -1024*1024: either would do.

> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Hugh Dickins <hughd@google.com>
> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f6385fc..fa16ba0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -402,16 +402,22 @@ static inline void init_page_count(struct page *page)
>  /*
>   * PageBuddy() indicate that the page is free and in the buddy system
>   * (see mm/page_alloc.c).
> + *
> + * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
> + * -2 so that an underflow of the page_mapcount() won't be mistaken
> + * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE.

Yes, good to comment that, thanks.

>   */
> +#define PAGE_BUDDY_MAPCOUNT_VALUE (-1024*1024)
> +
>  static inline int PageBuddy(struct page *page)
>  {
> -	return atomic_read(&page->_mapcount) == -2;
> +	return atomic_read(&page->_mapcount) == PAGE_BUDDY_MAPCOUNT_VALUE;
>  }
>  
>  static inline void __SetPageBuddy(struct page *page)
>  {
>  	VM_BUG_ON(atomic_read(&page->_mapcount) != -1);
> -	atomic_set(&page->_mapcount, -2);
> +	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
>  }
>  
>  static inline void __ClearPageBuddy(struct page *page)

Yes, that's fine, 0xfff00000 looks unlikely enough (and my
imagination for "deadbeef"-like magic is too drowsy today).

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a873e61..8aac134 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -286,7 +286,9 @@ static void bad_page(struct page *page)
>  
>  	/* Don't complain about poisoned pages */
>  	if (PageHWPoison(page)) {
> -		__ClearPageBuddy(page);
> +		/* __ClearPageBuddy VM_BUG_ON(!PageBuddy(page)) */
> +		if (PageBuddy(page))
> +			__ClearPageBuddy(page);
>  		return;
>  	}
>  
> @@ -317,7 +319,8 @@ static void bad_page(struct page *page)
>  	dump_stack();
>  out:
>  	/* Leave bad fields for debug, except PageBuddy could make trouble */
> -	__ClearPageBuddy(page);
> +	if (PageBuddy(page)) /* __ClearPageBuddy VM_BUG_ON(!PageBuddy(page)) */
> +		__ClearPageBuddy(page);
>  	add_taint(TAINT_BAD_PAGE);
>  }
>  

Okay I suppose: it seems rather laboured to me, I think I'd have just
moved the VM_BUG_ON into rmv_page_order() if I'd done the patch; but
since I was too lazy to do it, I'd better be grateful for yours!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
