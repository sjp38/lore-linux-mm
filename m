Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 100F26B0006
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:33:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i193so1822372qke.18
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:33:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b40si1010242qkb.82.2018.03.20.14.33.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:33:25 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:33:23 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] vfio iommu type1: improve memory pinning process for
 raw PFN mapping
Message-ID: <20180320153323.41c58c19@t450s.home>
In-Reply-To: <7F93BB33-4ABF-468F-8814-78DE9D23FA08@linux.alibaba.com>
References: <7F93BB33-4ABF-468F-8814-78DE9D23FA08@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gnehzuil@linux.alibaba.com

On Mon, 19 Mar 2018 10:30:24 +0800
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
>         unsigned long pfn = 0;
>         long ret, pinned = 0, lock_acct = 0;
> -       bool rsvd;
>         dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
> 
>         /* This code path is only user initiated */
> @@ -408,14 +407,22 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
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
> @@ -435,13 +442,12 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
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
> @@ -459,10 +465,8 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
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

Hi Jason,

Something is wrong with your mail setup, the patch looks normal above,
but when I view the source or save it to try to apply it, the diff is
corrupt, as below.  It looks like maybe you're pasting the patch into
your mailer and it's wrapping lines (ending with '=') and actual '='
are replaced with '=3D' and tabs are converted to spaces.  Please fix
your mailer and resend.  Thanks,

Alex

diff --git a/drivers/vfio/vfio_iommu_type1.c =
b/drivers/vfio/vfio_iommu_type1.c
index 45657e2b1ff7..0658f35318b8 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -397,7 +397,6 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
 {
        unsigned long pfn =3D 0;
        long ret, pinned =3D 0, lock_acct =3D 0;
-       bool rsvd;
        dma_addr_t iova =3D vaddr - dma->vaddr + dma->iova;

        /* This code path is only user initiated */
@@ -408,14 +407,22 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
        if (ret)
                return ret;

+       if (is_invalid_reserved_pfn(*pfn_base)) {
+               struct vm_area_struct *vma;
+               down_read(&current->mm->mmap_sem);
+               vma =3D find_vma_intersection(current->mm, vaddr, vaddr =
+ 1);
+               pinned =3D min(npage, (long)vma_pages(vma));
+               up_read(&current->mm->mmap_sem);
+               return pinned;
+       }
+
        pinned++;
-       rsvd =3D is_invalid_reserved_pfn(*pfn_base);

        /*
         * Reserved pages aren't counted against the user, externally =
pinned
         * pages are already counted against the user.
         */
-       if (!rsvd && !vfio_find_vpfn(dma, iova)) {
+       if (!vfio_find_vpfn(dma, iova)) {
                if (!lock_cap && current->mm->locked_vm + 1 > limit) {
                        put_pfn(*pfn_base, dma->prot);
                        pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", =
__func__,
@@ -435,13 +442,12 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
                if (ret)
                        break;

-               if (pfn !=3D *pfn_base + pinned ||
-                   rsvd !=3D is_invalid_reserved_pfn(pfn)) {
+               if (pfn !=3D *pfn_base + pinned) {
                        put_pfn(pfn, dma->prot);
                        break;
                }

-               if (!rsvd && !vfio_find_vpfn(dma, iova)) {
+               if (!vfio_find_vpfn(dma, iova)) {
                        if (!lock_cap &&
                            current->mm->locked_vm + lock_acct + 1 > =
limit) {
                                put_pfn(pfn, dma->prot);
@@ -459,10 +465,8 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,

 unpin_out:
        if (ret) {
-               if (!rsvd) {
-                       for (pfn =3D *pfn_base ; pinned ; pfn++, =
pinned--)
-                               put_pfn(pfn, dma->prot);
-               }
+               for (pfn =3D *pfn_base ; pinned ; pfn++, pinned--)
+                       put_pfn(pfn, dma->prot);

                return ret;
        }
--
2.13.6
