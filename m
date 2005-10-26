Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9QMoVIM013658
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 18:50:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9QMoStF533146
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 16:50:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9QMoRZs018199
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 16:50:28 -0600
Subject: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-RhW1rAS2huOQ9M7Uhumy"
Date: Wed, 26 Oct 2005 15:49:55 -0700
Message-Id: <1130366995.23729.38.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de
Cc: Jeff Dike <jdike@addtoit.com>, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-RhW1rAS2huOQ9M7Uhumy
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi All,

Based on comments from Hugh & Andrea, I took a shot at implementing
madvise(MADV_TRUNCATE) - which truncates range of pages in the file.
(basically provides ability to punche a hole in to the file).

Basically, I added "truncate_range" inode operation to provide
opportunity for the filesystem to zero the blocks and/or free
them up. 

I also attempted to implement shmem_truncate_range() which 
needs lots of testing before I work out bugs :(

I would really appreciate your comments on my approach.

Thanks,
Badari



--=-RhW1rAS2huOQ9M7Uhumy
Content-Disposition: attachment; filename=madvise-truncate3.patch
Content-Type: text/x-patch; name=madvise-truncate3.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-alpha/mman.h linux-2.6.14-rc5-madv/include/asm-alpha/mman.h
--- linux-2.6.14-rc5/include/asm-alpha/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-alpha/mman.h	2005-10-26 15:48:48.000000000 -0700
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_TRUNCATE	7		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-arm/mman.h linux-2.6.14-rc5-madv/include/asm-arm/mman.h
--- linux-2.6.14-rc5/include/asm-arm/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-arm/mman.h	2005-10-26 15:48:58.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-arm26/mman.h linux-2.6.14-rc5-madv/include/asm-arm26/mman.h
--- linux-2.6.14-rc5/include/asm-arm26/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-arm26/mman.h	2005-10-26 15:48:53.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-cris/mman.h linux-2.6.14-rc5-madv/include/asm-cris/mman.h
--- linux-2.6.14-rc5/include/asm-cris/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-cris/mman.h	2005-10-26 15:49:02.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-frv/mman.h linux-2.6.14-rc5-madv/include/asm-frv/mman.h
--- linux-2.6.14-rc5/include/asm-frv/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-frv/mman.h	2005-10-26 15:49:11.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-h8300/mman.h linux-2.6.14-rc5-madv/include/asm-h8300/mman.h
--- linux-2.6.14-rc5/include/asm-h8300/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-h8300/mman.h	2005-10-26 15:49:15.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-i386/mman.h linux-2.6.14-rc5-madv/include/asm-i386/mman.h
--- linux-2.6.14-rc5/include/asm-i386/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-i386/mman.h	2005-10-26 15:49:20.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-ia64/mman.h linux-2.6.14-rc5-madv/include/asm-ia64/mman.h
--- linux-2.6.14-rc5/include/asm-ia64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-ia64/mman.h	2005-10-26 15:49:26.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-m32r/mman.h linux-2.6.14-rc5-madv/include/asm-m32r/mman.h
--- linux-2.6.14-rc5/include/asm-m32r/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-m32r/mman.h	2005-10-26 15:49:31.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-m68k/mman.h linux-2.6.14-rc5-madv/include/asm-m68k/mman.h
--- linux-2.6.14-rc5/include/asm-m68k/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-m68k/mman.h	2005-10-26 15:49:35.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-mips/mman.h linux-2.6.14-rc5-madv/include/asm-mips/mman.h
--- linux-2.6.14-rc5/include/asm-mips/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-mips/mman.h	2005-10-26 15:49:41.000000000 -0700
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-parisc/mman.h linux-2.6.14-rc5-madv/include/asm-parisc/mman.h
--- linux-2.6.14-rc5/include/asm-parisc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-parisc/mman.h	2005-10-26 15:49:49.000000000 -0700
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_TRUNCATE	8		/* truncate range of pages */
 
 /* The range 12-64 is reserved for page size specification. */
 #define MADV_4K_PAGES   12              /* Use 4K pages  */
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-powerpc/mman.h linux-2.6.14-rc5-madv/include/asm-powerpc/mman.h
--- linux-2.6.14-rc5/include/asm-powerpc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-powerpc/mman.h	2005-10-26 15:49:53.000000000 -0700
@@ -44,6 +44,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-s390/mman.h linux-2.6.14-rc5-madv/include/asm-s390/mman.h
--- linux-2.6.14-rc5/include/asm-s390/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-s390/mman.h	2005-10-26 15:50:08.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL        0x2             /* read-ahead aggressively */
 #define MADV_WILLNEED  0x3              /* pre-fault pages */
 #define MADV_DONTNEED  0x4              /* discard these pages */
+#define MADV_TRUNCATE  0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sh/mman.h linux-2.6.14-rc5-madv/include/asm-sh/mman.h
--- linux-2.6.14-rc5/include/asm-sh/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-sh/mman.h	2005-10-26 15:50:15.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sparc/mman.h linux-2.6.14-rc5-madv/include/asm-sparc/mman.h
--- linux-2.6.14-rc5/include/asm-sparc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-sparc/mman.h	2005-10-26 15:50:31.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_TRUNCATE	0x6		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sparc64/mman.h linux-2.6.14-rc5-madv/include/asm-sparc64/mman.h
--- linux-2.6.14-rc5/include/asm-sparc64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-sparc64/mman.h	2005-10-26 15:50:25.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_TRUNCATE	0x6		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-v850/mman.h linux-2.6.14-rc5-madv/include/asm-v850/mman.h
--- linux-2.6.14-rc5/include/asm-v850/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-v850/mman.h	2005-10-26 15:50:39.000000000 -0700
@@ -32,6 +32,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-x86_64/mman.h linux-2.6.14-rc5-madv/include/asm-x86_64/mman.h
--- linux-2.6.14-rc5/include/asm-x86_64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-x86_64/mman.h	2005-10-26 15:50:43.000000000 -0700
@@ -36,6 +36,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-xtensa/mman.h linux-2.6.14-rc5-madv/include/asm-xtensa/mman.h
--- linux-2.6.14-rc5/include/asm-xtensa/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/asm-xtensa/mman.h	2005-10-26 15:50:46.000000000 -0700
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/linux/fs.h linux-2.6.14-rc5-madv/include/linux/fs.h
--- linux-2.6.14-rc5/include/linux/fs.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/linux/fs.h	2005-10-25 08:59:52.000000000 -0700
@@ -995,6 +995,7 @@ struct inode_operations {
 	ssize_t (*getxattr) (struct dentry *, const char *, void *, size_t);
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
+	void (*truncate_range)(struct inode *, loff_t, loff_t);
 };
 
 struct seq_file;
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/linux/mm.h linux-2.6.14-rc5-madv/include/linux/mm.h
--- linux-2.6.14-rc5/include/linux/mm.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/include/linux/mm.h	2005-10-26 10:15:05.000000000 -0700
@@ -704,6 +704,7 @@ static inline void unmap_shared_mapping_
 }
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
+extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 extern pud_t *FASTCALL(__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
 extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address));
 extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
