From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Date: Sat, 5 May 2007 18:42:31 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070504085201.GA24666@elte.hu> <200705042210.15953.kernel@kolivas.org>
In-Reply-To: <200705042210.15953.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4NEPGuQWzoRUlD2"
Message-Id: <200705051842.32328.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_4NEPGuQWzoRUlD2
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 04 May 2007 22:10, Con Kolivas wrote:
> On Friday 04 May 2007 18:52, Ingo Molnar wrote:
> > agreed. Con, IIRC you wrote a testcase for this, right? Could you please
> > send us the results of that testing?
>
> Yes, sorry it's a crappy test app but works on 32bit. Timed with prefetch
> disabled and then enabled swap prefetch saves ~5 seconds on average
> hardware on this one test case. I had many users try this and the results
> were between 2 and 10 seconds, but always showed a saving on this testcase.
> This effect easily occurs on printing a big picture, editing a large file,
> compressing an iso image or whatever in real world workloads. Smaller, but
> much more frequent effects of this over the course of a day obviously also
> occur and do add up.

Here's a better swap prefetch tester. Instructions in file.

Machine with 2GB ram and 2GB swapfile

Prefetch disabled:
./sp_tester
Ram 2060352000  Swap 1973420000
Total ram to be malloced: 3047062000 bytes
Starting first malloc of 1523531000 bytes
Starting 1st read of first malloc
Touching this much ram takes 809 milliseconds
Starting second malloc of 1523531000 bytes
Completed second malloc and free
Sleeping for 600 seconds
Important part - starting reread of first malloc
Completed read of first malloc
Timed portion 53397 milliseconds

Enabled:
./sp_tester
Ram 2060352000  Swap 1973420000
Total ram to be malloced: 3047062000 bytes
Starting first malloc of 1523531000 bytes
Starting 1st read of first malloc
Touching this much ram takes 676 milliseconds
Starting second malloc of 1523531000 bytes
Completed second malloc and free
Sleeping for 600 seconds
Important part - starting reread of first malloc
Completed read of first malloc
Timed portion 26351 milliseconds

Note huge time difference.

-- 
-ck

--Boundary-00=_4NEPGuQWzoRUlD2
Content-Type: text/x-csrc;
  charset="utf-8";
  name="sp_tester.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="sp_tester.c"

/*
sp_tester.c

Build with:
gcc -o sp_tester sp_tester.c -lrt -W -Wall -O2

How to use:
echo 1 > /proc/sys/vm/overcommit_memory
swapoff -a
swapon -a
./sp_tester

then repeat with changed conditions eg
echo 0 > /proc/sys/vm/swap_prefetch

Each Test takes 10 minutes
*/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <time.h>

void fatal(const char *format, ...)
{
	va_list ap;

	if (format) {
		va_start(ap, format);
		vfprintf(stderr, format, ap);
		va_end(ap);
	}

	fprintf(stderr, "Fatal error - exiting\n");
	exit(1);
}

unsigned long ramsize, swapsize;

size_t get_ram(void)
{
	FILE *meminfo;
        char aux[256];

	if(!(meminfo = fopen("/proc/meminfo", "r")))
		fatal("fopen\n");

	while( !feof(meminfo) && !fscanf(meminfo, "MemTotal: %lu kB", &ramsize) )
		fgets(aux,sizeof(aux),meminfo);
	while( !feof(meminfo) && !fscanf(meminfo, "SwapTotal: %lu kB", &swapsize) )
		fgets(aux,sizeof(aux),meminfo);
	if (fclose(meminfo) == -1)
		fatal("fclose");
	ramsize *= 1000;
	swapsize *= 1000;
	printf("Ram %lu  Swap %lu\n", ramsize, swapsize);
	return ramsize + (swapsize / 2);
}

unsigned long get_usecs(struct timespec *myts)
{
	if (clock_gettime(CLOCK_REALTIME, myts))
		fatal("clock_gettime");
	return (myts->tv_sec * 1000000 + myts->tv_nsec / 1000 );
}

int main(void)
{
	unsigned long current_time, time_diff;
	struct timespec myts;
	char *buf1, *buf2, *buf3, *buf4;
	size_t size = get_ram();
	int sleep_seconds = 600;

	if (size > ramsize / 2 * 3)
		size = ramsize / 2 * 3;
	printf("Total ram to be malloced: %u bytes\n", size);
	size /= 2;
	printf("Starting first malloc of %u bytes\n", size);
	buf1 = malloc(size);
	buf4 = malloc(1);
	if (buf1 == (char *)-1)
		fatal("Failed to malloc 1st buffer\n");
	memset(buf1, 0, size);
	time_diff = current_time = get_usecs(&myts);
	for (buf3 = buf1; buf3 < buf1 + size; buf3++)
		*buf4 = *buf3;
	printf("Starting 1st read of first malloc\n");
	current_time = get_usecs(&myts);
	time_diff = current_time - time_diff;
	printf("Touching this much ram takes %lu milliseconds\n",time_diff / 1000);
	printf("Starting second malloc of %u bytes\n", size);

	buf2 = malloc(size);
	if (buf2 == (char *)-1)
		fatal("Failed to malloc 2nd buffer\n");
	memset(buf2, 0, size);
	for (buf3 = buf2 + size; buf3 > buf2; buf3--)
		*buf4 = *buf3;
	free(buf2);
	printf("Completed second malloc and free\n");

	printf("Sleeping for %u seconds\n", sleep_seconds);
	sleep(sleep_seconds);

	printf("Important part - starting reread of first malloc\n");
	time_diff = current_time = get_usecs(&myts);
	for (buf3 = buf1; buf3 < buf1 + size; buf3++)
		*buf4 = *buf3;
	current_time = get_usecs(&myts);
	time_diff = current_time - time_diff;
	printf("Completed read of first malloc\n");
	printf("Timed portion %lu milliseconds\n",time_diff / 1000);

	free(buf1);
	free(buf4);

	return 0;
}

--Boundary-00=_4NEPGuQWzoRUlD2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
