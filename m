Date: Wed, 23 Apr 2008 19:45:50 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423174550.GF24536@duo.random>
References: <patchbomb.1208872276@duo.random> <ea87c15371b1bd49380c.1208872277@duo.random> <20080423170909.GA1459@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423170909.GA1459@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 12:09:09PM -0500, Jack Steiner wrote:
> 
> You may have spotted this already. If so, just ignore this.
> 
> It looks like there is a bug in copy_page_range() around line 667.
> It's possible to do a mmu_notifier_invalidate_range_start(), then
> return -ENOMEM w/o doing a corresponding mmu_notifier_invalidate_range_end().

No I didn't spot it yet, great catch!! ;) Thanks a lot. I think we can
take example by Jack and use our energy to spot any bug in the
mmu-notifier-core like with his above auditing effort (I'm quite
certain you didn't reprouce this with real oom ;) so we get a rock
solid mmu-notifier implementation in 2.6.26 so XPMEM will also benefit
later in 2.6.27 and I hope the last XPMEM internal bugs will also be
fixed by that time.

(for the not going to become mmu-notifier users, nothing to worry
about for you, unless you used KVM or GRU actively with mmu-notifiers
this bug would be entirely harmless with both MMU_NOTIFIER=n and =y,
as previously guaranteed)

Here the still untested fix for review.

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -597,6 +597,7 @@
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	int ret;
 
 	/*
 	 * Don't copy ptes where a page fault will fill them correctly.
@@ -604,33 +605,39 @@
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
+	ret = 0;
 	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
 		if (!vma->anon_vma)
-			return 0;
+			goto out;
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+	if (unlikely(is_vm_hugetlb_page(vma))) {
+		ret = copy_hugetlb_page_range(dst_mm, src_mm, vma);
+		goto out;
+	}
 
 	if (is_cow_mapping(vma->vm_flags))
 		mmu_notifier_invalidate_range_start(src_mm, addr, end);
 
+	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
+		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
+					    vma, addr, next))) {
+			ret = -ENOMEM;
+			break;
+		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow_mapping(vma->vm_flags))
 		mmu_notifier_invalidate_range_end(src_mm,
-						vma->vm_start, end);
-
-	return 0;
+						  vma->vm_start, end);
+out:
+	return ret;
 }
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
