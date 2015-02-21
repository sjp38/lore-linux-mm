Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 882696B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:29:28 -0500 (EST)
Received: by pdjg10 with SMTP id g10so12187255pdj.1
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:29:28 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id gz1si11191146pbd.38.2015.02.20.20.29.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:29:27 -0800 (PST)
Received: by pabkq14 with SMTP id kq14so12996243pab.3
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:29:27 -0800 (PST)
Date: Fri, 20 Feb 2015 20:29:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 23/24] kvm: plumb return of hva when resolving page fault.
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202027150.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

So we don't have to redo this work later. Note the hva is not racy, it
is simple arithmetic based on the memslot.

This will be used in the huge tmpfs commits.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/x86/kvm/mmu.c         |   16 +++++++++++-----
 arch/x86/kvm/paging_tmpl.h |    3 ++-
 include/linux/kvm_host.h   |    2 +-
 virt/kvm/kvm_main.c        |   24 ++++++++++++++----------
 4 files changed, 28 insertions(+), 17 deletions(-)

--- thpfs.orig/arch/x86/kvm/mmu.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/arch/x86/kvm/mmu.c	2015-02-20 19:35:20.095835839 -0800
@@ -2907,7 +2907,8 @@ exit:
 }
 
 static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
-			 gva_t gva, pfn_t *pfn, bool write, bool *writable);
+			 gva_t gva, pfn_t *pfn, bool write, bool *writable,
+			 unsigned long *hva);
 static void make_mmu_pages_available(struct kvm_vcpu *vcpu);
 
 static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, u32 error_code,
@@ -2918,6 +2919,7 @@ static int nonpaging_map(struct kvm_vcpu
 	int force_pt_level;
 	pfn_t pfn;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	bool map_writable, write = error_code & PFERR_WRITE_MASK;
 
 	force_pt_level = mapping_level_dirty_bitmap(vcpu, gfn);
@@ -2941,7 +2943,8 @@ static int nonpaging_map(struct kvm_vcpu
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write, &map_writable))
+	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write,
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, v, gfn, pfn, ACC_ALL, &r))
@@ -3360,11 +3363,12 @@ static bool can_do_async_pf(struct kvm_v
 }
 
 static bool try_async_pf(struct kvm_vcpu *vcpu, bool prefault, gfn_t gfn,
-			 gva_t gva, pfn_t *pfn, bool write, bool *writable)
+			 gva_t gva, pfn_t *pfn, bool write, bool *writable,
+			 unsigned long *hva)
 {
 	bool async;
 
-	*pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async, write, writable);
+	*pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async, write, writable, hva);
 
 	if (!async)
 		return false; /* *pfn has correct page already */
@@ -3393,6 +3397,7 @@ static int tdp_page_fault(struct kvm_vcp
 	int force_pt_level;
 	gfn_t gfn = gpa >> PAGE_SHIFT;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	int write = error_code & PFERR_WRITE_MASK;
 	bool map_writable;
 
@@ -3423,7 +3428,8 @@ static int tdp_page_fault(struct kvm_vcp
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
-	if (try_async_pf(vcpu, prefault, gfn, gpa, &pfn, write, &map_writable))
+	if (try_async_pf(vcpu, prefault, gfn, gpa, &pfn, write,
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, 0, gfn, pfn, ACC_ALL, &r))
--- thpfs.orig/arch/x86/kvm/paging_tmpl.h	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/arch/x86/kvm/paging_tmpl.h	2015-02-20 19:35:20.095835839 -0800
@@ -709,6 +709,7 @@ static int FNAME(page_fault)(struct kvm_
 	int level = PT_PAGE_TABLE_LEVEL;
 	int force_pt_level;
 	unsigned long mmu_seq;
+	unsigned long hva;
 	bool map_writable, is_self_change_mapping;
 
 	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
@@ -759,7 +760,7 @@ static int FNAME(page_fault)(struct kvm_
 	smp_rmb();
 
 	if (try_async_pf(vcpu, prefault, walker.gfn, addr, &pfn, write_fault,
-			 &map_writable))
+			 &map_writable, &hva))
 		return 0;
 
 	if (handle_abnormal_pfn(vcpu, mmu_is_nested(vcpu) ? 0 : addr,
--- thpfs.orig/include/linux/kvm_host.h	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/include/linux/kvm_host.h	2015-02-20 19:35:20.095835839 -0800
@@ -554,7 +554,7 @@ void kvm_set_page_accessed(struct page *
 
 pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn);
 pfn_t gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, bool *async,
-		       bool write_fault, bool *writable);
+		       bool write_fault, bool *writable, unsigned long *hva);
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn);
 pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
 		      bool *writable);
