Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AE6326B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 22:23:49 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o133Nlu4012715
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Feb 2010 12:23:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8F6345DE60
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:23:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA6C445DE4D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:23:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A341E1DB803A
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:23:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D0371DB8037
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:23:43 +0900 (JST)
Date: Wed, 3 Feb 2010 12:20:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: use generic percpu instead of private
 implementation
Message-Id: <20100203122021.619d250f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100203121624.bab7be2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100203121624.bab7be2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Here is a test program I used.

 1. fork() processes on each cpus.
 2. do page fault repeatedly on each process.
 3. after 60secs, kill all childredn and exit.

(3 is necessary for getting stable data, this is improvement from previous one.)

Bye.
-Kame
==

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
#define MAXNUM		(128)

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
	int num, i, ret, pid, status;
	int pids[MAXNUM];

	if (argc < 2)
		return 0;

	setpgid(0, 0);
	signal(SIGALRM, alarm_handler);
	num = atoi(argv[1]);	
	pid = getpid();

	for (i = 0; i < num; ++i) {
		ret = fork();
		if (!ret) {
			worker(i, pid);
			exit(0);
		}
		pids[i] = ret;
	}
	sleep(1);
	kill(-pid, SIGALRM);
	sleep(60);
	for (i = 0; i < num; i++)
		kill(pids[i], SIGKILL);
	for (i = 0; i < num; i++)
		waitpid(pids[i], &status, 0);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
