From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 0/3] activate pages in batch
References: <20081023104002.1CEA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<87prlsjcjg.fsf@saeurebad.de>
	<20081023110723.1CF0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Thu, 23 Oct 2008 18:21:41 +0200
In-Reply-To: <20081023110723.1CF0.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI
	Motohiro's message of "Thu, 23 Oct 2008 11:10:16 +0900 (JST)")
Message-ID: <87abcvjn8q.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

>> >> Instead of re-acquiring the highly contented LRU lock on every single
>> >> page activation, deploy an extra pagevec to do page activation in
>> >> batch.
>> >
>> > Do you have any mesurement result?
>> 
>> Not yet, sorry.
>> 
>> Spinlocks are no-ops on my architecture, though, so the best I can come
>> up with is results from emulating an SMP machine, would that be okay?
>
> it's not ok..

Ok.

> if you can explain best mesurement way, I can mesure on 8 way machine
> :)

Hmm, the `best way' is probably something else, but I played with the
attached program.  It causes around as much activations as I read in
pages and a lot of scanning, too, so perhaps this could work.  On your
box, you most likely need to turn up the knobs a bit, though ;)

> (but, of cource, I should mesure your madv_sequence patch earlier)

Thanks a lot for this, btw!

        Hannes

---
Sample output from the program:

$ egrep '(pgactivate|pgscan_direct_normal)' /proc/vmstat; \
  /usr/bin/time ./activate-reclaim-smp; \
  egrep '(pgactivate|pgscan_direct_normal)' /proc/vmstat

pgactivate 9587603
pgscan_direct_normal 8150176
2: warning, can not migrate to cpu
1: warning, can not migrate to cpu
<snipped warnings, you shouldn't get those, of course!>
/loader
/children
1.93user 16.36system 0:58.17elapsed 31%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (31major+526765minor)pagefaults 0swaps
pgactivate 9856316
pgscan_direct_normal 8603232

---
#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/mman.h>

#define NR_CPUS		8
#define PROCS_PER_CPU	4

#define NR_PROCS	(NR_CPUS * PROCS_PER_CPU)

#define FILE_SIZE       (1<<30)
#define ANON_SIZE       (1<<30)

static void move_self_to(int cpu)
{
	cpu_set_t set;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	if (sched_setaffinity(0, sizeof(set), &set))
		printf("%d: warning, can not migrate to cpu\n", cpu);
	sched_yield();
}

/* generate file pages */
static void reader(int cpu)
{
	int fd;
	char buf;
	unsigned long off;

	fd = open("zeroes", O_RDONLY);
	if (fd < 0) {
		printf("%d: open() failed\n", cpu);
		return;
	}

	for (off = 0; off < FILE_SIZE; off += sysconf(_SC_PAGESIZE)) {
		if (!read(fd, &buf, 1))
			puts("huh?");
		lseek(fd, off, SEEK_SET);
	}
	close(fd);
}

/* generate anon pages to trigger reclaims */
static void loader(void)
{
	char *map;
	unsigned long offset;

	map = mmap(NULL, ANON_SIZE, PROT_READ, MAP_PRIVATE|MAP_ANON, -1, 0);
	if (!map) {
		printf("failed to anon-map\n");
		return;
	}

	for (offset = 0; offset < ANON_SIZE; offset += sysconf(_SC_PAGESIZE))
		if (map[offset])
			puts("huh?");

	munmap(map, ANON_SIZE);
}

static pid_t spawn_on(int cpu)
{
	pid_t child = fork();

	switch (child) {
	case -1:
		printf("%d: fork() failed\n", cpu);
		exit(1);
	case 0:
		move_self_to(cpu);
		reader(cpu);
		exit(0);
	default:
		return child;
	}
}

int main(void)
{
	int cpu = -1, proc;
	pid_t children[NR_PROCS];

	while (++cpu < NR_CPUS)
		for (proc = 0; proc < PROCS_PER_CPU; proc++)
			children[cpu+proc] = spawn_on(cpu);

	loader();
	loader();
	puts("/loader");

	for (proc = 0; proc < NR_PROCS; proc++)
		waitpid(children[proc], &cpu, 0);
	puts("/children");

	return 0;
}
		

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
