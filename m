Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 47F096B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:06:44 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:06:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: use free_page instead of put_page for freeing
 kmalloc allocation
In-Reply-To: <1343913065-14631-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020902390.23049@router.home>
References: <1343913065-14631-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index e517d43..9ca4e20 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3453,7 +3453,7 @@ void kfree(const void *x)
>  	if (unlikely(!PageSlab(page))) {
>  		BUG_ON(!PageCompound(page));
>  		kmemleak_free(x);
> -		put_page(page);
> +		__free_pages(page, compound_order(page));

Hmmm... put_page would have called put_compound_page(). which would have
called the dtor function. dtor is set to __free_pages() ok which does
mlock checks and verifies that the page is in a proper condition for
freeing. Then it calls free_one_page().

__free_pages() decrements the refcount and then calls __free_pages_ok().

So we loose the checking and the dtor stuff with this patch. Guess that is
ok?

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
