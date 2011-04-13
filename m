Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8332C900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:44:26 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3DLiKbT001167
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:44:20 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz17.hot.corp.google.com with ESMTP id p3DLi3Th016728
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:44:19 -0700
Received: by pwj3 with SMTP id 3so829378pwj.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:44:18 -0700 (PDT)
Date: Wed, 13 Apr 2011 14:44:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Regression from 2.6.36
In-Reply-To: <20110413141600.28793661.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1104131432460.10702@chino.kir.corp.google.com>
References: <20110315132527.130FB80018F1@mail1005.cent> <20110317001519.GB18911@kroah.com> <20110407120112.E08DCA03@pobox.sk> <4D9D8FAA.9080405@suse.cz> <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com> <1302177428.3357.25.camel@edumazet-laptop>
 <1302178426.3357.34.camel@edumazet-laptop> <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com> <1302190586.3357.45.camel@edumazet-laptop> <20110412154906.70829d60.akpm@linux-foundation.org> <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
 <20110412183132.a854bffc.akpm@linux-foundation.org> <1302662256.2811.27.camel@edumazet-laptop> <20110413141600.28793661.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Wed, 13 Apr 2011, Andrew Morton wrote:

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

It's a shame that we can't at least try kmalloc() with sufficiently large 
sizes by doing something like

	gfp_t flags = GFP_NOWAIT | __GFP_NOWARN;

	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
		flags |= GFP_KERNEL;
	data = kmalloc(size, flags);
	if (data)
		return data;
	return vmalloc(size);

which would at least attempt to use the slab allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
