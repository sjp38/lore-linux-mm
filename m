From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Date: Wed, 13 Jan 2010 21:53:10 +0800
Message-ID: <20100113135957.833222772@intel.com>
References: <20100113135305.013124116@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07E016B007E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:00:37 -0500 (EST)
Content-Disposition: inline; filename=vread-vwrite-simplify.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

vread()/vwrite() is only called from kcore/kmem to access one page at a time.
So the logic can be vastly simplified.

The changes are:
- remove the vmlist walk and rely solely on vmalloc_to_page()
- replace the VM_IOREMAP check with (page && page_is_ram(pfn))
- rename to vread_page()/vwrite_page()

The page_is_ram() check is necessary because kmap_atomic() is not
designed to work with non-RAM pages.

Note that even for a RAM page, we don't own the page, and cannot assume
it's a _PAGE_CACHE_WB page.

CC: Tejun Heo <tj@kernel.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org> 
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/char/mem.c      |    8 -
 fs/proc/kcore.c         |    2 
 include/linux/vmalloc.h |    6 
 mm/vmalloc.c            |  230 ++++++++------------------------------
 4 files changed, 58 insertions(+), 188 deletions(-)

--- linux-mm.orig/mm/vmalloc.c	2010-01-13 21:23:05.000000000 +0800
+++ linux-mm/mm/vmalloc.c	2010-01-13 21:25:38.000000000 +0800
@@ -1646,232 +1646,102 @@ void *vmalloc_32_user(unsigned long size
 }
 EXPORT_SYMBOL(vmalloc_32_user);
 
-/*
- * small helper routine , copy contents to buf from addr.
- * If the page is not present, fill zero.
- */
-
-static int aligned_vread(char *buf, char *addr, unsigned long count)
-{
-	struct page *p;
-	int copied = 0;
-
-	while (count) {
-		unsigned long offset, length;
-
-		offset = (unsigned long)addr & ~PAGE_MASK;
-		length = PAGE_SIZE - offset;
-		if (length > count)
-			length = count;
-		p = vmalloc_to_page(addr);
-		/*
-		 * To do safe access to this _mapped_ area, we need
-		 * lock. But adding lock here means that we need to add
-		 * overhead of vmalloc()/vfree() calles for this _debug_
-		 * interface, rarely used. Instead of that, we'll use
-		 * kmap() and get small overhead in this access function.
-		 */
-		if (p) {
-			/*
-			 * we can expect USER0 is not used (see vread/vwrite's
-			 * function description)
-			 */
-			void *map = kmap_atomic(p, KM_USER0);
-			memcpy(buf, map + offset, length);
-			kunmap_atomic(map, KM_USER0);
-		} else
-			memset(buf, 0, length);
-
-		addr += length;
-		buf += length;
-		copied += length;
-		count -= length;
-	}
-	return copied;
-}
-
-static int aligned_vwrite(char *buf, char *addr, unsigned long count)
-{
-	struct page *p;
-	int copied = 0;
-
-	while (count) {
-		unsigned long offset, length;
-
-		offset = (unsigned long)addr & ~PAGE_MASK;
-		length = PAGE_SIZE - offset;
-		if (length > count)
-			length = count;
-		p = vmalloc_to_page(addr);
-		/*
-		 * To do safe access to this _mapped_ area, we need
-		 * lock. But adding lock here means that we need to add
-		 * overhead of vmalloc()/vfree() calles for this _debug_
-		 * interface, rarely used. Instead of that, we'll use
-		 * kmap() and get small overhead in this access function.
-		 */
-		if (p) {
-			/*
-			 * we can expect USER0 is not used (see vread/vwrite's
-			 * function description)
-			 */
-			void *map = kmap_atomic(p, KM_USER0);
-			memcpy(map + offset, buf, length);
-			kunmap_atomic(map, KM_USER0);
-		}
-		addr += length;
-		buf += length;
-		copied += length;
-		count -= length;
-	}
-	return copied;
-}
-
 /**
- *	vread() -  read vmalloc area in a safe way.
+ *	vread_page() -  read vmalloc area in a safe way.
  *	@buf:		buffer for reading data
  *	@addr:		vm address.
- *	@count:		number of bytes to be read.
+ *	@count:		number of bytes to read inside the page.
  *
- *	Returns # of bytes which addr and buf should be increased.
- *	(same number to @count). Returns 0 if [addr...addr+count) doesn't
- *	includes any intersect with alive vmalloc area.
+ *	Returns # of bytes copied on success.
+ *	Returns 0 if @addr is not vmalloc'ed, or is mapped to non-RAM.
  *
  *	This function checks that addr is a valid vmalloc'ed area, and
  *	copy data from that area to a given buffer. If the given memory range
  *	of [addr...addr+count) includes some valid address, data is copied to
  *	proper area of @buf. If there are memory holes, they'll be zero-filled.
- *	IOREMAP area is treated as memory hole and no copy is done.
  *
- *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0.
  *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
  *	the caller should guarantee KM_USER0 is not used.
  *
- *	Note: In usual ops, vread() is never necessary because the caller
+ *	Note: In usual ops, vread_page() is never necessary because the caller
  *	should know vmalloc() area is valid and can use memcpy().
  *	This is for routines which have to access vmalloc area without
- *	any informaion, as /dev/kmem.
+ *	any informaion, as /dev/kmem and /dev/kcore.
  *
  */
 
