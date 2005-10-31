Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9VJo2wK030102
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 14:50:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9VJo2fJ540656
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 12:50:02 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9VJo2m8009180
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 12:50:02 -0700
Subject: Re: [RFC][PATCH] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051029025119.GA14998@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <20051028034616.GA14511@ccure.user-mode-linux.org>
	 <43624F82.6080003@us.ibm.com>
	 <20051028184235.GC8514@ccure.user-mode-linux.org>
	 <1130544201.23729.167.camel@localhost.localdomain>
	 <20051029025119.GA14998@ccure.user-mode-linux.org>
Content-Type: multipart/mixed; boundary="=-WLg5zrKKGhQwjQFjj/Yz"
Date: Mon, 31 Oct 2005 11:49:36 -0800
Message-Id: <1130788176.24503.19.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

--=-WLg5zrKKGhQwjQFjj/Yz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi All,

Here is the latest patch. Still not cleaned up - but I thought I would
get more feedback & testing while I finish cleanups (since they are all
cosmetic).

TODO:
	- Change the naming to MADV_FREE (as Andrew suggested)
	- Merge shmem_truncate_range() with shmem_truncate()
	- Disallow VMA_NONLINEAR, HUGETLB etc.
	- Take a closer look at i_sem & i_alloc_sem. 
	- comments, white space, tab cleanups.
	- Drop truncate_inode_pages_range() changes - since they
	  are already in -mm tree.

Thanks,
Badari



--=-WLg5zrKKGhQwjQFjj/Yz
Content-Disposition: attachment; filename=madvise-truncate4.patch
Content-Type: text/x-patch; name=madvise-truncate4.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-alpha/mman.h linux-2.6.14-rc5.madv/include/asm-alpha/mman.h
--- linux-2.6.14-rc5/include/asm-alpha/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-alpha/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_TRUNCATE	7		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-arm/mman.h linux-2.6.14-rc5.madv/include/asm-arm/mman.h
--- linux-2.6.14-rc5/include/asm-arm/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-arm/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-arm26/mman.h linux-2.6.14-rc5.madv/include/asm-arm26/mman.h
--- linux-2.6.14-rc5/include/asm-arm26/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-arm26/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-cris/mman.h linux-2.6.14-rc5.madv/include/asm-cris/mman.h
--- linux-2.6.14-rc5/include/asm-cris/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-cris/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-frv/mman.h linux-2.6.14-rc5.madv/include/asm-frv/mman.h
--- linux-2.6.14-rc5/include/asm-frv/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-frv/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-h8300/mman.h linux-2.6.14-rc5.madv/include/asm-h8300/mman.h
--- linux-2.6.14-rc5/include/asm-h8300/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-h8300/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-i386/mman.h linux-2.6.14-rc5.madv/include/asm-i386/mman.h
--- linux-2.6.14-rc5/include/asm-i386/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-i386/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-ia64/mman.h linux-2.6.14-rc5.madv/include/asm-ia64/mman.h
--- linux-2.6.14-rc5/include/asm-ia64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-ia64/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-m32r/mman.h linux-2.6.14-rc5.madv/include/asm-m32r/mman.h
--- linux-2.6.14-rc5/include/asm-m32r/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-m32r/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-m68k/mman.h linux-2.6.14-rc5.madv/include/asm-m68k/mman.h
--- linux-2.6.14-rc5/include/asm-m68k/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-m68k/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-mips/mman.h linux-2.6.14-rc5.madv/include/asm-mips/mman.h
--- linux-2.6.14-rc5/include/asm-mips/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-mips/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-parisc/mman.h linux-2.6.14-rc5.madv/include/asm-parisc/mman.h
--- linux-2.6.14-rc5/include/asm-parisc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-parisc/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_TRUNCATE	8		/* truncate range of pages */
 
 /* The range 12-64 is reserved for page size specification. */
 #define MADV_4K_PAGES   12              /* Use 4K pages  */
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-powerpc/mman.h linux-2.6.14-rc5.madv/include/asm-powerpc/mman.h
--- linux-2.6.14-rc5/include/asm-powerpc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-powerpc/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -44,6 +44,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-s390/mman.h linux-2.6.14-rc5.madv/include/asm-s390/mman.h
--- linux-2.6.14-rc5/include/asm-s390/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-s390/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL        0x2             /* read-ahead aggressively */
 #define MADV_WILLNEED  0x3              /* pre-fault pages */
 #define MADV_DONTNEED  0x4              /* discard these pages */
