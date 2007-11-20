Subject: Re: [PATCH 4/6] Have zonelist contains structs with both a zone
	pointer and zone_idx
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071109143346.23540.69776.sendpatchset@skynet.skynet.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	 <20071109143346.23540.69776.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Tue, 20 Nov 2007 10:34:53 -0500
Message-Id: <1195572894.5041.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-09 at 14:33 +0000, Mel Gorman wrote:
> Filtering zonelists requires very frequent use of zone_idx(). This is costly
> as it involves a lookup of another structure and a substraction operation. As
> the zone_idx is often required, it should be quickly accessible.  The node
> idx could also be stored here if it was found that accessing zone->node is
> significant which may be the case on workloads where nodemasks are heavily
> used.
> 
> This patch introduces a struct zoneref to store a zone pointer and a zone
> index.  The zonelist then consists of an array of this struct zonerefs which
> are looked up as necessary. Helpers are given for accessing the zone index
> as well as the node index.
> 
> [kamezawa.hiroyu@jp.fujitsu.com: Suggested struct zoneref instead of embedding information in pointers]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <clameter@sgi.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
> 
>  arch/parisc/mm/init.c  |    2 -
>  fs/buffer.c            |    6 ++--
>  include/linux/mmzone.h |   64 +++++++++++++++++++++++++++++++++++++-------
>  include/linux/oom.h    |    4 +-
>  kernel/cpuset.c        |    4 +-
>  mm/hugetlb.c           |    3 +-
>  mm/mempolicy.c         |   35 ++++++++++++++----------
>  mm/oom_kill.c          |   45 +++++++++++++++---------------
>  mm/page_alloc.c        |   59 ++++++++++++++++++++--------------------
>  mm/slab.c              |    2 -
>  mm/slub.c              |    2 -
>  mm/vmscan.c            |    7 ++--
>  mm/vmstat.c            |    5 ++-
>  13 files changed, 145 insertions(+), 93 deletions(-)
> 
<snip>
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-010_use_two_zonelists/kernel/cpuset.c linux-2.6.24-rc1-mm-020_zoneid_zonelist/kernel/cpuset.c
> --- linux-2.6.24-rc1-mm-010_use_two_zonelists/kernel/cpuset.c	2007-10-24 04:50:57.000000000 +0100
> +++ linux-2.6.24-rc1-mm-020_zoneid_zonelist/kernel/cpuset.c	2007-11-08 19:18:27.000000000 +0000
> @@ -1877,8 +1877,8 @@ int cpuset_zonelist_valid_mems_allowed(s
>  {
>  	int i;
>  
> -	for (i = 0; zl->zones[i]; i++) {
> -		int nid = zone_to_nid(zl->zones[i]);
> +	for (i = 0; zl->_zonerefs[i].zone; i++) {
> +		int nid = zonelist_node_idx(zl->_zonerefs[i]);

Should be:
 +		  int nid = zonelist_node_idx(&zl->_zonerefs[i]);
                                              ^
else doesn't build.  Stand by for testing...

>  
>  		if (node_isset(nid, current->mems_allowed))
>  			return 1;
<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
