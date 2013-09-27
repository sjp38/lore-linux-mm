Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AFC666B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:16:28 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so3193994pdj.2
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:16:28 -0700 (PDT)
Message-ID: <1380323662.14046.51.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 5/6] x86, acpi, crash, kdump: Do
 reserve_crashkernel() after SRAT is parsed
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 27 Sep 2013 17:14:22 -0600
In-Reply-To: <5241DB3A.6090002@gmail.com>
References: <5241D897.1090905@gmail.com> <5241DB3A.6090002@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 2013-09-25 at 02:34 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> Memory reserved for crashkernel could be large. So we should not allocate
> this memory bottom up from the end of kernel image.
> 
> When SRAT is parsed, we will be able to know whihc memory is hotpluggable,
> and we can avoid allocating this memory for the kernel. So reorder
> reserve_crashkernel() after SRAT is parsed.
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  arch/x86/kernel/setup.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index f0de629..36cfce3 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1120,8 +1120,6 @@ void __init setup_arch(char **cmdline_p)
>  	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start);
>  #endif
>  
> -	reserve_crashkernel();
> -
>  	vsmp_init();
>  
>  	io_delay_init();
> @@ -1136,6 +1134,12 @@ void __init setup_arch(char **cmdline_p)
>  	initmem_init();
>  	memblock_find_dma_reserve();
>  
> +	/*
> +	 * Reserve memory for crash kernel after SRAT is parsed so that it
> +	 * won't consume hotpluggable memory.
> +	 */
> +	reserve_crashkernel();

Out of curiosity, is there any particular reason why it is moved after
memblock_find_dma_reserve(), not initmem_init()?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
