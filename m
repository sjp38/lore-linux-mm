Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 482916B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 07:03:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a22so4421085wme.0
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 04:03:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si10590750wra.452.2017.12.11.04.03.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 04:03:07 -0800 (PST)
Date: Mon, 11 Dec 2017 13:03:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND] x86/numa: move setting parsed numa node to
 num_add_memblk
Message-ID: <20171211120304.GD4779@dhcp22.suse.cz>
References: <1512123232-7263-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512123232-7263-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, minchan@kernel.org, vbabka@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 01-12-17 18:13:52, zhong jiang wrote:
> The acpi table are very much like user input. it is likely to
> introduce some unreasonable node in some architecture. but
> they do not ingore the node and bail out in time. it will result
> in unnecessary print.
> e.g  x86:  start is equal to end is a unreasonable node.
> numa_blk_memblk will fails but return 0.
> 
> meanwhile, Arm64 node will double set it to "numa_node_parsed"
> after NUMA adds a memblk successfully.  but X86 is not. because
> numa_add_memblk is not set in X86.

I am sorry but I still fail to understand wht the actual problem is.
You said that x86 will print a message. Alright at least you know that
the platform provides a nonsense ACPI/SRAT? tables and you can complain.
But does the kernel misbehave? In what way?

> In view of the above problems. I think it need a better improvement.
> we add a check here for bypassing the invalid memblk node.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  arch/x86/mm/amdtopology.c | 1 -
>  arch/x86/mm/numa.c        | 3 ++-
>  drivers/acpi/numa.c       | 5 ++++-
>  3 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/amdtopology.c b/arch/x86/mm/amdtopology.c
> index 91f501b..7657042 100644
> --- a/arch/x86/mm/amdtopology.c
> +++ b/arch/x86/mm/amdtopology.c
> @@ -151,7 +151,6 @@ int __init amd_numa_init(void)
>  
>  		prevbase = base;
>  		numa_add_memblk(nodeid, base, limit);
> -		node_set(nodeid, numa_nodes_parsed);
>  	}
>  
>  	if (!nodes_weight(numa_nodes_parsed))
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 25504d5..8f87f26 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -150,6 +150,8 @@ static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
>  	mi->blk[mi->nr_blks].end = end;
>  	mi->blk[mi->nr_blks].nid = nid;
>  	mi->nr_blks++;
> +
> +	node_set(nid, numa_nodes_parsed);
>  	return 0;
>  }
>  
> @@ -693,7 +695,6 @@ static int __init dummy_numa_init(void)
>  	printk(KERN_INFO "Faking a node at [mem %#018Lx-%#018Lx]\n",
>  	       0LLU, PFN_PHYS(max_pfn) - 1);
>  
> -	node_set(0, numa_nodes_parsed);
>  	numa_add_memblk(0, 0, PFN_PHYS(max_pfn));
>  
>  	return 0;
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index 917f1cc..f2e33cb 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -294,7 +294,9 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
>  		goto out_err_bad_srat;
>  	}
>  
> -	node_set(node, numa_nodes_parsed);
> +	/* some architecture is likely to ignore a unreasonable node */
> +	if (!node_isset(node, numa_nodes_parsed))
> +		goto out;
>  
>  	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
>  		node, pxm,
> @@ -309,6 +311,7 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
>  
>  	max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
>  
> +out:
>  	return 0;
>  out_err_bad_srat:
>  	bad_srat();
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
