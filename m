Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id CDA5B6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:46:32 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so4724227wib.5
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:46:30 -0700 (PDT)
Received: from mail.emea.novell.com (mail.emea.novell.com. [130.57.118.101])
        by mx.google.com with ESMTPS id au6si25800755wjc.98.2014.06.02.07.46.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 07:46:21 -0700 (PDT)
Message-Id: <538CAA520200007800016E87@mail.emea.novell.com>
Date: Mon, 02 Jun 2014 15:46:10 +0100
From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Vrabel <david.vrabel@citrix.com>, mingo@elte.hu, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

For cold page allocations using the normal clear_highpage() mechanism
may be inefficient on certain architectures, namely due to needlessly
replacing a good part of the data cache contents. Introduce an arch-
overridable clear_cold_highpage() (using streaming non-temporal stores
on x86, where an override gets implemented right away) to make use of
in this specific case.

Leverage the impovement in the Xen balloon driver, eliminating the
explicit scrub_page() function.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 arch/x86/include/asm/page_types.h |    3 ++
 arch/x86/lib/Makefile             |    4 +--
 arch/x86/lib/clear_page_32.S      |   42 +++++++++++++++++++++++++++++++++=
+++++
 arch/x86/lib/clear_page_64.S      |   28 ++++++++++++++++++++++++-
 drivers/xen/balloon.c             |   14 ++++++------
 include/linux/highmem.h           |   13 +++++++++++
 mm/page_alloc.c                   |    8 +++++--
 7 files changed, 100 insertions(+), 12 deletions(-)

--- 3.15-rc8/arch/x86/include/asm/page_types.h
+++ 3.15-rc8-clear-cold-highpage/arch/x86/include/asm/page_types.h
@@ -46,6 +46,9 @@
=20
 #ifndef __ASSEMBLY__
=20
+void clear_cold_page(void *);
+#define clear_cold_page clear_cold_page
+
 extern int devmem_is_allowed(unsigned long pagenr);
=20
 extern unsigned long max_low_pfn_mapped;
--- 3.15-rc8/arch/x86/lib/Makefile
+++ 3.15-rc8-clear-cold-highpage/arch/x86/lib/Makefile
@@ -19,7 +19,7 @@ obj-$(CONFIG_SMP) +=3D msr-smp.o cache-smp
 lib-y :=3D delay.o misc.o
 lib-y +=3D thunk_$(BITS).o
 lib-y +=3D usercopy_$(BITS).o usercopy.o getuser.o putuser.o
-lib-y +=3D memcpy_$(BITS).o
+lib-y +=3D memcpy_$(BITS).o clear_page_$(BITS).o
 lib-$(CONFIG_SMP) +=3D rwlock.o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) +=3D rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) +=3D insn.o inat.o
@@ -39,7 +39,7 @@ endif
 else
         obj-y +=3D iomap_copy_64.o
         lib-y +=3D csum-partial_64.o csum-copy_64.o csum-wrappers_64.o
-        lib-y +=3D thunk_64.o clear_page_64.o copy_page_64.o
+        lib-y +=3D thunk_64.o copy_page_64.o
         lib-y +=3D memmove_64.o memset_64.o
         lib-y +=3D copy_user_64.o copy_user_nocache_64.o
 	lib-y +=3D cmpxchg16b_emu.o
--- /home/jbeulich/tmp/linux-3.15-rc8/arch/x86/lib/clear_page_32.S	=
1970-01-01 01:00:00.000000000 +0100
+++ 3.15-rc8-clear-cold-highpage/arch/x86/lib/clear_page_32.S
@@ -0,0 +1,42 @@
+#include <linux/linkage.h>
+#include <asm/alternative-asm.h>
+#include <asm/cpufeature.h>
+#include <asm/dwarf2.h>
+#include <asm/page_types.h>
+
+ENTRY(clear_cold_page)
+	CFI_STARTPROC
+	xorl	%edx,%edx
+#ifdef CONFIG_X86_USE_3DNOW
+	jmp	mmx_clear_page
+#else
+	movl	$PAGE_SIZE,%ecx
+	jmp	memset
+#endif
+	.p2align 4
+.Lcold_loop:
+	decl	%ecx
+#define PUT(x) movntil %edx,x*4(%eax)
+	movntil %edx,(%eax)
+	PUT(1)
+	PUT(2)
+	PUT(3)
+	PUT(4)
+	PUT(5)
+	PUT(6)
+	PUT(7)
+	leal	8*4(%eax),%eax
+	jnz	.Lcold_loop
+	sfence
+	ret
+	CFI_ENDPROC
+ENDPROC(clear_cold_page)
+
+	.section .altinstr_replacement,"ax"
+1:	movl	$PAGE_SIZE/(8*4),%ecx
+2:
+	.previous
+	.section .altinstructions,"a"
+	altinstruction_entry clear_cold_page, 1b, X86_FEATURE_XMM2, \
+			     .Lcold_loop-clear_cold_page, 2b-1b
+	.previous
--- 3.15-rc8/arch/x86/lib/clear_page_64.S
+++ 3.15-rc8-clear-cold-highpage/arch/x86/lib/clear_page_64.S
@@ -1,6 +1,7 @@
 #include <linux/linkage.h>
 #include <asm/dwarf2.h>
 #include <asm/alternative-asm.h>
