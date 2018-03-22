Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 040336B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:48:28 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id e19-v6so5717429otf.9
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:48:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 4si2016620oin.5.2018.03.22.14.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 14:48:26 -0700 (PDT)
Date: Thu, 22 Mar 2018 15:48:25 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] vfio iommu type1: improve memory pinning process for
 raw PFN mapping
Message-ID: <20180322154825.0f8477f7@w520.home>
In-Reply-To: <20180322045216.22220-1-jason.cai@linux.alibaba.com>
References: <20180322045216.22220-1-jason.cai@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gnehzuil@linux.alibaba.com

On Thu, 22 Mar 2018 12:52:16 +0800
"Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com> wrote:

> When using vfio to pass through a PCIe device (e.g. a GPU card) that
> has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
> pinning because PFNs of PCI BAR are not backed by struct page, and
> the corresponding VMA has flag VM_PFNMAP.
> 
> With this change, when pinning a region which is a raw PFN mapping,
> it can skip unnecessary user memory pinning process, and thus, can
> significantly improve VM's boot up time when passing through devices
> via VFIO. In my test on a Xeon E5 2.6GHz, the time mapping a 16GB
> BAR was reduced from about 0.4s to 1.5us.
> 
> Signed-off-by: Jason Cai (Xiang Feng) <jason.cai@linux.alibaba.com>
> ---
>  drivers/vfio/vfio_iommu_type1.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index 45657e2b1ff7..0658f35318b8 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -397,7 +397,6 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  {
>  	unsigned long pfn = 0;
>  	long ret, pinned = 0, lock_acct = 0;
> -	bool rsvd;
>  	dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
>  
>  	/* This code path is only user initiated */
> @@ -408,14 +407,22 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  	if (ret)
>  		return ret;
>  
> +	if (is_invalid_reserved_pfn(*pfn_base)) {
> +		struct vm_area_struct *vma;

scripts/checkpatch.pl suggests a new line here to separate variable
declaration from code.

> +		down_read(&current->mm->mmap_sem);
> +		vma = find_vma_intersection(current->mm, vaddr, vaddr + 1);
> +		pinned = min(npage, (long)vma_pages(vma));

checkpatch also suggests using min_t rather than casting to a
compatible type, ie:

	pinned = min_t(long, npage, vma_pages(vma));

I'll make these updates on commit, please make use of checkpatch on
future patches.  Applied to vfio next branch for v4.17.  Thanks,

Alex

> +		up_read(&current->mm->mmap_sem);
> +		return pinned;
> +	}
> +
>  	pinned++;
> -	rsvd = is_invalid_reserved_pfn(*pfn_base);
>  
>  	/*
>  	 * Reserved pages aren't counted against the user, externally pinned
>  	 * pages are already counted against the user.
>  	 */
> -	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +	if (!vfio_find_vpfn(dma, iova)) {
>  		if (!lock_cap && current->mm->locked_vm + 1 > limit) {
>  			put_pfn(*pfn_base, dma->prot);
>  			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
> @@ -435,13 +442,12 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  		if (ret)
>  			break;
>  
> -		if (pfn != *pfn_base + pinned ||
> -		    rsvd != is_invalid_reserved_pfn(pfn)) {
> +		if (pfn != *pfn_base + pinned) {
>  			put_pfn(pfn, dma->prot);
>  			break;
>  		}
>  
> -		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +		if (!vfio_find_vpfn(dma, iova)) {
>  			if (!lock_cap &&
>  			    current->mm->locked_vm + lock_acct + 1 > limit) {
>  				put_pfn(pfn, dma->prot);
> @@ -459,10 +465,8 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  
>  unpin_out:
>  	if (ret) {
> -		if (!rsvd) {
> -			for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
> -				put_pfn(pfn, dma->prot);
> -		}
> +		for (pfn = *pfn_base ; pinned ; pfn++, pinned--)
> +			put_pfn(pfn, dma->prot);
>  
>  		return ret;
>  	}
