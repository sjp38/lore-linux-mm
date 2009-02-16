Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 018086B0088
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 09:32:38 -0500 (EST)
Date: Mon, 16 Feb 2009 14:32:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] fix vmaccnt at fork (Was Re: "heuristic overcommit"
	and fork())
Message-ID: <20090216143231.GB16153@csn.ul.ie>
References: <ED3886372DB5491AAA799709DBA78F6F@david> <20090213103655.3a0ea204.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090213103655.3a0ea204.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, David CHAMPELOVIER <david@champelovier.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 13, 2009 at 10:36:55AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 11 Feb 2009 20:26:32 +0100
> "David CHAMPELOVIER" <david@champelovier.com> wrote:
> 
> > Hi,
> > 
> > Recently, I was unable to fork() a 38 GB process on a system with 64 GB RAM
> > and no swap.
> > Having a look at the kernel source, I surprisingly found that in "heuristic
> > overcommit" mode, fork() always checks that there is enough memory to
> > duplicate process memory.
> > 
> > As far as I know, overcommit was introduced in the kernel for several
> > reasons, and fork() was one of them, since applications often exec() just
> > after fork(). I know fork() is not the most judicious choice in this case,
> > but well, this is the way many applications are written.
> > 
> > Moreover, I can read in the proc man page that in "heuristic overcommit
> > mode", "obvious overcommits of address space are refused". I do not think
> > fork() is an obvious overcommit, that's why I would expect fork() to be
> > always accepted in this mode.
> > 
> > So, is there a reason why fork() checks for available memory in "heuristic
> > mode" ?
> > 
> 
> fork() is used for duplicate process and it means to duplicate memory space.
> Because of Copy-On-Write, the page will not be used acutally. But, it's not
> different from mmap() case.

Pretty much. At fork() time, you cannot know if the process is going to
exec or not.

> In that case, overcommit_guess compares
> requested size and size of free memory for all that we use demand paging.
> So, the behavior is not surprizing.  For notifing the kernel can assume
> exec-is-called-after-fork, we may need some flags or paramater.
> 

There already is one of sorts. Use madvise(MADV_DONTFORK) on the large
memory regions so they don't get copied. If that doesn't work, it means
the accounting for the VMAs is being done in the wrong order.

> But, hmm.., there is something strange, following. Mel, how do you think ?
> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Vm accounting at fork() should use the same logic as mmap().
> 

This alters semantics in a fairly subtle manner and I think would break
counters as well.

accountable_mapping() is used to determine if VM_ACCOUNT is set or
not. Once set, it gets accounted after that. even if the overcommit settings
change. Somewhat weirdly, the overcommit decisions at the time of mmap()
are reused at fork() even if the overcommit settings change.  This is odd
behaviour and arguably your patch could fix this anomoly. However, it
would make more sense to me to recalculate if VM_ACCOUNT should be set
or not rather than what you do here.

I think this patch also has subtle breakage. We could do something like;

1. mmap(), VM_ACCOUNT not set due to overcommit settings
2. overcommit set to strict
3. fork()
4. check flags, note that VM_ACCOUNT would have been used, account but
   VM_ACCOUNT is still not set
5. child exits, VM_ACCOUNT not set so reserves are not given back

So reserves can constantly go up and never down. It would require root but
a bad program could eventually push the reserves up to the size of physical
memory without any of the memory actually being used.


> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/mm.h |    2 ++
>  kernel/fork.c      |    3 ++-
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> Index: mmotm-2.6.29-Feb11/kernel/fork.c
> ===================================================================
> --- mmotm-2.6.29-Feb11.orig/kernel/fork.c
> +++ mmotm-2.6.29-Feb11/kernel/fork.c
> @@ -301,7 +301,8 @@ static int dup_mmap(struct mm_struct *mm
>  			continue;
>  		}
>  		charge = 0;
> -		if (mpnt->vm_flags & VM_ACCOUNT) {
> +		if (accountable_mapping(mpnt->vm_file, mpnt->vm_flags) &&
> +			mpnt->vm_flags & VM_ACCOUNT) {
>  			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
>  			if (security_vm_enough_memory(len))
>  				goto fail_nomem;
> Index: mmotm-2.6.29-Feb11/include/linux/mm.h
> ===================================================================
> --- mmotm-2.6.29-Feb11.orig/include/linux/mm.h
> +++ mmotm-2.6.29-Feb11/include/linux/mm.h
> @@ -1047,6 +1047,8 @@ extern void free_bootmem_with_active_reg
>  typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
>  extern void work_with_active_regions(int nid, work_fn_t work_fn, void *data);
>  extern void sparse_memory_present_with_active_regions(int nid);
> +extern int accountable_mapping(struct file *file, unsigned int vmflags);
> +

accountable_mapping() is a static inline in mm/mmap.c so I'd be
surprised if this compiles.

>  #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
>  
>  #if !defined(CONFIG_ARCH_POPULATES_NODE_MAP) && \
> 
> 

NAK.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
