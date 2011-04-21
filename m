Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B6F5D8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:26:08 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QCttY-0003u9-1h
	for linux-mm@kvack.org; Thu, 21 Apr 2011 13:26:08 +0000
Subject: Re: [PATCH 19/20] mm: Convert anon_vma->lock to a mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130732.da620ce7.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121726.230302401@chello.nl>
	 <20110419130732.da620ce7.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 15:28:24 +0200
Message-ID: <1303392504.2035.137.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Tue, 2011-04-19 at 13:07 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:17 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Straight fwd conversion of anon_vma->lock to a mutex.
> 
> What workloads do we expect might be adversely affected by this? 
> Were such workloads tested?  With what results?


The worst affected workload would be a lightly contended lock, uncontended
mutexes are similarly fast as uncontended spinlocks, highly contended mutexes
win hands down since we waste vastly less resources spinning, leaving
lightly contended.

The below shows a workload tailored to isolate this one lock and is tested with
various numbers of contending tasks ran on a dual socket westmere EP (2*6*2),
the first results are from an unpatched -tip kernel, the second set is with
the patches applied:


	48		24		12		6		3

real    2m14.152s	1m7.976s	0m32.607s	0m13.593s	0m5.464s
sys     53m1.628s	27m7.502s	6m30.265s	1m22.047s	0m16.693s

real    1m14.742s	0m34.823s	0m26.320s	0m12.647s	0m4.896s
sys     4m51.984s	2m7.259s	2m11.851s	0m52.916s	0m13.610s



---

[root@westmere ~]# echo 0 > /proc/sys/kernel/nmi_watchdog 
[root@westmere ~]# for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ; do echo performance > $i; done
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 48 50000

 Performance counter stats for './mmap-merge 48 50000' (10 runs):

          4.142580 task-clock-msecs         #      0.000 CPUs    ( +-   2.738% )
                48 context-switches         #      0.012 M/sec   ( +-   0.000% )
                65 CPU-migrations           #      0.016 M/sec   ( +-   1.357% )
               250 page-faults              #      0.060 M/sec   ( +-   0.040% )
        10,918,844 cycles                   #   2635.759 M/sec   ( +-   2.759% )
         3,697,498 instructions             #      0.339 IPC     ( +-   3.023% )
           756,868 branches                 #    182.705 M/sec   ( +-   5.291% )
            21,012 branch-misses            #      2.776 %       ( +-   1.964% )
           126,172 cache-references         #     30.457 M/sec   ( +-   1.303% )
            53,508 cache-misses             #     12.917 M/sec   ( +-   2.845% )

       13.368707820  seconds time elapsed   ( +-   0.572% )


real    2m14.152s
user    0m0.786s
sys     53m1.628s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 24 50000

 Performance counter stats for './mmap-merge 24 50000' (10 runs):

          1.766450 task-clock-msecs         #      0.000 CPUs    ( +-   1.300% )
                22 context-switches         #      0.012 M/sec   ( +-   1.174% )
                23 CPU-migrations           #      0.013 M/sec   ( +-   0.000% )
               178 page-faults              #      0.101 M/sec   ( +-   0.101% )
         4,692,314 cycles                   #   2656.353 M/sec   ( +-   1.367% )
         1,911,120 instructions             #      0.407 IPC     ( +-   0.578% )
           374,376 branches                 #    211.937 M/sec   ( +-   0.588% )
            10,575 branch-misses            #      2.825 %       ( +-   1.778% )
            63,062 cache-references         #     35.700 M/sec   ( +-   1.400% )
            20,580 cache-misses             #     11.650 M/sec   ( +-   7.064% )

        6.795076582  seconds time elapsed   ( +-   0.546% )


real    1m7.976s
user    0m0.361s
sys     27m7.502s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 12 50000

 Performance counter stats for './mmap-merge 12 50000' (10 runs):

          0.854767 task-clock-msecs         #      0.000 CPUs    ( +-   1.354% )
                11 context-switches         #      0.013 M/sec   ( +-   3.030% )
                12 CPU-migrations           #      0.014 M/sec   ( +-   0.000% )
               142 page-faults              #      0.166 M/sec   ( +-   0.126% )
         2,264,106 cycles                   #   2648.798 M/sec   ( +-   1.285% )
         1,138,411 instructions             #      0.503 IPC     ( +-   0.814% )
           217,651 branches                 #    254.631 M/sec   ( +-   0.740% )
             6,632 branch-misses            #      3.047 %       ( +-   1.857% )
            34,727 cache-references         #     40.628 M/sec   ( +-   1.217% )
            10,195 cache-misses             #     11.927 M/sec   ( +-   6.837% )

        3.258410151  seconds time elapsed   ( +-   0.415% )


