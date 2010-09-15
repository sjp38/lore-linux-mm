Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 350346B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:51:43 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o8FJpcGg015448
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:51:38 -0700
Received: from gwb20 (gwb20.prod.google.com [10.200.2.20])
	by hpaq3.eem.corp.google.com with ESMTP id o8FJpURn019910
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:51:36 -0700
Received: by gwb20 with SMTP id 20so189987gwb.3
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 12:51:36 -0700 (PDT)
Date: Wed, 15 Sep 2010 12:51:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] unlink_anon_vmas in __split_vma in case of error
In-Reply-To: <20100915171816.GQ5981@random.random>
Message-ID: <alpine.DEB.2.00.1009151249290.2604@tigran.mtv.corp.google.com>
References: <20100915171816.GQ5981@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010, Andrea Arcangeli wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If __split_vma fails because of an out of memory condition the
> anon_vma_chain isn't teardown and freed potentially leading to rmap
> walks accessing freed vma information plus there's a memleak.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

and I'm glad to see Andrew already added Cc: stable@kernel.org

> ---
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2014,6 +2014,7 @@ static int __split_vma(struct mm_struct 
>  			removed_exe_file_vma(mm);
>  		fput(new->vm_file);
>  	}
> +	unlink_anon_vmas(new);
>   out_free_mpol:
>  	mpol_put(pol);
>   out_free_vma:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