@@ -865,6 +866,7 @@ extern unsigned long do_brk(unsigned lon
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
+extern void truncate_inode_pages_range(struct address_space *, loff_t, loff_t);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern struct page *filemap_nopage(struct vm_area_struct *, unsigned long, int *);
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/madvise.c linux-2.6.14-rc5-madv/mm/madvise.c
--- linux-2.6.14-rc5/mm/madvise.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/mm/madvise.c	2005-10-26 15:12:24.000000000 -0700
@@ -140,6 +140,33 @@ static long madvise_dontneed(struct vm_a
 	return 0;
 }
 
+static long madvise_truncate(struct vm_area_struct * vma,
+			     unsigned long start, unsigned long end)
+{
+	struct address_space *mapping;
+        loff_t offset, endoff;
+	int error = 0;
+
+	if (!vma->vm_file || !vma->vm_file->f_mapping 
+		|| !vma->vm_file->f_mapping->host) {
+			return -EINVAL;
+	}
+
+	mapping = vma->vm_file->f_mapping;
+	if (mapping == &swapper_space) {
+		return -EINVAL;
+	}
+
+	offset = (loff_t)(start - vma->vm_start);
+	endoff = (loff_t)(end - vma->vm_start);
+	printk("call vmtruncate_range(%p, %x %x)\n", mapping, 
+			(unsigned int)offset, (unsigned int)endoff);
+	down(&mapping->host->i_sem);
+	error = vmtruncate_range(mapping->host, offset, endoff);
+	up(&mapping->host->i_sem);
+	return error;
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -152,6 +179,9 @@ madvise_vma(struct vm_area_struct *vma, 
 	case MADV_RANDOM:
 		error = madvise_behavior(vma, prev, start, end, behavior);
 		break;
+	case MADV_TRUNCATE:
+		error = madvise_truncate(vma, start, end);
+		break;
 
 	case MADV_WILLNEED:
 		error = madvise_willneed(vma, prev, start, end);
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/memory.c linux-2.6.14-rc5-madv/mm/memory.c
--- linux-2.6.14-rc5/mm/memory.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/mm/memory.c	2005-10-26 15:35:15.000000000 -0700
@@ -1597,6 +1597,28 @@ out_busy:
 
 EXPORT_SYMBOL(vmtruncate);
 
+int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	/*
+	 * If the underlying filesystem is not going to provide 
+	 * a way to truncate a range of blocks (punch a hole) - 
+	 * we should return failure right now.
+	 */
+	if (!inode->i_op || !inode->i_op->truncate_range)
+		return -ENOSYS;
+		
+	unmap_mapping_range(mapping, offset, (end - offset), 1);
+	truncate_inode_pages_range(mapping, offset, end);
+	inode->i_op->truncate_range(inode, offset, end);
+
+	return 0;
+}
+
+EXPORT_SYMBOL(vmtruncate_range);
+
+
 /* 
  * Primitive swap readahead code. We simply read an aligned block of
  * (1 << page_cluster) entries in the swap area. This method is chosen
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/shmem.c linux-2.6.14-rc5-madv/mm/shmem.c
--- linux-2.6.14-rc5/mm/shmem.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/mm/shmem.c	2005-10-26 15:37:47.000000000 -0700
@@ -616,6 +616,168 @@ done2:
 	}
 }
 
+/*
+ * WIP ! WIP !! WIP !!!
+ *
+ * The idea is to free up the swap entries for the given range (start, end)
+ * in the file. 
+ *
+ * This is based on shmem_truncate() and I need to merge both of them
+ * into common routine.
+ */
+static void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	unsigned long idx;
+	unsigned long size;
+	unsigned long limit;
+	unsigned long stage;
+	unsigned long diroff;
+	struct page **dir;
+	struct page *topdir;
+	struct page *middir;
+	struct page *subdir;
+	swp_entry_t *ptr;
+	LIST_HEAD(pages_to_free);
+	long nr_pages_to_free = 0;
+	long nr_swaps_freed = 0;
+	int offset;
+	int freed;
+
+	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	idx = (start + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	if (idx >= info->next_index)
+		return;
+
+	limit = (end + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	spin_lock(&info->lock);
+	info->flags |= SHMEM_TRUNCATE;
+	if (limit > info->next_index)
+		limit = info->next_index;
+	topdir = info->i_indirect;
+#if 0
+	if (topdir && idx <= SHMEM_NR_DIRECT) {
+		info->i_indirect = NULL;
+		nr_pages_to_free++;
+		list_add(&topdir->lru, &pages_to_free);
+	}
+#endif
+	spin_unlock(&info->lock);
+
+	if (info->swapped && idx < SHMEM_NR_DIRECT) {
+		ptr = info->i_direct;
+		size = limit;
+		if (size > SHMEM_NR_DIRECT)
+			size = SHMEM_NR_DIRECT;
+		nr_swaps_freed = shmem_free_swp(ptr+idx, ptr+size);
+	}
+	if (!topdir)
+		goto done2;
+
+	BUG_ON(limit <= SHMEM_NR_DIRECT);
+	limit -= SHMEM_NR_DIRECT;
+	idx = (idx > SHMEM_NR_DIRECT)? (idx - SHMEM_NR_DIRECT): 0;
+	offset = idx % ENTRIES_PER_PAGE;
+	idx -= offset;
+
+	dir = shmem_dir_map(topdir);
+	stage = ENTRIES_PER_PAGEPAGE/2;
+	if (idx < ENTRIES_PER_PAGEPAGE/2) {
+		middir = topdir;
+		diroff = idx/ENTRIES_PER_PAGE;
+	} else {
+		dir += ENTRIES_PER_PAGE/2;
+		dir += (idx - ENTRIES_PER_PAGEPAGE/2)/ENTRIES_PER_PAGEPAGE;
+		while (stage <= idx)
+			stage += ENTRIES_PER_PAGEPAGE;
+		middir = *dir;
+		if (*dir) {
+			diroff = ((idx - ENTRIES_PER_PAGEPAGE/2) %
+				ENTRIES_PER_PAGEPAGE) / ENTRIES_PER_PAGE;
+			if (!diroff && !offset) {
+				*dir = NULL;
+				nr_pages_to_free++;
+				list_add(&middir->lru, &pages_to_free);
+			}
+			shmem_dir_unmap(dir);
+			dir = shmem_dir_map(middir);
+		} else {
+			diroff = 0;
+			offset = 0;
+			idx = stage;
+		}
+	}
+
+	for (; idx < limit; idx += ENTRIES_PER_PAGE, diroff++) {
+		if (unlikely(idx == stage)) {
+			shmem_dir_unmap(dir);
+			dir = shmem_dir_map(topdir) +
+			    ENTRIES_PER_PAGE/2 + idx/ENTRIES_PER_PAGEPAGE;
+			while (!*dir) {
+				dir++;
+				idx += ENTRIES_PER_PAGEPAGE;
+				if (idx >= limit)
+					goto done1;
+			}
+			stage = idx + ENTRIES_PER_PAGEPAGE;
+			middir = *dir;
+			*dir = NULL;
+			nr_pages_to_free++;
+			list_add(&middir->lru, &pages_to_free);
+			shmem_dir_unmap(dir);
+			cond_resched();
+			dir = shmem_dir_map(middir);
+			diroff = 0;
+		}
+		subdir = dir[diroff];
+		if (subdir && subdir->nr_swapped) {
+			size = limit - idx;
+			if (size > ENTRIES_PER_PAGE)
+				size = ENTRIES_PER_PAGE;
+			freed = shmem_map_and_free_swp(subdir,
+						offset, size, &dir);
+			if (!dir)
+				dir = shmem_dir_map(middir);
+			nr_swaps_freed += freed;
+			if (offset)
+				spin_lock(&info->lock);
+			subdir->nr_swapped -= freed;
+			if (offset)
+				spin_unlock(&info->lock);
+			BUG_ON(subdir->nr_swapped > offset);
+		}
+		if (offset)
+			offset = 0;
+		else if (subdir) {
+			dir[diroff] = NULL;
+			nr_pages_to_free++;
+			list_add(&subdir->lru, &pages_to_free);
+		}
+	}
+done1:
+	shmem_dir_unmap(dir);
+done2:
+	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
+		truncate_inode_pages_range(inode->i_mapping, start, end);
+	}
+
+	spin_lock(&info->lock);
+	info->flags &= ~SHMEM_TRUNCATE;
+	info->swapped -= nr_swaps_freed;
+	if (nr_pages_to_free)
+		shmem_free_blocks(inode, nr_pages_to_free);
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	/*
+	 * Empty swap vector directory pages to be freed?
+	 */
+	if (!list_empty(&pages_to_free)) {
+		pages_to_free.prev->next = NULL;
+		shmem_free_pages(pages_to_free.next);
+	}
+}
+
 static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
@@ -2083,6 +2245,7 @@ static struct file_operations shmem_file
 static struct inode_operations shmem_inode_operations = {
 	.truncate	= shmem_truncate,
 	.setattr	= shmem_notify_change,
+	.truncate_range	= shmem_truncate_range,
 };
 
 static struct inode_operations shmem_dir_inode_operations = {
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/truncate.c linux-2.6.14-rc5-madv/mm/truncate.c
--- linux-2.6.14-rc5/mm/truncate.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5-madv/mm/truncate.c	2005-10-26 10:14:43.000000000 -0700
@@ -113,7 +113,8 @@ invalidate_complete_page(struct address_
  *
  * Called under (and serialised by) inode->i_sem.
  */
-void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
+void truncate_inode_pages_range(struct address_space *mapping, loff_t lstart,
+		loff_t end)
 {
 	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
 	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
@@ -126,7 +127,8 @@ void truncate_inode_pages(struct address
 
 	pagevec_init(&pvec, 0);
 	next = start;
-	while (pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	while (next <= end &&
+			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
@@ -142,6 +144,8 @@ void truncate_inode_pages(struct address
 			}
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
+			if (next > end)
+				break;
 		}
 		pagevec_release(&pvec);
 		cond_resched();
@@ -176,12 +180,20 @@ void truncate_inode_pages(struct address
 			next++;
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
+			if (next > end)
+				break;
 		}
 		pagevec_release(&pvec);
 	}
 }
 
+void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
+{
+	return truncate_inode_pages_range(mapping, lstart, ~0UL);
+}
+
 EXPORT_SYMBOL(truncate_inode_pages);
+EXPORT_SYMBOL(truncate_inode_pages_range);
 
 /**
  * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode

--=-RhW1rAS2huOQ9M7Uhumy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
