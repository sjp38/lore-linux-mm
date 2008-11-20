Date: Thu, 20 Nov 2008 17:50:17 +0000
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: [PATCH] [ARM] clearpage: provide our own clear_user_highpage()
Message-ID: <20081120175017.GA2545@dyn-67.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is part of a larger ARM specific patch set cleaning up
aliasing VIPT cache support.

With aliasing VIPT cache support, our implementation of clear_user_page()
and copy_user_page() sets up a temporary kernel space mapping such that
we have the same cache colour as the userspace page.  This avoids having
to consider any userspace aliases from this operation.

However, when highmem is enabled, kmap_atomic() have to setup mappings.
The copy_user_highpage() and clear_user_highpage() call these functions
before delegating the copies to copy_user_page() and clear_user_page().

The effect of this is that each of the *_user_highpage() functions setup
their own kmap mapping, followed by the *_user_page() functions setting
up another mapping.  This is rather wasteful.

Thankfully, copy_user_highpage() can be overriden by architectures by
defining __HAVE_ARCH_COPY_USER_HIGHPAGE.  However, replacement of 
clear_user_highpage() is more difficult because its inline definition
is not conditional.  It seems that you're expected to define
__HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE and provide a replacement
__alloc_zeroed_user_highpage() implementation instead.

The allocation itself is fine, so we don't want to override that.  What
we really want to do is to override clear_user_highpage() with our own
version which doesn't kmap_atomic() unnecessarily.

However, there are two drivers (drivers/media/video/videobuf-dma-sg.c
and drivers/staging/go7007/go7007-v4l2.c) which want to provide non-
highmem clear_user_page()'d pages to userspace.

Requiring an architecture to provide __alloc_zeroed_user_highpage(),
a sub-optimal clear_user_page(), and keep the sub-optimal
clear_user_highpage() around seems rather silly and potentially
error prone.

So, what this patch below does is allow clear_user_highpage() itself
to be overriden by architectures, so that they can provide just one
implementation.

What needs to follow on from this is converting those two drivers to
use clear_user_highpage() instead of clear_user_page() - that should
be a trivial patch.

Are there any objections to this approach?  Can I get any acked-by's
from any MM folk for the include/linux/highmem.h change?


From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Mon, 17 Nov 2008 14:08:49 +0000
Subject: Re: [PATCH] [ARM] clearpage: provide our own clear_user_highpage()

From: Russell King <rmk@dyn-67.arm.linux.org.uk>

For similar reasons as copy_user_page(), we want to avoid the
additional kmap_atomic if it's unnecessary.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/include/asm/page.h     |   11 ++++++-----
 arch/arm/mm/copypage-feroceon.c |   20 ++++++++++----------
 arch/arm/mm/copypage-v3.c       |   13 +++++++------
 arch/arm/mm/copypage-v4mc.c     |   28 ++++++++++++++--------------
 arch/arm/mm/copypage-v4wb.c     |   28 ++++++++++++++--------------
 arch/arm/mm/copypage-v4wt.c     |   24 ++++++++++++------------
 arch/arm/mm/copypage-v6.c       |   23 +++++++++--------------
 arch/arm/mm/copypage-xsc3.c     |   25 +++++++++++++------------
 arch/arm/mm/copypage-xscale.c   |   26 ++++++++++++++------------
 arch/arm/mm/proc-syms.c         |    2 +-
 include/linux/highmem.h         |    2 ++
 11 files changed, 102 insertions(+), 100 deletions(-)

diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index f6e090f..f341c9d 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -111,7 +111,7 @@
 struct page;
 
 struct cpu_user_fns {
-	void (*cpu_clear_user_page)(void *p, unsigned long user);
+	void (*cpu_clear_user_highpage)(struct page *page, unsigned long vaddr);
 	void (*cpu_copy_user_highpage)(struct page *to, struct page *from,
 			unsigned long vaddr);
 };
