Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A39266B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 02:10:45 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g83so260507732oib.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:10:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id pz9si11261741igc.7.2016.05.29.23.10.44
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 23:10:44 -0700 (PDT)
Date: Mon, 30 May 2016 15:11:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
Message-ID: <20160530061117.GB28624@bbox>
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox>
 <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox>
 <20160527060839.GC13661@js1304-P5Q-DELUXE>
 <20160527081108.GG2322@bbox>
 <aa33f1e4-5a91-aaaf-70f1-557148b29b38@linaro.org>
MIME-Version: 1.0
In-Reply-To: <aa33f1e4-5a91-aaaf-70f1-557148b29b38@linaro.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, May 27, 2016 at 11:16:41AM -0700, Shi, Yang wrote:

<snip>

> >
> >If we goes this way, how to guarantee this race?
> 
> Thanks for pointing out this. It sounds reasonable. However, this
> should be only possible to happen on 32 bit since just 32 bit
> version page_is_idle() calls lookup_page_ext(), it doesn't do it on
> 64 bit.
> 
> And, such race condition should exist regardless of whether DEBUG_VM
> is enabled or not, right?
> 
> rcu might be good enough to protect it.
> 
> A quick fix may look like:
> 
> diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
> index 8f5d4ad..bf0cd6a 100644
> --- a/include/linux/page_idle.h
> +++ b/include/linux/page_idle.h
> @@ -77,8 +77,12 @@ static inline bool
> test_and_clear_page_young(struct page *page)
>  static inline bool page_is_idle(struct page *page)
>  {
>         struct page_ext *page_ext;
> +
> +       rcu_read_lock();
>         page_ext = lookup_page_ext(page);
> +       rcu_read_unlock();
> +
> 	if (unlikely(!page_ext))
>                 return false;
> 
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 56b160f..94927c9 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -183,7 +183,6 @@ struct page_ext *lookup_page_ext(struct page *page)
>  {
>         unsigned long pfn = page_to_pfn(page);
>         struct mem_section *section = __pfn_to_section(pfn);
> -#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
>         /*
>          * The sanity checks the page allocator does upon freeing a
>          * page can reach here before the page_ext arrays are
> @@ -195,7 +194,7 @@ struct page_ext *lookup_page_ext(struct page *page)
>          */
>         if (!section->page_ext)
>                 return NULL;
> -#endif
> +
>         return section->page_ext + pfn;
>  }
> 
> @@ -279,7 +278,8 @@ static void __free_page_ext(unsigned long pfn)
>                 return;
>         base = ms->page_ext + pfn;
>         free_page_ext(base);
> -       ms->page_ext = NULL;
> +       rcu_assign_pointer(ms->page_ext, NULL);
> +       synchronize_rcu();

How does it fix the problem?
I cannot understand your point.

>  }
> 
>  static int __meminit online_page_ext(unsigned long start_pfn,
> 
> Thanks,
> Yang
> 
> >
> >                                kpageflags_read
> >                                stable_page_flags
> >                                page_is_idle
> >                                  lookup_page_ext
> >                                  section = __pfn_to_section(pfn)
> >offline_pages
> >memory_notify(MEM_OFFLINE)
> >  offline_page_ext
> >  ms->page_ext = NULL
> >                                  section->page_ext + pfn
> >
> >>
> >>Thanks.
> >>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
