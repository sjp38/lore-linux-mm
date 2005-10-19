Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9JIpWob005090
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 14:51:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9JIpVLk459080
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 12:51:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9JIpV75028328
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 12:51:31 -0600
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
	 <1129651502.23632.63.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
Content-Type: multipart/mixed; boundary="=-MbaQQw7imlyfPaG8hI3F"
Date: Wed, 19 Oct 2005 11:50:55 -0700
Message-Id: <1129747855.8716.12.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Chris Wright <chrisw@osdl.org>, Jeff Dike <jdike@addtoit.com>, linux-mm <linux-mm@kvack.org>, dvhltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

--=-MbaQQw7imlyfPaG8hI3F
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2005-10-19 at 18:56 +0100, Hugh Dickins wrote:
> On Tue, 18 Oct 2005, Badari Pulavarty wrote:
> > 
> > As you suggested, here is the patch to add SHM_NORESERVE which does 
> > same thing as MAP_NORESERVE. This flag is ignored for OVERCOMMIT_NEVER.
> > I decided to do SHM_NORESERVE instead of IPC_NORESERVE - just to limit
> > its scope.
> 
> Good, yes, SHM_NORESERVE is a better name.

Hugh, Big Thank you for review and help on this.

> 
> > BTW, there is a call to security_shm_alloc() earlier, which could
> > be modified to reject shmget() if it needs to.
> 
> Excellent.  But it can only see shp, and the
> 	shp->shm_flags = (shmflg & S_IRWXUGO);
> will conceal SHM_NORESERVE from it.

I noticed that, but didn't feel like passing it to security_shm_alloc(),
since even SHM_HUGETLB and others are not getting passed today.
That's why I said, "we could, if need to". 

> 
> Since nothing in security/ is worrying about MAP_NORESERVE at present,
> perhaps you need not bother about this for now.  But easily overlooked
> later if MAP_NORESERVE rejection is added.
> 
> > Is this reasonable ? Please review.
> 
> Looks fine as far as it goes, except for the typos in the comment
> +		 * Do not allow no accouting for OVERCOMMIT_NEVER, even
> +	 	 * its asked for.
> should be
> 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
> 		 * if it's asked for.
> (rather a lot of negatives, but okay there I think!)

Initially I wrote it as "For OVERCOMMIT_GUESS and OVERCOMMIT_ALWAYS,
allow no accounting if asked for." - which matches the code. But,
in future, if we decide to add another mode - then we need to
update the comment.

> I say "as far as it goes" because I don't think it's actually going to
> achieve the effect you said you wanted in your original post.
> 
> As you've probably noticed, switching off VM_ACCOUNT here will mean that
> the shm object is accounted page by page as it's instantiated, and I
> expect you're okay with that.  But you want madvise(DONTNEED) to free
> up those reservations: it'll unmap the pages from userspace, but it
> won't free the pages from the shm object, so the reservations will
> still be in force, and accumulate.

Darren Hart is working on patch to add madvise(DISCARD) to extend
the functionality of madvise(DONTNEED) to really drop those pages.
I was going to ask your opinion on that approach :) 

