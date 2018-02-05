Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD156B005A
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:09 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v17so18511684pgb.18
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18-v6si6030227pll.186.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 32/64] arch/s390: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:22 +0100
Message-Id: <20180205012754.23615-33-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/s390/kernel/vdso.c  |  5 +++--
 arch/s390/kvm/gaccess.c  |  4 ++--
 arch/s390/kvm/kvm-s390.c | 24 ++++++++++++++----------
 arch/s390/kvm/priv.c     | 29 +++++++++++++++++------------
 arch/s390/mm/fault.c     |  6 +++---
 arch/s390/mm/gmap.c      | 45 ++++++++++++++++++++++++---------------------
 arch/s390/pci/pci_mmio.c |  5 +++--
 7 files changed, 66 insertions(+), 52 deletions(-)

diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index f3a1c7c6824e..0395c6b906fd 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -213,6 +213,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!vdso_enabled)
 		return 0;
@@ -239,7 +240,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * it at vdso_base which is the "natural" base for it, but we might
 	 * fail and end up putting it elsewhere.
 	 */
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, 0, vdso_pages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
@@ -270,7 +271,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	rc = 0;
 
 out_up:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return rc;
 }
 
diff --git a/arch/s390/kvm/gaccess.c b/arch/s390/kvm/gaccess.c
index ff739b86df36..28c2c14319c8 100644
--- a/arch/s390/kvm/gaccess.c
+++ b/arch/s390/kvm/gaccess.c
@@ -1179,7 +1179,7 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 	int rc;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&sg->mm->mmap_sem);
+	mm_read_lock(sg->mm, &mmrange);
 	/*
 	 * We don't want any guest-2 tables to change - so the parent
 	 * tables/pointers we read stay valid - unshadowing is however
@@ -1209,6 +1209,6 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 	if (!rc)
 		rc = gmap_shadow_page(sg, saddr, __pte(pte.val), &mmrange);
 	ipte_unlock(vcpu);
-	up_read(&sg->mm->mmap_sem);
+	mm_read_unlock(sg->mm, &mmrange);
 	return rc;
 }
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index ba4c7092335a..942aeb6cbf1c 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -1420,6 +1420,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 {
 	uint8_t *keys;
 	uint64_t hva;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	int srcu_idx, i, r = 0;
 
 	if (args->flags != 0)
@@ -1437,7 +1438,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 	if (!keys)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
 	for (i = 0; i < args->count; i++) {
 		hva = gfn_to_hva(kvm, args->start_gfn + i);
@@ -1451,7 +1452,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 			break;
 	}
 	srcu_read_unlock(&kvm->srcu, srcu_idx);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	if (!r) {
 		r = copy_to_user((uint8_t __user *)args->skeydata_addr, keys,
@@ -1468,6 +1469,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 {
 	uint8_t *keys;
 	uint64_t hva;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	int srcu_idx, i, r = 0;
 
 	if (args->flags != 0)
@@ -1493,7 +1495,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 	if (r)
 		goto out;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
 	for (i = 0; i < args->count; i++) {
 		hva = gfn_to_hva(kvm, args->start_gfn + i);
@@ -1513,7 +1515,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 			break;
 	}
 	srcu_read_unlock(&kvm->srcu, srcu_idx);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 out:
 	kvfree(keys);
 	return r;
@@ -1543,6 +1545,7 @@ static int kvm_s390_get_cmma_bits(struct kvm *kvm,
 	unsigned long bufsize, hva, pgstev, i, next, cur;
 	int srcu_idx, peek, r = 0, rr;
 	u8 *res;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	cur = args->start_gfn;
 	i = next = pgstev = 0;
@@ -1586,7 +1589,7 @@ static int kvm_s390_get_cmma_bits(struct kvm *kvm,
 
 	args->start_gfn = cur;
 
-	down_read(&kvm->mm->mmap_sem);
+	mm_read_lock(kvm->mm, &mmrange);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
 	while (i < bufsize) {
 		hva = gfn_to_hva(kvm, cur);
@@ -1620,7 +1623,7 @@ static int kvm_s390_get_cmma_bits(struct kvm *kvm,
 		cur++;
 	}
 	srcu_read_unlock(&kvm->srcu, srcu_idx);
-	up_read(&kvm->mm->mmap_sem);
+	mm_read_unlock(kvm->mm, &mmrange);
 	args->count = i;
 	args->remaining = s ? atomic64_read(&s->dirty_pages) : 0;
 
@@ -1643,6 +1646,7 @@ static int kvm_s390_set_cmma_bits(struct kvm *kvm,
 	unsigned long hva, mask, pgstev, i;
 	uint8_t *bits;
 	int srcu_idx, r = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mask = args->mask;
 
@@ -1668,7 +1672,7 @@ static int kvm_s390_set_cmma_bits(struct kvm *kvm,
 		goto out;
 	}
 
-	down_read(&kvm->mm->mmap_sem);
+	mm_read_lock(kvm->mm, &mmrange);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
 	for (i = 0; i < args->count; i++) {
 		hva = gfn_to_hva(kvm, args->start_gfn + i);
@@ -1683,12 +1687,12 @@ static int kvm_s390_set_cmma_bits(struct kvm *kvm,
 		set_pgste_bits(kvm->mm, hva, mask, pgstev);
 	}
 	srcu_read_unlock(&kvm->srcu, srcu_idx);
-	up_read(&kvm->mm->mmap_sem);
+	mm_read_unlock(kvm->mm, &mmrange);
 
 	if (!kvm->mm->context.use_cmma) {
-		down_write(&kvm->mm->mmap_sem);
+		mm_write_lock(kvm->mm, &mmrange);
 		kvm->mm->context.use_cmma = 1;
-		up_write(&kvm->mm->mmap_sem);
+		mm_write_unlock(kvm->mm, &mmrange);
 	}
 out:
 	vfree(bits);
diff --git a/arch/s390/kvm/priv.c b/arch/s390/kvm/priv.c
index c4c4e157c036..7bb37eca557e 100644
--- a/arch/s390/kvm/priv.c
+++ b/arch/s390/kvm/priv.c
@@ -246,6 +246,7 @@ static int handle_iske(struct kvm_vcpu *vcpu)
 	unsigned char key;
 	int reg1, reg2;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	vcpu->stat.instruction_iske++;
 
@@ -265,9 +266,9 @@ static int handle_iske(struct kvm_vcpu *vcpu)
 	if (kvm_is_error_hva(addr))
 		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	rc = get_guest_storage_key(current->mm, addr, &key);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	if (rc)
 		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 	vcpu->run->s.regs.gprs[reg1] &= ~0xff;
@@ -280,6 +281,7 @@ static int handle_rrbe(struct kvm_vcpu *vcpu)
 	unsigned long addr;
 	int reg1, reg2;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	vcpu->stat.instruction_rrbe++;
 
@@ -299,9 +301,9 @@ static int handle_rrbe(struct kvm_vcpu *vcpu)
 	if (kvm_is_error_hva(addr))
 		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	rc = reset_guest_reference_bit(current->mm, addr);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	if (rc < 0)
 		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 
@@ -351,16 +353,17 @@ static int handle_sske(struct kvm_vcpu *vcpu)
 	}
 
 	while (start != end) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 		unsigned long addr = gfn_to_hva(vcpu->kvm, gpa_to_gfn(start));
 
 		if (kvm_is_error_hva(addr))
 			return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		rc = cond_set_guest_storage_key(current->mm, addr, key, &oldkey,
 						m3 & SSKE_NQ, m3 & SSKE_MR,
 						m3 & SSKE_MC);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		if (rc < 0)
 			return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 		start += PAGE_SIZE;
@@ -953,13 +956,14 @@ static int handle_pfmf(struct kvm_vcpu *vcpu)
 
 		if (vcpu->run->s.regs.gprs[reg1] & PFMF_SK) {
 			int rc = kvm_s390_skey_check_enable(vcpu);
+			DEFINE_RANGE_LOCK_FULL(mmrange);
 
 			if (rc)
 				return rc;
-			down_read(&current->mm->mmap_sem);
+			mm_read_lock(current->mm, &mmrange);
 			rc = cond_set_guest_storage_key(current->mm, useraddr,
 							key, NULL, nq, mr, mc);
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			if (rc < 0)
 				return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
 		}
@@ -1046,6 +1050,7 @@ static int handle_essa(struct kvm_vcpu *vcpu)
 	unsigned long *cbrlo;
 	struct gmap *gmap;
 	int i, orc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	VCPU_EVENT(vcpu, 4, "ESSA: release %d pages", entries);
 	gmap = vcpu->arch.gmap;
@@ -1073,9 +1078,9 @@ static int handle_essa(struct kvm_vcpu *vcpu)
 		 * already correct, we do nothing and avoid the lock.
 		 */
 		if (vcpu->kvm->mm->context.use_cmma == 0) {
-			down_write(&vcpu->kvm->mm->mmap_sem);
+			mm_write_lock(vcpu->kvm->mm, &mmrange);
 			vcpu->kvm->mm->context.use_cmma = 1;
-			up_write(&vcpu->kvm->mm->mmap_sem);
+			mm_write_unlock(vcpu->kvm->mm, &mmrange);
 		}
 		/*
 		 * If we are here, we are supposed to have CMMA enabled in
@@ -1098,10 +1103,10 @@ static int handle_essa(struct kvm_vcpu *vcpu)
 	}
 	vcpu->arch.sie_block->cbrlo &= PAGE_MASK;	/* reset nceo */
 	cbrlo = phys_to_virt(vcpu->arch.sie_block->cbrlo);
