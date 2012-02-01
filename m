Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 848BD6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:46:52 -0500 (EST)
Date: Wed, 1 Feb 2012 12:46:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: compaction: make compact_control order signed
Message-Id: <20120201124651.9203acde.akpm@linux-foundation.org>
In-Reply-To: <20120201144101.GA5397@elgon.mountain>
References: <20120201144101.GA5397@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Wed, 1 Feb 2012 17:41:01 +0300
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> "order" is -1 when compacting via /proc/sys/vm/compact_memory.  Making
> it unsigned causes a bug in __compact_pgdat() when we test:
> 
> 	if (cc->order < 0 || !compaction_deferred(zone, cc->order))
> 		compact_zone(zone, cc);
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 382831e..5f80a11 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -35,7 +35,7 @@ struct compact_control {
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>  	bool sync;			/* Synchronous migration */
>  
> -	unsigned int order;		/* order a direct compactor needs */
> +	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
>  };

One would expect this to significantly change the behaviour of
/proc/sys/vm/compact_memory.  Enfeebled minds want to know: is
the new behaviour better or worse than the old behaviour?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
