Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id F41366B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 14:53:19 -0400 (EDT)
Date: Wed, 18 Jul 2012 13:53:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node
 and CONFIG_SLUB_DEBUG is on
In-Reply-To: <5006E9E6.2030004@gmail.com>
Message-ID: <alpine.DEB.2.00.1207181349370.22907@router.home>
References: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207171237320.15177@router.home> <5006E9E6.2030004@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jul 2012, Jiang Liu wrote:

> 	I found the previous analysis of the BUG_ON() issue is incorrect after
> another round of code review.
> 	The really issue is that function early_kmem_cache_node_alloc() calls
> inc_slabs_node(kmem_cache_node, node, page->objects) to increase the object
> count on local node no matter whether page is allocated from local or remote
> node. With current implementation it's OK because every memory node has normal
> memory so page is allocated from local node. Now we are working on a patch set
> to improve memory hotplug. The basic idea is to to let some memory nodes only
> host ZONE_MOVABLE zone, so we could easily remove the whole memory node when
> needed. That means some memory nodes have no ZONE_NORMAL/ZONE_DMA, and the page
> will be allocated from remote node in function early_kmem_cache_node_alloc().
> But early_kmem_cache_node_alloc() still increases object count on local node,
> which triggers the BUG_ON eventually when removing the affected memory node.

That does not work. If the node does only have ZONE_MOVABLE then no slab
object can be allocated from the zone. You need to modify the slab
allocators to not allocate a per node structure for those zones and forbit
all allocations from such a node. Actually that should already work
because only ZONE_NORMAL nodes should get a per node structure because
slab objects can only be allocated from ZONE_NORMAL.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
