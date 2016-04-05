Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 886036B02A2
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:39:32 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so18378161pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:39:32 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ez9si10145699pab.20.2016.04.05.14.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:39:31 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id fe3so18430101pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:39:31 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:39:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 16/31] kvm: plumb return of hva when resolving page fault.
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051437080.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

So we don't have to redo this work later. Note the hva is not racy,
it is simple arithmetic based on the memslot.

This will be used in the huge tmpfs commits.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Cc'ed to kvm@vger.kernel.org as an FYI: this patch is not expected to
go into the tree in the next few weeks.  The context is a huge tmpfs
patchset which implements huge pagecache transparently on tmpfs,
using a team of small pages rather than one compound page:
please refer to linux-mm or linux-kernel for more context.

 arch/x86/kvm/mmu.c         |   20 ++++++++++++++------
 arch/x86/kvm/paging_tmpl.h |    3 ++-
 include/linux/kvm_host.h   |    2 +-
 virt/kvm/kvm_main.c        |   14 ++++++++------
 4 files changed, 25 insertions(+), 14 deletions(-)

--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2992,7 +2992,8 @@ exit:
 }
 
 static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
-			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable);
+			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable,
+			 unsigned long *hva);
 static void make_mmu_pages_available(struct kvm_vcpu *vcpu);
 
 static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, u32 error_code,
@@ -3003,6 +3004,7 @@ static int nonpaging_map(struct kvm_vcpu
 	bool force_pt_level = false;
 	kvm_pfn_t pfn;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	bool map_writable, write = error_code & PFERR_WRITE_MASK;
 
 	level = mapping_level(vcpu, gfn, &force_pt_level);
@@ -3024,7 +3026,8 @@ static int nonpaging_map(struct kvm_vcpu
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write, &map_writable))
+	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write,
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, v, gfn, pfn, ACC_ALL, &r))
@@ -3487,14 +3490,16 @@ static bool can_do_async_pf(struct kvm_v
 }
 
 static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
-			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable)
+			 gva_t gva, kvm_pfn_t *pfn, bool write, bool *writable,
+			 unsigned long *hva)
 {
 	struct kvm_memory_slot *slot;
 	bool async;
 
 	slot = kvm_vcpu_gfn_to_memslot(vcpu, gfn);
 	async = false;
-	*pfn = __gfn_to_pfn_memslot(slot, gfn, false, &async, write, writable);
+	*pfn = __gfn_to_pfn_memslot(slot, gfn,
+				    false, &async, write, writable, hva);
 	if (!async)
 		return false; /* *pfn has correct page already */
 
@@ -3508,7 +3513,8 @@ static bool try_async_pf(struct kvm_vcpu
 			return true;
 	}
 
-	*pfn = __gfn_to_pfn_memslot(slot, gfn, false, NULL, write, writable);
+	*pfn = __gfn_to_pfn_memslot(slot, gfn,
+				    false, NULL, write, writable, hva);
 	return false;
 }
 
@@ -3531,6 +3537,7 @@ static int tdp_page_fault(struct kvm_vcp
 	bool force_pt_level;
 	gfn_t gfn = gpa >> PAGE_SHIFT;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	int write = error_code & PFERR_WRITE_MASK;
 	bool map_writable;
 
@@ -3559,7 +3566,8 @@ static int tdp_page_fault(struct kvm_vcp
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, prefault, gfn, gpa, &pfn, write, &map_writable))
+	if (try_async_pf(vcpu, prefault, gfn, gpa, &pfn, write,
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, 0, gfn, pfn, ACC_ALL, &r))
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -712,6 +712,7 @@ static int FNAME(page_fault)(struct kvm_
 	int level = PT_PAGE_TABLE_LEVEL;
 	bool force_pt_level = false;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	bool map_writable, is_self_change_mapping;
 
 	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
@@ -765,7 +766,7 @@ static int FNAME(page_fault)(struct kvm_
 	smp_rmb();
 
 	if (try_async_pf(vcpu, prefault, walker.gfn, addr, &pfn, write_fault,
-			 &map_writable))
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, mmu_is_nested(vcpu) ? 0 : addr,
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -600,7 +600,7 @@ kvm_pfn_t gfn_to_pfn_memslot(struct kvm_
 kvm_pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn);
 kvm_pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn,
 			       bool atomic, bool *async, bool write_fault,
-			       bool *writable);
+			       bool *writable, unsigned long *hva);
 
 void kvm_release_pfn_clean(kvm_pfn_t pfn);
 void kvm_set_pfn_dirty(kvm_pfn_t pfn);
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1444,7 +1444,7 @@ exit:
 
 kvm_pfn_t __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn,
 			       bool atomic, bool *async, bool write_fault,
-			       bool *writable)
+			       bool *writable, unsigned long *hva)
 {
 	unsigned long addr = __gfn_to_hva_many(slot, gfn, NULL, write_fault);
 
@@ -1466,8 +1466,10 @@ kvm_pfn_t __gfn_to_pfn_memslot(struct kv
 		writable = NULL;
 	}
 
-	return hva_to_pfn(addr, atomic, async, write_fault,
-			  writable);
+	if (hva)
+		*hva = addr;
+
+	return hva_to_pfn(addr, atomic, async, write_fault, writable);
 }
 EXPORT_SYMBOL_GPL(__gfn_to_pfn_memslot);
 
@@ -1475,19 +1477,19 @@ kvm_pfn_t gfn_to_pfn_prot(struct kvm *kv
 		      bool *writable)
 {
 	return __gfn_to_pfn_memslot(gfn_to_memslot(kvm, gfn), gfn, false, NULL,
-				    write_fault, writable);
+				    write_fault, writable, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_prot);
 
 kvm_pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn)
 {
-	return __gfn_to_pfn_memslot(slot, gfn, false, NULL, true, NULL);
+	return __gfn_to_pfn_memslot(slot, gfn, false, NULL, true, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_memslot);
 
 kvm_pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn)
 {
-	return __gfn_to_pfn_memslot(slot, gfn, true, NULL, true, NULL);
+	return __gfn_to_pfn_memslot(slot, gfn, true, NULL, true, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_memslot_atomic);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
