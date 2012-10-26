Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2BAB06B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 13:22:09 -0400 (EDT)
Message-ID: <1351271671.19172.74.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 3/3] acpi,memory-hotplug : add memory offline code to
 acpi_memory_device_remove()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 26 Oct 2012 11:14:31 -0600
In-Reply-To: <1351247463-5653-4-git-send-email-wency@cn.fujitsu.com>
References: <1351247463-5653-1-git-send-email-wency@cn.fujitsu.com>
	 <1351247463-5653-4-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, liuj97@gmail.com, len.brown@intel.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, rjw@sisk.pl, laijs@cn.fujitsu.com, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>

On Fri, 2012-10-26 at 18:31 +0800, wency@cn.fujitsu.com wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> In the 1st case, acpi_memory_disable_device() will be called.
> In the 2nd case, acpi_memory_device_remove() will be called.

Hi Yasuaki, Wen,

Why do you need to have separate code design & implementation for the
two cases?  In other words, can the 1st case simply use the same code
path of the 2nd case, just like I did for the CPU hot-remove patch
below?  It will simplify the code and make the memory notify handler
more consistent with other handlers.
https://lkml.org/lkml/2012/10/19/456

Thanks,
-Toshi


> acpi_memory_device_remove() will also be called when we unbind the
> memory device from the driver acpi_memhotplug or a driver initialization
> fails.
> 
> acpi_memory_disable_device() has already implemented a code which
> offlines memory and releases acpi_memory_info struct. But
> acpi_memory_device_remove() has not implemented it yet.
> 
> So the patch move offlining memory and releasing acpi_memory_info struct
> codes to a new function acpi_memory_remove_memory(). And it is used by both
> acpi_memory_device_remove() and acpi_memory_disable_device().
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>  drivers/acpi/acpi_memhotplug.c | 31 ++++++++++++++++++++++++-------
>  1 file changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 666dac6..92c973a 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -316,16 +316,11 @@ static int acpi_memory_powerdown_device(struct acpi_memory_device *mem_device)
>  	return 0;
>  }
>  
> -static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>  {
>  	int result;
>  	struct acpi_memory_info *info, *n;
>  
> -
> -	/*
> -	 * Ask the VM to offline this memory range.
> -	 * Note: Assume that this function returns zero on success
> -	 */
>  	mutex_lock(&mem_device->list_lock);
>  	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>  		if (info->enabled) {
> @@ -333,10 +328,27 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>  			if (result)
>  				return result;
>  		}
> +
> +		list_del(&info->list);
>  		kfree(info);
>  	}
>  	mutex_unlock(&mem_device->list_lock);
>  
> +	return 0;
> +}
> +
> +static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +{
> +	int result;
> +
> +	/*
> +	 * Ask the VM to offline this memory range.
> +	 * Note: Assume that this function returns zero on success
> +	 */
> +	result = acpi_memory_remove_memory(mem_device);
> +	if (result)
> +		return result;
> +
>  	/* Power-off and eject the device */
>  	result = acpi_memory_powerdown_device(mem_device);
>  	if (result) {
> @@ -487,12 +499,17 @@ static int acpi_memory_device_add(struct acpi_device *device)
>  static int acpi_memory_device_remove(struct acpi_device *device, int type)
>  {
>  	struct acpi_memory_device *mem_device = NULL;
> -
> +	int result;
>  
>  	if (!device || !acpi_driver_data(device))
>  		return -EINVAL;
>  
>  	mem_device = acpi_driver_data(device);
> +
> +	result = acpi_memory_remove_memory(mem_device);
> +	if (result)
> +		return result;
> +
>  	kfree(mem_device);
>  
>  	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
