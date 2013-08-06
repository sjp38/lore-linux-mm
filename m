Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 103D26B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 19:34:47 -0400 (EDT)
Message-ID: <1375832015.10300.206.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 RESEND 11/18] x86, acpi: Try to find SRAT in firmware
 earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 06 Aug 2013 17:33:35 -0600
In-Reply-To: <1375434877-20704-12-git-send-email-tangchen@cn.fujitsu.com>
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375434877-20704-12-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, 2013-08-02 at 17:14 +0800, Tang Chen wrote:
> This patch introduce early_acpi_firmware_srat() to find the
> phys addr of SRAT provided by firmware. And call it in
> find_hotpluggable_memory().
> 
> Since we have initialized acpi_gbl_root_table_list earlier,
> and store all the tables' phys addrs and signatures in it,
> it is easy to find the SRAT.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  drivers/acpi/acpica/tbxface.c |   32 ++++++++++++++++++++++++++++++++
>  drivers/acpi/osl.c            |   22 ++++++++++++++++++++++
>  include/acpi/acpixf.h         |    4 ++++
>  include/linux/acpi.h          |    4 ++++
>  mm/memory_hotplug.c           |    8 ++++++--
>  5 files changed, 68 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c

Please add "ACPICA" to the patch title.  This patch also needs to be
reviewed by ACPICA folks.

> index ad11162..6a92f12 100644
> --- a/drivers/acpi/acpica/tbxface.c
> +++ b/drivers/acpi/acpica/tbxface.c

 :

> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index dcbca3e..ec490fe 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -53,6 +53,7 @@
>  #include <acpi/acpi.h>
>  #include <acpi/acpi_bus.h>
>  #include <acpi/processor.h>
> +#include <acpi/acpixf.h>
>  
>  #define _COMPONENT		ACPI_OS_SERVICES
>  ACPI_MODULE_NAME("osl");
> @@ -760,6 +761,27 @@ void __init acpi_initrd_override(void *data, size_t size)
>  }
>  #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
>  
> +#ifdef CONFIG_ACPI_NUMA
> +/*******************************************************************************
> + *
> + * FUNCTION:    early_acpi_firmware_srat
> + *
> + * RETURN:      Phys addr of SRAT on success, 0 on error.
> + *
> + * DESCRIPTION: Get the phys addr of SRAT provided by firmware.
> + *
> + ******************************************************************************/
> +phys_addr_t __init early_acpi_firmware_srat(void)
> +{
> +	struct acpi_table_desc table_desc;
> +
> +	if (acpi_get_table_desc(ACPI_SIG_SRAT, &table_desc))

This check should use ACPI_FAILURE() macro:

  if (ACPI_FAILURE(acpi_get_table_desc(ACPI_SIG_SRAT, &table_desc))

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