-long vread(char *buf, char *addr, unsigned long count)
+int vread_page(char *buf, char *addr, unsigned int count)
 {
-	struct vm_struct *tmp;
-	char *vaddr, *buf_start = buf;
-	unsigned long buflen = count;
-	unsigned long n;
-
-	/* Don't allow overflow */
-	if ((unsigned long) addr + count < count)
-		count = -(unsigned long) addr;
+	struct page *p;
+	void *map;
+	int offset = (unsigned long)addr & (PAGE_SIZE - 1);
 
-	read_lock(&vmlist_lock);
-	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
-		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
-			continue;
-		while (addr < vaddr) {
-			if (count == 0)
-				goto finished;
-			*buf = '\0';
-			buf++;
-			addr++;
-			count--;
-		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
-		if (n > count)
-			n = count;
-		if (!(tmp->flags & VM_IOREMAP))
-			aligned_vread(buf, addr, n);
-		else /* IOREMAP area is treated as memory hole */
-			memset(buf, 0, n);
-		buf += n;
-		addr += n;
-		count -= n;
-	}
-finished:
-	read_unlock(&vmlist_lock);
+	/* Assume subpage access */
+	BUG_ON(count > PAGE_SIZE - offset);
 
-	if (buf == buf_start)
+	p = vmalloc_to_page(addr);
+	if (!p || !page_is_ram(page_to_pfn(p))) {
+		memset(buf, 0, count);
 		return 0;
-	/* zero-fill memory holes */
-	if (buf != buf_start + buflen)
-		memset(buf, 0, buflen - (buf - buf_start));
+	}
 
-	return buflen;
+	/*
+	 * To do safe access to this _mapped_ area, we need
+	 * lock. But adding lock here means that we need to add
+	 * overhead of vmalloc()/vfree() calles for this _debug_
+	 * interface, rarely used. Instead of that, we'll use
+	 * kmap() and get small overhead in this access function.
+	 */
+	map = kmap_atomic(p, KM_USER0);
+	memcpy(buf, map + offset, count);
+	kunmap_atomic(map, KM_USER0);
+
+	return count;
 }
 
 /**
- *	vwrite() -  write vmalloc area in a safe way.
+ *	vwrite_page() -  write vmalloc area in a safe way.
  *	@buf:		buffer for source data
  *	@addr:		vm address.
- *	@count:		number of bytes to be read.
+ *	@count:		number of bytes to write inside the page.
  *
- *	Returns # of bytes which addr and buf should be incresed.
- *	(same number to @count).
- *	If [addr...addr+count) doesn't includes any intersect with valid
- *	vmalloc area, returns 0.
+ *	Returns # of bytes copied on success.
+ *	Returns 0 if @addr is not vmalloc'ed, or is mapped to non-RAM.
  *
  *	This function checks that addr is a valid vmalloc'ed area, and
  *	copy data from a buffer to the given addr. If specified range of
  *	[addr...addr+count) includes some valid address, data is copied from
  *	proper area of @buf. If there are memory holes, no copy to hole.
- *	IOREMAP area is treated as memory hole and no copy is done.
  *
- *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0.
  *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
  *	the caller should guarantee KM_USER0 is not used.
  *
- *	Note: In usual ops, vwrite() is never necessary because the caller
+ *	Note: In usual ops, vwrite_page() is never necessary because the caller
  *	should know vmalloc() area is valid and can use memcpy().
  *	This is for routines which have to access vmalloc area without
  *	any informaion, as /dev/kmem.
- *
- *	The caller should guarantee KM_USER1 is not used.
  */
 
