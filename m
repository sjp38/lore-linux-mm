Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1ED8681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:41:04 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so19118504qtg.5
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:41:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v36si5832414qtd.91.2017.02.16.10.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 10:41:04 -0800 (PST)
Date: Thu, 16 Feb 2017 19:41:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170216184100.GS25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, Feb 15, 2017 at 01:46:50PM -0800, Mike Kravetz wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d0d1d08..41f6c51 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4029,6 +4029,18 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	__SetPageUptodate(page);
>  	set_page_huge_active(page);
>  
> +	/*
> +	 * If shared, add to page cache
> +	 */
> +	if (dst_vma->vm_flags & VM_SHARED) {

Minor nitpick, this could be a:

      int vm_shared = dst_vma->vm_flags & VM_SHARED;

(int faster than bool here as VM_SHARED won't have to be converted into 0|1)

> @@ -386,7 +413,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  		goto out_unlock;
>  
>  	err = -EINVAL;
> -	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
> +	if (!vma_is_shmem(dst_vma) && !is_vm_hugetlb_page(dst_vma) &&
> +	    dst_vma->vm_flags & VM_SHARED)
>  		goto out_unlock;

Other minor nitpick, this could have been faster as:

     if (vma_is_anonymous(dst_vma) && dst_vma->vm_flags & VM_SHARED)

Thinking twice, the only case we need to rule out is shmem_zero_setup
(it's not anon vmas can be really VM_SHARED or they wouldn't be anon
vmas in the first place) so even the above is superfluous because
shmem_zero_setup does:

	vma->vm_ops = &shmem_vm_ops;

So I would turn it into:


     /*
      * shmem_zero_setup is invoked in mmap for MAP_ANONYMOUS|MAP_SHARED but
      * it will overwrite vm_ops, so vma_is_anonymous must return false.
      */
     if (WARN_ON_ONCE(vma_is_anonymous(dst_vma) && dst_vma->vm_flags & VM_SHARED))
 		goto out_unlock;


Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---


Changing topic: thinking about the last part, I was wondering about
vma_is_anonymous because it's well known issue, it's only guaranteed
fully correct during page faults because the weird cases that can
return a false positive cannot generate page faults and they run
remap_pfn_range before releasing the mmap_sem for writing within
mmap(2) itself.

More than a year ago I discussed with Kirill (CC'ed) the
vma_is_anonymous() false positives: some VM_IO vma leaves vma->vm_ops
NULL, which is generally non concerning because putting an anon page
in there shouldn't have any adverse side effects for the rest of the
system.

It was critical for khugepaged, because khugepaged will run out of the
app own control, so khugepaged must be fully accurate of it'll just
activate on VM_IO special mappings, but that's definitely not the case
for userfaultfd.

Still I was wondering if we could be more strict by adding a
vma->vm_flags & VM_NO_KHUGEPAGED check so that VM_IO regions will not
pass registration (only in fs/userfaultfd.c:vma_can_userfault;
mm/userfaultfd.c doesn't need any of that as it requires registration
to be passed first and vm_userfaultfd_ctx already armed).

A fully accurate vma_is_anonymous could be implemented like this:

   vma_is_anonymous && !(vm_flags & VM_NO_KHUGEPAGED)

Which is what khugepaged internally uses.

This will also work for MAP_PRIVATE on /dev/zero (required to work by
the non cooperative case).

Side note: MAP_PRIVATE /dev/zero is very special and it's the only
case in the kernel a "true" anon vma has vm_file set. I think it'd be
cleaner to "decouple" the vma from /dev/zero the same way
MAP_SHARED|MAP_ANON "couples" the vma to a pseudo /dev/zero, so anon
vmas would always have vm_file NULL (not done because it'd risk to
break stuff by changing the /proc/pid/maps output), but that's besides
the point and the above solution deployed already by khugepaged
already works with the current /dev/zero MAP_PRIVATE code.

Kirill what's your take on making the registration checks stricter?
If we would add a vma_is_anonymous_not_in_fault implemented like above
vma_can_userfault would just need a
s/vma_is_anonymous/vma_is_anonymous_not_in_fault/ and it would be more
strict. khugepaged could be then converted to use it too instead of
hardcoding this vm_flags check. Unless I'm mistaken I would consider
such a change to the registration code, purely a cleanup to add a more
strict check.

Alternatively we could just leave things as is and depend on apps
using VM_IO with remap_pfn_range with vm_file set and vm_ops NULL, not
to screw themselves up by filling their regions with anon pages. I
don't see how it could break anything (except themselves) if they do,
but I'd appreciate a second thought on that. And at least for the
remap_pfn_range users it won't even get that far, because a graceful
-EEXIST would be returned instead. The change would effectively
convert a -EEXIST returned later into a stricter -EINVAL returned
early at registration time, for a case that is erratic by design.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
