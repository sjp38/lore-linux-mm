Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3150D6B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:45:42 -0400 (EDT)
Message-ID: <51F6F087.9060109@linux.intel.com>
Date: Mon, 29 Jul 2013 15:45:27 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
In-Reply-To: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeungHun Lee <waydi1@gmail.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, xinxing2zhou@gmail.com

On 07/28/2013 07:48 AM, SeungHun Lee wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b8475ed..e644cf5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2408,7 +2408,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * be using allocators in order of preference for an area that is
>  	 * too large.
>  	 */
> -	if (order >= MAX_ORDER) {
> +	if (unlikely(order >= MAX_ORDER)) {
>  		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>  		return NULL;
>  	}

What problem is this patch solving?  I can see doing this in hot paths,
or places where the compiler is known to be generating bad or suboptimal
code.  but, this costs me 512 bytes of text size:

 898384 Jul 29 15:40 mm/page_alloc.o.nothing
 898896 Jul 29 15:40 mm/page_alloc.o.unlikely

I really don't think we should be adding these without having _concrete_
reasons for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
