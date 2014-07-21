Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 05E586B0080
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:42:27 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id id10so8049671vcb.35
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:42:25 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id n11si27106841qgd.126.2014.07.21.10.42.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:42:24 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 21 Jul 2014 13:42:24 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CA3CD6E804D
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:42:12 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6LHgMEK50987074
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:42:22 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6LHgL7O014410
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:42:22 -0400
Date: Mon, 21 Jul 2014 10:42:18 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140721174218.GD4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny <carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>, Greg Rose <gregory.v.rose@intel.com>, Alex Duyck <alexander.h.duyck@intel.com>, John Ronciak <john.ronciak@intel.com>, Mitch Williams <mitch.a.williams@intel.com>, Linux NICS <linux.nics@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org

On 11.07.2014 [15:37:32 +0800], Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
> 
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index f145adbb55ac..2b74bffa5648 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6518,7 +6518,7 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
>  				  unsigned int truesize)
>  {
>  	/* avoid re-using remote pages */
> -	if (unlikely(page_to_nid(page) != numa_node_id()))
> +	if (unlikely(page_to_nid(page) != numa_mem_id()))
>  		return false;
> 
>  #if (PAGE_SIZE < 8192)
> @@ -6588,7 +6588,7 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
>  		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
> 
>  		/* we can reuse buffer as-is, just make sure it is local */
> -		if (likely(page_to_nid(page) == numa_node_id()))
> +		if (likely(page_to_nid(page) == numa_mem_id()))
>  			return true;
> 
>  		/* this page cannot be reused so discard it */

This doesn't seem to have anything to do with crashes or errors?

The original code is checking if the NUMA node of a page is remote to
the NUMA node current is running on. Your change makes it check if the
NUMA node of a page is not equal to the nearest NUMA node with memory.
That's not necessarily local, though, which seems like that is the whole
point. In this case, perhaps the driver author doesn't want to reuse the
memory at all for performance reasons? In any case, I don't think this
patch has appropriate justification.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
