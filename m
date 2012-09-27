Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 603E06B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 07:35:32 -0400 (EDT)
Message-ID: <1348745730.1512.19.camel@x61.thuisdomein>
Subject: Re: [PATCH -v2] mm: frontswap: fix a wrong if condition in
 frontswap_shrink
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 27 Sep 2012 13:35:30 +0200
In-Reply-To: <505C27FE.5080205@oracle.com>
References: <505C27FE.5080205@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhenzhong.duan@oracle.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, levinsasha928@gmail.com, Feng Jin <joe.jin@oracle.com>, dan.carpenter@oracle.com

On Fri, 2012-09-21 at 16:40 +0800, Zhenzhong Duan wrote:
> pages_to_unuse is set to 0 to unuse all frontswap pages
> But that doesn't happen since a wrong condition in frontswap_shrink
> cancel it.
> 
> -v2: Add comment to explain return value of __frontswap_shrink,
> as suggested by Dan Carpenter, thanks
> 
> Signed-off-by: Zhenzhong Duan <zhenzhong.duan@oracle.com>
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 6b3e71a..e38fc39 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -263,6 +263,11 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>  	return ret;
>  }
>  
> +/*
> + * Used to check if it's necessory and feasible to unuse pages.
> + * Return 1 when nothing to do, 0 when need to shink pages,
> + * error code when there is an error.
> + */
>  static int __frontswap_shrink(unsigned long target_pages,
>  				unsigned long *pages_to_unuse,
>  				int *type)
> @@ -275,7 +280,7 @@ static int __frontswap_shrink(unsigned long target_pages,
>  	if (total_pages <= target_pages) {
>  		/* Nothing to do */
>  		*pages_to_unuse = 0;

I think setting pages_to_unuse to zero here is not needed. It is
initiated to zero in frontswap_shrink() and hasn't been touched since.
See my patch at https://lkml.org/lkml/2012/9/27/250.

> -		return 0;
> +		return 1;
>  	}
>  	total_pages_to_unuse = total_pages - target_pages;
>  	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
> @@ -302,7 +307,7 @@ void frontswap_shrink(unsigned long target_pages)
>  	spin_lock(&swap_lock);
>  	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
>  	spin_unlock(&swap_lock);
> -	if (ret == 0 && pages_to_unuse)
> +	if (ret == 0)
>  		try_to_unuse(type, true, pages_to_unuse);
>  	return;
>  }

Are you sure pages_to_unuse won't be zero here? I've stared quite a bit
at __frontswap_unuse_pages() and it's not obvious pages_to_unuse (there
also called unused) will never be zero when that function returns zero.


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
