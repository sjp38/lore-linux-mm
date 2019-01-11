Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A11BA8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:25:34 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p21so1730180itb.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:25:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g4si1579717jae.39.2019.01.11.02.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 02:25:33 -0800 (PST)
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
Message-ID: <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
Date: Fri, 11 Jan 2019 19:25:22 +0900
MIME-Version: 1.0
In-Reply-To: <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/11 8:59, Tetsuo Handa wrote:
> Michal Hocko wrote:
>> On Wed 09-01-19 20:34:46, Tetsuo Handa wrote:
>>> On 2019/01/09 20:03, Michal Hocko wrote:
>>>> Tetsuo,
>>>> can you confirm that these two patches are fixing the issue you have
>>>> reported please?
>>>>
>>>
>>> My patch fixes the issue better than your "[PATCH 2/2] memcg: do not
>>> report racy no-eligible OOM tasks" does.
>>
>> OK, so we are stuck again. Hooray!
> 
> Andrew, will you pick up "[PATCH 3/2] memcg: Facilitate termination of memcg OOM victims." ?
> Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
> when task_will_free_mem() == true, memcg-do-not-report-racy-no-eligible-oom-tasks.patch
> does not close the race whereas my patch closes the race better.
> 

I confirmed that mm-oom-marks-all-killed-tasks-as-oom-victims.patch and
memcg-do-not-report-racy-no-eligible-oom-tasks.patch are completely failing
to fix the issue I am reporting. :-(

Reproducer:
----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <sys/mman.h>

#define NUMTHREADS 256
#define MMAPSIZE 4 * 10485760
#define STACKSIZE 4096
static int pipe_fd[2] = { EOF, EOF };
static int memory_eater(void *unused)
{
	int fd = open("/dev/zero", O_RDONLY);
	char *buf = mmap(NULL, MMAPSIZE, PROT_WRITE | PROT_READ,
			 MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
	read(pipe_fd[0], buf, 1);
	read(fd, buf, MMAPSIZE);
	pause();
	return 0;
}
int main(int argc, char *argv[])
{
	int i;
	char *stack;
	FILE *fp;
	const unsigned long size = 1048576UL * 200;
	mkdir("/sys/fs/cgroup/memory/test1", 0755);
	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
	fprintf(fp, "%lu\n", size);
	fclose(fp);
	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
	fprintf(fp, "%u\n", getpid());
	fclose(fp);
	if (setgid(-2) || setuid(-2) || pipe(pipe_fd))
		return 1;
	stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
		     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
	for (i = 0; i < NUMTHREADS; i++)
		if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
			  CLONE_VM | CLONE_FS | CLONE_FILES, NULL) == -1)
			break;
	close(pipe_fd[1]);
	pause(); // Manually enter Ctrl-C immediately after dump_header() started.
	return 0;
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20190111.txt.xz :
----------
[   71.146532][ T9694] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
[   71.151647][ T9694] CPU: 1 PID: 9694 Comm: a.out Kdump: loaded Not tainted 5.0.0-rc1-next-20190111 #272
(...snipped...)
[   71.304689][ T9694] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/test1,task_memcg=/test1,task=a.out,pid=9692,uid=-2
[   71.304703][ T9694] Memory cgroup out of memory: Kill process 9692 (a.out) score 904 or sacrifice child
[   71.309149][   T54] oom_reaper: reaped process 9750 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:185532kB
[   71.328523][ T9748] a.out invoked oom-killer: gfp_mask=0x7080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), order=0, oom_score_adj=0
[   71.328552][ T9748] CPU: 4 PID: 9748 Comm: a.out Kdump: loaded Not tainted 5.0.0-rc1-next-20190111 #272
(...snipped...)
[   71.328785][ T9748] Out of memory and no killable processes...
[   71.329194][ T9771] a.out invoked oom-killer: gfp_mask=0x7080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), order=0, oom_score_adj=0
(...snipped...)
[   99.696592][ T9924] Out of memory and no killable processes...
[   99.699001][ T9838] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
(...snipped...)
[   99.833413][ T9838] Out of memory and no killable processes...
----------

$ grep -F 'Out of memory and no killable processes...' serial-20190111.txt | wc -l
213
