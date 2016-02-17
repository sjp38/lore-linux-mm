Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id AE6E06B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:37:02 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id z135so37013781iof.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:37:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s9si5080792igg.47.2016.02.17.05.37.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 05:37:02 -0800 (PST)
Subject: Re: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171933.HFD51078.LOSFVMFQFOJHOt@I-love.SAKURA.ne.jp>
	<20160217131034.GH29196@dhcp22.suse.cz>
In-Reply-To: <20160217131034.GH29196@dhcp22.suse.cz>
Message-Id: <201602172236.FHF87070.LOVFtJSOFFMHQO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 22:36:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 19:33:07, Tetsuo Handa wrote:
> > >From 4924ca3031444bfb831b2d4f004e5a613ad48d68 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Wed, 17 Feb 2016 16:35:12 +0900
> > Subject: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
> > 
> > oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> > thread which returns oom_task_origin() == true. But it is possible
> > that that thread is marked as OOM-unkillable.
> > 
> > This patch changes oom_scan_process_thread() not to select it
> > if it is marked as OOM-unkillable.
> 
> oom_task_origin is only swapoff and ksm_store right now. I seriously
> doubt anybody sane will run them as OOM disabled (directly or
> indirectly).

I think that the OOM reaper will update such task as OOM-unkillable
after reaping that task's memory. This patch is intended for not to
fall into infinite loop after the OOM reaper updated it.

> 
> But you have a point that returing anything but OOM_SCAN_CONTINUE for
> OOM_SCORE_ADJ_MIN from oom_scan_process_thread sounds suboptimal.
> Sure such a check would be racy but do we actually care about a OOM vs.
> oom_score_adj_write. I am dubious to say the least.
> 
> So wouldn't it make more sense to check for OOM_SCORE_ADJ_MIN at the
> very top of oom_scan_process_thread instead?

Are you suggesting something like below?
(OOM_SCORE_ADJ_MIN check needs to be done after TIF_MEMDIE check)

enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
					struct task_struct *task, unsigned long totalpages)
{
	if (oom_unkillable_task(task, NULL, oc->nodemask))
		return OOM_SCAN_CONTINUE;

	/*
	 * This task already has access to memory reserves and is being killed.
	 * Don't allow any other task to have access to the reserves.
	 */
	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
		if (!is_sysrq_oom(oc))
			return OOM_SCAN_ABORT;
	}
	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
		return OOM_SCAN_CONTINUE;
(...snipped...)
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
