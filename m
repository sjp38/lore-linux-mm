Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4B2526B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:53:07 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2237083ggm.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2012 09:53:06 -0700 (PDT)
Message-ID: <5006E9E6.2030004@gmail.com>
Date: Thu, 19 Jul 2012 00:52:54 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node
 and CONFIG_SLUB_DEBUG is on
References: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207171237320.15177@router.home>
In-Reply-To: <alpine.DEB.2.00.1207171237320.15177@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Chris,
	I found the previous analysis of the BUG_ON() issue is incorrect after
another round of code review. 
	The really issue is that function early_kmem_cache_node_alloc() calls
inc_slabs_node(kmem_cache_node, node, page->objects) to increase the object 
count on local node no matter whether page is allocated from local or remote
node. With current implementation it's OK because every memory node has normal
memory so page is allocated from local node. Now we are working on a patch set
to improve memory hotplug. The basic idea is to to let some memory nodes only
host ZONE_MOVABLE zone, so we could easily remove the whole memory node when 
needed. That means some memory nodes have no ZONE_NORMAL/ZONE_DMA, and the page
will be allocated from remote node in function early_kmem_cache_node_alloc().
But early_kmem_cache_node_alloc() still increases object count on local node,
which triggers the BUG_ON eventually when removing the affected memory node.
	I will try to work out another version for it.
	Thanks!
	Gerry

On 07/18/2012 01:39 AM, Christoph Lameter wrote:
> On Wed, 18 Jul 2012, Jiang Liu wrote:
> 
>> From: Jianguo Wu <wujianguo@huawei.com>
>>
>> From: Jianguo Wu <wujianguo@huawei.com>
>>
>> SLUB allocator may cause a BUG_ON() when offlining a memory node if
>> CONFIG_SLUB_DEBUG is on. The scenario is:
>>
>> 1) when creating kmem_cache_node slab, it cause inc_slabs_node() twice.
>> early_kmem_cache_node_alloc
>> 	->new_slab
>> 		->inc_slabs_node
>> 	->inc_slabs_node
> 
> New slab will not be able to increment the slab counter. It will
> check that there is no per node structure yet and then skip the inc slabs
> node.
> 
> This suggests that a call to early_kmem_cache_node_alloc was not needed
> because the per node structure already existed. Lets fix that instead.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
