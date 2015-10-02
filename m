Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id CDAAC82F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:06:23 -0400 (EDT)
Received: by obbda8 with SMTP id da8so81306609obb.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:06:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r184si5940731oih.53.2015.10.02.06.06.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 06:06:22 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
	<20151001144820.GI24077@dhcp22.suse.cz>
In-Reply-To: <20151001144820.GI24077@dhcp22.suse.cz>
Message-Id: <201510022206.BHF13585.MSOHOFFLQtVOJF@I-love.SAKURA.ne.jp>
Date: Fri, 2 Oct 2015 22:06:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> On Mon 28-09-15 15:24:06, David Rientjes wrote:
> > I agree that i_mutex seems to be one of the most common offenders.  
> > However, I'm not sure I understand why holding it while trying to allocate 
> > infinitely for an order-0 allocation is problematic wrt the proposed 
> > kthread. 
> 
> I didn't say it would be problematic. We are talking past each other
> here. All I wanted to say was that a separate kernel oom thread wouldn't
> _help_ with the lock dependencies.
> 
Oops. I misunderstood that you are skeptical about memory unmapping approach
due to lock dependency. But rather, you are skeptical about use of a dedicated
kernel thread for memory unmapping approach.

> > The kthread itself need only take mmap_sem for read.  If all 
> > threads sharing the mm with a victim have been SIGKILL'd, they should get 
> > TIF_MEMDIE set when reclaim fails and be able to allocate so that they can 
> > drop mmap_sem. 
> 
> which is the case if the direct oom context used trylock...
> So just to make it clear. I am not objecting a specialized oom kernel
> thread. It would work as well. I am just not convinced that it is really
> needed because the direct oom context can use trylock and do the same
> work directly.

Well, I think it depends on from where we call memory unmapping code.

The first candidate is oom_kill_process() because it is a location where
the mm struct to unmap is determined. But since select_bad_process()
aborts upon encountering a TIF_MEMDIE task, we will fail to call memory
unmapping code again if the first down_trylock(&mm->mmap_sem) attempt in
oom_kill_process() failed. (Here I assumed that we allow all OOM victims
to access memory reserves so that subsequent down_trylock(&mm->mmap_sem)
attempts could succeed.)

The second candidate is select_bad_process() because it is a location
where we can call memory unmapping code again upon encountering a
TIF_MEMDIE task.

The third candidate is caller of out_of_memory() because it is a location
where we can call memory unmapping code again even when the OOM victims
are blocked. (Our discussion seems to assume that TIF_MEMDIE tasks can
make forward progress and die. But since TIF_MEMDIE tasks might encounter
unkillable locks after returning from allocation (e.g.
http://lkml.kernel.org/r/201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp ),
it will be safer not to assume that out_of_memory() can be always called.
So, I thought that a dedicated kernel thread makes it easy to call memory
unmapping code periodically again and again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
