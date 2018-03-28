Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3551F6B002F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:05:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id e15so1000325wrj.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:05:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u32si2753228wrf.52.2018.03.28.04.05.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 04:05:15 -0700 (PDT)
Date: Wed, 28 Mar 2018 13:05:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce i_mmap_lock_write_killable().
Message-ID: <20180328110513.GH9275@dhcp22.suse.cz>
References: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180327145220.GJ5652@dhcp22.suse.cz>
 <201803281923.EFF26009.OFOtJSMFHQFLVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803281923.EFF26009.OFOtJSMFHQFLVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com

On Wed 28-03-18 19:23:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 27-03-18 20:19:30, Tetsuo Handa wrote:
> > > If the OOM victim is holding mm->mmap_sem held for write, and if the OOM
> > > victim can interrupt operations which need mm->mmap_sem held for write,
> > > we can downgrade mm->mmap_sem upon SIGKILL and the OOM reaper will be
> > > able to reap the OOM victim's memory.
> > 
> > This really begs for much better explanation. Why is it safe?
> 
> Basic idea is
> 
>   bool downgraded = false;
>   down_write(mmap_sem);
>   for (something_1_that_might_depend_mmap_sem_held_for_write;
>        something_2_that_might_depend_mmap_sem_held_for_write;
>        something_3_that_might_depend_mmap_sem_held_for_write) {
>      something_4_that_might_depend_mmap_sem_held_for_write();
>      if (fatal_signal_pending(current)) {
>         downgrade_write(mmap_sem);
>         downgraded = true;
>         break;
>      }
>      something_5_that_might_depend_mmap_sem_held_for_write();
>   }
>   if (!downgraded)
>     up_write(mmap_sem);
>   else
>     up_read(mmap_sem);
> 
> . That is, try to interrupt critical sections at locations where it is
> known to be safe and consistent.

Please explain why those places are safe to interrupt.

> >                                                               Are you
> > assuming that the killed task will not perform any changes on the
> > address space?
> 
> If somebody drops mmap_sem held for write is not safe, how can the OOM
> reaper work safely?
> 
> The OOM reaper is assuming that the thread who got mmap_sem held for write
> is responsible to complete critical sections before dropping mmap_sem held
> for write, isn't it?
> 
> Then, how an attempt to perform changes on the address space can become a
> problem given that the thread who got mmap_sem held for write is responsible
> to complete critical sections before dropping mmap_sem held for write?

ENOPARSE. How does this have anything to do with oom_reaper. Sure you
want to _help_ the oom_reaper to do its job but you are dropping the
lock in the downgrading the lock in the middle of dup_mmap and that is
what we are dicussing here. So please explain why it is safe. It is
really not straightforward.

> >                What about ongoing page faults or other operations deeper
> > in the call chain.
> 
> Even if there are ongoing page faults or other operations deeper in the call
> chain, there should be no problem as long as the thread who got mmap_sem
> held for write is responsible to complete critical sections before dropping
> mmap_sem held for write.
> 
> >                    Why they are safe to change things for the child
> > during the copy?
> 
> In this patch, the current thread who got mmap_sem held for write (which is
> likely an OOM victim thread) downgrades mmap_sem, with an assumption that
> current thread no longer accesses memory which might depend on mmap_sem held
> for write.
> 
> dup_mmap() duplicates current->mm and to-be-duplicated mm is not visible yet.
> If dup_mmap() failed, to-be-duplicated incomplete mm is discarded via mmput()
> in dup_mm() rather than assigned to the child. Thus, this patch should not
> change things which are visible to the child during the copy.
> 
> What we need to be careful is making changes to current->mm.
> I'm assuming that current->mm->mmap_sem held for read is enough for
> i_mmap_lock_write()/flush_dcache_mmap_lock()/vma_interval_tree_insert_after()/
> flush_dcache_mmap_unlock()/i_mmap_unlock_write()/is_vm_hugetlb_page()/
> reset_vma_resv_huge_pages()/__vma_link_rb(). But I'm not sure.

But as soon as you downgrade the lock then all other threads can
interfere and perform page faults or update respecive mappings. Does
this matter? If not then why?

> > I am not saying this is wrong, I would have to think about that much
> > more because mmap_sem tends to be used on many surprising places and the
> > write lock just hide them all.
> 
> Then, an alternative approach which interrupts without downgrading is shown
> below. But I'm not sure.

Failing the whole dup_mmap might be quite reasonable, yes. I haven't
checked your particular patch because this code path needs much more
time than I can give this, though.
-- 
Michal Hocko
SUSE Labs
