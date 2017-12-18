Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB1C6B0271
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c9so9960204wrb.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:17 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id e21si6574977wrg.395.2017.12.18.11.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:15 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 07/18] kvm: page track: add support for preread, prewrite and preexec
Date: Mon, 18 Dec 2017 21:06:31 +0200
Message-Id: <20171218190642.7790-8-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

These callbacks return a boolean value. If false, the emulation should
stop and the instruction should be reexecuted in guest. The preread
callback can return the bytes needed by the read operation.

The kvm_page_track_create_memslot() was extended in order to track gfn-s
as soon as the memory slots are created.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/include/asm/kvm_page_track.h |  24 +++++-
 arch/x86/kvm/mmu.c                    | 143 ++++++++++++++++++++++++++++++----
 arch/x86/kvm/mmu.h                    |   4 +
 arch/x86/kvm/page_track.c             | 129 ++++++++++++++++++++++++++++--
 arch/x86/kvm/x86.c                    |   2 +-
 5 files changed, 281 insertions(+), 21 deletions(-)

diff --git a/arch/x86/include/asm/kvm_page_track.h b/arch/x86/include/asm/kvm_page_track.h
index 172f9749dbb2..77adc7f43754 100644
--- a/arch/x86/include/asm/kvm_page_track.h
+++ b/arch/x86/include/asm/kvm_page_track.h
@@ -3,8 +3,11 @@
 #define _ASM_X86_KVM_PAGE_TRACK_H
 
 enum kvm_page_track_mode {
+	KVM_PAGE_TRACK_PREREAD,
+	KVM_PAGE_TRACK_PREWRITE,
 	KVM_PAGE_TRACK_WRITE,
-	KVM_PAGE_TRACK_MAX,
+	KVM_PAGE_TRACK_PREEXEC,
+	KVM_PAGE_TRACK_MAX
 };
 
 /*
@@ -22,6 +25,13 @@ struct kvm_page_track_notifier_head {
 struct kvm_page_track_notifier_node {
 	struct hlist_node node;
 
+	bool (*track_preread)(struct kvm_vcpu *vcpu, gpa_t gpa, u8 *new,
+			      int bytes,
+			      struct kvm_page_track_notifier_node *node,
+			      bool *data_ready);
+	bool (*track_prewrite)(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
+			       int bytes,
+			       struct kvm_page_track_notifier_node *node);
 	/*
 	 * It is called when guest is writing the write-tracked page
 	 * and write emulation is finished at that time.
@@ -34,6 +44,11 @@ struct kvm_page_track_notifier_node {
 	 */
 	void (*track_write)(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
 			    int bytes, struct kvm_page_track_notifier_node *node);
+	bool (*track_preexec)(struct kvm_vcpu *vcpu, gpa_t gpa,
+			      struct kvm_page_track_notifier_node *node);
+	void (*track_create_slot)(struct kvm *kvm, struct kvm_memory_slot *slot,
+				  unsigned long npages,
+				  struct kvm_page_track_notifier_node *node);
 	/*
 	 * It is called when memory slot is being moved or removed
 	 * users can drop write-protection for the pages in that memory slot
@@ -51,7 +66,7 @@ void kvm_page_track_cleanup(struct kvm *kvm);
 
 void kvm_page_track_free_memslot(struct kvm_memory_slot *free,
 				 struct kvm_memory_slot *dont);
-int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
+int kvm_page_track_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages);
 
 void kvm_slot_page_track_add_page(struct kvm *kvm,
@@ -69,7 +84,12 @@ kvm_page_track_register_notifier(struct kvm *kvm,
 void
 kvm_page_track_unregister_notifier(struct kvm *kvm,
 				   struct kvm_page_track_notifier_node *n);
+bool kvm_page_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa, u8 *new,
+			    int bytes, bool *data_ready);
+bool kvm_page_track_prewrite(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
+			     int bytes);
 void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
 			  int bytes);
+bool kvm_page_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa);
 void kvm_page_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot);
 #endif
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 55fcb0292724..19dc17b00db2 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -1014,9 +1014,13 @@ static void account_shadowed(struct kvm *kvm, struct kvm_mmu_page *sp)
 	slot = __gfn_to_memslot(slots, gfn);
 
 	/* the non-leaf shadow pages are keeping readonly. */
-	if (sp->role.level > PT_PAGE_TABLE_LEVEL)
-		return kvm_slot_page_track_add_page(kvm, slot, gfn,
-						    KVM_PAGE_TRACK_WRITE);
+	if (sp->role.level > PT_PAGE_TABLE_LEVEL) {
+		kvm_slot_page_track_add_page(kvm, slot, gfn,
+					     KVM_PAGE_TRACK_PREWRITE);
+		kvm_slot_page_track_add_page(kvm, slot, gfn,
+					     KVM_PAGE_TRACK_WRITE);
+		return;
+	}
 
 	kvm_mmu_gfn_disallow_lpage(slot, gfn);
 }
