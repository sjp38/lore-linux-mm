Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EADD16B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 19:06:11 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n12so1721770wmc.5
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 16:06:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x8si5156183wrd.69.2018.03.02.16.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 16:06:10 -0800 (PST)
Date: Fri, 2 Mar 2018 16:06:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: make start_isolate_page_range() fail if already
 isolated
Message-Id: <20180302160607.570e13f2157f56503fe1bdaa@linux-foundation.org>
In-Reply-To: <20180226191054.14025-2-mike.kravetz@oracle.com>
References: <20180226191054.14025-1-mike.kravetz@oracle.com>
	<20180226191054.14025-2-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 26 Feb 2018 11:10:54 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> start_isolate_page_range() is used to set the migrate type of a
> set of page blocks to MIGRATE_ISOLATE while attempting to start
> a migration operation.  It assumes that only one thread is
> calling it for the specified range.  This routine is used by
> CMA, memory hotplug and gigantic huge pages.  Each of these users
> synchronize access to the range within their subsystem.  However,
> two subsystems (CMA and gigantic huge pages for example) could
> attempt operations on the same range.  If this happens, page
> blocks may be incorrectly left marked as MIGRATE_ISOLATE and
> therefore not available for page allocation.
> 
> Without 'locking code' there is no easy way to synchronize access
> to the range of page blocks passed to start_isolate_page_range.
> However, if two threads are working on the same set of page blocks
> one will stumble upon blocks set to MIGRATE_ISOLATE by the other.
> In such conditions, make the thread noticing MIGRATE_ISOLATE
> clean up as normal and return -EBUSY to the caller.
> 
> This will allow start_isolate_page_range to serve as a
> synchronization mechanism and will allow for more general use
> of callers making use of these interfaces.  So, update comments
> in alloc_contig_range to reflect this new functionality.
> 
> ...
>
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -28,6 +28,13 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
>  
>  	spin_lock_irqsave(&zone->lock, flags);
>  
> +	/*
> +	 * We assume we are the only ones trying to isolate this block.
> +	 * If MIGRATE_ISOLATE already set, return -EBUSY
> +	 */
> +	if (is_migrate_isolate_page(page))
> +		goto out;
> +
>  	pfn = page_to_pfn(page);
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = pageblock_nr_pages;

Seems a bit ugly and I'm not sure that it's correct.  If the loop in
start_isolate_page_range() gets partway through a number of pages then
we hit the race, start_isolate_page_range() will then go and "undo" the
work being done by the thread which it is racing against?

Even if that can't happen, blundering through a whole bunch of pages
then saying whoops then undoing everything is unpleasing.

Should we be looking at preventing these races at a higher level?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
