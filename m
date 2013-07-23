Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 71E7F6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 19:27:09 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 23 Jul 2013 17:27:08 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B8B093E4003F
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:26:44 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6NNR612142772
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:27:06 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6NNR5wc022472
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:27:06 -0600
Message-ID: <51EF1143.1020503@linux.vnet.ibm.com>
Date: Tue, 23 Jul 2013 16:26:59 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/19/2013 12:59 AM, Tang Chen wrote:
> This patch introduce early_acpi_firmware_srat() to find the
> phys addr of SRAT provided by firmware. And call it in
> reserve_hotpluggable_memory().
>
> Since we have initialized acpi_gbl_root_table_list earlier,
> and store all the tables' phys addrs and signatures in it,
> it is easy to find the SRAT.
>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>   drivers/acpi/acpica/tbxface.c |   34 ++++++++++++++++++++++++++++++++++
>   drivers/acpi/osl.c            |   24 ++++++++++++++++++++++++
>   include/acpi/acpixf.h         |    4 ++++
>   include/linux/acpi.h          |    4 ++++
>   mm/memory_hotplug.c           |   10 +++++++---
>   5 files changed, 73 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c
> index ad11162..95f8d1b 100644
> --- a/drivers/acpi/acpica/tbxface.c
> +++ b/drivers/acpi/acpica/tbxface.c
> @@ -181,6 +181,40 @@ acpi_status acpi_reallocate_root_table(void)
>   	return_ACPI_STATUS(status);
>   }
>
> +/*
> + * acpi_get_table_desc - Get the acpi table descriptor of a specific table.
> + * @signature: The signature of the table to be found.
> + * @out_desc: The out returned descriptor.

The "@out_desc:" line looks funky. Also, I believe changes to this file 
need to go in via acpica & probably conform to their commenting standards?

> + *
> + * This function iterates acpi_gbl_root_table_list and find the specified
> + * table's descriptor.
> + *
> + * NOTE: The caller has the responsibility to allocate memory for @out_desc.
> + *
> + * Return AE_OK on success, AE_NOT_FOUND if the table is not found.
> + */
> +acpi_status acpi_get_table_desc(char *signature,
> +				struct acpi_table_desc *out_desc)
> +{
> +	int pos;
> +
> +	for (pos = 0;
> +	     pos < acpi_gbl_root_table_list.current_table_count;
> +	     pos++) {
> +		if (!ACPI_COMPARE_NAME
> +		    (&(acpi_gbl_root_table_list.tables[pos].signature),
> +		    signature))
> +			continue;
> +
> +		memcpy(out_desc, &acpi_gbl_root_table_list.tables[pos],
> +		       sizeof(struct acpi_table_desc));
> +
> +		return_ACPI_STATUS(AE_OK);
> +	}
> +
> +	return_ACPI_STATUS(AE_NOT_FOUND);
> +}
> +
>   /*******************************************************************************
>    *
>    * FUNCTION:    acpi_get_table_header
> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index fa6b973..a2e4596 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -53,6 +53,7 @@
>   #include <acpi/acpi.h>
>   #include <acpi/acpi_bus.h>
>   #include <acpi/processor.h>
> +#include <acpi/acpixf.h>
>
>   #define _COMPONENT		ACPI_OS_SERVICES
>   ACPI_MODULE_NAME("osl");
> @@ -750,6 +751,29 @@ void __init acpi_initrd_override(void *data, size_t size)
>   }
>   #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
>
> +#ifdef CONFIG_ACPI_NUMA
> +#include <asm/numa.h>
> +#include <linux/memblock.h>
> +
> +/*
> + * early_acpi_firmware_srat - Get the phys addr of SRAT provide by firmware.

s/provide/provided/

> + *
> + * This function iterate acpi_gbl_root_table_list, find SRAT and return the

Perhaps: "Iterate over acpi_gbl_root_table_list to find SRAT then return 
its phys addr"

Though I wonder if this comment is even needed, as the iteration is done 
in acpi_get_table_desc() (added above).

> + * phys addr of SRAT.
> + *
> + * Return the phys addr of SRAT, or 0 on error.



> + */
> +phys_addr_t __init early_acpi_firmware_srat()
> +{
> +	struct acpi_table_desc table_desc;
> +
> +	if (acpi_get_table_desc(ACPI_SIG_SRAT, &table_desc))
> +		return 0;
> +
> +	return table_desc.address;
> +}
> +#endif	/* CONFIG_ACPI_NUMA */
> +
>   static void acpi_table_taint(struct acpi_table_header *table)
>   {
>   	pr_warn(PREFIX

[...]

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 066873e..15b11d3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -106,10 +106,14 @@ void __init reserve_hotpluggable_memory(void)
>   {
>   	phys_addr_t srat_paddr;
>
> -	/* Try to find if SRAT is overrided */
> +	/* Try to find out if SRAT is overrided */
>   	srat_paddr = early_acpi_override_srat();
> -	if (!srat_paddr)
> -		return;
> +	if (!srat_paddr) {
> +		/* Try to find SRAT from firmware if it wasn't overrided */

s/overrided/overridden/

> +		srat_paddr = early_acpi_firmware_srat();
> +		if (!srat_paddr)
> +			return;
> +	}
>
>   	/* Will reserve hotpluggable memory here */
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
