Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C8DAD6B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 19:15:35 -0500 (EST)
Date: Fri, 27 Jan 2012 01:15:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: AutoNUMA alpha3 microbench [Re: On numa interfaces and stuff]
Message-ID: <20120127001518.GX30782@redhat.com>
References: <1321541021.27735.64.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="xQR6quUbZ63TTuTU"
Content-Disposition: inline
In-Reply-To: <1321541021.27735.64.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


--xQR6quUbZ63TTuTU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi everyone,

On Thu, Nov 17, 2011 at 03:43:41PM +0100, Peter Zijlstra wrote:
> We also need to provide a new NUMA interface that allows (threaded)
> applications to specify what they want. The below patch outlines such an
> interface although the patch is very much incomplete and uncompilable, I
> guess its complete enough to illustrate the idea.
> 
> The abstraction proposed is that of coupling threads (tasks) with
> virtual address ranges (vmas) and guaranteeing they are all located on
> the same node. This leaves the kernel in charge of where to place all
> that and gives it the freedom to move them around, as long as the
> threads and v-ranges stay together.

I think expecting all apps to be modified to run a syscall after every
allocation to tell which thread will access which memory is
unreasonable (and I'm hopeful that's not needed).

Also not sure what you will do when N threads are sharing the same
memory and N is more than the CPUs in one node.

Another problem is that for the very large apps with tons of threads
on very large systems, you risk to fragment the vma too much and get
-ENOMEM, or in the best case slowdown the vma lookups significantly if
you'll build up a zillon of vmas.

None of the above issues are a concern for qemu-kvm of course, but you
still have to use the syscalls in guest or you're back to use cpusets
or other forms of hard binds in guest. It may work for guests that
fits in one node of course, but those are the easiest to get right for
autonuma. If the guest fits in one node, syscalls or not syscalls is
the same as you're back to square one: the syscall in that case would
ask the kernel to keep all vcpus access all guest memory as the
vtopology is the identity, so what's the point?

In the meantime I've got autonuma (total automatic NUMA scheduler and
memory migration) fully working, to the point I'm quite happy about it
(with what I tested so far at least...). I've yet to benchmark it
extensively for mixed real life workloads but I tested it a lot on the
microbenchmarks that tends to stress the NUMA effects in similar to
real life scenarios (they however tends to trash the CPU caches much
more than real life apps).

