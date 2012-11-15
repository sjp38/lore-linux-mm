Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 90DF26B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:20:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 335DA3EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:20:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1714345DE52
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:20:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D992445DE4F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:20:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD7B71DB803F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:20:56 +0900 (JST)
Received: from G01JPEXCHKW22.g01.fujitsu.local (G01JPEXCHKW22.g01.fujitsu.local [10.0.193.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 805711DB8037
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:20:56 +0900 (JST)
Message-ID: <50A4B3DB.8020702@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:20:27 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v5 5/7] acpi_memhotplug.c: don't allow to eject the memory
 device if it is being used
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1352962777-24407-6-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-6-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

2012/11/15 15:59, Wen Congyang wrote:
> We eject the memory device even if it is in use.  It is very dangerous,
> and it will cause the kernel to be panicked.
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> CC: Rafael J. Wysocki <rjw@sisk.pl>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   drivers/acpi/acpi_memhotplug.c | 42 +++++++++++++++++++++++++++++++++---------
>   1 file changed, 33 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index e52ad5d..f7e3007 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -78,6 +78,7 @@ struct acpi_memory_info {
>   	unsigned short caching;	/* memory cache attribute */
>   	unsigned short write_protect;	/* memory read/write attribute */
>   	unsigned int enabled:1;
> +	unsigned int failed:1;
>   };
>   
>   struct acpi_memory_device {
> @@ -257,9 +258,23 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   			node = memory_add_physaddr_to_nid(info->start_addr);
>   
>   		result = add_memory(node, info->start_addr, info->length);
> -		if (result)
> +
> +		/*
> +		 * If the memory block has been used by the kernel, add_memory()
> +		 * returns -EEXIST. If add_memory() returns the other error, it
> +		 * means that this memory block is not used by the kernel.
> +		 */
> +		if (result && result != -EEXIST) {
> +			info->failed = 1;
>   			continue;
> -		info->enabled = 1;
> +		}
> +
> +		if (!result)
> +			info->enabled = 1;
> +		/*
> +		 * Add num_enable even if add_memory() returns -EEXIST, so the
> +		 * device is bound to this driver.
> +		 */
>   		num_enabled++;
>   	}
>   	if (!num_enabled) {
> @@ -280,21 +295,30 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   
>   static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>   {
> -	int result;
> +	int result = 0;
>   	struct acpi_memory_info *info, *n;
>   
>   	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
> -		if (info->enabled) {
> -			result = remove_memory(info->start_addr, info->length);
> -			if (result)
> -				return result;
> -		}
> +		if (info->failed)
> +			/* The kernel does not use this memory block */
> +			continue;
> +
> +		if (!info->enabled)
> +			/*
> +			 * The kernel uses this memory block, but it may be not
> +			 * managed by us.
> +			 */
> +			return -EBUSY;
> +
> +		result = remove_memory(info->start_addr, info->length);
> +		if (result)
> +			return result;
>   
>   		list_del(&info->list);
>   		kfree(info);
>   	}
>   
> -	return 0;
> +	return result;
>   }
>   
>   static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
