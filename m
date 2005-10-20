Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9KMc4JR020853
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 18:38:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9KMcttE544718
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 16:38:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9KMc0s2002494
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 16:38:00 -0600
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051020172757.GB6590@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
	 <1129651502.23632.63.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
	 <1129747855.8716.12.camel@localhost.localdomain>
	 <20051019204732.GA9922@localhost.localdomain>
	 <1129821065.16301.5.camel@localhost.localdomain>
	 <20051020172757.GB6590@localhost.localdomain>
Content-Type: multipart/mixed; boundary="=-i8zX5acH7HOEbQGV9pUM"
Date: Thu, 20 Oct 2005 15:37:24 -0700
Message-Id: <1129847844.16301.37.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, dvhltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

--=-i8zX5acH7HOEbQGV9pUM
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-10-20 at 13:27 -0400, Jeff Dike wrote:
> On Thu, Oct 20, 2005 at 08:11:05AM -0700, Badari Pulavarty wrote:
> > Initial plan was to use invalidate_inode_pages2_range(). But it didn't
> > really do what we wanted. So we ended up using truncate_inode_pages().
> > If it really works, then I plan to add truncate_inode_pages2_range()
> > to which works on a range of pages, instead of the whole file.
> > madvise(DONTNEED) followed by madvise(DISCARD) should be able to drop
> > all the pages in the given range.
> > 
> > Does this make sense ? Does this seem like right approach ?
> 
> Works for me.  I obviously have no idea about the wider vm implications of 
> this - that would be Hugh's territory :-)

Here is the latest version of madvise(DISCARD) I cooked up after 
talking to Darren.

Changes from previous:

1) madvise(DISCARD) - zaps the range and discards the pages. So, no
need to call madvise(DONTNEED) before.

2) I added truncate_inode_pages2_range() to just discard only the
range of pages - not the whole file.

Hugh, when you get a chance could you review this instead ?

Thanks,
Badari



--=-i8zX5acH7HOEbQGV9pUM
Content-Disposition: attachment; filename=madvise-discard2.patch
Content-Type: text/x-patch; name=madvise-discard2.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-alpha/mman.h linux-2.6.14-rc3.db2/include/asm-alpha/mman.h
--- linux-2.6.14-rc3/include/asm-alpha/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-alpha/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_DISCARD    7               /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-arm/mman.h linux-2.6.14-rc3.db2/include/asm-arm/mman.h
--- linux-2.6.14-rc3/include/asm-arm/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-arm/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-arm26/mman.h linux-2.6.14-rc3.db2/include/asm-arm26/mman.h
--- linux-2.6.14-rc3/include/asm-arm26/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-arm26/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-cris/mman.h linux-2.6.14-rc3.db2/include/asm-cris/mman.h
--- linux-2.6.14-rc3/include/asm-cris/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-cris/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-frv/mman.h linux-2.6.14-rc3.db2/include/asm-frv/mman.h
--- linux-2.6.14-rc3/include/asm-frv/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-frv/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-h8300/mman.h linux-2.6.14-rc3.db2/include/asm-h8300/mman.h
--- linux-2.6.14-rc3/include/asm-h8300/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-h8300/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-i386/mman.h linux-2.6.14-rc3.db2/include/asm-i386/mman.h
--- linux-2.6.14-rc3/include/asm-i386/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-i386/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-ia64/mman.h linux-2.6.14-rc3.db2/include/asm-ia64/mman.h
--- linux-2.6.14-rc3/include/asm-ia64/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-ia64/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-m32r/mman.h linux-2.6.14-rc3.db2/include/asm-m32r/mman.h
--- linux-2.6.14-rc3/include/asm-m32r/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-m32r/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-m68k/mman.h linux-2.6.14-rc3.db2/include/asm-m68k/mman.h
--- linux-2.6.14-rc3/include/asm-m68k/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-m68k/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-mips/mman.h linux-2.6.14-rc3.db2/include/asm-mips/mman.h
--- linux-2.6.14-rc3/include/asm-mips/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-mips/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-parisc/mman.h linux-2.6.14-rc3.db2/include/asm-parisc/mman.h
--- linux-2.6.14-rc3/include/asm-parisc/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-parisc/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_DISCARD    8               /* discard pages right now */
 
 /* The range 12-64 is reserved for page size specification. */
 #define MADV_4K_PAGES   12              /* Use 4K pages  */
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-powerpc/mman.h linux-2.6.14-rc3.db2/include/asm-powerpc/mman.h
--- linux-2.6.14-rc3/include/asm-powerpc/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-powerpc/mman.h	2005-10-20 13:55:18.000000000 -0700
@@ -44,6 +44,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD	0x5		/* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-s390/mman.h linux-2.6.14-rc3.db2/include/asm-s390/mman.h
--- linux-2.6.14-rc3/include/asm-s390/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-s390/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL        0x2             /* read-ahead aggressively */
 #define MADV_WILLNEED  0x3              /* pre-fault pages */
 #define MADV_DONTNEED  0x4              /* discard these pages */
