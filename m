Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 596346B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 23:07:08 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so199742638pac.2
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 20:07:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c2si23243403pfb.198.2016.06.18.20.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 18 Jun 2016 20:07:07 -0700 (PDT)
Subject: Re: kernel, mm: NULL deref in copy_process while OOMing
References: <57618763.5010201@oracle.com>
 <20160616093951.GD6836@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <915586fa-13f6-e685-bf9d-9a87dc21739a@I-love.SAKURA.ne.jp>
Date: Sun, 19 Jun 2016 12:06:53 +0900
MIME-Version: 1.0
In-Reply-To: <20160616093951.GD6836@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/06/16 18:39, Michal Hocko wrote:
> On Wed 15-06-16 12:50:43, Sasha Levin wrote:
>> Hi all,
>>
>> I'm seeing the following NULL ptr deref in copy_process right after a bunch
>> of OOM killing activity on -next kernels:
>>
>> Out of memory (oom_kill_allocating_task): Kill process 3477 (trinity-c159) score 0 or sacrifice child
>> Killed process 3477 (trinity-c159) total-vm:3226820kB, anon-rss:36832kB, file-rss:1640kB, shmem-rss:444kB
>> oom_reaper: reaped process 3477 (trinity-c159), now anon-rss:0kB, file-rss:0kB, shmem-rss:444kB
>> Out of memory (oom_kill_allocating_task): Kill process 3450 (trinity-c156) score 0 or sacrifice child
>> Killed process 3450 (trinity-c156) total-vm:3769768kB, anon-rss:36832kB, file-rss:1652kB, shmem-rss:508kB
>> oom_reaper: reaped process 3450 (trinity-c156), now anon-rss:0kB, file-rss:0kB, shmem-rss:572kB
>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000150
>> IP: copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
>> PGD 1ff944067 PUD 1ff929067 PMD 0
>> Oops: 0002 [#1] PREEMPT SMP KASAN
>> Modules linked in:
>> CPU: 18 PID: 8761 Comm: trinity-main Not tainted 4.7.0-rc3-sasha-02101-g1e1b9fa #3108
> 
> Is this a common parent of the oom killed children?
> 
>> task: ffff880165564000 ti: ffff880337ad0000 task.ti: ffff880337ad0000
>> RIP: copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
> 
> IIUC this should be:
> _do_fork
>   copy_process
>     copy_mm
>       dup_mm
>         dup_mmap
> 	  if (tmp->vm_flags & VM_DENYWRITE)
> 	    atomic_dec(&inode->i_writecount);
> 
> I am not really sure how f->f_inode can become NULL when file should pin
> the inode AFAIR, and VMA should pin the file. Anyway this shouldn't be
> directly related to the OOM killer or at least the recent changes
> in that area because the oom reaper doesn't touch VMAs file.

These OOM messages say that oom_kill_allocating_task != 0 is used.
That is, a __GFP_FS allocation by a child process which is trying to
duplicate the parent's mm_struct was killed by the OOM killer and
reaped by the OOM reaper. I guess that mmap related stuff are not
fully initialized (or consistent) yet while the OOM reaper assumed
that it is safe to access such child's mmap related stuff.

So, if this bug is reproducible (I thing it is), first try to reproduce
this bug without the OOM reaper enabled (i.e. comment out the

subsys_initcall(oom_init)

line in mm/oom_kill.c ).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
