Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8CCA96B011D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:33:22 -0400 (EDT)
Date: Tue, 30 Apr 2013 17:33:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 11/31] list_lru: per-node list infrastructure
Message-ID: <20130430163317.GK6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-12-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-12-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:07AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that we have an LRU list API, we can start to enhance the
> implementation.  This splits the single LRU list into per-node lists
> and locks to enhance scalability. Items are placed on lists
> according to the node the memory belongs to. To make scanning the
> lists efficient, also track whether the per-node lists have entries
> in them in a active nodemask.
> 
> [ glommer: fixed warnings ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> ---
>  include/linux/list_lru.h |  14 ++--
>  lib/list_lru.c           | 162 +++++++++++++++++++++++++++++++++++------------
>  2 files changed, 130 insertions(+), 46 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index c0b796d..c422782 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -8,6 +8,7 @@
>  #define _LRU_LIST_H
>  
>  #include <linux/list.h>
> +#include <linux/nodemask.h>
>  
>  enum lru_status {
>  	LRU_REMOVED,		/* item removed from list */
> @@ -17,20 +18,21 @@ enum lru_status {
>  				   internally, but has to return locked. */
>  };
>  
> -struct list_lru {
> +struct list_lru_node {
>  	spinlock_t		lock;
>  	struct list_head	list;
>  	long			nr_items;
> +} ____cacheline_aligned_in_smp;
> +
> +struct list_lru {
> +	struct list_lru_node	node[MAX_NUMNODES];
> +	nodemask_t		active_nodes;
>  };

struct list_lru is going to be large. 64K just for the list_lru_nodes on a
distribution configuration that has NODES_SHIFT==10. On most machines it'll
be mostly unused space. How big is super_block now with two of these things?
xfs_buftarg? They are rarely allocated structures but it would be a little
embarassing if we failed to mount a usb stick because kmalloc() of some
large buffer failed on a laptop.

You may need to convert "list_lru_node node" to be an array of MAX_NUMNODES
pointers to list_lru_nodes. It'd need a lookup helper for list_lru_add
and list_lru_del that lazily allocates the list_lru_nodes on first usage
in case of node hot-add. You could allocate the online nodes at
list_lru_init.

It'd be awkward but avoid the need for a large kmalloc at runtime just
because someone plugged in a USB stick.

Otherwise I didn't spot a major problem. There are now per-node lists to
walk but the overall size of the LRU for walkers should be similar and
the additional overhead in list_lru_count is hardly going to be
noticable. I liked the use of active_mask.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