real    0m32.607s
user    0m0.222s
sys     6m30.265s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 6 50000

 Performance counter stats for './mmap-merge 6 50000' (10 runs):

          0.554700 task-clock-msecs         #      0.000 CPUs    ( +-   2.391% )
                 5 context-switches         #      0.010 M/sec   ( +-   5.660% )
                 6 CPU-migrations           #      0.011 M/sec   ( +-   0.000% )
               124 page-faults              #      0.224 M/sec   ( +-   0.107% )
         1,497,189 cycles                   #   2699.096 M/sec   ( +-   1.941% )
           794,179 instructions             #      0.530 IPC     ( +-   0.930% )
           151,675 branches                 #    273.436 M/sec   ( +-   0.903% )
             5,795 branch-misses            #      3.820 %       ( +-   2.436% )
            24,981 cache-references         #     45.036 M/sec   ( +-   1.101% )
             5,931 cache-misses             #     10.693 M/sec   ( +-   4.373% )

        1.356908302  seconds time elapsed   ( +-   0.981% )


real    0m13.593s
user    0m0.104s
sys     1m22.047s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 3 50000

 Performance counter stats for './mmap-merge 3 50000' (10 runs):

          0.413204 task-clock-msecs         #      0.001 CPUs    ( +-   3.120% )
                 3 context-switches         #      0.007 M/sec   ( +-   4.762% )
                 3 CPU-migrations           #      0.007 M/sec   ( +-   0.000% )
               115 page-faults              #      0.279 M/sec   ( +-   0.203% )
         1,132,363 cycles                   #   2740.446 M/sec   ( +-   2.553% )
           609,942 instructions             #      0.539 IPC     ( +-   0.778% )
           117,542 branches                 #    284.464 M/sec   ( +-   0.762% )
             5,000 branch-misses            #      4.254 %       ( +-   2.445% )
            17,825 cache-references         #     43.138 M/sec   ( +-   1.869% )
             3,358 cache-misses             #      8.126 M/sec   ( +-   7.906% )

        0.543944086  seconds time elapsed   ( +-   0.846% )


real    0m5.464s
user    0m0.052s
sys     0m16.693s


----

[root@westmere ~]# echo 0 > /proc/sys/kernel/nmi_watchdog 
[root@westmere ~]# for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ; do echo performance > $i; done
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 48 50000

 Performance counter stats for './mmap-merge 48 50000' (10 runs):

          3.707111 task-clock-msecs         #      0.000 CPUs    ( +-   3.961% )
                63 context-switches         #      0.017 M/sec   ( +-   8.853% )
                50 CPU-migrations           #      0.014 M/sec   ( +-   1.394% )
               250 page-faults              #      0.067 M/sec   ( +-   0.040% )
         9,564,633 cycles                   #   2580.078 M/sec   ( +-   4.053% )
         3,567,454 instructions             #      0.373 IPC     ( +-   1.245% )
           690,477 branches                 #    186.257 M/sec   ( +-   1.650% )
            21,207 branch-misses            #      3.071 %       ( +-   2.731% )
           142,269 cache-references         #     38.377 M/sec   ( +-   1.844% )
            58,300 cache-misses             #     15.727 M/sec   ( +-   1.927% )

        7.471369198  seconds time elapsed   ( +-  10.095% )


real    1m14.742s
user    0m1.825s
sys     4m51.984s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 24 50000

 Performance counter stats for './mmap-merge 24 50000' (10 runs):

          1.757956 task-clock-msecs         #      0.001 CPUs    ( +-   2.702% )
                34 context-switches         #      0.019 M/sec   ( +-  10.810% )
                24 CPU-migrations           #      0.014 M/sec   ( +-   1.394% )
               178 page-faults              #      0.101 M/sec   ( +-   0.056% )
         4,554,679 cycles                   #   2590.894 M/sec   ( +-   2.721% )
         1,929,470 instructions             #      0.424 IPC     ( +-   0.882% )
           371,094 branches                 #    211.094 M/sec   ( +-   1.441% )
            11,699 branch-misses            #      3.152 %       ( +-   2.183% )
            71,996 cache-references         #     40.954 M/sec   ( +-   1.119% )
            25,416 cache-misses             #     14.458 M/sec   ( +-   3.267% )

        3.479702410  seconds time elapsed   ( +-   8.481% )


