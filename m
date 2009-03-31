Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 437F26B0047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:09 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 2/3] kvm: add SPTE_HOST_WRITEABLE flag to the shadow ptes.
Date: Tue, 31 Mar 2009 03:00:03 +0300
Message-Id: <1238457604-7637-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457604-7637-2-git-send-email-ieidus@redhat.com>
References: <1238457604-7637-1-git-send-email-ieidus@redhat.com>
 <1238457604-7637-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

this flag notify that the host physical page we are pointing to from
the spte is write protected, and therefore we cant change its access
to be write unless we run get_user_pages(write = 1).

(this is needed for change_pte support in kvm)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 arch/x86/kvm/mmu.c         |   14 ++++++++++----
 arch/x86/kvm/paging_tmpl.h |   16 +++++++++++++---
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index df8fbaf..6b4d795 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -138,6 +138,8 @@ module_param(oos_shadow, bool, 0644);
 #define ACC_USER_MASK    PT_USER_MASK
 #define ACC_ALL          (ACC_EXEC_MASK | ACC_WRITE_MASK | ACC_USER_MASK)
 
+#define SPTE_HOST_WRITEABLE (1ULL << PT_FIRST_AVAIL_BITS_SHIFT)
+
 #define SHADOW_PT_INDEX(addr, level) PT64_INDEX(addr, level)
 
 struct kvm_rmap_desc {
@@ -1676,7 +1678,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *shadow_pte,
 		    unsigned pte_access, int user_fault,
 		    int write_fault, int dirty, int largepage,
 		    int global, gfn_t gfn, pfn_t pfn, bool speculative,
-		    bool can_unsync)
+		    bool can_unsync, bool reset_host_protection)
 {
 	u64 spte;
 	int ret = 0;
@@ -1719,6 +1721,8 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *shadow_pte,
 				kvm_x86_ops->get_mt_mask_shift();
 		spte |= mt_mask;
 	}
+	if (reset_host_protection)
+		spte |= SPTE_HOST_WRITEABLE;
 
 	spte |= (u64)pfn << PAGE_SHIFT;
 
@@ -1764,7 +1768,8 @@ static void mmu_set_spte(struct kvm_vcpu *vcpu, u64 *shadow_pte,
 			 unsigned pt_access, unsigned pte_access,
 			 int user_fault, int write_fault, int dirty,
 			 int *ptwrite, int largepage, int global,
-			 gfn_t gfn, pfn_t pfn, bool speculative)
+			 gfn_t gfn, pfn_t pfn, bool speculative,
+			 bool reset_host_protection)
 {
 	int was_rmapped = 0;
 	int was_writeble = is_writeble_pte(*shadow_pte);
@@ -1793,7 +1798,8 @@ static void mmu_set_spte(struct kvm_vcpu *vcpu, u64 *shadow_pte,
 			was_rmapped = 1;
 	}
 	if (set_spte(vcpu, shadow_pte, pte_access, user_fault, write_fault,
-		      dirty, largepage, global, gfn, pfn, speculative, true)) {
+		      dirty, largepage, global, gfn, pfn, speculative, true,
+		      reset_host_protection)) {
 		if (write_fault)
 			*ptwrite = 1;
 		kvm_x86_ops->tlb_flush(vcpu);
@@ -1840,7 +1846,7 @@ static int __direct_map(struct kvm_vcpu *vcpu, gpa_t v, int write,
 		    || (largepage && iterator.level == PT_DIRECTORY_LEVEL)) {
 			mmu_set_spte(vcpu, iterator.sptep, ACC_ALL, ACC_ALL,
 				     0, write, 1, &pt_write,
-				     largepage, 0, gfn, pfn, false);
+				     largepage, 0, gfn, pfn, false, true);
 			++vcpu->stat.pf_fixed;
 			break;
 		}
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index eae9499..9fdacd0 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -259,10 +259,14 @@ static void FNAME(update_pte)(struct kvm_vcpu *vcpu, struct kvm_mmu_page *page,
 	if (mmu_notifier_retry(vcpu, vcpu->arch.update_pte.mmu_seq))
 		return;
 	kvm_get_pfn(pfn);
+	/*
+	 * we call mmu_set_spte() with reset_host_protection = true beacuse that
+	 * vcpu->arch.update_pte.pfn was fetched from get_user_pages(write = 1).
+	 */
 	mmu_set_spte(vcpu, spte, page->role.access, pte_access, 0, 0,
 		     gpte & PT_DIRTY_MASK, NULL, largepage,
 		     gpte & PT_GLOBAL_MASK, gpte_to_gfn(gpte),
-		     pfn, true);
+		     pfn, true, true);
 }
 
 /*
@@ -297,7 +301,7 @@ static u64 *FNAME(fetch)(struct kvm_vcpu *vcpu, gva_t addr,
 				     gw->ptes[gw->level-1] & PT_DIRTY_MASK,
 				     ptwrite, largepage,
 				     gw->ptes[gw->level-1] & PT_GLOBAL_MASK,
-				     gw->gfn, pfn, false);
+				     gw->gfn, pfn, false, true);
 			break;
 		}
 
@@ -547,6 +551,7 @@ static void FNAME(prefetch_page)(struct kvm_vcpu *vcpu,
 static int FNAME(sync_page)(struct kvm_vcpu *vcpu, struct kvm_mmu_page *sp)
 {
 	int i, offset, nr_present;
+        bool reset_host_protection = 1;
 
 	offset = nr_present = 0;
 
@@ -584,9 +589,14 @@ static int FNAME(sync_page)(struct kvm_vcpu *vcpu, struct kvm_mmu_page *sp)
 
 		nr_present++;
 		pte_access = sp->role.access & FNAME(gpte_access)(vcpu, gpte);
+		if (!(sp->spt[i] & SPTE_HOST_WRITEABLE)) {
+			pte_access &= ~PT_WRITABLE_MASK;
+                        reset_host_protection = 0;
+                }
 		set_spte(vcpu, &sp->spt[i], pte_access, 0, 0,
 			 is_dirty_pte(gpte), 0, gpte & PT_GLOBAL_MASK, gfn,
-			 spte_to_pfn(sp->spt[i]), true, false);
+			 spte_to_pfn(sp->spt[i]), true, false,
+                         reset_host_protection);
 	}
 
 	return !nr_present;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
