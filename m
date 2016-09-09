Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81E296B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 10:08:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so15066229wmz.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:08:53 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id t62si3083185wma.138.2016.09.09.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 07:08:52 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id b187so33625981wme.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:08:52 -0700 (PDT)
Date: Fri, 9 Sep 2016 16:08:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
Message-ID: <20160909140851.GP4844@dhcp22.suse.cz>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <1472723464-22866-4-git-send-email-mhocko@kernel.org>
 <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

On Sun 04-09-16 10:50:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > mark_oom_victim and exit_oom_victim are used for oom_killer_disable
> > which should block as long as there any any oom victims alive. Up to now
> > we have relied on TIF_MEMDIE task flag to count how many oom victim
> > we have. This is not optimal because only one thread receives this flag
> > at the time while the whole process (thread group) is killed and should
> > die. As a result we do not thaw the whole thread group and so a multi
> > threaded process can leave some threads behind in the fridge. We really
> > want to thaw all the threads.
> > 
> > This is not all that easy because there is no reliable way to count
> > threads in the process as the oom killer might race with copy_process.
> 
> What is wrong with racing with copy_process()? Threads doing copy_process()
> are not frozen and thus we don't need to thaw such threads. Also, being
> OOM-killed implies receiving SIGKILL. Thus, newly created thread will also
> enter do_exit().

The problem is that we cannot rely on signal->nr_threads to know when
the last one is passing exit to declare the whole group done and wake
the waiter on the oom killer lock.

> > So marking all threads with TIF_MEMDIE and increment oom_victims
> > accordingly is not safe. Also TIF_MEMDIE flag should just die so
> > we should better come up with a different approach.
> > 
> > All we need to guarantee is that exit_oom_victim is called at the time
> > when no further access to (possibly suspended) devices or generate other
> > IO (which would clobber suspended image and only once per process)
> > is possible. It seems we can rely on exit_notify for that because we
> > already have to detect the last thread to do a cleanup. Let's propagate
> > that information up to do_exit and only call exit_oom_victim for such
> > a thread. With this in place we can safely increment oom_victims only
> > once per thread group and thaw all the threads from the process.
> > freezing_slow_path can also rely on tsk_is_oom_victim as well now.
> 
> If marking all threads which belong to tsk thread group with TIF_MEMDIE
> is not safe (due to possible race with copy_process()), how can
> 
> 	rcu_read_lock();
> 	for_each_thread(tsk, t)
> 		__thaw_task(t);
> 	rcu_read_unlock();
> 
> in mark_oom_victim() guarantee that all threads which belong to tsk
> thread group are thawed?

Because all the frozen thread already have to be hashed and those which
are in the middle of copy process will be tsk_is_oom_victim and so the
freezer will skip them.

> Unless all threads which belong to tsk thread group in __refrigerator()
> are guaranteed to be thawed, they might fail to leave __refrigerator()
> in order to enter do_exit() which means that exit_oom_victim() won't be
> called.
> 
> Do we want to thaw OOM victims from the beginning? If the freezer
> depends on CONFIG_MMU=y , we don't need to thaw OOM victims.

We want to thaw them, at least at this stage, because the task might be
sitting on a memory which is not reclaimable by the oom reaper (e.g.
different buffers of file descriptors etc.).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
