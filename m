From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911050253.SAA62093@google.engr.sgi.com>
Subject: [RFC] kmap_permanent for 2.3.25
Date: Thu, 4 Nov 1999 18:53:23 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.9911042338540.8880-100000@chiara.csoma.elte.hu> from "Ingo Molnar" at Nov 4, 99 11:43:28 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: ebiederm+eric@ccr.net, hans-christoph.rohland@sap.com, sct@redhat.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 4 Nov 1999, Kanoj Sarcar wrote:
> 
> > Also, I just pulled out an implementation of what you call
> > kmap_permanent that I was working on previously. I am cleaning
> > it up against 2.3.25, and will post it soon. It basically tries
> > to work off the vmalloc space. Since I spent some time on it
> > previously, I think it deserves to at least be reviewed, maybe
> > we can pick some parts of it into yours ...
> 
> yes, definitely post it please.
> 
> Basically i have found two major variants, and i'm not sure which one is
> the more correct. First is to make permanent kmaps global, which either
> means vmalloc, or some dedicated virtual memory area. The problem here are
> SMP flushes and global constraints. Things can be optimized wrt. SMP
> flushes, but not eliminated. I'm more worried about global constraints - i
> dont really know wether we want to restrict the number of currently mapped
> permanent kmaps to 4M, 64M or 256M.
> 
> the other variant - which i implemented - adds per-thread kmaps, which get
> unmapped at schedule time. (but in 99.99% there are no permanent kmaps
> held). The schedule() code is very low, a single offline branch:
> 
> 	if (prev->kmap_count + next->kmap_count)
> 		goto do_kmap_switch;
> 
> anyway, both approaches have pros and cons, we will see. The interface
> should be similar/identical.
> 
> 	Ingo
> 
> 

Okay, here's my version of permanent global kmap implementation. I have
not stress tested it much, other than compiling the kernel after changing
all the kmaps to unconditional kmap_permanent's. 

As soon as you post your version, I will send out a comparative note
on both methods, and we can decide which one we should send to Linus. 
Basically, the kmap_permanent implementation should go in right now,
without having to wait for your PCI64 changes. 

Thanks.

Kanoj


--- /usr/tmp/p_rdiff_a005AH/vmalloc.c	Thu Nov  4 18:28:05 1999
+++ mm/vmalloc.c	Thu Nov  4 17:24:31 1999
@@ -3,15 +3,340 @@
  *
  *  Copyright (C) 1993  Linus Torvalds
  *  Support of BIGMEM added by Gerhard Wichert, Siemens AG, July 1999
+ *  Support for bitmaps and dynamic page mapping added by Kanoj Sarcar
+ *			(kanoj@sgi.com) Nov 1999.
  */
 
 #include <linux/malloc.h>
 #include <linux/vmalloc.h>
+#include <linux/highmem.h>
 
 #include <asm/uaccess.h>
+#include <asm/semaphore.h>
 
 static struct vm_struct * vmlist = NULL;
 
