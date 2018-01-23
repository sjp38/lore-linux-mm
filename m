Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83E74800E4
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 18:54:21 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id h13so3467131qtj.1
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 15:54:21 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g184si63520qkc.463.2018.01.23.15.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 15:54:20 -0800 (PST)
From: Henry Willard <henry.willard@oracle.com>
Subject: [PATCH v2] mm: numa: Do not trap faults on shared data section pages.
Date: Tue, 23 Jan 2018 15:53:37 -0800
Message-Id: <1516751617-7369-1-git-send-email-henry.willard@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Workloads consisting of a large number of processes running the same program
with a very large shared data segment may experience performance problems 
when numa balancing attempts to migrate the shared cow pages. This manifests
itself with many processes or tasks in TASK_UNINTERRUPTIBLE state waiting
for the shared pages to be migrated.

The program listed below simulates the conditions with these results when 
run with 288 processes on a 144 core/8 socket machine.

Average throughput 	Average throughput     Average throughput
with numa_balancing=0	with numa_balancing=1  with numa_balancing=1
     			without the patch      with the patch
---------------------	---------------------  ---------------------
2118782			2021534		       2107979

Complex production environments show less variability and fewer poorly 
performing outliers accompanied with a smaller number of processes waiting 
on NUMA page migration with this patch applied. In some cases, %iowait drops 
from 16%-26% to 0.

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

This patch changes change_pte_range() to skip shared copy-on-write pages when
called from change_prot_numa(). 

NOTE: change_prot_numa() is nominally called from task_numa_work() and
queue_pages_test_walk(). task_numa_work() is the auto NUMA balancing path, and
queue_pages_test_walk() is part of explicit NUMA policy management. However,
queue_pages_test_walk() only calls change_prot_numa() when MPOL_MF_LAZY is
specified and currently that is not allowed, so change_prot_numa() is only
called from auto NUMA balancing.

In the case of explicit NUMA policy management, shared pages are not migrated
unless MPOL_MF_MOVE_ALL is specified, and MPOL_MF_MOVE_ALL depends on
CAP_SYS_NICE. Currently, there is no way to pass information about
MPOL_MF_MOVE_ALL to change_pte_range. This will have to be fixed if
MPOL_MF_LAZY is enabled and MPOL_MF_MOVE_ALL is to be honored in lazy
migration mode.

task_numa_work() skips the read-only VMAs of programs and shared libraries.

V2:
- Combined patch and cover letter
- Added note about applicability of MPOL_MF_MOVE_ALL 

Signed-off-by: Henry Willard <henry.willard@oracle.com>
Reviewed-by: HAJPYkon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Steve Sistare steven.sistare@oracle.com
Acked-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f730a0bf..fbbb3ab70818 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -84,6 +84,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				if (!page || PageKsm(page))
 					continue;
 
+				/* Also skip shared copy-on-write pages */
+				if (is_cow_mapping(vma->vm_flags) &&
+				    page_mapcount(page) != 1)
+					continue;
+
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
