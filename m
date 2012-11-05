Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 714576B005A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 17:47:49 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4646108pbb.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 14:47:49 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 10/16] mm: use vm_unmapped_area() on mips architecture
Date: Mon,  5 Nov 2012 14:47:07 -0800
Message-Id: <1352155633-8648-11-git-send-email-walken@google.com>
In-Reply-To: <1352155633-8648-1-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

Update the mips arch_get_unmapped_area[_topdown] functions to make
use of vm_unmapped_area() instead of implementing a brute force search.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/mips/mm/mmap.c |   99 +++++++++------------------------------------------
 1 files changed, 17 insertions(+), 82 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 302d779d5b0d..e4b54b233e17 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -71,6 +71,7 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 	struct vm_area_struct *vma;
 	unsigned long addr = addr0;
 	int do_color_align;
+	struct vm_unmapped_area_info info;
 
 	if (unlikely(len > TASK_SIZE))
 		return -ENOMEM;
@@ -107,97 +108,31 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 			return addr;
 	}
 
-	if (dir == UP) {
-		addr = mm->mmap_base;
-		if (do_color_align)
-			addr = COLOUR_ALIGN(addr, pgoff);
-		else
-			addr = PAGE_ALIGN(addr);
+	info.length = len;
+	info.align_mask = do_color_align ? (PAGE_MASK & shm_align_mask) : 0;
+	info.align_offset = pgoff << PAGE_SHIFT;
 
-		for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
-			/* At this point:  (!vma || addr < vma->vm_end). */
-			if (TASK_SIZE - len < addr)
-				return -ENOMEM;
-			if (!vma || addr + len <= vma->vm_start)
-				return addr;
-			addr = vma->vm_end;
-			if (do_color_align)
-				addr = COLOUR_ALIGN(addr, pgoff);
-		 }
-	 } else {
-		/* check if free_area_cache is useful for us */
-		if (len <= mm->cached_hole_size) {
-			mm->cached_hole_size = 0;
-			mm->free_area_cache = mm->mmap_base;
-		}
+	if (dir == DOWN) {
+		info.flags = VM_UNMAPPED_AREA_TOPDOWN;
+		info.low_limit = PAGE_SIZE;
+		info.high_limit = mm->mmap_base;
+		addr = vm_unmapped_area(&info);
+
+		if (!(addr & ~PAGE_MASK))
+			return addr;
 
-		/*
-		 * either no address requested, or the mapping can't fit into
-		 * the requested address hole
-		 */
-		addr = mm->free_area_cache;
-		if (do_color_align) {
-			unsigned long base =
-				COLOUR_ALIGN_DOWN(addr - len, pgoff);
-			addr = base + len;
-		}
-
-		/* make sure it can fit in the remaining address space */
-		if (likely(addr > len)) {
-			vma = find_vma(mm, addr - len);
-			if (!vma || addr <= vma->vm_start) {
-				/* cache the address as a hint for next time */
-				return mm->free_area_cache = addr - len;
-			}
-		}
-
-		if (unlikely(mm->mmap_base < len))
-			goto bottomup;
-
-		addr = mm->mmap_base - len;
-		if (do_color_align)
-			addr = COLOUR_ALIGN_DOWN(addr, pgoff);
-
-		do {
-			/*
-			 * Lookup failure means no vma is above this address,
-			 * else if new region fits below vma->vm_start,
-			 * return with success:
-			 */
-			vma = find_vma(mm, addr);
-			if (likely(!vma || addr + len <= vma->vm_start)) {
-				/* cache the address as a hint for next time */
-				return mm->free_area_cache = addr;
-			}
-
-			/* remember the largest hole we saw so far */
-			if (addr + mm->cached_hole_size < vma->vm_start)
-				mm->cached_hole_size = vma->vm_start - addr;
-
-			/* try just below the current vma->vm_start */
-			addr = vma->vm_start - len;
-			if (do_color_align)
-				addr = COLOUR_ALIGN_DOWN(addr, pgoff);
-		} while (likely(len < vma->vm_start));
-
-bottomup:
 		/*
 		 * A failed mmap() very likely causes application failure,
 		 * so fall back to the bottom-up function here. This scenario
 		 * can happen with large stack limits and large mmap()
 		 * allocations.
 		 */
-		mm->cached_hole_size = ~0UL;
-		mm->free_area_cache = TASK_UNMAPPED_BASE;
-		addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
-		/*
-		 * Restore the topdown base:
-		 */
-		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = ~0UL;
-
-		return addr;
 	}
+
+	info.flags = 0;
+	info.low_limit = mm->mmap_base;
+	info.high_limit = TASK_SIZE;
+	return vm_unmapped_area(&info);
 }
 
 unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr0,
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