real    0m34.823s
user    0m0.820s
sys     2m7.259s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 12 50000

 Performance counter stats for './mmap-merge 12 50000' (10 runs):

          0.920072 task-clock-msecs         #      0.000 CPUs    ( +-   2.413% )
                13 context-switches         #      0.014 M/sec   ( +-   3.553% )
                12 CPU-migrations           #      0.013 M/sec   ( +-   0.000% )
               142 page-faults              #      0.154 M/sec   ( +-   0.126% )
         2,453,089 cycles                   #   2666.192 M/sec   ( +-   2.294% )
         1,213,864 instructions             #      0.495 IPC     ( +-   4.309% )
           229,378 branches                 #    249.304 M/sec   ( +-   3.634% )
             7,582 branch-misses            #      3.306 %       ( +-   1.559% )
            39,421 cache-references         #     42.845 M/sec   ( +-   1.613% )
            13,022 cache-misses             #     14.153 M/sec   ( +-   2.974% )

        2.629273354  seconds time elapsed   ( +-  12.610% )


real    0m26.320s
user    0m0.355s
sys     2m11.851s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 6 50000

 Performance counter stats for './mmap-merge 6 50000' (10 runs):

          0.574440 task-clock-msecs         #      0.000 CPUs    ( +-   2.073% )
                 7 context-switches         #      0.012 M/sec   ( +-   7.105% )
                 6 CPU-migrations           #      0.010 M/sec   ( +-   0.000% )
               124 page-faults              #      0.216 M/sec   ( +-   0.081% )
         1,538,323 cycles                   #   2677.954 M/sec   ( +-   2.011% )
           805,689 instructions             #      0.524 IPC     ( +-   0.777% )
           153,771 branches                 #    267.689 M/sec   ( +-   0.760% )
             5,833 branch-misses            #      3.793 %       ( +-   2.511% )
            24,123 cache-references         #     41.994 M/sec   ( +-   1.714% )
             5,552 cache-misses             #      9.666 M/sec   ( +-   6.832% )

        1.262533725  seconds time elapsed   ( +-  10.411% )


real    0m12.647s
user    0m0.148s
sys     0m52.916s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-merge 3 50000

 Performance counter stats for './mmap-merge 3 50000' (10 runs):

          0.412164 task-clock-msecs         #      0.001 CPUs    ( +-   1.961% )
                 3 context-switches         #      0.007 M/sec   ( +-   0.000% )
                 3 CPU-migrations           #      0.007 M/sec   ( +-   0.000% )
               115 page-faults              #      0.279 M/sec   ( +-   0.203% )
         1,130,757 cycles                   #   2743.460 M/sec   ( +-   1.623% )
           621,400 instructions             #      0.550 IPC     ( +-   0.266% )
           118,812 branches                 #    288.263 M/sec   ( +-   0.259% )
             4,885 branch-misses            #      4.112 %       ( +-   1.501% )
            17,666 cache-references         #     42.861 M/sec   ( +-   0.993% )
             3,588 cache-misses             #      8.706 M/sec   ( +-   5.443% )

        0.487055557  seconds time elapsed   ( +-   9.425% )


real    0m4.896s
user    0m0.080s
sys     0m13.610s



---
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <pthread.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>


unsigned long nr_loops = 1000000; /* 1M */
unsigned long page_size;
void *mmap_base;

void *do_mmap_merge(void *data)
{
	int nr = (unsigned long)data;
	void *page = mmap_base + (2 + nr * 5) * page_size;
	void *addr;
	int ret;
	int i;

	for (i = 0; i < nr_loops; i++) {
		ret = munmap(page, page_size);
		if (ret) {
			perror("thread-munmap");
			exit(-1);
		}
		addr = mmap(page, page_size, PROT_READ | PROT_WRITE, 
				MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
		if (addr == MAP_FAILED) {
			perror("thread-mmap");
			exit(-1);
		}
	}

	return NULL;
}

int main(int argc, char **argv)
{
	int nr_tasks = 12;
	int i;

	if (argc > 1)
		nr_tasks = atoi(argv[1]);
	if (argc > 2)
		nr_loops = atoi(argv[2]);

	page_size = getpagesize();

	mmap_base = mmap(NULL, 5 * nr_tasks * page_size, PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (mmap_base == MAP_FAILED) {
		perror("mmap");
		exit(-1);
	}

	for (i = 0; i < nr_tasks; i++) {
		if (!fork()) {
			do_mmap_merge((void *)i);
			exit(0);
		}
	}

	for (i = 0; i < nr_tasks; i++)
		wait(NULL);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
