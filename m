Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 549106B03AB
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:30:31 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so7694638wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:30:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ma6si6377221wjb.88.2016.11.17.23.30.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 23:30:30 -0800 (PST)
Date: Fri, 18 Nov 2016 08:30:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161118073029.GB18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117191138.22769-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117191138.22769-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:11:31, Johannes Weiner wrote:
> The radix tree counts valid entries in each tree node. Entries stored
> in the tree cannot be removed by simpling storing NULL in the slot or
> the internal counters will be off and the node never gets freed again.
> 
> When collapsing a shmem page fails, restore the holes that were filled
> with radix_tree_insert() with a proper radix tree deletion.
> 
> Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Reported-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/khugepaged.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index bdfdab40a813..d553c294de40 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1523,9 +1523,11 @@ static void collapse_shmem(struct mm_struct *mm,
>  			if (!page || iter.index < page->index) {
>  				if (!nr_none)
>  					break;
> -				/* Put holes back where they were */
> -				radix_tree_replace_slot(slot, NULL);
>  				nr_none--;
> +				/* Put holes back where they were */
> +				radix_tree_delete(&mapping->page_tree,
> +						  iter.index);
> +				slot = radix_tree_iter_next(&iter);
>  				continue;
>  			}
>  
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