The code is still dirty so I just need to start cleaning it up (now
that I'm happy about the math :), add sysfs, add native THP
migration. At the moment THP is split, so it works fine and it's
recreated by khugepaged, but I prefer not to split in the future. The
benchmarks are run with THP off just in case (not necessairly because
it was faster that way, I didn't bother to benchmark it with THP yet,
I only verified it's stable).

Sharing code at this point while possible with a large raw diff, may
not be so easy to read and it's still going to change significantly as
I'm in the clean up process :). Reviewing it for bugs also not worth
it at this point.

But I'd like to share at least the results I got so far and that makes
me slightly optimistic that it can work well, especially if you will
help me improve it over time. The testcases source is attached (not so
clean too I know but they're just quick testcases..). They're tuned to
run on 24-way 2 sockets 2 nodes with 8G per node.

Note that the hard bind case don't do any memory migration and
allocates the memory in the right place immediately. autonuma is the
only case where any memory migration happens in the benchmark, so it's
immpossible for autonuma to perform exactly the same as hard bindings
no matter what. (I also have an initial placement logic that gets us
closer to hard bindings in the numa01 first bench, only if you disable
-DNO_BIND_FORCE_SAME_NODE of course, but that logic is disabled in
this benchmark because I feel it's not generic enough, and anyway I
built numa01 with -DNO_BIND_FORCE_SAME_NODE to ensure to start with
the worst possible memory placement even when I had that logic
enabled, otherwise if the initial placement is right no memory
migration would run anymore at all as autonuma would agree then)

I'm afraid my current implementation may not be too good if there's a
ton of CPU overcommit, to avoid regressing the scheduler to O(N) (and
to avoid being too intrusive on the scheduler code too) but that
should be doable in the future. But note that the last bench has a x2
overcommit (48 threads on 24 CPUs) and it still does close to the hard
bindings so it kind of works well there too. I suspect it'll gradually
get worse if you overcommit 10 or 100 times every CPU (but ideally not
worse than no autonuma).

When booted on not-NUMA systems the overhead (after I will clean it
up) will become 1 pointer in mm_struct and 1 pointer in task_struct,
and no more than that. On NUMA systems where it will activate, the
memory overhead is still fairly low (comparable to memcg). It will
also be possible to shut off all the runtime CPU overhead totally
(freeing all memory at runtime it's a lot more tricky, booting with
noautonuma will be possible to avoid the memory overhead though). The
whole thing is activated a single knuma_scand damon, stop that and it
runs identical to upstream.

If you modify the testcases to run your new NUMA affinity syscalls and
compare your results that would be interesting to see. For example the
numa01 benchmark compiled with -DNO_BIND_FORCE_SAME_NODE will allow
you to first allocate all ram of both "mm" in the same node, then
return to MPOL_DEFAULT and then run your syscalls to verify the
performance of your memory migration and NUMA node scheduler placement
vs mine. Of course for these benchmarks you want to keep it on the
aggressive side so it will converge to the point where migration stops
within 10-30 sec from startup (in real life the processes won't quit
after a few min so the migration rate can be much lower).

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120126.pdf

Thanks,
Andrea

--xQR6quUbZ63TTuTU
Content-Type: text/x-c; charset=us-ascii
Content-Disposition: attachment; filename="numa01.c"

/*
 *  Copyright (C) 2012  Red Hat, Inc.
 *
 *  This work is licensed under the terms of the GNU GPL, version 2. See
 *  the COPYING file in the top-level directory.
 */

#define _GNU_SOURCE
#include <pthread.h>
#include <strings.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <numaif.h>
#include <sched.h>
#include <time.h>
#include <sys/wait.h>
#include <sys/file.h>

//#define KVM
#ifndef KVM
#define THREADS 12
#define SIZE (3UL*1024*1024*1024)
#else
#define THREADS 4
#define SIZE (200*1024*1024)
#endif
//#define THREAD_ALLOC
#ifdef THREAD_ALLOC
#define THREAD_SIZE (SIZE/THREADS)
#else
#define THREAD_SIZE SIZE
#endif
//#define HARD_BIND
//#define INVERSE_BIND
//#define NO_BIND_FORCE_SAME_NODE

static char *p_global;
static unsigned long nodemask_global;

void *thread(void * arg)
{
	char *p = arg;
	int i;
#ifndef KVM
#ifndef THREAD_ALLOC
	int nr = 50;
#else
	int nr = 1000;
#endif
#else
	int nr = 500;
#endif
#ifdef NO_BIND_FORCE_SAME_NODE
	if (set_mempolicy(MPOL_BIND, &nodemask_global, 3) < 0)
		perror("set_mempolicy"), printf("%lu\n", nodemask_global),
			exit(1);
#endif
	bzero(p_global, SIZE);
#ifdef NO_BIND_FORCE_SAME_NODE
	if (set_mempolicy(MPOL_DEFAULT, NULL, 3) < 0)
		perror("set_mempolicy"), exit(1);
#endif
	for (i = 0; i < nr; i++) {
#if 1
		bzero(p, THREAD_SIZE);
#else
		memcpy(p, p+THREAD_SIZE/2, THREAD_SIZE/2);
#endif
		asm volatile("" : : : "memory");
	}
	return NULL;
}

int main()
{
	int i;
	pthread_t pthread[THREADS];
	char *p;
	pid_t pid;
	cpu_set_t cpumask;
	int f;
	unsigned long nodemask;

	nodemask_global = (time(NULL) & 1) + 1;
	f = creat("lock", 0400);
	if (f < 0)
		perror("creat"), exit(1);
	if (unlink("lock") < 0)
		perror("unlink"), exit(1);

	if ((pid = fork()) < 0)
		perror("fork"), exit(1);

	p_global = p = malloc(SIZE);
	if (!p)
		perror("malloc"), exit(1);
	CPU_ZERO(&cpumask);
	if (!pid) {
		nodemask = 1;
		for (i = 0; i < 6; i++)
			CPU_SET(i, &cpumask);
#if 1
		for (i = 12; i < 18; i++)
			CPU_SET(i, &cpumask);
#else
		for (i = 6; i < 12; i++)
			CPU_SET(i, &cpumask);
#endif
	} else {
		nodemask = 2;
		for (i = 6; i < 12; i++)
			CPU_SET(i, &cpumask);
		for (i = 18; i < 24; i++)
			CPU_SET(i, &cpumask);
	}
#ifdef INVERSE_BIND
	if (nodemask == 1)
		nodemask = 2;
	else if (nodemask == 2)
		nodemask = 1;
#endif
#if 0
	if (pid)
		goto skip;
#endif
#ifdef HARD_BIND
	if (sched_setaffinity(0, sizeof(cpumask), &cpumask) < 0)
		perror("sched_setaffinity"), exit(1);
#endif
#ifdef HARD_BIND
	if (set_mempolicy(MPOL_BIND, &nodemask, 3) < 0)
		perror("set_mempolicy"), printf("%lu\n", nodemask), exit(1);
#endif
#if 0
	bzero(p, SIZE);
#endif
	for (i = 0; i < THREADS; i++) {
		char *_p = p;
#ifdef THREAD_ALLOC
		_p += THREAD_SIZE * i;
#endif
		if (pthread_create(&pthread[i], NULL, thread, _p) != 0)
			perror("pthread_create"), exit(1);
	}
	for (i = 0; i < THREADS; i++)
		if (pthread_join(pthread[i], NULL) != 0)
			perror("pthread_join"), exit(1);
#if 1
skip:
#endif
	if (pid)
		if (wait(NULL) < 0)
			perror("wait"), exit(1);
	return 0;
}

--xQR6quUbZ63TTuTU
Content-Type: text/x-c; charset=us-ascii
Content-Disposition: attachment; filename="numa02.c"

/*
 *  Copyright (C) 2012  Red Hat, Inc.
 *
 *  This work is licensed under the terms of the GNU GPL, version 2. See
 *  the COPYING file in the top-level directory.
 */

#define _GNU_SOURCE
#include <pthread.h>
#include <strings.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <numaif.h>
#include <sched.h>
#include <sys/wait.h>
#include <sys/file.h>

#if 1
#define THREADS 24
#define SIZE (1UL*1024*1024*1024)
#else
#define THREADS 8
#define SIZE (500*1024*1024)
#endif
#define TOTALSIZE (4UL*1024*1024*1024*200)
#define THREAD_SIZE (SIZE/THREADS)
//#define HARD_BIND
//#define INVERSE_BIND

static void *thread(void * arg)
{
	char *p = arg;
	int i;
	for (i = 0; i < TOTALSIZE/SIZE; i++) {
		bzero(p, THREAD_SIZE);
		asm volatile("" : : : "memory");
	}
	return NULL;
}

#ifdef HARD_BIND
static void bind(int node)
{
	int i;
	unsigned long nodemask;
	cpu_set_t cpumask;
	CPU_ZERO(&cpumask);
	if (!node) {
		nodemask = 1;
		for (i = 0; i < 6; i++)
			CPU_SET(i, &cpumask);
		for (i = 12; i < 18; i++)
			CPU_SET(i, &cpumask);
	} else {
		nodemask = 2;
		for (i = 6; i < 12; i++)
			CPU_SET(i, &cpumask);
		for (i = 18; i < 24; i++)
			CPU_SET(i, &cpumask);
	}
	if (sched_setaffinity(0, sizeof(cpumask), &cpumask) < 0)
		perror("sched_setaffinity"), exit(1);
	if (set_mempolicy(MPOL_BIND, &nodemask, 3) < 0)
		perror("set_mempolicy"), printf("%lu\n", nodemask), exit(1);
}
#else
static void bind(int node) {}
#endif

int main()
{
	int i;
	pthread_t pthread[THREADS];
	char *p;
	pid_t pid;
	int f;

	p = malloc(SIZE);
	if (!p)
		perror("malloc"), exit(1);
	bind(0);
	bzero(p, SIZE/2);
	bind(1);
	bzero(p+SIZE/2, SIZE/2);
	for (i = 0; i < THREADS; i++) {
		char *_p = p + THREAD_SIZE * i;
#ifdef INVERSE_BIND
		bind(i < THREADS/2);
#else
		bind(i >= THREADS/2);
#endif
		if (pthread_create(&pthread[i], NULL, thread, _p) != 0)
			perror("pthread_create"), exit(1);
	}
	for (i = 0; i < THREADS; i++)
		if (pthread_join(pthread[i], NULL) != 0)
			perror("pthread_join"), exit(1);
	return 0;
}

--xQR6quUbZ63TTuTU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