@@ -119,20 +119,21 @@ struct cpu_user_fns {
 #ifdef MULTI_USER
 extern struct cpu_user_fns cpu_user;
 
-#define __cpu_clear_user_page		cpu_user.cpu_clear_user_page
+#define __cpu_clear_user_highpage	cpu_user.cpu_clear_user_highpage
 #define __cpu_copy_user_highpage	cpu_user.cpu_copy_user_highpage
 
 #else
 
-#define __cpu_clear_user_page		__glue(_USER,_clear_user_page)
+#define __cpu_clear_user_highpage	__glue(_USER,_clear_user_highpage)
 #define __cpu_copy_user_highpage	__glue(_USER,_copy_user_highpage)
 
-extern void __cpu_clear_user_page(void *p, unsigned long user);
+extern void __cpu_clear_user_highpage(struct page *page, unsigned long vaddr);
 extern void __cpu_copy_user_highpage(struct page *to, struct page *from,
 			unsigned long vaddr);
 #endif
 
-#define clear_user_page(addr,vaddr,pg)	 __cpu_clear_user_page(addr, vaddr)
+#define clear_user_highpage(page,vaddr)		\
+	 __cpu_clear_user_highpage(page, vaddr)
 
 #define __HAVE_ARCH_COPY_USER_HIGHPAGE
 #define copy_user_highpage(to,from,vaddr,vma)	\
diff --git a/arch/arm/mm/copypage-feroceon.c b/arch/arm/mm/copypage-feroceon.c
index edd7168..c3651b2 100644
--- a/arch/arm/mm/copypage-feroceon.c
+++ b/arch/arm/mm/copypage-feroceon.c
@@ -79,12 +79,11 @@ void feroceon_copy_user_highpage(struct page *to, struct page *from,
 	kunmap_atomic(kto, KM_USER0);
 }
 
-void __attribute__((naked))
-feroceon_clear_user_page(void *kaddr, unsigned long vaddr)
+void feroceon_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm("\
-	stmfd	sp!, {r4-r7, lr}		\n\
-	mov	r1, %0				\n\
+	mov	r1, %1				\n\
 	mov	r2, #0				\n\
 	mov	r3, #0				\n\
 	mov	r4, #0				\n\
@@ -93,19 +92,20 @@ feroceon_clear_user_page(void *kaddr, unsigned long vaddr)
 	mov	r7, #0				\n\
 	mov	ip, #0				\n\
 	mov	lr, #0				\n\
-1:	stmia	r0, {r2-r7, ip, lr}		\n\
+1:	stmia	%0, {r2-r7, ip, lr}		\n\
 	subs	r1, r1, #1			\n\
-	mcr	p15, 0, r0, c7, c14, 1		@ clean and invalidate D line\n\
+	mcr	p15, 0, %0, c7, c14, 1		@ clean and invalidate D line\n\
 	add	r0, r0, #32			\n\
 	bne	1b				\n\
-	mcr	p15, 0, r1, c7, c10, 4		@ drain WB\n\
-	ldmfd	sp!, {r4-r7, pc}"
+	mcr	p15, 0, r1, c7, c10, 4		@ drain WB"
 	:
-	: "I" (PAGE_SIZE / 32));
+	: "r" (kaddr), "I" (PAGE_SIZE / 32)
+	: "r1", "r2", "r3", "r4", "r5", "r6", "r7", "ip", "lr");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns feroceon_user_fns __initdata = {
-	.cpu_clear_user_page	= feroceon_clear_user_page,
+	.cpu_clear_user_highpage = feroceon_clear_user_highpage,
 	.cpu_copy_user_highpage	= feroceon_copy_user_highpage,
 };
 
diff --git a/arch/arm/mm/copypage-v3.c b/arch/arm/mm/copypage-v3.c
index 52df8f0..13ce0ba 100644
--- a/arch/arm/mm/copypage-v3.c
+++ b/arch/arm/mm/copypage-v3.c
@@ -54,10 +54,10 @@ void v3_copy_user_highpage(struct page *to, struct page *from,
  *
  * FIXME: do we need to handle cache stuff...
  */
-void __attribute__((naked)) v3_clear_user_page(void *kaddr, unsigned long vaddr)
+void v3_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm("\n\
-	str	lr, [sp, #-4]!\n\
 	mov	r1, %1				@ 1\n\
 	mov	r2, #0				@ 1\n\
 	mov	r3, #0				@ 1\n\
@@ -68,13 +68,14 @@ void __attribute__((naked)) v3_clear_user_page(void *kaddr, unsigned long vaddr)
 	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
 	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
 	subs	r1, r1, #1			@ 1\n\
-	bne	1b				@ 1\n\
-	ldr	pc, [sp], #4"
+	bne	1b				@ 1"
 	:
-	: "r" (kaddr), "I" (PAGE_SIZE / 64));
+	: "r" (kaddr), "I" (PAGE_SIZE / 64)
+	: "r1", "r2", "r3", "ip", "lr");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns v3_user_fns __initdata = {
-	.cpu_clear_user_page	= v3_clear_user_page,
+	.cpu_clear_user_highpage = v3_clear_user_highpage,
 	.cpu_copy_user_highpage	= v3_copy_user_highpage,
 };