+#define MADV_DISCARD   0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-sh/mman.h linux-2.6.14-rc3.db2/include/asm-sh/mman.h
--- linux-2.6.14-rc3/include/asm-sh/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-sh/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-sparc/mman.h linux-2.6.14-rc3.db2/include/asm-sparc/mman.h
--- linux-2.6.14-rc3/include/asm-sparc/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-sparc/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_DISCARD    0x6             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-sparc64/mman.h linux-2.6.14-rc3.db2/include/asm-sparc64/mman.h
--- linux-2.6.14-rc3/include/asm-sparc64/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-sparc64/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_DISCARD    0x6             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-v850/mman.h linux-2.6.14-rc3.db2/include/asm-v850/mman.h
--- linux-2.6.14-rc3/include/asm-v850/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-v850/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -32,6 +32,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-x86_64/mman.h linux-2.6.14-rc3.db2/include/asm-x86_64/mman.h
--- linux-2.6.14-rc3/include/asm-x86_64/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-x86_64/mman.h	2005-10-20 10:52:37.000000000 -0700
@@ -36,6 +36,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/asm-xtensa/mman.h linux-2.6.14-rc3.db2/include/asm-xtensa/mman.h
--- linux-2.6.14-rc3/include/asm-xtensa/mman.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/asm-xtensa/mman.h	2005-10-20 13:56:45.000000000 -0700
@@ -72,6 +72,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD	0x5		/* discard pages right now */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -Naurp -X dontdiff linux-2.6.14-rc3/include/linux/mm.h linux-2.6.14-rc3.db2/include/linux/mm.h
--- linux-2.6.14-rc3/include/linux/mm.h	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/include/linux/mm.h	2005-10-20 13:41:57.000000000 -0700
@@ -865,6 +865,7 @@ extern unsigned long do_brk(unsigned lon
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
+extern void truncate_inode_pages2_range(struct address_space *, loff_t, loff_t);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern struct page *filemap_nopage(struct vm_area_struct *, unsigned long, int *);
diff -Naurp -X dontdiff linux-2.6.14-rc3/mm/madvise.c linux-2.6.14-rc3.db2/mm/madvise.c
--- linux-2.6.14-rc3/mm/madvise.c	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/mm/madvise.c	2005-10-20 13:37:41.000000000 -0700
@@ -137,6 +137,40 @@ static long madvise_dontneed(struct vm_a
 	return 0;
 }
 
+static long madvise_discard(struct vm_area_struct * vma,
+			     struct vm_area_struct ** prev,
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
+	error = madvise_dontneed(vma, prev, start, end);
+	if (error)
+		return error;
+
+	/* looks good, try and rip it out of page cache */
+	printk("%s: trying to rip shm vma (%p) inode from page cache\n", __FUNCTION__, vma);
+	offset = (loff_t)(start - vma->vm_start);
+	endoff = (loff_t)(end - vma->vm_start);
+	printk("call truncate_inode_pages(%p, %x %x)\n", mapping, 
+			(unsigned int)offset, (unsigned int)endoff);
+	down(&mapping->host->i_sem);
+	truncate_inode_pages2_range(mapping, offset, endoff);
+	up(&mapping->host->i_sem);
+	return 0;
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -153,6 +187,9 @@ madvise_vma(struct vm_area_struct *vma, 
 	case MADV_RANDOM:
 		error = madvise_behavior(vma, prev, start, end, behavior);
 		break;
+	case MADV_DISCARD:
+		error = madvise_discard(vma, prev, start, end);
+		break;
 
 	case MADV_WILLNEED:
 		error = madvise_willneed(vma, prev, start, end);
diff -Naurp -X dontdiff linux-2.6.14-rc3/mm/truncate.c linux-2.6.14-rc3.db2/mm/truncate.c
--- linux-2.6.14-rc3/mm/truncate.c	2005-09-30 14:17:35.000000000 -0700
+++ linux-2.6.14-rc3.db2/mm/truncate.c	2005-10-20 13:59:20.000000000 -0700
@@ -113,7 +113,8 @@ invalidate_complete_page(struct address_
  *
  * Called under (and serialised by) inode->i_sem.
  */
-void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
+void truncate_inode_pages2_range(struct address_space *mapping, loff_t lstart,
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
+	return truncate_inode_pages2_range(mapping, lstart, ~0UL);
+}
+
 EXPORT_SYMBOL(truncate_inode_pages);
+EXPORT_SYMBOL(truncate_inode_pages2_range);
 
 /**
  * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode

--=-i8zX5acH7HOEbQGV9pUM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
