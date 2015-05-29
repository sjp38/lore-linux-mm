Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 883356B0073
	for <linux-mm@kvack.org>; Fri, 29 May 2015 08:40:52 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so57815457pad.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 05:40:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id dh15si8329503pac.23.2015.05.29.05.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 May 2015 05:40:51 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150526170213.GB14955@dhcp22.suse.cz>
	<201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
	<20150527164505.GD27348@dhcp22.suse.cz>
	<201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
	<20150528180524.GB2321@dhcp22.suse.cz>
In-Reply-To: <20150528180524.GB2321@dhcp22.suse.cz>
Message-Id: <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
Date: Fri, 29 May 2015 21:40:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 28-05-15 06:59:32, Tetsuo Handa wrote:
> > I just imagined a case where p is blocked at down_read() in acct_collect() from
> > do_exit() when p is sharing mm with other processes, and other process is doing
> > blocking operation with mm->mmap_sem held for writing. Is such case impossible?
> 
> It is very much possible and I have missed this case when proposing
> my alternative. The other process could be doing an address space
> operation e.g. mmap which requires an allocation.

Are there locations that do memory allocations with mm->mmap_sem held for
writing? Is it possible that thread1 is doing memory allocation between
down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem),
thread2 sharing the same mm is waiting at down_read(&current->mm->mmap_sem),
and the OOM killer invoked by thread3 chooses thread2 as the OOM victim and
sets TIF_MEMDIE to thread2?

If yes, I think setting TIF_MEMDIE to only one thread can cause deadlock
problem when mm is shared by multiple threads, for thread2 cannot be terminated
because thread1 will not call up_write(&current->mm->mmap_sem) until thread1's
memory allocation completes, resulting in hang up. If thread2->mm &&
task_will_free_mem(thread2) was true when the OOM killer chooses thread2 as
the OOM victim, it will result in annoying silent hang up.

If there are locations that do memory allocations with mm->mmap_sem held for
writing, don't we need to send SIGKILL and set TIF_MEMDIE to all threads which
could block the OOM victim?

Maybe we can use "struct mm_struct"->"bool chosen_by_oom_killer" and checking
for (current->mm && current->mm->chosen_by_oom_killer) than
test_thread_flag(TIF_MEMDIE) inside the memory allocator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
