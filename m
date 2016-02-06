Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D8AA5440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 03:38:00 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p63so55711976wmp.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 00:38:00 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gg9si29341710wjb.115.2016.02.06.00.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 00:37:59 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g62so6509427wme.2
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 00:37:59 -0800 (PST)
Date: Sat, 6 Feb 2016 09:37:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
Message-ID: <20160206083757.GB25220@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
 <20160204145357.GE14425@dhcp22.suse.cz>
 <201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-02-16 14:54:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > But if we consider non system-wide OOM events, it is not very unlikely to hit
> > > this race. This queue is useful for situations where memcg1 and memcg2 hit
> > > memcg OOM at the same time and victim1 in memcg1 cannot terminate immediately.
> > 
> > This can happen of course but the likelihood is _much_ smaller without
> > the global OOM because the memcg OOM killer is invoked from a lockless
> > context so the oom context cannot block the victim to proceed.
> 
> Suppose mem_cgroup_out_of_memory() is called from a lockless context via
> mem_cgroup_oom_synchronize() called from pagefault_out_of_memory(), that
> "lockless" is talking about only current thread, doesn't it?

Yes and you need the OOM context to sit on the same lock as the victim
to form a deadlock. So while the victim might be blocked somewhere it is
much less likely it would be deadlocked.

> Since oom_kill_process() sets TIF_MEMDIE on first mm!=NULL thread of a
> victim process, it is possible that non-first mm!=NULL thread triggers
> pagefault_out_of_memory() and first mm!=NULL thread gets TIF_MEMDIE,
> isn't it?

I got lost here completely. Maybe it is your usage of thread terminology
again.
 
> Then, where is the guarantee that victim1 (first mm!=NULL thread in memcg1
> which got TIF_MEMDIE) is not waiting at down_read(&victim2->mm->mmap_sem)
> when victim2 (first mm!=NULL thread in memcg2 which got TIF_MEMDIE) is
> waiting at down_write(&victim2->mm->mmap_sem)

All threads/processes sharing the same mm are in fact in the same memory
cgroup. That is the reason we have owner in the task_struct

> or both victim1 and victim2
> are waiting on a lock somewhere in memory reclaim path (e.g.
> mutex_lock(&inode->i_mutex))?

Such waiting has to make a forward progress at some point in time
because the lock itself cannot be deadlocked by the memcg OOM context.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
