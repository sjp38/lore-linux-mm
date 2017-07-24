Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC0336B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:15:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u89so24885996wrc.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:15:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c136si5715913wmc.161.2017.07.24.07.15.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 07:15:30 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:15:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170724141526.GM25221@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 24-07-17 17:00:08, Kirill A. Shutemov wrote:
> On Mon, Jul 24, 2017 at 09:23:32AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > David has noticed that the oom killer might kill additional tasks while
> > the exiting oom victim hasn't terminated yet because the oom_reaper marks
> > the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
> > to 0. The race is as follows
> > 
> > oom_reap_task				do_exit
> > 					  exit_mm
> >   __oom_reap_task_mm
> > 					    mmput
> > 					      __mmput
> >     mmget_not_zero # fails
> >     						exit_mmap # frees memory
> >   set_bit(MMF_OOM_SKIP)
> > 
> > The victim is still visible to the OOM killer until it is unhashed.
> > 
> > Currently we try to reduce a risk of this race by taking oom_lock
> > and wait for out_of_memory sleep while holding the lock to give the
> > victim some time to exit. This is quite suboptimal approach because
> > there is no guarantee the victim (especially a large one) will manage
> > to unmap its address space and free enough memory to the particular oom
> > domain which needs a memory (e.g. a specific NUMA node).
> > 
> > Fix this problem by allowing __oom_reap_task_mm and __mmput path to
> > race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
> > to run in parallel with other unmappers (hence the mmap_sem for read).
> > 
> > The only tricky part is to exclude page tables tear down and all
> > operations which modify the address space in the __mmput path. exit_mmap
> > doesn't expect any other users so it doesn't use any locking. Nothing
> > really forbids us to use mmap_sem for write, though. In fact we are
> > already relying on this lock earlier in the __mmput path to synchronize
> > with ksm and khugepaged.
> 
> That's true, but we take mmap_sem there for small portion of cases.
> 
> It's quite different from taking the lock unconditionally. I'm worry about
> scalability implication of such move. On bigger machines it can be big
> hit.

What kind of scalability implication you have in mind? There is
basically a zero contention on the mmap_sem that late in the exit path
so this should be pretty much a fast path of the down_write. I agree it
is not 0 cost but the cost of the address space freeing should basically
make it a noise.

> Should we do performance/scalability evaluation of the patch before
> getting it applied?

What kind of test(s) would you be interested in?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
