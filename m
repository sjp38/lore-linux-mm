Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5E196B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:08:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r207so73419806pgr.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:08:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si11298547plj.269.2017.02.17.13.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:08:56 -0800 (PST)
Date: Fri, 17 Feb 2017 13:08:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-Id: <20170217130855.57813d7e96c7547202bba544@linux-foundation.org>
In-Reply-To: <20170217205124.GV25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
	<20170216184100.GS25530@redhat.com>
	<c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
	<20170217155241.GT25530@redhat.com>
	<20170217121738.f5b2e24474021f38fdb72845@linux-foundation.org>
	<20170217205124.GV25530@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, 17 Feb 2017 21:51:24 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Fri, Feb 17, 2017 at 12:17:38PM -0800, Andrew Morton wrote:
> > I merged this up and a small issue remains:
> 
> Great!
> 
> > The value of `err' here is EINVAL.  That sems appropriate, but it only
> > happens by sheer luck.
> 
> It might have been programmer luck but just for completeness, at
> runtime no luck was needed (the temporary setting to ENOENT is undoed
> before the if clause is closed). Your addition is surely safer just in
> case of future changes missing how we inherited the EINVAL in both
> branches, thanks! (plus the compiler should be able to optimize it
> away until after it will be needed)

OK.

I had a bunch more rejects to fix in that function.  Below is the final
result - please check it carefully.

I'll release another mmotm tree in the next few hours for runtime
testing.


static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
					      struct vm_area_struct *dst_vma,
					      unsigned long dst_start,
					      unsigned long src_start,
					      unsigned long len,
					      bool zeropage)
{
	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
	int vm_shared = dst_vma->vm_flags & VM_SHARED;
	ssize_t err;
	pte_t *dst_pte;
	unsigned long src_addr, dst_addr;
	long copied;
	struct page *page;
	struct hstate *h;
	unsigned long vma_hpagesize;
	pgoff_t idx;
	u32 hash;
	struct address_space *mapping;

	/*
	 * There is no default zero huge page for all huge page sizes as
	 * supported by hugetlb.  A PMD_SIZE huge pages may exist as used
	 * by THP.  Since we can not reliably insert a zero page, this
	 * feature is not supported.
	 */
	if (zeropage) {
		up_read(&dst_mm->mmap_sem);
		return -EINVAL;
	}

	src_addr = src_start;
	dst_addr = dst_start;
	copied = 0;
	page = NULL;
	vma_hpagesize = vma_kernel_pagesize(dst_vma);

	/*
	 * Validate alignment based on huge page size
	 */
	err = -EINVAL;
	if (dst_start & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
		goto out_unlock;

retry:
	/*
	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
	 * retry, dst_vma will be set to NULL and we must lookup again.
	 */
	if (!dst_vma) {
		err = -ENOENT;
		dst_vma = find_vma(dst_mm, dst_start);
		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
			goto out_unlock;
		/*
		 * Only allow __mcopy_atomic_hugetlb on userfaultfd
		 * registered ranges.
		 */
		if (!dst_vma->vm_userfaultfd_ctx.ctx)
			goto out_unlock;

		if (dst_start < dst_vma->vm_start ||
		    dst_start + len > dst_vma->vm_end)
			goto out_unlock;

		vm_shared = dst_vma->vm_flags & VM_SHARED;

		err = -EINVAL;
		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
			goto out_unlock;
	}

	err = -EINVAL;
	if (WARN_ON(dst_addr & (vma_hpagesize - 1) ||
		    (len - copied) & (vma_hpagesize - 1)))
		goto out_unlock;

	if (dst_start < dst_vma->vm_start ||
	    dst_start + len > dst_vma->vm_end)
		goto out_unlock;

	/*
	 * If not shared, ensure the dst_vma has a anon_vma.
	 */
	err = -ENOMEM;
	if (!vm_shared) {
		if (unlikely(anon_vma_prepare(dst_vma)))
			goto out_unlock;
	}

	h = hstate_vma(dst_vma);

	while (src_addr < src_start + len) {
		pte_t dst_pteval;

		BUG_ON(dst_addr >= dst_start + len);
		VM_BUG_ON(dst_addr & ~huge_page_mask(h));

		/*
		 * Serialize via hugetlb_fault_mutex
		 */
		idx = linear_page_index(dst_vma, dst_addr);
		mapping = dst_vma->vm_file->f_mapping;
		hash = hugetlb_fault_mutex_hash(h, dst_mm, dst_vma, mapping,
								idx, dst_addr);
		mutex_lock(&hugetlb_fault_mutex_table[hash]);

		err = -ENOMEM;
		dst_pte = huge_pte_alloc(dst_mm, dst_addr, huge_page_size(h));
		if (!dst_pte) {
			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
			goto out_unlock;
		}

		err = -EEXIST;
		dst_pteval = huge_ptep_get(dst_pte);
		if (!huge_pte_none(dst_pteval)) {
			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
			goto out_unlock;
		}

		err = hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma,
						dst_addr, src_addr, &page);

		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
		vm_alloc_shared = vm_shared;

		cond_resched();

		if (unlikely(err == -EFAULT)) {
			up_read(&dst_mm->mmap_sem);
			BUG_ON(!page);

			err = copy_huge_page_from_user(page,
						(const void __user *)src_addr,
						pages_per_huge_page(h), true);
			if (unlikely(err)) {
				err = -EFAULT;
				goto out;
			}
			down_read(&dst_mm->mmap_sem);

			dst_vma = NULL;
			goto retry;
		} else
			BUG_ON(page);

		if (!err) {
			dst_addr += vma_hpagesize;
			src_addr += vma_hpagesize;
			copied += vma_hpagesize;

			if (fatal_signal_pending(current))
				err = -EINTR;
		}
		if (err)
			break;
	}

out_unlock:
	up_read(&dst_mm->mmap_sem);
out:
	if (page) {
		/*
		 * We encountered an error and are about to free a newly
		 * allocated huge page.
		 *
		 * Reservation handling is very subtle, and is different for
		 * private and shared mappings.  See the routine
		 * restore_reserve_on_error for details.  Unfortunately, we
		 * can not call restore_reserve_on_error now as it would
		 * require holding mmap_sem.
		 *
		 * If a reservation for the page existed in the reservation
		 * map of a private mapping, the map was modified to indicate
		 * the reservation was consumed when the page was allocated.
		 * We clear the PagePrivate flag now so that the global
		 * reserve count will not be incremented in free_huge_page.
		 * The reservation map will still indicate the reservation
		 * was consumed and possibly prevent later page allocation.
		 * This is better than leaking a global reservation.  If no
		 * reservation existed, it is still safe to clear PagePrivate
		 * as no adjustments to reservation counts were made during
		 * allocation.
		 *
		 * The reservation map for shared mappings indicates which
		 * pages have reservations.  When a huge page is allocated
		 * for an address with a reservation, no change is made to
		 * the reserve map.  In this case PagePrivate will be set
		 * to indicate that the global reservation count should be
		 * incremented when the page is freed.  This is the desired
		 * behavior.  However, when a huge page is allocated for an
		 * address without a reservation a reservation entry is added
		 * to the reservation map, and PagePrivate will not be set.
		 * When the page is freed, the global reserve count will NOT
		 * be incremented and it will appear as though we have leaked
		 * reserved page.  In this case, set PagePrivate so that the
		 * global reserve count will be incremented to match the
		 * reservation map entry which was created.
		 *
		 * Note that vm_alloc_shared is based on the flags of the vma
		 * for which the page was originally allocated.  dst_vma could
		 * be different or NULL on error.
		 */
		if (vm_alloc_shared)
			SetPagePrivate(page);
		else
			ClearPagePrivate(page);
		put_page(page);
	}
	BUG_ON(copied < 0);
	BUG_ON(err > 0);
	BUG_ON(!copied && !err);
	return copied ? copied : err;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
