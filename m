Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 113BD6007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 20:35:30 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB31ZRoD028951
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Dec 2009 10:35:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5455C45DE4C
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:35:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FBD745DE4F
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:35:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0819E1DB8043
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:35:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF7021DB8038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:35:26 +0900 (JST)
Date: Thu, 3 Dec 2009 10:32:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mmotm][PATCH] percpu mm struct counter cache
Message-Id: <20091203103234.d53f5fde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091203102851.daeb940c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091203102851.daeb940c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

This is a test program for measuring page fault cost, I used.
This program creates threads on cpu 0,4,8,....(because I use 4code cpu)
and cause page faults on each cpu in parallel.
If you run too many threads, spin_lock costs will dominates all...
I used just 2 threads in measurements, cpu 0 and 4.

==
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
