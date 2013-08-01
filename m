Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0FF0D6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 18:07:55 -0400 (EDT)
Message-ID: <1375394806.10300.24.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 03/18] acpi: Remove "continue" in macro
 INVALID_TABLE().
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 01 Aug 2013 16:06:46 -0600
In-Reply-To: <1375340800-19332-4-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375340800-19332-4-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-01 at 15:06 +0800, Tang Chen wrote:
> The macro INVALID_TABLE() is defined like this:
> 
>  #define INVALID_TABLE(x, path, name)                                    \
>          { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); continue; }
> 
> And it is used like this:
> 
> 	for (...) {
> 		...
> 		if (...)
> 			INVALID_TABLE()
> 		...
> 	}
> 
> The "continue" in the macro makes the code hard to understand.
> Change it to the style like other macros:
> 
>  #define INVALID_TABLE(x, path, name)                                    \
>          do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)
> 
> So after this patch, this macro should be used like this:
> 
> 	for (...) {
> 		...
> 		if (...) {
> 			INVALID_TABLE()
> 			continue;
> 		}
> 		...
> 	}
> 
> Add the "continue" wherever the macro is called.
> (For now, it is only called in acpi_initrd_override().)
> 
> The idea is from Yinghai Lu <yinghai@kernel.org>.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Acked-by: Tejun Heo <tj@kernel.org>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  drivers/acpi/osl.c |   18 +++++++++++++-----
>  1 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index e721863..91d9f54 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -565,7 +565,7 @@ static const char * const table_sigs[] = {
>  
>  /* Non-fatal errors: Affected tables/files are ignored */
>  #define INVALID_TABLE(x, path, name)					\

Since you are touching this macro, I'd suggest to rename it something
like ACPI_INVALID_TABLE().  INVALID_TABLE() sounds too generic to me.
Otherwise, it looks good.

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


> -	{ pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); continue; }
> +	do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)
>  
>  #define ACPI_HEADER_SIZE sizeof(struct acpi_table_header)
>  
> @@ -593,9 +593,11 @@ void __init acpi_initrd_override(void *data, size_t size)
>  		data += offset;
>  		size -= offset;
>  
> -		if (file.size < sizeof(struct acpi_table_header))
> +		if (file.size < sizeof(struct acpi_table_header)) {
>  			INVALID_TABLE("Table smaller than ACPI header",
>  				      cpio_path, file.name);
> +			continue;
> +		}
>  
>  		table = file.data;
>  
> @@ -603,15 +605,21 @@ void __init acpi_initrd_override(void *data, size_t size)
>  			if (!memcmp(table->signature, table_sigs[sig], 4))
>  				break;
>  
> -		if (!table_sigs[sig])
> +		if (!table_sigs[sig]) {
>  			INVALID_TABLE("Unknown signature",
>  				      cpio_path, file.name);
> -		if (file.size != table->length)
> +			continue;
> +		}
> +		if (file.size != table->length) {
>  			INVALID_TABLE("File length does not match table length",
>  				      cpio_path, file.name);
> -		if (acpi_table_checksum(file.data, table->length))
> +			continue;
> +		}
> +		if (acpi_table_checksum(file.data, table->length)) {
>  			INVALID_TABLE("Bad table checksum",
>  				      cpio_path, file.name);
> +			continue;
> +		}
>  
>  		pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
>  			table->signature, cpio_path, file.name, table->length);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
