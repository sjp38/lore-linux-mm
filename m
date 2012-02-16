Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E50216B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 21:14:47 -0500 (EST)
Received: by dadv6 with SMTP id v6so1864426dad.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:14:46 -0800 (PST)
Date: Wed, 15 Feb 2012 18:14:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
In-Reply-To: <20120215183317.GA26977@redhat.com>
Message-ID: <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
References: <20120215183317.GA26977@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Wed, 15 Feb 2012, Dave Jones wrote:

> We've had three reports against the Fedora kernel recently where
> a process exits, and we're tripping up the 
> 
>         BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
> 
> in exit_mmap()
> 
> It started happening with 3.1, but still occurs on 3.2
> (no 3.3rc reports yet, but it's not getting much testing).
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=786632
> https://bugzilla.redhat.com/show_bug.cgi?id=787527
> https://bugzilla.redhat.com/show_bug.cgi?id=790546
> 
> I don't see anything special in common between the loaded modules.
> 
> anyone?

My suspicion was that it would be related to Transparent HugePages:
they do complicate the pagetable story.  And I think I have found a
potential culprit.  I don't know if nr_ptes is the only loser from
these two split_huge_pages calls, but assuming it is...


[PATCH] mm: fix BUG on mm->nr_ptes

mm->nr_ptes had unusual locking: down_read mmap_sem plus page_table_lock
when incrementing, down_write mmap_sem (or mm_users 0) when decrementing;
whereas THP is careful to increment and decrement it under page_table_lock.

Now most of those paths in THP also hold mmap_sem for read or write (with
appropriate checks on mm_users), but two do not: when split_huge_page()
is called by hwpoison_user_mappings(), and when called by add_to_swap().

It's conceivable that the latter case is responsible for the exit_mmap()
BUG_ON mm->nr_ptes that has been reported on Fedora.

THP's understanding of the locking seems reasonable, so take that lock
to update it in free_pgd_range(): try to avoid retaking it repeatedly
by passing the count up from levels below - free_pgtables() already
does its best to combine calls across neighbouring vmas.

Or should we try harder to avoid the extra locking: test mm_users?
#ifdef on THP?  Or consider the accuracy of this count not worth
extra locking, and just scrap the BUG_ON now?

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memory.c |   40 +++++++++++++++++++++++++++-------------
 1 file changed, 27 insertions(+), 13 deletions(-)

--- 3.3-rc3/mm/memory.c	2012-01-31 14:51:15.100021868 -0800
+++ linux/mm/memory.c	2012-02-15 17:01:46.588649490 -0800
@@ -419,22 +419,23 @@ void pmd_clear_bad(pmd_t *pmd)
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
  */
-static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
+static long free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
 			   unsigned long addr)
 {
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, token, addr);
-	tlb->mm->nr_ptes--;
+	return 1;
 }
 
-static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+static inline long free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 				unsigned long addr, unsigned long end,
 				unsigned long floor, unsigned long ceiling)
 {
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long start;
+	long nr_ptes = 0;
 
 	start = addr;
 	pmd = pmd_offset(pud, addr);
@@ -442,32 +443,35 @@ static inline void free_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		free_pte_range(tlb, pmd, addr);
+		nr_ptes += free_pte_range(tlb, pmd, addr);
 	} while (pmd++, addr = next, addr != end);
 
 	start &= PUD_MASK;
 	if (start < floor)
-		return;
+		goto out;
 	if (ceiling) {
 		ceiling &= PUD_MASK;
 		if (!ceiling)
-			return;
+			goto out;
 	}
 	if (end - 1 > ceiling - 1)
-		return;
+		goto out;
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
 	pmd_free_tlb(tlb, pmd, start);
+out:
+	return nr_ptes;
 }
 
-static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+static inline long free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
 				unsigned long floor, unsigned long ceiling)
 {
 	pud_t *pud;
 	unsigned long next;
 	unsigned long start;
+	long nr_ptes = 0;
 
 	start = addr;
 	pud = pud_offset(pgd, addr);
@@ -475,23 +479,25 @@ static inline void free_pud_range(struct
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+		nr_ptes += free_pmd_range(tlb, pud, addr, next, floor, ceiling);
 	} while (pud++, addr = next, addr != end);
 
 	start &= PGDIR_MASK;
 	if (start < floor)
-		return;
+		goto out;
 	if (ceiling) {
 		ceiling &= PGDIR_MASK;
 		if (!ceiling)
-			return;
+			goto out;
 	}
 	if (end - 1 > ceiling - 1)
-		return;
+		goto out;
 
 	pud = pud_offset(pgd, start);
 	pgd_clear(pgd);
 	pud_free_tlb(tlb, pud, start);
+out:
+	return nr_ptes;
 }
 
 /*
@@ -505,6 +511,7 @@ void free_pgd_range(struct mmu_gather *t
 {
 	pgd_t *pgd;
 	unsigned long next;
+	long nr_ptes = 0;
 
 	/*
 	 * The next few lines have given us lots of grief...
@@ -553,8 +560,15 @@ void free_pgd_range(struct mmu_gather *t
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		free_pud_range(tlb, pgd, addr, next, floor, ceiling);
+		nr_ptes += free_pud_range(tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
+
+	if (nr_ptes) {
+		struct mm_struct *mm = tlb->mm;
+		spin_lock(&mm->page_table_lock);
+		mm->nr_ptes -= nr_ptes;
+		spin_unlock(&mm->page_table_lock);
+	}
 }
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
