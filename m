Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2256B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:04:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so244477108pfb.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:04:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a96si29932100pli.200.2016.11.28.22.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 22:04:08 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAT648fT052099
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:04:08 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271367uxr7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:04:00 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 29 Nov 2016 16:03:50 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5DD2F2CE8057
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:03:48 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAT63mhu54853780
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:03:48 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAT63lcq008488
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:03:48 +1100
Subject: Re: [PATCH 3/5] migrate: Add copy_page_mt to use multi-threaded page
 migration.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-4-zi.yan@sent.com> <5836B25E.7040100@linux.vnet.ibm.com>
 <F3961404-1642-4E52-9967-BE03303D8E58@cs.rutgers.edu>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 29 Nov 2016 11:33:45 +0530
MIME-Version: 1.0
In-Reply-To: <F3961404-1642-4E52-9967-BE03303D8E58@cs.rutgers.edu>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <583D1A41.7020209@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com

On 11/28/2016 08:33 PM, Zi Yan wrote:
> On 24 Nov 2016, at 4:26, Anshuman Khandual wrote:
> 
>> On 11/22/2016 09:55 PM, Zi Yan wrote:
>>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>>
>>> From: Zi Yan <ziy@nvidia.com>
>>
>> Please fix these.
>>
>>>
>>> Internally, copy_page_mt splits a page into multiple threads
>>> and send them as jobs to system_highpri_wq.
>>
>> The function should be renamed as copy_page_multithread() or at
>> the least copy_page_mthread() to make more sense. The commit
>> message needs to more comprehensive and detailed.
>>
> 
> Sure.
> 
>>>
>>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>>> ---
>>>  include/linux/highmem.h |  2 ++
>>>  kernel/sysctl.c         |  1 +
>>>  mm/Makefile             |  2 ++
>>>  mm/copy_page.c          | 96 +++++++++++++++++++++++++++++++++++++++++++++++++
>>>  4 files changed, 101 insertions(+)
>>>  create mode 100644 mm/copy_page.c
>>>
>>> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
>>> index bb3f329..519e575 100644
>>> --- a/include/linux/highmem.h
>>> +++ b/include/linux/highmem.h
>>> @@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
>>>
>>>  #endif
>>>
>>> +int copy_page_mt(struct page *to, struct page *from, int nr_pages);
>>> +
>>>  static inline void copy_highpage(struct page *to, struct page *from)
>>>  {
>>>  	char *vfrom, *vto;
>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>> index 706309f..d54ce12 100644
>>> --- a/kernel/sysctl.c
>>> +++ b/kernel/sysctl.c
>>> @@ -97,6 +97,7 @@
>>>
>>>  #if defined(CONFIG_SYSCTL)
>>>
>>> +
>>
>> I guess this is a stray code change.
>>
>>>  /* External variables not in a header file. */
>>>  extern int suid_dumpable;
>>>  #ifdef CONFIG_COREDUMP
>>> diff --git a/mm/Makefile b/mm/Makefile
>>> index 295bd7a..467305b 100644
>>> --- a/mm/Makefile
>>> +++ b/mm/Makefile
>>> @@ -41,6 +41,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
>>>
>>>  obj-y += init-mm.o
>>>
>>> +obj-y += copy_page.o
>>
>> Its getting compiled all the time. Dont you want to make it part of
>> of a new config option which will cover for all these code for multi
>> thread copy ?
> 
> I can do that.
> 
>>> +
>>>  ifdef CONFIG_NO_BOOTMEM
>>>  	obj-y		+= nobootmem.o
>>>  else
>>> diff --git a/mm/copy_page.c b/mm/copy_page.c
>>> new file mode 100644
>>> index 0000000..ca7ce6c
>>> --- /dev/null
>>> +++ b/mm/copy_page.c
>>> @@ -0,0 +1,96 @@
>>> +/*
>>> + * Parallel page copy routine.
>>> + *
>>> + * Zi Yan <ziy@nvidia.com>
>>> + *
>>> + */
>>
>> No, this is too less. Please see other files inside mm directory as
>> example.
>>
> 
> Sure, I will add more description here.
> 
>>> +
>>> +#include <linux/highmem.h>
>>> +#include <linux/workqueue.h>
>>> +#include <linux/slab.h>
>>> +#include <linux/freezer.h>
>>> +
>>> +
>>> +const unsigned int limit_mt_num = 4;
>>
>> From where this number 4 came from ? At the very least it should be
>> configured from either a sysctl variable or from a sysfs file, so
>> that user will have control on number of threads used for copy. But
>> going forward this should be derived out a arch specific call back
>> which then analyzes NUMA topology and scheduler loads to figure out
>> on how many threads should be used for optimum performance of page
>> copy.
> 
> I will expose this to sysctl.

When you do, if the user specifies a number, take it after some basic
sanity checks but if the user specifies "default" then we should fall
back to arch specific call back to figure out how many of them should
be used.
 
> 
> For finding optimum performance, can we do a boot time microbenchmark
> to find the thread number?

Hmm, not sure that much of measurement is required. I wonder any other
part of kernel does this kind of thing ? Arch call back should be able
to tell you based on already established facts. IMHO that should be
enough.

> 
> For scheduler loads, can we traverse all online CPUs and use idle CPUs
> by checking idle_cpu()?

Arch call back should return a nodemask pointing out exactly which CPUs
should be used for the copy purpose. The nodemask should be calculated
based on established facts of multi threaded performance, NUMA affinity
(based on source and destination pages we are trying to migrate) and
scheduler run queue states. But this function has to be fast enough
without eating into the benefits of multi threaded copy. idle_cpu()
check should be a very good starting point.

> 
> 
>>> +
>>> +/* ======================== multi-threaded copy page ======================== */
>>> +
>>
>> Please use standard exported function description semantics while
>> describing this new function. I think its a good function to be
>> exported as a symbol as well.
>>
>>> +struct copy_page_info {
>>
>> s/copy_page_info/mthread_copy_struct/
>>
>>> +	struct work_struct copy_page_work;
>>> +	char *to;
>>> +	char *from;
>>
>> Swap the order of 'to' and 'from'.
>>
>>> +	unsigned long chunk_size;
>>
>> Just 'size' should be fine.
>>
>>> +};
>>> +
>>> +static void copy_page_routine(char *vto, char *vfrom,
>>
>> s/copy_page_routine/mthread_copy_fn/
>>
>>> +	unsigned long chunk_size)
>>> +{
>>> +	memcpy(vto, vfrom, chunk_size);
>>> +}
>>
>> s/chunk_size/size/
>>
>>
> 
> Will do the suggested changes in the next version.
> 
>>> +
>>> +static void copy_page_work_queue_thread(struct work_struct *work)
>>> +{
>>> +	struct copy_page_info *my_work = (struct copy_page_info *)work;
>>> +
>>> +	copy_page_routine(my_work->to,
>>> +					  my_work->from,
>>> +					  my_work->chunk_size);
>>> +}
>>> +
>>> +int copy_page_mt(struct page *to, struct page *from, int nr_pages)
>>> +{
>>> +	unsigned int total_mt_num = limit_mt_num;
>>> +	int to_node = page_to_nid(to);
>>
>> Should we make sure that the entire page range [to, to + nr_pages] is
>> part of to_node.
>>
> 
> Currently, this is only used for huge pages. nr_pages = hpage_nr_pages().
> This guarantees the entire page range in the same node.

In that case WARN_ON() if both source and destination pages are not huge.

> 
>>> +	int i;
>>> +	struct copy_page_info *work_items;
>>> +	char *vto, *vfrom;
>>> +	unsigned long chunk_size;
>>> +	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
>>
>> So all the threads used for copy has to be part of cpumask of the
>> destination node ? Why ? The copy accesses both the source pages as
>> well as destination pages. Source node threads might also perform
>> good for the memory accesses. Which and how many threads should be
>> used for copy should be decided wisely from an architecture call
>> back. On a NUMA system this will have impact on performance of the
>> multi threaded copy.
> 
> This is based on my copy throughput benchmark results. The results
> shows that moving data from the remote node to the local node (pulling)
> has higher throughput than moving data from the local node to the remote node (pushing).
> 
> I got the same results from both Intel Xeon and IBM Power8, but
> it might not be the case for other machines.
> 
> Ideally, we can do a boot time benchmark to find out the best configuration,
> like pulling or pushing the data, how many threads. But for this
> patchset, I may choose pulling the data.

Right but again it should be decided by the arch call back.

> 
> 
>>
>>
>>> +	int cpu_id_list[32] = {0};
>>> +	int cpu;
>>> +
>>> +	total_mt_num = min_t(unsigned int, total_mt_num,
>>> +						 cpumask_weight(per_node_cpumask));
>>> +	total_mt_num = (total_mt_num / 2) * 2;
>>> +
>>> +	work_items = kcalloc(total_mt_num, sizeof(struct copy_page_info),
>>> +						 GFP_KERNEL);
>>> +	if (!work_items)
>>> +		return -ENOMEM;
>>> +
>>> +	i = 0;
>>> +	for_each_cpu(cpu, per_node_cpumask) {
>>> +		if (i >= total_mt_num)
>>> +			break;
>>> +		cpu_id_list[i] = cpu;
>>> +		++i;
>>> +	}
>>> +
>>> +	vfrom = kmap(from);
>>> +	vto = kmap(to);
>>> +	chunk_size = PAGE_SIZE*nr_pages / total_mt_num;
>>
>> Coding style ? Please run all these patches though scripts/
>> checkpatch.pl script to catch coding style problems.
>>
>>> +
>>> +	for (i = 0; i < total_mt_num; ++i) {
>>> +		INIT_WORK((struct work_struct *)&work_items[i],
>>> +				  copy_page_work_queue_thread);
>>> +
>>> +		work_items[i].to = vto + i * chunk_size;
>>> +		work_items[i].from = vfrom + i * chunk_size;
>>> +		work_items[i].chunk_size = chunk_size;
>>> +
>>> +		queue_work_on(cpu_id_list[i],
>>> +					  system_highpri_wq,
>>> +					  (struct work_struct *)&work_items[i]);
>>
>> I am not very familiar with the system work queues but is
>> system_highpri_wq has the highest priority ? Because if
>> the time spend waiting on these work queue functions to
>> execute increases it can offset out all the benefits we
>> get by this multi threaded copy.
> 
> According to include/linux/workqueue.h, system_highpri_wq has
> high priority.
> 
> Another option is to create a dedicated workqueue for all
> copy jobs.

Not sure, will have to check on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