+#include <asm/page_types.h>
=20
 /*
  * Zero a page. =09
@@ -27,7 +28,7 @@ ENDPROC(clear_page_c_e)
 ENTRY(clear_page)
 	CFI_STARTPROC
 	xorl   %eax,%eax
-	movl   $4096/64,%ecx
+	movl   $PAGE_SIZE/64,%ecx
 	.p2align 4
 .Lloop:
 	decl	%ecx
@@ -40,6 +41,7 @@ ENTRY(clear_page)
 	PUT(5)
 	PUT(6)
 	PUT(7)
+#undef PUT
 	leaq	64(%rdi),%rdi
 	jnz	.Lloop
 	nop
@@ -48,6 +50,30 @@ ENTRY(clear_page)
 .Lclear_page_end:
 ENDPROC(clear_page)
=20
+ENTRY(clear_cold_page)
+	CFI_STARTPROC
+	xorl   %eax,%eax
+	movl   $PAGE_SIZE/(8*8),%ecx
+	.p2align 4
+.Lcold_loop:
+	decl	%ecx
+#define PUT(x) movntiq %rax,x*8(%rdi)
+	movntiq %rax,(%rdi)
+	PUT(1)
+	PUT(2)
+	PUT(3)
+	PUT(4)
+	PUT(5)
+	PUT(6)
+	PUT(7)
+#undef PUT
+	leaq	8*8(%rdi),%rdi
+	jnz	.Lcold_loop
+	sfence
+	ret
+	CFI_ENDPROC
+ENDPROC(clear_cold_page)
+
 	/*
 	 * Some CPUs support enhanced REP MOVSB/STOSB instructions.
 	 * It is recommended to use this when possible.
--- 3.15-rc8/drivers/xen/balloon.c
+++ 3.15-rc8-clear-cold-highpage/drivers/xen/balloon.c
@@ -107,12 +107,11 @@ static DECLARE_DELAYED_WORK(balloon_work
 #define GFP_BALLOON \
 	(GFP_HIGHUSER | __GFP_NOWARN | __GFP_NORETRY | __GFP_NOMEMALLOC)
=20
-static void scrub_page(struct page *page)
-{
 #ifdef CONFIG_XEN_SCRUB_PAGES
-	clear_highpage(page);
+#define __GFP_SCRUB __GFP_ZERO
+#else
+#define __GFP_SCRUB 0
 #endif
-}
=20
 /* balloon_append: add the given page to the balloon. */
 static void __balloon_append(struct page *page)
@@ -360,7 +359,9 @@ static enum bp_state increase_reservatio
 #endif
=20
 		/* Relinquish the page back to the allocator. */
-		__free_reserved_page(page);
+		ClearPageReserved(page);
+		init_page_count(page);
+		free_hot_cold_page(page, 1);
 	}
=20
 	balloon_stats.current_pages +=3D rc;
@@ -392,6 +393,7 @@ static enum bp_state decrease_reservatio
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages =3D ARRAY_SIZE(frame_list);
=20
+	gfp |=3D __GFP_NOTRACK | __GFP_COLD | __GFP_SCRUB;
 	for (i =3D 0; i < nr_pages; i++) {
 		page =3D alloc_page(gfp);
 		if (page =3D=3D NULL) {
@@ -399,8 +401,6 @@ static enum bp_state decrease_reservatio
 			state =3D BP_EAGAIN;
 			break;
 		}
-		scrub_page(page);
-
 		frame_list[i] =3D page_to_pfn(page);
 	}
=20
--- 3.15-rc8/include/linux/highmem.h
+++ 3.15-rc8-clear-cold-highpage/include/linux/highmem.h
@@ -189,6 +189,19 @@ static inline void clear_highpage(struct
 	kunmap_atomic(kaddr);
 }
=20
+#ifndef __HAVE_ARCH_CLEAR_COLD_HIGHPAGE
+#ifdef clear_cold_page
+static inline void clear_cold_highpage(struct page *page)
+{
+	void *kaddr =3D kmap_atomic(page);
+	clear_cold_page(kaddr);
+	kunmap_atomic(kaddr);
+}
+#else
+#define clear_cold_highpage clear_highpage
+#endif
+#endif
+
 static inline void zero_user_segments(struct page *page,
 	unsigned start1, unsigned end1,
 	unsigned start2, unsigned end2)
--- 3.15-rc8/mm/page_alloc.c
+++ 3.15-rc8-clear-cold-highpage/mm/page_alloc.c
@@ -417,8 +417,12 @@ static inline void prep_zero_page(struct
 	 * and __GFP_HIGHMEM from hard or soft interrupt context.
 	 */
 	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
-	for (i =3D 0; i < (1 << order); i++)
-		clear_highpage(page + i);
+	for (i =3D 0; i < (1 << order); i++) {
+		if (unlikely(gfp_flags & __GFP_COLD))
+			clear_cold_highpage(page + i);
+		else
+			clear_highpage(page + i);
+	}
 }
=20
 #ifdef CONFIG_DEBUG_PAGEALLOC


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
