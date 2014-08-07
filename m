Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 423AB6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 10:21:40 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so4192866wgg.28
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 07:21:39 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l1si16336460wif.13.2014.08.07.07.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 07:21:38 -0700 (PDT)
Date: Thu, 7 Aug 2014 10:21:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/4] mm: memcontrol: populate unified hierarchy interface
Message-ID: <20140807142131.GC14734@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <20140805124033.GF15908@dhcp22.suse.cz>
 <20140805135325.GB14734@cmpxchg.org>
 <20140805152740.GI15908@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140805152740.GI15908@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 05, 2014 at 05:27:40PM +0200, Michal Hocko wrote:
> On Tue 05-08-14 09:53:25, Johannes Weiner wrote:
> > On Tue, Aug 05, 2014 at 02:40:33PM +0200, Michal Hocko wrote:
> > > On Mon 04-08-14 17:14:53, Johannes Weiner wrote:
> > > > Hi,
> > > > 
> > > > the ongoing versioning of the cgroup user interface gives us a chance
> > > > to clean up the memcg control interface and fix a lot of
> > > > inconsistencies and ugliness that crept in over time.
> > > 
> > > The first patch doesn't fit into the series and should be posted
> > > separately.
> > 
> > It's a prerequisite for the high limit implementation.
> 
> I do not think it is strictly needed. I am even not sure whether the
> patch is OK and have to think more about it. I think you can throttle
> high limit breachers by SWAP_CLUSTER_MAX for now.

It really doesn't work once you have higher order pages.  THP-heavy
workloads overshoot the high limit by a lot if you reclaim 32 pages
for every 512 charged.

In my tests, with the change in question, even heavily swapping THP
loads consistently stay around the high limit, whereas without it the
memory consumption quickly overshoots.

> > > > This series adds a minimal set of control files to the new memcg
> > > > interface to get basic memcg functionality going in unified hierarchy:
> > > 
> > > Hmm, I have posted RFC for new knobs quite some time ago and the
> > > discussion died without some questions answered and now you are coming
> > > with a new one. I cannot say I would be happy about that.
> > 
> > I remembered open questions mainly about other things like swappiness,
> > charge immigration, kmem limits.  My bad, I should have checked.  Here
> > are your concerns on these basic knobs from that email:
> > 
> > ---
> > 
> > On Thu, Jul 17, 2014 at 03:45:09PM +0200, Michal Hocko wrote:
> > > On Wed 16-07-14 11:58:14, Johannes Weiner wrote:
> > > > How about "memory.current"?
> > > 
> > > I wanted old users to change the minimum possible when moving to unified
> > > hierarchy so I didn't touch the old names.
> > > Why should we make the end users life harder? If there is general
> > > agreement I have no problem with renaming I just do not think it is
> > > really necessary because there is no real reason why configurations
> > > which do not use any of the deprecated or unified-hierarchy-only
> > > features shouldn't run in both unified and legacy hierarchies without
> > > any changes.
> > 
> > There is the rub, though: you can't *not* use new interfaces.  We are
> > getting rid of the hard limit as the default and we really want people
> > to rethink their configuration in the light of this.  And even if you
> > would just use the hard limit as before, there is no way we can leave
> > the name 'memory.limit_in_bytes' when we have in fact 4 different
> > limits.
> 
> We could theoretically keep a single limit and turn other limits into
> watermarks. I am _not_ suggesting that now because I haven't thought
> that through but I just think we should discuss other possible ways
> before we go on.

I am definitely open to discuss your alternative suggestions, but for
that you have to actually propose them. :)

The reason why I want existing users to rethink the approach to memory
limiting is that the current hard limit completely fails to partition
and isolate in a practical manner, and we are changing the fundamental
approach here.  Pretending to provide backward compatibility through
the names of control knobs is specious, and will lead to more issues
than it actually solves.

> > > One of the concern was renaming knobs which represent the same
> > > functionality as before. I have posted some concerns but haven't heard
> > > back anything. This series doesn't give any rationale for renaming
> > > either.
> > > It is true we have a v2 but that doesn't necessarily mean we should put
> > > everything upside down.
> > 
> > I'm certainly not going out of my way to turn things upside down, but
> > the old interface is outrageous.  I'm sorry if you can't see that it
> > badly needs to be cleaned up and fixed.  This is the time to do that.
> 
> Of course I can see many problems. But please let's think twice and even
> more times when doing radical changes. Many decisions sound reasonable
> at the time but then they turn out bad much later.

These are radical changes, and I'm sorry that my justifications were
very terse.  I've updated this patch to include the following in
Documentation/cgroups/unified-hierarchy.txt:

---

4-3-3. memory

Memory cgroups account and limit the memory consumption of cgroups,
but the current limit semantics make the feature hard to use and
creates problems in existing configurations.

