Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E87626B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 06:58:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so101744224wmp.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 03:58:30 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id j6si21914012wmd.67.2016.11.09.03.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 03:58:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id EC34E1C1804
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 11:58:28 +0000 (GMT)
Date: Wed, 9 Nov 2016 11:58:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] mem-hotplug: shall we skip unmovable node when doing numa
 balance?
Message-ID: <20161109115827.GD3614@techsingularity.net>
References: <582157E5.8000106@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <582157E5.8000106@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "robert.liu@huawei.com" <robert.liu@huawei.com>

On Tue, Nov 08, 2016 at 12:43:17PM +0800, Xishi Qiu wrote:
> On mem-hotplug system, there is a problem, please see the following case.
> 
> memtester xxG, the memory will be alloced on a movable node. And after numa
> balancing, the memory may be migrated to the other node, it may be a unmovable
> node. This will reduce the free memory of the unmovable node, and may be oom
> later.
> 

How would it OOM later? It's movable memmory that is moving via
automatic NUMA balancing so at the very least it can be reclaimed. If
the memory is mlocked or unable to migrate then it's irrelevant if
automatic balancing put it there.

> My question is that shall we skip unmovable node when doing numa balance?
> or just let the manager set some numa policies?
> 

If the unmovable node must be protected from automatic NUMA balancing
then policies are the appropriate step to prevent the processes running
on that node or from allocating memory on that node.

Either way, protecting unmovable nodes in the name of hotplug is pretty
much guaranteed to be a performance black hole because at the very
least, page table pages will always be remote accesses for processes
running on the unmovable node.

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 057964d..f0954ac 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2334,6 +2334,13 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  out:
>  	mpol_cond_put(pol);
>  
> +	/* Skip unmovable nodes when do numa balancing */
> +	if (movable_node_enabled && ret != -1) {
> +		zone = NODE_DATA(ret)->node_zones + MAX_NR_ZONES - 1;
> +		if (!populated_zone(zone))
> +			ret = -1;
> +	}
> +
>  	return ret;
>  }

Nak.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
