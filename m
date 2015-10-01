Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 878FB6B027A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 23:01:52 -0400 (EDT)
Received: by igxx6 with SMTP id x6so5491117igx.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:01:52 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id x4si536866igr.34.2015.09.30.20.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 20:01:51 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so59343281pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:01:51 -0700 (PDT)
Date: Wed, 30 Sep 2015 20:01:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: fix the racy mm->locked_vm change in
In-Reply-To: <20150929182756.GA21740@redhat.com>
Message-ID: <alpine.LSU.2.11.1509301911320.4528@eggly.anvils>
References: <20150929182756.GA21740@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 29 Sep 2015, Oleg Nesterov wrote:

> "mm->locked_vm += grow" and vm_stat_account() in acct_stack_growth()
> are not safe; multiple threads using the same ->mm can do this at the
> same time trying to expans different vma's under down_read(mmap_sem).
                      expand
> This means that one of the "locked_vm += grow" changes can be lost
> and we can miss munlock_vma_pages_all() later.

>From the Cc list, I guess you are thinking this might be the fix to
the "Bad state page (mlocked)" issues Andrey and Sasha have reported.

I've not been able to explain those from the direction in which
I was thinking (despite giving it more hours of thought meanwhile),
so I am glad you're looking at it from a very different direction,
and hope you're right with this.

> 
> Move this code into the caller(s) under mm->page_table_lock. All other
> updates to ->locked_vm hold mmap_sem for writing.

So it looks like Andrea and I broke this back in v2.6.7: page_table_lock
was used here before then, and we thought the anon_vma lock was better.

Confession: from that time until today, I thought MAP_GROWSDOWN was
one of those flags (say, like MAP_DENYWRITE) which the kernel accepts
from userspace but ignores; I thought ia64 was the only architecture
on which an mm might contain more than one VM_GROWS* vma (excepting
the case where the original gets split; but surely stack would have
its anon_vma allocated by then, and shared across the split).  It's
only this patch of yours that leads me to calc_vm_flag_bits(), and
to how Michel brought page_table_lock back here to guard vma_gap.

> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

with some hesitation.  I don't like very much that the preliminary
mm->locked_vm + grow check is still done without complete locking,
so racing threads could get more locked_vm than they're permitted;
but I'm not sure that we care enough to put page_table_lock back
over all of that (and security_vm_enough_memory wants to have final
say on whether to go ahead); even if it was that way years ago.

(And if we did care, shouldn't __vm_enough_memory() be using
percpu_counter_compare instead of percpu_counter_read_positive?
but that's a digression.)

It would be even nicer if we could kill these expand_stack()
anomalies once and for all, with down_write of mmap_sem here too.
But can't be done without revisiting every architecture's mm/fault.c,
which I have no stomach for at this time, and probably you neither.

Let's accept that your patch is a significant improvement,
and hope that it fixes the "Bad page state (mlocked)".

> ---
>  mm/mmap.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8393580..4efdc37 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2138,10 +2138,6 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
>  	if (security_vm_enough_memory_mm(mm, grow))
>  		return -ENOMEM;
>  
> -	/* Ok, everything looks good - let it rip */
> -	if (vma->vm_flags & VM_LOCKED)
> -		mm->locked_vm += grow;
> -	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
>  	return 0;
>  }
>  
> @@ -2202,6 +2198,10 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  				 * against concurrent vma expansions.
>  				 */
>  				spin_lock(&vma->vm_mm->page_table_lock);
> +				if (vma->vm_flags & VM_LOCKED)
> +					vma->vm_mm->locked_vm += grow;
> +				vm_stat_account(vma->vm_mm, vma->vm_flags,
> +						vma->vm_file, grow);
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_end = address;
>  				anon_vma_interval_tree_post_update_vma(vma);
> @@ -2273,6 +2273,10 @@ int expand_downwards(struct vm_area_struct *vma,
>  				 * against concurrent vma expansions.
>  				 */
>  				spin_lock(&vma->vm_mm->page_table_lock);
> +				if (vma->vm_flags & VM_LOCKED)
> +					vma->vm_mm->locked_vm += grow;
> +				vm_stat_account(vma->vm_mm, vma->vm_flags,
> +						vma->vm_file, grow);
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_start = address;
>  				vma->vm_pgoff -= grow;
> -- 
> 2.4.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
