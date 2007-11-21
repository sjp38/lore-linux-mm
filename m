Date: Wed, 21 Nov 2007 22:20:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-ID: <20071121222059.GC31674@csn.ul.ie>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com> <20071115162706.4b9b9e2a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071115162706.4b9b9e2a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 11:52:47 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Well.  The whole per-cpu-pages thing was a very marginal benefit - I
> wibbled for months before merging it.  So the effects of simplifying the
> lists will be hard to measure.
> 

You were not joking.

> The test which per-cpu-pages helped most was one which sits in a loop
> extending and truncating a file by 32k - per-cpu-pages sped that up by a
> lot (3x, iirc) because with per-cpu-pages it's always getting the same
> pages on each CPU and they're cache-hot.

> <goes archeological for a bit>
> 
> OK, it's create-delete.c from ext3-tools, duplicated below.  It would be
> nice if someone(tm) could check that this patch doesn't hurt this test.
> 

It took me a while but I finally got around to taking a closer look at
this after I got the zonelist stuff out again.

> I'd suggest running one instance per cpu with various values of "size".

Good idea so I followed your suggestion. The end results could do with as
many set of eyes double-checking what I did. Andy Whitcroft took a read
for me in advance of this posting and did not spot any obvious insanity.
While I am reasonably confident the results are accurate and I measured the
right thing, the more the merrier.  The very short summary of what I found was;

1. In general, the split lists are faster than the combined list
2. Disabling Per-CPU has comparable performance to having the lists

Point 2 was certainly not expected!

This is a more detailed account of what I did so people can tear holes in the
methodology if they wish or rerun the tests. The aim was to show if per-CPU
allocator really helped scalability or not in the file extend/truncate
case. We know there would be contention on other semaphores so it was not
going to be a linear improvement. Ideally though, if one CPU took 800ms to
work on data, four CPUs would take 200ms.

My initial objectives for the test were

1. Run multiple instances
2. Instances would be bound to CPUs to avoid scheduler jitter
3. The same amount of file data would be generated regardless of CPU count

The ideal results would show

1. Linear improvements for number of CPUs
2. No difference between single PCPU lists and hot/cold lists
3. Clear improvement over no PCPU list

The test machine was elm3b6 from test.kernel.org. This is a 4-CPU x86_64 NUMA
machine with 8GiB of memory. The base kernel version was 2.6.24-rc2-mm1 with
some hotfixes applied. FWIW, I spent the time to write test harnesses around
this necessary to quickly automate new tests for future patches or machine
types. This should make it easier for me to re-run tests quickly although
the script below is all people really need to replicate the results. The
test on this particular machine did the following.

1. Create a range of filesizes from 16K to 8MB
2. Run multiple times with instances ranging from 1 to 12 CPUs
3. Fork off the number of requested instances
4. Each child runs one worker function to completion and exits
5. Parent waits for all the children to complete and exits
6. One file is created per instance
7. The sum total of the files created is the same regardless of instances
   - For example, if using a 16K file, using 1 instance will be 1 16K file.
     Running 4 instances would create 4 4K files and operate on them
     independently

Results
=======

The raw data, gnuplot scripts etc are available from
http://www.csn.ul.ie/~mel/postings/percpu-20071121/alldata.tar.gz

The titles of patches are

hotcold-pcplist: This is the vanilla PCPU allocator
single-pcplist-batch8: This is Christophs patch with pcp->high == 8*batch
	as suggested by Martin Bligh (I agreed with him that keeping lists
	the same size made sense)
no-pcplist: buffered_rmqueue() always calls the core allocator

1-4CPU Scaling: http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-1_4Scaling-fullrange.ps

First lets look if the standard allocator scales at all in this graph.
You should see that by the end of the test, the scalability is not
bad although not exactly linear. One CPU looks to be taking about
2.4 seconds there and 4 CPUS does the job in 0.9 - probably losing
out on the additional file creations. At the smaller sizes you can see in
http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-1_4Scaling-upto0.5MB.ps,
it is not scaling as well but it is happening.

1-Instance Graph: http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-1instance-fullrange.ps

This shows running on just one CPU the full range of pages. It looks at a
glance to me that single pcplist is slowest with the hotcold lists being
faster. The no-pcplist is faster again as you would expect because it has
less work to do and no scalability concerns.

Up to the 0.5MB mark which is about the size of the PCPU lists
in general, you can see the three kernels are comparable; obvious in
http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-1instance-upto0.5MB.ps.
In the last 2MB shown
http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-1instance-last2MB.ps,
no-PCPU is consistently faster, then hotcold with the combined list being
slower.  are marginally faster most of the time.

4-Instances Graph: http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-4instance-fullrange.ps

At this point, there should be one instance running on each CPU.  The results
are a lot more variable at a glance, but it is still pretty clear what the
trends are. The combined-list is noticably slower. The real shock here is
that there is no real difference between the combined lists and using no
PCPU list at all. For this reason alone, the benchmark script needs to be
looked at by another person. I am still running the tests on another machine
but the results there so far match.

12-Instances Graph: http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-12instance-fullrange.ps 

