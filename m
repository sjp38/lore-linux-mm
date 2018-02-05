Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5066B02B5
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:34:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 79so18601814pge.16
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:34:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a33-v6si3954577pld.666.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 16/64] virt: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:06 +0100
Message-Id: <20180205012754.23615-17-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 virt/kvm/arm/mmu.c  | 17 ++++++++++-------
 virt/kvm/async_pf.c |  4 ++--
 virt/kvm/kvm_main.c |  9 +++++----
 3 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index ec62d1cccab7..9a866a639c2c 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -815,9 +815,10 @@ void stage2_unmap_vm(struct kvm *kvm)
 	struct kvm_memslots *slots;
 	struct kvm_memory_slot *memslot;
 	int idx;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	idx = srcu_read_lock(&kvm->srcu);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	spin_lock(&kvm->mmu_lock);
 
 	slots = kvm_memslots(kvm);
@@ -825,7 +826,7 @@ void stage2_unmap_vm(struct kvm *kvm)
 		stage2_unmap_memslot(kvm, memslot);
 
 	spin_unlock(&kvm->mmu_lock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
@@ -1317,6 +1318,7 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 	pgprot_t mem_type = PAGE_S2;
 	bool logging_active = memslot_is_logging(memslot);
 	unsigned long flags = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	write_fault = kvm_is_write_fault(vcpu);
 	exec_fault = kvm_vcpu_trap_is_iabt(vcpu);
@@ -1328,11 +1330,11 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 	}
 
 	/* Let's check if we will get back a huge page backed by hugetlbfs */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma_intersection(current->mm, hva, hva + 1);
 	if (unlikely(!vma)) {
 		kvm_err("Failed to find VMA for hva 0x%lx\n", hva);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		return -EFAULT;
 	}
 
@@ -1353,7 +1355,7 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 		    ((memslot->base_gfn << PAGE_SHIFT) & ~PMD_MASK))
 			force_pte = true;
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	/* We need minimum second+third level pages */
 	ret = mmu_topup_memory_cache(memcache, KVM_MMU_CACHE_MIN_PAGES,
@@ -1889,6 +1891,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 	hva_t reg_end = hva + mem->memory_size;
 	bool writable = !(mem->flags & KVM_MEM_READONLY);
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (change != KVM_MR_CREATE && change != KVM_MR_MOVE &&
 			change != KVM_MR_FLAGS_ONLY)
@@ -1902,7 +1905,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 	    (KVM_PHYS_SIZE >> PAGE_SHIFT))
 		return -EFAULT;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	/*
 	 * A memory region could potentially cover multiple VMAs, and any holes
 	 * between them, so iterate over all of them to find out if we can map
@@ -1970,7 +1973,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 		stage2_flush_memslot(kvm, memslot);
 	spin_unlock(&kvm->mmu_lock);
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return ret;
 }
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 4cd2b93bb20c..ed559789d7cb 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -87,11 +87,11 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * access remotely.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
 			      &locked, &mmrange);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 	kvm_async_page_present_sync(vcpu, apf);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 86ec078f4c3b..92fd944e7e3a 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1222,6 +1222,7 @@ EXPORT_SYMBOL_GPL(kvm_is_visible_gfn);
 unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long addr, size;
 
 	size = PAGE_SIZE;
@@ -1230,7 +1231,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	if (kvm_is_error_hva(addr))
 		return PAGE_SIZE;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		goto out;
@@ -1238,7 +1239,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	size = vma_kernel_pagesize(vma);
 
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return size;
 }
@@ -1494,7 +1495,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (npages == 1)
 		return pfn;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	if (npages == -EHWPOISON ||
 	    (!async && check_user_page_hwpoison(addr, &mmrange))) {
 		pfn = KVM_PFN_ERR_HWPOISON;
@@ -1519,7 +1520,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 		pfn = KVM_PFN_ERR_FAULT;
 	}
 exit:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return pfn;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
