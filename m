Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6758C6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:17:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so73183008pfb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:17:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o9si329777pge.380.2017.02.17.12.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:17:39 -0800 (PST)
Date: Fri, 17 Feb 2017 12:17:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-Id: <20170217121738.f5b2e24474021f38fdb72845@linux-foundation.org>
In-Reply-To: <20170217155241.GT25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
	<20170216184100.GS25530@redhat.com>
	<c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
	<20170217155241.GT25530@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, 17 Feb 2017 16:52:41 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> Everything else is identical which is great. Mike Rapoport could you
> verify the below hunk is missing in mm?
> 
> Once it'll all be merged upstream then there will be less merge crunch
> as we've been working somewhat in parallel on the same files, so this
> is resulting in more merge rejects than ideal :).
> 
> diff --git a/../mm/mm/userfaultfd.c b/mm/userfaultfd.c
> index 830bed7..3ec9aad 100644
> --- a/../mm/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -199,6 +201,12 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  		dst_vma = find_vma(dst_mm, dst_start);
>  		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
>  			goto out_unlock;
> +		/*
> +		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
> +		 * registered ranges.
> +		 */
> +		if (!dst_vma->vm_userfaultfd_ctx.ctx)
> +			goto out_unlock;
>  
>  		if (dst_start < dst_vma->vm_start ||
>  		    dst_start + len > dst_vma->vm_end)
> @@ -214,16 +224,10 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  		goto out_unlock;
>  
>  	/*
> -	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
> -	 */
> -	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> -		goto out_unlock;
> -
> -	/*
>  	 * If not shared, ensure the dst_vma has a anon_vma.
>  	 */

I merged this up and a small issue remains:


:	/*
:	 * Validate alignment based on huge page size
:	 */
:	err = -EINVAL;
:	if (dst_start & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
:		goto out_unlock;
:
:retry:
:	/*
:	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
:	 * retry, dst_vma will be set to NULL and we must lookup again.
:	 */
:	if (!dst_vma) {
:		err = -ENOENT;
:		dst_vma = find_vma(dst_mm, dst_start);
:		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
:			goto out_unlock;
:		/*
:		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
:		 * registered ranges.
:		 */
:		if (!dst_vma->vm_userfaultfd_ctx.ctx)
:			goto out_unlock;
:
:		if (dst_start < dst_vma->vm_start ||
:		    dst_start + len > dst_vma->vm_end)
:			goto out_unlock;
:
:		err = -EINVAL;
:		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
:			goto out_unlock;
:	}
:
:	if (WARN_ON(dst_addr & (vma_hpagesize - 1) ||
:		    (len - copied) & (vma_hpagesize - 1)))
:		goto out_unlock;

The value of `err' here is EINVAL.  That sems appropriate, but it only
happens by sheer luck.

:	/*
:	 * If not shared, ensure the dst_vma has a anon_vma.
:	 */
:	err = -ENOMEM;
:	if (!(dst_vma->vm_flags & VM_SHARED)) {
:		if (unlikely(anon_vma_prepare(dst_vma)))
:			goto out_unlock;
:	}

So...

--- a/mm/userfaultfd.c~userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found-fix-2-fix
+++ a/mm/userfaultfd.c
@@ -215,6 +215,7 @@ retry:
 			goto out_unlock;
 	}
 
+	err = -EINVAL;
 	if (WARN_ON(dst_addr & (vma_hpagesize - 1) ||
 		    (len - copied) & (vma_hpagesize - 1)))
 		goto out_unlock;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
