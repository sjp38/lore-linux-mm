Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 85D8C6B00D1
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 16:25:31 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o29LPSI3027105
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 13:25:28 -0800
Received: from fxm2 (fxm2.prod.google.com [10.184.13.2])
	by spaceape13.eur.corp.google.com with ESMTP id o29LPRh3019319
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 13:25:27 -0800
Received: by fxm2 with SMTP id 2so1190577fxm.36
        for <linux-mm@kvack.org>; Tue, 09 Mar 2010 13:25:26 -0800 (PST)
Date: Tue, 9 Mar 2010 21:25:12 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] shmem : remove redundant code
In-Reply-To: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
Message-ID: <alpine.LSU.2.00.1003092123520.22884@sister.anvils>
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010, Huang Shijie wrote:

> The  prep_new_page() will call set_page_private(page, 0) to initiate
> the page.
> 
> So the code is redundant.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I didn't feel too enthusiastic at first, since private used not to be initialized
by page allocation, and I don't know of a strong reason why it should be: we do
strongly demand that page->mapping be NULL on allocation, but we leave page->index
with whatever it already contains, and I had thought page->_private the same.

But it seems we have been initializing private to 0 for nearly seven years now,
and it was done intentionally for something (XFS) to depend upon, so yes,
let's rely on that here too - thanks.

Hugh

> ---
>  mm/shmem.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index eef4ebe..dde4363 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -433,8 +433,6 @@ static swp_entry_t *shmem_swp_alloc(struct shmem_inode_info *info, unsigned long
>  
>  		spin_unlock(&info->lock);
>  		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
> -		if (page)
> -			set_page_private(page, 0);
>  		spin_lock(&info->lock);
>  
>  		if (!page) {
> -- 
> 1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
