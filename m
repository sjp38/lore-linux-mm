Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CA2F76B0070
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 10:10:11 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id a1so1024765wgh.9
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 07:10:11 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id dn5si1561346wjb.163.2014.10.17.07.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Oct 2014 07:10:09 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 17 Oct 2014 15:10:08 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 311462190056
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 15:09:44 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9HEA7S814352880
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 14:10:07 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9HEA4QQ026756
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:10:07 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/4] s390/mm: prevent and break zero page mappings in case of storage keys
Date: Fri, 17 Oct 2014 16:09:49 +0200
Message-Id: <1413554990-48512-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

As soon as storage keys are enabled we need to work around of zero page
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

While holding the mmap sem, we are safe before changes on entries we
already fixed. As sske and host large pages are also mutual exclusive
we do not even need to retry the fixup_user_fault.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/Kconfig      |  3 +++
 arch/s390/mm/pgtable.c | 15 +++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 05c78bb..4e04e63 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -1,6 +1,9 @@
 config MMU
 	def_bool y
 
+config NOZEROPAGE
+	def_bool y
+
 config ZONE_DMA
 	def_bool y
 
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index ab55ba8..6321692 100644
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
@@ -1323,10 +1332,16 @@ void s390_enable_skey(void)
 {
 	struct mm_walk walk = { .pte_entry = __s390_enable_skey };
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
 	if (mm_use_skey(mm))
 		goto out_up;
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next)
+		vma->vm_flags |= VM_NOZEROPAGE;
+	mm->def_flags |= VM_NOZEROPAGE;
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
