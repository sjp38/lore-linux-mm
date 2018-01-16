Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C961A6B0282
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:29:31 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id u10so13013010qtg.5
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:29:31 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f100si3117516qkf.204.2018.01.16.11.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:29:30 -0800 (PST)
From: Henry Willard <henry.willard@oracle.com>
Subject: [PATCH] mm: numa: numa balancing performance problem
Date: Tue, 16 Jan 2018 11:28:43 -0800
Message-Id: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Workloads consisting of a large number of processes running the same program
with a very large shared data section may experience performance problems 
when numa balancing attempts to migrate the shared cow pages. This manifests
itself with many processes or tasks in TASK_UNINTERRUPTIBLE state waiting
for the shared pages to be migrated.

This patch changes change_pte_range() to skip shared copy-on-write pages when
called from change_prot_numa(). 

The program listed below simulates the conditions with these results when 
run with 288 processes on a 144 core/8 socket machine.

Average throughput 	Average throughput     Average throughput
with numa_balancing=0	with numa_balancing=1  with numa_balancing=1
     			without the patch      with the patch
---------------------	---------------------  ---------------------
2118782			2021534		       2107979

Complex production environments show less variability and fewer poorly 
performing outliers accompanied with a smaller number of processes waiting 
on NUMA page migration. In some cases, %iowait drops from 16%-26% to 0.

// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (c) 2017 Oracle and/or its affiliates. All rights reserved.
 */
#include <sys/time.h>
#include <stdio.h>
#include <wait.h>
#include <sys/mman.h>

int a[1000000] = {13};

int  main(int argc, const char **argv)
{
	int n = 0;
	int i;
	pid_t pid;
	int stat;
	int *count_array;
	int cpu_count = 288;
	long total = 0;

	struct timeval t1, t2 = {(argc > 1 ? atoi(argv[1]) : 10), 0};

	if (argc > 2)
		cpu_count = atoi(argv[2]);

	count_array = mmap(NULL, cpu_count * sizeof(int),
			   (PROT_READ|PROT_WRITE),
			   (MAP_SHARED|MAP_ANONYMOUS), 0, 0);

	if (count_array == MAP_FAILED) {
		perror("mmap:");
		return 0;
	}


	for (i = 0; i < cpu_count; ++i) {
		pid = fork();
		if (pid <= 0)
			break;
		if ((i & 0xf) == 0)
			usleep(2);
	}

	if (pid != 0) {
		if (i == 0) {
			perror("fork:");
			return 0;
		}

		for (;;) {
			pid = wait(&stat);
			if (pid < 0)
				break;
		}

		for (i = 0; i < cpu_count; ++i)
			total += count_array[i];

		printf("Total %ld\n", total);
		munmap(count_array, cpu_count * sizeof(int));
		return 0;
	}

	gettimeofday(&t1, 0);
	timeradd(&t1, &t2, &t1);
	while (timercmp(&t2, &t1, <)) {
		int b = 0;
		int j;

		for (j = 0; j < 1000000; j++)
			b += a[j];
		gettimeofday(&t2, 0);
		n++;
	}
	count_array[i] = n;
	return 0;
}



 mm/mprotect.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
