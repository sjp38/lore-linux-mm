Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id CC7CD6B0299
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 20:00:13 -0500 (EST)
Date: Tue, 13 Dec 2011 17:00:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: clean up soft_limit_tree properly new
Message-Id: <20111213170012.8fe53c90.akpm@linux-foundation.org>
In-Reply-To: <20111212140935.GF14720@tiehlicka.suse.cz>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
	<alpine.LSU.2.00.1112111520510.2297@eggly>
	<20111212131118.GA15249@tiehlicka.suse.cz>
	<CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
	<20111212140750.GE14720@tiehlicka.suse.cz>
	<20111212140935.GF14720@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 12 Dec 2011 15:09:35 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> And a follow up patch for the proper clean up:
> ---
> >From 4b9f5a1e88496af9f336d1ef37cfdf3754a3ba48 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 12 Dec 2011 15:04:18 +0100
> Subject: [PATCH] memcg: clean up soft_limit_tree properly
> 
> If we are not able to allocate tree nodes for all NUMA nodes then we
> should better clean up those that were allocated otherwise we will leak
> a memory.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6aff93c..838d812 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4874,7 +4874,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  			tmp = -1;
>  		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
>  		if (!rtpn)
> -			return 1;
> +			goto err_cleanup;
>  
>  		soft_limit_tree.rb_tree_per_node[node] = rtpn;
>  
> @@ -4885,6 +4885,16 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  		}
>  	}
>  	return 0;
> +
> +err_cleanup:
> +	for_each_node_state(node, N_POSSIBLE) {
> +		if (!soft_limit_tree.rb_tree_per_node[node])
> +			break;
> +		kfree(soft_limit_tree.rb_tree_per_node[node]);
> +		soft_limit_tree.rb_tree_per_node[node] = NULL;
> +	}
> +	return 1;
> +
>  }

afacit the kernel never frees the soft_limit_tree.rb_tree_per_node[]
entries on the mem_cgroup_destroy() path.  Bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
