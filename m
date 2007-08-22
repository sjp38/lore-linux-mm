Message-ID: <387773371.00311@ustc.edu.cn>
Date: Wed, 22 Aug 2007 17:02:51 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 3/3] mm: variable length argument support
Message-ID: <20070822090251.GA7038@mail.ustc.edu.cn>
References: <20070613100334.635756997@chello.nl> <20070613100835.014096712@chello.nl> <20070822084852.GA12314@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822084852.GA12314@localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Aloni <da-x@monatomic.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 11:48:52AM +0300, Dan Aloni wrote:
> On Wed, Jun 13, 2007 at 12:03:37PM +0200, Peter Zijlstra wrote:
> > From: Ollie Wild <aaw@google.com>
> > 
> > Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> > from the old mm into the new mm.
> > 
> [...]
> > +static int __bprm_mm_init(struct linux_binprm *bprm)
> > +{
> [...]
> > +	vma->vm_flags = VM_STACK_FLAGS;
> > +	vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
> > +	err = insert_vm_struct(mm, vma);
> > +	if (err) {
> > +		up_write(&mm->mmap_sem);
> > +		goto err;
> > +	}
> > +
> 
> That change causes a crash in khelper when overcommit_memory = 2 
> under 2.6.23-rc3.
> 
> When a khelper execs, at __bprm_mm_init() current->mm is still NULL.
> insert_vm_struct() calls security_vm_enough_memory(), which calls 
> __vm_enough_memory(), and that's where current->mm->total_vm gets 
> dereferenced.
> 
> 
> Signed-off-by: Dan Aloni <da-x@monatomic.org>
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 906ed40..6e021df 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -163,10 +163,12 @@ int __vm_enough_memory(long pages, int cap_sys_admin)
>  	if (!cap_sys_admin)
>  		allowed -= allowed / 32;
>  	allowed += total_swap_pages;
> -
> -	/* Don't let a single process grow too big:
> -	   leave 3% of the size of this process for other processes */
> -	allowed -= current->mm->total_vm / 32;
> +
> +	if (current->mm) {
> +		/* Don't let a single process grow too big:
> +		   leave 3% of the size of this process for other processes */
> +		allowed -= current->mm->total_vm / 32;
> +	}
>  
>  	/*
>  	 * cast `allowed' as a signed long because vm_committed_space
> 

FYI: This bug has been fixed by Alan Cox: http://lkml.org/lkml/2007/8/13/782.

But thanks anyway~

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
