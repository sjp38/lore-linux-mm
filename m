Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BBD796B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 04:51:27 -0400 (EDT)
Message-ID: <50601E41.5000603@parallels.com>
Date: Mon, 24 Sep 2012 12:48:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 12/13] execute the whole memcg freeing in rcu callback
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-13-git-send-email-glommer@parallels.com> <20120921172355.GD7264@google.com>
In-Reply-To: <20120921172355.GD7264@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

> And the above description too makes me scratch my head quite a bit.  I
> can see what the patch is doing but can't understand the why.
> 
> * Why was it punting the freeing to workqueue anyway?  ISTR something
>   about static_keys but my memory fails.  What changed?  Why don't we
>   need it anymore?
> 
> * As for locking context, the above description seems a bit misleading
>   to me.  Synchronization constructs involved there currently doesn't
>   require softirq or irq safe context.  If that needs to change,
>   that's fine but that's a completely different reason than given
>   above.
> 
> Thanks.
> 

I just suck at changelogs =(

The problem here is very much like the one we had with static branches.
In that case, we had the problem with the cgroup_lock() being held, in
which case the jump label lock could not be called.

In here, after the kmem patches are in, the destruction function could
be called directly from memcg_kmem_uncharge_page() when the last put is
done. But this can actually be called from the page allocator, with an
incompatible softirq context. So it is not that it could be called, they
are actually called in that context at this point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
