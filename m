Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBHIRb8F001882
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 13:27:37 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBHIRbjn250028
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 13:27:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBHIRbXs016268
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 13:27:37 -0500
Subject: Re: [patch] kill off ARCH_HAS_ATOMIC_UNSIGNED (take 2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0412171814050.10470-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0412171814050.10470-100000@localhost.localdomain>
Content-Type: multipart/mixed; boundary="=-HmRXdrkrkiE4Kw99nEld"
Message-Id: <1103308048.4450.123.camel@localhost>
Mime-Version: 1.0
Date: Fri, 17 Dec 2004 10:27:28 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.de
List-ID: <linux-mm.kvack.org>

--=-HmRXdrkrkiE4Kw99nEld
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2004-12-17 at 10:17, Hugh Dickins wrote:
> On Fri, 17 Dec 2004, Dave Hansen wrote:
> > --- apw2/mm/page_alloc.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 09:19:30.000000000 -0800
> > +++ apw2-dave/mm/page_alloc.c	2004-12-17 09:19:48.000000000 -0800
> > @@ -85,7 +85,7 @@ static void bad_page(const char *functio
> >  	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
> >  		function, current->comm, page);
> >  	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
> > -		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
> > +		(int)(2*sizeof(unsigned long)), (unsigned long)page->flags,
>    		                                ^^^^^^^^^^^^^^^
> >  		page->mapping, page_mapcount(page), page_count(page));
> >  	printk(KERN_EMERG "Backtrace:\n");
> >  	dump_stack();
> 
> Teensy nit: better not to cast to unsigned long when it's unsigned long.

My built-in s/// got a little carried away.  How's this?

-- Dave

--=-HmRXdrkrkiE4Kw99nEld
Content-Disposition: attachment; filename=000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED.patch
Content-Type: text/x-patch; name=000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit


Andi says that we don't need this on x86_64 any more.  Since it
is the only user, let's kill it off completely.  BTW, this now
makes 4 free bytes of space in page->flags for all 64-bit
architectures to use.  Also get rid of the typedef.

Still compiles on x86.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 apw2-dave/include/asm-x86_64/bitops.h |    2 --
 apw2-dave/include/linux/mm.h          |   10 ++--------
 apw2-dave/include/linux/mmzone.h      |    2 +-
 apw2-dave/mm/filemap.c                |    2 +-
 apw2-dave/mm/page_alloc.c             |    2 +-
 5 files changed, 5 insertions(+), 13 deletions(-)

diff -puN arch/x86_64/Kconfig~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED arch/x86_64/Kconfig
diff -puN include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mm.h
--- apw2/include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 10:23:10.000000000 -0800
+++ apw2-dave/include/linux/mm.h	2004-12-17 10:23:10.000000000 -0800
@@ -216,12 +216,6 @@ struct vm_operations_struct {
 struct mmu_gather;
 struct inode;
 
-#ifdef ARCH_HAS_ATOMIC_UNSIGNED
-typedef unsigned page_flags_t;
-#else
-typedef unsigned long page_flags_t;
-#endif
-
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -229,7 +223,7 @@ typedef unsigned long page_flags_t;
  * a page.
  */
 struct page {
-	page_flags_t flags;		/* Atomic flags, some possibly
+	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	atomic_t _count;		/* Usage count, see below. */
 	atomic_t _mapcount;		/* Count of ptes mapped in mms,
@@ -409,7 +403,7 @@ static inline void put_page(struct page 
  * We'll have up to (MAX_NUMNODES * MAX_NR_ZONES) zones total,
  * so we use (MAX_NODES_SHIFT + MAX_ZONES_SHIFT) here to get enough bits.
  */
-#define NODEZONE_SHIFT (sizeof(page_flags_t)*8 - MAX_NODES_SHIFT - MAX_ZONES_SHIFT)
+#define NODEZONE_SHIFT (sizeof(unsigned long)*8 - MAX_NODES_SHIFT - MAX_ZONES_SHIFT)
 #define NODEZONE(node, zone)	((node << ZONES_SHIFT) | zone)
 
 static inline unsigned long page_zonenum(struct page *page)
diff -puN include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mmzone.h
--- apw2/include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 10:23:10.000000000 -0800
+++ apw2-dave/include/linux/mmzone.h	2004-12-17 10:23:10.000000000 -0800
@@ -388,7 +388,7 @@ extern struct pglist_data contig_page_da
 
 #include <asm/mmzone.h>
 
-#if BITS_PER_LONG == 32 || defined(ARCH_HAS_ATOMIC_UNSIGNED)
+#if BITS_PER_LONG == 32
 /*
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
  * there are 3 zones (2 bits) and this leaves 8-2=6 bits for nodes.
diff -puN include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/asm-x86_64/bitops.h
--- apw2/include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 10:23:10.000000000 -0800
+++ apw2-dave/include/asm-x86_64/bitops.h	2004-12-17 10:23:10.000000000 -0800
@@ -411,8 +411,6 @@ static __inline__ int ffs(int x)
 /* find last set bit */
 #define fls(x) generic_fls(x)
 
-#define ARCH_HAS_ATOMIC_UNSIGNED 1
-
 #endif /* __KERNEL__ */
 
 #endif /* _X86_64_BITOPS_H */
diff -puN mm/page_alloc.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED mm/page_alloc.c
--- apw2/mm/page_alloc.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 10:23:10.000000000 -0800
+++ apw2-dave/mm/page_alloc.c	2004-12-17 10:24:41.000000000 -0800
@@ -85,7 +85,7 @@ static void bad_page(const char *functio
 	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
 		function, current->comm, page);
 	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
-		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
+		(int)(2*sizeof(unsigned long)), page->flags,
 		page->mapping, page_mapcount(page), page_count(page));
 	printk(KERN_EMERG "Backtrace:\n");
 	dump_stack();
diff -puN mm/filemap.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED mm/filemap.c
--- apw2/mm/filemap.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 10:23:10.000000000 -0800
+++ apw2-dave/mm/filemap.c	2004-12-17 10:23:10.000000000 -0800
@@ -138,7 +138,7 @@ static int sync_page(void *word)
 	struct address_space *mapping;
 	struct page *page;
 
-	page = container_of((page_flags_t *)word, struct page, flags);
+	page = container_of((unsigned long *)word, struct page, flags);
 
 	/*
 	 * FIXME, fercrissake.  What is this barrier here for?
_

--=-HmRXdrkrkiE4Kw99nEld--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
