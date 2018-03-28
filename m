Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 352D56B000A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:26:51 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id i39so2246531iod.12
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:26:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l191-v6si2683209itl.125.2018.03.28.05.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 05:26:49 -0700 (PDT)
Subject: Re: [PATCH] mm: Introduce i_mmap_lock_write_killable().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180327145220.GJ5652@dhcp22.suse.cz>
	<201803281923.EFF26009.OFOtJSMFHQFLVO@I-love.SAKURA.ne.jp>
	<20180328110513.GH9275@dhcp22.suse.cz>
In-Reply-To: <20180328110513.GH9275@dhcp22.suse.cz>
Message-Id: <201803282126.GBC56799.tOFVFSOHJLFOQM@I-love.SAKURA.ne.jp>
Date: Wed, 28 Mar 2018 21:26:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com

Michal Hocko wrote:
> > > I am not saying this is wrong, I would have to think about that much
> > > more because mmap_sem tends to be used on many surprising places and the
> > > write lock just hide them all.
> > 
> > Then, an alternative approach which interrupts without downgrading is shown
> > below. But I'm not sure.
> 
> Failing the whole dup_mmap might be quite reasonable, yes. I haven't
> checked your particular patch because this code path needs much more
> time than I can give this, though.

I think that interrupting at

diff --git a/kernel/fork.c b/kernel/fork.c
index 1e8c9a7..851c675 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -514,6 +514,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
 
+		if (!retval && fatal_signal_pending(current))
+			retval = -EINTR;
+
 		if (retval)
 			goto out;
 	}
-- 

is safe because there is no difference (except the error code) between above
change and hitting "goto fail_nomem;" path after "mpnt = mpnt->vm_next;".

Therefore, I think that interrupting at

diff --git a/kernel/fork.c b/kernel/fork.c
index 851c675..2706acc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -508,7 +508,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		if (!(tmp->vm_flags & VM_WIPEONFORK))
+		if (fatal_signal_pending(current))
+			retval = -EINTR;
+		else if (!(tmp->vm_flags & VM_WIPEONFORK))
 			retval = copy_page_range(mm, oldmm, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
-- 

is also safe because handling of copy_page_range() failure is already
scheduled by mmput().

Thus, I think that there are locations where it is known to be safely and consistently
interruptible inside "for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next)" loop.

> On Wed 28-03-18 19:23:20, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 27-03-18 20:19:30, Tetsuo Handa wrote:
> > > > If the OOM victim is holding mm->mmap_sem held for write, and if the OOM
> > > > victim can interrupt operations which need mm->mmap_sem held for write,
> > > > we can downgrade mm->mmap_sem upon SIGKILL and the OOM reaper will be
> > > > able to reap the OOM victim's memory.
> > > 
> > > This really begs for much better explanation. Why is it safe?
> > 
> > Basic idea is
> > 
> >   bool downgraded = false;
> >   down_write(mmap_sem);
> >   for (something_1_that_might_depend_mmap_sem_held_for_write;
> >        something_2_that_might_depend_mmap_sem_held_for_write;
> >        something_3_that_might_depend_mmap_sem_held_for_write) {
> >      something_4_that_might_depend_mmap_sem_held_for_write();
> >      if (fatal_signal_pending(current)) {
> >         downgrade_write(mmap_sem);
> >         downgraded = true;
> >         break;
> >      }
> >      something_5_that_might_depend_mmap_sem_held_for_write();
> >   }
> >   if (!downgraded)
> >     up_write(mmap_sem);
> >   else
> >     up_read(mmap_sem);
> > 
> > . That is, try to interrupt critical sections at locations where it is
> > known to be safe and consistent.
> 
> Please explain why those places are safe to interrupt.

Because (regarding the downgrade_write() approach), as far as I know,
the current thread does not access memory which needs to be protected with
mmap_sem held for write.

> 
> > >                                                               Are you
> > > assuming that the killed task will not perform any changes on the
> > > address space?
> > 
> > If somebody drops mmap_sem held for write is not safe, how can the OOM
> > reaper work safely?
> > 
> > The OOM reaper is assuming that the thread who got mmap_sem held for write
> > is responsible to complete critical sections before dropping mmap_sem held
> > for write, isn't it?
> > 
> > Then, how an attempt to perform changes on the address space can become a
> > problem given that the thread who got mmap_sem held for write is responsible
> > to complete critical sections before dropping mmap_sem held for write?
> 
> ENOPARSE. How does this have anything to do with oom_reaper.

The oom_reaper can work safely as long as mmap_sem held for write is released
at safely and consistently interruptible locations.

>                                                              Sure you
> want to _help_ the oom_reaper to do its job but you are dropping the
> lock in the downgrading the lock in the middle of dup_mmap and that is
> what we are dicussing here.

Yes.

>                             So please explain why it is safe. It is
> really not straightforward.

So, please explain why it is not safe. How can releasing mmap_sem held for
write at safely and consistently interruptible locations be not safe?

> 
> > >                What about ongoing page faults or other operations deeper
> > > in the call chain.
> > 
> > Even if there are ongoing page faults or other operations deeper in the call
> > chain, there should be no problem as long as the thread who got mmap_sem
> > held for write is responsible to complete critical sections before dropping
> > mmap_sem held for write.
> > 
> > >                    Why they are safe to change things for the child
> > > during the copy?
> > 
> > In this patch, the current thread who got mmap_sem held for write (which is
> > likely an OOM victim thread) downgrades mmap_sem, with an assumption that
> > current thread no longer accesses memory which might depend on mmap_sem held
> > for write.
> > 
> > dup_mmap() duplicates current->mm and to-be-duplicated mm is not visible yet.
> > If dup_mmap() failed, to-be-duplicated incomplete mm is discarded via mmput()
> > in dup_mm() rather than assigned to the child. Thus, this patch should not
> > change things which are visible to the child during the copy.
> > 
> > What we need to be careful is making changes to current->mm.
> > I'm assuming that current->mm->mmap_sem held for read is enough for
> > i_mmap_lock_write()/flush_dcache_mmap_lock()/vma_interval_tree_insert_after()/
> > flush_dcache_mmap_unlock()/i_mmap_unlock_write()/is_vm_hugetlb_page()/
> > reset_vma_resv_huge_pages()/__vma_link_rb(). But I'm not sure.
> 
> But as soon as you downgrade the lock then all other threads can
> interfere and perform page faults or update respecive mappings. Does
> this matter? If not then why?
> 

Why does this matter?

I don't know what "update respecive mappings" means.
Is that about mmap()/munmap() which need mmap_sem held for write?
Since mmap_sem is still held for read, operations which needs
mmap_sem held for write cannot happen.

Anyway, as long as I downgrade the mmap_sem at safely and consistently
interruptible locations, there cannot be a problem.
