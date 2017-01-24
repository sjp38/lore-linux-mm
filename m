Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E94736B0260
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:16:12 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so26720675wmi.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:16:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w81si18319273wmg.39.2017.01.24.05.16.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 05:16:11 -0800 (PST)
Subject: Re: [PATCH 4/4] mm, page_alloc: Only use per-cpu allocator for
 irq-safe requests
References: <20170123153906.3122-1-mgorman@techsingularity.net>
 <20170123153906.3122-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <66455e10-f014-ba8f-3449-4c16aa0c402c@suse.cz>
Date: Tue, 24 Jan 2017 14:16:10 +0100
MIME-Version: 1.0
In-Reply-To: <20170123153906.3122-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/23/2017 04:39 PM, Mel Gorman wrote:
> Many workloads that allocate pages are not handling an interrupt at a
> time. As allocation requests may be from IRQ context, it's necessary to
> disable/enable IRQs for every page allocation. This cost is the bulk
> of the free path but also a significant percentage of the allocation
> path.
> 
> This patch alters the locking and checks such that only irq-safe allocation
> requests use the per-cpu allocator. All others acquire the irq-safe
> zone->lock and allocate from the buddy allocator. It relies on disabling
> preemption to safely access the per-cpu structures. It could be slightly
> modified to avoid soft IRQs using it but it's not clear it's worthwhile.
> 
> This modification may slow allocations from IRQ context slightly but the main
> gain from the per-cpu allocator is that it scales better for allocations
> from multiple contexts. There is an implicit assumption that intensive
> allocations from IRQ contexts on multiple CPUs from a single NUMA node are
> rare and that the fast majority of scaling issues are encountered in !IRQ
> contexts such as page faulting. It's worth noting that this patch is not
> required for a bulk page allocator but it significantly reduces the overhead.
> 
[...]

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
