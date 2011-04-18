Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7814E900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 23:05:32 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p3I35NiF029841
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:05:24 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by wpaz24.hot.corp.google.com with ESMTP id p3I35LO9008261
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:05:22 -0700
Received: by pvg11 with SMTP id 11so3105307pvg.27
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:05:16 -0700 (PDT)
Date: Sun, 17 Apr 2011 20:05:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH]mmap: avoid unnecessary anon_vma lock
In-Reply-To: <1301277532.3981.25.camel@sli10-conroe>
Message-ID: <alpine.LSU.2.00.1104172003330.22756@sister.anvils>
References: <1301277532.3981.25.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Mon, 28 Mar 2011, Shaohua Li wrote:

> If we only change vma->vm_end, we can avoid taking anon_vma lock even 'insert'
> isn't NULL, which is the case of split_vma.
> From my understanding, we need the lock before because rmap must get the
> 'insert' VMA when we adjust old VMA's vm_end (the 'insert' VMA is linked to
> anon_vma list in __insert_vm_struct before).
> But now this isn't true any more. The 'insert' VMA is already linked to
> anon_vma list in __split_vma(with anon_vma_clone()) instead of
> __insert_vm_struct. There is no race rmap can't get required VMAs.
> So the anon_vma lock is unnecessary, and this can reduce one locking in brk
> case and improve scalability.
> 
> Signed-off-by: Shaohua Li<shaohua.li@intel.com>

I was sceptical at first, but yes, you're right: thanks.
Acked-by: Hugh Dickins <hughd@google.com>

> 
> ---
>  mm/mmap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux/mm/mmap.c
> ===================================================================
> --- linux.orig/mm/mmap.c	2011-03-24 09:08:27.000000000 +0800
> +++ linux/mm/mmap.c	2011-03-24 09:14:03.000000000 +0800
> @@ -605,7 +605,7 @@ again:			remove_next = 1 + (end > next->
>  	 * lock may be shared between many sibling processes.  Skipping
>  	 * the lock for brk adjustments makes a difference sometimes.
>  	 */
> -	if (vma->anon_vma && (insert || importer || start != vma->vm_start)) {
> +	if (vma->anon_vma && (importer || start != vma->vm_start)) {
>  		anon_vma = vma->anon_vma;
>  		anon_vma_lock(anon_vma);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
