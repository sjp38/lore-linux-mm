Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB88E6B7C68
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:33:05 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so1393120pfb.17
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:33:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 26si1090431pgu.190.2018.12.06.13.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:33:04 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB6LVonr134679
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 16:33:02 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p78cgsmh3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:32:55 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 21:32:20 -0000
Date: Thu, 6 Dec 2018 23:32:12 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 1/1] userfaultfd: check VM_MAYWRITE was set after
 verifying the uffd is registered
References: <20181206212028.18726-1-aarcange@redhat.com>
 <20181206212028.18726-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206212028.18726-2-aarcange@redhat.com>
Message-Id: <20181206213212.GB7479@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

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

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

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

-- 
Sincerely yours,
Mike.
