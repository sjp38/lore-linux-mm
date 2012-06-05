Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 0908E6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 18:56:02 -0400 (EDT)
Date: Tue, 5 Jun 2012 15:56:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Make vb_alloc() more foolproof
Message-Id: <20120605155601.738bde7c.akpm@linux-foundation.org>
In-Reply-To: <1338936056-4092-1-git-send-email-jack@suse.cz>
References: <1338936056-4092-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org

On Wed,  6 Jun 2012 00:40:56 +0200
Jan Kara <jack@suse.cz> wrote:

> If someone calls vb_alloc() (or vm_map_ram() for that matter) to allocate
> 0 bytes (0 pages), get_order() returns BITS_PER_LONG - PAGE_CACHE_SHIFT
> and interesting stuff happens. So make debugging such problems easier and
> warn about 0-size allocation.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/vmalloc.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 2aad499..bebee70 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -904,6 +904,15 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
>  
>  	BUG_ON(size & ~PAGE_MASK);
>  	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
> +	if (size == 0) {
> +		/*
> +		 * Allocating 0 bytes isn't what caller wants since
> +		 * get_order(0) returns funny result. Just warn and terminate
> +		 * early.
> +		 */
> +		WARN_ON(1);
> +		return NULL;
> +	}
>  	order = get_order(size);

Spose so.  You got bitten, I assume ;)

We can neaten the implementation:

--- a/mm/vmalloc.c~mm-make-vb_alloc-more-foolproof-fix
+++ a/mm/vmalloc.c
@@ -904,13 +904,12 @@ static void *vb_alloc(unsigned long size
 
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
-	if (size == 0) {
+	if (WARN_ON(size == 0)) {
 		/*
 		 * Allocating 0 bytes isn't what caller wants since
 		 * get_order(0) returns funny result. Just warn and terminate
 		 * early.
 		 */
-		WARN_ON(1);
 		return NULL;
 	}
 	order = get_order(size);

and that gives us the unlikely() hit too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
