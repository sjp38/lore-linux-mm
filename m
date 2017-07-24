Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 835856B02F3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:51:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p17so2470558wmd.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:51:46 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id 80si3992794wmr.170.2017.07.24.07.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 07:51:45 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id m85so19669401wma.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:51:44 -0700 (PDT)
Date: Mon, 24 Jul 2017 17:51:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724141526.GM25221@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 24, 2017 at 04:15:26PM +0200, Michal Hocko wrote:
> On Mon 24-07-17 17:00:08, Kirill A. Shutemov wrote:
> > On Mon, Jul 24, 2017 at 09:23:32AM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > David has noticed that the oom killer might kill additional tasks while
> > > the exiting oom victim hasn't terminated yet because the oom_reaper marks
> > > the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
> > > to 0. The race is as follows
> > > 
> > > oom_reap_task				do_exit
> > > 					  exit_mm
> > >   __oom_reap_task_mm
> > > 					    mmput
> > > 					      __mmput
> > >     mmget_not_zero # fails
> > >     						exit_mmap # frees memory
> > >   set_bit(MMF_OOM_SKIP)
> > > 
> > > The victim is still visible to the OOM killer until it is unhashed.
> > > 
> > > Currently we try to reduce a risk of this race by taking oom_lock
> > > and wait for out_of_memory sleep while holding the lock to give the
> > > victim some time to exit. This is quite suboptimal approach because
> > > there is no guarantee the victim (especially a large one) will manage
> > > to unmap its address space and free enough memory to the particular oom
> > > domain which needs a memory (e.g. a specific NUMA node).
> > > 
> > > Fix this problem by allowing __oom_reap_task_mm and __mmput path to
> > > race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
> > > to run in parallel with other unmappers (hence the mmap_sem for read).
> > > 
> > > The only tricky part is to exclude page tables tear down and all
> > > operations which modify the address space in the __mmput path. exit_mmap
> > > doesn't expect any other users so it doesn't use any locking. Nothing
> > > really forbids us to use mmap_sem for write, though. In fact we are
> > > already relying on this lock earlier in the __mmput path to synchronize
> > > with ksm and khugepaged.
> > 
> > That's true, but we take mmap_sem there for small portion of cases.
> > 
> > It's quite different from taking the lock unconditionally. I'm worry about
> > scalability implication of such move. On bigger machines it can be big
> > hit.
> 
> What kind of scalability implication you have in mind? There is
> basically a zero contention on the mmap_sem that late in the exit path
> so this should be pretty much a fast path of the down_write. I agree it
> is not 0 cost but the cost of the address space freeing should basically
> make it a noise.

Even in fast path case, it adds two atomic operation per-process. If the
cache line is not exclusive to the core by the time of exit(2) it can be
noticible.

... but I guess it's not very hot scenario.

I guess I'm just too cautious here. :)

> > Should we do performance/scalability evaluation of the patch before
> > getting it applied?
> 
> What kind of test(s) would you be interested in?

Can we at lest check that number of /bin/true we can spawn per second
wouldn't be harmed by the patch? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
