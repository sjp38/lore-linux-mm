Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9E026B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:50:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so865513edo.8
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 05:50:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b11-v6si1107202edf.140.2018.06.29.05.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 05:50:18 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5TCeAJS011700
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:50:16 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jwm41arpy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:50:16 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 29 Jun 2018 08:50:14 -0400
Date: Fri, 29 Jun 2018 05:52:18 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629090419.GD13860@dhcp22.suse.cz>
Message-Id: <20180629125218.GX3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Jun 29, 2018 at 11:04:19AM +0200, Michal Hocko wrote:
> On Thu 28-06-18 14:31:05, Paul E. McKenney wrote:
> > On Thu, Jun 28, 2018 at 01:39:42PM +0200, Michal Hocko wrote:
> > > On Wed 27-06-18 07:31:25, Paul E. McKenney wrote:
> > > > On Wed, Jun 27, 2018 at 09:22:07AM +0200, Michal Hocko wrote:
> > > > > On Tue 26-06-18 10:03:45, Paul E. McKenney wrote:
> > > > > [...]
> > > > > > 3.	Something else?
> > > > > 
> > > > > How hard it would be to use a different API than oom notifiers? E.g. a
> > > > > shrinker which just kicks all the pending callbacks if the reclaim
> > > > > priority reaches low values (e.g. 0)?
> > > > 
> > > > Beats me.  What is a shrinker?  ;-)
> > > 
> > > This is a generich mechanism to reclaim memory that is not on standard
> > > LRU lists. Lwn.net surely has some nice coverage (e.g.
> > > https://lwn.net/Articles/548092/).
> > 
> > "In addition, there is little agreement over what a call to a shrinker
> > really means or how the called subsystem should respond."  ;-)
> > 
> > Is this set up using register_shrinker() in mm/vmscan.c?  I am guessing
> 
> Yes, exactly. You are supposed to implement the two methods in struct
> shrink_control
> 
> > that the many mentions of shrinker in DRM are irrelevant.
> > 
> > If my guess is correct, the API seems a poor fit for RCU.  I can
> > produce an approximate number of RCU callbacks for ->count_objects(),
> > but a given callback might free a lot of memory or none at all.  Plus,
> > to actually have ->scan_objects() free them before returning, I would
> > need to use something like rcu_barrier(), which might involve longer
> > delays than desired.`
> 
> Well, I am not yet sure how good fit this is because I still do not
> understand the underlying problem your notifier is trying to solve. So I
> will get back to this once that is settled.
> > 
> > Or am I missing something here?
> > 
> > > > More seriously, could you please point me at an exemplary shrinker
> > > > use case so I can see what is involved?
> > > 
> > > Well, I am not really sure what is the objective of the oom notifier to
> > > point you to the right direction. IIUC you just want to kick callbacks
> > > to be handled sooner under a heavy memory pressure, right? How is that
> > > achieved? Kick a worker?
> > 
> > That is achieved by enqueuing a non-lazy callback on each CPU's callback
> > list, but only for those CPUs having non-empty lists.  This causes
> > CPUs with lists containing only lazy callbacks to be more aggressive,
> > in particular, it prevents such CPUs from hanging out idle for seconds
> > at a time while they have callbacks on their lists.
> > 
> > The enqueuing happens via an IPI to the CPU in question.
> 
> I am afraid this is too low level for my to understand what is going on
> here. What are lazy callbacks and why do they need any specific action
> when we are getting close to OOM? I mean, I do understand that we might
> have many callers of call_rcu and free memory lazily. But there is quite
> a long way before we start the reclaim until we reach the OOM killer path.
> So why don't those callbacks get called during that time period? How are
> their triggered when we are not hitting the OOM path? They surely cannot
> sit there for ever, right? Can we trigger them sooner? Maybe the
> shrinker is not the best fit but we have a retry feedback loop in the page
> allocator, maybe we can kick this processing from there.

The effect of RCU's current OOM code is to speed up callback invocation
by at most a few seconds (assuming no stalled CPUs, in which case
it is not possible to speed up callback invocation).

Given that, I should just remove RCU's OOM code entirely?

							Thanx, Paul
