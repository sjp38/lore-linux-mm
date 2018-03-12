Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEC726B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 18:06:47 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id r32so10089266ota.18
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:06:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k47si2447149otb.13.2018.03.12.15.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 15:06:46 -0700 (PDT)
Date: Mon, 12 Mar 2018 16:06:44 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [RFC v2] vfio iommu type1: improve memory pinning process for
 raw PFN mapping
Message-ID: <20180312160644.0de6f96b@w520.home>
In-Reply-To: <25959294-E232-43EB-9CE2-E558A8D62F57@linux.alibaba.com>
References: <7090CB2E-8D63-44B1-A739-932FFA649BC9@linux.alibaba.com>
	<20180226121930.5e1f6300@w520.home>
	<25959294-E232-43EB-9CE2-E558A8D62F57@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gnehzuil@linux.alibaba.com

On Sat, 3 Mar 2018 20:10:33 +0800
"Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com> wrote:

> When using vfio to pass through a PCIe device (e.g. a GPU card) that
> has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
> pinning because PFNs of PCI BAR are not backed by struct page, and
> the corresponding VMA has flag VM_PFNMAP.
> 
> With this change, when pinning a region which is a raw PFN mapping,
> it can skip unnecessary user memory pinning process. Thus, it can
> significantly improve VM's boot up time when passing through devices
> via VFIO.
> 
> Signed-off-by: Jason Cai (Xiang Feng) <jason.cai@linux.alibaba.com>
> ---
>  drivers/vfio/vfio_iommu_type1.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)


It looks reasonable to me, is this still really an RFC?  It would also
be interesting to include performance data in the commit log, how much
faster is it to map that 16GB BAR with this change?  Thanks,

Alex

 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index e30e29ae4819..82ccfa350315 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -385,7 +385,6 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  {
>         unsigned long pfn = 0;
>         long ret, pinned = 0, lock_acct = 0;
> -       bool rsvd;
>         dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
> 
>         /* This code path is only user initiated */
> @@ -396,14 +395,22 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>         if (ret)
>                 return ret;
> 
> +       if (is_invalid_reserved_pfn(*pfn_base)) {
> +               struct vm_area_struct *vma;
> +               down_read(&current->mm->mmap_sem);
> +               vma = find_vma_intersection(current->mm, vaddr, vaddr + 1);
> +               pinned = min(npage, (long)vma_pages(vma));
> +               up_read(&current->mm->mmap_sem);
> +               return pinned;
> +       }
> +
>         pinned++;
> -       rsvd = is_invalid_reserved_pfn(*pfn_base);
> 
>         /*
>          * Reserved pages aren't counted against the user, externally pinned
>          * pages are already counted against the user.
>          */
> -       if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +       if (!vfio_find_vpfn(dma, iova)) {
>                 if (!lock_cap && current->mm->locked_vm + 1 > limit) {
>                         put_pfn(*pfn_base, dma->prot);
>                         pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
> @@ -423,13 +430,12 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>                 if (ret)
>                         break;
> 
> -               if (pfn != *pfn_base + pinned ||
> -                   rsvd != is_invalid_reserved_pfn(pfn)) {
> +               if (pfn != *pfn_base + pinned) {
>                         put_pfn(pfn, dma->prot);
>                         break;
>                 }
> 
> -               if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +               if (!vfio_find_vpfn(dma, iova)) {
>                         if (!lock_cap &&
>                             current->mm->locked_vm + lock_acct + 1 > limit) {
>                                 put_pfn(pfn, dma->prot);
> @@ -447,10 +453,8 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
> 
>  unpin_out:
>         if (ret) {
> -               if (!rsvd) {
> -                       for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
> -                               put_pfn(pfn, dma->prot);
> -               }
> +               for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
> +                       put_pfn(pfn, dma->prot);
> 
>                 return ret;
>         }
> --
> 2.13.6