+#define MADV_TRUNCATE  0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sh/mman.h linux-2.6.14-rc5.madv/include/asm-sh/mman.h
--- linux-2.6.14-rc5/include/asm-sh/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-sh/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sparc/mman.h linux-2.6.14-rc5.madv/include/asm-sparc/mman.h
--- linux-2.6.14-rc5/include/asm-sparc/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-sparc/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_TRUNCATE	0x6		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-sparc64/mman.h linux-2.6.14-rc5.madv/include/asm-sparc64/mman.h
--- linux-2.6.14-rc5/include/asm-sparc64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-sparc64/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_TRUNCATE	0x6		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-v850/mman.h linux-2.6.14-rc5.madv/include/asm-v850/mman.h
--- linux-2.6.14-rc5/include/asm-v850/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-v850/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -32,6 +32,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-x86_64/mman.h linux-2.6.14-rc5.madv/include/asm-x86_64/mman.h
--- linux-2.6.14-rc5/include/asm-x86_64/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-x86_64/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -36,6 +36,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/asm-xtensa/mman.h linux-2.6.14-rc5.madv/include/asm-xtensa/mman.h
--- linux-2.6.14-rc5/include/asm-xtensa/mman.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/asm-xtensa/mman.h	2005-10-27 05:22:59.000000000 -0700
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/linux/fs.h linux-2.6.14-rc5.madv/include/linux/fs.h
--- linux-2.6.14-rc5/include/linux/fs.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/linux/fs.h	2005-10-27 05:22:59.000000000 -0700
@@ -995,6 +995,7 @@ struct inode_operations {
 	ssize_t (*getxattr) (struct dentry *, const char *, void *, size_t);
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
+	void (*truncate_range)(struct inode *, loff_t, loff_t);
 };
 
 struct seq_file;
