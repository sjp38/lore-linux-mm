Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C31E46B0044
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 21:56:16 -0400 (EDT)
Received: by iajr24 with SMTP id r24so635287iaj.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 18:56:16 -0700 (PDT)
Date: Tue, 3 Apr 2012 18:56:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] thp, memcg: split hugepage for memcg oom on cow
Message-ID: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On COW, a new hugepage is allocated and charged to the memcg.  If the
memcg is oom, however, this charge will fail and will return VM_FAULT_OOM
to the page fault handler which results in an oom kill.

Instead, it's possible to fallback to splitting the hugepage so that the
COW results only in an order-0 page being charged to the memcg which has
a higher liklihood to succeed.  This is expensive because the hugepage
must be split in the page fault handler, but it is much better than
unnecessarily oom killing a process.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c |    1 +
 mm/memory.c      |   18 +++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -959,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
+		split_huge_page(page);
 		put_page(page);
 		ret |= VM_FAULT_OOM;
 		goto out;
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3489,6 +3489,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
+retry:
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
@@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 							  pmd, flags);
 	} else {
 		pmd_t orig_pmd = *pmd;
+		int ret;
+
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd))
-				return do_huge_pmd_wp_page(mm, vma, address,
-							   pmd, orig_pmd);
+			    !pmd_trans_splitting(orig_pmd)) {
+				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
+							  orig_pmd);
+				/*
+				 * If COW results in an oom memcg, the huge pmd
+				 * will already have been split, so retry the
+				 * fault on the pte for a smaller charge.
+				 */
+				if (unlikely(ret & VM_FAULT_OOM))
+					goto retry;
+				return ret;
+			}
 			return 0;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
