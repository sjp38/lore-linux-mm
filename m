Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id F05496B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 04:25:05 -0400 (EDT)
Date: Fri, 7 Jun 2013 10:25:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130607082502.GC8117@dhcp22.suse.cz>
References: <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
 <20130605073728.GC15997@dhcp22.suse.cz>
 <20130605080545.GF7303@mtj.dyndns.org>
 <20130605085239.GF15997@dhcp22.suse.cz>
 <20130605085849.GB7990@mtj.dyndns.org>
 <20130605090739.GH15997@dhcp22.suse.cz>
 <20130605090938.GA8266@mtj.dyndns.org>
 <20130607004824.GA16160@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130607004824.GA16160@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 06-06-13 17:48:24, Tejun Heo wrote:
> On Wed, Jun 05, 2013 at 02:09:38AM -0700, Tejun Heo wrote:
> > On Wed, Jun 05, 2013 at 11:07:39AM +0200, Michal Hocko wrote:
> > > On Wed 05-06-13 01:58:49, Tejun Heo wrote:
> > > [...]
> > > > Anyways, so you aren't gonna try the skipping thing?
> > > 
> > > As I said. I do not consider this a priority for the said reasons (i
> > > will not repeat them).
> > 
> > That's a weird way to respond.  Alright, whatever, let me give it a
> > shot then.
> 
> So, there were some private exchanges and here's my main issue with
> the addition of predicate callback to mem_cgroup_iter_cond().
> 
> There are two common patterns that are used to implement iteration.
> One is the good ol' callback based one - ie. call_fn_on_each(fn) type
> interface.  The other is something which can be used as part of flow
> control by the user - be it give_me_next_elem() or for_each() type
> loop macro.  In majority of cases, especially for anything generic,
> the latter is considered to be the better choice because, while a bit
> more challenging to implement usually, it's a lot less cumbersome for
> the users of the interface.
> 
> mem_cgroup_iter_cond() seems icky to me because the predicate callback
> is essentially visit callback,

OK, I thought that the predicate signature made it clear that its
purpose is to _check_ whether visiting makes sense rather than _visit_
that node and work with the node. That is the reason why I didn't
include state parameter which would be expected for the full visitor.
Maybe using const would make it even more clear. I can update
documentation for the predicate to make it more clear.

> so now we end up with give_me_next_elem() with visit callback, which
> is fundamentally superflous.  If it were properly call_fn_on_each(fn),
> the return values would be CONTINUE, SKIP_SUBTREE or ABORT, which
> makes more sense to me.  Sure, it can be said that the predicate
> callback is for a different purpose but it really doesn't change that
> the interface now is visiting the same node in two different places.
> If it were something remotely widely used, it won't take much time
> developing braindamaged usages where part is being done inside the
> predicate callback and the rest is done outside without clear reason
> why just because of natural code growth.  I don't think this is the
> type of construct that we want in kernel in general.
> 
> That said, it also is true that doing this is the shortest path to
> implementing subtree skip given how the iterator is put together
> currently and the series as a whole reduces significant amount of
> complexity, so it is an acceptable tradeoff to proceed with this
> implementation with later restructuring of the iterator.

Good. As I said many times, memcg iterators could see some clean ups.

> So, let's go ahead as proposed.  

Thanks!

> I'll try to rework the iterator on top of it, and my aplogies to
> Michal for being over-the-top.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
