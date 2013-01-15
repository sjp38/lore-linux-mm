Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id EF23C8D0001
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 13:10:04 -0500 (EST)
Date: Tue, 15 Jan 2013 12:10:03 -0600
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: Improving lock pages
Message-ID: <20130115181003.GA9352@gulag1.americas.sgi.com>
References: <20130115173814.GA13329@gulag1.americas.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Content-Disposition: inline
In-Reply-To: <20130115173814.GA13329@gulag1.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Mel Gorman <mgorman@suse.de>, holt@sgi.com, linux-mm@kvack.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 15, 2013 at 11:38:14AM -0600, Nathan Zimmer wrote:
> 
> Hello Mel,
>     You helped some time ago with contention in lock_pages on very large boxes. 
> You worked with Jack Steiner on this.  Currently I am tasked with improving this 
> area even more.  So I am fishing for any more ideas that would be productive or 
> worth trying. 
> 
> I have some numbers from a 512 machine.
> 
> Linux uvpsw1 3.0.51-0.7.9-default #1 SMP Thu Nov 29 22:12:17 UTC 2012 (f3be9d0) x86_64 x86_64 x86_64 GNU/Linux
>       0.166850
>       0.082339
>       0.248428
>       0.081197
>       0.127635
> 
> Linux uvpsw1 3.8.0-rc1-medusa_ntz_clean-dirty #32 SMP Tue Jan 8 16:01:04 CST 2013 x86_64 x86_64 x86_64 GNU/Linux
>       0.151778
>       0.118343
>       0.135750
>       0.437019
>       0.120536
> 
> Nathan Zimmer
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

I realized I forgot to attach the test.

The test is fairly basic.  Just fork off a number of threads each on their own cpu
have them all wait on a cell and measure how long it took for them to all exit.

Usage is ./time_exit -p 3 512

The numbers I have provided where from some runs on a 512 system.  I tried for
a 4096 box but it was being fickle and was needed for some other testing.


--wac7ysb48OaltWcw
Content-Type: text/x-c++src; charset=us-ascii
Content-Disposition: attachment; filename="time_exit.c"

#define _GNU_SOURCE
#include <errno.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/time.h>
#include <sys/wait.h>

struct time_exit {
	volatile int ready	__attribute__((aligned(64)));
	volatile int quit	__attribute__((aligned(64)));
};

#define cpu_relax()             asm volatile ("rep;nop":::"memory");

#define MAXCPUS 4096
static int cpu_set_size;
static cpu_set_t *task_affinity;
static int delay;

static void pin(int cpu)
{
	cpu_set_t *affinity;

	if (cpu < 0 || cpu >= MAXCPUS)
		return;

	affinity = CPU_ALLOC(MAXCPUS);
	CPU_ZERO_S(cpu_set_size, affinity);
	CPU_SET_S(cpu, cpu_set_size, affinity);
	(void)sched_setaffinity(0, cpu_set_size, affinity);
	CPU_FREE(affinity);
	return;
}

static void child(struct time_exit *sharep, int cpu)
{
	pin(cpu);
	__sync_fetch_and_add(&sharep->ready, 1);
	while (sharep->quit == 0)
		cpu_relax();
	exit(0);
}

int main(int argc, char **argv)
{
	int children, i;
	struct time_exit *sharep;
	struct timeval tv0, tv1;
	long secs, usecs;
	char opt;

	while ((opt = getopt(argc, argv, "p:")) != -1) {
		switch (opt) {
		case 'p':
			delay = atoi(optarg);
			break;
		default:
			fprintf(stderr, "Usage:\n");
		}
	}
	argv += optind - 1;
	argc -= optind - 1;
	if (argc != 2) {
		printf("Wrong\n");
		exit(-1);
	}
	children = atoi(argv[1]);

	cpu_set_size = CPU_ALLOC_SIZE(MAXCPUS);
	task_affinity = CPU_ALLOC(MAXCPUS);
	if (sched_getaffinity(0, cpu_set_size, task_affinity) < 0) {
		perror("Failed in sched_getaffinitt");
		exit(-2);
	}

	sharep = mmap(0, sizeof(struct time_exit), PROT_READ | PROT_WRITE,
			MAP_ANONYMOUS | MAP_SHARED, -1, 0);

	for (i = 0; i < children; i++)
		if (fork() == 0)
			child(sharep, i);

	while (sharep->ready != children)
		cpu_relax();

	if (delay)
		sleep(delay);

	gettimeofday(&tv0, NULL);
	sharep->quit = 1;
	while (wait(&i) > 0)
		cpu_relax();
	gettimeofday(&tv1, NULL);

	usecs = tv1.tv_usec - tv0.tv_usec;
	secs = tv1.tv_sec - tv0.tv_sec;
	if (usecs < 0) {
		secs--;
		usecs += 1000000;
	}
	printf("%7ld.%06ld\n", secs, usecs);

	return 0;
}

--wac7ysb48OaltWcw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