@@ -1031,9 +1035,13 @@ static void unaccount_shadowed(struct kvm *kvm, struct kvm_mmu_page *sp)
 	gfn = sp->gfn;
 	slots = kvm_memslots_for_spte_role(kvm, sp->role);
 	slot = __gfn_to_memslot(slots, gfn);
-	if (sp->role.level > PT_PAGE_TABLE_LEVEL)
-		return kvm_slot_page_track_remove_page(kvm, slot, gfn,
-						       KVM_PAGE_TRACK_WRITE);
+	if (sp->role.level > PT_PAGE_TABLE_LEVEL) {
+		kvm_slot_page_track_remove_page(kvm, slot, gfn,
+						KVM_PAGE_TRACK_PREWRITE);
+		kvm_slot_page_track_remove_page(kvm, slot, gfn,
+						KVM_PAGE_TRACK_WRITE);
+		return;
+	}
 
 	kvm_mmu_gfn_allow_lpage(slot, gfn);
 }
@@ -1416,6 +1424,29 @@ static bool spte_write_protect(u64 *sptep, bool pt_protect)
 	return mmu_spte_update(sptep, spte);
 }
 
+static bool spte_read_protect(u64 *sptep)
+{
+	u64 spte = *sptep;
+
+	rmap_printk("rmap_read_protect: spte %p %llx\n", sptep, *sptep);
+
+	/* TODO: verify if the CPU supports EPT-execute-only */
+	spte = spte & ~(PT_WRITABLE_MASK | PT_PRESENT_MASK);
+
+	return mmu_spte_update(sptep, spte);
+}
+
+static bool spte_exec_protect(u64 *sptep, bool pt_protect)
+{
+	u64 spte = *sptep;
+
+	rmap_printk("rmap_exec_protect: spte %p %llx\n", sptep, *sptep);
+
+	spte = spte & ~PT_USER_MASK;
+
+	return mmu_spte_update(sptep, spte);
+}
+
 static bool __rmap_write_protect(struct kvm *kvm,
 				 struct kvm_rmap_head *rmap_head,
 				 bool pt_protect)
@@ -1430,6 +1461,34 @@ static bool __rmap_write_protect(struct kvm *kvm,
 	return flush;
 }
 
