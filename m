Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889506B04AF
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 07:11:00 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id d59so364193476ybi.1
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 04:11:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o4si3598765ybe.34.2016.11.20.04.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 04:10:59 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAKC8fTC011020
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 07:10:59 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ub4kh0pk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 07:10:59 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 20 Nov 2016 12:10:57 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 10A1B17D8056
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 12:13:21 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAKCAsu152691114
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 12:10:54 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAKCAsbY018107
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 05:10:54 -0700
Date: Sun, 20 Nov 2016 14:10:51 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for
 shared memory faults
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-26-git-send-email-aarcange@redhat.com>
 <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
 <20161104154438.GD5605@rapoport-lnx>
 <20161118003734.GC10229@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161118003734.GC10229@redhat.com>
Message-Id: <20161120121050.GC32009@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>

On Fri, Nov 18, 2016 at 01:37:34AM +0100, Andrea Arcangeli wrote:
> Hello,
> 
> I found a minor issue with the non cooperative testcase, sometime an
> userfault would trigger in between UFFD_EVENT_MADVDONTNEED and
> UFFDIO_UNREGISTER:
> 
> 		case UFFD_EVENT_MADVDONTNEED:
> 			uffd_reg.range.start = msg.arg.madv_dn.start;
> 			uffd_reg.range.len = msg.arg.madv_dn.end -
> 				msg.arg.madv_dn.start;
> 			if (ioctl(uffd, UFFDIO_UNREGISTER, &uffd_reg.range))
> 
> It always triggered at the nr == 0:
> 
> 	for (nr = 0; nr < nr_pages; nr++) {
> 		if (my_bcmp(area_dst + nr * page_size, zeropage, page_size))
> 
> The userfault still pending after UFFDIO_UNREGISTER returned, lead to
> poll() getting a UFFD_EVENT_PAGEFAULT and trying to do a UFFDIO_COPY
> into the unregistered range, which gracefully results in -EINVAL.
> 
> So this could be all handled in userland, by storing the MADV_DONTNEED
> range and calling UFFDIO_WAKE instead of UFFDIO_COPY... but I think
> it's more reliable to fix it into the kernel.
> 
> If a pending userfault happens before UFFDIO_UNREGISTER it'll just
> behave like if it happened after.
> 
> I also noticed the order of uffd notification of MADV_DONTNEED and the
> pagetable zap was wrong, we've to notify userland first so it won't
> risk to call UFFDIO_COPY while the process runs zap_page_range.
> 
> With the two patches appended below the -EINVAL error out of
> UFFDIO_COPY is gone.
> 
> From fc27d209e566d95e8ae0eb83a703aa4e02316b4c Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 17 Nov 2016 20:15:50 +0100
> Subject: [PATCH 1/2] userfaultfd: non-cooperative: avoid MADV_DONTNEED race
>  condition
> 
> MADV_DONTNEED must be notified to userland before the pages are
> zapped. This allows userland to immediately stop adding pages to the
> userfaultfd ranges before the pages are actually zapped or there could
> be non-zeropage leftovers as result of concurrent UFFDIO_COPY run in
> between zap_page_range and madvise_userfault_dontneed (both
> MADV_DONTNEED and UFFDIO_COPY runs under the mmap_sem for reading, so
> they can run concurrently).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  mm/madvise.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 7168bc6..4d4c7f8 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -476,8 +476,8 @@ static long madvise_dontneed(struct vm_area_struct *vma,
>  	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>  		return -EINVAL;
> 
> -	zap_page_range(vma, start, end - start, NULL);
>  	madvise_userfault_dontneed(vma, prev, start, end);
> +	zap_page_range(vma, start, end - start, NULL);
>  	return 0;
>  }
> 
> 
> 
> From 18e7b30cf82c927af4c0323a6caac20184a03ff4 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 17 Nov 2016 20:20:40 +0100
> Subject: [PATCH 2/2] userfaultfd: non-cooperative: wake userfaults after
>  UFFDIO_UNREGISTER
> 
> Userfaults may still happen after the userfaultfd monitor thread
> received a UFFD_EVENT_MADVDONTNEED until UFFDIO_UNREGISTER is run.
> 
> Wake any pending userfault within UFFDIO_UNREGISTER protected by the
> mmap_sem for writing, so they will not be reported to userland leading
> to UFFDIO_COPY returning -EINVAL (as the range was already
> unregistered) and they will not hang permanently either.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  fs/userfaultfd.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 2b75fab..42168d3 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1267,6 +1267,19 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  			start = vma->vm_start;
>  		vma_end = min(end, vma->vm_end);
> 
> +		if (userfaultfd_missing(vma)) {
> +			/*
> +			 * Wake any concurrent pending userfault while
> +			 * we unregister, so they will not hang
> +			 * permanently and it avoids userland to call
> +			 * UFFDIO_WAKE explicitly.
> +			 */
> +			struct userfaultfd_wake_range range;
> +			range.start = start;
> +			range.len = vma_end - start;
> +			wake_userfault(vma->vm_userfaultfd_ctx.ctx, &range);
> +		}
> +
>  		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
>  		prev = vma_merge(mm, prev, start, vma_end, new_flags,
>  				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
