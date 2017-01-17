Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD0576B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:07:38 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so145174303qtg.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:07:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g8si17162454qtc.212.2017.01.17.10.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 10:07:37 -0800 (PST)
Date: Tue, 17 Jan 2017 19:07:32 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Message-ID: <20170117190732.0fc733ec@redhat.com>
In-Reply-To: <20170117092954.15413-2-mgorman@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
	<20170117092954.15413-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, brouer@redhat.com, Michal Hocko <mhocko@suse.com>


On Tue, 17 Jan 2017 09:29:51 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> +/* Lock and remove page from the per-cpu list */
> +static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> +			struct zone *zone, unsigned int order,
> +			gfp_t gfp_flags, int migratetype)
> +{
> +	struct per_cpu_pages *pcp;
> +	struct list_head *list;
> +	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> +	struct page *page;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> +	list = &pcp->lists[migratetype];
> +	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
> +	if (page) {
> +		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> +		zone_statistics(preferred_zone, zone, gfp_flags);

Word-of-warning: The zone_statistics() call changed number of
parameters in commit 41b6167e8f74 ("mm: get rid of __GFP_OTHER_NODE").
(Not sure what tree you are based on)

> +	}
> +	local_irq_restore(flags);
> +	return page;
> +}


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
