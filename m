Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id DD3776B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:06:56 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so9824320pbb.36
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:06:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id si6si11260985pab.121.2014.04.15.11.06.55
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 11:06:55 -0700 (PDT)
Date: Tue, 15 Apr 2014 11:06:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write
 instead of clear_soft_dirty
Message-Id: <20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
In-Reply-To: <20140324125926.204897920@openvz.org>
References: <20140324122838.490106581@openvz.org>
	<20140324125926.204897920@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, 24 Mar 2014 16:28:42 +0400 Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> The clear_refs_write is called earlier than clear_soft_dirty and it is
> more natural to clear VM_SOFTDIRTY (which belongs to VMA entry but not
> PTEs) that early instead of clearing it a way deeper inside call chain.

This patch had some significant conflicts with the pagewalk patches:

mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
pagewalk-update-page-table-walker-core.patch
pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
pagewalk-add-walk_page_vma.patch
smaps-redefine-callback-functions-for-page-table-walker.patch
clear_refs-redefine-callback-functions-for-page-table-walker.patch
pagemap-redefine-callback-functions-for-page-table-walker.patch
pagemap-redefine-callback-functions-for-page-table-walker-fix.patch
numa_maps-redefine-callback-functions-for-page-table-walker.patch
memcg-redefine-callback-functions-for-page-table-walker.patch
arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
pagewalk-remove-argument-hmask-from-hugetlb_entry-fix.patch
pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix.patch
mempolicy-apply-page-table-walker-on-queue_pages_range.patch
mm-add-pte_present-check-on-existing-hugetlb_entry-callbacks.patch
mm-pagewalkc-move-pte-null-check.patch

I resolved this by merging
mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
on top of the pagewalk patches as below - please carefully review.

I'm hoping we'll be able to get the pagewalk patches merged in 3.16-rc1
- we'll see what happens when the testing gets underway again.


From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: mm: softdirty: clear VM_SOFTDIRTY flag inside clear_refs_write() instead of clear_soft_dirty()

clear_refs_write() is called earlier than clear_soft_dirty() and it is
more natural to clear VM_SOFTDIRTY (which belongs to VMA entry but not
PTEs) that early instead of clearing it a way deeper inside call chain.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/task_mmu.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff -puN fs/proc/task_mmu.c~mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty
+++ a/fs/proc/task_mmu.c
@@ -723,9 +723,6 @@ static inline void clear_soft_dirty(stru
 		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
-	if (vma->vm_flags & VM_SOFTDIRTY)
-		vma->vm_flags &= ~VM_SOFTDIRTY;
-
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
 #endif
 }
@@ -762,11 +759,16 @@ static int clear_refs_test_walk(unsigned
 	 * Writing 1 to /proc/pid/clear_refs affects all pages.
 	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
 	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
+	 * Writing 4 to /proc/pid/clear_refs affects all pages.
 	 */
 	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
 		walk->skip = 1;
 	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
 		walk->skip = 1;
+	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+		if (vma->vm_flags & VM_SOFTDIRTY)
+			vma->vm_flags &= ~VM_SOFTDIRTY;
+	}
 	return 0;
 }
 
@@ -795,8 +797,9 @@ static ssize_t clear_refs_write(struct f
 
 	if (type == CLEAR_REFS_SOFT_DIRTY) {
 		soft_dirty_cleared = true;
-		pr_warn_once("The pagemap bits 55-60 has changed their meaning! "
-				"See the linux/Documentation/vm/pagemap.txt for details.\n");
+		pr_warn_once("The pagemap bits 55-60 has changed their meaning!"
+			     " See the linux/Documentation/vm/pagemap.txt for "
+			     "details.\n");
 	}
 
 	task = get_proc_task(file_inode(file));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
