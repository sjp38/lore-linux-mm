Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3548E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:42:49 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d3so13851154pgv.23
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:42:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q34si12016627pgk.35.2019.01.21.02.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 02:42:48 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0LAcrpP087765
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:42:47 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q59weq0hu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:42:47 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 10:42:44 -0000
Date: Mon, 21 Jan 2019 12:42:33 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH RFC 07/24] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-8-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121075722.7945-8-peterx@redhat.com>
Message-Id: <20190121104232.GA26461@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:57:05PM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> v1: From: Shaohua Li <shli@fb.com>
> 
> v2: cleanups, remove a branch.
> 
> [peterx writes up the commit message, as below...]
> 
> This patch introduces the new uffd-wp APIs for userspace.
> 
> Firstly, we'll allow to do UFFDIO_REGISTER with write protection
> tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
> flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
> which case the userspace program can not only resolve missing page
> faults, and at the same time tracking page data changes along the way.
> 
> Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
> level write protection tracking.  Note that we will need to register
> the memory region with UFFDIO_REGISTER_MODE_WP before that.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx: remove useless block, write commit message]
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c                 | 78 +++++++++++++++++++++++++-------
>  include/uapi/linux/userfaultfd.h | 11 +++++
>  2 files changed, 73 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index bc9f6230a3f0..6ff8773d6797 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -305,8 +305,11 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
>  	if (!pmd_present(_pmd))
>  		goto out;
> 
> -	if (pmd_trans_huge(_pmd))
> +	if (pmd_trans_huge(_pmd)) {
> +		if (!pmd_write(_pmd) && (reason & VM_UFFD_WP))
> +			ret = true;
>  		goto out;
> +	}
> 
>  	/*
>  	 * the pmd is stable (as in !pmd_trans_unstable) so we can re-read it
> @@ -319,6 +322,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
>  	 */
>  	if (pte_none(*pte))
>  		ret = true;
> +	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
> +		ret = true;
>  	pte_unmap(pte);
> 
>  out:
> @@ -1252,10 +1257,13 @@ static __always_inline int validate_range(struct mm_struct *mm,
>  	return 0;
>  }
> 
> -static inline bool vma_can_userfault(struct vm_area_struct *vma)
> +static inline bool vma_can_userfault(struct vm_area_struct *vma,
> +				     unsigned long vm_flags)
>  {
> -	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
> -		vma_is_shmem(vma);
> +	/* FIXME: add WP support to hugetlbfs and shmem */
> +	return vma_is_anonymous(vma) ||
> +		((is_vm_hugetlb_page(vma) || vma_is_shmem(vma)) &&
> +		 !(vm_flags & VM_UFFD_WP));
>  }
> 
>  static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> @@ -1287,15 +1295,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	vm_flags = 0;
>  	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
>  		vm_flags |= VM_UFFD_MISSING;
> -	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
> +	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP)
>  		vm_flags |= VM_UFFD_WP;
> -		/*
> -		 * FIXME: remove the below error constraint by
> -		 * implementing the wprotect tracking mode.
> -		 */
> -		ret = -EINVAL;
> -		goto out;
> -	}
> 
>  	ret = validate_range(mm, uffdio_register.range.start,
>  			     uffdio_register.range.len);
> @@ -1343,7 +1344,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> 
>  		/* check not compatible vmas */
>  		ret = -EINVAL;
> -		if (!vma_can_userfault(cur))
> +		if (!vma_can_userfault(cur, vm_flags))
>  			goto out_unlock;
> 
>  		/*
> @@ -1371,6 +1372,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  			if (end & (vma_hpagesize - 1))
>  				goto out_unlock;
>  		}
> +		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_WRITE))
> +			goto out_unlock;

This is problematic for the non-cooperative use-case. Way may still want to
monitor a read-only area because it may eventually become writable, e.g. if
the monitored process runs mprotect().
Particularity, for using uffd-wp as a replacement for soft-dirty would
require it.

> 
>  		/*
>  		 * Check that this vma isn't already owned by a
> @@ -1400,7 +1403,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_can_userfault(vma));
> +		BUG_ON(!vma_can_userfault(vma, vm_flags));
>  		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
>  		       vma->vm_userfaultfd_ctx.ctx != ctx);
>  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> @@ -1535,7 +1538,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		 * provides for more strict behavior to notice
>  		 * unregistration errors.
>  		 */
> -		if (!vma_can_userfault(cur))
> +		if (!vma_can_userfault(cur, cur->vm_flags))
>  			goto out_unlock;
> 
>  		found = true;
> @@ -1549,7 +1552,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_can_userfault(vma));
> +		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
>  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> 
>  		/*
> @@ -1760,6 +1763,46 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  	return ret;
>  }
> 
> +static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> +				    unsigned long arg)
> +{
> +	int ret;
> +	struct uffdio_writeprotect uffdio_wp;
> +	struct uffdio_writeprotect __user *user_uffdio_wp;
> +	struct userfaultfd_wake_range range;
> +

In the non-cooperative mode the userfaultfd_writeprotect() may race with VM
layout changes, pretty much as uffdio_copy() [1]. My solution for uffdio_copy()
was to return -EAGAIN if such race is encountered. I think the same would
apply here.

> +	user_uffdio_wp = (struct uffdio_writeprotect __user *) arg;
> +
> +	if (copy_from_user(&uffdio_wp, user_uffdio_wp,
> +			   sizeof(struct uffdio_writeprotect)))
> +		return -EFAULT;
> +
> +	ret = validate_range(ctx->mm, uffdio_wp.range.start,
> +			     uffdio_wp.range.len);
> +	if (ret)
> +		return ret;
> +
> +	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> +			       UFFDIO_WRITEPROTECT_MODE_WP))
> +		return -EINVAL;
> +	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> +	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> +		return -EINVAL;
> +
> +	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> +				  uffdio_wp.range.len, uffdio_wp.mode &
> +				  UFFDIO_WRITEPROTECT_MODE_WP);
> +	if (ret)
> +		return ret;
> +
> +	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> +		range.start = uffdio_wp.range.start;
> +		range.len = uffdio_wp.range.len;
> +		wake_userfault(ctx, &range);
> +	}
> +	return ret;
> +}
> +
>  static inline unsigned int uffd_ctx_features(__u64 user_features)
>  {
>  	/*
> @@ -1837,6 +1880,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
>  	case UFFDIO_ZEROPAGE:
>  		ret = userfaultfd_zeropage(ctx, arg);
>  		break;
> +	case UFFDIO_WRITEPROTECT:
> +		ret = userfaultfd_writeprotect(ctx, arg);
> +		break;
>  	}
>  	return ret;
>  }
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 48f1a7c2f1f0..11517f796275 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -52,6 +52,7 @@
>  #define _UFFDIO_WAKE			(0x02)
>  #define _UFFDIO_COPY			(0x03)
>  #define _UFFDIO_ZEROPAGE		(0x04)
> +#define _UFFDIO_WRITEPROTECT		(0x06)
>  #define _UFFDIO_API			(0x3F)
> 
>  /* userfaultfd ioctl ids */
> @@ -68,6 +69,8 @@
>  				      struct uffdio_copy)
>  #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
>  				      struct uffdio_zeropage)
> +#define UFFDIO_WRITEPROTECT	_IOWR(UFFDIO, _UFFDIO_WRITEPROTECT, \
> +				      struct uffdio_writeprotect)
> 
>  /* read() structure */
>  struct uffd_msg {
> @@ -231,4 +234,12 @@ struct uffdio_zeropage {
>  	__s64 zeropage;
>  };
> 
> +struct uffdio_writeprotect {
> +	struct uffdio_range range;
> +	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> +#define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> +#define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> +	__u64 mode;
> +};
> +
>  #endif /* _LINUX_USERFAULTFD_H */
> -- 
> 2.17.1
 
[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=df2cc96e77011cf7989208b206da9817e0321028

-- 
Sincerely yours,
Mike.