+static bool __rmap_read_protect(struct kvm *kvm,
+				struct kvm_rmap_head *rmap_head,
+				bool pt_protect)
+{
+	u64 *sptep;
+	struct rmap_iterator iter;
+	bool flush = false;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep)
+		flush |= spte_read_protect(sptep);
+
+	return flush;
+}
+
+static bool __rmap_exec_protect(struct kvm *kvm,
+				struct kvm_rmap_head *rmap_head,
+				bool pt_protect)
+{
+	u64 *sptep;
+	struct rmap_iterator iter;
+	bool flush = false;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep)
+		flush |= spte_exec_protect(sptep, pt_protect);
+
+	return flush;
+}
+
 static bool spte_clear_dirty(u64 *sptep)
 {
 	u64 spte = *sptep;
@@ -1600,6 +1659,36 @@ bool kvm_mmu_slot_gfn_write_protect(struct kvm *kvm,
 	return write_protected;
 }
 
+bool kvm_mmu_slot_gfn_read_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	int i;
+	bool read_protected = false;
+
+	for (i = PT_PAGE_TABLE_LEVEL; i <= PT_MAX_HUGEPAGE_LEVEL; ++i) {
+		rmap_head = __gfn_to_rmap(gfn, i, slot);
+		read_protected |= __rmap_read_protect(kvm, rmap_head, true);
+	}
+
+	return read_protected;
+}
+
+bool kvm_mmu_slot_gfn_exec_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	int i;
+	bool exec_protected = false;
+
+	for (i = PT_PAGE_TABLE_LEVEL; i <= PT_MAX_HUGEPAGE_LEVEL; ++i) {
+		rmap_head = __gfn_to_rmap(gfn, i, slot);
+		exec_protected |= __rmap_exec_protect(kvm, rmap_head, true);
+	}
+
+	return exec_protected;
+}
+
 static bool rmap_write_protect(struct kvm_vcpu *vcpu, u64 gfn)
 {
 	struct kvm_memory_slot *slot;
@@ -2688,7 +2777,8 @@ static bool mmu_need_write_protect(struct kvm_vcpu *vcpu, gfn_t gfn,
 {
 	struct kvm_mmu_page *sp;
 
-	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
+	    kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
 		return true;
 
 	for_each_gfn_indirect_valid_sp(vcpu->kvm, sp, gfn) {
@@ -2953,6 +3043,21 @@ static void direct_pte_prefetch(struct kvm_vcpu *vcpu, u64 *sptep)
 	__direct_pte_prefetch(vcpu, sp, sptep);
 }
 
+static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gfn_t gfn)
+{
+	unsigned int acc = ACC_ALL;
+
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
+		acc &= ~ACC_USER_MASK;
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
+	    kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+		acc &= ~ACC_WRITE_MASK;
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREEXEC))
+		acc &= ~ACC_EXEC_MASK;
+
+	return acc;
+}
+
 static int __direct_map(struct kvm_vcpu *vcpu, int write, int map_writable,
 			int level, gfn_t gfn, kvm_pfn_t pfn, bool prefault)
 {
@@ -2966,7 +3071,9 @@ static int __direct_map(struct kvm_vcpu *vcpu, int write, int map_writable,
 
 	for_each_shadow_entry(vcpu, (u64)gfn << PAGE_SHIFT, iterator) {
 		if (iterator.level == level) {
-			emulate = mmu_set_spte(vcpu, iterator.sptep, ACC_ALL,
+			unsigned int acc = kvm_mmu_page_track_acc(vcpu, gfn);
+
+			emulate = mmu_set_spte(vcpu, iterator.sptep, acc,
 					       write, level, gfn, pfn, prefault,
 					       map_writable);
 			direct_pte_prefetch(vcpu, iterator.sptep);
@@ -3713,15 +3820,21 @@ static bool page_fault_handle_page_track(struct kvm_vcpu *vcpu,
 	if (unlikely(error_code & PFERR_RSVD_MASK))
 		return false;
 
-	if (!(error_code & PFERR_PRESENT_MASK) ||
-	      !(error_code & PFERR_WRITE_MASK))
+	if (!(error_code & PFERR_PRESENT_MASK))
 		return false;
 
 	/*
-	 * guest is writing the page which is write tracked which can
+	 * guest is reading/writing/fetching the page which is
+	 * read/write/execute tracked which can
 	 * not be fixed by page fault handler.
 	 */
-	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+	if (((error_code & PFERR_USER_MASK)
+		&& kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
+	    || ((error_code & PFERR_WRITE_MASK)
+		&& (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE)
+		 || kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE)))
+	    || ((error_code & PFERR_FETCH_MASK)
+		&& kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREEXEC)))
 		return true;
 
 	return false;
@@ -4942,7 +5055,11 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u64 error_code,
 	 * and resume the guest.
 	 */
 	if (vcpu->arch.mmu.direct_map &&
-	    (error_code & PFERR_NESTED_GUEST_PAGE) == PFERR_NESTED_GUEST_PAGE) {
+	    (error_code & PFERR_NESTED_GUEST_PAGE) == PFERR_NESTED_GUEST_PAGE &&
+	    !kvm_page_track_is_active(vcpu, gpa_to_gfn(cr2), KVM_PAGE_TRACK_PREREAD) &&
+	    !kvm_page_track_is_active(vcpu, gpa_to_gfn(cr2), KVM_PAGE_TRACK_PREWRITE) &&
+	    !kvm_page_track_is_active(vcpu, gpa_to_gfn(cr2), KVM_PAGE_TRACK_WRITE) &&
+	    !kvm_page_track_is_active(vcpu, gpa_to_gfn(cr2), KVM_PAGE_TRACK_PREEXEC)) {
 		kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(cr2));
 		return 1;
 	}
diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
index 5b408c0ad612..57c947752490 100644
--- a/arch/x86/kvm/mmu.h
+++ b/arch/x86/kvm/mmu.h
@@ -193,5 +193,9 @@ void kvm_mmu_gfn_disallow_lpage(struct kvm_memory_slot *slot, gfn_t gfn);
 void kvm_mmu_gfn_allow_lpage(struct kvm_memory_slot *slot, gfn_t gfn);
 bool kvm_mmu_slot_gfn_write_protect(struct kvm *kvm,
 				    struct kvm_memory_slot *slot, u64 gfn);
+bool kvm_mmu_slot_gfn_read_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn);
+bool kvm_mmu_slot_gfn_exec_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn);
 int kvm_arch_write_log_dirty(struct kvm_vcpu *vcpu);
 #endif
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index 01c1371f39f8..8bf6581d25d5 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -34,10 +34,13 @@ void kvm_page_track_free_memslot(struct kvm_memory_slot *free,
 		}
 }
 
