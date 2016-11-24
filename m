Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2746B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:27:10 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so90409065pgc.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:27:10 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g28si38445915pfk.140.2016.11.24.01.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 01:27:09 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAO9OOtN023705
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:27:08 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26wuabe4ft-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:27:08 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 19:27:05 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E03AD2BB005C
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:27:02 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAO9R2fe54591518
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:27:02 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAO9R2O9006311
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:27:02 +1100
Subject: Re: [PATCH 3/5] migrate: Add copy_page_mt to use multi-threaded page
 migration.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-4-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 14:56:54 +0530
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-4-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5836B25E.7040100@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/22/2016 09:55 PM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>

Please fix these.

> 
> Internally, copy_page_mt splits a page into multiple threads
> and send them as jobs to system_highpri_wq.

The function should be renamed as copy_page_multithread() or at
the least copy_page_mthread() to make more sense. The commit
message needs to more comprehensive and detailed.

> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  include/linux/highmem.h |  2 ++
>  kernel/sysctl.c         |  1 +
>  mm/Makefile             |  2 ++
>  mm/copy_page.c          | 96 +++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 101 insertions(+)
>  create mode 100644 mm/copy_page.c
> 
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index bb3f329..519e575 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
> 
>  #endif
> 
> +int copy_page_mt(struct page *to, struct page *from, int nr_pages);
> +
>  static inline void copy_highpage(struct page *to, struct page *from)
>  {
>  	char *vfrom, *vto;
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 706309f..d54ce12 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -97,6 +97,7 @@
> 
>  #if defined(CONFIG_SYSCTL)
> 
> +

I guess this is a stray code change.

>  /* External variables not in a header file. */
>  extern int suid_dumpable;
>  #ifdef CONFIG_COREDUMP
> diff --git a/mm/Makefile b/mm/Makefile
> index 295bd7a..467305b 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -41,6 +41,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
> 
>  obj-y += init-mm.o
> 
> +obj-y += copy_page.o

Its getting compiled all the time. Dont you want to make it part of
of a new config option which will cover for all these code for multi
thread copy ?

> +
>  ifdef CONFIG_NO_BOOTMEM
>  	obj-y		+= nobootmem.o
>  else
> diff --git a/mm/copy_page.c b/mm/copy_page.c
> new file mode 100644
> index 0000000..ca7ce6c
> --- /dev/null
> +++ b/mm/copy_page.c
> @@ -0,0 +1,96 @@
> +/*
> + * Parallel page copy routine.
> + *
> + * Zi Yan <ziy@nvidia.com>
> + *
> + */

No, this is too less. Please see other files inside mm directory as
example. 

> +
> +#include <linux/highmem.h>
> +#include <linux/workqueue.h>
> +#include <linux/slab.h>
> +#include <linux/freezer.h>
> +
> +
> +const unsigned int limit_mt_num = 4;

>From where this number 4 came from ? At the very least it should be
configured from either a sysctl variable or from a sysfs file, so
that user will have control on number of threads used for copy. But
going forward this should be derived out a arch specific call back
which then analyzes NUMA topology and scheduler loads to figure out
on how many threads should be used for optimum performance of page
copy.

> +
> +/* ======================== multi-threaded copy page ======================== */
> +

Please use standard exported function description semantics while
describing this new function. I think its a good function to be
exported as a symbol as well.

> +struct copy_page_info {

s/copy_page_info/mthread_copy_struct/

> +	struct work_struct copy_page_work;
> +	char *to;
> +	char *from;

Swap the order of 'to' and 'from'.

> +	unsigned long chunk_size;

Just 'size' should be fine.

> +};
> +
> +static void copy_page_routine(char *vto, char *vfrom,

s/copy_page_routine/mthread_copy_fn/

> +	unsigned long chunk_size)
> +{
> +	memcpy(vto, vfrom, chunk_size);
> +}

s/chunk_size/size/


> +
> +static void copy_page_work_queue_thread(struct work_struct *work)
> +{
> +	struct copy_page_info *my_work = (struct copy_page_info *)work;
> +
> +	copy_page_routine(my_work->to,
> +					  my_work->from,
> +					  my_work->chunk_size);
> +}
> +
> +int copy_page_mt(struct page *to, struct page *from, int nr_pages)
> +{
> +	unsigned int total_mt_num = limit_mt_num;
> +	int to_node = page_to_nid(to);

Should we make sure that the entire page range [to, to + nr_pages] is
part of to_node.

> +	int i;
> +	struct copy_page_info *work_items;
> +	char *vto, *vfrom;
> +	unsigned long chunk_size;
> +	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);

So all the threads used for copy has to be part of cpumask of the
destination node ? Why ? The copy accesses both the source pages as
well as destination pages. Source node threads might also perform
good for the memory accesses. Which and how many threads should be
used for copy should be decided wisely from an architecture call
back. On a NUMA system this will have impact on performance of the
multi threaded copy.


> +	int cpu_id_list[32] = {0};
> +	int cpu;
> +
> +	total_mt_num = min_t(unsigned int, total_mt_num,
> +						 cpumask_weight(per_node_cpumask));
> +	total_mt_num = (total_mt_num / 2) * 2;
> +
> +	work_items = kcalloc(total_mt_num, sizeof(struct copy_page_info),
> +						 GFP_KERNEL);
> +	if (!work_items)
> +		return -ENOMEM;
> +
> +	i = 0;
> +	for_each_cpu(cpu, per_node_cpumask) {
> +		if (i >= total_mt_num)
> +			break;
> +		cpu_id_list[i] = cpu;
> +		++i;
> +	}
> +
> +	vfrom = kmap(from);
> +	vto = kmap(to);
> +	chunk_size = PAGE_SIZE*nr_pages / total_mt_num;

Coding style ? Please run all these patches though scripts/
checkpatch.pl script to catch coding style problems.

> +
> +	for (i = 0; i < total_mt_num; ++i) {
> +		INIT_WORK((struct work_struct *)&work_items[i],
> +				  copy_page_work_queue_thread);
> +
> +		work_items[i].to = vto + i * chunk_size;
> +		work_items[i].from = vfrom + i * chunk_size;
> +		work_items[i].chunk_size = chunk_size;
> +
> +		queue_work_on(cpu_id_list[i],
> +					  system_highpri_wq,
> +					  (struct work_struct *)&work_items[i]);

I am not very familiar with the system work queues but is
system_highpri_wq has the highest priority ? Because if
the time spend waiting on these work queue functions to
execute increases it can offset out all the benefits we
get by this multi threaded copy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
