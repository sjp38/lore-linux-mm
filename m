Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 92C7B6B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:59:26 -0400 (EDT)
Received: by mail-gg0-f176.google.com with SMTP id h1so16710ggn.35
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:59:25 -0700 (PDT)
Date: Tue, 23 Jul 2013 16:59:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 15/21] x86, acpi, numa: Don't reserve memory on nodes the
 kernel resides in.
Message-ID: <20130723205919.GT21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-16-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-16-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Fri, Jul 19, 2013 at 03:59:28PM +0800, Tang Chen wrote:
>  /*
> + * kernel_resides_in_range - Check if kernel resides in a memory range.
> + * @base: The base address of the memory range.
> + * @length: The length of the memory range.
> + *
> + * memblock reserves some memory for the kernel at very early time, such
> + * as kernel code and data segments, initrd file, and so on. So this
> + * function iterates memblock.reserved[] and check if any memory range with
> + * flag MEMBLK_FLAGS_DEFAULT overlaps [@base, @length). If so, the kernel
> + * resides in this memory range.
> + *
> + * Return true if the kernel resides in the memory range, false otherwise.
> + */
> +static bool __init kernel_resides_in_range(phys_addr_t base, u64 length)
> +{
> +	int i;
> +	struct memblock_type *reserved = &memblock.reserved;
> +	struct memblock_region *region;
> +	phys_addr_t start, end;
> +
> +	for (i = 0; i < reserved->cnt; i++) {
> +		region = &reserved->regions[i];
> +
> +		if (region->flags != MEMBLK_FLAGS_DEFAULT)
> +			continue;
> +
> +		start = region->base;
> +		end = region->base + region->size;
> +		if (end <= base || start >= base + length)
> +			continue;
> +
> +		return true;
> +	}
> +
> +	return false;
> +}

This being in acpi/osl.c is rather weird.  Overall, the acpi and
memblock parts don't seem very well split.  It'd best if acpi just
indicates which regions are hotpluggable and the rest is handled by
x86 boot or memblock code as appropriate.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
