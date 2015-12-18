Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 102916B0006
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:10:40 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id l9so29982082oia.2
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:10:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ux4si13874052obc.94.2015.12.18.04.10.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 04:10:39 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
	<20151217130223.GE18625@dhcp22.suse.cz>
In-Reply-To: <20151217130223.GE18625@dhcp22.suse.cz>
Message-Id: <201512182110.FBH73485.LFOFtOOVSHFQMJ@I-love.SAKURA.ne.jp>
Date: Fri, 18 Dec 2015 21:10:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 16-12-15 16:50:35, Andrew Morton wrote:
> > On Tue, 15 Dec 2015 19:36:15 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > +static void oom_reap_vmas(struct mm_struct *mm)
> > > +{
> > > +	int attempts = 0;
> > > +
> > > +	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> > > +		schedule_timeout(HZ/10);
> > 
> > schedule_timeout() in state TASK_RUNNING doesn't do anything.  Use
> > msleep() or msleep_interruptible().  I can't decide which is more
> > appropriate - it only affects the load average display.
> 
> Ups. You are right. I will go with msleep_interruptible(100).
>  

I didn't know that. My testing was almost without oom_reap_vmas().

> > I guess it means that the __oom_reap_vmas() success rate is nice anud
> > high ;)
> 
> I had a debugging trace_printks around this and there were no reties
> during my testing so I was probably lucky to not trigger the mmap_sem
> contention.

Yes, you are lucky that you did not hit the mmap_sem contention.
I retested with

 static void oom_reap_vmas(struct mm_struct *mm)
 {
 	int attempts = 0;
 
 	while (attempts++ < 10 && !__oom_reap_vmas(mm))
-		schedule_timeout(HZ/10);
+		msleep_interruptible(100);
+	printk(KERN_WARNING "oom_reaper: attempts=%u\n", attempts);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	mmdrop(mm);
 }

and I can hit that attempts becomes 11 (i.e. oom_reap_vmas() gives up
waiting) if I ran a memory stressing program with many contending
mmap_sem readers and writers shown below.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/mman.h>

static cpu_set_t set = { { 1 } }; /* Allow only CPU 0. */
static char filename[32] = { };

/* down_read(&mm->mmap_sem) requester. */
static int reader(void *unused)
{
	const int fd = open(filename, O_RDONLY);
	char buffer[128];
	sched_setaffinity(0, sizeof(set), &set);
	sleep(2);
	while (pread(fd, buffer, sizeof(buffer), 0) > 0);
	while (1)
		pause();
	return 0;
}

/* down_write(&mm->mmap_sem) requester. */
static int writer(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	sched_setaffinity(0, sizeof(set), &set);
	sleep(2);
	while (1) {
		void *ptr = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0);
		munmap(ptr, 4096);
	}
	return 0;
}

static void my_clone(int (*func) (void *))
{
	char *stack = malloc(4096);
	if (stack)
		clone(func, stack + 4096,
		      CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
}

/* Memory consumer for invoking the OOM killer. */
static void memory_eater(void) {
	char *buf = NULL;
	unsigned long i;
	unsigned long size = 0;
	sleep(4);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	fprintf(stderr, "Start eating memory\n");
	for (i = 0; i < size; i += 4096)
		buf[i] = '\0'; /* Will cause OOM due to overcommit */
}

int main(int argc, char *argv[])
{
	int i;
	const pid_t pid = fork();
	if (pid == 0) {
		for (i = 0; i < 9; i++)
			my_clone(writer);
		writer(NULL);
		_exit(0);
	} else if (pid > 0) {
		snprintf(filename, sizeof(filename), "/proc/%u/stat", pid);
		for (i = 0; i < 1000; i++)
			my_clone(reader);
	}
	memory_eater();
	return *(char *) NULL; /* Not reached. */
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151218.txt.xz .
----------
[   90.790847] Killed process 9560 (oom_reaper-test) total-vm:4312kB, anon-rss:124kB, file-rss:0kB, shmem-rss:0kB
[   91.803154] oom_reaper: attempts=11
[  100.701494] MemAlloc-Info: 509 stalling task, 0 dying task, 1 victim task.
[  102.439082] Killed process 9559 (oom_reaper-test) total-vm:2170960kB, anon-rss:1564600kB, file-rss:0kB, shmem-rss:0kB
[  102.441937] Killed process 9561 (oom_reaper-test) total-vm:2170960kB, anon-rss:1564776kB, file-rss:0kB, shmem-rss:0kB
[  102.731326] oom_reaper: attempts=1
[  125.420727] Killed process 10573 (oom_reaper-test) total-vm:4340kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  126.440392] oom_reaper: attempts=11
[  135.354193] MemAlloc-Info: 450 stalling task, 0 dying task, 0 victim task.
[  240.023256] MemAlloc-Info: 1016 stalling task, 0 dying task, 0 victim task.
[  302.246975] Killed process 10572 (oom_reaper-test) total-vm:2170960kB, anon-rss:1562128kB, file-rss:0kB, shmem-rss:0kB
[  302.263515] oom_reaper: attempts=1
[  382.961343] Killed process 11667 (oom_reaper-test) total-vm:4312kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  383.980541] oom_reaper: attempts=11
[  392.592658] MemAlloc-Info: 758 stalling task, 10 dying task, 1 victim task.
[  399.497478] Killed process 11666 (oom_reaper-test) total-vm:2170960kB, anon-rss:1556072kB, file-rss:0kB, shmem-rss:0kB
[  399.499101] Killed process 11668 (oom_reaper-test) total-vm:2170960kB, anon-rss:1556260kB, file-rss:0kB, shmem-rss:0kB
[  399.778283] oom_reaper: attempts=1
[  438.304082] Killed process 12680 (oom_reaper-test) total-vm:4324kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
[  439.318951] oom_reaper: attempts=11
[  445.581171] MemAlloc-Info: 796 stalling task, 0 dying task, 0 victim task.
[  618.955215] MemAlloc-Info: 979 stalling task, 0 dying task, 0 victim task.
----------

Yes, this is an insane program. But what is important will be we prepare for
cases when oom_reap_vmas() gave up waiting. Silent hang up is annoying.
Like Andrew said
( http://lkml.kernel.org/r/20151216153513.e432dc70e035e5d07984710c@linux-foundation.org ),
I want to add a watchdog for printk()ing.
( http://lkml.kernel.org/r/201512170011.IAC73451.FLtFMSJHOQFVOO@I-love.SAKURA.ne.jp ).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