-	down_read(&gmap->mm->mmap_sem);
+	mm_read_lock(gmap->mm, &mmrange);
 	for (i = 0; i < entries; ++i)
 		__gmap_zap(gmap, cbrlo[i]);
-	up_read(&gmap->mm->mmap_sem);
+	mm_read_unlock(gmap->mm, &mmrange);
 	return 0;
 }
 
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 17ba3c402f9d..0d6b63fa629e 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -463,7 +463,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 		flags |= FAULT_FLAG_USER;
 	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
 		flags |= FAULT_FLAG_WRITE;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	gmap = NULL;
 	if (IS_ENABLED(CONFIG_PGSTE) && type == GMAP_FAULT) {
@@ -546,7 +546,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 			flags &= ~(FAULT_FLAG_ALLOW_RETRY |
 				   FAULT_FLAG_RETRY_NOWAIT);
 			flags |= FAULT_FLAG_TRIED;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			goto retry;
 		}
 	}
@@ -564,7 +564,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	}
 	fault = 0;
 out_up:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 out:
 	return fault;
 }
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index b12a44813022..9419ae7b7f56 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -395,6 +395,7 @@ int gmap_unmap_segment(struct gmap *gmap, unsigned long to, unsigned long len)
 {
 	unsigned long off;
 	int flush;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(gmap_is_shadow(gmap));
 	if ((to | len) & (PMD_SIZE - 1))
@@ -403,10 +404,10 @@ int gmap_unmap_segment(struct gmap *gmap, unsigned long to, unsigned long len)
 		return -EINVAL;
 
 	flush = 0;
-	down_write(&gmap->mm->mmap_sem);
+	mm_write_lock(gmap->mm, &mmrange);
 	for (off = 0; off < len; off += PMD_SIZE)
 		flush |= __gmap_unmap_by_gaddr(gmap, to + off);
-	up_write(&gmap->mm->mmap_sem);
+	mm_write_unlock(gmap->mm, &mmrange);
 	if (flush)
 		gmap_flush_tlb(gmap);
 	return 0;
@@ -427,6 +428,7 @@ int gmap_map_segment(struct gmap *gmap, unsigned long from,
 {
 	unsigned long off;
 	int flush;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(gmap_is_shadow(gmap));
 	if ((from | to | len) & (PMD_SIZE - 1))
@@ -436,7 +438,7 @@ int gmap_map_segment(struct gmap *gmap, unsigned long from,
 		return -EINVAL;
 
 	flush = 0;
-	down_write(&gmap->mm->mmap_sem);
+	mm_write_lock(gmap->mm, &mmrange);
 	for (off = 0; off < len; off += PMD_SIZE) {
 		/* Remove old translation */
 		flush |= __gmap_unmap_by_gaddr(gmap, to + off);
@@ -446,7 +448,7 @@ int gmap_map_segment(struct gmap *gmap, unsigned long from,
 				      (void *) from + off))
 			break;
 	}
-	up_write(&gmap->mm->mmap_sem);
+	mm_write_unlock(gmap->mm, &mmrange);
 	if (flush)
 		gmap_flush_tlb(gmap);
 	if (off >= len)
@@ -492,10 +494,11 @@ EXPORT_SYMBOL_GPL(__gmap_translate);
 unsigned long gmap_translate(struct gmap *gmap, unsigned long gaddr)
 {
 	unsigned long rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&gmap->mm->mmap_sem);
+	mm_read_lock(gmap->mm, &mmrange);
 	rc = __gmap_translate(gmap, gaddr);
-	up_read(&gmap->mm->mmap_sem);
+	mm_read_unlock(gmap->mm, &mmrange);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(gmap_translate);
@@ -623,8 +626,7 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 	bool unlocked;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&gmap->mm->mmap_sem);
-
+	mm_read_lock(gmap->mm, &mmrange);
 retry:
 	unlocked = false;
 	vmaddr = __gmap_translate(gmap, gaddr);
@@ -646,7 +648,7 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 
 	rc = __gmap_link(gmap, gaddr, vmaddr);
 out_up:
-	up_read(&gmap->mm->mmap_sem);
+	mm_read_unlock(gmap->mm, &mmrange);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(gmap_fault);
@@ -678,8 +680,9 @@ void gmap_discard(struct gmap *gmap, unsigned long from, unsigned long to)
 {
 	unsigned long gaddr, vmaddr, size;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&gmap->mm->mmap_sem);
+	mm_read_lock(gmap->mm, &mmrange);
 	for (gaddr = from; gaddr < to;
 	     gaddr = (gaddr + PMD_SIZE) & PMD_MASK) {
 		/* Find the vm address for the guest address */
@@ -694,7 +697,7 @@ void gmap_discard(struct gmap *gmap, unsigned long from, unsigned long to)
 		size = min(to - gaddr, PMD_SIZE - (gaddr & ~PMD_MASK));
 		zap_page_range(vma, vmaddr, size);
 	}
-	up_read(&gmap->mm->mmap_sem);
+	mm_read_unlock(gmap->mm, &mmrange);
 }
 EXPORT_SYMBOL_GPL(gmap_discard);
 
@@ -942,9 +945,9 @@ int gmap_mprotect_notify(struct gmap *gmap, unsigned long gaddr,
 		return -EINVAL;
 	if (!MACHINE_HAS_ESOP && prot == PROT_READ)
 		return -EINVAL;
-	down_read(&gmap->mm->mmap_sem);
+	mm_read_lock(gmap->mm, &mmrange);
 	rc = gmap_protect_range(gmap, gaddr, len, prot, PGSTE_IN_BIT, &mmrange);
-	up_read(&gmap->mm->mmap_sem);
+	mm_read_unlock(gmap->mm, &mmrange);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(gmap_mprotect_notify);
@@ -1536,11 +1539,11 @@ struct gmap *gmap_shadow(struct gmap *parent, unsigned long asce,
 	}
 	spin_unlock(&parent->shadow_lock);
 	/* protect after insertion, so it will get properly invalidated */
-	down_read(&parent->mm->mmap_sem);
+	mm_read_lock(parent->mm, &mmrange);
 	rc = gmap_protect_range(parent, asce & _ASCE_ORIGIN,
 				((asce & _ASCE_TABLE_LENGTH) + 1) * PAGE_SIZE,
 				PROT_READ, PGSTE_VSIE_BIT, &mmrange);
-	up_read(&parent->mm->mmap_sem);
+	mm_read_unlock(parent->mm, &mmrange);
 	spin_lock(&parent->shadow_lock);
 	new->initialized = true;
 	if (rc) {
@@ -2176,12 +2179,12 @@ int s390_enable_sie(void)
 	/* Fail if the page tables are 2K */
 	if (!mm_alloc_pgste(mm))
 		return -EINVAL;
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	mm->context.has_pgste = 1;
 	/* split thp mappings and disable thp for future mappings */
 	thp_split_mm(mm);
 	zap_zero_pages(mm, &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(s390_enable_sie);
@@ -2206,7 +2209,7 @@ int s390_enable_skey(void)
 	int rc = 0;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	if (mm_use_skey(mm))
 		goto out_up;
 
@@ -2225,7 +2228,7 @@ int s390_enable_skey(void)
 	walk_page_range(0, TASK_SIZE, &walk, &mmrange);
 
 out_up:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(s390_enable_skey);
@@ -2245,9 +2248,9 @@ void s390_reset_cmma(struct mm_struct *mm)
 	struct mm_walk walk = { .pte_entry = __s390_reset_cmma };
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	walk.mm = mm;
 	walk_page_range(0, TASK_SIZE, &walk, &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 }
 EXPORT_SYMBOL_GPL(s390_reset_cmma);
diff --git a/arch/s390/pci/pci_mmio.c b/arch/s390/pci/pci_mmio.c
index 7d42a8794f10..bea541d5e181 100644
--- a/arch/s390/pci/pci_mmio.c
+++ b/arch/s390/pci/pci_mmio.c
@@ -17,8 +17,9 @@ static long get_pfn(unsigned long user_addr, unsigned long access,
 {
 	struct vm_area_struct *vma;
 	long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	ret = -EINVAL;
 	vma = find_vma(current->mm, user_addr);
 	if (!vma)
@@ -28,7 +29,7 @@ static long get_pfn(unsigned long user_addr, unsigned long access,
 		goto out;
 	ret = follow_pfn(vma, user_addr, pfn);
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return ret;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
