Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE156B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 02:59:40 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so126069327pac.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 23:59:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g7si7603173pat.101.2015.08.17.23.59.39
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 23:59:39 -0700 (PDT)
Subject: Re: [Patch V3 9/9] mm, x86: Enable memoryless node support to better
 support CPU/memory hotplug
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com>
 <55D2CC76.4020100@cn.fujitsu.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55D2D7C2.3090109@linux.intel.com>
Date: Tue, 18 Aug 2015 14:59:14 +0800
MIME-Version: 1.0
In-Reply-To: <55D2CC76.4020100@cn.fujitsu.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, "=?UTF-8?Q?Jan_H._Sch=c3=b6nherr?=" <jschoenh@amazon.de>, Igor Mammedov <imammedo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Luiz Capitulino <lcapitulino@redhat.com>, Dave Young <dyoung@redhat.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-pm@vger.kernel.org

On 2015/8/18 14:11, Tang Chen wrote:
> 
> Hi Liu,
> 
> On 08/17/2015 11:19 AM, Jiang Liu wrote:
......
>> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>> index 08860bdf5744..f2a4e23bd14d 100644
>> --- a/arch/x86/mm/numa.c
>> +++ b/arch/x86/mm/numa.c
>> @@ -22,6 +22,7 @@
>>     int __initdata numa_off;
>>   nodemask_t numa_nodes_parsed __initdata;
>> +static nodemask_t numa_nodes_empty __initdata;
>>     struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
>>   EXPORT_SYMBOL(node_data);
>> @@ -560,17 +561,16 @@ static int __init numa_register_memblks(struct
>> numa_meminfo *mi)
>>               end = max(mi->blk[i].end, end);
>>           }
>>   -        if (start >= end)
>> -            continue;
>> -
>>           /*
>>            * Don't confuse VM with a node that doesn't have the
>>            * minimum amount of memory:
>>            */
>> -        if (end && (end - start) < NODE_MIN_SIZE)
>> -            continue;
>> -
>> -        alloc_node_data(nid);
>> +        if (start < end && (end - start) >= NODE_MIN_SIZE) {
>> +            alloc_node_data(nid);
>> +        } else if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
>> +            alloc_node_data(nid);
>> +            node_set(nid, numa_nodes_empty);
> 
> Seeing from here, I think numa_nodes_empty represents all memory-less
> nodes.
> So, since we still have cpu-less nodes out there, shall we rename it to
> numa_nodes_memoryless or something similar ?
> 
> And BTW, does x86 support cpu-less node after these patches ?
> 
> Since I don't have any memory-less or cpu-less node on my box, I cannot
> tell it clearly.
> A node is brought online when is has memory in original kernel. So I
> think it is supported.
Hi Chen,
	Thanks for review. With current Intel processor, there's no
hardware configurations for CPU-less NUMA node. From the code itself,
I think CPU-less node is supported. So we could fake CPU-less node
by "maxcpus" kernel parameter. For example, when "maxcpus=2" is
specified on my system, we get following NUMA topology. Among which,
node 2 is CPU-less node with memory.

root@bkd04sdp:~# numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1
node 0 size: 15954 MB
node 0 free: 15686 MB
node 1 cpus:
node 1 size: 0 MB
node 1 free: 0 MB
node 2 cpus:
node 2 size: 16113 MB
node 2 free: 16058 MB
node distances:
node   0   1   2
  0:  10  21  21
  1:  21  10  21
  2:  21  21  10


>> +        }
...
>>       }
>> @@ -739,6 +746,22 @@ void __init init_cpu_to_node(void)
>>           if (!node_online(node))
>>               node = find_near_online_node(node);
>>           numa_set_node(cpu, node);
> 
> So, CPUs are still mapped to online near node, right ?
> 
> I was expecting CPUs on a memory-less node are mapped to the node they
> belong to. If so, the current memory allocator may fail because they assume
> each online node has memory. I was trying to do this in my patch.
> 
> https://lkml.org/lkml/2015/7/7/205
> 
> Of course, my patch is not to support memory-less node, just run into
> this problem.
We have two sets of interfaces to figure out NUMA node associated with
a CPU.
1) numa_node_id()/cpu_to_node() return the NUMA node associated with
   the CPU, no matter whether there's memory associated with the node.
2) numa_mem_id()/cpu_to_mem() return the NUMA node the CPU should
   allocate memory from.

> 
>> +        if (node_spanned_pages(node))
>> +            set_cpu_numa_mem(cpu, node);
>> +        if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
>> +            node_clear(node, numa_nodes_empty);
> 
> And since we are supporting memory-less node, it's better to provide a
> for_each_memoryless_node() wrapper.
> 
>> +    }
>> +
>> +    /* Destroy empty nodes */
>> +    if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
>> +        int nid;
>> +        const size_t nd_size = roundup(sizeof(pg_data_t), PAGE_SIZE);
>> +
>> +        for_each_node_mask(nid, numa_nodes_empty) {
>> +            node_set_offline(nid);
>> +            memblock_free(__pa(node_data[nid]), nd_size);
>> +            node_data[nid] = NULL;
> 
> So, memory-less nodes are set offline finally. It's a little different
> from what I thought.
> I was expecting that both memory-less and cpu-less nodes could also be
> online after
> this patch, which would be very helpful to me.
> 
> But actually, they are just exist temporarily, used to set _numa_mem_ so
> that cpu_to_mem()
> is able to work, right ?

No. We have removed NUMA node w/ CPU but w/o memory from the
numa_nodes_empty set. So here we only remove NUMA node without
CPU and memory.
> +        if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
> +            node_clear(node, numa_nodes_empty);

Please refer to the example below, which has memoryless node (node 1).
root@bkd04sdp:~# numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 45 46 47 48 49 50 51 52
53 54 55 56 57 58 59
node 0 size: 15954 MB
node 0 free: 15584 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 60 61 62 63 64
65 66 67 68 69 70 71 72 73 74
node 1 size: 0 MB
node 1 free: 0 MB
node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 75 76 77 78 79
80 81 82 83 84 85 86 87 88 89
node 2 size: 16113 MB
node 2 free: 15802 MB
node distances:
node   0   1   2
  0:  10  21  21
  1:  21  10  21
  2:  21  21  10
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
