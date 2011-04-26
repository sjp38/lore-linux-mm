Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4A2900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:50:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 30B693EE0C5
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:50:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1501545DEAA
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:50:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE2F745DEA4
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:50:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DFD321DB8041
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:50:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A55C11DB803C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:50:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: readahead and oom
In-Reply-To: <20110426063421.GC19717@localhost>
References: <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com> <20110426063421.GC19717@localhost>
Message-Id: <20110426155258.F38F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 26 Apr 2011 15:50:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

> > > btw readahead page allocations are completely optional. They are OK to
> > > fail and in theory shall not trigger OOM on themselves. We may
> > > consider passing __GFP_NORETRY for readahead page allocations.
> > 
> > Good idea, care to submit a patch?
> 
> Here it is :)
> 
> Thanks,
> Fengguang
> ---
> readahead: readahead page allocations is OK to fail
> 
> Pass __GFP_NORETRY for readahead page allocations.
> 
> readahead page allocations are completely optional. They are OK to
> fail and in particular shall not trigger OOM on themselves.
> 
> Reported-by: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/pagemap.h |    5 +++++
>  mm/readahead.c          |    2 +-
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> --- linux-next.orig/include/linux/pagemap.h	2011-04-26 14:27:46.000000000 +0800
> +++ linux-next/include/linux/pagemap.h	2011-04-26 14:29:31.000000000 +0800
> @@ -219,6 +219,11 @@ static inline struct page *page_cache_al
>  	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
>  }
>  
> +static inline struct page *page_cache_alloc_cold_noretry(struct address_space *x)
> +{
> +	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD|__GFP_NORETRY);
> +}
> +
>  typedef int filler_t(void *, struct page *);
>  
>  extern struct page * find_get_page(struct address_space *mapping,
> --- linux-next.orig/mm/readahead.c	2011-04-26 14:27:02.000000000 +0800
> +++ linux-next/mm/readahead.c	2011-04-26 14:27:24.000000000 +0800
> @@ -180,7 +180,7 @@ __do_page_cache_readahead(struct address
>  		if (page)
>  			continue;
>  
> -		page = page_cache_alloc_cold(mapping);
> +		page = page_cache_alloc_cold_noretry(mapping);
>  		if (!page)
>  			break;
>  		page->index = page_offset;

I like this patch.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
