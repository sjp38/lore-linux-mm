Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C21C6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 07:44:29 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id b35so336177368uaa.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 04:44:29 -0800 (PST)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id g125si3504799vkb.239.2016.12.05.04.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 04:44:28 -0800 (PST)
Received: by mail-vk0-x243.google.com with SMTP id p9so15995017vkd.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 04:44:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161202095841.16648-1-mhocko@kernel.org>
References: <20161202095841.16648-1-mhocko@kernel.org>
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 5 Dec 2016 23:44:27 +1100
Message-ID: <CAKTCnz=K8QG69tKB8yStiZypBzcvnE=wW+25xuo9f_HZNzPtDg@mail.gmail.com>
Subject: Re: [PATCH] mm, vmscan: add cond_resched into shrink_node_memcg
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Zhmurov <bb@kernelpanic.ru>, "Christopher S. Aker" <caker@theshore.net>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>

>
> Hi,
> there were multiple reportes of the similar RCU stalls. Only Boris has
> confirmed that this patch helps in his workload. Others might see a
> slightly different issue and that should be investigated if it is the
> case. As pointed out by Paul [1] cond_resched might be not sufficient
> to silence RCU stalls because that would require a real scheduling.
> This is a separate problem, though, and Paul is working with Peter [2]
> to resolve it.
>
> Anyway, I believe that this patch should be a good start because it
> really seems that nr_taken=0 during the LRU isolation can be triggered
> in the real life. All reporters are agreeing to start seeing this issue
> when moving on to 4.8 kernel which might be just a coincidence or a
> different behavior of some subsystem. Well, MM has moved from zone to
> node reclaim but I couldn't have found any direct relation to that
> change.
>
> [1] http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com
> [2] http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com
>
>  mm/vmscan.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c05f00042430..c4abf08861d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2362,6 +2362,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
>                         }
>                 }
>
> +               cond_resched();
> +

I see a cond_resched_rcu_qs() as a part of linux next inside the while
(nr[..]) loop.
Do we need this as well?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
