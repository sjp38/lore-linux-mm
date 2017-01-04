Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 679366B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 00:07:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g1so1338743129pgn.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 21:07:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j61si71250335plb.116.2017.01.03.21.07.23
        for <linux-mm@kvack.org>;
        Tue, 03 Jan 2017 21:07:24 -0800 (PST)
Date: Wed, 4 Jan 2017 14:07:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170104050722.GA17166@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz>
 <20170103050328.GA15700@bbox>
 <20170103082122.GA30111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170103082122.GA30111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 03, 2017 at 09:21:22AM +0100, Michal Hocko wrote:
> On Tue 03-01-17 14:03:28, Minchan Kim wrote:
> > Hi Michal,
> > 
> > On Fri, Dec 30, 2016 at 05:37:42PM +0100, Michal Hocko wrote:
> > > On Sat 31-12-16 01:04:56, Minchan Kim wrote:
> > > [...]
> > > > > From 5f1bc22ad1e54050b4da3228d68945e70342ebb6 Mon Sep 17 00:00:00 2001
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > Date: Tue, 27 Dec 2016 13:18:20 +0100
> > > > > Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> > > > > 
> > > > > Our reclaim process has several tracepoints to tell us more about how
> > > > > things are progressing. We are, however, missing a tracepoint to track
> > > > > active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> > > > 
> > > > I agree this part.
> > > > 
> > > > > the number of
> > > > > 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> > > > > 	  effectiveness.
> > > > 
> > > > I agree nr_taken for knowing shrinking effectiveness but don't
> > > > agree nr_scanned. If we want to know LRU isolation effectiveness
> > > > with nr_scanned and nr_taken, isolate_lru_pages will do.
> > > 
> > > Yes it will. On the other hand the number is there and there is no
> > > additional overhead, maintenance or otherwise, to provide that number.
> > 
> > You are adding some instructions, how can you imagine it's no overhead?
> 
> There should be close to zero overhead when the tracepoint is disabled
> (we pay only one more argument when the function is called). Is this
> really worth discussing in this cold path? We are talking about the
> reclaim here.

I am talking about that why we should add pointless code in there.
No matter it's overhead. We are looping infinite. Blindly, it adds
overhead although you might think so trivial.

> 
> > Let's say whether it's measurable. Although it's not big in particular case,
> > it would be measurable if everyone start to say like that "it's trivial so
> > what's the problem adding a few instructions although it was duplicated?"
> > 
> > You already said "LRU isolate effectiveness". It should be done in there,
> > isolate_lru_pages and we have been. You need another reasons if you want to
> > add the duplicated work, strongly.
> 
> isolate_lru_pages is certainly there but you have to enable a trace
> point for that. Sometimes it is quite useful to get a reasonably good
> picture even without all the vmscan tracepoints enabled because they
> can generate quite a lot of output. So if the counter is available I

If someone want to see "isolate effectivenss", he should enable
mm_vmscan_lru_isolate which was born in that and has more helpful
information.

Think it in an opposit way. If some users want to see just active
list aging problem and no interested in "LRU isolate effectivness",
you are adding meaningless output for him and he has no choice to
turn it off with your patch.

> see no reason to exclude it, especially when it can provide a useful
> information. One of the most frustrating debugging experience is when

I said several times. Please think over if everyone begins adding extra
parameters in every tracepoints which we could already get it via other
tracepoint with "just, it might be useful in a specific context".
Could you be happy with that, really?

> you are missing some part of the information and have to guess which
> part is that and patch, rebuild the kernel and hope to reproduce it
> again in the same/similar way.

No need to rebuild. Just enable mm_vmscan_lru_isolate.

> 
> There are two things about this and other tracepoint patches in general
> I believe. 1) Is the tracepoint useful? and 2) Do we have to go over
> extra hops to show tracepoint data?
> 
> I guess we are in an agreement that the answer for 1 is yes. And

yeb.

> regarding 2, all the data we are showing are there or trivially
> retrieved without touching _any_ hot path. Som of it might be duplicated


Currently, you rely on just unfortunate modulization to just add
unncessary information to the tracepoint.

I just removed nr_scanned in your patch and look below.

./scripts/bloat-o-meter vmlinux.old vmlinux.new
add/remove: 0/0 grow/shrink: 0/6 up/down: 0/-147 (-147)
function                                     old     new   delta
perf_trace_mm_vmscan_lru_shrink_active       264     256      -8
trace_raw_output_mm_vmscan_lru_shrink_active     203     193     -10
trace_event_raw_event_mm_vmscan_lru_shrink_active     241     225     -16
print_fmt_mm_vmscan_lru_shrink_active        458     426     -32
shrink_active_list                          1265    1232     -33
trace_event_define_fields_mm_vmscan_lru_shrink_active     384     336     -48
Total: Before=26268743, After=26268596, chg -0.00%

Let's furhter it more.

We can factor out logics to account isolation of LRU from shrink_[in]active_list
which is more clean, I think.
