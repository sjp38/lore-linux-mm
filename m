Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 437DF6B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:41:39 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id rw3so173116737obb.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:41:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k9si10021626otk.227.2016.05.20.06.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 06:41:38 -0700 (PDT)
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160518125138.GH21654@dhcp22.suse.cz>
	<201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
	<20160520075035.GF19172@dhcp22.suse.cz>
	<201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
	<20160520120954.GA5215@dhcp22.suse.cz>
In-Reply-To: <20160520120954.GA5215@dhcp22.suse.cz>
Message-Id: <201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
Date: Fri, 20 May 2016 22:41:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Michal Hocko wrote:
> On Fri 20-05-16 20:51:56, Tetsuo Handa wrote:
> [...]
> > +static bool has_pending_victim(struct task_struct *p)
> > +{
> > +	struct task_struct *t;
> > +	bool ret = false;
> > +
> > +	rcu_read_lock();
> > +	for_each_thread(p, t) {
> > +		if (test_tsk_thread_flag(t, TIF_MEMDIE)) {
> > +			ret = true;
> > +			break;
> > +		}
> > +	}
> > +	rcu_read_unlock();
> > +	return ret;
> > +}
> 
> And so you do not speed up anything in the end because you have to
> iterate all threads anyway yet you add quite some code on top. No I do
> not like it. This is no longer a cleanup...

I changed for_each_process_thread() to for_each_process(). This means
O(num_threads^2) task_in_mem_cgroup() and O(num_threads^2)
has_intersects_mems_allowed() are replaced with O(num_threads)
task_in_mem_cgroup() and O(num_threads) has_intersects_mems_allowed()
at the cost of adding O(num_threads) has_pending_victim().

I expect that O(num_threads) (task_in_mem_cgroup() + has_intersects_mems_allowed() +
has_pending_victim()) is faster than O(num_threads^2) (task_in_mem_cgroup() +
has_intersects_mems_allowed()) + O(num_threads) test_tsk_thread_flag().

> 
> [...]
> > Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
> > broke oom_task_origin(task) case, for oom_select_bad_process() might select
> > a task without mm because oom_badness() which checks for mm != NULL will not be
> > called.
> 
> How can we have oom_task_origin without mm? The flag is set explicitly
> while doing swapoff resp. writing to ksm. We clear the flag before
> exiting.

What if oom_task_origin(task) received SIGKILL, but task was unable to run for
very long period (e.g. 30 seconds) due to scheduling priority, and the OOM-reaper
reaped task's mm within a second. Next round of OOM-killer selects the same task
due to oom_task_origin(task) without doing MMF_OOM_REAPED test.

Once the OOM-reaper reaped task's mm (or gave up reaping it), subsequent
OOM-killer should treat that task as task->mm = NULL. Moving
oom_task_origin(task) test to after test_bit(MMF_OOM_REAPED, &p->mm->flags)
test will let the OOM-killer think as "oom_task_origin without mm".

> 
> [...]
> 
> > By the way, I noticed that mem_cgroup_out_of_memory() might have a bug about its
> > return value. It returns true if hit OOM_SCAN_ABORT after chosen != NULL, false
> > if hit OOM_SCAN_ABORT before chosen != NULL. Which is expected return value?
> 
> true. Care to send a patch?

I don't know what memory_max_write() wants to do when it found a TIF_MEMDIE thread
in the given memcg. Thus, I can't tell whether setting chosen to NULL (which means
mem_cgroup_out_of_memory() returns false) is the expected behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
