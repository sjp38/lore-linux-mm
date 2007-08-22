From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 3/3] mm: variable length argument support
Date: Wed, 22 Aug 2007 17:02:51 +0800
Message-ID: <20070822090251.GA7038__12739.2433038496$1188144231$gmane$org@mail.ustc.edu.cn>
References: <20070613100334.635756997@chello.nl>
	<20070613100835.014096712@chello.nl>
	<20070822084852.GA12314@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <parisc-linux-bounces@lists.parisc-linux.org>
Message-ID: <20070822090251.GA7038@mail.ustc.edu.cn>
Content-Disposition: inline
In-Reply-To: <20070822084852.GA12314@localdomain>
List-Unsubscribe: <http://lists.parisc-linux.org/mailman/listinfo/parisc-linux>,
	<mailto:parisc-linux-request@lists.parisc-linux.org?subject=unsubscribe>
List-Archive: <http://lists.parisc-linux.org/pipermail/parisc-linux>
List-Post: <mailto:parisc-linux@lists.parisc-linux.org>
List-Help: <mailto:parisc-linux-request@lists.parisc-linux.org?subject=help>
List-Subscribe: <http://lists.parisc-linux.org/mailman/listinfo/parisc-linux>,
	<mailto:parisc-linux-request@lists.parisc-linux.org?subject=subscribe>
Sender: parisc-linux-bounces@lists.parisc-linux.org
Errors-To: parisc-linux-bounces@lists.parisc-linux.org
To: Dan Aloni <da-x@monatomic.org>
Cc: linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, parisc-linux@lists.parisc-linux.org
List-Id: linux-mm.kvack.org

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
