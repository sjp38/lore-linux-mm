Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47E8A6B0069
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 11:53:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so28955764pfd.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 08:53:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s23si25947929pfg.121.2017.02.03.08.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 08:53:08 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13GoMWe048223
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 11:53:07 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28cvjbk2ja-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 11:53:07 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 3 Feb 2017 16:53:04 -0000
Date: Fri, 3 Feb 2017 18:52:57 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/5] userfaultfd: mcopy_atomic: return -ENOENT when no
 compatible VMA found
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1485542673-24387-5-git-send-email-rppt@linux.vnet.ibm.com>
 <20170202180247.GA32446@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170202180247.GA32446@redhat.com>
Message-Id: <20170203165256.GB3183@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Andrea,

On Thu, Feb 02, 2017 at 07:02:47PM +0100, Andrea Arcangeli wrote:
> On Fri, Jan 27, 2017 at 08:44:32PM +0200, Mike Rapoport wrote:
> > -		err = -EINVAL;
> > +		err = -ENOENT;
> >  		dst_vma = find_vma(dst_mm, dst_start);
> >  		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
> >  			goto out_unlock;
> > +		/*
> > +		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
> > +		 * registered ranges.
> > +		 */
> > +		if (!dst_vma->vm_userfaultfd_ctx.ctx)
> > +			goto out_unlock;
> >  
> > +		err = -EINVAL;
> >  		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
> >  			goto out_unlock;
> 
> That's correct, if a new vma emerges with a different page size it
> cannot have a not null dst_vma->vm_userfaultfd_ctx.ctx in the non
> cooperative case.
> 
> > @@ -219,12 +226,6 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
> >  		goto out_unlock;
> >  
> >  	/*
> > -	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
> > -	 */
> > -	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> > -		goto out_unlock;
> > -
> > -	/*
> 
> but this is buggy and it shouldn't be removed, we need this check also
> if dst_vma was found not NULL.

The check for not-NULL uffd context is done in __mcopy_atomic, between
find_vma and call to __mcopy_atomic_hugetlb. Sp, at this point we verified
that dst_vma->vm_userfaultfd_ctx.ctx is not NULL either in the caller, or
for the 'retry' case in the hunk above.

> >  	 * Ensure the dst_vma has a anon_vma.
> >  	 */
> >  	err = -ENOMEM;
> > @@ -368,10 +369,23 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> >  	 * Make sure the vma is not shared, that the dst range is
> >  	 * both valid and fully within a single existing vma.
> >  	 */
> > -	err = -EINVAL;
> > +	err = -ENOENT;
> >  	dst_vma = find_vma(dst_mm, dst_start);
> >  	if (!dst_vma)
> >  		goto out_unlock;
> > +	/*
> > +	 * Be strict and only allow __mcopy_atomic on userfaultfd
> > +	 * registered ranges to prevent userland errors going
> > +	 * unnoticed. As far as the VM consistency is concerned, it
> > +	 * would be perfectly safe to remove this check, but there's
> > +	 * no useful usage for __mcopy_atomic ouside of userfaultfd
> > +	 * registered ranges. This is after all why these are ioctls
> > +	 * belonging to the userfaultfd and not syscalls.
> > +	 */
> > +	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> > +		goto out_unlock;
> > +
> > +	err = -EINVAL;
> >  	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
> >  		goto out_unlock;
> >  	if (dst_start < dst_vma->vm_start ||
> 
> This isn't enough, the -ENOENT should be returned also if the address
> doesn't isn't in the range of the found vma, instead of -EINVAL. "vma"
> may be a completely different vma just it happen to be way above the
> fault address, and the vma previously covering the "addr" (which was
> below the found "vma") was already munmapped, so you'd be returning
> -EINVAL after munmap still unless the -EINVAL is moved down below.

Will fix, thanks.
 
> The check on !vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED
> instead can be shifted down below after setting err to -EINVAL as then
> we know the vma is really the one we were looking for but it's of a
> type we can't handle.

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
