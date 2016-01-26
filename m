Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7686B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 02:48:05 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id o11so129699904qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 23:48:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c16si29270522qkb.85.2016.01.25.23.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 23:48:04 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: Re: [LTP] [BUG] oom hangs the system, NMI backtrace shows most CPUs
 in shrink_slab
References: <569D06F8.4040209@redhat.com>
 <569E1010.2070806@I-love.SAKURA.ne.jp> <56A24760.5020503@redhat.com>
Message-ID: <56A724B1.3000407@redhat.com>
Date: Tue, 26 Jan 2016 08:48:01 +0100
MIME-Version: 1.0
In-Reply-To: <56A24760.5020503@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------090203050506050602070101"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org
Cc: ltp@lists.linux.it

This is a multi-part message in MIME format.
--------------090203050506050602070101
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 01/22/2016 04:14 PM, Jan Stancek wrote:
> On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
>> although I
>> couldn't find evidence that mlock() and madvice() are related with this hangup,
> 
> I simplified reproducer by having only single thread allocating
> memory when OOM triggers:
>   http://jan.stancek.eu/tmp/oom_hangs/console.log.3-v4.4-8606-with-memalloc.txt
> 
> In this instance it was mmap + mlock, as you can see from oom call trace.
> It made it to do_exit(), but couldn't complete it:

I have extracted test from LTP into standalone reproducer (attached),
if you want to give a try. It usually hangs my system within ~30
minutes. If it takes too long, you can try disabling swap. From my past
experience this usually helped to reproduce it faster on small KVM guests.

# gcc oom_mlock.c -pthread -O2
# echo 1 > /proc/sys/vm/overcommit_memory
(optionally) # swapoff -a
# ./a.out

Also, it's interesting to note, that when I disabled mlock() calls
test ran fine over night. I'll look into confirming this observation
on more systems.

Regards,
Jan

--------------090203050506050602070101
Content-Type: text/x-csrc;
 name="oom_mlock.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="oom_mlock.c"

#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>

/*
 * oom hang reproducer v1
 *
 * # gcc oom_mlock.c -pthread -O2
 * # echo 1 > /proc/sys/vm/overcommit_memory
 * (optionally) # swapoff -a
 * # ./a.out
 */

#define _1GB (1024L*1024*1024)

static do_mlock = 1;

static int alloc_mem(long int length)
{
	char *s;
	long i, pagesz = getpagesize();
	int loop = 10;

	printf("thread (%lx), allocating %ld bytes, do_mlock: %d\n",
		(unsigned long) pthread_self(), length, do_mlock);

	s = mmap(NULL, length, PROT_READ | PROT_WRITE,
		 MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	if (s == MAP_FAILED)
		return errno;

	if (do_mlock) {
		while (mlock(s, length) == -1 && loop > 0) {
			if (EAGAIN != errno)
				return errno;
			usleep(300000);
			loop--;
		}
	}

	for (i = 0; i < length; i += pagesz)
		s[i] = '\a';

	return 0;
}

void *alloc_thread(void *args)
{
	int ret;

	do {
		ret = alloc_mem(3 * _1GB);
	} while (ret == 0);

	exit(ret);
}

int trigger_oom(void)
{
	int i, ret, child, status, threads;
	pthread_t *th;

	threads = sysconf(_SC_NPROCESSORS_ONLN) - 1;
	th = malloc(sizeof(pthread_t) * threads);
	if (!th) {
		printf("malloc failed\n");
		exit(2);
	}

	do_mlock = !do_mlock;
	child = fork();
	if (child == 0) {
		for (i = 0; i < threads - 1; i++) {
			ret = pthread_create(&th[i], NULL, alloc_thread, NULL);
			if (ret) {
				printf("pthread_create failed with %d\n", ret);
				exit(3);
			}
		}
		pause();
	}
	
	if (waitpid(-1, &status, 0) == -1) {
		perror("waitpid");
		exit(1);
	}

	if (WIFSIGNALED(status)) {
		printf("child killed by %d\n", WTERMSIG(status));
		if (WTERMSIG(status) != SIGKILL)
			exit(1);
	}
	
	if (WIFEXITED(status)) {
		printf("child exited with %d\n", WEXITSTATUS(status));
		if (WEXITSTATUS(status) != ENOMEM)
			exit(1);
	}
}

int main(void)
{
	int i = 1;

	while (1) {
		printf("starting iteration %d\n", i++);
		trigger_oom();
	}

	return 0;
}


--------------090203050506050602070101--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
