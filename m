Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 8119B6B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:14:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 17F343EE0B5
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:14:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E721945DE59
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:14:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF94C45DE54
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:14:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4452E08002
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:14:00 +0900 (JST)
Received: from g01jpexchkw24.g01.fujitsu.local (g01jpexchkw24.g01.fujitsu.local [10.0.193.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FA1F1DB803F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:14:00 +0900 (JST)
Message-ID: <50A4B227.4050307@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:13:11 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v5 2/7] acpi,memory-hotplug: deal with eject request in
 hotplug queue
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1352962777-24407-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-3-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

2012/11/15 15:59, Wen Congyang wrote:
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> We handle the 1st case in the module acpi_memhotplug, and handle
> the 2nd case in ACPI eject notification. This 2 events may happen
> at the same time, so we may touch acpi_memory_device.res_list at
> the same time. This patch reimplements memory-hotremove support
> through an ACPI eject notification. Now the memory device is
> offlined and hotremoved only in the function acpi_memory_device_remove()
> which is protected by device_lock().
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

>   drivers/acpi/acpi_memhotplug.c | 87 +++++-------------------------------------
>   1 file changed, 9 insertions(+), 78 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 2918be1..6e12042 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -272,40 +272,6 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   	return 0;
>   }
>   
> -static int acpi_memory_powerdown_device(struct acpi_memory_device *mem_device)
> -{
> -	acpi_status status;
> -	struct acpi_object_list arg_list;
> -	union acpi_object arg;
> -	unsigned long long current_status;
> -
> -
> -	/* Issue the _EJ0 command */
> -	arg_list.count = 1;
> -	arg_list.pointer = &arg;
> -	arg.type = ACPI_TYPE_INTEGER;
> -	arg.integer.value = 1;
> -	status = acpi_evaluate_object(mem_device->device->handle,
> -				      "_EJ0", &arg_list, NULL);
> -	/* Return on _EJ0 failure */
> -	if (ACPI_FAILURE(status)) {
> -		ACPI_EXCEPTION((AE_INFO, status, "_EJ0 failed"));
> -		return -ENODEV;
> -	}
> -
> -	/* Evalute _STA to check if the device is disabled */
> -	status = acpi_evaluate_integer(mem_device->device->handle, "_STA",
> -				       NULL, &current_status);
> -	if (ACPI_FAILURE(status))
> -		return -ENODEV;
> -
> -	/* Check for device status.  Device should be disabled */
> -	if (current_status & ACPI_STA_DEVICE_ENABLED)
> -		return -EINVAL;
> -
> -	return 0;
> -}
> -
>   static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>   {
>   	int result;
> @@ -325,34 +291,11 @@ static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>   	return 0;
>   }
>   
> -static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> -{
> -	int result;
> -
> -	/*
> -	 * Ask the VM to offline this memory range.
> -	 * Note: Assume that this function returns zero on success
> -	 */
> -	result = acpi_memory_remove_memory(mem_device);
> -	if (result)
> -		return result;
> -
> -	/* Power-off and eject the device */
> -	result = acpi_memory_powerdown_device(mem_device);
> -	if (result) {
> -		/* Set the status of the device to invalid */
> -		mem_device->state = MEMORY_INVALID_STATE;
> -		return result;
> -	}
> -
> -	mem_device->state = MEMORY_POWER_OFF_STATE;
> -	return result;
> -}
> -
>   static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
>   {
>   	struct acpi_memory_device *mem_device;
>   	struct acpi_device *device;
> +	struct acpi_eject_event *ej_event = NULL;
>   	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
>   
>   	switch (event) {
> @@ -394,31 +337,19 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
>   			break;
>   		}
>   
> -		/*
> -		 * Currently disabling memory device from kernel mode
> -		 * TBD: Can also be disabled from user mode scripts
> -		 * TBD: Can also be disabled by Callback registration
> -		 *      with generic sysfs driver
> -		 */
> -		if (acpi_memory_disable_device(mem_device)) {
> -			printk(KERN_ERR PREFIX "Disable memory device\n");
> -			/*
> -			 * If _EJ0 was called but failed, _OST is not
> -			 * necessary.
> -			 */
> -			if (mem_device->state == MEMORY_INVALID_STATE)
> -				return;
> -
> +		ej_event = kmalloc(sizeof(*ej_event), GFP_KERNEL);
> +		if (!ej_event) {
> +			pr_err(PREFIX "No memory, dropping EJECT\n");
>   			break;
>   		}
>   
> -		/*
> -		 * TBD: Invoke acpi_bus_remove to cleanup data structures
> -		 */
> +		ej_event->handle = handle;
> +		ej_event->event = ACPI_NOTIFY_EJECT_REQUEST;
> +		acpi_os_hotplug_execute(acpi_bus_hot_remove_device,
> +					(void *)ej_event);
>   
> -		/* _EJ0 succeeded; _OST is not necessary */
> +		/* eject is performed asynchronously */
>   		return;
> -
>   	default:
>   		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
>   				  "Unsupported event [0x%x]\n", event));
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
