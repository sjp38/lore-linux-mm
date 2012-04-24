Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B51FC6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 16:21:47 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1016353yhr.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 13:21:46 -0700 (PDT)
Date: Tue, 24 Apr 2012 13:21:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 17/23] kmem controller charge/uncharge infrastructure
In-Reply-To: <20120424142232.GC8626@somewhere>
Message-ID: <alpine.DEB.2.00.1204241319360.753@chino.kir.corp.google.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204231522320.13535@chino.kir.corp.google.com> <20120424142232.GC8626@somewhere>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 24 Apr 2012, Frederic Weisbecker wrote:

> > This seems horribly inconsistent with memcg charging of user memory since 
> > it charges to p->mm->owner and you're charging to p.  So a thread attached 
> > to a memcg can charge user memory to one memcg while charging slab to 
> > another memcg?
> 
> Charging to the thread rather than the process seem to me the right behaviour:
> you can have two threads of a same process attached to different cgroups.
> 
> Perhaps it is the user memory memcg that needs to be fixed?
> 

No, because memory is represented by mm_struct, not task_struct, so you 
must charge to p->mm->owner to allow for moving threads amongst memcgs 
later for memory.move_charge_at_immigrate.  You shouldn't be able to 
charge two different memcgs for memory represented by a single mm.

> > > +
> > > +	if (!mem_cgroup_kmem_enabled(memcg))
> > > +		goto out;
> > > +
> > > +	mem_cgroup_get(memcg);
> > > +	ret = memcg_charge_kmem(memcg, gfp, size) == 0;
> > > +	if (ret)
> > > +		mem_cgroup_put(memcg);
> > > +out:
> > > +	rcu_read_unlock();
> > > +	return ret;
> > > +}
> > > +EXPORT_SYMBOL(__mem_cgroup_charge_kmem);
> > > +
> > > +void __mem_cgroup_uncharge_kmem(size_t size)
> > > +{
> > > +	struct mem_cgroup *memcg;
> > > +
> > > +	rcu_read_lock();
> > > +	memcg = mem_cgroup_from_task(current);
> > > +
> > > +	if (!mem_cgroup_kmem_enabled(memcg))
> > > +		goto out;
> > > +
> > > +	mem_cgroup_put(memcg);
> > > +	memcg_uncharge_kmem(memcg, size);
> > > +out:
> > > +	rcu_read_unlock();
> > > +}
> > > +EXPORT_SYMBOL(__mem_cgroup_uncharge_kmem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
