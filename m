Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E5CB46B01F2
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 04:34:57 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S8Ytr9018358
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 17:34:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E70F345DE50
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:34:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0CFB45DE4E
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:34:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BDFC1DB8041
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:34:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 357381DB803E
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 17:34:54 +0900 (JST)
Date: Wed, 28 Apr 2010 17:30:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428173054.7b6716cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 22:30:52 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> During exec(), a temporary stack is setup and moved later to its final
> location. There is a race between migration and exec whereby a migration
> PTE can be placed in the temporary stack. When this VMA is moved under the
> lock, migration no longer knows where the PTE is, fails to remove the PTE
> and the migration PTE gets copied to the new location.  This later causes
> a bug when the migration PTE is discovered but the page is not locked.
> 
> This patch handles the situation by removing the migration PTE when page
> tables are being moved in case migration fails to find them. The alternative
> would require significant modification to vma_adjust() and the locks taken
> to ensure a VMA move and page table copy is atomic with respect to migration.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Here is my final proposal (before going vacation.)

I think this is very simple. The biggest problem is when move_page_range
fails, setup_arg_pages pass it all to exit() ;)

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is an band-aid patch for avoiding unmap->remap of stack pages
while it's udner exec(). At exec, pages for stack is moved by
setup_arg_pages(). Under this, (vma,page)<->address relationship
can be in broken state.
Moreover, if moving ptes fails, pages with not-valid-rmap remains
in the page table and objrmap for the page is completely broken
until exit() frees all up.

This patch adds vma->broken_rmap. If broken_rmap != 0, vma_address()
returns -EFAULT always and try_to_unmap() fails.
(IOW, the pages for stack are pinned until setup_arg_pages() ends.)

And this prevents page migration because the page's mapcount never
goes to 0 until exec() fixes it up.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c                |    4 +++-
 include/linux/mm_types.h |    5 +++++
 mm/rmap.c                |    5 +++++
 3 files changed, 13 insertions(+), 1 deletion(-)

Index: mel-test/fs/exec.c
===================================================================
--- mel-test.orig/fs/exec.c
+++ mel-test/fs/exec.c
@@ -250,7 +250,8 @@ static int __bprm_mm_init(struct linux_b
 	err = insert_vm_struct(mm, vma);
 	if (err)
 		goto err;
-
+	/* prevent rmap_walk, try_to_unmap() etc..until we get fixed rmap */
+	vma->unstable_rmap = 1;
 	mm->stack_vm = mm->total_vm = 1;
 	up_write(&mm->mmap_sem);
 	bprm->p = vma->vm_end - sizeof(void *);
@@ -653,6 +654,7 @@ int setup_arg_pages(struct linux_binprm 
 		ret = -EFAULT;
 
 out_unlock:
+	vma->unstable_rmap = 0;
 	up_write(&mm->mmap_sem);
 	return ret;
 }
Index: mel-test/include/linux/mm_types.h
===================================================================
--- mel-test.orig/include/linux/mm_types.h
+++ mel-test/include/linux/mm_types.h
@@ -183,6 +183,11 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	/*
+ 	 * updated only under down_write(mmap_sem). while this is not 0,
+ 	 * objrmap is not trustable.
+ 	 */
+	int unstable_rmap;
 };
 
 struct core_thread {
Index: mel-test/mm/rmap.c
===================================================================
--- mel-test.orig/mm/rmap.c
+++ mel-test/mm/rmap.c
@@ -332,6 +332,11 @@ vma_address(struct page *page, struct vm
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	unsigned long address;
+#ifdef CONFIG_MIGRATION
+	/* While unstable_rmap is set, we cannot trust objrmap */
+	if (unlikely(vma->unstable_rmap))
+		return -EFAULT:
+#endif
 
 	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
