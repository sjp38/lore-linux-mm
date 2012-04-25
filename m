Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 411616B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:35:31 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so70988qcs.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 06:35:30 -0700 (PDT)
Message-ID: <4F97FD9D.9090105@vflare.org>
Date: Wed, 25 Apr 2012 09:35:25 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] zsmalloc: remove unnecessary type casting
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-6-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/25/2012 02:23 AM, Minchan Kim wrote:

> Let's remove unnecessary type casting of (void *).
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index b7d31cc..ff089f8 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -644,8 +644,7 @@ void zs_free(struct zs_pool *pool, void *obj)
>  	spin_lock(&class->lock);
>  
>  	/* Insert this object in containing zspage's freelist */
> -	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
> -							+ f_offset);
> +	link = (struct link_free *)(kmap_atomic(f_page)	+ f_offset);
>  	link->next = first_page->freelist;
>  	kunmap_atomic(link);
>  	first_page->freelist = obj;



Incrementing a void pointer looks weired and should not be allowed by C
compilers though gcc and clang seem to allow this without any warnings.
(fortunately C++ forbids incrementing void pointers)

So, we should keep this cast to unsigned char pointer to avoid relying
on a non-standard, compiler specific behavior.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
