Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AAD1C6B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:12:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF9C7ix021322
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 18:12:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B3A945DE7B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:12:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8DE245DE79
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:12:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8120F1DB8037
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:12:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C0B81DB803B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:12:06 +0900 (JST)
Date: Tue, 15 Dec 2009 18:09:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 0/5] mm rss counting updates
Message-Id: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__15_Dec_2009_18_09_04_+0900_rS5pWCQBUAEbLDqN"
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, minchan.kim@gmail.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Tue__15_Dec_2009_18_09_04_+0900_rS5pWCQBUAEbLDqN
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


This is version 3 or 4....for rss counting. removed RFC.

My purpose is gathering more (rss-related) information per process without
scalability impact. (and improve oom-killer etc..)
The whole patch series is organized as

 [1/5] clean-up per mm stat counting.
 [2/5] making counter (a bit) more scalable with per-thread counting.
 [3/5] adding swap counter per mm
 [4/5] adding lowmem detection logic
 [5/5] adding lowmem usage counter per mm.

Big changes from previous one are...
  - removed per-cpu counter. added per-thread counter
  - synchronization point of a counter is moved to memory.c
    no hooks to ticks and scheduler.

Now, this patch is not very invasive as previous ones.

cache-miss/page fault with my benchmark on my box is

 [Before patch] 4.55 cache-miss/fault
 [After patch 2] 3.99 cache-miss/fault
 [After all patch] 4.06 cache-miss/fault

>From this numbers, I think swap/lowmem counters can be added.

My test program is attached (this is not modified from previous one)

[Future Plan]
 - add CONSTRAINT_LOWMEM oom killer.
 - add rss+swap based oom killer (with sysctl ?)
 - add some patch for perf ?
 - add mm_accessor patch.
 - improve page faults scalability, finally.

Thanks,
-Kame

--Multipart=_Tue__15_Dec_2009_18_09_04_+0900_rS5pWCQBUAEbLDqN
Content-Type: text/x-csrc;
 name="multi-fault.c"
Content-Disposition: attachment;
 filename="multi-fault.c"
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

#define CORE_PER_SOCK	4
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
void *worker(void *data)
{
	cpu_set_t set;
	int cpu;

	cpu = *(int *)data;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	cpu /= CORE_PER_SOCK;

	while (1) {
		char *c;
		char *start = mmap_area[cpu];
		char *end = mmap_area[cpu] + FAULT_LENGTH;
		pthread_barrier_wait(&barrier);
		//printf("fault into %p-%p\n",start, end);

		for (c = start; c < end; c += PAGE_SIZE)
			*c = 0;
		pthread_barrier_wait(&barrier);

		madvise(start, FAULT_LENGTH, MADV_DONTNEED);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int i, ret;
	unsigned int num;

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
		name[i] = i * CORE_PER_SOCK;
		ret = pthread_create(&threads[i], NULL, worker, &name[i]);
		if (ret < 0) {
			perror("pthread create");
			return 0;
		}
	}
	sleep(60);
	return 0;
}

--Multipart=_Tue__15_Dec_2009_18_09_04_+0900_rS5pWCQBUAEbLDqN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
