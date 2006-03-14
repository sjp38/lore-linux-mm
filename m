Received: from taynzmail03.nz-tay.cpqcorp.net (tandem.com [16.47.4.103])
	by atlrel8.hp.com (Postfix) with ESMTP id 37DD2346DC
	for <linux-mm@kvack.org>; Sun, 19 Mar 2006 18:25:52 -0500 (EST)
Received: from anw.zk3.dec.com (alpha.zk3.dec.com [16.140.128.4])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id 0772E630F
	for <linux-mm@kvack.org>; Tue, 14 Mar 2006 17:28:07 -0500 (EST)
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1142019195.5204.12.camel@localhost.localdomain>
References: <1142019195.5204.12.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 14 Mar 2006 17:27:46 -0500
Message-Id: <1142375266.5235.105.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Some results for auto migration + migrate on fault using the McAlpin
Stream benchmark.

Kernel:  2.6.16-rc6-git1 with the migrate-on-fault and automigration
patches applied, in that order.

Platform:  HP rx8620 16cpu/4node/32BG numa platform with 1.6GHz ia64
cpus.

I built the stream benchmark to run for 1000 loops [NTIMES defined as
1000], and at the end of each loop I printed the run# and the times for
the copy, scale, add and triad loops.  I compiled with icc [Intel
compiler] 9.0 using OpenMP extensions to parallelize the loops.  

I ran the benchmark twice:  once with auto migration disabled
[/sys/kernel/migration/sched_migrate_memory = 0] and once with it
enabled [including migrate on fault--a.k.a lazy migration].  After I
started each run, I did a kernel build on the platform using:  make
mrproper; make oldconfig [using my regular .config]; make -j32 all.

I have posted graphs of the results and the raw data itself at:

http://free.linux.hp.com/~lts/Patches/PageMigration/

The nomig+kbuild files [automigration disabled] show the benchmark
starting with more or less "best case" times.  By best case, I mean,
that if you run the benchmark over and over [with, say, NTIMES = 10],
you'll see a number of different results, depending on how the OMP
threads happen to fall relative to the data.  I have made no effort to
do any initial placement.  The copy and scale times are ~0.052 seconds;
the add and triad numbers are ~0.078 seconds.  Then the kernel build
disturbs the run for a while, during which time the scheduler migrates
the stream/OMP threads to least busy groups/queues.  When the kernel
build is done, the threads happen to be a way suboptimal configuration.
This is just a roll of the dice.  They could have ended up in better
shape.

The automig+kbuild files show the same secnario.  However, the threads
happened to start at a suboptimal configuration, similar to the end
state of the nomig case.  Again, I made no effort to place the threads
at the start.  As soon as the kernel build starts, migration kicks in.
I believe that the first spike is from the "make mrproper".  This
disturbance is sufficient to cause the stream/OMP threads to migrate, at
which time autopage migration causes the pages to be migrated to the
node with the threads.  Then, the "make -j32 all" really messes up the
benchmark, but when build finishes, the job runs in the more or less
best case configuration.

Some things to note:  the peaks for the automigration case are higher
[almost double] that of the no migration case because the page
migrations get included in the benchmark times, which is just using
gettimeofday().   Also, because I'm using lazy migration
[sched_migrate_lazy enabled], when a task migrates to a new node, I only
unmap the pages.  Then, they migrate or not, as threads touch them.  If
the page is already on the node where the faulting thread is running,
the fault just reinstates the pte for the page.  If not, it will migrate
the page to the thread's node and install that pte.

Finally, as noted above, the first disturbance in the automig case
caused some migrations that resulted in a better thread/memory
configuration that what the program started with.  To give an
application control over this, it might be useful to provide an
MPOL_NOOP policy to be used along with the MPOL_MF_MOVE flag, and the
MPOL_MF_LAZY flag that I implemented in the last of the migrate-on-fault
patches.  The 'NOOP would retain the existing policy for the specified
range, but the 'MOVE+'LAZY would unmap the ptes of the range, pushing
anon pages to the swap cache, if necessary.
This would allow the threads of an application to pull the pages local
to their node on next touch.  I will test this theory...

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
