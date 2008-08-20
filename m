Date: Wed, 20 Aug 2008 20:08:13 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When a test program which does task migration runs, my 8GB box spends 800MB of memory
for quicklist. This is not memory leak but doesn't seem good.

% cat /proc/meminfo

MemTotal:        7701568 kB
MemFree:         4724672 kB
(snip)
Quicklists:       844800 kB


because

- My machine spec is 
	number of numa node: 2
	number of cpus:      8 (4CPU x2 node)
        total mem:           8GB (4GB x2 node)
        free mem:            about 5GB

- Maximum quicklist usage is here

	 Number of CPUs per node            2    4    8   16
	 ==============================  ====================
	 QList_max / (Free + QList_max)   5.8%  16%  30%  48%


- Then, 4.7GB x 16% ~= 880MB.
  So, Quicklist can use 800MB.



So, if following spec machine run that program

   CPUs: 64 (8cpu x 8node)
   Mem:  1TB (128GB x8node)

Then, quicklist can waste 300GB (= 1TB x 30%).
it is fairly too large.

So, I don't like cache policies which is proportional to # of cpus.

My patch changes the number of caches 
from:
   per-cpu-cache-amount = memory_on_node / 16
to
   per-cpu-cache-amount = memory_on_node / 16 / numder_of_cpus_on_node.

I think this is reasonable. but even if this patch is applied, quicklist
can cache tons of memory on big machine.

(Although its patch applied, quicklist can waste 64GB on 1TB server (= 1TB / 16),
 it is still too much??)


test program is below.
--------------------------------------------------------------------------------
#define _GNU_SOURCE

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>

#define BUFFSIZE 512

int max_cpu(void)	/* get max number of logical cpus from /proc/cpuinfo */
{
  FILE *fd;
  char *ret, buffer[BUFFSIZE];
  int cpu = 1;

  fd = fopen("/proc/cpuinfo", "r");
  if (fd == NULL) {
    perror("fopen(/proc/cpuinfo)");
    exit(EXIT_FAILURE);
  }
  while (1) {
    ret = fgets(buffer, BUFFSIZE, fd);
    if (ret == NULL)
      break;
    if (!strncmp(buffer, "processor", 9))
      cpu = atoi(strchr(buffer, ':') + 2);
  }
  fclose(fd);
  return cpu;
}

void cpu_bind(int cpu)	/* bind current process to one cpu */
{
  cpu_set_t mask;
  int ret;

  CPU_ZERO(&mask);
  CPU_SET(cpu, &mask);
  ret = sched_setaffinity(0, sizeof(mask), &mask);
  if (ret == -1) {
    perror("sched_setaffinity()");
    exit(EXIT_FAILURE);
  }
  sched_yield();	/* not necessary */
}

#define MMAP_SIZE (10 * 1024 * 1024)	/* 10 MB */
#define FORK_INTERVAL 1	/* 1 second */

main(int argc, char *argv[])
{
  int cpu_max, nextcpu;
  long pagesize;
  pid_t pid;

  /* set max number of logical cpu */
  if (argc > 1)
    cpu_max = atoi(argv[1]) - 1;
  else
    cpu_max = max_cpu();

  /* get the page size */
  pagesize = sysconf(_SC_PAGESIZE);
  if (pagesize == -1) {
    perror("sysconf(_SC_PAGESIZE)");
    exit(EXIT_FAILURE);
  }

  /* prepare parent process */
  cpu_bind(0);
  nextcpu = cpu_max;

loop:

  /* select destination cpu for child process by round-robin rule */
  if (++nextcpu > cpu_max)
    nextcpu = 1;

  pid = fork();

  if (pid == 0) { /* child action */

    char *p;
    int i;

    /* consume page tables */
    p = mmap(0, MMAP_SIZE, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
    i = MMAP_SIZE / pagesize;
    while (i-- > 0) {
      *p = 1;
      p += pagesize;
    }

    /* move to other cpu */
    cpu_bind(nextcpu);
/*
    printf("a child moved to cpu%d after mmap().\n", nextcpu);
    fflush(stdout);
 */
  
    /* back page tables to pgtable_quicklist */
    exit(0);

  } else if (pid > 0) { /* parent action */

    sleep(FORK_INTERVAL);
    waitpid(pid, NULL, WNOHANG);

  }

  goto loop;
}
-----------------------------------------------------------------------------


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/quicklist.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: b/mm/quicklist.c
===================================================================
--- a/mm/quicklist.c
+++ b/mm/quicklist.c
@@ -26,7 +26,9 @@ DEFINE_PER_CPU(struct quicklist, quickli
 static unsigned long max_pages(unsigned long min_pages)
 {
 	unsigned long node_free_pages, max;
-	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
+	int node = numa_node_id();
+	struct zone *zones = NODE_DATA(node)->node_zones;
+	int num_cpus_per_node;
 
 	node_free_pages =
 #ifdef CONFIG_ZONE_DMA
@@ -38,6 +40,10 @@ static unsigned long max_pages(unsigned 
 		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
 
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
+
+	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
+	max /= num_cpus_per_node;
+
 	return max(max, min_pages);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
