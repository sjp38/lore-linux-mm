Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 95D776B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 02:32:16 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so6305792pab.35
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 23:32:16 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sf9si12930900pac.8.2014.11.27.23.32.13
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 23:32:15 -0800 (PST)
Date: Fri, 28 Nov 2014 16:35:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 2/8] mm/debug-pagealloc: prepare boottime configurable
 on/off
Message-ID: <20141128073524.GC11802@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416816926-7756-3-git-send-email-iamjoonsoo.kim@lge.com>
 <1417091739.29407.95.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417091739.29407.95.camel@x220>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 27, 2014 at 01:35:39PM +0100, Paul Bolle wrote:
> Joonsoo,
> 
> On Mon, 2014-11-24 at 17:15 +0900, Joonsoo Kim wrote:
> > Until now, debug-pagealloc needs extra flags in struct page, so we need
> > to recompile whole source code when we decide to use it. This is really
> > painful, because it takes some time to recompile and sometimes rebuild is
> > not possible due to third party module depending on struct page.
> > So, we can't use this good feature in many cases.
> > 
> > Now, we have the page extension feature that allows us to insert
> > extra flags to outside of struct page. This gets rid of third party module
> > issue mentioned above. And, this allows us to determine if we need extra
> > memory for this page extension in boottime. With these property, we can
> > avoid using debug-pagealloc in boottime with low computational overhead
> > in the kernel built with CONFIG_DEBUG_PAGEALLOC. This will help our
> > development process greatly.
> > 
> > This patch is the preparation step to achive above goal. debug-pagealloc
> > originally uses extra field of struct page, but, after this patch, it
> > will use field of struct page_ext. Because memory for page_ext is
> > allocated later than initialization of page allocator in CONFIG_SPARSEMEM,
> > we should disable debug-pagealloc feature temporarily until initialization
> > of page_ext. This patch implements this.
> > 
> > v2: fix compile error on CONFIG_PAGE_POISONING
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> This patch is included in today's linux-next (ie, next-2o0141127) as
> commit 1e491e9be4c9 ("mm/debug-pagealloc: prepare boottime configurable
> on/off").
> 
> > [...]
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 33a8acf..c7b22e7 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -10,7 +10,6 @@
> >  #include <linux/rwsem.h>
> >  #include <linux/completion.h>
> >  #include <linux/cpumask.h>
> > -#include <linux/page-debug-flags.h>
> >  #include <linux/uprobes.h>
> >  #include <linux/page-flags-layout.h>
> >  #include <asm/page.h>
> > @@ -186,9 +185,6 @@ struct page {
> >  	void *virtual;			/* Kernel virtual address (NULL if
> >  					   not kmapped, ie. highmem) */
> >  #endif /* WANT_PAGE_VIRTUAL */
> > -#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
> > -	unsigned long debug_flags;	/* Use atomic bitops on this */
> > -#endif
> >  
> >  #ifdef CONFIG_KMEMCHECK
> >  	/*
> > diff --git a/include/linux/page-debug-flags.h b/include/linux/page-debug-flags.h
> > deleted file mode 100644
> > index 22691f61..0000000
> > --- a/include/linux/page-debug-flags.h
> > +++ /dev/null
> > @@ -1,32 +0,0 @@
> > -#ifndef LINUX_PAGE_DEBUG_FLAGS_H
> > -#define  LINUX_PAGE_DEBUG_FLAGS_H
> > -
> > -/*
> > - * page->debug_flags bits:
> > - *
> > - * PAGE_DEBUG_FLAG_POISON is set for poisoned pages. This is used to
> > - * implement generic debug pagealloc feature. The pages are filled with
> > - * poison patterns and set this flag after free_pages(). The poisoned
> > - * pages are verified whether the patterns are not corrupted and clear
> > - * the flag before alloc_pages().
> > - */
> > -
> > -enum page_debug_flags {
> > -	PAGE_DEBUG_FLAG_POISON,		/* Page is poisoned */
> > -	PAGE_DEBUG_FLAG_GUARD,
> > -};
> > -
> > -/*
> > - * Ensure that CONFIG_WANT_PAGE_DEBUG_FLAGS reliably
> > - * gets turned off when no debug features are enabling it!
> > - */
> > -
> > -#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
> > -#if !defined(CONFIG_PAGE_POISONING) && \
> > -    !defined(CONFIG_PAGE_GUARD) \
> > -/* && !defined(CONFIG_PAGE_DEBUG_SOMETHING_ELSE) && ... */
> > -#error WANT_PAGE_DEBUG_FLAGS is turned on with no debug features!
> > -#endif
> > -#endif /* CONFIG_WANT_PAGE_DEBUG_FLAGS */
> > -
> > -#endif /* LINUX_PAGE_DEBUG_FLAGS_H */
> 
> This remove all uses of CONFIG_WANT_PAGE_DEBUG_FLAGS and
> CONFIG_PAGE_GUARD. So the Kconfig symbols WANT_PAGE_DEBUG_FLAGS and
> PAGE_GUARD are now unused.
> 
> Should I submit the trivial patch to remove these symbols or is a patch
> that does that queued already?

Hello, Paul.

Thanks for spotting this.
I attach the patch. :)

Andrew,
Could you kindly fold this into the patch in your tree?

Thanks.

------------------->8---------------
