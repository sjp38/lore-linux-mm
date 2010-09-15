Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F36416B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:49:19 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o8FJnGNE016786
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:49:16 -0700
Received: from yxj4 (yxj4.prod.google.com [10.190.3.68])
	by kpbe11.cbf.corp.google.com with ESMTP id o8FJnEE6025895
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:49:14 -0700
Received: by yxj4 with SMTP id 4so239034yxj.10
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:49:14 -0700 (PDT)
Date: Wed, 15 Sep 2010 12:49:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix rmap walk during fork
In-Reply-To: <20100915171657.GP5981@random.random>
Message-ID: <alpine.DEB.2.00.1009151247390.2604@tigran.mtv.corp.google.com>
References: <20100915171657.GP5981@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010, Andrea Arcangeli wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The below bug in fork lead to the rmap walk finding the parent huge-pmd twice
> instead of just one, because the anon_vma_chain objects of the child vma still
> point to the vma->vm_mm of the parent. The below patch fixes it by making the
> rmap walk accurate during fork. It's not a big deal normally but it
> worth being accurate considering the cost is the same.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -360,10 +360,10 @@ static int dup_mmap(struct mm_struct *mm
>  		if (IS_ERR(pol))
>  			goto fail_nomem_policy;
>  		vma_set_policy(tmp, pol);
> +		tmp->vm_mm = mm;
>  		if (anon_vma_fork(tmp, mpnt))
>  			goto fail_nomem_anon_vma_fork;
>  		tmp->vm_flags &= ~VM_LOCKED;
> -		tmp->vm_mm = mm;
>  		tmp->vm_next = tmp->vm_prev = NULL;
>  		file = tmp->vm_file;
>  		if (file) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
