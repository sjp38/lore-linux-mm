From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
Date: Mon, 14 Apr 2014 17:42:18 +0300
Message-ID: <20140414144218.GA26515@node.dhcp.inet.fi>
References: <53440991.9090001@oracle.com>
 <20140410102527.GA24111@node.dhcp.inet.fi>
 <20140410134436.GA25933@node.dhcp.inet.fi>
 <20140410162750.GD2749@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140410162750.GD2749@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 10, 2014 at 06:27:50PM +0200, Andrea Arcangeli wrote:
> Hi,
> 
> On Thu, Apr 10, 2014 at 04:44:36PM +0300, Kirill A. Shutemov wrote:
> > Okay, below is my attempt to fix the bug. I'm not entirely sure it's
> > correct. Andrea, could you take a look?
> 
> The possibility the interval tree implicitly broke the walk order of
> the anon_vma list didn't cross my mind, that's very good catch!
> Breakage of the rmap walk order definitely can explain that BUG_ON in
> split_huge_page that signals a pte was missed by the rmap walk.

I've spent few day trying to understand rmap code. And now I think my
patch is wrong.

I actually don't see where walk order requirement comes from. It seems all
operations (insert, remove, foreach) on anon_vma is serialized with
anon_vma->root->rwsem. Andrea, could you explain this for me?

The actual bug was introduced by me with split PMD page table lock
patchset. The patch below should fix it. Please review.

It also means it can't be the root cause of other bug report[1] since
split PMD lock was introduced in v3.13 and bug report is about v3.8.

[1] https://bugzilla.redhat.com/show_bug.cgi?id=923817

>From 8e0095daf2f0fac113c2e98369c7fc9ff4cde484 Mon Sep 17 00:00:00 2001
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Mon, 14 Apr 2014 16:05:33 +0300
Subject: [PATCH] thp: close race between split and zap huge pages

Sasha Levin has reported two THP BUGs[1][2]. I believe both of them have
the same root cause. Let's look to them one by one.

The first bug[1] is "kernel BUG at mm/huge_memory.c:1829!".
It's BUG_ON(mapcount != page_mapcount(page)) in __split_huge_page().
>From my testing I see that page_mapcount() is higher than mapcount here.

I think it happens due to race between zap_huge_pmd() and
page_check_address_pmd(). page_check_address_pmd() misses PMD
which is under zap:

	CPU0						CPU1
						zap_huge_pmd()
						  pmdp_get_and_clear()
__split_huge_page()
  anon_vma_interval_tree_foreach()
    __split_huge_page_splitting()
      page_check_address_pmd()
        mm_find_pmd()
	  /*
	   * We check if PMD present without taking ptl: no
	   * serialization against zap_huge_pmd(). We miss this PMD,
	   * it's not accounted to 'mapcount' in __split_huge_page().
	   */
	  pmd_present(pmd) == 0

  BUG_ON(mapcount != page_mapcount(page)) // CRASH!!!

						  page_remove_rmap(page)
						    atomic_add_negative(-1, &page->_mapcount)

The second bug[2] is "kernel BUG at mm/huge_memory.c:1371!".
It's VM_BUG_ON_PAGE(!PageHead(page), page) in zap_huge_pmd().

This happens in similar way:

	CPU0						CPU1
						zap_huge_pmd()
						  pmdp_get_and_clear()
						  page_remove_rmap(page)
						    atomic_add_negative(-1, &page->_mapcount)
__split_huge_page()
  anon_vma_interval_tree_foreach()
    __split_huge_page_splitting()
      page_check_address_pmd()
        mm_find_pmd()
	  pmd_present(pmd) == 0	/* The same comment as above */
  /*
   * No crash this time since we already decremented page->_mapcount in
   * zap_huge_pmd().
   */
  BUG_ON(mapcount != page_mapcount(page))

  /*
   * We split the compound page here into small pages without
   * serialization against zap_huge_pmd()
   */
  __split_huge_page_refcount()
						VM_BUG_ON_PAGE(!PageHead(page), page); // CRASH!!!

So my understanding the problem is pmd_present() check in mm_find_pmd()
without taking page table lock.

The bug was introduced by me commit with commit 117b0791ac42. Sorry for
that. :(

Let's open code mm_find_pmd() in page_check_address_pmd() and do the
check under page table lock.

Note that __page_check_address() does the same for PTE entires
if sync != 0.

[1] https://lkml.kernel.org/g/<53440991.9090001@oracle.com>
[2] https://lkml.kernel.org/g/<5310C56C.60709@oracle.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: <stable@vger.kernel.org> #3.13+
---
 mm/huge_memory.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5025709bb3b5..d02a83852ee9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1536,16 +1536,23 @@ pmd_t *page_check_address_pmd(struct page *page,
 			      enum page_check_address_pmd_flag flag,
 			      spinlock_t **ptl)
 {
+	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	if (address & ~HPAGE_PMD_MASK)
 		return NULL;
 
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
 		return NULL;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return NULL;
+	pmd = pmd_offset(pud, address);
+
 	*ptl = pmd_lock(mm, pmd);
-	if (pmd_none(*pmd))
+	if (!pmd_present(*pmd))
 		goto unlock;
 	if (pmd_page(*pmd) != page)
 		goto unlock;
-- 
 Kirill A. Shutemov
