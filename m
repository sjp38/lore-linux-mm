Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4256E6B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 17:29:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w138-v6so5629wmw.4
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:29:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j10-v6si914549wrh.398.2018.06.28.14.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 14:29:05 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5SLT2Cb142616
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 17:29:03 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jw7ak8nq1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 17:29:03 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 Jun 2018 17:29:03 -0400
Date: Thu, 28 Jun 2018 14:31:05 -0700
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628113942.GD32348@dhcp22.suse.cz>
Message-Id: <20180628213105.GP3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, Jun 28, 2018 at 01:39:42PM +0200, Michal Hocko wrote:
> On Wed 27-06-18 07:31:25, Paul E. McKenney wrote:
> > On Wed, Jun 27, 2018 at 09:22:07AM +0200, Michal Hocko wrote:
> > > On Tue 26-06-18 10:03:45, Paul E. McKenney wrote:
> > > [...]
> > > > 3.	Something else?
> > > 
> > > How hard it would be to use a different API than oom notifiers? E.g. a
> > > shrinker which just kicks all the pending callbacks if the reclaim
> > > priority reaches low values (e.g. 0)?
> > 
> > Beats me.  What is a shrinker?  ;-)
> 
> This is a generich mechanism to reclaim memory that is not on standard
> LRU lists. Lwn.net surely has some nice coverage (e.g.
> https://lwn.net/Articles/548092/).

"In addition, there is little agreement over what a call to a shrinker
really means or how the called subsystem should respond."  ;-)

Is this set up using register_shrinker() in mm/vmscan.c?  I am guessing
that the many mentions of shrinker in DRM are irrelevant.

If my guess is correct, the API seems a poor fit for RCU.  I can
produce an approximate number of RCU callbacks for ->count_objects(),
but a given callback might free a lot of memory or none at all.  Plus,
to actually have ->scan_objects() free them before returning, I would
need to use something like rcu_barrier(), which might involve longer
delays than desired.

Or am I missing something here?

> > More seriously, could you please point me at an exemplary shrinker
> > use case so I can see what is involved?
> 
> Well, I am not really sure what is the objective of the oom notifier to
> point you to the right direction. IIUC you just want to kick callbacks
> to be handled sooner under a heavy memory pressure, right? How is that
> achieved? Kick a worker?

That is achieved by enqueuing a non-lazy callback on each CPU's callback
list, but only for those CPUs having non-empty lists.  This causes
CPUs with lists containing only lazy callbacks to be more aggressive,
in particular, it prevents such CPUs from hanging out idle for seconds
at a time while they have callbacks on their lists.

The enqueuing happens via an IPI to the CPU in question.

						Thanx, Paul
