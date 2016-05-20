Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 01BA26B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 11:23:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so15275689wma.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:23:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id kk4si26290783wjb.75.2016.05.20.08.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 08:23:32 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 67so6907805wmg.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:23:32 -0700 (PDT)
Date: Fri, 20 May 2016 17:23:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520152331.GD5215@dhcp22.suse.cz>
References: <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160520075035.GF19172@dhcp22.suse.cz>
 <201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
 <20160520120954.GA5215@dhcp22.suse.cz>
 <201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Fri 20-05-16 22:41:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 20-05-16 20:51:56, Tetsuo Handa wrote:
> > [...]
> > > +static bool has_pending_victim(struct task_struct *p)
> > > +{
> > > +	struct task_struct *t;
> > > +	bool ret = false;
> > > +
> > > +	rcu_read_lock();
> > > +	for_each_thread(p, t) {
> > > +		if (test_tsk_thread_flag(t, TIF_MEMDIE)) {
> > > +			ret = true;
> > > +			break;
> > > +		}
> > > +	}
> > > +	rcu_read_unlock();
> > > +	return ret;
> > > +}
> > 
> > And so you do not speed up anything in the end because you have to
> > iterate all threads anyway yet you add quite some code on top. No I do
> > not like it. This is no longer a cleanup...
> 
> I changed for_each_process_thread() to for_each_process(). This means
> O(num_threads^2) task_in_mem_cgroup()

oom_unkillable_task is called with NULL memcg so we do not call
task_in_mem_cgroup.

> and O(num_threads^2)
> has_intersects_mems_allowed() are replaced with O(num_threads)

I am really confused why has_intersects_mems_allowed has to iterate all
threads. Do we really allow different mempolicies for threads in the
same thread group?

> task_in_mem_cgroup() and O(num_threads) has_intersects_mems_allowed()
> at the cost of adding O(num_threads) has_pending_victim().
> 
> I expect that O(num_threads) (task_in_mem_cgroup() + has_intersects_mems_allowed() +
> has_pending_victim()) is faster than O(num_threads^2) (task_in_mem_cgroup() +
> has_intersects_mems_allowed()) + O(num_threads) test_tsk_thread_flag().

I thought the whole point of the cleanup was to get rid of O(num_thread)
because num_threads >> num_processes in most workloads. It seems that
we are still not there because of has_intersects_mems_allowed but we
should rather address that than add another O(num_threads) sources.
 
> > [...]
> > > Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
> > > broke oom_task_origin(task) case, for oom_select_bad_process() might select
> > > a task without mm because oom_badness() which checks for mm != NULL will not be
> > > called.
> > 
> > How can we have oom_task_origin without mm? The flag is set explicitly
> > while doing swapoff resp. writing to ksm. We clear the flag before
> > exiting.
> 
> What if oom_task_origin(task) received SIGKILL, but task was unable to run for
> very long period (e.g. 30 seconds) due to scheduling priority, and the OOM-reaper
> reaped task's mm within a second. Next round of OOM-killer selects the same task
> due to oom_task_origin(task) without doing MMF_OOM_REAPED test.

Which is actuall the intended behavior. The whole point of
oom_task_origin is to prevent from killing somebody because of
potentially memory hungry operation (e.g. swapoff) and rather kill the
initiator. 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
