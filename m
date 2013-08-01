Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 035AA6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 17:56:16 -0400 (EDT)
Message-ID: <1375394108.10300.15.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 01/18] acpi: Print Hot-Pluggable Field in SRAT.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 01 Aug 2013 15:55:08 -0600
In-Reply-To: <1375340800-19332-2-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375340800-19332-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-01 at 15:06 +0800, Tang Chen wrote:
> The Hot-Pluggable field in SRAT suggests if the memory could be
> hotplugged while the system is running. Print it as well when
> parsing SRAT will help users to know which memory is hotpluggable.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Acked-by: Tejun Heo <tj@kernel.org>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


> ---
>  arch/x86/mm/srat.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
> index cdd0da9..d44c8a4 100644
> --- a/arch/x86/mm/srat.c
> +++ b/arch/x86/mm/srat.c
> @@ -146,6 +146,7 @@ int __init
>  acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  {
>  	u64 start, end;
> +	u32 hotpluggable;
>  	int node, pxm;
>  
>  	if (srat_disabled())
> @@ -154,7 +155,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  		goto out_err_bad_srat;
>  	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
>  		goto out_err;
> -	if ((ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) && !save_add_info())
> +	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
> +	if (hotpluggable && !save_add_info())
>  		goto out_err;
>  
>  	start = ma->base_address;
> @@ -174,9 +176,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  
>  	node_set(node, numa_nodes_parsed);
>  
> -	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
> -	       node, pxm,
> -	       (unsigned long long) start, (unsigned long long) end - 1);
> +	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s\n",
> +		node, pxm,
> +		(unsigned long long) start, (unsigned long long) end - 1,
> +		hotpluggable ? " Hot Pluggable" : "");
>  
>  	return 0;
>  out_err_bad_srat:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
