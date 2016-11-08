Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76C896B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 04:53:56 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so57494365wms.7
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 01:53:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kj10si34467279wjc.263.2016.11.08.01.53.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 01:53:54 -0800 (PST)
Date: Tue, 8 Nov 2016 10:53:52 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161108095352.GH32353@quack2.suse.cz>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107190741.3619-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 07-11-16 14:07:36, Johannes Weiner wrote:
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
> ---
>  mm/khugepaged.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 728d7790dc2d..eac6f0580e26 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1520,7 +1520,8 @@ static void collapse_shmem(struct mm_struct *mm,
>  				if (!nr_none)
>  					break;
>  				/* Put holes back where they were */
> -				radix_tree_replace_slot(slot, NULL);
> +				radix_tree_delete(&mapping->page_tree,
> +						  iter.index);

Hum, but this is inside radix_tree_for_each_slot() iteration. And
radix_tree_delete() may end up freeing nodes resulting in invalidating
current slot pointer and the iteration code will do use-after-free.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
