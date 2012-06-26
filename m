Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 56E866B0114
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 08:04:33 -0400 (EDT)
Date: Tue, 26 Jun 2012 14:03:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: AutoNUMA15
Message-ID: <20120626120325.GA25956@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <20120529133627.GA7637@shutemov.name>
 <20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
 <20120531180834.GP21339@redhat.com>
 <CAGjg+kHNe4RkhHKt5JYKDnE2oqs0ZBNUkL_XYOwfDK1S5cxjvw@mail.gmail.com>
 <20120621145552.GG4954@redhat.com>
 <4FE96A3A.2080307@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Content-Disposition: inline
In-Reply-To: <4FE96A3A.2080307@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: Alex Shi <lkml.alex@gmail.com>, Petr Holasek <pholasek@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, "Chen, Tim C" <tim.c.chen@intel.com>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 26, 2012 at 03:52:26PM +0800, Alex Shi wrote:
> Could you like to give a url for the benchmarks?

I posted them to lkml a few months ago, I'm attaching them here. There
is actually a more polished version around that I didn't have time to
test yet. For now I'm attaching the old version here that I'm still
using to verify the regressions.

If you edit the .c files to make the right hard/inverse binds, and
then build with -DHARD_BIND and later -DINVERSE_BIND you can measure
the hardware NUMA effects on your hardware. numactl --hardware will
give you the topology to check if the code is ok for your hardware.

> memory). find the openjdk has about 2% regression, while jrockit has no

2% regression is in the worst case the numa hinting page faults (or in
the best case a measurement error) when you get no benefit from the
vastly increased NUMA affinity.

You can reduce that overhead to below 1% by multiplying by 2/3 times
the /sys/kernel/mm/autonuma/knuma_scand/scan_sleep_millisecs and
/sys/kernel/mm/autonuma/knuma_scand/scan_sleep_pass_millisecs .
Especially the latter if set to 15000 will reduce the overhead by 1%.

The current AutoNUMA defaults are hyper aggressive, with benchmarks
running for several minutes you can easily reduce AutoNUMA
aggressiveness to pay a lower fixed cost in the numa hinting page
faults without reducing overall performance.

The boost when you use AutoNUMA is >20%, sometime as high as 100%, so
the 2% is lost in the noise, but over time we should reduce it
(especially with hypervisor tuned profile for those cloud nodes which
only run virtual machines in turn with quite constant loads where
there's no need to react that fast).

> the testing user 2 instances, each of them are pinned to a node. some
> setting is here:

Ok the problem is that you must not pin anything. If you hard pin
AutoNUMA won't do anything on those processes.

It is impossible to run faster than the raw hard pinning, impossible
because AutoNUMA has also to migrate memory, hard pinning avoids all
memory migrations.

AutoNUMA aims to achieve as close performance to hard pinning as
possible without having to user hard pinning, that's the whole point.

So this explains why you measure a 2% regression or no difference,
with hard pins used at all times only the AutoNUMA worst case overhead
can be measured (and I explained above how it can be reduced).

A plan I can suggest for this benchmark is this:

1) "upstream default"
  - no hugetlbfs (AutoNUMA cannot migrate hugetlbfs memory)
  - no hard pinning of CPUs or memory to nodes
  - CONFIG_AUTONUMA=n
  - CONFIG_TRANSPARENT_HUGEPAGE=y

2) "autonuma"
  - no hugetlbfs (AutoNUMA cannot migrate hugetlbfs memory)
  - no hard pinning of CPUs or memory to nodes
  - CONFIG_AUTONUMA=y
  - CONFIG_AUTONUMA_DEFAULT_ENABLED=y
  - CONFIG_TRANSPARENT_HUGEPAGE=y

3) "autonuma lower numa hinting page fault overhead"
  - no hugetlbfs (AutoNUMA cannot migrate hugetlbfs memory)
  - no hard pinning of CPUs or memory to nodes
  - CONFIG_AUTONUMA=y
  - CONFIG_AUTONUMA_DEFAULT_ENABLED=y
  - CONFIG_TRANSPARENT_HUGEPAGE=y
  - echo 15000 >/sys/kernel/mm/autonuma/knuma_scand/scan_sleep_pass_millisecs

4) "upstream hard pinning and transparent hugepage"
  - hard pinning of CPUs or memory to nodes
  - CONFIG_AUTONUMA=n
  - CONFIG_TRANSPARENT_HUGEPAGE=y

5) "upstream hard pinning and hugetlbfs"
  - hugetlbfs
  - hard pinning of CPUs or memory to nodes
  - CONFIG_AUTONUMA=n
  - CONFIG_TRANSPARENT_HUGEPAGE=y (y/n won't matter if you use hugetlbfs)

Then you can compare 1/2/3/4/5.

The minimum to make a meaningful comparison is 1 vs 2. The next best
comparison is 1 vs 2 vs 4 (4 is very useful reference too because the
closer AutoNUMA gets to 4 the better! beating 1 is trivial, getting
very close to 4 is less easy because 4 isn't migrating any memory).

Running 3 and 5 is optional, especially I mentioned 5 just because you
liked to run it with hugetlbfs and not just THP.

> jrockit use hugetlb and its options:

hugetlbfs should be disabled when AutoNUMA is enabled because AutoNUMA
won't try to migrate hugetlbfs memory, not that it makes any
difference if the memory is hard pinned. THP should deliver the same
performance of hugetlbfs for the JVM and THP memory can be migrated by
AutoNUMA (as well as mmapped not-shared pagecache, not just anon
memory).

Thanks a lot, and looking forward to see how things goes when you
remove the hard pins.

Andrea

--M9NhX3UHpAaciwkO
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

--M9NhX3UHpAaciwkO
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

//#define KVM
#ifndef KVM
#ifndef SMT
#define THREADS 24
#else
#define THREADS 12
#endif
#define SIZE (1UL*1024*1024*1024)
#else
#ifndef SMT
#define THREADS 8
#else
#define THREADS 4
#endif
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

--M9NhX3UHpAaciwkO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
