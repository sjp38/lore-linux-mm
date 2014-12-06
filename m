Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id A5EDF6B0032
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 08:07:01 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id z107so1741745qgd.1
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:07:01 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id a8si37964469qcs.23.2014.12.06.05.07.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 05:07:00 -0800 (PST)
Received: by mail-qg0-f51.google.com with SMTP id e89so561591qgf.38
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:07:00 -0800 (PST)
Date: Sat, 6 Dec 2014 08:06:57 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 2/5] OOM: thaw the OOM victim if it is frozen
Message-ID: <20141206130657.GC18711@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hello,

On Fri, Dec 05, 2014 at 05:41:44PM +0100, Michal Hocko wrote:
> oom_kill_process only sets TIF_MEMDIE flag and sends a signal to the
> victim. This is basically noop when the task is frozen though because
> the task sleeps in uninterruptible sleep. The victim is eventually
> thawed later when oom_scan_process_thread meets the task again in a
> later OOM invocation so the OOM killer doesn't live lock. But this is
> less than optimal. Let's add the frozen check and thaw the task right
> before we send SIGKILL to the victim.
> 
> The check and thawing in oom_scan_process_thread has to stay because the
> task might got access to memory reserves even without an explicit
> SIGKILL from oom_kill_process (e.g. it already has fatal signal pending
> or it is exiting already).

How else would a task get TIF_MEMDIE?  If there are other paths which
set TIF_MEMDIE, the right thing to do is creating a function which
thaws / wakes up the target task and use it there too.  Please
interlock these things properly from the get-go instead of scattering
these things around.

> @@ -545,6 +545,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	rcu_read_unlock();
>  
>  	mark_tsk_oom_victim(victim);
> +	if (frozen(victim))
> +		__thaw_task(victim);

The frozen() test here is racy.  Always calling __thaw_task() wouldn't
be.  You can argue that being racy here is okay because the later
scanning would find it but why complicate things like that?  Just
properly interlock each instance and be done with it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
