From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Date: Fri, 4 May 2007 22:10:15 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <463AE1EB.1020909@yahoo.com.au> <20070504085201.GA24666@elte.hu>
In-Reply-To: <20070504085201.GA24666@elte.hu>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_nKyOGHgbcePlRY6"
Message-Id: <200705042210.15953.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_nKyOGHgbcePlRY6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 04 May 2007 18:52, Ingo Molnar wrote:
> agreed. Con, IIRC you wrote a testcase for this, right? Could you please
> send us the results of that testing?

Yes, sorry it's a crappy test app but works on 32bit. Timed with prefetch 
disabled and then enabled swap prefetch saves ~5 seconds on average hardware 
on this one test case. I had many users try this and the results were between 
2 and 10 seconds, but always showed a saving on this testcase. This effect 
easily occurs on printing a big picture, editing a large file, compressing an 
iso image or whatever in real world workloads. Smaller, but much more 
frequent effects of this over the course of a day obviously also occur and do 
add up.

-- 
-ck

--Boundary-00=_nKyOGHgbcePlRY6
Content-Type: text/x-csrc;
  charset="iso-8859-1";
  name="swap_prefetch_tester.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="swap_prefetch_tester.c"

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

size_t get_ram(void)
{
        unsigned long ramsize;
	FILE *meminfo;
        char aux[256];

	if(!(meminfo = fopen("/proc/meminfo", "r")))
		fatal("fopen\n");

	while( !feof(meminfo) && !fscanf(meminfo, "MemTotal: %lu kB", &ramsize) )
		fgets(aux,sizeof(aux),meminfo);
	if (fclose(meminfo) == -1)
		fatal("fclose");
	return ramsize * 1000;
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
	size_t size, full_size = get_ram();
	int sleep_seconds = 600;

	size = full_size * 7 / 10;
	printf("Starting first malloc of %d bytes\n", size);
	buf1 = malloc(size);
	if (buf1 == (char *)-1)
		fatal("Failed to malloc 1st buffer\n");
	memset(buf1, 0, size);
	printf("Completed first malloc and starting second malloc of %d bytes\n", full_size);

	buf2 = malloc(full_size);
	if (buf2 == (char *)-1)
		fatal("Failed to malloc 2nd buffer\n");
	memset(buf2, 0, full_size);
	buf4 = malloc(1);
	for (buf3 = buf2 + full_size; buf3 > buf2; buf3--)
		*buf4 = *buf3;
	free(buf2);
	printf("Completed second malloc and free\n");

	printf("Sleeping for %d seconds\n", sleep_seconds);
	sleep(sleep_seconds);

	printf("Important part - starting read of first malloc\n");
	time_diff = current_time = get_usecs(&myts);
	for (buf3 = buf1; buf3 < buf1 + size; buf3++)
		*buf4 = *buf3;
	current_time = get_usecs(&myts);
	free(buf4);
	free(buf1);
	printf("Completed read and freeing of first malloc\n");
	time_diff = current_time - time_diff;
	printf("Timed portion %lu microseconds\n",time_diff);

	return 0;
}

--Boundary-00=_nKyOGHgbcePlRY6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
