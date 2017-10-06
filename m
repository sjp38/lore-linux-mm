Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED7B06B0038
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 17:38:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so40453612pfj.3
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 14:38:31 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k197si1791151pgc.187.2017.10.06.14.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 14:38:30 -0700 (PDT)
From: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
Subject: [PATCH v1][cover-letter] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Date: Fri,  6 Oct 2017 08:36:33 -0500
Message-Id: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>

According to mbind() and set_mempolicy()'s man pages the argument "maxnode"
specifies the max number of bits in the "nodemask" (which is also to be passed
to these functions) that should be considered for the memory policy. If maxnode
= 2, only two bits are to be considered thus valid node masks are: 0b00, 0b01,
0b10 and 0b11.

In systems with multiple NUMA nodes, sometimes it is useful to set strict
memory policies like MPOL_BIND to restric memory allocations to a single node
maybe because it is the closest node or because is a high bandwidth node,
however an off-by-one error in get_nodes() the function that copies the node
mask from user space requires users to pass maxnode = actual_maxnode + 1 to
mbind()/set_mempolicy(), for instance with 2 nodes maxnode = 3.

Below some code to exemplify this behavior, on a system with 2 NUMA nodes to
force memory allocation on node 1, nodemask = 2 (0b10) and maxnode should be 2,
however if maxnode = 2 set_mempolicy() fails with error code 22, to make this
code work maxnode = 3.  The proposed patch fixes this issue, allowing users to
use maxnode = 2.


// compile with  gcc -std=c99 -lnuma test.c -o test

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sched.h>
#include <numa.h>
#include <numaif.h>

#define NUMBER_OF_LETTERS 26

int main() {
	int cpu = sched_getcpu();
	int node = numa_node_of_cpu(cpu);
	printf("process running on CPU %d numa node %d\n", cpu, node);

	// 2 == 0b10 allocate memory on NUMA node 1
	unsigned long nodemask = 2; 

	// with maxnode = 3 this code works on a system with 2 NUMA nodes
	unsigned long maxnode = 2;

	if (set_mempolicy(MPOL_BIND, &nodemask, maxnode)) {
		printf("set_mempolicy() failed with error code: %d, error string: %s\n",
			errno, strerror(errno));
		exit(-1);
	}

	char *ptr = (char*)malloc(NUMBER_OF_LETTERS * sizeof(char));

	for (int i = 0; i < NUMBER_OF_LETTERS; i++)
	ptr[i] = i + 'a';

	printf("freeing memory...\n");
	free(ptr);

	return 0;
}

Luis Felipe Sandoval Castro (1):
  mm/mempolicy.c: Fix get_nodes() off-by-one error.

 mm/mempolicy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
