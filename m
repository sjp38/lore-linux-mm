Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 765246B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:45:02 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v186so9760603pfb.8
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:45:02 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id g1si6439626pgc.726.2018.02.26.23.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 23:45:01 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: [RFC] vfio iommu type1: improve memory pinning process for raw
 PFN mapping
From: "Jason Cai (Xiang Feng)" <jason.cai@linux.alibaba.com>
In-Reply-To: <20180226121930.5e1f6300@w520.home>
Date: Tue, 27 Feb 2018 15:44:48 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <8112174E-E15E-4E77-986C-FE3AF4C23EC3@linux.alibaba.com>
References: <7090CB2E-8D63-44B1-A739-932FFA649BC9@linux.alibaba.com>
 <20180226121930.5e1f6300@w520.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gnehzuil@linux.alibaba.com

On 27 Feb 2018, at 3:19 AM, Alex Williamson <alex.williamson@redhat.com> =
wrote:

> On Sat, 24 Feb 2018 13:44:07 +0800
> jason <jason.cai@linux.alibaba.com> wrote:
>=20
>> When using vfio to pass through a PCIe device (e.g. a GPU card) that
>> has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
>> pinning because PFNs of PCI BAR are not backed by struct page, and
>> the corresponding VMA has flags VM_IO|VM_PFNMAP.
>>=20
>> With this change, memory pinning process will firstly try to figure
>> out whether the corresponding region is a raw PFN mapping, and if so
>> it can skip unnecessary user memory pinning process.
>>=20
>> Even though it commes with a little overhead, finding vma and testing
>> flags, on each call, it can significantly improve VM's boot up time
>> when passing through devices via VFIO.
>=20
> Needs a Sign-off, see Documentation/process/submitting-patches.rst
>=20
>> ---
>> drivers/vfio/vfio_iommu_type1.c | 22 ++++++++++++++++++++++
>> 1 file changed, 22 insertions(+)
>>=20
>> diff --git a/drivers/vfio/vfio_iommu_type1.c =
b/drivers/vfio/vfio_iommu_type1.c
>> index e30e29ae4819..1a471ece3f9c 100644
>> --- a/drivers/vfio/vfio_iommu_type1.c
>> +++ b/drivers/vfio/vfio_iommu_type1.c
>> @@ -374,6 +374,24 @@ static int vaddr_get_pfn(struct mm_struct *mm, =
unsigned long vaddr,
>>        return ret;
>> }
>>=20
>> +static int try_io_pfnmap(struct mm_struct *mm, unsigned long vaddr, =
long npage,
>> +                        unsigned long *pfn)
>> +{
>> +       struct vm_area_struct *vma;
>> +       int pinned =3D 0;
>> +
>> +       down_read(&mm->mmap_sem);
>> +       vma =3D find_vma_intersection(mm, vaddr, vaddr + 1);
>> +       if (vma && vma->vm_flags & (VM_IO | VM_PFNMAP)) {
>> +               *pfn =3D ((vaddr - vma->vm_start) >> PAGE_SHIFT) + =
vma->vm_pgoff;
>> +               if (is_invalid_reserved_pfn(*pfn))
>> +                       pinned =3D min(npage, (long)vma_pages(vma));
>> +       }
>> +       up_read(&mm->mmap_sem);
>> +
>> +       return pinned;
>> +}
>> +
>> /*
>>  * Attempt to pin pages.  We really don't want to track all the pfns =
and
>>  * the iommu can only map chunks of consecutive pfns anyway, so get =
the
>> @@ -392,6 +410,10 @@ static long vfio_pin_pages_remote(struct =
vfio_dma *dma, unsigned long vaddr,
>>        if (!current->mm)
>>                return -ENODEV;
>>=20
>> +       ret =3D try_io_pfnmap(current->mm, vaddr, npage, pfn_base);
>> +       if (ret)
>> +               return ret;
>> +
>>        ret =3D vaddr_get_pfn(current->mm, vaddr, dma->prot, =
pfn_base);
>>        if (ret)
>>                return ret;
>=20
> I like the idea, but couldn't we integrated it better?  For instance,
> does it really make sense to test for this first, the majority of =
users
> are going to have more regular mappings than PFNMAP mappings.  If we
> were to do the above optimization, doesn't the rsvd bits in the
> remainder of the code become cruft?  What if we optimized from the =
point
> where we test the return of vaddr_get_pfn() for a reserved/invalid =
page?
> Perhaps something like the below (untested, uncompiled) patch.  Also
> curious why the above tests VM_IO|VM_PFNMAP while vaddr_get_pfn() only
> tests VM_PFNMAP, we should at least be consistent, but also correct =
the
> existing function if it's missing a case. Thanks,
>=20
> Alex
>=20

Good points! The patch has been updated according to these points.
And I=E2=80=99ve also tested with it. Please see it at the end. Thanks.

> diff --git a/drivers/vfio/vfio_iommu_type1.c =
b/drivers/vfio/vfio_iommu_type1.c
> index e113b2c43be2..425922393316 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -399,7 +399,6 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
> {
> 	unsigned long pfn =3D 0;
> 	long ret, pinned =3D 0, lock_acct =3D 0;
> -	bool rsvd;
> 	dma_addr_t iova =3D vaddr - dma->vaddr + dma->iova;
>=20
> 	/* This code path is only user initiated */
> @@ -410,14 +409,23 @@ static long vfio_pin_pages_remote(struct =
vfio_dma *dma, unsigned long vaddr,
> 	if (ret)
> 		return ret;
>=20
> +	if (is_invalid_reserved_pfn(*pfn_base)) {
> +		struct vm_area_struct *vma;
> +
> +		down_read(&mm->mmap_sem);
> +		vma =3D find_vma_intersection(mm, vaddr, vaddr + 1);
> +		pinned =3D min(npage, (long)vma_pages(vma));
> +		up_read(&mm->mmap_sem);
> +		return pinned;
> +	}
> +
> 	pinned++;
> -	rsvd =3D is_invalid_reserved_pfn(*pfn_base);
>=20
> 	/*
> 	 * Reserved pages aren't counted against the user, externally =
pinned
> 	 * pages are already counted against the user.
> 	 */
> -	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +	if (!vfio_find_vpfn(dma, iova)) {
> 		if (!lock_cap && current->mm->locked_vm + 1 > limit) {
> 			put_pfn(*pfn_base, dma->prot);
> 			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", =
__func__,
> @@ -437,13 +445,12 @@ static long vfio_pin_pages_remote(struct =
vfio_dma *dma, unsigned long vaddr,
> 		if (ret)
> 			break;
>=20
> -		if (pfn !=3D *pfn_base + pinned ||
> -		    rsvd !=3D is_invalid_reserved_pfn(pfn)) {
> +		if (pfn !=3D *pfn_base + pinned) {
> 			put_pfn(pfn, dma->prot);
> 			break;
> 		}
>=20
> -		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> +		if (!vfio_find_vpfn(dma, iova)) {
> 			if (!lock_cap &&
> 			    current->mm->locked_vm + lock_acct + 1 > =
limit) {
> 				put_pfn(pfn, dma->prot);
> @@ -461,10 +468,8 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
>=20
> unpin_out:
> 	if (ret) {
> -		if (!rsvd) {
> -			for (pfn =3D *pfn_base ; pinned ; pfn++, =
pinned--)
> -				put_pfn(pfn, dma->prot);
> -		}
> +		for (pfn =3D *pfn_base ; pinned ; pfn++, pinned--)
> +			put_pfn(pfn, dma->prot);
>=20
> 		return ret;
> 	}


When using vfio to pass through a PCIe device (e.g. a GPU card) that
has a huge BAR (e.g. 16GB), a lot of cycles are wasted on memory
pinning because PFNs of PCI BAR are not backed by struct page, and
the corresponding VMA has flag VM_PFNMAP.

With this change, when pinning a region which is a raw PFN mapping,
it can skip unnecessary user memory pinning process. Thus, it can
significantly improve VM's boot up time when passing through devices
via VFIO.

Signed-off-by: Jason Cai (Xiang Feng) <jason.cai@linux.alibaba.com>
---
 drivers/vfio/vfio_iommu_type1.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c =
b/drivers/vfio/vfio_iommu_type1.c
index e30e29ae4819..82ccfa350315 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -385,7 +385,6 @@ static long vfio_pin_pages_remote(struct vfio_dma =
*dma, unsigned long vaddr,
 {
        unsigned long pfn =3D 0;
        long ret, pinned =3D 0, lock_acct =3D 0;
-       bool rsvd;
        dma_addr_t iova =3D vaddr - dma->vaddr + dma->iova;

        /* This code path is only user initiated */
@@ -396,14 +395,22 @@ static long vfio_pin_pages_remote(struct vfio_dma =
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
@@ -423,13 +430,12 @@ static long vfio_pin_pages_remote(struct vfio_dma =
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
@@ -447,10 +453,8 @@ static long vfio_pin_pages_remote(struct vfio_dma =
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
