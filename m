Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 944A46B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:03:01 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1989E3EE0BD
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:03:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 02F792AFD7C
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:03:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFCD41EF083
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:02:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C282FE38001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:02:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 692EB1DB803A
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:02:59 +0900 (JST)
Message-ID: <50DA68A8.4060001@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 12:02:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
> 
> memory can't be offlined when CONFIG_MEMCG is selected.
> For example: there is a memory device on node 1. The address range
> is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
> and memory11 under the directory /sys/devices/system/memory/.
> 
> If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
> when we online pages. When we online memory8, the memory stored page cgroup
> is not provided by this memory device. But when we online memory9, the memory
> stored page cgroup may be provided by memory8. So we can't offline memory8
> now. We should offline the memory in the reversed order.
> 

If memory8 is onlined as NORMAL memory ...right ?

IIUC, vmalloc() uses __GFP_HIGHMEM but doesn't use __GFP_MOVABLE.

> When the memory device is hotremoved, we will auto offline memory provided
> by this memory device. But we don't know which memory is onlined first, so
> offlining memory may fail. In such case, iterate twice to offline the memory.
> 1st iterate: offline every non primary memory block.
> 2nd iterate: offline primary (i.e. first added) memory block.
> 
> This idea is suggested by KOSAKI Motohiro.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

I'm not sure but the whole DIMM should be onlined as MOVABLE mem ?

Anyway, I agree this kind of retry is required if memory is onlined as NORMAL mem.
But retry-once is ok ?

Thanks,
-Kame

> ---
>   mm/memory_hotplug.c |   16 ++++++++++++++--
>   1 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d04ed87..62e04c9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1388,10 +1388,13 @@ int remove_memory(u64 start, u64 size)
>   	unsigned long start_pfn, end_pfn;
>   	unsigned long pfn, section_nr;
>   	int ret;
> +	int return_on_error = 0;
> +	int retry = 0;
>   
>   	start_pfn = PFN_DOWN(start);
>   	end_pfn = start_pfn + PFN_DOWN(size);
>   
> +repeat:
>   	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>   		section_nr = pfn_to_section_nr(pfn);
>   		if (!present_section_nr(section_nr))
> @@ -1410,14 +1413,23 @@ int remove_memory(u64 start, u64 size)
>   
>   		ret = offline_memory_block(mem);
>   		if (ret) {
> -			kobject_put(&mem->dev.kobj);
> -			return ret;
> +			if (return_on_error) {
> +				kobject_put(&mem->dev.kobj);
> +				return ret;
> +			} else {
> +				retry = 1;
> +			}
>   		}
>   	}
>   
>   	if (mem)
>   		kobject_put(&mem->dev.kobj);
>   
> +	if (retry) {
> +		return_on_error = 1;
> +		goto repeat;
> +	}
> +
>   	return 0;
>   }
>   #else
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
