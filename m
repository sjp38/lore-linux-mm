From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 1/4] mm: Refactor remap_pfn_range()
Date: Sat, 21 Jun 2014 16:53:53 +0100
Message-ID: <1403366036-10169-1-git-send-email-chris@chris-wilson.co.uk>
References: <20140619135944.20837E00A3@blue.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20140619135944.20837E00A3@blue.fi.intel.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
To: intel-gfx@lists.freedesktop.org
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
List-Id: linux-mm.kvack.org

In preparation for exporting very similar functionality through another
interface, gut the current remap_pfn_range(). The motivating factor here
is to reuse the PGB/PUD/PMD/PTE walker, but allow back progation of
errors rather than BUG_ON.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
---
 mm/memory.c | 102 +++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 57 insertions(+), 45 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 037b812a9531..d2c7fe88a289 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2295,71 +2295,81 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
+struct remap_pfn {
+	struct mm_struct *mm;
+	unsigned long addr;
+	unsigned long pfn;
+	pgprot_t prot;
+};
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
  * in null mappings (currently treated as "copy-on-access")
  */
-static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+static inline int remap_pfn(struct remap_pfn *r, pte_t *pte)
+{
+	if (!pte_none(*pte))
+		return -EBUSY;
+
+	set_pte_at(r->mm, r->addr, pte,
+		   pte_mkspecial(pfn_pte(r->pfn, r->prot)));
+	r->pfn++;
+	r->addr += PAGE_SIZE;
+	return 0;
+}
+
+static int remap_pte_range(struct remap_pfn *r, pmd_t *pmd, unsigned long end)
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	int err;
 
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
+	pte = pte_alloc_map_lock(r->mm, pmd, r->addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
+
 	arch_enter_lazy_mmu_mode();
 	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+		err = remap_pfn(r, pte++);
+	} while (err == 0 && r->addr < end);
 	arch_leave_lazy_mmu_mode();
+
 	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
+	return err;
 }
 
-static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+static inline int remap_pmd_range(struct remap_pfn *r, pud_t *pud, unsigned long end)
 {
 	pmd_t *pmd;
-	unsigned long next;
+	int err;
 
-	pfn -= addr >> PAGE_SHIFT;
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(r->mm, pud, r->addr);
 	if (!pmd)
 		return -ENOMEM;
 	VM_BUG_ON(pmd_trans_huge(*pmd));
+
 	do {
-		next = pmd_addr_end(addr, end);
-		if (remap_pte_range(mm, pmd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
+		err = remap_pte_range(r, pmd++, pmd_addr_end(r->addr, end));
+	} while (err == 0 && r->addr < end);
+
+	return err;
 }
 
-static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+static inline int remap_pud_range(struct remap_pfn *r, pgd_t *pgd, unsigned long end)
 {
 	pud_t *pud;
-	unsigned long next;
+	int err;
 
-	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(r->mm, pgd, r->addr);
 	if (!pud)
 		return -ENOMEM;
+
 	do {
-		next = pud_addr_end(addr, end);
-		if (remap_pmd_range(mm, pud, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
+		err = remap_pmd_range(r, pud++, pud_addr_end(r->addr, end));
+	} while (err == 0 && r->addr < end);
+
+	return err;
 }
 
 /**
@@ -2375,10 +2385,9 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
 int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		    unsigned long pfn, unsigned long size, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
-	struct mm_struct *mm = vma->vm_mm;
+	struct remap_pfn r;
+	pgd_t *pgd;
 	int err;
 
 	/*
@@ -2412,19 +2421,22 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 
 	BUG_ON(addr >= end);
-	pfn -= addr >> PAGE_SHIFT;
-	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
+
+	r.mm = vma->vm_mm;
+	r.addr = addr;
+	r.pfn = pfn;
+	r.prot = prot;
+
+	pgd = pgd_offset(r.mm, addr);
 	do {
-		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+		err = remap_pud_range(&r, pgd++, pgd_addr_end(r.addr, end));
+	} while (err == 0 && r.addr < end);
 
-	if (err)
+	if (err) {
 		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
+		BUG_ON(err == -EBUSY);
+	}
 
 	return err;
 }
-- 
2.0.0
