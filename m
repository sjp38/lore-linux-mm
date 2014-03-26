Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEBE6B0036
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:11:23 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so2192400wiw.6
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 12:11:22 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id a8si2137232wiy.5.2014.03.26.12.11.21
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 12:11:22 -0700 (PDT)
Date: Wed, 26 Mar 2014 20:11:13 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Postgresql performance problems with IO latency, especially during
 fsync()
Message-ID: <20140326191113.GF9066@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@alap3.anarazel.de
Cc: andres@2ndquadrant.com


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

At LSF/MM there was a slot about postgres' problems with the kernel. Our
top#1 concern is frequent slow read()s that happen while another process
calls fsync(), even though we'd be perfectly fine if that fsync() took
ages.
The "conclusion" of that part was that it'd be very useful to have a
demonstration of the problem without needing a full blown postgres
setup. I've quickly hacked something together, that seems to show the
problem nicely.

For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
and the "IO Scheduling" bit in
http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de

The tools output looks like this:
gcc -std=c99 -Wall -ggdb ~/tmp/ioperf.c -o ioperf && ./ioperf
...
wal[12155]: avg: 0.0 msec; max: 0.0 msec
commit[12155]: avg: 0.2 msec; max: 15.4 msec
wal[12155]: avg: 0.0 msec; max: 0.0 msec
read[12157]: avg: 0.2 msec; max: 9.4 msec
...
read[12165]: avg: 0.2 msec; max: 9.4 msec
wal[12155]: avg: 0.0 msec; max: 0.0 msec
starting fsync() of files
finished fsync() of files
read[12162]: avg: 0.6 msec; max: 2765.5 msec

So, the average read time is less than one ms (SSD, and about 50% cached
workload). But once another backend does the fsync(), read latency
skyrockets.

A concurrent iostat shows the problem pretty clearly:
Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s	avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               1.00     0.00 6322.00  337.00    51.73     4.38	17.26     2.09    0.32    0.19    2.59   0.14  90.00
sda               0.00     0.00 6016.00  303.00    47.18     3.95	16.57     2.30    0.36    0.23    3.12   0.15  94.40
sda               0.00     0.00 6236.00 1059.00    49.52    12.88	17.52     5.91    0.64    0.20    3.23   0.12  88.40
sda               0.00     0.00  105.00 26173.00     0.89   311.39	24.34   142.37    5.42   27.73    5.33   0.04 100.00
sda               0.00     0.00   78.00 27199.00     0.87   324.06	24.40   142.30    5.25   11.08    5.23   0.04 100.00
sda               0.00     0.00   10.00 33488.00     0.11   399.05	24.40   136.41    4.07  100.40    4.04   0.03 100.00
sda               0.00     0.00 3819.00 10096.00    31.14   120.47	22.31    42.80    3.10    0.32    4.15   0.07  96.00
sda               0.00     0.00 6482.00  346.00    52.98     4.53	17.25     1.93    0.28    0.20    1.80   0.14  93.20

While the fsync() is going on (or the kernel decides to start writing
out aggressively for some other reason) the amount of writes to the disk
is increased by two orders of magnitude. Unsurprisingly with disastrous
consequences for read() performance. We really want a way to pace the
writes issued to the disk more regularly.

The attached program right now can only be configured by changing some
details in the code itself, but I guess that's not a problem. It will
upfront allocate two files, and then start testing. If the files already
exists it will use them.

Possible solutions:
* Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
  sync_file_range() does.
* Make IO triggered by writeback regard IO priorities and add it to
  schedulers other than CFQ
* Add a tunable that allows limiting the amount of dirty memory before
  writeback on a per process basis.
* ...?

If somebody familiar with buffered IO writeback is around at LSF/MM, or
rather collab, Robert and I will be around for the next days.

Greetings,

Andres Freund

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ioperf.c"

