Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5822A6B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 06:06:07 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so1521136wiw.1
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 03:06:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pe11si19464391wic.100.2015.01.09.03.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 03:06:06 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v3 0/5] OOM vs PM freezer fixes
Date: Fri,  9 Jan 2015 12:05:50 +0100
Message-Id: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hi,
this is an updated version of the patchset previous posted here:
http://marc.info/?l=linux-mm&m=141779771518056&w=2. 
Changes since then are:
- cleanups, doc and function renames as per Tejun
- __thaw_task moved to mark_tsk_oom_victim and frozen() check removed
  as it would be racy and it is not necessary anyway - per Tejun
- obvious typo in wait_event condition
- oom_killer_enable moved to thaw_processes before user tasks are thawed
  rather than thaw_kernel_threads which is even not called from s2ram resume
  path - per Tejun
- oom_killer_disable moved to freeze_processes to be more in sync with
  the enable.

I have tested the series in KVM with 100M RAM:
- many small tasks (20M anon mmap) which are triggering OOM continually
- s2ram which resumes automatically is triggered in a loop
	echo processors > /sys/power/pm_test
	while true
	do
		echo mem > /sys/power/state
		sleep 1s
	done
- simple module which allocates and frees 20M in 8K chunks. If it sees
  freezing(current) then it tries another round of allocation before calling
  try_to_freeze
- debugging messages of PM stages and OOM killer enable/disable/fail added
  and unmark_oom_victim is delayed by 1s after it clears TIF_MEMDIE and before
  it wakes up waiters.
- rebased on top of the current mmotm which means some necessary updates
  in mm/oom_kill.c. mark_tsk_oom_victim is now called under task_lock but
  I think this should be OK because __thaw_task shouldn't interfere with any
  locking down wake_up_process. Oleg?

As expected there are no OOM killed tasks after oom is disabled and
allocations requested by the kernel thread are failing after all the
tasks are frozen and OOM disabled. I wasn't able to catch a race where
oom_killer_disable would really have to wait but I kinda expected the
race is really unlikely.

[  242.609330] Killed process 2992 (mem_eater) total-vm:24412kB, anon-rss:2164kB, file-rss:4kB
[  243.628071] Unmarking 2992 OOM victim. oom_victims: 1
[  243.636072] (elapsed 2.837 seconds) done.
[  243.641985] Trying to disable OOM killer
[  243.643032] Waiting for concurent OOM victims
[  243.644342] OOM killer disabled
[  243.645447] Freezing remaining freezable tasks ... (elapsed 0.005 seconds) done.
[  243.652983] Suspending console(s) (use no_console_suspend to debug)
[  243.903299] kmem_eater: page allocation failure: order:1, mode:0x204010
[...]
[  243.992600] PM: suspend of devices complete after 336.667 msecs
[  243.993264] PM: late suspend of devices complete after 0.660 msecs
[  243.994713] PM: noirq suspend of devices complete after 1.446 msecs
[  243.994717] ACPI: Preparing to enter system sleep state S3
[  243.994795] PM: Saving platform NVS memory
[  243.994796] Disabling non-boot CPUs ...

The first 2 patches are simple cleanups for OOM. They should go in
regardless the rest IMO.
Patches 3 and 4 are trivial printk -> pr_info conversion and they should
go in ditto.
The main patch is the last one and I would appreciate acks from Tejun
and Rafael. I think the OOM part should be OK (except for __thaw_task
vs. task_lock where a look from Oleg would appreciated) but I am not
so sure I haven't screwed anything in the freezer code. I have found
several surprises there.

The patchset is based on the current mmotm tree (mmotm-2015-01-07-17-07).
I think it make more sense if it is routed via Andrew due to dependences on
other OOM killer patches.

Shortlog says:
Michal Hocko (5):
      oom: add helpers for setting and clearing TIF_MEMDIE
      oom: thaw the OOM victim if it is frozen
      PM: convert printk to pr_* equivalent
      sysrq: convert printk to pr_* equivalent
      oom, PM: make OOM detection in the freezer path raceless

And diffstat:
 drivers/staging/android/lowmemorykiller.c |   7 +-
 drivers/tty/sysrq.c                       |  23 ++---
 include/linux/oom.h                       |  18 ++--
 kernel/exit.c                             |   3 +-
 kernel/power/process.c                    |  76 +++++----------
 mm/memcontrol.c                           |   4 +-
 mm/oom_kill.c                             | 149 ++++++++++++++++++++++++++----
 mm/page_alloc.c                           |  17 +---
 8 files changed, 185 insertions(+), 112 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
