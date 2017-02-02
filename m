Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0996B026C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 13:02:53 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h53so31056587qth.6
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 10:02:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si17331412qtf.58.2017.02.02.10.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 10:02:51 -0800 (PST)
Date: Thu, 2 Feb 2017 19:02:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 4/5] userfaultfd: mcopy_atomic: return -ENOENT when no
 compatible VMA found
Message-ID: <20170202180247.GA32446@redhat.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1485542673-24387-5-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485542673-24387-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 27, 2017 at 08:44:32PM +0200, Mike Rapoport wrote:
> -		err = -EINVAL;
> +		err = -ENOENT;
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
> +		err = -EINVAL;
>  		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
>  			goto out_unlock;

That's correct, if a new vma emerges with a different page size it
cannot have a not null dst_vma->vm_userfaultfd_ctx.ctx in the non
cooperative case.

> @@ -219,12 +226,6 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
>  		goto out_unlock;
>  
>  	/*
> -	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
> -	 */
> -	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> -		goto out_unlock;
> -
> -	/*

but this is buggy and it shouldn't be removed, we need this check also
if dst_vma was found not NULL.

>  	 * Ensure the dst_vma has a anon_vma.
>  	 */
>  	err = -ENOMEM;
> @@ -368,10 +369,23 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  	 * Make sure the vma is not shared, that the dst range is
>  	 * both valid and fully within a single existing vma.
>  	 */
> -	err = -EINVAL;
> +	err = -ENOENT;
>  	dst_vma = find_vma(dst_mm, dst_start);
>  	if (!dst_vma)
>  		goto out_unlock;
> +	/*
> +	 * Be strict and only allow __mcopy_atomic on userfaultfd
> +	 * registered ranges to prevent userland errors going
> +	 * unnoticed. As far as the VM consistency is concerned, it
> +	 * would be perfectly safe to remove this check, but there's
> +	 * no useful usage for __mcopy_atomic ouside of userfaultfd
> +	 * registered ranges. This is after all why these are ioctls
> +	 * belonging to the userfaultfd and not syscalls.
> +	 */
> +	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> +		goto out_unlock;
> +
> +	err = -EINVAL;
>  	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
>  		goto out_unlock;
>  	if (dst_start < dst_vma->vm_start ||

This isn't enough, the -ENOENT should be returned also if the address
doesn't isn't in the range of the found vma, instead of -EINVAL. "vma"
may be a completely different vma just it happen to be way above the
fault address, and the vma previously covering the "addr" (which was
below the found "vma") was already munmapped, so you'd be returning
-EINVAL after munmap still unless the -EINVAL is moved down below.

The check on !vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED
instead can be shifted down below after setting err to -EINVAL as then
we know the vma is really the one we were looking for but it's of a
type we can't handle.


Now changing topic (aside from implementation comments above) I need
to raise a big fat warning that this change breaks the userland ABI.
There's definitely a 100% backwards compatible way to do this and it
would be to introduce a new UFFDIO_COPY2 ioctl.

However I think the above approach is ok because, userland should
always crash dump if UFFDIO_COPY returns -EINVAL to be strict, so it
means any app that is running into this corner case would currently be
getting -EINVAL and it'd crash in the first place.

For non cooperative usage, is very good that it will be allowed not to
ignore -EINVAL errors, and it will only ignore -ENOENT retvals so it
can be strict too (qemu will instead crash no matter if it gets
-ENOENT or -ENOSPC or -EINVAL).

I believe it's an acceptable ABI change with no risk to existing apps,
the main current user of userfaultfd being the cooperative usage (non
cooperative is still in -mm after all) and with David we reviewed qemu
to never run into the -ENOENT/-ENOSPC case. It'd crash already if it
would get -EINVAL (and it has to still crash with the more finegrined
-ENOENT/-ENOSPC).

So I'm positive about this ABI change as it can't break any existing
app we know of, and I'm also positive the other one in 5/5 for the
same reason (-ENOSPC) where I don't see implementation issues either.

There have been major complains about breaking userland ABI retvals in
the past, so I just want to give a big fat warning about these two
patches 4/5 and 5/5, but I personally think it's an acceptable change
as I don't see any risk of cooperative userland breaking because of it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
