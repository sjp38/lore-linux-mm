Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 942B56B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 08:19:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so50813503wma.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 05:19:13 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id m193si7097363wmd.4.2016.11.30.05.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 05:19:12 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id jb2so22171291wjb.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 05:19:12 -0800 (PST)
Date: Wed, 30 Nov 2016 14:19:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161130131910.GF18432@dhcp22.suse.cz>
References: <20161121141818.GD18112@dhcp22.suse.cz>
 <20161121142901.GV3612@linux.vnet.ibm.com>
 <68025f6c-6801-ab46-b0fc-a9407353d8ce@molgen.mpg.de>
 <20161124101525.GB20668@dhcp22.suse.cz>
 <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130115320.GO3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed 30-11-16 03:53:20, Paul E. McKenney wrote:
> On Wed, Nov 30, 2016 at 12:09:44PM +0100, Michal Hocko wrote:
> > [CCing Paul]
> > 
> > On Wed 30-11-16 11:28:34, Donald Buczek wrote:
> > [...]
> > > shrink_active_list gets and releases the spinlock and calls cond_resched().
> > > This should give other tasks a chance to run. Just as an experiment, I'm
> > > trying
> > > 
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1921,7 +1921,7 @@ static void shrink_active_list(unsigned long
> > > nr_to_scan,
> > >         spin_unlock_irq(&pgdat->lru_lock);
> > > 
> > >         while (!list_empty(&l_hold)) {
> > > -               cond_resched();
> > > +               cond_resched_rcu_qs();
> > >                 page = lru_to_page(&l_hold);
> > >                 list_del(&page->lru);
> > > 
> > > and didn't hit a rcu_sched warning for >21 hours uptime now. We'll see.
> > 
> > This is really interesting! Is it possible that the RCU stall detector
> > is somehow confused?
> 
> No, it is not confused.  Again, cond_resched() is not a quiescent
> state unless it does a context switch.  Therefore, if the task running
> in that loop was the only runnable task on its CPU, cond_resched()
> would -never- provide RCU with a quiescent state.

Sorry for being dense here. But why cannot we hide the QS handling into
cond_resched()? I mean doesn't every current usage of cond_resched
suffer from the same problem wrt RCU stalls?

> In contrast, cond_resched_rcu_qs() unconditionally provides RCU
> with a quiescent state (hence the _rcu_qs in its name), regardless
> of whether or not a context switch happens.
> 
> It is therefore expected behavior that this change might prevent
> RCU CPU stall warnings.
> 
> 							Thanx, Paul

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
