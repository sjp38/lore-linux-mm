Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC1D6B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 08:46:37 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id f198so30573366wme.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:46:37 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 131si19110662wmm.66.2016.04.05.05.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 05:46:36 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n3so3974025wmn.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:46:35 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:46:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/11] mm: consider compaction feedback also for costly
 allocation
Message-ID: <20160405124634.GB24035@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-12-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Content-Disposition: inline
In-Reply-To: <1459855533-4600-12-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached you can find both the tool to fragment memory and the script it
calls in my testing.

I was executing this as follows (on 2G machine with 2G swap space):
echo 1 > /proc/sys/vm/overcommit_memory
echo 1 > /proc/sys/vm/compact_memory
/root/fragment-mem-and-run /root/alloc_hugepages.sh 1920M 250M
-- 
Michal Hocko
SUSE Labs

--PEIAKu/WMn1b1Hv9
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="fragment-mem-and-run.c"

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

/*
 * Tries to fragment memory and then executes the given program.
 * Usage:
 * 	fragment-mem-and-run program_to_run mem_to_allocate mem_to_free
 *
 * First tries to allocate mem_to_allocate[KMG] amount of memory which,
 * then tries to free mem_to_free[KMG] in a way to maximize the fragmentation
 * of the page allocator. It is advisable to run compaction before starting
 * to get reproducible behavior.
 *
 * Copyright Michal Hocko 2016
 */
#define PAGE_SIZE 4096UL
#define MAX_ORDER 11
#define ALIGN(x, a) (((x) + (a) - 1) & ~((a) - 1))
#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)

size_t parse_size(const char *value)
{
	char *endptr;
	size_t size = strtoul(value, &endptr, 10);

	if (*endptr == 'K')
		size *= 1024;
	else if (*endptr == 'M')
		size *= 1024*1024;
	else if (*endptr == 'G')
		size *= 1024*1024*1024;
	else if (*endptr)
		size = -1UL;

	return size;
}

void dump_file(const char *filename)
{
	char buffer[BUFSIZ];
	int fd;

	fd = open(filename, O_RDONLY);
	if (fd == -1)
		return;

	while (read(fd, buffer, sizeof(buffer)))
		printf("%s", buffer);

	printf("\n");
	close(fd);
}

int main(int argc, char **argv)
{
	size_t size = 10<<20;
	size_t to_free, freed = 0;
	size_t i, step = PAGE_SIZE*((1UL<<MAX_ORDER)-1);
	unsigned char *addr;
	int buddy_fd;
	const char *to_run;

	if (argc > 1) {
		to_run = argv[1];
	} else {
		fprintf(stderr, "Didn't tell me what to run");
		return 1;
	}
	if (argc > 2) {
		size = parse_size(argv[2]);
		if (size == -1UL) {
			fprintf(stderr, "Number expected \"%s\" given.\n", argv[0]);
			return 1;
		}
	}
	if (argc > 3) {
		to_free = parse_size(argv[3]);
		if (to_free == -1UL) {
			fprintf(stderr, "Number expected \"%s\" given.\n", argv[0]);
			return 1;
		}
	} else {
		to_free = size;
	}

	dump_file("/proc/buddyinfo");
	addr = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	if (addr == MAP_FAILED) {
		perror("mmap");
		return 3;
	}
	madvise(addr, size, MADV_NOHUGEPAGE);
	for (i = 0; i < size; i += PAGE_SIZE)
		addr[i] = 1;

	while (freed < to_free) {
		for (i = step; (freed < to_free) && (i < size); i = (i + step) % size) {
			i = PAGE_ALIGN(i);
			if (madvise(&addr[i], PAGE_SIZE, MADV_DONTNEED))
				continue;
			freed += PAGE_SIZE;
		}
		step = (step / 2) + 1;
	}

	printf("Done fragmenting. size=%lu freed=%lu\n", size, freed);
	dump_file("/proc/buddyinfo");
	printf("Executing \"%s\"\n", to_run);
	fflush(stdout);
	return system(to_run);
}

--PEIAKu/WMn1b1Hv9
Content-Type: application/x-sh
Content-Disposition: attachment; filename="alloc_hugepages.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0Anr_hugepages=3D$(awk '/MemAvailable/{printf "%d\n", $2/(2*1024)=
}' /proc/meminfo)=0Aecho Eating some pagecache=0Afile=3D/mnt/data/file.1=0A=
nr_blocks=3D$(awk '/MemTotal/{printf "%d\n", $2/4}' /proc/meminfo)=0Add of=
=3D/dev/null if=3D/mnt/data/file.1 bs=3D4096 count=3D$nr_blocks=0Acat /proc=
/buddyinfo=0Aecho Trying to allocate $nr_hugepages=0A/bin/echo $nr_hugepage=
s > /proc/sys/vm/nr_hugepages=0Acat /proc/sys/vm/nr_hugepages=0Acat /proc/b=
uddyinfo=0Aecho Try to compact=0Aecho 1 > /proc/sys/vm/compact_memory=0Acat=
 /proc/buddyinfo=0Aecho 0 > /proc/sys/vm/nr_hugepages=0A
--PEIAKu/WMn1b1Hv9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
