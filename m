Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAA36B025E
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:33:14 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id d17so31555001wjx.5
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:33:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203si57821354wmh.55.2016.12.30.01.33.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 01:33:12 -0800 (PST)
Date: Fri, 30 Dec 2016 10:33:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161230093308.GB13301@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <20161229060204.GC1815@bbox>
 <20161229075649.GB29208@dhcp22.suse.cz>
 <20161230015625.GB4184@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230015625.GB4184@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-12-16 10:56:25, Minchan Kim wrote:
> On Thu, Dec 29, 2016 at 08:56:49AM +0100, Michal Hocko wrote:
> > On Thu 29-12-16 15:02:04, Minchan Kim wrote:
> > > On Wed, Dec 28, 2016 at 04:30:29PM +0100, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > > > from is file or anonymous but we do not know which LRU this is. It is
> > > > useful to know whether the list is file or anonymous as well. Change
> > > > the tracepoint to show symbolic names of the lru rather.
> > > > 
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > Not exactly same with this but idea is almost same.
> > > I used almost same tracepoint to investigate agging(i.e., deactivating) problem
> > > in 32b kernel with node-lru.
> > > It was enough. Namely, I didn't need tracepoint in shrink_active_list like your
> > > first patch.
> > > Your first patch is more straightforwad and information. But as you introduced
> > > this patch, I want to ask in here.
> > > Isn't it enough with this patch without your first one to find a such problem?
> > 
> > I assume this should be a reply to
> > http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org, right?
> 
> I don't know my browser says "No such Message-ID known"

Hmm, not sure why it didn't get archived at lkml.kernel.org.
I meant https://lkml.org/lkml/2016/12/28/167
 
> > And you are right that for the particular problem it was enough to have
> > a tracepoint inside inactive_list_is_low and shrink_active_list one
> > wasn't really needed. On the other hand aging issues are really hard to
> 
> What kinds of aging issue? What's the problem? How such tracepoint can help?
> Please describe.

If you do not see that active list is shrunk then you do not know why it
is not shrunk. It might be a active/inactive ratio or just a plan bug
like the 32b issue me and you were debugging.

> > debug as well and so I think that both are useful. The first one tell us
> > _why_ we do aging while the later _how_ we do that.
> 
> Solve reported problem first you already knew. It would be no doubt
> to merge and then send other patches about "it might be useful" with
> useful scenario.

I am not sure I understand. The point of tracepoints is to be
pro-actively helpful not only to add something that has been useful in
one-off cases. A particular debugging session might be really helpful to
tell us what we are missing and this was the case here to a large part.
Once I was looking there I just wanted to save the pain of adding more
debugging information in future and allow people to debug their issue
without forcing them to recompile the kernel. I believe this is one of
the strong usecases for tracepoints in the first place.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
