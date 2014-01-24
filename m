Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 97C996B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:31:59 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so1562409bkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:31:59 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id tq3si4676354bkb.315.2014.01.24.15.31.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 15:31:58 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so4750781qab.9
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:31:57 -0800 (PST)
Date: Fri, 24 Jan 2014 18:31:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty
 cache
Message-ID: <20140124233153.GA3422@htj.dyndns.org>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
 <20140124222144.GA3197@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
Content-Disposition: inline
In-Reply-To: <20140124222144.GA3197@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 24, 2014 at 05:21:44PM -0500, Tejun Heo wrote:
> The trigger conditions seem quite plausible - high anon memory usage
> w/ heavy buffered IO and swap configured - and it's highly likely that
> this is happening in the wild too.  (this can happen with copying
> large files to usb sticks too, right?)

So, just tested with the usb stick and these two patches, while not
perfect, make a world of difference.  The problem is really easy to
reproduce on my machine which has 8gig of memory with the two attached
test programs.

* run "test-membloat 4300" and wait for it to report completion.

* run "test-latency"

Mount a slow USB stick and copy a large (multi-gig) file to it.
test-latency tries to print out a dot every 10ms but will report a
log2 number if the latency becomes more than twice high - ie. 4 means
it took 2^4 * 10ms to complete a loop which is supposed to take
slightly longer than 10ms (10ms sleep + 4 page fault).  My USB stick
only can do a couple mbytes/s and without these patches the machine
becomes basically useless.  It's just not useable, it stutters more
than it runs until the whole file finishes copying.

Because I've been using tmpfs as build target for a while, I've been
experiencing this occassionally and secretly growing bitter
disappointment towards the linux kernel which developed into
self-loathing to the point where I found booting into win8 consoling
after looking at my machine stuttering for 45mins while it was
repartitioning the hard drive to make room for steamos.  Oh the irony.
I had to stay in fetal position for a while afterwards.  It was a
crisis.

With the patches applied, for both heavy harddrive IO and
copy-large-file-to-slow-USB cases, the behavior is vastly improved.
It does stutter for a while once memory is filled up but stabilizes in
somewhere above ten seconds and then stays responsive.  While it isn't
perfect, it's not completely ridiculous as before.

So, lots of kudos to Johannes for *finally* fixing the issue and I
strongly believe this is something we should consider for -stable even
if that takes considerable amount of effort to verify it's not too
harmful for other workloads.

Thanks a lot.

-- 
tejun

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test-latency.c"

#include <stdio.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <time.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>

#define NR_ALPHAS	('z' - 'a' + 1)

int main(int argc, char **argv)
{
	struct timespec intv_ts = { }, ts;
	unsigned long long time0, time1;
	long long msecs = 10;
	const size_t map_size = 4096 * 4;

	if (argc > 1) {
		msecs = atoll(argv[1]);
		if (msecs <= 0) {
			fprintf(stderr, "test-latency [interval-in-msecs]\n");
			return 1;
		}
	}

	intv_ts.tv_sec = msecs / 1000;
	intv_ts.tv_nsec = (msecs % 1000) * 1000000;

	clock_gettime(CLOCK_MONOTONIC, &ts);
	time1 = ts.tv_sec * 1000000000LLU + ts.tv_nsec;

	while (1) {
		void *map, *p;
		int idx;
		char c;

		nanosleep(&intv_ts, NULL);
		map = mmap(NULL, map_size, PROT_READ | PROT_WRITE,
			   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
		if (map == MAP_FAILED) {
			perror("mmap");
			return 1;
		}

		for (p = map; p < map + map_size; p += 4096)
			*(volatile unsigned long *)p = 0xdeadbeef;

		munmap(map, map_size);

		time0 = time1;
		clock_gettime(CLOCK_MONOTONIC, &ts);
		time1 = ts.tv_sec * 1000000000LLU + ts.tv_nsec;

		idx = (time1 - time0) / msecs / 1000000;
		idx = log2(idx);
		if (idx <= 1) {
			c = '.';
		} else {
			if (idx > 9)
				idx = 9;
			c = '0' + idx;
		}
		write(1, &c, 1);
	}
}

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test-membloat.c"

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	struct timespec ts_100s = { .tv_sec = 100 };
	long mbytes, cnt;
	void *map, *p;
	int fd = -1;
	int flags;

	if (argc < 2 || (mbytes = atol(argv[1])) <= 0) {
		fprintf(stderr, "test-membloat SIZE_IN_MBYTES [FILENAME]\n");
		return 1;
	}

	if (argc >= 3) {
		fd = open(argv[2], O_CREAT|O_TRUNC|O_RDWR, S_IRWXU);
		if (fd < 0) {
			perror("open");
			return 1;
		}

		if (ftruncate(fd, mbytes << 20)) {
			perror("ftruncate");
			return 1;
		}

		flags = MAP_SHARED;
	} else {
		flags = MAP_ANONYMOUS | MAP_PRIVATE;
	}

	map = mmap(NULL, (size_t)mbytes << 20, PROT_READ | PROT_WRITE,
		   flags, fd, 0);
	if (map == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	for (p = map, cnt = 0; p < map + (mbytes << 20); p += 4096) {
		*(volatile unsigned long *)p = 0xdeadbeef;
		cnt++;
	}

	printf("faulted in %ld mbytes, %ld pages\n", mbytes, cnt);

	while (1)
		nanosleep(&ts_100s, NULL);

	return 0;
}

--7JfCtLOvnd9MIVvH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
