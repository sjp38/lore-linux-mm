Date: Sun, 8 Jul 2001 23:04:22 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107051148430.22414-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0107082224020.30164-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Linus Torvalds wrote:

> So in general, the block layer should not care AT ALL, and just use the
> physical addresses passed in to it. For things like bounce buffers, YES,
> we should make sure that the bounce buffers are at least the size of
> PAGE_CACHE_SIZE.

Hmmm, interesting.  At present page cache sizes from PAGE_SIZE to
8*PAGE_SIZE are working here.  Setting the shift to 4 or a 64KB page size
results in the SCSI driver blowing up on io completion.  See the patch
below.  This version works and seems to be stable in normal usage
providing you run without swap.  Properly fixing swapping probably means
using O_DIRECT... ;-)

> > It may come down to Ben having 2**N more struct pages than I do:
> > greater flexibility, but significant waste of kernel virtual.
>
> The waste of kernel virtual memory space is actually a good point. Already
> on big x86 machines the "struct page[]" array is a big memory-user. That
> may indeed be the biggest argument for increasing PAGE_SIZE.

Well, here are a few lmbench runs with larger PAGE_CACHE_SIZES.  Except
for 2.4.2-2, the kernels are all based on 2.4.6-pre8, with -b and -c being
the 2 and 3 shift page cache kernels.  As expected, exec and sh latencies
are reduced.  Mmap latency appears to be adversely affected in the 16KB
page cache case while other latencies are reduced.  My best guess here is
that either a change in layout is causing cache collisions, or the changes
in do_no_page are having an adverse impact on page fault timing.  Ideally
the loop would be unrolled, however...

The way I changed do_no_page to speculatively pre-fill ptes is suboptimal:
it still has to obtain a ref count for each pte that touches the page
cache page.  One idea here is to treat ptes within a given page cache page
as sharing a single reference count, but this may have no impact on
performance and simply add to code complexity and as such probably isn't
worth the added hassle.

There is a noteworthy increase in file re-read bandwidth from 212MB/s in
the base kernel to 230 and 237 MB/s for kernels with 16 and 32KB pages.
I also tried a few kernel compiles against all three, and the larger page
cache sizes resulted in a 2m20s cache warm compile compared to 2m21s; a
change well below the margin of error, but at least not negative.  I
didn't try the cold cache senario, which on reflection is probably more
interesting.

The next step is to try out Hugh's approach and see what differences there
are and how the patches work together.  I also suspect that these changes
will have a larger impact on performance with ia64 where we can use a
single tlb entry to map all the page cache pages at the same time.  Hmmm,
perhaps I should try making anonymous pages use the larger allocations
where possible...

		-ben


