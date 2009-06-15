Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1408C6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 18:01:45 -0400 (EDT)
Date: Mon, 15 Jun 2009 15:01:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] procfs: provide stack information for threads V0.8
Message-Id: <20090615150121.ce04ba08.akpm@linux-foundation.org>
In-Reply-To: <1244618442.17616.5.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244618442.17616.5.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jun 2009 09:20:41 +0200
Stefani Seibold <stefani@seibold.net> wrote:

> This is the newest version of the formaly named "detailed stack info"
> patch which give you a better overview of the userland application stack
> usage, especially for embedded linux.
> 
> Currently you are only able to dump the main process/thread stack usage
> which is showed in /proc/pid/status by the "VmStk" Value. But you get no
> information about the consumed stack memory of the the threads.
> 
> There is an enhancement in the /proc/<pid>/{task/*,}/*maps and which
> marks the vm mapping where the thread stack pointer reside with "[thread
> stack xxxxxxxx]". xxxxxxxx is the maximum size of stack. This is a
> value information, because libpthread doesn't set the start of the stack
> to the top of the mapped area, depending of the pthread usage.
> 
> A sample output of /proc/<pid>/task/<tid>/maps looks like:
> 
> 08048000-08049000 r-xp 00000000 03:00 8312       /opt/z
> 08049000-0804a000 rw-p 00001000 03:00 8312       /opt/z
> 0804a000-0806b000 rw-p 00000000 00:00 0          [heap]
> a7d12000-a7d13000 ---p 00000000 00:00 0 
> a7d13000-a7f13000 rw-p 00000000 00:00 0          [thread stack: 001ff4b4]
> a7f13000-a7f14000 ---p 00000000 00:00 0 
> a7f14000-a7f36000 rw-p 00000000 00:00 0 
> a7f36000-a8069000 r-xp 00000000 03:00 4222       /lib/libc.so.6
> a8069000-a806b000 r--p 00133000 03:00 4222       /lib/libc.so.6
> a806b000-a806c000 rw-p 00135000 03:00 4222       /lib/libc.so.6
> a806c000-a806f000 rw-p 00000000 00:00 0 
> a806f000-a8083000 r-xp 00000000 03:00 14462      /lib/libpthread.so.0
> a8083000-a8084000 r--p 00013000 03:00 14462      /lib/libpthread.so.0
> a8084000-a8085000 rw-p 00014000 03:00 14462      /lib/libpthread.so.0
> a8085000-a8088000 rw-p 00000000 00:00 0 
> a8088000-a80a4000 r-xp 00000000 03:00 8317       /lib/ld-linux.so.2
> a80a4000-a80a5000 r--p 0001b000 03:00 8317       /lib/ld-linux.so.2
> a80a5000-a80a6000 rw-p 0001c000 03:00 8317       /lib/ld-linux.so.2
> afaf5000-afb0a000 rw-p 00000000 00:00 0          [stack]
> ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
> 
>  
> Also there is a new entry "stack usage" in /proc/<pid>/{task/*,}/status
> which will you give the current stack usage in kb.
> 
> A sample output of /proc/self/status looks like:
> 
> Name:	cat
> State:	R (running)
> Tgid:	507
> Pid:	507
> .
> .
> .
> CapBnd:	fffffffffffffeff
> voluntary_ctxt_switches:	0
> nonvoluntary_ctxt_switches:	0
> Stack usage:	12 kB
> 
> I also fixed stack base address in /proc/<pid>/{task/*,}/stat to the
> base address of the associated thread stack and not the one of the main
> process. This makes more sense.
> 
>
> ...
>
> --- linux-2.6.30.orig/include/linux/sched.h	2009-06-04 09:29:47.000000000 +0200
> +++ linux-2.6.30/include/linux/sched.h	2009-06-04 09:32:35.000000000 +0200
> @@ -1429,6 +1429,7 @@
>  	/* state flags for use by tracers */
>  	unsigned long trace;
>  #endif
> +	unsigned long stack_start;
>  };
>  

A `stack_start' in the task_struct.  This is a bit confusing - we
already have a `void *stack' in there.  Perhaps this should be named
user_stack_start or something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
