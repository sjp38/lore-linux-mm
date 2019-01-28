From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Date: Mon, 28 Jan 2019 18:05:26 +0100
Message-ID: <20190128170526.GQ18811@dhcp22.suse.cz>
References: <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
List-Id: linux-mm.kvack.org

On Mon 28-01-19 07:41:50, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jan 28, 2019 at 04:18:59PM +0100, Michal Hocko wrote:
> > How do you make an atomic snapshot of the hierarchy state? Or you do
> > not need it because event counters are monotonic and you are willing to
> > sacrifice some lost or misinterpreted events? For example, you receive
> > an oom event while the two children increase the oom event counter. How
> > do you tell which one was the source of the event and which one is still
> > pending? Or is the ordering unimportant in general?
> 
> Hmm... This is straightforward stateful notification.  Imagine the
> following hierarchy.  The numbers are the notification counters.
> 
>      A:0
>    /   \
>   B:0  C:0
> 
> Let's say B generates an event, soon followed by C.  If A's counter is
> read after both B and C's events, nothing is missed.
> 
> Let's say it ends up generating two notifications and we end up
> walking down inbetween B and C's events.  It would look like the
> following.
> 
>      A:1
>    /   \
>   B:1  C:0
> 
> We first see A's 0 -> 1 and then start scanning the subtrees to find
> out the origin.  We will notice B but let's say we visit C before C's
> event gets registered (otherwise, nothing is missed).

Yeah, that is quite clear. But it also assumes that the hierarchy is
pretty stable but cgroups might go away at any time. I am not saying
that the aggregated events are not useful I am just saying that it is
quite non-trivial to use and catch all potential corner cases. Maybe I
am overcomplicating it but one thing is quite clear to me. The existing
semantic is really useful to watch for the reclaim behavior at the
current level of the tree. You really do not have to care what is
happening in the subtree when it is clear that the workload itself
is underprovisioned etc. Considering that such a semantic already
existis, somebody might depend on it and we likely want also aggregated
semantic then I really do not see why to risk regressions rather than
add a new memory.hierarchy_events and have both.

-- 
Michal Hocko
SUSE Labs
