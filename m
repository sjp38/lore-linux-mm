Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9917E6B00DF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 01:08:35 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so13862722pad.3
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 22:08:35 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id xk1si17171118pab.121.2014.11.03.22.08.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 22:08:34 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so13750167pab.14
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 22:08:33 -0800 (PST)
Date: Mon, 3 Nov 2014 22:08:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mremap: take anon_vma lock in shared mode
In-Reply-To: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1411032204420.15596@eggly.anvils>
References: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, walken@google.com, aarcange@redhat.com, linux-mm@kvack.org

On Tue, 28 Oct 2014, Kirill A. Shutemov wrote:

> There's no modification to anon_vma interval tree. We only need to
> serialize against exclusive rmap walker who want s to catch all ptes the
> page is mapped with. Shared lock is enough for that.
> 
> Suggested-by: Davidlohr Bueso <dbueso@suse.de>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

NAK: please read Michel's comment on need_rmap_locks again, there is
no point in using read locks on anon_vma (and i_mmap) here, those will
not exclude the read locks on anon_vma (and i_mmap) in the rmap walk,
while we move ptes around.

Or am I confused?

Hugh

> ---
>  mm/mremap.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index c855922497a3..1e35ba664406 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -123,7 +123,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  		}
>  		if (vma->anon_vma) {
>  			anon_vma = vma->anon_vma;
> -			anon_vma_lock_write(anon_vma);
> +			anon_vma_lock_read(anon_vma);
>  		}
>  	}
>  
> @@ -154,7 +154,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  	pte_unmap(new_pte - 1);
>  	pte_unmap_unlock(old_pte - 1, old_ptl);
>  	if (anon_vma)
> -		anon_vma_unlock_write(anon_vma);
> +		anon_vma_unlock_read(anon_vma);
>  	if (mapping)
>  		mutex_unlock(&mapping->i_mmap_mutex);
>  }
> @@ -199,12 +199,12 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  					      vma);
>  				/* See comment in move_ptes() */
>  				if (need_rmap_locks)
> -					anon_vma_lock_write(vma->anon_vma);
> +					anon_vma_lock_read(vma->anon_vma);
>  				err = move_huge_pmd(vma, new_vma, old_addr,
>  						    new_addr, old_end,
>  						    old_pmd, new_pmd);
>  				if (need_rmap_locks)
> -					anon_vma_unlock_write(vma->anon_vma);
> +					anon_vma_unlock_read(vma->anon_vma);
>  			}
>  			if (err > 0) {
>  				need_flush = true;
> -- 
> 2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
