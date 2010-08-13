Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 07C686B01F1
	for <linux-mm@kvack.org>; Fri, 13 Aug 2010 15:52:58 -0400 (EDT)
Date: Fri, 13 Aug 2010 21:52:52 +0200
From: Helge Deller <deller@gmx.de>
Subject: [PATCH][RFC] Fix up rss/swap usage of shm segments in /proc/pid/smaps
Message-ID: <20100813195252.GA2450@p100.box>
References: <20100811201345.GA11304@p100.box>
 <20100812131005.e466a9fd.akpm@linux-foundation.org>
 <4C6468A9.7090503@gmx.de>
 <alpine.DEB.1.00.1008121522150.9966@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.1008121522150.9966@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
Cc: Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

> > By the way - I found another bug/issue in /proc/<pid>/smaps as well. The
> > kernel currently does not adds swapped-out shm pages to the swap size value
> > correctly. The swap size value always stays zero for shm pages. I'm currently
> > preparing a small patch to fix that, which I will send to linux-mm for review
> > soon.
> 
> I certainly wouldn't call smaps's present behaviour on it a bug: but given
> your justification above, I can see that it would be more useful to you,
> and probably to others, for it to be changed in the way that you suggest,
> to reveal the underlying swap.
> 
> Hmm, I wonder what that patch is going to look like...

:-)

I tried quite hard to implement rss/swap accounting for shm segments inside
smaps_pte_range() which is a callback function of walk_page_range() in
show_smap().

Given the fact that I'm no linux-mm expert, I might have overseen other
possibilities, but my experiments inside smaps_pte_range() were not
very successful:
>From my tests, a swapped-out shm segment 
	- fails on the "is_swap_pte()" test, and
	- succeeds on the "!pte_present()" test (since it's swapped
	  out).
So, here would it be possible to add such accounting for swap, but how
can I then see that this pte is 
	a) belonging to a shm segment?, and
	b) see if this page/pte was really swapped out and not just not
yet written to at all?
As answers I found:
	a) (vma->vm_flags & VM_MAYSHARE) is true for shm segments (is
		this check sufficient?)
	b) no idea.

But if I add this page to the mss.swap entry, all pages including such 
which haven't been touched yet at all are suddenly counted as
swapped-out...?

Any hints here would be great...


As an alternative solution, I created the following patch.
This one works nicely, but it's just a fix-up of the mss.resident and
mss.swap values after walk_page_range() was called.
It's mostly a copy of the shm_add_rss_swap() function from 
my previous patch (http://marc.info/?l=linux-mm&m=128171161101817&w=2).
Do you think such a fix-up-afterwards-approach is acceptable at all?
If yes, a new patch on top of my ipc/shm.c patch would be easy (and
small).

Comments?

Helge



diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index aea1d3f..a1ef7c9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -9,6 +9,7 @@
 #include <linux/mempolicy.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -392,6 +393,31 @@ static int show_smap(struct seq_file *m, void *v)
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
 
+#ifdef CONFIG_SYSVIPC
+	/* sysvipc shm segments and hugepages are counted wrong in
+	 * walk_page_range(). Fix it up.
+	 */
+	if (vma->vm_file && (vma->vm_flags & VM_MAYSHARE)) {
+		struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+		if (is_file_hugepages(vma->vm_file)) {
+			struct address_space *mapping = inode->i_mapping;
+			struct hstate *h = hstate_file(vma->vm_file);
+			mss.resident = pages_per_huge_page(h) * 
+				mapping->nrpages * PAGE_SIZE;
+		} else {
+#ifdef CONFIG_SHMEM
+			struct shmem_inode_info *info = SHMEM_I(inode);
+			spin_lock(&info->lock);
+			mss.resident = inode->i_mapping->nrpages * PAGE_SIZE;
+			mss.swap = info->swapped * PAGE_SIZE;
+			spin_unlock(&info->lock);
+#else
+			mss.resident = inode->i_mapping->nrpages * PAGE_SIZE;
+#endif
+		}
+	}
+#endif
+	
 	show_map_vma(m, vma);
 
 	seq_printf(m,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
