Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CC63E6B02DD
	for <linux-mm@kvack.org>; Sat, 23 May 2015 10:40:06 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so40102855pdb.0
        for <linux-mm@kvack.org>; Sat, 23 May 2015 07:40:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id uj9si8144489pbc.34.2015.05.23.07.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 23 May 2015 07:40:04 -0700 (PDT)
Subject: [PATCH] mm: Introduce timeout based OOM killing
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp>
Date: Sat, 23 May 2015 23:39:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: david@fromorbit.com, akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, vbabka@suse.cz, fernando_b1@lab.ntt.co.jp

>From 5999a1ebee5e611eaa4fa7be37abbf1fbdc8ef93 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 23 May 2015 22:42:20 +0900
Subject: [PATCH] mm: Introduce timeout based OOM killing

This proposal is an interim amendment, which focused on possibility of
backporting, of a problem that a Linux system can lock up forever due to
the behavior of memory allocator.

About current behavior of memory allocator:

  The memory allocator continues looping than fail the allocation requests
  unless "the requested page's order is larger than PAGE_ALLOC_COSTLY_ORDER"
  or "GFP_NORETRY flag is passed to the allocation requests" or "TIF_MEMDIE
  flag was set on the current thread by the OOM killer". As a result, the
  system can fall into forever stalling state without any kernel messages;
  resulting in unexplained system hang up troubles.
  ( https://lwn.net/Articles/627419/ )

  There are at least three cases where a thread falls into infinite loop
  inside the memory allocator.

  The first case is too_many_isolated() throttling loop inside
  shrink_inactive_list(). This throttling is intended for not to invoke the
  OOM killer unnecessarily, but a certain type of memory pressure can make it
  possible to let too_many_isolated() return true forever and nobody can
  escape from shrink_inactive_list(). If all threads trying to allocate memory
  are caught at too_many_isolated() loop, nobody can proceed.
  ( http://marc.info/?l=linux-kernel&m=140051046730378 and
  http://marc.info/?l=linux-mm&m=141671817211121 ; Reproducer program for this
  case is shared by only security@kernel.org members and some individuals. )

  The second case is allocation requests without __GFP_FS flag. This behavior
  is intended for not to invoke the OOM killer unnecessarily because there
  might be memory reclaimable by allocation requests with __GFP_FS flag. But
  it is possible that all threads doing __GFP_FS allocation requests (including
  kswapd which is capable of reclaiming memory with __GFP_FS flag) are blocked
  and nobody can perform memory reclaim operations. As a result, the memory
  allocator gives nobody a chance to invoke the OOM killer, falling into
  infinite loop.

  The third case is that the OOM victim is unable to release memory due to being
  blocked by invisible dependency after a __GFP_FS allocation request invoked
  the OOM killer. This case can occur when the OOM victim is blocked for waiting
  for a lock whereas a thread doing allocation request with the lock held is
  waiting for the OOM victim to release its mm struct. For example, we can
  reproduce this case on XFS filesystem by doing !__GFP_FS allocation requests
  with inode's mutex held. We can't expect that there are memory reclaimable by
  __GFP_FS allocations because the OOM killer is already invoked. And since
  there is already an OOM victim, the OOM killer is not invoked even if threads
  doing __GFP_FS allocations are running. As a result, allocation requests by a
  thread which is blocking an OOM victim can fall into infinite loop regardless
  of whether the allocation request is __GFP_FS or not. We call such state as
  OOM deadlock.

  There are programs which are protected from the OOM killer by setting
  /proc/$pid/oom_score_adj to -1000. /usr/sbin/sshd (an example of such
  programs) is helpful for restarting programs killed by the OOM killer
  because /usr/sbin/sshd can offer a mean to login to the system. However,
  under the OOM deadlock state, /usr/sbin/sshd cannot offer a mean to login
  because /usr/sbin/sshd will be stalling forever inside allocation requests
  (e.g. page faults).

  Those who set /proc/sys/vm/panic_on_oom to 0 are not expecting that the
  system falls into forever-inoperable state when the OOM killer is invoked.
  Instead, they are expecting that the system keeps operable state via the
  OOM killer when the OOM killer is invoked. But current behavior makes it
  impossible to login to the system, impossible to trigger SysRq-f (manually
  kill a process) due to "workqueue being fallen into infinite loop inside
  the memory allocator" or "SysRq-f choosing an OOM victim which already got
  TIF_MEMDIE flag and got stuck due to invisible dependency". As a result, they
  need to choose from SysRq-i (manually kill all processes), SysRq-c (manually
  trigger kernel panic) or SysRq-b (manually reset the system). Asking them to
  choose one of these SysRq is an unnecessarily large sacrifice. Also, they are
  carried penalty that they need to go to in front of console in order to issue
  a SysRq command, for infinite loop inside the memory allocator prevents them
  from logging into the system via /usr/sbin/sshd . And since administrators are
  using /proc/sys/vm/panic_on_oom with 0 without understanding that there is
  such sacrifice and penalty, they rush into support center that their systems
  had unexplained hang up problem. I do want to solve this circumstance.

  The above description is about the third case. But people are carried penalty
  for the first case and the second case that their systems fall into forever-
  inoperable state until they go to in front of console and trigger SysRq-f
  manually. The first case and the second case can happen regardless of
  /proc/sys/vm/panic_on_oom setting because the OOM killer is not involved, but
  administrators are using it without understanding that there are such cases.
  And, even if they rush into support center with vmcore captured via SysRq-c,
  we cannot analyze how long the threads spent looping inside the memory
  allocator because current implementation gives no hint.

About proposals for mitigating this problem:

  There has been several proposals which try to reduce the possibility of
  OOM deadlock without use of timeout. Two of them are explained here.

  One proposal is to allow small allocation requests to fail in order to avoid
  lockups caused by looping forever inside the memory allocator.
  ( https://lwn.net/Articles/636017/ and https://lwn.net/Articles/636797/ )
  But if such allocation requests start failing under memory pressure, a lot of
  memory allocation failure paths which have almost never been tested will be
  used, and various obscure bugs (e.g.
  http://marc.info/?l=dri-devel&m=142189369426813 ) will show up. Thus, it is
  too risky to backport. Also, as long as there are GFP_NOFAIL allocations
  (either explicit or open-coded retry loop), this approach cannot completely
  avoid OOM deadlock.

  If we allow small memory allocations to fail than loop inside the memory
  allocator, allocation requests caused by page faults start failing. As a side
  effect, either "the OOM killer is invoked and some mm struct is chosen by the
  OOM killer" or "that thread is killed by SIGBUS signal sent from the kernel"
  will occur when an allocation request by page faults failed.

  If important processes which are protected from the OOM killer by setting
  /proc/$pid/oom_score_adj to -1000 are killed by SIGBUS signal than kill
  OOM-killable processes via the OOM killer, /proc/$pid/oom_score_adj becomes
  useless. Also, we can observe kernel panic triggered by the global init
  process being killed by SIGBUS signal.
  ( http://marc.info/?l=linux-kernel&m=142676304911566 )

  Regarding !__GFP_FS allocation requests caused by page faults, there will
  be no difference (except for SIGBUS case explained above) between "directly
  invoking the OOM killer while looping inside the memory allocator" and
  "indirectly invoking the OOM killer after failing the allocation request".

  However, penalty carried by failing !__GFP_FS allocation requests not caused
  by page faults is large. For example, we experienced in Linux 3.19 that ext4
  filesystem started to trigger filesystem error actions (remount as read-only
  which prevents programs from working correctly, or kernel panic which stops
  the whole system) when memory is extremely tight because we unexpectedly
  allowed !__GFP_FS allocations to fail without retrying.
  ( http://marc.info/?l=linux-ext4&m=142443125221571 ) And we restored the
  original behavior for now.

  It is observed that this proposal (which allows memory allocations to fail)
  is likely carrying larger penalty than trying to keep the system operable
  state by invoking the OOM killer. Allowing small allocations to fail is not
  as easy as people think.

  Another proposal is to reserve some amount of memory which is used by
  allocation requests which can invoke the OOM killer, by manipulating zone
  watermark. ( https://lwn.net/Articles/642057/ ) But this proposal will not
  help if threads which are preventing the OOM victim are doing allocation
  requests which cannot invoke the OOM killer, or threads which are not
  preventing the OOM victim can consume the reserve by doing allocation
  requests which can invoke the OOM killer. Also, by manipulating zone
  watermark, there could be performance impact because direct reclaim is
  more likely to be invoked.

  Since the dependency needed for avoiding OOM deadlock is not visible to the
  memory allocator, we cannot avoid use of heuristic approaches for detecting
  the OOM deadlock state. Already proposed for many times, and again proposed
  here is to invoke the OOM killer based on timeout approach.
  ( https://lwn.net/Articles/635354/ )

About this proposal:

  (1) Stop use of ALLOC_NO_WATERMARKS by TIF_MEMDIE threads. Instead, set
      TIF_MEMDIE flag to all threads chosen by the OOM killer. And allow partial
      access to memory reserve in order to facilitate faster releasing of
      the mm struct which TIF_MEMDIE threads are using.
  (2) Let the OOM killer select next mm struct or trigger kernel panic if
      the mm struct which was previously chosen was not released within
      administrator controlled timeout period. This makes it possible to
      avoid locking up the system forever with __GFP_FS allocations.
  (3) Allow invoking the OOM killer than fail if !__GFP_FS allocations does
      not succeed within administrator controlled timeout period. This makes
      it possible to avoid locking up the system forever with !__GFP_FS
      allocations, while reducing penalty carried by failing memory allocations
      without retrying.

About changes made by (1):

  The memory allocator tries to reclaim memory by killing a process via invoking
  the OOM killer. A thread chosen by the OOM killer gets TIF_MEMDIE flag in
  order to facilitate faster releasing of the mm struct. But if the thread is
  unable to release the mm struct due to e.g. waiting for lock in unkillable
  state, the OOM killer is disabled and the system locks up forever unless
  somebody else releases memory.

  While the OOM killer sends SIGKILL signal to all threads which share the mm
  struct a thread the OOM killer chose, the OOM killer sets TIF_MEMDIE flag to
  only one thread. Since this behavior is based on an assumption that the thread
  which got TIF_MEMDIE flag can terminate quickly, this behavior helps only if
  the TIF_MEMDIE thread can terminate quickly. Therefore, currently, a local
  unprivileged user can trigger the OOM deadlock and make the system forever
  inoperable state. For example, running oom-sample1.c shown below on XFS
  filesystem can reproduce this problem.

  There is a mechanism called memory cgroup that can mitigate the OOM deadlock
  problem, but the system will anyway lock up if the memory cgroup failed to
  prevent the occurrence of the global OOM killer. Also, since there is
  possibility that the kernel was built without memory cgroup and/or the system
  administrators cannot afford configuring their systems to run all processes
  under appropriate memory cgroup, we want an approach which does not depend on
  memory cgroup. Therefore, in this proposal, we don't take memory cgroup into
  account, and we aim to avoid locking up the system forever under the worst
  cases.

  It is what we can observe by running oom-sample2.c or oom-sample3.c shown
  below on XFS filesystem for single instance that, the mm struct which
  the TIF_MEMDIE thread is using tends to be released faster if the cause of
  the OOM deadlock (i.e. invisible lock dependency) involves only threads
  sharing the mm struct (i.e. within single instance) by favoring all threads
  sharing the mm struct over favoring only one thread.
  ( http://marc.info/?l=linux-mm&m=142002495532320 )

  Therefore, this patch proposes that stop use of ALLOC_NO_WATERMARKS by
  TIF_MEMDIE threads. Instead, this patch sets TIF_MEMDIE flag to all threads
  chosen by the OOM killer. And this patch favors (i.e. allows partial access
  to memory reserve, but not full access like ALLOC_NO_WATERMARKS) all
  TIF_MEMDIE threads in order to facilitate faster releasing of the mm struct
  which TIF_MEMDIE threads are using.

  While changes made by (1) eliminate possibility of complete depletion of
  memory reserve (which should not happen unless TIF_MEMDIE thread itself does
  unlimited memory allocations for doing filesystem writeback etc.) via use of
  ALLOC_NO_WATERMARKS, these changes might be counterproductive if total amount
  of memory required by each TIF_MEMDIE thread exceeded amount of memory reserve
  allowed by these changes (which is unlikely though, for not all of TIF_MEMDIE
  threads start allocation requests at the same time because they are likely
  serialized by locks held by other threads). In the attached patch, the memory
  allocator favors only TIF_MEMDIE threads, but it might make sense to favor
  all fatal_signal_pending() threads or GFP_NOIO allocation requests.

  If changes made by (1) failed to avoid the OOM deadlock, changes made by (2)
  (which are for handling cases where !TIF_MEMDIE threads are preventing
  TIF_MEMDIE threads from terminating) will handle such case.

About changes made by (2):

  It is what we can observe by running oom-sample2.c or oom-sample3.c for
  multiple instances that, changes made by (1) does not help if the cause of
  the OOM deadlock involves threads not sharing the mm struct.
  This is because favoring only threads that share the mm struct cannot make
  the mm struct be released faster. Therefore, this patch chooses next mm
  struct via /proc/sys/vm/memdie_task_skip_secs or trigger kernel panic via
  /proc/sys/vm/memdie_task_panic_secs if previously selected mm struct was not
  released within administrator controlled timeout period.

  There have been strong objections about choosing next OOM victims based on
  timeout. Mainly three opinions shown below:

    (a) By selecting next mm struct, the number of TIF_MEMDIE threads increases
        and the possibility of completely depleting memory reserve increases.

    (b) We might no longer need to select next mm struct if we wait for a bit
        more.

    (c) The kernel panic will occur when there is no more mm struct to select.

  Regarding (a), changes made by (1) will avoid complete depletion of memory
  reserve.

  Regarding (b), such opinion is sometimes correct but sometimes wrong.
  It makes no sense that waiting TIF_MEMDIE thread for 10 minutes to release
  the mm struct if the TIF_MEMDIE thread is blocked waiting for locks to be
  released. Rather, it is counterproductive to wait forever if the TIF_MEMDIE
  thread is waiting for current thread doing memory allocation to release
  locks. Since the lock dependency is not visible to the memory allocator,
  there is no means to calculate how long we need to wait for the mm struct
  to be released. Also, since the risk of failing the allocation request is
  large (as I described above), I don't want to fail the allocation request
  without waiting. Therefore, this patch chooses next mm struct.

  Regarding (c), we can avoid massive concurrent killing by not choosing
  next mm struct until the timeout by (b) expires. And, something is
  definitely wrong with the system if the OOM deadlock remains even after
  killing all killable processes. Therefore, triggering kernel panic in
  order to take kdump followed by automatic reboot is considered preferable
  behavior than continue stalling.

About changes made by (3):

  Currently, the memory allocator does not invoke the OOM killer for !__GFP_FS
  allocation requests, for there might be memory reclaimable by __GFP_FS
  allocation requests. But such assumption is not always correct. If there is
  no thread doing __GFP_FS allocation requests, or there are threads doing
  __GFP_FS allocation requests but are unable to invoke the OOM killer because
  there are TIF_MEMDIE threads, the threads doing !__GFP_FS allocation requests
  will loop forever inside the memory allocator. For example, there is a state
  in too_many_isolated() where GFP_NOFS / GFP_NOIO allocation requests get false
  and GFP_KERNEL allocation requests get true. Therefore, depending of memory
  stress, it is possible that !__GFP_FS allocations left shrink_inactive_list()
  but are unable to invoke the OOM killer whereas __GFP_FS allocations cannot
  leave shrink_inactive_list() and therefore are unable to invoke the OOM
  killer. Even kswapd which is not affected by too_many_isolated(), it is
  possible that kswapd is blocked forever during reclaiming slab memory; e.g.
  we can observe that kswapd is blocked at mutex_lock() inside XFS writeback
  path. Therefore, supposition that memory will be eventually reclaimed if the
  current thread continues waiting is sometimes wrong because there is no
  guarantee that somebody else volunteers memory.

  Therefore, this patch gives up looping at out_of_memory() via
  /proc/sys/vm/memalloc_task_retry_secs if !__GFP_FS memory allocation requests
  did not complete within administrator controlled timeout period. This timeout
  is also applied for too_many_isolated_pages() loop in order to allow both
  __GFP_FS and !__GFP_FS allocation requests to eventually leave
  too_many_isolated_pages() and invoke the OOM killer, in case the system fell
  into state where nobody (including kswapd) can reclaim memory.

  Please note that it is /proc/sys/vm/memdie_task_skip_secs which determines
  whether the OOM killer chooses next mm struct or not.
  /proc/sys/vm/memalloc_task_retry_secs is intended for giving a chance to
  invoke the OOM killer, and current thread can block longer than
  /proc/sys/vm/memalloc_task_retry_secs if e.g. waiting for locks held inside
  shrinker functions.

  KOSAKI-san said at http://marc.info/?l=linux-kernel&m=140060242529604 that
  use of simple timeout in too_many_isolated_pages() resurrects false OOM-kill
  (a false positive). But since the cause of deadlock is that we are forever
  looping in the memory allocator and we don't want to crash the system by not
  looping in the memory allocator, timeout is the only possible approach which
  we can do for avoiding a false negative.
  Maybe we could reduce massive concurrent timeouts by ratelimiting (e.g. use
  global timeout counter) when 1000 threads arrived at too_many_isolated_pages()
  at the same time. But if a thread which the OOM victim is waiting for is one
  of these 1000 threads, how long will the system stall?

  Johannes said at http://marc.info/?l=linux-mm&m=143031212312459 that sleeping
  for too long can make the page allocator unusable when there is a genuine
  deadlock. The timeout counter used in this patch starts when outermost memory
  allocation request reached GFP_WAIT-able location in __alloc_pages_slowpath()
  (which was modified in line with Michal's comment to a patch at
  http://marc.info/?l=linux-mm&m=141671829611143 ) in order to make sure that
  non-outermost memory allocation requests by shrinker functions will not be
  blocked repeatedly.

  It is expected that allowing OOM killer for GFP_NOIO allocation requests
  after timeout helps avoiding problems listed below.

  (i)  problems where GFP_NOIO allocation requests used for writing back to or
       swapping out to disks are blocked forever

  (ii) problems where SysRq-f cannot be processed forever due to workqueue
       which is supposed to process SysRq-f is blocked forever at GFP_NOIO
       allocation requests

There would be administrators who want to preserve current behavior, even
after they understand the possibility of falling into forever-inoperable
state. This patch provides /proc/sys/vm/memalloc_task_warn_secs and
/proc/sys/vm/memdie_task_warn_secs which are just emitting warning messages.
We can preserve current behavior by setting /proc/sys/vm/memdie_task_skip_secs
/proc/sys/vm/memdie_task_panic_secs and /proc/sys/vm/memalloc_task_retry_secs
to 0, and by using proposed behavior only if /proc/sys/vm/memdie_task_skip_secs
is set to non-0.

So far I killed request_module() OOM deadlock
( https://bugzilla.redhat.com/show_bug.cgi?id=853474 ),
kthread_create() OOM deadlock ( https://lwn.net/Articles/611226/ ),
memory reclaim deadlock in shrinker functions in drm/ttm driver
( http://marc.info/?l=dri-devel&m=140707985130044 ).
Nonetheless I still encounter one stall after another
(e.g. http://marc.info/?l=linux-mm&m=142635485231639 ).

Now that the cause of memory allocation stall / deadlock became clear, and
we can't afford converting all locks/completions killable, and we can't let
small allocations to fail without testing all memory allocation failure paths.
I do want to put a period to ever-lasting forever-OOM-stalling problems.
It is time to introduce preventive measures than continue playing whack-a-mole
game. The timeout for (2) and (3) are designed for serving as preventive
measures for Linux users (via trying to survive by OOM-killing more) and as
debugging measures for Linux developers (via capturing vmcore for analysis).

At the beginning of this post, I said that this proposal is an interim
amendment. Fundamental amendment would be to deprecate use of memory allocation
functions without neither GFP_NOFAIL nor GFP_NORETRY. I think we can introduce
*_noretry() which acts like GFP_NORETRY, *_nofail() which acts like GFP_NOFAIL,
and *_retry() which acts like neither GFP_NOFAIL nor GFP_NORETRY in order to
force memory allocation callers to express how hard memory allocation should
try, with testing allocation failure paths with mandatory fault injection
mechanism like SystemTap ( http://marc.info/?l=linux-mm&m=142668221020620 ).

---------- oom-sample1.c ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
        static char buffer[1048576] = { };
        const int fd = open("/tmp/file",
                            O_WRONLY | O_CREAT | O_APPEND, 0600);
        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
        return 0;
}

static int memory_consumer(void *unused)
{
        const int fd = open("/dev/zero", O_RDONLY);
        unsigned long size;
        char *buf = NULL;
        sleep(3);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        read(fd, buf, size); /* Will cause OOM due to overcommit */
        return 0;
}

int main(int argc, char *argv[])
{
        clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        clone(memory_consumer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        pause();
        return 0;
}
---------- oom-sample1.c ----------
Example log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150516-1.txt.xz .

---------- oom-sample2.c ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
        static char buffer[4096] = { };
        const int fd = open("/tmp/file",
                            O_WRONLY | O_CREAT | O_APPEND | O_SYNC, 0600);
        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
        return 0;
}

static int memory_consumer(void *unused)
{
        const int fd = open("/dev/zero", O_RDONLY);
        unsigned long size;
        char *buf = NULL;
        sleep(1);
        unlink("/tmp/file");
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        read(fd, buf, size); /* Will cause OOM due to overcommit */
        return 0;
}

int main(int argc, char *argv[])
{
        int i;
        for (i = 0; i < 100; i++) {
                char *cp = malloc(4 * 1024);
                if (!cp ||
                    clone(file_writer,
                          cp + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL) == -1)
                        break;
        }
        memory_consumer(NULL);
        while (1)
                pause();
}
---------- oom-sample2.c ----------
Example log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150516-2.txt.xz .

---------- oom-sample3.c ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
        char buffer[128] = { };
        int fd;
        snprintf(buffer, sizeof(buffer) - 1, "/tmp/file.%u", getpid());
        fd = open(buffer, O_WRONLY | O_CREAT, 0600);
        unlink(buffer);
        while (write(fd, buffer, 1) == 1 && fsync(fd) == 0);
        return 0;
}

static int memory_consumer(void *unused)
{
        const int fd = open("/dev/zero", O_RDONLY);
        unsigned long size;
        char *buf = NULL;
        sleep(1);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        read(fd, buf, size); /* Will cause OOM due to overcommit */
        return 0;
}

int main(int argc, char *argv[])
{
        int i;
        for (i = 0; i < 1024; i++)
                close(i);
        if (fork() || fork() || setsid() == EOF)
                _exit(0);
        for (i = 0; i < 100; i++) {
                char *cp = malloc(4 * 1024);
                if (!cp ||
                    clone(i < 99 ? file_writer : memory_consumer,
                          cp + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL) == -1)
                        break;
        }
        while (1)
                pause();
        return 0;
}
---------- oom-sample3.c ----------

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  6 ++++
 include/linux/sched.h |  2 ++
 kernel/sysctl.c       | 46 ++++++++++++++++++++++++++
 mm/oom_kill.c         | 91 +++++++++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c       | 87 ++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c           | 13 ++++++++
 6 files changed, 235 insertions(+), 10 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 44b2f6f..46c9dd9 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -68,6 +68,7 @@ extern void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			       int order, const nodemask_t *nodemask,
 			       struct mem_cgroup *memcg);
+extern bool check_memalloc_delay(void);
 
 extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
@@ -99,4 +100,9 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_memdie_task_warn_secs;
+extern unsigned long sysctl_memdie_task_skip_secs;
+extern unsigned long sysctl_memdie_task_panic_secs;
+extern unsigned long sysctl_memalloc_task_warn_secs;
+extern unsigned long sysctl_memalloc_task_retry_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e370087..5ce591c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1790,6 +1790,8 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+	unsigned long memalloc_start;
+	unsigned long memdie_start;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 699571a..7e4a02a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -144,6 +144,12 @@ static const int cap_last_cap = CAP_LAST_CAP;
 static unsigned long hung_task_timeout_max = (LONG_MAX/HZ);
 #endif
 
+/*
+ * Used by proc_doulongvec_minmax of sysctl_memdie_task_*_secs and
+ * sysctl_memalloc_task_*_secs
+ */
+static unsigned long wait_timeout_max = (LONG_MAX/HZ);
+
 #ifdef CONFIG_INOTIFY_USER
 #include <linux/inotify.h>
 #endif
@@ -1535,6 +1541,46 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname       = "memdie_task_warn_secs",
+		.data           = &sysctl_memdie_task_warn_secs,
+		.maxlen         = sizeof(sysctl_memdie_task_warn_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+	{
+		.procname       = "memdie_task_skip_secs",
+		.data           = &sysctl_memdie_task_skip_secs,
+		.maxlen         = sizeof(sysctl_memdie_task_skip_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+	{
+		.procname       = "memdie_task_panic_secs",
+		.data           = &sysctl_memdie_task_panic_secs,
+		.maxlen         = sizeof(sysctl_memdie_task_panic_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+	{
+		.procname       = "memalloc_task_warn_secs",
+		.data           = &sysctl_memalloc_task_warn_secs,
+		.maxlen         = sizeof(sysctl_memalloc_task_warn_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
+	{
+		.procname       = "memalloc_task_retry_secs",
+		.data           = &sysctl_memalloc_task_retry_secs,
+		.maxlen         = sizeof(sysctl_memalloc_task_retry_secs),
+		.mode           = 0644,
+		.proc_handler   = proc_doulongvec_minmax,
+		.extra2         = &wait_timeout_max,
+	},
 	{ }
 };
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2b665da..ff5fb0b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -42,6 +42,11 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+unsigned long sysctl_memdie_task_warn_secs;
+unsigned long sysctl_memdie_task_skip_secs;
+unsigned long sysctl_memdie_task_panic_secs;
+unsigned long sysctl_memalloc_task_warn_secs;
+unsigned long sysctl_memalloc_task_retry_secs;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 #ifdef CONFIG_NUMA
@@ -117,6 +122,69 @@ found:
 	return t;
 }
 
+/* Timer for avoiding flooding of warning messages. */
+static bool memdie_delay_warned;
+static void memdie_reset_warned(unsigned long arg)
+{
+	xchg(&memdie_delay_warned, false);
+}
+static DEFINE_TIMER(memdie_warn_timer, memdie_reset_warned, 0, 0);
+
+/**
+ * is_killable_memdie_task - check task is not stuck with TIF_MEMDIE flag set.
+ * @p: Pointer to "struct task_struct".
+ *
+ * Setting TIF_MEMDIE flag to @p disables the OOM killer. However, @p could get
+ * stuck due to dependency which is invisible to the OOM killer. When @p got
+ * stuck, the system will stall for unpredictable duration (presumably forever)
+ * because the OOM killer is kept disabled.
+ *
+ * If @p remained stuck for /proc/sys/vm/memdie_task_warn_secs seconds, this
+ * function emits warning. Setting 0 to this interface disables this check.
+ *
+ * If @p remained stuck for /proc/sys/vm/memdie_task_skip_secs seconds, this
+ * function returns false as if TIF_MEMDIE flag was not set to @p. As a result,
+ * the OOM killer will try to find other killable processes at the risk of
+ * kernel panic when there is no other killable processes. Setting 0 to this
+ * interface disables this check.
+ *
+ * If @p remained stuck for /proc/sys/vm/memdie_task_panic_secs seconds, this
+ * function triggers kernel panic (for optionally taking vmcore for analysis).
+ * Setting 0 to this interface disables this check.
+ *
+ * Note that unless you set non-0 value to
+ * /proc/sys/vm/memalloc_task_retry_secs interface, the possibility of
+ * stalling the system for unpredictable duration (presumably forever) will
+ * remain. See check_memalloc_delay() for deadlock without the OOM killer.
+ */
+static bool is_killable_memdie_task(struct task_struct *p)
+{
+	const unsigned long start = p->memdie_start;
+	unsigned long spent;
+	unsigned long timeout;
+
+	/* If task does not have TIF_MEMDIE flag, there is nothing to do. */
+	if (!start)
+		return false;
+	spent = jiffies - start;
+	/* Trigger kernel panic after timeout. */
+	timeout = sysctl_memdie_task_panic_secs;
+	if (timeout && time_after(spent, timeout * HZ))
+		panic("Out of memory: %s (%u) did not die within %lu seconds.\n",
+		      p->comm, p->pid, timeout);
+	/* Emit warnings after timeout. */
+	timeout = sysctl_memdie_task_warn_secs;
+	if (timeout && time_after(spent, timeout * HZ) &&
+	    !xchg(&memdie_delay_warned, true)) {
+		pr_warn("Out of memory: %s (%u) can not die for %lu seconds.\n",
+			p->comm, p->pid, spent / HZ);
+		mod_timer(&memdie_warn_timer, jiffies + timeout * HZ);
+	}
+	/* Return true before timeout. */
+	timeout = sysctl_memdie_task_skip_secs;
+	return !timeout || time_before(spent, timeout * HZ);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -134,7 +202,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
-	return false;
+	return is_killable_memdie_task(p);
 }
 
 /**
@@ -416,10 +484,17 @@ static DECLARE_RWSEM(oom_sem);
  */
 void mark_tsk_oom_victim(struct task_struct *tsk)
 {
+	unsigned long start;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	/* Set current time for is_killable_memdie_task() check. */
+	start = jiffies;
+	if (!start)
+		start = 1;
+	tsk->memdie_start = start;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -437,6 +512,7 @@ void mark_tsk_oom_victim(struct task_struct *tsk)
  */
 void unmark_oom_victim(void)
 {
+	current->memdie_start = 0;
 	if (!test_and_clear_thread_flag(TIF_MEMDIE))
 		return;
 
@@ -581,12 +657,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * any. This mitigates mm->mmap_sem livelock when an oom killed thread
+	 * cannot exit because it requires the semaphore and its contended by
+	 * another thread trying to allocate memory itself. Note that this does
+	 * not help if the contended process does not share victim->mm. In that
+	 * case, is_killable_memdie_task() will detect it and take actions.
 	 */
 	rcu_read_lock();
 	for_each_process(p)
@@ -600,6 +675,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+			if (sysctl_memdie_task_skip_secs)
+				mark_tsk_oom_victim(p);
 		}
 	rcu_read_unlock();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index afd5459..9315ccc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2214,6 +2214,14 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
+	/*
+	 * Allow all OOM-killed threads to access part of memory reserves
+	 * than allow only one OOM-killed thread to access entire memory
+	 * reserves.
+	 */
+	if (min == mark && sysctl_memdie_task_skip_secs &&
+	    unlikely(test_thread_flag(TIF_MEMDIE)))
+		min -= min / 4;
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
 	if (!(alloc_flags & ALLOC_CMA))
@@ -2718,6 +2726,57 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 	return 0;
 }
 
+/* Timer for avoiding flooding of warning messages. */
+static bool memalloc_delay_warned;
+static void memalloc_reset_warned(unsigned long arg)
+{
+	xchg(&memalloc_delay_warned, false);
+}
+static DEFINE_TIMER(memalloc_warn_timer, memalloc_reset_warned, 0, 0);
+
+/**
+ * check_memalloc_delay - check current thread should invoke OOM killer.
+ *
+ * This function starts the OOM killer timer so that memory allocator can
+ * eventually invoke the OOM killer after timeout. Otherwise, we can end up
+ * with a system locked up forever because there is no guarantee that somebody
+ * else will volunteer some memory while we keep looping. This is critically
+ * important when there are OOM victims (i.e. atomic_read(&oom_victims) > 0)
+ * which means that there may be OOM victims which are waiting for current
+ * thread doing !__GFP_FS allocation to release locks while there is already
+ * unlikely reclaimable memory.
+ *
+ * If current thread continues failed to allocate memory for
+ * /proc/sys/vm/memalloc_task_warn_secs seconds, this function emits warning.
+ * Setting 0 to this interface disables this check.
+ *
+ * If current thread continues failed to allocate memory for
+ * /proc/sys/vm/memalloc_task_retry_secs seconds, this function returns true.
+ * As a result, the OOM killer will be invoked at the risk of killing some
+ * process when there is still reclaimable memory. Setting 0 to this interface
+ * disables this check.
+ *
+ * Note that unless you set non-0 value to /proc/sys/vm/memdie_task_skip_secs
+ * and/or /proc/sys/vm/memdie_task_panic_secs interfaces in addition to this
+ * interface, the possibility of stalling the system for unpredictable duration
+ * (presumably forever) will remain. See is_killable_memdie_task() for OOM
+ * deadlock.
+ */
+bool check_memalloc_delay(void)
+{
+	unsigned long spent = jiffies - current->memalloc_start;
+	unsigned long timeout = sysctl_memalloc_task_warn_secs;
+
+	if (timeout && time_after(spent, timeout * HZ) &&
+	    !xchg(&memalloc_delay_warned, true)) {
+		pr_warn("MemAlloc: %s (%u) is retrying for %lu seconds.\n",
+			current->comm, current->pid, spent / HZ);
+		mod_timer(&memalloc_warn_timer, jiffies + timeout * HZ);
+	}
+	timeout = sysctl_memalloc_task_retry_secs;
+	return timeout && time_after(spent, timeout * HZ);
+}
+
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
@@ -2764,7 +2823,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			 * keep looping as per should_alloc_retry().
 			 */
 			*did_some_progress = 1;
-			goto out;
+			if (!check_memalloc_delay())
+				goto out;
 		}
 		/* The OOM killer may not free memory on a specific node */
 		if (gfp_mask & __GFP_THISNODE)
@@ -2981,7 +3041,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() &&
 				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+				 (!sysctl_memdie_task_skip_secs &&
+				  unlikely(test_thread_flag(TIF_MEMDIE)))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA
@@ -3007,6 +3068,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
+	bool stop_timer_on_return = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
 
 	/*
@@ -3088,10 +3150,25 @@ retry:
 		goto nopage;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	if (!sysctl_memdie_task_skip_secs &&
+	    test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
 	/*
+	 * Start memory allocation timer. Since this function might be called
+	 * recursively via memory shrinker functions, start timer only if this
+	 * function is not recursively called.
+	 */
+	if (!current->memalloc_start) {
+		unsigned long start = jiffies;
+
+		if (!start)
+			start = 1;
+		current->memalloc_start = start;
+		stop_timer_on_return = true;
+	}
+
+	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
@@ -3185,6 +3262,10 @@ retry:
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
+	/* Stop memory allocation timer. */
+	if (stop_timer_on_return)
+		current->memalloc_start = 0;
+
 	return page;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37e90db..6cdfc38 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1465,6 +1465,12 @@ static int __too_many_isolated(struct zone *zone, int file,
  * allocation, such sleeping direct reclaimers may keep piling up on each CPU,
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
+ *
+ * However, there is no guarantee that somebody else is reclaiming memory when
+ * current thread is looping, for even kswapd can be blocked waiting for
+ * somebody doing memory allocation to release a lock. Therefore, we cannot
+ * wait forever, for current_is_kswapd() bypass logic does not help if kswapd
+ * is blocked at e.g. shrink_slab().
  */
 static int too_many_isolated(struct zone *zone, int file,
 			     struct scan_control *sc)
@@ -1476,6 +1482,13 @@ static int too_many_isolated(struct zone *zone, int file,
 		return 0;
 
 	/*
+	 * Check me: Are there paths which call this function without
+	 * initializing current->memalloc_start at __alloc_pages_slowpath() ?
+	 */
+	if (check_memalloc_delay())
+		return 0;
+
+	/*
 	 * __too_many_isolated(safe=0) is fast but inaccurate, because it
 	 * doesn't account for the vm_stat_diff[] counters.  So if it looks
 	 * like too_many_isolated() is about to return true, fall back to the
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
