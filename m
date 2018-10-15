Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1B8F6B0008
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 06:58:12 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f5-v6so17858768ioq.17
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 03:58:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f123-v6si8390047itd.9.2018.10.15.03.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 03:58:11 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org> <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
 <20181012124137.GA29330@cmpxchg.org>
 <0417c888-d74e-b6ae-a8f0-234cbde03d38@i-love.sakura.ne.jp>
 <bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp>
 <20181013112238.GA762@cmpxchg.org>
 <b61b2e60-d899-90c6-579a-587815cebff6@i-love.sakura.ne.jp>
 <20181015081934.GD18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp>
Date: Mon, 15 Oct 2018 19:57:35 +0900
MIME-Version: 1.0
In-Reply-To: <20181015081934.GD18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On 2018/10/15 17:19, Michal Hocko wrote:
> As so many dozens of times before, I will point you to an incremental
> nature of changes we really prefer in the mm land. We are also after a
> simplicity which your proposal lacks in many aspects. You seem to ignore
> that general approach and I have hard time to consider your NAK as a
> relevant feedback. Going to an extreme and basing a complex solution on
> it is not going to fly. No killable process should be a rare event which
> requires a seriously misconfigured memcg to happen so wildly. If you can
> trigger it with a normal user privileges then it would be a clear bug to
> address rather than work around with printk throttling.
> 

I can trigger 200+ times / 900+ lines / 69KB+ of needless OOM messages
with a normal user privileges. This is a lot of needless noise/delay.
No killable process is not a rare event, even without root privileges.

[root@ccsecurity kumaneko]# time ./a.out
Killed

real    0m2.396s
user    0m0.000s
sys     0m2.970s
[root@ccsecurity ~]# dmesg | grep 'no killable' | wc -l
202
[root@ccsecurity ~]# dmesg | wc
    942    7335   70716
[root@ccsecurity ~]#

----------------------------------------
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
----------------------------------------
