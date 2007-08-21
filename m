Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LKiCe2018572
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:44:12 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKgn10163170
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:42:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKgnmr016791
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:42:49 -0400
Subject: [RFC][PATCH 1/9] /proc/pid/pagemap update
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:48 -0700
Message-Id: <20070821204248.0F506A29@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a series of patches to update /proc/pid/pagemap,
to simplify the code, and fix bugs which caused userspace
memory corruption.

Since it is just in -mm, we should probably roll all of
these together and just update it all at once, or send
a simple drop-on replacement patch.  These patches are
all here mostly to help with review.

Matt, if you're OK with these, do you mind if I send
the update into -mm, or would you like to do it?

--
From: Matt Mackall <mpm@selenic.com>

On Mon, Aug 06, 2007 at 01:44:19AM -0500, Dave Boutcher wrote:
> 
> Matt, this patch set replaces the two patches I sent earlier and
> contains additional fixes.  I've done some reasonably rigorous testing
> on x86_64, but not on a 32 bit arch.  I'm pretty sure this isn't worse
> than what's in mm right now, which has some user-space corruption and
> a nasty infinite kernel loop. YMMV.

Dave, here's my current work-in-progress patch to deal with a couple
locking issues, primarily a possible deadlock on the mm semaphore that
can occur if someone unmaps the target buffer while we're walking the
tree. It currently hangs on my box and I haven't had any free cycles
to finish debugging it, but you might want to take a peek at it.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |  121 ++++++++++++++++++++------------------------
 1 file changed, 55 insertions(+), 66 deletions(-)

diff -puN fs/proc/task_mmu.c~Re-_PATCH_0_3_proc_pid_pagemap_fixes fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~Re-_PATCH_0_3_proc_pid_pagemap_fixes	2007-08-21 13:30:50.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:50.000000000 -0700
@@ -501,37 +501,21 @@ const struct file_operations proc_clear_
 };
 
 struct pagemapread {
-	struct mm_struct *mm;
 	unsigned long next;
-	unsigned long *buf;
-	pte_t *ptebuf;
 	unsigned long pos;
 	size_t count;
 	int index;
-	char __user *out;
+	unsigned long __user *out;
 };
 
-static int flush_pagemap(struct pagemapread *pm)
-{
-	int n = min(pm->count, pm->index * sizeof(unsigned long));
-	if (copy_to_user(pm->out, pm->buf, n))
-		return -EFAULT;
-	pm->out += n;
-	pm->pos += n;
-	pm->count -= n;
-	pm->index = 0;
-	cond_resched();
-	return 0;
-}
-
 static int add_to_pagemap(unsigned long addr, unsigned long pfn,
 			  struct pagemapread *pm)
 {
-	pm->buf[pm->index++] = pfn;
+	__put_user(pfn, pm->out);
+	pm->out++;
+	pm->pos += sizeof(unsigned long);
+	pm->count -= sizeof(unsigned long);
 	pm->next = addr + PAGE_SIZE;
-	if (pm->index * sizeof(unsigned long) >= PAGE_SIZE ||
-	    pm->index * sizeof(unsigned long) >= pm->count)
-		return flush_pagemap(pm);
 	return 0;
 }
 
@@ -543,14 +527,6 @@ static int pagemap_pte_range(pmd_t *pmd,
 	int err;
 
 	pte = pte_offset_map(pmd, addr);
-
-#ifdef CONFIG_HIGHPTE
-	/* copy PTE directory to temporary buffer and unmap it */
-	memcpy(pm->ptebuf, pte, PAGE_ALIGN((unsigned long)pte) - (unsigned long)pte);
-	pte_unmap(pte);
-	pte = pm->ptebuf;
-#endif
-
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		if (addr < pm->next)
 			continue;
@@ -560,11 +536,12 @@ static int pagemap_pte_range(pmd_t *pmd,
 			err = add_to_pagemap(addr, pte_pfn(*pte), pm);
 		if (err)
 			return err;
+		if (pm->count == 0)
+			break;
 	}
-
-#ifndef CONFIG_HIGHPTE
 	pte_unmap(pte - 1);
-#endif
+
+	cond_resched();
 
 	return 0;
 }