+#define BITSPERBYTE		8
+#define	BITSPERWORD		32
+#define BITSPERLONG		(BITSPERBYTE * sizeof(long))
+#define	WORDMASK		31
+#define BITSTOWORDS(x)		(x >> 5)
+#define rotor(size)		(rotor[0])
+#define updrotor(size, bitnum)	rotor[0] = (bitnum)
+
+static spinlock_t vm_addr_lock = SPIN_LOCK_UNLOCKED;
+static struct semaphore vm_wait_sema;
+static int vm_waiter = 0;
+static unsigned char *freemap, *stalemap;
+static long mapsize;
+static long stalehi, stalelo, freelo;
+static long rotor[1] = { 0 };
+
+/*
+ * Test a bit field of length len in bitmap bp starting at b to be all set.
+ * Return a count of the number of set bits found.
+ */
+static long bftstset(unsigned char *bp, long b, long len)
+{
+	unsigned int mask, w, *wp;
+	unsigned short i, n, flen, sflen;
+	long count;
+
+	wp = (unsigned int *)bp + BITSTOWORDS(b);
+	i = b & WORDMASK;
+
+	for (count = 0, w = *wp >> i, flen = BITSPERWORD - i;
+	     (len > 0) && (w & 1); w = *(++wp), flen = BITSPERWORD) {
+
+		for (mask = -1, i = BITSPERWORD, sflen = flen, n = 0;
+		     (len > 0) && (flen > 0) && (i > 0) && (w & 1);
+		     i >>= 1, mask >>= i) {
+
+			if ((len >= i) && (flen >= i) &&
+			    ((w & mask) == mask)) {
+				n += i;
+				len -= i;
+				flen -= i;
+				w >>= i;
+			}
+		}
+		count += n;
+		if (n < sflen)
+			break;
+	}
+	return (count);
+}
+
+/*
+ * Clear a bit field of length len in bitmap bp starting at b
+ */
+static void bfclr(unsigned char *bp, long b, long len)
+{
+	unsigned int mask, i, j, *wp;
+
+	wp = (unsigned int *)bp + BITSTOWORDS(b);
+	while (len) {
+		i = b & WORDMASK;
+		mask = -1 << i;
+		if (len < (j = BITSPERWORD - i)) {
+			mask &= mask >> (j - len);
+			*wp &= ~mask;
+			return;
+		}
+		else {
+			len -= (BITSPERWORD - i);
+			*wp &= ~mask;
+			wp++;
+			b = 0;
+		}
+	}
+}
+
+/*
+ * Test a bit field of length len in bitmap bp starting at b to be all clear.
+ * Return a count of the number of clear bits found
+ */
+static long bftstclr(unsigned char *bp, long b, long len)
+{
+	unsigned int mask, w, *wp;
+	unsigned short i, n, flen, sflen;
+	long count;
+
+	wp = (unsigned int *)bp + BITSTOWORDS(b);
+	i = b & WORDMASK;
+
+	for (count = 0, w = *wp >> i, flen = BITSPERWORD - i;
+	     (len > 0) && !(w & 1); w = *(++wp), flen = BITSPERWORD) {
+
+		for (mask = -1, i = BITSPERWORD, sflen = flen, n = 0;
+		     (len > 0) && (flen > 0) && (i > 0) && !(w & 1);
+		     i >>= 1, mask >>= i) {
+
+			if ((len >= i) && (flen >= i) &&
+			    ((w | ~mask) == ~mask)) {
+					n += i;
+					len -= i;
+					flen -= i;
+					w >>= i;
+			}
+		}
+		count += n;
+		if (n < sflen)
+			break;
+	}
+	return (count);
+}
+
+/*
+ * Set a bit field of length len in bitmap bp starting at b
+ */
+static void bfset(unsigned char *bp, long b, long len)
+{
+	unsigned int mask, i, j, *wp;
+
+	wp = (unsigned int *)bp + BITSTOWORDS(b);
+	while (len) {
+		i = b & WORDMASK;
+		mask = -1 << i;
+		if (len < (j = BITSPERWORD - i)) {
+			mask &= mask >> (j - len);
+			*wp |= mask;
+			return;
+		}
+		else {
+			len -= (BITSPERWORD - i);
+			*wp |= mask;
+			wp++;
+			b = 0;
+		}
+	}
+}
+
+static void init_kptbl(void)
+{
+	unsigned long addr = VMALLOC_START;
+	unsigned long end = VMALLOC_END;
+	pgd_t * dir = pgd_offset_k(addr);
+
+	do {
+		pmd_t *pmd = pmd_alloc_kernel(dir, addr);
+
+		if (!pmd)
+			panic("init_kptbl out of memory\n");
+		{
+			unsigned long addr2 = addr & ~PGDIR_MASK;
+			unsigned long end2 = addr2 + (end - addr);
+
+			if (end > PGDIR_SIZE)
+				end = PGDIR_SIZE;
+			do {
+				pte_t * pte = pte_alloc_kernel(pmd, addr2);
+
+				if (!pte)
+					panic("init_kptbl out of memory\n");
+				addr2 = (addr2 + PMD_SIZE) & PMD_MASK;
+				pmd++;
+			} while (addr2 < end2);
+		}
+		set_pgdir(addr, *dir);
+		addr = (addr + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (addr && (addr < end));
+	
+}
+
+void vinit(void)
+{
+	long m, size;
+	unsigned char *p;
+
+	if (((VMALLOC_START - VMALLOC_END) % PAGE_SIZE) != 0)
+		panic("VMALLOC_START .. VMALLOC_END not page aligned\n");
+	sema_init(&vm_wait_sema, 0);
+	mapsize = ((VMALLOC_END - VMALLOC_START) / PAGE_SIZE);
+
+	/*
+	 * Lets align the maps to "unsigned long" boundaries so
+	 * that recycle_vm_area goes fast.
+	 */
+	size = (mapsize + BITSPERLONG - 1)/BITSPERLONG;
+	size *= (sizeof (unsigned long));
+	freemap = (unsigned char *)kmalloc(size, GFP_KERNEL);
+	stalemap = (unsigned char *)kmalloc(size, GFP_KERNEL);
+
+	if ((freemap == 0) || (stalemap == 0))
+		panic("can not set up vmalloc maps\n");
+	
+	m = size;
+	p = freemap;
+	while (m--) *p++ = 0xff;
+
+	m = size;
+	p = stalemap;
+	while (m--) *p++ = 0;
+
+	stalehi = -1;
+	freelo = 0;
+	stalelo = mapsize;
+
+	/*
+	 * If there are high memory pages, vmalloc space is small enough
+	 * to be contained in a few page tables. Preallocate the kernel
+	 * page tables for faster/parallel kmap_permanent.
+	 */
+	if (nr_free_highpages)
+		init_kptbl();
+	return;
+} 
+
+static void recycle_vm_area(void)
+{
+	unsigned long *from, *to;
+	long i, tmp, size, first, last;
+
+	first = stalelo / BITSPERLONG;
+	last = (stalehi + BITSPERLONG - 1) / BITSPERLONG;
+	size = last - first;
+	if (size < 0)
+		return;
+	if (stalelo < freelo)
+		freelo = stalelo;
+	from = (unsigned long *)stalemap + first;
+	to = (unsigned long *)freemap + first;
+	for (i = 0; i < size; i++, from++, to++) {
+		if ((tmp = *from))
+			*to |= tmp;
+		*from = 0;
+	}
+	stalehi = -1;
+	stalelo = 0;
+	updrotor(1, freelo);
+	flush_tlb_all();
+	return;
+}
+
+static void * get_vm_addr(unsigned long want)
+{
+	long length, firstbit, bitlen;
+	int reps = 0;
+
+search:
+	firstbit = rotor(want);
+	bitlen = mapsize - firstbit;
+	while (bitlen >= want) {
+		if ((length = bftstset(freemap, firstbit, want)) >= want) {
+			bfclr(freemap, firstbit, want - 1);
+			updrotor(want, firstbit + want);
+			freelo = firstbit + want;
+			return((void *)(VMALLOC_START + 
+						(PAGE_SIZE * firstbit)));
+		}
+		firstbit += length;
+		bitlen -= length;
+		length = bftstclr(freemap, firstbit, bitlen);
+		firstbit += length;
+		bitlen -= length;
+	}
+	if (reps)
+		return(NULL);
+	reps++;
+	recycle_vm_area();
+	goto search;
+}
+
+static void free_vm_addr(void * addr, unsigned long size)
+{
+	long firstbit;
+	unsigned long flags;
+
+	firstbit = ((unsigned long)addr - VMALLOC_START) / PAGE_SIZE;
+	if (firstbit < 0 || firstbit >= mapsize) {
+		printk("Trying to free_vm_addr() bad address (%p)\n", addr);
+		return;
+	}
+	spin_lock_irqsave(&vm_addr_lock, flags);
+	bfset(stalemap, firstbit, size);
+	if (stalehi < firstbit)
+		stalehi = firstbit + size;
+	if (stalelo > firstbit)
+		stalelo = firstbit;
+	if (vm_waiter) {
+		while (vm_waiter--)
+			up(&vm_wait_sema);
+	}
+	spin_unlock_irqrestore(&vm_addr_lock, flags);
+	return;
+}
+
+unsigned long kmap_permanent(struct page * page)
+{
+	unsigned long addr = 0, flags;
+	pgd_t * dir;
+	pmd_t * pmd;
+	pte_t * pte;
+
+	while (addr == 0) {
+		spin_lock_irqsave(&vm_addr_lock, flags);
+		addr = (unsigned long)get_vm_addr(1);
+		if (!addr) {
+			vm_waiter++;
+			spin_unlock_irqrestore(&vm_addr_lock, flags);
+			down(&vm_wait_sema);
+		}
+	}
+	spin_unlock_irqrestore(&vm_addr_lock, flags);
+	dir = pgd_offset_k(addr);
+	pmd = pmd_offset(dir, addr);
+	pte = pte_offset(pmd, addr);
+	set_pte(pte, mk_pte(page, PAGE_KERNEL));
+	return(addr);
+}
+
+void kunmap_permanent(unsigned long addr)
+{
+	free_vm_addr((void *)addr, 1);
+}
+
 static inline void free_area_pte(pmd_t * pmd, unsigned long address, unsigned long size)
 {
 	pte_t * pte;
@@ -82,7 +407,6 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	flush_tlb_all();
 }
 
 static inline int alloc_area_pte(pte_t * pte, unsigned long address, unsigned long size)
@@ -148,27 +472,27 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	flush_tlb_all();
 	return 0;
 }
 
 struct vm_struct * get_vm_area(unsigned long size)
 {
-	unsigned long addr;
+	unsigned long addr, flags;
 	struct vm_struct **p, *tmp, *area;
 
 	area = (struct vm_struct *) kmalloc(sizeof(*area), GFP_KERNEL);
 	if (!area)
 		return NULL;
-	addr = VMALLOC_START;
+	spin_lock_irqsave(&vm_addr_lock, flags);
+	addr = (unsigned long)get_vm_addr(size/PAGE_SIZE + 1);
+	spin_unlock_irqrestore(&vm_addr_lock, flags);
+	if (!addr) {
+		kfree(area);
+		return NULL;
+	}
 	for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
-		if (size + addr < (unsigned long) tmp->addr)
+		if ((unsigned long)tmp->addr > addr)
 			break;
-		addr = tmp->size + (unsigned long) tmp->addr;
-		if (addr > VMALLOC_END-size) {
-			kfree(area);
-			return NULL;
-		}
 	}
 	area->addr = (void *)addr;
 	area->size = size + PAGE_SIZE;
@@ -191,6 +515,7 @@
 		if (tmp->addr == addr) {
 			*p = tmp->next;
 			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
+			free_vm_addr(addr, tmp->size/PAGE_SIZE);
 			kfree(tmp);
 			return;
 		}
--- /usr/tmp/p_rdiff_a005AQ/main.c	Thu Nov  4 18:28:20 1999
+++ init/main.c	Thu Nov  4 12:28:01 1999
@@ -25,6 +25,7 @@
 #include <linux/hdreg.h>
 #include <linux/iobuf.h>
 #include <linux/bootmem.h>
+#include <linux/vmalloc.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -495,6 +496,7 @@
 #endif
 	mem_init();
 	kmem_cache_sizes_init();
+	vinit();
 #ifdef CONFIG_PROC_FS
 	proc_root_init();
 #endif
--- /usr/tmp/p_rdiff_a005AZ/vmalloc.h	Thu Nov  4 18:28:32 1999
+++ include/linux/vmalloc.h	Thu Nov  4 16:28:08 1999
@@ -13,6 +13,7 @@
 	struct vm_struct * next;
 };
 
+void vinit(void);
 struct vm_struct * get_vm_area(unsigned long size);
 void vfree(void * addr);
 void * vmalloc(unsigned long size);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
