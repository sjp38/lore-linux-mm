Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 515506B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 12:43:15 -0400 (EDT)
Received: by mail-oi0-f50.google.com with SMTP id u20so6797599oif.23
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 09:43:15 -0700 (PDT)
Received: from mail-pd0-x24a.google.com (mail-pd0-x24a.google.com [2607:f8b0:400e:c02::24a])
        by mx.google.com with ESMTPS id rj1si4447504pbc.228.2014.09.04.09.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 09:43:14 -0700 (PDT)
Received: by mail-pd0-f202.google.com with SMTP id w10so1958349pde.3
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 09:43:13 -0700 (PDT)
Date: Thu, 4 Sep 2014 09:43:11 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140904164311.GA29610@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Mon, Aug 25, 2014 at 09:45:34PM -0700, Hugh Dickins wrote:
> On Sun, 24 Aug 2014, Peter Feiner wrote:
> > With this patch, write notifications are enabled when VM_SOFTDIRTY is
> > cleared. Furthermore, to avoid unnecessary faults, write
> > notifications are disabled when VM_SOFTDIRTY is reset.
> 
> "reset" is often a synonym for "cleared": "whenever VM_SOFTDIRTY is set"?

Agreed, "set" sounds good.

> > As a side effect of enabling and disabling write notifications with
> > care, this patch fixes a bug in mprotect where vm_page_prot bits set
> > by drivers were zapped on mprotect. An analogous bug was fixed in mmap
> > by c9d0bf241451a3ab7d02e1652c22b80cd7d93e8f.
> 
> 
> Commit c9d0bf241451 ("mm: uncached vma support with writenotify").
> Adding Magnus to the Cc list: I have some doubt as to whether his
> bugfix is in fact preserved below, and would like him to check.

I believe the fix is preserved as long as pgprot_modify preserves cache flags.
As you explain below, pgprot_modify only does this on x86 and tile. So this
patch does indeed break c9d0bf241451 on most architectures. Furthermore, as you
said below, this patch would break the build on the other architectures :-)

> I like Kirill's suggestion to approach this via writenotify,
> but find the disable/enable rather confusing (partly because
> enabling writenotify amounts to disabling write access).
> I may be alone in my confusion.

I agree about the confusion. I wasn't too happy with the names myself.
Furthermore, I only really use vma_disable_writenotify to set vm_page_prot
from vm_flags. So I think the enable / disable idea is pretty broken. As you
suggest below, I'm going to give vma_set_page_prot a try.

