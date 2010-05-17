Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E502A600385
	for <linux-mm@kvack.org>; Mon, 17 May 2010 12:13:21 -0400 (EDT)
Date: Mon, 17 May 2010 11:09:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mem-hotplug: fix potential race while building
 zonelist for new populated zone
In-Reply-To: <4BF0FC4C.4060306@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1005171108070.20764@router.home>
References: <4BF0FC4C.4060306@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 May 2010, Haicheng Li wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 72c1211..0729a82 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2783,6 +2783,20 @@ static __init_refok int __build_all_zonelists(void
> *data)
>  {
>  	int nid;
>  	int cpu;
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	struct zone_online_info *new = (struct zone_online_info *)data;
> +
> +	/*
> +	 * Populate the new zone before build zonelists, which could
> +	 * happen only when onlining a new node after system is booted.
> +	 */
> +	if (new) {
> +		/* We are expecting a new memory block here. */
> +		WARN_ON(!new->onlined_pages);
> +		new->zone->present_pages += new->onlined_pages;
> +		new->zone->zone_pgdat->node_present_pages +=
> new->onlined_pages;
> +	}
> +#endif


Building a zonelist now has the potential side effect of changes to the
size of the zone?

Can we have a global mutex that protects against size modification of
zonelists instead? And it could also serialize the pageset setup?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
