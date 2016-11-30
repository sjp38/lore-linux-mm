Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A04E6B0277
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:34:37 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so52187185wma.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:34:37 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g8si64923645wje.166.2016.11.30.09.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 09:34:36 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so30335472wmu.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:34:35 -0800 (PST)
Date: Wed, 30 Nov 2016 18:34:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161130173433.GL18432@dhcp22.suse.cz>
References: <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130172355.GA3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130172355.GA3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed 30-11-16 09:23:55, Paul E. McKenney wrote:
> On Wed, Nov 30, 2016 at 06:05:57PM +0100, Michal Hocko wrote:
> > On Wed 30-11-16 17:38:20, Peter Zijlstra wrote:
> > > On Wed, Nov 30, 2016 at 06:29:55AM -0800, Paul E. McKenney wrote:
> > > > We can, and you are correct that cond_resched() does not unconditionally
> > > > supply RCU quiescent states, and never has.  Last time I tried to add
> > > > cond_resched_rcu_qs() semantics to cond_resched(), I got told "no",
> > > > but perhaps it is time to try again.
> > > 
> > > Well, you got told: "ARRGH my benchmark goes all regress", or something
> > > along those lines. Didn't we recently dig out those commits for some
> > > reason or other?
> > > 
> > > Finding out what benchmark that was and running it against this patch
> > > would make sense.
> > > 
> > > Also, I seem to have missed, why are we going through this again?
> > 
> > Well, the point I've brought that up is because having basically two
> > APIs for cond_resched is more than confusing. Basically all longer in
> > kernel loops do cond_resched() but it seems that this will not help the
> > silence RCU lockup detector in rare cases where nothing really wants to
> > schedule. I am really not sure whether we want to sprinkle
> > cond_resched_rcu_qs at random places just to silence RCU detector...
> 
> Just in case there is any doubt on this point, any patch of mine adding
> cond_resched_rcu_qs() functionality to cond_resched() cannot go upstream
> without Peter's Acked-by.

Yeah, that is clear to me. I just wanted to clarify the "why are we
going through this again" part ;)
 
> Or did you have some other solution in mind?

Not really. The fact that cond_resched() cannot silence RCU stall
detector under some circumstances is sad. I believe we shouldn't
have two different APIs to control scheduling and RCU latencies because
that just asks for whack a mole games and some level of confusion...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
