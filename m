Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA5476B0260
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:11:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n74so767366wmi.3
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:11:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si1593905edh.180.2017.11.15.06.11.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 06:11:16 -0800 (PST)
Date: Wed, 15 Nov 2017 15:11:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171115141113.2nw4c4nejermhckb@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
 <20171115140020.GA6771@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115140020.GA6771@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-11-17 09:00:20, Johannes Weiner wrote:
> On Wed, Nov 15, 2017 at 10:02:51AM +0100, Michal Hocko wrote:
> > On Tue 14-11-17 06:37:42, Tetsuo Handa wrote:
> > > This patch uses polling loop with short sleep for unregister_shrinker()
> > > rather than wait_on_atomic_t(), for we can save reader's cost (plain
> > > atomic_dec() compared to atomic_dec_and_test()), we can expect that
> > > do_shrink_slab() of unregistering shrinker likely returns shortly, and
> > > we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> > > shrinker unexpectedly took so long.
> > 
> > I would use wait_event_interruptible in the remove path rather than the
> > short sleep loop which is just too ugly. The shrinker walk would then
> > just wake_up the sleeper when the ref. count drops to 0. Two
> > synchronize_rcu is quite ugly as well, but I was not able to simplify
> > them. I will keep thinking. It just sucks how we cannot follow the
> > standard rcu list with dynamically allocated structure pattern here.
> 
> It's because the refcount is dropped too early. The refcount protects
> the object during shrink, but not for the list_next(), and so you need
> an additional grace period just for that part.

Exactly

> I think you could drop the reference count in the next iteration. This
> way the list_next() works without requiring a second RCU grace period.

That would work. I was playing with an idea of prefetching the next
elemnt before dropping the reference but that would require a lock for
the remove operation. Ugly...

> ref count protects the object and its list pointers; RCU protects what
> the list pointers point to before we acquire the reference:
> 
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(pos, list) {
> 		if (!atomic_inc_not_zero(&pos->ref))
> 			continue;
> 		rcu_read_unlock();
> 
> 		if (prev)
> 			atomic_dec(&prev->ref);
> 		prev = pos;
> 
> 		shrink();
> 
> 		rcu_read_lock();
> 	}
> 	rcu_read_unlock();
> 	if (prev)
> 		atomic_dec(&prev->ref);
> 
> In any case, Minchan's lock breaking seems way preferable over that
> level of headscratching complexity for an unusual case like Shakeel's.

agreed! I would go the more complex way only if it turns out that early
break out causes some real problems.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