/*
 * Portions Copyright (c) 2014, PostgreSQL Global Development Group
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without a written agreement
 * is hereby granted, provided that the above copyright notice and this
 * paragraph appear in all copies.
 *
 * Test program roughly simulating postgres' IO.
 *
 * Parameters will need need to be changed to reproduce the problem on
 * individual systems.
 *
 * Author: Andres Freund, andres@2ndquadrant.com, andres@anarazel.de
 */
#define _POSIX_C_SOURCE 200809L
#define _XOPEN_SOURCE 800

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <time.h>

/* CHANGE: number of reading processes */
#define NUM_RANDOM_READERS 16

/*
 * CHANGE: set to memory size * 2 or so.
 *
 * Remove the 'data', 'wal' files after changing.
 */
static const size_t data_size = 1024L * 1024 * 1024 * 48;

/* probably ok this way */
static const size_t wal_size = 1024L * 1024 * 1024 * 1;

/* after how many iterations should stuff get reported */
static const uint64_t read_report_interval = 10000;
static const uint64_t wal_report_interval = 1000;
static const uint64_t commit_report_interval = 500;


/* internal data */
static const char initdata[8192];
static pid_t readers[NUM_RANDOM_READERS];

struct timing
{
	uint64_t iter;
	uint64_t period_total;
	uint64_t total;
	uint64_t period_max;

	struct timespec t_before;
	struct timespec t_after;
};

static void
fatal_error(int e)
{
	fprintf(stderr, "frak me: %d: %s\n", e, strerror(e));
	_exit(0);
}

static void
nsleep(int64_t s)
{
	struct timespec d;
	d.tv_sec = 0;
	d.tv_nsec = s;
	if (nanosleep(&d, NULL) < 0)
		fatal_error(errno);
}

static off_t
random_block(size_t end)
{
	return (((double) random())/RAND_MAX) * (end - 1);
}

static int64_t
nsec_diff(const struct timespec *a, const struct timespec *b)
{
	return ((int64_t)(a->tv_sec - b->tv_sec) * 1000000000)
		+ (a->tv_nsec - b->tv_nsec);
}

static void
timing_init(struct timing *t)
{
	t->iter = 0;
	t->total = 0;
	t->period_total = 0;
	t->period_max = 0;
}

static void
timing_before_action(struct timing *t)
{
	clock_gettime(CLOCK_MONOTONIC, &t->t_before);
}


static void
timing_after_action(struct timing *t, const char *ctx, int64_t report_interval)
{
	uint64_t dur;

	clock_gettime(CLOCK_MONOTONIC, &t->t_after);

	dur = nsec_diff(&t->t_after, &t->t_before);

	t->iter++;
	t->period_total += dur;
	t->period_max = t->period_max < dur ? dur : t->period_max;

	if ((t->iter % report_interval) == 0)
	{
		fprintf(stdout, "%s[%d]: avg: %.1f msec; max: %.1f msec\n",
				ctx, getpid(),
				(double) (t->period_total / read_report_interval) / 1000000,
				(double) t->period_max / 1000000);
		t->total += t->period_total;
		t->period_total = 0;
		t->period_max = 0;
	}
}

static void
do_wal_writes(void)
{
	int fd;
	off_t pos = 0;
	int64_t iter = 0;

	struct timing wal_timing;
	struct timing commit_timing;

	timing_init(&wal_timing);
	timing_init(&commit_timing);

	fd = open("wal", O_RDWR, S_IRUSR|S_IWUSR);
	if (fd < 0)
		fatal_error(errno);

	while(true)
	{
		bool is_commit = (iter++ % 5) == 0;

		if (lseek(fd, pos, SEEK_SET) < 0)
			fatal_error(errno);

		timing_before_action(&wal_timing);
		if (is_commit)
			timing_before_action(&commit_timing);

		if (write(fd, initdata, 8192) < 0)
			fatal_error(errno);

		timing_after_action(&wal_timing, "wal", wal_report_interval);

		if (is_commit)
		{

			if (fdatasync(fd) < 0)
				fatal_error(errno);
			timing_after_action(&commit_timing, "commit", commit_report_interval);
		}

		pos += 8192;

		if (pos + 8192 >= wal_size)
			pos = 0;

		nsleep(1000000);
	}
}

