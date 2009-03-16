Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 062326B005D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:23:53 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 03:23:45 +1100
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090316223612.4B2A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170323.45917.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 03:01:42 KOSAKI Motohiro wrote:
> Hi
>

> > AFAIKS, the approach I've posted is probably the simplest (and maybe only
> > way) to really fix it. It's not too ugly.
>
> May I join this discussion?

Of course :)


> if we only need concern to O_DIRECT, below patch is enough.
>
> Yes, my patch isn't realy solusion.
> Andrea already pointed out that it's not O_DIRECT issue, it's gup vs fork
> issue. *and* my patch is crazy slow :)

Well, it's an interesting question. I'd say it probably is more than
just O_DIRECT. vmsplice too, for example (which I think is much harder
to fix this way because the pages are retired by the other end of
the pipe, so I don't think you can hold a lock across it).

For other device drivers, one could argue that they are "special" and
require special knowledge and apps to use MADV_DONTFORK... Ben didn't
like that so much, and also some other users of get_user_pages might
come up.

But your patch is interesting. I don't think it is crazy slow... well
it might be a bit slow in the case that a threaded app doing a lot of
direct IO or an app doing async IO forks. But how common is that?

I would be slightly more worried about the common cacheline touched
to take the read lock for multithreaded direct IO, but I'm not sure
how much that will hurt DB2.


> So, my point is, I merely oppose easily decision to give up fixing.
>
> Currently, I agree we don't have easily fixinig way.
> but I believe we can solve this problem completely in the nealy future
> because LKML folks are very cool guys.
>
> Thus, I don't hope to append the "BUGS" section of the O_DIRECT man page.
> Also I don't hope that I says "Oh, Solaris can solve your requirement,
> AIX can, FreeBSD can, but Linux can't".
> it beat my proud of linux developer a bit ;)
>
> andorea's patch seems a bit complex than your. but I think it can
> improve later.
> but the man page change can't undo.
>
>
> In addition, May I talk about my gup-fast concern?
> AFAIK, the worth of gup-fast is not removing one atomic operation.
> not grabbing mmap_sem is essetial.

Yes, mmap_sem is the big thing. But straight line speed is important
too.

[...]

> ---
>  fs/direct-io.c            |    2 ++
>  include/linux/init_task.h |    1 +
>  include/linux/mm_types.h  |    3 +++
>  kernel/fork.c             |    3 +++
>  4 files changed, 9 insertions(+), 0 deletions(-)

It is an interesting patch. Thanks for throwing it into the discussion.
I do prefer to close the race up for all cases if we decide to do
anything at all about it, ie. all or nothing. But maybe others disagree.


> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index b6d4390..8f9a810 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -1206,8 +1206,10 @@ __blockdev_direct_IO(int rw, struct kiocb
> *iocb, struct inode *inode,
>  	dio->is_async = !is_sync_kiocb(iocb) && !((rw & WRITE) &&
>  		(end > i_size_read(inode)));
>
> +	down_read(&current->mm->directio_sem);
>  	retval = direct_io_worker(rw, iocb, inode, iov, offset,
>  				nr_segs, blkbits, get_block, end_io, dio);
> +	up_read(&current->mm->directio_sem);
>
>  	/*
>  	 * In case of error extending write may have instantiated a few
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index e752d97..68e02b9 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -37,6 +37,7 @@ extern struct fs_struct init_fs;
>  	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
>  	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
>  	.cpu_vm_mask	= CPU_MASK_ALL,				\
> +	.directio_sem	= __RWSEM_INITIALIZER(name.directio_sem), \
>  }
>
>  #define INIT_SIGNALS(sig) {						\
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index d84feb7..39ba4e6 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -274,6 +274,9 @@ struct mm_struct {
>  #ifdef CONFIG_MMU_NOTIFIER
>  	struct mmu_notifier_mm *mmu_notifier_mm;
>  #endif
> +
> +	/* if there are on-flight directio, we can't fork. */
> +	struct rw_semaphore directio_sem;
>  };
>
>  /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 4854c2c..bbe9fa7 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -266,6 +266,7 @@ static int dup_mmap(struct mm_struct *mm, struct
> mm_struct *oldmm)
>  	unsigned long charge;
>  	struct mempolicy *pol;
>
> +	down_write(&oldmm->directio_sem);
>  	down_write(&oldmm->mmap_sem);
>  	flush_cache_dup_mm(oldmm);
>  	/*
> @@ -368,6 +369,7 @@ out:
>  	up_write(&mm->mmap_sem);
>  	flush_tlb_mm(oldmm);
>  	up_write(&oldmm->mmap_sem);
> +	up_write(&oldmm->directio_sem);
>  	return retval;
>  fail_nomem_policy:
>  	kmem_cache_free(vm_area_cachep, tmp);
> @@ -431,6 +433,7 @@ static struct mm_struct * mm_init(struct mm_struct
> * mm, struct task_struct *p)
>  	mm->free_area_cache = TASK_UNMAPPED_BASE;
>  	mm->cached_hole_size = ~0UL;
>  	mm_init_owner(mm, p);
> +	init_rwsem(&mm->directio_sem);
>
>  	if (likely(!mm_alloc_pgd(mm))) {
>  		mm->def_flags = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
