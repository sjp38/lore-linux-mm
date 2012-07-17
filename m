Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 18E456B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 13:39:05 -0400 (EDT)
Date: Tue, 17 Jul 2012 12:39:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node
 and CONFIG_SLUB_DEBUG is on
In-Reply-To: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1207171237320.15177@router.home>
References: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Jul 2012, Jiang Liu wrote:

> From: Jianguo Wu <wujianguo@huawei.com>
>
> From: Jianguo Wu <wujianguo@huawei.com>
>
> SLUB allocator may cause a BUG_ON() when offlining a memory node if
> CONFIG_SLUB_DEBUG is on. The scenario is:
>
> 1) when creating kmem_cache_node slab, it cause inc_slabs_node() twice.
> early_kmem_cache_node_alloc
> 	->new_slab
> 		->inc_slabs_node
> 	->inc_slabs_node

New slab will not be able to increment the slab counter. It will
check that there is no per node structure yet and then skip the inc slabs
node.

This suggests that a call to early_kmem_cache_node_alloc was not needed
because the per node structure already existed. Lets fix that instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
