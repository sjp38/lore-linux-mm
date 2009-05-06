Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 061BA6B005D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 02:36:10 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n466afda024067
	for <linux-mm@kvack.org>; Wed, 6 May 2009 07:36:42 +0100
Received: from wa-out-1112.google.com (wafk17.prod.google.com [10.114.187.17])
	by wpaz24.hot.corp.google.com with ESMTP id n466ad2b018081
	for <linux-mm@kvack.org>; Tue, 5 May 2009 23:36:40 -0700
Received: by wa-out-1112.google.com with SMTP id k17so2585782waf.15
        for <linux-mm@kvack.org>; Tue, 05 May 2009 23:36:39 -0700 (PDT)
Date: Tue, 5 May 2009 23:36:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mmotm] mm: init_per_zone_pages_min - get rid of sqrt
 call on small machines
In-Reply-To: <20090506061953.GA16057@lenovo>
Message-ID: <alpine.DEB.2.00.0905052334391.9824@chino.kir.corp.google.com>
References: <20090506061953.GA16057@lenovo>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Cyrill Gorcunov wrote:

> Index: linux-2.6.git/mm/page_alloc.c
> =====================================================================
> --- linux-2.6.git.orig/mm/page_alloc.c
> +++ linux-2.6.git/mm/page_alloc.c
> @@ -4610,11 +4610,15 @@ static int __init init_per_zone_pages_mi
>  
>  	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
>  
> -	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
> -	if (min_free_kbytes < 128)
> +	/* for small values we may eliminate sqrt operation completely */
> +	if (lowmem_kbytes < 1024)
>  		min_free_kbytes = 128;
> -	if (min_free_kbytes > 65536)
> -		min_free_kbytes = 65536;
> +	else {
> +		min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
> +		if (min_free_kbytes > 65536)
> +			min_free_kbytes = 65536;
> +	}
> +
>  	setup_per_zone_pages_min();
>  	setup_per_zone_lowmem_reserve();
>  	setup_per_zone_inactive_ratio();

For a function that's called once, this just isn't worth it.  int_sqrt() 
isn't expensive enough to warrant the assault on the readability of the 
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
