Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE486B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 06:23:40 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id r68-v6so456171oie.12
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 03:23:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g6-v6si376626oia.212.2018.10.23.03.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 03:23:38 -0700 (PDT)
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
References: <20181018042739.GA650@jagdpanzerIV>
 <20181018143033.z5gck2enrictqja3@pathway.suse.cz>
 <201810190018.w9J0IGI2019559@www262.sakura.ne.jp>
 <20181023082111.edb3ela4mhwaaimi@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5251d336-4ad0-ccf0-e31f-35d9c832b0be@i-love.sakura.ne.jp>
Date: Tue, 23 Oct 2018 19:23:00 +0900
MIME-Version: 1.0
In-Reply-To: <20181023082111.edb3ela4mhwaaimi@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On 2018/10/23 17:21, Petr Mladek wrote:
> On Fri 2018-10-19 09:18:16, Tetsuo Handa wrote:
>> I assumed we calculate the average dynamically, for the amount of
>> messages printed by an OOM event is highly unstable (depends on
>> hardware configuration such as number of nodes, number of zones,
>> and how many processes are there as a candidate for OOM victim).
> 
> Is there any idea how the average length can be counted dynamically?

I don't have one. Maybe sum up return values of printk() from OOM context?



> This reminds me another problem. We would need to use the same
> decision for all printk() calls that logically belongs to each
> other. Otherwise we might get mixed lines that might confuse
> poeple. I mean that OOM messages might look like:
> 
>   OOM: A
>   OOM: B
>   OOM: C
> 
> If we do not synchronize the rateliting, we might see:
> 
>   OOM: A
>   OOM: B
>   OOM: C
>   OOM: B
>   OOM: B
>   OOM: A
>   OOM: C
>   OOM: C

Messages from out_of_memory() are serialized by oom_lock mutex.
Messages from warn_alloc() are not serialized, and thus cause confusion.



>> I wish that memcg OOM events do not use printk(). Since memcg OOM is not
>> out of physical memory, we can dynamically allocate physical memory for
>> holding memcg OOM messages and let the userspace poll it via some interface.
> 
> Would the userspace work when the system gets blocked on allocations?

Yes for memcg OOM events. No for global OOM events.
You can try reproducers shown below from your environment.

Regarding case 2, we can solve the problem by checking tsk_is_oom_victim(current) == true.
But regarding case 1, Michal's patch is not sufficient for allowing administrators
to enter commands for recovery from console.

---------- Case 1: Flood of memcg OOM events caused by misconfiguration. ----------

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	FILE *fp;
	const unsigned long size = 1048576 * 200;
	char *buf = malloc(size);
	mkdir("/sys/fs/cgroup/memory/test1", 0755);
	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
	fprintf(fp, "%lu\n", size / 2);
	fclose(fp);
	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
	fprintf(fp, "%u\n", getpid());
	fclose(fp);
	fp = fopen("/proc/self/oom_score_adj", "w");
	fprintf(fp, "-1000\n");
	fclose(fp);
	fp = fopen("/dev/zero", "r");
	fread(buf, 1, size, fp);
	fclose(fp);
	return 0;
}

---------- Case 2: Flood of memcg OOM events caused by MMF_OOM_SKIP race. ----------

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
	if (setgid(-2) || setuid(-2))
		return 1;
	stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
		     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
	for (i = 0; i < NUMTHREADS; i++)
		if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
			  CLONE_SIGHAND | CLONE_THREAD | CLONE_VM | CLONE_FS | CLONE_FILES, NULL) == -1)
			break;
	sleep(1);
	close(pipe_fd[1]);
	pause();
	return 0;
}
