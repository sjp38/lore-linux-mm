Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 0E5F56B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:18:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7B68D3EE0B6
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FB6A45DE55
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4793F45DE4D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A221DB802C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:12 +0900 (JST)
Received: from g01jpexchkw26.g01.fujitsu.local (g01jpexchkw26.g01.fujitsu.local [10.0.193.109])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E06EB1DB803A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:11 +0900 (JST)
Message-ID: <50A4B337.6070109@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:17:43 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v5 4/7] acpi_memhotplug.c: free memory device if acpi_memory_enable_device()
 failed
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1352962777-24407-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-5-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

2012/11/15 15:59, Wen Congyang wrote:
> If acpi_memory_enable_device() fails, acpi_memory_enable_device() will
> return a non-zero value, which means we fail to bind the memory device to
> this driver.  So we should free memory device before
> acpi_memory_device_add() returns.
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

>   drivers/acpi/acpi_memhotplug.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index c5e7b6d..e52ad5d 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -421,9 +421,11 @@ static int acpi_memory_device_add(struct acpi_device *device)
>   	if (!acpi_memory_check_device(mem_device)) {
>   		/* call add_memory func */
>   		result = acpi_memory_enable_device(mem_device);
> -		if (result)
> +		if (result) {
>   			printk(KERN_ERR PREFIX
>   				"Error in acpi_memory_enable_device\n");
> +			acpi_memory_device_free(mem_device);
> +		}
>   	}
>   	return result;
>   }
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
