Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D16BC6B0265
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:27:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so124745179pab.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:27:43 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a189si8169828pfa.80.2016.07.21.00.27.39
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 00:27:42 -0700 (PDT)
Date: Thu, 21 Jul 2016 16:31:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v1
Message-ID: <20160721073156.GC27554@js1304-P5Q-DELUXE>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2016 at 04:21:46PM +0100, Mel Gorman wrote:
> Both Joonsoo Kim and Minchan Kim have reported premature OOM kills on
> a 32-bit platform. The common element is a zone-constrained high-order
> allocation failing. Two factors appear to be at fault -- pgdat being
> considered unreclaimable prematurely and insufficient rotation of the
> active list.
> 
> Unfortunately to date I have been unable to reproduce this with a variety
> of stress workloads on a 2G 32-bit KVM instance. It's not clear why as
> the steps are similar to what was described. It means I've been unable to
> determine if this series addresses the problem or not. I'm hoping they can
> test and report back before these are merged to mmotm. What I have checked
> is that a basic parallel DD workload completed successfully on the same
> machine I used for the node-lru performance tests. I'll leave the other
> tests running just in case anything interesting falls out.

Hello, Mel.

I tested this series and it doesn't solve my problem. But, with this
series and one change below, my problem is solved.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f5ab357..d451c29 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1819,7 +1819,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 
                nr_pages = hpage_nr_pages(page);
                update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
-               list_move(&page->lru, &lruvec->lists[lru]);
+               list_move_tail(&page->lru, &lruvec->lists[lru]);
                pgmoved += nr_pages;
 
                if (put_page_testzero(page)) {

It is brain-dead work-around so it is better you to find a better solution.

I guess that, in my test, file reference happens very quickly. So, if there are
many skip candidates, reclaimable pages on lower zone cannot be reclaimed easily
due to re-reference. If I apply above work-around, the test is finally passed.

One more note that, in my test, 1/5 patch have a negative impact. Sometime,
system lock-up happens and elapsed time is also worse than the test without it.

Anyway, it'd be good to post my test script and program.

setup: 64 bit 2000 MB (500 MB DMA32 and 1500 MB MOVABLE)

sudo swapoff -a
file-read 1500 0 &
file-read 1500 0 &

while(1)
 ./fork 3000 0

Thanks.


file-read.c
-----------------
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define MB (1024 * 1024)
#define PAGE_SIZE (4096)
#define TEST_FILE "XXXX"

static void touch_mem_seq(void *mem, unsigned long size_mb)
{
        unsigned long i;
        unsigned long size_b;
        char c;

        size_b = size_mb * MB;
        for (i = 0; i < size_b; i += PAGE_SIZE)
                c = *((char *)mem + i);
}

static void touch_mem_rand(void *mem, unsigned long size_mb)
{
        unsigned long i;
        unsigned long size_b;
        char c;

        size_b = size_mb * MB;
        for (i = 0; i < size_b; i += PAGE_SIZE)
                c = *((char *)mem + rand() % size_b);
}

int main(int argc, char *argv[])
{
        unsigned long size_mb;
        void *mem;
        int fd;
        int type;

        srand(time(NULL));

        if (argc != 3) {
                printf("Invalid argument\n");
                exit(1);
        }

        size_mb = atol(argv[1]);
        if (size_mb < 1 || size_mb > 2048) {
                printf("Invalid argument\n");
                exit(1);
        }

        type = atol(argv[2]);
        if (type != 0 && type != 1) {
                printf("Invalid argument\n");
                exit(1);
        }

        fd = open(TEST_FILE, O_RDWR);
        if (fd < 0) {
                printf("Open failed\n");
                exit(1);
        }

        mem = mmap(NULL, size_mb * MB, PROT_READ, MAP_PRIVATE, fd, 0);
        if (mem == MAP_FAILED) {
                printf ("Out of memory: %lu MB\n", size_mb);
                exit(1);
        }

        while (1) {
                if (!type)
                        touch_mem_seq(mem, size_mb);
                else
                        touch_mem_rand(mem, size_mb);
        }

        return 0;
}



fork.c
------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>

int main(int argc, char *argv[])
{
        int i, n;
        pid_t pid;
        pid_t *pids;

        if (argc != 2) {
                printf("Invalid argument\n");
                exit(1);
        }

        n = atoi(argv[1]);
        pids = malloc(n * sizeof(pid_t));
        if (!pids) {
                printf("Out of memory\n");
                exit(1);
        }

        for (i = 0; i < n; i++) {
                pid = fork();
                if (pid == 0)
                        sleep(1000);

                if (pid == -1) {
                        i--;
                        continue;
                }
                pids[i] = pid;
                if (i % 100 == 0)
                        printf("Child forked: %d\n", i);
        }

        for (i = 0; i < n; i++) {
                kill(pids[i], SIGTERM);
        }

        sleep(1);
        printf("Parent finished\n");
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
