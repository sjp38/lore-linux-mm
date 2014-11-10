Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A15E82BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 01:05:25 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so7588563pab.38
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 22:05:25 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id u7si15640255pdj.64.2014.11.09.22.05.22
        for <linux-mm@kvack.org>;
        Sun, 09 Nov 2014 22:05:24 -0800 (PST)
Date: Mon, 10 Nov 2014 15:07:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Message-ID: <20141110060726.GA4900@js1304-P5Q-DELUXE>
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos>
 <3583067.00bS4AInhm@xorhgos3.pefnos>
 <545BEA3B.40005@suse.cz>
 <3443150.6EQzxj6Rt9@xorhgos3.pefnos>
 <545E96BD.5040103@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545E96BD.5040103@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "P. Christeas" <xrg@linux.gr>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, Markus Trippelsdorf <markus@trippelsdorf.de>, Pavel Machek <pavel@ucw.cz>

On Sat, Nov 08, 2014 at 11:18:37PM +0100, Vlastimil Babka wrote:
> On 11/08/2014 02:11 PM, P. Christeas wrote:
> > On Thursday 06 November 2014, Vlastimil Babka wrote:
> >>> On Wednesday 05 November 2014, Vlastimil Babka wrote:
> >>>> Can you please try the following patch?
> >>>> -			compaction_defer_reset(zone, order, false);
> >> Oh and did I ask in this thread for /proc/zoneinfo yet? :)
> > 
> > Using that same kernel[1], got again into a race, gathered a few more data.
> > 
> > This time, I had 1x "urpmq" process [2] hung at 100% CPU , when "kwin" got 
> > apparently blocked (100% CPU, too) trying to resize a GUI window. I suppose 
> > the resizing operation would mean heavy memory alloc/free.
> > 
> > The rest of the system was responsive, I could easily get a console, login, 
> > gather the files.. Then, I have *killed* -9 the "urpmq" process, which solved 
> > the race and my system is still alive! "kwin" is still running, returned to 
> > regular CPU load.
> > 
> > Attached is traces from SysRq+l (pressed a few times, wanted to "snapshot" the 
> > stack) and /proc/zoneinfo + /proc/vmstat
> > 
> > Bisection is not yet meaningful, IMHO, because I cannot be sure that "good" 
> > points are really free from this issue. I'd estimate that each test would take 
> > +3days, unless I really find a deterministic way to reproduce the issue .
> 
> Hi,
> 
> I think I finally found the cause by staring into the code... CCing
> people from all 4 separate threads I know about this issue.
> The problem with finding the cause was that the first report I got from
> Markus was about isolate_freepages_block() overhead, and later Norbert
> reported that reverting a patch for isolate_freepages* helped. But the
> problem seems to be that although the loop in isolate_migratepages exits
> because the scanners almost meet (they are within same pageblock), they
> don't truly meet, therefore compact_finished() decides to continue, but
> isolate_migratepages() exits immediately... boom! But indeed e14c720efdd7
> made this situation possible, as free scaner pfn can now point to a
> middle of pageblock.

Indeed.

> 
> So I hope the attached patch will fix the soft-lockup issues in
> compact_zone. Please apply on 3.18-rc3 or later without any other reverts,
> and test. It probably won't help Markus and his isolate_freepages_block()
> overhead though...

Yes, I found this bug too, but, it can't explain
isolate_freepages_block() overhead. Anyway, I can't find another bug
related to isolate_freepages_block(). :/

> Thanks,
> Vlastimil
> 
> ------8<------
> >From fbf8eb0bcd2897090312e23da6a31bad9cc6b337 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Sat, 8 Nov 2014 22:20:43 +0100
> Subject: [PATCH] mm, compaction: prevent endless loop in migrate scanner
> 
> ---
>  mm/compaction.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ec74cf0..1b7a1be 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1029,8 +1029,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	}
>  
>  	acct_isolated(zone, cc);
> -	/* Record where migration scanner will be restarted */
> -	cc->migrate_pfn = low_pfn;
> +	/* 
> +	 * Record where migration scanner will be restarted. If we end up in
> +	 * the same pageblock as the free scanner, make the scanners fully
> +	 * meet so that compact_finished() terminates compaction.
> +	 */
> +	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
>  
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }

IMHO, proper fix is not to change this logic, but, to change decision
logic in compact_finished() and in compact_zone(). Maybe helper
function would be good for readability.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