cd results && make summary percent 2>/dev/null | more
make[1]: Entering directory `/tmp/LMbench/results'

                 L M B E N C H  2 . 0   S U M M A R Y
                 ------------------------------------
		 (Alpha software, do not distribute)

Basic system parameters
----------------------------------------------------
Host                 OS Description              Mhz

--------- ------------- ----------------------- ----
toolbox.t Linux 2.4.2-2       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-p       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-p       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-p       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-b       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-b       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-b       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-c       i686-pc-linux-gnu  550
toolbox.t Linux 2.4.6-c       i686-pc-linux-gnu  550

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec sh
                             call  I/O stat clos TCP   inst hndl proc proc proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ---- ---- ----
toolbox.t Linux 2.4.2-2  550 0.60 0.97 3.60 5.63    44 1.46 4.79  547 1948 7115
toolbox.t Linux 2.4.6-p  550 0.63 1.02 3.61 5.47    46 1.47 4.91  553 1932 6923
toolbox.t Linux 2.4.6-p  550 0.63 1.01 3.61 5.50    44 1.50 4.92  563 1927 7072
toolbox.t Linux 2.4.6-p  550 0.63 1.00 3.64 5.50    43 1.50 4.91  563 1917 6961
toolbox.t Linux 2.4.6-b  550 0.63 1.02 3.54 5.35    43 1.50 4.84  547 1878 6933
toolbox.t Linux 2.4.6-b  550 0.63 1.02 3.55 5.38    49 1.50 4.90  551 1889 6951
toolbox.t Linux 2.4.6-b  550 0.63 1.02 3.54 5.37    47 1.50 4.84  550 1887 6927
toolbox.t Linux 2.4.6-c  550 0.63 1.00 3.60 5.40    44 1.51 4.90  543 1882 6854
toolbox.t Linux 2.4.6-c  550 0.63 1.02 3.54 5.46    47 1.47 4.90  545 1875 6872

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------
Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                        ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ----- ------ ------ ------ ------ ------- -------
toolbox.t Linux 2.4.2-2 4.280     12     40     19     43      19      52
toolbox.t Linux 2.4.6-p 4.360     11     39     19     43      18      43
toolbox.t Linux 2.4.6-p 4.530     11     39     18     42      18      43
toolbox.t Linux 2.4.6-p 4.600     12     39     19     43      19      43
toolbox.t Linux 2.4.6-b 4.470     11     39     18     43      19      43
toolbox.t Linux 2.4.6-b 4.560     11     39     18     42      18      44
toolbox.t Linux 2.4.6-b 4.700     11     39     18     43      18      44
toolbox.t Linux 2.4.6-c 4.430     11     39     18     43      19      60
toolbox.t Linux 2.4.6-c 4.630     11     39     19     42      18      48

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
toolbox.t Linux 2.4.2-2 4.280    15   35    44    82    58   109  110
toolbox.t Linux 2.4.6-p 4.360    15   32    46    82    57   104  111
toolbox.t Linux 2.4.6-p 4.530    15   31    46    82    56   103  110
toolbox.t Linux 2.4.6-p 4.600    15   32    45    82    58   104  111
toolbox.t Linux 2.4.6-b 4.470    15   33    45    81    56   103  109
toolbox.t Linux 2.4.6-b 4.560    15   35    45    81    56   104  109
toolbox.t Linux 2.4.6-b 4.700    15   35    45    82    56   104  110
toolbox.t Linux 2.4.6-c 4.430    15   34    45    82    56   104  110
toolbox.t Linux 2.4.6-c 4.630    15   35    45    82    56   103  110

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot    Page
                        Create Delete Create Delete  Latency Fault   Fault
--------- ------------- ------ ------ ------ ------  ------- -----   -----
toolbox.t Linux 2.4.2-2    113     15    214     36      424 1.204 5.00000
toolbox.t Linux 2.4.6-p     59     11    157     31      496 1.199 4.00000
toolbox.t Linux 2.4.6-p     60     12    158     31      506 1.270 4.00000
toolbox.t Linux 2.4.6-p     60     12    157     31      508 1.221 4.00000
toolbox.t Linux 2.4.6-b     59     11    152     28      737 1.169 5.00000
toolbox.t Linux 2.4.6-b     59     11    152     27      736 1.225 5.00000
toolbox.t Linux 2.4.6-b     59     11    152     28      746 1.152 5.00000
toolbox.t Linux 2.4.6-c     60     11    157     32      516 1.223 4.00000
toolbox.t Linux 2.4.6-c     60     11    157     32      541 1.270 4.00000

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
toolbox.t Linux 2.4.2-2  219  160  114    211    274    197    160  274   210
toolbox.t Linux 2.4.6-p  221  160  117    212    274    197    160  274   210
toolbox.t Linux 2.4.6-p  220  160  115    212    273    197    160  274   210
toolbox.t Linux 2.4.6-p  221  159  117    212    273    197    160  274   210
toolbox.t Linux 2.4.6-b  220  160  114    231    274    197    160  274   210
toolbox.t Linux 2.4.6-b  221  159  116    230    274    197    160  274   210
toolbox.t Linux 2.4.6-b  222  158  116    230    274    197    160  274   210
toolbox.t Linux 2.4.6-c  218  159  122    237    274    192    159  274   210
toolbox.t Linux 2.4.6-c  220  159  116    238    274    193    160  274   210

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------  ---- ----- ------    --------    -------
toolbox.t Linux 2.4.2-2   550 5.457     32    222
toolbox.t Linux 2.4.6-p   550 5.455     32    222
toolbox.t Linux 2.4.6-p   550 5.455     32    222
toolbox.t Linux 2.4.6-p   550 5.455     32    222
toolbox.t Linux 2.4.6-b   550 5.454     32    222
toolbox.t Linux 2.4.6-b   550 5.455     32    222
toolbox.t Linux 2.4.6-b   550 5.455     32    222
toolbox.t Linux 2.4.6-c   550 5.455     32    222
toolbox.t Linux 2.4.6-c   550 5.455     32    222
make[1]: Leaving directory `/tmp/LMbench/results'



.... ~/patches/v2.4.6-pre8-pgc-B0.diff ....
diff -ur /md0/kernels/2.4/v2.4.6-pre8/Makefile pgc-2.4.6-pre8/Makefile
--- /md0/kernels/2.4/v2.4.6-pre8/Makefile	Sat Jun 30 14:04:26 2001
+++ pgc-2.4.6-pre8/Makefile	Sun Jul  8 02:32:00 2001
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 4
 SUBLEVEL = 6
-EXTRAVERSION =-pre8
+EXTRAVERSION =-pre8-pgc-B0

 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

diff -ur /md0/kernels/2.4/v2.4.6-pre8/arch/i386/boot/install.sh pgc-2.4.6-pre8/arch/i386/boot/install.sh
--- /md0/kernels/2.4/v2.4.6-pre8/arch/i386/boot/install.sh	Tue Jan  3 06:57:26 1995
+++ pgc-2.4.6-pre8/arch/i386/boot/install.sh	Wed Jul  4 16:42:32 2001
@@ -21,6 +21,7 @@

 # User may have a custom install script

