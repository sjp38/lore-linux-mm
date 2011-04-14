Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2714900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 22:19:12 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1245388wwi.26
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:19:09 -0700 (PDT)
Subject: Re: Regression from 2.6.36
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110413141600.28793661.akpm@linux-foundation.org>
References: <20110315132527.130FB80018F1@mail1005.cent>
	 <20110317001519.GB18911@kroah.com> <20110407120112.E08DCA03@pobox.sk>
	 <4D9D8FAA.9080405@suse.cz>
	 <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	 <1302177428.3357.25.camel@edumazet-laptop>
	 <1302178426.3357.34.camel@edumazet-laptop>
	 <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
	 <1302190586.3357.45.camel@edumazet-laptop>
	 <20110412154906.70829d60.akpm@linux-foundation.org>
	 <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
	 <20110412183132.a854bffc.akpm@linux-foundation.org>
	 <1302662256.2811.27.camel@edumazet-laptop>
	 <20110413141600.28793661.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Apr 2011 04:10:58 +0200
Message-ID: <1302747058.3549.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Changli Gao <xiaosuo@gmail.com>, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>

Le mercredi 13 avril 2011 A  14:16 -0700, Andrew Morton a A(C)crit :

> So am I correct in believing that this regression is due to the
> high-order allocations putting excess stress onto page reclaim?
> 

I suppose so.

> If so, then how large _are_ these allocations?  This perhaps can be
> determined from /proc/slabinfo.  They must be pretty huge, because slub
> likes to do excessively-large allocations and the system handles that
> reasonably well.
> 
> I suppose that a suitable fix would be
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Azurit reports large increases in system time after 2.6.36 when running
> Apache.  It was bisected down to a892e2d7dcdfa6c76e6 ("vfs: use kmalloc()
> to allocate fdmem if possible").
> 
> That patch caused the vfs to use kmalloc() for very large allocations and
> this is causing excessive work (and presumably excessive reclaim) within
> the page allocator.
> 
> Fix it by falling back to vmalloc() earlier - when the allocation attempt
> would have been considered "costly" by reclaim.
> 
> Reported-by: azurIt <azurit@pobox.sk>
> Cc: Changli Gao <xiaosuo@gmail.com>
> Cc: Americo Wang <xiyou.wangcong@gmail.com>
> Cc: Jiri Slaby <jslaby@suse.cz>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/file.c |   17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff -puN fs/file.c~a fs/file.c
> --- a/fs/file.c~a
> +++ a/fs/file.c
> @@ -39,14 +39,17 @@ int sysctl_nr_open_max = 1024 * 1024; /*
>   */
>  static DEFINE_PER_CPU(struct fdtable_defer, fdtable_defer_list);
>  
> -static inline void *alloc_fdmem(unsigned int size)
> +static void *alloc_fdmem(unsigned int size)
>  {
> -	void *data;
> -
> -	data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> -	if (data != NULL)
> -		return data;
> -
> +	/*
> +	 * Very large allocations can stress page reclaim, so fall back to
> +	 * vmalloc() if the allocation size will be considered "large" by the VM.
> +	 */
> +	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) {
> +		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> +		if (data != NULL)
> +			return data;
> +	}
>  	return vmalloc(size);
>  }
>  
> _
> 

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

#define PAGE_ALLOC_COSTLY_ORDER 3

On x86_64, this means we try kmalloc() up to 4096 files in fdtable.

Thanks !


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
