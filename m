Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEB136B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 16:14:41 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b23-v6so2285665pls.8
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 13:14:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16-v6sor16134843plo.4.2018.10.09.13.14.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 13:14:40 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH] mm: Speed up mremap on large regions
Date: Tue,  9 Oct 2018 13:14:00 -0700
Message-Id: <20181009201400.168705-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kernel-team@android.com, Joel Fernandes <joel@joelfernandes.org>, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

Android needs to mremap large regions of memory during memory management
related operations. The mremap system call can be really slow if THP is
not enabled. The bottleneck is move_page_tables, which is copying each
pte at a time, and can be really slow across a large map. Turning on THP
may not be a viable option, and is not for us. This patch speeds up the
performance for non-THP system by copying at the PMD level when possible.

The speed up is three orders of magnitude. On a 1GB mremap, the mremap
completion times drops from 160-250 millesconds to 380-400 microseconds.

Before:
Total mremap time for 1GB data: 242321014 nanoseconds.
Total mremap time for 1GB data: 196842467 nanoseconds.
Total mremap time for 1GB data: 167051162 nanoseconds.

After:
Total mremap time for 1GB data: 385781 nanoseconds.
Total mremap time for 1GB data: 388959 nanoseconds.
Total mremap time for 1GB data: 402813 nanoseconds.

Incase THP is enabled, the optimization is skipped. I also flush the
tlb every time we do this optimization since I couldn't find a way to
determine if the low-level PTEs are dirty. It is seen that the cost of
doing so is not much compared the improvement, on both x86-64 and arm64.

Cc: minchan@google.com
Cc: hughd@google.com
Cc: lokeshgidra@google.com
Cc: kernel-team@android.com
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 mm/mremap.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index 5c2e18505f75..68ddc9e9dfde 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		drop_rmap_locks(vma);
 }
 
+bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
+		  unsigned long new_addr, unsigned long old_end,
+		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
+{
+	spinlock_t *old_ptl, *new_ptl;
+	struct mm_struct *mm = vma->vm_mm;
+
+	if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
+	    || old_end - old_addr < PMD_SIZE)
+		return false;
+
+	/*
+	 * The destination pmd shouldn't be established, free_pgtables()
+	 * should have release it.
+	 */
+	if (WARN_ON(!pmd_none(*new_pmd)))
+		return false;
+
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * ptlocks because exclusive mmap_sem prevents deadlock.
+	 */
+	old_ptl = pmd_lock(vma->vm_mm, old_pmd);
+	if (old_ptl) {
+		pmd_t pmd;
+
+		new_ptl = pmd_lockptr(mm, new_pmd);
+		if (new_ptl != old_ptl)
+			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+
+		/* Clear the pmd */
+		pmd = *old_pmd;
+		pmd_clear(old_pmd);
+
+		VM_BUG_ON(!pmd_none(*new_pmd));
+
+		/* Set the new pmd */
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
+		if (new_ptl != old_ptl)
+			spin_unlock(new_ptl);
+		spin_unlock(old_ptl);
+
+		*need_flush = true;
+		return true;
+	}
+	return false;
+}
+
 unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
@@ -239,7 +287,21 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			split_huge_pmd(vma, old_pmd, old_addr);
 			if (pmd_trans_unstable(old_pmd))
 				continue;
+		} else if (extent == PMD_SIZE) {
+			bool moved;
+
+			/* See comment in move_ptes() */
+			if (need_rmap_locks)
+				take_rmap_locks(vma);
+			moved = move_normal_pmd(vma, old_addr, new_addr,
+					old_end, old_pmd, new_pmd,
+					&need_flush);
+			if (need_rmap_locks)
+				drop_rmap_locks(vma);
+			if (moved)
+				continue;
 		}
+
 		if (pte_alloc(new_vma->vm_mm, new_pmd, new_addr))
 			break;
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
-- 
2.19.0.605.g01d371f741-goog
