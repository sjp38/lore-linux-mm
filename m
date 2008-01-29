Date: Tue, 29 Jan 2008 19:28:32 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080129182831.GS7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080129162004.GL7233@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Christoph, the below patch should fix the current leak of the pinned
pages. I hope the page-pin that should be dropped by the
invalidate_range op, is enough to prevent the "physical page" mapped
on that "mm+address" to change before invalidate_range returns. If
that would ever happen, there would be a coherency loss between the
guest VM writes and the writes coming from userland on the same
mm+address from a different thread (qemu, whatever). invalidate_page
before PT lock was obviously safe. Now we entirely relay on the pin to
prevent the page to change before invalidate_range returns. If the pte
is unmapped and the page is mapped back in with a minor fault that's
ok, as long as the physical page remains the same for that mm+address,
until all sptes are gone.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -212,8 +212,8 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	err = populate_range(mm, vma, start, size, pgoff);
 	mmu_notifier(invalidate_range, mm, start, start + size, 0);
-	err = populate_range(mm, vma, start, size, pgoff);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1639,8 +1639,6 @@ gotten:
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	mmu_notifier(invalidate_range, mm, address,
-				address + PAGE_SIZE - 1, 0);
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
@@ -1676,6 +1674,8 @@ gotten:
 		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	mmu_notifier(invalidate_range, mm, address,
+				address + PAGE_SIZE - 1, 0);
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
