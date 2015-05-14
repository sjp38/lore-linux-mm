Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11DFE6B008A
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:36 -0400 (EDT)
Received: by qkgy4 with SMTP id y4so54080987qkg.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d7si23749343qka.121.2015.05.14.10.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:28 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 21/23] userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE preparation
Date: Thu, 14 May 2015 19:31:18 +0200
Message-Id: <1431624680-20153-22-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This implements mcopy_atomic and mfill_zeropage that are the lowlevel
VM methods that are invoked respectively by the UFFDIO_COPY and
UFFDIO_ZEROPAGE userfaultfd commands.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/userfaultfd_k.h |   6 +
 mm/Makefile                   |   1 +
 mm/userfaultfd.c              | 269 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 276 insertions(+)
 create mode 100644 mm/userfaultfd.c

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index e1e4360..587480a 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -30,6 +30,12 @@
 extern int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 			    unsigned int flags, unsigned long reason);
 
+extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
+			    unsigned long src_start, unsigned long len);
+extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
+			      unsigned long dst_start,
+			      unsigned long len);
+
 /* mm helpers */
 static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
 					struct vm_userfaultfd_ctx vm_ctx)
diff --git a/mm/Makefile b/mm/Makefile
index 98c4eae..b424d5e 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
+obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
new file mode 100644
index 0000000..c54c761
--- /dev/null
+++ b/mm/userfaultfd.c
@@ -0,0 +1,269 @@
+/*
+ *  mm/userfaultfd.c
+ *
+ *  Copyright (C) 2015  Red Hat, Inc.
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/userfaultfd_k.h>
+#include <linux/mmu_notifier.h>
+#include <asm/tlbflush.h>
+#include "internal.h"
+
+static int mcopy_atomic_pte(struct mm_struct *dst_mm,
+			    pmd_t *dst_pmd,
+			    struct vm_area_struct *dst_vma,
+			    unsigned long dst_addr,
+			    unsigned long src_addr)
+{
+	struct mem_cgroup *memcg;
+	pte_t _dst_pte, *dst_pte;
+	spinlock_t *ptl;
+	struct page *page;
+	void *page_kaddr;
+	int ret;
+
+	ret = -ENOMEM;
+	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, dst_vma, dst_addr);
+	if (!page)
+		goto out;
+
+	page_kaddr = kmap(page);
+	ret = -EFAULT;
+	if (copy_from_user(page_kaddr, (const void __user *) src_addr,
+			   PAGE_SIZE))
+		goto out_kunmap_release;
+	kunmap(page);
+
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * preceeding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
+	__SetPageUptodate(page);
+
+	ret = -ENOMEM;
+	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg))
+		goto out_release;
+
+	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
+	if (dst_vma->vm_flags & VM_WRITE)
+		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
+
+	ret = -EEXIST;
+	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+	if (!pte_none(*dst_pte))
+		goto out_release_uncharge_unlock;
+
+	inc_mm_counter(dst_mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(page, dst_vma, dst_addr);
+	mem_cgroup_commit_charge(page, memcg, false);
+	lru_cache_add_active_or_unevictable(page, dst_vma);
+
+	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(dst_vma, dst_addr, dst_pte);
+
+	pte_unmap_unlock(dst_pte, ptl);
+	ret = 0;
+out:
+	return ret;
+out_release_uncharge_unlock:
+	pte_unmap_unlock(dst_pte, ptl);
+	mem_cgroup_cancel_charge(page, memcg);
+out_release:
+	page_cache_release(page);
+	goto out;
+out_kunmap_release:
+	kunmap(page);
+	goto out_release;
+}
+
+static int mfill_zeropage_pte(struct mm_struct *dst_mm,
+			      pmd_t *dst_pmd,
+			      struct vm_area_struct *dst_vma,
+			      unsigned long dst_addr)
+{
+	pte_t _dst_pte, *dst_pte;
+	spinlock_t *ptl;
+	int ret;
+
+	_dst_pte = pte_mkspecial(pfn_pte(my_zero_pfn(dst_addr),
+					 dst_vma->vm_page_prot));
+	ret = -EEXIST;
+	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
+	if (!pte_none(*dst_pte))
+		goto out_unlock;
+	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(dst_vma, dst_addr, dst_pte);
+	ret = 0;
+out_unlock:
+	pte_unmap_unlock(dst_pte, ptl);
+	return ret;
+}
+
+static pmd_t *mm_alloc_pmd(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+
+	pgd = pgd_offset(mm, address);
+	pud = pud_alloc(mm, pgd, address);
+	if (pud)
+		/*
+		 * Note that we didn't run this because the pmd was
+		 * missing, the *pmd may be already established and in
+		 * turn it may also be a trans_huge_pmd.
+		 */
+		pmd = pmd_alloc(mm, pud, address);
+	return pmd;
+}
+
+static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
+					      unsigned long dst_start,
+					      unsigned long src_start,
+					      unsigned long len,
+					      bool zeropage)
+{
+	struct vm_area_struct *dst_vma;
+	ssize_t err;
+	pmd_t *dst_pmd;
+	unsigned long src_addr, dst_addr;
+	long copied = 0;
+
+	/*
+	 * Sanitize the command parameters:
+	 */
+	BUG_ON(dst_start & ~PAGE_MASK);
+	BUG_ON(len & ~PAGE_MASK);
+
+	/* Does the address range wrap, or is the span zero-sized? */
+	BUG_ON(src_start + len <= src_start);
+	BUG_ON(dst_start + len <= dst_start);
+
+	down_read(&dst_mm->mmap_sem);
+
+	/*
+	 * Make sure the vma is not shared, that the dst range is
+	 * both valid and fully within a single existing vma.
+	 */
+	err = -EINVAL;
+	dst_vma = find_vma(dst_mm, dst_start);
+	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
+		goto out;
+	if (dst_start < dst_vma->vm_start ||
+	    dst_start + len > dst_vma->vm_end)
+		goto out;
+
+	/*
+	 * Be strict and only allow __mcopy_atomic on userfaultfd
+	 * registered ranges to prevent userland errors going
+	 * unnoticed. As far as the VM consistency is concerned, it
+	 * would be perfectly safe to remove this check, but there's
+	 * no useful usage for __mcopy_atomic ouside of userfaultfd
+	 * registered ranges. This is after all why these are ioctls
+	 * belonging to the userfaultfd and not syscalls.
+	 */
+	if (!dst_vma->vm_userfaultfd_ctx.ctx)
+		goto out;
+
+	/*
+	 * FIXME: only allow copying on anonymous vmas, tmpfs should
+	 * be added.
+	 */
+	if (dst_vma->vm_ops)
+		goto out;
+
+	/*
+	 * Ensure the dst_vma has a anon_vma or this page
+	 * would get a NULL anon_vma when moved in the
+	 * dst_vma.
+	 */
+	err = -ENOMEM;
+	if (unlikely(anon_vma_prepare(dst_vma)))
+		goto out;
+
+	for (src_addr = src_start, dst_addr = dst_start;
+	     src_addr < src_start + len; ) {
+		pmd_t dst_pmdval;
+		BUG_ON(dst_addr >= dst_start + len);
+		dst_pmd = mm_alloc_pmd(dst_mm, dst_addr);
+		if (unlikely(!dst_pmd)) {
+			err = -ENOMEM;
+			break;
+		}
+
+		dst_pmdval = pmd_read_atomic(dst_pmd);
+		/*
+		 * If the dst_pmd is mapped as THP don't
+		 * override it and just be strict.
+		 */
+		if (unlikely(pmd_trans_huge(dst_pmdval))) {
+			err = -EEXIST;
+			break;
+		}
+		if (unlikely(pmd_none(dst_pmdval)) &&
+		    unlikely(__pte_alloc(dst_mm, dst_vma, dst_pmd,
+					 dst_addr))) {
+			err = -ENOMEM;
+			break;
+		}
+		/* If an huge pmd materialized from under us fail */
+		if (unlikely(pmd_trans_huge(*dst_pmd))) {
+			err = -EFAULT;
+			break;
+		}
+
+		BUG_ON(pmd_none(*dst_pmd));
+		BUG_ON(pmd_trans_huge(*dst_pmd));
+
+		if (!zeropage)
+			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
+					       dst_addr, src_addr);
+		else
+			err = mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma,
+						 dst_addr);
+
+		cond_resched();
+
+		if (!err) {
+			dst_addr += PAGE_SIZE;
+			src_addr += PAGE_SIZE;
+			copied += PAGE_SIZE;
+
+			if (fatal_signal_pending(current))
+				err = -EINTR;
+		}
+		if (err)
+			break;
+	}
+
+out:
+	up_read(&dst_mm->mmap_sem);
+	BUG_ON(copied < 0);
+	BUG_ON(err > 0);
+	BUG_ON(!copied && !err);
+	return copied ? copied : err;
+}
+
+ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
+		     unsigned long src_start, unsigned long len)
+{
+	return __mcopy_atomic(dst_mm, dst_start, src_start, len, false);
+}
+
+ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
+		       unsigned long len)
+{
+	return __mcopy_atomic(dst_mm, start, 0, len, true);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
