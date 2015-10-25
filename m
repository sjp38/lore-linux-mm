Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6F36B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 19:41:58 -0400 (EDT)
Received: by obctp1 with SMTP id tp1so102927201obc.2
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:41:58 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id e141si19003834oig.125.2015.10.25.16.41.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 16:41:57 -0700 (PDT)
Received: by oifu63 with SMTP id u63so49029059oif.2
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:41:57 -0700 (PDT)
Date: Sun, 25 Oct 2015 16:41:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/6] ksm: add cond_resched() to the rmap_walks
In-Reply-To: <1444925065-4841-3-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251634410.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> While at it add it to the file and anon walks too.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Subject really should be "mm: add cond_resched() to the rmap walks",
then body "Add cond_resched() to the ksm and anon and file rmap walks."

Acked-by: Hugh Dickins <hughd@google.com>
but I think we need a blessing from Davidlohr too, if not more.

> ---
>  mm/ksm.c  | 2 ++
>  mm/rmap.c | 4 ++++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 8fc6793..39ef485 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1961,9 +1961,11 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> +		cond_resched();
>  		anon_vma_lock_read(anon_vma);
>  		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
>  					       0, ULONG_MAX) {
> +			cond_resched();
>  			vma = vmac->vma;
>  			if (rmap_item->address < vma->vm_start ||
>  			    rmap_item->address >= vma->vm_end)
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f5b5c1f..b949778 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1607,6 +1607,8 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
>  		struct vm_area_struct *vma = avc->vma;
>  		unsigned long address = vma_address(page, vma);
>  
> +		cond_resched();
> +
>  		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
>  			continue;
>  
> @@ -1656,6 +1658,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address = vma_address(page, vma);
>  
> +		cond_resched();
> +
>  		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
>  			continue;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
