Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 521AD6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 13:15:51 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so161440391wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 10:15:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k84si6004306wmc.14.2016.03.08.10.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 10:15:49 -0800 (PST)
Date: Tue, 8 Mar 2016 13:14:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem()
 check.
Message-ID: <20160308181432.GA9091@cmpxchg.org>
References: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Wed, Mar 09, 2016 at 12:15:10AM +0900, Tetsuo Handa wrote:
> Since mem_cgroup_out_of_memory() is called by
> mem_cgroup_oom_synchronize(true) via pagefault_out_of_memory() via
> page fault, and possible allocations between setting PF_EXITING and
> calling exit_mm() are tty_audit_exit() and taskstats_exit() which will
> not trigger page fault, task_will_free_mem(current) in
> mem_cgroup_out_of_memory() is never true.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

This opens us up to subtle bugs when somebody later changes the order
and adds new possible allocation sites between the sequence points you
describe above, or maybe adds other mem_cgroup_out_of_memory() callers.

It looks like a simplification, but it actually complicates things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