Now there are 3 instances running per CPU on the system. The combined list
is again slowest but the other two are interesting. This time, the hot/cold
lists have a noticable performance improvement over the no-PCPU kernel in
genreal. However, for the first 0.5MB, the combined list is winning with
the hot/cold lists faring worst. Towards the larger filesizes, the opposite
applies.

Conclusions
===========

Overall, the single list is slower than the split lists although seeing it in a
larger benchmark may be difficult. The biggest suprise by far is that disabling
the PCPU list altogether seemed to have comparable performance. Intuitively,
this makes no sense and means the benchmark code should be read over by a
second person to check for mistakes.

I cannot see the evidence of this 3x improvement around the 32K filesize
mark. It may be because my test is very different to what happened before,
I got something wrong or the per-CPU allocator is not as good as it used to
be and does not give out the same hot-pages all the time. I tried running
tests on 2.6.23 but the results of PCPU vs no-PCPU were comparable to
2.6.24-rc2-mm1 so it is not something that has changed very recently.

As it is, the single PCP list may need another revision or at least
more investigation to see why it slows so much in comparison to the split
lists. The more controversial question is why disabling PCP appeared to make
no difference in this test.

Any comments on the test or what could be done differently?

Notes
=====

o The fact the machine was NUMA might have skewed the results. I bound the CPU,
  but did not set nodemasks. Node-local policies should have been used. I have
  kicked off tests on bl6-13 which has 4 cores but non-NUMA. It'll be a long
  time before they complete though
o The timings are of the whole process and children creation. This means that
  we are measuring more than just the file creation. Most fine-grained timings
  could be collected if it was felt to be relevant
o The no-pcplist patch was crude. The PCPU structures were not actually removed.
  Just the function itself was butchered. The patch is at
  http://www.csn.ul.ie/~mel/postings/percpu-20071121/disable_pcp.patch


Benchmark script
================
#!/bin/bash
#
# This benchmark is based on create/delete test from ext3-tools. The objective
# of this is to check the benefit of the per-cpu allocator. At the time of
# writing, the hot/cold lists are being collapsed into one. This is required
# to see if there is any performance loss from doing that.
#

# Paths for results directory and the like
export SCRIPT=`basename $0 | sed -e 's/\./\\\./'`
export SCRIPTDIR=`echo $0 | sed -e "s/$SCRIPT//"`
CPUCOUNT=`grep -c processor /proc/cpuinfo`
FILENAME=
RESULT_DIR=$HOME/vmregressbench-`uname -r`/createdelete
EXTRA=

# The filesizes are set so that the number of allocations
# coming from each CPU steadily rises. The size of the
# actual stride is based on the number of running instances
LOW_FILESIZE=$((4096*$CPUCOUNT))
HIGH_FILESIZE=$((524288*4*$CPUCOUNT))
STRIDE_FILESIZE_PERCPU=4096

# Print usage of command
usage() {
  echo "bench-createdelete.sh"
  echo This script measures how well the allocator scales for small file
  echo creations and deletions
  echo
  echo "Usage: bench-createdelete.sh [options]"
  echo "    -f, --filename Filename prefix to use for test files"
  echo "    -r, --result   Result directory (default: $RESULT_DIR)"
  echo "    -e, --extra    String to append to result dir"
  echo "    -h, --help     Print this help message"
  echo
  exit 1
}

# Parse command line arguements
ARGS=`getopt -o hf:r:e:v: --long help,filename:,result:,extra:,vmr: -n bench-createdelete.sh -- "$@"`
eval set -- "$ARGS"
while true ; do
	case "$1" in
		-f|--filename)	export FILENAME="$2"; shift 2;;
		-r|--result)	export RESULT_DIR="$2"; shift 2;;
		-e|--extra)	export EXTRA="$2"; shift 2;;
		-h|--help)	usage;;
		*)		shift 1; break;;
	esac
done

# Build the test program that does all the work
SELF=$0
TESTPROGRAM=`mktemp`
LINECOUNT=`wc -l $SELF | awk '{print $1}'`
CSTART=`grep -n "BEGIN C FILE" $SELF | tail -1 | awk -F : '{print $1}'`
tail -$(($LINECOUNT-$CSTART)) $SELF > $TESTPROGRAM.c
gcc $TESTPROGRAM.c -o $TESTPROGRAM || exit 1

# Setup results directory
if [ "$EXTRA" != "" ]; then
  export EXTRA=-$EXTRA
fi
export RESULT_DIR=$RESULT_DIR$EXTRA
if [ -d "$RESULT_DIR" ]; then
	echo ERROR: Results dir $RESULT_DIR already exists
	exit 1
fi
mkdir -p $RESULT_DIR || exit

echo bench-createdelete
echo o Result directory $RESULT_DIR

# Setup the filename prefix to be used by the test program
if [ "$FILENAME" = "" ]; then
	FILENAME=`mktemp`
fi

