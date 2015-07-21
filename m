Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D997D6B028B
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:36:09 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so114880837wib.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 02:36:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si18093749wiy.23.2015.07.21.02.36.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 02:36:08 -0700 (PDT)
Message-ID: <55AE1285.4010600@suse.cz>
Date: Tue, 21 Jul 2015 11:36:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [rfc] mm, thp: allow khugepaged to periodically compact memory
 synchronously
References: <alpine.DEB.2.10.1507141918340.11697@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507141918340.11697@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/15/2015 04:19 AM, David Rientjes wrote:
> We have seen a large benefit in the amount of hugepages that can be
> allocated at fault

That's understandable...

> and by khugepaged when memory is periodically
> compacted in the background.

... but for khugepaged it's surprising. Doesn't khugepaged (unlike page 
faults) attempt the same sync compaction as your manual triggers?

> We trigger synchronous memory compaction over all memory every 15 minutes
> to keep fragmentation low and to offset the lightweight compaction that
> is done at page fault to keep latency low.

I'm surprised that 15 minutes is frequent enough to make a difference. 
I'd expect it very much depends on the memory size and workload though.

> compact_sleep_millisecs controls how often khugepaged will compact all
> memory.  Each scan_sleep_millisecs wakeup after this value has expired, a
> node is synchronously compacted until all memory has been scanned.  Then,
> khugepaged will restart the process compact_sleep_millisecs later.
>
> This defaults to 0, which means no memory compaction is done.

Being another tunable and defaulting to 0 it means that most people 
won't use it at all, or their distro will provide some other value. We 
should really strive to make it self-tuning based on e.g. memory 
fragmentation statistics. But I know that my kcompactd proposal also 
wasn't quite there yet...

>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   RFC: this is for initial comment on whether it's appropriate to do this
>   in khugepaged.  We already do to the background compaction for the
>   benefit of thp, but others may feel like this belongs in a new per-node
>   kcompactd thread as proposed by Vlastimil.
>
>   Regardless, it appears there is a substantial need for periodic memory
>   compaction in the background to reduce the latency of thp page faults
>   and still have a reasonable chance of having the allocation succeed.
>
>   We could also speed up this process in the case of alloc_sleep_millisecs
>   timeout since allocation recently failed for khugepaged.
>
>   Documentation/vm/transhuge.txt | 10 +++++++
>   mm/huge_memory.c               | 65 ++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 75 insertions(+)
>
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -170,6 +170,16 @@ A lower value leads to gain less thp performance. Value of
>   max_ptes_none can waste cpu time very little, you can
>   ignore it.
>
> +/sys/kernel/mm/transparent_hugepage/khugepaged/compact_sleep_millisecs
> +
> +controls how often khugepaged will utilize memory compaction to defragment
> +memory.  This makes it easier to allocate hugepages both at page fault and
> +by khugepaged since this compaction can be synchronous.
> +
> +This only occurs if scan_sleep_millisecs is configured.  One node per
> +scan_sleep_millisecs wakeup is compacted when compact_sleep_millisecs
> +expires until all memory has been compacted.
> +
>   == Boot parameter ==
>
>   You can change the sysfs boot time defaults of Transparent Hugepage
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -23,6 +23,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/migrate.h>
>   #include <linux/hashtable.h>
> +#include <linux/compaction.h>
>
>   #include <asm/tlb.h>
>   #include <asm/pgalloc.h>
> @@ -65,6 +66,16 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>    */
>   static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
>
> +/*
> + * Khugepaged may memory compaction over all memory at regular intervals.
> + * It round-robins through all nodes, compacting one at a time each
> + * scan_sleep_millisecs wakeup when triggered.
> + * May be set with compact_sleep_millisecs, which is disabled by default.
> + */
> +static unsigned long khugepaged_compact_sleep_millisecs __read_mostly;
> +static unsigned long khugepaged_compact_jiffies;
> +static int next_compact_node = MAX_NUMNODES;
> +
>   static int khugepaged(void *none);
>   static int khugepaged_slab_init(void);
>   static void khugepaged_slab_exit(void);
> @@ -463,6 +474,34 @@ static struct kobj_attribute alloc_sleep_millisecs_attr =
>   	__ATTR(alloc_sleep_millisecs, 0644, alloc_sleep_millisecs_show,
>   	       alloc_sleep_millisecs_store);
>
> +static ssize_t compact_sleep_millisecs_show(struct kobject *kobj,
> +					    struct kobj_attribute *attr,
> +					    char *buf)
> +{
> +	return sprintf(buf, "%lu\n", khugepaged_compact_sleep_millisecs);
> +}
> +
> +static ssize_t compact_sleep_millisecs_store(struct kobject *kobj,
> +					     struct kobj_attribute *attr,
> +					     const char *buf, size_t count)
> +{
> +	unsigned long msecs;
> +	int err;
> +
> +	err = kstrtoul(buf, 10, &msecs);
> +	if (err || msecs > ULONG_MAX)
> +		return -EINVAL;
> +
> +	khugepaged_compact_sleep_millisecs = msecs;
> +	khugepaged_compact_jiffies = jiffies + msecs_to_jiffies(msecs);
> +	wake_up_interruptible(&khugepaged_wait);
> +
> +	return count;
> +}
> +static struct kobj_attribute compact_sleep_millisecs_attr =
> +	__ATTR(compact_sleep_millisecs, 0644, compact_sleep_millisecs_show,
> +	       compact_sleep_millisecs_store);
> +
>   static ssize_t pages_to_scan_show(struct kobject *kobj,
>   				  struct kobj_attribute *attr,
>   				  char *buf)
> @@ -564,6 +603,7 @@ static struct attribute *khugepaged_attr[] = {
>   	&full_scans_attr.attr,
>   	&scan_sleep_millisecs_attr.attr,
>   	&alloc_sleep_millisecs_attr.attr,
> +	&compact_sleep_millisecs_attr.attr,
>   	NULL,
>   };
>
> @@ -652,6 +692,10 @@ static int __init hugepage_init(void)
>   		return 0;
>   	}
>
> +	if (khugepaged_compact_sleep_millisecs)
> +		khugepaged_compact_jiffies = jiffies +
> +			msecs_to_jiffies(khugepaged_compact_sleep_millisecs);
> +
>   	err = start_stop_khugepaged();
>   	if (err)
>   		goto err_khugepaged;
> @@ -2834,6 +2878,26 @@ static void khugepaged_wait_work(void)
>   		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
>   }
>
> +static void khugepaged_compact_memory(void)
> +{
> +	if (!khugepaged_compact_jiffies ||
> +	    time_before(jiffies, khugepaged_compact_jiffies))
> +		return;
> +
> +	get_online_mems();
> +	if (next_compact_node == MAX_NUMNODES)
> +		next_compact_node = first_node(node_states[N_MEMORY]);
> +
> +	compact_pgdat(NODE_DATA(next_compact_node), -1);
> +
> +	next_compact_node = next_node(next_compact_node, node_states[N_MEMORY]);
> +	put_online_mems();
> +
> +	if (next_compact_node == MAX_NUMNODES)
> +		khugepaged_compact_jiffies = jiffies +
> +			msecs_to_jiffies(khugepaged_compact_sleep_millisecs);
> +}
> +
>   static int khugepaged(void *none)
>   {
>   	struct mm_slot *mm_slot;
> @@ -2842,6 +2906,7 @@ static int khugepaged(void *none)
>   	set_user_nice(current, MAX_NICE);
>
>   	while (!kthread_should_stop()) {
> +		khugepaged_compact_memory();
>   		khugepaged_do_scan();
>   		khugepaged_wait_work();
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
