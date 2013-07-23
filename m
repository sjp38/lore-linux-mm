Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id DB6FC6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:27:54 -0400 (EDT)
Received: by mail-gh0-f182.google.com with SMTP id z15so2647312ghb.41
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:27:53 -0700 (PDT)
Date: Tue, 23 Jul 2013 16:27:46 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 12/21] x86, acpi: Try to find if SRAT is overrided
 earlier.
Message-ID: <20130723202746.GQ21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-13-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-13-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:25PM +0800, Tang Chen wrote:
> As we mentioned in previous patches, to prevent the kernel

Prolly best to briefly describe what the overall goal is about.

> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 28d2e60..9717760 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1078,6 +1078,15 @@ void __init setup_arch(char **cmdline_p)
>  	/* Initialize ACPI root table */
>  	acpi_root_table_init();
>  
> +#ifdef CONFIG_ACPI_NUMA
> +	/*
> +	 * Linux kernel cannot migrate kernel pages, as a result, memory used
> +	 * by the kernel cannot be hot-removed. Reserve hotpluggable memory to
> +	 * prevent memblock from allocating hotpluggable memory for the kernel.
> +	 */
> +	reserve_hotpluggable_memory();
> +#endif

Hmmm, so you're gonna reserve all hotpluggable memory areas until
everything is up and running, which probably is why allocating
node_data on hotpluggable node doesn't work, right?

> +#ifdef CONFIG_ACPI_NUMA
> +/*

/**

> + * early_acpi_override_srat - Try to get the phys addr of SRAT in initrd.
> + *
> + * The ACPI_INITRD_TABLE_OVERRIDE procedure is able to use tables in initrd
> + * file to override the ones provided by firmware. This function checks if
> + * there is a SRAT in initrd at early time. If so, return the phys addr of
> + * the SRAT.
> + *
> + * Return the phys addr of SRAT in initrd, 0 if there is no SRAT.
> + */
> +phys_addr_t __init early_acpi_override_srat(void)
> +{
> +	int i;
> +	u32 length;
> +	long offset;
> +	void *ramdisk_vaddr;
> +	struct acpi_table_header *table;
> +	unsigned long map_step = NR_FIX_BTMAPS << PAGE_SHIFT;
> +	phys_addr_t ramdisk_image = get_ramdisk_image();
> +	char cpio_path[32] = "kernel/firmware/acpi/";
> +	struct cpio_data file;

Don't we usually put variable declarations with initializers before
others?  For some reason, the above block is painful to look at.

> +	/* Try to find if SRAT is overrided */
                                  ^
                                  overridden?

...
> +#ifdef CONFIG_ACPI_NUMA
> +/*

/**

> + * reserve_hotpluggable_memory - Reserve hotpluggable memory in memblock.
> + *
> + * This function did the following:
> + * 1. Try to find if there is a SRAT in initrd file used to override the one
> + *    provided by firmware. If so, get its phys addr.
> + * 2. If there is no override SRAT, get the phys addr of the SRAT in firmware.
> + * 3. Parse SRAT, find out which memory is hotpluggable, and reserve it in
> + *    memblock.
> + */
> +void __init reserve_hotpluggable_memory(void)

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
