Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7CD6B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 07:22:50 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so34910029pab.13
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 04:22:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id tk5si15303409pac.190.2015.02.16.04.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Feb 2015 04:22:48 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141220223504.GI15665@dastard>
	<201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
In-Reply-To: <20141230112158.GA15546@dhcp22.suse.cz>
Message-Id: <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
Date: Mon, 16 Feb 2015 20:23:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> > but I think we need to be prepared for cases where sending SIGKILL to
> > all threads sharing the same memory does not help.
> 
> Sure, unkillable tasks are a problem which we have to handle. Having
> GFP_KERNEL allocations looping without way out contributes to this which
> is sad but your current data just show that sometimes it might take ages
> to finish even without that going on.

Hello. Can we resume TIF_MEMDIE stall discussion?

I'd like to propose

  (1) Make several locks killable.

  (2) Implement TIF_MEMDIE timeout.

  (3) Replace kmalloc() with kmalloc_nofail() and kmalloc_noretry().

for handling TIF_MEMDIE stall problems.



(1) Make several locks killable.

  On Linux 3.19, running below command line as an unprivileged user
  on a system with 4 CPUs / 2GB RAM / no swap can make the system unusable.

  $ for i in `seq 1 100`; do dd if=/dev/zero of=/tmp/file bs=104857600 count=100 & done

---------- An example with ext4 partition ----------
(...snipped...)
[  369.902616] dd              D ffff88007fc12d00     0  9113   6418 0x00000080
[  369.904867]  ffff88007b460890 0000000000012d00 ffff88007b28ffd8 0000000000012d00
[  369.907254]  ffff88007b460890 ffff88007fc12d80 ffff88007a6eb360 0000000000000001
[  369.909855]  ffffffff810946cb 00000000000025f6 ffffffff8108ef1d 0000000000000000
[  369.912054] Call Trace:
[  369.913175]  [<ffffffff810946cb>] ? put_prev_entity+0x5b/0x2c0
[  369.914960]  [<ffffffff8108ef1d>] ? pick_next_entity+0x9d/0x170
[  369.916778]  [<ffffffff8109157e>] ? set_next_entity+0x4e/0x60
[  369.918634]  [<ffffffff81097953>] ? pick_next_task_fair+0x453/0x520
[  369.920530]  [<ffffffff8100c6e0>] ? __switch_to+0x240/0x570
[  369.922263]  [<ffffffff815799f9>] ? schedule_preempt_disabled+0x9/0x10
[  369.924161]  [<ffffffff8157af25>] ? __mutex_lock_slowpath+0xb5/0x120
[  369.926106]  [<ffffffff8157afa6>] ? mutex_lock+0x16/0x25
[  369.927800]  [<ffffffffa01f3acc>] ? ext4_file_write_iter+0x7c/0x3a0 [ext4]
[  369.929778]  [<ffffffff81280fbc>] ? __clear_user+0x1c/0x40
[  369.931491]  [<ffffffff8112c876>] ? iov_iter_zero+0x66/0x2d0
[  369.933235]  [<ffffffff811732a3>] ? new_sync_write+0x83/0xd0
[  369.934977]  [<ffffffff8117397d>] ? vfs_write+0xad/0x1f0
[  369.936703]  [<ffffffff8101b57b>] ? syscall_trace_enter_phase1+0x19b/0x1b0
[  369.938674]  [<ffffffff8117459d>] ? SyS_write+0x4d/0xc0
[  369.940336]  [<ffffffff8157d329>] ? system_call_fastpath+0x12/0x17
(...snipped...)
[  498.421741] SysRq : Manual OOM execution
[  498.423627] kworker/3:3 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
(...snipped...)
[  498.952807] Out of memory: Kill process 9113 (dd) score 57 or sacrifice child
[  498.954450] Killed process 9113 (dd) total-vm:210340kB, anon-rss:102500kB, file-rss:0kB
(...snipped...)
[  502.068921] SysRq : Manual OOM execution
[  502.070825] kworker/3:3 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
(...snipped...)
[  502.618222] Out of memory: Kill process 9113 (dd) score 57 or sacrifice child
[  502.620016] Killed process 9113 (dd) total-vm:210340kB, anon-rss:102500kB, file-rss:0kB
(...snipped...)
[  503.900554] SysRq : Manual OOM execution
[  503.902387] kworker/3:3 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
(...snipped...)
[  504.410444] Out of memory: Kill process 9113 (dd) score 57 or sacrifice child
[  504.412221] Killed process 9113 (dd) total-vm:210340kB, anon-rss:102500kB, file-rss:0kB
(...snipped...)
---------- An example with ext4 partition ----------

