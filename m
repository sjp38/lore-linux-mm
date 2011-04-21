Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB398D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:26:00 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QCttP-0003ta-3P
	for linux-mm@kvack.org; Thu, 21 Apr 2011 13:25:59 +0000
Subject: Re: [PATCH 15/20] mm: Convert i_mmap_lock to a mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130725.38cb638b.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121726.037173835@chello.nl>
	 <20110419130725.38cb638b.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 15:28:23 +0200
Message-ID: <1303392503.2035.136.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Tue, 2011-04-19 at 13:07 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:13 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Straight fwd conversion of i_mmap_lock to a mutex
> 
> What effect does this have on kernel performance?
> 
> Workloads which take the lock at high frequency from multiple threads
> should be tested.

The worst affected workload would be a lightly contended lock, uncontended
mutexes are similarly fast as uncontended spinlocks, highly contended mutexes
win hands down since we waste vastly less resources spinning, leaving
lightly contended.

The below shows a workload tailored to isolate this one lock and is tested with
various numbers of contending tasks ran on a dual socket westmere EP (2*6*2),
the first results are from an unpatched -tip kernel, the second set is with
the patches applied:


	48		24		12		6		3

real    0m33.973s	0m17.816s	0m8.762s	0m3.778s	0m1.307s
sys     13m20.203s	7m5.814s	1m44.440s	0m22.371s	0m3.751s

real    0m23.551s	0m12.265s	0m7.016s	0m3.644s	0m1.412s
sys     1m17.177s	0m41.875s	0m26.139s	0m13.872s	0m3.873s

It looks like we might have a slight loss at 3 tasks contending although I'd
have to run with larger sets in order to increase the confidence interval as
the current numbers are within each others error range.

Also, this conversion is needed to allow the anon_vma->lock conversion, which
shows an improvement over the whole range.

---

[root@westmere ~]# echo 0 > /proc/sys/kernel/nmi_watchdog 
[root@westmere ~]# for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ; do echo performance > $i; done
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 48 50000

 Performance counter stats for './mmap-file 48 50000' (10 runs):

          3.045659 task-clock-msecs         #      0.001 CPUs    ( +-   0.481% )
                48 context-switches         #      0.016 M/sec   ( +-   0.566% )
                69 CPU-migrations           #      0.023 M/sec   ( +-   1.456% )
               250 page-faults              #      0.082 M/sec   ( +-   0.040% )
         7,985,758 cycles                   #   2622.013 M/sec   ( +-   0.413% )
         3,335,330 instructions             #      0.418 IPC     ( +-   0.198% )
           614,795 branches                 #    201.859 M/sec   ( +-   0.175% )
            20,177 branch-misses            #      3.282 %       ( +-   1.299% )
           123,596 cache-references         #     40.581 M/sec   ( +-   0.693% )
            57,380 cache-misses             #     18.840 M/sec   ( +-   2.148% )

        3.380886384  seconds time elapsed   ( +-   0.159% )


real    0m33.973s
user    0m1.463s
sys     13m20.203s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 24 50000

 Performance counter stats for './mmap-file 24 50000' (10 runs):

          1.511615 task-clock-msecs         #      0.001 CPUs    ( +-   1.049% )
                16 context-switches         #      0.011 M/sec   ( +-   3.040% )
                23 CPU-migrations           #      0.015 M/sec   ( +-   0.437% )
               178 page-faults              #      0.118 M/sec   ( +-   0.120% )
         4,003,891 cycles                   #   2648.750 M/sec   ( +-   0.988% )
         1,767,231 instructions             #      0.441 IPC     ( +-   0.678% )
           328,415 branches                 #    217.261 M/sec   ( +-   0.707% )
             9,281 branch-misses            #      2.826 %       ( +-   1.045% )
            56,897 cache-references         #     37.640 M/sec   ( +-   0.966% )
            26,209 cache-misses             #     17.339 M/sec   ( +-   2.700% )

        1.779547040  seconds time elapsed   ( +-   0.116% )


