Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4B0DD5F0047
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:22:40 -0400 (EDT)
Date: Mon, 18 Oct 2010 15:22:23 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v7 04/12] Add memory slot versioning and use it to
 provide fast guest write interface
Message-ID: <20101018132223.GB10207@redhat.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
 <1287048176-2563-5-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287048176-2563-5-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Keep track of memslots changes by keeping generation number in memslots
structure. Provide kvm_write_guest_cached() function that skips
gfn_to_hva() translation if memslots was not changed since previous
invocation.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---

arch/x86/kvm/x86.c also changes slots. Forgot to update generation
there.

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index bee71ec..bcc48bc 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3193,6 +3193,7 @@ int kvm_vm_ioctl_get_dirty_log(struct kvm *kvm,
 		}
 		memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
 		slots->memslots[log->slot].dirty_bitmap = dirty_bitmap;
+		slots->generation++;
 
 		old_slots = kvm->memslots;
 		rcu_assign_pointer(kvm->memslots, slots);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 9a9b017..dda88f2 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -199,6 +199,7 @@ struct kvm_irq_routing_table {};
 
 struct kvm_memslots {
 	int nmemslots;
+	u64 generation;
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
index 7ac0d4e..fa7cc72 100644
--- a/include/linux/kvm_types.h
+++ b/include/linux/kvm_types.h
@@ -67,4 +67,11 @@ struct kvm_lapic_irq {
 	u32 dest_id;
 };
 
+struct gfn_to_hva_cache {
+	u64 generation;
+	gpa_t gpa;
+	unsigned long hva;
+	struct kvm_memory_slot *memslot;
+};
+
 #endif /* __KVM_TYPES_H__ */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 238079e..5d57ec9 100644
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
@@ -853,10 +855,10 @@ int kvm_is_error_hva(unsigned long addr)
 }
 EXPORT_SYMBOL_GPL(kvm_is_error_hva);
 
-struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn)
+static struct kvm_memory_slot *__gfn_to_memslot(struct kvm_memslots *slots,
+						gfn_t gfn)
 {
 	int i;
-	struct kvm_memslots *slots = kvm_memslots(kvm);
 
 	for (i = 0; i < slots->nmemslots; ++i) {
 		struct kvm_memory_slot *memslot = &slots->memslots[i];
@@ -867,6 +869,11 @@ struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn)
 	}
 	return NULL;
 }
+
+struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn)
+{
+	return __gfn_to_memslot(kvm_memslots(kvm), gfn);
+}
 EXPORT_SYMBOL_GPL(gfn_to_memslot);
 
 int kvm_is_visible_gfn(struct kvm *kvm, gfn_t gfn)
@@ -929,12 +936,9 @@ int memslot_id(struct kvm *kvm, gfn_t gfn)
 	return memslot - slots->memslots;
 }
 
-static unsigned long gfn_to_hva_many(struct kvm *kvm, gfn_t gfn,
+static unsigned long gfn_to_hva_many(struct kvm_memory_slot *slot, gfn_t gfn,
 				     gfn_t *nr_pages)
 {
-	struct kvm_memory_slot *slot;
-
-	slot = gfn_to_memslot(kvm, gfn);
 	if (!slot || slot->flags & KVM_MEMSLOT_INVALID)
 		return bad_hva();
 
@@ -946,7 +950,7 @@ static unsigned long gfn_to_hva_many(struct kvm *kvm, gfn_t gfn,
 
 unsigned long gfn_to_hva(struct kvm *kvm, gfn_t gfn)
 {
-	return gfn_to_hva_many(kvm, gfn, NULL);
+	return gfn_to_hva_many(gfn_to_memslot(kvm, gfn), gfn, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_hva);
 
@@ -1063,7 +1067,7 @@ int gfn_to_page_many_atomic(struct kvm *kvm, gfn_t gfn, struct page **pages,
 	unsigned long addr;
 	gfn_t entry;
 
-	addr = gfn_to_hva_many(kvm, gfn, &entry);
+	addr = gfn_to_hva_many(gfn_to_memslot(kvm, gfn), gfn, &entry);
 	if (kvm_is_error_hva(addr))
 		return -1;
 
@@ -1247,6 +1251,47 @@ int kvm_write_guest(struct kvm *kvm, gpa_t gpa, const void *data,
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
+	ghc->memslot = __gfn_to_memslot(slots, gfn);
+	ghc->hva = gfn_to_hva_many(ghc->memslot, gfn, NULL);
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
@@ -1272,11 +1317,9 @@ int kvm_clear_guest(struct kvm *kvm, gpa_t gpa, unsigned long len)
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
 
@@ -1284,6 +1327,14 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
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
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
