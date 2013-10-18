Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9182D6B011C
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 02:05:08 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so4098103pdi.19
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 23:05:08 -0700 (PDT)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id gw3si550199pac.143.2013.10.17.23.05.06
        for <linux-mm@kvack.org>;
        Thu, 17 Oct 2013 23:05:07 -0700 (PDT)
Received: by mail-ee0-f42.google.com with SMTP id b45so1694037eek.1
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 23:05:04 -0700 (PDT)
Date: Fri, 18 Oct 2013 08:05:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 4/3] x86/vdso: Optimize setup_additional_pages()
Message-ID: <20131018060501.GA3411@gmail.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382057438-3306-4-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> --- a/arch/x86/vdso/vma.c
> +++ b/arch/x86/vdso/vma.c
> @@ -154,12 +154,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
>  				  unsigned size)
>  {
>  	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
>  	unsigned long addr;
>  	int ret;
>  
>  	if (!vdso_enabled)
>  		return 0;
>  
> +	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> +	if (unlikely(!vma))
> +		return -ENOMEM;
> +
>  	down_write(&mm->mmap_sem);
>  	addr = vdso_addr(mm->start_stack, size);
>  	addr = get_unmapped_area(NULL, addr, size, 0, 0);
> @@ -173,14 +178,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
>  	ret = install_special_mapping(mm, addr, size,
>  				      VM_READ|VM_EXEC|
>  				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
> -				      pages);
> +				      pages, &vma);
>  	if (ret) {
>  		current->mm->context.vdso = NULL;
>  		goto up_fail;
>  	}
>  
> +	up_write(&mm->mmap_sem);
> +	return ret;
>  up_fail:
>  	up_write(&mm->mmap_sem);
> +	kmem_cache_free(vm_area_cachep, vma);
>  	return ret;
>  }
>  

1)

Beyond the simplification that Linus suggested, why not introduce a new 
function, named 'install_special_mapping_vma()' or so, and convert 
architectures one by one, without pressure to get it all done (and all 
correct) in a single patch?

2)

I don't see the justification: this code gets executed in exec() where a 
new mm has just been allocated. There's only a single user of the mm and 
thus the critical section width of mmap_sem is more or less irrelevant.

mmap_sem critical section size only matters for codepaths that threaded 
programs can hit.

3)

But, if we do all that, a couple of other (micro-)optimizations are 
possible in setup_additional_pages() as well:

 - vdso_addr(), which is actually much _more_ expensive than kmalloc() 
   because on most distros it will call into the RNG, can also be done 
   outside the mmap_sem.

 - the error paths can all be merged and the common case can be made 
   fall-through.

 - use 'mm' consistently instead of repeating 'current->mm'

 - set 'mm->context.vdso' only once we know it's all a success, and do it 
   outside the lock

 - add a few comments about which operations are locked, which unlocked, 
   and why. Please double check the assumptions I documented there.

See the diff attached below. (Totally untested and all that.)

Also note that I think, in theory, if exec() guaranteed the privacy and 
single threadedness of the new mm, we could probably do _all_ of this 
unlocked. Right now I don't think this is guaranteed: ptrace() users might 
look up the new PID and might interfere on the MM via 
PTRACE_PEEK*/PTRACE_POKE*.

( Furthermore, /proc/ might also give early access to aspects of the mm - 
  although no manipulation of the mm is possible there. )

If such privacy of the new mm was guaranteed then that would also remove 
the need to move the allocation out of install_special_mapping().

But, I don't think it all matters, due to #2 - and your changes actively 
complicate setup_pages(), which makes this security sensitive code a bit 
more fragile. We can still do it out of sheer principle, I just don't see 
where it's supposed to help scale better.

Thanks,

	Ingo

 arch/x86/vdso/vma.c | 40 +++++++++++++++++++++++++++-------------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 431e875..c590387 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -157,30 +157,44 @@ static int setup_additional_pages(struct linux_binprm *bprm,
 	unsigned long addr;
 	int ret;
 
-	if (!vdso_enabled)
+	if (unlikely(!vdso_enabled))
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	/*
+	 * Do this outside the MM lock - we are in exec() with a new MM,
+	 * nobody else can use these fields of the mm:
+	 */
 	addr = vdso_addr(mm->start_stack, size);
-	addr = get_unmapped_area(NULL, addr, size, 0, 0);
-	if (IS_ERR_VALUE(addr)) {
-		ret = addr;
-		goto up_fail;
-	}
 
-	current->mm->context.vdso = (void *)addr;
+	/*
+	 * This must be done under the MM lock - there might be parallel
+	 * accesses to this mm, such as ptrace().
+	 *
+	 * [ This could be further optimized if exec() reliably inhibited
+	 *   all early access to the mm. ]
+	 */
+	down_write(&mm->mmap_sem);
+	addr = get_unmapped_area(NULL, addr, size, 0, 0);
+	if (IS_ERR_VALUE(addr))
+		goto up_fail_addr;
 
 	ret = install_special_mapping(mm, addr, size,
 				      VM_READ|VM_EXEC|
 				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 				      pages);
-	if (ret) {
-		current->mm->context.vdso = NULL;
-		goto up_fail;
-	}
+	up_write(&mm->mmap_sem);
+	if (ret)
+		goto fail;
 
-up_fail:
+	mm->context.vdso = (void *)addr;
+	return ret;
+
+up_fail_addr:
+	ret = addr;
 	up_write(&mm->mmap_sem);
+fail:
+	mm->context.vdso = NULL;
+
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
