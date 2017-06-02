Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7546B0292
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 07:13:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a99so76125813oic.8
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 04:13:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s78si9506833oih.175.2017.06.02.04.13.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 04:13:47 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601115936.GA9091@dhcp22.suse.cz>
	<201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
	<20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
In-Reply-To: <20170602071818.GA29840@dhcp22.suse.cz>
Message-Id: <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
Date: Fri, 2 Jun 2017 20:13:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
>> Michal Hocko wrote:
>>> On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
>>>> Cong Wang has reported a lockup when running LTP memcg_stress test [1].
>>>
>>> This seems to be on an old and not pristine kernel. Does it happen also
>>> on the vanilla up-to-date kernel?
>>
>> 4.9 is not an old kernel! It might be close to the kernel version which
>> enterprise distributions would choose for their next long term supported
>> version.
>>
>> And please stop saying "can you reproduce your problem with latest
>> linux-next (or at least latest linux)?" Not everybody can use the vanilla
>> up-to-date kernel!
>
> The changelog mentioned that the source of stalls is not clear so this
> might be out-of-tree patches doing something wrong and dump_stack
> showing up just because it is called often. This wouldn't be the first
> time I have seen something like that. I am not really keen on adding
> heavy lifting for something that is not clearly debugged and based on
> hand waving and speculations.

You are asking users to prove that the problem is indeed in the MM subsystem,
but you are thinking that kmallocwd which helps users to check whether the
problem is indeed in the MM subsystem is not worth merging into mainline.
As a result, we have to try things based on what you think handwaving and
speculations. This is a catch-22. If you don't want handwaving/speculations,
please please do provide a mechanism for checking (a) and (b) shown later.

>
>> What I'm pushing via kmallocwd patch is to prepare for overlooked problems
>> so that enterprise distributors can collect information and identify what
>> changes are needed to be backported.
>>
>> As long as you ignore problems not happened with latest linux-next (or
>> at least latest linux), enterprise distribution users can do nothing.
>>
>>>
>>> [...]
>>>> Therefore, this patch uses a mutex dedicated for warn_alloc() like
>>>> suggested in [3].
>>>
>>> As I've said previously. We have rate limiting and if that doesn't work
>>> out well, let's tune it. The lock should be the last resort to go with.
>>> We already throttle show_mem, maybe we can throttle dump_stack as well,
>>> although it sounds a bit strange that this adds so much to the picture.
>>
>> Ratelimiting never works well. It randomly drops information which is
>> useful for debugging. Uncontrolled concurrent dump_stack() causes lockups.
>> And restricting dump_stack() drops more information.
>
> As long as the dump_stack can be a source of the stalls, which I am not
> so sure about, then we should rate limit it.

I'm to some degree suspecting (a) shown later, but I can't prove it due to
lack of a mechanism for debugging. Looking at timestamps of output, the delay
between lines is varying; sometimes multiple lines are printed within one
microsecond, sometimes two lines are printed with ten or twenty milliseconds.
This fluctuation state resembles what I can observe when I put the system under
overstressed condition (i.e. out of CPU time for making progress). But again,
I can't prove it because I'm also suspecting (b) shown later due to use of
memcg and multiple nodes.

Since the server used in that report is Dell Inc. PowerEdge C6220/03C9JJ,
I estimate that the total CPUs installed is 12 cores * 2 slots = 24 CPUs.
(I can confirm that at least 21 CPUs are recognized from "CPU: 20" output.)
Since Cong was trying to run memcg stress test with 150 memcg groups, I
estimate that there were 150 threads running. This means that the system
might have been put under memory pressure where total number of threads
looping inside the page allocator dominates total number of available CPUs.
Since Cong assigned 0.5GB memory limit on each memcg group on a server
which has 64GB of memory, I estimate that the system might experience
non-memcg OOM due to 150 * 0.5G > 64G.

Then, this situation resembles my testcase where I put the system under
memory pressure where total number of threads looping inside the page
allocator (about one hundred or so) dominates total number of available
CPUs (i.e. 4) on a system with only 2GB or 4GB RAM (and no swap partition).
What I can observe is that all CPU times are spent for pointless busy loop
inside __alloc_pages_slowpath() and makes the OOM killer unable to send
SIGKILL, and the system stalls to the level where printk() flooding happens
due to uncontrolled concurrent warn_alloc().

