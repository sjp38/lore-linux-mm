Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 517DF6B0035
	for <linux-mm@kvack.org>; Sun,  3 Nov 2013 23:49:21 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq13so2559916pbb.34
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 20:49:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id xb5si9829008pab.26.2013.11.03.20.49.03
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 20:49:04 -0800 (PST)
Date: Mon, 4 Nov 2013 04:48:44 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: converting unicore32 to gate_vma as done for arm (was Re: [PATCH]
 mm: cache largest vma)
Message-ID: <20131104044844.GN13318@ZenIV.linux.org.uk>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Nov 03, 2013 at 08:20:10PM -0800, Davidlohr Bueso wrote:
> > > diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
> > > index fb5e4c6..38cc7fc 100644
> > > --- a/arch/unicore32/include/asm/mmu_context.h
> > > +++ b/arch/unicore32/include/asm/mmu_context.h
> > > @@ -73,7 +73,7 @@ do { \
> > >  		else \
> > >  			mm->mmap = NULL; \
> > >  		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> > > -		mm->mmap_cache = NULL; \
> > > +		vma_clear_caches(mm);			\
> > >  		mm->map_count--; \
> > >  		remove_vma(high_vma); \
> > >  	} \

BTW, this one needs an analog of
commit f9d4861fc32b995b1616775614459b8f266c803c
Author: Will Deacon <will.deacon@arm.com>
Date:   Fri Jan 20 12:01:13 2012 +0100

    ARM: 7294/1: vectors: use gate_vma for vectors user mapping

This code is a copy of older arm logics rewritten in that commit; unicore32
never got its counterpart.  I have a [completely untested] variant sitting
in vfs.git#vm^; it's probably worth testing - if it works, we'll get rid
of one more place that needs to be aware of MM guts and unicore32 folks
will have fewer potential headache sources...

FWIW, after porting to the current tree it becomes the following; I'm not
sure whether we want VM_DONTEXPAND | VM_DONTDUMP set for this one, though...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/arch/unicore32/include/asm/elf.h b/arch/unicore32/include/asm/elf.h
index 829042d..eeba258 100644
--- a/arch/unicore32/include/asm/elf.h
+++ b/arch/unicore32/include/asm/elf.h
@@ -87,8 +87,4 @@ struct mm_struct;
 extern unsigned long arch_randomize_brk(struct mm_struct *mm);
 #define arch_randomize_brk arch_randomize_brk
 
-extern int vectors_user_mapping(void);
-#define arch_setup_additional_pages(bprm, uses_interp) vectors_user_mapping()
-#define ARCH_HAS_SETUP_ADDITIONAL_PAGES
-
 #endif
diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index fb5e4c6..600b1b8 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -18,6 +18,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/cpu-single.h>
+#include <asm-generic/mm_hooks.h>
 
 #define init_new_context(tsk, mm)	0
 
@@ -56,32 +57,4 @@ switch_mm(struct mm_struct *prev, struct mm_struct *next,
 #define deactivate_mm(tsk, mm)	do { } while (0)
 #define activate_mm(prev, next)	switch_mm(prev, next, NULL)
 
-/*
- * We are inserting a "fake" vma for the user-accessible vector page so
- * gdb and friends can get to it through ptrace and /proc/<pid>/mem.
- * But we also want to remove it before the generic code gets to see it
- * during process exit or the unmapping of it would  cause total havoc.
- * (the macro is used as remove_vma() is static to mm/mmap.c)
- */
-#define arch_exit_mmap(mm) \
-do { \
-	struct vm_area_struct *high_vma = find_vma(mm, 0xffff0000); \
-	if (high_vma) { \
-		BUG_ON(high_vma->vm_next);  /* it should be last */ \
-		if (high_vma->vm_prev) \
-			high_vma->vm_prev->vm_next = NULL; \
-		else \
-			mm->mmap = NULL; \
-		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
-		mm->mmap_cache = NULL; \
-		mm->map_count--; \
-		remove_vma(high_vma); \
-	} \
-} while (0)
-
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
-{
-}
-
 #endif
diff --git a/arch/unicore32/include/asm/page.h b/arch/unicore32/include/asm/page.h
index 594b322..e79da8b 100644
--- a/arch/unicore32/include/asm/page.h
+++ b/arch/unicore32/include/asm/page.h
@@ -28,6 +28,8 @@ extern void copy_page(void *to, const void *from);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
+#define __HAVE_ARCH_GATE_AREA 1
+
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index 778ebba..51d129e 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -307,21 +307,39 @@ unsigned long arch_randomize_brk(struct mm_struct *mm)
 
 /*
  * The vectors page is always readable from user space for the
- * atomic helpers and the signal restart code.  Let's declare a mapping
- * for it so it is visible through ptrace and /proc/<pid>/mem.
+ * atomic helpers and the signal restart code. Insert it into the
+ * gate_vma so that it is visible through ptrace and /proc/<pid>/mem.
  */
+static struct vm_area_struct gate_vma = {
+	.vm_start	= 0xffff0000,
+	.vm_end		= 0xffff0000 + PAGE_SIZE,
+	.vm_flags	= VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC |
+			  VM_DONTEXPAND | VM_DONTDUMP,
+};
+
+static int __init gate_vma_init(void)
+{
+	gate_vma.vm_page_prot	= PAGE_READONLY_EXEC;
+	return 0;
+}
+arch_initcall(gate_vma_init);
+
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
+{
+	return &gate_vma;
+}
+
+int in_gate_area(struct mm_struct *mm, unsigned long addr)
+{
+	return (addr >= gate_vma.vm_start) && (addr < gate_vma.vm_end);
+}
 
-int vectors_user_mapping(void)
+int in_gate_area_no_mm(unsigned long addr)
 {
-	struct mm_struct *mm = current->mm;
-	return install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
-				       VM_READ | VM_EXEC |
-				       VM_MAYREAD | VM_MAYEXEC |
-				       VM_DONTEXPAND | VM_DONTDUMP,
-				       NULL);
+	return in_gate_area(NULL, addr);
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
-	return (vma->vm_start == 0xffff0000) ? "[vectors]" : NULL;
+	return (vma == &gate_vma) ? "[vectors]" : NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
