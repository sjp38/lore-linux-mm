Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 28ACB6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 22:11:22 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so4658080pad.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 19:11:21 -0800 (PST)
Message-ID: <50B42F32.4050107@gmail.com>
Date: Tue, 27 Nov 2012 11:10:42 +0800
From: wujianguo <wujianguo106@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 2012-11-23 18:44, Tang Chen wrote:
> [What we are doing]
> This patchset provide a boot option for user to specify ZONE_MOVABLE memory
> map for each node in the system.
> 
> movablecore_map=nn[KMG]@ss[KMG]
> 

Hi Tang,
	DMA address can't be set as movable, if some one boot kernel with
movablecore_map=4G@0xa00000 or other memory region that contains DMA address,
system maybe boot failed. Should this case be handled or mentioned
in the change log and kernel-parameters.txt?

Thanks,
Jianguo Wu

> This option make sure memory range from ss to ss+nn is movable memory.
> 
> 
> [Why we do this]
> If we hot remove a memroy, the memory cannot have kernel memory,
> because Linux cannot migrate kernel memory currently. Therefore,
> we have to guarantee that the hot removed memory has only movable
> memoroy.
> 
> Linux has two boot options, kernelcore= and movablecore=, for
> creating movable memory. These boot options can specify the amount
> of memory use as kernel or movable memory. Using them, we can
> create ZONE_MOVABLE which has only movable memory.
> 
> But it does not fulfill a requirement of memory hot remove, because
> even if we specify the boot options, movable memory is distributed
> in each node evenly. So when we want to hot remove memory which
> memory range is 0x80000000-0c0000000, we have no way to specify
> the memory as movable memory.
> 
> So we proposed a new feature which specifies memory range to use as
> movable memory.
> 
> 
> [Ways to do this]
> There may be 2 ways to specify movable memory.
>  1. use firmware information
>  2. use boot option
> 
> 1. use firmware information
>   According to ACPI spec 5.0, SRAT table has memory affinity structure
>   and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>   Affinity Structure". If we use the information, we might be able to
>   specify movable memory by firmware. For example, if Hot Pluggable
>   Filed is enabled, Linux sets the memory as movable memory.
> 
> 2. use boot option
>   This is our proposal. New boot option can specify memory range to use
>   as movable memory.
> 
> 
> [How we do this]
> We chose second way, because if we use first way, users cannot change
> memory range to use as movable memory easily. We think if we create
> movable memory, performance regression may occur by NUMA. In this case,
> user can turn off the feature easily if we prepare the boot option.
> And if we prepare the boot optino, the user can select which memory
> to use as movable memory easily. 
> 
> 
> [How to use]
> Specify the following boot option:
> movablecore_map=nn[KMG]@ss[KMG]
> 
> That means physical address range from ss to ss+nn will be allocated as
> ZONE_MOVABLE.
> 
> And the following points should be considered.
> 
> 1) If the range is involved in a single node, then from ss to the end of
>    the node will be ZONE_MOVABLE.
> 2) If the range covers two or more nodes, then from ss to the end of
>    the node will be ZONE_MOVABLE, and all the other nodes will only
>    have ZONE_MOVABLE.
> 3) If no range is in the node, then the node will have no ZONE_MOVABLE
>    unless kernelcore or movablecore is specified.
> 4) This option could be specified at most MAX_NUMNODES times.
> 5) If kernelcore or movablecore is also specified, movablecore_map will have
>    higher priority to be satisfied.
> 6) This option has no conflict with memmap option.
> 
> 
> 
> Tang Chen (4):
>   page_alloc: add movable_memmap kernel parameter
>   page_alloc: Introduce zone_movable_limit[] to keep movable limit for
>     nodes
>   page_alloc: Make movablecore_map has higher priority
>   page_alloc: Bootmem limit with movablecore_map
> 
> Yasuaki Ishimatsu (1):
>   x86: get pg_data_t's memory from other node
> 
>  Documentation/kernel-parameters.txt |   17 +++
>  arch/x86/mm/numa.c                  |   11 ++-
>  include/linux/memblock.h            |    1 +
>  include/linux/mm.h                  |   11 ++
>  mm/memblock.c                       |   15 +++-
>  mm/page_alloc.c                     |  216 ++++++++++++++++++++++++++++++++++-
>  6 files changed, 263 insertions(+), 8 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