+if [ -x ~/bin/installkernel ]; then exec ~/bin/installkernel "$@"; fi
 if [ -x /sbin/installkernel ]; then exec /sbin/installkernel "$@"; fi

 # Default install - same as make zlilo
diff -ur /md0/kernels/2.4/v2.4.6-pre8/arch/i386/config.in pgc-2.4.6-pre8/arch/i386/config.in
--- /md0/kernels/2.4/v2.4.6-pre8/arch/i386/config.in	Sun Jul  1 21:45:04 2001
+++ pgc-2.4.6-pre8/arch/i386/config.in	Sun Jul  1 21:49:20 2001
@@ -180,6 +180,8 @@
 if [ "$CONFIG_SMP" = "y" -a "$CONFIG_X86_CMPXCHG" = "y" ]; then
    define_bool CONFIG_HAVE_DEC_LOCK y
 fi
+
+int 'Page cache shift' CONFIG_PAGE_CACHE_SHIFT 0
 endmenu

 mainmenu_option next_comment
diff -ur /md0/kernels/2.4/v2.4.6-pre8/arch/i386/mm/init.c pgc-2.4.6-pre8/arch/i386/mm/init.c
--- /md0/kernels/2.4/v2.4.6-pre8/arch/i386/mm/init.c	Thu May  3 11:22:07 2001
+++ pgc-2.4.6-pre8/arch/i386/mm/init.c	Fri Jul  6 01:11:23 2001
@@ -156,6 +156,7 @@
 void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
 {
 	unsigned long address = __fix_to_virt(idx);
+	unsigned i;

 	if (idx >= __end_of_fixed_addresses) {
 		printk("Invalid __set_fixmap\n");
@@ -282,7 +283,7 @@
 	 * Permanent kmaps:
 	 */
 	vaddr = PKMAP_BASE;
-	fixrange_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
+	fixrange_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP*PKMAP_PAGES, pgd_base);

 	pgd = swapper_pg_dir + __pgd_offset(vaddr);
 	pmd = pmd_offset(pgd, vaddr);
diff -ur /md0/kernels/2.4/v2.4.6-pre8/fs/buffer.c pgc-2.4.6-pre8/fs/buffer.c
--- /md0/kernels/2.4/v2.4.6-pre8/fs/buffer.c	Sat Jun 30 14:04:27 2001
+++ pgc-2.4.6-pre8/fs/buffer.c	Thu Jul  5 04:41:19 2001
@@ -774,6 +774,7 @@

 	/* This is a temporary buffer used for page I/O. */
 	page = bh->b_page;
+	page = page_cache_page(page);

 	if (!uptodate)
 		SetPageError(page);
@@ -1252,8 +1253,10 @@

 void set_bh_page (struct buffer_head *bh, struct page *page, unsigned long offset)
 {
+	page += offset >> PAGE_SHIFT;
+	offset &= PAGE_SIZE - 1;
 	bh->b_page = page;
-	if (offset >= PAGE_SIZE)
+	if (offset >= PAGE_CACHE_SIZE)
 		BUG();
 	if (PageHighMem(page))
 		/*
@@ -1280,7 +1283,9 @@

 try_again:
 	head = NULL;
-	offset = PAGE_SIZE;
+	if (!PageCachePage(page))
+		BUG();
+	offset = PAGE_CACHE_SIZE;
 	while ((offset -= size) >= 0) {
 		bh = get_unused_buffer_head(async);
 		if (!bh)
@@ -1664,6 +1669,8 @@
 	unsigned int blocksize, blocks;
 	int nr, i;

+	if (!PageCachePage(page))
+		BUG();
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 	blocksize = inode->i_sb->s_blocksize;
@@ -2228,7 +2235,7 @@
 		return 0;
 	}

-	page = alloc_page(GFP_NOFS);
+	page = __page_cache_alloc(GFP_NOFS);
 	if (!page)
 		goto out;
 	LockPage(page);
diff -ur /md0/kernels/2.4/v2.4.6-pre8/fs/ext2/dir.c pgc-2.4.6-pre8/fs/ext2/dir.c
--- /md0/kernels/2.4/v2.4.6-pre8/fs/ext2/dir.c	Sat Jun 30 14:04:27 2001
+++ pgc-2.4.6-pre8/fs/ext2/dir.c	Thu Jul  5 21:38:16 2001
@@ -321,15 +321,13 @@
 		de = (ext2_dirent *) kaddr;
 		kaddr += PAGE_CACHE_SIZE - reclen;
 		for ( ; (char *) de <= kaddr ; de = ext2_next_entry(de))
-			if (ext2_match (namelen, name, de))
-				goto found;
+			if (ext2_match (namelen, name, de)) {
+				*res_page = page;
+				return de;
+			}
 		ext2_put_page(page);
 	}
 	return NULL;
-
-found:
-	*res_page = page;
-	return de;
 }

 struct ext2_dir_entry_2 * ext2_dotdot (struct inode *dir, struct page **p)
@@ -353,8 +351,7 @@
 	de = ext2_find_entry (dir, dentry, &page);
 	if (de) {
 		res = le32_to_cpu(de->inode);
-		kunmap(page);
-		page_cache_release(page);
+		ext2_put_page(page);
 	}
 	return res;
 }
diff -ur /md0/kernels/2.4/v2.4.6-pre8/include/asm-i386/fixmap.h pgc-2.4.6-pre8/include/asm-i386/fixmap.h
--- /md0/kernels/2.4/v2.4.6-pre8/include/asm-i386/fixmap.h	Sun Jul  8 02:18:42 2001
+++ pgc-2.4.6-pre8/include/asm-i386/fixmap.h	Sun Jul  8 02:36:31 2001
@@ -40,6 +40,8 @@
  * TLB entries of such buffers will not be flushed across
  * task switches.
  */
+#define KM_ORDER	(CONFIG_PAGE_CACHE_SHIFT)
+#define KM_PAGES	(1UL << KM_ORDER)

 /*
  * on UP currently we will have no trace of the fixmap mechanizm,
@@ -63,7 +65,7 @@
 #endif
 #ifdef CONFIG_HIGHMEM
 	FIX_KMAP_BEGIN,	/* reserved pte's for temporary kernel mappings */
-	FIX_KMAP_END = FIX_KMAP_BEGIN+(KM_TYPE_NR*NR_CPUS)-1,
+	FIX_KMAP_END = FIX_KMAP_BEGIN+(KM_PAGES*KM_TYPE_NR*NR_CPUS)-1,
 #endif
 	__end_of_fixed_addresses
 };
@@ -86,7 +88,7 @@
  * at the top of mem..
  */
 #define FIXADDR_TOP	(0xffffe000UL)
-#define FIXADDR_SIZE	(__end_of_fixed_addresses << PAGE_SHIFT)
+#define FIXADDR_SIZE	(__end_of_fixed_addresses << (PAGE_SHIFT + KM_ORDER))
 #define FIXADDR_START	(FIXADDR_TOP - FIXADDR_SIZE)

 #define __fix_to_virt(x)	(FIXADDR_TOP - ((x) << PAGE_SHIFT))
diff -ur /md0/kernels/2.4/v2.4.6-pre8/include/asm-i386/highmem.h pgc-2.4.6-pre8/include/asm-i386/highmem.h
--- /md0/kernels/2.4/v2.4.6-pre8/include/asm-i386/highmem.h	Sun Jul  8 04:50:02 2001
+++ pgc-2.4.6-pre8/include/asm-i386/highmem.h	Sun Jul  8 02:36:31 2001
@@ -43,15 +43,19 @@
  * easily, subsequent pte tables have to be allocated in one physical
  * chunk of RAM.
  */
-#define PKMAP_BASE (0xfe000000UL)
+#define PKMAP_ORDER (CONFIG_PAGE_CACHE_SHIFT)	/* Fix mm dependancies if changed*/
+#define PKMAP_PAGES (1UL << PKMAP_ORDER)
+#define PKMAP_SIZE	4096
 #ifdef CONFIG_X86_PAE
-#define LAST_PKMAP 512
+#define LAST_PKMAP ((PKMAP_SIZE / 8) >> PKMAP_ORDER)
 #else
-#define LAST_PKMAP 1024
+#define LAST_PKMAP ((PKMAP_SIZE / 4) >> PKMAP_ORDER)
 #endif
 #define LAST_PKMAP_MASK (LAST_PKMAP-1)
-#define PKMAP_NR(virt)  ((virt-PKMAP_BASE) >> PAGE_SHIFT)
-#define PKMAP_ADDR(nr)  (PKMAP_BASE + ((nr) << PAGE_SHIFT))
+#define PKMAP_BASE	(0xfe000000UL)
+#define PKMAP_SHIFT	(PAGE_SHIFT + PKMAP_ORDER)
+#define PKMAP_NR(virt)  ((virt-PKMAP_BASE) >> PKMAP_SHIFT)
+#define PKMAP_ADDR(nr)  (PKMAP_BASE + ((nr) << PKMAP_SHIFT))

 extern void * FASTCALL(kmap_high(struct page *page));
 extern void FASTCALL(kunmap_high(struct page *page));
@@ -84,18 +88,22 @@
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	unsigned i;

 	if (page < highmem_start_page)
 		return page_address(page);

 	idx = type + KM_TYPE_NR*smp_processor_id();
+	idx <<= PKMAP_ORDER;
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #if HIGHMEM_DEBUG
 	if (!pte_none(*(kmap_pte-idx)))
 		BUG();
 #endif
-	set_pte(kmap_pte-idx, mk_pte(page, kmap_prot));
-	__flush_tlb_one(vaddr);
+	for (i=0; i<PKMAP_PAGES; i++)
+		set_pte(kmap_pte-idx+i, mk_pte(page+i, kmap_prot));
+	for (i=0; i<PKMAP_PAGES; i++)
+		__flush_tlb_one(vaddr + (i << PAGE_SHIFT));

 	return (void*) vaddr;
 }
