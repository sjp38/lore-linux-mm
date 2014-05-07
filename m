Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C1E996B004D
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:20:35 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id g10so1570188pdj.3
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:20:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tf5si10607264pac.49.2014.05.07.14.20.34
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 14:20:34 -0700 (PDT)
Date: Wed, 7 May 2014 14:20:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
Message-Id: <20140507142033.1ec148fe35059121db547f25@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 May 2014 19:22:52 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Async compaction terminates prematurely when need_resched(), see
> compact_checklock_irqsave().  This can never trigger, however, if the 
> cond_resched() in isolate_migratepages_range() always takes care of the 
> scheduling.
> 
> If the cond_resched() actually triggers, then terminate this pageblock scan for 
> async compaction as well.
> 
> ..
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -500,8 +500,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			return 0;
>  	}
>  
> +	if (cond_resched()) {
> +		/* Async terminates prematurely on need_resched() */
> +		if (cc->mode == MIGRATE_ASYNC)
> +			return 0;
> +	}

Comment comments the obvious.  What is less obvious is *why* we do this.


Someone please remind my why sync and async compaction use different
scanning cursors?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
