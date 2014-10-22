Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id BD9F96B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:30:45 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so634409wib.9
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:30:45 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id r2si1016882wia.37.2014.10.22.01.30.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 01:30:44 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 09:30:43 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id BA2791B0806B
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:30:41 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9M8Ufo464225464
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:30:41 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9M8Ue9X015896
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 02:30:41 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/4] s390/mm: prevent and break zero page mappings in case of storage keys
Date: Wed, 22 Oct 2014 10:30:23 +0200
Message-Id: <1413966624-12447-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

As soon as storage keys are enabled we need to stop working on zero page
mappings to prevent inconsistencies between storage keys and pgste.

Otherwise following data corruption could happen:
1) guest enables storage key
2) guest sets storage key for not mapped page X
   -> change goes to PGSTE
3) guest reads from page X
   -> as X was not dirty before, the page will be zero page backed,
      storage key from PGSTE for X will go to storage key for zero page
4) guest sets storage key for not mapped page Y (same logic as above
5) guest reads from page Y
   -> as Y was not dirty before, the page will be zero page backed,
      storage key from PGSTE for Y will got to storage key for zero page
      overwriting storage key for X

While holding the mmap sem, we are safe against changes on entries we
already fixed, as every fault would need to take the mmap_sem (read).
As sske and host large pages are also mutual exclusive we do not even
need to retry the fixup_user_fault.

As use_skey is already the condition on which we call s390_enable_skey
we need to introduce a new flag for the mm->context on which we decide
if zero page mapping is allowed.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/mmu.h     |  2 ++
 arch/s390/include/asm/pgtable.h | 14 ++++++++++++++
 arch/s390/mm/pgtable.c          | 12 ++++++++++++
 3 files changed, 28 insertions(+)

diff --git a/arch/s390/include/asm/mmu.h b/arch/s390/include/asm/mmu.h
index a5e6562..0f38469 100644
--- a/arch/s390/include/asm/mmu.h
+++ b/arch/s390/include/asm/mmu.h
@@ -18,6 +18,8 @@ typedef struct {
 	unsigned int has_pgste:1;
 	/* The mmu context uses storage keys. */
 	unsigned int use_skey:1;
+	/* The mmu context forbids zeropage mappings. */
+	unsigned int forbids_zeropage:1;
 } mm_context_t;
 
 #define INIT_MM_CONTEXT(name)						      \
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 1e991f6a..fe3cfdf 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -481,6 +481,20 @@ static inline int mm_has_pgste(struct mm_struct *mm)
 	return 0;
 }
 
+/*
+ * In the case that a guest uses storage keys
+ * faults should no longer be backed by zero pages
+ */
+#define mm_forbids_zeropage mm_forbids_zeropage
+static inline int mm_forbids_zeropage(struct mm_struct *mm)
+{
+#ifdef CONFIG_PGSTE
+	if (mm->context.forbids_zeropage)
+		return 1;
+#endif
+	return 0;
+}
+
 static inline int mm_use_skey(struct mm_struct *mm)
 {
 #ifdef CONFIG_PGSTE
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index ab55ba8..1e06fbc 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1309,6 +1309,15 @@ static int __s390_enable_skey(pte_t *pte, unsigned long addr,
 	pgste_t pgste;
 
 	pgste = pgste_get_lock(pte);
+	/*
+	 * Remove all zero page mappings,
+	 * after establishing a policy to forbid zero page mappings
+	 * following faults for that page will get fresh anonymous pages
+	 */
+	if (is_zero_pfn(pte_pfn(*pte))) {
+		ptep_flush_direct(walk->mm, addr, pte);
+		pte_val(*pte) = _PAGE_INVALID;
+	}
 	/* Clear storage key */
 	pgste_val(pgste) &= ~(PGSTE_ACC_BITS | PGSTE_FP_BIT |
 			      PGSTE_GR_BIT | PGSTE_GC_BIT);
@@ -1327,6 +1336,9 @@ void s390_enable_skey(void)
 	down_write(&mm->mmap_sem);
 	if (mm_use_skey(mm))
 		goto out_up;
+
+	mm->context.forbids_zeropage = 1;
+
 	walk.mm = mm;
 	walk_page_range(0, TASK_SIZE, &walk);
 	mm->context.use_skey = 1;
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
