Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3F77E6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:19:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B5A5D3EE0BD
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:19:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B02C45DE59
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:19:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 817DB45DE58
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:19:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ECF11DB8056
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:19:02 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F4B81DB8047
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:19:01 +0900 (JST)
Message-ID: <515942D8.1070301@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 17:18:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 23/28] lru: add an element to a memcg list
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-24-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-24-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

(2013/03/29 18:14), Glauber Costa wrote:
> With the infrastructure we now have, we can add an element to a memcg
> LRU list instead of the global list. The memcg lists are still
> per-node.
> 
> Technically, we will never trigger per-node shrinking in the memcg is
> short of memory. Therefore an alternative to this would be to add the
> element to *both* a single-node memcg array and a per-node global array.
> 

per-node shrinking by memcg pressure is not imporant, I think.


> There are two main reasons for this design choice:
> 
> 1) adding an extra list_head to each of the objects would waste 16-bytes
> per object, always remembering that we are talking about 1 dentry + 1
> inode in the common case. This means a close to 10 % increase in the
> dentry size, and a lower yet significant increase in the inode size. In
> terms of total memory, this design pays 32-byte per-superblock-per-node
> (size of struct list_lru_node), which means that in any scenario where
> we have more than 10 dentries + inodes, we would already be paying more
> memory in the two-list-heads approach than we will here with 1 node x 10
> superblocks. The turning point of course depends on the workload, but I
> hope the figures above would convince you that the memory footprint is
> in my side in any workload that matters.
> 
> 2) The main drawback of this, namely, that we loose global LRU order, is
> not really seen by me as a disadvantage: if we are using memcg to
> isolate the workloads, global pressure should try to balance the amount
> reclaimed from all memcgs the same way the shrinkers will already
> naturally balance the amount reclaimed from each superblock. (This
> patchset needs some love in this regard, btw).
> 
> To help us easily tracking down which nodes have and which nodes doesn't
> have elements in the list, we will count on an auxiliary node bitmap in
> the global level.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>   include/linux/list_lru.h   | 10 +++++++
>   include/linux/memcontrol.h | 10 +++++++
>   lib/list_lru.c             | 68 +++++++++++++++++++++++++++++++++++++++-------
>   mm/memcontrol.c            | 38 +++++++++++++++++++++++++-
>   4 files changed, 115 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index d6cf126..0856899 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -26,6 +26,7 @@ struct list_lru_array {
>   
>   struct list_lru {
>   	struct list_lru_node	node[MAX_NUMNODES];
> +	atomic_long_t		node_totals[MAX_NUMNODES];

some comments will be helpful. 

>   	nodemask_t		active_nodes;
>   #ifdef CONFIG_MEMCG_KMEM
>   	struct list_head	lrus;
> @@ -40,10 +41,19 @@ int memcg_update_all_lrus(unsigned long num);
>   void list_lru_destroy(struct list_lru *lru);
>   void list_lru_destroy_memcg(struct mem_cgroup *memcg);
>   int __memcg_init_lru(struct list_lru *lru);
> +struct list_lru_node *
> +lru_node_of_index(struct list_lru *lru, int index, int nid);
>   #else
>   static inline void list_lru_destroy(struct list_lru *lru)
>   {
>   }
> +
> +static inline struct list_lru_node *
> +lru_node_of_index(struct list_lru *lru, int index, int nid)
> +{
> +	BUG_ON(index < 0); /* index != -1 with !MEMCG_KMEM. Impossible */
> +	return &lru->node[nid];
> +}
>   #endif

I'm sorry ...what "lru_node_of_index" means ? What is the "index" ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
