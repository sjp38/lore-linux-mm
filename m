Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03AE66B0260
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:39:28 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so1316275wmu.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:39:27 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id e6si46698039wjc.228.2016.12.14.09.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 09:39:26 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id kp2so6046197wjc.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:39:26 -0800 (PST)
Date: Wed, 14 Dec 2016 18:39:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Fw: [lkp-developer] [sched,rcu]  cf7a2dca60: [No primary change]
 +186% will-it-scale.time.involuntary_context_switches
Message-ID: <20161214173923.GA16763@dhcp22.suse.cz>
References: <20161213151408.GC3924@linux.vnet.ibm.com>
 <20161214095425.GE25573@dhcp22.suse.cz>
 <20161214110609.GK3924@linux.vnet.ibm.com>
 <20161214161540.GP25573@dhcp22.suse.cz>
 <20161214164827.GL3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214164827.GL3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org

On Wed 14-12-16 08:48:27, Paul E. McKenney wrote:
> On Wed, Dec 14, 2016 at 05:15:41PM +0100, Michal Hocko wrote:
> > On Wed 14-12-16 03:06:09, Paul E. McKenney wrote:
> > > On Wed, Dec 14, 2016 at 10:54:25AM +0100, Michal Hocko wrote:
> > > > On Tue 13-12-16 07:14:08, Paul E. McKenney wrote:
> > > > > Just FYI for the moment...
> > > > > 
> > > > > So even with the slowed-down checking, making cond_resched() do what
> > > > > cond_resched_rcu_qs() does results in a smallish but quite measurable
> > > > > degradation according to 0day.
> > > > 
> > > > So if I understand those results properly, the reason seems to be the
> > > > increased involuntary context switches, right? Or am I misreading the
> > > > data?
> > > > I am looking at your "sched,rcu: Make cond_resched() provide RCU
> > > > quiescent state" in linux-next and I am wondering whether rcu_all_qs has
> > > > to be called unconditionally and not only when should_resched failed few
> > > > times? I guess you have discussed that with Peter already but do not
> > > > remember the outcome.
> > > 
> > > My first thought is to wait for the grace period to age further before
> > > checking, the idea being to avoid increasing cond_resched() overhead
> > > any further.  But if that doesn't work, then yes, I may have to look at
> > > adding more checks to cond_resched().
> > 
> > This might be really naive but would something like the following work?
> > The overhead should be pretty much negligible, I guess. Ideally the pcp
> > variable could be set somewhere from check_cpu_stall() but I couldn't
> > wrap my head around that code to see how exactly.
> 
> My concern (perhaps misplaced) with this approach is that there are
> quite a few tight loops containing cond_resched().  So I would still
> need to throttle the resulting grace-period acceleration to keep the
> context switches down to a dull roar.

Yes, I see your point. Something based on the stall timeout would be
much better of course. I just failed to come up with something that
would make sense. This was more my lack of familiarity with the code so
I hope you will be more successful ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
