Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6F3306B0034
	for <linux-mm@kvack.org>; Thu, 30 May 2013 11:12:25 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hi5so4666852wib.12
        for <linux-mm@kvack.org>; Thu, 30 May 2013 08:12:23 -0700 (PDT)
Date: Thu, 30 May 2013 17:12:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/9] memcg: use css_get/put when charging/uncharging kmem
Message-ID: <20130530151220.GB18155@dhcp22.suse.cz>
References: <5195D5F8.7000609@huawei.com>
 <5195D666.6030408@huawei.com>
 <20130517180822.GC12632@mtj.dyndns.org>
 <519C838B.9060609@huawei.com>
 <20130524075420.GA24813@dhcp22.suse.cz>
 <20130530054852.GA9305@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130530054852.GA9305@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Thu 30-05-13 14:48:52, Tejun Heo wrote:
> Hello,
> 
> Sorry about the delay.  Have been and still am traveling.
> 
> On Fri, May 24, 2013 at 09:54:20AM +0200, Michal Hocko wrote:
> > > > On Fri, May 17, 2013 at 03:04:06PM +0800, Li Zefan wrote:
> > > >> +	/*
> > > >> +	 * Releases a reference taken in kmem_cgroup_css_offline in case
> > > >> +	 * this last uncharge is racing with the offlining code or it is
> > > >> +	 * outliving the memcg existence.
> > > >> +	 *
> > > >> +	 * The memory barrier imposed by test&clear is paired with the
> > > >> +	 * explicit one in kmem_cgroup_css_offline.
> > > > 
> > > > Paired with the wmb to achieve what?
> > 
> > https://lkml.org/lkml/2013/4/4/190
> > "
> > ! > +	css_get(&memcg->css);
> > ! I think that you need a write memory barrier here because css_get
> > ! nor memcg_kmem_mark_dead implies it. memcg_uncharge_kmem uses
> > ! memcg_kmem_test_and_clear_dead which imply a full memory barrier but it
> > ! should see the elevated reference count. No?
> > ! 
> > ! > +	/*
> > ! > +	 * We need to call css_get() first, because memcg_uncharge_kmem()
> > ! > +	 * will call css_put() if it sees the memcg is dead.
> > ! > +	 */
> > ! >  	memcg_kmem_mark_dead(memcg);
> > "
> > 
> > Does it make sense to you Tejun?
> 
> Yeah, you're right.  We need them.  It's still a bummer that mark_dead
> has the appearance of proper encapsulation while not really taking
> care of synchronization. 

No objection to put barrier there. You are right it is more natural.

> I think it'd make more sense for mark_dead to have the barrier (which
> BTW should probably be smp_wmb() instead of wmb())

Yes, smp_wmb sounds like a better fit.

> inside it or for the function to be just open-coded.  More on this
> topic later.
>
> > > The comment is wrong. I'll fix it.
> > 
> > Ohh, right. "Althouth this might sound strange as this path is called from
> > css_offline when the reference might have dropped down to 0 and shouldn't ..."
> > 
> > Sounds better?
> 
> Yeap.
> 
> > > I don't quite like adding a lock not to protect data but just ensure code
> > > orders.
> > 
> > Agreed.
> > 
> > > Michal, what's your preference? I want to be sure that everyone is happy
> > > so the next version will hopefully be the last version.
> > 
> > I still do not see why the barrier is not needed and the lock seems too
> > big hammer.
> 
> Yes, the barrier is necessary but I still think it's unnecessarily
> elaborate.  Among the locking constructs, the barriesr are the worst -
> they don't enforce any structures, people often misunderstand / make
> mistakes about them, bugs from misusages are extremely difficult to
> trigger and reproduce especially on x86.  It's a horrible construct
> and should only be used if no other options can meet the performance
> requirements required for the path.

I am all for simplifying the code. I guess it deserves a separate patch
though and it is a bit unrelated to the scope of the series.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
