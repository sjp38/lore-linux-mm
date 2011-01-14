Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1311A6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 01:47:25 -0500 (EST)
Date: Thu, 13 Jan 2011 22:44:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmap/munmap 20ms latencies, 2.6.37
Message-Id: <20110113224437.00119c2f.akpm@linux-foundation.org>
In-Reply-To: <20110111081928.GL18828@hexapodia.org>
References: <20110111081928.GL18828@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andy Isaacson <adi@hexapodia.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(cc linux-mm)

On Tue, 11 Jan 2011 00:19:28 -0800 Andy Isaacson <adi@hexapodia.org> wrote:

> I'm seeing high latencies (up to 20 ms with no sign of CPU contention)
> from mmap/munmap, using the enclosed test program on various Core i7
> processors.  For example on a "Intel(R) Core(TM) i7 CPU 930@2.80GHz"
> with 12GB RAM running 0c21e3a,
> 
> % /tmp/munmapslow -t 6
> ...
> [1294732507.539851] <8636> free(0x7f2608f08000) len=57344 took 4041 us
> [1294732507.559841] <8632> free(0x7f260e810000) len=32768 took 8032 us
> [1294732507.570254] <8632> malloc(81920) took 2452 us
> [1294732507.583834] <8635> malloc(73728) took 8035 us
> [1294732507.595840] <8631> malloc(65536) took 4048 us
> [1294732507.599838] <8635> malloc(45056) took 8041 us
> [1294732507.603834] <8631> malloc(20480) took 4029 us
> ...
> [1294732510.603845] <8634> realloc(0x756170, 23408) took 4035 us
> [1294732510.647850] <8634> malloc(73728) took 28047 us
> [1294732510.675831] <8631> malloc(53248) took 28028 us
> [1294732510.731835] <8631> malloc(81920) took 28035 us
> ...
> [1294732543.685480] <8633> 5244182 heap events, 3739 allocated, 4425 max, 153.57 MiB total
> [1294732543.685503] <8633> 78060.59 ms total for 5244182 allocations (15 us per allocation)
> [1294732543.685509] <8633> 13779.82 ms total for 5240443 frees (3 us per free)
> 
> Most of the time, mmap takes about 15 us and munmap takes less than 5 us
> for these small buffers (<20 pages).
> 
> Of course if a significant background job fires, a lot of "slow
> operations" are seen; but I'm seeing cases where preemption doesn't
> appear to be the cause.  (I suppose I could parse /proc/self/sched to
> confirm this...)
> 
> I'll try trace-cmd tomorrow, but I wonder if anyone already knows what's
> going on?
> 
> (As you may guess, this is an attempt to isolate a problem seen in a
> larger system that's not easy to reduce to a simple testcase.  We're
> seeing a 3x higher system time reported via munin than previously, even
> though the CPUs went from 20%-40% idle to 100% pegged and overall
> throughput *dropped* somewhat due to being CPU limited.  It's not clear
> what changed to trigger the increased system time -- but munmap popped
> out of strace -c.)
> 
> Thanks,
> -andy
> 
> /*
>  * Attempt to reproduce munmap slowness seen on
>  * 2.6.35-23-generic
>  * Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz
>  * with HT turned on.
>  *
>  * strace -c shows that munmap is taking up to 11 ms per call and
>  * that's where we are spending 95% of our time.
>  *
>  * Plan for testcase:
>  *
>  * fork N processes.
>  * In each process, repeatedly allocate and free various buffer sizes.
>  */
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <stdarg.h>
> #include <string.h>
> #include <errno.h>
> 
> #include <sys/time.h>
> 
> #include <unistd.h>
> #include <sys/wait.h>
> #include <sys/mman.h>
> 
> #define MAX_TIME (1000 * 1e-6)
> 
> typedef unsigned int u32;
> 
> static int pgsz;
> 
> double rtc(void)
> {
>     struct timeval t;
> 
>     gettimeofday(&t, 0);
>     return t.tv_sec + t.tv_usec/1e6;
> }
> 
> void die(char *fmt, ...) __attribute__((noreturn));
> 
> void die(char *fmt, ...)
> {
>     va_list ap;
> 
>     fprintf(stderr, "[%.6f] <%d> ", rtc(), (int)getpid());
>     va_start(ap, fmt);
>     vfprintf(stderr, fmt, ap);
>     va_end(ap);
>     exit(1);
> }
> 
> void msg(char *fmt, ...)
> {
>     va_list ap;
> 
>     printf("[%.6f] <%d> ", rtc(), (int)getpid());
>     va_start(ap, fmt);
>     vfprintf(stdout, fmt, ap);
>     va_end(ap);
> }
> 
> /*
>  * returns a random integer chosen from a uniform distribution on [0, range).
>  */
> u32 myrand(u32 range)
> {
>     u32 x, mask;
>     int i, MAX = 1000;
> 
>     if (range == 1) return 0;
> 
>     mask = range - 1;
>     while (mask & (mask - 1))
> 	mask &= (mask - 1);
>     mask |= (mask - 1);
> 
>     for (i = 0; i < MAX; i++) {
> 	x = lrand48() & mask;
> 	if (x < range)
> 	    return x;
>     }
>     die("myrand failed after %d iter, range = %lld mask = 0x%llx x = 0x%llx\n",
> 	    i, (long long)range, (long long) mask, (long long)x);
> }
> 
> static void **heap;
> static int num_heap, max_num_heap;
> static long long totsz;
> 
> static double elapsed_alloc, elapsed_free;
> int num_alloc, num_free;
> 
> void heap_stats(void)
> {
>     msg("%d heap events, %d allocated, %d max, %.2f MiB total\n",
> 	    num_alloc, num_heap, max_num_heap, totsz / 1024. / 1024);
>     msg("%.2f ms total for %d allocations (%.0f us per allocation)\n",
> 	    elapsed_alloc * 1e3, num_alloc, elapsed_alloc * 1e6 / num_alloc);
>     msg("%.2f ms total for %d frees (%.0f us per free)\n",
> 	    elapsed_free * 1e3, num_free, elapsed_free * 1e6 / num_alloc);
> }
> 
> void *myalloc(size_t sz)
> {
>     double t0, t1, e;
>     void *p;
> 
>     t0 = rtc();
>     p = mmap(0, sz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
>     if (p == MAP_FAILED)
> 	die("mmap(%d): %s\n", (int)sz, strerror(errno));
>     t1 = rtc();
> 
>     e = t1 - t0;
> 
>     if (e > MAX_TIME)
> 	msg("malloc(%d) took %.0f us\n", (int)sz, e * 1e6);
> 
>     elapsed_alloc += e;
>     num_alloc++;
> 
>     return p;
> }
> 
> void myfree(void *p)
> {
>     double t0, t1, e;
>     int sz = *(int *)p;
> 
>     t0 = rtc();
>     munmap(p, sz);
>     t1 = rtc();
> 
>     e = t1 - t0;
>     if (e > MAX_TIME)
> 	msg("free(%p) len=%d took %.0f us\n", p, sz, e * 1e6);
>     elapsed_free += e;
>     num_free++;
> }
> 
> void heap_allocate(int sz)
> {
>     void *n;
>     void **h2;
>     double t1, t2, e;
> 
>     n = myalloc(sz);
>     if (!n) die("malloc(%d) failed.\n", sz);
> 
>     *(int *)n = sz;
> 
>     t1 = rtc();
>     h2 = realloc(heap, sizeof(*heap) * ++num_heap);
>     t2 = rtc();
>     e = t2 - t1;
>     if (!h2)
> 	die("realloc(%p, %d) failed.\n",
> 	       	heap, (int)(sizeof(*heap) * num_heap));
> 
>     if ((t2 - t1) > MAX_TIME)
> 	msg("realloc(%p, %d) took %.0f us\n",
> 	       	heap, (int)(sizeof(*heap) * num_heap), e * 1e6);
> 
>     if (num_heap > max_num_heap) max_num_heap = num_heap;
>     totsz += sz;
> 
>     h2[num_heap-1] = n;
>     heap = h2;
> }
> 
> void heap_free(void)
> {
>     int i;
> 
>     if (num_heap <= 0)
> 	return;
> 
>     i = myrand(num_heap--);
> 
>     totsz -= *(int *)heap[i];
> 
>     if (heap[i])
> 	myfree(heap[i]);
> 
>     for (; i < num_heap; i++)
> 	heap[i] = heap[i+1];
> }
> 
> void send_message(void)
> {
> }
> 
> void receive_message(void)
> {
> }
> 
> void worker(void)
> {
>     long long i;
>     long long counts[4] = { 0 };
>     int ITERCOUNT = 10 * 1024 * 1024;
> 
>     for (i=0; ; i++) {
> 	int action = myrand(4);
> 
> 	if (i < 10000 && action == 1 && myrand(2) == 1) action = 0;
> 	counts[action]++;
> 	switch(action) {
> 	case 0:
> 	    heap_allocate(pgsz * (myrand(20) + 1));
> 	    break;
> 	case 1:
> 	    heap_free();
> 	    break;
> 	case 2:
> 	    send_message();
> 	    break;
> 	case 3:
> 	    receive_message();
> 	    break;
> 	}
> 	if (i % ITERCOUNT == ITERCOUNT - 1) {
> 	    heap_stats();
> 	}
>     }
> }
> 
> void usage(const char *cmd)
> {
>     die("Usage: %s [-t numthreads]\n", cmd);
> }
> 
> int main(int argc, char **argv)
> {
>     int c, i;
>     int nproc = sysconf(_SC_NPROCESSORS_ONLN);
> 
>     pgsz = getpagesize();
> 
>     while ((c = getopt(argc, argv, "t:")) != EOF) {
> 	switch (c) {
> 	case 't':
> 	    nproc = strtol(optarg, 0, 0);
> 	    break;
> 	default:
> 	    usage(argv[0]);
> 	}
>     }
> 
>     printf("forking %d children\n", nproc);
>     for (i=0; i < nproc; i++) {
> 	switch(fork()) {
> 	case -1:
> 	    die("fork: %s\n", strerror(errno));
> 	case 0: /* child */
> 	    worker();
> 	    exit(0);
> 	default: /* parent */
> 	    /* nothing */
> 	    break;
> 	}
>     }
> 
>     for (i=0; i < nproc; i++) {
> 	int x, p;
> 
> 	p = wait(&x);
> 	msg("child %d exited\n", p);
>     }
> 
>     return 0;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
