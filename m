Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 104AB6B0325
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:43:52 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id b80so871532iob.23
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:43:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d3sor1058146itg.85.2017.12.05.18.43.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 18:43:51 -0800 (PST)
Date: Tue, 5 Dec 2017 18:43:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

I'd like to understand the synchronization between the oom_reaper's 
unmap_page_range() and exit_mmap().  The latter does not hold 
mm->mmap_sem: it's supposed to be the last thread operating on the mm 
before it is destroyed.

If unmap_page_range() races with unmap_vmas(), we trivially call 
page_remove_rmap() twice on the same page:

BUG: Bad page map in process oom_reaper  pte:6353826300000000 pmd:00000000
addr:00007f50cab1d000 vm_flags:08100073 anon_vma:ffff9eea335603f0 mapping:          (null) index:7f50cab1d
file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
CPU: 2 PID: 1001 Comm: oom_reaper
Call Trace:
 [<ffffffffa4bd967d>] dump_stack+0x4d/0x70
 [<ffffffffa4a03558>] unmap_page_range+0x1068/0x1130
 [<ffffffffa4a2e07f>] __oom_reap_task_mm+0xd5/0x16b
 [<ffffffffa4a2e226>] oom_reaper+0xff/0x14c
 [<ffffffffa48d6ad1>] kthread+0xc1/0xe0

And there are more examples of badness from an unmap_page_range() racing 
with unmap_vmas().  In this case, MMF_OOM_SKIP is doing two things: (1) 
avoiding additional oom kills until unmap_vmas() returns and (2) avoid the 
oom_reaper working on the mm after unmap_vmas().  In (2), there's nothing 
preventing the oom reaper from calling unmap_page_range() in parallel with 
the final thread doing unmap_vmas() -- we no longer do mmget() to prevent 
exit_mmap() from being called.

I don't think that we can allow the oom reaper's unmap_page_range() to 
race with unmap_vmas().  If we can, what allows this if we don't either 
increment mm->mm_users in the oom reaper or hold mm->mmap_sem for write in 
exit_mmap()?

One way to solve the issue is to have two mm flags: one to indicate the mm 
is entering unmap_vmas(): set the flag, do down_write(&mm->mmap_sem); 
up_write(&mm->mmap_sem), then unmap_vmas().  The oom reaper needs this 
flag clear, not MMF_OOM_SKIP, while holding down_read(&mm->mmap_sem) to be 
allowed to call unmap_page_range().  The oom killer will still defer 
selecting this victim for MMF_OOM_SKIP after unmap_vmas() returns.

The result of that change would be that we do not oom reap from any mm 
entering unmap_vmas(): we let unmap_vmas() do the work itself and avoid 
racing with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
