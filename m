Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC8D56B0038
	for <linux-mm@kvack.org>; Sat, 18 Feb 2017 04:21:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so4809211wmi.6
        for <linux-mm@kvack.org>; Sat, 18 Feb 2017 01:21:37 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id j1si16380310wrc.129.2017.02.18.01.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Feb 2017 01:21:36 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id v77so6129447wmv.0
        for <linux-mm@kvack.org>; Sat, 18 Feb 2017 01:21:35 -0800 (PST)
Date: Sat, 18 Feb 2017 12:21:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and
 PR_GET_MAX_VADDR
Message-ID: <20170218092133.GA17471@node.shutemov.name>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 12:02:13PM -0800, Linus Torvalds wrote:
> I also get he feeling that the whole thing is unnecessary. I'm
> wondering if we should just instead say that the whole 47 vs 56-bit
> virtual address is _purely_ about "get_unmapped_area()", and nothing
> else.
> 
> IOW, I'm wondering if we can't just say that
> 
>  - if the processor and kernel support 56-bit user address space, then
> you can *always* use the whole space
> 
>  - but by default, get_unmapped_area() will only return mappings that
> fit in the 47 bit address space.
> 
> So if you use MAP_FIXED and give an address in the high range, it will
> just always work, and the MM will always consider the task size to be
> the full address space.
> 
> But for the common case where a process does no use MAP_FIXED, the
> kernel will never give a high address by default, and you have to do
> the process control thing to say "I want those high addresses".
> 
> Hmm?
> 
> In other words, I'd like to at least start out trying to keep the
> differences between the 47-bit and 56-bit models as simple and minimal
> as possible. Not make such a big deal out of it.
> 
> We already have "arch_get_unmapped_area()" that controls the whole
> "what will non-MAP_FIXED mmap allocations return", so I'd hope that
> the above kind of semantics could be done without *any* actual
> TASK_SIZE changes _anywhere_ in the VM code.
> 
> Comments?

Okay, below is my try on implementing this.

I've chosen to respect hint address even without MAP_FIXED, but only if
it doesn't collide with other mappings. Otherwise, fallback to look for
unmapped area within 47-bit window.

Interaction with MPX would requires more work. I'm not yet sure what is the
right way to address it.

Also Dave noticed that some test-cases from ltp would break with the
approach. See for instance hugemmap03. I don't think it matter much as it
tests for negative outcome and I don't expect real world application to do
anything like this.

Test-case that I used to test the patch:

	#include <stdio.h>
	#include <sys/mman.h>

	#define SIZE (2UL << 20)
	#define LOW_ADDR ((void *) (1UL << 30))
	#define HIGH_ADDR ((void *) (1UL << 50))

	int main(int argc, char **argv)
	{
		void *p;

		p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
		printf("mmap(NULL): %p\n", p);

		p = mmap(LOW_ADDR, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
		printf("mmap(%p): %p\n", LOW_ADDR, p);

		p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
		printf("mmap(%p): %p\n", HIGH_ADDR, p);

		p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
		printf("mmap(%p) again: %p\n", HIGH_ADDR, p);

		p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
		printf("mmap(%p, MAP_FIXED): %p\n", HIGH_ADDR, p);

		return 0;
	}

------------------------8<---------------------------

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index e7f155c3045e..9c6315d9aa34 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -250,7 +250,7 @@ extern int force_personality32;
    the loader.  We need to make sure that it is out of the way of the program
    that it will "exec", and that there is sufficient room for the brk.  */
 
-#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
+#define ELF_ET_DYN_BASE		(DEFAULT_MAP_WINDOW / 3 * 2)
 
 /* This yields a mask that user programs can use to figure out what
    instruction set this CPU supports.  This could be done in user space,
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index e6cfe7ba2d65..492548c87cb1 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -789,6 +789,7 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
+#define DEFAULT_MAP_WINDOW	TASK_SIZE
 #define STACK_TOP		TASK_SIZE
 #define STACK_TOP_MAX		STACK_TOP
 
@@ -828,7 +829,9 @@ static inline void spin_lock_prefetch(const void *x)
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
+
+#define DEFAULT_MAP_WINDOW	((1UL << 47) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
@@ -841,7 +844,7 @@ static inline void spin_lock_prefetch(const void *x)
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		DEFAULT_MAP_WINDOW
 #define STACK_TOP_MAX		TASK_SIZE_MAX
 
 #define INIT_THREAD  {						\
@@ -863,7 +866,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a55ed63b9f91..7f2e26dca1f2 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -147,7 +147,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = begin;
-	info.high_limit = end;
+	info.high_limit = min(end, DEFAULT_MAP_WINDOW);
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 2ae8584b44c7..e1c2ee098be0 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -82,7 +82,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = current->mm->mmap_legacy_base;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = DEFAULT_MAP_WINDOW;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
@@ -114,7 +114,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = DEFAULT_MAP_WINDOW;
 		addr = vm_unmapped_area(&info);
 	}
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index d2dc0438d654..a29a830ad341 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -52,7 +52,7 @@ static unsigned long stack_maxrandom_size(void)
  * Leave an at least ~128 MB hole with possible stack randomization.
  */
 #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
-#define MAX_GAP (TASK_SIZE/6*5)
+#define MAX_GAP (DEFAULT_MAP_WINDOW/6*5)
 
 static int mmap_is_legacy(void)
 {
@@ -90,7 +90,7 @@ static unsigned long mmap_base(unsigned long rnd)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(DEFAULT_MAP_WINDOW - gap - rnd);
 }
 
 /*
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
