Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 7C4EC6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:20:22 -0400 (EDT)
Message-ID: <1375406353.10300.73.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 10/18] x86, acpi: Try to find if SRAT is overrided
 earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 01 Aug 2013 19:19:13 -0600
In-Reply-To: <1375340800-19332-11-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375340800-19332-11-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-01 at 15:06 +0800, Tang Chen wrote:
> Linux cannot migrate pages used by the kernel due to the direct mapping
> (va = pa + PAGE_OFFSET), any memory used by the kernel cannot be hot-removed.
> So when using memory hotplug, we have to prevent the kernel from using
> hotpluggable memory.
> 
> The ACPI table SRAT (System Resource Affinity Table) contains info to specify
> which memory is hotpluggble. After SRAT is parsed, we are aware of which
> memory is hotpluggable.
> 
> At the early time when system is booting, SRAT has not been parsed. The boot
> memory allocator memblock will allocate any memory to the kernel. So we need
> SRAT parsed before memblock starts to work.
> 
> In this patch, we are going to parse SRAT earlier, right after memblock is ready.
> 
> Generally speaking, tables such as SRAT are provided by firmware. But
> ACPI_INITRD_TABLE_OVERRIDE functionality allows users to customize their own
> tables in initrd, and override the ones from firmware. So if we want to parse
> SRAT earlier, we also need to do SRAT override earlier.
> 
> First, we introduce early_acpi_override_srat() to check if SRAT will be overridden
> from initrd.
> 
> Second, we introduce find_hotpluggable_memory() to reserve hotpluggable memory,
> which will firstly call early_acpi_override_srat() to find out which memory is
> hotpluggable in the override SRAT.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  arch/x86/kernel/setup.c        |   10 +++++++
>  drivers/acpi/osl.c             |   58 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/acpi.h           |   14 ++++++++-
>  include/linux/memory_hotplug.h |    2 +
>  mm/memory_hotplug.c            |   25 ++++++++++++++++-
>  5 files changed, 106 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index c8f5d1a..8b1bddd 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1060,6 +1060,16 @@ void __init setup_arch(char **cmdline_p)
>  	/* Initialize ACPI root table */
>  	acpi_root_table_init();
>  
> +#ifdef CONFIG_ACPI_NUMA
> +	/*
> +	 * Linux kernel cannot migrate kernel pages, as a result, memory used
> +	 * by the kernel cannot be hot-removed. Find and mark hotpluggable
> +	 * memory in memblock to prevent memblock from allocating hotpluggable
> +	 * memory for the kernel.
> +	 */
> +	find_hotpluggable_memory();
> +#endif
> +
>  	/*
>  	 * The EFI specification says that boot service code won't be called
>  	 * after ExitBootServices(). This is, in fact, a lie.
> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index 8df8a93..d0b687c 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -48,6 +48,7 @@
>  
>  #include <asm/io.h>
>  #include <asm/uaccess.h>
> +#include <asm/setup.h>
>  
>  #include <acpi/acpi.h>
>  #include <acpi/acpi_bus.h>
> @@ -631,6 +632,63 @@ int __init acpi_invalid_table(struct cpio_data *file,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_ACPI_NUMA
> +/*******************************************************************************
> + *
> + * FUNCTION:    early_acpi_override_srat
> + *
> + * RETURN:      Phys addr of SRAT on success, 0 on error.
> + *
> + * DESCRIPTION: Try to get the phys addr of SRAT in initrd.
> + *              The ACPI_INITRD_TABLE_OVERRIDE procedure is able to use tables
> + *              in initrd file to override the ones provided by firmware. This
> + *              function checks if there is a SRAT in initrd at early time. If
> + *              so, return the phys addr of the SRAT.
> + *
> + ******************************************************************************/
> +phys_addr_t __init early_acpi_override_srat(void)
> +{
> +	int i;
> +	u32 length;
> +	long offset;
> +	void *ramdisk_vaddr;
> +	struct acpi_table_header *table;
> +	struct cpio_data file;
> +	unsigned long map_step = NR_FIX_BTMAPS << PAGE_SHIFT;
> +	phys_addr_t ramdisk_image = get_ramdisk_image();
> +	char cpio_path[32] = "kernel/firmware/acpi/";

Don't you need to check if ramdisk is present before parsing the table?
You may need something like:

  if (!ramdisk_image || !get_ramdisk_size())
        return 0;

> +
> +	/* Try to find if SRAT is overrided */

overrided -> overridden

> +	for (i = 0; i < ACPI_OVERRIDE_TABLES; i++) {
> +		ramdisk_vaddr = early_ioremap(ramdisk_image, map_step);
> +
> +		file = find_cpio_data(cpio_path, ramdisk_vaddr,
> +				      map_step, &offset);
> +		if (!file.data) {
> +			early_iounmap(ramdisk_vaddr, map_step);
> +			return 0;
> +		}
> +
> +		table = file.data;
> +		length = table->length;
> +
> +		if (acpi_invalid_table(&file, cpio_path, ACPI_SIG_SRAT)) {
> +			ramdisk_image += offset;
> +			early_iounmap(ramdisk_vaddr, map_step);
> +			continue;
> +		}
> +
> +		/* Found SRAT */
> +		early_iounmap(ramdisk_vaddr, map_step);
> +		ramdisk_image = ramdisk_image + offset - length;
> +
> +		break;
> +	}
> +
> +	return ramdisk_image;

Doesn't this function return a physical address regardless of SRAT if a
ramdisk is present?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
