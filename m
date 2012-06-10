Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 70D4C6B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 22:13:18 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4807676dak.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 19:13:17 -0700 (PDT)
Date: Sat, 9 Jun 2012 19:13:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: kernel BUG at mm/memory.c:1228!
In-Reply-To: <20120606165330.GA27744@redhat.com>
Message-ID: <alpine.DEB.2.00.1206091904030.7832@chino.kir.corp.google.com>
References: <20120606165330.GA27744@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <levinsasha928@gmail.com>

On Wed, 6 Jun 2012, Dave Jones wrote:

> I hit this in overnight testing..
> 
> ------------[ cut here ]------------
> kernel BUG at mm/memory.c:1228!

Looks like a duplicate of the "mm: kernel BUG at mm/memory.c:1230" thread 
at http://marc.info/?t=133788420400003

Andrea suggested adding a printk of addr, end, vma->vm_start, and 
vma->vm_end to debug it.

Since it's been reported a few different times, perhaps this should be 
merged?


mm, thp: print useful information when mmap_sem is unlocked in zap_pmd_range

Andrea asked for addr, end, vma->vm_start, and vma->vm_end to be emitted 
when !rwsem_is_locked(&tlb->mm->mmap_sem).  Otherwise, debugging the 
underlying issue is more difficult.

Signed-off-by: David Rientjes <rientjes@google.com>
---
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
+					pr_err("%s: mmap_sem is unlocked! addr=%lu end=%lu vma->vm_start=%lu vma->vm_end=%lu\n",
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
