Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1CC6B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 00:44:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l1so4240321pga.1
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 21:44:13 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id z9si2507785pgs.529.2018.02.23.21.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 21:44:11 -0800 (PST)
From: jason <jason.cai@linux.alibaba.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: [RFC] vfio iommu type1: improve memory pinning process for raw PFN
 mapping
Message-Id: <7090CB2E-8D63-44B1-A739-932FFA649BC9@linux.alibaba.com>
Date: Sat, 24 Feb 2018 13:44:07 +0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jason <jason.cai@linux.alibaba.com>, alex.williamson@redhat.com, pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gnehzuil@linux.alibaba.com

When using vfio to pass through a PCIe device (e.g. a GPU card) that
has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
pinning because PFNs of PCI BAR are not backed by struct page, and
the corresponding VMA has flags VM_IO|VM_PFNMAP.

With this change, memory pinning process will firstly try to figure
out whether the corresponding region is a raw PFN mapping, and if so
it can skip unnecessary user memory pinning process.

Even though it commes with a little overhead, finding vma and testing
flags, on each call, it can significantly improve VM's boot up time
when passing through devices via VFIO.
---
 drivers/vfio/vfio_iommu_type1.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c =
b/drivers/vfio/vfio_iommu_type1.c
index e30e29ae4819..1a471ece3f9c 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -374,6 +374,24 @@ static int vaddr_get_pfn(struct mm_struct *mm, =
unsigned long vaddr,
        return ret;
 }

+static int try_io_pfnmap(struct mm_struct *mm, unsigned long vaddr, =
long npage,
+                        unsigned long *pfn)
+{
+       struct vm_area_struct *vma;
+       int pinned =3D 0;
+
+       down_read(&mm->mmap_sem);
+       vma =3D find_vma_intersection(mm, vaddr, vaddr + 1);
+       if (vma && vma->vm_flags & (VM_IO | VM_PFNMAP)) {
+               *pfn =3D ((vaddr - vma->vm_start) >> PAGE_SHIFT) + =
vma->vm_pgoff;
+               if (is_invalid_reserved_pfn(*pfn))
+                       pinned =3D min(npage, (long)vma_pages(vma));
+       }
+       up_read(&mm->mmap_sem);
+
+       return pinned;
+}
+
 /*
  * Attempt to pin pages.  We really don't want to track all the pfns =
and
  * the iommu can only map chunks of consecutive pfns anyway, so get the
@@ -392,6 +410,10 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
        if (!current->mm)
                return -ENODEV;

+       ret =3D try_io_pfnmap(current->mm, vaddr, npage, pfn_base);
+       if (ret)
+               return ret;
+
        ret =3D vaddr_get_pfn(current->mm, vaddr, dma->prot, pfn_base);
        if (ret)
                return ret;
--
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
