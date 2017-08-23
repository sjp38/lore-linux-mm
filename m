Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 515F46B050E
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:38:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b189so113838wmd.13
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 06:38:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10si1335760wrc.108.2017.08.23.06.38.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 06:38:49 -0700 (PDT)
Date: Wed, 23 Aug 2017 15:38:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196729] New: System becomes unresponsive when swapping -
 Regression since 4.10.x
Message-ID: <20170823133848.GA2652@dhcp22.suse.cz>
References: <bug-196729-27@https.bugzilla.kernel.org/>
 <20170822155530.928b377fa636bbea28e1d4df@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Content-Disposition: inline
In-Reply-To: <20170822155530.928b377fa636bbea28e1d4df@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netwiz@crc.id.au
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 22-08-17 15:55:30, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 22 Aug 2017 11:17:08 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
[...]
> Sadly I haven't been able to capture this information 
> > fully yet due to said unresponsiveness.

Please try to collect /proc/vmstat in the bacground and provide the
collected data. Something like

while true
do
	cp /proc/vmstat > vmstat.$(date +%s)
	sleep 1s
done

If the system turns out so busy that it won't be able to fork a process
or write the output (which you will see by checking timestamps of files
and looking for holes) then you can try the attached proggy
./read_vmstat output_file timeout output_size

Note you might need to increase the mlock rlimit to lock everything into
memory.

-- 
Michal Hocko
SUSE Labs

--huq684BweRXVnRxX
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

--huq684BweRXVnRxX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
