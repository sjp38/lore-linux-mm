Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 7D32B6B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:48:15 -0500 (EST)
Date: Mon, 5 Nov 2012 16:48:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
Message-Id: <20121105164813.2eba5ecb.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-26-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-26-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:41 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This means that when we destroy a memcg cache that happened to be empty,
> those caches may take a lot of time to go away: removing the memcg
> reference won't destroy them - because there are pending references, and
> the empty pages will stay there, until a shrinker is called upon for any
> reason.
> 
> In this patch, we will call kmem_cache_shrink for all dead caches that
> cannot be destroyed because of remaining pages. After shrinking, it is
> possible that it could be freed. If this is not the case, we'll schedule
> a lazy worker to keep trying.

This patch is really quite nasty.  We poll the cache once per minute
trying to shrink then free it?  a) it gives rise to concerns that there
will be scenarios where the system could suffer unlimited memory windup
but mainly b) it's just lame.

The kernel doesn't do this sort of thing.  The kernel tries to be
precise: in a situation like this we keep track of the number of
outstanding objects and when that falls to zero, we free their
container synchronously.  If those objects are normally left floating
around in an allocated but reclaimable state then we can address that
by synchronously freeing them if their container has been destroyed.

Or something like that.  If it's something else then fine, but not this.

What do we need to do to fix this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
