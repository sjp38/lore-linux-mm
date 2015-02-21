Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7696B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:20:55 -0500 (EST)
Received: by pdjg10 with SMTP id g10so12154356pdj.1
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:20:55 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id bf1si12188390pbb.88.2015.02.20.20.20.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:20:54 -0800 (PST)
Received: by pdno5 with SMTP id o5so12082832pdn.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:20:54 -0800 (PST)
Date: Fri, 20 Feb 2015 20:20:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 18/24] huge tmpfs: mmap_sem is unlocked when truncation splits
 huge pmd
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202018160.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

zap_pmd_range()'s CONFIG_DEBUG_VM !rwsem_is_locked(&mmap_sem) BUG()
is invalid with huge tmpfs, where truncation of a hugely-mapped file
to an unhugely-aligned size easily hits it.

(Although anon THP could in principle apply khugepaged to private file
mappings, which are not excluded by the MADV_HUGEPAGE restrictions, in
practice there's a vm_ops check which excludes them, so it never hits
this BUG() - there's no interface to "truncate" an anonymous mapping.)

We could complicate the test, to check i_mmap_rwsem also when there's
a vm_file; but I'm inclined to make zap_pmd_range() more readable by
simply deleting this check.  A search has shown no report of the issue
in the 2.5 years since e0897d75f0b2 ("mm, thp: print useful information
when mmap_sem is unlocked in zap_pmd_range") expanded it from VM_BUG_ON()
- though I cannot point to what commit I would say then fixed the issue.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memory.c |   13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

--- thpfs.orig/mm/memory.c	2015-02-20 19:34:48.083909034 -0800
+++ thpfs/mm/memory.c	2015-02-20 19:34:53.467896724 -0800
@@ -1219,18 +1219,9 @@ static inline unsigned long zap_pmd_rang
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE) {
-#ifdef CONFIG_DEBUG_VM
-				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
-					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
-						__func__, addr, end,
-						vma->vm_start,
-						vma->vm_end);
-					BUG();
-				}
-#endif
+			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma, addr, pmd);
-			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
+			else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