4.3.3.1 No more default hard limit

'memory.limit_in_bytes' is the current upper limit that can not be
exceeded under any circumstances.  If it can not be met by direct
reclaim, the tasks in the cgroup are OOM killed.

While this may look like a valid approach to partition the machine, in
practice workloads expand and contract during runtime, and it's
impossible to get the machine-wide configuration right: if users set
this hard limit conservatively, they are plagued by cgroup-internal
OOM kills while another group's memory might be idle.  If they set it
too generously, precious resources are wasted.  As a result, many
users overcommit such that the sum of all hard limits exceed the
machine size, but this puts the actual burden of containment on global
reclaim and OOM handling.  This led to further extremes, such as the
demand for having global reclaim honor group-specific priorities and
minimums, and the ability to handle global OOM situations from
userspace using task-specific physical memory reserves.  All these
outcomes and developments show the utter failure of hard limits to
practically partition the machine for maximum resource utilization.

In unified hierarchy, the primary means of limiting memory consumption
is 'memory.high'.  It's enforced by direct reclaim but can be exceeded
under severe memory pressure.  Memory pressure created by this limit
still applies mainly to the group itself, but it prefers offloading
the excess to the rest of the system in order to avoid OOM killing.
Configurations can start out by setting this limit to a conservative
estimate of the average workload size and then make upward adjustments
based on monitoring high limit excess, workload performance, and the
global memory situation.

In untrusted environments, users may wish to limit the amount of such
offloading in order to contain malicious workloads.  For that purpose,
a hard upper limit can be set through 'memory.max'.

'memory.pressure_level' was added for userspace to monitor memory
pressure based on reclaim efficiency, but the window between initial
memory pressure and an OOM kill is very short with hard limits.  By
the time high pressure is reported to userspace it's often too late to
still intervene before the group goes OOM, thus severely limiting the
usefulness of this feature for anticipating looming OOM situations.

This new approach to limiting allows packing workloads more densely
based on their average workingset size.  Coinciding peaks of multiple
groups are handled by throttling allocations within the groups rather
than putting the full burden on global reclaim and OOM handling, and
pressure situations build up gracefully and allow better monitoring.

---

> > > > - memory.current: a read-only file that shows current memory usage.
> > > 
> > > Even if we go with renaming existing knobs I really hate this name. The
> > > old one was too long but this is not descriptive enough. Same applies to
> > > max and high. I would expect at least limit in the name.
> > 
> > Memory cgroups are about accounting and limiting memory usage.  That's
> > all they do.  In that context, current, min, low, high, max seem
> > perfectly descriptive to me, adding usage and limit seems redundant.
> 
> Getting naming right is always pain and different people will always
> have different views. For example I really do not like memory.current
> and would prefer memory.usage much more. I am not a native speaker but
> `usage' sounds much less ambiguous to me. Whether shorter (without _limit
> suffix) names for limits are better I don't know. They certainly seem
> more descriptive with the suffix to me.

These knobs control the most fundamental behavior of memory cgroups,
which is accounting and then limiting memory consumption, so I think
we can agree at least that we want something short and poignant here
that stands out compared to secondary controls, feature toggles etc.

The reason I went with memory.current over memory.usage is that it's
more consistent with the limit names I chose, which is memory.high and
memory.max.  Going with memory.usage begs the question what memory.max
applies to, and now you need to add 'usage' or 'limit' to high/max as
well (and 'guarantee' to min/low), which moves us away from short and
poignant towards more specific niche control names.  memory.current,
memory.high, memory.max all imply the same thing: memory consumption -
what memory cgroups is fundamentally about.

> > We name syscalls creat() and open() and stat() because, while you have
> > to look at the manpage once, they are easy to remember, easy to type,
> > and they keep the code using them readable.
> >
> > memory.usage_in_bytes was the opposite approach: it tried to describe
> > all there is to this knob in the name itself, assuming tab completion
> > would help you type that long name.  But we are more and more moving
> > away from ad-hoc scripting of cgroups and I don't want to optimize for
> > that anymore at the cost of really unwieldy identifiers.
> 
> I agree with you. _in_bytes is definitely excessive. It can be nicely
> demonstrated by the fact that different units are allowed when setting
> the value.

It's maybe misleading for that reason, but that wasn't my main point.

There are certain things we can imply in the name and either explain
in the documentation or assume from the context, and _in_bytes is one
such piece of information.  It's something that you need to know once
and don't need to be reminded of everytime you type that control name.

Likewise, I'm extending this argument that we don't need to include
'usage' or 'limit' in any of these basic knobs, because that's *the*
thing that memory cgroups do.  It's up to secondary controls to pick
names that do not create ambiguity with those core controls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
