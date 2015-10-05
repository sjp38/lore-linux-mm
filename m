Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id BFA3A6B02F9
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 09:59:23 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so121392609wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 06:59:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mw14si7684499wic.6.2015.10.05.06.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Oct 2015 06:59:22 -0700 (PDT)
Subject: Re: [PATCH] ovs: do not allocate memory from offline numa node
References: <20151002101822.12499.27658.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56128238.8010305@suse.cz>
Date: Mon, 5 Oct 2015 15:59:20 +0200
MIME-Version: 1.0
In-Reply-To: <20151002101822.12499.27658.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
> When openvswitch tries allocate memory from offline numa node 0:
> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO, 0)
> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
> This patch disables numa affinity in this case.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

...

> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index f2ea83ba4763..c7f74aab34b9 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>
>   	/* Initialize the default stat node. */
>   	stats = kmem_cache_alloc_node(flow_stats_cache,
> -				      GFP_KERNEL | __GFP_ZERO, 0);
> +				      GFP_KERNEL | __GFP_ZERO,
> +				      node_online(0) ? 0 : NUMA_NO_NODE);

Stupid question: can node 0 become offline between this check, and the 
VM_WARN_ON? :) BTW what kind of system has node 0 offline?

>   	if (!stats)
>   		goto err;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
