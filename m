Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 458846B00EA
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 12:51:36 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so4676043pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 09:51:35 -0800 (PST)
Date: Sun, 4 Mar 2012 09:51:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: shmem: unlock valid page
In-Reply-To: <CAJd=RBBYdY1rgoW+0bgKh6Cn8n=guB2_zq2nzaMr8-arqNkr_A@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1203040943240.18498@eggly.anvils>
References: <CAJd=RBBYdY1rgoW+0bgKh6Cn8n=guB2_zq2nzaMr8-arqNkr_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 4 Mar 2012, Hillf Danton wrote:
> In shmem_read_mapping_page_gfp() page is unlocked if no error returned,
> so the unlocked page has to valid.
> 
> To guarantee that validity, when getting page, success result is feed
> back to caller only when page is valid.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

I don't understand your description, nor its relation to the patch.

NAK to the patch: when no page has previously been allocated, the
SGP_READ case avoids allocation and returns NULL - do_shmem_file_read
then copies the ZERO_PAGE instead, avoiding lots of unnecessary memory
allocation when reading a large sparse file.

Hugh

> ---
> 
> --- a/mm/shmem.c	Sun Mar  4 12:17:42 2012
> +++ b/mm/shmem.c	Sun Mar  4 12:26:56 2012
> @@ -889,13 +889,13 @@ repeat:
>  		goto failed;
>  	}
> 
> -	if (page || (sgp == SGP_READ && !swap.val)) {
> +	if (page) {
>  		/*
>  		 * Once we can get the page lock, it must be uptodate:
>  		 * if there were an error in reading back from swap,
>  		 * the page would not be inserted into the filecache.
>  		 */
> -		BUG_ON(page && !PageUptodate(page));
> +		BUG_ON(!PageUptodate(page));
>  		*pagep = page;
>  		return 0;
>  	}
> --
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
