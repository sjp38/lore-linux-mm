Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6606F6B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:45 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 04/12] Add memory slot versioning and use it to provide fast guest write interface
Date: Mon,  4 Oct 2010 17:56:26 +0200
Message-Id: <1286207794-16120-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Keep track of memslots changes by keeping generation number in memslots
structure. Provide kvm_write_guest_cached() function that skips
gfn_to_hva() translation if memslots was not changed since previous
invocation.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 include/linux/kvm_host.h  |    7 +++++
 include/linux/kvm_types.h |    7 +++++
 virt/kvm/kvm_main.c       |   57 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 67 insertions(+), 4 deletions(-)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index a08614e..4dff9a1 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -199,6 +199,7 @@ struct kvm_irq_routing_table {};
 
 struct kvm_memslots {
 	int nmemslots;
+	u32 generation;
 	struct kvm_memory_slot memslots[KVM_MEMORY_SLOTS +
 					KVM_PRIVATE_MEM_SLOTS];
 };
@@ -352,12 +353,18 @@ int kvm_write_guest_page(struct kvm *kvm, gfn_t gfn, const void *data,
 			 int offset, int len);
 int kvm_write_guest(struct kvm *kvm, gpa_t gpa, const void *data,
 		    unsigned long len);
+int kvm_write_guest_cached(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			   void *data, unsigned long len);
+int kvm_gfn_to_hva_cache_init(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			      gpa_t gpa);
 int kvm_clear_guest_page(struct kvm *kvm, gfn_t gfn, int offset, int len);
 int kvm_clear_guest(struct kvm *kvm, gpa_t gpa, unsigned long len);
 struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn);
 int kvm_is_visible_gfn(struct kvm *kvm, gfn_t gfn);
 unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn);
 void mark_page_dirty(struct kvm *kvm, gfn_t gfn);
+void mark_page_dirty_in_slot(struct kvm *kvm, struct kvm_memory_slot *memslot,
+			     gfn_t gfn);
 
 void kvm_vcpu_block(struct kvm_vcpu *vcpu);
 void kvm_vcpu_on_spin(struct kvm_vcpu *vcpu);
diff --git a/include/linux/kvm_types.h b/include/linux/kvm_types.h
index 7ac0d4e..ee6eb71 100644
--- a/include/linux/kvm_types.h
+++ b/include/linux/kvm_types.h
@@ -67,4 +67,11 @@ struct kvm_lapic_irq {
 	u32 dest_id;
 };
 
+struct gfn_to_hva_cache {
+	u32 generation;
+	gpa_t gpa;
+	unsigned long hva;
+	struct kvm_memory_slot *memslot;
+};
+
 #endif /* __KVM_TYPES_H__ */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index db58a1b..45ef50c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -687,6 +687,7 @@ skip_lpage:
 		memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
 		if (mem->slot >= slots->nmemslots)
 			slots->nmemslots = mem->slot + 1;
+		slots->generation++;
 		slots->memslots[mem->slot].flags |= KVM_MEMSLOT_INVALID;
 
 		old_memslots = kvm->memslots;
@@ -723,6 +724,7 @@ skip_lpage:
 	memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
 	if (mem->slot >= slots->nmemslots)
 		slots->nmemslots = mem->slot + 1;
+	slots->generation++;
 
 	/* actual memory is freed via old in kvm_free_physmem_slot below */
 	if (!npages) {
@@ -1247,6 +1249,47 @@ int kvm_write_guest(struct kvm *kvm, gpa_t gpa, const void *data,
 	return 0;
 }
 
+int kvm_gfn_to_hva_cache_init(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			      gpa_t gpa)
+{
+	struct kvm_memslots *slots = kvm_memslots(kvm);
+	int offset = offset_in_page(gpa);
+	gfn_t gfn = gpa >> PAGE_SHIFT;
+
+	ghc->gpa = gpa;
+	ghc->generation = slots->generation;
+	ghc->memslot = gfn_to_memslot(kvm, gfn);
+	ghc->hva = gfn_to_hva(kvm, gfn);
+	if (!kvm_is_error_hva(ghc->hva))
+		ghc->hva += offset;
+	else
+		return -EFAULT;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(kvm_gfn_to_hva_cache_init);
+
+int kvm_write_guest_cached(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			   void *data, unsigned long len)
+{
+	struct kvm_memslots *slots = kvm_memslots(kvm);
+	int r;
+
+	if (slots->generation != ghc->generation)
+		kvm_gfn_to_hva_cache_init(kvm, ghc, ghc->gpa);
+	
+	if (kvm_is_error_hva(ghc->hva))
+		return -EFAULT;
+
+	r = copy_to_user((void __user *)ghc->hva, data, len);
+	if (r)
+		return -EFAULT;
+	mark_page_dirty_in_slot(kvm, ghc->memslot, ghc->gpa >> PAGE_SHIFT);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(kvm_write_guest_cached);
+
 int kvm_clear_guest_page(struct kvm *kvm, gfn_t gfn, int offset, int len)
 {
 	return kvm_write_guest_page(kvm, gfn, empty_zero_page, offset, len);
@@ -1272,11 +1315,9 @@ int kvm_clear_guest(struct kvm *kvm, gpa_t gpa, unsigned long len)
 }
 EXPORT_SYMBOL_GPL(kvm_clear_guest);
 
-void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
+void mark_page_dirty_in_slot(struct kvm *kvm, struct kvm_memory_slot *memslot,
+			     gfn_t gfn)
 {
-	struct kvm_memory_slot *memslot;
-
-	memslot = gfn_to_memslot(kvm, gfn);
 	if (memslot && memslot->dirty_bitmap) {
 		unsigned long rel_gfn = gfn - memslot->base_gfn;
 
@@ -1284,6 +1325,14 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
 	}
 }
 
+void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
+{
+	struct kvm_memory_slot *memslot;
+
+	memslot = gfn_to_memslot(kvm, gfn);
+	mark_page_dirty_in_slot(kvm, memslot, gfn);
+}
+
 /*
  * The vCPU has executed a HLT instruction with in-kernel mode enabled.
  */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
