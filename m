Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AF2736B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 05:50:50 -0500 (EST)
Date: Thu, 5 Jan 2012 10:50:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm/compaction : fix the wrong return value for
 isolate_migratepages()
Message-ID: <20120105105044.GE28031@suse.de>
References: <1325322585-16216-1-git-send-email-b32955@freescale.com>
 <20120105101222.GD28031@suse.de>
 <4F057BF2.5040206@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F057BF2.5040206@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

On Thu, Jan 05, 2012 at 06:31:14PM +0800, Huang Shijie wrote:
> >Why?
> >
> >
> >Returning ISOLATE_SUCCESS means that we fall through. This means busy
> >work in migrate_pages(), updating list accounting and the list. It's
> >wasteful but is it functionally incorrect? What problem did you observe?
>
> there may are many times the cc->migratepages is zero, but the
> return value is ISOLATE_SUCCESS.
> 

Ok, this is a reasonable assertion. How often will depend on a large
number of factors.

> >If this is simply a performance issue then minimally COMPACTBLOCKS
>
> yes, My concern is the performance.
> 

For future reference, please explain this in the changelog.

> the comment of ISOLATE_NONE makes me confused.  :(
> 

I see your confusion. The main difference between ISOLATE_NONE and
ISOLATE_SUCCESS is that scanning within the pageblock took place even
if no pages were isolated by the scan. Maybe it would be easier if
your patch clarified the meaning of the return values. Something like;

typedef enum {
        ISOLATE_ABORT,          /* Abort compaction now */
        ISOLATE_NONE,           /* No pages scanned, consider next pageblock */
        ISOLATE_SUCCESS,        /* Pages scanned and maybe isolated, migrate */
} isolate_migrate_t;

and then check if pages were really isolated on ISOLATE_SUCCESS?


> If you think we should update the COMPACTBLOCK in this case, my
> patch is wrong.
> 

I think the overhead is unnecessary and worth fixing but because the
scanning took place, the COMPACTBLOCK counter should be bumped and
the tracepoint triggered.

> >still needs to be updated, we still want to see the tracepoint etc. To
>
> ok.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
