Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 03B796B00E7
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 18:51:55 -0400 (EDT)
Date: Fri, 20 Apr 2012 00:51:33 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120419225133.GB2536@cmpxchg.org>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
 <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120419223318.GA2536@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 12:33:18AM +0200, Johannes Weiner wrote:
> On Thu, Apr 19, 2012 at 10:47:27AM -0700, Ying Han wrote:
> > On Thu, Apr 19, 2012 at 10:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Wed 18-04-12 11:00:40, Ying Han wrote:
> > >> On Wed, Apr 18, 2012 at 5:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >> > On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
> > >> >> The "soft_limit" was introduced in memcg to support over-committing the
> > >> >> memory resource on the host. Each cgroup configures its "hard_limit" where
> > >> >> it will be throttled or OOM killed by going over the limit. However, the
> > >> >> cgroup can go above the "soft_limit" as long as there is no system-wide
> > >> >> memory contention. So, the "soft_limit" is the kernel mechanism for
> > >> >> re-distributing system spare memory among cgroups.
> > >> >>
> > >> >> This patch reworks the softlimit reclaim by hooking it into the new global
> > >> >> reclaim scheme. So the global reclaim path including direct reclaim and
> > >> >> background reclaim will respect the memcg softlimit.
> > >> >>
> > >> >> v3..v2:
> > >> >> 1. rebase the patch on 3.4-rc3
> > >> >> 2. squash the commits of replacing the old implementation with new
> > >> >> implementation into one commit. This is to make sure to leave the tree
> > >> >> in stable state between each commit.
> > >> >> 3. removed the commit which changes the nr_to_reclaim for global reclaim
> > >> >> case. The need of that patch is not obvious now.
> > >> >>
> > >> >> Note:
> > >> >> 1. the new implementation of softlimit reclaim is rather simple and first
> > >> >> step for further optimizations. there is no memory pressure balancing between
> > >> >> memcgs for each zone, and that is something we would like to add as follow-ups.
> > >> >>
> > >> >> 2. this patch is slightly different from the last one posted from Johannes
> > >> >> http://comments.gmane.org/gmane.linux.kernel.mm/72382
> > >> >> where his patch is closer to the reverted implementation by doing hierarchical
> > >> >> reclaim for each selected memcg. However, that is not expected behavior from
> > >> >> user perspective. Considering the following example:
> > >> >>
> > >> >> root (32G capacity)
> > >> >> --> A (hard limit 20G, soft limit 15G, usage 16G)
> > >> >>    --> A1 (soft limit 5G, usage 4G)
> > >> >>    --> A2 (soft limit 10G, usage 12G)
> > >> >> --> B (hard limit 20G, soft limit 10G, usage 16G)
> > >> >>
> > >> >> Under global reclaim, we shouldn't add pressure on A1 although its parent(A)
> > >> >> exceeds softlimit. This is what admin expects by setting softlimit to the
> > >> >> actual working set size and only reclaim pages under softlimit if system has
> > >> >> trouble to reclaim.
> > >> >
> > >> > Actually, this is exactly what the admin expects when creating a
> > >> > hierarchy, because she defines that A1 is a child of A and is
> > >> > responsible for the memory situation in its parent.
> > >
> > > Hmm, I guess that both approaches have cons and pros.
> > > * Hierarchical soft limit reclaim - reclaim the whole subtree of the over
> > >  soft limit memcg
> > >  + it is consistent with the hard limit reclaim
> > Not sure why we want them to be consistent. Soft_limit is serving
> > different purpose and the one of the main purpose is to preserve the
> > working set of the cgroup.
> 
> I'd argue, given the history of cgroups, one of the main purposes is
> having a machine of containers where you overcommit their hard limit
> and set the soft limit accordingly to provide fairness.
> 
> Yes, we don't want to reclaim hierarchies that are below their soft
> limit as long as there are some in excess, of course.  This is a flaw
> and needs fixing.  But it's something completely different than
> changing how the soft limit is defined and suddenly allow child
> groups, which you may not trust, to override rules defined by parental
> groups.
> 
> It bothers me that we should add something that will almost certainly
> bite us in the future while we are discussing on the cgroups list what
> would stand in the way of getting sane hierarchy semantics across
> controllers to provide consistency, nesting, etc.
> 
> To support a single use case, which I feel we still have not discussed
> nearly enough to justify this change.
> 
> For example, I get that you want 'meta-groups' that group together
> subgroups for common accounting and hard limiting.  But I don't see
> why such meta-groups have their own processes.  Conceptually, I mean,
> how does a process fit into A?  Is it superior to the tasks in A1 and
> A2?  Why can't it live in A3?
> 
> So here is a proposal:
> 
> Would it make sense to try to keep those meta groups always free of
> their own memory so that they don't /need/ soft limits with weird
> semantics?  E.g. immediately free the unused memory on rmdir, OR add
> mechanisms to migrate the memory to a dedicated group:
> 
>      A
>        A1 (soft-limited)
>        A2 (soft-limited)
>      B
>      unused (soft-limited)
> 
> Move all leftover memory from finished jobs to this 'unused' group.
> You could set its soft limit to 0 so that it sticks around only until
> you actually need the memory for something else.
> 
> Then you would get the benefits of accounting and limiting A1 and A2
> under a single umbrella without the need for a soft limit in A.  We
> could keep the consistent semantics for soft limits, because you would
> only have to set it on leaf nodes.
> 
> Wouldn't this work for you?

Or, if the frequency of job creation and completion permits, just keep
the original groups around after completion, set their soft limit to
0, put a watch ("threshold notification") on its usage and reap it
when global pressure finally cleaned it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
