Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7095F6B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:35:05 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so7857528wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:35:05 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id gd1si33779723wjb.154.2016.02.29.12.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:35:04 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id p65so730923wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:35:04 -0800 (PST)
Date: Mon, 29 Feb 2016 21:35:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160229203502.GW16930@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
[...]
> Boot with mem=1G (or boot your usual way, and do something to occupy
> most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> way to gobble up most of the memory, though it's not how I've done it).
> 
> Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> kernel source tree into a tmpfs: size=2G is more than enough.
> make defconfig there, then make -j20.
> 
> On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> 
> Except that you'll probably need to fiddle around with that j20,
> it's true for my laptop but not for my workstation.  j20 just happens
> to be what I've had there for years, that I now see breaking down
> (I can lower to j6 to proceed, perhaps could go a bit higher,
> but it still doesn't exercise swap very much).

I have tried to reproduce and failed in a virtual on my laptop. I
will try with another host with more CPUs (because my laptop has only
two). Just for the record I did: boot 1G machine in kvm, I have 2G swap
and reserve 800M for hugetlb pages (I got 445 of them). Then I extract
the kernel source to tmpfs (-o size=2G), make defconfig and make -j20
(16, 10 no difference really). I was also collecting vmstat in the
background. The compilation takes ages but the behavior seems consistent
and stable.

If I try 900M for huge pages then I get OOMs but this happens with the
mmotm without my oom rework patch set as well.

It would be great if you could retry and collect /proc/vmstat data
around the OOM time to see what compaction did? (I was using the
attached little program to reduce interference during OOM (no forks, the
code locked in and the resulting file preallocated - e.g.
read_vmstat 1s vmstat.log 10M and interrupt it by ctrl+c after the OOM
hits).

Thanks!
-- 
Michal Hocko
SUSE Labs

--rwEMma7ioTxnRzrJ
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="read_vmstat.c"

#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <time.h>

/*
 * A simple /proc/vmstat collector into a file. It tries hard to guarantee
 * that the content will get into the output file even under a strong memory
 * pressure.
 *
 * Usage
 * ./read_vmstat output_file timeout output_size
 *
 * output_file can be either a non-existing file or - for stdout
 * timeout - time period between two snapshots. s - seconds, ms - miliseconds
 * 	     and m - minutes suffix is allowed
 * output_file - size of the output file. The file is preallocated and pre-filled.
 *
 * If the output reaches the end of the file it will start over overwriting the oldest
 * data. Each snapshot is enclosed by header and footer.
 * =S timestamp
 * [...]
 * E=
 *
 * Please note that your ulimit has to be sufficient to allow to mlock the code+
 * all the buffers.
 *
 * This comes under GPL v2
 * Copyright: Michal Hocko <mhocko@suse.cz> 2015 
 */

#define NS_PER_MS (1000*1000)
#define NS_PER_SEC (1000*NS_PER_MS)

int open_file(const char *str)
{
	int fd;

	fd = open(str, O_CREAT|O_EXCL|O_RDWR, 0755);
	if (fd == -1) {
		perror("open input");
		return 1;
	}

	return fd;
}

int read_timeout(const char *str, struct timespec *timeout)
{
	char *end;
	unsigned long val;

	val = strtoul(str, &end, 10);
	if (val == ULONG_MAX) {
		perror("Invalid number");
		return 1;
	}
	switch(*end) {
		case 's':
			timeout->tv_sec = val;
			break;
		case 'm':
			/* ms vs minute*/
			if (*(end+1) == 's') {
				timeout->tv_sec = (val * NS_PER_MS) / NS_PER_SEC;
				timeout->tv_nsec = (val * NS_PER_MS) % NS_PER_SEC;
			} else {
				timeout->tv_sec = val*60;
			}
			break;
		default:
			fprintf(stderr, "Uknown number %s\n", str);
			return 1;
	}

	return 0;
}

size_t read_size(const char *str)
{
	char *end;
	size_t val = strtoul(str, &end, 10);

	switch (*end) {
		case 'K':
			val <<= 10;
			break;
		case 'M':
			val <<= 20;
			break;
		case 'G':
			val <<= 30;
			break;
	}

	return val;
}

size_t dump_str(char *buffer, size_t buffer_size, size_t pos, const char *in, size_t size)
{
	size_t i;
	for (i = 0; i < size; i++) {
		buffer[pos] = in[i];
		pos = (pos + 1) % buffer_size;
	}

	return pos;
}

/* buffer == NULL -> stdout */
int __collect_logs(const struct timespec *timeout, char *buffer, size_t buffer_size)
{
	char buff[4096]; /* dump to the file automatically */
	time_t before, after;
	int in_fd = open("/proc/vmstat", O_RDONLY);
	size_t out_pos = 0;
	size_t in_pos = 0;
	size_t size = 0;
	int estimate = 0;

	if (in_fd == -1) {
		perror("open vmstat:");
		return 1;
	}

	/* lock everything in */
	if (mlockall(MCL_CURRENT) == -1) {
		perror("mlockall. Continuing anyway");
	}

	while (1) {
		before = time(NULL);

		size = snprintf(buff, sizeof(buff), "=S %lu\n", before);
		lseek(in_fd, 0, SEEK_SET);
		size += read(in_fd, buff + size, sizeof(buff) - size);
		size += snprintf(buff + size, sizeof(buff) - size, "E=\n");
		if (buffer && !estimate) {
			printf("Estimated %d entries fit to the buffer\n", buffer_size/size);
			estimate = 1;
		}

		/* Dump to stdout */
		if (!buffer) {
			printf("%s", buff);
		} else {
			size_t pos;
			pos = dump_str(buffer, buffer_size, out_pos, buff, size);
			if (pos < out_pos)
				fprintf(stderr, "%lu: Buffer wrapped\n", before);
			out_pos = pos;
		}

		after = time(NULL);

		if (after - before > 2) {
			fprintf(stderr, "%d: Snapshoting took %d!!!\n", before, after-before);
		}
		if (nanosleep(timeout, NULL) == -1)
			if (errno == EINTR)
				return 0;
		/* kick in the flushing */
		if (buffer)
			msync(buffer, buffer_size, MS_ASYNC);
	}
}

int collect_logs(int fd, const struct timespec *timeout, size_t buffer_size)
{
	unsigned char *buffer = NULL;

	if (fd != -1) {
		if (ftruncate(fd, buffer_size) == -1) {
			perror("ftruncate");
			return 1;
		}

		if (fallocate(fd, 0, 0, buffer_size) && errno != EOPNOTSUPP) {
			perror("fallocate");
			return 1;
		}

		/* commit it to the disk */
		sync();

		buffer = mmap(NULL, buffer_size, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_POPULATE, fd, 0);
		if (buffer == MAP_FAILED) {
			perror("mmap");
			return 1;
		}
	}

	return __collect_logs(timeout, buffer, buffer_size);
}

int main(int argc, char **argv)
{
	struct timespec timeout = {.tv_sec = 1};
	int fd = -1;
	size_t buffer_size = 10UL<<20;

	if (argc > 1) {
		/* output file */
		if (strcmp(argv[1], "-")) {
			fd = open_file(argv[1]);
			if (fd == -1)
				return 1;
		}

		/* timeout */
		if (argc > 2) {
			if (read_timeout(argv[2], &timeout))
				return 1;

			/* buffer size */
			if (argc > 3) {
				buffer_size = read_size(argv[3]);
				if (buffer_size == -1UL)
					return 1;
			}
		}
	}
	printf("file:%s timeout:%lu.%lus buffer_size:%llu\n",
			(fd == -1)? "stdout" : argv[1],
			timeout.tv_sec, timeout.tv_nsec / NS_PER_MS,
			buffer_size);

	return collect_logs(fd, &timeout, buffer_size);
}

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
