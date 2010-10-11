Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6736B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 04:57:03 -0400 (EDT)
Date: Mon, 11 Oct 2010 09:56:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101011085647.GA30667@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <20101008152953.GB3315@csn.ul.ie> <20101009005807.GA28793@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101009005807.GA28793@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 09, 2010 at 08:58:07AM +0800, Shaohua Li wrote:
> On Fri, Oct 08, 2010 at 11:29:53PM +0800, Mel Gorman wrote:
> > On Tue, Sep 28, 2010 at 01:08:01PM +0800, Shaohua Li wrote:
> > > In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> > > according to perf when memory pressure is high. The workload does something
> > > like:
> > > for i in `seq 1 $nr_cpu`
> > > do
> > >         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
> > >         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> > > done
> > > this simply reads a sparse file for each CPU. Apparently the
> > > zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> > > a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
> > 
> > Would it be possible for you to post the oprofile report? I'm in the
> > early stages of trying to reproduce this locally based on your test
> > description. The first machine I tried showed that zone_nr_page_state
> > was consuming 0.26% of profile time with the vast bulk occupied by
> > do_mpage_readahead. See as follows
> > 
> > 1599339  53.3463  vmlinux-2.6.36-rc7-pcpudrift do_mpage_readpage
> > 131713    4.3933  vmlinux-2.6.36-rc7-pcpudrift __isolate_lru_page
> > 103958    3.4675  vmlinux-2.6.36-rc7-pcpudrift free_pcppages_bulk
> > 85024     2.8360  vmlinux-2.6.36-rc7-pcpudrift __rmqueue
> > 78697     2.6250  vmlinux-2.6.36-rc7-pcpudrift native_flush_tlb_others
> > 75678     2.5243  vmlinux-2.6.36-rc7-pcpudrift unlock_page
> > 68741     2.2929  vmlinux-2.6.36-rc7-pcpudrift get_page_from_freelist
> > 56043     1.8693  vmlinux-2.6.36-rc7-pcpudrift __alloc_pages_nodemask
> > 55863     1.8633  vmlinux-2.6.36-rc7-pcpudrift ____pagevec_lru_add
> > 46044     1.5358  vmlinux-2.6.36-rc7-pcpudrift radix_tree_delete
> > 44543     1.4857  vmlinux-2.6.36-rc7-pcpudrift shrink_page_list
> > 33636     1.1219  vmlinux-2.6.36-rc7-pcpudrift zone_watermark_ok
> > .....
> > 7855      0.2620  vmlinux-2.6.36-rc7-pcpudrift zone_nr_free_pages
> > 
> > The machine I am testing on is non-NUMA 4-core single socket and totally
> > different characteristics but I want to be sure I'm going more or less the
> > right direction with the reproduction case before trying to find a larger
> > machine.
> Here it is. this is a 4 socket nahalem machine.
>            268160.00 57.2% _raw_spin_lock                      /lib/modules/2.6.36-rc5-shli+/build/vmlinux
>             40302.00  8.6% zone_nr_free_pages                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
>             36827.00  7.9% do_mpage_readpage                   /lib/modules/2.6.36-rc5-shli+/build/vmlinux
>             28011.00  6.0% _raw_spin_lock_irq                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
>             22973.00  4.9% flush_tlb_others_ipi                /lib/modules/2.6.36-rc5-shli+/build/vmlinux
>             10713.00  2.3% smp_invalidate_interrupt            /lib/modules/2.6.36-rc5-shli+/build/vmlinux

Ok, we are seeing *very* different things. Can you tell me more about
what usemem actually does? I thought it might be doing something like
mapping the file and just reading it but that doesn't appear to be the
case. I also tried using madvise dropping pages to strictly limit how
much memory was used but the profiles are still different.

I've posted the very basic test script I was using based on your
description. Can you tell me what usemem does differently or better again,
post the source of usemem? Can you also post your .config please. I'm curious
to see why you are seeing so much more locking overhead. If you have lock
debugging and lock stat enabled, would it be possible to test without them
enabled to see what the profile looks like?

Thanks

