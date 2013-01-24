Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 704DC6B0022
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 20:30:10 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so5165136pad.32
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 17:30:09 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 7/8] mm: use vm_unmapped_area() on powerpc architecture
Date: Wed, 23 Jan 2013 17:29:50 -0800
Message-Id: <1358990991-21316-8-git-send-email-walken@google.com>
In-Reply-To: <1358990991-21316-1-git-send-email-walken@google.com>
References: <1358990991-21316-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Update the powerpc slice_get_unmapped_area function to make use of
vm_unmapped_area() instead of implementing a brute force search.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/powerpc/mm/slice.c |  123 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 78 insertions(+), 45 deletions(-)

diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 999a74f25ebe..3e99c149271a 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -237,36 +237,69 @@ static void slice_convert(struct mm_struct *mm, struct slice_mask mask, int psiz
 #endif
 }
 
+/*
+ * Compute which slice addr is part of;
+ * set *boundary_addr to the start or end boundary of that slice
+ * (depending on 'end' parameter);
+ * return boolean indicating if the slice is marked as available in the
+ * 'available' slice_mark.
+ */
+static bool slice_scan_available(unsigned long addr,
+				 struct slice_mask available,
+				 int end,
+				 unsigned long *boundary_addr)
+{
+	unsigned long slice;
+	if (addr < SLICE_LOW_TOP) {
+		slice = GET_LOW_SLICE_INDEX(addr);
+		*boundary_addr = (slice + end) << SLICE_LOW_SHIFT;
+		return !!(available.low_slices & (1u << slice));
+	} else {
+		slice = GET_HIGH_SLICE_INDEX(addr);
+		*boundary_addr = (slice + end) ?
+			((slice + end) << SLICE_HIGH_SHIFT) : SLICE_LOW_TOP;
+		return !!(available.high_slices & (1u << slice));
+	}
+}
+
 static unsigned long slice_find_area_bottomup(struct mm_struct *mm,
 					      unsigned long len,
 					      struct slice_mask available,
 					      int psize)
 {
-	struct vm_area_struct *vma;
-	unsigned long addr;
-	struct slice_mask mask;
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
+	unsigned long addr, found, next_end;
+	struct vm_unmapped_area_info info;
 
-	addr = TASK_UNMAPPED_BASE;
-
-	for (;;) {
-		addr = _ALIGN_UP(addr, 1ul << pshift);
-		if ((TASK_SIZE - len) < addr)
-			break;
-		vma = find_vma(mm, addr);
-		BUG_ON(vma && (addr >= vma->vm_end));
+	info.flags = 0;
+	info.length = len;
+	info.align_mask = PAGE_MASK & ((1ul << pshift) - 1);
+	info.align_offset = 0;
 
-		mask = slice_range_to_mask(addr, len);
-		if (!slice_check_fit(mask, available)) {
-			if (addr < SLICE_LOW_TOP)
-				addr = _ALIGN_UP(addr + 1,  1ul << SLICE_LOW_SHIFT);
-			else
-				addr = _ALIGN_UP(addr + 1,  1ul << SLICE_HIGH_SHIFT);
+	addr = TASK_UNMAPPED_BASE;
+	while (addr < TASK_SIZE) {
+		info.low_limit = addr;
+		if (!slice_scan_available(addr, available, 1, &addr))
 			continue;
+
+ next_slice:
+		/*
+		 * At this point [info.low_limit; addr) covers
+		 * available slices only and ends at a slice boundary.
+		 * Check if we need to reduce the range, or if we can
+		 * extend it to cover the next available slice.
+		 */
+		if (addr >= TASK_SIZE)
+			addr = TASK_SIZE;
+		else if (slice_scan_available(addr, available, 1, &next_end)) {
+			addr = next_end;
+			goto next_slice;
 		}
-		if (!vma || addr + len <= vma->vm_start)
-			return addr;
-		addr = vma->vm_end;
+		info.high_limit = addr;
+
+		found = vm_unmapped_area(&info);
+		if (!(found & ~PAGE_MASK))
+			return found;
 	}
 
 	return -ENOMEM;
@@ -277,39 +310,39 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 					     struct slice_mask available,
 					     int psize)
 {
-	struct vm_area_struct *vma;
-	unsigned long addr;
-	struct slice_mask mask;
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
+	unsigned long addr, found, prev;
+	struct vm_unmapped_area_info info;
 
-	addr = mm->mmap_base;
-	while (addr > len) {
-		/* Go down by chunk size */
-		addr = _ALIGN_DOWN(addr - len, 1ul << pshift);
+	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
+	info.length = len;
+	info.align_mask = PAGE_MASK & ((1ul << pshift) - 1);
+	info.align_offset = 0;
 
-		/* Check for hit with different page size */
-		mask = slice_range_to_mask(addr, len);
-		if (!slice_check_fit(mask, available)) {
-			if (addr < SLICE_LOW_TOP)
-				addr = _ALIGN_DOWN(addr, 1ul << SLICE_LOW_SHIFT);
-			else if (addr < (1ul << SLICE_HIGH_SHIFT))
-				addr = SLICE_LOW_TOP;
-			else
-				addr = _ALIGN_DOWN(addr, 1ul << SLICE_HIGH_SHIFT);
+	addr = mm->mmap_base;
+	while (addr > PAGE_SIZE) {
+		info.high_limit = addr;
+		if (!slice_scan_available(addr - 1, available, 0, &addr))
 			continue;
-		}
 
+ prev_slice:
 		/*
-		 * Lookup failure means no vma is above this address,
-		 * else if new region fits below vma->vm_start,
-		 * return with success:
+		 * At this point [addr; info.high_limit) covers
+		 * available slices only and starts at a slice boundary.
+		 * Check if we need to reduce the range, or if we can
+		 * extend it to cover the previous available slice.
 		 */
-		vma = find_vma(mm, addr);
-		if (!vma || (addr + len) <= vma->vm_start)
-			return addr;
+		if (addr < PAGE_SIZE)
+			addr = PAGE_SIZE;
+		else if (slice_scan_available(addr - 1, available, 0, &prev)) {
+			addr = prev;
+			goto prev_slice;
+		}
+		info.low_limit = addr;
 
-		/* try just below the current vma->vm_start */
-		addr = vma->vm_start;
+		found = vm_unmapped_area(&info);
+		if (!(found & ~PAGE_MASK))
+			return found;
 	}
 
 	/*
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
