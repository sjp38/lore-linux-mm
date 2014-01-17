Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEAE6B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 07:39:52 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e49so2115879eek.29
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 04:39:51 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id r9si7361379eeo.149.2014.01.17.04.39.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 04:39:51 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Fri, 17 Jan 2014 12:39:50 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1846A1B08061
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 12:39:10 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0HCdYQ27602370
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 12:39:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0HCdjL4005802
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 05:39:46 -0700
Message-ID: <52D9248F.6030901@linux.vnet.ibm.com>
Date: Fri, 17 Jan 2014 13:39:43 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [Resend] Puzzling behaviour with multiple swap targets
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Shaohua Li <shli@kernel.org>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Eberhard Pasch <epasch@de.ibm.com>

Hi,

/*
  * RESEND - due the vacation time we all hopefully shared this might
  * have slipped through mail filters and mass deletes - so I wanted to
  * give the question another chance.
  */

I've analyzed swapping for a while now. I made some progress tuning my 
system for better, faster and more efficient swapping. However one thing 
still eludes me.
I think by asking here we can only win. Either it is trivial to you and 
I get a better understanding or you can take it as brain teaser over 
Christmas time :-)

Long Story Short - the Issue:
The more Swap targets I use, the slower the swapping becomes.


Details - Issue:
As mentioned before I made a lot of analysis already including 
simplifications of the testcase.
Therefore I only describe the most simplified setup and scenario.
I run a testcase (see below) accessing overcommitted (1.25:1) memory in 
4k chunks selecting the offset randomly.
When swapping to a single disk I achieve about 20% more throughput 
compared to just taking this disk, partitioning it into 4 equal pieces 
and activate those as swap.
The workload does read only in that overcommitted memory.

According to my understanding for read only the exact location shouldn't 
matter.
The fault will find a page that was swapped out and discarded, start the 
I/O to bring it back going via the swap extends.
There is just no code caring a lot about the partitions in the fault-IN 
path.
Also as the workload is uniform random locality on disk should be 
irrelevant as the accesses to the four partitions will be mapped to just 
the same disk.

Still the number of partitions on the same physical resource changes the 
throughput I can achieve on memory.



Details - Setup
My Main System is a System zEnterprise zEC12 s390 machine with 10GB Memory.
I have 2 CPUs (FYI the issue appears no matter how much cpus - tested 1-64).
The working set of the workload is 12.5 GB,so the overcommit ratio is a 
light 1.25:1 (also tested from 1.02 up to 3:1 - it was visible in each 
case, but 1.25:1 was the most stable)
As swap device I use 1 FCP attached Disk served by a IBM DS8870 attached 
via 8x8Gb FCP adapters on Server and Storage Server.
The disk holds 256GB which leaves my case far away from 50% swap.
Initially I used multiple disks, but the problem is more puzzling (as it 
leaves less room for speculation) when just changing the #partitions on 
the same physical resource.

I verified it on an IBM X5 (Xeon X7560) and while the (local raid 5) 
disk devices there are much slower, they still show the same issue when 
comparing 1 disk 1 partition vs the same 1 disk 4 partitions.



Remaining Leads:
Using iostat to compare swap disk activity vs what my testcase can 
achieve in memory identified that the "bad case" is less efficient.
That means it doesn't have less/slower disk I/O, no in fact it has 
usually slightly more disk I/O at about the same performance 
characteristics than the "good case".
That implies that the "efficiency" in the good case is better meaning 
that it is more likely to have the "correct next page" at hand and in 
swap cache.
That is confirmed by the fact that setting page_cluster to 0 eliminates 
the difference of 1 to many partitions.
Unfortunately the meet at the lower throughput level.
Also I don't see what the mm/swap code can make right/wrong for a 
workload accessing 4k pages in a randomized way.
There should be no statistically relevant value in the locality of the 
workload that can be handled right.



Rejected theories:
I tested a lot of things already and some made it into tunings (IO 
scheduler, page_cluster, ...), but non of them fixed the "more swap 
targets -> slower" issue.
- locking: Lockstat showed nothing changing a lot between 1 and 4 
partitions. In fact the 5 most busy locks were related to huge pages and 
disabling those got rid of the locks in lockstat, but didn't affect the 
throughput at all.
- scsi/blkdev: as complex multipath setups can often be a source of 
issues I used a special s390 only memory device called xpram. It 
essentially is a block device that fulfils I/O requests at make_request 
level at memory speed. That sped up my test a lot, but taking the same 
xpram memory once in one chunk and once broken into 4 pieces it still 
was worse with the four pieces.
- already fixed: there was an upstream patch commit ec8acf20 "swap: add 
per-partition lock for swapfile" from "Shaohua Li <shli@kernel.org>" 
that pretty much sounds like the same issue. But it was already applied.
- Kernel Versions: while the majority of my tests were on 3.10.7 I 
tested up to 3.12.2 and still saw the same issue.
- Scaling in general: when I go from 1 to 4 partitions on a single disk 
I see the mentioned ~20% drop in throughput.
   But going further like 6 disks with 4 partitions each is at almost 
the same level.
   So it gets a bit worse, but the black magic seems to happen between 1->4.



Details - Workload:
While my original workload can be complex with configurable threads, 
background load and all kind of accounting I thought it is better to 
simplify it for this discussion. Therefore the code now is rather simple 
and even lacking the majority of e.g. null pointer checks - but it is 
easy to understand what it does.
Essentially I allocate a given amount of memory - 12500MB by default. 
Then I initialize that memory followed by a warmup phase of three runs 
through the full working set. Then the real workload starts accessing 4k 
chunks at random offsets.

Since the code is so small now I think it qualifies as inline
---cut here---
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define MB (1024*1024)
int stopme = 0;
unsigned chunk_size = 4096;
unsigned no_chunks = 0;
int duration = 600;
size_t mem_size = 12500;

void * uniform_random_access(char *buffer) {
	unsigned long offset;
	offset = ((unsigned long)(drand48()*(mem_size/chunk_size)))*chunk_size;
	return (void*)(((unsigned long)buffer)+offset);
}

void  alrmhandler(int sig) {
	signal(SIGALRM, SIG_IGN);
	printf("\n\nGot alarm, set stopme\n");
	stopme=1;
}

int main(int argc, char * argv[])
{
	unsigned long j, i = 0;
	double rmem;
	unsigned long local_reads = 0;
	void *read_buffer;
	char *c;
	mem_size = mem_size * MB;
	signal(SIGALRM, alrmhandler);
	c=malloc(mem_size);
	read_buffer = malloc(chunk_size);
	memset(read_buffer,1,chunk_size);
	memset(c,1,mem_size);
	for (i=0; i<3; i++) {
		for (j=0; j<(mem_size/chunk_size); j++) {
			memcpy(read_buffer,uniform_random_access(c),chunk_size);
		}
	}
	i=0;
	alarm(duration);

	while (1) {
		for (j=0; j<(mem_size/chunk_size); j++) {
			memcpy(read_buffer,uniform_random_access(c),chunk_size);
			local_reads++;

			if (stopme)
				goto out;
		}
		i++;
	}
out:
	rmem = ((mem_size/MB)*i*1) + ((local_reads*chunk_size)/MB);
	printf("Accumulated Read Throughput (mb/s):  %20.2lf\n", rmem/duration);
	printf("%% of working set covered:            %20.2lf\n", 
(rmem/(mem_size/MB))*100.0 );
	free(c);
	free(read_buffer);
	exit(0);
}
---cut here---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
