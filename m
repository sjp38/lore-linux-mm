Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EDB906B0071
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:09:40 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so3373494wgh.23
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:09:40 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id h8si18102420wjw.13.2014.10.22.04.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 04:09:39 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 12:09:38 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7D0782190043
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:09:12 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9MB9aMF4653534
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:09:36 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9MB9VKU008998
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 05:09:35 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 4/4] s390/mm: disable KSM for storage key enabled pages
Date: Wed, 22 Oct 2014 13:09:30 +0200
Message-Id: <1413976170-42501-5-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

When storage keys are enabled unmerge already merged pages and prevent
new pages from being merged.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h |  2 +-
 arch/s390/kvm/priv.c            | 17 ++++++++++++-----
 arch/s390/mm/pgtable.c          | 16 +++++++++++++++-
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 0da98d6..dfb38af 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1754,7 +1754,7 @@ static inline pte_t mk_swap_pte(unsigned long type, unsigned long offset)
 extern int vmem_add_mapping(unsigned long start, unsigned long size);
 extern int vmem_remove_mapping(unsigned long start, unsigned long size);
 extern int s390_enable_sie(void);
-extern void s390_enable_skey(void);
+extern int s390_enable_skey(void);
 extern void s390_reset_cmma(struct mm_struct *mm);
 
 /*
diff --git a/arch/s390/kvm/priv.c b/arch/s390/kvm/priv.c
index f89c1cd..e0967fd 100644
--- a/arch/s390/kvm/priv.c
+++ b/arch/s390/kvm/priv.c
@@ -156,21 +156,25 @@ static int handle_store_cpu_address(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
-static void __skey_check_enable(struct kvm_vcpu *vcpu)
+static int __skey_check_enable(struct kvm_vcpu *vcpu)
 {
+	int rc = 0;
 	if (!(vcpu->arch.sie_block->ictl & (ICTL_ISKE | ICTL_SSKE | ICTL_RRBE)))
-		return;
+		return rc;
 
-	s390_enable_skey();
+	rc = s390_enable_skey();
 	trace_kvm_s390_skey_related_inst(vcpu);
 	vcpu->arch.sie_block->ictl &= ~(ICTL_ISKE | ICTL_SSKE | ICTL_RRBE);
+	return rc;
 }
 
 
 static int handle_skey(struct kvm_vcpu *vcpu)
 {
-	__skey_check_enable(vcpu);
+	int rc = __skey_check_enable(vcpu);
 
+	if (rc)
+		return rc;
 	vcpu->stat.instruction_storage_key++;
 
 	if (vcpu->arch.sie_block->gpsw.mask & PSW_MASK_PSTATE)
@@ -692,7 +696,10 @@ static int handle_pfmf(struct kvm_vcpu *vcpu)
 		}
 
 		if (vcpu->run->s.regs.gprs[reg1] & PFMF_SK) {
-			__skey_check_enable(vcpu);
+			int rc = __skey_check_enable(vcpu);
+
+			if (rc)
+				return rc;
 			if (set_guest_storage_key(current->mm, useraddr,
 					vcpu->run->s.regs.gprs[reg1] & PFMF_KEY,
 					vcpu->run->s.regs.gprs[reg1] & PFMF_NQ))
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 58d7eb2..82aa528 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -18,6 +18,8 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/swapops.h>
+#include <linux/ksm.h>
+#include <linux/mman.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1328,22 +1330,34 @@ static int __s390_enable_skey(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
-void s390_enable_skey(void)
+int s390_enable_skey(void)
 {
 	struct mm_walk walk = { .pte_entry = __s390_enable_skey };
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	int rc = 0;
 
 	down_write(&mm->mmap_sem);
 	if (mm_use_skey(mm))
 		goto out_up;
 
 	mm->context.use_skey = 1;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (ksm_madvise(vma, vma->vm_start, vma->vm_end,
+				MADV_UNMERGEABLE, &vma->vm_flags)) {
+			mm->context.use_skey = 0;
+			rc = -ENOMEM;
+			goto out_up;
+		}
+	}
+	mm->def_flags &= ~VM_MERGEABLE;
 
 	walk.mm = mm;
 	walk_page_range(0, TASK_SIZE, &walk);
 
 out_up:
 	up_write(&mm->mmap_sem);
+	return rc;
 }
 EXPORT_SYMBOL_GPL(s390_enable_skey);
 
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
