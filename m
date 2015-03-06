Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id A1D006B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 16:07:04 -0500 (EST)
Received: by igbhn18 with SMTP id hn18so7206718igb.2
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:07:04 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id 82si87685ioz.62.2015.03.06.13.07.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 13:07:04 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so6159087iec.5
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:07:04 -0800 (PST)
Date: Fri, 6 Mar 2015 13:07:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Allow compaction of unevictable pages
In-Reply-To: <1425667287-30841-1-git-send-email-emunson@akamai.com>
Message-ID: <alpine.DEB.2.10.1503061301500.10330@chino.kir.corp.google.com>
References: <1425667287-30841-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Mar 2015, Eric B Munson wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..33c81e1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1056,7 +1056,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  {
>  	unsigned long low_pfn, end_pfn;
>  	struct page *page;
> -	const isolate_mode_t isolate_mode =
> +	const isolate_mode_t isolate_mode = ISOLATE_UNEVICTABLE |
>  		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
>  
>  	/*

I agree that memory compaction should be isolating and migrating 
unevictable memory for better results, and we have been running with a 
similar patch internally for about a year for the same purpose as you, 
higher probability of allocating hugepages.

This would be better off removing the notion of ISOLATE_UNEVICTABLE 
entirely, however, since CMA and now memory compaction would be using it, 
so the check in __isolate_lru_page() is no longer necessary.  Has the 
added bonus of removing about 10 lines of soure code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
