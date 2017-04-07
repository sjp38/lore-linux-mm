Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3B76B0397
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 13:29:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e68so739561wme.10
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 10:29:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r205si35346219wma.48.2017.04.07.10.29.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 10:29:21 -0700 (PDT)
Date: Fri, 7 Apr 2017 19:29:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
Message-ID: <20170407172918.GK16413@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
 <20170406130614.a6ygueggpwseqysd@techsingularity.net>
 <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
 <alpine.LSU.2.11.1704070914520.1566@eggly.anvils>
 <20170407163932.GJ16413@dhcp22.suse.cz>
 <alpine.LSU.2.11.1704070952530.2261@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704070952530.2261@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 07-04-17 09:58:17, Hugh Dickins wrote:
> On Fri, 7 Apr 2017, Michal Hocko wrote:
> > On Fri 07-04-17 09:25:33, Hugh Dickins wrote:
> > [...]
> > > 24 hours so far, and with a clean /var/log/messages.  Not conclusive
> > > yet, and of course I'll leave it running another couple of days, but
> > > I'm increasingly sure that it works as you intended: I agree that
> > > 
> > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch
> > > 
> > > should go to Linus as soon as convenient.  Though I think the commit
> > > message needs something a bit stronger than "Quite annoying though".
> > > Maybe add a line:
> > > 
> > > Fixes serious hang under load, observed repeatedly on 4.11-rc.
> > 
> > Yeah, it is much less theoretical now. I will rephrase and ask Andrew to
> > update the chagelog and send it to Linus once I've got your final go.
> 
> I don't know akpm's timetable, but your fix being more than a two-liner,
> I think it would be better if it could get into rc6, than wait another
> week for rc7, just in case others then find problems with it.  So I
> think it's safer *not* to wait for my final go, but proceed on the
> assumption that it will follow a day later.

Fair enough. Andrew, could you update the changelog of
mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
and send it to Linus along with
mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch before rc6?

I would add your Teste-by Hugh but I guess you want to give your testing
more time before feeling comfortable to give it.
---
mm: move pcp and lru-pcp draining into single wq

We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
per cpu lru caches.  This seems more than necessary because both can run
on a single WQ.  Both do not block on locks requiring a memory allocation
nor perform any allocations themselves.  We will save one rescuer thread
this way.

On the other hand drain_all_pages() queues work on the system wq which
doesn't have rescuer and so this depend on memory allocation (when all
workers are stuck allocating and new ones cannot be created). Initially
we thought this would be more of a theoretical problem but Hugh Dickins
has reported:
: 4.11-rc has been giving me hangs after hours of swapping load.  At
: first they looked like memory leaks ("fork: Cannot allocate memory");
: but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
: before looking at /proc/meminfo one time, and the stat_refresh stuck
: in D state, waiting for completion of flush_work like many kworkers.
: kthreadd waiting for completion of flush_work in drain_all_pages().

This worker should be using WQ_RECLAIM as well in order to guarantee
a forward progress. We can reuse the same one as for lru draining and
vmstat.

Link: http://lkml.kernel.org/r/20170307131751.24936-1-mhocko@kernel.org
Fixes: 0ccce3b92421 ("mm, page_alloc: drain per-cpu pages from workqueue context")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