---------- An example with xfs partition ----------
(...snipped...)
[  127.135041] Out of memory: Kill process 2505 (dd) score 59 or sacrifice child
[  127.136460] Killed process 2505 (dd) total-vm:210340kB, anon-rss:102464kB, file-rss:1728kB
(...snipped...)
[  243.672302] dd              D ffff88005bd27cb8 12776  2505   2386 0x00100084
[  243.674066]  ffff88005bd27cb8 ffff88005bd27c98 ffff88007850c740 0000000000014080
[  243.676005]  0000000000000000 ffff88005bd27fd8 0000000000014080 ffff88005835d740
[  243.677916]  ffff88007850c740 0000000000000014 ffff8800669bee50 ffff8800669bee54
[  243.679823] Call Trace:
[  243.680478]  [<ffffffff816b2799>] schedule_preempt_disabled+0x29/0x70
[  243.682047]  [<ffffffff816b43d5>] __mutex_lock_slowpath+0x95/0x100
[  243.683548]  [<ffffffff816b83e8>] ? page_fault+0x28/0x30
[  243.684875]  [<ffffffff816b4463>] mutex_lock+0x23/0x37
[  243.686146]  [<ffffffff8129df6c>] xfs_file_buffered_aio_write+0x6c/0x240
[  243.687791]  [<ffffffff813497b5>] ? __clear_user+0x25/0x50
[  243.689121]  [<ffffffff8117294d>] ? iov_iter_zero+0x6d/0x2e0
[  243.690511]  [<ffffffff8129e1b8>] xfs_file_write_iter+0x78/0x110
[  243.691990]  [<ffffffff811beb31>] new_sync_write+0x81/0xb0
[  243.693329]  [<ffffffff811bf2a7>] vfs_write+0xb7/0x1f0
[  243.694581]  [<ffffffff811bfeb6>] SyS_write+0x46/0xb0
[  243.695834]  [<ffffffff81109196>] ? __audit_syscall_exit+0x236/0x2e0
[  243.697376]  [<ffffffff816b64a9>] system_call_fastpath+0x12/0x17
(...snipped...)
[  291.433296] dd              D ffff88005bd27cb8 12776  2505   2386 0x00100084
[  291.433297]  ffff88005bd27cb8 ffff88005bd27c98 ffff88007850c740 0000000000014080
[  291.433298]  0000000000000000 ffff88005bd27fd8 0000000000014080 ffff88005835d740
[  291.433298]  ffff88007850c740 0000000000000014 ffff8800669bee50 ffff8800669bee54
[  291.433299] Call Trace:
[  291.433300]  [<ffffffff816b2799>] schedule_preempt_disabled+0x29/0x70
[  291.433301]  [<ffffffff816b43d5>] __mutex_lock_slowpath+0x95/0x100
[  291.433302]  [<ffffffff816b83e8>] ? page_fault+0x28/0x30
[  291.433303]  [<ffffffff816b4463>] mutex_lock+0x23/0x37
[  291.433304]  [<ffffffff8129df6c>] xfs_file_buffered_aio_write+0x6c/0x240
[  291.433306]  [<ffffffff813497b5>] ? __clear_user+0x25/0x50
[  291.433307]  [<ffffffff8117294d>] ? iov_iter_zero+0x6d/0x2e0
[  291.433308]  [<ffffffff8129e1b8>] xfs_file_write_iter+0x78/0x110
[  291.433309]  [<ffffffff811beb31>] new_sync_write+0x81/0xb0
[  291.433311]  [<ffffffff811bf2a7>] vfs_write+0xb7/0x1f0
[  291.433312]  [<ffffffff811bfeb6>] SyS_write+0x46/0xb0
[  291.433313]  [<ffffffff81109196>] ? __audit_syscall_exit+0x236/0x2e0
[  291.433314]  [<ffffffff816b64a9>] system_call_fastpath+0x12/0x17
(...snipped...)
---------- An example with xfs partition ----------

  This is because the OOM killer happily tries to kill a process which is
  blocked at unkillable mutex_lock(). If locks shown above were killable,
  we can reduce the possibility of getting stuck.

  I didn't check whether it has livelocked or not. But too slow to wait is
  not acceptable. Oh, why every thread trying to allocate memory has to repeat
  the loop that might defer somebody who can make progress if CPU time was
  given? I wish only somebody like kswapd repeats the loop on behalf of all
  threads waiting at memory allocation slowpath...

(2) Implement TIF_MEMDIE timeout.

  While the command line shown above is an artificial stresstest, I'm seeing
  troubles on real KVM systems where the guests hang entirely with many
  processes being blocked at jbd2_journal_commit_transaction() or
  jbd2_journal_get_write_access(). The root cause of guest's stall is not yet
  identified but is at least independent with TIF_MEMDIE. However, cron jobs
  which are blocked at those functions after I/O stall begins exhaust all of
  the system's memory and make the situation worse (e.g. load average exceeded
  7000 on a guest with 2 CPUs as of occurrence of the OOM killer livelock).

  Unkillable locks in non-critical paths can be replaced with killable locks.
  But there are critical paths where fail-on-SIGKILL can lead to unwanted
  results (e.g. filesystem's error action such as remount as r/o or call
  panic() being taken), there are locks (e.g. rw_semaphore used by mmap_sem)
  where killable version does not exist, and there are wait_for_completion()
  calls where killable version does not worth complicating the code.

  If TIF_MEMDIE timeout were implemented, we can cope with the OOM killer
  livelock problem by choosing more OOM victims (for survive strategy) or
  calling panic() (for debug and reboot strategy).

(3) Replace kmalloc() with kmalloc_nofail() and kmalloc_noretry().

  Currently small allocations are implicitly treated like __GFP_NOFAIL
  unless TIF_MEMDIE is set. But silently changing small allocations like
  __GFP_NORETRY will cause obscure bugs. If TIF_MEMDIE timeout is implemented,
  we will no longer worry about unkillable tasks which is retrying forever at
  memory allocation; instead we kill more OOM victims and satisfy the request.
  Therefore, we could introduce kmalloc_nofail(size, gfp) which does
  kmalloc(size, gfp | __GFP_NOFAIL) (i.e. invoke the OOM killer) and
  kmalloc_noretry(size, gfp) which does kmalloc(size, gfp | __GFP_NORETRY)
  (i.e. do not invoke the OOM killer), and switch from kmalloc() to either
  kmalloc_noretry() or kmalloc_nofail(). Those who are doing smaller than
  PAGE_SIZE bytes allocations would wish to switch from kmalloc() to
  kmalloc_nofail() and eliminate untested memory allocation failure paths.
  Those who are well prepared for memory allocation failures would wish to
  switch from kmalloc() to kmalloc_noretry(). Eventually, kmalloc() which is
  implicitly treating small allocations like __GFP_NOFAIL and invoking the
  OOM killer will be abolished.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
