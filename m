Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0EB26B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 15:52:48 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id n3so57072559wjy.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 12:52:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si78625230wjo.159.2017.01.03.12.52.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 12:52:47 -0800 (PST)
Date: Tue, 3 Jan 2017 21:52:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170103205244.GD13873@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <19b44b6e-037f-45fd-a13a-be5d87259e75@suse.cz>
 <20170103204745.GC13873@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170103204745.GC13873@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 03-01-17 21:47:45, Michal Hocko wrote:
> On Tue 03-01-17 18:08:58, Vlastimil Babka wrote:
> > On 12/28/2016 04:30 PM, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > > from is file or anonymous but we do not know which LRU this is. It is
> > > useful to know whether the list is file or anonymous as well. Change
> > > the tracepoint to show symbolic names of the lru rather.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  include/trace/events/vmscan.h | 20 ++++++++++++++------
> > >  mm/vmscan.c                   |  2 +-
> > >  2 files changed, 15 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > > index 6af4dae46db2..cc0b4c456c78 100644
> > > --- a/include/trace/events/vmscan.h
> > > +++ b/include/trace/events/vmscan.h
> > > @@ -36,6 +36,14 @@
> > >  		(RECLAIM_WB_ASYNC) \
> > >  	)
> > > 
> > > +#define show_lru_name(lru) \
> > > +	__print_symbolic(lru, \
> > > +			{LRU_INACTIVE_ANON, "LRU_INACTIVE_ANON"}, \
> > > +			{LRU_ACTIVE_ANON, "LRU_ACTIVE_ANON"}, \
> > > +			{LRU_INACTIVE_FILE, "LRU_INACTIVE_FILE"}, \
> > > +			{LRU_ACTIVE_FILE, "LRU_ACTIVE_FILE"}, \
> > > +			{LRU_UNEVICTABLE, "LRU_UNEVICTABLE"})
> > > +
> > 
> > Does this work with external tools such as trace-cmd, i.e. does it export
> > the correct format file?
> 
> How do I find out?

Well, I've just checked the format file and it says
print fmt: "isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu lru=%s", REC->isolate_mode, REC->classzone_idx, REC->order, REC->nr_requested, REC->nr_scanned, REC->nr_skipped, REC->nr_taken, __print_symbolic(REC->lru, {LRU_INACTIVE_ANON, "LRU_INACTIVE_ANON"}, {LRU_ACTIVE_ANON, "LRU_ACTIVE_ANON"}, {LRU_INACTIVE_FILE, "LRU_INACTIVE_FILE"}, {LRU_ACTIVE_FILE, "LRU_ACTIVE_FILE"}, {LRU_UNEVICTABLE, "LRU_UNEVICTABLE"})

So the tool should be OK as long as it can find values for LRU_*
constants. Is this what is the problem?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