--- thpfs.orig/virt/kvm/kvm_main.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/virt/kvm/kvm_main.c	2015-02-20 19:35:20.095835839 -0800
@@ -1328,7 +1328,8 @@ exit:
 
 static pfn_t
 __gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn, bool atomic,
-		     bool *async, bool write_fault, bool *writable)
+		     bool *async, bool write_fault, bool *writable,
+		     unsigned long *hva)
 {
 	unsigned long addr = __gfn_to_hva_many(slot, gfn, NULL, write_fault);
 
@@ -1344,12 +1345,15 @@ __gfn_to_pfn_memslot(struct kvm_memory_s
 		writable = NULL;
 	}
 
+	if (hva)
+		*hva = addr;
+
 	return hva_to_pfn(addr, atomic, async, write_fault,
 			  writable);
 }
 
 static pfn_t __gfn_to_pfn(struct kvm *kvm, gfn_t gfn, bool atomic, bool *async,
-			  bool write_fault, bool *writable)
+			  bool write_fault, bool *writable, unsigned long *hva)
 {
 	struct kvm_memory_slot *slot;
 
@@ -1359,43 +1363,43 @@ static pfn_t __gfn_to_pfn(struct kvm *kv
 	slot = gfn_to_memslot(kvm, gfn);
 
 	return __gfn_to_pfn_memslot(slot, gfn, atomic, async, write_fault,
-				    writable);
+				    writable, hva);
 }
 
 pfn_t gfn_to_pfn_atomic(struct kvm *kvm, gfn_t gfn)
 {
-	return __gfn_to_pfn(kvm, gfn, true, NULL, true, NULL);
+	return __gfn_to_pfn(kvm, gfn, true, NULL, true, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_atomic);
 
 pfn_t gfn_to_pfn_async(struct kvm *kvm, gfn_t gfn, bool *async,
-		       bool write_fault, bool *writable)
+		       bool write_fault, bool *writable, unsigned long *hva)
 {
-	return __gfn_to_pfn(kvm, gfn, false, async, write_fault, writable);
+	return __gfn_to_pfn(kvm, gfn, false, async, write_fault, writable, hva);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_async);
 
 pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t gfn)
 {
-	return __gfn_to_pfn(kvm, gfn, false, NULL, true, NULL);
+	return __gfn_to_pfn(kvm, gfn, false, NULL, true, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn);
 
 pfn_t gfn_to_pfn_prot(struct kvm *kvm, gfn_t gfn, bool write_fault,
 		      bool *writable)
 {
-	return __gfn_to_pfn(kvm, gfn, false, NULL, write_fault, writable);
+	return __gfn_to_pfn(kvm, gfn, false, NULL, write_fault, writable, NULL);
 }
 EXPORT_SYMBOL_GPL(gfn_to_pfn_prot);
 
 pfn_t gfn_to_pfn_memslot(struct kvm_memory_slot *slot, gfn_t gfn)
 {
-	return __gfn_to_pfn_memslot(slot, gfn, false, NULL, true, NULL);
+	return __gfn_to_pfn_memslot(slot, gfn, false, NULL, true, NULL, NULL);
 }
 
 pfn_t gfn_to_pfn_memslot_atomic(struct kvm_memory_slot *slot, gfn_t gfn)
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