static void
do_checkpointer_writes(void)
{
	int fd;
	int64_t writes = 0;

	fd = open("data", O_RDWR, S_IRUSR|S_IWUSR);
	if (fd < 0)
		fatal_error(errno);

	while(true)
	{
		off_t pos = random_block(data_size);

		if (lseek(fd, pos, SEEK_SET) < 0)
			fatal_error(errno);

		if (write(fd, initdata, 8192) < 0)
			fatal_error(errno);

		if ((++writes % 100000) == 0)
		{
			fprintf(stdout, "starting fsync() of files\n");

			if (fsync(fd) < 0)
				fatal_error(errno);

			fprintf(stdout, "finished fsync() of files\n");
		}

		nsleep(200000);
	}
}

static void
do_random_reads(void)
{
	int fd;
	struct timing timing;

	timing_init(&timing);

	fd = open("data", O_RDWR, S_IRUSR|S_IWUSR);
	if (fd < 0)
		fatal_error(errno);

	while(true)
	{
		char data[8192];
		off_t pos = random_block(data_size);

		if (lseek(fd, pos, SEEK_SET) < 0)
			fatal_error(errno);

		timing_before_action(&timing);

		if (read(fd, data, 8192) < 0)
			fatal_error(errno);

		timing_after_action(&timing, "read", read_report_interval);
	}
}

static void
initialize_files(void)
{
	int fd;
	ssize_t data_size_written = 0;
	ssize_t wal_size_written = 0;

	/* initialize data file */
	fd = open("data", O_CREAT|O_EXCL|O_RDWR, S_IRUSR|S_IWUSR);
	if (fd < 0 && errno == EEXIST)
		;
	else if (fd < 0)
		fatal_error(errno);
	else
	{
		while (data_size_written <= data_size)
		{
			ssize_t ret = write(fd, initdata, sizeof(initdata));
			if (ret == -1)
				fatal_error(errno);
			data_size_written += ret;
		}
		if (fsync(fd) < 0)
			fatal_error(errno);
		close(fd);
	}

	/* initialize wal file */
	fd = open("wal", O_CREAT|O_EXCL|O_RDWR, S_IRUSR|S_IWUSR);
	if (fd < 0 && errno == EEXIST)
		;
	else if (fd < 0)
		fatal_error(errno);
	else
	{
		while (wal_size_written <= wal_size)
		{
			ssize_t ret = write(fd, initdata, sizeof(initdata));
			if (ret == -1)
				fatal_error(errno);
			wal_size_written += ret;
		}
		fsync(fd);
		close(fd);
	}
}

static pid_t
start_subprocess(void (*sub)(void))
{
	pid_t pid;

	pid = fork();
	if (pid == -1)
		fatal_error(errno);
	else if (pid == 0)
		sub();

	return pid;
}

int
main(int argc, char **argv)
{
	int status;
	pid_t checkpointer_pid, wal_pid;

	/*
	 * Don't want to hit the same, already cached, pages after restarting.
	 */
	srandom((int)time(NULL));

	initialize_files();

	checkpointer_pid = start_subprocess(do_checkpointer_writes);
	wal_pid = start_subprocess(do_wal_writes);

	/* start all reader processes */
	for (int i = 0; i < NUM_RANDOM_READERS; i++)
		readers[i] = start_subprocess(do_random_reads);

	/* return if all subprocesses decided to die */
	for (int i = 0; i < NUM_RANDOM_READERS; i++)
		waitpid(readers[i], &status, 0);

	waitpid(checkpointer_pid, &status, 0);
	waitpid(wal_pid, &status, 0);

	return 0;
}

--J/dobhs11T7y2rNN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
