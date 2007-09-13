Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070912210625.31625.36220.sendpatchset@skynet.skynet.ie>
References: <20070912210444.31625.65810.sendpatchset@skynet.skynet.ie>
	 <20070912210625.31625.36220.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 11:49:40 -0400
Message-Id: <1189698581.5013.74.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 22:06 +0100, Mel Gorman wrote:
> The MPOL_BIND policy creates a zonelist that is used for allocations belonging
> to that thread that can use the policy_zone. As the per-node zonelist is
> already being filtered based on a zone id, this patch adds a version of
> __alloc_pages() that takes a nodemask for further filtering. This eliminates
> the need for MPOL_BIND to create a custom zonelist. A positive benefit of
> this is that allocations using MPOL_BIND now use the local-node-ordered
> zonelist instead of a custom node-id-ordered zonelist.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> 
>  fs/buffer.c               |    2 
>  include/linux/cpuset.h    |    4 -
>  include/linux/gfp.h       |    4 +
>  include/linux/mempolicy.h |    3 
>  include/linux/mmzone.h    |   65 ++++++++++++++----
>  kernel/cpuset.c           |   18 +----
>  mm/mempolicy.c            |  145 ++++++++++++-----------------------------
>  mm/page_alloc.c           |   40 +++++++----
>  8 files changed, 136 insertions(+), 145 deletions(-)
<snip>
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-020_zoneid_zonelist/kernel/cpuset.c linux-2.6.23-rc4-mm1-030_filter_nodemask/kernel/cpuset.c
> --- linux-2.6.23-rc4-mm1-020_zoneid_zonelist/kernel/cpuset.c	2007-09-12 16:05:35.000000000 +0100
> +++ linux-2.6.23-rc4-mm1-030_filter_nodemask/kernel/cpuset.c	2007-09-12 16:05:44.000000000 +0100
> @@ -1516,22 +1516,14 @@ nodemask_t cpuset_mems_allowed(struct ta
>  }
>  
>  /**
> - * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
> - * @zl: the zonelist to be checked
> + * cpuset_nodemask_valid_mems_allowed - check nodemask vs. curremt mems_allowed
> + * @nodemask: the nodemask to be checked
>   *
> - * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
> + * Are any of the nodes in the nodemask allowed in current->mems_allowed?
>   */
> -int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
> +int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
>  {
> -	int i;
> -
> -	for (i = 0; zl->_zonerefs[i].zone; i++) {
> -		int nid = zonelist_node_idx(zl->_zonerefs[i]);
> -
> -		if (node_isset(nid, current->mems_allowed))
> -			return 1;
> -	}
> -	return 0;
> +	return nodes_intersect(nodemask, current->mems_allowed);
                 nodes_intersects(*nodemask, ... 
>  }
>  
>  /*
<snip>

Still preping for test.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
