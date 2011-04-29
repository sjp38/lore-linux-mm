Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 31AC3900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 02:26:56 -0400 (EDT)
Date: Fri, 29 Apr 2011 08:26:47 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-ID: <20110429062647.GN12437@cmpxchg.org>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
 <20110428180139.6ec67196.kamezawa.hiroyu@jp.fujitsu.com>
 <20110428123652.GM12437@cmpxchg.org>
 <BANLkTikJxWmF+8P3-pGeyECaDoV01v77Pg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikJxWmF+8P3-pGeyECaDoV01v77Pg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 10:46:07AM -0700, Ying Han wrote:
> On Thu, Apr 28, 2011 at 5:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 1. Limit-triggered direct reclaim
> >
> > The memory cgroup hits its limit and the task does direct reclaim from
> > its own memcg.  We probably want statistics for this separately from
> > background reclaim to see how successful background reclaim is, the
> > same reason we have this separation in the global vmstat as well.
> >
> >        pgscan_direct_limit
> >        pgfree_direct_limit
> 
> Ack.
> >
> > 2. Limit-triggered background reclaim
> >
> > This is the watermark-based asynchroneous reclaim that is currently in
> > discussion.  It's triggered by the memcg breaching its watermark,
> > which is relative to its hard-limit.  I named it kswapd because I
> > still think kswapd should do this job, but it is all open for
> > discussion, obviously.  Treat it as meaning 'background' or
> > 'asynchroneous'.
> >
> >        pgscan_kswapd_limit
> >        pgfree_kswapd_limit
> Ack.
> 
> To clarify, the 1 and 2 only count the reclaim which is due to the
> pressure from the memcg itself.

Yes, limit-triggered implies that.  If you have reclaim going on in a
memcg that is unrelated to the limit, the pressure must be external.

> > 3. Hierarchy-triggered direct reclaim
> >
> > A condition outside the memcg leads to a task directly reclaiming from
> > this memcg.  This could be global memory pressure for example, but
> > also a parent cgroup hitting its limit.  It's probably helpful to
> > assume global memory pressure meaning that the root cgroup hit its
> > limit, conceptually.  We don't have that yet, but this could be the
> > direct softlimit reclaim Ying mentioned above.
> >
> >        pgscan_direct_hierarchy
> >        pgsteal_direct_hierarchy
> 
> For this one, it could be global direct reclaim doing softlimit
> pushback or hierarchical reclaim
> due to the parent hit its hardlimit. It would be nice if we can
> separate them up?

Short-answer: you are able to differentiate between the two by looking
at the memcg.  If the parent is the root cgroup, you know its direct
softlimit reclaim.

Long-answer:

In the paragraph of 3., I suggested that they are conceptually the
same.  If you observe hierarchical pressure on a memcg, you know that
one of the ancestors is in trouble and go up the chain to find which
one has internal pressure.  If the troubled ancestor turns out to be
the root cgroup, you know that it's a physical memory shortness, as
its ownly limit is physical memory.

It can all be described with the memcg-native concept of hierarchy and
the specialness of the root cgroup.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
