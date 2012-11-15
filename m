Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 9EB7D6B006C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:22:54 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CDB5C3EE081
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:22:52 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B5A9845DE53
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:22:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C23E45DE4D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:22:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F257E38004
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:22:52 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 349EA1DB8038
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:22:52 +0900 (JST)
Message-ID: <50A4B44F.1040006@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:22:23 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v5 6/7] acpi_memhotplug.c: bind the memory device when
 the driver is being loaded
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1352962777-24407-7-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-7-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

2012/11/15 15:59, Wen Congyang wrote:
> We had introduced acpi_hotmem_initialized to avoid strange add_memory fail
> message.  But the memory device may not be used by the kernel, and the
> device should be bound when the driver is being loaded.  Remove
> acpi_hotmem_initialized to allow that the device can be bound when the
> driver is being loaded.
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

>   drivers/acpi/acpi_memhotplug.c | 12 ------------
>   1 file changed, 12 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index f7e3007..e0f7425 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -87,8 +87,6 @@ struct acpi_memory_device {
>   	struct list_head res_list;
>   };
>   
> -static int acpi_hotmem_initialized;
> -
>   static acpi_status
>   acpi_memory_get_resource(struct acpi_resource *resource, void *context)
>   {
> @@ -433,15 +431,6 @@ static int acpi_memory_device_add(struct acpi_device *device)
>   
>   	printk(KERN_DEBUG "%s \n", acpi_device_name(device));
>   
> -	/*
> -	 * Early boot code has recognized memory area by EFI/E820.
> -	 * If DSDT shows these memory devices on boot, hotplug is not necessary
> -	 * for them. So, it just returns until completion of this driver's
> -	 * start up.
> -	 */
> -	if (!acpi_hotmem_initialized)
> -		return 0;
> -
>   	if (!acpi_memory_check_device(mem_device)) {
>   		/* call add_memory func */
>   		result = acpi_memory_enable_device(mem_device);
> @@ -557,7 +546,6 @@ static int __init acpi_memory_device_init(void)
>   		return -ENODEV;
>   	}
>   
> -	acpi_hotmem_initialized = 1;
>   	return 0;
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
