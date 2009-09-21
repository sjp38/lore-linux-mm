Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8202F6B016C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 11:22:14 -0400 (EDT)
Date: Mon, 21 Sep 2009 16:22:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: a patch drop request in -mm
Message-ID: <20090921152219.GQ12726@csn.ul.ie>
References: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 12:00:51AM +0900, KOSAKI Motohiro wrote:
> Mel,
> 
> Today, my test found following patch makes false-positive warning.
> because, truncate can free the pages
> although the pages are mlock()ed.
> 
> So, I think following patch should be dropped.
> .. or, do you think truncate should clear PG_mlock before free the page?
> 

Is there a reason that truncate cannot clear PG_mlock before freeing the
page?

> Can I ask your patch intention?


Locked pages being freed to the page allocator were considered
unexpected and a counter was in place to determine how often that
situation occurred. However, I considered it unlikely that the counter
would be noticed so the warning was put in place to catch what class of
pages were getting freed locked inappropriately. I think a few anomolies
have been cleared up since. Ultimately, it should have been safe to
delete the check.

> 
> 
> =============================================================
> commit 7a06930af46eb39351cbcdc1ab98701259f9a72c
> Author: Mel Gorman <mel@csn.ul.ie>
> Date:   Tue Aug 25 00:43:07 2009 +0200
> 
>     When a page is freed with the PG_mlocked set, it is considered an
>     unexpected but recoverable situation.  A counter records how often this
>     event happens but it is easy to miss that this event has occured at
>     all.  This patch warns once when PG_mlocked is set to prompt debuggers
>     to check the counter to see how often it is happening.
> 
>     Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>     Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
>     Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 28c2f3e..251fd73 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -494,6 +494,11 @@ static inline void __free_one_page(struct page *page,
>   */
>  static inline void free_page_mlock(struct page *page)
>  {
> +       WARN_ONCE(1, KERN_WARNING
> +               "Page flag mlocked set for process %s at pfn:%05lx\n"
> +               "page:%p flags:%#lx\n",
> +               current->comm, page_to_pfn(page),
> +               page, page->flags|__PG_MLOCKED);
>         __dec_zone_page_state(page, NR_MLOCK);
>         __count_vm_event(UNEVICTABLE_MLOCKFREED);
>  }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
