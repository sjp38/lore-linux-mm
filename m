Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E07346B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 21:11:25 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L2BG1S005428
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Jan 2010 11:11:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84A9D45DE54
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 11:11:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A1C945DE4F
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 11:11:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB68E18004
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 11:11:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D5A7B1DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 11:11:15 +0900 (JST)
Date: Thu, 21 Jan 2010 11:07:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg use generic percpu allocator instead of
 private one
Message-Id: <20100121110759.250ed739.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B56CEF0.2040406@linux.vnet.ibm.com>
References: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com>
	<4B56CEF0.2040406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Thu__21_Jan_2010_11_07_59_+0900_sG8dNNtnL3RTT6sn"
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Thu__21_Jan_2010_11_07_59_+0900_sG8dNNtnL3RTT6sn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 20 Jan 2010 15:07:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
 
> > This includes no functional changes.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> Before review, could you please post parallel pagefault data on a large
> system, since root now uses these per cpu counters and its overhead is
> now dependent on these counters. Also the data read from root cgroup is
> also dependent on these, could you make sure that is not broken.
> 
Hmm, I rewrote test program for avoidng mmap_sem. This version does fork()
instead of pthread_create() and meausre parallel-process page fault speed.

[Before patch]
[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8

 Performance counter stats for './multi-fault-fork 8' (5 runs):

       45256919  page-faults                ( +-   0.851% )
      602230144  cache-misses               ( +-   0.187% )

   61.020533723  seconds time elapsed   ( +-   0.002% 

[After patch]
[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-fork 8

 Performance counter stats for './multi-fault-fork 8' (5 runs):

       46007166  page-faults                ( +-   0.339% )
      599553505  cache-misses               ( +-   0.298% )

   61.020937843  seconds time elapsed   ( +-   0.004% )

slightly improved ? But this test program does some extreme behavior and
you can't see difference in real-world applications, I think.
So, I guess this is in error-range in famous (not small) benchmarks.

Thanks,
-Kame

--Multipart=_Thu__21_Jan_2010_11_07_59_+0900_sG8dNNtnL3RTT6sn
Content-Type: text/x-csrc;
 name="multi-fault-fork.c"
Content-Disposition: attachment;
 filename="multi-fault-fork.c"
Content-Transfer-Encoding: 7bit

/*
 * multi-fault.c :: causes 60secs of parallel page fault in multi-thread.
 * % gcc -O2 -o multi-fault multi-fault.c -lpthread
 * % multi-fault # of cpus.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>

/*
 * For avoiding contention in page table lock, FAULT area is
 * sparse. If FAULT_LENGTH is too large for your cpus, decrease it.
 */
#define FAULT_LENGTH	(2 * 1024 * 1024)
#define PAGE_SIZE	4096

void alarm_handler(int sig)
{
}

void *worker(int cpu, int ppid)
{
	void *start, *end;
	char *c;
	cpu_set_t set;
	int i;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	start = mmap(NULL, FAULT_LENGTH, PROT_READ|PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	if (start == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	end = start + FAULT_LENGTH;

	pause();
	//fprintf(stderr, "run%d", cpu);
	while (1) {
		for (c = (char*)start; (void *)c < end; c += PAGE_SIZE)
			*c = 0;
		madvise(start, FAULT_LENGTH, MADV_DONTNEED);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int num, i, ret, pid;

	if (argc < 2)
		return 0;

	setpgid(0, 0);
	signal(SIGALRM, alarm_handler);
	num = atoi(argv[1]);	
	pid = getpid();

	for (i = 0; i < num; ++i) {
		if (fork()) {
			worker(i, pid);
		}
	}
	sleep(1);
	kill(-pid, SIGALRM);
	sleep(60);
	kill(-pid, SIGKILL);
	return 0;
}

--Multipart=_Thu__21_Jan_2010_11_07_59_+0900_sG8dNNtnL3RTT6sn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
