Date: Mon, 13 Mar 2000 16:32:36 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
In-Reply-To: <Pine.LNX.4.10.10003131229580.1257-100000@penguin.transmeta.com>
Message-ID: <Pine.BSO.4.10.10003131630570.12643-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Mar 2000, Linus Torvalds wrote:
> On Mon, 13 Mar 2000, Chuck Lever wrote:
> > > So I'd prefer something that does not have the "incore" function at all,
> > > and if that convinces somebody else to change shm to use the address_space
> > > stuff to get a working mincore(), all the better. Ok?
> > 
> > hmm.  i created the "incore" method because mincore needs to synchronize
> > with the swapping method used for each of the different vma types.  this
> > is different for shm's vs. mapped files -- they both use locking methods
> > that are independent of one another.
> 
> But that's exactly my point. The shm version is bad, and it will be
> eventually removed ;)

ok, try this on for size.

diff -ruN Linux-2.3.51/arch/i386/kernel/entry.S linux/arch/i386/kernel/entry.S
--- Linux-2.3.51/arch/i386/kernel/entry.S	Sun Mar 12 18:42:20 2000
+++ linux/arch/i386/kernel/entry.S	Sun Mar 12 18:47:04 2000
@@ -638,6 +638,7 @@
 	.long SYMBOL_NAME(sys_setfsuid)		/* 215 */
 	.long SYMBOL_NAME(sys_setfsgid)
 	.long SYMBOL_NAME(sys_pivot_root)
+	.long SYMBOL_NAME(sys_mincore)
 
 
 	/*
@@ -646,6 +647,6 @@
 	 * entries. Don't panic if you notice that this hasn't
 	 * been shrunk every time we add a new system call.
 	 */
-	.rept NR_syscalls-217
+	.rept NR_syscalls-218
 		.long SYMBOL_NAME(sys_ni_syscall)
 	.endr
diff -ruN Linux-2.3.51/include/asm-i386/unistd.h linux/include/asm-i386/unistd.h
--- Linux-2.3.51/include/asm-i386/unistd.h	Wed Jan 26 15:32:02 2000
+++ linux/include/asm-i386/unistd.h	Mon Mar 13 15:52:08 2000
@@ -222,6 +222,7 @@
 #define __NR_setfsuid32		215
 #define __NR_setfsgid32		216
 #define __NR_pivot_root		217
+#define __NR_mincore		218
 
 /* user-visible error numbers are in the range -1 - -124: see <asm-i386/errno.h> */
 
diff -ruN Linux-2.3.51/mm/filemap.c linux/mm/filemap.c
--- Linux-2.3.51/mm/filemap.c	Sun Mar 12 18:42:48 2000
+++ linux/mm/filemap.c	Mon Mar 13 16:13:58 2000
@@ -1727,6 +1727,160 @@
 	return error;
 }
 
+/*
+ * Later we can get more picky about what "in core" means precisely.
+ * For now, simply check to see if the page is in the page cache,
+ * and is up to date; i.e. that no page-in operation would be required
+ * at this time if an application were to map and access this page.
+ */
+static unsigned char mincore_page(struct vm_area_struct * vma,
+	unsigned long pgoff)
+{
+	unsigned char present = 0;
+	struct address_space * as = &vma->vm_file->f_dentry->d_inode->i_data;
+	struct page * page, ** hash = page_hash(as, pgoff);
+
+	spin_lock(&pagecache_lock);
+	page = __find_page_nolock(as, pgoff, *hash);
+	if ((page) && (Page_Uptodate(page)))
+		present = 1;
+	spin_unlock(&pagecache_lock);
+
+	return present;
+}
+
+static long mincore_vma(struct vm_area_struct * vma,
+	unsigned long start, unsigned long end, unsigned char * vec)
+{
+	long error, i, remaining;
+	unsigned char * tmp;
+
+	error = -ENOMEM;
+	if (!vma->vm_file)
+		return error;
+
+	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	if (end > vma->vm_end)
+		end = vma->vm_end;
+	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	error = -EAGAIN;
+	tmp = (unsigned char *) __get_free_page(GFP_KERNEL);
+	if (!tmp)
+		return error;
+
+	/* (end - start) is # of pages, and also # of bytes in "vec */
+	remaining = (end - start),
+
+	error = 0;
+	for (i = 0; remaining > 0; remaining -= PAGE_SIZE, i++) {
+		int j = 0;
+		long thispiece = (remaining < PAGE_SIZE) ?
+						remaining : PAGE_SIZE;
+
+		while (j < thispiece)
+			tmp[j++] = mincore_page(vma, start++);
+
+		if (copy_to_user(vec + PAGE_SIZE * i, tmp, thispiece)) {
+			error = -EFAULT;
+			break;
+		}
+	}
+
+	free_page((unsigned long) tmp);
+	return error;
+}
+
+/*
+ * The mincore(2) system call.
+ *
+ * mincore() returns the memory residency status of the pages in the
+ * current process's address space specified by [addr, addr + len).
+ * The status is returned in a vector of bytes.  The least significant
+ * bit of each byte is 1 if the referenced page is in memory, otherwise
+ * it is zero.
+ *
+ * Because the status of a page can change after mincore() checks it
+ * but before it returns to the application, the returned vector may
+ * contain stale information.  Only locked pages are guaranteed to
+ * remain in memory.
+ *
+ * return values:
+ *  zero    - success
+ *  -EFAULT - vec points to an illegal address
+ *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE,
+ *		or len has a nonpositive value
+ *  -ENOMEM - Addresses in the range [addr, addr + len] are
+ *		invalid for the address space of this process, or
+ *		specify one or more pages which are not currently
+ *		mapped
+ *  -EAGAIN - A kernel resource was temporarily unavailable.
+ */
+asmlinkage long sys_mincore(unsigned long start, size_t len,
+	unsigned char * vec)
+{
+	int index = 0;
+	unsigned long end;
+	struct vm_area_struct * vma;
+	int unmapped_error = 0;
+	long error = -EINVAL;
+
+	down(&current->mm->mmap_sem);
+
+	if (start & ~PAGE_MASK)
+		goto out;
+	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	error = 0;
+	if (end == start)
+		goto out;
+
+	/*
+	 * If the interval [start,end) covers some unmapped address
+	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 */
+	vma = find_vma(current->mm, start);
+	for (;;) {
+		/* Still start < end. */
+		error = -ENOMEM;
+		if (!vma)
+			goto out;
+
+		/* Here start < vma->vm_end. */
+		if (start < vma->vm_start) {
+			unmapped_error = -ENOMEM;
+			start = vma->vm_start;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end. */
+		if (end <= vma->vm_end) {
+			if (start < end) {
+				error = mincore_vma(vma, start, end,
+							&vec[index]);
+				if (error)
+					goto out;
+			}
+			error = unmapped_error;
+			goto out;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end < end. */
+		error = mincore_vma(vma, start, vma->vm_end, &vec[index]);
+		if (error)
+			goto out;
+		index += (vma->vm_end - start) >> PAGE_CACHE_SHIFT;
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	}
+
+out:
+	up(&current->mm->mmap_sem);
+	return error;
+}
+
 struct page *read_cache_page(struct address_space *mapping,
 				unsigned long index,
 				int (*filler)(void *,struct page*),

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
