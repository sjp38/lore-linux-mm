Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1024C6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:24:00 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so8764321pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 10:23:59 -0700 (PDT)
Date: Fri, 21 Sep 2012 10:23:55 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 12/13] execute the whole memcg freeing in rcu
 callback
Message-ID: <20120921172355.GD7264@google.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-13-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977050-29476-13-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Tue, Sep 18, 2012 at 06:04:09PM +0400, Glauber Costa wrote:
> A lot of the initialization we do in mem_cgroup_create() is done with softirqs
> enabled. This include grabbing a css id, which holds &ss->id_lock->rlock, and
> the per-zone trees, which holds rtpz->lock->rlock. All of those signal to the
> lockdep mechanism that those locks can be used in SOFTIRQ-ON-W context. This
> means that the freeing of memcg structure must happen in a compatible context,
> otherwise we'll get a deadlock.

Lockdep requires lock to be softirq or irq safe iff the lock is
actually acquired from the said context.  Merely using a lock with bh
/ irq disabled doesn't signal that to lockdep; otherwise, we'll end up
with enormous number of spurious warnings.

> The reference counting mechanism we use allows the memcg structure to be freed
> later and outlive the actual memcg destruction from the filesystem. However, we
> have little, if any, means to guarantee in which context the last memcg_put
> will happen. The best we can do is test it and try to make sure no invalid
> context releases are happening. But as we add more code to memcg, the possible
> interactions grow in number and expose more ways to get context conflicts.
> 
> We already moved a part of the freeing to a worker thread to be context-safe
> for the static branches disabling. I see no reason not to do it for the whole
> freeing action. I consider this to be the safe choice.

And the above description too makes me scratch my head quite a bit.  I
can see what the patch is doing but can't understand the why.

* Why was it punting the freeing to workqueue anyway?  ISTR something
  about static_keys but my memory fails.  What changed?  Why don't we
  need it anymore?

* As for locking context, the above description seems a bit misleading
  to me.  Synchronization constructs involved there currently doesn't
  require softirq or irq safe context.  If that needs to change,
  that's fine but that's a completely different reason than given
  above.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
