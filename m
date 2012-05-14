Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 135D88D000B
	for <linux-mm@kvack.org>; Mon, 14 May 2012 08:01:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id ACFE43EE0AE
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:01:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9294945DE50
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:01:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7811745DD74
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:01:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0281DB803E
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:01:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 196781DB802C
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:01:08 +0900 (JST)
Message-ID: <4FB0F423.10907@jp.fujitsu.com>
Date: Mon, 14 May 2012 21:01:39 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory: add kernelcore_max_addr boot option
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com>
In-Reply-To: <4FB0F174.1000400@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Lai,

2012/05/14 20:50, Yasuaki Ishimatsu wrote:
> Hi Lai,
>
> Your patch does not consider allocated memory from memblock.
> Thus even if I set the kernelcore_max_addr boot option, movable
> node cannot be created.
>
> I made sample patches that limited the memory from memblock.
>
> [Patch 1/4] x86: get pg_data_t's memory from other node
> [Patch 2/4] x86: use memblock_set_current_limit() to set memblock.current_limit
> [Patch 3/4] memblock: limit memory address from memblock
> [Patch 4/4] memblock: compare current_limit with end variable at memblock_find_in_range_node()
>
> System seems to be able to create movable node by applying these
> patches.
>

> But there are two problems.
> - When online memory of movable zone is under 512MB by offlining
> memory, system cannot create new process.
> - When all memory of movable zone is offlined, "kernel BUG at
> mm/slub.c:3587!" message is shown.

There are typos.
s/zone/node/

Thanks,
Yasuaki Ishimatsu

> I have not understood the root cause of the problems.
>
> Thanks,
> Yasuaki Ishimatsu
>
> 2012/05/11 14:46, Lai Jiangshan wrote:
>> Current ZONE_MOVABLE (kernelcore=) setting policy with boot option doesn't meet
>> our requirement. We need something like kernelcore_max_addr= boot option
>> to limit the kernelcore upper address.
>>
>> The memory with higher address will be migratable(movable) and they
>> are easier to be offline(always ready to be offline when the system don't require
>> so much memory).
>>
>> All kernelcore_max_addr=, kernelcore= and movablecore= can be safely specified
>> at the same time(or any 2 of them).
>>
>> Signed-off-by: Lai Jiangshan<laijs@cn.fujitsu.com>
>> ---
>> Documentation/kernel-parameters.txt | 9 +++++++++
>> mm/page_alloc.c | 27 ++++++++++++++++++++++++++-
>> 2 files changed, 35 insertions(+), 1 deletions(-)
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index c1601e5..9f42787 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -1184,6 +1184,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>> use the HighMem zone if it exists, and the Normal
>> zone if it does not.
>>
>> + kernelcore_max_addr=nn[KMG] [KNL,X86,IA-64,PPC] This parameter
>> + is the same effect as kernelcore parameter, except it
>> + specifies the up physical address of memory range
>> + usable by the kernel for non-movable allocations.
>> + If both kernelcore and kernelcore_max_addr are
>> + specified, this requested's priority is higher than
>> + kernelcore's.
>> + See the kernelcore parameter.
>> +
>> kgdbdbgp= [KGDB,HW] kgdb over EHCI usb debug port.
>> Format:<Controller#>[,poll interval]
>> The controller # is the number of the ehci usb debug
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a712fb9..9169ea9 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -200,6 +200,7 @@ static unsigned long __meminitdata dma_reserve;
>> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>> static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
>> static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>> +static unsigned long __initdata required_kernelcore_max_pfn;
>> static unsigned long __initdata required_kernelcore;
>> static unsigned long __initdata required_movablecore;
>> static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
>> @@ -4568,6 +4569,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>> {
>> int i, nid;
>> unsigned long usable_startpfn;
>> + unsigned long kernelcore_max_pfn;
>> unsigned long kernelcore_node, kernelcore_remaining;
>> /* save the state before borrow the nodemask */
>> nodemask_t saved_node_state = node_states[N_HIGH_MEMORY];
>> @@ -4596,6 +4598,9 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>> required_kernelcore = max(required_kernelcore, corepages);
>> }
>>
>> + if (required_kernelcore_max_pfn&& !required_kernelcore)
>> + required_kernelcore = totalpages;
>> +
>> /* If kernelcore was not specified, there is no ZONE_MOVABLE */
>> if (!required_kernelcore)
>> goto out;
>> @@ -4604,6 +4609,12 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>> find_usable_zone_for_movable();
>> usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
>>
>> + if (required_kernelcore_max_pfn)
>> + kernelcore_max_pfn = required_kernelcore_max_pfn;
>> + else
>> + kernelcore_max_pfn = ULONG_MAX>> PAGE_SHIFT;
>> + kernelcore_max_pfn = max(kernelcore_max_pfn, usable_startpfn);
>> +
>> restart:
>> /* Spread kernelcore memory as evenly as possible throughout nodes */
>> kernelcore_node = required_kernelcore / usable_nodes;
>> @@ -4630,8 +4641,12 @@ restart:
>> unsigned long size_pages;
>>
>> start_pfn = max(start_pfn, zone_movable_pfn[nid]);
>> - if (start_pfn>= end_pfn)
>> + end_pfn = min(kernelcore_max_pfn, end_pfn);
>> + if (start_pfn>= end_pfn) {
>> + if (!zone_movable_pfn[nid])
>> + zone_movable_pfn[nid] = start_pfn;
>> continue;
>> + }
>>
>> /* Account for what is only usable for kernelcore */
>> if (start_pfn< usable_startpfn) {
>> @@ -4816,6 +4831,15 @@ static int __init cmdline_parse_core(char *p, unsigned long *core)
>> }
>>
>> /*
>> + * kernelcore_max_addr=addr sets the up physical address of memory range
>> + * for use for allocations that cannot be reclaimed or migrated.
>> + */
>> +static int __init cmdline_parse_kernelcore_max_addr(char *p)
>> +{
>> + return cmdline_parse_core(p,&required_kernelcore_max_pfn);
>> +}
>> +
>> +/*
>> * kernelcore=size sets the amount of memory for use for allocations that
>> * cannot be reclaimed or migrated.
>> */
>> @@ -4833,6 +4857,7 @@ static int __init cmdline_parse_movablecore(char *p)
>> return cmdline_parse_core(p,&required_movablecore);
>> }
>>
>> +early_param("kernelcore_max_addr", cmdline_parse_kernelcore_max_addr);
>> early_param("kernelcore", cmdline_parse_kernelcore);
>> early_param("movablecore", cmdline_parse_movablecore);
>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org"> email@kvack.org</a>
>>
>>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
