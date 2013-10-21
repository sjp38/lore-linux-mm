Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 145D66B02F8
	for <linux-mm@kvack.org>; Sun, 20 Oct 2013 23:52:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7410505pad.0
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 20:52:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.197])
        by mx.google.com with SMTP id ar2si7375749pbc.82.2013.10.20.20.52.52
        for <linux-mm@kvack.org>;
        Sun, 20 Oct 2013 20:52:53 -0700 (PDT)
Message-ID: <1382327556.2402.23.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 4/3] x86/vdso: Optimize setup_additional_pages()
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 20 Oct 2013 20:52:36 -0700
In-Reply-To: <20131018060501.GA3411@gmail.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
	 <20131018060501.GA3411@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

Hi Ingo,

On Fri, 2013-10-18 at 08:05 +0200, Ingo Molnar wrote:
> * Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > --- a/arch/x86/vdso/vma.c
> > +++ b/arch/x86/vdso/vma.c
> > @@ -154,12 +154,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
> >  				  unsigned size)
> >  {
> >  	struct mm_struct *mm = current->mm;
> > +	struct vm_area_struct *vma;
> >  	unsigned long addr;
> >  	int ret;
> >  
> >  	if (!vdso_enabled)
> >  		return 0;
> >  
> > +	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> > +	if (unlikely(!vma))
> > +		return -ENOMEM;
> > +
> >  	down_write(&mm->mmap_sem);
> >  	addr = vdso_addr(mm->start_stack, size);
> >  	addr = get_unmapped_area(NULL, addr, size, 0, 0);
> > @@ -173,14 +178,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
> >  	ret = install_special_mapping(mm, addr, size,
> >  				      VM_READ|VM_EXEC|
> >  				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
> > -				      pages);
> > +				      pages, &vma);
> >  	if (ret) {
> >  		current->mm->context.vdso = NULL;
> >  		goto up_fail;
> >  	}
> >  
> > +	up_write(&mm->mmap_sem);
> > +	return ret;
> >  up_fail:
> >  	up_write(&mm->mmap_sem);
> > +	kmem_cache_free(vm_area_cachep, vma);
> >  	return ret;
> >  }
> >  
> 
> 1)
> 
> Beyond the simplification that Linus suggested, why not introduce a new 
> function, named 'install_special_mapping_vma()' or so, and convert 
> architectures one by one, without pressure to get it all done (and all 
> correct) in a single patch?
> 

Hmm I'd normally take this approach but updating the callers from all
architectures was so straightforward and monotonous that I think it's
easier to just do it all at once. Andrew had suggested using linux-next
for testing, so if some arch breaks (in the not-compiling sense), the
maintainer or I can easily address the issue.

> 2)
> 
> I don't see the justification: this code gets executed in exec() where a 
> new mm has just been allocated. There's only a single user of the mm and 
> thus the critical section width of mmap_sem is more or less irrelevant.
> 
> mmap_sem critical section size only matters for codepaths that threaded 
> programs can hit.
> 

Yes, I was surprised by the performance boost I noticed when running
this patch. This weekend I re-ran the tests (including your 4/3 patch)
and noticed that while we're still getting some benefits (more like in
the +5% throughput range), it's not as good as I originally reported. I
believe the reason is because I had ran the tests on the vanilla kernel
without the max clock frequency, so the comparison was obviously not
fair. That said, I still think it's worth adding this patch, as it does
help at a micro-optimization level, and it's one less mmap_sem user we
have to worry about.

> 3)
> 
> But, if we do all that, a couple of other (micro-)optimizations are 
> possible in setup_additional_pages() as well:

I've rebased your patch on top of mine and things ran fine over the
weekend, didn't notice anything unusual - see below. I've *not* added
your SoB tag, so if you think it's good to go, please go ahead and add
it.

> 
>  - vdso_addr(), which is actually much _more_ expensive than kmalloc() 
>    because on most distros it will call into the RNG, can also be done 
>    outside the mmap_sem.
> 
>  - the error paths can all be merged and the common case can be made 
>    fall-through.
> 
>  - use 'mm' consistently instead of repeating 'current->mm'
> 
>  - set 'mm->context.vdso' only once we know it's all a success, and do it 
>    outside the lock
> 
>  - add a few comments about which operations are locked, which unlocked, 
>    and why. Please double check the assumptions I documented there.
> 
> See the diff attached below. (Totally untested and all that.)
> 
> Also note that I think, in theory, if exec() guaranteed the privacy and 
> single threadedness of the new mm, we could probably do _all_ of this 
> unlocked. Right now I don't think this is guaranteed: ptrace() users might 
> look up the new PID and might interfere on the MM via 
> PTRACE_PEEK*/PTRACE_POKE*.
> 
> ( Furthermore, /proc/ might also give early access to aspects of the mm - 
>   although no manipulation of the mm is possible there. )

I was not aware of this, thanks for going into more details.

> 
> If such privacy of the new mm was guaranteed then that would also remove 
> the need to move the allocation out of install_special_mapping().
> 
> But, I don't think it all matters, due to #2 - and your changes actively 
> complicate setup_pages(), which makes this security sensitive code a bit 
> more fragile. We can still do it out of sheer principle, I just don't see 
> where it's supposed to help scale better.

I think that trying to guarantee new mm privacy would actually
complicate things much more than this patch, which is quite simple. And,
as you imply, it's not worthwhile for these code paths.

Thanks,
Davidlohr

8<------------------------------------------
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 4/3] x86/vdso: Optimize setup_additional_pages()

(micro-)optimizations are possible in setup_additional_pages() as well:

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

[rebased on top of "vdso: preallocate new vmas" patch]
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 arch/x86/vdso/vma.c | 39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index fc189de..5af8597 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -158,36 +158,47 @@ static int setup_additional_pages(struct linux_binprm *bprm,
 	unsigned long addr;
 	int ret;
 
-	if (!vdso_enabled)
+	if (unlikely(!vdso_enabled))
 		return 0;
 
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (unlikely(!vma))
 		return -ENOMEM;
 
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
 				      pages, vma);
-	if (ret) {
-		current->mm->context.vdso = NULL;
-		goto up_fail;
-	}
-
 	up_write(&mm->mmap_sem);
+	if (ret)
+		goto fail;
+
+	mm->context.vdso = (void *)addr;
 	return ret;
-up_fail:
+
+up_fail_addr:
+	ret = addr;
 	up_write(&mm->mmap_sem);
+fail:
+	mm->context.vdso = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
