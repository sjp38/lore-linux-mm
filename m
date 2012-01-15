Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id E6F1A6B004F
	for <linux-mm@kvack.org>; Sun, 15 Jan 2012 10:07:19 -0500 (EST)
Date: Sun, 15 Jan 2012 15:07:07 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH] proc: clear_refs: do not clear reserved pages
Message-ID: <20120115150706.GA7474@mudshark.cambridge.arm.com>
References: <1326467587-22218-1-git-send-email-will.deacon@arm.com>
 <alpine.LFD.2.02.1201131748380.2722@xanadu.home>
 <alpine.LSU.2.00.1201140901260.2381@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1201140901260.2381@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nicolas Pitre <nico@fluxnic.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "moussaba@micron.com" <moussaba@micron.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Hi Hugh,

Thanks for the explanation.

On Sat, Jan 14, 2012 at 05:36:37PM +0000, Hugh Dickins wrote:
> On Fri, 13 Jan 2012, Nicolas Pitre wrote:
> > Given Andrew's answer, this should be fine wrt Russell's concern.
> > 
> > Acked-by: Nicolas Pitre <nico@linaro.org>
> 
> Yes, it should be okay as an urgent fix for -stable.
> But going forward, I doubt it's the right answer: comments below.

Ok great, getting this into -stable ASAP would be much appreciated. Can
somebody pick it up please?

> Please, going forward, can you delete your vectors page code, and
> use the gate_vma for it?  Extending it a little if it somehow does
> not satsify your need.  Or else can you please explain (ec706dab
> does not) why the gate_vma does not suit you.
> 
> I'm not saying the horrible hack gate_vma mechanism is any safer
> than yours (the latest bug in it was fixed all of 13 days ago).
> But I am saying that one horrible hack is safer than two.

Something like what I've got below seems to do the trick, and clear_refs
also seems to behave when it's presented with the gate_vma. If Russell is
happy with the approach, we can move to the gate_vma in the future.

Thanks,

Will


    ARM: vectors: use gate_vma for vectors user mapping
    
    The current user mapping for the vectors page is inserted as a `horrible
    hack vma' into each task via arch_setup_additional_pages. This causes
    problems with the MM subsystem and vm_normal_page, as described here:
    
    https://lkml.org/lkml/2012/1/14/55
    
    Following the suggestion from Hugh in the above thread, this patch uses
    the gate_vma for the vectors user mapping, therefore consolidating
    the horrible hack VMAs into one.
    
    Signed-off-by: Will Deacon <will.deacon@arm.com>

diff --git a/arch/arm/include/asm/elf.h b/arch/arm/include/asm/elf.h
index 0e9ce8d..38050b1 100644
--- a/arch/arm/include/asm/elf.h
+++ b/arch/arm/include/asm/elf.h
@@ -130,8 +130,4 @@ struct mm_struct;
 extern unsigned long arch_randomize_brk(struct mm_struct *mm);
 #define arch_randomize_brk arch_randomize_brk
 
-extern int vectors_user_mapping(void);
-#define arch_setup_additional_pages(bprm, uses_interp) vectors_user_mapping()
-#define ARCH_HAS_SETUP_ADDITIONAL_PAGES
-
 #endif
diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index ca94653..e851aa3 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -151,6 +151,8 @@ extern void __cpu_copy_user_highpage(struct page *to, struct page *from,
 #define clear_page(page)	memset((void *)(page), 0, PAGE_SIZE)
 extern void copy_page(void *to, const void *from);
 
+#define __HAVE_ARCH_GATE_AREA 1
+
 #include <asm/pgtable-2level-types.h>
 
 #endif /* CONFIG_MMU */
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 3d0c6fb..c13b8f6 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -493,22 +493,40 @@ unsigned long arch_randomize_brk(struct mm_struct *mm)
 #ifdef CONFIG_MMU
 /*
  * The vectors page is always readable from user space for the
- * atomic helpers and the signal restart code.  Let's declare a mapping
- * for it so it is visible through ptrace and /proc/<pid>/mem.
+ * atomic helpers and the signal restart code. Insert it into the
+ * gate_vma so that it is visible through ptrace and /proc/<pid>/mem.
  */
+static struct vm_area_struct gate_vma;
 
-int vectors_user_mapping(void)
+static int __init gate_vma_init(void)
 {
-	struct mm_struct *mm = current->mm;
-	return install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
-				       VM_READ | VM_EXEC |
-				       VM_MAYREAD | VM_MAYEXEC |
-				       VM_ALWAYSDUMP | VM_RESERVED,
-				       NULL);
+	gate_vma.vm_start	= 0xffff0000;
+	gate_vma.vm_end		= 0xffff0000 + PAGE_SIZE;
+	gate_vma.vm_page_prot	= PAGE_READONLY_EXEC;
+	gate_vma.vm_flags	= VM_READ | VM_EXEC |
+				  VM_MAYREAD | VM_MAYEXEC |
+				  VM_ALWAYSDUMP;
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
+
+int in_gate_area_no_mm(unsigned long addr)
+{
+	return in_gate_area(NULL, addr);
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
-	return (vma->vm_start == 0xffff0000) ? "[vectors]" : NULL;
+	return (vma == &gate_vma) ? "[vectors]" : NULL;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
