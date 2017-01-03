Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF2826B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 03:21:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so46478888wmi.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 00:21:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j16si72536057wmd.116.2017.01.03.00.21.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 00:21:26 -0800 (PST)
Date: Tue, 3 Jan 2017 09:21:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170103082122.GA30111@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz>
 <20170103050328.GA15700@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170103050328.GA15700@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 03-01-17 14:03:28, Minchan Kim wrote:
> Hi Michal,
> 
> On Fri, Dec 30, 2016 at 05:37:42PM +0100, Michal Hocko wrote:
> > On Sat 31-12-16 01:04:56, Minchan Kim wrote:
> > [...]
> > > > From 5f1bc22ad1e54050b4da3228d68945e70342ebb6 Mon Sep 17 00:00:00 2001
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > Date: Tue, 27 Dec 2016 13:18:20 +0100
> > > > Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> > > > 
> > > > Our reclaim process has several tracepoints to tell us more about how
> > > > things are progressing. We are, however, missing a tracepoint to track
> > > > active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> > > 
> > > I agree this part.
> > > 
> > > > the number of
> > > > 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> > > > 	  effectiveness.
> > > 
> > > I agree nr_taken for knowing shrinking effectiveness but don't
> > > agree nr_scanned. If we want to know LRU isolation effectiveness
> > > with nr_scanned and nr_taken, isolate_lru_pages will do.
> > 
> > Yes it will. On the other hand the number is there and there is no
> > additional overhead, maintenance or otherwise, to provide that number.
> 
> You are adding some instructions, how can you imagine it's no overhead?

There should be close to zero overhead when the tracepoint is disabled
(we pay only one more argument when the function is called). Is this
really worth discussing in this cold path? We are talking about the
reclaim here.

> Let's say whether it's measurable. Although it's not big in particular case,
> it would be measurable if everyone start to say like that "it's trivial so
> what's the problem adding a few instructions although it was duplicated?"
> 
> You already said "LRU isolate effectiveness". It should be done in there,
> isolate_lru_pages and we have been. You need another reasons if you want to
> add the duplicated work, strongly.

isolate_lru_pages is certainly there but you have to enable a trace
point for that. Sometimes it is quite useful to get a reasonably good
picture even without all the vmscan tracepoints enabled because they
can generate quite a lot of output. So if the counter is available I
see no reason to exclude it, especially when it can provide a useful
information. One of the most frustrating debugging experience is when
you are missing some part of the information and have to guess which
part is that and patch, rebuild the kernel and hope to reproduce it
again in the same/similar way.

There are two things about this and other tracepoint patches in general
I believe. 1) Is the tracepoint useful? and 2) Do we have to go over
extra hops to show tracepoint data?

I guess we are in an agreement that the answer for 1 is yes. And
regarding 2, all the data we are showing are there or trivially
retrieved without touching _any_ hot path. Som of it might be duplicated
with other tracepoints but that can be helpful because you do not have
all the tracepoints enabled all the time. So unless you see this
particular thing as a road block I would rather keep it.
 
> > The inactive counterpart does that for quite some time already. So why
> 
> It couldn't be a reason. If it was duplicated in there, it would be
> better to fix it rather than adding more duplciated work to match both
> sides.

I really do not see this as a bad thing.

> > exactly does that matter? Don't take me wrong but isn't this more on a
> > nit picking side than necessary? Or do I just misunderstand your
> > concenrs? It is not like we are providing a stable user API as the
> 
> My concern is that I don't see what we can get benefit from those
> duplicated work. If it doesn't give benefit to us, I don't want to add.
> I hope you think another reasonable reasons.
> 
> > tracepoint is clearly implementation specific and not something to be
> > used for anything other than debugging.
> 
> My point is we already had things "LRU isolation effectivness". Namely,
> isolate_lru_pages.
> 
> > 
> > > > 	- nr_rotated pages which tells us that we are hitting referenced
> > > > 	  pages which are deactivated. If this is a large part of the
> > > > 	  reported nr_deactivated pages then the active list is too small
> > > 
> > > It might be but not exactly. If your goal is to know LRU size, it can be
> > > done in get_scan_count. I tend to agree LRU size is helpful for
> > > performance analysis because decreased LRU size signals memory shortage
> > > then performance drop.
> > 
> > No, I am not really interested in the exact size but rather to allow to
> > find whether we are aging the active list too early...
> 
> Could you elaborate it more that how we can get active list early aging
> with nr_rotated?

If you see too many referenced pages on the active list then they have
been used since promoted and that is an indication that they might be
reclaimed too early. If you are debugging a performance issue and see
this happening then it might be a good indication to look at.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