==== CUT HERE ====
#!/bin/bash
# Benchmark is just a basic memory pressure. Based on a test suggested by
# Shaohua Li in a bug report complaining about the overhead of measuring
# NR_FREE_PAGES under memory pressure
#
# Copyright Mel Gorman 2010
NUM_CPU=$(grep -c '^processor' /proc/cpuinfo)
MEMTOTAL_BYTES=`free -b | grep Mem: | awk '{print $2}'`
DURATION=300
SELF=$0

if [ "$1" != "" ]; then
	DURATION=$1
fi

function create_sparse_file() {
	TITLE=$1
	SIZE=$2

	echo Creating sparse file $TITLE
	dd if=/dev/zero of=$TITLE bs=4096 count=0 seek=$((SIZE/4096+1))
}

echo -n > memorypressure-sparsefile-$$.pids
if [ "$SHELLPACK_TEMP" != "" ]; then
	cd $SHELLPACK_TEMP || die Failed to cd to temporary directory
fi

# Extract and build usemem program
LINECOUNT=`wc -l $SELF | awk '{print $1}'`
CSTART=`grep -n "BEGIN C FILE" $SELF | tail -1 | awk -F : '{print $1}'`
tail -$(($LINECOUNT-$CSTART)) $SELF > usemem.c
gcc -m64 -O2 usemem.c -o usemem || exit -1

for i in `seq 1 $NUM_CPU`
do
        create_sparse_file sparse-$i $((10 * MEMTOTAL_BYTES / NUM_CPU))
        ./usemem sparse-$i $DURATION $((10 * MEMTOTAL_BYTES / NUM_CPU)) &
	echo $! >> memorypressure-sparsefile-$$.pids
done

# Wait for memory pressure programs to exit
EXITCODE=0
echo Waiting on helper programs to exit
for PID in `cat memorypressure-sparsefile-$$.pids`; do
	wait $PID
	if [ $? -ne 0 ]; then
		EXITCODE=$?
	fi
done

rm memorypressure-sparsefile-$$.pids
rm sparse-*
exit $EXITCODE

==== BEGIN C FILE ====
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

void usage(void)
{
	fprintf(stderr, "usemem filename duration nr_bytes\n");
	exit(EXIT_FAILURE);
}

static int do_test(char *filename, unsigned long duration, unsigned long nr_bytes)
{
	unsigned long pagesize = getpagesize();
	int references = nr_bytes / pagesize;
	int fd;
	int read_index, discard_index;
	time_t endtime;
	void **fifo;
	char *file;
	int dummy;

	fifo = calloc(references, sizeof(void *));
	if (fifo == NULL) {
		fprintf(stderr, "Failed to malloc pointers\n");
		exit(EXIT_FAILURE);
	}

	fd = open(filename, O_RDONLY);
	if (fd == -1) {
		perror("open");
		exit(EXIT_FAILURE);
	}

	file = mmap(NULL, nr_bytes, PROT_READ, MAP_SHARED, fd, 0);
	if (file == MAP_FAILED) {
		perror("mmap");
		exit(EXIT_FAILURE);
	}

	endtime = time(NULL) + duration;
	read_index = 0;
	discard_index = 1;
	do {
		dummy += file[read_index * pagesize];
		/* WRITE TEST file[read_index * pagesize]++; */
		read_index = (read_index + 13) % references;
		discard_index = (discard_index + 13) % references;

		/* Could use this to strictly limit memory usage
		fifo[read_index] = &(file[read_index * pagesize]);
		if (fifo[discard_index]) {
			madvise(file + (discard_index * pagesize), pagesize, MADV_DONTNEED);
		}
		*/
	} while (time(NULL) < endtime);

	/* Prevents gcc optimising */
	return dummy == -1 ? EXIT_SUCCESS : EXIT_FAILURE;
}

int main(int argc, char **argv)
{
	char *filename;
	unsigned long duration, nr_bytes;

	if (argc != 4)
		usage();
	filename = argv[1];
	duration = strtoul(argv[2], NULL, 0);
	nr_bytes = strtoul(argv[3], NULL, 0);
	setbuf(stdout, NULL);
	setbuf(stderr, NULL);

	return do_test(filename, duration, nr_bytes);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
