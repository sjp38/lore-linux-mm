Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC726B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:30:47 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so3102642wgh.7
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:30:46 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id yw4si17609892wjc.94.2014.10.22.01.30.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 01:30:46 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 09:30:45 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id E4D551B08072
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:30:41 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9M8UfLW16384308
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:30:41 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9M8UeP0031412
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 02:30:41 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/4] mm: introduce mm_forbids_zeropage function
Date: Wed, 22 Oct 2014 10:30:22 +0200
Message-Id: <1413966624-12447-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

Add a new function stub to allow architectures to disable for
an mm_structthe backing of non-present, anonymous pages with
read-only empty zero pages.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 include/linux/mm.h | 4 ++++
 mm/huge_memory.c   | 2 +-
 mm/memory.c        | 2 +-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index cd33ae2..0a2022e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -56,6 +56,10 @@ extern int sysctl_legacy_va_layout;
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
 
+#ifndef mm_forbids_zeropage
+#define mm_forbids_zeropage(X)  (0)
+#endif
+
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de98415..357a381 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -805,7 +805,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
-	if (!(flags & FAULT_FLAG_WRITE) &&
+	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm) &&
 			transparent_hugepage_use_zero_page()) {
 		spinlock_t *ptl;
 		pgtable_t pgtable;
diff --git a/mm/memory.c b/mm/memory.c
index 64f82aa..f275a9d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2640,7 +2640,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_SIGBUS;
 
 	/* Use the zero-page for reads */
-	if (!(flags & FAULT_FLAG_WRITE)) {
+	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
