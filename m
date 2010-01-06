Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EF4346B0047
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 02:09:35 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0679W1s005776
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 16:09:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA57045DE51
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:09:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B076945DE4D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:09:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 94EB71DB803F
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:09:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E3831DB803B
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:09:31 +0900 (JST)
Date: Wed, 6 Jan 2010 16:06:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100106160614.ff756f82.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
	<20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
	<20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
	<20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Wed__6_Jan_2010_16_06_14_+0900_Q0PT66Vq4hjUMo+P"
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Wed__6_Jan_2010_16_06_14_+0900_Q0PT66Vq4hjUMo+P
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 5 Jan 2010 20:20:56 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
> > > 
> > > Of course, your other load with MADV_DONTNEED seems to be horrible, and 
> > > has some nasty spinlock issues, but that looks like a separate deal (I 
> > > assume that load is just very hard on the pgtable lock).
> > 
> > It's zone->lock, I guess. My test program avoids pgtable lock problem.
> 
> Yeah, I should have looked more at your callchain. That's nasty. Much 
> worse than the per-mm lock. I thought the page buffering would avoid the 
> zone lock becoming a huge problem, but clearly not in this case.
> 
For my mental peace, I rewrote test program as

  while () {
	touch memory
	barrier
	madvice DONTNEED all range by cpu 0
	barrier
  }
And serialize madivce().

Then, zone->lock disappears and I don't see big difference with XADD rwsem and
my tricky patch. I think I got reasonable result and fixing rwsem is the sane way.

next target will be clear_page()? hehe.
What catches my eyes is cost of memcg... (>_<  

Thank you all, 
-Kame
==
[XADD rwsem]
[root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8

 Performance counter stats for './multi-fault-all 8' (5 runs):

       33029186  page-faults                ( +-   0.146% )
      348698659  cache-misses               ( +-   0.149% )

   60.002876268  seconds time elapsed   ( +-   0.001% )

# Samples: 815596419603
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    41.51%  multi-fault-all  [kernel]                  [k] clear_page_c
     9.08%  multi-fault-all  [kernel]                  [k] down_read_trylock
     6.23%  multi-fault-all  [kernel]                  [k] up_read
     6.17%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_charg
     4.76%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     3.77%  multi-fault-all  [kernel]                  [k] __mem_cgroup_commit_ch
     3.62%  multi-fault-all  [kernel]                  [k] __rmqueue
     2.30%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     2.30%  multi-fault-all  [kernel]                  [k] page_fault
     2.12%  multi-fault-all  [kernel]                  [k] mem_cgroup_charge_comm
     2.05%  multi-fault-all  [kernel]                  [k] bad_range
     1.78%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irq
     1.53%  multi-fault-all  [kernel]                  [k] lookup_page_cgroup
     1.44%  multi-fault-all  [kernel]                  [k] __mem_cgroup_uncharge_
     1.41%  multi-fault-all  ./multi-fault-all         [.] worker
     1.30%  multi-fault-all  [kernel]                  [k] get_page_from_freelist
     1.06%  multi-fault-all  [kernel]                  [k] page_remove_rmap



[async page fault]
[root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8

 Performance counter stats for './multi-fault-all 8' (5 runs):

       33345089  page-faults                ( +-   0.555% )
      357660074  cache-misses               ( +-   1.438% )

   60.003711279  seconds time elapsed   ( +-   0.002% )


    40.94%  multi-fault-all  [kernel]                  [k] clear_page_c
     6.96%  multi-fault-all  [kernel]                  [k] vma_put
     6.82%  multi-fault-all  [kernel]                  [k] page_add_new_anon_rmap
     5.86%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_charg
     4.40%  multi-fault-all  [kernel]                  [k] __rmqueue
     4.14%  multi-fault-all  [kernel]                  [k] find_vma_speculative
     3.97%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     3.52%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     3.46%  multi-fault-all  [kernel]                  [k] __mem_cgroup_commit_ch
     2.23%  multi-fault-all  [kernel]                  [k] bad_range
     2.16%  multi-fault-all  [kernel]                  [k] mem_cgroup_charge_comm
     1.96%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irq
     1.75%  multi-fault-all  [kernel]                  [k] mem_cgroup_add_lru_lis
     1.73%  multi-fault-all  [kernel]                  [k] page_fault

--Multipart=_Wed__6_Jan_2010_16_06_14_+0900_Q0PT66Vq4hjUMo+P
Content-Type: text/x-csrc;
 name="multi-fault-all.c"
Content-Disposition: attachment;
 filename="multi-fault-all.c"
Content-Transfer-Encoding: 7bit

/*
 * multi-fault.c :: causes 60secs of parallel page fault in multi-thread.
 * % gcc -O2 -o multi-fault multi-fault.c -lpthread
 * % multi-fault # of cpus.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define NR_THREADS	8
pthread_t threads[NR_THREADS];
/*
 * For avoiding contention in page table lock, FAULT area is
 * sparse. If FAULT_LENGTH is too large for your cpus, decrease it.
 */
#define MMAP_LENGTH	(8 * 1024 * 1024)
#define FAULT_LENGTH	(2 * 1024 * 1024)
void *mmap_area[NR_THREADS];
#define PAGE_SIZE	4096

pthread_barrier_t barrier;
int name[NR_THREADS];

void segv_handler(int sig)
{
	sleep(100);
}

int num;
void *worker(void *data)
{
	cpu_set_t set;
	int i, cpu;

	cpu = *(int *)data;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	while (1) {
		char *c;
		char *start = mmap_area[cpu];
		char *end = mmap_area[cpu] + FAULT_LENGTH;
		pthread_barrier_wait(&barrier);
		//printf("fault into %p-%p\n",start, end);

		for (c = start; c < end; c += PAGE_SIZE)
			*c = 0;

		pthread_barrier_wait(&barrier);
		for (i = 0; cpu==0 && i < num; i++)
			madvise(mmap_area[i], FAULT_LENGTH, MADV_DONTNEED);
		pthread_barrier_wait(&barrier);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int i, ret;

	if (argc < 2)
		return 0;

	num = atoi(argv[1]);	
	pthread_barrier_init(&barrier, NULL, num);

	mmap_area[0] = mmap(NULL, MMAP_LENGTH * num, PROT_WRITE|PROT_READ,
				MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	for (i = 1; i < num; i++) {
		mmap_area[i] = mmap_area[i - 1]+ MMAP_LENGTH;
	}

	for (i = 0; i < num; ++i) {
		name[i] = i;
		ret = pthread_create(&threads[i], NULL, worker, &name[i]);
		if (ret < 0) {
			perror("pthread create");
			return 0;
		}
	}
	sleep(60);
	return 0;
}

--Multipart=_Wed__6_Jan_2010_16_06_14_+0900_Q0PT66Vq4hjUMo+P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
