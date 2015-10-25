Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7D15B6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 19:21:27 -0400 (EDT)
Received: by pabuq3 with SMTP id uq3so3582487pab.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:21:27 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id qx6si4456008pab.180.2015.10.25.16.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 16:21:26 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so168595269pad.1
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:21:26 -0700 (PDT)
Date: Sun, 25 Oct 2015 16:21:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/6] ksm: use find_mergeable_vma in
 try_to_merge_with_ksm_page
In-Reply-To: <1444925065-4841-6-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251618240.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> Doing the VM_MERGEABLE check after the page == kpage check won't
> provide any meaningful benefit. The !vma->anon_vma check of
> find_mergeable_vma is the only superfluous bit in using
> find_mergeable_vma because the !PageAnon check of
> try_to_merge_one_page() implicitly checks for that, but it still looks
> cleaner to share the same find_mergeable_vma().
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

This looks like a nice little cleanup; I'm not 100% sure of it, forked
pages always awkward here; but you're clearly more in touch with this
now than I am, and I've seen no problem from it, so let's go with this.

> ---
>  mm/ksm.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 241588e..10618a3 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1057,8 +1057,6 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
>  	if (page == kpage)			/* ksm page forked */
>  		return 0;
>  
> -	if (!(vma->vm_flags & VM_MERGEABLE))
> -		goto out;
>  	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
>  		goto out;
>  	BUG_ON(PageTransCompound(page));
> @@ -1135,8 +1133,8 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  		return err;
>  
>  	down_read(&mm->mmap_sem);
> -	vma = find_vma(mm, rmap_item->address);
> -	if (!vma || vma->vm_start > rmap_item->address)
> +	vma = find_mergeable_vma(mm, rmap_item->address);
> +	if (!vma)
>  		goto out;
>  
>  	err = try_to_merge_one_page(vma, page, kpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
