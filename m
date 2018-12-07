Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF40B6B7E0B
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 22:43:54 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w18so2510554qts.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 19:43:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34si1428571qvs.160.2018.12.06.19.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 19:43:54 -0800 (PST)
Date: Fri, 7 Dec 2018 11:43:45 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: check VM_MAYWRITE was set after
 verifying the uffd is registered
Message-ID: <20181207034345.GC10726@xz-x1>
References: <20181206212028.18726-1-aarcange@redhat.com>
 <20181206212028.18726-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181206212028.18726-2-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Thu, Dec 06, 2018 at 04:20:28PM -0500, Andrea Arcangeli wrote:
> Calling UFFDIO_UNREGISTER on virtual ranges not yet registered in uffd
> could trigger an harmless false positive WARN_ON. Check the vma is
> already registered before checking VM_MAYWRITE to shut off the
> false positive warning.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 29ec90660d68 ("userfaultfd: shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas")
> Reported-by: syzbot+06c7092e7d71218a2c16@syzkaller.appspotmail.com
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/userfaultfd.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cd58939dc977..7a85e609fc27 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1566,7 +1566,6 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		cond_resched();
>  
>  		BUG_ON(!vma_can_userfault(vma));
> -		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
>  
>  		/*
>  		 * Nothing to do: this vma is already registered into this

Maybe we want to fix this comment too some day:

		/*
		 * Nothing to do: this vma is already registered into this
		 * userfaultfd and with the right tracking mode too.
		 */

But I don't think it's anything urgent since it's clear it means the
other way round and it can potentially be touched up in any further
cleanup/fixes of uffd.

Acked-by: Peter Xu <peterx@redhat.com>

> @@ -1575,6 +1574,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		if (!vma->vm_userfaultfd_ctx.ctx)
>  			goto skip;
>  
> +		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> +
>  		if (vma->vm_start > start)
>  			start = vma->vm_start;
>  		vma_end = min(end, vma->vm_end);

Thanks,

-- 
Peter Xu