> > +		if (type == CLEAR_REFS_SOFT_DIRTY &&
> > +		    (vma->vm_flags & VM_SOFTDIRTY)) {
> > +			if (!write) {
> > +				r = -EAGAIN;
> > +				break;
> 
> Hmm.  For a long time I thought you were fixing another important bug
> with down_write, since we "always" use down_write to modify vm_flags.
> 
> But now I'm realizing that if this is the _only_ place which modifies
> vm_flags with down_read, then it's "probably" safe.  I've a vague
> feeling that this was discussed before - is that so, Cyrill?
> 
> It certainly feels fragile to depend on this; but conversely, I don't
> like replacing a long down_read scan by an indefinite down_read scan
> followed by a long down_write scan.
> 
> I see that you earlier persuaded yourself that the races are benign
> if you stick with down_read.  I can't confirm or deny that at present:
> seems more important right now to get this mail out to you than think
> through that aspect.

Your observation is correct: clear_refs_write is the only place that vm_flags
is modified without an exclusive lock on mmap_sem.

I was wrong about the race between clear_refs_write modifying vm_flags and the
fault handler reading vm_flags being benign. I had thought that since
clear_refs_write zaps all of the PTEs in the VMA after it modifies vm_flags,
it was ok for a writable PTE to be temporarily installed to handle a read
fault. However, if a write happened after the read fault and before
clear_refs_write zapped the PTE, then we'd miss the write. Therefore I'm
convinced that its necessary to serialize changes to vm_flags and fault
handling.

There are a few ways to accomplish this serialization, all with their pros and
cons:

	* One down_read scan followed by a down_write scan, if necessary. This
	  is the current implementation.
	  Pros: won't take exclusive lock when VMAs haven't changed.
	  Cons: might hold exclusive lock during page table walk.

	* Per-vma lock, as Cyrill and Kirill were discussing.
	  Pros: handle faults on other VMAs when vm_flags is changing.
	  Cons: another lock acquired in fault path.
	
	* Iterate over VMAs and modify vm_flags with down_write, then
	  downgrade to down_read for page table scan, as Kirill suggested.
	  Pros: won't hold exclusive lock during page table walk.
	  Cons: clear_refs_write always grabs exclusive lock.

I think the extra lock in the fault handling path rules the per-vma lock out.
Whether the first or third approach is better depends on whether or not VMAs
are changing, which is obviously application specific behavior. A hybrid
approach offers the best of both worlds (i.e., an optimistic down_read scan
that bails out if there's a VM_SOFTDIRTY VMA and falls back to the downgrading
approach).

> 
> > +			}
> > +			vma->vm_flags &= ~VM_SOFTDIRTY;
> > +			vma_enable_writenotify(vma);
> 
> That's an example of how the vma_enable_writenotify() interface
> may be confusing.  I thought for a while that that line was unsafe,
> there being quite other reasons why write protection may be needed;
> then realized it's okay because "enable" is the restrictive one.

Yep, agreed. It'll look like

	vma->vm_flags &= ~VM_SOFTDIRTY;
	vma_set_page_prot(vma);

after implementing your suggestion.

> 
> > +		}
> > +		walk_page_range(vma->vm_start, vma->vm_end,
> > +				&clear_refs_walk);
> > +	}
> > +
> > +	if (type == CLEAR_REFS_SOFT_DIRTY)
> > +		mmu_notifier_invalidate_range_end(mm, 0, -1);
> > +
> > +	if (!r)
> > +		flush_tlb_mm(mm);
> > +
> > +	if (write)
> > +		up_write(&mm->mmap_sem);
> > +	else
> > +		up_read(&mm->mmap_sem);
> > +
> > +	return r;
> > +}
> > +
> >  static ssize_t clear_refs_write(struct file *file, const char __user *buf,
> >  				size_t count, loff_t *ppos)
> >  {
> >  	struct task_struct *task;
> >  	char buffer[PROC_NUMBUF];
> >  	struct mm_struct *mm;
> > -	struct vm_area_struct *vma;
> >  	enum clear_refs_types type;
> >  	int itype;
> >  	int rv;
> > @@ -820,47 +887,9 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
> >  		return -ESRCH;
> >  	mm = get_task_mm(task);
> >  	if (mm) {
> > -		struct clear_refs_private cp = {
> > -			.type = type,
> > -		};
> > -		struct mm_walk clear_refs_walk = {
> > -			.pmd_entry = clear_refs_pte_range,
> > -			.mm = mm,
> > -			.private = &cp,
> > -		};
> > -		down_read(&mm->mmap_sem);
> > -		if (type == CLEAR_REFS_SOFT_DIRTY)
> > -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> > -		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > -			cp.vma = vma;
> > -			if (is_vm_hugetlb_page(vma))
> > -				continue;
> > -			/*
> > -			 * Writing 1 to /proc/pid/clear_refs affects all pages.
> > -			 *
> > -			 * Writing 2 to /proc/pid/clear_refs only affects
> > -			 * Anonymous pages.
> > -			 *
> > -			 * Writing 3 to /proc/pid/clear_refs only affects file
> > -			 * mapped pages.
> > -			 *
> > -			 * Writing 4 to /proc/pid/clear_refs affects all pages.
> > -			 */
> > -			if (type == CLEAR_REFS_ANON && vma->vm_file)
> > -				continue;
> > -			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> > -				continue;
> > -			if (type == CLEAR_REFS_SOFT_DIRTY) {
> > -				if (vma->vm_flags & VM_SOFTDIRTY)
> > -					vma->vm_flags &= ~VM_SOFTDIRTY;
> > -			}
> > -			walk_page_range(vma->vm_start, vma->vm_end,
> > -					&clear_refs_walk);
> > -		}
> > -		if (type == CLEAR_REFS_SOFT_DIRTY)
> > -			mmu_notifier_invalidate_range_end(mm, 0, -1);
> > -		flush_tlb_mm(mm);
> > -		up_read(&mm->mmap_sem);
> > +		rv = clear_refs(mm, type, 0);
> > +		if (rv)
> > +			clear_refs(mm, type, 1);
> >  		mmput(mm);
> >  	}
> >  	put_task_struct(task);
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 8981cc8..7979b79 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1946,6 +1946,20 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
> >  }
> >  #endif
> >  
> > +/* Enable write notifications without blowing away special flags. */
> > +static inline void vma_enable_writenotify(struct vm_area_struct *vma)
> > +{
> > +	pgprot_t newprot = vm_get_page_prot(vma->vm_flags & ~VM_SHARED);
> > +	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot, newprot);
> > +}
> > +
> > +/* Disable write notifications without blowing away special flags. */
> > +static inline void vma_disable_writenotify(struct vm_area_struct *vma)
> > +{
> > +	pgprot_t newprot = vm_get_page_prot(vma->vm_flags);
> > +	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot, newprot);
> > +}
> 
> As mentioned above, I find that enable and disable confusing.
> Might it be better just to have a vma_set_page_prot(vma), which does
> the "if vma_wants_writenotify(vma) blah; else blah;" internally?