-long vwrite(char *buf, char *addr, unsigned long count)
+int vwrite_page(char *buf, char *addr, unsigned int count)
 {
-	struct vm_struct *tmp;
-	char *vaddr;
-	unsigned long n, buflen;
-	int copied = 0;
-
-	/* Don't allow overflow */
-	if ((unsigned long) addr + count < count)
-		count = -(unsigned long) addr;
-	buflen = count;
+	struct page *p;
+	void *map;
+	int offset = (unsigned long)addr & (PAGE_SIZE - 1);
 
-	read_lock(&vmlist_lock);
-	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
-		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
-			continue;
-		while (addr < vaddr) {
-			if (count == 0)
-				goto finished;
-			buf++;
-			addr++;
-			count--;
-		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
-		if (n > count)
-			n = count;
-		if (!(tmp->flags & VM_IOREMAP)) {
-			aligned_vwrite(buf, addr, n);
-			copied++;
-		}
-		buf += n;
-		addr += n;
-		count -= n;
-	}
-finished:
-	read_unlock(&vmlist_lock);
-	if (!copied)
+	/* Assume subpage access */
+	BUG_ON(count > PAGE_SIZE - offset);
+
+	p = vmalloc_to_page(addr);
+	if (!p)
+		return 0;
+	if (!page_is_ram(page_to_pfn(p)))
 		return 0;
-	return buflen;
+
+	map = kmap_atomic(p, KM_USER0);
+	memcpy(map + offset, buf, count);
+	kunmap_atomic(map, KM_USER0);
+
+	return count;
 }
 
 /**
--- linux-mm.orig/drivers/char/mem.c	2010-01-13 21:23:58.000000000 +0800
+++ linux-mm/drivers/char/mem.c	2010-01-13 21:26:10.000000000 +0800
@@ -394,7 +394,7 @@ static ssize_t read_kmem(struct file *fi
 {
 	unsigned long p = *ppos;
 	ssize_t low_count, read, sz;
-	char * kbuf; /* k-addr because vread() takes vmlist_lock rwlock */
+	char *kbuf;	/* k-addr because vread_page() does kmap_atomic */
 	int err = 0;
 
 	read = 0;
@@ -446,7 +446,7 @@ static ssize_t read_kmem(struct file *fi
 				err = -ENXIO;
 				break;
 			}
-			sz = vread(kbuf, (char *)p, sz);
+			sz = vread_page(kbuf, (char *)p, sz);
 			if (!sz)
 				break;
 			if (copy_to_user(buf, kbuf, sz)) {
@@ -524,7 +524,7 @@ static ssize_t write_kmem(struct file * 
 	unsigned long p = *ppos;
 	ssize_t wrote = 0;
 	ssize_t virtr = 0;
-	char * kbuf; /* k-addr because vwrite() takes vmlist_lock rwlock */
+	char *kbuf;	/* k-addr because vwrite_page() does kmap_atomic */
 	int err = 0;
 
 	if (p < (unsigned long) high_memory) {
@@ -555,7 +555,7 @@ static ssize_t write_kmem(struct file * 
 				err = -EFAULT;
 				break;
 			}
-			vwrite(kbuf, (char *)p, sz);
+			vwrite_page(kbuf, (char *)p, sz);
 			count -= sz;
 			buf += sz;
 			virtr += sz;
--- linux-mm.orig/fs/proc/kcore.c	2010-01-13 21:23:05.000000000 +0800
+++ linux-mm/fs/proc/kcore.c	2010-01-13 21:24:00.000000000 +0800
@@ -499,7 +499,7 @@ read_kcore(struct file *file, char __use
 			elf_buf = kzalloc(tsz, GFP_KERNEL);
 			if (!elf_buf)
 				return -ENOMEM;
-			vread(elf_buf, (char *)start, tsz);
+			vread_page(elf_buf, (char *)start, tsz);
 			/* we have to zero-fill user buffer even if no read */
 			if (copy_to_user(buffer, elf_buf, tsz)) {
 				kfree(elf_buf);
--- linux-mm.orig/include/linux/vmalloc.h	2010-01-13 21:23:05.000000000 +0800
+++ linux-mm/include/linux/vmalloc.h	2010-01-13 21:24:00.000000000 +0800
@@ -104,9 +104,9 @@ extern void unmap_kernel_range(unsigned 
 extern struct vm_struct *alloc_vm_area(size_t size);
 extern void free_vm_area(struct vm_struct *area);
 
-/* for /dev/kmem */
-extern long vread(char *buf, char *addr, unsigned long count);
-extern long vwrite(char *buf, char *addr, unsigned long count);
+/* for /dev/kmem and /proc/kcore */
+extern int vread_page(char *buf, char *addr, unsigned int count);
+extern int vwrite_page(char *buf, char *addr, unsigned int count);
 
 /*
  *	Internals.  Dont't use..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
