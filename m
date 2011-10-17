Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C02646B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 07:11:33 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 17 Oct 2011 05:11:32 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9HBBAdi131398
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 05:11:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9HBB7Od014170
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 05:11:10 -0600
Date: Mon, 17 Oct 2011 16:20:54 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/X] uprobes: reimplement xol_add_vma() via
 install_special_mapping()
Message-ID: <20111017105054.GC11831@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20111015190007.GA30243@redhat.com>
 <20111016161359.GA24893@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111016161359.GA24893@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Eric Paris <eparis@parisplace.org>, Stephen Smalley <sds@tycho.nsa.gov>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

> I apologize in advance if this was already discussed, but I just can't
> understand why xol_add_vma() does not use install_special_mapping().
> Unless I missed something this should work and this has the following
> advantages:


The override_creds was based on what Stephen Smalley suggested 
https://lkml.org/lkml/2011/4/20/224    

At that time Peter had suggested install_special_mapping(). However the
consensus was to go with Stephen's suggestion of override_creds.

> 
> 	- we can avoid override_creds() hacks, install_special_mapping()
> 	  fools security_file_mmap() passing prot/flags = 0
> 
> 	- no need to play with vma after do_mmap_pgoff()
> 
> 	- no need for get_user_pages(FOLL_WRITE/FOLL_FORCE) hack
> 
> 	- no need for do_munmap() if get_user_pages() fails
> 
> 	- this protects us from mprotect(READ/WRITE)
> 
> 	- this protects from MADV_DONTNEED, the page will be correctly
> 	  re-instantiated from area->page
> 
> 	- this makes xol_vma more "cheap", swapper can't see this page
> 	  and we avoid the meaningless add_to_swap/pageout.
> 
> 	  Note that, before this patch, area->page can't be removed
> 	  from the swap cache anyway (we have the reference). And it
> 	  must not, uprobes modifies this page directly.

Stephan, Eric, 

Would you agree with Oleg's observation that we would be better off
using install_special_mapping rather than using override_creds.

To give you some more information about the problem.

Uprobes will be a in-kernel debugging facility that provides
singlestepping out of line. To achieve this, it will create a per-mm vma
which is not mapped to any file. However this vma has to be executable.

Slots are made in this executable vma, and one slot can be used to
single step a original instruction.

This executable vma that we are creating is not for any particular
binary but would have to be created dynamically as and when an
application is debugged. For example, if we were to debug malloc call in
libc, we would end up adding xol vma to all the live processes in the
system.

Since selinux wasnt happy to have an anonymous vma attached, we would
create a pseudo file using shmem_file_setup. However after comments from
Peter and Stephan's suggestions we started using override_creds. Peter and
Oleg suggest that we use install_special_mapping. 

Are you okay with using install_special_mapping instead of
override_creds()?

-- 
Thanks and Regards
Srikar


> 
> Note on vm_flags:
> 
> 	- we do not use VM_DONTEXPAND, install_special_mapping() adds it
> 
> 	- VM_IO protects from MADV_DOFORK
> 
> 	- I am not sure, may be some archs need VM_READ along with EXEC?
> 
> Anything else I have missed?
> ---
> 
>  kernel/uprobes.c |   42 +++++++++++++++++++-----------------------
>  1 files changed, 19 insertions(+), 23 deletions(-)
> 
> diff --git a/kernel/uprobes.c b/kernel/uprobes.c
> index b59af3b..038f21c 100644
> --- a/kernel/uprobes.c
> +++ b/kernel/uprobes.c
> @@ -1045,53 +1045,49 @@ void munmap_uprobe(struct vm_area_struct *vma)
>  /* Slot allocation for XOL */
>  static int xol_add_vma(struct uprobes_xol_area *area)
>  {
> -	const struct cred *curr_cred;
>  	struct vm_area_struct *vma;
>  	struct mm_struct *mm;
> -	unsigned long addr;
> +	unsigned long addr_hint;
>  	int ret;
> 
> +	area->page = alloc_page(GFP_HIGHUSER);
> +	if (!area->page)
> +		return -ENOMEM;
> +
>  	mm = current->mm;
> 
>  	down_write(&mm->mmap_sem);
>  	ret = -EALREADY;
>  	if (mm->uprobes_xol_area)
>  		goto fail;
> -
> -	ret = -ENOMEM;
>  	/*
>  	 * Find the end of the top mapping and skip a page.
> -	 * If there is no space for PAGE_SIZE above
> -	 * that, mmap will ignore our address hint.
> -	 *
> -	 * override credentials otherwise anonymous memory might
> -	 * not be granted execute permission when the selinux
> -	 * security hooks have their way.
> +	 * If there is no space for PAGE_SIZE above that,
> +	 * this hint will be ignored.
>  	 */
>  	vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
> -	addr = vma->vm_end + PAGE_SIZE;
> -	curr_cred = override_creds(&init_cred);
> -	addr = do_mmap_pgoff(NULL, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
> -	revert_creds(curr_cred);
> +	addr_hint = vma->vm_end + PAGE_SIZE;
> 
> -	if (IS_ERR_VALUE(addr))
> +	area->vaddr = get_unmapped_area(NULL, addr_hint, PAGE_SIZE, 0, 0);
> +	if (IS_ERR_VALUE(area->vaddr)) {
> +		ret = area->vaddr;
>  		goto fail;
> +	}
> 
> -	vma = find_vma(mm, addr);
> -	/* Don't expand vma on mremap(). */
> -	vma->vm_flags |= VM_DONTEXPAND | VM_DONTCOPY;
> -	if (get_user_pages(current, mm, addr, 1, 1, 1,
> -					&area->page, NULL) != 1) {
> -		do_munmap(mm, addr, PAGE_SIZE);
> +	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
> +					VM_EXEC|VM_MAYEXEC | VM_DONTCOPY|VM_IO,
> +					&area->page);
> +	if (ret)
>  		goto fail;
> -	}
> 
> -	area->vaddr = addr;
>  	smp_wmb();	/* pairs with get_uprobes_xol_area() */
>  	mm->uprobes_xol_area = area;
>  	ret = 0;
>  fail:
>  	up_write(&mm->mmap_sem);
> +	if (ret)
> +		__free_page(area->page);
> +
>  	return ret;
>  }
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
