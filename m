Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 587B5280260
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 02:43:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j198so93851380oih.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 23:43:22 -0700 (PDT)
Received: from out0-153.mail.aliyun.com (out0-153.mail.aliyun.com. [140.205.0.153])
        by mx.google.com with ESMTP id g3si9943111ioa.252.2016.11.03.23.43.20
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 23:43:21 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-16-git-send-email-aarcange@redhat.com> <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com> <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com> <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
In-Reply-To: <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Fri, 04 Nov 2016 14:43:17 +0800
Message-ID: <07a101d23666$b9d73aa0$2d85afe0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Friday, November 04, 2016 3:14 AM, Mike Kravetz wrote: 
> 
> Andrea, let me know if you prefer a delta from original patch.
> 
> From: Mike Kravetz <mike.kravetz@oracle.com>
> 
> userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
> 
> __mcopy_atomic_hugetlb performs the UFFDIO_COPY operation for huge
> pages.  It is based on the existing __mcopy_atomic routine for normal
> pages.  Unlike normal pages, there is no huge page support for the
> UFFDIO_ZEROPAGE operation.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/userfaultfd.c | 186
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 186 insertions(+)
> 
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 9c2ed70..e01d013 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -14,6 +14,8 @@
>  #include <linux/swapops.h>
>  #include <linux/userfaultfd_k.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/hugetlb.h>
> +#include <linux/pagemap.h>
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> 
> @@ -139,6 +141,183 @@ static pmd_t *mm_alloc_pmd(struct mm_struct *mm,
> unsigned long address)
>  	return pmd;
>  }
> 
> +
> +#ifdef CONFIG_HUGETLB_PAGE
> +/*
> + * __mcopy_atomic processing for HUGETLB vmas.  Note that this routine is
> + * called with mmap_sem held, it will release mmap_sem before returning.
> + */
> +static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct
> *dst_mm,
> +					      struct vm_area_struct *dst_vma,
> +					      unsigned long dst_start,
> +					      unsigned long src_start,
> +					      unsigned long len,
> +					      bool zeropage)
> +{
> +	ssize_t err;
> +	pte_t *dst_pte;
> +	unsigned long src_addr, dst_addr;
> +	long copied;
> +	struct page *page;
> +	struct hstate *h;
> +	unsigned long vma_hpagesize;
> +	pgoff_t idx;
> +	u32 hash;
> +	struct address_space *mapping;
> +
> +	/*
> +	 * There is no default zero huge page for all huge page sizes as
> +	 * supported by hugetlb.  A PMD_SIZE huge pages may exist as used
> +	 * by THP.  Since we can not reliably insert a zero page, this
> +	 * feature is not supported.
> +	 */
> +	if (zeropage) {
> +		up_read(&dst_mm->mmap_sem);
> +		return -EINVAL;
> +	}
> +
> +	src_addr = src_start;
> +	dst_addr = dst_start;
> +	copied = 0;
> +	page = NULL;
> +	vma_hpagesize = vma_kernel_pagesize(dst_vma);
> +
> +retry:
> +	/*
> +	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
> +	 * retry, dst_vma will be set to NULL and we must lookup again.
> +	 */
> +	err = -EINVAL;
> +	if (!dst_vma) {
> +		/* lookup dst_addr as we may have copied some pages */
> +		dst_vma = find_vma(dst_mm, dst_addr);
> +		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
> +			goto out_unlock;
> +
> +		vma_hpagesize = vma_kernel_pagesize(dst_vma);
> +
> +		/*
> +		 * Make sure the vma is not shared, that the remaining dst
> +		 * range is both valid and fully within a single existing vma.
> +		 */
> +		if (dst_vma->vm_flags & VM_SHARED)
> +			goto out_unlock;
> +		if (dst_addr < dst_vma->vm_start ||
> +		    dst_addr + len - (copied * vma_hpagesize) > dst_vma->vm_end)
> +			goto out_unlock;
> +	}
> +
> +	/*
> +	 * Validate alignment based on huge page size
> +	 */
> +	if (dst_addr & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
> +		goto out_unlock;
> +
> +	/*
> +	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
> +	 */
> +	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> +		goto out_unlock;
> +
> +	/*
> +	 * Ensure the dst_vma has a anon_vma.
> +	 */
> +	err = -ENOMEM;
> +	if (unlikely(anon_vma_prepare(dst_vma)))
> +		goto out_unlock;
> +
> +	h = hstate_vma(dst_vma);
> +
> +	while (src_addr < src_start + len) {
> +		pte_t dst_pteval;
> +
> +		BUG_ON(dst_addr >= dst_start + len);
> +		dst_addr &= huge_page_mask(h);
> +
> +		/*
> +		 * Serialize via hugetlb_fault_mutex
> +		 */
> +		idx = linear_page_index(dst_vma, dst_addr);
> +		mapping = dst_vma->vm_file->f_mapping;
> +		hash = hugetlb_fault_mutex_hash(h, dst_mm, dst_vma, mapping,
> +								idx, dst_addr);
> +		mutex_lock(&hugetlb_fault_mutex_table[hash]);
> +
> +		err = -ENOMEM;
> +		dst_pte = huge_pte_alloc(dst_mm, dst_addr, huge_page_size(h));
> +		if (!dst_pte) {
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			goto out_unlock;
> +		}
> +
> +		err = -EEXIST;
> +		dst_pteval = huge_ptep_get(dst_pte);
> +		if (!huge_pte_none(dst_pteval)) {
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			goto out_unlock;
> +		}
> +
> +		err = hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma,
> +						dst_addr, src_addr, &page);
> +
> +		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +
> +		cond_resched();
> +
> +		if (unlikely(err == -EFAULT)) {
> +			up_read(&dst_mm->mmap_sem);
> +			BUG_ON(!page);
> +
> +			err = copy_huge_page_from_user(page,
> +						(const void __user *)src_addr,
> +						pages_per_huge_page(h));
> +			if (unlikely(err)) {
> +				err = -EFAULT;
> +				goto out;
> +			}
> +			down_read(&dst_mm->mmap_sem);
> +
> +			dst_vma = NULL;
> +			goto retry;
> +		} else
> +			BUG_ON(page);
> +
> +		if (!err) {
> +			dst_addr += vma_hpagesize;
> +			src_addr += vma_hpagesize;
> +			copied += vma_hpagesize;
> +
> +			if (fatal_signal_pending(current))
> +				err = -EINTR;
> +		}
> +		if (err)
> +			break;
> +	}
> +
> +out_unlock:
> +	up_read(&dst_mm->mmap_sem);
> +out:
> +	if (page)
> +		put_page(page);
> +	BUG_ON(copied < 0);
> +	BUG_ON(err > 0);
> +	BUG_ON(!copied && !err);
> +	return copied ? copied : err;
> +}
> +#else /* !CONFIG_HUGETLB_PAGE */
> +static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct
> *dst_mm,
> +					      struct vm_area_struct *dst_vma,
> +					      unsigned long dst_start,
> +					      unsigned long src_start,
> +					      unsigned long len,
> +					      bool zeropage)
> +{
> +	up_read(&dst_mm->mmap_sem);	/* HUGETLB not configured */
> +	BUG();
> +	return -EINVAL;
> +}
> +#endif /* CONFIG_HUGETLB_PAGE */
> +
>  static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  					      unsigned long dst_start,
>  					      unsigned long src_start,
> @@ -182,6 +361,13 @@ retry:
>  		goto out_unlock;
> 
>  	/*
> +	 * If this is a HUGETLB vma, pass off to appropriate routine
> +	 */
> +	if (is_vm_hugetlb_page(dst_vma))
> +		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
> +						src_start, len, false);
> +
> +	/*
>  	 * Be strict and only allow __mcopy_atomic on userfaultfd
>  	 * registered ranges to prevent userland errors going
>  	 * unnoticed. As far as the VM consistency is concerned, it
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
