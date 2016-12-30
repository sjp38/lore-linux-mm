Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9A16B025E
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:26:42 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id d17so31532732wjx.5
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:26:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iu2si61458334wjb.280.2016.12.30.01.26.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 01:26:40 -0800 (PST)
Date: Fri, 30 Dec 2016 10:26:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161230092636.GA13301@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230014853.GA4184@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-12-16 10:48:53, Minchan Kim wrote:
> On Thu, Dec 29, 2016 at 08:52:46AM +0100, Michal Hocko wrote:
> > On Thu 29-12-16 14:33:59, Minchan Kim wrote:
> > > On Wed, Dec 28, 2016 at 04:30:27PM +0100, Michal Hocko wrote:
[...]
> > > > +TRACE_EVENT(mm_vmscan_lru_shrink_active,
> > > > +
> > > > +	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
> > > > +		unsigned long nr_unevictable, unsigned long nr_deactivated,
> > > > +		unsigned long nr_rotated, int priority, int file),
> > > > +
> > > > +	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),
> > > 
> > > I agree it is helpful. And it was when I investigated aging problem of 32bit
> > > when node-lru was introduced. However, the question is we really need all those
> > > kinds of information? just enough with nr_taken, nr_deactivated, priority, file?
> > 
> > Dunno. Is it harmful to add this information? I like it more when the
> > numbers just add up and you have a clear picture. You never know what
> > might be useful when debugging a weird behavior. 
> 
> Michal, I'm not huge fan of "might be useful" although it's a small piece of code.

But these are tracepoints. One of their primary reasons to exist is
to help debug things.  And it is really hard to predict what might be
useful in advance. It is not like the patch would export numbers which
would be irrelevant to the reclaim.

> It adds just all of kinds overheads (memory footprint, runtime performance,
> maintainance) without any proved benefit.

Does it really add any measurable overhead or the maintenance burden? I
think the only place we could argue about is free_hot_cold_page_list
which is used in hot paths.

I think we can sacrifice it. The same for culled unevictable
pages. We wouldn't know what is the missing part
nr_taken-(nr_activate+nr_deactivate) because it could be either freed or
moved to the unevictable list but that could be handled in a separate
tracepoint in putback_lru_page which sounds like a useful thing I guess.
 
> If we allow such things, people would start adding more things with just "why not,
> it might be useful. you never know the future" and it ends up making linux fiction
> novel mess.

I agree with this concern in general, but is this the case in this
particular case?

> If it's necessary, someday, someone will catch up and will send or ask patch with
> detailed description "why the stat is important and how it is good for us to solve
> some problem".

I can certainly enhance the changelog. See below.

> From that, we can learn workload, way to solve the problem and git
> history has the valuable description so new comers can keep the community up easily.
> So, finally, overheads are justified and get merged.
> 
> Please add must-have for your goal described.

My primary point is that tracepoints which do not give us a good picture
are quite useless and force us to add trace_printk or other means to
give us further information. Then I wonder why to have an incomplete
tracepoint at all.

Anyway, what do you think about this updated patch? I have kept Hillf's
A-b so please let me know if it is no longer valid.
--- 