I like that idea. I'll think it through and give it a try.

> And does what you have there build on any architecture other than
> x86 and tile?  Because pgprot_modify() was only used in mm/mprotect.c
> before, we declare the fallback version there, and so far as I can see,
> only x86 and tile declare the pgprot_modify() they need in a header file.
> 
> > +
> >  #ifdef CONFIG_NUMA_BALANCING
> >  unsigned long change_prot_numa(struct vm_area_struct *vma,
> >  			unsigned long start, unsigned long end);
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index c1f2ea4..2963130 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1470,6 +1470,10 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
> >  	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
> >  		return 1;
> >  
> > +	/* Do we need to track softdirty? */
> > +	if (IS_ENABLED(CONFIG_MEM_SOFT_DIRTY) && !(vm_flags & VM_SOFTDIRTY))
> > +		return 1;
> > +
> >  	/* The open routine did something to the protections already? */
> >  	if (pgprot_val(vma->vm_page_prot) !=
> >  	    pgprot_val(vm_get_page_prot(vm_flags)))
> 
> That sets me wondering: have you placed the VM_SOFTDIRTY check in the
> right place in this series of tests?
> 
> I think, once pgprot_modify() is correct on all architectures,
> it should be possible to drop that pgprot_val() check from
> vma_wants_writenotify() - which would be a welcome simplification.
> 
> But what about the VM_PFNMAP test below it?  If that test was necessary,
> then having your VM_SOFTDIRTY check before it seems dangerous.  But I'm
> hoping we can persuade ourselves that the VM_PFNMAP test was unnecessary,
> and simply delete it.

If VM_PFNMAP is necessary, then I definitely put the VM_SOFTDIRTY check in the
wrong spot :-) I don't know much (i.e., anything) about VM_PFNMAP, so I'll
have to bone up on a lot of code before I have an informed opinion about the
necessity of the check.

I had erroneously reasoned that it was necessary to put the VM_SOFTDIRTY check
before the pgprot_val check in order to handle VMA merging correctly. I'll
give this another think and look into dropping the pgprot_val check altogether,
as you suggest.

> 
> > @@ -1610,21 +1614,6 @@ munmap_back:
> >  			goto free_vma;
> >  	}
> >  
> > -	if (vma_wants_writenotify(vma)) {
> > -		pgprot_t pprot = vma->vm_page_prot;
> > -
> > -		/* Can vma->vm_page_prot have changed??
> > -		 *
> > -		 * Answer: Yes, drivers may have changed it in their
> > -		 *         f_op->mmap method.
> > -		 *
> > -		 * Ensures that vmas marked as uncached stay that way.
> > -		 */
> > -		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
> > -		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
> > -			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> 
> So, this is where Magnus's bugfix gets deleted: but I'm afraid that
> with pgprot_modify() properly implemented only on x86 and tile, we
> cannot delete this so easily.
> 
> It's going to be tedious and error-prone to devise a proper
> pgprot_modify() for each of N unfamiliar architectures.  I wonder
> if we can take a hint from Magnus's code there, to get a suitable
> default going, which may not be perfect for each, but will avoid
> introducing regression.
> 
> Or am I simply confused about the lack of proper pgprot_modify()s?

No, I think you're right about pgprot_modify. I like your idea for
a best-effort implementation of a generic pgprot_modify. I'll give it a try
and see if everything fits together nicely for VM_SOFTDIRTY.

> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index c43d557..2dea043 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -320,12 +320,12 @@ success:
> >  	 * held in write mode.
> >  	 */
> >  	vma->vm_flags = newflags;
> > -	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> > -					  vm_get_page_prot(newflags));
> >  
> >  	if (vma_wants_writenotify(vma)) {
> > -		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
> > +		vma_enable_writenotify(vma);
> >  		dirty_accountable = 1;
> 
> Not an issue coming from your patch, but please take a look at how
> dirty_accountable gets used in change_pte_range(): I suspect we have a
> similar soft-dirty bug there, do you agree?  Or does it work out safely?

Indeed, there is a similar bug in change_pte_range. If a PTE is dirty but not
soft-dirty and dirty_accountable is true, then the PTE will be made writable
and we'll never get to mark the PTE softdirty. Good catch! I'll submit another
patch to fix this.

> scripts/checkpatch.pl has a few complaints too.  Personally, I like
> to make very simple functions as brief as possible, ignoring the rule
> about a blank line between declarations and body.  So I like your style,
> but others will disagree: I suppose we should bow to checkpatch there.

Aye, I shall bend the knee.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
