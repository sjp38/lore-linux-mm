Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0CCB6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 00:03:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so905744943pga.4
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 21:03:30 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v14si43297975pgo.85.2017.01.02.21.03.29
        for <linux-mm@kvack.org>;
        Mon, 02 Jan 2017 21:03:30 -0800 (PST)
Date: Tue, 3 Jan 2017 14:03:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170103050328.GA15700@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230163742.GK13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

On Fri, Dec 30, 2016 at 05:37:42PM +0100, Michal Hocko wrote:
> On Sat 31-12-16 01:04:56, Minchan Kim wrote:
> [...]
> > > From 5f1bc22ad1e54050b4da3228d68945e70342ebb6 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Tue, 27 Dec 2016 13:18:20 +0100
> > > Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> > > 
> > > Our reclaim process has several tracepoints to tell us more about how
> > > things are progressing. We are, however, missing a tracepoint to track
> > > active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> > 
> > I agree this part.
> > 
> > > the number of
> > > 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> > > 	  effectiveness.
> > 
> > I agree nr_taken for knowing shrinking effectiveness but don't
> > agree nr_scanned. If we want to know LRU isolation effectiveness
> > with nr_scanned and nr_taken, isolate_lru_pages will do.
> 
> Yes it will. On the other hand the number is there and there is no
> additional overhead, maintenance or otherwise, to provide that number.

You are adding some instructions, how can you imagine it's no overhead?
Let's say whether it's measurable. Although it's not big in particular case,
it would be measurable if everyone start to say like that "it's trivial so
what's the problem adding a few instructions although it was duplicated?"

You already said "LRU isolate effectiveness". It should be done in there,
isolate_lru_pages and we have been. You need another reasons if you want to
add the duplicated work, strongly.

> The inactive counterpart does that for quite some time already. So why

It couldn't be a reason. If it was duplicated in there, it would be
better to fix it rather than adding more duplciated work to match both
sides.

> exactly does that matter? Don't take me wrong but isn't this more on a
> nit picking side than necessary? Or do I just misunderstand your
> concenrs? It is not like we are providing a stable user API as the

My concern is that I don't see what we can get benefit from those
duplicated work. If it doesn't give benefit to us, I don't want to add.
I hope you think another reasonable reasons.

> tracepoint is clearly implementation specific and not something to be
> used for anything other than debugging.

My point is we already had things "LRU isolation effectivness". Namely,
isolate_lru_pages.

> 
> > > 	- nr_rotated pages which tells us that we are hitting referenced
> > > 	  pages which are deactivated. If this is a large part of the
> > > 	  reported nr_deactivated pages then the active list is too small
> > 
> > It might be but not exactly. If your goal is to know LRU size, it can be
> > done in get_scan_count. I tend to agree LRU size is helpful for
> > performance analysis because decreased LRU size signals memory shortage
> > then performance drop.
> 
> No, I am not really interested in the exact size but rather to allow to
> find whether we are aging the active list too early...

Could you elaborate it more that how we can get active list early aging
with nr_rotated?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
