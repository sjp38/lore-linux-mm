Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 166C46B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:58:29 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so20173250wiv.14
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:58:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si35162670wiz.67.2014.12.02.00.58.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:58:27 -0800 (PST)
Date: Tue, 2 Dec 2014 09:58:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 2/3] mm: memory: remove ->vm_file check on shared
 writable vmas
Message-ID: <20141202085825.GA9092@quack.suse.cz>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 01-12-14 17:58:01, Johannes Weiner wrote:
> The only way a VMA can have shared and writable semantics is with a
> backing file.
  OK, one always learns :) After some digging I found that MAP_SHARED |
MAP_ANONYMOUS mappings are in fact mappings of a temporary file in tmpfs.
It would be worth to mention this in the changelog I believe. Otherwise
feel free to add:
  Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memory.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 73220eb6e9e3..2a2e3648ed65 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2167,9 +2167,7 @@ reuse:
>  				balance_dirty_pages_ratelimited(mapping);
>  			}
>  
> -			/* file_update_time outside page_lock */
> -			if (vma->vm_file)
> -				file_update_time(vma->vm_file);
> +			file_update_time(vma->vm_file);
>  		}
>  		put_page(dirty_page);
>  		if (page_mkwrite) {
> @@ -3025,8 +3023,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		balance_dirty_pages_ratelimited(mapping);
>  	}
>  
> -	/* file_update_time outside page_lock */
> -	if (vma->vm_file && !vma->vm_ops->page_mkwrite)
> +	if (!vma->vm_ops->page_mkwrite)
>  		file_update_time(vma->vm_file);
>  
>  	return ret;
> -- 
> 2.1.3
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