diff -Naurp -X dontdiff linux-2.6.14-rc5/include/linux/mm.h linux-2.6.14-rc5.madv/include/linux/mm.h
--- linux-2.6.14-rc5/include/linux/mm.h	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/include/linux/mm.h	2005-10-27 05:22:59.000000000 -0700
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
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/madvise.c linux-2.6.14-rc5.madv/mm/madvise.c
--- linux-2.6.14-rc5/mm/madvise.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/mm/madvise.c	2005-10-31 06:10:17.000000000 -0800
@@ -140,6 +140,31 @@ static long madvise_dontneed(struct vm_a
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
+	offset = (loff_t)(start - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	endoff = (loff_t)(end - vma->vm_start - 1) + (vma->vm_pgoff << PAGE_SHIFT);
+	printk("call vmtruncate_range(%p, %x %x) pgoff:%x\n", mapping, 
+			(unsigned int)offset, (unsigned int)endoff, vma->vm_pgoff);
+	error = vmtruncate_range(mapping->host, offset, endoff);
+	return error;
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -152,6 +177,9 @@ madvise_vma(struct vm_area_struct *vma, 
 	case MADV_RANDOM:
 		error = madvise_behavior(vma, prev, start, end, behavior);
 		break;
+	case MADV_TRUNCATE:
+		error = madvise_truncate(vma, start, end);
+		break;
 
 	case MADV_WILLNEED:
 		error = madvise_willneed(vma, prev, start, end);
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/memory.c linux-2.6.14-rc5.madv/mm/memory.c
--- linux-2.6.14-rc5/mm/memory.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/mm/memory.c	2005-10-31 03:19:35.000000000 -0800
@@ -1597,6 +1597,32 @@ out_busy:
 
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
+	down(&inode->i_sem);
+	down_write(&inode->i_alloc_sem);
+	unmap_mapping_range(mapping, offset, (end - offset), 1);
+	truncate_inode_pages_range(mapping, offset, end);
+	inode->i_op->truncate_range(inode, offset, end);
+	up_write(&inode->i_alloc_sem);
+	up(&inode->i_sem);
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
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/shmem.c linux-2.6.14-rc5.madv/mm/shmem.c
--- linux-2.6.14-rc5/mm/shmem.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/mm/shmem.c	2005-10-31 06:46:13.000000000 -0800
@@ -616,6 +616,184 @@ done2:
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
+#if 0
+printk("freeing swap entries <%d  - %d> limit %d\n", idx, size, limit);
+#endif
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
+#if 0
+printk("added middir page to free list\n");
+#endif
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
+#if 0
+printk("freeing swap entries offset: %d  size: %d (%d %d)\n", offset, size, idx, limit);
+#endif
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
+#if 0
+			BUG_ON(subdir->nr_swapped > offset);
+printk("subdir swapped %d\n", subdir->nr_swapped);
+#endif
+		}
+		if (offset)
+			offset = 0;
+		else if (subdir && !subdir->nr_swapped) {
+			dir[diroff] = NULL;
+			nr_pages_to_free++;
+#if 0
+printk("added dir page to free list\n");
+#endif
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
+printk("swap entries free %d pages freed %d\n", nr_swaps_freed, nr_pages_to_free);
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
@@ -2083,6 +2261,7 @@ static struct file_operations shmem_file
 static struct inode_operations shmem_inode_operations = {
 	.truncate	= shmem_truncate,
 	.setattr	= shmem_notify_change,
+	.truncate_range	= shmem_truncate_range,
 };
 
 static struct inode_operations shmem_dir_inode_operations = {
diff -Naurp -X dontdiff linux-2.6.14-rc5/mm/truncate.c linux-2.6.14-rc5.madv/mm/truncate.c
--- linux-2.6.14-rc5/mm/truncate.c	2005-10-19 23:23:05.000000000 -0700
+++ linux-2.6.14-rc5.madv/mm/truncate.c	2005-10-31 06:43:10.000000000 -0800
@@ -91,12 +91,15 @@ invalidate_complete_page(struct address_
 }
 
 /**
- * truncate_inode_pages - truncate *all* the pages from an offset
+ * truncate_inode_pages - truncate range of pages specified by start and
+ * end byte offsets
  * @mapping: mapping to truncate
  * @lstart: offset from which to truncate
+ * @lend: offset to which to truncate
  *
- * Truncate the page cache at a set offset, removing the pages that are beyond
- * that offset (and zeroing out partial pages).
+ * Truncate the page cache, removing the pages that are between
+ * specified offsets (and zeroing out partial page
+ * (if lstart is not page aligned)).
  *
  * Truncate takes two passes - the first pass is nonblocking.  It will not
  * block on page locks and it will not block on writeback.  The second pass
@@ -110,12 +113,12 @@ invalidate_complete_page(struct address_
  * We pass down the cache-hot hint to the page freeing code.  Even if the
  * mapping is large, it is probably the case that the final pages are the most
  * recently touched, and freeing happens in ascending file offset order.
- *
- * Called under (and serialised by) inode->i_sem.
  */
-void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
+void truncate_inode_pages_range(struct address_space *mapping,
+				loff_t lstart, loff_t lend)
 {
 	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
+	pgoff_t end;
 	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
 	struct pagevec pvec;
 	pgoff_t next;
@@ -124,13 +127,22 @@ void truncate_inode_pages(struct address
 	if (mapping->nrpages == 0)
 		return;
 
+	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
+	end = (lend  >> PAGE_CACHE_SHIFT);
+
 	pagevec_init(&pvec, 0);
 	next = start;
-	while (pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	while (next <= end &&
+	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
 
+			if (page_index > end) {
+				next = page_index;
+				break;
+			}
+
 			if (page_index > next)
 				next = page_index;
 			next++;
@@ -166,9 +178,15 @@ void truncate_inode_pages(struct address
 			next = start;
 			continue;
 		}
+		if (pvec.pages[0]->index > end) {
+			pagevec_release(&pvec);
+			break;
+		}
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
+			if (page->index > end)
+				break;
 			lock_page(page);
 			wait_on_page_writeback(page);
 			if (page->index > next)
@@ -180,7 +198,19 @@ void truncate_inode_pages(struct address
 		pagevec_release(&pvec);
 	}
 }
+EXPORT_SYMBOL(truncate_inode_pages_range);
 
+/**
+ * truncate_inode_pages - truncate *all* the pages from an offset
+ * @mapping: mapping to truncate
+ * @lstart: offset from which to truncate
+ *
+ * Called under (and serialised by) inode->i_sem.
+ */
+void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
+{
+	truncate_inode_pages_range(mapping, lstart, (loff_t)-1);
+}
 EXPORT_SYMBOL(truncate_inode_pages);
 
 /**

--=-WLg5zrKKGhQwjQFjj/Yz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
