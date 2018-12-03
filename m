Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 329826B6ABE
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 14:25:28 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v12so10794570plp.16
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:25:28 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f63si16103419pfg.136.2018.12.03.11.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 11:25:26 -0800 (PST)
Subject: [PATCH RFC 1/3] kvm: Split use cases for kvm_is_reserved_pfn to
 kvm_is_refcounted_pfn
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 03 Dec 2018 11:25:26 -0800
Message-ID: <154386512606.27193.13867450982940890636.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, pbonzini@redhat.com, yi.z.zhang@linux.intel.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

The function kvm_is_reserved_pfn really has two uses. One is to test for if
we should be updating the reference count on a page when we are accessing
it. The other is to determine if we should be updating the dirty flag or
marking pages as accessed.

In preparation for blurring the lines between ZONE_DEVICE and system RAM I
am splitting out the dirty/accessed cases into their own checks. Doing this
allows us to add ZONE_DEVICE to the list of refcounted pages without having
to worry about us introducing possible issues with pages being marked as
dirty or accessed and possibly causing any issues with attempted LRU
accesses on the ZONE_DEVICE pages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/x86/kvm/mmu.c       |    6 +++---
 include/linux/kvm_host.h |    2 +-
 virt/kvm/kvm_main.c      |   22 +++++++++++++---------
 3 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 7c03c0f35444..7c61cc260c23 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -798,7 +798,7 @@ static int mmu_spte_clear_track_bits(u64 *sptep)
 	 * kvm mmu, before reclaiming the page, we should
 	 * unmap it from mmu first.
 	 */
-	WARN_ON(!kvm_is_reserved_pfn(pfn) && !page_count(pfn_to_page(pfn)));
+	WARN_ON(kvm_is_refcounted_pfn(pfn) && !page_count(pfn_to_page(pfn)));
 
 	if (is_accessed_spte(old_spte))
 		kvm_set_pfn_accessed(pfn);
@@ -3166,7 +3166,7 @@ static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
 	 * PT_PAGE_TABLE_LEVEL and there would be no adjustment done
 	 * here.
 	 */
-	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn) &&
+	if (!is_error_noslot_pfn(pfn) && kvm_is_refcounted_pfn(pfn) &&
 	    level == PT_PAGE_TABLE_LEVEL &&
 	    PageTransCompoundMap(pfn_to_page(pfn)) &&
 	    !mmu_gfn_lpage_is_disallowed(vcpu, gfn, PT_DIRECTORY_LEVEL)) {
@@ -5668,7 +5668,7 @@ static bool kvm_mmu_zap_collapsible_spte(struct kvm *kvm,
 		 * mapping if the indirect sp has level = 1.
 		 */
 		if (sp->role.direct &&
-			!kvm_is_reserved_pfn(pfn) &&
+			kvm_is_refcounted_pfn(pfn) &&
 			PageTransCompoundMap(pfn_to_page(pfn))) {
 			pte_list_remove(rmap_head, sptep);
 			need_tlb_flush = 1;
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index c926698040e0..132e5dbc9049 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -906,7 +906,7 @@ void kvm_arch_sync_events(struct kvm *kvm);
 int kvm_cpu_has_pending_timer(struct kvm_vcpu *vcpu);
 void kvm_vcpu_kick(struct kvm_vcpu *vcpu);
 
-bool kvm_is_reserved_pfn(kvm_pfn_t pfn);
+bool kvm_is_refcounted_pfn(kvm_pfn_t pfn);
 
 struct kvm_irq_ack_notifier {
 	struct hlist_node link;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2679e476b6c3..5e666df5666d 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -146,7 +146,15 @@ __weak int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 	return 0;
 }
 
-bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
+bool kvm_is_refcounted_pfn(kvm_pfn_t pfn)
+{
+	if (pfn_valid(pfn))
+		return !PageReserved(pfn_to_page(pfn));
+
+	return false;
+}
+
+static bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
 {
 	if (pfn_valid(pfn))
 		return PageReserved(pfn_to_page(pfn));
@@ -1678,7 +1686,7 @@ EXPORT_SYMBOL_GPL(kvm_release_page_clean);
 
 void kvm_release_pfn_clean(kvm_pfn_t pfn)
 {
-	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn))
+	if (!is_error_noslot_pfn(pfn) && kvm_is_refcounted_pfn(pfn))
 		put_page(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_release_pfn_clean);
@@ -1700,12 +1708,8 @@ EXPORT_SYMBOL_GPL(kvm_release_pfn_dirty);
 
 void kvm_set_pfn_dirty(kvm_pfn_t pfn)
 {
-	if (!kvm_is_reserved_pfn(pfn)) {
-		struct page *page = pfn_to_page(pfn);
-
-		if (!PageReserved(page))
-			SetPageDirty(page);
-	}
+	if (!kvm_is_reserved_pfn(pfn))
+		SetPageDirty(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_set_pfn_dirty);
 
@@ -1718,7 +1722,7 @@ EXPORT_SYMBOL_GPL(kvm_set_pfn_accessed);
 
 void kvm_get_pfn(kvm_pfn_t pfn)
 {
-	if (!kvm_is_reserved_pfn(pfn))
+	if (kvm_is_refcounted_pfn(pfn))
 		get_page(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_get_pfn);
