Date: Fri, 22 Aug 2008 08:23:09 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
Message-ID: <20080822132309.GB9501@sgi.com>
References: <20080820113559.f559a411.akpm@linux-foundation.org> <2f11576a0808210036icd9b61eue58049f15381bcc8@mail.gmail.com> <20080822100049.F562.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080821212847.f7fc936b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080821212847.f7fc936b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Christoph,

Could we maybe add a per_cpu off-node quicklist and just always free
that in check_pgt_cache?  That would get us back the freeing of off-node
page tables.

Thanks,
Robin


On Thu, Aug 21, 2008 at 09:28:47PM -0700, Andrew Morton wrote:
> On Fri, 22 Aug 2008 10:05:45 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > quicklist_total_size() is racy against cpu hotplug.  That's OK for
> > > > /proc/meminfo purposes (occasional transient inaccuracy?), but will it
> > > > crash?  Not in the current implementation of per_cpu() afaict, but it
> > > > might crash if we ever teach cpu hotunplug to free up the percpu
> > > > resources.
> > > 
> > > First, Quicklist doesn't concern to cpu hotplug at all.
> > > it is another quicklist problem.
> > > 
> > > Next, I think it doesn't cause crash. but I haven't any test.
> > > So, I'll test cpu hotplug/unplug testing today.
> > > 
> > > I'll report result tommorow.
> > 
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
> 
> 
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> At present the quicklists store some page for each CPU as a cache.  (Each
> CPU has node_free_pages/16 pages)
> 
> It is used for page table cache.  Then, exit() increase cache, the other
> hand fork() spent it.
> 
> So, if apache type (one parent and many child model) middleware run, One
> CPU process fork(), Other CPU process the middleware work and exit().
> 
> At that time, One CPU don't have page table cache at all, Others have
> maximum caches.
> 
> 	QList_max = (#ofCPUs - 1) x Free / 16
> 	=> QList_max / (Free + QList_max) = (#ofCPUs - 1) / (16 + #ofCPUs - 1)
> 
> So, How much quicklist spent memory at maximum case?  That is #CPUs
> proposional because it is per CPU cache but cache amount calculation
> doesn't use #ofCPUs.
> 
> 	Above calculation mean
> 
> 	 Number of CPUs per node            2    4    8   16
> 	 ==============================  ====================
> 	 QList_max / (Free + QList_max)   5.8%  16%  30%  48%
> 
> 
> Wow!  Quicklist can spent about 50% memory at worst case.  More
> unfortunately, it doesn't have any cache shrinking mechanism.  So it cause
> some wrong thing.
> 
> 1. End user misunderstand to memory leak happend.
> 	=> /proc/meminfo should display amount quicklist
> 
> 2. It can cause OOM killer
> 	=> Amount of quicklists shouldn't be proportional to number of CPUs.
> 
> 
> 
> This patch:
> 
> Quicklists can consume several GB memory.  So, if end user can't see how
> much memory is used, he can fail to understand why a memory leak happend.
> 
> after this patch applied, /proc/meminfo output following.
> 
> % cat /proc/meminfo
> 
> MemTotal:        7701504 kB
> MemFree:         5159040 kB
> Buffers:          112960 kB
> Cached:           337536 kB
> SwapCached:            0 kB
> Active:           218944 kB
> Inactive:         350848 kB
> Active(anon):     120832 kB
> Inactive(anon):        0 kB
> Active(file):      98112 kB
> Inactive(file):   350848 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:       2031488 kB
> SwapFree:        2031488 kB
> Dirty:               320 kB
> Writeback:             0 kB
> AnonPages:        119488 kB
> Mapped:            38528 kB
> Slab:            1595712 kB
> SReclaimable:      23744 kB
> SUnreclaim:      1571968 kB
> PageTables:        14336 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     5882240 kB
> Committed_AS:     356672 kB
> VmallocTotal:   17592177655808 kB
> VmallocUsed:       29056 kB
> VmallocChunk:   17592177626304 kB
> Quicklists:       283776 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> HugePages_Surp:      0
> Hugepagesize:    262144 kB
> 
> [akpm@linux-foundation.org: build fix]
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/proc/proc_misc.c       |    7 +++++--
>  include/linux/quicklist.h |    7 +++++++
>  2 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff -puN fs/proc/proc_misc.c~mm-show-quicklist-memory-usage-in-proc-meminfo fs/proc/proc_misc.c
> --- a/fs/proc/proc_misc.c~mm-show-quicklist-memory-usage-in-proc-meminfo
> +++ a/fs/proc/proc_misc.c
> @@ -24,6 +24,7 @@
>  #include <linux/tty.h>
>  #include <linux/string.h>
>  #include <linux/mman.h>
> +#include <linux/quicklist.h>
>  #include <linux/proc_fs.h>
>  #include <linux/ioport.h>
>  #include <linux/mm.h>
> @@ -189,7 +190,8 @@ static int meminfo_read_proc(char *page,
>  		"Committed_AS: %8lu kB\n"
>  		"VmallocTotal: %8lu kB\n"
>  		"VmallocUsed:  %8lu kB\n"
> -		"VmallocChunk: %8lu kB\n",
> +		"VmallocChunk:   %8lu kB\n"
> +		"Quicklists:     %8lu kB\n",
>  		K(i.totalram),
>  		K(i.freeram),
>  		K(i.bufferram),
> @@ -221,7 +223,8 @@ static int meminfo_read_proc(char *page,
>  		K(committed),
>  		(unsigned long)VMALLOC_TOTAL >> 10,
>  		vmi.used >> 10,
> -		vmi.largest_chunk >> 10
> +		vmi.largest_chunk >> 10,
> +		K(quicklist_total_size())
>  		);
>  
>  		len += hugetlb_report_meminfo(page + len);
> diff -puN include/linux/quicklist.h~mm-show-quicklist-memory-usage-in-proc-meminfo include/linux/quicklist.h
> --- a/include/linux/quicklist.h~mm-show-quicklist-memory-usage-in-proc-meminfo
> +++ a/include/linux/quicklist.h
> @@ -80,6 +80,13 @@ void quicklist_trim(int nr, void (*dtor)
>  
>  unsigned long quicklist_total_size(void);
>  
> +#else
> +
> +static inline unsigned long quicklist_total_size(void)
> +{
> +	return 0;
> +}
> +
>  #endif
>  
>  #endif /* LINUX_QUICKLIST_H */
> _
> 
> 
> 
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> When a test program which does task migration runs, my 8GB box spends
> 800MB of memory for quicklist.  This is not memory leak but doesn't seem
> good.
> 
> % cat /proc/meminfo
> 
> MemTotal:        7701568 kB
> MemFree:         4724672 kB
> (snip)
> Quicklists:       844800 kB
> 
> because
> 
> - My machine spec is
> 	number of numa node: 2
> 	number of cpus:      8 (4CPU x2 node)
>         total mem:           8GB (4GB x2 node)
>         free mem:            about 5GB
> 
> - Maximum quicklist usage is here
> 
> 	 Number of CPUs per node            2    4    8   16
> 	 ==============================  ====================
> 	 QList_max / (Free + QList_max)   5.8%  16%  30%  48%
> 
> - Then, 4.7GB x 16% ~= 880MB.
>   So, Quicklist can use 800MB.
> 
> So, if following spec machine run that program
> 
>    CPUs: 64 (8cpu x 8node)
>    Mem:  1TB (128GB x8node)
> 
> Then, quicklist can waste 300GB (= 1TB x 30%).  It is too large.
> 
> So, I don't like cache policies which is proportional to # of cpus.
> 
> My patch changes the number of caches
> from:
>    per-cpu-cache-amount = memory_on_node / 16
> to
>    per-cpu-cache-amount = memory_on_node / 16 / number_of_cpus_on_node.
> 
> I think this is reasonable.  but even if this patch is applied, quicklist
> can cache tons of memory on big machine.
> 
> (Although its patch applied, quicklist can waste 64GB on 1TB server (= 1TB
> / 16), it is still too much??)
> 
> test program is below.
> --------------------------------------------------------------------------------
> #define _GNU_SOURCE
> 
> #include <stdio.h>
> #include <errno.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sched.h>
> #include <unistd.h>
> #include <sys/mman.h>
> #include <sys/wait.h>
> 
> #define BUFFSIZE 512
> 
> int max_cpu(void)	/* get max number of logical cpus from /proc/cpuinfo */
> {
>   FILE *fd;
>   char *ret, buffer[BUFFSIZE];
>   int cpu = 1;
> 
>   fd = fopen("/proc/cpuinfo", "r");
>   if (fd == NULL) {
>     perror("fopen(/proc/cpuinfo)");
>     exit(EXIT_FAILURE);
>   }
>   while (1) {
>     ret = fgets(buffer, BUFFSIZE, fd);
>     if (ret == NULL)
>       break;
>     if (!strncmp(buffer, "processor", 9))
>       cpu = atoi(strchr(buffer, ':') + 2);
>   }
>   fclose(fd);
>   return cpu;
> }
> 
> void cpu_bind(int cpu)	/* bind current process to one cpu */
> {
>   cpu_set_t mask;
>   int ret;
> 
>   CPU_ZERO(&mask);
>   CPU_SET(cpu, &mask);
>   ret = sched_setaffinity(0, sizeof(mask), &mask);
>   if (ret == -1) {
>     perror("sched_setaffinity()");
>     exit(EXIT_FAILURE);
>   }
>   sched_yield();	/* not necessary */
> }
> 
> #define MMAP_SIZE (10 * 1024 * 1024)	/* 10 MB */
> #define FORK_INTERVAL 1	/* 1 second */
> 
> main(int argc, char *argv[])
> {
>   int cpu_max, nextcpu;
>   long pagesize;
>   pid_t pid;
> 
>   /* set max number of logical cpu */
>   if (argc > 1)
>     cpu_max = atoi(argv[1]) - 1;
>   else
>     cpu_max = max_cpu();
> 
>   /* get the page size */
>   pagesize = sysconf(_SC_PAGESIZE);
>   if (pagesize == -1) {
>     perror("sysconf(_SC_PAGESIZE)");
>     exit(EXIT_FAILURE);
>   }
> 
>   /* prepare parent process */
>   cpu_bind(0);
>   nextcpu = cpu_max;
> 
> loop:
> 
>   /* select destination cpu for child process by round-robin rule */
>   if (++nextcpu > cpu_max)
>     nextcpu = 1;
> 
>   pid = fork();
> 
>   if (pid == 0) { /* child action */
> 
>     char *p;
>     int i;
> 
>     /* consume page tables */
>     p = mmap(0, MMAP_SIZE, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
>     i = MMAP_SIZE / pagesize;
>     while (i-- > 0) {
>       *p = 1;
>       p += pagesize;
>     }
> 
>     /* move to other cpu */
>     cpu_bind(nextcpu);
> /*
>     printf("a child moved to cpu%d after mmap().\n", nextcpu);
>     fflush(stdout);
>  */
> 
>     /* back page tables to pgtable_quicklist */
>     exit(0);
> 
>   } else if (pid > 0) { /* parent action */
> 
>     sleep(FORK_INTERVAL);
>     waitpid(pid, NULL, WNOHANG);
> 
>   }
> 
>   goto loop;
> }
> 
> [akpm@linux-foundation.org: fix build on sparc64]
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/quicklist.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff -puN mm/quicklist.c~mm-quicklist-shouldnt-be-proportional-to-number-of-cpus mm/quicklist.c
> --- a/mm/quicklist.c~mm-quicklist-shouldnt-be-proportional-to-number-of-cpus
> +++ a/mm/quicklist.c
> @@ -26,7 +26,9 @@ DEFINE_PER_CPU(struct quicklist, quickli
>  static unsigned long max_pages(unsigned long min_pages)
>  {
>  	unsigned long node_free_pages, max;
> -	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
> +	int node = numa_node_id();
> +	struct zone *zones = NODE_DATA(node)->node_zones;
> +	cpumask_t node_cpumask;
>  
>  	node_free_pages =
>  #ifdef CONFIG_ZONE_DMA
> @@ -38,6 +40,10 @@ static unsigned long max_pages(unsigned 
>  		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
>  
>  	max = node_free_pages / FRACTION_OF_NODE_MEM;
> +
> +	node_cpumask = node_to_cpumask(node);
> +	max /= cpus_weight_nr(node_cpumask);
> +
>  	return max(max, min_pages);
>  }
>  
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
