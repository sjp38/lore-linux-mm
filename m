Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 592606B0092
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 04:11:47 -0400 (EDT)
Date: Fri, 20 Apr 2012 10:11:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120420081144.GC4191@tiehlicka.suse.cz>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
 <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 19-04-12 10:47:27, Ying Han wrote:
> On Thu, Apr 19, 2012 at 10:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 18-04-12 11:00:40, Ying Han wrote:
> >> On Wed, Apr 18, 2012 at 5:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> > On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
> >> >> The "soft_limit" was introduced in memcg to support over-committing the
> >> >> memory resource on the host. Each cgroup configures its "hard_limit" where
> >> >> it will be throttled or OOM killed by going over the limit. However, the
> >> >> cgroup can go above the "soft_limit" as long as there is no system-wide
> >> >> memory contention. So, the "soft_limit" is the kernel mechanism for
> >> >> re-distributing system spare memory among cgroups.
> >> >>
> >> >> This patch reworks the softlimit reclaim by hooking it into the new global
> >> >> reclaim scheme. So the global reclaim path including direct reclaim and
> >> >> background reclaim will respect the memcg softlimit.
> >> >>
> >> >> v3..v2:
> >> >> 1. rebase the patch on 3.4-rc3
> >> >> 2. squash the commits of replacing the old implementation with new
> >> >> implementation into one commit. This is to make sure to leave the tree
> >> >> in stable state between each commit.
> >> >> 3. removed the commit which changes the nr_to_reclaim for global reclaim
> >> >> case. The need of that patch is not obvious now.
> >> >>
> >> >> Note:
> >> >> 1. the new implementation of softlimit reclaim is rather simple and first
> >> >> step for further optimizations. there is no memory pressure balancing between
> >> >> memcgs for each zone, and that is something we would like to add as follow-ups.
> >> >>
> >> >> 2. this patch is slightly different from the last one posted from Johannes
> >> >> http://comments.gmane.org/gmane.linux.kernel.mm/72382
> >> >> where his patch is closer to the reverted implementation by doing hierarchical
> >> >> reclaim for each selected memcg. However, that is not expected behavior from
> >> >> user perspective. Considering the following example:
> >> >>
> >> >> root (32G capacity)
> >> >> --> A (hard limit 20G, soft limit 15G, usage 16G)
> >> >>    --> A1 (soft limit 5G, usage 4G)
> >> >>    --> A2 (soft limit 10G, usage 12G)
> >> >> --> B (hard limit 20G, soft limit 10G, usage 16G)
> >> >>
> >> >> Under global reclaim, we shouldn't add pressure on A1 although its parent(A)
> >> >> exceeds softlimit. This is what admin expects by setting softlimit to the
> >> >> actual working set size and only reclaim pages under softlimit if system has
> >> >> trouble to reclaim.
> >> >
> >> > Actually, this is exactly what the admin expects when creating a
> >> > hierarchy, because she defines that A1 is a child of A and is
> >> > responsible for the memory situation in its parent.
> >
> > Hmm, I guess that both approaches have cons and pros.
> > * Hierarchical soft limit reclaim - reclaim the whole subtree of the over
> >  soft limit memcg
> >  + it is consistent with the hard limit reclaim
> Not sure why we want them to be consistent. Soft_limit is serving
> different purpose and the one of the main purpose is to preserve the
> working set of the cgroup.

Well, cgroups subsystem is moving towards unification so all the
controllers should live in one hierarchy and it would be nice if we had
a common view on what hard and soft limits mean wrt. hierarchies. It is
true that memcg is the only user of the soft limit in the moment but it
would be better if we were prepared for future users are well and
wouldn't come up with one shot solutions.

> >  + easier for top to bottom configuration - especially when you allow
> >    subgroups to create deeper hierarchies. Does anybody do that?
> 
> As far as I heard, most (if not all) are using flat configuration
> where everything is running under root.

Might be true for memcg but what about other controllers?

[...]
> > Both approaches don't play very well with the default 0 limit because we
> > either reclaim unless we set up the whole hierarchy properly or we just
> > burn cycles by trying to reclaim groups wit no or only few pages.
> 
> Setting the default to 0 is a good optimization which makes everybody
> to be eligible for reclaim if admin doesn't do anything.
> 
> In reality, if admin want to preserve working set of cgroups and
> he/she has to set the softlimit. By doing that, it is easier to only
> focus on the cgroup itself without looking up its ancestors.

I guess it is not that clear who should be responsible for setting the
limit. Should it be admin or rather a workload owner? Because this
changes a lot. 

> 
> > The second approach leads to more expected results though because we do
> > not touch "leaf" groups unless they are over limit.
> > I have to think about that some more but it seems that the second approach
> > is much easier to implement and matches the "guarantee" expectations
> > more.
> 
> Agree.
> 
> > I guess we could converge both approaches if we could reclaim from the
> > leaf groups upwards to the root but I didn't think about this very much.
> 
> That is what the current patch does, which only consider softlimit
> under global pressure :)

Not really, because your patch iterates sequentially from top to bottom.
I was thinking about iteration from the leaves and do the hierarchical
reclaim from the first one which is over the limit. This would uncharge
from the parent as well so it could get down under its limit and if not
then we can hammer on siblings. But, as I said, I did give this more
thoughts, it sure comes with its own set of issues (including
inconsistency with the hard limit reclaim ;))

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
