Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F12FD6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 19:41:22 -0400 (EDT)
Date: Tue, 28 Sep 2010 16:40:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] arch: remove __GFP_REPEAT for order-0 allocations
Message-Id: <20100928164006.55c442b1.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1009281605180.24817@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com>
	<20100928143655.4282a001.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009281536390.24817@chino.kir.corp.google.com>
	<20100928155326.9ded5a92.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009281605180.24817@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010 16:12:26 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 28 Sep 2010, Andrew Morton wrote:
> 
> > > So we can definitely remove __GFP_REPEAT for any order-0 allocation and 
> > > it's based on its implementation -- poorly defined as it may be -- and the 
> > > inherit design of any sane page allocator that retries such an allocation 
> > > if it's going to use reclaim in the first place.
> > 
> > Why was __GFP_REPEAT used in those callsites?  What were people trying
> > to achieve?
> > 
> 
> I can't predict what they were trying to achieve

Using my super powers it took me all of three minutes.

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git

Do `git log > foo', and search foo for GFP_REPEAT.

A couple of interesting ones are:



commit f3615244f15c8bee5783fcf032717ffdfd56e219
Author:     akpm <akpm>
AuthorDate: Sun Apr 20 21:28:12 2003 +0000
Commit:     akpm <akpm>
CommitDate: Sun Apr 20 21:28:12 2003 +0000

    [PATCH] implement __GFP_REPEAT, __GFP_NOFAIL, __GFP_NORETRY
    
    This is a cleanup patch.
    
    There are quite a lot of places in the kernel which will infinitely retry a
    memory allocation.
    
    Generally, they get it wrong.  Some do yield(), the semantics of which have
    changed over time.  Some do schedule(), which can lock up if the caller is
    SCHED_FIFO/RR.  Some do schedule_timeout(), etc.
    
    And often it is unnecessary, because the page allocator will do the retry
    internally anyway.  But we cannot rely on that - this behaviour may change
    (-aa and -rmap kernels do not do this, for instance).
    
    So it is good to formalise and to centralise this operation.  If an
    allocation specifies __GFP_REPEAT then the page allocator must infinitely
    retry the allocation.
    
    The semantics of __GFP_REPEAT are "try harder".  The allocation _may_ fail
    (the 2.4 -aa and -rmap VM's do not retry infinitely by default).
    
    The semantics of __GFP_NOFAIL are "cannot fail".  It is a no-op in this VM,
    but needs to be honoured (or fix up the callers) if the VM ischanged to not
    retry infinitely by default.
    
    The semantics of __GFP_NOREPEAT are "try once, don't loop".  This isn't used
    at present (although perhaps it should be, in swapoff).  It is mainly for
    completeness.
    
    BKrev: 3ea310ecLgvT41M93_3ecU4Tut6XyQ

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index c475f7b..ade6d9e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -11,13 +11,26 @@
 #define __GFP_DMA	0x01
 #define __GFP_HIGHMEM	0x02
 
-/* Action modifiers - doesn't change the zoning */
+/*
+ * Action modifiers - doesn't change the zoning
+ *
+ * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
+ * _might_ fail.  This depends upon the particular VM implementation.
+ *
+ * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
+ * cannot handle allocation failures.
+ *
+ * __GFP_NORETRY: The VM implementation must not retry indefinitely.
+ */
 #define __GFP_WAIT	0x10	/* Can wait and reschedule? */
 #define __GFP_HIGH	0x20	/* Should access emergency pools? */
 #define __GFP_IO	0x40	/* Can start physical IO? */
 #define __GFP_FS	0x80	/* Can call down to low-level FS? */
 #define __GFP_COLD	0x100	/* Cache-cold page required */
 #define __GFP_NOWARN	0x200	/* Suppress page allocation failure warning */
+#define __GFP_REPEAT	0x400	/* Retry the allocation.  Might fail */
+#define __GFP_NOFAIL	0x800	/* Retry for ever.  Cannot fail */
+#define __GFP_NORETRY	0x1000	/* Do not retry.  Might fail */
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
diff --git a/include/linux/slab.h b/include/linux/slab.h
index bdc5256..603748b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -22,7 +22,7 @@ typedef struct kmem_cache_s kmem_cache_t;
 #define	SLAB_KERNEL		GFP_KERNEL
 #define	SLAB_DMA		GFP_DMA
 
-#define SLAB_LEVEL_MASK		(__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|__GFP_COLD|__GFP_NOWARN)
+#define SLAB_LEVEL_MASK		(__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|__GFP_NORETRY)
 #define	SLAB_NO_GROW		0x00001000UL	/* don't grow a cache */
 
 /* flags to pass to kmem_cache_create().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c9c7acc..bff7db2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -536,6 +536,7 @@ __alloc_pages(unsigned int gfp_mask, unsigned int order,
 	struct page *page;
 	int i;
 	int cold;
+	int do_retry;
 
 	if (wait)
 		might_sleep();
@@ -626,10 +627,21 @@ rebalance:
 	}
 
 	/*
-	 * Don't let big-order allocations loop.  Yield for kswapd, try again.
+	 * Don't let big-order allocations loop unless the caller explicitly
+	 * requests that.  Wait for some write requests to complete then retry.
+	 *
+	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL, but that
+	 * may not be true in other implementations.
 	 */
-	if (order <= 3) {
-		yield();
+	do_retry = 0;
+	if (!(gfp_mask & __GFP_NORETRY)) {
+		if ((order <= 3) || (gfp_mask & __GFP_REPEAT))
+			do_retry = 1;
+		if (gfp_mask & __GFP_NOFAIL)
+			do_retry = 1;
+	}
+	if (do_retry) {
+		blk_congestion_wait(WRITE, HZ/50);
 		goto rebalance;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 291ce11..c1dffbd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -805,8 +805,7 @@ shrink_caches(struct zone *classzone, int priority, int *total_scanned,
  * excessive rotation of the inactive list, which is _supposed_ to be an LRU,
  * yes?
  */
-int
-try_to_free_pages(struct zone *classzone,
+int try_to_free_pages(struct zone *classzone,
 		unsigned int gfp_mask, unsigned int order)
 {
 	int priority;
@@ -838,7 +837,7 @@ try_to_free_pages(struct zone *classzone,
 		blk_congestion_wait(WRITE, HZ/10);
 		shrink_slab(total_scanned, gfp_mask);
 	}
-	if (gfp_mask & __GFP_FS)
+	if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY))
 		out_of_memory();
 	return 0;
 }


and


commit 28e172ed053b0535fb7c45dfd404c795a00c36e1
Author:     akpm <akpm>
AuthorDate: Sun Apr 20 21:28:25 2003 +0000
Commit:     akpm <akpm>
CommitDate: Sun Apr 20 21:28:25 2003 +0000

    [PATCH] use __GFP_REPEAT in pte_alloc_one()
    
    Remove all the open-coded retry loops in various architectures, use
    __GFP_REPEAT.
    
    It could be that at some time in the future we change __GFP_REPEAT to give up
    after ten seconds or so, so all the checks for failed allocations are
    retained.
    
    BKrev: 3ea310f9crWaBJIb9us4X_HVeI_DfA

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index bbf7417..d310bcc 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -66,19 +66,9 @@ pgd_alloc(struct mm_struct *mm)
 pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte;
-	long timeout = 10;
-
- retry:
-	pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
-	else if (--timeout >= 0) {
-		current->state = TASK_UNINTERRUPTIBLE;
-		schedule_timeout(HZ);
-		goto retry;
-	}
-
 	return pte;
 }
 
diff --git a/arch/i386/mm/pgtable.c b/arch/i386/mm/pgtable.c
index 054eec2..9d36261 100644
--- a/arch/i386/mm/pgtable.c
+++ b/arch/i386/mm/pgtable.c
@@ -131,39 +131,23 @@ void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	int count = 0;
-	pte_t *pte;
-   
-   	do {
-		pte = (pte_t *) __get_free_page(GFP_KERNEL);
-		if (pte)
-			clear_page(pte);
-		else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (pte)
+		clear_page(pte);
 	return pte;
 }
 
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	int count = 0;
 	struct page *pte;
-   
-   	do {
+
 #if CONFIG_HIGHPTE
-		pte = alloc_pages(GFP_KERNEL | __GFP_HIGHMEM, 0);
+	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT, 0);
 #else
-		pte = alloc_pages(GFP_KERNEL, 0);
+	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 #endif
-		if (pte)
-			clear_highpage(pte);
-		else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
+	if (pte)
+		clear_highpage(pte);
 	return pte;
 }
 
diff --git a/arch/ppc/mm/pgtable.c b/arch/ppc/mm/pgtable.c
index 9682525..5d4aef7 100644
--- a/arch/ppc/mm/pgtable.c
+++ b/arch/ppc/mm/pgtable.c
@@ -76,15 +76,11 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 	extern void *early_get_page(void);
 	int timeout = 0;
 
-	if (mem_init_done) {
-		while ((pte = (pte_t *) __get_free_page(GFP_KERNEL)) == NULL
-		       && ++timeout < 10) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ);
-		}
-	} else
-		pte = (pte_t *) early_get_page();
-	if (pte != NULL)
+	if (mem_init_done)
+		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	else
+		pte = (pte_t *)early_get_page();
+	if (pte)
 		clear_page(pte);
 	return pte;
 }
@@ -92,20 +88,16 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
-	int timeout = 0;
+
 #ifdef CONFIG_HIGHPTE
-	int flags = GFP_KERNEL | __GFP_HIGHMEM;
+	int flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
 #else
-	int flags = GFP_KERNEL;
+	int flags = GFP_KERNEL | __GFP_REPEAT;
 #endif
 
-	while ((pte = alloc_pages(flags, 0)) == NULL) {
-		if (++timeout >= 10)
-			return NULL;
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ);
-	}
-	clear_highpage(pte);
+	pte = alloc_pages(flags, 0);
+	if (pte)
+		clear_highpage(pte);
 	return pte;
 }
 
diff --git a/arch/sparc/mm/sun4c.c b/arch/sparc/mm/sun4c.c
index 9cda5ee..e4da222 100644
--- a/arch/sparc/mm/sun4c.c
+++ b/arch/sparc/mm/sun4c.c
@@ -1901,7 +1901,7 @@ static pte_t *sun4c_pte_alloc_one_kernel(struct mm_struct *mm, unsigned long add
 	if ((pte = sun4c_pte_alloc_one_fast(mm, address)) != NULL)
 		return pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte)
 		memset(pte, 0, PAGE_SIZE);
 	return pte;
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 2e71992..d0c24d4 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -810,35 +810,21 @@ void pgd_free(pgd_t *pgd)
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	int count = 0;
 	pte_t *pte;
 
-   	do {
-		pte = (pte_t *) __get_free_page(GFP_KERNEL);
-		if (pte)
-			clear_page(pte);
-		else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (pte)
+		clear_page(pte);
 	return pte;
 }
 
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	int count = 0;
 	struct page *pte;
    
-   	do {
-		pte = alloc_pages(GFP_KERNEL, 0);
-		if (pte)
-			clear_highpage(pte);
-		else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
+	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	if (pte)
+		clear_highpage(pte);
 	return pte;
 }
 
diff --git a/include/asm-arm/proc-armv/pgalloc.h b/include/asm-arm/proc-armv/pgalloc.h
index 4440be7..3263c34 100644
--- a/include/asm-arm/proc-armv/pgalloc.h
+++ b/include/asm-arm/proc-armv/pgalloc.h
@@ -27,17 +27,9 @@
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	int count = 0;
 	pte_t *pte;
 
-	do {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL);
-		if (!pte) {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
-
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte) {
 		clear_page(pte);
 		clean_dcache_area(pte, sizeof(pte_t) * PTRS_PER_PTE);
@@ -51,16 +43,8 @@ static inline struct page *
 pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *pte;
-	int count = 0;
-
-	do {
-		pte = alloc_pages(GFP_KERNEL, 0);
-		if (!pte) {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
 
+	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 	if (pte) {
 		void *page = page_address(pte);
 		clear_page(page);
diff --git a/include/asm-cris/pgalloc.h b/include/asm-cris/pgalloc.h
index 80e73be..75dde6f 100644
--- a/include/asm-cris/pgalloc.h
+++ b/include/asm-cris/pgalloc.h
@@ -62,7 +62,7 @@ static inline pte_t *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
         pte_t *pte;
 
-        pte = (pte_t *) __get_free_page(GFP_KERNEL);
+        pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
         if (pte)
                 clear_page(pte);
         return pte;
diff --git a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
index 2e6134a..00847ac 100644
--- a/include/asm-ia64/pgalloc.h
+++ b/include/asm-ia64/pgalloc.h
@@ -125,7 +125,7 @@ pmd_populate_kernel (struct mm_struct *mm, pmd_t *pmd_entry, pte_t *pte)
 static inline struct page *
 pte_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	struct page *pte = alloc_pages(GFP_KERNEL, 0);
+	struct page *pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 
 	if (likely(pte != NULL))
 		clear_page(page_address(pte));
@@ -135,7 +135,7 @@ pte_alloc_one (struct mm_struct *mm, unsigned long addr)
 static inline pte_t *
 pte_alloc_one_kernel (struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 
 	if (likely(pte != NULL))
 		clear_page(pte);
diff --git a/include/asm-m68k/motorola_pgalloc.h b/include/asm-m68k/motorola_pgalloc.h
index 4beb7a8..f315615 100644
--- a/include/asm-m68k/motorola_pgalloc.h
+++ b/include/asm-m68k/motorola_pgalloc.h
@@ -11,7 +11,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long ad
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte) {
 		clear_page(pte);
 		__flush_page_to_ram(pte);
@@ -30,7 +30,7 @@ static inline void pte_free_kernel(pte_t *pte)
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *page = alloc_pages(GFP_KERNEL, 0);
+	struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 	pte_t *pte;
 
 	if(!page)
diff --git a/include/asm-m68k/sun3_pgalloc.h b/include/asm-m68k/sun3_pgalloc.h
index 7740a29..3b7f6cc 100644
--- a/include/asm-m68k/sun3_pgalloc.h
+++ b/include/asm-m68k/sun3_pgalloc.h
@@ -39,7 +39,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *page)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, 
 					  unsigned long address)
 {
-	unsigned long page = __get_free_page(GFP_KERNEL);
+	unsigned long page = __get_free_page(GFP_KERNEL|__GFP_REPEAT);
 
 	if (!page)
 		return NULL;
@@ -51,7 +51,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 static inline struct page *pte_alloc_one(struct mm_struct *mm, 
 					 unsigned long address)
 {
-        struct page *page = alloc_pages(GFP_KERNEL, 0);
+        struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 
 	if (page == NULL)
 		return NULL;
diff --git a/include/asm-mips/pgalloc.h b/include/asm-mips/pgalloc.h
index 9492a50..f71b90b 100644
--- a/include/asm-mips/pgalloc.h
+++ b/include/asm-mips/pgalloc.h
@@ -132,7 +132,7 @@ static inline pte_t *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte = (pte_t *) __get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
diff --git a/include/asm-mips64/pgalloc.h b/include/asm-mips64/pgalloc.h
index 79b5840..a311307 100644
--- a/include/asm-mips64/pgalloc.h
+++ b/include/asm-mips64/pgalloc.h
@@ -93,7 +93,7 @@ static inline pte_t *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
diff --git a/include/asm-parisc/pgalloc.h b/include/asm-parisc/pgalloc.h
index 32dcf11..14c8605 100644
--- a/include/asm-parisc/pgalloc.h
+++ b/include/asm-parisc/pgalloc.h
@@ -73,7 +73,7 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 static inline struct page *
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *page = alloc_page(GFP_KERNEL);
+	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
 	if (likely(page != NULL))
 		clear_page(page_address(page));
 	return page;
@@ -82,7 +82,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (likely(pte != NULL))
 		clear_page(pte);
 	return pte;
diff --git a/include/asm-ppc64/pgalloc.h b/include/asm-ppc64/pgalloc.h
index 0c46141..40361c2 100644
--- a/include/asm-ppc64/pgalloc.h
+++ b/include/asm-ppc64/pgalloc.h
@@ -62,19 +62,11 @@ pmd_free(pmd_t *pmd)
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	int count = 0;
 	pte_t *pte;
 
-	do {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL);
-		if (pte)
-			clear_page(pte);
-		else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
-
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (pte)
+		clear_page(pte);
 	return pte;
 }
 
diff --git a/include/asm-s390/pgalloc.h b/include/asm-s390/pgalloc.h
index 67230ef..e4729fb 100644
--- a/include/asm-s390/pgalloc.h
+++ b/include/asm-s390/pgalloc.h
@@ -120,20 +120,13 @@ static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long vmaddr)
 {
 	pte_t *pte;
-	int count;
         int i;
 
-	count = 0;
-	do {
-		pte = (pte_t *) __get_free_page(GFP_KERNEL);
-		if (pte != NULL) {
-			for (i=0; i < PTRS_PER_PTE; i++)
-				pte_clear(pte+i);
-		} else {
-			current->state = TASK_UNINTERRUPTIBLE;
-			schedule_timeout(HZ);
-		}
-	} while (!pte && (count++ < 10));
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (pte != NULL) {
+		for (i=0; i < PTRS_PER_PTE; i++)
+			pte_clear(pte+i);
+	}
 	return pte;
 }
 
diff --git a/include/asm-sh/pgalloc.h b/include/asm-sh/pgalloc.h
index 9cc5a7d..a60b4c9 100644
--- a/include/asm-sh/pgalloc.h
+++ b/include/asm-sh/pgalloc.h
@@ -35,7 +35,7 @@ static inline void pgd_free(pgd_t *pgd)
 
 static inline pte_t *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = (pte_t *) __get_free_page(GFP_KERNEL);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
diff --git a/include/asm-x86_64/pgalloc.h b/include/asm-x86_64/pgalloc.h
index 4cae8e6..65b8177 100644
--- a/include/asm-x86_64/pgalloc.h
+++ b/include/asm-x86_64/pgalloc.h
@@ -48,12 +48,12 @@ static inline void pgd_free (pgd_t *pgd)
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *) get_zeroed_page(GFP_KERNEL);
+	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)get_zeroed_page(GFP_KERNEL); 
+	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 	if (!p)
 		return NULL;
 	return virt_to_page(p);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
