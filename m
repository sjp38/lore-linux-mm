Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B62586B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:29:52 -0400 (EDT)
Received: by pawq9 with SMTP id q9so53019664paw.3
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 06:29:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ge2si12855814pbb.254.2015.08.21.06.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 06:29:51 -0700 (PDT)
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on livelock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
	<20150821081745.GG23723@dhcp22.suse.cz>
In-Reply-To: <20150821081745.GG23723@dhcp22.suse.cz>
Message-Id: <201508212229.GIC00036.tVFMQLOOFJOFSH@I-love.SAKURA.ne.jp>
Date: Fri, 21 Aug 2015 22:29:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, oleg@redhat.com, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> [CCing Tetsuo - he was really concerned about the oom deadlocks and he
>  was proposing a timeout based solution as well]

Thank you for CCing me.
My proposal is http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp .

> 
> On Thu 20-08-15 14:00:36, David Rientjes wrote:
> > On system oom, a process may fail to exit if its thread depends on a lock
> > held by another allocating process.
> > 
> > In this case, we can detect an oom kill livelock that requires memory
> > allocation to be successful to resolve.
> > 
> > This patch introduces an oom expiration, set to 5s, that defines how long
> > a thread has to exit after being oom killed.
> > 
> > When this period elapses, it is assumed that the thread cannot make
> > forward progress without help.  The only help the VM may provide is to
> > allow pending allocations to succeed, so it grants all allocators access
> > to memory reserves after reclaim and compaction have failed.

Why can't we think about choosing more OOM victims instead of granting access
to memory reserves?

> 
> There might be many threads waiting for the allocation and this can lead
> to quick oom reserves depletion without releasing resources which are
> holding back the oom victim. As Tetsuo has shown, such a load can be
> generated from the userspace without root privileges so it is much
> easier to make the system _completely_ unusable with this patch. Not that
> having an OOM deadlock would be great but you still have emergency tools
> like sysrq triggered OOM killer to attempt to sort the situation out.

Like I described in my proposal, the administrator might not be ready to use
SysRq. Automatic recovery based on timeout is useful for such cases than
manual emergency tools.

Also, SysRq might not be usable under OOM because workqueues can get stuck.
The panic_on_oom_timeout was first proposed using a workqueue but was
updated to use a timer because there is no guarantee that workqueues work
as expected under OOM.

> Once your are out of reserves nothing will help you, though. So I think it
> is a bad idea to give access to reserves without any throttling.

I agree.
But I also think that it is a bad idea to cling to only memory reserves.

> 
> Johannes' idea to give a partial access to memory reserves to the task
> which has invoked the OOM killer was much better IMO.

In a different thread, we are planning to change !__GFP_FS allocations.
Some of !__GFP_FS allocations are about to acquire __GFP_NOFAIL which could
in turn suffer from OOM deadlock because the possibility of hitting
"__GFP_NOFAIL allocations not only start calling out_of_memory() but also
start triggering OOM deadlock when out_of_memory() cannot choose next OOM
victim" is increased.

The panic_on_oom_timeout will be overkilling when choosing next OOM victim
can make forward progress. If a local unprivileged user discovers a method
for keeping the OOM state for panic_on_oom_timeout seconds, we will allow
that user to kill the system _completely_.

I think that "out_of_memory() cannot choose next OOM victim" problem
should be addressed before addressing "how to manage memory reserves"
problem.

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
