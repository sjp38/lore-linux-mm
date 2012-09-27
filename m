Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 022A76B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:17:41 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so1020966pad.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:17:41 -0700 (PDT)
Date: Wed, 26 Sep 2012 18:17:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4] kpageflags: fix wrong KPF_THP on non-huge compound
 pages
In-Reply-To: <1348691234-31729-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1209261817200.7072@chino.kir.corp.google.com>
References: <1348691234-31729-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 26 Sep 2012, Naoya Horiguchi wrote:

> diff --git v3.6-rc6.orig/fs/proc/page.c v3.6-rc6/fs/proc/page.c
> index 7fcd0d6..b8730d9 100644
> --- v3.6-rc6.orig/fs/proc/page.c
> +++ v3.6-rc6/fs/proc/page.c
> @@ -115,7 +115,13 @@ u64 stable_page_flags(struct page *page)
>  		u |= 1 << KPF_COMPOUND_TAIL;
>  	if (PageHuge(page))
>  		u |= 1 << KPF_HUGE;
> -	else if (PageTransCompound(page))
> +	/*
> +	 * PageTransCompound can be true for non-huge compound pages (slab
> +	 * pages or pages allocated by drivers with __GFP_COMP) because it
> +	 * just checks PG_head/PG_tail, so we need to check PageLRU to make
> +	 * sure a given page is a thp, not a non-huge compound page.
> +	 */
> +	else if (PageTransCompound(page) && PageLRU(compound_trans_head(page)))
>  		u |= 1 << KPF_THP;
>  
>  	/*

Yes, that looks good.  Nice catch by Fengguang.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
