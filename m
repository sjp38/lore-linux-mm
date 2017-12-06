Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE426B0069
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 09:18:47 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 12so2247310vko.11
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 06:18:47 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p69si1722556vkd.156.2017.12.06.06.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 06:18:41 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v3 2/7] ktask: multithread CPU-intensive kernel work
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
 <20171205195220.28208-3-daniel.m.jordan@oracle.com>
 <20171205142102.8b53c7d6eca231b07dbf422e@linux-foundation.org>
Message-ID: <6af3aff5-8747-5276-f20a-9853321e445a@oracle.com>
Date: Wed, 6 Dec 2017 09:21:33 -0500
MIME-Version: 1.0
In-Reply-To: <20171205142102.8b53c7d6eca231b07dbf422e@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Thanks for looking at this, Andrew.  Responses below.


On 12/05/2017 05:21 PM, Andrew Morton wrote:
> On Tue,  5 Dec 2017 14:52:15 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> 
>> ktask is a generic framework for parallelizing CPU-intensive work in the
>> kernel.  The intended use is for big machines that can use their CPU power to
>> speed up large tasks that can't otherwise be multithreaded in userland.  The
>> API is generic enough to add concurrency to many different kinds of tasks--for
>> example, zeroing a range of pages or evicting a list of inodes--and aims to
>> save its clients the trouble of splitting up the work, choosing the number of
>> threads to use, maintaining an efficient concurrency level, starting these
>> threads, and load balancing the work between them.
>>
>> The Documentation patch earlier in this series has more background.
>>
>> Introduces the ktask API; consumers appear in subsequent patches.
>>
>> Based on work by Pavel Tatashin, Steve Sistare, and Jonathan Adams.
>>
>> ...
>>
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -319,6 +319,18 @@ config AUDIT_TREE
>>   	depends on AUDITSYSCALL
>>   	select FSNOTIFY
>>   
>> +config KTASK
>> +	bool "Multithread cpu-intensive kernel tasks"
>> +	depends on SMP
>> +	depends on NR_CPUS > 16
> 
> Why this?

Good question.  I picked 16 to represent a big machine, but as with most 
cutoffs it's somewhat arbitrary.

> It would make sense to relax (or eliminate) this at least for the
> development/test period, so more people actually run and test the new
> code.

Ok, that makes sense.  I'll remove it for now.

Since many (most?) distributions ship with a high NR_CPUS, maybe 
deciding whether to enable the framework at runtime based on online CPUs 
and memory is a better option.  A static branch might do it.

> 
>> +	default n
>> +	help
>> +	  Parallelize expensive kernel tasks such as zeroing huge pages.  This
>> +          feature is designed for big machines that can take advantage of their
>> +          cpu count to speed up large kernel tasks.
>> +
>> +          If unsure, say 'N'.
>> +
>>   source "kernel/irq/Kconfig"
>>   source "kernel/time/Kconfig"
>>   
>>
>> ...
>>
>> +/*
>> + * Initialize internal limits on work items queued.  Work items submitted to
>> + * cmwq capped at 80% of online cpus both system-wide and per-node to maintain
>> + * an efficient level of parallelization at these respective levels.
>> + */
>> +bool ktask_rlim_init(void)
> 
> Why not static __init?

I forgot both.  I added them, thanks.

> 
>> +{
>> +	int node;
>> +	unsigned nr_node_cpus;
>> +
>> +	spin_lock_init(&ktask_rlim_lock);
> 
> This can be done at compile time.  Unless there's a real reason for
> ktask_rlim_init to be non-static, non-__init, in which case I'm
> worried: reinitializing a static spinlock is weird.

You're right, I should have used DEFINE_SPINLOCK.  This is fixed.


The patch at the bottom covers these changes and gets rid of a mismerge 
in this patch.

Daniel


diff --git a/init/Kconfig b/init/Kconfig
index 2a7b120de4d4..28c234791819 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -322,15 +322,12 @@ config AUDIT_TREE
  config KTASK
         bool "Multithread cpu-intensive kernel tasks"
         depends on SMP
-       depends on NR_CPUS > 16
-       default n
+       default y
         help
           Parallelize expensive kernel tasks such as zeroing huge 
pages.  This
            feature is designed for big machines that can take advantage 
of their
            cpu count to speed up large kernel tasks.

-          If unsure, say 'N'.
-
  source "kernel/irq/Kconfig"
  source "kernel/time/Kconfig"

diff --git a/kernel/ktask.c b/kernel/ktask.c
index 7b075075b56b..4db38fe59bdb 100644
--- a/kernel/ktask.c
+++ b/kernel/ktask.c
@@ -29,7 +29,7 @@
  #include <linux/workqueue.h>

  /* Resource limits on the amount of workqueue items queued through 
ktask. */
-spinlock_t ktask_rlim_lock;
+static DEFINE_SPINLOCK(ktask_rlim_lock);
  /* Work items queued on all nodes (includes NUMA_NO_NODE) */
  size_t ktask_rlim_cur;
  size_t ktask_rlim_max;
@@ -382,14 +382,6 @@ int ktask_run_numa(struct ktask_node *nodes, size_t 
nr_nodes,
                 return KTASK_RETURN_SUCCESS;

         mutex_init(&kt.kt_mutex);
-
-       kt.kt_nthreads = ktask_nthreads(kt.kt_total_size,
-                                       ctl->kc_min_chunk_size,
-                                       ctl->kc_max_threads);
-
-       kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
-                                       ctl->kc_min_chunk_size, 
kt.kt_nthreads);
-
         init_completion(&kt.kt_ktask_done);

         kt.kt_nthreads = ktask_prepare_threads(nodes, nr_nodes, &kt, 
&to_queue);
@@ -449,13 +441,11 @@ EXPORT_SYMBOL_GPL(ktask_run);
   * cmwq capped at 80% of online cpus both system-wide and per-node to 
maintain
   * an efficient level of parallelization at these respective levels.
   */
-bool ktask_rlim_init(void)
+static bool __init ktask_rlim_init(void)
  {
         int node;
         unsigned nr_node_cpus;

-       spin_lock_init(&ktask_rlim_lock);
-
         ktask_rlim_node_cur = kcalloc(num_possible_nodes(),
                                                sizeof(size_t),
                                                GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
