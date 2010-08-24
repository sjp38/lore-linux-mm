Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4C5666B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:28:35 -0400 (EDT)
Date: Tue, 24 Aug 2010 15:28:44 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
Message-ID: <20100824122844.GA10499@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
 <1279553462-7036-9-git-send-email-gleb@redhat.com>
 <4C729F10.40005@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C729F10.40005@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 07:17:20PM +0300, Avi Kivity wrote:
> >
> >+static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> >+{
> >+	if (unlikely(vcpu->arch.apf_memslot_ver !=
> >+		     vcpu->kvm->memslot_version)) {
> >+		u64 gpa = vcpu->arch.apf_msr_val&  ~0x3f;
> >+		unsigned long addr;
> >+		int offset = offset_in_page(gpa);
> >+
> >+		addr = gfn_to_hva(vcpu->kvm, gpa>>  PAGE_SHIFT);
> >+		vcpu->arch.apf_data = (u32 __user *)(addr + offset);
> >+		if (kvm_is_error_hva(addr)) {
> >+			vcpu->arch.apf_data = NULL;
> >+			return -EFAULT;
> >+		}
> >+	}
> >+
> >+	return put_user(val, vcpu->arch.apf_data);
> >+}
> 
> This nice cache needs to be outside apf to reduce complexity for
> reviewers and since it is useful for others.
> 
> Would be good to have memslot-cached kvm_put_guest() and kvm_get_guest().
> 
Something like this? (only compile tested)


diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index c13cc48..9aa3dd2 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -168,10 +168,18 @@ struct kvm_irq_routing_table {};
 
 struct kvm_memslots {
 	int nmemslots;
+	u32 generation;
 	struct kvm_memory_slot memslots[KVM_MEMORY_SLOTS +
 					KVM_PRIVATE_MEM_SLOTS];
 };
 
+struct gfn_to_hva_cache {
+	u32 generation;
+	gpa_t gpa;
+	unsigned long hva;
+	struct kvm_memory_slot *memslot;
+};
+
 struct kvm {
 	spinlock_t mmu_lock;
 	raw_spinlock_t requests_lock;
@@ -315,12 +323,16 @@ int kvm_write_guest_page(struct kvm *kvm, gfn_t gfn, const void *data,
 			 int offset, int len);
 int kvm_write_guest(struct kvm *kvm, gpa_t gpa, const void *data,
 		    unsigned long len);
+int kvm_write_guest_cached(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			   void *data, unsigned long len);
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
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index b78b794..512cf9b 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -685,6 +685,7 @@ skip_lpage:
 		memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
 		if (mem->slot >= slots->nmemslots)
 			slots->nmemslots = mem->slot + 1;
+		slots->generation++;
 		slots->memslots[mem->slot].flags |= KVM_MEMSLOT_INVALID;
 
 		old_memslots = kvm->memslots;
@@ -721,6 +722,7 @@ skip_lpage:
 	memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
 	if (mem->slot >= slots->nmemslots)
 		slots->nmemslots = mem->slot + 1;
+	slots->generation++;
 
 	/* actual memory is freed via old in kvm_free_physmem_slot below */
 	if (!npages) {
@@ -1175,6 +1177,36 @@ int kvm_write_guest(struct kvm *kvm, gpa_t gpa, const void *data,
 	return 0;
 }
 
+int kvm_write_guest_cached(struct kvm *kvm, struct gfn_to_hva_cache *ghc,
+			   void *data, unsigned long len)
+{
+	int r;
+	gfn_t gfn = ghc->gpa >> PAGE_SHIFT;
+	struct kvm_memslots *slots = kvm_memslots(kvm);
+
+	if (slots->generation != ghc->generation) {
+		int offset = offset_in_page(ghc->gpa);
+
+		ghc->hva = gfn_to_hva(kvm, gfn);
+		if (!kvm_is_error_hva(ghc->hva))
+			ghc->hva += offset;
+		ghc->generation = slots->generation;
+
+		ghc->memslot = gfn_to_memslot(kvm, gfn);
+	}
+	
+	if (kvm_is_error_hva(ghc->hva))
+		return -EFAULT;
+
+	r = copy_to_user((void __user *)ghc->hva, data, len);
+	if (r)
+		return -EFAULT;
+	mark_page_dirty_in_slot(kvm, ghc->memslot, gfn);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(kvm_write_guest_cached);
+
 int kvm_clear_guest_page(struct kvm *kvm, gfn_t gfn, int offset, int len)
 {
 	return kvm_write_guest_page(kvm, gfn, empty_zero_page, offset, len);
@@ -1200,11 +1232,9 @@ int kvm_clear_guest(struct kvm *kvm, gpa_t gpa, unsigned long len)
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
 
@@ -1212,6 +1242,14 @@ void mark_page_dirty(struct kvm *kvm, gfn_t gfn)
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
