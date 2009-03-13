Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 463B86B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 07:37:02 -0400 (EDT)
Message-ID: <49BA4541.6000708@nokia.com>
Date: Fri, 13 Mar 2009 13:36:33 +0200
From: Aaro Koskinen <aaro.koskinen@nokia.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [ARM] Flush only the needed range when unmapping a VMA
References: <49B54B2A.9090408@nokia.com> <1236690093-3037-1-git-send-email-Aaro.Koskinen@nokia.com> <20090312213006.GN7854@n2100.arm.linux.org.uk>
In-Reply-To: <20090312213006.GN7854@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ext Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hello,

ext Russell King - ARM Linux wrote:
> On Tue, Mar 10, 2009 at 03:01:33PM +0200, Aaro Koskinen wrote:
>> When unmapping N pages (e.g. shared memory) the amount of TLB flushes
>> done can be (N*PAGE_SIZE/ZAP_BLOCK_SIZE)*N although it should be N at
>> maximum. With PREEMPT kernel ZAP_BLOCK_SIZE is 8 pages, so there is a
>> noticeable performance penalty when unmapping a large VMA and the system
>> is spending its time in flush_tlb_range().
> 
> It would be nice to have some figures for the speedup gained by this
> optimisation - is there any chance you could provide a comparison?

Here's a test on an OMAP3 board, 2.6.28 with linux-omap fixes and 
PREEMPT enabled. Without the patch:

~ # for PAGES in 1000 2000 3000 4000 5000 6000 7000 8000; do time 
./shmtst $PAGES; done
shm segment size 4096000 bytes
real    0m 0.12s
user    0m 0.02s
sys     0m 0.10s
shm segment size 8192000 bytes
real    0m 0.36s
user    0m 0.00s
sys     0m 0.35s
shm segment size 12288000 bytes
real    0m 0.71s
user    0m 0.03s
sys     0m 0.67s
shm segment size 16384000 bytes
real    0m 1.17s
user    0m 0.07s
sys     0m 1.10s
shm segment size 20480000 bytes
real    0m 1.75s
user    0m 0.03s
sys     0m 1.71s
shm segment size 24576000 bytes
real    0m 2.44s
user    0m 0.03s
sys     0m 2.39s
shm segment size 28672000 bytes
real    0m 3.24s
user    0m 0.10s
sys     0m 3.14s
shm segment size 32768000 bytes
real    0m 4.16s
user    0m 0.11s
sys     0m 4.04s

With the patch:

~ # for PAGES in 1000 2000 3000 4000 5000 6000 7000 8000; do time 
./shmtst $PAGES; done
shm segment size 4096000 bytes
real    0m 0.07s
user    0m 0.01s
sys     0m 0.05s
shm segment size 8192000 bytes
real    0m 0.13s
user    0m 0.02s
sys     0m 0.10s
shm segment size 12288000 bytes
real    0m 0.20s
user    0m 0.00s
sys     0m 0.19s
shm segment size 16384000 bytes
real    0m 0.27s
user    0m 0.04s
sys     0m 0.22s
shm segment size 20480000 bytes
real    0m 0.33s
user    0m 0.02s
sys     0m 0.31s
shm segment size 24576000 bytes
real    0m 0.40s
user    0m 0.03s
sys     0m 0.36s
shm segment size 28672000 bytes
real    0m 0.47s
user    0m 0.03s
sys     0m 0.42s
shm segment size 32768000 bytes
real    0m 0.53s
user    0m 0.09s
sys     0m 0.43s

The test program:

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/ipc.h>
#include <sys/shm.h>

volatile char dummy;

int main (int argc, char *argv[])
{
         void *addr;
         int i;
         int shmid;
         int pages = 0;

         if (argc == 2)
                 pages = atoi(argv[1]);

         if (pages < 0) {
                 fprintf(stderr, "usage: %s <pages>\n", argv[0]);
                 return 0;
         }

         printf("shm segment size %d bytes\n", pages*4096);

         shmid = shmget(IPC_PRIVATE, pages*4096, IPC_CREAT | 0777);
         addr = shmat(shmid, NULL, 0);
         memset(addr, 0xBA, pages*4096);
         shmdt(addr);

         addr = shmat(shmid, NULL, 0);
         for (i = 0; i < pages*4096; i += 4096)
                 dummy += *((char *)addr + i);
         shmdt(addr);

         addr = shmat(shmid, NULL, 0);
         shmctl(shmid, IPC_RMID, 0);
         shmdt(addr);

         return 0;
}

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
