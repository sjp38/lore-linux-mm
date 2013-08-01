Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 056196B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 16:17:01 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2 04/18] acpi: Introduce acpi_invalid_table() to check if a table is invalid.
Date: Thu, 01 Aug 2013 22:27:13 +0200
Message-ID: <2933065.Fj6XrC3sr2@vostro.rjw.lan>
In-Reply-To: <1375340800-19332-5-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com> <1375340800-19332-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thursday, August 01, 2013 03:06:26 PM Tang Chen wrote:
> In acpi_initrd_override(), it checks several things to ensure the
> table it found is valid. In later patches, we need to do these check
> somewhere else. So this patch introduces a common function
> acpi_invalid_table() to do all these checks, and reuse it in different
> places. The function will be used in the subsequent patches.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/osl.c |   86 +++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 61 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index 91d9f54..8df8a93 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -572,9 +572,68 @@ static const char * const table_sigs[] = {
>  /* Must not increase 10 or needs code modification below */
>  #define ACPI_OVERRIDE_TABLES 10
>  
> +/*******************************************************************************
> + *
> + * FUNCTION:    acpi_invalid_table
> + *
> + * PARAMETERS:  File               - The initrd file
> + *              Path               - Path to acpi overriding tables in cpio file
> + *              Signature          - Signature of the table
> + *
> + * RETURN:      0 if it passes all the checks, -EINVAL if any check fails.
> + *
> + * DESCRIPTION: Check if an acpi table found in initrd is invalid.
> + *              @signature can be NULL. If it is NULL, the function will check
> + *              if the table signature matches any signature in table_sigs[].
> + *
> + ******************************************************************************/
> +int __init acpi_invalid_table(struct cpio_data *file,
> +			      const char *path, const char *signature)
> +{
> +	int idx;
> +	struct acpi_table_header *table = file->data;
> +
> +	if (file->size < sizeof(struct acpi_table_header)) {
> +		INVALID_TABLE("Table smaller than ACPI header",
> +			      path, file->name);
> +		return -EINVAL;
> +	}
> +
> +	if (signature) {
> +		if (memcmp(table->signature, signature, 4)) {
> +			INVALID_TABLE("Table signature does not match",
> +				      path, file->name);
> +			return -EINVAL;
> +		}
> +	} else {
> +		for (idx = 0; table_sigs[idx]; idx++)
> +			if (!memcmp(table->signature, table_sigs[idx], 4))
> +				break;
> +
> +		if (!table_sigs[idx]) {
> +			INVALID_TABLE("Unknown signature", path, file->name);
> +			return -EINVAL;
> +		}
> +	}
> +
> +	if (file->size != table->length) {
> +		INVALID_TABLE("File length does not match table length",
> +			      path, file->name);
> +		return -EINVAL;
> +	}
> +
> +	if (acpi_table_checksum(file->data, table->length)) {
> +		INVALID_TABLE("Bad table checksum",
> +			      path, file->name);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  void __init acpi_initrd_override(void *data, size_t size)
>  {
> -	int sig, no, table_nr = 0, total_offset = 0;
> +	int no, table_nr = 0, total_offset = 0;
>  	long offset = 0;
>  	struct acpi_table_header *table;
>  	char cpio_path[32] = "kernel/firmware/acpi/";
> @@ -593,33 +652,10 @@ void __init acpi_initrd_override(void *data, size_t size)
>  		data += offset;
>  		size -= offset;
>  
> -		if (file.size < sizeof(struct acpi_table_header)) {
> -			INVALID_TABLE("Table smaller than ACPI header",
> -				      cpio_path, file.name);
> -			continue;
> -		}
> -
>  		table = file.data;
>  
> -		for (sig = 0; table_sigs[sig]; sig++)
> -			if (!memcmp(table->signature, table_sigs[sig], 4))
> -				break;
> -
> -		if (!table_sigs[sig]) {
> -			INVALID_TABLE("Unknown signature",
> -				      cpio_path, file.name);
> +		if (acpi_invalid_table(&file, cpio_path, NULL))
>  			continue;
> -		}
> -		if (file.size != table->length) {
> -			INVALID_TABLE("File length does not match table length",
> -				      cpio_path, file.name);
> -			continue;
> -		}
> -		if (acpi_table_checksum(file.data, table->length)) {
> -			INVALID_TABLE("Bad table checksum",
> -				      cpio_path, file.name);
> -			continue;
> -		}
>  
>  		pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
>  			table->signature, cpio_path, file.name, table->length);
> 
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
