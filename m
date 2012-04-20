Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BFBC66B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:18:08 -0400 (EDT)
Date: Fri, 20 Apr 2012 15:17:22 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120420131722.GD2536@cmpxchg.org>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
 <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
 <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 12:37:41AM -0700, Ying Han wrote:
> On Thu, Apr 19, 2012 at 3:33 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Thu, Apr 19, 2012 at 10:47:27AM -0700, Ying Han wrote:
> >> On Thu, Apr 19, 2012 at 10:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > On Wed 18-04-12 11:00:40, Ying Han wrote:
> >> >> On Wed, Apr 18, 2012 at 5:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> >> > On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
> >> >> >> 2. this patch is slightly different from the last one posted from Johannes
> >> >> >> http://comments.gmane.org/gmane.linux.kernel.mm/72382
> >> >> >> where his patch is closer to the reverted implementation by doing hierarchical
> >> >> >> reclaim for each selected memcg. However, that is not expected behavior from
> >> >> >> user perspective. Considering the following example:
> >> >> >>
> >> >> >> root (32G capacity)
> >> >> >> --> A (hard limit 20G, soft limit 15G, usage 16G)
> >> >> >>    --> A1 (soft limit 5G, usage 4G)
> >> >> >>    --> A2 (soft limit 10G, usage 12G)
> >> >> >> --> B (hard limit 20G, soft limit 10G, usage 16G)
> >> >> >>
> >> >> >> Under global reclaim, we shouldn't add pressure on A1 although its parent(A)
> >> >> >> exceeds softlimit. This is what admin expects by setting softlimit to the
> >> >> >> actual working set size and only reclaim pages under softlimit if system has
> >> >> >> trouble to reclaim.
> >> >> >
> >> >> > Actually, this is exactly what the admin expects when creating a
> >> >> > hierarchy, because she defines that A1 is a child of A and is
> >> >> > responsible for the memory situation in its parent.
> >> >
> >> > Hmm, I guess that both approaches have cons and pros.
> >> > * Hierarchical soft limit reclaim - reclaim the whole subtree of the over
> >> >  soft limit memcg
> >> >  + it is consistent with the hard limit reclaim
> >> Not sure why we want them to be consistent. Soft_limit is serving
> >> different purpose and the one of the main purpose is to preserve the
> >> working set of the cgroup.
> >
> > I'd argue, given the history of cgroups, one of the main purposes is
> > having a machine of containers where you overcommit their hard limit
> > and set the soft limit accordingly to provide fairness.
> >
> > Yes, we don't want to reclaim hierarchies that are below their soft
> > limit as long as there are some in excess, of course.  This is a flaw
> > and needs fixing.  But it's something completely different than
> > changing how the soft limit is defined and suddenly allow child
> > groups, which you may not trust, to override rules defined by parental
> > groups.
> >
> > It bothers me that we should add something that will almost certainly
> > bite us in the future while we are discussing on the cgroups list what
> > would stand in the way of getting sane hierarchy semantics across
> > controllers to provide consistency, nesting, etc.
> 
> I understand the concern here and I don't want the soft_limit reclaim
> to be far away from the other part of the cgroup design down to the
> road. On the other hand, I don't think the current implementation is
> against the hierarchy semantics totally. See the comment below :)
> 
> > To support a single use case, which I feel we still have not discussed
> > nearly enough to justify this change.
> >
> > For example, I get that you want 'meta-groups' that group together
> > subgroups for common accounting and hard limiting.  But I don't see
> > why such meta-groups have their own processes.  Conceptually, I mean,
> > how does a process fit into A?  Is it superior to the tasks in A1 and
> > A2?  Why can't it live in A3?
> 
> For user processes, I can see that is totally feasible to live in A3.
> The case I was thinking is kernel threads, which 1) we don't want to
> limit their memory usage 2) they  serve for the whole group unlike
> individual jobs. Of course, we could say that putting those kernel
> thread in A3 and leave the cgroup to unlimited, but not sure if we
> should constrain ourselves not having any processes running under A.

That's just handwaving.

> > So here is a proposal:
> >
> > Would it make sense to try to keep those meta groups always free of
> > their own memory so that they don't /need/ soft limits with weird
> > semantics?  E.g. immediately free the unused memory on rmdir, OR add
> > mechanisms to migrate the memory to a dedicated group:
> >
> >     A
> >       A1 (soft-limited)
> >       A2 (soft-limited)
> >     B
> >     unused (soft-limited)
> >
> > Move all leftover memory from finished jobs to this 'unused' group.
> > You could set its soft limit to 0 so that it sticks around only until
> > you actually need the memory for something else.
> >
> > Then you would get the benefits of accounting and limiting A1 and A2
> > under a single umbrella without the need for a soft limit in A.  We
> > could keep the consistent semantics for soft limits, because you would
> > only have to set it on leaf nodes.
> >
> > Wouldn't this work for you?
> 
> To be frankly, this sounds a lot of extra work for admin to manage the
> system and we still can not prevent page being landed on A totally.

Why not?

And what extra work are we talking here?  As I wrote in the followup
mail: just keep the finished job groups around, set their soft limit
to 0.  Surely you have a userspace job scheduler that sets up these
groups in the first place and could be trivially extended to set soft
limits and watch for notifications.

Let me repeat the pros here: no breaking of existing semantics.  No
introduction of unprecedented semantics into the cgroup mess.  No
changing of kernel code necessary (except what we want to tune
anyway).  No computational overhead for you or anyone else.

If your only counter argument to this is that you can't be bothered to
slightly adjust your setup, I'm no longer interested in this
discussion.

> Back to the current proposal, there are two concerns that I can tell by far:
> 
> 1. skipping "not trust" cgroup in case it sets its soft_limit very high:
> Here, we don't skip the "not trust" cgroup always. We do reclaim from
> them if not enough progress made from other cgroups above the
> softlimit. So, I don't see a problem here.

When you decide to reclaim from groups below their soft limit.

Which means that an untrusted group can force global reclaim to go for
the workingset in other groups.

> 2. not reclaiming based on hierarchy:
> Here I am not checking the ancestor's soft_limit in
> should_reclaim_mem_cgroup(). And it will only make difference if A is
> under soft_limit and A1 is above soft_limit. Now you do agree that we
> shouldn't reclaim from those under softlimit groups if there are
> cgroup exeed their softlimit. Then it leads me to think something like
> the following:
> 
> 1. for priority > DEF_PRIORITY - 3, only reclaim memcg above their softlimit
> 2. for priority <= DEF_PRIORITY - 3, besides 1), also look at memcg's
> ancestor. reclaim memcgs whose ancestor above soft_limit
> 3. for priority == 0, reclaim everything.
>
> Then it has the guarantee of the softlimit at certain level while also
> considers the hierarchy reclaim if the first few rounds doesn't
> fulfill the request.

You expect sane setups to pay the cost of uselessly consulting the res
counters of every existing memcg, twice, on every single reclaim cycle.

Everyone has their agenda and their primary usecase, but this takes
the cake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
