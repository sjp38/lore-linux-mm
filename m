Date: Sat, 23 Aug 2008 17:24:31 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
In-Reply-To: <20080821212847.f7fc936b.akpm@linux-foundation.org>
References: <20080822100049.F562.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080821212847.f7fc936b.akpm@linux-foundation.org>
Message-Id: <20080823171352.2533.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> > OK.
> > I ran cpu hotplug/unplug coutinuous workload over 12H.
> > then, system crash doesn't happend.
> > 
> > So, I believe my patch is cpu unplug safe.
> 
> err, which patch?
> 
> I presently have:
> 
> mm-show-quicklist-memory-usage-in-proc-meminfo.patch
> mm-show-quicklist-memory-usage-in-proc-meminfo-fix.patch
> mm-quicklist-shouldnt-be-proportional-to-number-of-cpus.patch
> mm-quicklist-shouldnt-be-proportional-to-number-of-cpus-fix.patch
> 
> Is that what you have?
> 
> I'll consolidate them into two patches and will append them here.  Please check.

Andrew, Thank you for your attention.

I test on

mm-show-quicklist-memory-usage-in-proc-meminfo.patch
mm-show-quicklist-memory-usage-in-proc-meminfo-fix.patch

and 

http://marc.info/?l=linux-mm&m=121931317407295&w=2 


the above url's patch already checked sparc64 compilable by David.
and I tested it.

So, if possible, Could you replace current quicklist-shouldnt-be-proportional
patch to that?
(of cource, current -mm patch also works well)



the same patch attached below because web mail interface is a bit ugly.


From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

When a test program which does task migration runs, my 8GB box spends
800MB of memory for quicklist.  This is not memory leak but doesn't seem
good.

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

Then, quicklist can waste 300GB (= 1TB x 30%).  It is too large.

So, I don't like cache policies which is proportional to # of cpus.

My patch changes the number of caches
from:
   per-cpu-cache-amount = memory_on_node / 16
to
   per-cpu-cache-amount = memory_on_node / 16 / number_of_cpus_on_node.

I think this is reasonable.  but even if this patch is applied, quicklist
can cache tons of memory on big machine.

(Although its patch applied, quicklist can waste 64GB on 1TB server (= 1TB
/ 16), it is still too much??)

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

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
Tested-by: David Miller <davem@davemloft.net>
Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]

---
 mm/quicklist.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: b/mm/quicklist.c
===================================================================
--- a/mm/quicklist.c
+++ b/mm/quicklist.c
@@ -26,7 +26,10 @@ DEFINE_PER_CPU(struct quicklist, quickli
 static unsigned long max_pages(unsigned long min_pages)
 {
 	unsigned long node_free_pages, max;
-	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
+	int node = numa_node_id();
+	struct zone *zones = NODE_DATA(node)->node_zones;
+	int num_cpus_on_node;
+	node_to_cpumask_ptr(cpumask_on_node, node);
 
 	node_free_pages =
 #ifdef CONFIG_ZONE_DMA
@@ -38,6 +41,10 @@ static unsigned long max_pages(unsigned 
 		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
 
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
+
+	num_cpus_on_node = cpus_weight_nr(*cpumask_on_node);
+	max /= num_cpus_on_node;
+
 	return max(max, min_pages);
 }
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
