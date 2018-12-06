Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2CD96B7C95
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:08:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so1479908pfk.12
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:08:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n85sor2900687pfb.16.2018.12.06.14.08.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 14:08:01 -0800 (PST)
Date: Thu, 6 Dec 2018 14:07:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] userfaultfd: check VM_MAYWRITE was set after verifying
 the uffd is registered
In-Reply-To: <20181206212028.18726-2-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1812061406300.1616@eggly.anvils>
References: <20181206212028.18726-1-aarcange@redhat.com> <20181206212028.18726-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Thu, 6 Dec 2018, Andrea Arcangeli wrote:

> Calling UFFDIO_UNREGISTER on virtual ranges not yet registered in uffd
> could trigger an harmless false positive WARN_ON. Check the vma is
> already registered before checking VM_MAYWRITE to shut off the
> false positive warning.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 29ec90660d68 ("userfaultfd: shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas")
> Reported-by: syzbot+06c7092e7d71218a2c16@syzkaller.appspotmail.com
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

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
> @@ -1575,6 +1574,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		if (!vma->vm_userfaultfd_ctx.ctx)
>  			goto skip;
>  
> +		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> +
>  		if (vma->vm_start > start)
>  			start = vma->vm_start;
>  		vma_end = min(end, vma->vm_end);
> 
