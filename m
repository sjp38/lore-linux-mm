Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 601F56B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:50:29 -0500 (EST)
Received: by pdjz10 with SMTP id z10so4855474pdj.0
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 06:50:29 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id e10si1115213pdp.183.2015.02.11.06.50.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 11 Feb 2015 06:50:28 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJM00LXP42NLM80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Feb 2015 14:54:23 +0000 (GMT)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC] shmem: Add eventfd notification on utlilization level
Date: Wed, 11 Feb 2015 15:50:07 +0100
Message-id: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Hi,


We have a need of getting notifications from kernel to user-space
when tmpfs runs out of free space. I used here a term 'utilization'
in the meaning of percent of free space.

The idea I got is to use eventfd. Proof of concept attached:
1. Patch for kernel.
2. Sample C program (at the end of cover letter).

Usage:
$ mount -t tmpfs -o warn_used=1k,nr_blocks=2k none /path
$ ( sleep 5 && dd if=/dev/zero of=/path/file bs=1M count=4 ) &
$ ./eventfd-wait /sys/fs/tmpfs/tmpfs-6/warn_used_blocks_efd


What do you think about this? Maybe there are simpler ways
of achieving this?

Best regards,
Krzysztof


------------[ cut here ]------------
#include <sys/eventfd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>				 /* Definition of uint64_t */

#define handle_error(msg) \
	do { perror(msg); exit(EXIT_FAILURE); } while (0)

int
main(int argc, char *argv[])
{
	int efd;
	uint64_t u;
	ssize_t s;
	int fd;
	char buf[10];

	if (argc != 2) {
		printf("Usage: %s PATH\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	efd = eventfd(0, 0);
	if (efd == -1)
		 handle_error("eventfd");

	fd = open(argv[1], O_WRONLY);
	if (fd < 0)
		handle_error("sysfs open");

	snprintf(buf, sizeof(buf), "%d", efd);

	s = write(fd, buf, strlen(buf));
	if (s < 0)
		handle_error("sysfs write");

	close(fd);
	
	printf("Waiting for usage notification:\n");
	s = read(efd, &u, sizeof(uint64_t));
	if (s != sizeof(uint64_t))
		 handle_error("read");
	printf("Usage threshold reached: %llu\n",
			  (unsigned long long) u, (unsigned long long) u);
	exit(EXIT_SUCCESS);
}
------------[ cut here ]------------


Krzysztof Kozlowski (1):
  shmem: Add eventfd notification on utlilization level

 include/linux/shmem_fs.h |   4 ++
 mm/shmem.c               | 138 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 140 insertions(+), 2 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
