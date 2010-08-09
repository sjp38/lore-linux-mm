Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6DA9E6B02A4
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 09:30:04 -0400 (EDT)
Date: Mon, 9 Aug 2010 09:30:00 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100809133000.GB6981@wil.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This testcase shows some odd behaviour from the Linux VM.

It creates a 1TB sparse file, mmaps it, and randomly reads locations 
in it.  Due to the file being entirely sparse, the VM allocates new pages
and zeroes them.  Initially, it runs very fast, taking on the order of
2.7 to 4us per page fault.  Eventually, the VM runs out of free pages,
and starts doing huge amounts of work trying to figure out which of
these clean pages to throw away.  In my testing with a 6GB machine 
and 2.9GHz CPU, one in every 15,000 page faults takes over a second, 
and one in every 40,000 page faults take over seven seconds!

This test-case demonstrates a problem that occurs with a read-mostly 
mmap of a file on very fast media.  I wouldn't like to see a solution
that special-cases zeroed pages.  I think userspace has done its part
to tell the kernel what's it's doing by calling madvise(MADV_RANDOM).
This ought to be enough to hint to the kernel that it should be eagerly
throwing away pages in this VMA.


/*
 * Copyright (c) 2010, Intel Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  * Neither the name of Intel Corporation nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#define rdtscll(val) do { \
     unsigned int __a,__d; \
     asm volatile("rdtsc" : "=a" (__a), "=d" (__d)); \
     (val) = ((unsigned long)__a) | (((unsigned long)__d)<<32); \
} while(0)


#define MAX_FILE_SIZE	((off_t)1024 * 1024 * 1024 * 1024)
#define	MAX_FILE_IOS	16384
#define	MAX_LATENCY	10000000		// usecs

#define NUM_IOS		1024
#define IO_SIZE		4096
#define BUFFER_SIZE	(1024 * 1024)

pthread_t tid;
double 	cpu_clock;
long long unsigned cpu_start, cpu_stop;

void *mmap_test(void *arg);
void die ();

static const char usage_cmds[] =
"usage: %s [options]\n"
"cmd line options:\n"
"    -f	file_name	Read from File named 'file_name'\n"
"    -a	file_size	File of 'file_size' Bytes/thread\n"
"    -b	buffer_size	Write/Read into/from buffer of 'buffer_size' Bytes/thread\n"
"    -n	num_file_ios	Process 'num_file_ios' IOs\n"
"    -s	io_size		IO Size = 'io_size' Bytes\n"
"    -l max_latency     Show latency stats based on usecs of max_latency\n"
;

void usage(const char *program)
{
	fprintf(stderr, usage_cmds, program);
}

off_t file_size = MAX_FILE_SIZE;	// -a
long long unsigned int buffer_size = BUFFER_SIZE;	// -b
char *filename = "sparse-file";			// -f
int	num_file_ios = NUM_IOS;		// -n
int	max_latency = MAX_LATENCY;	// -l
int	io_size = IO_SIZE;		// -s
long long unsigned int   latency_limit;

int main(int argc, char **argv)
{
	pthread_attr_t 	attr;
	cpu_set_t             mask;
	FILE *proc;
	char buf[256];
	double mhz = 0.0;

	while (1) {
	    int option = getopt(argc, argv, "a:b:f:h:l:n:p:s:");
		if (option == -1) {
		    break;
		}
	    switch (option) {
		case 'a':
		    file_size = strtoul(optarg, NULL, 0);
		    printf("a: file_size:%ld Bytes :%ld MB\n", file_size, file_size/(1024*1024));
		    break;
		case 'b':
		    buffer_size = strtoul(optarg, NULL, 0);
		    printf("b: buffer_size:%lld Bytes\n", buffer_size);
		    break;
		case 'f':
	    	    filename = optarg;
		    printf("f: filename:%s\n", filename);
		    break;
		case 'h':
		    printf("h: options\n");
		    goto help;
		case 'l':
		    max_latency = strtoul(optarg, NULL, 0);
		    printf("l: latency stats based on max latency:%d\n", max_latency);
		    break;
		case 'n':
		    num_file_ios = strtoul(optarg, NULL, 0);
		    printf("n: num_file_ios:%d\n", num_file_ios);
		    if (num_file_ios > MAX_FILE_IOS) {
			printf("-n %d Entered > MAX_FILE_IOS:%d\n", num_file_ios, MAX_FILE_IOS);
			exit(1);
		    }
		    break;
		case 's':
		    io_size = strtoul(optarg, NULL, 0);
		    printf("s: io_size:%d Bytes\n", io_size);
		    break;
		default:
		help:
		    usage(argv[0]);
		    printf("default:\n");
		    exit(1);
	    }
	}

	proc = fopen("/proc/cpuinfo", "r");
	if (!proc)
		return 0.0;

	while (fgets(buf, sizeof buf, proc)) {
		double cpu;

		if (sscanf(buf, "cpu MHz : %lf", &cpu) != 1)
			continue;
		if (mhz == 0.0) {
			mhz = cpu;
			continue;
		}
		if (mhz != cpu) {
			fprintf(stderr,
				"Conflicting CPU frequency values: %lf != %lf\n",
				mhz, cpu);
			return 0.0;
		}
	}
	fclose(proc);
	printf("CPU Clock Freq from /proc/cpuinfo:%.4f\n", mhz);
//
// Measure CPU Core Frequnecy over 5 second period
//
	printf("Measuring CPU Frequency......:");
	rdtscll(cpu_start);
	usleep(5000000);
	rdtscll(cpu_stop);
	cpu_clock = (double)((double)(cpu_stop-cpu_start))/(double)5.0;
	printf("%.3f\n", cpu_clock);
	latency_limit = (long long unsigned int) (cpu_clock*max_latency/1000000);
	printf("latency_limit:%llu cycles or %d usecs\n", latency_limit, max_latency);

	pthread_attr_init (&attr);
	pthread_attr_setscope (&attr, PTHREAD_SCOPE_SYSTEM);
	pthread_attr_setstacksize (&attr, (size_t) (1024*1024));

	if (pthread_create(&tid, &attr, mmap_test, (void *)(long) 0) != 0) {
		die("Thread create failed!");
	}

	CPU_ZERO(&mask);
	CPU_SET(0, &mask);
	if (pthread_setaffinity_np(tid, sizeof(mask), &mask) ) {
	 	printf("WARNING: could not set CPU Affinity, exit...\n");
	 	exit(1);
	}

        pthread_join(tid, NULL);
        sleep(1);

	return 0;
}


void die(char *string)
{
	fprintf(stderr, "\nmmap_test: %s\n", string);
	exit(1);
}

void *mmapfile(char *fname, off_t size, int *filed)
{
	int fd;
	void *file_addr;
	struct stat statbuf;

	fd = open(fname, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
	*filed = fd;
	if (fd < 0) {
    		fprintf(stderr, "unable to open %s to get an FD:%s\n", fname, strerror(errno));
		exit(1);
	}

	fstat(fd, &statbuf);
	if (statbuf.st_size < size)
		ftruncate(fd, size);

	file_addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (file_addr == MAP_FAILED) {
    		fprintf(stderr, "datafile mmap failed: %s\n", strerror(errno));
		exit(1);
	}

	madvise(file_addr, size, MADV_RANDOM);
	return file_addr;
}

void create_offsets(off_t *offset_buf, int threadnum)
{
	int i, curr_time;

	curr_time = time(NULL);
        srandom(curr_time / (threadnum + 1));

	for (i = 0; i < num_file_ios; i++) {
		double random1 = ((double)(rand()%(RAND_MAX)) / RAND_MAX);
		offset_buf[i] = file_size * random1;
		offset_buf[i] = offset_buf[i] / io_size * io_size;
	}
}

void *mmap_test(void *arg)
{
	int threadnum = (long) arg;
	int fd;
	char *file_ptr, *file_addr;
	char *buf_ptr, *buf_addr = NULL;
	int i, j, ios;
	off_t offset_buf[MAX_FILE_IOS];
	unsigned long long latency_start, latency_stop;

	posix_memalign((void *)&buf_addr, 4096, buffer_size);

	file_addr = mmapfile(filename, file_size, &fd);

	ios = buffer_size/io_size;

	create_offsets(offset_buf, threadnum);

	for (j = 0; j < num_file_ios; j++) {
		buf_ptr = buf_addr;
		file_ptr = file_addr + offset_buf[j];
 
		for (i = 0; i < ios; i++) {
			rdtscll(latency_start);
			*buf_ptr = *(char *)file_ptr;
			rdtscll(latency_stop);
			printf("%lld\n", latency_stop - latency_start);
			buf_ptr += io_size;
			file_ptr += io_size;
		}
	}

	close(fd);
	munmap(file_addr, file_size);
	free(buf_addr);

	pthread_exit(NULL);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