shmget(SHM_NORESERVE) + madvise(DISCARD) should do what I was
hoping for. (BTW, none of this has been tested with database stuff -
I am just concentrating on reasonable extensions.

Here is the version of patch under test. 
(Darren - I am sending this out without your permission, I hope
you are okay with it).
 
Thanks,
Badari



--=-MbaQQw7imlyfPaG8hI3F
Content-Disposition: attachment; filename=madvise_discard.patch
Content-Type: text/x-patch; name=madvise_discard.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-alpha/mman.h 2.6.12-madvise/include/asm-alpha/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-alpha/mman.h	2003-12-17 18:58:04.000000000 -0800
+++ 2.6.12-madvise/include/asm-alpha/mman.h	2005-07-06 09:27:11.000000000 -0700
@@ -42,6 +42,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_DISCARD    7               /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-arm/mman.h 2.6.12-madvise/include/asm-arm/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-arm/mman.h	2003-12-17 18:58:39.000000000 -0800
+++ 2.6.12-madvise/include/asm-arm/mman.h	2005-07-06 09:28:31.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-arm26/mman.h 2.6.12-madvise/include/asm-arm26/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-arm26/mman.h	2003-12-17 18:58:04.000000000 -0800
+++ 2.6.12-madvise/include/asm-arm26/mman.h	2005-07-06 09:28:40.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-cris/mman.h 2.6.12-madvise/include/asm-cris/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-cris/mman.h	2003-12-17 18:59:44.000000000 -0800
+++ 2.6.12-madvise/include/asm-cris/mman.h	2005-07-06 09:28:53.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-frv/mman.h 2.6.12-madvise/include/asm-frv/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-frv/mman.h	2005-03-02 03:00:08.000000000 -0800
+++ 2.6.12-madvise/include/asm-frv/mman.h	2005-07-06 09:29:01.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-h8300/mman.h 2.6.12-madvise/include/asm-h8300/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-h8300/mman.h	2005-06-17 17:21:39.000000000 -0700
+++ 2.6.12-madvise/include/asm-h8300/mman.h	2005-07-06 09:29:05.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-i386/mman.h 2.6.12-madvise/include/asm-i386/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-i386/mman.h	2003-12-17 18:58:15.000000000 -0800
+++ 2.6.12-madvise/include/asm-i386/mman.h	2005-07-06 09:29:10.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-ia64/mman.h 2.6.12-madvise/include/asm-ia64/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-ia64/mman.h	2004-04-05 16:25:06.000000000 -0700
+++ 2.6.12-madvise/include/asm-ia64/mman.h	2005-07-06 09:29:14.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-m32r/mman.h 2.6.12-madvise/include/asm-m32r/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-m32r/mman.h	2004-10-18 15:51:10.000000000 -0700
+++ 2.6.12-madvise/include/asm-m32r/mman.h	2005-07-06 09:29:20.000000000 -0700
@@ -37,6 +37,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-m68k/mman.h 2.6.12-madvise/include/asm-m68k/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-m68k/mman.h	2003-12-17 18:58:16.000000000 -0800
+++ 2.6.12-madvise/include/asm-m68k/mman.h	2005-07-06 09:29:25.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-mips/mman.h 2.6.12-madvise/include/asm-mips/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-mips/mman.h	2003-12-17 18:58:39.000000000 -0800
+++ 2.6.12-madvise/include/asm-mips/mman.h	2005-07-06 09:29:37.000000000 -0700
@@ -65,6 +65,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON       MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-parisc/mman.h 2.6.12-madvise/include/asm-parisc/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-parisc/mman.h	2003-12-17 18:58:58.000000000 -0800
+++ 2.6.12-madvise/include/asm-parisc/mman.h	2005-07-06 09:32:51.000000000 -0700
@@ -38,6 +38,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_DISCARD    8               /* free memory and page cache now */
 
 /* The range 12-64 is reserved for page size specification. */
 #define MADV_4K_PAGES   12              /* Use 4K pages  */
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-ppc/mman.h 2.6.12-madvise/include/asm-ppc/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-ppc/mman.h	2003-12-17 19:00:03.000000000 -0800
+++ 2.6.12-madvise/include/asm-ppc/mman.h	2005-07-06 09:33:13.000000000 -0700
@@ -36,6 +36,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-ppc64/mman.h 2.6.12-madvise/include/asm-ppc64/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-ppc64/mman.h	2003-12-17 18:58:47.000000000 -0800
+++ 2.6.12-madvise/include/asm-ppc64/mman.h	2005-07-06 09:33:25.000000000 -0700
@@ -44,6 +44,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-s390/mman.h 2.6.12-madvise/include/asm-s390/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-s390/mman.h	2003-12-17 18:58:08.000000000 -0800
+++ 2.6.12-madvise/include/asm-s390/mman.h	2005-07-06 09:33:36.000000000 -0700
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL        0x2             /* read-ahead aggressively */
 #define MADV_WILLNEED  0x3              /* pre-fault pages */
 #define MADV_DONTNEED  0x4              /* discard these pages */
+#define MADV_DISCARD   0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-sh/mman.h 2.6.12-madvise/include/asm-sh/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-sh/mman.h	2003-12-17 18:59:27.000000000 -0800
+++ 2.6.12-madvise/include/asm-sh/mman.h	2005-07-06 09:33:57.000000000 -0700
@@ -35,6 +35,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-sparc/mman.h 2.6.12-madvise/include/asm-sparc/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-sparc/mman.h	2003-12-17 18:59:43.000000000 -0800
+++ 2.6.12-madvise/include/asm-sparc/mman.h	2005-07-06 09:35:02.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_DISCARD    0x6             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-sparc64/mman.h 2.6.12-madvise/include/asm-sparc64/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-sparc64/mman.h	2003-12-17 18:58:49.000000000 -0800
+++ 2.6.12-madvise/include/asm-sparc64/mman.h	2005-07-06 09:35:15.000000000 -0700
@@ -54,6 +54,7 @@
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
 #define MADV_FREE	0x5		/* (Solaris) contents can be freed */
+#define MADV_DISCARD    0x6             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-v850/mman.h 2.6.12-madvise/include/asm-v850/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-v850/mman.h	2003-12-17 18:59:26.000000000 -0800
+++ 2.6.12-madvise/include/asm-v850/mman.h	2005-07-06 09:35:35.000000000 -0700
@@ -32,6 +32,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/include/asm-x86_64/mman.h 2.6.12-madvise/include/asm-x86_64/mman.h
--- /home/linux/views/linux-2.6.12/include/asm-x86_64/mman.h	2003-12-17 18:59:05.000000000 -0800
+++ 2.6.12-madvise/include/asm-x86_64/mman.h	2005-07-06 09:35:40.000000000 -0700
@@ -36,6 +36,7 @@
 #define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
 #define MADV_WILLNEED	0x3		/* pre-fault pages */
 #define MADV_DONTNEED	0x4		/* discard these pages */
+#define MADV_DISCARD    0x5             /* free memory and page cache now */
 
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
diff -purN -X /home/dvhart/.diff.exclude /home/linux/views/linux-2.6.12/mm/madvise.c 2.6.12-madvise/mm/madvise.c
--- /home/linux/views/linux-2.6.12/mm/madvise.c	2005-03-02 03:00:18.000000000 -0800
+++ 2.6.12-madvise/mm/madvise.c	2005-07-06 10:15:09.000000000 -0700
@@ -111,6 +111,37 @@ static long madvise_dontneed(struct vm_a
 	return 0;
 }
 
+static long madvise_discard(struct vm_area_struct * vma,
+			     unsigned long start, unsigned long end)
+{
+	struct semaphore *i_sem;
+        loff_t offset;
+
+	if (vma->vm_file && vma->vm_file->f_mapping) {
+		if (vma->vm_file->f_mapping == &swapper_space) {
+			printk("%s: vma (%p)'s mapping is swapper_space\n", __FUNCTION__, vma);
+			return -EINVAL;
+		}
+
+		if (!vma->vm_file->f_mapping->host) {
+			printk("%s: vma (%p)'s mapping->host is null\n", __FUNCTION__, vma);
+			return -EINVAL;
+		}
+
+		/* looks good, try and rip it out of page cache */
+		printk("%s: trying to rip shm vma (%p) inode from page cache\n", __FUNCTION__, vma);
+		i_sem = &vma->vm_file->f_mapping->host->i_sem;
+                offset = (loff_t)(start - vma->vm_start);
+		printk("%s: call truncate_inode_pages(%p, %x\n", __FUNCTION__,
+		       vma->vm_file->f_mapping, (unsigned int)offset);
+		down(i_sem);
+		truncate_inode_pages(vma->vm_file->f_mapping, offset);
+		up(i_sem);
+	}
+
+	return 0;
+}
+
 static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
 			unsigned long end, int behavior)
 {
@@ -130,6 +161,9 @@ static long madvise_vma(struct vm_area_s
 	case MADV_DONTNEED:
 		error = madvise_dontneed(vma, start, end);
 		break;
+	case MADV_DISCARD:
+		error = madvise_discard(vma, start, end);
+		break;
 
 	default:
 		error = -EINVAL;


--=-MbaQQw7imlyfPaG8hI3F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
