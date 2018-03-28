Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 597046B0022
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:39:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v25so1218692pgn.20
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:39:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6-v6si3477505plm.239.2018.03.28.05.39.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 05:39:25 -0700 (PDT)
Date: Wed, 28 Mar 2018 14:39:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce i_mmap_lock_write_killable().
Message-ID: <20180328123919.GK9275@dhcp22.suse.cz>
References: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180327145220.GJ5652@dhcp22.suse.cz>
 <201803281923.EFF26009.OFOtJSMFHQFLVO@I-love.SAKURA.ne.jp>
 <20180328110513.GH9275@dhcp22.suse.cz>
 <201803282126.GBC56799.tOFVFSOHJLFOQM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803282126.GBC56799.tOFVFSOHJLFOQM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com

On Wed 28-03-18 21:26:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > > Basic idea is
> > > 
> > >   bool downgraded = false;
> > >   down_write(mmap_sem);
> > >   for (something_1_that_might_depend_mmap_sem_held_for_write;
> > >        something_2_that_might_depend_mmap_sem_held_for_write;
> > >        something_3_that_might_depend_mmap_sem_held_for_write) {
> > >      something_4_that_might_depend_mmap_sem_held_for_write();
> > >      if (fatal_signal_pending(current)) {
> > >         downgrade_write(mmap_sem);
> > >         downgraded = true;
> > >         break;
> > >      }
> > >      something_5_that_might_depend_mmap_sem_held_for_write();
> > >   }
> > >   if (!downgraded)
> > >     up_write(mmap_sem);
> > >   else
> > >     up_read(mmap_sem);
> > > 
> > > . That is, try to interrupt critical sections at locations where it is
> > > known to be safe and consistent.
> > 
> > Please explain why those places are safe to interrupt.
> 
> Because (regarding the downgrade_write() approach), as far as I know,
> the current thread does not access memory which needs to be protected with
> mmap_sem held for write.

But there are other threads which can be in an arbitrary code path
before they get to the signal handling code.

> >                             So please explain why it is safe. It is
> > really not straightforward.
> 
> So, please explain why it is not safe. How can releasing mmap_sem held for
> write at safely and consistently interruptible locations be not safe?

Look, you are proposing a patch and the onus to justify its correctness
is on you. You are playing with the code which you have only vague
understanding of and so you should study and understand it more. You
seem to be infering invariants from the current function scope and that
is quite dangerous.

[...]
> > > What we need to be careful is making changes to current->mm.
> > > I'm assuming that current->mm->mmap_sem held for read is enough for
> > > i_mmap_lock_write()/flush_dcache_mmap_lock()/vma_interval_tree_insert_after()/
> > > flush_dcache_mmap_unlock()/i_mmap_unlock_write()/is_vm_hugetlb_page()/
> > > reset_vma_resv_huge_pages()/__vma_link_rb(). But I'm not sure.
> > 
> > But as soon as you downgrade the lock then all other threads can
> > interfere and perform page faults or update respecive mappings. Does
> > this matter? If not then why?
> > 
> 
> Why does this matter?
> 
> I don't know what "update respecive mappings" means.

E.g. any get_user_page or an ongoing #PF can update a mapping and so the
child process might see some inconsistencies (aka partial of the address
space with the previous content).

> Is that about mmap()/munmap() which need mmap_sem held for write?

No, it is about those who take it for read.

> Since mmap_sem is still held for read, operations which needs
> mmap_sem held for write cannot happen.
> 
> Anyway, as long as I downgrade the mmap_sem at safely and consistently
> interruptible locations, there cannot be a problem.

I have a strong feeling that the whole address space has to be copied
atomicaly form the address space POV. I might be wrong but it is not
really obvious to me why and if you want to downgrade the lock there
then please make sure to document what are you assumptions and why they
are valid.
-- 
Michal Hocko
SUSE Labs
