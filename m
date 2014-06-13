From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 1/2] mm: Report attempts to overwrite PTE from
	remap_pfn_range()
Date: Fri, 13 Jun 2014 17:26:17 +0100
Message-ID: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
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

When using remap_pfn_range() from a fault handler, we are exposed to
races between concurrent faults. Rather than hitting a BUG, report the
error back to the caller, like vm_insert_pfn().

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
 mm/memory.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 037b812a9531..6603a9e6a731 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2306,19 +2306,23 @@ static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	int ret = 0;
 
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 	arch_enter_lazy_mmu_mode();
 	do {
-		BUG_ON(!pte_none(*pte));
+		if (!pte_none(*pte)) {
+			ret = -EBUSY;
+			break;
+		}
 		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
+	return ret;
 }
 
 static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-- 
2.0.0
