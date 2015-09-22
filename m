Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id D5BAA6B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:32:41 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so29747332ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:32:41 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id z10si4256420igl.94.2015.09.22.16.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 16:32:41 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so22465184pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:32:40 -0700 (PDT)
Date: Tue, 22 Sep 2015 16:32:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <201509221433.ICI00012.VFOQMFHLFJtSOO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509221631040.7794@chino.kir.corp.google.com>
References: <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org> <20150919083218.GD28815@dhcp22.suse.cz> <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1509211628050.27715@chino.kir.corp.google.com>
 <201509221433.ICI00012.VFOQMFHLFJtSOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Tue, 22 Sep 2015, Tetsuo Handa wrote:

> David Rientjes wrote:
> > Your proposal, which I mostly agree with, tries to kill additional 
> > processes so that they allocate and drop the lock that the original victim 
> > depends on.  My approach, from 
> > http://marc.info/?l=linux-kernel&m=144010444913702, is the same, but 
> > without the killing.  It's unecessary to kill every process on the system 
> > that is depending on the same lock, and we can't know which processes are 
> > stalling on that lock and which are not.
> 
> Would you try your approach with below program?
> (My reproducers are tested on XFS on a VM with 4 CPUs / 2048MB RAM.)
> 
> ---------- oom-depleter3.c start ----------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <sched.h>
> 
> static int zero_fd = EOF;
> static char *buf = NULL;
> static unsigned long size = 0;
> 
> static int dummy(void *unused)
> {
> 	static char buffer[4096] = { };
> 	int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
> 	while (write(fd, buffer, sizeof(buffer) == sizeof(buffer)) &&
> 	       fsync(fd) == 0);
> 	return 0;
> }
> 
> static int trigger(void *unused)
> {
> 	read(zero_fd, buf, size); /* Will cause OOM due to overcommit */
> 	return 0;
> }
> 
> int main(int argc, char *argv[])
> {
>         unsigned long i;
> 	zero_fd = open("/dev/zero", O_RDONLY);
> 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> 		char *cp = realloc(buf, size);
> 		if (!cp) {
> 			size >>= 1;
> 			break;
> 		}
> 		buf = cp;
> 	}
> 	/*
> 	 * Create many child threads in order to enlarge time lag between
> 	 * the OOM killer sets TIF_MEMDIE to thread group leader and
> 	 * the OOM killer sends SIGKILL to that thread.
> 	 */
> 	for (i = 0; i < 1000; i++) {
> 		clone(dummy, malloc(1024) + 1024, CLONE_SIGHAND | CLONE_VM,
> 		      NULL);
> 	}
> 	/* Let a child thread trigger the OOM killer. */
> 	clone(trigger, malloc(4096)+ 4096, CLONE_SIGHAND | CLONE_VM, NULL);
> 	/* Deplete all memory reserve using the time lag. */
> 	for (i = size; i; i -= 4096)
> 		buf[i - 1] = 1;
> 	return * (char *) NULL; /* Kill all threads. */
> }
> ---------- oom-depleter3.c end ----------
> 
> uptime > 350 of http://I-love.SAKURA.ne.jp/tmp/serial-20150922-1.txt.xz
> shows that the memory reserves completely depleted and
> uptime > 42 of http://I-love.SAKURA.ne.jp/tmp/serial-20150922-2.txt.xz
> shows that the memory reserves was not used at all.
> Is this result what you expected?
> 

What are the results when the kernel isn't patched at all?  The trade-off 
being made is that we want to attempt to make forward progress when there 
is an excessive stall in an oom victim making its exit rather than 
livelock the system forever waiting for memory that can never be 
allocated.

I struggle to understand how the approach of randomly continuing to kill 
more and more processes in the hope that it slows down usage of memory 
reserves or that we get lucky is better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
