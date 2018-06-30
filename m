Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2526B0008
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:03:21 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u1-v6so3291072wrs.18
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:03:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 132-v6si3707141wmi.117.2018.06.30.10.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 10:03:19 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UGweVl079778
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:03:18 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jx3g713th-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:03:17 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 13:03:17 -0400
Date: Sat, 30 Jun 2018 10:05:22 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
 <20180629125218.GX3593@linux.vnet.ibm.com>
 <20180629132638.GD5963@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629132638.GD5963@dhcp22.suse.cz>
Message-Id: <20180630170522.GZ3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Jun 29, 2018 at 03:26:38PM +0200, Michal Hocko wrote:
> On Fri 29-06-18 05:52:18, Paul E. McKenney wrote:
> > On Fri, Jun 29, 2018 at 11:04:19AM +0200, Michal Hocko wrote:
> > > On Thu 28-06-18 14:31:05, Paul E. McKenney wrote:
> > > > On Thu, Jun 28, 2018 at 01:39:42PM +0200, Michal Hocko wrote:
> [...]
> > > > > Well, I am not really sure what is the objective of the oom notifier to
> > > > > point you to the right direction. IIUC you just want to kick callbacks
> > > > > to be handled sooner under a heavy memory pressure, right? How is that
> > > > > achieved? Kick a worker?
> > > > 
> > > > That is achieved by enqueuing a non-lazy callback on each CPU's callback
> > > > list, but only for those CPUs having non-empty lists.  This causes
> > > > CPUs with lists containing only lazy callbacks to be more aggressive,
> > > > in particular, it prevents such CPUs from hanging out idle for seconds
> > > > at a time while they have callbacks on their lists.
> > > > 
> > > > The enqueuing happens via an IPI to the CPU in question.
> > > 
> > > I am afraid this is too low level for my to understand what is going on
> > > here. What are lazy callbacks and why do they need any specific action
> > > when we are getting close to OOM? I mean, I do understand that we might
> > > have many callers of call_rcu and free memory lazily. But there is quite
> > > a long way before we start the reclaim until we reach the OOM killer path.
> > > So why don't those callbacks get called during that time period? How are
> > > their triggered when we are not hitting the OOM path? They surely cannot
> > > sit there for ever, right? Can we trigger them sooner? Maybe the
> > > shrinker is not the best fit but we have a retry feedback loop in the page
> > > allocator, maybe we can kick this processing from there.
> > 
> > The effect of RCU's current OOM code is to speed up callback invocation
> > by at most a few seconds (assuming no stalled CPUs, in which case
> > it is not possible to speed up callback invocation).
> > 
> > Given that, I should just remove RCU's OOM code entirely?
> 
> Yeah, it seems so. I do not see how this would really help much. If we
> really need some way to kick callbacks then we should do so much earlier
> in the reclaim process - e.g. when we start struggling to reclaim any
> memory.

One approach would be to tell RCU "It is time to trade CPU for memory"
at the beginning of that struggle and then tell RCU "Go back to optimizing
for CPU" at the end of that struggle.  Is there already a way to do this?
If so, RCU should probably just switch to it.

But what is the typical duration of such a struggle?  Does this duration
change with workload?  (I suspect that the answers are "who knows?" and
"yes", but you tell me!)  Are there other oom handlers that would prefer
the approach of the previous paragraph?

> I am curious. Has the notifier been motivated by a real world use case
> or it was "nice thing to do"?

It was introduced by b626c1b689364 ("rcu: Provide OOM handler to motivate
lazy RCU callbacks").  The motivation for this commit was a set of changes
that improved energy efficiency by making CPUs sleep for longer when all
of their pending callbacks were known to only free memory (as opposed
to doing a wakeup or some such).  Prior to this set of changes, a CPU
with callbacks would invoke those callbacks (thus freeing the memory)
within a jiffy or so of the end of a grace period.  After this set of
changes, a CPU might wait several seconds.  This was a concern to people
with small-memory systems, hence commit b626c1b689364.

							Thanx, Paul
