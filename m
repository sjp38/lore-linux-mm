Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 820DE8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:51:28 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id l131so7912837pga.2
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:51:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f38si9866528pgf.206.2018.12.10.09.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 09:51:27 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBAHnbka012445
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:51:26 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p9uhccgnk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:51:26 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 10 Dec 2018 17:51:23 -0000
Date: Mon, 10 Dec 2018 19:51:16 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] userfaultfd: clear flag if remap event not enabled
References: <20181210065121.14984-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210065121.14984-1-peterx@redhat.com>
Message-Id: <20181210175115.GB6380@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Pravin Shedge <pravin.shedge4linux@gmail.com>, linux-mm@kvack.org

On Mon, Dec 10, 2018 at 02:51:21PM +0800, Peter Xu wrote:
> When the process being tracked do mremap() without
> UFFD_FEATURE_EVENT_REMAP on the corresponding tracking uffd file
> handle, we should not generate the remap event, and at the same
> time we should clear all the uffd flags on the new VMA.  Without
> this patch, we can still have the VM_UFFD_MISSING|VM_UFFD_WP
> flags on the new VMA even the fault handling process does not
> even know the existance of the VMA.
> 
> CC: Andrea Arcangeli <aarcange@redhat.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
> CC: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Hugh Dickins <hughd@google.com>
> CC: Pavel Emelyanov <xemul@virtuozzo.com>
> CC: Pravin Shedge <pravin.shedge4linux@gmail.com>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cd58939dc977..798ae8a438ff 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -740,6 +740,9 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
>  		vm_ctx->ctx = ctx;
>  		userfaultfd_ctx_get(ctx);
>  		WRITE_ONCE(ctx->mmap_changing, true);
> +	} else if (ctx) {
> +		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> +		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);

My preference would be 

	if (!ctx)
		return;
	
	if (ctx->features & UFFD_FEATURE_EVENT_REMAP) {
		...
	} else {
		...
	}

but I don't feel strongly about it.

I'd appreciate a comment in the code and with it 

Acked-by: Mike Rapoport <rppt@linux.ibm.com>


>  	}
>  }
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
