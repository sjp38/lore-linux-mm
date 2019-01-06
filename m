Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 433E18E00F9
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 01:02:40 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so5308253ita.1
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 22:02:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m7si3293461itn.21.2019.01.05.22.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 22:02:38 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
Date: Sun, 6 Jan 2019 15:02:24 +0900
MIME-Version: 1.0
In-Reply-To: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

Michal and Johannes, can we please stop this stupid behavior now?

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
	const unsigned long size = 1048576 * 200;
	mkdir("/sys/fs/cgroup/memory/test1", 0755);
	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
	fprintf(fp, "%lu\n", size);
	fclose(fp);
	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
	fprintf(fp, "%u\n", getpid());
	fclose(fp);
	if (setgid(-2) || setuid(-2) || pipe(pipe_fd))
		return 1;
	if (fork() == 0) {
		stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
			     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
		for (i = 0; i < NUMTHREADS; i++)
			if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
				  CLONE_SIGHAND | CLONE_THREAD | CLONE_VM | CLONE_FS | CLONE_FILES, NULL) == -1)
				break;
		close(pipe_fd[1]);
		pause();
	}
	close(pipe_fd[0]);
	for (i = 0; i < NUMTHREADS / 2; i++)
		if (fork() == 0) {
			close(pipe_fd[1]);
			pause();
		}
	sleep(1);
	close(pipe_fd[1]);
	pause();
	return 0;
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20190106.txt.xz :
----------
[   79.104729] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
(...snipped...)
[   79.237203] memory: usage 204800kB, limit 204800kB, failcnt 2834
[   79.242176] memory+swap: usage 204800kB, limit 9007199254740988kB, failcnt 0
[   79.245175] kmem: usage 23420kB, limit 9007199254740988kB, failcnt 0
[   79.247945] Memory cgroup stats for /test1: cache:177456KB rss:3420KB rss_huge:0KB shmem:177456KB mapped_file:177540KB dirty:0KB writeback:0KB swap:0KB inactive_anon:177676KB active_anon:3612KB inactive_file:0KB active_file:0KB unevictable:0KB
[   79.256726] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/test1,task_memcg=/test1,task=a.out,pid=8204,uid=-2
[   79.262470] Memory cgroup out of memory: Kill process 8204 (a.out) score 822 or sacrifice child
[   79.266901] Killed process 8204 (a.out) total-vm:10491132kB, anon-rss:92kB, file-rss:444kB, shmem-rss:167028kB
[   79.272974] oom_reaper: reaped process 8447 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:167488kB
[   79.277733] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
(...snipped...)
[   79.386222] memory: usage 204708kB, limit 204800kB, failcnt 2837
[   79.412519] Killed process 8205 (a.out) total-vm:4348kB, anon-rss:92kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[   79.539042] memory: usage 204600kB, limit 204800kB, failcnt 2838
[   79.564617] Killed process 8206 (a.out) total-vm:4348kB, anon-rss:92kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[   81.967741] Memory cgroup out of memory: Kill process 8203 (a.out) score 6 or sacrifice child
[   81.971760] Killed process 8203 (a.out) total-vm:4348kB, anon-rss:92kB, file-rss:1156kB, shmem-rss:0kB
[   81.977329] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
(...snipped...)
[   81.977529] memory: usage 187160kB, limit 204800kB, failcnt 2838
[   81.977530] memory+swap: usage 187160kB, limit 9007199254740988kB, failcnt 0
[   81.977531] kmem: usage 8264kB, limit 9007199254740988kB, failcnt 0
[   81.977532] Memory cgroup stats for /test1: cache:178248KB rss:372KB rss_huge:0KB shmem:178248KB mapped_file:178332KB dirty:0KB writeback:0KB swap:0KB inactive_anon:178568KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
[   81.977545] Out of memory and no killable processes...
(...snipped...)
[   87.914960] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
(...snipped...)
[   88.019110] memory: usage 183472kB, limit 204800kB, failcnt 2838
[   88.021629] memory+swap: usage 183472kB, limit 9007199254740988kB, failcnt 0
[   88.024513] kmem: usage 4448kB, limit 9007199254740988kB, failcnt 0
[   88.027137] Memory cgroup stats for /test1: cache:178512KB rss:372KB rss_huge:0KB shmem:178512KB mapped_file:178464KB dirty:0KB writeback:0KB swap:0KB inactive_anon:178760KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
[   88.036008] Out of memory and no killable processes...
----------



>From 0fb58415770a83d6c40d471e1840f8bc4a35ca83 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 26 Dec 2018 19:13:35 +0900
Subject: [PATCH] memcg: killed threads should not invoke memcg OOM killer

If $N > $M, a single process with $N threads in a memcg group can easily
kill all $M processes in that memcg group, for mem_cgroup_out_of_memory()
does not check if current thread needs to invoke the memcg OOM killer.

  T1@P1     |T2...$N@P1|P2...$M   |OOM reaper
  ----------+----------+----------+----------
                        # all sleeping
  try_charge()
    mem_cgroup_out_of_memory()
      mutex_lock(oom_lock)
             try_charge()
               mem_cgroup_out_of_memory()
                 mutex_lock(oom_lock)
      out_of_memory()
        select_bad_process()
        oom_kill_process(P1)
        wake_oom_reaper()
                                   oom_reap_task() # ignores P1
      mutex_unlock(oom_lock)
                 out_of_memory()
                   select_bad_process(P2...M)
                        # all killed by T2...N@P1
                   wake_oom_reaper()
                                   oom_reap_task() # ignores P2...M
                 mutex_unlock(oom_lock)

We don't need to invoke the memcg OOM killer if current thread was killed
when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) and
memory_max_write() can bail out upon SIGKILL, and try_charge() allows
already killed/exiting threads to make forward progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b860dd4f7..b0d3bf3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1389,8 +1389,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
+	/*
+	 * A few threads which were not waiting at mutex_lock_killable() can
+	 * fail to bail out. Therefore, check again after holding oom_lock.
+	 */
+	ret = fatal_signal_pending(current) || out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
 }
-- 
1.8.3.1
