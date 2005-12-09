Date: Thu, 8 Dec 2005 19:20:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Making high and batch sizes of per_cpu_pagelists
 configurable
Message-Id: <20051208192032.6387f638.akpm@osdl.org>
In-Reply-To: <20051208190016.A3975@unix-os.sc.intel.com>
References: <20051208190016.A3975@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth <rohit.seth@intel.com> wrote:
>
> +	if ((high/4) > (PAGE_SHIFT * 8))
>  +		pcp->batch = PAGE_SHIFT * 8;

hm.  What relationship is there between log2(PAGE_SIZE) and the batch
quantity?  I'd have thought that if anything, we'd want to make the batch
sizes smaller for larger PAGE_SIZE.  Or something.

>  +}
>  +
>  +/*
>  + * percpu_pagelist_fraction - changes the pcp->high for each zone on each
>  + * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
>  + * can have before it gets flushed back to buddy allocator.
>  + */
>  +
>  +int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
>  +	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
>  +{
>  +	struct zone *zone;
>  +	unsigned int cpu;
>  +	int ret;
>  +
>  +	ret = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
>  +	if (!write || (ret == -EINVAL))
>  +		return ret;
>  +	for_each_zone(zone) {
>  +		for_each_online_cpu(cpu) {
>  +			unsigned long  high;
>  +			high = zone->present_pages / percpu_pagelist_fraction;
>  +			setup_pagelist_highmark(zone_pcp(zone, cpu), high);

What happens if a CPU comes online afterwards?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