@@ -105,10 +113,12 @@
 #if HIGHMEM_DEBUG
 	unsigned long vaddr = (unsigned long) kvaddr;
 	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
+	unsigned i;

 	if (vaddr < FIXADDR_START) // FIXME
 		return;

+	idx <<= PKMAP_ORDER;
 	if (vaddr != __fix_to_virt(FIX_KMAP_BEGIN+idx))
 		BUG();

@@ -116,8 +126,10 @@
 	 * force other mappings to Oops if they'll try to access
 	 * this pte without first remap it
 	 */
-	pte_clear(kmap_pte-idx);
-	__flush_tlb_one(vaddr);
+	for (i=0; i<PKMAP_PAGES; i++)
+		pte_clear(kmap_pte-idx+i);
+	for (i=0; i<PKMAP_PAGES; i++, vaddr += PAGE_SIZE)
+		__flush_tlb_one(vaddr);
 #endif
 }

diff -ur /md0/kernels/2.4/v2.4.6-pre8/include/linux/highmem.h pgc-2.4.6-pre8/include/linux/highmem.h
--- /md0/kernels/2.4/v2.4.6-pre8/include/linux/highmem.h	Sun Jul  8 04:50:02 2001
+++ pgc-2.4.6-pre8/include/linux/highmem.h	Sun Jul  8 02:36:31 2001
@@ -59,7 +59,7 @@
 {
 	char *kaddr;

-	if (offset + size > PAGE_SIZE)
+	if (offset + size > (PAGE_SIZE * PKMAP_PAGES))
 		BUG();
 	kaddr = kmap(page);
 	memset(kaddr + offset, 0, size);
@@ -73,7 +73,7 @@
 {
 	char *kaddr;

-	if (offset + size > PAGE_SIZE)
+	if (offset + size > (PAGE_SIZE * PKMAP_PAGES))
 		BUG();
 	kaddr = kmap(page);
 	memset(kaddr + offset, 0, size);
diff -ur /md0/kernels/2.4/v2.4.6-pre8/include/linux/mm.h pgc-2.4.6-pre8/include/linux/mm.h
--- /md0/kernels/2.4/v2.4.6-pre8/include/linux/mm.h	Sun Jul  8 04:50:02 2001
+++ pgc-2.4.6-pre8/include/linux/mm.h	Sun Jul  8 02:36:32 2001
@@ -282,6 +282,7 @@
 #define PG_inactive_clean	11
 #define PG_highmem		12
 #define PG_checked		13	/* kill me in 2.5.<early>. */
+#define PG_pagecache		14
 				/* bits 21-29 unused */
 #define PG_arch_1		30
 #define PG_reserved		31
@@ -298,6 +299,9 @@
 #define TryLockPage(page)	test_and_set_bit(PG_locked, &(page)->flags)
 #define PageChecked(page)	test_bit(PG_checked, &(page)->flags)
 #define SetPageChecked(page)	set_bit(PG_checked, &(page)->flags)
+#define PageCachePage(page)	test_bit(PG_pagecache, &(page)->flags)
+#define SetPageCache(page)	set_bit(PG_pagecache, &(page)->flags)
+#define ClearPageCache(page)	clear_bit(PG_pagecache, &(page)->flags)

 extern void __set_page_dirty(struct page *);

diff -ur /md0/kernels/2.4/v2.4.6-pre8/include/linux/pagemap.h pgc-2.4.6-pre8/include/linux/pagemap.h
--- /md0/kernels/2.4/v2.4.6-pre8/include/linux/pagemap.h	Sun Jul  8 04:50:02 2001
+++ pgc-2.4.6-pre8/include/linux/pagemap.h	Sun Jul  8 20:25:14 2001
@@ -22,19 +22,53 @@
  * space in smaller chunks for same flexibility).
  *
  * Or rather, it _will_ be done in larger chunks.
+ *
+ * It's now configurable.  -ben 20010702
  */
-#define PAGE_CACHE_SHIFT	PAGE_SHIFT
-#define PAGE_CACHE_SIZE		PAGE_SIZE
-#define PAGE_CACHE_MASK		PAGE_MASK
+#define PAGE_CACHE_ORDER	(CONFIG_PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_PAGES	(1UL << CONFIG_PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_PMASK	(PAGE_CACHE_PAGES - 1)
+#define PAGE_CACHE_SHIFT	(PAGE_SHIFT + CONFIG_PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE - 1))
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)

