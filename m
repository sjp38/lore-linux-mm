Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 377AD6B0034
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 08:53:44 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2 RESEND 07/18] x86, ACPI: Also initialize signature and length when parsing root table.
Date: Fri, 02 Aug 2013 15:03:56 +0200
Message-ID: <3299662.WAS8YLIUlv@vostro.rjw.lan>
In-Reply-To: <1375434877-20704-8-git-send-email-tangchen@cn.fujitsu.com>
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com> <1375434877-20704-8-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Friday, August 02, 2013 05:14:26 PM Tang Chen wrote:
> Besides the phys addr of the acpi tables, it will be very convenient if
> we also have the signature of each table in acpi_gbl_root_table_list at
> early time. We can find SRAT easily by comparing the signature.
> 
> This patch alse record signature and some other info in
> acpi_gbl_root_table_list at early time.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

The subject is misleading, as the change is in ACPICA and therefore affects not
only x86.

Also I think the same comments as for the other ACPICA patch is this series
applies: You shouldn't modify acpi_tbl_parse_root_table() in ways that would
require the other OSes using ACPICA to be modified.

> ---
>  drivers/acpi/acpica/tbutils.c |   22 ++++++++++++++++++++++
>  1 files changed, 22 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/acpi/acpica/tbutils.c b/drivers/acpi/acpica/tbutils.c
> index e3621cf..af942fe 100644
> --- a/drivers/acpi/acpica/tbutils.c
> +++ b/drivers/acpi/acpica/tbutils.c
> @@ -438,6 +438,7 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
>  	u32 i;
>  	u32 table_count;
>  	struct acpi_table_header *table;
> +	struct acpi_table_desc *table_desc;
>  	acpi_physical_address address;
>  	acpi_physical_address uninitialized_var(rsdt_address);
>  	u32 length;
> @@ -577,6 +578,27 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
>  	 */
>  	acpi_os_unmap_memory(table, length);
>  
> +	/*
> +	 * Also initialize the table entries here, so that later we can use them
> +	 * to find SRAT at very eraly time to reserve hotpluggable memory.
> +	 */
> +	for (i = 2; i < acpi_gbl_root_table_list.current_table_count; i++) {
> +		table = acpi_os_map_memory(
> +				acpi_gbl_root_table_list.tables[i].address,
> +				sizeof(struct acpi_table_header));
> +		if (!table)
> +			return_ACPI_STATUS(AE_NO_MEMORY);
> +
> +		table_desc = &acpi_gbl_root_table_list.tables[i];
> +
> +		table_desc->pointer = NULL;
> +		table_desc->length = table->length;
> +		table_desc->flags = ACPI_TABLE_ORIGIN_MAPPED;
> +		ACPI_MOVE_32_TO_32(table_desc->signature.ascii, table->signature);
> +
> +		acpi_os_unmap_memory(table, sizeof(struct acpi_table_header));
> +	}
> +
>  	return_ACPI_STATUS(AE_OK);
>  }

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