@@ -573,7 +550,7 @@ static int pagemap_fill(struct pagemapre
 {
 	int ret;
 
-	while (pm->next != end) {
+	while (pm->next != end && pm->count > 0) {
 		ret = add_to_pagemap(pm->next, -1UL, pm);
 		if (ret)
 			return ret;
@@ -608,15 +585,16 @@ static ssize_t pagemap_read(struct file 
 {
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
 	unsigned long src = *ppos;
-	unsigned long *page;
-	unsigned long addr, end, vend, svpfn, evpfn;
+	struct page **pages, *page;
+	unsigned long addr, end, vend, svpfn, evpfn, uaddr, uend;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	struct pagemapread pm;
+	int pagecount;
 	int ret = -ESRCH;
 
 	if (!task)
-		goto out_no_task;
+		goto out;
 
 	ret = -EACCES;
 	if (!ptrace_may_attach(task))
@@ -628,39 +606,43 @@ static ssize_t pagemap_read(struct file 
 	if ((svpfn + 1) * sizeof(unsigned long) != src)
 		goto out;
 	evpfn = min((src + count) / sizeof(unsigned long) - 1,
-		    ((~0UL) >> PAGE_SHIFT) + 1);
+		    ((~0UL) >> PAGE_SHIFT) + 1) - 1;
 	count = (evpfn - svpfn) * sizeof(unsigned long);
 	end = PAGE_SIZE * evpfn;
-
-	ret = -ENOMEM;
-	page = kzalloc(PAGE_SIZE, GFP_USER);
-	if (!page)
-		goto out;
-
-#ifdef CONFIG_HIGHPTE
-	pm.ptebuf = kzalloc(PAGE_SIZE, GFP_USER);
-	if (!pm.ptebuf)
-		goto out_free;
-#endif
+	//printk("src %ld svpfn %d evpfn %d count %d\n", src, svpfn, evpfn, count);
 
 	ret = 0;
 	mm = get_task_mm(task);
 	if (!mm)
-		goto out_freepte;
+		goto out;
+
+	ret = -ENOMEM;
+	uaddr = (unsigned long)buf & ~(PAGE_SIZE-1);
+	uend = (unsigned long)(buf + count);
+	pagecount = (uend - uaddr + PAGE_SIZE-1) / PAGE_SIZE;
+	pages = kmalloc(pagecount * sizeof(struct page *), GFP_KERNEL);
+	if (!pages)
+		goto out_task;
+
+	down_read(&current->mm->mmap_sem);
+	ret = get_user_pages(current, current->mm, uaddr, pagecount,
+			     1, 0, pages, NULL);
+	up_read(&current->mm->mmap_sem);
+
+	//printk("%x(%x):%x %d@%ld (%d pages) -> %d\n", uaddr, buf, uend, count, src, pagecount, ret);
+	if (ret < 0)
+		goto out_free;
 
-	pm.mm = mm;
 	pm.next = addr;
-	pm.buf = page;
 	pm.pos = src;
 	pm.count = count;
-	pm.index = 0;
-	pm.out = buf;
+	pm.out = (unsigned long __user *)buf;
 
 	if (svpfn == -1) {
-		((char *)page)[0] = (ntohl(1) != 1);
-		((char *)page)[1] = PAGE_SHIFT;
-		((char *)page)[2] = sizeof(unsigned long);
-		((char *)page)[3] = sizeof(unsigned long);
+		put_user((char)(ntohl(1) != 1), buf);
+		put_user((char)PAGE_SHIFT, buf + 1);
+		put_user((char)sizeof(unsigned long), buf + 2);
+		put_user((char)sizeof(unsigned long), buf + 3);
 		add_to_pagemap(pm.next, page[0], &pm);
 	}
 
@@ -669,7 +651,8 @@ static ssize_t pagemap_read(struct file 
 	while (pm.count > 0 && vma) {
 		if (!ptrace_may_attach(task)) {
 			ret = -EIO;
-			goto out_mm;
+			up_read(&mm->mmap_sem);
+			goto out_release;
 		}
 		vend = min(vma->vm_end - 1, end - 1) + 1;
 		ret = pagemap_fill(&pm, vend);
@@ -682,23 +665,29 @@ static ssize_t pagemap_read(struct file 
 	}
 	up_read(&mm->mmap_sem);
 
+	//printk("before fill at %ld\n", pm.pos);
 	ret = pagemap_fill(&pm, end);
 
+	printk("after fill at %ld\n", pm.pos);
 	*ppos = pm.pos;
 	if (!ret)
 		ret = pm.pos - src;
 
-out_mm:
+out_release:
+	printk("releasing pages\n");
+	for (; pagecount; pagecount--) {
+		page = pages[pagecount-1];
+		if (!PageReserved(page))
+			SetPageDirty(page);
+		page_cache_release(page);
+	}
 	mmput(mm);
-out_freepte:
-#ifdef CONFIG_HIGHPTE
-	kfree(pm.ptebuf);
 out_free:
-#endif
-	kfree(page);
-out:
+	kfree(pages);
+out_task:
 	put_task_struct(task);
-out_no_task:
+out:
+	printk("returning\n");
 	return ret;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