+#define __page_cache_page(page)	(page - ((page - mem_map) & PAGE_CACHE_PMASK))
+
+static inline struct page *page_cache_page(struct page *page)
+{
+	if (PageCachePage(page))
+		page = __page_cache_page(page);
+	return page;
+}
+
 #define page_cache_get(x)	get_page(x)
-#define page_cache_free(x)	__free_page(x)
-#define page_cache_release(x)	__free_page(x)
+#define __page_cache_free(x)	__free_pages(x, PAGE_CACHE_ORDER)
+#define page_cache_free(x)	page_cache_release(x)
+
+static inline void page_cache_release(struct page *page)
+{
+	if (PageCachePage(page))
+		__page_cache_free(__page_cache_page(page));
+	else
+		__free_page(page);
+}
+
+static inline struct page *__page_cache_alloc(int gfp)
+{
+	struct page *page;
+	page = alloc_pages(gfp, PAGE_CACHE_ORDER);
+	if (page) {
+		unsigned i;
+		for (i=0; i<PAGE_CACHE_PAGES; i++)
+			SetPageCache(page+i);
+	}
+	return page;
+}

 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return alloc_pages(x->gfp_mask, 0);
+	return __page_cache_alloc(x->gfp_mask);
 }

 /*
diff -ur /md0/kernels/2.4/v2.4.6-pre8/mm/filemap.c pgc-2.4.6-pre8/mm/filemap.c
--- /md0/kernels/2.4/v2.4.6-pre8/mm/filemap.c	Sat Jun 30 14:04:28 2001
+++ pgc-2.4.6-pre8/mm/filemap.c	Thu Jul  5 19:54:16 2001
@@ -236,13 +236,12 @@
 		if ((offset >= start) || (*partial && (offset + 1) == start)) {
 			list_del(head);
 			list_add(head, curr);
+			page_cache_get(page);
 			if (TryLockPage(page)) {
-				page_cache_get(page);
 				spin_unlock(&pagecache_lock);
 				wait_on_page(page);
 				goto out_restart;
 			}
-			page_cache_get(page);
 			spin_unlock(&pagecache_lock);

 			if (*partial && (offset + 1) == start) {
@@ -1499,8 +1498,11 @@
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page, **hash, *old_page;
 	unsigned long size, pgoff;
+	unsigned long offset;

-	pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
+	pgoff = ((address - area->vm_start) >> PAGE_SHIFT) + area->vm_pgoff;
+	offset = pgoff & PAGE_CACHE_PMASK;
+	pgoff >>= PAGE_CACHE_ORDER;

 retry_all:
 	/*
@@ -1538,7 +1540,7 @@
 	 * Found the page and have a reference on it, need to check sharing
 	 * and possibly copy it over to another page..
 	 */