And your response is always "Your system is already DOSed. I don't make
changes for such system at all." and the situation remained unchanged
until this moment (i.e. Cong's report). It is possible that

  (a) Cong is unintentionally making the system under DOS like
      my non-memcg testcase while Cong just wanted to test memcg

but it is also possible that

  (b) Cong is reporting an unnoticed bug in the MM subsystem

as well as

  (c) Cong is reporting a bug which does not exist in the latest
      linux-next kernel

and you are suspecting only (c) without providing a mechanism for
checking (a) and (b). kmallocwd helps users to check (a) and (b)
whereas printk() flooding due to uncontrolled concurrent warn_alloc()
prevents users from checking (a) and (b). This is really bad.

>
>> What we should do is to yield CPU time to operations which might do useful
>> things (let threads not doing memory allocation; e.g. let printk kernel
>> threads to flush pending buffer, let console drivers write the output to
>> consoles, let watchdog kernel threads report what is happening).
>
> yes we call that preemptive kernel...
>

And the page allocator is not preemptive. It does not yield enough CPU
time for other threads to do potentially useful things, allowing (a) to
happen.

>> When memory allocation request is stalling, serialization via waiting
>> for a lock does help.
>
> Which will mean that those unlucky ones which stall will stall even more
> because they will wait on a lock with potentially many others. While
> this certainly is a throttling mechanism it is also a big hammer.

According to my testing, the cause of stalls with flooding of printk() from
warn_alloc() is exactly the lack of enough CPU time because the page
allocator continues busy looping when memory allocation is stalling.



Andrew Morton wrote:
> I'm thinking we should serialize warn_alloc anyway, to prevent the
> output from concurrent calls getting all jumbled together?

Yes. According to my testing, serializing warn_alloc() can not yield
enough CPU time because warn_alloc() is called only once per 10 seconds.
Serializing

-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {

in __alloc_pages_may_oom() can yield enough CPU time to solve the stalls.

>
> I'm not sure I buy the "this isn't a mainline kernel" thing. 
> warn_alloc() obviously isn't very robust, but we'd prefer that it be
> robust to peculiar situations, wild-n-wacky kernel patches, etc.  It's
> a low-level thing and it should Just Work.

Michal is clear that he won't make warn_alloc() robust, please see
http://lkml.kernel.org/r/20161019115525.GH7517@dhcp22.suse.cz .
And since kmallocwd is stalling, I'm trying to make warn_alloc() robust.

And I'm trying to yield CPU time as well as avoid getting all messages
jumbled by serialization using a lock, and Michal does not like locking.
We are deadlocked. :-(

>
> I do think ratelimiting will be OK - if the kernel is producing such a
> vast stream of warn_alloc() output then nobody is going to be reading
> it all anyway.  Probably just the first one is enough for operators to
> understand what's going wrong.

I don't think ratelimiting is OK. Printing only current thread's traces
helps little because the memory allocation stall problem interacts with
other threads. Without reporting all potentially relevant threads, we
won't know more than "something went wrong". That's where kmallocwd
becomes useful.

>
> So...  I think both.  ratelimit *and* serialize.  Perhaps a simple but
> suitable way of doing that is simply to disallow concurrent warn_allocs:
>
> 	/* comment goes here */
> 	if (test_and_set_bit(0, &foo))
> 		return;
> 	...
> 	clear_bit(0, &foo);
>
> or whatever?
>
> (And if we do decide to go with "mm,page_alloc: Serialize warn_alloc()
> if schedulable", please do add code comments explaining what's going on)

I think "no ratelimit" for __GFP_DIRECT_RECLAIM allocation requests
(unless we do decide to go with state tracking like kmallocwd does).

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3187,11 +3187,13 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 				      DEFAULT_RATELIMIT_BURST);
 	static DEFINE_MUTEX(warn_alloc_lock);
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
+	if (gfp_mask & __GFP_NOWARN)
 		return;
 
 	if (gfp_mask & __GFP_DIRECT_RECLAIM)
 		mutex_lock(&warn_alloc_lock);
+	else if (!__ratelimit(&nopage_rs))
+		return;
 	pr_warn("%s: ", current->comm);
 
 	va_start(args, fmt);



Michal Hocko wrote:
> On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > output from concurrent calls getting all jumbled together?
> 
> dump_stack already serializes concurrent calls.
> 
> > I'm not sure I buy the "this isn't a mainline kernel" thing. 
> 
> The changelog doesn't really explain what is going on and only
> speculates that the excessive warn_alloc is the cause. The kernel is 
> 4.9.23.el7.twitter.x86_64 which I suspect contains a lot of stuff on top
> of 4.9. So I would really _like_ to see whether this is reproducible
> with the upstream kernel. Especially when this is a LTP test.

You are misunderstanding. This patch is intended for help users understand
what was going on, for flooded/ratelimited/truncated/dropped logs prevents
users from knowing what was going on. You are not allowing users to explain
what is going on, by not allowing users to know what is going on.

> 
> > warn_alloc() obviously isn't very robust, but we'd prefer that it be
> > robust to peculiar situations, wild-n-wacky kernel patches, etc.  It's
> > a low-level thing and it should Just Work.
> 
> Yes I would agree and if we have an evidence that warn_alloc is really
> the problem then I am all for fixing it. There is no such evidence yet.

I don't have access to a system with 24 CPUs. Thus, I use a system with
4 CPUs / 2GB RAM with linux-next-20170602 kernel.

Testcase:
----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
        struct sched_param sp = { 0 };
        cpu_set_t cpu = { { 1 } };
        static int pipe_fd[2] = { EOF, EOF };
        char *buf = NULL;
        unsigned long size = 0;
        unsigned int i;
        int fd;
        pipe(pipe_fd);
        signal(SIGCLD, SIG_IGN);
        if (fork() == 0) {
                prctl(PR_SET_NAME, (unsigned long) "first-victim", 0, 0, 0);
                while (1)
                        pause();
        }
        close(pipe_fd[1]);
        sched_setaffinity(0, sizeof(cpu), &cpu);
        prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
        for (i = 0; i < 1024; i++)
                if (fork() == 0) {
                        char c;
                        /* Wait until the first-victim is OOM-killed. */
                        read(pipe_fd[0], &c, 1);
                        /* Try to consume as much CPU time as possible. */
                        while(1);
                        _exit(0);
                }
        close(pipe_fd[0]);
        fd = open("/dev/zero", O_RDONLY);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        sched_setscheduler(0, SCHED_IDLE, &sp);
        prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
        read(fd, buf, size); /* Will cause OOM due to overcommit */
        kill(-1, SIGKILL);
        return 0; /* Not reached. */
}
----------------------------------------

Results from http://I-love.SAKURA.ne.jp/tmp/serial-20170602-1.txt.xz :
----------------------------------------
[   46.896272] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
(...snipped...)
[   47.102375] Out of memory: Kill process 2210 (idle-priority) score 698 or sacrifice child
[   47.109067] Killed process 2211 (first-victim) total-vm:4168kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[   56.906104] postgres: page allocation stalls for 10003ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[   56.911263] systemd-journal: page allocation stalls for 10005ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
(...snipped...)
[  282.940538] pickup: page allocation stalls for 150003ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
(...snipped...)
[  283.203997] sysrq: SysRq : Kill All Tasks
----------------------------------------
This result shows that the OOM killer cannot be invoked again because
userspace processes continued wasting CPU time after an OOM victim was
selected. Yes, I know you will shout that "wasting CPU time in userspace
in order to disturb the OOM killer is unfair". OK, here is another result.

Testcase:
----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/prctl.h>

static void setproctitle(const char *name)
{
        prctl(PR_SET_NAME, (unsigned long) name, 0, 0, 0);
}

static cpu_set_t set = { { 1 } };
struct sched_param sp = { };
//static char filename[64] = { };
static char buffer[4096] = { };

static int file_io(void *unused)
{
        const int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
        setproctitle("mmap-file");
        sched_setscheduler(0, SCHED_IDLE, &sp);
        while (write(fd, buffer, 1) > 0)
                sched_yield();
        close(fd);
        return 0;
}

/* down_read(&mm->mmap_sem) requester which is chosen as an OOM victim. */
static int reader(void *pid)
{
        int fd;
        char filename[32] = { };
        snprintf(filename, sizeof(filename), "/proc/%u/stat", *(pid_t *)pid);
        fd = open(filename, O_RDONLY);
        setproctitle("mmap-read");
        sched_setaffinity(0, sizeof(set), &set);
        //sched_setscheduler(0, SCHED_IDLE, &sp);
        while (pread(fd, buffer, sizeof(buffer), 0) > 0);
        close(fd);
        return 0;
}

/* down_write(&mm->mmap_sem) requester which is chosen as an OOM victim. */
static int writer(void *unused)
{
        const int fd = open("/proc/self/exe", O_RDONLY);
        setproctitle("mmap-write");
        sched_setaffinity(0, sizeof(set), &set);
        //sched_setscheduler(0, SCHED_IDLE, &sp);
        while (1) {
                void *ptr = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0);
                //if (ptr && ptr != (void *) -1)
                munmap(ptr, 4096);
        }
        return 0;
}

int main(int argc, char *argv[])
{
#define MAX_PARALLEL 10
#define MAX_CONTENTION 10
        int i;
        int j;
        pid_t pids[MAX_PARALLEL];
        for (i = 0; i < MAX_PARALLEL; i++) {
                pids[i] = fork();
                if (pids[i] == EOF)
                        break;
                if (pids[i] == 0) {
                        sleep(1);
                        //for (i = 0; i < 2; i++)
                        //      clone(file_io, malloc(1024) + 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
                        for (j = 0; j < MAX_CONTENTION; j++) {
                                char *cp = malloc(4096);
                                if (!cp)
                                        break;
                                clone(writer, cp + 4096, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
                        }
                        pause();
                        _exit(0);
                }
        }
        for (i = 0; i < MAX_PARALLEL; i++) {
                if (pids[i] == EOF)
                        break;
                for (j = 0; j < MAX_CONTENTION; j++) {
                        char *cp = malloc(4096);
                        if (!cp)
                                break;
                        clone(reader, cp + 4096, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, &pids[i]);
                }
        }
        { /* A dummy process for invoking the OOM killer. */
                char *buf = NULL;
                unsigned long i;
                unsigned long size = 0;
                setproctitle("mmap-mem");
                for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                        char *cp = realloc(buf, size);
                        if (!cp) {
                                size >>= 1;
                                break;
                        }
                        buf = cp;
                }
                sleep(2);
                //sched_setscheduler(0, SCHED_IDLE, &sp);
                fprintf(stderr, "Eating memory\n");
                for (i = 0; i < size; i += 4096)
                        buf[i] = '\0'; /* Will cause OOM due to overcommit */
                fprintf(stderr, "Exiting\n");
                return 0;
        }
}
----------------------------------------

Results from http://I-love.SAKURA.ne.jp/tmp/serial-20170602-2.txt.xz :
----------------------------------------
[  123.771523] mmap-write invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
[  124.808940] mmap-write cpuset=/ mems_allowed=0
[  124.811595] CPU: 0 PID: 2852 Comm: mmap-write Not tainted 4.12.0-rc3-next-20170602 #99
[  124.815842] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  124.821171] Call Trace:
[  124.823106]  dump_stack+0x86/0xcf
[  124.825336]  dump_header+0x97/0x26d
[  124.827668]  ? trace_hardirqs_on+0xd/0x10
[  124.830222]  oom_kill_process+0x203/0x470
[  124.832778]  out_of_memory+0x138/0x580
[  124.835223]  __alloc_pages_slowpath+0x1100/0x11f0
[  124.838085]  __alloc_pages_nodemask+0x308/0x3c0
[  124.840850]  alloc_pages_current+0x6a/0xe0
[  124.843332]  __page_cache_alloc+0x119/0x150
[  124.845723]  filemap_fault+0x3dc/0x950
[  124.847932]  ? debug_lockdep_rcu_enabled+0x1d/0x20
[  124.850683]  ? xfs_filemap_fault+0x5b/0x180 [xfs]
[  124.853427]  ? down_read_nested+0x73/0xb0
[  124.855792]  xfs_filemap_fault+0x63/0x180 [xfs]
[  124.858327]  __do_fault+0x1e/0x140
[  124.860383]  __handle_mm_fault+0xb2c/0x1090
[  124.862760]  handle_mm_fault+0x190/0x350
[  124.865161]  __do_page_fault+0x266/0x520
[  124.867409]  do_page_fault+0x30/0x80
[  124.869846]  page_fault+0x28/0x30
[  124.871803] RIP: 0033:0x7fb997682dca
[  124.873875] RSP: 002b:0000000000777fe8 EFLAGS: 00010246
[  124.876601] RAX: 00007fb997b6e000 RBX: 0000000000000000 RCX: 00007fb997682dca
[  124.880077] RDX: 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
[  124.883551] RBP: 0000000000001000 R08: 0000000000000003 R09: 0000000000000000
[  124.886933] R10: 0000000000000002 R11: 0000000000000246 R12: 0000000000000002
[  124.890336] R13: 0000000000000000 R14: 0000000000000003 R15: 0000000000000001
[  124.893853] Mem-Info:
[  126.408131] mmap-read: page allocation stalls for 10005ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[  126.408137] mmap-read cpuset=/ mems_allowed=0
(...snipped...)
[  350.182442] mmap-read: page allocation stalls for 230016ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[  350.182446] mmap-read cpuset=/ mems_allowed=0
(...snipped...)
[  350.836483] sysrq: SysRq : Kill All Tasks
(...snipped...)
[  389.308085] active_anon:1146 inactive_anon:2777 isolated_anon:0
[  389.308085]  active_file:479 inactive_file:508 isolated_file:0
[  389.308085]  unevictable:0 dirty:0 writeback:0 unstable:0
[  389.308085]  slab_reclaimable:9536 slab_unreclaimable:15265
[  389.308085]  mapped:629 shmem:3535 pagetables:34 bounce:0
[  389.308085]  free:356689 free_pcp:596 free_cma:0
[  389.308089] Node 0 active_anon:4584kB inactive_anon:11108kB active_file:1916kB inactive_file:2032kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2516kB dirty:0kB writeback:0kB shmem:14140kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  389.308090] Node 0 DMA free:15872kB min:440kB low:548kB high:656kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  389.308093] lowmem_reserve[]: 0 1561 1561 1561
[  389.308097] Node 0 DMA32 free:1410884kB min:44612kB low:55764kB high:66916kB active_anon:4584kB inactive_anon:11108kB active_file:1916kB inactive_file:2032kB unevictable:0kB writepending:0kB present:2080640kB managed:1599404kB mlocked:0kB slab_reclaimable:38144kB slab_unreclaimable:61028kB kernel_stack:3808kB pagetables:136kB bounce:0kB free_pcp:2384kB local_pcp:696kB free_cma:0kB
[  389.308099] lowmem_reserve[]: 0 0 0 0
[  389.308103] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15872kB
[  389.308121] Node 0 DMA32: 975*4kB (UME) 1199*8kB (UME) 1031*16kB (UME) 973*32kB (UME) 564*64kB (UME) 303*128kB (UME) 160*256kB (UME) 70*512kB (UME) 40*1024kB (UME) 21*2048kB (M) 272*4096kB (M) = 1410884kB
[  389.308142] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  389.308143] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  389.308143] 4522 total pagecache pages
[  389.308147] 0 pages in swap cache
[  389.308148] Swap cache stats: add 0, delete 0, find 0/0
[  389.308149] Free swap  = 0kB
[  389.308149] Total swap = 0kB
[  389.308150] 524157 pages RAM
[  389.308151] 0 pages HighMem/MovableOnly
[  389.308152] 120330 pages reserved
[  389.308153] 0 pages cma reserved
[  389.308153] 0 pages hwpoisoned
[  389.308155] Out of memory: Kill process 2649 (mmap-mem) score 783 or sacrifice child
----------------------------------------
This result shows that the OOM killer was not able to send SIGKILL until
I gave up waiting and pressed SysRq-i because __alloc_pages_slowpath() continued
wasting CPU time after the OOM killer tried to start printing memory information.
We can avoid this case if we wait for oom_lock at __alloc_pages_may_oom().

> Note that dump_stack serialization might be unfair because there is no
> queuing. Is it possible that this is the problem? If yes we should
> rather fix that because that is arguably even more low-level routine than
> warn_alloc.

Wasting all CPU times in __alloc_pages_slowpath() enough to disallow
the OOM killer to send SIGKILL is also unfair. And you refuse to queue
allocating threads into oom_lock waiters at __alloc_pages_may_oom().

> 
> That being said. I strongly believe that this patch is not properly
> justified, issue fully understood and as such a disagree with adding a
> new lock on those grounds.
> 
> Until the above is resolved
> Nacked-by: Michal Hocko <mhocko@suse.com>

So, you can't agree with inspecting synchronously so that users can know
what is happening. Then, we have no choice other than use state tracking
and inspect asynchronously like kmallocwd does. Andrew, I'm so happy if we
can inspect asynchronously.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
