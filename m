Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E7CCB6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:16:29 -0500 (EST)
Date: Tue, 6 Nov 2012 23:16:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
Message-Id: <20121106231627.3610c908.akpm@linux-foundation.org>
In-Reply-To: <509A0A04.2030503@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-26-git-send-email-glommer@parallels.com>
	<20121105164813.2eba5ecb.akpm@linux-foundation.org>
	<509A0A04.2030503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Wed, 7 Nov 2012 08:13:08 +0100 Glauber Costa <glommer@parallels.com> wrote:

> On 11/06/2012 01:48 AM, Andrew Morton wrote:
> > On Thu,  1 Nov 2012 16:07:41 +0400
> > Glauber Costa <glommer@parallels.com> wrote:
> > 
> >> This means that when we destroy a memcg cache that happened to be empty,
> >> those caches may take a lot of time to go away: removing the memcg
> >> reference won't destroy them - because there are pending references, and
> >> the empty pages will stay there, until a shrinker is called upon for any
> >> reason.
> >>
> >> In this patch, we will call kmem_cache_shrink for all dead caches that
> >> cannot be destroyed because of remaining pages. After shrinking, it is
> >> possible that it could be freed. If this is not the case, we'll schedule
> >> a lazy worker to keep trying.
> > 
> > This patch is really quite nasty.  We poll the cache once per minute
> > trying to shrink then free it?  a) it gives rise to concerns that there
> > will be scenarios where the system could suffer unlimited memory windup
> > but mainly b) it's just lame.
> > 
> > The kernel doesn't do this sort of thing.  The kernel tries to be
> > precise: in a situation like this we keep track of the number of
> > outstanding objects and when that falls to zero, we free their
> > container synchronously.  If those objects are normally left floating
> > around in an allocated but reclaimable state then we can address that
> > by synchronously freeing them if their container has been destroyed.
> > 
> > Or something like that.  If it's something else then fine, but not this.
> > 
> > What do we need to do to fix this?
> > 
> The original patch had a unlikely() test in the free path, conditional
> on whether or not the cache is dead, that would then call this is the
> cache would now be empty.
> 
> I got several requests to remove it and change it to something like
> this, because that is a fast path (I myself think an unlikely branch is
> not that bad)
> 
> If you think such a test is acceptable, I can bring it back and argue in
> the basis of "akpm made me do it!". But meanwhile I will give this extra
> though to see if there is any alternative way I can do it...

OK, thanks, please do take a look at it.

I'd be interested in seeing the old version of the patch which had this
test-n-branch.  Perhaps there's some trick we can pull to lessen its cost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
