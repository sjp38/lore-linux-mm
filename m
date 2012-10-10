Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 759236B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 03:54:35 -0400 (EDT)
Message-ID: <50752B07.5050007@cn.fujitsu.com>
Date: Wed, 10 Oct 2012 16:00:07 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: hot-added cpu is not asiggned to the correct node
References: <50501E97.2020200@jp.fujitsu.com>
In-Reply-To: <50501E97.2020200@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Minchan Kim <minchan@kernel.org>

At 09/12/2012 01:33 PM, Yasuaki Ishimatsu Wrote:
> When I hot-added CPUs and memories simultaneously using container driver,
> all the hot-added CPUs were mistakenly assigned to node0.

The reason is that we don't online the node when the cpu is hotadded.

In current kernel, we online a node when:
1. a cpu on the node is onlined(not hotadded)
2. a memory on the node is hotadded

I don't know why we don't online the node when a cpu is hotadded.
I think it is better to online the node when a cpu is hotadded, and
it can fix this problem.

Thanks
Wen Congyang

> 
> Accoding to my DSDT, hot-added CPUs and memorys have PXM#1. So in my system,
> these devices should be assigned to node1 as follows:
> 
> --- Expected result
> ls /sys/devices/system/node/node1/:
> cpu16 cpu17 cpu18 cpu19 cpu20 cpu21 cpu22 cpu23 cpu24 cpu25 cpu26 cpu27
> cpu28 cpu29 cpu30 cpu31 cpulist ... memory512 memory513 - 767 meminfo ...
> 
> => hot-added CPUs and memorys are assigned to same node.
> ---
> 
> But in actuality, the CPUs were assigned to node0 and the memorys were assigned
> to node1 as follows:
> 
> --- Actual result
> ls /sys/devices/system/node/node0/:
> cpu0 cpu1 cpu2 cpu3 cpu4 cpu5 cpu6 cpu7 cpu8 cpu9 cpu10 cpu11 cpu12 cpu13
> cpu14 cpu15 cpu16 cpu17 cpu18 cpu19 cpu20 cpu21 cpu22 cpu23 cpu24 cpu25 cpu26
> cpu27 cpu28 cpu29 cpu30 cpu31 cpulist ... memory1 memory2 - 255 meminfo ...
> 
> ls /sys/devices/system/node/node1/:
> cpulist memory512 memory513 - 767 meminfo ...
> 
> => hot-added CPUs are assinged to node0 and hot-added memorys are assigned to
>    node1. CPUs and memorys has same PXM#. But assigned node is different.
> ---
> 
> In my investigation, "acpi_map_cpu2node()" causes the problem.
> 
> ---
> #arch/x86/kernel/acpi/boot.c"
> static void __cpuinit acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  {
>  #ifdef CONFIG_ACPI_NUMA
>    int nid;
> 
>    nid = acpi_get_node(handle);
>    if (nid == -1 || !node_online(nid))
>            return;
>    set_apicid_to_node(physid, nid);
>    numa_set_node(cpu, nid);
>  #endif
>  }
> ---
> 
> In my DSDT, CPUs were written ahead of memories, so CPUs were hot-added
> before memories. Thus the system has memory-less-node temporarily .
> In this case, "node_online()" fails. So the CPU is assigned to node 0.
> 
> When I wrote memories ahead of CPUs in DSDT, the CPUs were assigned to the
> correct node. In current Linux, the CPUs were assigned to the correct node
> or not depends on the order of hot-added resources in DSDT.
> 
> ACPI specification doesn't define the order of hot-added resources. So I think
> the kernel should properly handle any DSDT conformable to its specification.
> 
> I'm thinking a solution about the problem, but I don't have any good idea...
> Does anyone has opinion how we should treat it?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
