Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id E9A606B005A
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:11:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7FE9A3EE0C1
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:11:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6396C45DEC8
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:11:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 486A445DEC7
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:11:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39550E08004
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:11:41 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF8D31DB8043
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:11:40 +0900 (JST)
Message-ID: <50DA6AB3.2030608@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 12:10:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 02/14] memory-hotplug: check whether all memory blocks
 are offlined or not when removing memory
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> We remove the memory like this:
> 1. lock memory hotplug
> 2. offline a memory block
> 3. unlock memory hotplug
> 4. repeat 1-3 to offline all memory blocks
> 5. lock memory hotplug
> 6. remove memory(TODO)
> 7. unlock memory hotplug
> 
> All memory blocks must be offlined before removing memory. But we don't hold
> the lock in the whole operation. So we should check whether all memory blocks
> are offlined before step6. Otherwise, kernel maybe panicked.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

a nitpick below.

> ---
>   drivers/base/memory.c          |    6 +++++
>   include/linux/memory_hotplug.h |    1 +
>   mm/memory_hotplug.c            |   47 ++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 987604d..8300a18 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -693,6 +693,12 @@ int offline_memory_block(struct memory_block *mem)
>   	return ret;
>   }
>   
> +/* return true if the memory block is offlined, otherwise, return false */
> +bool is_memblock_offlined(struct memory_block *mem)
> +{
> +	return mem->state == MEM_OFFLINE;
> +}
> +
>   /*
>    * Initialize the sysfs support for memory devices...
>    */
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 4a45c4e..8dd0950 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -247,6 +247,7 @@ extern int add_memory(int nid, u64 start, u64 size);
>   extern int arch_add_memory(int nid, u64 start, u64 size);
>   extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>   extern int offline_memory_block(struct memory_block *mem);
> +extern bool is_memblock_offlined(struct memory_block *mem);
>   extern int remove_memory(u64 start, u64 size);
>   extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>   								int nr_pages);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 62e04c9..d43d97b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1430,6 +1430,53 @@ repeat:
>   		goto repeat;
>   	}
>   
> +	lock_memory_hotplug();
> +
> +	/*
> +	 * we have offlined all memory blocks like this:
> +	 *   1. lock memory hotplug
> +	 *   2. offline a memory block
> +	 *   3. unlock memory hotplug
> +	 *
> +	 * repeat step1-3 to offline the memory block. All memory blocks
> +	 * must be offlined before removing memory. But we don't hold the
> +	 * lock in the whole operation. So we should check whether all
> +	 * memory blocks are offlined.
> +	 */
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {

I prefer adding mem = NULL at the start of this for().

> +		section_nr = pfn_to_section_nr(pfn);
> +		if (!present_section_nr(section_nr))
> +			continue;
> +
> +		section = __nr_to_section(section_nr);
> +		/* same memblock? */
> +		if (mem)
> +			if ((section_nr >= mem->start_section_nr) &&
> +			    (section_nr <= mem->end_section_nr))
> +				continue;
> +

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