-	old_page = page;
+	old_page = page + offset;
 	if (no_share) {
 		struct page *new_page = alloc_page(GFP_HIGHUSER);

@@ -1652,6 +1654,7 @@
 	if (pte_present(pte) && ptep_test_and_clear_dirty(ptep)) {
 		struct page *page = pte_page(pte);
 		flush_tlb_page(vma, address);
+		page = page_cache_page(page);
 		set_page_dirty(page);
 	}
 	return 0;
diff -ur /md0/kernels/2.4/v2.4.6-pre8/mm/highmem.c pgc-2.4.6-pre8/mm/highmem.c
--- /md0/kernels/2.4/v2.4.6-pre8/mm/highmem.c	Sat Jun 30 14:04:28 2001
+++ pgc-2.4.6-pre8/mm/highmem.c	Sun Jul  8 00:30:12 2001
@@ -46,6 +46,7 @@

 	for (i = 0; i < LAST_PKMAP; i++) {
 		struct page *page;
+		unsigned j;
 		pte_t pte;
 		/*
 		 * zero means we don't have anything to do,
@@ -56,9 +57,11 @@
 		if (pkmap_count[i] != 1)
 			continue;
 		pkmap_count[i] = 0;
-		pte = ptep_get_and_clear(pkmap_page_table+i);
-		if (pte_none(pte))
-			BUG();
+		for (j=PKMAP_PAGES; j>0; ) {
+			pte = ptep_get_and_clear(pkmap_page_table+(i*PKMAP_PAGES)+ --j);
+			if (pte_none(pte))
+				BUG();
+		}
 		page = pte_page(pte);
 		page->virtual = NULL;
 	}
@@ -68,6 +71,7 @@
 static inline unsigned long map_new_virtual(struct page *page)
 {
 	unsigned long vaddr;
+	unsigned i;
 	int count;

 start:
@@ -105,10 +109,12 @@
 			goto start;
 		}
 	}
+	pkmap_count[last_pkmap_nr] = 1;
 	vaddr = PKMAP_ADDR(last_pkmap_nr);
-	set_pte(&(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
+	last_pkmap_nr <<= PKMAP_ORDER;
+	for (i=0; i<PKMAP_PAGES; i++)
+		set_pte(&(pkmap_page_table[last_pkmap_nr+i]), mk_pte(page+i, kmap_prot));

-	pkmap_count[last_pkmap_nr] = 1;
 	page->virtual = (void *) vaddr;

 	return vaddr;
diff -ur /md0/kernels/2.4/v2.4.6-pre8/mm/memory.c pgc-2.4.6-pre8/mm/memory.c
--- /md0/kernels/2.4/v2.4.6-pre8/mm/memory.c	Sat Jun 30 14:04:28 2001
+++ pgc-2.4.6-pre8/mm/memory.c	Sun Jul  8 02:36:20 2001
@@ -233,6 +233,7 @@
 				if (vma->vm_flags & VM_SHARED)
 					pte = pte_mkclean(pte);
 				pte = pte_mkold(pte);
+				ptepage = page_cache_page(ptepage);
 				get_page(ptepage);

 cont_copy_pte_range:		set_pte(dst_pte, pte);
@@ -268,6 +269,7 @@
 		struct page *page = pte_page(pte);
 		if ((!VALID_PAGE(page)) || PageReserved(page))
 			return 0;
+		page = page_cache_page(page);
 		/*
 		 * free_page() used to be able to clear swap cache
 		 * entries.  We may now have to do it manually.
@@ -508,7 +510,7 @@
 		map = get_page_map(map);
 		if (map) {
 			flush_dcache_page(map);
-			atomic_inc(&map->count);
+			get_page(page_cache_page(map));
 		} else
 			printk (KERN_INFO "Mapped page missing [%d]\n", i);
 		spin_unlock(&mm->page_table_lock);
@@ -551,7 +553,7 @@

 	while (remaining > 0 && index < iobuf->nr_pages) {
 		page = iobuf->maplist[index];
-
+		page = page_cache_page(page);
 		if (!PageReserved(page))
 			SetPageDirty(page);

@@ -574,6 +576,7 @@
 	for (i = 0; i < iobuf->nr_pages; i++) {
 		map = iobuf->maplist[i];
 		if (map) {
+			map = page_cache_page(map);
 			if (iobuf->locked)
 				UnlockPage(map);
 			__free_page(map);
@@ -616,7 +619,7 @@
 			page = *ppage;
 			if (!page)
 				continue;
-
+			page = page_cache_page(page);
 			if (TryLockPage(page)) {
 				while (j--) {
 					page = *(--ppage);
@@ -687,6 +690,7 @@
 			page = *ppage;
 			if (!page)
 				continue;
+			page = page_cache_page(page);
 			UnlockPage(page);
 		}
 	}
@@ -894,12 +898,14 @@
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct * vma,
 	unsigned long address, pte_t *page_table, pte_t pte)
 {
-	struct page *old_page, *new_page;
+	struct page *old_page, *__old_page, *new_page;
+
+	__old_page = pte_page(pte);
+	old_page = page_cache_page(__old_page);

-	old_page = pte_page(pte);
 	if (!VALID_PAGE(old_page))
 		goto bad_wp_page;
-
+
 	/*
 	 * We can avoid the copy if:
 	 * - we're the only user (count == 1)
@@ -949,7 +955,7 @@
 	if (pte_same(*page_table, pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
-		break_cow(vma, old_page, new_page, address, page_table);
+		break_cow(vma, __old_page, new_page, address, page_table);

 		/* Free the old page.. */
 		new_page = old_page;
@@ -1016,7 +1022,7 @@
 	if (!mapping->i_mmap && !mapping->i_mmap_shared)
 		goto out_unlock;

-	pgoff = (offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	pgoff = (offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (mapping->i_mmap != NULL)
 		vmtruncate_list(mapping->i_mmap, pgoff);
 	if (mapping->i_mmap_shared != NULL)
@@ -1201,8 +1207,11 @@
 static int do_no_page(struct mm_struct * mm, struct vm_area_struct * vma,
 	unsigned long address, int write_access, pte_t *page_table)
 {
-	struct page * new_page;
+	struct page *new_page, *ppage;
 	pte_t entry;
+	int no_share, offset, i;
+	unsigned long addr_min, addr_max;
+	int put;

 	if (!vma->vm_ops || !vma->vm_ops->nopage)
 		return do_anonymous_page(mm, vma, page_table, write_access, address);
@@ -1213,13 +1222,15 @@
 	 * to copy, not share the page even if sharing is possible.  It's
 	 * essentially an early COW detection.
 	 */
-	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, (vma->vm_flags & VM_SHARED)?0:write_access);
+	no_share = (vma->vm_flags & VM_SHARED) ? 0 : write_access;
+	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, no_share);

 	spin_lock(&mm->page_table_lock);
 	if (new_page == NULL)	/* no page was available -- SIGBUS */
 		return 0;
 	if (new_page == NOPAGE_OOM)
 		return -1;
+	ppage = page_cache_page(new_page);
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
 	 * due to the bad i386 page protection. But it's valid
@@ -1231,25 +1242,73 @@
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
-		++mm->rss;
+	if (!pte_none(*page_table)) {
+		/* One of our sibling threads was faster, back out. */
+		page_cache_release(ppage);
+		return 1;
+	}
+
+	addr_min = address & PMD_MASK;
+	addr_max = address | (PMD_SIZE - 1);
+
+	addr_min = vma->vm_start;
+	addr_max = vma->vm_end;
+
+	/* The following implements PAGE_CACHE_SIZE prefilling of
+	 * page tables.  The technique is essentially the same as
+	 * a cache burst using
+	 */
+	offset = address >> PAGE_SHIFT;
+	offset &= PAGE_CACHE_PMASK;
+	i = 0;
+	put = 1;
+	do {
+		if (!pte_none(*page_table))
+			goto next_page;
+
+		if ((address < addr_min) || (address >= addr_max))
+			goto next_page;
+
+		if (put)
+			put = 0;
+		else
+			page_cache_get(ppage);
+
+		mm->rss++;
 		flush_page_to_ram(new_page);
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		if (write_access) {
+		if (write_access && !i)
 			entry = pte_mkwrite(pte_mkdirty(entry));
-		} else if (page_count(new_page) > 1 &&
+		else if (page_count(ppage) > 1 &&
 			   !(vma->vm_flags & VM_SHARED))
 			entry = pte_wrprotect(entry);
+		if (i)
+			entry = pte_mkold(entry);
 		set_pte(page_table, entry);
-	} else {
-		/* One of our sibling threads was faster, back out. */
-		page_cache_release(new_page);
-		return 1;
-	}

-	/* no need to invalidate: a not-present page shouldn't be cached */
-	update_mmu_cache(vma, address, entry);
+		/* no need to invalidate: a not-present page shouldn't be cached */
+		update_mmu_cache(vma, address, entry);
+
+next_page:
+		if (!PageCachePage(ppage))
+			break;
+		if ((ppage + offset) != new_page)
+			break;
+
+		/* Implement wrap around for the address, page and ptep. */
+		address -= offset << PAGE_SHIFT;
+		page_table -= offset;
+		new_page -= offset;
+
+		offset = (offset + 1) & PAGE_CACHE_PMASK;
+
+		address += offset << PAGE_SHIFT;
+		page_table += offset;
+		new_page += offset;
+	} while (++i < PAGE_CACHE_PAGES) ;
+	if (put)
+		page_cache_release(ppage);
 	return 2;	/* Major fault */
 }

diff -ur /md0/kernels/2.4/v2.4.6-pre8/mm/page_alloc.c pgc-2.4.6-pre8/mm/page_alloc.c
--- /md0/kernels/2.4/v2.4.6-pre8/mm/page_alloc.c	Sat Jun 30 14:04:28 2001
+++ pgc-2.4.6-pre8/mm/page_alloc.c	Wed Jul  4 02:46:12 2001
@@ -87,6 +87,13 @@
 		BUG();
 	if (PageInactiveClean(page))
 		BUG();
+	if (PageCachePage(page) && (order != PAGE_CACHE_ORDER)) {
+		printk("PageCachePage and order == %lu\n", order);
+		BUG();
+	}
+
+	for (index=0; index < (1<<order); index++)
+		ClearPageCache(page+index);

 	page->flags &= ~((1<<PG_referenced) | (1<<PG_dirty));
 	page->age = PAGE_AGE_START;
diff -ur /md0/kernels/2.4/v2.4.6-pre8/mm/vmscan.c pgc-2.4.6-pre8/mm/vmscan.c
--- /md0/kernels/2.4/v2.4.6-pre8/mm/vmscan.c	Sat Jun 30 14:04:28 2001
+++ pgc-2.4.6-pre8/mm/vmscan.c	Mon Jul  2 17:08:34 2001
@@ -38,8 +38,11 @@
 /* mm->page_table_lock is held. mmap_sem is not held */
 static void try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
 {
-	pte_t pte;
 	swp_entry_t entry;
+	pte_t pte;
+
+	if (PageCachePage(page))
+		page = page_cache_page(page);

 	/* Don't look at this pte if it's been accessed recently. */
 	if (ptep_test_and_clear_young(page_table)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
