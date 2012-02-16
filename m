Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 89C526B004A
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 02:12:21 -0500 (EST)
Date: Thu, 16 Feb 2012 08:07:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
Message-ID: <20120216070753.GA23585@redhat.com>
References: <20120215183317.GA26977@redhat.com>
 <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Wed, Feb 15, 2012 at 06:14:12PM -0800, Hugh Dickins wrote:
> Now most of those paths in THP also hold mmap_sem for read or write (with
> appropriate checks on mm_users), but two do not: when split_huge_page()
> is called by hwpoison_user_mappings(), and when called by add_to_swap().

So the race is split_huge_page_map() called by add_to_swap() running
concurrently with free_pgtables. Great catch!!

> Or should we try harder to avoid the extra locking: test mm_users?
> #ifdef on THP?  Or consider the accuracy of this count not worth
> extra locking, and just scrap the BUG_ON now?

It's probably also happening with a large munmap, while add_to_swap
runs on another vma. Process didn't exit yet, but the actual BUG_ON
check runs at exit. So I doubt aborting split_huge_page on zero
mm_users could solve it.

Good part is, this being a false positive makes these oopses a
nuisance, so it means they can't corrupt any memory or disk etc...

The simplest is probably to change nr_ptes to count THPs too. I tried
that and no oopses so far but it's not very well tested yet.

====
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: thp: fix BUG on mm->nr_ptes

Quoting Hugh's discovery and explanation of the SMP race condition:

===
mm->nr_ptes had unusual locking: down_read mmap_sem plus
page_table_lock when incrementing, down_write mmap_sem (or mm_users 0)
when decrementing; whereas THP is careful to increment and decrement
it under page_table_lock.

Now most of those paths in THP also hold mmap_sem for read or write
(with appropriate checks on mm_users), but two do not: when
split_huge_page() is called by hwpoison_user_mappings(), and when
called by add_to_swap().

It's conceivable that the latter case is responsible for the
exit_mmap() BUG_ON mm->nr_ptes that has been reported on Fedora.
===

The simplest way to fix it without having to alter the locking is to
make split_huge_page() a noop in nr_ptes terms, so by counting the
preallocated pagetables that exists for every mapped hugepage. It was
an arbitrary choice not to count them and either way is not wrong or
right, because they are not used but they're still allocated.

Reported-by: Dave Jones <davej@redhat.com>
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 91d3efb..8f7fc39 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -671,6 +671,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		mm->nr_ptes++;
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -789,6 +790,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 	prepare_pmd_huge_pte(pgtable, dst_mm);
+	dst_mm->nr_ptes++;
 
 	ret = 0;
 out_unlock:
@@ -887,7 +889,6 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	}
 	kfree(pages);
 
-	mm->nr_ptes++;
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
 	page_remove_rmap(page);
@@ -1047,6 +1048,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			VM_BUG_ON(page_mapcount(page) < 0);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
+			tlb->mm->nr_ptes--;
 			spin_unlock(&tlb->mm->page_table_lock);
 			tlb_remove_page(tlb, page);
 			pte_free(tlb->mm, pgtable);
@@ -1375,7 +1377,6 @@ static int __split_huge_page_map(struct page *page,
 			pte_unmap(pte);
 		}
 
-		mm->nr_ptes++;
 		smp_wmb(); /* make pte visible before pmd */
 		/*
 		 * Up to this point the pmd is present and huge and
@@ -1988,7 +1989,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache(vma, address, _pmd);
 	prepare_pmd_huge_pte(pgtable, mm);
-	mm->nr_ptes--;
 	spin_unlock(&mm->page_table_lock);
 
 #ifndef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