real    0m17.816s
user    0m0.704s
sys     7m5.814s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 12 50000

 Performance counter stats for './mmap-file 12 50000' (10 runs):

          0.833400 task-clock-msecs         #      0.001 CPUs    ( +-   2.223% )
                 8 context-switches         #      0.010 M/sec   ( +-   4.047% )
                12 CPU-migrations           #      0.014 M/sec   ( +-   0.000% )
               142 page-faults              #      0.170 M/sec   ( +-   0.105% )
         2,218,792 cycles                   #   2662.338 M/sec   ( +-   2.025% )
         1,091,917 instructions             #      0.492 IPC     ( +-   0.558% )
           205,310 branches                 #    246.352 M/sec   ( +-   0.516% )
             6,030 branch-misses            #      2.937 %       ( +-   1.436% )
            32,260 cache-references         #     38.710 M/sec   ( +-   0.747% )
            12,526 cache-misses             #     15.030 M/sec   ( +-   2.783% )

        0.874054257  seconds time elapsed   ( +-   0.122% )


real    0m8.762s
user    0m0.283s
sys     1m44.440s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 6 50000

 Performance counter stats for './mmap-file 6 50000' (10 runs):

          0.525969 task-clock-msecs         #      0.001 CPUs    ( +-   1.705% )
                 3 context-switches         #      0.006 M/sec   ( +-  11.994% )
                 6 CPU-migrations           #      0.011 M/sec   ( +-   0.000% )
               124 page-faults              #      0.236 M/sec   ( +-   0.000% )
         1,413,250 cycles                   #   2686.948 M/sec   ( +-   1.138% )
           757,501 instructions             #      0.536 IPC     ( +-   0.565% )
           144,120 branches                 #    274.009 M/sec   ( +-   0.560% )
             5,098 branch-misses            #      3.538 %       ( +-   2.054% )
            22,782 cache-references         #     43.315 M/sec   ( +-   1.068% )
             6,159 cache-misses             #     11.709 M/sec   ( +-   5.052% )

        0.375598224  seconds time elapsed   ( +-   0.560% )


real    0m3.778s
user    0m0.100s
sys     0m22.371s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 3 50000

 Performance counter stats for './mmap-file 3 50000' (10 runs):

          0.426419 task-clock-msecs         #      0.003 CPUs    ( +-   2.223% )
                 3 context-switches         #      0.007 M/sec   ( +-   3.448% )
                 3 CPU-migrations           #      0.007 M/sec   ( +-   0.000% )
               115 page-faults              #      0.270 M/sec   ( +-   0.132% )
         1,134,258 cycles                   #   2659.963 M/sec   ( +-   1.587% )
           610,569 instructions             #      0.538 IPC     ( +-   0.289% )
           117,666 branches                 #    275.940 M/sec   ( +-   0.320% )
             4,318 branch-misses            #      3.670 %       ( +-   3.292% )
            17,922 cache-references         #     42.029 M/sec   ( +-   0.819% )
             3,905 cache-misses             #      9.157 M/sec   ( +-   7.969% )

        0.127845444  seconds time elapsed   ( +-   1.226% )


real    0m1.307s
user    0m0.158s
sys     0m3.751s



---

[root@westmere ~]# echo 0 > /proc/sys/kernel/nmi_watchdog 
[root@westmere ~]# for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ; do echo performance > $i; done
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 48 50000

 Performance counter stats for './mmap-file 48 50000' (10 runs):

          2.910655 task-clock-msecs         #      0.001 CPUs    ( +-   0.580% )
                48 context-switches         #      0.016 M/sec   ( +-   0.279% )
                52 CPU-migrations           #      0.018 M/sec   ( +-   1.225% )
               250 page-faults              #      0.086 M/sec   ( +-   0.053% )
         7,538,292 cycles                   #   2589.895 M/sec   ( +-   0.725% )
         3,285,984 instructions             #      0.436 IPC     ( +-   0.248% )
           608,888 branches                 #    209.193 M/sec   ( +-   0.256% )
            17,153 branch-misses            #      2.817 %       ( +-   0.944% )
           128,392 cache-references         #     44.111 M/sec   ( +-   0.816% )
            57,160 cache-misses             #     19.638 M/sec   ( +-   2.574% )

        2.352105837  seconds time elapsed   ( +-   0.729% )


real    0m23.551s
user    0m1.451s
sys     1m17.177s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 24 50000

 Performance counter stats for './mmap-file 24 50000' (10 runs):

          1.600378 task-clock-msecs         #      0.001 CPUs    ( +-   1.531% )
                24 context-switches         #      0.015 M/sec   ( +-   0.745% )
                25 CPU-migrations           #      0.015 M/sec   ( +-   0.806% )
               178 page-faults              #      0.111 M/sec   ( +-   0.118% )
         4,112,616 cycles                   #   2569.778 M/sec   ( +-   1.250% )
         1,839,878 instructions             #      0.447 IPC     ( +-   0.307% )
           343,196 branches                 #    214.447 M/sec   ( +-   0.361% )
            10,876 branch-misses            #      3.169 %       ( +-   1.514% )
            68,812 cache-references         #     42.998 M/sec   ( +-   1.175% )
            26,286 cache-misses             #     16.425 M/sec   ( +-   2.509% )

        1.224012964  seconds time elapsed   ( +-   1.200% )


