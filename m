Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78DD86B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:17:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r20so5869134wrg.23
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:17:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si5341963edm.364.2017.12.01.07.17.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 07:17:16 -0800 (PST)
Date: Fri, 1 Dec 2017 16:17:15 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171201143317.GC8097@cmpxchg.org>
 <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
 <20171201145638.GA10280@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201145638.GA10280@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri 01-12-17 14:56:38, Johannes Weiner wrote:
> On Fri, Dec 01, 2017 at 03:46:34PM +0100, Michal Hocko wrote:
> > On Fri 01-12-17 14:33:17, Johannes Weiner wrote:
> > > On Sat, Nov 25, 2017 at 07:52:47PM +0900, Tetsuo Handa wrote:
> > > > @@ -1068,6 +1071,17 @@ bool out_of_memory(struct oom_control *oc)
> > > >  	}
> > > >  
> > > >  	select_bad_process(oc);
> > > > +	/*
> > > > +	 * Try really last second allocation attempt after we selected an OOM
> > > > +	 * victim, for somebody might have managed to free memory while we were
> > > > +	 * selecting an OOM victim which can take quite some time.
> > > 
> > > Somebody might free some memory right after this attempt fails. OOM
> > > can always be a temporary state that resolves on its own.
> > > 
> > > What keeps us from declaring OOM prematurely is the fact that we
> > > already scanned the entire LRU list without success, not last second
> > > or last-last second, or REALLY last-last-last-second allocations.
> > 
> > You are right that this is inherently racy. The point here is, however,
> > that the race window between the last check and the kill can be _huge_!
> 
> My point is that it's irrelevant. We already sampled the entire LRU
> list; compared to that, the delay before the kill is immaterial.

Well, I would disagree. I have seen OOM reports with a free memory.
Closer debugging shown that an existing process was on the way out and
the oom victim selection took way too long and fired after a large
process manage. There were different hacks^Wheuristics to cover those
cases but they turned out to just cause different corner cases. Moving
the existing last moment allocation after a potentially very time
consuming action is relatively cheap and safe measure to cover those
cases without any negative side effects I can think of.

Anyway, if the delay is immaterial than the existing last-retry is
even more pointless because it is executed right _after_ we gave up
reclaim retries. Compare that to the select_bad_process time window. And
really, that can take quite a lot of time. Especially in weird priority
inversion situations.

> > Another argument is that the allocator itself could have changed its
> > allocation capabilities - e.g. become the OOM victim itself since the
> > last time it the allocator could have reflected that fact.
> 
> Can you outline how this would happen exactly?

http://lkml.kernel.org/r/20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz

As I try to explain the workload is really pathological but this (resp.
the follow up based on this patch) as a workaround is moderately ugly
wrt. it actually can help.

> > > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
