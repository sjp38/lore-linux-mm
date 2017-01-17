Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 942E36B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:17:46 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so18313487wjc.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:17:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b205si16796081wmd.127.2017.01.17.10.17.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 10:17:44 -0800 (PST)
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-2-mgorman@techsingularity.net>
 <20170117190732.0fc733ec@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2df88f73-a32d-4b71-d4de-3a0ad8831d9a@suse.cz>
Date: Tue, 17 Jan 2017 19:17:22 +0100
MIME-Version: 1.0
In-Reply-To: <20170117190732.0fc733ec@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

On 01/17/2017 07:07 PM, Jesper Dangaard Brouer wrote:
> 
> On Tue, 17 Jan 2017 09:29:51 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
>> +/* Lock and remove page from the per-cpu list */
>> +static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>> +			struct zone *zone, unsigned int order,
>> +			gfp_t gfp_flags, int migratetype)
>> +{
>> +	struct per_cpu_pages *pcp;
>> +	struct list_head *list;
>> +	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>> +	struct page *page;
>> +	unsigned long flags;
>> +
>> +	local_irq_save(flags);
>> +	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>> +	list = &pcp->lists[migratetype];
>> +	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
>> +	if (page) {
>> +		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>> +		zone_statistics(preferred_zone, zone, gfp_flags);
> 
> Word-of-warning: The zone_statistics() call changed number of
> parameters in commit 41b6167e8f74 ("mm: get rid of __GFP_OTHER_NODE").
> (Not sure what tree you are based on)

Yeah and there will likely be more conflicts with fixes wrt the "getting
oom/stalls for ltp test cpuset01 with latest/4.9 kernela??" thread,
hopefully tomorrow.

>> +	}
>> +	local_irq_restore(flags);
>> +	return page;
>> +}
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
