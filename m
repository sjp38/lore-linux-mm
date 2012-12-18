Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 97CC46B0070
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 11:47:54 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so423669dae.35
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 08:47:53 -0800 (PST)
Date: Tue, 18 Dec 2012 08:47:47 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: don't register hotcpu notifier from ->css_alloc()
Message-ID: <20121218164747.GJ1844@htj.dyndns.org>
References: <20121214012436.GA25481@localhost>
 <20121218154030.GC10220@mtj.dyndns.org>
 <20121218164022.GB25208@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121218164022.GB25208@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hey, Michal.

On Tue, Dec 18, 2012 at 05:40:22PM +0100, Michal Hocko wrote:
> > +/*
> > + * The rest of init is performed during ->css_alloc() for root css which
> > + * happens before initcalls.  hotcpu_notifier() can't be done together as
> > + * it would introduce circular locking by adding cgroup_lock -> cpu hotplug
> > + * dependency.  Do it from a subsys_initcall().
> > + */
> > +static int __init mem_cgroup_init(void)
> > +{
> > +	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> 
> Hmm, we can move enable_swap_cgroup() and per-cpu memcg_stock
> initialization here as well to make the css_alloc a bit cleaner.
> mem_cgroup_soft_limit_tree_init with a trivial BUG_ON() on allocation
> failure can go there as well. 
> 
> I will do it.

The thing was that cgroup_init() happens before any initcalls so
you'll end up with root css being set up before other stuff gets
initialized, which could be okay but a bit nasty.  I'm wondering why
cgroup_init() has to happen so early.  The cpu one is already taking
an early init path, but the rest doesn't seem to need such early init.

Anyways, yeap, no objection to cleaning up anyway which fits memcg.
We can deal with the whole init order thing later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
