Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D484B6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 03:38:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G7c3Mm023289
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 16:38:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB62B45DE51
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 16:38:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B972845DE55
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 16:38:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5603CE38005
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 16:38:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA6FAE08001
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 16:37:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set V2
In-Reply-To: <20090715220445.GA1823@cmpxchg.org>
References: <alpine.DEB.1.10.0907151027410.23643@gentwo.org> <20090715220445.GA1823@cmpxchg.org>
Message-Id: <20090716163537.9D3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 16:37:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

> From eee677ddea61b1331a3bd8e402a0d02437fe872a Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 15 Jul 2009 23:40:28 +0200
> Subject: [patch] mm: non-atomic test-clear of PG_mlocked on free
> 
> By the time PG_mlocked is cleared in the page freeing path, nobody
> else is looking at our page->flags anymore.
> 
> It is thus safe to make the test-and-clear non-atomic and thereby
> removing an unnecessary and expensive operation from a hotpath.

I like this patch. but can you please separate two following patches?
  - introduce __TESTCLEARFLAG()
  - non-atomic test-clear of PG_mlocked on free



> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/page-flags.h |   12 +++++++++---
>  mm/page_alloc.c            |    4 ++--
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index e2e5ce5..10e6011 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -158,6 +158,9 @@ static inline int TestSetPage##uname(struct page *page)			\
>  static inline int TestClearPage##uname(struct page *page)		\
>  		{ return test_and_clear_bit(PG_##lname, &page->flags); }
>  
> +#define __TESTCLEARFLAG(uname, lname)					\
> +static inline int __TestClearPage##uname(struct page *page)		\
> +		{ return __test_and_clear_bit(PG_##lname, &page->flags); }
>  
>  #define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
>  	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
> @@ -184,6 +187,9 @@ static inline void __ClearPage##uname(struct page *page) {  }
>  #define TESTCLEARFLAG_FALSE(uname)					\
>  static inline int TestClearPage##uname(struct page *page) { return 0; }
>  
> +#define __TESTCLEARFLAG_FALSE(uname)					\
> +static inline int __TestClearPage##uname(struct page *page) { return 0; }
> +
>  struct page;	/* forward declaration */
>  
>  TESTPAGEFLAG(Locked, locked) TESTSETFLAG(Locked, locked)
> @@ -250,11 +256,11 @@ PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
>  #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
>  #define MLOCK_PAGES 1
>  PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
> -	TESTSCFLAG(Mlocked, mlocked)
> +	TESTSCFLAG(Mlocked, mlocked) __TESTCLEARFLAG(Mlocked, mlocked)
>  #else
>  #define MLOCK_PAGES 0
> -PAGEFLAG_FALSE(Mlocked)
> -	SETPAGEFLAG_NOOP(Mlocked) TESTCLEARFLAG_FALSE(Mlocked)
> +PAGEFLAG_FALSE(Mlocked) SETPAGEFLAG_NOOP(Mlocked)
> +	TESTCLEARFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
>  #endif
>  
>  #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index caa9268..b0c8758 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -557,7 +557,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	unsigned long flags;
>  	int i;
>  	int bad = 0;
> -	int wasMlocked = TestClearPageMlocked(page);
> +	int wasMlocked = __TestClearPageMlocked(page);
>  
>  	kmemcheck_free_shadow(page, order);
>  
> @@ -1021,7 +1021,7 @@ static void free_hot_cold_page(struct page *page, int cold)
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
>  	unsigned long flags;
> -	int wasMlocked = TestClearPageMlocked(page);
> +	int wasMlocked = __TestClearPageMlocked(page);
>  
>  	kmemcheck_free_shadow(page, 0);
>  
> -- 
> 1.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
