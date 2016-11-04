Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CED9280285
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 12:36:02 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h201so1140986qke.7
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 09:36:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v85si8127820qka.130.2016.11.04.09.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 09:36:01 -0700 (PDT)
Date: Fri, 4 Nov 2016 17:35:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
Message-ID: <20161104163558.GQ4611@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Thu, Nov 03, 2016 at 10:33:09AM -0700, Mike Kravetz wrote:
> On 11/03/2016 03:15 AM, Hillf Danton wrote:
> >> +	if (zeropage)
> >> +		return -EINVAL;
> > 
> > Release mmap_sem before return?

This shows we need to extend the selftest to execute UFFDIO_ZEROPAGE
also on tmpfs and hugetlbfs two cases, and verify it returns -EINVAL.

> >> +
> >> +	src_addr = src_start;
> >> +	dst_addr = dst_start;
> >> +	copied = 0;
> >> +	page = NULL;
> >> +	vma_hpagesize = vma_kernel_pagesize(dst_vma);
> >> +
> >> +retry:
> >> +	/*
> >> +	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
> >> +	 * retry, dst_vma will be set to NULL and we must lookup again.
> >> +	 */
> >> +	err = -EINVAL;
> >> +	if (!dst_vma) {
> >> +		dst_vma = find_vma(dst_mm, dst_start);
> > 
> > In case of retry, s/dst_start/dst_addr/?
> > And check if we find a valid vma?

I don't think that's needed. Yes intuitively if a munmap zaps the
start of the vma during the copy we could continue, but userfaultfd
generally is as strict as it can get.

This is why UFFDIO_COPY is not doing like mremap, that just wipe
whatever existed in destination silently. UFFDIO_COPY returns -EEXIST
whenever something is already mapped there during a UFFDIO_COPY.

When it's userland managing the faults, being more strict I think it's
safer.

Running a copy concurrent with a munmap or any other vma mangling
leads to an undefined result. I think it's preferable to generate an
error to userland if it ever does an undefined operation considering
the risk if something goes wrong here while userland are managing the
faults. Furthermore this keeps the code simpler.

This is also why the revalidation code then does:

		if (dst_start < dst_vma->vm_start ||
		    dst_start + len > dst_vma->vm_end)
			goto out_unlock;

and it pretends the vma it is still there for the whole range being
copied.

So I tend to prefer the current version, letting it succeed silently
while correct and valid in theory, in practice sounds worse than the
current stricter behavior.

In any case if we change this for hugetlbfs, the non-hugetlbfs variant
should also be updated.

> >> @@ -182,6 +355,13 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> >>  		goto out_unlock;
> >>
> >>  	/*
> >> +	 * If this is a HUGETLB vma, pass off to appropriate routine
> >> +	 */
> >> +	if (dst_vma->vm_flags & VM_HUGETLB)
> >> +		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
> >> +						src_start, len, false);
> > 
> > Use is_vm_hugetlb_page()? 
> > 
> > 
> 
> Thanks Hillf, all valid points.  I will create another version of
> this patch.

Nice cleanup yes.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
