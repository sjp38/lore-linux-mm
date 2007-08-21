Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LKh0PC015282
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:00 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKh0cd266978
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:43:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKh0YU027145
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:43:00 -0600
Subject: [RFC][PATCH 8/9] pagemap: use page walker pte_hole() helper
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:57 -0700
References: <20070821204248.0F506A29@kernel>
In-Reply-To: <20070821204248.0F506A29@kernel>
Message-Id: <20070821204257.BB3A4C17@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I tried to do this a bit more incrementally, but it ended
up just looking like an even worse mess.  So, this does
a a couple of different things.

1. use page walker pte_hole() helper, which
2. gets rid of the "next" value in "struct pagemapread"
3. allow 1-3 byte reads from pagemap.  This at least
   ensures that we don't write over user memory if they
   ask us for 1 bytes and we tried to write 4.
4. Instead of trying to calculate what ranges of pages
   we are going to walk, simply start walking them,
   then return PAGEMAP_END_OF_BUFFER at the end of the
   buffer, error out, and stop walking.
5. enforce that reads must be algined to PM_ENTRY_BYTES

Note that, despite these functional additions, and some
nice new comments, this patch still removes more code
than it adds.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |  123 ++++++++++++++++++++------------------------
 1 file changed, 56 insertions(+), 67 deletions(-)

diff -puN fs/proc/task_mmu.c~bail-instead-of-tracking fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~bail-instead-of-tracking	2007-08-21 13:30:54.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:54.000000000 -0700
@@ -501,7 +501,6 @@ const struct file_operations proc_clear_
 };
 
 struct pagemapread {
-	unsigned long next;
 	unsigned long pos;
 	size_t count;
 	int index;
@@ -510,58 +509,64 @@ struct pagemapread {
 
 #define PM_ENTRY_BYTES sizeof(unsigned long)
 #define PM_NOT_PRESENT ((unsigned long)-1)
+#define PAGEMAP_END_OF_BUFFER 1
 
 static int add_to_pagemap(unsigned long addr, unsigned long pfn,
 			  struct pagemapread *pm)
 {
-	__put_user(pfn, pm->out);
-	pm->out++;
-	pm->next = addr + PAGE_SIZE;
+	int out_len = PM_ENTRY_BYTES;
+	if (pm->count < PM_ENTRY_BYTES)
+		out_len = pm->count;
+	copy_to_user(pm->out, &pfn, out_len);
 	pm->pos += PM_ENTRY_BYTES;
 	pm->count -= PM_ENTRY_BYTES;
+	if (pm->count <= 0)
+		return PAGEMAP_END_OF_BUFFER;
 	return 0;
 }
 
+static int pagemap_pte_hole(unsigned long start, unsigned long end,
+				void *private)
+{
+	struct pagemapread *pm = private;
+	unsigned long addr;
+	int err = 0;
+	for (addr = start; addr < end; addr += PAGE_SIZE) {
+		err = add_to_pagemap(addr, PM_NOT_PRESENT, pm);
+		if (err)
+			break;
+	}
+	return err;
+}
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     void *private)
 {
 	struct pagemapread *pm = private;
 	pte_t *pte;
-	int err;
+	int err = 0;
 
 	pte = pte_offset_map(pmd, addr);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
-		if (addr < pm->next)
-			continue;
-		if (!pte_present(*pte))
-			err = add_to_pagemap(addr, PM_NOT_PRESENT, pm);
-		else
-			err = add_to_pagemap(addr, pte_pfn(*pte), pm);
+		unsigned long pfn = PM_NOT_PRESENT;
+		if (pte_present(*pte))
+			pfn = pte_pfn(*pte);
+		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
 			return err;
-		if (pm->count == 0)
-			break;
 	}
 	pte_unmap(pte - 1);
 
 	cond_resched();
 
-	return 0;
+	return err;
 }
 
