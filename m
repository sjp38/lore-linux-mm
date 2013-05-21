Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 69D996B0039
	for <linux-mm@kvack.org>; Tue, 21 May 2013 03:35:12 -0400 (EDT)
Message-ID: <519B238D.3070900@huawei.com>
Date: Tue, 21 May 2013 15:34:37 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] ACPI / scan: Add second pass of companion offlining
 to hot-remove code
References: <2250271.rGYN6WlBxf@vostro.rjw.lan> <3662688.5fMZaG7XgD@vostro.rjw.lan>
In-Reply-To: <3662688.5fMZaG7XgD@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

On 2013/5/19 7:34, Rafael J. Wysocki wrote:

> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> As indicated by comments in mm/memory_hotplug.c:remove_memory(),
> if CONFIG_MEMCG is set, it may not be possible to offline all of the
> memory blocks held by one module (FRU) in one pass (because one of
> them may be used by the others to store page cgroup in that case
> and that block has to be offlined before the other ones).
> 
> To handle that arguably corner case, add a second pass of companion
> device offlining to acpi_scan_hot_remove() and make it ignore errors
> returned in the first pass (and make it skip the second pass if the
> first one is successful).
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> ---
>  drivers/acpi/scan.c |   67 ++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 50 insertions(+), 17 deletions(-)
> 
> Index: linux-pm/drivers/acpi/scan.c
> ===================================================================
> --- linux-pm.orig/drivers/acpi/scan.c
> +++ linux-pm/drivers/acpi/scan.c
> @@ -131,6 +131,7 @@ static acpi_status acpi_bus_offline_comp
>  {
>  	struct acpi_device *device = NULL;
>  	struct acpi_device_physical_node *pn;
> +	bool second_pass = (bool)data;
>  	acpi_status status = AE_OK;
>  
>  	if (acpi_bus_get_device(handle, &device))
> @@ -141,15 +142,26 @@ static acpi_status acpi_bus_offline_comp
>  	list_for_each_entry(pn, &device->physical_node_list, node) {
>  		int ret;
>  
> +		if (second_pass) {
> +			/* Skip devices offlined by the first pass. */
> +			if (pn->put_online)

should it be "if (!pn->put_online)" ?

Thanks
Xishi Qiu

> +				continue;
> +		} else {
> +			pn->put_online = false;
> +		}
>  		ret = device_offline(pn->dev);
>  		if (acpi_force_hot_remove)
>  			continue;
>  
> -		if (ret < 0) {
> -			status = AE_ERROR;
> -			break;
> +		if (ret >= 0) {
> +			pn->put_online = !ret;
> +		} else {
> +			*ret_p = pn->dev;
> +			if (second_pass) {
> +				status = AE_ERROR;
> +				break;
> +			}
>  		}
> -		pn->put_online = !ret;
>  	}
>  
>  	mutex_unlock(&device->physical_node_lock);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
