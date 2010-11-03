Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D91888D0003
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:31:21 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 27 of 66] kvm mmu transparent hugepage support
Message-Id: <4ccaac37884a448962e3.1288798082@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Marcelo Tosatti <mtosatti@redhat.com>

This should work for both hugetlbfs and transparent hugepages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -543,10 +543,20 @@ static int has_wrprotected_page(struct k
 
 static int host_mapping_level(struct kvm *kvm, gfn_t gfn)
 {
-	unsigned long page_size;
+	unsigned long page_size, addr;
 	int i, ret = 0;
 
-	page_size = kvm_host_page_size(kvm, gfn);
+	page_size = kvm_host_page_size(kvm, gfn, &addr);
+
+	/* check for transparent hugepages */
+	if (page_size == PAGE_SIZE && !kvm_is_error_hva(addr)) {
+		pfn_t pfn = hva_to_pfn(kvm, addr, 0);
+
+		if (!is_error_pfn(pfn) && !kvm_is_mmio_pfn(pfn) &&
+		    PageTransCompound(pfn_to_page(pfn)))
+			page_size = KVM_HPAGE_SIZE(2);
+		kvm_release_pfn_clean(pfn);
+	}
 
 	for (i = PT_PAGE_TABLE_LEVEL;
 	     i < (PT_PAGE_TABLE_LEVEL + KVM_NR_PAGE_SIZES); ++i) {
@@ -2283,6 +2293,8 @@ static int nonpaging_map(struct kvm_vcpu
 	pfn_t pfn;
 	unsigned long mmu_seq;
 
+	mmu_seq = vcpu->kvm->mmu_notifier_seq;
+	smp_rmb();
 	level = mapping_level(vcpu, gfn);
 
 	/*
@@ -2294,8 +2306,6 @@ static int nonpaging_map(struct kvm_vcpu
 
 	gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
 
-	mmu_seq = vcpu->kvm->mmu_notifier_seq;
-	smp_rmb();
 	pfn = gfn_to_pfn(vcpu->kvm, gfn);
 
 	/* mmio */
@@ -2601,12 +2611,12 @@ static int tdp_page_fault(struct kvm_vcp
 	if (r)
 		return r;
 
-	level = mapping_level(vcpu, gfn);
-
-	gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
-
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
+	level = mapping_level(vcpu, gfn);
+
+	gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
+
 	pfn = gfn_to_pfn(vcpu->kvm, gfn);
 	if (is_error_pfn(pfn))
 		return kvm_handle_bad_page(vcpu->kvm, gfn, pfn);
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -561,13 +561,13 @@ static int FNAME(page_fault)(struct kvm_
 		return 0;
 	}
 
+	mmu_seq = vcpu->kvm->mmu_notifier_seq;
+	smp_rmb();
 	if (walker.level >= PT_DIRECTORY_LEVEL) {
 		level = min(walker.level, mapping_level(vcpu, walker.gfn));
 		walker.gfn = walker.gfn & ~(KVM_PAGES_PER_HPAGE(level) - 1);
 	}
 
-	mmu_seq = vcpu->kvm->mmu_notifier_seq;
-	smp_rmb();
 	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
 
 	/* mmio */
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -301,6 +301,7 @@ void kvm_set_page_dirty(struct page *pag
 void kvm_set_page_accessed(struct page *page);
 
 pfn_t hva_to_pfn_atomic(struct kvm *kvm, unsigned long addr);
+pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic);
 pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn);
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
 pfn_t gfn_to_pfn_memslot(struct kvm *kvm,
@@ -325,7 +326,8 @@ int kvm_clear_guest_page(struct kvm *kvm
 int kvm_clear_guest(struct kvm *kvm, gpa_t gpa, unsigned long len);
 struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn);
 int kvm_is_visible_gfn(struct kvm *kvm, gfn_t gfn);
-unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn);
+unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn,
+				 unsigned long *addr);
 void mark_page_dirty(struct kvm *kvm, gfn_t gfn);
 
 void kvm_vcpu_block(struct kvm_vcpu *vcpu);
diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
--- a/virt/kvm/iommu.c
+++ b/virt/kvm/iommu.c
@@ -83,7 +83,7 @@ int kvm_iommu_map_pages(struct kvm *kvm,
 		}
 
 		/* Get the page size we could use to map */
-		page_size = kvm_host_page_size(kvm, gfn);
+		page_size = kvm_host_page_size(kvm, gfn, NULL);
 
 		/* Make sure the page_size does not exceed the memslot */
 		while ((gfn + (page_size >> PAGE_SHIFT)) > end_gfn)
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -102,8 +102,36 @@ static pfn_t fault_pfn;
 inline int kvm_is_mmio_pfn(pfn_t pfn)
 {
 	if (pfn_valid(pfn)) {
-		struct page *page = compound_head(pfn_to_page(pfn));
-		return PageReserved(page);
+		struct page *head;
+		struct page *tail = pfn_to_page(pfn);
+		head = compound_head(tail);
+		if (head != tail) {
+			smp_rmb();
+			/*
+			 * head may be a dangling pointer.
+			 * __split_huge_page_refcount clears PageTail
+			 * before overwriting first_page, so if
+			 * PageTail is still there it means the head
+			 * pointer isn't dangling.
+			 */
+			if (PageTail(tail)) {
+				/*
+				 * the "head" is not a dangling
+				 * pointer but the hugepage may have
+				 * been splitted from under us (and we
+				 * may not hold a reference count on
+				 * the head page so it can be reused
+				 * before we run PageReferenced), so
+				 * we've to recheck PageTail before
+				 * returning what we just read.
+				 */
+				int reserved = PageReserved(head);
+				smp_rmb();
+				if (PageTail(tail))
+					return reserved;
+			}
+		}
+		return PageReserved(tail);
 	}
 
 	return true;
@@ -884,7 +912,8 @@ int kvm_is_visible_gfn(struct kvm *kvm, 
 }
 EXPORT_SYMBOL_GPL(kvm_is_visible_gfn);
 
-unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
+unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn,
+				 unsigned long *addrp)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr, size;
@@ -892,6 +921,8 @@ unsigned long kvm_host_page_size(struct 
 	size = PAGE_SIZE;
 
 	addr = gfn_to_hva(kvm, gfn);
+	if (addrp)
+		*addrp = addr;
 	if (kvm_is_error_hva(addr))
 		return PAGE_SIZE;
 
@@ -946,7 +977,7 @@ unsigned long gfn_to_hva(struct kvm *kvm
 }
 EXPORT_SYMBOL_GPL(gfn_to_hva);
 
-static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic)
+pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic)
 {
 	struct page *page[1];
 	int npages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