# Run the actual test
MAXINSTANCES=$(($CPUCOUNT*3))
for NUMCPUS in `seq 1 $MAXINSTANCES`; do
	echo o Running with $NUMCPUS striding $STRIDE_FILESIZE
	STRIDE_FILESIZE=$(($STRIDE_FILESIZE_PERCPU*$NUMCPUS))
	for SIZE in `seq -f "%10.0f" $LOW_FILESIZE $STRIDE_FILESIZE $HIGH_FILESIZE`; do
		/usr/bin/time -f "$SIZE %e" $TESTPROGRAM	\
				-n 50				\
				-s $SIZE			\
				-i$NUMCPUS			\
				$FILENAME 2>> $RESULT_DIR/results.$NUMCPUS || exit 1
		tail -1 $RESULT_DIR/results.$NUMCPUS
	done
done

# Generate a simply gnuplot script for giggles
echo "set xrange [$LOW_FILESIZE:$HIGH_FILESIZE]" > $RESULT_DIR/gnuplot.script
echo -n "plot " 		>> $RESULT_DIR/gnuplot.script
for NUMCPUS in `seq 1 $MAXINSTANCES`; do
	echo -n "'results.$NUMCPUS' with lines" >> $RESULT_DIR/gnuplot.script
	if [ $NUMCPUS -ne $MAXINSTANCES ]; then
		echo -n ", " >> $RESULT_DIR/gnuplot.script
	fi
done
echo >> $RESULT_DIR/gnuplot.script

exit 0

==== BEGIN C FILE ====
/*
 * This is lifted straight from ext3 tools to test the trunaction of a file.
 * On the suggestion of Andrew Morton, this can be used as a micro-benchmark
 * of the Linux per-cpu allocator. Hence, it has been modified to run the
 * requested number of instances. If scaling properly, the completion times
 * should be the same if the number of instances is less than the number of
 * CPUs.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sched.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>

int verbose;
char *progname;

void usage(void)
{
	fprintf(stderr, "Usage: %s [-v] [-nN] [-s size] filename-prefix\n", progname);
	fprintf(stderr, "      -v:         Verbose\n"); 
	fprintf(stderr, "     -nN:         Run N iterations\n"); 
	fprintf(stderr, "     -iN:         Run N instances simultaneously\n");
	fprintf(stderr, "     -s size:     Size of file\n"); 
	exit(1);
}

int numcpus(void)
{
	static int count = -1;
	cpu_set_t mask;

	if (count != -1)
		return count;

	/* Work it out for the first time */
	CPU_ZERO(&mask);
	count = 0;
	if (sched_getaffinity(getpid(), sizeof(mask), &mask) == -1) {
		perror("sched_getaffinity\n");
		exit(1);
	}

	while (CPU_ISSET(count, &mask))
		count++;
	
	return count;
}

/* This is the worker function doing all the work */
int createdelete(char *fileprefix, int size, int niters, int instance)
{
	char *buf, *filename;
	int length = strlen(fileprefix) + 6;
	int fd;
	cpu_set_t mask;

	/* Bind to one CPU */
	CPU_ZERO(&mask);
	CPU_SET(instance % numcpus(), &mask);
	if (sched_setaffinity(getpid(), sizeof(cpu_set_t), &mask) == -1) {
		perror("sched_setaffinity");
		exit(1);
	}

	/* Allocate the necessary buffers */
	filename = malloc(length);
	if (filename == 0) {
		perror("nomem");
		exit(1);
	}
	buf = malloc(size);
	if (buf == 0) {
		perror("nomem");
		exit(1);
	}

	/* Create the file for this instance */
	snprintf(filename, length, "%s-%d\n", fileprefix, instance);
	fd = creat(filename, 0666);
	if (fd < 0) {
		perror("creat");
		exit(1);
	}

	/* Lets get this show on the road */
	while (niters--) {
		if (lseek(fd, 0, SEEK_SET)) {
			perror("lseek");
			exit(1);
		}
		if (write(fd, buf, size) != size) {
			perror("write");
			exit(1);
		}
		if (ftruncate(fd, 0)) {
			perror("ftruncate");
			exit(1);
		}
	}

	exit(0);
}

int main(int argc, char *argv[])
{
	int c;
	int i;
	int ninstances = 1;
	int niters = -1;
	int size = 16 * 4096;
	char *filename;

	progname = argv[0];
	while ((c = getopt(argc, argv, "vn:s:i:")) != -1) {
		switch (c) {
		case 'n':
			niters = strtol(optarg, NULL, 10);
			break;
		case 's':
			size = strtol(optarg, NULL, 10);
			break;
		case 'i':
			ninstances = strtol(optarg, NULL, 10);
			break;
		case 'v':
			verbose++;
			break;
		}
	}

	if (optind == argc)
		usage();
	filename = argv[optind++];
	if (optind != argc)
		usage();

	/* fork off the number of required instances doing work */
	for (i = 0; i < ninstances; i++) {
		pid_t pid = fork();
		if (pid == -1) {
			perror("fork");
			exit(1);
		}

		if (pid == 0)
			createdelete(filename, size / ninstances, niters, i);
	}

	/* Wait for the children */
	for (i = 0; i < ninstances; i++) {
		pid_t pid = wait(NULL);
		if (pid == -1) {
			perror("wait");
			exit(1);
		}
	}

	exit(0);
}

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
