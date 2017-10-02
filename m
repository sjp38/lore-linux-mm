Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF2CB6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 06:38:08 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j126so1621322oia.5
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 03:38:08 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g44si998462oth.248.2017.10.02.03.38.07
        for <linux-mm@kvack.org>;
        Mon, 02 Oct 2017 03:38:07 -0700 (PDT)
Date: Mon, 2 Oct 2017 11:38:07 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 1/1] mm: only dispaly online cpus of the numa node
Message-ID: <20171002103806.GB3823@arm.com>
References: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com>
 <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, akpm@linux-foundation.org

[+akpm]

Hi Thunder,

On Fri, Sep 29, 2017 at 05:53:25PM +0800, Zhen Lei wrote:
> When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
> and display cpumask_of_node for each node), but I got different result on
> X86 and arm64. For each numa node, the former only displayed online CPUs,
> and the latter displayed all possible CPUs. Unfortunately, both Linux
> documentation and numactl manual have not described it clear.
> 
> I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
> that he preferred to print online cpus because it doesn't really make much
> sense to bind anything on offline nodes.
> 
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/base/node.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

Which tree is this intended to go through? I'm happy to take it via arm64,
but I don't want to tread on anybody's toes in linux-next and it looks like
there are already queued changes to this file via Andrew's tree.

Will

> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 3855902..aae2402 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -27,13 +27,21 @@ static struct bus_type node_subsys = {
>  
>  static ssize_t node_read_cpumap(struct device *dev, bool list, char *buf)
>  {
> +	ssize_t n;
> +	cpumask_var_t mask;
>  	struct node *node_dev = to_node(dev);
> -	const struct cpumask *mask = cpumask_of_node(node_dev->dev.id);
>  
>  	/* 2008/04/07: buf currently PAGE_SIZE, need 9 chars per 32 bits. */
>  	BUILD_BUG_ON((NR_CPUS/32 * 9) > (PAGE_SIZE-1));
>  
> -	return cpumap_print_to_pagebuf(list, buf, mask);
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		return 0;
> +
> +	cpumask_and(mask, cpumask_of_node(node_dev->dev.id), cpu_online_mask);
> +	n = cpumap_print_to_pagebuf(list, buf, mask);
> +	free_cpumask_var(mask);
> +
> +	return n;
>  }
>  
>  static inline ssize_t node_read_cpumask(struct device *dev,
> -- 
> 2.5.0
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
