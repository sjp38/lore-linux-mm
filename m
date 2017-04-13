Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50A7D6B03B3
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 13:56:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y38so16601367qtb.23
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 10:56:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si23332793qth.45.2017.04.13.10.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 10:56:26 -0700 (PDT)
Date: Thu, 13 Apr 2017 19:56:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
Message-ID: <20170413175622.GA18022@redhat.com>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
 <20170406130614.a6ygueggpwseqysd@techsingularity.net>
 <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
 <alpine.LSU.2.11.1704070914520.1566@eggly.anvils>
 <20170407163932.GJ16413@dhcp22.suse.cz>
 <alpine.LSU.2.11.1704070952530.2261@eggly.anvils>
 <20170407172918.GK16413@dhcp22.suse.cz>
 <alpine.LSU.2.11.1704071141110.3348@eggly.anvils>
 <alpine.LSU.2.11.1704081000110.27995@eggly.anvils>
 <20170408180910.mtkcvi4vlwg2li6b@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170408180910.mtkcvi4vlwg2li6b@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>

Hello,

On Sat, Apr 08, 2017 at 07:09:10PM +0100, Mel Gorman wrote:
> On Sat, Apr 08, 2017 at 10:04:20AM -0700, Hugh Dickins wrote:
> > On Fri, 7 Apr 2017, Hugh Dickins wrote:
> > > On Fri, 7 Apr 2017, Michal Hocko wrote:
> > > > On Fri 07-04-17 09:58:17, Hugh Dickins wrote:
> > > > > On Fri, 7 Apr 2017, Michal Hocko wrote:
> > > > > > On Fri 07-04-17 09:25:33, Hugh Dickins wrote:
> > > > > > [...]
> > > > > > > 24 hours so far, and with a clean /var/log/messages.  Not conclusive
> > > > > > > yet, and of course I'll leave it running another couple of days, but
> > > > > > > I'm increasingly sure that it works as you intended: I agree that
> > > > > > > 
> > > > > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > > > > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch
> > > > > > > 
> > > > > > > should go to Linus as soon as convenient.  Though I think the commit
> > > > > > > message needs something a bit stronger than "Quite annoying though".
> > > > > > > Maybe add a line:
> > > > > > > 
> > > > > > > Fixes serious hang under load, observed repeatedly on 4.11-rc.
> > > > > > 
> > > > > > Yeah, it is much less theoretical now. I will rephrase and ask Andrew to
> > > > > > update the chagelog and send it to Linus once I've got your final go.
> > > > > 
> > > > > I don't know akpm's timetable, but your fix being more than a two-liner,
> > > > > I think it would be better if it could get into rc6, than wait another
> > > > > week for rc7, just in case others then find problems with it.  So I
> > > > > think it's safer *not* to wait for my final go, but proceed on the
> > > > > assumption that it will follow a day later.
> > > > 
> > > > Fair enough. Andrew, could you update the changelog of
> > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > > > and send it to Linus along with
> > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch before rc6?
> > > > 
> > > > I would add your Teste-by Hugh but I guess you want to give your testing
> > > > more time before feeling comfortable to give it.
> > > 
> > > Yes, fair enough: at the moment it's just
> > > Half-Tested-by: Hugh Dickins <hughd@google.com>
> > > and I hope to take the Half- off in about 21 hours.
> > > But I certainly wouldn't mind if it found its way to Linus without my
> > > final seal of approval.
> > 
> > 48 hours and still going well: I declare it good, and thanks to Andrew,
> > Linus has ce612879ddc7 "mm: move pcp and lru-pcp draining into single wq"
> > already in for rc6.
> > 
> 
> Excellent, thanks for that testing.

Not questioning the fixes for this, but just giving another possible
explanation for any hangs experienced in v4.11-rc in
drain_local_pages_wq never running.

If you use i915 the drain_local_pages_wq would have hanged under load
also because of i915 is deadlocking the system_wq so if
drain_local_pages_wq is queued on it, it'll get stuck as well.

Not queuing drain_local_pages in the system_wq will prevent it to
hang, but i915 would still hang the system_wq leading to a full hang
eventually.

BUG: workqueue lockup - pool cpus=5 node=0 flags=0x0 nice=0 stuck for 45s!
Showing busy workqueues and worker pools:
workqueue events: flags=0x0
pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=4/256
in-flight: 5217:__i915_gem_free_work
pending: __i915_gem_free_work, drain_local_pages_wq BAR(2), wait_rcu_exp_gp

The deadlock materializes between __i915_gem_free_work and
wait_rcu_exp_gp (shrinker waits for wait_rcu_exp_gp with shared_mutex
held 100% of the time, and sometime __i915_gem_free_work will be
pending and stuck in mutex_lock(&shared_mutex)).

drain_local_pages_wq is not involved but it just to happen to be
queued in a deadlocked system_wq, so it will appear hanging as well.

This got fixed in upstream commit
c053b5a506d3afc038c485a86e3d461f6c7fb207 with a patch that I consider
inefficient as its calling synchronize_rcu_expedited in places even
the older code was never attempting to do that because it's
unnecessary (i915_gem_shrinker_count is an example). It'd be nice to
optimize that away at least from i915_gem_shrinker_count before v4.11
final.

Despite the reduced performance if compared to my fix, it will solve
the reproducible hang as is equivalent to my fix in that respect.

In any case synchronize_rcu_expedited remains unsafe in the shrinker
as we discussed recently (lockdep isn't capable of warning about it).

I suggested to make two separate WQ_MEM_RECLAIM workqueues, one for
RCU wait_rcu_exp_gp, one for __i915_gem_free_work. The former will
allow to call synchronize_* in PF_MEMALLOC context (i.e. i915
shrinker). The latter will allow to call
flush_work(&__i915_gem_free_work_wq) in PF_MEMALLOC context (i.e. i915
shrinker) so that when the i915 shrinker returns all memory has been
freed.

Chris (CC'ed) suggested to drop all RCU/flush_work synchronization and
let the system free the memory when it can. Which is likely to work,
but the larger the system the less infrequent the quiescent points
will be. Not waiting the i915 memory to be freed before returning from
the shrinker is clearly simpler and a few liner change, just it makes
things run a bit more by luck. It would be faster overall though.

The assumption the VM reclaim code will take care of serializing on
quiescent points or system_wq runs by itself, is probably not correct
as it currently can't. If the i915 shrinker can't serialize and
throttle on that, the reclaim code can't do that either, it's still
the same problematic PF_MEMALLOC context after all. Only kswapd
actually could, because unlike direct reclaim, it's setting
PF_MEMALLOC but it cannot be holding any random lock when it calls
reclaim.

Comments welcome.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