diff --git a/arch/arm/mm/copypage-v4mc.c b/arch/arm/mm/copypage-v4mc.c
index a7dc838..a5eae50 100644
--- a/arch/arm/mm/copypage-v4mc.c
+++ b/arch/arm/mm/copypage-v4mc.c
@@ -91,30 +91,30 @@ void v4_mc_copy_user_highpage(struct page *from, struct page *to,
 /*
  * ARMv4 optimised clear_user_page
  */
-void __attribute__((naked))
-v4_mc_clear_user_page(void *kaddr, unsigned long vaddr)
+void v4_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	asm volatile(
-	"str	lr, [sp, #-4]!\n\
+	void *kaddr = kmap_atomic(page, KM_USER0);
+	asm volatile("\
 	mov	r1, %0				@ 1\n\
 	mov	r2, #0				@ 1\n\
 	mov	r3, #0				@ 1\n\
 	mov	ip, #0				@ 1\n\
 	mov	lr, #0				@ 1\n\
-1:	mcr	p15, 0, r0, c7, c6, 1		@ 1   invalidate D line\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	mcr	p15, 0, r0, c7, c6, 1		@ 1   invalidate D line\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
+1:	mcr	p15, 0, %0, c7, c6, 1		@ 1   invalidate D line\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	mcr	p15, 0, %0, c7, c6, 1		@ 1   invalidate D line\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
 	subs	r1, r1, #1			@ 1\n\
-	bne	1b				@ 1\n\
-	ldr	pc, [sp], #4"
+	bne	1b				@ 1"
 	:
-	: "I" (PAGE_SIZE / 64));
+	: "r" (kaddr), "I" (PAGE_SIZE / 64)
+	: "r1", "r2", "r3", "ip", "lr");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns v4_mc_user_fns __initdata = {
-	.cpu_clear_user_page	= v4_mc_clear_user_page, 
+	.cpu_clear_user_highpage = v4_mc_clear_user_highpage,
 	.cpu_copy_user_highpage	= v4_mc_copy_user_highpage,
 };
diff --git a/arch/arm/mm/copypage-v4wb.c b/arch/arm/mm/copypage-v4wb.c
index 186a68a..9144a96 100644
--- a/arch/arm/mm/copypage-v4wb.c
+++ b/arch/arm/mm/copypage-v4wb.c
@@ -64,31 +64,31 @@ void v4wb_copy_user_highpage(struct page *to, struct page *from,
  *
  * Same story as above.
  */
-void __attribute__((naked))
-v4wb_clear_user_page(void *kaddr, unsigned long vaddr)
+void v4wb_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm("\
-	str	lr, [sp, #-4]!\n\
-	mov	r1, %0				@ 1\n\
+	mov	r1, %1				@ 1\n\
 	mov	r2, #0				@ 1\n\
 	mov	r3, #0				@ 1\n\
 	mov	ip, #0				@ 1\n\
 	mov	lr, #0				@ 1\n\
-1:	mcr	p15, 0, r0, c7, c6, 1		@ 1   invalidate D line\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	mcr	p15, 0, r0, c7, c6, 1		@ 1   invalidate D line\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
+1:	mcr	p15, 0, %0, c7, c6, 1		@ 1   invalidate D line\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	mcr	p15, 0, %0, c7, c6, 1		@ 1   invalidate D line\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
 	subs	r1, r1, #1			@ 1\n\
 	bne	1b				@ 1\n\
-	mcr	p15, 0, r1, c7, c10, 4		@ 1   drain WB\n\
-	ldr	pc, [sp], #4"
+	mcr	p15, 0, r1, c7, c10, 4		@ 1   drain WB"
 	:
-	: "I" (PAGE_SIZE / 64));
+	: "r" (kaddr), "I" (PAGE_SIZE / 64)
+	: "r1", "r2", "r3", "ip", "lr");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns v4wb_user_fns __initdata = {
-	.cpu_clear_user_page	= v4wb_clear_user_page,
+	.cpu_clear_user_highpage = v4wb_clear_user_highpage,
 	.cpu_copy_user_highpage	= v4wb_copy_user_highpage,
 };
diff --git a/arch/arm/mm/copypage-v4wt.c b/arch/arm/mm/copypage-v4wt.c
index 86c2cfd..b8a345d 100644
--- a/arch/arm/mm/copypage-v4wt.c
+++ b/arch/arm/mm/copypage-v4wt.c
@@ -60,29 +60,29 @@ void v4wt_copy_user_highpage(struct page *to, struct page *from,
  *
  * Same story as above.
  */
-void __attribute__((naked))
-v4wt_clear_user_page(void *kaddr, unsigned long vaddr)
+void v4wt_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm("\
-	str	lr, [sp, #-4]!\n\
-	mov	r1, %0				@ 1\n\
+	mov	r1, %1				@ 1\n\
 	mov	r2, #0				@ 1\n\
 	mov	r3, #0				@ 1\n\
 	mov	ip, #0				@ 1\n\
 	mov	lr, #0				@ 1\n\
-1:	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
-	stmia	r0!, {r2, r3, ip, lr}		@ 4\n\
+1:	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
+	stmia	%0!, {r2, r3, ip, lr}		@ 4\n\
 	subs	r1, r1, #1			@ 1\n\
 	bne	1b				@ 1\n\
-	mcr	p15, 0, r2, c7, c7, 0		@ flush ID cache\n\
-	ldr	pc, [sp], #4"
+	mcr	p15, 0, r2, c7, c7, 0		@ flush ID cache"
 	:
-	: "I" (PAGE_SIZE / 64));
+	: "r" (kaddr), "I" (PAGE_SIZE / 64)
+	: "r1", "r2", "r3", "ip", "lr");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns v4wt_user_fns __initdata = {
-	.cpu_clear_user_page	= v4wt_clear_user_page,
+	.cpu_clear_user_highpage = v4wt_clear_user_highpage,
 	.cpu_copy_user_highpage	= v4wt_copy_user_highpage,
 };
diff --git a/arch/arm/mm/copypage-v6.c b/arch/arm/mm/copypage-v6.c
index 2ea75d0..4127a7b 100644
--- a/arch/arm/mm/copypage-v6.c
+++ b/arch/arm/mm/copypage-v6.c
@@ -49,9 +49,11 @@ static void v6_copy_user_highpage_nonaliasing(struct page *to,
  * Clear the user page.  No aliasing to deal with so we can just
  * attack the kernel's existing mapping of this page.
  */
-static void v6_clear_user_page_nonaliasing(void *kaddr, unsigned long vaddr)
+static void v6_clear_user_highpage_nonaliasing(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	clear_page(kaddr);
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 /*
@@ -107,20 +109,13 @@ static void v6_copy_user_highpage_aliasing(struct page *to,
  * so remap the kernel page into the same cache colour as the user
  * page.
  */
-static void v6_clear_user_page_aliasing(void *kaddr, unsigned long vaddr)
+static void v6_clear_user_highpage_aliasing(struct page *page, unsigned long vaddr)
 {
 	unsigned int offset = CACHE_COLOUR(vaddr);
 	unsigned long to = to_address + (offset << PAGE_SHIFT);
 
-	/*
-	 * Discard data in the kernel mapping for the new page
-	 * FIXME: needs this MCRR to be supported.
-	 */
-	__asm__("mcrr	p15, 0, %1, %0, c6	@ 0xec401f06"
-	   :
-	   : "r" (kaddr),
-	     "r" ((unsigned long)kaddr + PAGE_SIZE - L1_CACHE_BYTES)
-	   : "cc");
+	/* FIXME: not highmem safe */
+	discard_old_kernel_data(page_address(page));
 
 	/*
 	 * Now clear the page using the same cache colour as
@@ -128,7 +123,7 @@ static void v6_clear_user_page_aliasing(void *kaddr, unsigned long vaddr)
 	 */
 	spin_lock(&v6_lock);
 
-	set_pte_ext(TOP_PTE(to_address) + offset, pfn_pte(__pa(kaddr) >> PAGE_SHIFT, PAGE_KERNEL), 0);
+	set_pte_ext(TOP_PTE(to_address) + offset, pfn_pte(page_to_pfn(page), PAGE_KERNEL), 0);
 	flush_tlb_kernel_page(to);
 	clear_page((void *)to);
 
@@ -136,14 +131,14 @@ static void v6_clear_user_page_aliasing(void *kaddr, unsigned long vaddr)
 }
 
 struct cpu_user_fns v6_user_fns __initdata = {
-	.cpu_clear_user_page	= v6_clear_user_page_nonaliasing,
+	.cpu_clear_user_highpage = v6_clear_user_highpage_nonaliasing,
 	.cpu_copy_user_highpage	= v6_copy_user_highpage_nonaliasing,
 };
 
 static int __init v6_userpage_init(void)
 {
 	if (cache_is_vipt_aliasing()) {
-		cpu_user.cpu_clear_user_page = v6_clear_user_page_aliasing;
+		cpu_user.cpu_clear_user_highpage = v6_clear_user_highpage_aliasing;
 		cpu_user.cpu_copy_user_highpage = v6_copy_user_highpage_aliasing;
 	}
 
diff --git a/arch/arm/mm/copypage-xsc3.c b/arch/arm/mm/copypage-xsc3.c
index caa697c..0e7cb32 100644
--- a/arch/arm/mm/copypage-xsc3.c
+++ b/arch/arm/mm/copypage-xsc3.c
@@ -87,26 +87,27 @@ void xsc3_mc_copy_user_highpage(struct page *to, struct page *from,
  *  r0 = destination
  *  r1 = virtual user address of ultimate destination page
  */
-void __attribute__((naked))
-xsc3_mc_clear_user_page(void *kaddr, unsigned long vaddr)
+void xsc3_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm("\
-	mov	r1, %0				\n\
+	mov	r1, %1				\n\
 	mov	r2, #0				\n\
 	mov	r3, #0				\n\
-1:	mcr	p15, 0, r0, c7, c6, 1		@ invalidate line\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
+1:	mcr	p15, 0, %0, c7, c6, 1		@ invalidate line\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
 	subs	r1, r1, #1			\n\
-	bne	1b				\n\
-	mov	pc, lr"
+	bne	1b"
 	:
-	: "I" (PAGE_SIZE / 32));
+	: "r" (kaddr), "I" (PAGE_SIZE / 32)
+	: "r1", "r2", "r3");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns xsc3_mc_user_fns __initdata = {
-	.cpu_clear_user_page	= xsc3_mc_clear_user_page,
+	.cpu_clear_user_highpage = xsc3_mc_clear_user_highpage,
 	.cpu_copy_user_highpage	= xsc3_mc_copy_user_highpage,
 };
diff --git a/arch/arm/mm/copypage-xscale.c b/arch/arm/mm/copypage-xscale.c
index 01bafaf..aa9f2ff 100644
--- a/arch/arm/mm/copypage-xscale.c
+++ b/arch/arm/mm/copypage-xscale.c
@@ -113,28 +113,30 @@ void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 /*
  * XScale optimised clear_user_page
  */
-void __attribute__((naked))
-xscale_mc_clear_user_page(void *kaddr, unsigned long vaddr)
+void
+xscale_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
+	void *kaddr = kmap_atomic(page, KM_USER0);
 	asm volatile(
-	"mov	r1, %0				\n\
+	"mov	r1, %1				\n\
 	mov	r2, #0				\n\
 	mov	r3, #0				\n\
-1:	mov	ip, r0				\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
-	strd	r2, [r0], #8			\n\
+1:	mov	ip, %0				\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
+	strd	r2, [%0], #8			\n\
 	mcr	p15, 0, ip, c7, c10, 1		@ clean D line\n\
 	subs	r1, r1, #1			\n\
 	mcr	p15, 0, ip, c7, c6, 1		@ invalidate D line\n\
-	bne	1b				\n\
-	mov	pc, lr"
+	bne	1b"
 	:
-	: "I" (PAGE_SIZE / 32));
+	: "r" (kaddr), "I" (PAGE_SIZE / 32)
+	: "r1", "r2", "r3", "ip");
+	kunmap_atomic(kaddr, KM_USER0);
 }
 
 struct cpu_user_fns xscale_mc_user_fns __initdata = {
-	.cpu_clear_user_page	= xscale_mc_clear_user_page, 
+	.cpu_clear_user_highpage = xscale_mc_clear_user_highpage,
 	.cpu_copy_user_highpage	= xscale_mc_copy_user_highpage,
 };
diff --git a/arch/arm/mm/proc-syms.c b/arch/arm/mm/proc-syms.c
index b9743e6..4ad3bf2 100644
--- a/arch/arm/mm/proc-syms.c
+++ b/arch/arm/mm/proc-syms.c
@@ -33,7 +33,7 @@ EXPORT_SYMBOL(cpu_cache);
 
 #ifdef CONFIG_MMU
 #ifndef MULTI_USER
-EXPORT_SYMBOL(__cpu_clear_user_page);
+EXPORT_SYMBOL(__cpu_clear_user_highpage);
 EXPORT_SYMBOL(__cpu_copy_user_highpage);
 #else
 EXPORT_SYMBOL(cpu_user);
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 7dcbc82..13875ce 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -63,12 +63,14 @@ static inline void *kmap_atomic(struct page *page, enum km_type idx)
 #endif /* CONFIG_HIGHMEM */
 
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
+#ifndef clear_user_highpage
 static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
 {
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
 }
+#endif
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 /**

----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
