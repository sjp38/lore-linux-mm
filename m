Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8CC6B01B0
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 10:29:42 -0400 (EDT)
Date: Mon, 5 Jul 2010 16:28:11 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] slob: Get lock before getting slob_list
Message-ID: <20100705142811.GB1493@cmpxchg.org>
References: <1278334297-6952-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278334297-6952-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Mon, Jul 05, 2010 at 08:51:37PM +0800, Bob Liu wrote:
> If get lock after getting slob_list, the partially free page list maybe
> changed before list_for_each_entry().

Nodes of the lists may, but not the addresses of the static list
heads!  The locking is fine as it is.

> And maybe trigger a NULL pointer access Bug like this:

[snip]

There is something else going on.  It might be a good idea to see if
this bug is reproducible on an upstream kernel and not some random svn
checkout from who knows where.

> diff --git a/mm/slob.c b/mm/slob.c
> index 3f19a34..c391f55 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -326,6 +326,8 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  	slob_t *b = NULL;
>  	unsigned long flags;
>  
> +	spin_lock_irqsave(&slob_lock, flags);
> +
>  	if (size < SLOB_BREAK1)
>  		slob_list = &free_slob_small;
>  	else if (size < SLOB_BREAK2)
> @@ -333,7 +335,6 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  	else
>  		slob_list = &free_slob_large;
>  
> -	spin_lock_irqsave(&slob_lock, flags);
>  	/* Iterate through each partially free page, try to find room */
>  	list_for_each_entry(sp, slob_list, list) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
