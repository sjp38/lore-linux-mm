Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4A06B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 22:30:29 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az5-v6so9549624plb.14
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 19:30:29 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id p26-v6si11099741pli.534.2018.03.18.19.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 19:30:27 -0700 (PDT)
From: "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: [PATCH] vfio iommu type1: improve memory pinning process for raw PFN
 mapping
Message-Id: <7F93BB33-4ABF-468F-8814-78DE9D23FA08@linux.alibaba.com>
Date: Mon, 19 Mar 2018 10:30:24 +0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Williamson <alex.williamson@redhat.com>, pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gnehzuil@linux.alibaba.com, "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>

When using vfio to pass through a PCIe device (e.g. a GPU card) that
has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
pinning because PFNs of PCI BAR are not backed by struct page, and
the corresponding VMA has flag VM_PFNMAP.

With this change, when pinning a region which is a raw PFN mapping,
it can skip unnecessary user memory pinning process, and thus, can
significantly improve VM's boot up time when passing through devices
via VFIO. In my test on a Xeon E5 2.6GHz, the time mapping a 16GB
BAR was reduced from about 0.4s to 1.5us.

Signed-off-by: Jason Cai (Xiang Feng) <jason.cai@linux.alibaba.com>
---
 drivers/vfio/vfio_iommu_type1.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

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
