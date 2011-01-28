Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BE16F8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 04:02:50 -0500 (EST)
Date: Fri, 28 Jan 2011 10:02:42 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH 2/4] memcg: fix charge path for THP and allow
 early retirement
Message-ID: <20110128090242.GF2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128075724.GB2213@cmpxchg.org>
 <20110128171447.1b5b19f3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128171447.1b5b19f3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 05:14:47PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 28 Jan 2011 08:57:24 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Fri, Jan 28, 2011 at 12:26:08PM +0900, KAMEZAWA Hiroyuki wrote:
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > When THP is used, Hugepage size charge can happen. It's not handled
> > > correctly in mem_cgroup_do_charge(). For example, THP can fallback
> > > to small page allocation when HUGEPAGE allocation seems difficult
> > > or busy, but memory cgroup doesn't understand it and continue to
> > > try HUGEPAGE charging. And the worst thing is memory cgroup
> > > believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.
> > > 
> > > By this, khugepaged etc...can goes into inifinite reclaim loop
> > > if tasks in memcg are busy.
> > > 
> > > After this patch 
> > >  - Hugepage allocation will fail if 1st trial of page reclaim fails.
> > > 
> > > Changelog:
> > >  - make changes small. removed renaming codes.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/memcontrol.c |   28 ++++++++++++++++++++++++----
> > >  1 file changed, 24 insertions(+), 4 deletions(-)
> > 
> > Was there something wrong with my oneline fix?
> > 
> I thought your patch was against RHEL6.

Sorry, this was a misunderstanding.  All three patches I sent
yesterday were based on the latest mmotm.

> > Really, there is no way to make this a beautiful fix.  The way this
> > function is split up makes no sense, and the constant addition of more
> > and more flags just to correctly communicate with _one callsite_
> > should be an obvious hint.
> > 
> 
> Your version has to depend on oom_check flag to work fine.
> I think it's complicated.

I don't understand.  We want to retry when batching fails, but not
when huge page charging fails.  This is exactly what my patch does.

This function has 3 steps:

1. charge
2. reclaim
3. handle out of memory

Between all those steps, there are defined break-out points.  Between
1. and 2. there is the check for batching.  Between 2. and 3. is the
check for whether we should OOM directly or let it be handled by the
caller.

These break points make perferct sense, because when batching we want
to charge but not reclaim.  With huge pages we want to charge,
rcelaim, but not OOM.  This is straight-forward exactly what my
patches implement.  Not by introducing new break points, but by fixing
those that are already there!

I resent your patch because you mess up this logic by moving the break
point between 1. and 2. between 2. and 3. where it is not intuitive to
understand anymore.  And your argument is that you don't want to trust
your own code to function correctly (oom_check).  This is insane.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
