Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CF2A56B004D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:03:26 -0400 (EDT)
Date: Tue, 17 Mar 2009 01:01:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903141620.45052.nickpiggin@yahoo.com.au>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au>
Message-Id: <20090316223612.4B2A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > IB folks so far have been avoiding the fork() trap thanks to
> > madvise(MADV_DONTFORK) afaik. And it all goes generally well when the
> > whole application knows what it's doing and just plain avoids fork.
> >
> > -But- things get nasty if for some reason, the user of gup is somewhere
> > deep in some kind of library that an application uses without knowing,
> > while forking here or there to run shell scripts or other helpers.
> >
> > I've seen it :-)
> >
> > So if a solution can be found that doesn't uglify the whole thing beyond
> > recognition, it's probably worth it.
> 
> AFAIKS, the approach I've posted is probably the simplest (and maybe only
> way) to really fix it. It's not too ugly.

May I join this discussion?

if we only need concern to O_DIRECT, below patch is enough.

Yes, my patch isn't realy solusion.
Andrea already pointed out that it's not O_DIRECT issue, it's gup vs fork issue.
*and* my patch is crazy slow :)

So, my point is, I merely oppose easily decision to give up fixing.

Currently, I agree we don't have easily fixinig way.
but I believe we can solve this problem completely in the nealy future 
because LKML folks are very cool guys.

Thus, I don't hope to append the "BUGS" section of the O_DIRECT man page.
Also I don't hope that I says "Oh, Solaris can solve your requirement,
AIX can, FreeBSD can, but Linux can't".
it beat my proud of linux developer a bit ;)

andorea's patch seems a bit complex than your. but I think it can
improve later.
but the man page change can't undo.


In addition, May I talk about my gup-fast concern?
AFAIK, the worth of gup-fast is not removing one atomic operation.
not grabbing mmap_sem is essetial.

it because:
  - block layer and i/o driver also have several lock.
    then, DirectIO take many atomic operations anyway.
    one atomic operation cost is not so expensive.
  - but mmap_sem is one of most easy contented lock in linux.
    because
    - almost modern DB software have multi threading.
    - glibc malloc/free can cause mmap, munmap, mprotect syscall.
      its syscall grab down_write(&mmap_sem).
    - page fault also grab down_read(&mmap_sem).
    - anyway, userland application can't avoid malloc() and pagefault.

However, I haven't seen anyone try to munmap() to direct-io region.
So, it imply mmap_sem can split out fine grainy.
(or, Can we remove it completely? iirc PerterZ tryed it about two month ago)

after that, we can grab mmap_sem without performace degression and 
many mmap_sem avoiding effort can be removed.

perhaps, I talk funny thing. gup-fast was introduced for solving DB2 problem.
but I don't have any DB2 development experience.

Am I over-optimistic?



> You can't easily fix it at write-time by COWing in the right direction like
> Linus suggested because at that point you may have multiple get_user_pages
> (for read) from the parent and child on the page, so there is no way to COW
> it in the right direction.
> 
> You could do something crazy like allowing only one get_user_pages read on a
> wp page, and recording which direction to send it if it does get COWed. But
> at that point you've got something that's far uglier in the core code and
> more complex than what I posted.





---
 fs/direct-io.c            |    2 ++
 include/linux/init_task.h |    1 +
 include/linux/mm_types.h  |    3 +++
 kernel/fork.c             |    3 +++
 4 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index b6d4390..8f9a810 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -1206,8 +1206,10 @@ __blockdev_direct_IO(int rw, struct kiocb
*iocb, struct inode *inode,
 	dio->is_async = !is_sync_kiocb(iocb) && !((rw & WRITE) &&
 		(end > i_size_read(inode)));

+	down_read(&current->mm->directio_sem);
 	retval = direct_io_worker(rw, iocb, inode, iov, offset,
 				nr_segs, blkbits, get_block, end_io, dio);
+	up_read(&current->mm->directio_sem);

 	/*
 	 * In case of error extending write may have instantiated a few
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index e752d97..68e02b9 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -37,6 +37,7 @@ extern struct fs_struct init_fs;
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
+	.directio_sem	= __RWSEM_INITIALIZER(name.directio_sem), \
 }

 #define INIT_SIGNALS(sig) {						\
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d84feb7..39ba4e6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -274,6 +274,9 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+
+	/* if there are on-flight directio, we can't fork. */
+	struct rw_semaphore directio_sem;
 };

 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4854c2c..bbe9fa7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -266,6 +266,7 @@ static int dup_mmap(struct mm_struct *mm, struct
mm_struct *oldmm)
 	unsigned long charge;
 	struct mempolicy *pol;

+	down_write(&oldmm->directio_sem);
 	down_write(&oldmm->mmap_sem);
 	flush_cache_dup_mm(oldmm);
 	/*
@@ -368,6 +369,7 @@ out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
+	up_write(&oldmm->directio_sem);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
@@ -431,6 +433,7 @@ static struct mm_struct * mm_init(struct mm_struct
* mm, struct task_struct *p)
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_owner(mm, p);
+	init_rwsem(&mm->directio_sem);

 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
-- 
1.6.0.6



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
