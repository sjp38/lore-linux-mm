Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B2B1E6B00E0
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:15:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6472467pbb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 02:15:32 -0700 (PDT)
Date: Mon, 11 Jun 2012 02:15:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, thp: print useful information when mmap_sem is unlocked
 in zap_pmd_range
In-Reply-To: <alpine.DEB.2.00.1206091904030.7832@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206110214150.6843@chino.kir.corp.google.com>
References: <20120606165330.GA27744@redhat.com> <alpine.DEB.2.00.1206091904030.7832@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <levinsasha928@gmail.com>

Andrea asked for addr, end, vma->vm_start, and vma->vm_end to be emitted
when !rwsem_is_locked(&tlb->mm->mmap_sem).  Otherwise, debugging the
underlying issue is more difficult.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: print in hex rather than decimal

 mm/memory.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1225,7 +1225,15 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
+#ifdef CONFIG_DEBUG_VM
+				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
+					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
+						__func__, addr, end,
+						vma->vm_start,
+						vma->vm_end);
+					BUG();
+				}
+#endif
 				split_huge_page_pmd(vma->vm_mm, pmd);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
