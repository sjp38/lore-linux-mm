Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2D5DE6B0154
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 16:53:41 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so1241047oag.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 13:53:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506C0C53.60205@jp.fujitsu.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 4 Oct 2012 16:53:17 -0400
Message-ID: <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to acpi_memory_device_remove()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Wed, Oct 3, 2012 at 5:58 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>
> In the 1st case, acpi_memory_disable_device() will be called.
> In the 2nd case, acpi_memory_device_remove() will be called.
> acpi_memory_device_remove() will also be called when we unbind the
> memory device from the driver acpi_memhotplug.
>
> acpi_memory_disable_device() has already implemented a code which
> offlines memory and releases acpi_memory_info struct . But
> acpi_memory_device_remove() has not implemented it yet.
>
> So the patch implements acpi_memory_remove_memory() for offlining
> memory and releasing acpi_memory_info struct. And it is used by both
> acpi_memory_device_remove() and acpi_memory_disable_device().
>
> Additionally, if the type is ACPI_BUS_REMOVAL_EJECT in
> acpi_memory_device_remove() , it means that the user wants to eject
> the memory device. In this case, acpi_memory_device_remove() calls
> acpi_memory_remove_memory().
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
>  drivers/acpi/acpi_memhotplug.c |   44 +++++++++++++++++++++++++++++++----------
>  1 file changed, 34 insertions(+), 10 deletions(-)
>
> Index: linux-3.6/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-3.6.orig/drivers/acpi/acpi_memhotplug.c       2012-10-03 18:55:33.386378909 +0900
> +++ linux-3.6/drivers/acpi/acpi_memhotplug.c    2012-10-03 18:55:58.624380688 +0900
> @@ -306,24 +306,37 @@ static int acpi_memory_powerdown_device(
>         return 0;
>  }
>
> -static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>  {
>         int result;
>         struct acpi_memory_info *info, *n;
>
> +       list_for_each_entry_safe(info, n, &mem_device->res_list, list) {

Which lock protect this loop?


> +               if (!info->enabled)
> +                       return -EBUSY;
> +
> +               result = remove_memory(info->start_addr, info->length);
> +               if (result)
> +                       return result;

I suspect you need to implement rollback code instead of just return.


> +
> +               list_del(&info->list);
> +               kfree(info);
> +       }
> +
> +       return 0;
> +}
> +
> +static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +{
> +       int result;
>
>         /*
>          * Ask the VM to offline this memory range.
>          * Note: Assume that this function returns zero on success
>          */

Write function comment instead of this silly comment.

> -       list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
> -               if (info->enabled) {
> -                       result = remove_memory(info->start_addr, info->length);
> -                       if (result)
> -                               return result;
> -               }
> -               kfree(info);
> -       }
> +       result = acpi_memory_remove_memory(mem_device);
> +       if (result)
> +               return result;
>
>         /* Power-off and eject the device */
>         result = acpi_memory_powerdown_device(mem_device);

This patch move acpi_memory_powerdown_device() from ACPI_NOTIFY_EJECT_REQUEST
to release callback, but don't explain why.





> @@ -473,12 +486,23 @@ static int acpi_memory_device_add(struct
>  static int acpi_memory_device_remove(struct acpi_device *device, int type)
>  {
>         struct acpi_memory_device *mem_device = NULL;
> -
> +       int result;
>
>         if (!device || !acpi_driver_data(device))
>                 return -EINVAL;
>
>         mem_device = acpi_driver_data(device);
> +
> +       if (type == ACPI_BUS_REMOVAL_EJECT) {
> +               /*
> +                * offline and remove memory only when the memory device is
> +                * ejected.
> +                */

This comment explain nothing. A comment should describe _why_ should we do.
e.g. Why REMOVAL_NORMAL and REMOVEL_EJECT should be ignored. Why
we need remove memory here instead of ACPI_NOTIFY_EJECT_REQUEST.


> +               result = acpi_memory_remove_memory(mem_device);
> +               if (result)
> +                       return result;
> +       }
> +
>         kfree(mem_device);
>
>         return 0;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
