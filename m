Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE56C6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 22:26:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so1531972311pgi.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 19:26:53 -0800 (PST)
Received: from out0-144.mail.aliyun.com (out0-144.mail.aliyun.com. [140.205.0.144])
        by mx.google.com with ESMTP id 129si77893812pgi.256.2017.01.05.19.26.50
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 19:26:52 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170104111049.15501-1-mgorman@techsingularity.net> <20170104111049.15501-4-mgorman@techsingularity.net>
In-Reply-To: <20170104111049.15501-4-mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for irq-safe requests
Date: Fri, 06 Jan 2017 11:26:46 +0800
Message-ID: <00ee01d267cc$b61feaa0$225fbfe0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Jesper Dangaard Brouer' <brouer@redhat.com>
Cc: 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>


On Wednesday, January 04, 2017 7:11 PM Mel Gorman wrote: 
> @@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	struct list_head *list;
>  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  	struct page *page;
> -	unsigned long flags;
> 
> -	local_irq_save(flags);
> +	preempt_disable();
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
> @@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  		zone_statistics(preferred_zone, zone, gfp_flags);
>  	}
> -	local_irq_restore(flags);
> +	preempt_enable();
>  	return page;
>  }
> 
With PREEMPT configured, preempt_enable() adds entry point to schedule().
Is that needed when we try to allocate a page?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
