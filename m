Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1B36B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:15:18 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id av4so15697303igc.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 03:15:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a20si4271815ioa.119.2016.03.10.03.15.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 03:15:16 -0800 (PST)
Subject: Re: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem() check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160309100558.GB27018@dhcp22.suse.cz>
In-Reply-To: <20160309100558.GB27018@dhcp22.suse.cz>
Message-Id: <201603102015.AEG81788.FOFOHFJQLMVOSt@I-love.SAKURA.ne.jp>
Date: Thu, 10 Mar 2016 20:15:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 09-03-16 00:15:10, Tetsuo Handa wrote:
> > Since mem_cgroup_out_of_memory() is called by
> > mem_cgroup_oom_synchronize(true) via pagefault_out_of_memory() via
> > page fault, and possible allocations between setting PF_EXITING and
> > calling exit_mm() are tty_audit_exit() and taskstats_exit() which will
> > not trigger page fault, task_will_free_mem(current) in
> > mem_cgroup_out_of_memory() is never true.
> 
> What about exit_robust_list called from mm_release?
> 
> Anyway I guess we can indeed remove the check because try_charge will
> bypass the charge if we are exiting so we shouldn't even reach this path
> with PF_EXITING. But I haven't double checked. The above changelog seems
> to be incorrect, though.
> 

Indeed. do_exit()->exit_mm()->mm_release()->exit_robust_list()->get_user()
can trigger page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
