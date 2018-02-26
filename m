Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 019B76B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:19:34 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id v63so594799ota.12
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:19:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y19si2851595oie.400.2018.02.26.11.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 11:19:32 -0800 (PST)
Date: Mon, 26 Feb 2018 12:19:30 -0700
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [RFC] vfio iommu type1: improve memory pinning process for raw
 PFN mapping
Message-ID: <20180226121930.5e1f6300@w520.home>
In-Reply-To: <7090CB2E-8D63-44B1-A739-932FFA649BC9@linux.alibaba.com>
References: <7090CB2E-8D63-44B1-A739-932FFA649BC9@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jason <jason.cai@linux.alibaba.com>
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gnehzuil@linux.alibaba.com

On Sat, 24 Feb 2018 13:44:07 +0800
jason <jason.cai@linux.alibaba.com> wrote:

> When using vfio to pass through a PCIe device (e.g. a GPU card) that
> has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
> pinning because PFNs of PCI BAR are not backed by struct page, and
> the corresponding VMA has flags VM_IO|VM_PFNMAP.
> 
> With this change, memory pinning process will firstly try to figure
> out whether the corresponding region is a raw PFN mapping, and if so
> it can skip unnecessary user memory pinning process.
> 
> Even though it commes with a little overhead, finding vma and testing
> flags, on each call, it can significantly improve VM's boot up time
> when passing through devices via VFIO.

Needs a Sign-off, see Documentation/process/submitting-patches.rst

> ---
>  drivers/vfio/vfio_iommu_type1.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index e30e29ae4819..1a471ece3f9c 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -374,6 +374,24 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
>         return ret;
>  }
> 
> +static int try_io_pfnmap(struct mm_struct *mm, unsigned long vaddr, long npage,
> +                        unsigned long *pfn)
> +{
> +       struct vm_area_struct *vma;
> +       int pinned = 0;
> +
> +       down_read(&mm->mmap_sem);
> +       vma = find_vma_intersection(mm, vaddr, vaddr + 1);
> +       if (vma && vma->vm_flags & (VM_IO | VM_PFNMAP)) {
> +               *pfn = ((vaddr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +               if (is_invalid_reserved_pfn(*pfn))
> +                       pinned = min(npage, (long)vma_pages(vma));
> +       }
> +       up_read(&mm->mmap_sem);
> +
> +       return pinned;
> +}
> +
>  /*
>   * Attempt to pin pages.  We really don't want to track all the pfns and
>   * the iommu can only map chunks of consecutive pfns anyway, so get the
> @@ -392,6 +410,10 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>         if (!current->mm)
>                 return -ENODEV;
> 
> +       ret = try_io_pfnmap(current->mm, vaddr, npage, pfn_base);
> +       if (ret)
> +               return ret;
> +
>         ret = vaddr_get_pfn(current->mm, vaddr, dma->prot, pfn_base);
>         if (ret)
>                 return ret;

I like the idea, but couldn't we integrated it better?  For instance,
does it really make sense to test for this first, the majority of users
are going to have more regular mappings than PFNMAP mappings.  If we
were to do the above optimization, doesn't the rsvd bits in the
remainder of the code become cruft?  What if we optimized from the point
where we test the return of vaddr_get_pfn() for a reserved/invalid page?
Perhaps something like the below (untested, uncompiled) patch.  Also
curious why the above tests VM_IO|VM_PFNMAP while vaddr_get_pfn() only
tests VM_PFNMAP, we should at least be consistent, but also correct the
existing function if it's missing a case. Thanks,

Alex

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index e113b2c43be2..425922393316 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -399,7 +399,6 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 {
 	unsigned long pfn = 0;
 	long ret, pinned = 0, lock_acct = 0;
-	bool rsvd;
 	dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
 
 	/* This code path is only user initiated */
@@ -410,14 +409,23 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	if (ret)
 		return ret;
 
+	if (is_invalid_reserved_pfn(*pfn_base)) {
+		struct vm_area_struct *vma;
+
+		down_read(&mm->mmap_sem);
+		vma = find_vma_intersection(mm, vaddr, vaddr + 1);
+		pinned = min(npage, (long)vma_pages(vma));
+		up_read(&mm->mmap_sem);
+		return pinned;
+	}
+
 	pinned++;
-	rsvd = is_invalid_reserved_pfn(*pfn_base);
 
 	/*
 	 * Reserved pages aren't counted against the user, externally pinned
 	 * pages are already counted against the user.
 	 */
-	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
+	if (!vfio_find_vpfn(dma, iova)) {
 		if (!lock_cap && current->mm->locked_vm + 1 > limit) {
 			put_pfn(*pfn_base, dma->prot);
 			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
@@ -437,13 +445,12 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 		if (ret)
 			break;
 
-		if (pfn != *pfn_base + pinned ||
-		    rsvd != is_invalid_reserved_pfn(pfn)) {
+		if (pfn != *pfn_base + pinned) {
 			put_pfn(pfn, dma->prot);
 			break;
 		}
 
-		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
+		if (!vfio_find_vpfn(dma, iova)) {
 			if (!lock_cap &&
 			    current->mm->locked_vm + lock_acct + 1 > limit) {
 				put_pfn(pfn, dma->prot);
@@ -461,10 +468,8 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 
 unpin_out:
 	if (ret) {
-		if (!rsvd) {
-			for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
-				put_pfn(pfn, dma->prot);
-		}
+		for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
+			put_pfn(pfn, dma->prot);
 
 		return ret;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
