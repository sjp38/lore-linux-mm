Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC91D6B025E
	for <linux-mm@kvack.org>; Sat,  3 Sep 2016 21:50:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c198so85994263ith.2
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 18:50:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j9si13970915ite.90.2016.09.03.18.50.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Sep 2016 18:50:51 -0700 (PDT)
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
	<1472723464-22866-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472723464-22866-4-git-send-email-mhocko@kernel.org>
Message-Id: <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
Date: Sun, 4 Sep 2016 10:50:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com, oleg@redhat.com, viro@zeniv.linux.org.uk

Michal Hocko wrote:
> mark_oom_victim and exit_oom_victim are used for oom_killer_disable
> which should block as long as there any any oom victims alive. Up to now
> we have relied on TIF_MEMDIE task flag to count how many oom victim
> we have. This is not optimal because only one thread receives this flag
> at the time while the whole process (thread group) is killed and should
> die. As a result we do not thaw the whole thread group and so a multi
> threaded process can leave some threads behind in the fridge. We really
> want to thaw all the threads.
> 
> This is not all that easy because there is no reliable way to count
> threads in the process as the oom killer might race with copy_process.

What is wrong with racing with copy_process()? Threads doing copy_process()
are not frozen and thus we don't need to thaw such threads. Also, being
OOM-killed implies receiving SIGKILL. Thus, newly created thread will also
enter do_exit().

> So marking all threads with TIF_MEMDIE and increment oom_victims
> accordingly is not safe. Also TIF_MEMDIE flag should just die so
> we should better come up with a different approach.
> 
> All we need to guarantee is that exit_oom_victim is called at the time
> when no further access to (possibly suspended) devices or generate other
> IO (which would clobber suspended image and only once per process)
> is possible. It seems we can rely on exit_notify for that because we
> already have to detect the last thread to do a cleanup. Let's propagate
> that information up to do_exit and only call exit_oom_victim for such
> a thread. With this in place we can safely increment oom_victims only
> once per thread group and thaw all the threads from the process.
> freezing_slow_path can also rely on tsk_is_oom_victim as well now.

If marking all threads which belong to tsk thread group with TIF_MEMDIE
is not safe (due to possible race with copy_process()), how can

	rcu_read_lock();
	for_each_thread(tsk, t)
		__thaw_task(t);
	rcu_read_unlock();

in mark_oom_victim() guarantee that all threads which belong to tsk
thread group are thawed?

Unless all threads which belong to tsk thread group in __refrigerator()
are guaranteed to be thawed, they might fail to leave __refrigerator()
in order to enter do_exit() which means that exit_oom_victim() won't be
called.

Do we want to thaw OOM victims from the beginning? If the freezer
depends on CONFIG_MMU=y , we don't need to thaw OOM victims.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