-int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
+int kvm_page_track_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages)
 {
-	int  i;
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	int i;
 
 	for (i = 0; i < KVM_PAGE_TRACK_MAX; i++) {
 		slot->arch.gfn_track[i] = kvzalloc(npages *
@@ -46,6 +49,17 @@ int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
 			goto track_free;
 	}
 
+	head = &kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return 0;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_create_slot)
+			n->track_create_slot(kvm, slot, npages, n);
+	srcu_read_unlock(&head->track_srcu, idx);
+
 	return 0;
 
 track_free:
@@ -86,7 +100,7 @@ static void update_gfn_track(struct kvm_memory_slot *slot, gfn_t gfn,
  * @kvm: the guest instance we are interested in.
  * @slot: the @gfn belongs to.
  * @gfn: the guest page.
- * @mode: tracking mode, currently only write track is supported.
+ * @mode: tracking mode.
  */
 void kvm_slot_page_track_add_page(struct kvm *kvm,
 				  struct kvm_memory_slot *slot, gfn_t gfn,
@@ -104,9 +118,16 @@ void kvm_slot_page_track_add_page(struct kvm *kvm,
 	 */
 	kvm_mmu_gfn_disallow_lpage(slot, gfn);
 
-	if (mode == KVM_PAGE_TRACK_WRITE)
+	if (mode == KVM_PAGE_TRACK_PREWRITE || mode == KVM_PAGE_TRACK_WRITE) {
 		if (kvm_mmu_slot_gfn_write_protect(kvm, slot, gfn))
 			kvm_flush_remote_tlbs(kvm);
+	} else if (mode == KVM_PAGE_TRACK_PREREAD) {
+		if (kvm_mmu_slot_gfn_read_protect(kvm, slot, gfn))
+			kvm_flush_remote_tlbs(kvm);
+	} else if (mode == KVM_PAGE_TRACK_PREEXEC) {
+		if (kvm_mmu_slot_gfn_exec_protect(kvm, slot, gfn))
+			kvm_flush_remote_tlbs(kvm);
+	}
 }
 EXPORT_SYMBOL_GPL(kvm_slot_page_track_add_page);
 
@@ -121,7 +142,7 @@ EXPORT_SYMBOL_GPL(kvm_slot_page_track_add_page);
  * @kvm: the guest instance we are interested in.
  * @slot: the @gfn belongs to.
  * @gfn: the guest page.
- * @mode: tracking mode, currently only write track is supported.
+ * @mode: tracking mode.
  */
 void kvm_slot_page_track_remove_page(struct kvm *kvm,
 				     struct kvm_memory_slot *slot, gfn_t gfn,
@@ -214,6 +235,75 @@ kvm_page_track_unregister_notifier(struct kvm *kvm,
 }
 EXPORT_SYMBOL_GPL(kvm_page_track_unregister_notifier);
 
+/*
+ * Notify the node that a read access is about to happen. Returning false
+ * doesn't stop the other nodes from being called, but it will stop
+ * the emulation.
+ *
+ * The node should figure out if the written page is the one that node is
+ * interested in by itself.
+ *
+ * The nodes will always be in conflict if they track the same page:
+ * - accepting a read won't guarantee that the next node will not override
+ *   the data (filling new/bytes and setting data_ready)
+ * - filling new/bytes with custom data won't guarantee that the next node
+ *   will not override that
+ */
+bool kvm_page_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa, u8 *new,
+			    int bytes, bool *data_ready)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	*data_ready = false;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_preread)
+			if (!n->track_preread(vcpu, gpa, new, bytes, n,
+					       data_ready))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
+/*
+ * Notify the node that an write access is about to happen. Returning false
+ * doesn't stop the other nodes from being called, but it will stop
+ * the emulation.
+ *
+ * The node should figure out if the written page is the one that node is
+ * interested in by itself.
+ */
+bool kvm_page_track_prewrite(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
+			     int bytes)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_prewrite)
+			if (!n->track_prewrite(vcpu, gpa, new, bytes, n))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
 /*
  * Notify the node that write access is intercepted and write emulation is
  * finished at this time.
@@ -240,6 +330,35 @@ void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
 	srcu_read_unlock(&head->track_srcu, idx);
 }
 
+/*
+ * Notify the node that an instruction is about to be executed.
+ * Returning false doesn't stop the other nodes from being called,
+ * but it will stop the emulation with ?!.
+ *
+ * The node should figure out if the written page is the one that node is
+ * interested in by itself.
+ */
+bool kvm_page_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_preexec)
+			if (!n->track_preexec(vcpu, gpa, n))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
 /*
  * Notify the node that memory slot is being removed or moved so that it can
  * drop write-protection for the pages in the memory slot.
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e7db70ac1f82..74839859c0fd 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8421,7 +8421,7 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 		}
 	}
 
-	if (kvm_page_track_create_memslot(slot, npages))
+	if (kvm_page_track_create_memslot(kvm, slot, npages))
 		goto out_free;
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
