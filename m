Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 38F506B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 12:18:34 -0400 (EDT)
Date: Sun, 16 Oct 2011 18:13:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 6/X] uprobes: reimplement xol_add_vma() via
	install_special_mapping()
Message-ID: <20111016161359.GA24893@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111015190007.GA30243@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

I apologize in advance if this was already discussed, but I just can't
understand why xol_add_vma() does not use install_special_mapping().
Unless I missed something this should work and this has the following
advantages:

	- we can avoid override_creds() hacks, install_special_mapping()
	  fools security_file_mmap() passing prot/flags = 0

	- no need to play with vma after do_mmap_pgoff()

	- no need for get_user_pages(FOLL_WRITE/FOLL_FORCE) hack

	- no need for do_munmap() if get_user_pages() fails

	- this protects us from mprotect(READ/WRITE)

	- this protects from MADV_DONTNEED, the page will be correctly
	  re-instantiated from area->page

	- this makes xol_vma more "cheap", swapper can't see this page
	  and we avoid the meaningless add_to_swap/pageout.

	  Note that, before this patch, area->page can't be removed
	  from the swap cache anyway (we have the reference). And it
	  must not, uprobes modifies this page directly.

Note on vm_flags:

	- we do not use VM_DONTEXPAND, install_special_mapping() adds it

	- VM_IO protects from MADV_DOFORK

	- I am not sure, may be some archs need VM_READ along with EXEC?

Anything else I have missed?
---

 kernel/uprobes.c |   42 +++++++++++++++++++-----------------------
 1 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index b59af3b..038f21c 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1045,53 +1045,49 @@ void munmap_uprobe(struct vm_area_struct *vma)
 /* Slot allocation for XOL */
 static int xol_add_vma(struct uprobes_xol_area *area)
 {
-	const struct cred *curr_cred;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
-	unsigned long addr;
+	unsigned long addr_hint;
 	int ret;
 
+	area->page = alloc_page(GFP_HIGHUSER);
+	if (!area->page)
+		return -ENOMEM;
+
 	mm = current->mm;
 
 	down_write(&mm->mmap_sem);
 	ret = -EALREADY;
 	if (mm->uprobes_xol_area)
 		goto fail;
-
-	ret = -ENOMEM;
 	/*
 	 * Find the end of the top mapping and skip a page.
-	 * If there is no space for PAGE_SIZE above
-	 * that, mmap will ignore our address hint.
-	 *
-	 * override credentials otherwise anonymous memory might
-	 * not be granted execute permission when the selinux
-	 * security hooks have their way.
+	 * If there is no space for PAGE_SIZE above that,
+	 * this hint will be ignored.
 	 */
 	vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
-	addr = vma->vm_end + PAGE_SIZE;
-	curr_cred = override_creds(&init_cred);
-	addr = do_mmap_pgoff(NULL, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
-	revert_creds(curr_cred);
+	addr_hint = vma->vm_end + PAGE_SIZE;
 
-	if (IS_ERR_VALUE(addr))
+	area->vaddr = get_unmapped_area(NULL, addr_hint, PAGE_SIZE, 0, 0);
+	if (IS_ERR_VALUE(area->vaddr)) {
+		ret = area->vaddr;
 		goto fail;
+	}
 
-	vma = find_vma(mm, addr);
-	/* Don't expand vma on mremap(). */
-	vma->vm_flags |= VM_DONTEXPAND | VM_DONTCOPY;
-	if (get_user_pages(current, mm, addr, 1, 1, 1,
-					&area->page, NULL) != 1) {
-		do_munmap(mm, addr, PAGE_SIZE);
+	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
+					VM_EXEC|VM_MAYEXEC | VM_DONTCOPY|VM_IO,
+					&area->page);
+	if (ret)
 		goto fail;
-	}
 
-	area->vaddr = addr;
 	smp_wmb();	/* pairs with get_uprobes_xol_area() */
 	mm->uprobes_xol_area = area;
 	ret = 0;
 fail:
 	up_write(&mm->mmap_sem);
+	if (ret)
+		__free_page(area->page);
+
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
