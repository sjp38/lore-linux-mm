Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 53D346B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:50:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E18D83EE0C1
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:50:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C769245DEAD
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:50:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAEBA45DE7E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:50:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A0CD1DB803E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:50:12 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 459481DB803B
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:50:12 +0900 (JST)
Message-ID: <50090DA4.8040908@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 16:49:56 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/8] memory-hotplug: call remove_memory() to cleanup
 when removing memory device
References: <5009038A.4090001@cn.fujitsu.com> <5009046C.106@cn.fujitsu.com>
In-Reply-To: <5009046C.106@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/07/20 16:10, Wen Congyang wrote:
> We should remove the following things when removing the memory device:
> 1. memmap and related sysfs files
> 2. iomem_resource
> 3. mem_section and related sysfs files
> 4. node and related sysfs files
>
> The function remove_memory() can do this. So call it after the memory device
> is offlined.
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
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---

I have no comment.
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu


>   drivers/acpi/acpi_memhotplug.c |    7 ++++++-
>   1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 712e767..58e4e63 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -315,7 +315,7 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>   {
>   	int result;
>   	struct acpi_memory_info *info, *n;
> -
> +	int node = mem_device->nid;
>
>   	/*
>   	 * Ask the VM to offline this memory range.
> @@ -330,6 +330,11 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>   				if (result)
>   					return result;
>   			}
> +
> +			result = remove_memory(node, info->start_addr,
> +					       info->length);
> +			if (result)
> +				return result;
>   		}
>   		list_del(&info->list);
>   		kfree(info);
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
