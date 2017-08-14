Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36D4B6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 19:33:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so15757101wrc.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 16:33:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c13si6246793wrb.483.2017.08.14.16.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 16:33:39 -0700 (PDT)
Date: Mon, 14 Aug 2017 16:33:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: choose swap device according to numa node
Message-Id: <20170814163337.92c9f07666645366af82aba2@linux-foundation.org>
In-Reply-To: <20170814053130.GD2369@aaronlu.sh.intel.com>
References: <20170814053130.GD2369@aaronlu.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

On Mon, 14 Aug 2017 13:31:30 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> If the system has more than one swap device and swap device has the node
> information, we can make use of this information to decide which swap
> device to use in get_swap_pages() to get better performance.
> 
> The current code uses a priority based list, swap_avail_list, to decide
> which swap device to use and if multiple swap devices share the same
> priority, they are used round robin. This patch changes the previous
> single global swap_avail_list into a per-numa-node list, i.e. for each
> numa node, it sees its own priority based list of available swap devices.
> Swap device's priority can be promoted on its matching node's swap_avail_list.
> 
> The current swap device's priority is set as: user can set a >=0 value,
> or the system will pick one starting from -1 then downwards. The priority
> value in the swap_avail_list is the negated value of the swap device's
> due to plist being sorted from low to high. The new policy doesn't change
> the semantics for priority >=0 cases, the previous starting from -1 then
> downwards now becomes starting from -2 then downwards and -1 is reserved
> as the promoted value.
> 
> ...
>
> On a 2 node Skylake EP machine with 64GiB memory, two 170GB SSD drives
> are used as swap devices with each attached to a different node, the
> result is:
> 
> runtime=30m/processes=32/total test size=128G/each process mmap region=4G
> kernel         throughput
> vanilla        13306
> auto-binding   15169 +14%
> 
> runtime=30m/processes=64/total test size=128G/each process mmap region=2G
> kernel         throughput
> vanilla        11885
> auto-binding   14879 25%
> 

Sounds nice.

> ...
>
> --- /dev/null
> +++ b/Documentation/vm/swap_numa.txt
> @@ -0,0 +1,18 @@
> +If the system has more than one swap device and swap device has the node
> +information, we can make use of this information to decide which swap
> +device to use in get_swap_pages() to get better performance.
> +
> +The current code uses a priority based list, swap_avail_list, to decide
> +which swap device to use and if multiple swap devices share the same
> +priority, they are used round robin. This change here replaces the single
> +global swap_avail_list with a per-numa-node list, i.e. for each numa node,
> +it sees its own priority based list of available swap devices. Swap
> +device's priority can be promoted on its matching node's swap_avail_list.
> +
> +The current swap device's priority is set as: user can set a >=0 value,
> +or the system will pick one starting from -1 then downwards. The priority
> +value in the swap_avail_list is the negated value of the swap device's
> +due to plist being sorted from low to high. The new policy doesn't change
> +the semantics for priority >=0 cases, the previous starting from -1 then
> +downwards now becomes starting from -2 then downwards and -1 is reserved
> +as the promoted value.

Could we please add a little "user guide" here?  Tell people how to set
up their system to exploit this?  Sample /etc/fstab entries, perhaps?

>
> ...
>
> +static int __init swapfile_init(void)
> +{
> +	int nid;
> +
> +	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
> +	if (!swap_avail_heads)
> +		return -ENOMEM;

Well, a kmalloc failure at __init time is generally considered "can't
happen", but if it _does_ happen, the system will later oops, I think. 
Can we do something nicer here?


> +	for_each_node(nid)
> +		plist_head_init(&swap_avail_heads[nid]);
> +
> +	return 0;
> +}
> +subsys_initcall(swapfile_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
