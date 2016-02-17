Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B53C36B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:44:43 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so28855360wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:44:43 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id k10si2006605wjy.108.2016.02.17.05.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 05:44:42 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id a4so28702513wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:44:42 -0800 (PST)
Date: Wed, 17 Feb 2016 14:44:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
Message-ID: <20160217134441.GL29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171933.HFD51078.LOSFVMFQFOJHOt@I-love.SAKURA.ne.jp>
 <20160217131034.GH29196@dhcp22.suse.cz>
 <201602172236.FHF87070.LOVFtJSOFFMHQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602172236.FHF87070.LOVFtJSOFFMHQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 22:36:47, Tetsuo Handa wrote:
[...]
> Are you suggesting something like below?
> (OOM_SCORE_ADJ_MIN check needs to be done after TIF_MEMDIE check)
> 
> enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> 					struct task_struct *task, unsigned long totalpages)
> {
> 	if (oom_unkillable_task(task, NULL, oc->nodemask))
> 		return OOM_SCAN_CONTINUE;
> 
> 	/*
> 	 * This task already has access to memory reserves and is being killed.
> 	 * Don't allow any other task to have access to the reserves.
> 	 */
> 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> 		if (!is_sysrq_oom(oc))
> 			return OOM_SCAN_ABORT;
> 	}
> 	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> 		return OOM_SCAN_CONTINUE;

yes

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