-static int pagemap_fill(struct pagemapread *pm, unsigned long end)
+static struct mm_walk pagemap_walk =
 {
-	int ret;
-
-	while (pm->next != end && pm->count > 0) {
-		ret = add_to_pagemap(pm->next, -1UL, pm);
-		if (ret)
-			return ret;
-	}
-	return 0;
-}
-
-static struct mm_walk pagemap_walk = { .pmd_entry = pagemap_pte_range };
+	.pmd_entry = pagemap_pte_range,
+	.pte_hole = pagemap_pte_hole
+};
 
 /*
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
@@ -589,9 +594,8 @@ static ssize_t pagemap_read(struct file 
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
 	unsigned long src = *ppos;
 	struct page **pages, *page;
-	unsigned long addr, end, vend, svpfn, evpfn, uaddr, uend;
+	unsigned long uaddr, uend;
 	struct mm_struct *mm;
-	struct vm_area_struct *vma;
 	struct pagemapread pm;
 	int pagecount;
 	int ret = -ESRCH;
@@ -603,16 +607,10 @@ static ssize_t pagemap_read(struct file 
 	if (!ptrace_may_attach(task))
 		goto out;
 
-	ret = -EIO;
-	svpfn = src / PM_ENTRY_BYTES;
-	addr = PAGE_SIZE * svpfn;
-	if (svpfn * PM_ENTRY_BYTES != src)
+	ret = -EINVAL;
+	/* file position must be aligned */
+	if (*ppos % PM_ENTRY_BYTES)
 		goto out;
-	evpfn = min((src + count) / sizeof(unsigned long) - 1,
-		    ((~0UL) >> PAGE_SHIFT) + 1);
-	count = (evpfn - svpfn) * PM_ENTRY_BYTES;
-	end = PAGE_SIZE * evpfn;
-	//printk("src %ld svpfn %d evpfn %d count %d\n", src, svpfn, evpfn, count);
 
 	ret = 0;
 	mm = get_task_mm(task);
@@ -632,44 +630,36 @@ static ssize_t pagemap_read(struct file 
 			     1, 0, pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
-	//printk("%x(%x):%x %d@%ld (%d pages) -> %d\n", uaddr, buf, uend, count, src, pagecount, ret);
 	if (ret < 0)
 		goto out_free;
 
-	pm.next = addr;
 	pm.pos = src;
 	pm.count = count;
 	pm.out = (unsigned long __user *)buf;
 
-	down_read(&mm->mmap_sem);
-	vma = find_vma(mm, pm.next);
-	while (pm.count > 0 && vma) {
-		if (!ptrace_may_attach(task)) {
-			ret = -EIO;
-			up_read(&mm->mmap_sem);
-			goto out_release;
-		}
-		vend = min(vma->vm_end - 1, end - 1) + 1;
-		ret = pagemap_fill(&pm, vend);
-		if (ret || !pm.count)
-			break;
-		vend = min(vma->vm_end - 1, end - 1) + 1;
-		ret = walk_page_range(mm, vma->vm_start, vend,
-				      &pagemap_walk, &pm);
-		vma = vma->vm_next;
+	if (!ptrace_may_attach(task)) {
+		ret = -EIO;
+	} else {
+		unsigned long src = *ppos;
+		unsigned long svpfn = src / PM_ENTRY_BYTES;
+		unsigned long start_vaddr = svpfn << PAGE_SHIFT;
+		unsigned long end_vaddr = TASK_SIZE_OF(task);
+		/*
+		 * The odds are that this will stop walking way
+		 * before end_vaddr, because the length of the
+		 * user buffer is tracked in "pm", and the walk
+		 * will stop when we hit the end of the buffer.
+		 */
+		ret = walk_page_range(mm, start_vaddr, end_vaddr,
+					&pagemap_walk, &pm);
+		if (ret == PAGEMAP_END_OF_BUFFER)
+			ret = 0;
+		/* don't need mmap_sem for these, but this looks cleaner */
+		*ppos = pm.pos;
+		if (!ret)
+			ret = pm.pos - src;
 	}
-	up_read(&mm->mmap_sem);
-
-	//printk("before fill at %ld\n", pm.pos);
-	ret = pagemap_fill(&pm, end);
-
-	printk("after fill at %ld\n", pm.pos);
-	*ppos = pm.pos;
-	if (!ret)
-		ret = pm.pos - src;
 
-out_release:
-	printk("releasing pages\n");
 	for (; pagecount; pagecount--) {
 		page = pages[pagecount-1];
 		if (!PageReserved(page))
@@ -682,7 +672,6 @@ out_free:
 out_task:
 	put_task_struct(task);
 out:
-	printk("returning\n");
 	return ret;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