real    0m12.265s
user    0m0.685s
sys     0m41.875s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 12 50000

 Performance counter stats for './mmap-file 12 50000' (10 runs):

          0.833480 task-clock-msecs         #      0.001 CPUs    ( +-   1.324% )
                12 context-switches         #      0.014 M/sec   ( +-   0.000% )
                12 CPU-migrations           #      0.014 M/sec   ( +-   0.000% )
               142 page-faults              #      0.170 M/sec   ( +-   0.126% )
         2,180,779 cycles                   #   2616.476 M/sec   ( +-   1.408% )
         1,127,027 instructions             #      0.517 IPC     ( +-   0.354% )
           211,726 branches                 #    254.026 M/sec   ( +-   0.327% )
             6,628 branch-misses            #      3.131 %       ( +-   1.522% )
            36,986 cache-references         #     44.376 M/sec   ( +-   1.459% )
            12,337 cache-misses             #     14.802 M/sec   ( +-   3.203% )

        0.699308658  seconds time elapsed   ( +-   0.931% )


real    0m7.016s
user    0m0.323s
sys     0m26.139s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 6 50000

 Performance counter stats for './mmap-file 6 50000' (10 runs):

          0.551046 task-clock-msecs         #      0.002 CPUs    ( +-   2.031% )
                 6 context-switches         #      0.011 M/sec   ( +-   3.042% )
                 6 CPU-migrations           #      0.011 M/sec   ( +-   0.000% )
               124 page-faults              #      0.226 M/sec   ( +-   0.123% )
         1,482,359 cycles                   #   2690.081 M/sec   ( +-   1.767% )
           793,407 instructions             #      0.535 IPC     ( +-   0.387% )
           150,806 branches                 #    273.673 M/sec   ( +-   0.416% )
             5,649 branch-misses            #      3.746 %       ( +-   2.961% )
            24,554 cache-references         #     44.559 M/sec   ( +-   1.985% )
             5,632 cache-misses             #     10.220 M/sec   ( +-   4.339% )

        0.362139074  seconds time elapsed   ( +-   1.599% )


real    0m3.644s
user    0m0.153s
sys     0m13.872s
[root@westmere ~]# time perf stat --repeat 10 ./mmap-file 3 50000

 Performance counter stats for './mmap-file 3 50000' (10 runs):

          0.419324 task-clock-msecs         #      0.003 CPUs    ( +-   2.667% )
                 3 context-switches         #      0.007 M/sec   ( +-   0.000% )
                 3 CPU-migrations           #      0.007 M/sec   ( +-   0.000% )
               116 page-faults              #      0.276 M/sec   ( +-   0.264% )
         1,147,068 cycles                   #   2735.515 M/sec   ( +-   2.253% )
           623,614 instructions             #      0.544 IPC     ( +-   0.228% )
           119,060 branches                 #    283.933 M/sec   ( +-   0.207% )
             4,679 branch-misses            #      3.930 %       ( +-   2.200% )
            17,917 cache-references         #     42.729 M/sec   ( +-   1.021% )
             3,779 cache-misses             #      9.013 M/sec   ( +-   3.425% )

        0.138764629  seconds time elapsed   ( +-   0.903% )


real    0m1.412s
user    0m0.065s
sys     0m3.873s


---
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <pthread.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>


unsigned long nr_loops = 1000000; /* 1M */
unsigned long page_size;
int file;

void *do_mmap_merge(void *data)
{
	int nr = (unsigned long)data;
	void *addr;
	int ret;
	int i;

	for (i = 0; i < nr_loops; i++) {
		addr = mmap(NULL, page_size, PROT_READ | PROT_WRITE, 
				MAP_SHARED, file, 0);
		if (addr == MAP_FAILED) {
			perror("thread-mmap");
			exit(-1);
		}
		ret = munmap(addr, page_size);
		if (ret) {
			perror("thread-munmap");
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

	file = open("/tmp/mmap-file-test", O_RDWR | O_CREAT);

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
